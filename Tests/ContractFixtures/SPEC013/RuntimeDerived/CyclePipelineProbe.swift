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

func exercisePipeline<G, C, R, H>(models: borrowing ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, semantic: borrowing SemanticRecordStore<CyclePayload>, values: borrowing CanvasStagedValues<SemanticRecordReference, CycleValueTable>, dynamic: Bool, geometry: consuming G, interaction: consuming InteractionOwnedKeyState<C, R, H>, audit: RuntimeStorageAudit, control: inout CycleControl) -> CycleReturnedWorkspaces<G, C, R, H> where G: CycleGeometry, C: CycleCandidateBacking, R: CycleCommittedBacking, H: CycleHitBacking, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
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
        // Reset a real incomplete attempt after an earlier publication. The
        // enclosing factory still owns the same semantic/model backing; reset
        // must release candidate work without retiring that live publication.
        var published: SemanticRecordReference?
        do throws(SemanticExpansionError) { try semantic.withPublishedView { published = $0.rootReference } }
        catch { preconditionFailure("published before attempt reset") }
        let liveIdentity = owner.rootIdentity
        expect(owner.admitAndSeal() == .advanced)
        expect(owner.applyAdmittedWork() == .applied(false))
        expect(owner.freezeObservableMutation() == .advanced)
        expect(owner.beginObservableCandidateAndExpandSemantics() == .advanced)
        expect(owner.resolveLayout() == .advanced)
        expect(values.count == 1 && models.phase == .reading)
        expect(owner.interaction.beginCandidate(limits: audit.limits.interaction) == nil)
        owner.interactionCandidate = true
        trace.pointee.mutate = true // Arrived after seal; remains pending.
        owner.cleanup(.resetAttemptStorage)
        owner.finalizePipeline()
        expect(values.count == 0 && models.phase == .mutating)
        expect(owner.interaction.committedRecordCount == 1 && owner.rootIdentity == liveIdentity)
        expect(trace.pointee.mutate && trace.pointee.applied == 0)
        do throws(SemanticExpansionError) { try semantic.withPublishedView { expect($0.rootReference == published) } }
        catch { preconditionFailure("published lost by attempt reset") }
        trace.pointee.mutate = false
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
        var returned = cycleConcreteCoordinator(owner: consume owner, dynamic: dynamic, control: trace, audit: audit)
        returned.checks += checks
        return consume returned
    }
}
