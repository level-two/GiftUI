import GiftUI

/// Holds both actual backing borrows for the complete activation callback. The
/// generic result is Escapable, so neither a scope nor a ticket can be returned.
@inlinable
package func withObservableModelScope<Model: ~Copyable, Schema, Result>(
    ownership: inout ObservableModelOwnership,
    models: inout MutableSpan<Model?>,
    schema: UInt16, needsCapture: Bool,
    _ body: (borrowing ObservableModelScope<Model, Schema>) throws(ObservableStateError) -> Result
) throws(ObservableStateError) -> Result {
    if let failure = ownership.operationAllowed() { throw failure }
    guard models.count == 2 else { throw .modelCapacityExhausted }
    return try withUnsafeMutablePointer(to: &ownership) { (owner) throws(ObservableStateError) in
        try models.withUnsafeMutableBufferPointer { (buffer) throws(ObservableStateError) in
            let scope = ObservableModelScope<Model, Schema>(
                ownership: owner, models: buffer, schema: schema, needsCapture: needsCapture)
            defer { scope.finishActivation() }
            return try body(scope)
        }
    }
}

@usableFromInline
package struct ObservableModelScope<Model: ~Copyable, Schema>: ~Copyable, ~Escapable {
    @usableFromInline let ownership: UnsafeMutablePointer<ObservableModelOwnership>
    @usableFromInline let models: UnsafeMutableBufferPointer<Model?>
    @usableFromInline let schema: UInt16
    @usableFromInline let needsCapture: Bool

    // The private factory is called inside both owning storage borrows above.
    // Borrowing these descriptors alone is not the backing-lifetime proof.
    @_lifetime(borrow ownership, borrow models)
    @inlinable
    @inline(__always)
    init(
        ownership: borrowing UnsafeMutablePointer<ObservableModelOwnership>,
        models: borrowing UnsafeMutableBufferPointer<Model?>, schema: UInt16, needsCapture: Bool
    ) {
        self.ownership = copy ownership
        self.models = copy models
        self.schema = schema
        self.needsCapture = needsCapture
    }

    @_lifetime(copy self)
    @inlinable
    package borrowing func borrowedScope() -> ObservableModelScope<Model, Schema> {
        ObservableModelScope(borrowing: self)
    }

    @_lifetime(copy other)
    @inlinable
    @inline(__always)
    init(borrowing other: borrowing ObservableModelScope<Model, Schema>) {
        ownership = other.ownership
        models = other.models
        schema = other.schema
        needsCapture = other.needsCapture
    }

    // Concrete joins must match the actual owner backing, not merely a schema
    // or a numeric identity issued by a different namespace.
    @inlinable
    package borrowing func sharesOwner(with other: borrowing ObservableModelScope<Model, Schema>)
        -> Bool
    {
        ownership == other.ownership && models.baseAddress == other.models.baseAddress
            && schema == other.schema
    }

    @inlinable
    package borrowing func validateTicket(_ ticket: borrowing ObservableModelTicket<Schema>)
        throws(ObservableStateError)
    {
        _ = try ownership.pointee.validatedClaim(ticket.requireClaim(), schema: schema)
    }

    @inlinable
    package borrowing func validateAssociation(_ key: _GiftUIModelKey<Schema>)
        throws(ObservableStateError)
    {
        try ownership.pointee.validateAssociation(
            ownership.pointee.address(for: key), schema: schema)
    }

    @inlinable
    package borrowing func validateOperation(discovery: Bool = false) throws(ObservableStateError) {
        if let failure = ownership.pointee.operationAllowed(discovery: discovery) { throw failure }
    }

    @inlinable
    package var phase: ObservableModelOwnership.Phase { ownership.pointee.phase }

    @inlinable
    package borrowing func requireStop() { ownership.pointee.retireActivation() }

    // Called before the root report-storage borrow ends, even if an independent
    // ticket survives a failed detach. Terminal activation cannot be reopened.
    @inlinable
    package borrowing func finishStoppedActivation() {
        if ownership.pointee.phase == .retired { finishActivation() }
    }

    @inlinable
    borrowing func finishActivation() {
        let occupied = ownership.pointee.finishActivation()
        for index in 0 ..< models.count where occupied & (1 << index) != 0 {
            models[index] = nil
        }
    }

    @inlinable
    package borrowing func attach(
        _ key: _GiftUIModelKey<Schema>, sink: consuming _GiftUIObservableChangeSink
    ) throws(ObservableStateError) -> _GiftUIObservationAttachment?
    where Model: ObservableStateModel, Model.Schema == Schema {
        let index = try ownership.pointee.callbackIndex(
            ownership.pointee.address(for: key), schema: schema)
        guard models[index] != nil else { throw .invariantViolation }
        return models[index]!.attach(consume sink)
    }

    @inlinable
    package borrowing func detach(
        _ key: _GiftUIModelKey<Schema>, attachment: _GiftUIObservationAttachment
    ) throws(ObservableStateError)
    where Model: ObservableStateModel, Model.Schema == Schema {
        let index = try ownership.pointee.callbackIndex(
            ownership.pointee.address(for: key), schema: schema)
        guard models[index] != nil, models[index]!.detach(attachment) else {
            throw .invariantViolation
        }
    }

    @inlinable
    package borrowing func report(_ key: _GiftUIModelKey<Schema>)
        -> _GiftUIObservableChangeReportOutcome
    where Model: ObservableStateModel, Model.Schema == Schema {
        if phase == .retired { return .invalidPhaseSafetyNotProven }
        do throws(ObservableStateError) {
            let index = try ownership.pointee.callbackIndex(
                ownership.pointee.address(for: key), schema: schema)
            guard models[index] != nil else { return .invariantViolation }
            return models[index]!.reportChange()
        } catch { return .invariantViolation }
    }

    package borrowing func stageReplacement(
        transferring ticket: borrowing ObservableModelTicket<Schema>, seed: Schema.Seed,
        registrationAvailable: Bool, stagingAvailable: Bool
    ) throws(ObservableStateError) -> ObservableModelOwnership.Replacement
    where Model: ObservableStateModel, Model.Schema == Schema {
        let model = Model.materialize(seed)
        let reservation = try ownership.pointee.reserveReplacement(
            transferring: ticket.requireClaim(), schema: schema,
            candidateIsEmpty: model.isEmptyReplacement,
            registrationAvailable: registrationAvailable, stagingAvailable: stagingAvailable)
        models[Int(reservation.candidate.slot)] = consume model
        return reservation
    }

    package borrowing func discardReplacement(_ reservation: ObservableModelOwnership.Replacement)
        throws(ObservableStateError)
    {
        _ = try ownership.pointee.finishReplacement(reservation, commit: false)
        models[Int(reservation.candidate.slot)] = nil
    }

    @_lifetime(copy self)
    package borrowing func commitReplacement(
        _ reservation: ObservableModelOwnership.Replacement,
        transferring ticket: inout ObservableModelTicket<Schema>
    ) throws(ObservableStateError) -> ObservableModelTicket<Schema> {
        guard try ticket.requireClaim().address == reservation.former else { throw .staleModel }
        guard let claim = try ownership.pointee.finishReplacement(reservation, commit: true) else {
            throw .invariantViolation
        }
        ticket.endOwnership()
        models[Int(reservation.former.slot)] = nil
        return ObservableModelTicket(claim: claim, lifetime: self)
    }

    @usableFromInline
    package borrowing func key(for address: ObservableModelOwnership.Address) -> _GiftUIModelKey<
        Schema
    > {
        ownership.pointee.key(for: address, as: Schema.self)
    }

    @_lifetime(copy self)
    @inlinable
    @inline(__always)
    package borrowing func materialize(_ seed: consuming Model) throws(ObservableStateError)
        -> ObservableModelTicket<Schema>
    {
        let claim = try ownership.pointee.materialize(schema: schema, needsCapture: needsCapture)
        models[Int(claim.address.slot)] = consume seed
        return ObservableModelTicket(claim: claim, lifetime: self)
    }

    @_lifetime(copy self)
    package borrowing func retain(_ key: _GiftUIModelKey<Schema>) throws(ObservableStateError)
        -> ObservableModelTicket<Schema>
    {
        let claim = try ownership.pointee.retain(ownership.pointee.address(for: key))
        return ObservableModelTicket(claim: claim, lifetime: self)
    }

    @inlinable
    package borrowing func release(_ ticket: inout ObservableModelTicket<Schema>)
        throws(ObservableStateError)
    {
        if let failure = ownership.pointee.operationAllowed(discovery: true) { throw failure }
        let claim = try ticket.requireClaim()
        if let slot = try ownership.pointee.release(claim) { models[Int(slot)] = nil }
        ticket.endOwnership()
    }

    @inlinable
    package borrowing func register(_ ticket: borrowing ObservableModelTicket<Schema>)
        throws(ObservableStateError)
    {
        if let failure = ownership.pointee.operationAllowed(discovery: true) { throw failure }
        try ownership.pointee.register(ticket.requireClaim().address, schema: schema)
    }

    @inlinable
    package borrowing func unregister(_ key: _GiftUIModelKey<Schema>) throws(ObservableStateError) {
        if let slot = try ownership.pointee.unregister(ownership.pointee.address(for: key)) {
            models[Int(slot)] = nil
        }
    }

    @inlinable
    @inline(__always)
    package borrowing func withDiscovery<Result>(
        _ body: () throws(ObservableStateError) -> Result
    ) throws(ObservableStateError) -> Result {
        try ownership.pointee.beginDiscovery()
        defer { try? ownership.pointee.endDiscovery() }
        return try body()
    }

    @inlinable
    package borrowing func mutate(
        _ key: _GiftUIModelKey<Schema>, mutation: Model.Mutation,
        report: () -> _GiftUIObservableChangeReportOutcome
    ) -> ObservableStateResult where Model: ObservableModelMutation {
        mutate(key, operation: { mutation }, report: report)
    }

    /// The finite host action operation is constructed only after mutation
    /// authority is acquired; no unchecked model callback is exposed.
    @inlinable
    package borrowing func mutate(
        _ key: _GiftUIModelKey<Schema>, operation: () -> Model.Mutation,
        report: () -> _GiftUIObservableChangeReportOutcome
    ) -> ObservableStateResult where Model: ObservableModelMutation {
        do throws(ObservableStateError) {
            let index = try ownership.pointee.beginMutation(
                ownership.pointee.address(for: key), schema: schema)
            defer { ownership.pointee.endMutation() }
            guard models[index] != nil else { throw .invariantViolation }
            let mutation = operation()
            let prepared = try models[index]!.preflight(mutation)
            // The only mutable model borrow ends before the report route begins.
            let changed = models[index]!.commit(prepared)
            guard changed else { return .success(.unchanged) }
            switch report() {
            case .dirtied: return .success(.dirtied)
            case .coalesced: return .success(.coalesced)
            case .staleAttachment: return .failure(.staleAttachment)
            case .invalidPhaseContained: return .failure(.invalidPhaseContained)
            case .invalidPhaseSafetyNotProven: return .failure(.invalidPhaseSafetyNotProven)
            case .reentrancyViolation: return .failure(.reentrancyViolation)
            case .invariantViolation: return .failure(.invariantViolation)
            }
        } catch { return .failure(error) }
    }

    /// The runtime's staged pipeline keeps the activation scope alive across
    /// these checked transitions. Each successful begin requires one end during
    /// mandatory attempt cleanup; ordinary lexical callers use withFrame.
    package borrowing func beginFrame() throws(ObservableStateError) {
        try ownership.pointee.beginFrame()
    }

    @inlinable
    package borrowing func endFrame() throws(ObservableStateError) {
        try ownership.pointee.endFrame { models[Int($0)] = nil }
    }

    package borrowing func withFrame<Result>(
        _ body: () throws(ObservableStateError) -> Result
    ) throws(ObservableStateError) -> Result {
        try beginFrame()
        do {
            let result = try body()
            try endFrame()
            return result
        } catch {
            // Cleanup cannot replace the first operation failure.
            try? endFrame()
            throw error
        }
    }

    @inlinable
    package borrowing func pin(_ key: _GiftUIModelKey<Schema>) throws(ObservableStateError) {
        try ownership.pointee.pin(ownership.pointee.address(for: key))
    }

    @inlinable
    @inline(__always)
    package borrowing func withRead<D: _GiftUIReadDomain, Result>(
        _ domain: D.Type,
        _ body: (borrowing _GiftUIFrameRead<D>) throws(_GiftUIAccessFailure) -> Result
    ) throws(_GiftUIAccessFailure) -> Result where D.Slot == ObservableModelReadSlot<Model> {
        do { try ownership.pointee.beginRead() } catch { throw .invalidPhase }
        defer { try? ownership.pointee.endRead() }
        let slots: InlineArray<2, ObservableModelReadSlot<Model>> = .init { index in
            ObservableModelReadSlot(
                ownership: UnsafePointer(ownership),
                model: UnsafePointer(models.baseAddress! + index), schema: schema)
        }
        let read = _GiftUIFrameRead<D>(slots: slots.span)
        return try body(read)
    }
}
