import GiftUI
import GiftUISemanticCore
import Testing

@testable import GiftUIRuntimeDynamic

private enum SemanticHostAction: UInt16, GiftUIAction {
    case run = 7
}

private struct SemanticHostRoot: View {
    var body: some View {
        VStack {
            Button("Run", action: SemanticHostAction.run)
                .disabled(true)
            Canvas { _, _ in }
            Text("A°")
        }
    }
}

private struct StructuralExcessRoot: View {
    var body: some View {
        VStack {
            Text("A")
        }
    }
}

@Test func dynamicSemanticHostStoragePreservesRenderCanvasAndActionFacts() throws {
    let limits = try #require(
        SemanticExpansionLimits(
            maximumDepth: 16,
            maximumSemanticNodes: 16,
            maximumBodyEvaluations: 4,
            maximumModifierApplications: 2,
            maximumActionOccurrences: 1
        )
    )
    var workspace = DynamicSemanticExpansionWorkspace(
        maximumPathComponents: 16,
        maximumIdentities: 64
    )
    var storage = DynamicSemanticHostStorage(
        limits: limits,
        maximumStructuralOccurrences: 16,
        canvasCapacity: 1
    )

    let result = expandSemanticTree(
        SemanticHostRoot(),
        limits: limits,
        workspace: &workspace,
        sink: &storage
    )

    guard case .success(let summary) = result else {
        Issue.record("production Dynamic semantic expansion failed: \(result)")
        return
    }
    #expect(storage.hasPublishedResult)
    #expect(!workspace.isExpanding)
    #expect(summary.actionOccurrenceCount == 1)
    #expect(storage.actionOccurrenceCount == 1)
    let action = try #require(storage.action(at: 0))
    #expect(action.action.code == SemanticHostAction.run.rawValue)
    #expect(!storage.isActionEnabled(at: action.identity))
    #expect(storage.primitive(at: action.identity) == .proxy)
    #expect(storage.canvasOccurrenceCount == 1)
    #expect(storage.canvasIdentity(at: 0) != nil)
    #expect(storage.semanticScopeCount > 0)
    #expect(storage.renderSnapshotVersion == 1)

    var foundDegree = false
    for ordinal in 0 ..< storage.semanticScopeCount {
        guard let identity = storage.semanticIdentity(at: ordinal),
            let scalarCount = storage.textScalarCount(of: identity)
        else { continue }
        for scalarIndex in 0 ..< scalarCount
        where storage.textScalar(of: identity, at: scalarIndex) == 0xB0 {
            foundDegree = true
        }
    }
    #expect(foundDegree)
}

@Test func dynamicSemanticHostStorageDiscardsFirstExcessAtomically() throws {
    let limits = try #require(
        SemanticExpansionLimits(
            maximumDepth: 16,
            maximumSemanticNodes: 16,
            maximumBodyEvaluations: 4,
            maximumModifierApplications: 2,
            maximumActionOccurrences: 0
        )
    )
    var workspace = DynamicSemanticExpansionWorkspace(
        maximumPathComponents: 16,
        maximumIdentities: 64
    )
    var storage = DynamicSemanticHostStorage(
        limits: limits,
        maximumStructuralOccurrences: 16,
        canvasCapacity: 1
    )

    let result = expandSemanticTree(
        SemanticHostRoot(),
        limits: limits,
        workspace: &workspace,
        sink: &storage
    )

    #expect(result == .failure(.capacityExhausted))
    #expect(!storage.hasPublishedResult)
    #expect(storage.actionOccurrenceCount == 0)
    #expect(storage.canvasOccurrenceCount == 0)
    #expect(!workspace.isExpanding)
}

@Test func dynamicSemanticHostStorageRejectsFirstStructuralExcess() throws {
    let limits = try #require(
        SemanticExpansionLimits(
            maximumDepth: 16,
            maximumSemanticNodes: 2,
            maximumBodyEvaluations: 2,
            maximumModifierApplications: 0,
            maximumActionOccurrences: 0
        )
    )
    var workspace = DynamicSemanticExpansionWorkspace(
        maximumPathComponents: 16,
        maximumIdentities: 64
    )
    var storage = DynamicSemanticHostStorage(
        limits: limits,
        maximumStructuralOccurrences: 2,
        canvasCapacity: 0
    )

    let result = expandSemanticTree(
        StructuralExcessRoot(),
        limits: limits,
        workspace: &workspace,
        sink: &storage
    )

    #expect(result == .failure(.capacityExhausted))
    #expect(!storage.hasPublishedResult)
    #expect(!workspace.isExpanding)
}
