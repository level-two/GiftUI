import GiftUI
import GiftUIRenderLowering
import GiftUIRuntimeDynamic
import Testing

@Test func dynamicRenderWorkspaceEnforcesExactStructuralBoundsAndResets() {
    let render = RenderLimits(
        maximumOperations: 3,
        maximumPositionedGlyphs: 5,
        maximumClipDepth: 2
    )!
    let structure = RenderWorkspaceCapacity(
        maximumSemanticScopes: 2,
        maximumLayoutScopes: 3,
        maximumTraversalDepth: 2,
        maximumTextLines: 1
    )!
    var workspace = DynamicRenderWorkspace(
        capacity: render,
        structuralCapacity: structure
    )

    #expect(workspace.capacity == render)
    #expect(workspace.structuralCapacity == structure)
    #expect(!workspace.isActive)
    #expect(workspace.visitSemanticScope(at: 0) == .invalid)
    #expect(workspace.visitLayoutScope(at: 0) == .invalid)
    let firstAcquire = workspace.acquire()
    let nestedAcquire = workspace.acquire()
    #expect(firstAcquire)
    #expect(!nestedAcquire)

    #expect(workspace.visitSemanticScope(at: 0) == .first)
    #expect(workspace.visitSemanticScope(at: 1) == .first)
    #expect(workspace.visitSemanticScope(at: 0) == .repeated)
    #expect(workspace.visitSemanticScope(at: 2) == .invalid)
    #expect(workspace.visitLayoutScope(at: 0) == .first)
    #expect(workspace.visitLayoutScope(at: 2) == .first)
    #expect(workspace.visitLayoutScope(at: 3) == .invalid)

    let first = Color(red: 1, green: 2, blue: 3)
    let second = Color(red: 4, green: 5, blue: 6)
    let pushedFirst = workspace.pushForeground(first)
    #expect(pushedFirst)
    #expect(workspace.currentForeground == first)
    let pushedSecond = workspace.pushForeground(second)
    let pushedExcess = workspace.pushForeground(first)
    #expect(pushedSecond)
    #expect(!pushedExcess)
    #expect(workspace.currentForeground == second)
    let poppedSecond = workspace.popForeground()
    #expect(poppedSecond)
    #expect(workspace.currentForeground == first)
    let poppedFirst = workspace.popForeground()
    let poppedEmpty = workspace.popForeground()
    #expect(poppedFirst)
    #expect(!poppedEmpty)

    workspace.reset()
    #expect(!workspace.isActive)
    #expect(workspace.currentForeground == nil)
    let reacquired = workspace.acquire()
    #expect(reacquired)
    #expect(workspace.visitSemanticScope(at: 0) == .first)
    #expect(workspace.visitLayoutScope(at: 0) == .first)
    workspace.reset()
}
