import GiftUIExecution
import GiftUIRuntimeCore

package typealias DynamicStorageFamily = RuntimeStorageFamily
package typealias DynamicStorageLimit = RuntimeStorageLimit

package enum DynamicStorageReservation: Equatable, Sendable {
    case accepted
    case limitExceeded
    case arithmeticOverflow
    case unavailable
}

package struct DynamicStorageUse: Equatable, Sendable {
    package let current: UInt16
    package let highWater: UInt16
    package let limit: UInt16
}

package struct DynamicAllocatorReport: Equatable, Sendable {
    package let ownedPayloadBytes: UInt32
    package let observedReservedPayloadBytes: UInt32
    package let observedSparePayloadBytes: UInt32
    package let allocationCount: UInt16
}

package enum DynamicStorageLifetimeState: UInt8, Equatable, Sendable {
    case beforeUse = 0
    case idle = 1
    case attemptActive = 2
    case quiescenceRequested = 3
    case tornDown = 4
}

package struct DynamicStorageReleaseCounters: Equatable, Sendable {
    package private(set) var attemptResetCount: UInt32 = 0
    package private(set) var allStorageResetCount: UInt32 = 0
    package private(set) var quiescentTeardownCount: UInt32 = 0

    mutating func recordAttemptReset() {
        increment(&attemptResetCount)
    }

    mutating func recordAllStorageReset() {
        increment(&allStorageResetCount)
    }

    mutating func recordQuiescentTeardown() {
        increment(&quiescentTeardownCount)
    }

    private func increment(_ value: inout UInt32) {
        let next = value.addingReportingOverflow(1)
        guard !next.overflow else { return }
        value = next.partialValue
    }
}

package final class DynamicStorageDeinitializationCounter {
    package private(set) var count: UInt32 = 0

    package init() {}

    fileprivate func record() {
        let next = count.addingReportingOverflow(1)
        guard !next.overflow else { return }
        count = next.partialValue
    }
}

private final class DynamicStorageLifetimeToken {
    private let counter: DynamicStorageDeinitializationCounter

    init(counter: DynamicStorageDeinitializationCounter) {
        self.counter = counter
    }

    deinit {
        counter.record()
    }
}

private struct DynamicStorageRegion {
    let family: DynamicStorageFamily
    private(set) var bytes: [UInt8]

    init?(family: DynamicStorageFamily, byteCount: UInt32) {
        guard let count = Int(exactly: byteCount) else { return nil }
        self.family = family
        bytes = Array(repeating: 0, count: count)
    }

    var ownedByteCount: UInt32 {
        UInt32(bytes.count)
    }

    var observedReservedByteCount: UInt32? {
        UInt32(exactly: bytes.capacity)
    }

    mutating func reset() {
        _ = bytes.withUnsafeMutableBytes { rawBytes in
            rawBytes.initializeMemory(as: UInt8.self, repeating: 0)
        }
    }
}

private struct DynamicLogicalUseLedger {
    private let limits: [UInt16]
    private var current: [UInt16]
    private var highWater: [UInt16]

    init(limits: RuntimeProfileLimits) {
        let configured = DynamicStorageLimit.allCases.map { limit in
            limit.capacity(in: limits)
        }
        self.limits = configured
        current = Array(repeating: 0, count: configured.count)
        highWater = Array(repeating: 0, count: configured.count)
    }

    mutating func reserve(
        _ count: UInt16,
        for limit: DynamicStorageLimit
    ) -> DynamicStorageReservation {
        let index = Int(limit.rawValue)
        let (next, overflow) = current[index].addingReportingOverflow(count)
        guard !overflow else { return .arithmeticOverflow }
        guard next <= limits[index] else { return .limitExceeded }
        current[index] = next
        highWater[index] = max(highWater[index], next)
        return .accepted
    }

    func use(for limit: DynamicStorageLimit) -> DynamicStorageUse {
        let index = Int(limit.rawValue)
        return DynamicStorageUse(
            current: current[index],
            highWater: highWater[index],
            limit: limits[index]
        )
    }

    mutating func resetAttempt() {
        for limit in DynamicStorageLimit.allCases where limit.family.isAttemptLocal {
            current[Int(limit.rawValue)] = 0
        }
    }

    mutating func resetAll() {
        for index in current.indices {
            current[index] = 0
        }
    }

}

