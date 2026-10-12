import GiftUI
import GiftUIDrawing
import GiftUIObservableState
import GiftUISemanticCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import P08CounterSchema
import P08CounterPresentation

private let counterRecordLimits = SemanticRecordLimits(records: 64, paths: 192, depth: 24, fanout: 5, payloads: 64, textScalars: 64, payloadBytes: 4096)!
private let counterExpansionLimits = SemanticExpansionLimits(maximumDepth: 24, maximumSemanticNodes: 24, maximumBodyEvaluations: 8, maximumModifierApplications: 8, maximumActionOccurrences: 2)!
private struct CounterSemanticBacking: ~Copyable {
    var records: InlineArray<128, SemanticRuntimeRecord> = .init(repeating: .init())
    var paths: InlineArray<384, SemanticPathEntry> = .init(repeating: .init())
    var payloads: InlineArray<128, CounterPayload?> = .init(repeating: nil)
    var scalars: InlineArray<128, UInt32> = .init(repeating: 0)
}
private func withCounterValues(dynamic: Bool, _ body: (borrowing CanvasStagedValues<SemanticRecordReference, CounterValueTable>) throws(DrawingError) -> Void) throws(DrawingError) {
    let limits = StaticCanvasLimits(maximumStaticCallableCases: 1, maximumStaticCaptureBytes: 32)!
    #if !hasFeature(Embedded)
    if dynamic {
        var storage = DynamicCanvasCallableStorage<SemanticRecordReference, CounterValueTable>(capacity: 1)
        return try storage.withLifetime(table: CounterValueTable(), limits: limits, body)
    }
    #endif
    var storage = StaticCanvasValueStorage()
    var backing: InlineArray<1, CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?> = .init(repeating: nil)
    var entries = backing.mutableSpan
    try storage.withLifetime(entries: &entries, table: CounterValueTable(), capacity: 1, limits: limits, body)
}
private func inspectCounter(_ bank: borrowing SemanticRecordView<CounterPayload>, value: UInt8) -> (SemanticCompleteIdentity, Int) {
    var checks = 0, textCount = 0, actionCount = 0, disabledCount = 0, canvasCount = 0
    var modelIdentity: SemanticCompleteIdentity?
    for index: UInt16 in 0..<bank.recordCount {
        let ref = bank.reference(at: index)!
        let record = bank.record(ref)!
        if bank.path(at: record.path)?.component.role == 1 {
            var target = bank.completeIdentity(for: ref)!
            // visitCustomBody enters customBody before evaluateStateful binds
            // State; this is the owning declaration identity, not its record key.
            counterSemanticExpect(target.append(.init(kind: .customBody)))
            modelIdentity = target
        }
        guard let payload = bank.payload(at: record.payload) else { continue }
        switch payload {
        case .canvas:
            canvasCount += 1
        case .standard(.text):
            let expected: InlineArray<9, UInt32> = textCount == 0 ? [67,111,117,110,116,101,114,0,0] : textCount == 1 ? [UInt32(48 + value),0,0,0,0,0,0,0,0] : textCount == 2 ? [73,110,99,114,101,109,101,110,116] : [82,101,115,101,116,0,0,0,0]
            let count: UInt16 = textCount == 0 ? 7 : textCount == 1 ? 1 : textCount == 2 ? 9 : 5
            counterSemanticExpect(record.textScalarCount == count); checks += 1
            for scalar: UInt16 in 0..<count { counterSemanticExpect(bank.scalar(at: record.firstTextScalar + scalar) == expected[Int(scalar)]); checks += 1 }
            textCount += 1
        case .standard(.action(let role, let code)):
            counterSemanticExpect(role == 6 && code == UInt16(actionCount)); actionCount += 1; checks += 1
        case .standard(.disabled(let disabled)):
            counterSemanticExpect(disabled == (disabledCount == 0 ? value == 9 : value == 0)); disabledCount += 1; checks += 1
        default: break
        }
    }
    counterSemanticExpect(textCount == 4 && actionCount == 2 && disabledCount == 2 && canvasCount == 1); checks += 1
    counterSemanticExpect(bank.recordCount <= 64 && bank.pathCount <= 192 && bank.payloadBytes <= 4096); checks += 1
    return (modelIdentity!, checks)
}
private func exerciseCounter(_ semantic: borrowing SemanticRecordStore<CounterPayload>, models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, dynamic: Bool) throws(SemanticExpansionError) -> Int {
    var checks = 0
    var identity: SemanticCompleteIdentity?
    var key: _GiftUIModelKey<CounterModelSchema>?
    for value: UInt8 in 0...9 {
        do throws(ObservableStateError) {
            if let key { counterSemanticExpect(models.mutate(key, mutation: .fact(value), report: { .dirtied }) == .success(.dirtied)); checks += 1 }
            try models.beginFrame()
            try models.withDiscovery { () throws(ObservableStateError) in
                guard case .success = root.beginCandidate() else { preconditionFailure("counter begin") }
            }
            let result = semantic.expand(CounterScreen<CounterDomain>(), roles: CounterRoles.self, codec: CanvasSemanticPayloadCodec<CounterRoles, CounterValueTable>.self, limits: counterExpansionLimits, binding: ObservableSemanticBodyBinding(models: models.borrowedScope(), root: root.borrowedRoot(), domain: CounterDomain.self))
            guard case .success = result else { print("counter expansion failed", result); preconditionFailure("counter expansion") }
            do throws(DrawingError) {
                try withCounterValues(dynamic: dynamic) { (values) throws(DrawingError) in
                    try CanvasSemanticTransfer.stage(from: semantic, into: values, table: CounterValueTable())
                    counterSemanticExpect(values.count == 1 && values.releaseCount == 0); checks += 1
                    do throws(SemanticExpansionError) {
                        try semantic.withCandidateView { bank in
                            let inspected = inspectCounter(bank, value: value)
                            identity = inspected.0; checks += inspected.1
                        }
                    } catch { print("counter caught", error); preconditionFailure("counter view") }
                    checks += counterRenderActual(semantic: semantic, models: models, values: values, value: value, dynamic: dynamic)
                    values.discard()
                    counterSemanticExpect(values.count == 0 && values.releaseCount == 1); checks += 1
                }
            } catch { print("counter caught", error); preconditionFailure("counter Canvas transfer") }
            try models.withDiscovery { () throws(ObservableStateError) in
                guard case .success = root.finishCandidate(.publish) else { preconditionFailure("counter publish State") }
            }
            try models.endFrame()
            key = root.modelKey(identity: identity!, ordinal: 0)!
        } catch { print("counter caught", error); preconditionFailure("counter model phase") }
        try semantic.publishCandidate()
    }
    do throws(ObservableStateError) {
        // This explicit-final-ticket transfer API refuses while another cache
        // claim exists. This does not claim that all independent scalar-slot
        // replacement strategies require reclaiming retained former backing.
        var transfer = try models.retain(key!)
        var cache = try models.retain(key!)
        counterSemanticExpect(root.replace(identity: identity!, ordinal: 0, transferring: &transfer, seed: .init(value: 3)) == .failure(.retainedModel)); checks += 1
        try models.release(&cache)
        counterSemanticExpect(root.replace(identity: identity!, ordinal: 0, transferring: &transfer, seed: .init(value: 3)) == .success(.replaced)); checks += 1
        let replacement = root.modelKey(identity: identity!, ordinal: 0)!
        counterSemanticExpect(replacement != key); checks += 1
        try models.beginFrame()
        try models.pin(replacement)
        do throws(_GiftUIAccessFailure) {
            try models.withRead(CounterDomain.self) { (read) throws(_GiftUIAccessFailure) in
                counterSemanticExpect(try CounterRead<CounterDomain>(replacement, read: read).value == 3); checks += 1
            }
        } catch { throw ObservableStateError(accessFailure: error) }
        try models.endFrame()
        counterSemanticExpect(models.mutate(key!, mutation: .reset, report: { .dirtied }) == .failure(.staleModel)); checks += 1
        try root.shutdown(); checks += 1
    } catch { print("counter caught", error); preconditionFailure("counter cache/replacement") }
    return checks
}
private func counterSemanticBacking(models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, dynamic: Bool) -> Int {
    do throws(SemanticExpansionError) {
        var namespace = SemanticRecordOwnerNamespace()
        #if !hasFeature(Embedded)
        if dynamic {
            let storage = DynamicSemanticRecordStorage<CounterPayload>(limits: counterRecordLimits, owner: try namespace.issue())
            return try storage.withLifetime { (semantic) throws(SemanticExpansionError) in try exerciseCounter(semantic, models: models, root: root, dynamic: true) }
        }
        #endif
        var storage = StaticSemanticRecordStorage(limits: counterRecordLimits, owner: try namespace.issue())
        var backing = CounterSemanticBacking()
        var records = backing.records.mutableSpan; var paths = backing.paths.mutableSpan
        var payloads = backing.payloads.mutableSpan; var scalars = backing.scalars.mutableSpan
        return try storage.withLifetime(records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (semantic) throws(SemanticExpansionError) in try exerciseCounter(semantic, models: models, root: root, dynamic: false) }
    } catch { print("counter caught", error); preconditionFailure("counter semantic backing") }
}
package func p08CounterSemantic() -> Int {
    var checks = 0
    do throws(ObservableStateError) {
        var namespace = ObservableModelOwnerNamespace()
        var storage = StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>(identity: try namespace.issue(), schema: 1, needsCapture: false)!
        let layout = storage.storageLayout
        counterSemanticExpect(layout.models == 2 && layout.claims == 4 && layout.pins == 2 && layout.captures == 0); checks += 1
        checks += try storage.withLifetime { (models, root) throws(ObservableStateError) in counterSemanticBacking(models: models, root: root, dynamic: false) }
        #if !hasFeature(Embedded)
        let dynamic = DynamicObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>(identity: try namespace.issue(), schema: 1, needsCapture: false)!
        counterSemanticExpect(dynamic.storageLayout.models == 2 && dynamic.storageLayout.claims == 4 && dynamic.storageLayout.pins == 2 && dynamic.storageLayout.captures == 0); checks += 1
        checks += try dynamic.withLifetime { (models, root) throws(ObservableStateError) in counterSemanticBacking(models: models, root: root, dynamic: true) }
        #endif
    } catch { print("counter caught", error); preconditionFailure("counter root") }
    return checks
}

private func counterSemanticExpect(_ condition: Bool, file: StaticString = #fileID, line: UInt = #line) {
    if !condition { print("counter assertion failed", file, line); preconditionFailure("counter assertion") }
}
