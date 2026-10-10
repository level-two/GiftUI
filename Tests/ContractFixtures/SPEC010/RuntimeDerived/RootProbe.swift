import GiftUI
import GiftUIExecution
@testable import GiftUIObservableState
import GiftUIRuntimeStatic

package struct RootTrace {
    var materializations = 0
    var attachments = 0
    var detachments = 0
    var destructions = 0
    var reports = 0
    var parentBodies = 0
    var childBodies = 0
    var leaves = 0
    var lastAttachedValue: UInt8 = 0
    var lastAttachedCount = 0
    var attachReport: _GiftUIObservableChangeReportOutcome?
    var destructionReport: _GiftUIObservableChangeReportOutcome?
    var detachReport: _GiftUIObservableChangeReportOutcome?
}
package struct RootSeed {
    let trace: UnsafeMutablePointer<RootTrace>
    var value: UInt8 = 7
    var count = 0
    var fault: UInt8 = 0
}
package enum RootSchema: _GiftUIModelSchema { package typealias Seed = RootSeed }
package struct RootModel: ~Copyable, ObservableStateModel, ObservableModelMutation {
    package typealias Schema = RootSchema
    package enum Mutation { case set(UInt8); case fail }
    package typealias Prepared = UInt8
    var seed: RootSeed
    var sink: _GiftUIObservableChangeSink?
    package static func materialize(_ seed: RootSeed) -> RootModel {
        seed.trace.pointee.materializations += 1
        return RootModel(seed: seed)
    }
    package var isEmptyReplacement: Bool { seed.count == 0 }
    package mutating func attach(_ sink: consuming _GiftUIObservableChangeSink) -> _GiftUIObservationAttachment? {
        seed.trace.pointee.attachments += 1
        seed.trace.pointee.lastAttachedValue = seed.value
        seed.trace.pointee.lastAttachedCount = seed.count
        guard seed.fault != 1 else { return nil }
        let attachment = sink.attachment
        self.sink = consume sink
        if seed.fault == 3 { seed.trace.pointee.attachReport = self.sink!.reportChange() }
        if seed.fault == 2 || seed.fault == 7 { return _GiftUIObservationAttachment(slot: attachment.slot, generation: attachment.generation + 100) }
        return attachment
    }
    package mutating func detach(_ attachment: _GiftUIObservationAttachment) -> Bool {
        seed.trace.pointee.detachments += 1
        guard sink?.attachment == attachment else { return false }
        seed.trace.pointee.detachReport = sink!.reportChange()
        if seed.fault == 6 || seed.fault == 7 { return false }
        sink = nil
        return seed.fault != 4
    }
    package mutating func reportChange() -> _GiftUIObservableChangeReportOutcome {
        seed.trace.pointee.reports += 1
        return sink?.reportChange() ?? .coalesced
    }
    package borrowing func preflight(_ mutation: Mutation) throws(ObservableStateError) -> UInt8 {
        switch mutation { case .set(let value): return value; case .fail: throw .incompatibleAssociation }
    }
    package mutating func commit(_ value: UInt8) -> Bool {
        let changed = seed.value != value
        seed.value = value
        return changed
    }
    deinit {
        if var sink { seed.trace.pointee.destructionReport = sink.reportChange() }
        seed.trace.pointee.destructions += 1
    }
}
package enum RootDomain: _GiftUIReadDomain {
    package typealias Slot = ObservableModelReadSlot<RootModel>
    package static func value(_ key: _GiftUIModelKey<RootSchema>, _ read: borrowing _GiftUIFrameRead<Self>) throws(_GiftUIAccessFailure) -> UInt8 {
        let index = try read.slots[0].ownership.pointee.bind(key, schema: 7)
        switch read.slots[index].model.pointee { case .some(let model): return model.seed.value; case .none: throw .staleModel }
    }
}
package func exerciseRoot(_ scope: borrowing ObservableModelScope<RootModel, RootSchema>, _ root: borrowing ObservableStateRootScope<RootModel, UInt8>, _ trace: UnsafeMutablePointer<RootTrace>) throws(ObservableStateError) -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ yes: Bool) { checks += 1; precondition(yes) }
    func value(_ key: _GiftUIModelKey<RootSchema>) throws(ObservableStateError) -> UInt8 {
        try scope.withFrame { () throws(ObservableStateError) in
            try scope.pin(key)
            do throws(_GiftUIAccessFailure) { return try scope.withRead(RootDomain.self) { (read) throws(_GiftUIAccessFailure) in try RootDomain.value(key, read) } }
            catch { throw ObservableStateError(accessFailure: error) }
        }
    }
    var initial = State<RootSchema>(seed: RootSeed(trace: trace))
    var generation: UInt32?
    try scope.withFrame { () throws(ObservableStateError) in
        try scope.withDiscovery { () throws(ObservableStateError) in
            expect(root.beginCandidate() == .success(.candidateStarted))
            expect(root.encounter(identity: 1, ordinal: 0, state: &initial) == .success(.materialized))
            generation = root.generation(identity: 1, ordinal: 0, publishable: true)
            expect(generation == 0 && root.generation(identity: 1, ordinal: 0) == nil)
        }
        do throws(_GiftUIAccessFailure) {
            try scope.withRead(RootDomain.self) { (read) throws(_GiftUIAccessFailure) in expect(try RootDomain.value(initial._giftUIKey(), read) == 7) }
        } catch { throw ObservableStateError(accessFailure: error) }
        try scope.withDiscovery { expect(root.finishCandidate(.publish) == .success(.associationsCommitted)) }
    }
    let a = root.modelKey(identity: 1, ordinal: 0)!
    let target = StaticObservableRootTargetAccess(root: root, identity: UInt8(1), ordinal: 0)
    let initialTarget = target.currentGeneration()!
    expect(initialTarget.rawValue == generation)
    expect(target.mutate(matching: initialTarget, mutation: .set(7)) == .success(.unchanged))
    expect(trace.pointee.attachments == 1 && trace.pointee.lastAttachedValue == 7)
    var ignored = State<RootSchema>(seed: RootSeed(trace: trace, value: 42))
    try scope.withFrame { () throws(ObservableStateError) in
        try scope.withDiscovery { () throws(ObservableStateError) in
            expect(root.beginCandidate() == .success(.candidateStarted))
            expect(root.encounter(identity: 1, ordinal: 0, state: &ignored) == .success(.preserved))
            expect(ignored.wrappedValue == a && trace.pointee.attachments == 1)
            expect(root.finishCandidate(.publish) == .success(.unchanged))
        }
    }
    expect(root.mutate(a, mutation: .set(7)) == .success(.unchanged) && trace.pointee.reports == 0)
    expect(root.mutate(a, mutation: .set(11)) == .success(.dirtied) && trace.pointee.reports == 1)
    expect(root.mutate(a, mutation: .fail) == .failure(.incompatibleAssociation) && root.isDirty)
    expect(try value(a) == 11)
    try scope.withFrame { () throws(ObservableStateError) in
        expect(target.mutate(matching: initialTarget, mutation: .set(99)) == .failure(.invalidPhaseContained))
        try scope.pin(a)
        do throws(_GiftUIAccessFailure) {
            try scope.withRead(RootDomain.self) { (read) throws(_GiftUIAccessFailure) in
                expect(target.mutate(matching: initialTarget, mutation: .set(99)) == .failure(.invalidPhaseSafetyNotProven))
                expect(root.mutate(a, mutation: .set(99)) == .failure(.invalidPhaseSafetyNotProven))
                expect(root.beginCandidate() == .failure(.invalidPhaseSafetyNotProven))
                expect(scope.report(a) == .invalidPhaseSafetyNotProven)
                expect(try RootDomain.value(a, read) == 11)
            }
        } catch { throw ObservableStateError(accessFailure: error) }
        try scope.withDiscovery {
            expect(root.mutate(a, mutation: .set(99)) == .failure(.invalidPhaseContained))
            expect(root.beginCandidate() == .success(.candidateStarted))
            expect(root.beginCandidate() == .failure(.reentrancyViolation))
            expect(root.finishCandidate(.discard) == .success(.candidateDiscarded))
        }
    }
    var transfer = try scope.retain(a)
    var independent = try scope.retain(a)
    expect(root.replace(identity: 1, ordinal: 0, transferring: &transfer, seed: RootSeed(trace: trace)) == .failure(.retainedModel))
    expect(try value(independent.key) == 11)
    try scope.release(&independent)
    expect(root.replace(identity: 1, ordinal: 0, transferring: &transfer, seed: RootSeed(trace: trace, count: 1)) == .failure(.modelCapacityExhausted))
    expect(root.replace(identity: 1, ordinal: 0, transferring: &transfer, seed: RootSeed(trace: trace), registrationAvailable: false) == .failure(.registrationCapacityExhausted))
    expect(root.replace(identity: 1, ordinal: 0, transferring: &transfer, seed: RootSeed(trace: trace), stagingAvailable: false) == .failure(.replacementStagingCapacityExhausted))
    for fault: UInt8 in 1...3 {
        let attachments = trace.pointee.attachments
        let detachments = trace.pointee.detachments
        let failure: ObservableStateError = fault == 1 ? .duplicateOwner : (fault == 2 ? .invariantViolation : .staleAttachment)
        expect(root.replace(identity: 1, ordinal: 0, transferring: &transfer, seed: RootSeed(trace: trace, value: 0, fault: fault)) == .failure(failure))
        expect(trace.pointee.attachments == attachments + 1)
        expect(trace.pointee.detachments == detachments + (fault == 1 ? 0 : 1))
        expect(root.modelKey(identity: 1, ordinal: 0) == a && root.generation(identity: 1, ordinal: 0) == generation && root.isDirty)
        expect(try value(a) == 11)
    }
    expect(trace.pointee.attachReport == .staleAttachment)
    expect(root.replace(identity: 1, ordinal: 0, transferring: &transfer, seed: RootSeed(trace: trace, value: 9)) == .success(.replaced))
    let b = root.modelKey(identity: 1, ordinal: 0)!
    expect(target.currentGeneration() != initialTarget)
    expect(target.mutate(matching: initialTarget, mutation: .set(99)) == .failure(.staleModel))
    expect(b != a && root.generation(identity: 1, ordinal: 0) != generation && root.isDirty)
    expect(trace.pointee.lastAttachedValue == 9 && trace.pointee.lastAttachedCount == 0)
    expect(trace.pointee.detachReport == .staleAttachment)
    do throws(ObservableStateError) { try scope.release(&transfer); expect(false) } catch { expect(error == .staleModel) }
    expect(root.mutate(a, mutation: .set(99)) == .failure(.staleModel))
    do throws(ObservableStateError) {
        try scope.withFrame { () throws(ObservableStateError) in try scope.pin(b); throw .modelReadOutOfBounds }
    } catch { expect(error == .modelReadOutOfBounds) }
    expect(try value(b) == 9 && root.modelKey(identity: 1, ordinal: 0) == b)
    // Empty installed B still owns the sole capture entitlement.
    do throws(ObservableStateError) { _ = try scope.materialize(RootModel.materialize(RootSeed(trace: trace))); expect(false) }
    catch { expect(error == .modelCapacityExhausted) }
    var retainedB = try scope.retain(b)
    try scope.withFrame { () throws(ObservableStateError) in
        try scope.withDiscovery { expect(root.beginCandidate() == .success(.candidateStarted)); expect(root.finishCandidate(.publish) == .success(.associationsCommitted)) }
    }
    expect(root.modelKey(identity: 1, ordinal: 0) == nil)
    expect(target.currentGeneration() == nil)
    expect(target.mutate(matching: initialTarget, mutation: .set(99)) == .failure(.staleModel))
    expect(try value(retainedB.key) == 9)
    expect(root.mutate(retainedB.key, mutation: .set(10)) == .success(.coalesced))
    try scope.release(&retainedB)
    var candidate = try scope.materialize(RootModel.materialize(RootSeed(trace: trace, value: 17)))
    let c = candidate.key
    var state = State<RootSchema>(candidate: c)
    try scope.withFrame { () throws(ObservableStateError) in
        try scope.withDiscovery { () throws(ObservableStateError) in
            expect(root.beginCandidate() == .success(.candidateStarted))
            expect(root.encounter(identity: 1, ordinal: 0, state: &state, transferring: &candidate) == .success(.materialized))
            expect(state.wrappedValue == c && c != a && c != b)
            expect(root.finishCandidate(.discard) == .success(.candidateDiscarded))
        }
    }
    do throws(ObservableStateError) { try scope.release(&candidate); expect(false) } catch { expect(error == .staleModel) }
    expect(root.mutate(c, mutation: .set(99)) == .failure(.staleModel))
    var reinsert = State<RootSchema>(seed: RootSeed(trace: trace, value: 23, fault: 4))
    try scope.withFrame { () throws(ObservableStateError) in
        try scope.withDiscovery {
            expect(root.beginCandidate() == .success(.candidateStarted))
            expect(root.encounter(identity: 1, ordinal: 0, state: &reinsert) == .success(.materialized))
            expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
        }
    }
    let d = root.modelKey(identity: 1, ordinal: 0)!
    var dTicket = try scope.retain(d)
    expect(root.replace(identity: 1, ordinal: 0, transferring: &dTicket, seed: RootSeed(trace: trace, value: 29)) == .failure(.invariantViolation))
    let e = root.modelKey(identity: 1, ordinal: 0)!
    // SPEC-010 required-stop table: B remains selected after commit, but an
    // invariant cannot admit a later normal cycle. Inspect owned identity and
    // attachment evidence; do not reopen a read merely to inspect B.
    expect(e != d && trace.pointee.lastAttachedValue == 29 && root.isDirty)
    expect(root.mutate(e, mutation: .set(3)) == .failure(.invalidPhaseSafetyNotProven))
    do throws(ObservableStateError) { _ = try value(e); expect(false) } catch { expect(error == .invalidPhaseSafetyNotProven) }
    try? root.shutdown()
    expect(root.modelKey(identity: 1, ordinal: 0) == nil)
    expect(root.mutate(e, mutation: .set(3)) == .failure(.invalidPhaseSafetyNotProven))
    return checks
}
package func staticRootChecks() throws(ObservableStateError) -> UInt32 {
    var namespace = ObservableModelOwnerNamespace()
    var root = StaticObservableRootAdapter<RootModel, UInt8>(identity: try namespace.issue(), schema: 7, needsCapture: true)!
    return try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
        trace.initialize(repeating: RootTrace())
        defer { trace.deinitialize() }
        return try root.withLifetime { (scope, owner) throws(ObservableStateError) in try exerciseRoot(scope, owner, trace.baseAddress!) }
    }
}
@_cdecl("giftui_p03_root") public func giftuiP03Root() -> UInt32 {
    do { return try staticRootChecks() + rootGenerationPrecedenceChecks() + retainingSinkChecks() + rootEntryPhaseChecks() } catch { return 0 }
}

