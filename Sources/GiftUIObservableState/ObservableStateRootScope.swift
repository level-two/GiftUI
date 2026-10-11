import GiftUI
import GiftUIExecution

/// Registration/dirty storage is separate from model bytes and ownership. The
/// activation factory lends this entire value until all model sinks are retired.
package struct ObservableStateRootStorage<Identity: Equatable & Sendable> {
    struct Record {
        var identity: Identity?
        var ordinal: UInt16 = 0
        var keyOwner: UInt32 = 0
        var keyGeneration: UInt32 = 0
        var attachment: _GiftUIObservationAttachment?
        var published = false
        var encountered = false
    }
    fileprivate var records: InlineArray<2, Record> = .init(repeating: Record())
    fileprivate var reports = ObservableStateRootReports()
    fileprivate var offeredClaims: InlineArray<4, ObservableModelOwnership.Claim?> = .init(
        repeating: nil)
    fileprivate var nextGeneration: UInt32? = 0
    fileprivate var candidateActive = false
    fileprivate var operationActive = false
    fileprivate var retired = false

    package static var storageCapacities:
        (locations: UInt16, registrations: UInt16, associations: UInt16)
    { (2, 2, 2) }

    package static var candidateStorageBytes: Int {
        MemoryLayout<InlineArray<4, ObservableModelOwnership.Claim?>>.size + MemoryLayout<Bool>.size
    }
    package static var liveStorageBytes: Int { MemoryLayout<Self>.size - candidateStorageBytes }

    package init() {}

    // Internal fixture boundary, matching the checked identity cursor controls.
    // Production construction cannot seed or reset the registration namespace.
    init(nextGeneration: UInt32?) {
        self.nextGeneration = nextGeneration
    }

    fileprivate mutating func reserve(_ slot: UInt16) throws(ObservableStateError)
        -> _GiftUIObservationAttachment
    {
        guard let generation = nextGeneration else { throw .registrationGenerationExhausted }
        let successor = generation.addingReportingOverflow(1)
        nextGeneration = successor.overflow ? nil : successor.partialValue
        return _GiftUIObservationAttachment(slot: slot, generation: generation)
    }
}

/// A fixed callback needs no captured generic metadata or heap context. Its
/// pointer is lent independently from model storage for the activation interval.
struct ObservableStateRootReports {
    struct Route {
        var lifecycle = ObservableStateRegistrationLifecycle()
        var dirty = false
    }
    var routes: InlineArray<2, Route> = .init(repeating: Route())
    var mutationReporting = false

    mutating func report(_ attachment: _GiftUIObservationAttachment)
        -> _GiftUIObservableChangeReportOutcome
    {
        guard attachment.slot < 2 else { return .staleAttachment }
        let slot = Int(attachment.slot)
        if let failure = routes[slot].lifecycle.acceptReport(attachment) {
            return failure == .staleAttachment ? .staleAttachment : .invariantViolation
        }
        guard mutationReporting else { return .invalidPhaseSafetyNotProven }
        guard !routes[slot].dirty else { return .coalesced }
        routes[slot].dirty = true
        return .dirtied
    }
}

func reportObservableStateRoot(
    _ context: UnsafeMutableRawPointer, _ slot: UInt16, _ generation: UInt32
) -> UInt8 {
    context.assumingMemoryBound(to: ObservableStateRootReports.self).pointee.report(
        _GiftUIObservationAttachment(slot: slot, generation: generation)
    ).rawValue
}

extension ObservableModelScope
where Model: ObservableStateModel & ~Copyable, Schema == Model.Schema {
    package borrowing func withRoot<Identity: Equatable & Sendable, Result>(
        storage: inout ObservableStateRootStorage<Identity>,
        _ body: (borrowing ObservableStateRootScope<Model, Identity>) throws(ObservableStateError)
            -> Result
    ) throws(ObservableStateError) -> Result {
        // Activation must enclose frame/read/discovery scopes so their defers
        // restore mutation phase before automatic registration retirement.
        // Reject before lending report backing or invoking the caller's body.
        try validateOperation()
        return try withUnsafeMutablePointer(to: &storage) {
            (records) throws(ObservableStateError) in
            try withUnsafeMutablePointer(to: &records.pointee.reports) {
                (reports) throws(ObservableStateError) in
                let root = ObservableStateRootScope(
                    models: borrowedScope(), records: records, reports: reports)
                defer { finishStoppedActivation() }
                do throws(ObservableStateError) {
                    let result = try body(root)
                    try root.shutdown()
                    return result
                } catch {
                    try? root.shutdown()
                    throw error
                }
            }
        }
    }
}

