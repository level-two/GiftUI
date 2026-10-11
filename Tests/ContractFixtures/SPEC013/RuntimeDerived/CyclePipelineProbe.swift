import CycleTable
import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
@testable import GiftUIRuntimeCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import GiftUISemanticCore
import CycleSchema

func exercisePipeline<G, C, R, H>(models: borrowing ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, semantic: borrowing SemanticRecordStore<CyclePayload>, values: borrowing CanvasStagedValues<SemanticRecordReference, CycleValueTable>, dynamic: Bool, geometry: consuming G, interaction: consuming InteractionOwnedKeyState<C, R, H>) -> CycleReturnedWorkspaces<G, C, R, H> where G: CycleGeometry, C: CycleCandidateBacking, R: CycleCommittedBacking, H: CycleHitBacking, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    var control = CycleControl()
    var transferredGeometry: G? = consume geometry
    var transferredInteraction: InteractionOwnedKeyState<C, R, H>? = consume interaction
    return withUnsafeMutablePointer(to: &control) { trace in
        var owner = CyclePipelineOwner(models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic.borrowedStore(), values: values.borrowedValues(), geometry: transferredGeometry.take()!, interaction: transferredInteraction.take()!, control: trace)
        var checks = 0
        func expect(_ value: Bool) { checks += 1; precondition(value) }
        var result = RuntimeCompletePipeline.run(owner: &owner)
        guard case .completed(let initial) = result else { preconditionFailure("initial complete pipeline") }
        expect(initial.disposition.logicalFrameDisposition == .committed)
        expect(trace.pointee.stages == 2047 && trace.pointee.finalized == 1 && trace.pointee.commits == 1)
        expect(models.phase == .mutating && values.count == 0)
        expect(owner.interaction.committedRecordCount == 1)
        trace.pointee.mutate = true; trace.pointee.offer = .retryableRefusal
        result = RuntimeCompletePipeline.run(owner: &owner)
        guard case .completed(let refused) = result else { preconditionFailure("refusal pipeline") }
        expect(refused.operational == .retryableRefusal && refused.disposition.presentationIntentState == .pending)
        expect(trace.pointee.applied == 1 && trace.pointee.commits == 1)
        trace.pointee.offer = .accepted
        result = RuntimeCompletePipeline.run(owner: &owner)
        guard case .completed(let retried) = result else { preconditionFailure("retry pipeline") }
        expect(retried.publication.semanticRevision == refused.publication.semanticRevision && !retried.publication.changed)
        expect(trace.pointee.applied == 1 && trace.pointee.commits == 2)
        expect(models.phase == .mutating && values.count == 0)
        trace.pointee.mutate = true; trace.pointee.failAfterMutation = true
        result = RuntimeCompletePipeline.run(owner: &owner)
        guard case .failed(let partial) = result else { preconditionFailure("partial mutation") }
        expect(partial.stage == .applyAdmittedWork && partial.disposition.semanticDisposition == .dirty)
        expect(trace.pointee.applied == 2 && partial.disposition.wakeReasons.contains(.semanticDirty))
        trace.pointee.failAfterMutation = false
        result = RuntimeCompletePipeline.run(owner: &owner)
        guard case .completed(let recovered) = result else { preconditionFailure("partial recovery") }
        expect(recovered.publication.changed && trace.pointee.applied == 2)
        for offer: FrameOfferDisposition in [.backpressured, .nonRetryableRefusal] {
            trace.pointee.offer = offer
            let streams = trace.pointee.streams, commits = trace.pointee.commits
            result = RuntimeCompletePipeline.run(owner: &owner)
            switch result {
            case .completed(let refusal):
                expect(offer == .backpressured && refusal.disposition.logicalFrameDisposition == .aborted)
                expect(refusal.disposition.presentationIntentState == .pending)
            case .failed(let refusal):
                expect(offer == .nonRetryableRefusal && refusal.failure == .nonRetryableRefusal(.endpoint))
                expect(refusal.disposition.presentationIntentState == .unavailable)
            }
            expect(trace.pointee.streams == streams && trace.pointee.commits == commits)
            expect(models.phase == .mutating && values.count == 0)
        }
        trace.pointee.offer = .accepted
        for raw: UInt8 in 0...10 {
            trace.pointee.fault = RuntimeCompletePipelineStage(rawValue: raw)!
            trace.pointee.stages = 0; trace.pointee.cleanups = 0
            let finalized = trace.pointee.finalized
            result = RuntimeCompletePipeline.run(owner: &owner)
            guard case .failed(let failed) = result else { preconditionFailure("fault pipeline") }
            expect(failed.stage.rawValue == raw && failed.failure == .execution(.capacityExhausted))
            expect(trace.pointee.stages == (UInt16(1) << (raw + 1)) - 1)
            expect(trace.pointee.finalized == finalized + 1)
            expect(models.phase == .mutating && values.count == 0 && !owner.frameActive)
            for index in 1..<max(1, trace.pointee.cleanupCount) {
                expect(trace.pointee.cleanupOrder[index - 1] < trace.pointee.cleanupOrder[index])
            }
        }
        trace.pointee.fault = nil; trace.pointee.show = false; owner.changed = true
        result = RuntimeCompletePipeline.run(owner: &owner)
        guard case .completed = result else { preconditionFailure("retirement pipeline") }
        expect(owner.rootIdentity == nil && owner.interaction.committedRecordCount == 0)
        expect(models.phase == .mutating && values.count == 0)
        owner.quiescent = true
        result = RuntimeCompletePipeline.run(owner: &owner)
        guard case .failed(let stopped) = result else { preconditionFailure("quiescence pipeline") }
        expect(stopped.failure == .execution(.requiredFacilityUnavailable))
        expect(models.phase == .mutating)
        owner.quiescent = false
        trace.pointee.show = true; owner.changed = true
        var returned = cycleConcreteCoordinator(owner: consume owner, dynamic: dynamic, control: trace)
        returned.checks += checks
        return consume returned
    }
}
func cyclePipelineProbe(models: borrowing ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, semantic: borrowing SemanticRecordStore<CyclePayload>, dynamic: Bool) -> Int {
    var checks = 0
    do throws(DrawingError) {
        try withPipelineValues(dynamic: dynamic) { values in
            #if !hasFeature(Embedded)
            if dynamic {
                typealias C = DynamicInteractionCandidateStorage<SemanticCompleteIdentity>
                typealias R = DynamicInteractionCommittedStorage<SemanticCompleteIdentity>
                typealias H = DynamicInteractionHitStorage<SemanticCompleteIdentity>
                let state = InteractionState(candidateRecords: C(capacity: 6), candidateHitRegions: H(capacity: 6), candidateCommittedRecords: R(capacity: 6), committedRecords: R(capacity: 6), committedHitRegions: H(capacity: 6))
                let keys = InteractionOwnedKeyState(state: state, maximumComponentsPerKey: 34, maximumComponents: 204)!
                checks += exercisePipeline(models: models, root: root, semantic: semantic, values: values, dynamic: dynamic, geometry: DynamicCycleGeometry(), interaction: keys).checks
                return
            }
            #endif
            typealias C = StaticSixInteractionCandidateStorage<SemanticCompleteIdentity>
            typealias R = StaticSixInteractionCommittedStorage<SemanticCompleteIdentity>
            typealias H = StaticSixInteractionHitStorage<SemanticCompleteIdentity>
            let state = InteractionState(candidateRecords: C(capacity: 6)!, candidateHitRegions: H(capacity: 6)!, candidateCommittedRecords: R(capacity: 6)!, committedRecords: R(capacity: 6)!, committedHitRegions: H(capacity: 6)!)
            let keys = InteractionOwnedKeyState(state: state, maximumComponentsPerKey: 34, maximumComponents: 204)!
            var scopes: InlineArray<3136, UInt8> = .init(repeating: 0)
            var text: InlineArray<4704, UInt8> = .init(repeating: 0)
            var path: InlineArray<3280, UInt8> = .init(repeating: 0)
            var plan: InlineArray<13536, UInt8> = .init(repeating: 0)
            withUnsafeMutableBytes(of: &scopes) { s in withUnsafeMutableBytes(of: &text) { t in withUnsafeMutableBytes(of: &path) { p in withUnsafeMutableBytes(of: &plan) { d in
                checks += exercisePipeline(models: models, root: root, semantic: semantic, values: values, dynamic: dynamic, geometry: StaticCycleGeometry(scopes: s, text: t, path: p, plan: d), interaction: keys).checks
            } } } }
        }
    } catch { preconditionFailure("pipeline Canvas owner") }
    return checks
}
private func withPipelineValues(dynamic: Bool, _ body: (borrowing CanvasStagedValues<SemanticRecordReference, CycleValueTable>) throws(DrawingError) -> Void) throws(DrawingError) {
    let limits = StaticCanvasLimits(maximumStaticCallableCases: 1, maximumStaticCaptureBytes: 32)!
    #if !hasFeature(Embedded)
    if dynamic {
        var storage = DynamicCanvasCallableStorage<SemanticRecordReference, CycleValueTable>(capacity: 5)
        return try storage.withLifetime(table: CycleValueTable(), limits: limits, body)
    }
    #endif
    var storage = StaticCanvasValueStorage()
    var backing: InlineArray<5, CanvasStagedEntry<SemanticRecordReference, CycleValueTable.CaptureStorage>?> = .init(repeating: nil)
    var entries = backing.mutableSpan
    try storage.withLifetime(entries: &entries, table: CycleValueTable(), capacity: 5, limits: limits, body)
}