// Exercise the real root and actual Static backing with both later capacity
// failures visible. The fixture-only exhausted cursor avoids billions of binds.
package func rootGenerationPrecedenceChecks() throws(ObservableStateError) -> UInt32 {
    var checks: UInt32 = 0
    var namespace = ObservableModelOwnerNamespace()
    for needsCapture in [true, false] {
        var storage = StaticObservableModelStorage<RootModel, RootSchema>(
            identity: try namespace.issue(), schema: 7, needsCapture: needsCapture)!
        try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
            trace.initialize(repeating: RootTrace())
            defer { trace.deinitialize() }
            try storage.withLifetime { (scope) throws(ObservableStateError) in
                var first = try scope.materialize(RootModel.materialize(RootSeed(trace: trace.baseAddress!, value: 31)))
                if needsCapture {
                    checks += try exhaustedRootCheck(scope, trace.baseAddress!)
                } else {
                    var second = try scope.materialize(RootModel.materialize(RootSeed(trace: trace.baseAddress!, value: 37)))
                    checks += try exhaustedRootCheck(scope, trace.baseAddress!)
                    try scope.validateTicket(second)
                    try scope.release(&second)
                    checks += 1
                }
                try scope.validateTicket(first)
                try scope.release(&first)
                checks += 1
                var next = try scope.materialize(RootModel.materialize(RootSeed(trace: trace.baseAddress!)))
                precondition(next.key._giftUIAllocationGeneration == (needsCapture ? 1 : 2))
                checks += 1
                try scope.release(&next)
            }
        }
    }
    return checks
}

