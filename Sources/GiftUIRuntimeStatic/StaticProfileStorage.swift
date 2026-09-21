import GiftUI
import GiftUIDrawing
import GiftUIRuntimeCore

package struct StaticStructuralIdentity: Equatable, Hashable, Sendable {
    package let rawValue: UInt32

    package init?(rawValue: UInt32) {
        guard rawValue > 0 else { return nil }
        self.rawValue = rawValue
    }
}

package protocol StaticProfileStorageRegions: ~Copyable {
    var byteCounts: RuntimeStorageByteCounts { get }
    mutating func withRegion<Result>(
        _ family: RuntimeStorageFamily,
        _ body: (UnsafeMutableRawBufferPointer) throws -> Result
    ) rethrows -> Result
    mutating func withSemanticRegions<Result>(
        _ body: (
            UnsafeMutableRawBufferPointer,
            UnsafeMutableRawBufferPointer
        ) throws -> Result
    ) rethrows -> Result
    mutating func resetAttemptRegions()
    mutating func resetAllRegions()
}

package enum StaticStorageReservation: Equatable, Sendable {
    case accepted
    case limitExceeded
    case arithmeticOverflow
    case unavailable
}

package struct StaticStorageUse: Equatable, Sendable {
    package let current: UInt16
    package let highWater: UInt16
    package let limit: UInt16
}

package enum StaticStorageLifetimeState: UInt8, Equatable, Sendable {
    case beforeUse = 0
    case idle = 1
    case attemptActive = 2
    case quiescenceRequested = 3
    case tornDown = 4
}

private struct StaticLogicalUseLedger: ~Copyable {
    private let limits: StaticLimitCounters
    private var current: StaticLimitCounters
    private var highWater: StaticLimitCounters

    init(limits: RuntimeProfileLimits) {
        var configured = StaticLimitCounters()
        var rawValue: UInt8 = 0
        while let limit = RuntimeStorageLimit(rawValue: rawValue) {
            configured[Int(rawValue)] = limit.capacity(in: limits)
            guard rawValue < UInt8.max else { break }
            rawValue += 1
        }
        self.limits = configured
        current = StaticLimitCounters()
        highWater = StaticLimitCounters()
    }

    mutating func reserve(
        _ count: UInt16,
        for limit: RuntimeStorageLimit
    ) -> StaticStorageReservation {
        let index = Int(limit.rawValue)
        let next = current[index].addingReportingOverflow(count)
        guard !next.overflow else { return .arithmeticOverflow }
        guard next.partialValue <= limits[index] else { return .limitExceeded }
        current[index] = next.partialValue
        highWater[index] = max(highWater[index], next.partialValue)
        return .accepted
    }

    borrowing func use(for limit: RuntimeStorageLimit) -> StaticStorageUse {
        let index = Int(limit.rawValue)
        return StaticStorageUse(
            current: current[index],
            highWater: highWater[index],
            limit: limits[index]
        )
    }

    mutating func resetAttempt() {
        var rawValue: UInt8 = 0
        while let limit = RuntimeStorageLimit(rawValue: rawValue) {
            if limit.family.isAttemptLocal {
                current[Int(rawValue)] = 0
            }
            guard rawValue < UInt8.max else { break }
            rawValue += 1
        }
    }

    mutating func resetAll() {
        current = StaticLimitCounters()
    }
}

private struct StaticLimitCounters: ~Copyable {
    private typealias Storage = (
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16,
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16,
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16,
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16,
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16,
        UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16,
        UInt16, UInt16, UInt16
    )

    private var storage: Storage = (
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    )

    subscript(index: Int) -> UInt16 {
        borrowing get {
            precondition((0 ..< 51).contains(index))
            return withUnsafeBytes(of: storage) { bytes in
                bytes.load(fromByteOffset: index * MemoryLayout<UInt16>.stride, as: UInt16.self)
            }
        }
        mutating set {
            precondition((0 ..< 51).contains(index))
            withUnsafeMutableBytes(of: &storage) { bytes in
                bytes.storeBytes(
                    of: newValue,
                    toByteOffset: index * MemoryLayout<UInt16>.stride,
                    as: UInt16.self
                )
            }
        }
    }
}

