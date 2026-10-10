import GiftUI

/// Holds both actual backing borrows for the complete activation callback. The
/// generic result is Escapable, so neither a scope nor a ticket can be returned.
package func withObservableModelScope<Model: ~Copyable, Schema, Result>(
    ownership: inout ObservableModelOwnership,
    models: inout MutableSpan<Model?>,
    schema: UInt16, needsCapture: Bool,
    _ body: (borrowing ObservableModelScope<Model, Schema>) throws(ObservableStateError) -> Result
) throws(ObservableStateError) -> Result {
    guard models.count == 2 else { throw .modelCapacityExhausted }
    return try withUnsafeMutablePointer(to: &ownership) { (owner) throws(ObservableStateError) in
        try models.withUnsafeMutableBufferPointer { (buffer) throws(ObservableStateError) in
            let scope = ObservableModelScope<Model, Schema>(
                ownership: owner, models: buffer, schema: schema, needsCapture: needsCapture)
            return try body(scope)
        }
    }
}

package struct ObservableModelScope<Model: ~Copyable, Schema>: ~Copyable, ~Escapable {
    private let ownership: UnsafeMutablePointer<ObservableModelOwnership>
    private let models: UnsafeMutableBufferPointer<Model?>
    private let schema: UInt16
    private let needsCapture: Bool

    // The private factory is called inside both owning storage borrows above.
    // Borrowing these descriptors alone is not the backing-lifetime proof.
    @_lifetime(borrow ownership, borrow models)
    fileprivate init(
        ownership: borrowing UnsafeMutablePointer<ObservableModelOwnership>,
        models: borrowing UnsafeMutableBufferPointer<Model?>, schema: UInt16, needsCapture: Bool
    ) {
        self.ownership = copy ownership
        self.models = copy models
        self.schema = schema
        self.needsCapture = needsCapture
    }

    @_lifetime(copy self)
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

    package borrowing func release(_ ticket: inout ObservableModelTicket<Schema>)
        throws(ObservableStateError)
    {
        if let failure = ownership.pointee.operationAllowed(discovery: true) { throw failure }
        let claim = try ticket.requireClaim()
        if let slot = try ownership.pointee.release(claim) { models[Int(slot)] = nil }
        ticket.endOwnership()
    }

    package borrowing func register(_ ticket: borrowing ObservableModelTicket<Schema>)
        throws(ObservableStateError)
    {
        if let failure = ownership.pointee.operationAllowed(discovery: true) { throw failure }
        try ownership.pointee.register(ticket.requireClaim().address, schema: schema)
    }

    package borrowing func unregister(_ key: _GiftUIModelKey<Schema>) throws(ObservableStateError) {
        if let slot = try ownership.pointee.unregister(ownership.pointee.address(for: key)) {
            models[Int(slot)] = nil
        }
    }

    package borrowing func withFrame<Result>(
        _ body: () throws(ObservableStateError) -> Result
    ) throws(ObservableStateError) -> Result {
        try ownership.pointee.beginFrame()
        do {
            let result = try body()
            try ownership.pointee.endFrame { models[Int($0)] = nil }
            return result
        } catch {
            // Cleanup cannot replace the first operation failure.
            try? ownership.pointee.endFrame { models[Int($0)] = nil }
            throw error
        }
    }

    package borrowing func pin(_ key: _GiftUIModelKey<Schema>) throws(ObservableStateError) {
        try ownership.pointee.pin(ownership.pointee.address(for: key))
    }

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
