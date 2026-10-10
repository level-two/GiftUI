import GiftUI
@testable import GiftUIObservableState

@main struct OwnershipChecks {
    enum Schema {}
    static func main() throws {
        var checks = 0
        func expect(_ condition: Bool) { checks += 1; precondition(condition) }
        func failure(_ expected: ObservableStateError, _ body: () throws(ObservableStateError) -> Void) {
            do { try body(); expect(false) } catch { expect(error == expected) }
        }
        func readFailure(_ expected: _GiftUIAccessFailure, _ body: () throws(_GiftUIAccessFailure) -> Void) {
            do { try body(); expect(false) } catch { expect(error == expected) }
        }
        var namespace = ObservableModelOwnerNamespace()
        guard var owner = ObservableModelOwnership(identity: try namespace.issue(), captureLimit: 1) else { fatalError() }
        let a = try owner.materialize(schema: 7, needsCapture: true)
        let key: _GiftUIModelKey<Schema> = owner.key(for: a.address, as: Schema.self)
        expect(owner.occupiedCount == 1 && owner.claimCount == 1 && owner.captureCount == 1)
        try owner.register(a.address, schema: 7)
        failure(.modelCapacityExhausted) { () throws(ObservableStateError) in
            _ = try owner.materialize(schema: 7, needsCapture: true)
        }
        let retained = try owner.retain(a.address)
        failure(.retainedModel) { () throws(ObservableStateError) in
            _ = try owner.reserveReplacement(transferring: a, schema: 7, candidateIsEmpty: true, registrationAvailable: true, stagingAvailable: true)
        }
        expect(owner.claimCount == 2 && owner.captureCount == 1)
        expect(try owner.unregister(a.address) == nil)
        expect(try owner.release(a) == nil)
        expect(owner.claimCount == 1 && owner.occupiedCount == 1)
        try owner.beginFrame()
        try owner.pin(retained.address)
        try owner.pin(retained.address)
        expect(owner.pinCount == 1)
        try owner.beginRead()
        expect(try owner.bind(key, schema: 7) == Int(a.address.slot))
        failure(.invalidPhaseSafetyNotProven) { () throws(ObservableStateError) in try owner.beginDiscovery() }
        failure(.invalidPhaseSafetyNotProven) { () throws(ObservableStateError) in _ = try owner.retain(a.address) }
        readFailure(.wrongSchema) { () throws(_GiftUIAccessFailure) in _ = try owner.bind(key, schema: 8) }
        let wrongOwner = _GiftUIModelKey<Schema>(ownerInstance: 99, allocationGeneration: 99, slot: 99)
        readFailure(.wrongOwner) { () throws(_GiftUIAccessFailure) in _ = try owner.bind(wrongOwner, schema: 8) }
        try owner.endRead()
        readFailure(.invalidPhase) { () throws(_GiftUIAccessFailure) in _ = try owner.bind(wrongOwner, schema: 8) }
        try owner.beginDiscovery()
        let nested = try owner.materialize(schema: 8, needsCapture: false)
        try owner.register(nested.address, schema: 8)
        try owner.pin(nested.address)
        expect(owner.pinCount == 2 && owner.occupiedCount == 2)
        failure(.invalidPhaseContained) { () throws(ObservableStateError) in _ = try owner.retain(retained.address) }
        try owner.endDiscovery()
        try owner.endFrame { _ in expect(false) }
        expect(owner.pinCount == 0 && owner.phase == .mutating)
        expect(try owner.unregister(nested.address) == nil)
        expect(try owner.release(nested) == nested.address.slot)
        try owner.register(retained.address, schema: 7)
        failure(.modelCapacityExhausted) { () throws(ObservableStateError) in
            _ = try owner.reserveReplacement(transferring: retained, schema: 7, candidateIsEmpty: false, registrationAvailable: true, stagingAvailable: true)
        }
        failure(.registrationCapacityExhausted) { () throws(ObservableStateError) in
            _ = try owner.reserveReplacement(transferring: retained, schema: 7, candidateIsEmpty: true, registrationAvailable: false, stagingAvailable: false)
        }
        failure(.replacementStagingCapacityExhausted) { () throws(ObservableStateError) in
            _ = try owner.reserveReplacement(transferring: retained, schema: 7, candidateIsEmpty: true, registrationAvailable: true, stagingAvailable: false)
        }
        let discarded = try owner.reserveReplacement(transferring: retained, schema: 7, candidateIsEmpty: true, registrationAvailable: true, stagingAvailable: true)
        expect(owner.phase == .replacing && owner.occupiedCount == 2 && owner.claimCount == 2 && owner.captureCount == 1)
        failure(.reentrancyViolation) { () throws(ObservableStateError) in _ = try owner.release(retained) }
        failure(.reentrancyViolation) { () throws(ObservableStateError) in _ = try owner.retain(retained.address) }
        failure(.reentrancyViolation) { () throws(ObservableStateError) in try owner.beginFrame() }
        expect(try owner.finishReplacement(discarded, commit: false) == nil)
        expect(owner.occupiedCount == 1 && owner.claimCount == 1 && owner.captureCount == 1)
        failure(.invariantViolation) { () throws(ObservableStateError) in _ = try owner.finishReplacement(discarded, commit: false) }
        let committed = try owner.reserveReplacement(transferring: retained, schema: 7, candidateIsEmpty: true, registrationAvailable: true, stagingAvailable: true)
        expect(committed.candidate.generation != discarded.candidate.generation)
        guard let b = try owner.finishReplacement(committed, commit: true) else { fatalError() }
        expect(owner.occupiedCount == 1 && owner.claimCount == 1 && owner.captureCount == 1)
        failure(.staleModel) { () throws(ObservableStateError) in _ = try owner.release(retained) }
        try owner.beginFrame()
        try owner.pin(b.address)
        try owner.beginRead()
        readFailure(.staleModel) { () throws(_GiftUIAccessFailure) in _ = try owner.bind(key, schema: 7) }
        try owner.endRead()
        try owner.endFrame { _ in expect(false) }
        let extra1 = try owner.retain(b.address)
        let extra2 = try owner.retain(b.address)
        let extra3 = try owner.retain(b.address)
        failure(.ownerCapacityExhausted) { () throws(ObservableStateError) in _ = try owner.retain(b.address) }
        expect(try owner.release(extra1) == nil)
        let reused = try owner.retain(b.address)
        failure(.staleModel) { () throws(ObservableStateError) in _ = try owner.release(extra1) }
        expect(try owner.release(extra2) == nil)
        expect(try owner.release(extra3) == nil)
        expect(try owner.release(reused) == nil)
        expect(try owner.unregister(b.address) == nil)
        expect(try owner.release(b) == b.address.slot)
        expect(owner.occupiedCount == 0 && owner.claimCount == 0 && owner.captureCount == 0)
        guard var limited = ObservableModelOwnership(identity: try namespace.issue(), modelLimit: 1, claimLimit: 1, pinLimit: 1, captureLimit: 0) else { fatalError() }
        let single = try limited.materialize(schema: 1, needsCapture: false)
        failure(.modelCapacityExhausted) { () throws(ObservableStateError) in _ = try limited.materialize(schema: 1, needsCapture: false) }
        failure(.ownerCapacityExhausted) { () throws(ObservableStateError) in _ = try limited.retain(single.address) }
        expect(try limited.release(single) == 0)
        failure(.modelCapacityExhausted) { () throws(ObservableStateError) in _ = try limited.materialize(schema: 1, needsCapture: true) }
        print("P03 ownership ledger checks=\(checks) failures=0 bytes=\(MemoryLayout<ObservableModelOwnership>.stride)")
    }
}