package struct StaticProfileStorage<Regions, Metadata>: RuntimeProfileStorage, ~Copyable
where
    Regions: StaticProfileStorageRegions & ~Copyable,
    Metadata: RuntimeStaticCanvasAuditMetadata
{
    package typealias StructuralIdentity = StaticStructuralIdentity

    package static var profile: RuntimeProfileKind { .static }

    package let structuralIdentity: StaticStructuralIdentity
    package let limits: RuntimeProfileLimits
    private let retainedAudit: RuntimeStorageAudit
    private var regions: Regions
    private var metadata: Metadata
    private var logicalUse: StaticLogicalUseLedger
    private var lifetimeState: StaticStorageLifetimeState
    private var attemptStorageWasReset: Bool

    package init?(
        structuralIdentity: StaticStructuralIdentity,
        limits: RuntimeProfileLimits,
        regions: consuming Regions,
        metadata: consuming Metadata
    ) {
        let byteCounts = regions.byteCounts
        let validation = RuntimeProfileValidator.validateStatic(
            inputs: RuntimeProfileLimitInputs(validated: limits, profile: .static),
            capacities: RuntimeStorageCapacities(exact: limits, byteCounts: byteCounts),
            metadata: metadata
        )
        guard case .valid(let audit) = validation else { return nil }

        self.structuralIdentity = structuralIdentity
        self.limits = limits
        retainedAudit = audit
        self.regions = consume regions
        self.metadata = consume metadata
        logicalUse = StaticLogicalUseLedger(limits: limits)
        lifetimeState = .beforeUse
        attemptStorageWasReset = false
    }

    package borrowing func audit() -> RuntimeProfileValidationResult {
        let validation = RuntimeProfileValidator.validateStatic(
            inputs: RuntimeProfileLimitInputs(validated: limits, profile: .static),
            capacities: RuntimeStorageCapacities(
                exact: limits,
                byteCounts: regions.byteCounts
            ),
            metadata: metadata
        )
        guard validation == .valid(retainedAudit) else {
            return .invalid(.invariantViolation)
        }
        return validation
    }

    package var storageLifetimeState: StaticStorageLifetimeState {
        lifetimeState
    }

    package mutating func beginAttempt() -> Bool {
        guard lifetimeState == .beforeUse || lifetimeState == .idle else { return false }
        lifetimeState = .attemptActive
        attemptStorageWasReset = false
        return true
    }

    package mutating func reserve(
        _ count: UInt16,
        for limit: RuntimeStorageLimit
    ) -> StaticStorageReservation {
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

    package borrowing func use(for limit: RuntimeStorageLimit) -> StaticStorageUse {
        logicalUse.use(for: limit)
    }

    package mutating func withRegion<Result>(
        _ family: RuntimeStorageFamily,
        _ body: (UnsafeMutableRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        guard lifetimeState != .quiescenceRequested,
            lifetimeState != .tornDown,
            !family.isAttemptLocal || lifetimeState == .attemptActive
        else { return nil }
        return try regions.withRegion(family, body)
    }

    /// Lends disjoint candidate and published semantic regions together. The
    /// attempt must be active because the candidate region is attempt-local.
    package mutating func withSemanticRegions<Result>(
        _ body: (
            UnsafeMutableRawBufferPointer,
            UnsafeMutableRawBufferPointer
        ) throws -> Result
    ) rethrows -> Result? {
        guard lifetimeState == .attemptActive else { return nil }
        return try regions.withSemanticRegions(body)
    }

    package mutating func stageCanvas<Identity>(
        identity: consuming Identity,
        callableID: UInt16,
        declaredCaptureByteCount: UInt16,
        capture: consuming Metadata.CaptureStorage
    ) -> StaticCanvasOccurrence<Identity, Metadata.CaptureStorage>?
    where Metadata: StaticCanvasCallableTable, Identity: Equatable & Sendable {
        guard lifetimeState == .attemptActive else { return nil }
        return StaticCanvasOccurrence(
            identity: consume identity,
            callableID: callableID,
            declaredCaptureByteCount: declaredCaptureByteCount,
            capture: consume capture,
            metadata: metadata
        )
    }

    package mutating func invokeCanvas<Identity>(
        occurrence: inout StaticCanvasOccurrence<Identity, Metadata.CaptureStorage>,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError)
    where Metadata: StaticCanvasCallableTable, Identity: Equatable & Sendable {
        try occurrence.invoke(
            table: &metadata,
            context: &context,
            size: size
        )
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
    }

    private mutating func resetAttemptStorageIfNeeded() {
        guard !attemptStorageWasReset else { return }
        logicalUse.resetAttempt()
        regions.resetAttemptRegions()
        attemptStorageWasReset = true
    }

    private mutating func resetAllRegions() {
        logicalUse.resetAll()
        regions.resetAllRegions()
        attemptStorageWasReset = false
    }

    private mutating func finishQuiescentTeardown() {
        guard lifetimeState != .tornDown else { return }
        resetAllRegions()
        lifetimeState = .tornDown
    }
}
