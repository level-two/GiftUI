import CycleTable
import GiftUI
import GiftUIDrawing
import GiftUIObservableState
import GiftUISemanticCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import CycleSchema
import CyclePresentation

private typealias Payload = CanvasSemanticPayload<CycleValueTable.CaptureStorage>
enum CycleRoles: SemanticDeclarationRoles {
    static func role<V>(of type: V.Type) -> SemanticRecordingRole? {
        if V.self == CycleScene<CycleDomain>.self { return .init(rawValue: 1) }
        if V.self == CycleScene<CycleDomain>.Body.self { return .init(rawValue: 2) }
        if V.self == CycleRoot<CycleDomain>.self { return .init(rawValue: 3) }
        if V.self == CycleRoot<CycleDomain>.Body.self { return .init(rawValue: 4) }
        if V.self == TupleView3<Text<CycleDomain>, Button<CycleAction, Text<CycleDomain>>, CycleTrace<CycleDomain>>.self { return .init(rawValue: 5) }
        if V.self == Text<CycleDomain>.self { return .init(rawValue: 6) }
        if V.self == Button<CycleAction, Text<CycleDomain>>.self { return .init(rawValue: 7) }
        if V.self == CycleTrace<CycleDomain>.self { return .init(rawValue: 8) }
        if V.self == CycleAction.self { return .init(rawValue: 9) }
        return nil
    }
    static func modifierDiscriminator<V>(of type: V.Type) -> UInt16 { 0 }
}
private struct Backing: ~Copyable {
    var records: InlineArray<252, SemanticRuntimeRecord> = .init(repeating: .init())
    var paths: InlineArray<756, SemanticPathEntry> = .init(repeating: .init())
    var payloads: InlineArray<196, Payload?> = .init(repeating: nil)
    var scalars: InlineArray<448, UInt32> = .init(repeating: 0)
}
private func exercise(_ semantic: borrowing SemanticRecordStore<Payload>, models: borrowing ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, dynamic: Bool) throws(SemanticExpansionError) -> Int {
    var checks = 0
    func expect(_ okay: Bool) { checks += 1; precondition(okay) }
    let limits = SemanticExpansionLimits(maximumDepth: 34, maximumSemanticNodes: 48, maximumBodyEvaluations: 14, maximumModifierApplications: 50, maximumActionOccurrences: 6)!
    do throws(ObservableStateError) {
        expect(root.belongs(to: models))
        var foreignNamespace = ObservableModelOwnerNamespace()
        var foreign = StaticObservableModelStorage<CycleOwnedModel, CycleModelSchema>(identity: try foreignNamespace.issue(), schema: 1, needsCapture: false)!
        try foreign.withLifetime { (other) throws(ObservableStateError) in
            expect(!root.belongs(to: other))
            let rejected = semantic.expand(CycleScene<CycleDomain>(show: true), roles: CycleRoles.self, codec: CanvasSemanticPayloadCodec<CycleRoles, CycleValueTable>.self, limits: limits, binding: ObservableSemanticBodyBinding(models: other.borrowedScope(), root: root.borrowedRoot(), domain: CycleDomain.self))
            guard case .bindingFailure(.incompatibleAssociation) = rejected else { preconditionFailure("foreign owner accepted") }
            checks += 1
            expect(other.phase == .mutating && models.phase == .mutating)
        }
        for show in [true, true, false, true] {
            try models.beginFrame()
            try models.withDiscovery { () throws(ObservableStateError) in
                guard case .success = root.beginCandidate() else { preconditionFailure("begin candidate") }
            }
            let result = semantic.expand(CycleScene<CycleDomain>(show: show), roles: CycleRoles.self, codec: CanvasSemanticPayloadCodec<CycleRoles, CycleValueTable>.self, limits: limits, binding: ObservableSemanticBodyBinding(models: models.borrowedScope(), root: root.borrowedRoot(), domain: CycleDomain.self))
            guard case .success = result else { preconditionFailure("finite State expansion") }
            do throws(DrawingError) {
                try withCycleValues(dynamic: dynamic) { (values) throws(DrawingError) in
                    try CanvasSemanticTransfer.stage(from: semantic, into: values, table: CycleValueTable())
                    expect(values.count == (show ? 1 : 0))
                    #if !hasFeature(Embedded)
                    if dynamic { checks += cycleDynamicDrawing(semantic: semantic, models: models, values: values, shown: show) }
                    else { checks += cycleStaticDrawing(semantic: semantic, models: models, values: values, shown: show) }
                    #else
                    checks += cycleStaticDrawing(semantic: semantic, models: models, values: values, shown: show)
                    #endif
                    values.discard()
                    expect(values.releaseCount == (show ? 1 : 0))
                }
            } catch { preconditionFailure("Canvas transfer") }
            try models.withDiscovery { () throws(ObservableStateError) in
                guard case .success = root.finishCandidate(.publish) else { preconditionFailure("State publish") }
            }
            try models.endFrame()
            expect(models.phase == .mutating)
            // Actual semantic publication is outside the ObservableState typed-error scope.
            do throws(SemanticExpansionError) { try semantic.publishCandidate() }
            catch { preconditionFailure("semantic publication") }
        }
    } catch { preconditionFailure("model phase") }
    return checks
}
private func withSemantic(models: borrowing ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, dynamic: Bool) -> Int {
    do throws(SemanticExpansionError) {
        var namespace = SemanticRecordOwnerNamespace()
        let limits = SemanticRecordLimits(records: 126, paths: 378, depth: 34, fanout: 5, payloads: 98, textScalars: 224, payloadBytes: UInt32(98 * MemoryLayout<Payload?>.stride + 224 * 4))!
        #if !hasFeature(Embedded)
        if dynamic {
            let storage = DynamicSemanticRecordStorage<Payload>(limits: limits, owner: try namespace.issue())
            let before = storage.retainedExtents
            precondition(before.records >= 252 && before.paths >= 756 && before.payloads >= 196 && before.scalars >= 448)
            let result = try storage.withLifetime { (semantic) throws(SemanticExpansionError) in
                try exercise(semantic, models: models, root: root, dynamic: dynamic)
            }
            let after = storage.retainedExtents
            precondition(before.recordBytes == after.recordBytes && before.pathBytes == after.pathBytes)
            precondition(before.payloadBytes == after.payloadBytes && before.controlBytes == after.controlBytes)
            return result + 3
        }
        #endif
        var storage = StaticSemanticRecordStorage(limits: limits, owner: try namespace.issue())
        var backing = Backing()
        var records = backing.records.mutableSpan; var paths = backing.paths.mutableSpan
        var payloads = backing.payloads.mutableSpan; var scalars = backing.scalars.mutableSpan
        return try storage.withLifetime(records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (semantic) throws(SemanticExpansionError) in
            try exercise(semantic, models: models, root: root, dynamic: dynamic)
        }
    } catch { preconditionFailure("semantic owner") }
}
public func giftuiP07CycleSemantic() -> Int {
    var checks = cycleAdmissionBackingProbe() + cycleFactoryProbe() + cycleFactoryCapacityProbe()
    do throws(ObservableStateError) {
        var namespace = ObservableModelOwnerNamespace()
        var storage = StaticObservableRootAdapter<CycleOwnedModel, SemanticCompleteIdentity>(identity: try namespace.issue(), schema: 1, needsCapture: false)!
        let staticLayout = storage.storageLayout
        precondition(staticLayout.models == 2 && staticLayout.claims == 4 && staticLayout.pins == 2 && staticLayout.captures == 0)
        precondition(staticLayout.pinBytes == 2 * MemoryLayout<Bool>.size)
        checks += 2
        checks += try storage.withLifetime { (models, root) throws(ObservableStateError) in
            withSemantic(models: models, root: root, dynamic: false)
        }
        #if !hasFeature(Embedded)
        checks += cycleDynamicStorageEdges()
        let dynamic = DynamicObservableRootAdapter<CycleOwnedModel, SemanticCompleteIdentity>(identity: try namespace.issue(), schema: 1, needsCapture: false)!
        let dynamicLayout = dynamic.storageLayout
        precondition(dynamicLayout.models == staticLayout.models && dynamicLayout.claims == staticLayout.claims && dynamicLayout.pins == staticLayout.pins)
        precondition(dynamicLayout.modelBytes == staticLayout.modelBytes && dynamicLayout.pinBytes == staticLayout.pinBytes)
        precondition(dynamicLayout.liveBytes == staticLayout.liveBytes && dynamicLayout.candidateBytes == staticLayout.candidateBytes)
        checks += 3
        checks += try dynamic.withLifetime { (models, root) throws(ObservableStateError) in
            withSemantic(models: models, root: root, dynamic: true)
        }
        #endif
    } catch { preconditionFailure("root owner") }
    return checks
}

private func withCycleValues(dynamic: Bool, _ body: (borrowing CanvasStagedValues<SemanticRecordReference, CycleValueTable>) throws(DrawingError) -> Void) throws(DrawingError) {
    let limits = StaticCanvasLimits(maximumStaticCallableCases: 1, maximumStaticCaptureBytes: 32)!
    #if !hasFeature(Embedded)
    if dynamic {
        var storage = DynamicCanvasCallableStorage<SemanticRecordReference, CycleValueTable>(capacity: 1)
        return try storage.withLifetime(table: CycleValueTable(), limits: limits, body)
    }
    #endif
    var storage = StaticCanvasValueStorage()
    var backing: InlineArray<1, CanvasStagedEntry<SemanticRecordReference, CycleValueTable.CaptureStorage>?> = .init(repeating: nil)
    var entries = backing.mutableSpan
    try storage.withLifetime(entries: &entries, table: CycleValueTable(), capacity: 1, limits: limits, body)
}