package struct DynamicProfileStorage: RuntimeProfileStorage {
    package typealias StructuralIdentity = DynamicStructuralIdentity

    package static let profile = RuntimeProfileKind.dynamic

    package let structuralIdentity: DynamicStructuralIdentity
    package let limits: RuntimeProfileLimits
    private let retainedAudit: RuntimeStorageAudit
    private var regions: [DynamicStorageRegion]
    private var logicalUse: DynamicLogicalUseLedger
    private var lifetimeState: DynamicStorageLifetimeState
    private var pendingPresentationIntent: PresentationPendingIntent?
    private var releaseCounts: DynamicStorageReleaseCounters
    private var attemptStorageWasReset: Bool
    private let lifetimeToken: DynamicStorageLifetimeToken?

    package init?(
        structuralIdentity: DynamicStructuralIdentity,
        limits: RuntimeProfileLimits,
        byteCounts: RuntimeStorageByteCounts,
        deinitializationCounter: DynamicStorageDeinitializationCounter? = nil
    ) {
        let capacities = RuntimeStorageCapacities(exact: limits, byteCounts: byteCounts)
        let validation = RuntimeProfileValidator.validateDynamic(
            inputs: RuntimeProfileLimitInputs(validated: limits, profile: .dynamic),
            capacities: capacities
        )
        guard
            let construction = DynamicProfileConstruction(
                structuralIdentity: structuralIdentity,
                validation: validation
            )
        else {
            return nil
        }

        var allocated: [DynamicStorageRegion] = []
        allocated.reserveCapacity(DynamicStorageFamily.allCases.count)
        for family in DynamicStorageFamily.allCases {
            guard
                let region = DynamicStorageRegion(
                    family: family,
                    byteCount: Self.byteCount(for: family, in: byteCounts)
                )
            else {
                return nil
            }
            allocated.append(region)
        }

        self.structuralIdentity = structuralIdentity
        self.limits = construction.limits
        retainedAudit = construction.storageAudit
        regions = allocated
        logicalUse = DynamicLogicalUseLedger(limits: construction.limits)
        lifetimeState = .beforeUse
        pendingPresentationIntent = nil
        releaseCounts = DynamicStorageReleaseCounters()
        attemptStorageWasReset = false
        lifetimeToken = deinitializationCounter.map(DynamicStorageLifetimeToken.init(counter:))
    }

    package borrowing func audit() -> RuntimeProfileValidationResult {
        guard regions.count == DynamicStorageFamily.allCases.count else {
            return .invalid(.invariantViolation)
        }
        for family in DynamicStorageFamily.allCases {
            let region = regions[Int(family.rawValue)]
            guard region.family == family,
                region.ownedByteCount == Self.auditByteCount(for: family, in: retainedAudit)
            else {
                return .invalid(.invariantViolation)
            }
        }
        return .valid(retainedAudit)
    }

    package mutating func reserve(
        _ count: UInt16,
        for limit: DynamicStorageLimit
    ) -> DynamicStorageReservation {
        guard lifetimeState != .quiescenceRequested, lifetimeState != .tornDown else {
            return .unavailable
        }
        guard !limit.family.isAttemptLocal || lifetimeState == .attemptActive else {
            return .unavailable
        }
        if lifetimeState == .beforeUse {
            lifetimeState = .idle
        }
        return logicalUse.reserve(count, for: limit)
    }

    package borrowing func use(for limit: DynamicStorageLimit) -> DynamicStorageUse {
        logicalUse.use(for: limit)
    }

    package borrowing func allocatorReport() -> DynamicAllocatorReport? {
        var owned: UInt32 = 0
        var reserved: UInt32 = 0
        var allocationCount: UInt16 = 0
        for region in regions {
            let (nextOwned, ownedOverflow) = owned.addingReportingOverflow(
                region.ownedByteCount
            )
            guard !ownedOverflow,
                let reservedBytes = region.observedReservedByteCount
            else {
                return nil
            }
            let (nextReserved, reservedOverflow) = reserved.addingReportingOverflow(
                reservedBytes
            )
            guard !reservedOverflow else { return nil }
            owned = nextOwned
            reserved = nextReserved
            if reservedBytes > 0 {
                let (nextCount, countOverflow) = allocationCount.addingReportingOverflow(1)
                guard !countOverflow else { return nil }
                allocationCount = nextCount
            }
        }
        guard reserved >= owned else { return nil }
        return DynamicAllocatorReport(
            ownedPayloadBytes: owned,
            observedReservedPayloadBytes: reserved,
            observedSparePayloadBytes: reserved - owned,
            allocationCount: allocationCount
        )
    }

    package var storageLifetimeState: DynamicStorageLifetimeState {
        lifetimeState
    }

    package var retainedPresentationIntent: PresentationPendingIntent? {
        pendingPresentationIntent
    }

    package var releaseCounters: DynamicStorageReleaseCounters {
        releaseCounts
    }

    package mutating func beginAttempt() -> Bool {
        guard lifetimeState == .beforeUse || lifetimeState == .idle else { return false }
        lifetimeState = .attemptActive
        attemptStorageWasReset = false
        return true
    }

    package mutating func retainPresentationIntent(_ intent: PresentationPendingIntent?) {
        guard lifetimeState != .tornDown else { return }
        pendingPresentationIntent = intent
    }

    package mutating func finishAttempt() {
        guard lifetimeState == .attemptActive || lifetimeState == .quiescenceRequested else {
            return
        }
        resetAttemptStorageIfNeeded()
        if lifetimeState == .quiescenceRequested {
            finishQuiescentTeardown()
        } else {
            lifetimeState = .idle
        }
    }

    package mutating func quiesce() {
        switch lifetimeState {
        case .beforeUse, .idle:
            finishQuiescentTeardown()
        case .attemptActive:
            lifetimeState = .quiescenceRequested
        case .quiescenceRequested, .tornDown:
            break
        }
    }

    package mutating func resetAttemptStorage() {
        guard lifetimeState == .attemptActive || lifetimeState == .quiescenceRequested else {
            return
        }
        resetAttemptStorageIfNeeded()
    }

    package mutating func resetAllStorage() {
        guard lifetimeState == .beforeUse || lifetimeState == .tornDown else { return }
        resetAllRegions()
        releaseCounts.recordAllStorageReset()
    }

    private mutating func resetAttemptRegions() {
        logicalUse.resetAttempt()
        for index in regions.indices where regions[index].family.isAttemptLocal {
            regions[index].reset()
        }
    }

    private mutating func resetAttemptStorageIfNeeded() {
        guard !attemptStorageWasReset else { return }
        resetAttemptRegions()
        attemptStorageWasReset = true
        releaseCounts.recordAttemptReset()
    }

    private mutating func resetAllRegions() {
        logicalUse.resetAll()
        for index in regions.indices {
            regions[index].reset()
        }
        pendingPresentationIntent = nil
        attemptStorageWasReset = false
    }

    private mutating func finishQuiescentTeardown() {
        guard lifetimeState != .tornDown else { return }
        resetAllRegions()
        releaseCounts.recordAllStorageReset()
        releaseCounts.recordQuiescentTeardown()
        lifetimeState = .tornDown
    }

    private static func byteCount(
        for family: DynamicStorageFamily,
        in counts: RuntimeStorageByteCounts
    ) -> UInt32 {
        switch family {
        case .semanticCandidate: counts.semanticCandidateBytes
        case .semanticPublished: counts.semanticPublishedBytes
        case .layoutCandidate: counts.layoutCandidateBytes
        case .renderWorkspace: counts.renderWorkspaceBytes
        case .canvasCallable: counts.canvasCallableBytes
        case .pathWorkspace: counts.pathWorkspaceBytes
        case .drawingPlan: counts.drawingPlanBytes
        case .observableLive: counts.observableLiveBytes
        case .observableCandidate: counts.observableCandidateBytes
        case .interactionCandidate: counts.interactionCandidateBytes
        case .interactionCommitted: counts.interactionCommittedBytes
        case .admissionQueue: counts.admissionQueueBytes
        case .sealedBatch: counts.sealedBatchBytes
        case .pointerState: counts.pointerStateBytes
        case .coordinatorState: counts.coordinatorStateBytes
        case .failureState: counts.failureStateBytes
        }
    }

    private static func auditByteCount(
        for family: DynamicStorageFamily,
        in audit: RuntimeStorageAudit
    ) -> UInt32 {
        switch family {
        case .semanticCandidate: audit.semanticCandidateBytes
        case .semanticPublished: audit.semanticPublishedBytes
        case .layoutCandidate: audit.layoutCandidateBytes
        case .renderWorkspace: audit.renderWorkspaceBytes
        case .canvasCallable: audit.canvasCallableBytes
        case .pathWorkspace: audit.pathWorkspaceBytes
        case .drawingPlan: audit.drawingPlanBytes
        case .observableLive: audit.observableLiveBytes
        case .observableCandidate: audit.observableCandidateBytes
        case .interactionCandidate: audit.interactionCandidateBytes
        case .interactionCommitted: audit.interactionCommittedBytes
        case .admissionQueue: audit.admissionQueueBytes
        case .sealedBatch: audit.sealedBatchBytes
        case .pointerState: audit.pointerStateBytes
        case .coordinatorState: audit.coordinatorStateBytes
        case .failureState: audit.failureStateBytes
        }
    }
}
