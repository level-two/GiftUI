import GiftUI
import GiftUIRenderCore
import Testing

@testable import GiftUIRenderLowering

@Test
func renderLimitsRequireThreeNonzeroBoundsAndPreserveExactValues() {
    #expect(
        RenderLimits(
            maximumOperations: 0,
            maximumPositionedGlyphs: 1,
            maximumClipDepth: 1
        ) == nil
    )
    #expect(
        RenderLimits(
            maximumOperations: 1,
            maximumPositionedGlyphs: 0,
            maximumClipDepth: 1
        ) == nil
    )
    #expect(
        RenderLimits(
            maximumOperations: 1,
            maximumPositionedGlyphs: 1,
            maximumClipDepth: 0
        ) == nil
    )

    let limits = RenderLimits(
        maximumOperations: 11,
        maximumPositionedGlyphs: 12,
        maximumClipDepth: 13
    )!
    #expect(limits.maximumOperations == 11)
    #expect(limits.maximumPositionedGlyphs == 12)
    #expect(limits.maximumClipDepth == 13)
    #expect(MemoryLayout<RenderLimits>.size == 6)
    #expect(MemoryLayout<RenderLimits>.stride == 6)
}

@Test
func renderProductionResultPreservesExactSuccessAndFailureValues() {
    let zero = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 0, height: 0)!
    )!
    let header = RenderPlanHeader(
        surfaceBounds: zero,
        damageBounds: zero,
        operationCount: 1,
        positionedGlyphCount: 2,
        maximumObservedClipDepth: 3
    )

    #expect(RenderProductionResult.success(header) == .success(header))
    for error in RenderProductionError.allFixtureCases {
        #expect(RenderProductionResult.failure(error) == .failure(error))
    }
    #expect(MemoryLayout<RenderProductionResult>.size <= 44)
    #expect(MemoryLayout<RenderProductionResult>.stride <= 44)
}

@Test
func boundedWorkspaceReportsCapacityAndHasExactAcquireResetLifecycle() {
    var workspace = FixtureRenderWorkspace<UInt16>()

    #expect(workspace.capacity == FixtureRenderWorkspace<UInt16>.limits)
    #expect(!workspace.isActive)
    let firstAcquire = workspace.acquire()
    #expect(firstAcquire)
    #expect(workspace.isActive)
    let nestedAcquire = workspace.acquire()
    #expect(!nestedAcquire)
    workspace.reset()
    #expect(!workspace.isActive)
    let secondAcquire = workspace.acquire()
    #expect(secondAcquire)
    workspace.reset()
    #expect(workspace.resetCount == 2)
}

private struct FixtureRenderWorkspace<Identity>: RenderProductionWorkspace
where Identity: Equatable & Sendable {
    static var limits: RenderLimits {
        RenderLimits(
            maximumOperations: 8,
            maximumPositionedGlyphs: 16,
            maximumClipDepth: 4
        )!
    }

    let capacity = Self.limits
    private(set) var isActive = false
    private(set) var resetCount: UInt16 = 0
    private var activeIdentity: Identity?
    private var foregroundDepth: UInt16 = 0
    private var traversalDepth: UInt16 = 0
    private var preflightOperationCount: UInt16 = 0
    private var clipDepth: UInt16 = 0

    mutating func acquire() -> Bool {
        guard !isActive else { return false }
        isActive = true
        return true
    }

    mutating func reset() {
        activeIdentity = nil
        foregroundDepth = 0
        traversalDepth = 0
        preflightOperationCount = 0
        clipDepth = 0
        isActive = false
        resetCount += 1
    }
}

private extension RenderProductionError {
    static let allFixtureCases: [Self] = [
        .invalidInput,
        .arithmeticOverflow,
        .capacityExhausted,
        .incompatibleTextResource,
        .sinkRefused,
        .reentrancyViolation,
        .invariantViolation,
    ]
}