private func exhaustedRootCheck(
    _ scope: borrowing ObservableModelScope<RootModel, RootSchema>,
    _ trace: UnsafeMutablePointer<RootTrace>
) throws(ObservableStateError) -> UInt32 {
    var registration = ObservableStateRootStorage<UInt8>(nextGeneration: nil)
    let before = trace.pointee
    return try scope.withRoot(storage: &registration) { (root) throws(ObservableStateError) in
        var state = State<RootSchema>(seed: RootSeed(trace: trace, value: 99))
        try scope.withFrame { () throws(ObservableStateError) in
            try scope.withDiscovery {
                precondition(root.beginCandidate() == .success(.candidateStarted))
                precondition(root.encounter(identity: 1, ordinal: 0, state: &state) == .failure(.registrationGenerationExhausted))
                precondition(state._giftUIBinding == nil)
                precondition(root.modelKey(identity: 1, ordinal: 0) == nil && root.generation(identity: 1, ordinal: 0, publishable: true) == nil)
                precondition(!root.isDirty)
                precondition(trace.pointee.materializations == before.materializations)
                precondition(trace.pointee.attachments == before.attachments && trace.pointee.detachments == before.detachments)
                precondition(trace.pointee.destructions == before.destructions)
                precondition(root.finishCandidate(.discard) == .success(.candidateDiscarded))
            }
        }
        return 9
    }
}

