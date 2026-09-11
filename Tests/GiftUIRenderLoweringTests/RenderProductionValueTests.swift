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
func renderWorkspaceCapacityRequiresFourNonzeroBoundsAndExactLayout() {
    #expect(
        RenderWorkspaceCapacity(
            maximumSemanticScopes: 0,
            maximumLayoutScopes: 1,
            maximumTraversalDepth: 1,
            maximumTextLines: 1
        ) == nil
    )
    #expect(
        RenderWorkspaceCapacity(
            maximumSemanticScopes: 1,
            maximumLayoutScopes: 0,
            maximumTraversalDepth: 1,
            maximumTextLines: 1
        ) == nil
    )
    #expect(
        RenderWorkspaceCapacity(
            maximumSemanticScopes: 1,
            maximumLayoutScopes: 1,
            maximumTraversalDepth: 0,
            maximumTextLines: 1
        ) == nil
    )
    #expect(
        RenderWorkspaceCapacity(
            maximumSemanticScopes: 1,
            maximumLayoutScopes: 1,
            maximumTraversalDepth: 1,
            maximumTextLines: 0
        ) == nil
    )

    let capacity = RenderWorkspaceCapacity(
        maximumSemanticScopes: 11,
        maximumLayoutScopes: 12,
        maximumTraversalDepth: 13,
        maximumTextLines: 14
    )!
    #expect(capacity.maximumSemanticScopes == 11)
    #expect(capacity.maximumLayoutScopes == 12)
    #expect(capacity.maximumTraversalDepth == 13)
    #expect(capacity.maximumTextLines == 14)
    #expect(MemoryLayout<RenderWorkspaceCapacity>.size == 8)
    #expect(MemoryLayout<RenderWorkspaceVisit>.size == 1)
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
    #expect(workspace.structuralCapacity == FixtureRenderWorkspace<UInt16>.structure)
    #expect(!workspace.isActive)
    let firstAcquire = workspace.acquire()
    #expect(firstAcquire)
    #expect(workspace.isActive)
    #expect(workspace.visitSemanticScope(at: 0) == .first)
    #expect(workspace.visitSemanticScope(at: 0) == .repeated)
    #expect(workspace.visitSemanticScope(at: 8) == .invalid)
    #expect(workspace.visitLayoutScope(at: 0) == .first)
    #expect(workspace.visitLayoutScope(at: 0) == .repeated)
    let nestedAcquire = workspace.acquire()
    #expect(!nestedAcquire)
    workspace.reset()
    #expect(!workspace.isActive)
    let secondAcquire = workspace.acquire()
    #expect(secondAcquire)
    #expect(workspace.visitSemanticScope(at: 0) == .first)
    #expect(workspace.visitLayoutScope(at: 0) == .first)
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

    static var structure: RenderWorkspaceCapacity {
        RenderWorkspaceCapacity(
            maximumSemanticScopes: 8,
            maximumLayoutScopes: 8,
            maximumTraversalDepth: 8,
            maximumTextLines: 8
        )!
    }

    let capacity = Self.limits
    let structuralCapacity = Self.structure
    private(set) var isActive = false
    private(set) var resetCount: UInt16 = 0
    private var activeIdentity: Identity?
    private var foregroundDepth: UInt16 = 0
    private var traversalDepth: UInt16 = 0
    private var preflightOperationCount: UInt16 = 0
    private var clipDepth: UInt16 = 0
    private var semanticVisits = [Bool](repeating: false, count: 8)
    private var layoutVisits = [Bool](repeating: false, count: 8)

    mutating func acquire() -> Bool {
        guard !isActive else { return false }
        isActive = true
        return true
    }

    mutating func visitSemanticScope(at ordinal: UInt16) -> RenderWorkspaceVisit {
        visit(ordinal: ordinal, in: &semanticVisits)
    }

    mutating func visitLayoutScope(at ordinal: UInt16) -> RenderWorkspaceVisit {
        visit(ordinal: ordinal, in: &layoutVisits)
    }

    mutating func reset() {
        activeIdentity = nil
        foregroundDepth = 0
        traversalDepth = 0
        preflightOperationCount = 0
        clipDepth = 0
        semanticVisits = [Bool](repeating: false, count: 8)
        layoutVisits = [Bool](repeating: false, count: 8)
        isActive = false
        resetCount += 1
    }

    private func visit(
        ordinal: UInt16,
        in visits: inout [Bool]
    ) -> RenderWorkspaceVisit {
        guard isActive, Int(ordinal) < visits.count else { return .invalid }
        let index = Int(ordinal)
        if visits[index] { return .repeated }
        visits[index] = true
        return .first
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
