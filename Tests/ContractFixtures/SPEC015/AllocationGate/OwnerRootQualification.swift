import GiftUI
import GiftUISemanticCore

// Compiled with the complete unchanged defining-module source list. This can
// inspect existing internal root bookkeeping without introducing production seams.
@_noAllocation @inline(never)
private func newOwner(_ identity: ObservableModelOwnerIdentity, _ models: UInt16, _ claims: UInt16, _ pins: UInt16, _ captures: UInt16) -> ObservableModelOwnership? {
    ObservableModelOwnership(identity: identity, modelLimit: models, claimLimit: claims, pinLimit: pins, captureLimit: captures)
}

@_noAllocation @inline(never)
private func newControl() -> ObservableStateRootControl { ObservableStateRootControl() }

@_noAllocation @inline(never)
private func descriptorBytes() -> (Int, Int, Int) {
    (ObservableModelOwnership.metadataStorageBytes, ObservableModelOwnership.framePinStorageBytes, ObservableStateRootControl.candidateStorageBytes)
}

@_noAllocation @inline(never)
private func rootCapacity() -> (UInt16, UInt16, UInt16) {
    ObservableStateRootControl.storageCapacities()
}

@main
private struct OwnerRootQualification {
    static func check(_ condition: Bool, _ checks: inout Int) {
        precondition(condition)
        checks += 1
    }
    static func align(_ offset: Int, _ alignment: Int) -> Int {
        ((offset + alignment - 1) / alignment) * alignment
    }
    static func main() throws(ObservableStateError) {
        var checks = 0
        var namespace = ObservableModelOwnerNamespace()
        let first = try namespace.issue()
        let second = try namespace.issue()
        let values: [UInt16] = [0, 1, 2, 3, 4, 5, .max]
        var valid = 0
        var refused = 0
        for models in values { for claims in values { for pins in values { for captures in values {
            let expected = models > 0 && models <= 2 && claims > 0 && claims <= 4 && pins > 0 && pins <= 2 && captures <= 1
            if let owner = newOwner(first, models, claims, pins, captures) {
                let result = owner.storageCapacities
                check(expected, &checks)
                check(owner.identityForAccounting().rawValue == first.rawValue && result.models == models && result.claims == claims && result.pins == pins && result.captures == captures, &checks)
                check(owner.occupiedCount == 0 && owner.claimCount == 0 && owner.pinCount == 0 && owner.captureCount == 0 && owner.phase == .mutating, &checks)
                valid += 1
            } else {
                check(!expected, &checks)
                refused += 1
            }
        } } } }
        check(valid == 32 && refused == 2369, &checks)
        for captures: UInt16 in [0, 1] {
            let owner = ObservableModelOwnership(identity: second, captureLimit: captures)!
            let limits = owner.storageCapacities
            check(limits.models == 2 && limits.claims == 4 && limits.pins == 2 && limits.captures == captures, &checks)
            check(owner.identity == owner.identityForAccounting() && owner.identityForAccounting().rawValue == second.rawValue, &checks)
        }
        let bytes = descriptorBytes()
        check(bytes.1 == 2 * MemoryLayout<Bool>.size, &checks)
        check(bytes.0 >= 0 && bytes.0 + bytes.1 == MemoryLayout<ObservableModelOwnership>.size, &checks)
        check(bytes.2 == MemoryLayout<InlineArray<4, ObservableModelOwnership.Claim?>>.size + MemoryLayout<Bool>.size, &checks)
        let control = newControl()
        check(control.nextGeneration == 0 && !control.candidateActive && !control.operationActive && !control.retired, &checks)
        check(control.limits.maximumLocations == 2 && control.limits.maximumRegistrations == 2 && control.limits.maximumStagedAssociations == 2, &checks)
        check(control.records.count == 2 && control.offeredClaims.count == 4 && control.reports.routes.count == 2 && !control.reports.mutationReporting, &checks)
        for index in 0..<2 {
            let record = control.records[index]
            check(record.ordinal == 0 && record.keyOwner == 0 && record.keyGeneration == 0 && record.attachment == nil && !record.published && !record.encountered, &checks)
            let route = control.reports.routes[index]
            check(!route.dirty && !route.lifecycle.isActive && !route.lifecycle.isShutdown, &checks)
        }
        for index in 0..<4 { check(control.offeredClaims[index] == nil, &checks) }
        // Independently align every stored RootControl field in declaration order.
        let reports = align(MemoryLayout<InlineArray<2, ObservableStateRootControl.Record>>.size, MemoryLayout<ObservableStateRootReports>.alignment)
        let offered = align(reports + MemoryLayout<ObservableStateRootReports>.size, MemoryLayout<InlineArray<4, ObservableModelOwnership.Claim?>>.alignment)
        let generation = align(offered + MemoryLayout<InlineArray<4, ObservableModelOwnership.Claim?>>.size, MemoryLayout<UInt32?>.alignment)
        let candidate = generation + MemoryLayout<UInt32?>.size
        let operation = candidate + MemoryLayout<Bool>.size
        let retired = operation + MemoryLayout<Bool>.size
        let limits = align(retired + MemoryLayout<Bool>.size, MemoryLayout<ObservableStateLimits>.alignment)
        check(MemoryLayout<ObservableStateRootControl>.offset(of: \.records) == 0, &checks)
        check(MemoryLayout<ObservableStateRootControl>.offset(of: \.reports) == reports, &checks)
        check(MemoryLayout<ObservableStateRootControl>.offset(of: \.offeredClaims) == offered, &checks)
        check(MemoryLayout<ObservableStateRootControl>.offset(of: \.nextGeneration) == generation, &checks)
        check(MemoryLayout<ObservableStateRootControl>.offset(of: \.candidateActive) == candidate, &checks)
        check(MemoryLayout<ObservableStateRootControl>.offset(of: \.operationActive) == operation, &checks)
        check(MemoryLayout<ObservableStateRootControl>.offset(of: \.retired) == retired, &checks)
        check(MemoryLayout<ObservableStateRootControl>.offset(of: \.limits) == limits, &checks)
        check(MemoryLayout<ObservableStateRootControl>.size == limits + MemoryLayout<ObservableStateLimits>.size, &checks)
        let root = rootCapacity()
        check(root.0 == 2 && root.1 == 2 && root.2 == 2, &checks)
        let generic32 = ObservableStateRootStorage<UInt32>.storageCapacities
        let generic64 = ObservableStateRootStorage<UInt64>.storageCapacities
        let genericSemantic = ObservableStateRootStorage<SemanticCompleteIdentity>.storageCapacities
        check(generic32 == root && generic64 == root && genericSemantic == root, &checks)
        check(ObservableStateRootStorage<UInt32>.candidateStorageBytes == bytes.2 && ObservableStateRootStorage<UInt64>.candidateStorageBytes == bytes.2, &checks)
        check(ObservableStateRootStorage<UInt32>.liveStorageBytes + bytes.2 == MemoryLayout<ObservableStateRootStorage<UInt32>>.size, &checks)
        check(ObservableStateRootStorage<UInt64>.liveStorageBytes + bytes.2 == MemoryLayout<ObservableStateRootStorage<UInt64>>.size, &checks)
        check(MemoryLayout<ObservableStateRootStorage<UInt32>>.size == align(MemoryLayout<InlineArray<2, UInt32?>>.size, MemoryLayout<ObservableStateRootControl>.alignment) + MemoryLayout<ObservableStateRootControl>.size, &checks)
        check(MemoryLayout<ObservableStateRootStorage<UInt64>>.size == align(MemoryLayout<InlineArray<2, UInt64?>>.size, MemoryLayout<ObservableStateRootControl>.alignment) + MemoryLayout<ObservableStateRootControl>.size, &checks)
        let root32 = ObservableStateRootStorage<UInt32>()
        let root64 = ObservableStateRootStorage<UInt64>()
        withExtendedLifetime(root32) {}
        withExtendedLifetime(root64) {}
        var allocations = ObservableModelAllocationNamespace()
        check(try allocations.issue() == 0, &checks)
        check(try allocations.issue() == 1, &checks)
        print("OWNER_ROOT_QUALIFICATION checks=\(checks) valid=\(valid) refused=\(refused) capacities-defaults-identity-partitions-offsets=preserved generic-root-identity=3")
    }
}