// A safe package caller catches the error, keeps an independent ticket, and
// ends temporary report storage before its wider model activation ends.
package func retainingSinkChecks() throws(ObservableStateError) -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ yes: Bool) { checks += 1; precondition(yes) }
    var namespace = ObservableModelOwnerNamespace()
    for mode: UInt8 in 0 ... 2 {
        var storage = StaticObservableModelStorage<RootModel, RootSchema>(identity: try namespace.issue(), schema: 7, needsCapture: false)!
        try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
            trace.initialize(repeating: RootTrace()); defer { trace.deinitialize() }
            try storage.withLifetime { (scope) throws(ObservableStateError) in
                var ticket = try scope.materialize(RootModel.materialize(RootSeed(trace: trace.baseAddress!, fault: mode == 2 ? 7 : 6)))
                let key = ticket.key
                var independent = try scope.retain(key)
                do throws(ObservableStateError) {
                    var registration = ObservableStateRootStorage<UInt8>()
                    try scope.withRoot(storage: &registration) { (root) throws(ObservableStateError) in
                        var state = State<RootSchema>(candidate: key)
                        if mode == 2 {
                            try scope.withFrame { () throws(ObservableStateError) in
                                try scope.withDiscovery { () throws(ObservableStateError) in
                                    expect(root.beginCandidate() == .success(.candidateStarted))
                                    expect(root.encounter(identity: 1, ordinal: 0, state: &state, transferring: &ticket) == .failure(.invariantViolation))
                                    throw .invariantViolation
                                }
                            }
                        }
                        try scope.withFrame { () throws(ObservableStateError) in
                            try scope.withDiscovery {
                                expect(root.beginCandidate() == .success(.candidateStarted))
                                expect(root.encounter(identity: 1, ordinal: 0, state: &state, transferring: &ticket) == .success(.materialized))
                                expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
                            }
                        }
                        if mode == 1 {
                            do throws(ObservableStateError) {
                                try scope.withFrame { () throws(ObservableStateError) in
                                    try scope.withDiscovery {
                                        expect(root.beginCandidate() == .success(.candidateStarted))
                                        expect(root.finishCandidate(.publish) == .failure(.invariantViolation))
                                    }
                                }
                            } catch { expect(error == .invalidPhaseSafetyNotProven) }
                            expect(scope.mutate(key, mutation: .set(99), report: { .dirtied }) == .failure(.invalidPhaseSafetyNotProven))
                            expect(scope.report(key) == .invalidPhaseSafetyNotProven)
                            // Preserve the caught failure as the outer disposition.
                            throw .invariantViolation
                        }
                    }
                    expect(false)
                } catch { expect(error == .invariantViolation) }
                expect(trace[0].detachments == 1 && trace[0].destructions == 1)
                expect(trace[0].destructionReport == .staleAttachment)
                expect(scope.mutate(key, mutation: .set(99), report: { .dirtied }) == .failure(.invalidPhaseSafetyNotProven))
                expect(scope.report(key) == .invalidPhaseSafetyNotProven)
                do throws(ObservableStateError) { try scope.release(&independent); expect(false) } catch { expect(error == .invalidPhaseSafetyNotProven) }
                do throws(ObservableStateError) { _ = try scope.materialize(RootModel.materialize(RootSeed(trace: trace.baseAddress!))); expect(false) } catch { expect(error == .invalidPhaseSafetyNotProven) }
            }
            do throws(ObservableStateError) { try storage.withLifetime { _ in () }; expect(false) } catch { expect(error == .invalidPhaseSafetyNotProven) }
        }
    }
    return checks
}