package struct ObservableStateRootScope<
    Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable
>: ~Copyable, ~Escapable {
    private let models: ObservableModelScope<Model, Model.Schema>
    private let records: UnsafeMutablePointer<ObservableStateRootStorage<Identity>>

    private let reports: UnsafeMutablePointer<ObservableStateRootReports>

    @_lifetime(copy models, borrow records, borrow reports)
    fileprivate init(
        models: consuming ObservableModelScope<Model, Model.Schema>,
        records: borrowing UnsafeMutablePointer<ObservableStateRootStorage<Identity>>,
        reports: borrowing UnsafeMutablePointer<ObservableStateRootReports>
    ) {
        self.models = consume models
        self.records = copy records
        self.reports = copy reports
    }

    @_lifetime(copy self)
    package borrowing func borrowedRoot() -> ObservableStateRootScope<Model, Identity> {
        ObservableStateRootScope(borrowing: self)
    }

    @_lifetime(copy other)
    private init(borrowing other: borrowing ObservableStateRootScope<Model, Identity>) {
        models = other.models.borrowedScope()
        records = other.records
        reports = other.reports
    }

    package borrowing func belongs(to scope: borrowing ObservableModelScope<Model, Model.Schema>)
        -> Bool
    {
        models.sharesOwner(with: scope)
    }

    package var isDirty: Bool {
        reports.pointee.routes[0].dirty || reports.pointee.routes[1].dirty
    }

    private borrowing func checkOperation(discovery: Bool = false) throws(ObservableStateError) {
        guard !records.pointee.retired else { throw .invalidPhaseSafetyNotProven }
        guard !records.pointee.operationActive else { throw .reentrancyViolation }
        try models.validateOperation(discovery: discovery)
    }

    package borrowing func beginCandidate() -> ObservableStateResult {
        do throws(ObservableStateError) {
            try checkOperation(discovery: true)
            guard models.phase == .discovering else { throw .invalidPhaseSafetyNotProven }
            guard !records.pointee.candidateActive else { throw .reentrancyViolation }
            records.pointee.candidateActive = true
            for i in 0 ..< 2 { records.pointee.records[i].encountered = false }
            return .success(.candidateStarted)
        } catch { return .failure(error) }
    }

    private borrowing func matching(_ identity: Identity, ordinal: UInt16) -> Int? {
        for i in 0 ..< 2
        where records.pointee.records[i].identity == identity
            && records.pointee.records[i].ordinal == ordinal
        { return i }
        return nil
    }

    private borrowing func key(at slot: Int) -> _GiftUIModelKey<Model.Schema> {
        let record = records.pointee.records[slot]
        return _GiftUIModelKey(
            ownerInstance: record.keyOwner, allocationGeneration: record.keyGeneration,
            slot: UInt16(slot))
    }

    package borrowing func modelKey(identity: Identity, ordinal: UInt16) -> _GiftUIModelKey<
        Model.Schema
    >? {
        guard let slot = matching(identity, ordinal: ordinal),
            records.pointee.records[slot].published
        else { return nil }
        return key(at: slot)
    }

    package borrowing func generation(
        identity: Identity, ordinal: UInt16, publishable: Bool = false
    ) -> UInt32? {
        guard let slot = matching(identity, ordinal: ordinal) else { return nil }
        let record = records.pointee.records[slot]
        if publishable {
            guard records.pointee.candidateActive, record.encountered else { return nil }
        } else if !record.published {
            return nil
        }
        return record.attachment?.generation
    }

    private borrowing func bind(_ state: inout State<Model.Schema>, slot: Int)
        throws(ObservableStateError)
    {
        let record = records.pointee.records[slot]
        guard let attachment = record.attachment else { throw .invariantViolation }
        let binding = _GiftUIBoundState(
            locationSlot: UInt16(slot), declarationOrdinal: record.ordinal,
            registrationGeneration: attachment.generation, key: key(at: slot))
        if let prior = state._giftUIBinding {
            guard prior.locationSlot == binding.locationSlot,
                prior.declarationOrdinal == binding.declarationOrdinal,
                prior.registrationGeneration == binding.registrationGeneration,
                prior.key == binding.key
            else {
                throw .staleModel
            }
        } else {
            state._giftUIBind(binding)
        }
    }

    private borrowing func preserved(
        _ identity: Identity, ordinal: UInt16, state: inout State<Model.Schema>
    ) throws(ObservableStateError) -> Bool {
        try checkOperation(discovery: true)
        guard models.phase == .discovering, records.pointee.candidateActive else {
            throw .invalidPhaseSafetyNotProven
        }
        guard let slot = matching(identity, ordinal: ordinal) else { return false }
        try models.pin(key(at: slot))
        try bind(&state, slot: slot)
        records.pointee.records[slot].encountered = true
        return true
    }

    package borrowing func encounter(
        identity: Identity, ordinal: UInt16, state: inout State<Model.Schema>
    ) -> ObservableStateResult {
        do throws(ObservableStateError) {
            if try preserved(identity, ordinal: ordinal, state: &state) {
                return .success(.preserved)
            }
            if case .candidate(let key)? = state._giftUIInitial {
                for i in 0 ..< 4 {
                    guard let claim = records.pointee.offeredClaims[i],
                        models.key(for: claim.address) == key
                    else { continue }
                    var ticket = ObservableModelTicket<Model.Schema>(claim: claim, lifetime: models)
                    try install(identity, ordinal: ordinal, state: &state, ticket: &ticket)
                    records.pointee.offeredClaims[i] = nil
                    return .success(.materialized)
                }
                throw .incompatibleAssociation
            }
            guard case .seed(let seed)? = state._giftUIInitial else {
                throw .incompatibleAssociation
            }
            // A fresh typed seed has no prior owner to duplicate. Generation
            // exhaustion precedes every model metadata/backing capacity check.
            guard records.pointee.nextGeneration != nil else {
                throw .registrationGenerationExhausted
            }
            var ticket = try models.materialize(Model.materialize(seed))
            do {
                try install(identity, ordinal: ordinal, state: &state, ticket: &ticket)
                return .success(.materialized)
            } catch {
                try? models.release(&ticket)
                throw error
            }
        } catch { return .failure(error) }
    }

    /// Explicitly consumes the host's matching candidate claim after attachment
    /// succeeds. On failure it remains the caller's ticket and model.
    package borrowing func encounter(
        identity: Identity, ordinal: UInt16, state: inout State<Model.Schema>,
        transferring ticket: inout ObservableModelTicket<Model.Schema>
    ) -> ObservableStateResult {
        do throws(ObservableStateError) {
            if try preserved(identity, ordinal: ordinal, state: &state) {
                return .success(.preserved)
            }
            guard case .candidate(let descriptor)? = state._giftUIInitial, descriptor == ticket.key
            else {
                throw .incompatibleAssociation
            }
            try models.validateTicket(ticket)
            try install(identity, ordinal: ordinal, state: &state, ticket: &ticket)
            return .success(.materialized)
        } catch { return .failure(error) }
    }

    /// Transfers an explicit claim into this activation's bounded candidate set.
    /// Unused claims are released on candidate completion or activation teardown.
    package borrowing func offerCandidate(_ ticket: inout ObservableModelTicket<Model.Schema>)
        -> ObservableStateResult
    {
        do throws(ObservableStateError) {
            try checkOperation()
            try models.validateTicket(ticket)
            for i in 0 ..< 4 where records.pointee.offeredClaims[i] == nil {
                records.pointee.offeredClaims[i] = try ticket.requireClaim()
                ticket.endOwnership()
                return .success(.unchanged)
            }
            throw .ownerCapacityExhausted
        } catch { return .failure(error) }
    }

    private borrowing func releaseOffers() throws(ObservableStateError) {
        var failure: ObservableStateError?
        for i in 0 ..< 4 {
            guard let claim = records.pointee.offeredClaims[i] else { continue }
            var ticket = ObservableModelTicket<Model.Schema>(claim: claim, lifetime: models)
            do { try models.release(&ticket) } catch { if failure == nil { failure = error } }
            records.pointee.offeredClaims[i] = nil
        }
        if let failure { throw failure }
    }

    private borrowing func install(
        _ identity: Identity, ordinal: UInt16, state: inout State<Model.Schema>,
        ticket: inout ObservableModelTicket<Model.Schema>
    ) throws(ObservableStateError) {
        let key = ticket.key
        try models.validateAssociation(key)
        let slot = Int(key._giftUISlot)
        guard records.pointee.records[slot].identity == nil else {
            throw .locationCapacityExhausted
        }
        let attachment = try records.pointee.reserve(UInt16(slot))
        try models.pin(key)
        records.pointee.operationActive = true
        defer { records.pointee.operationActive = false }
        records.pointee.records[slot] = .init(
            identity: identity, ordinal: ordinal,
            keyOwner: key._giftUIOwnerInstance, keyGeneration: key._giftUIAllocationGeneration,
            attachment: attachment, encountered: true)
        reports.pointee.routes[slot] = .init()
        if let failure = reports.pointee.routes[slot].lifecycle.beginAttachment(attachment) {
            throw failure
        }
        let sink = _GiftUIObservableChangeSink(
            attachment: attachment, context: UnsafeMutableRawPointer(reports),
            reportRoute: reportObservableStateRoot)
        let returned = try models.attach(key, sink: consume sink)
        if let failure = reports.pointee.routes[slot].lifecycle.acceptAttachmentReturn(returned) {
            if returned != nil {
                do { try models.detach(key, attachment: attachment) } catch { models.requireStop() }
            }
            records.pointee.records[slot] = .init()
            throw failure
        }
        try models.register(ticket)
        try bind(&state, slot: slot)
        try models.release(&ticket)
    }

    private borrowing func retire(_ slot: Int) throws(ObservableStateError) {
        guard let attachment = records.pointee.records[slot].attachment else {
            throw .invariantViolation
        }
        let former = key(at: slot)
        if let failure = reports.pointee.routes[slot].lifecycle.retire(attachment: attachment) {
            throw failure
        }
        var firstFailure: ObservableStateError?
        do { try models.detach(former, attachment: attachment) } catch { firstFailure = error }
        do { try models.unregister(former) } catch {
            if firstFailure == nil { firstFailure = error }
        }
        records.pointee.records[slot] = .init()
        reports.pointee.routes[slot].dirty = false
        if let firstFailure {
            models.requireStop()
            throw firstFailure
        }
    }

    package borrowing func finishCandidate(_ disposition: ObservableStateCandidateDisposition)
        -> ObservableStateResult
    {
        do throws(ObservableStateError) {
            try checkOperation(discovery: true)
            guard models.phase == .discovering, records.pointee.candidateActive else {
                throw .invalidPhaseSafetyNotProven
            }
            records.pointee.operationActive = true
            defer {
                records.pointee.operationActive = false
                records.pointee.candidateActive = false
            }
            var changed = false
            var failure: ObservableStateError?
            for i in 0 ..< 2 where records.pointee.records[i].identity != nil {
                let record = records.pointee.records[i]
                let remove = disposition == .discard ? !record.published : !record.encountered
                if remove {
                    do { try retire(i) } catch { if failure == nil { failure = error } }
                    changed = true
                } else {
                    if disposition == .publish {
                        changed = changed || !record.published
                        records.pointee.records[i].published = true
                        reports.pointee.routes[i].dirty = false
                    }
                    records.pointee.records[i].encountered = false
                }
            }
            do { try releaseOffers() } catch { if failure == nil { failure = error } }
            if let failure { throw failure }
            return .success(
                disposition == .discard
                    ? .candidateDiscarded : (changed ? .associationsCommitted : .unchanged))
        } catch { return .failure(error) }
    }

    package borrowing func replace(
        identity: Identity, ordinal: UInt16,
        transferring ticket: inout ObservableModelTicket<Model.Schema>, seed: Model.Schema.Seed,
        registrationAvailable: Bool = true, stagingAvailable: Bool = true
    ) -> ObservableStateResult {
        do throws(ObservableStateError) {
            try checkOperation()
            guard !records.pointee.candidateActive else { throw .reentrancyViolation }
            guard let old = matching(identity, ordinal: ordinal),
                records.pointee.records[old].published,
                key(at: old) == ticket.key
            else { throw .incompatibleAssociation }
            try models.validateTicket(ticket)
            // Target-generation exhaustion precedes retained-owner/capacity checks.
            guard records.pointee.nextGeneration != nil else {
                throw .registrationGenerationExhausted
            }
            let reservation = try models.stageReplacement(
                transferring: ticket, seed: seed,
                registrationAvailable: registrationAvailable, stagingAvailable: stagingAvailable)
            let candidate = models.key(for: reservation.candidate)
            let new = Int(reservation.candidate.slot)
            let attachment = try records.pointee.reserve(UInt16(new))
            records.pointee.operationActive = true
            defer { records.pointee.operationActive = false }
            records.pointee.records[new] = .init(
                identity: identity, ordinal: ordinal,
                keyOwner: candidate._giftUIOwnerInstance,
                keyGeneration: candidate._giftUIAllocationGeneration,
                attachment: attachment)
            reports.pointee.routes[new] = .init()
            _ = reports.pointee.routes[new].lifecycle.beginAttachment(attachment)
            let sink = _GiftUIObservableChangeSink(
                attachment: attachment, context: UnsafeMutableRawPointer(reports),
                reportRoute: reportObservableStateRoot)
            let returned = try models.attach(candidate, sink: consume sink)
            if let failure = reports.pointee.routes[new].lifecycle.acceptAttachmentReturn(returned)
            {
                var cleanupFailed = false
                if returned != nil {
                    do { try models.detach(candidate, attachment: attachment) } catch {
                        cleanupFailed = true
                    }
                }
                records.pointee.records[new] = .init()
                try? models.discardReplacement(reservation)
                if cleanupFailed { models.requireStop() }
                throw failure
            }
            guard let formerAttachment = records.pointee.records[old].attachment else {
                throw .invariantViolation
            }
            // This is the commit boundary. Retire old routing before invoking its
            // detach hook; a detach invariant failure cannot roll back B.
            let retirementFailure = reports.pointee.routes[old].lifecycle.retire(
                attachment: formerAttachment)
            records.pointee.records[new].published = true
            reports.pointee.routes[new].dirty = true
            var failure = retirementFailure
            do { try models.detach(ticket.key, attachment: formerAttachment) } catch {
                if failure == nil { failure = error }
            }
            var activated = try models.commitReplacement(reservation, transferring: &ticket)
            try models.release(&activated)
            records.pointee.records[old] = .init()
            reports.pointee.routes[old].dirty = false
            if let failure {
                models.requireStop()
                throw failure
            }
            return .success(.replaced)
        } catch { return .failure(error) }
    }

    package borrowing func mutate(_ key: _GiftUIModelKey<Model.Schema>, mutation: Model.Mutation)
        -> ObservableStateResult where Model: ObservableModelMutation
    {
        guard !records.pointee.retired else { return .failure(.invalidPhaseSafetyNotProven) }
        guard !records.pointee.operationActive else { return .failure(.reentrancyViolation) }
        reports.pointee.mutationReporting = true
        defer { reports.pointee.mutationReporting = false }
        return models.mutate(key, mutation: mutation) {
            models.report(key)
        }
    }

    package borrowing func mutate(
        identity: Identity, ordinal: UInt16, matching generation: ObservableTargetGeneration,
        mutation: Model.Mutation
    ) -> ObservableStateResult where Model: ObservableModelMutation {
        do throws(ObservableStateError) {
            try checkOperation()
            guard let slot = matching(identity, ordinal: ordinal),
                records.pointee.records[slot].published,
                records.pointee.records[slot].attachment?.generation == generation.rawValue
            else { throw .staleModel }
            return mutate(key(at: slot), mutation: mutation)
        } catch { return .failure(error) }
    }

    package borrowing func mutate(
        identity: Identity, ordinal: UInt16, matching generation: ObservableTargetGeneration,
        operation: () -> Model.Mutation
    ) -> ObservableStateResult where Model: ObservableModelMutation {
        do throws(ObservableStateError) {
            try checkOperation()
            guard let slot = matching(identity, ordinal: ordinal),
                records.pointee.records[slot].published,
                records.pointee.records[slot].attachment?.generation == generation.rawValue
            else { throw .staleModel }
            let key = key(at: slot)
            reports.pointee.mutationReporting = true
            defer { reports.pointee.mutationReporting = false }
            return models.mutate(key, operation: operation) { models.report(key) }
        } catch { return .failure(error) }
    }

    package borrowing func shutdown() throws(ObservableStateError) {
        if records.pointee.retired { return }
        // A terminal activation still needs to retire all callback routes while
        // their report storage exists. Normal operations remain forbidden.
        if models.phase != .retired { try checkOperation() }
        records.pointee.operationActive = true
        defer {
            records.pointee.operationActive = false
            records.pointee.retired = true
        }
        var failure: ObservableStateError?
        for i in 0 ..< 2 where records.pointee.records[i].identity != nil {
            do { try retire(i) } catch { if failure == nil { failure = error } }
        }
        records.pointee.candidateActive = false
        do { try releaseOffers() } catch { if failure == nil { failure = error } }
        if let failure { throw failure }
    }
}

