import GiftUIRuntimeCore
import GiftUIRuntimeStatic

private struct StaticNRFProfileRegion {
    let offset: Int
    let byteCount: Int
}

/// Allocation-free region map over the caller-owned nRF52840 Static profile
/// workspace. Firmware supplies its retained 36,368-byte storage symbol.
package struct StaticSignalAnalyzerNRFProfileRegions: StaticProfileStorageRegions,
    ~Copyable
{
    package static let requiredByteCount = 36_368

    private static let semanticCandidate = StaticNRFProfileRegion(offset: 0, byteCount: 3_024)
    private static let semanticPublished = StaticNRFProfileRegion(
        offset: 3_024,
        byteCount: 3_024
    )
    private static let layoutCandidate = StaticNRFProfileRegion(
        offset: 6_048,
        byteCount: 3_136
    )
    private static let renderWorkspace = StaticNRFProfileRegion(
        offset: 9_184,
        byteCount: 4_704
    )
    private static let canvasCallable = StaticNRFProfileRegion(
        offset: 13_888,
        byteCount: 160
    )
    private static let pathWorkspace = StaticNRFProfileRegion(
        offset: 14_048,
        byteCount: 3_280
    )
    private static let drawingPlan = StaticNRFProfileRegion(
        offset: 17_328,
        byteCount: 13_536
    )
    private static let observableLive = StaticNRFProfileRegion(
        offset: 30_864,
        byteCount: 128
    )
    private static let observableCandidate = StaticNRFProfileRegion(
        offset: 30_992,
        byteCount: 128
    )
    private static let interactionCandidate = StaticNRFProfileRegion(
        offset: 31_120,
        byteCount: 256
    )
    private static let interactionCommitted = StaticNRFProfileRegion(
        offset: 31_376,
        byteCount: 256
    )
    private static let admissionQueue = StaticNRFProfileRegion(
        offset: 31_632,
        byteCount: 2_176
    )
    private static let sealedBatch = StaticNRFProfileRegion(
        offset: 33_808,
        byteCount: 2_176
    )
    private static let pointerState = StaticNRFProfileRegion(
        offset: 35_984,
        byteCount: 96
    )
    private static let coordinatorState = StaticNRFProfileRegion(
        offset: 36_080,
        byteCount: 192
    )
    private static let failureState = StaticNRFProfileRegion(
        offset: 36_272,
        byteCount: 96
    )

    private let storage: UnsafeMutableRawBufferPointer

    package init?(storage: UnsafeMutableRawBufferPointer) {
        guard storage.count == Self.requiredByteCount,
            storage.baseAddress != nil
        else { return nil }
        storage.initializeMemory(as: UInt8.self, repeating: 0)
        self.storage = storage
    }

    package var byteCounts: RuntimeStorageByteCounts {
        RuntimeStorageByteCounts(
            semanticCandidateBytes: UInt32(Self.semanticCandidate.byteCount),
            semanticPublishedBytes: UInt32(Self.semanticPublished.byteCount),
            layoutCandidateBytes: UInt32(Self.layoutCandidate.byteCount),
            renderWorkspaceBytes: UInt32(Self.renderWorkspace.byteCount),
            canvasCallableBytes: UInt32(Self.canvasCallable.byteCount),
            pathWorkspaceBytes: UInt32(Self.pathWorkspace.byteCount),
            drawingPlanBytes: UInt32(Self.drawingPlan.byteCount),
            observableLiveBytes: UInt32(Self.observableLive.byteCount),
            observableCandidateBytes: UInt32(Self.observableCandidate.byteCount),
            interactionCandidateBytes: UInt32(Self.interactionCandidate.byteCount),
            interactionCommittedBytes: UInt32(Self.interactionCommitted.byteCount),
            admissionQueueBytes: UInt32(Self.admissionQueue.byteCount),
            sealedBatchBytes: UInt32(Self.sealedBatch.byteCount),
            pointerStateBytes: UInt32(Self.pointerState.byteCount),
            coordinatorStateBytes: UInt32(Self.coordinatorState.byteCount),
            failureStateBytes: UInt32(Self.failureState.byteCount)
        )
    }

    /// Lends one exact family range for a synchronous focused operation.
    package mutating func withRegion<Result>(
        _ family: RuntimeStorageFamily,
        _ body: (UnsafeMutableRawBufferPointer) throws -> Result
    ) rethrows -> Result {
        let region = Self.region(for: family)
        return try body(
            UnsafeMutableRawBufferPointer(
                rebasing: storage[region.offset ..< region.offset + region.byteCount]
            )
        )
    }

    package mutating func withSemanticRegions<Result>(
        _ body: (
            UnsafeMutableRawBufferPointer,
            UnsafeMutableRawBufferPointer
        ) throws -> Result
    ) rethrows -> Result {
        let candidate = Self.semanticCandidate
        let published = Self.semanticPublished
        return try body(
            UnsafeMutableRawBufferPointer(
                rebasing: storage[candidate.offset ..< candidate.offset + candidate.byteCount]
            ),
            UnsafeMutableRawBufferPointer(
                rebasing: storage[published.offset ..< published.offset + published.byteCount]
            )
        )
    }

    package mutating func withLayoutRegions<Result>(
        _ body: (
            UnsafeMutableRawBufferPointer,
            UnsafeMutableRawBufferPointer
        ) throws -> Result
    ) rethrows -> Result {
        let layout = Self.layoutCandidate
        let render = Self.renderWorkspace
        return try body(
            UnsafeMutableRawBufferPointer(
                rebasing: storage[layout.offset ..< layout.offset + layout.byteCount]
            ),
            UnsafeMutableRawBufferPointer(
                rebasing: storage[render.offset ..< render.offset + render.byteCount]
            )
        )
    }

    package mutating func resetAttemptRegions() {
        reset(Self.semanticCandidate)
        reset(Self.layoutCandidate)
        reset(Self.renderWorkspace)
        reset(Self.canvasCallable)
        reset(Self.pathWorkspace)
        reset(Self.drawingPlan)
        reset(Self.observableCandidate)
        reset(Self.interactionCandidate)
    }

    package mutating func resetAllRegions() {
        storage.initializeMemory(as: UInt8.self, repeating: 0)
    }

    private func reset(_ region: StaticNRFProfileRegion) {
        storage[region.offset ..< region.offset + region.byteCount]
            .initializeMemory(as: UInt8.self, repeating: 0)
    }

    private static func region(for family: RuntimeStorageFamily) -> StaticNRFProfileRegion {
        switch family {
        case .semanticCandidate: semanticCandidate
        case .semanticPublished: semanticPublished
        case .layoutCandidate: layoutCandidate
        case .renderWorkspace: renderWorkspace
        case .canvasCallable: canvasCallable
        case .pathWorkspace: pathWorkspace
        case .drawingPlan: drawingPlan
        case .observableLive: observableLive
        case .observableCandidate: observableCandidate
        case .interactionCandidate: interactionCandidate
        case .interactionCommitted: interactionCommitted
        case .admissionQueue: admissionQueue
        case .sealedBatch: sealedBatch
        case .pointerState: pointerState
        case .coordinatorState: coordinatorState
        case .failureState: failureState
        }
    }
}