// Regression for the independently reproduced frame-encloses-root exit hazard.
// Reject before report backing/body admission; inverse nesting still tears down.
package func rootEntryPhaseChecks() throws(ObservableStateError) -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ yes: Bool) { checks += 1; precondition(yes) }
    var namespace = ObservableModelOwnerNamespace()
    var storage = StaticObservableModelStorage<RootModel, RootSchema>(identity: try namespace.issue(), schema: 7, needsCapture: false)!
    try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
        trace.initialize(repeating: RootTrace()); defer { trace.deinitialize() }
        try storage.withLifetime { (scope) throws(ObservableStateError) in
            var ticket = try scope.materialize(RootModel.materialize(RootSeed(trace: trace.baseAddress!)))
            try scope.withFrame { () throws(ObservableStateError) in
                checks += rejectedRootEntry(scope, trace.baseAddress!, .invalidPhaseContained)
                try scope.withDiscovery { checks += rejectedRootEntry(scope, trace.baseAddress!, .invalidPhaseContained) }
                try scope.pin(ticket.key)
                do throws(_GiftUIAccessFailure) {
                    try scope.withRead(RootDomain.self) { _ in checks += rejectedRootEntry(scope, trace.baseAddress!, .invalidPhaseSafetyNotProven) }
                } catch { throw ObservableStateError(accessFailure: error) }
            }
            expect(scope.mutate(ticket.key, mutation: .set(9), report: { checks += rejectedRootEntry(scope, trace.baseAddress!, .reentrancyViolation); return .dirtied }) == .success(.dirtied))
            try scope.register(ticket)
            let reservation = try scope.stageReplacement(transferring: ticket, seed: RootSeed(trace: trace.baseAddress!), registrationAvailable: true, stagingAvailable: true)
            checks += rejectedRootEntry(scope, trace.baseAddress!, .reentrancyViolation)
            try scope.discardReplacement(reservation)
            try scope.unregister(ticket.key)
            try scope.release(&ticket)
            scope.requireStop()
            checks += rejectedRootEntry(scope, trace.baseAddress!, .invalidPhaseSafetyNotProven)
        }
    }
    // Normal return, discovery throw, and active-read throw all leave the root
    // at mutation phase for detachment. An independent owner survives normally.
    for mode: UInt8 in 0 ... 2 {
        var backing = StaticObservableModelStorage<RootModel, RootSchema>(identity: try namespace.issue(), schema: 7, needsCapture: false)!
        try withUnsafeTemporaryAllocation(of: RootTrace.self, capacity: 1) { (trace) throws(ObservableStateError) in
            trace.initialize(repeating: RootTrace()); defer { trace.deinitialize() }
            try backing.withLifetime { (scope) throws(ObservableStateError) in
                var ticket = try scope.materialize(RootModel.materialize(RootSeed(trace: trace.baseAddress!)))
                var independent = try scope.retain(ticket.key)
                var registration = ObservableStateRootStorage<UInt8>()
                do throws(ObservableStateError) {
                    try scope.withRoot(storage: &registration) { (root) throws(ObservableStateError) in
                        var state = State<RootSchema>(candidate: ticket.key)
                        try scope.withFrame { () throws(ObservableStateError) in
                            try scope.withDiscovery { () throws(ObservableStateError) in
                                expect(root.beginCandidate() == .success(.candidateStarted))
                                expect(root.encounter(identity: 1, ordinal: 0, state: &state, transferring: &ticket) == .success(.materialized))
                                expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
                                if mode == 1 { throw .incompatibleAssociation }
                            }
                            if mode == 2 {
                                do throws(_GiftUIAccessFailure) { try scope.withRead(RootDomain.self) { _ throws(_GiftUIAccessFailure) in throw .outOfBounds } }
                                catch { throw ObservableStateError(accessFailure: error) }
                            }
                        }
                    }
                    expect(mode == 0)
                } catch { expect(error == (mode == 1 ? .incompatibleAssociation : .modelReadOutOfBounds)) }
                expect(scope.phase == .mutating)
                expect(trace[0].attachments == 1 && trace[0].detachments == 1 && trace[0].destructions == 0)
                try scope.withFrame { () throws(ObservableStateError) in
                    try scope.pin(independent.key)
                    do throws(_GiftUIAccessFailure) { try scope.withRead(RootDomain.self) { (read) throws(_GiftUIAccessFailure) in expect(try RootDomain.value(independent.key, read) == 7) } }
                    catch { throw ObservableStateError(accessFailure: error) }
                }
                try scope.release(&independent)
                expect(trace[0].destructions == 1)
            }
        }
    }
    return checks
}

private func rejectedRootEntry(
    _ scope: borrowing ObservableModelScope<RootModel, RootSchema>,
    _ trace: UnsafeMutablePointer<RootTrace>, _ expected: ObservableStateError
) -> UInt32 {
    var bodyEntered = false
    var registration = ObservableStateRootStorage<UInt8>()
    let before = trace.pointee
    do throws(ObservableStateError) {
        try scope.withRoot(storage: &registration) { _ in bodyEntered = true }
        preconditionFailure("root entry unexpectedly admitted")
    } catch { precondition(error == expected) }
    precondition(!bodyEntered)
    precondition(trace.pointee.attachments == before.attachments && trace.pointee.materializations == before.materializations && trace.pointee.detachments == before.detachments && trace.pointee.destructions == before.destructions)
    return 3
}