extension ObservableStateRootScope where Model: ~Copyable {
    /// Exactly one generated lexical visit. The binder's actual root borrow
    /// cannot be copied or escaped by a public generic host witness.
    package borrowing func withBoundDeclaration<Declaration: _GiftUIObservableStateHost, Result>(
        _ declaration: borrowing Declaration, identity: Identity,
        body: (borrowing Declaration) throws(ObservableStateError) -> Result
    ) throws(ObservableStateError) -> Result {
        var transient = copy declaration
        try models.withDiscovery { () throws(ObservableStateError) in
            var visitor = ScopedObservableDeclarationVisitor(
                root: borrowedRoot(), identity: identity)
            transient._giftUIVisitObservableStateDeclarations(&visitor)
            if let failure = visitor.failure { throw failure }
        }
        return try body(transient)
    }

    /// End the body read before returning owned child declarations to traversal.
    package borrowing func evaluate<Declaration: View & _GiftUIObservableStateHost>(
        _ declaration: borrowing Declaration, identity: Identity,
        body: (borrowing Declaration, borrowing _GiftUIFrameRead<Declaration.Domain>)
            throws(_GiftUIAccessFailure) -> Declaration.Body
    ) throws(ObservableStateError) -> Declaration.Body
    where Declaration.Domain.Slot == ObservableModelReadSlot<Model> {
        try withBoundDeclaration(declaration, identity: identity) {
            (bound) throws(ObservableStateError) in
            do throws(_GiftUIAccessFailure) {
                return try models.withRead(Declaration.Domain.self) {
                    (read) throws(_GiftUIAccessFailure) in
                    try body(bound, read)
                }
            } catch { throw ObservableStateError(accessFailure: error) }
        }
    }
}

private struct ScopedObservableDeclarationVisitor<
    Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable
>: ~Copyable, ~Escapable, _GiftUIObservableStateDeclarationVisitor {
    let root: ObservableStateRootScope<Model, Identity>
    let identity: Identity
    var failure: ObservableStateError?

    @_lifetime(copy root)
    init(root: consuming ObservableStateRootScope<Model, Identity>, identity: Identity) {
        self.root = consume root
        self.identity = identity
    }

    mutating func visit<Schema: _GiftUIModelSchema>(
        _ state: inout State<Schema>, declarationOrdinal: UInt16
    ) {
        guard failure == nil else { return }
        guard Schema.self == Model.Schema.self else {
            failure = .incompatibleAssociation
            return
        }
        let result = withUnsafeMutablePointer(to: &state) { pointer in
            pointer.withMemoryRebound(to: State<Model.Schema>.self, capacity: 1) { typed in
                root.encounter(
                    identity: identity, ordinal: declarationOrdinal, state: &typed.pointee)
            }
        }
        if case .failure(let error) = result { failure = error }
    }
}
