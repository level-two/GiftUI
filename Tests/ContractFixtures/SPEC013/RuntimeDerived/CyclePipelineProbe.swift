import CycleTable
import GiftUI
import GiftUIDrawing
@testable import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
@testable import GiftUIRuntimeCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import GiftUISemanticCore
import CycleSchema
import CyclePresentation

func exercisePipeline<G, C, R, H>(models: borrowing ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, semantic: borrowing SemanticRecordStore<CyclePayload>, values: borrowing CanvasStagedValues<SemanticRecordReference, CycleValueTable>, dynamic: Bool, geometry: consuming G, interaction: consuming InteractionOwnedKeyState<C, R, H>, audit: RuntimeStorageAudit, control: inout CycleControl) -> CycleReturnedWorkspaces<G, C, R, H> where G: CycleGeometry, C: CycleCandidateBacking, R: CycleCommittedBacking, H: CycleHitBacking, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    cycleTrace("begin", dynamic ? "dynamic" : "static")
    defer { cycleTrace("end", dynamic ? "dynamic" : "static") }
    var transferredGeometry: G? = consume geometry
    var transferredInteraction: InteractionOwnedKeyState<C, R, H>? = consume interaction
    return withUnsafeMutablePointer(to: &control) { trace in
        var owner = CyclePipelineOwner(models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic.borrowedStore(), values: values.borrowedValues(), geometry: transferredGeometry.take()!, interaction: transferredInteraction.take()!, control: trace, limits: audit.limits)
        var admission = CycleAdmission(control: trace, limits: audit.limits.execution)
        var checks = 0
        func expect(_ value: Bool) { checks += 1; precondition(value) }
        var result = owner.runTracedPipeline()
        trace.pointee.result = result
        if case .failed = result {
            expect(models.phase == .mutating && values.count == 0 && !owner.frameActive)
            expect(trace.pointee.applied == 0 && trace.pointee.streams == 0 && trace.pointee.commits == 0)
            expect(owner.interaction.committedRecordCount == 0)
            var returned = cycleConcreteCoordinator(owner: consume owner, dynamic: dynamic, control: trace, audit: audit, admission: consume admission, stopAfterFailure: true)
            returned.checks += checks
            return consume returned
        }
        guard case .completed(let initial) = result else { preconditionFailure("unreachable initial result") }
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
        if audit.limits.execution.maximumInputEvents == 2 {
            let revision = owner.interaction.committedRevision!
            for phase: PointerPhase in [.down, .up] {
                let event = NormalizedPointerEvent(phase: phase, position: trace.pointee.actionPoint, source: .init(rawValue: 0), sequence: .init(rawValue: 0), ordinal: .init(rawValue: phase == .down ? 0 : 1), presentationRevision: revision)
                expect(admission.submit(pointer: event).result == .queued)
            }
        }
        expect(owner.admitAndSeal() == .advanced)
        if audit.limits.execution.maximumInputEvents == 2 {
            let sealed = owner.sealedAdmission!
            expect(sealed.inputEventCount == 2 && sealed.semanticActionCount == 1 && trace.pointee.admission.sealedAction != nil)
            // SPEC-009 source cancellation invalidates an activation, while the
            // already admitted membership/counts remain the immutable snapshot.
            let stale = NormalizedPointerEvent(phase: .up, position: trace.pointee.actionPoint, source: .init(rawValue: 0), sequence: .init(rawValue: 0), ordinal: .init(rawValue: 2), presentationRevision: .init(rawValue: 0))
            let cancelled = admission.submit(pointer: stale)
            expect(cancelled.result == .invalidProvenance && cancelled.context == owner.phase.context)
            expect(owner.sealedAdmission == sealed && trace.pointee.admission.sealedPointerCount == 2)
            expect(trace.pointee.admission.sealedAction == nil && trace.pointee.runtime.pointer.capture.current == nil)
            cycleTrace("sealed-cancel", sealed)
        }
        expect(owner.applyAdmittedWork() == .applied(false))
        expect(owner.freezeObservableMutation() == .advanced)
        expect(owner.beginObservableCandidateAndExpandSemantics() == .advanced)
        expect(owner.resolveLayout() == .advanced)
        expect(values.count == 1 && models.phase == .reading)
        expect(owner.interaction.beginCandidate(limits: audit.limits.interaction) == nil)
        owner.interactionCandidate = true
        let late = admission.submit(stateChange: 1)
        expect(late.result == .queued && late.context == owner.phase.context && late.context.phase == .deriving)
        expect(admission.controller.didDeferAfterSeal && trace.pointee.admission.sealedState == nil)
        let finalizedBeforeReentry = trace.pointee.finalized
        guard case .failure(let nestedContext, .execution(.reentrancyViolation), nil) = owner.runOpportunity() else { preconditionFailure("nested opportunity accepted") }
        expect(nestedContext == owner.phase.context && trace.pointee.finalized == finalizedBeforeReentry)
        expect(trace.pointee.mutate && trace.pointee.admission.sealedState == nil)
        cycleTrace("nested", nestedContext)
        owner.cleanup(.resetAttemptStorage)
        owner.finalizePipeline()
        expect(values.count == 0 && models.phase == .mutating)
        expect(owner.interaction.committedRecordCount == 1 && owner.rootIdentity == liveIdentity)
        expect(trace.pointee.mutate && trace.pointee.applied == 0)
        do throws(SemanticExpansionError) { try semantic.withPublishedView { expect($0.rootReference == published) } }
        catch { preconditionFailure("published lost by attempt reset") }
        trace.pointee.mutate = true; trace.pointee.offer = .retryableRefusal
        result = owner.runTracedPipeline()
        guard case .completed(let refused) = result else { preconditionFailure("refusal pipeline") }
        expect(refused.operational == .retryableRefusal && refused.disposition.presentationIntentState == .pending)
        expect(trace.pointee.applied == 1 && trace.pointee.commits == 1)
        trace.pointee.offer = .accepted
        result = owner.runTracedPipeline()
        guard case .completed(let retried) = result else { preconditionFailure("retry pipeline") }
        expect(retried.publication.semanticRevision == refused.publication.semanticRevision && !retried.publication.changed)
        expect(trace.pointee.applied == 1 && trace.pointee.commits == 2)
        expect(models.phase == .mutating && values.count == 0)
        trace.pointee.mutate = true; trace.pointee.failAfterMutation = true
        result = owner.runTracedPipeline()
        guard case .failed(let partial) = result else { preconditionFailure("partial mutation") }
        expect(partial.stage == .applyAdmittedWork && partial.disposition.semanticDisposition == .dirty)
        expect(trace.pointee.applied == 2 && partial.disposition.wakeReasons.contains(.semanticDirty))
        trace.pointee.failAfterMutation = false
        result = owner.runTracedPipeline()
        guard case .completed(let recovered) = result else { preconditionFailure("partial recovery") }
        expect(recovered.publication.changed && trace.pointee.applied == 2)
        for offer: FrameOfferDisposition in [.backpressured] {
            trace.pointee.offer = offer
            let streams = trace.pointee.streams, commits = trace.pointee.commits
            result = owner.runTracedPipeline()
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
            result = owner.runTracedPipeline()
            guard case .failed(let failed) = result else { preconditionFailure("fault pipeline") }
            expect(failed.stage.rawValue == raw && failed.failure == .execution(.capacityExhausted))
            expect(trace.pointee.stages == (UInt16(1) << (raw + 1)) - 1)
            expect(trace.pointee.finalized == finalized + 1)
            expect(models.phase == .mutating && values.count == 0 && !owner.frameActive)
            for index in 1..<max(1, trace.pointee.cleanupCount) {
                expect(trace.pointee.cleanupOrder[index - 1] < trace.pointee.cleanupOrder[index])
            }
        }
        // A rejected removal candidate must not change the target used by the
        // still-published model and committed action table.
        let preservedTarget = owner.rootIdentity!
        let preservedRouting = owner.interaction.committedRevision
        trace.pointee.show = false; trace.pointee.fault = .semanticAndObservablePublication
        owner.changed = true
        result = owner.runTracedPipeline()
        guard case .failed(let rejectedRemoval) = result else { preconditionFailure("removal publication fault") }
        expect(rejectedRemoval.stage == .semanticAndObservablePublication && rejectedRemoval.publication == nil)
        cycleTrace("discarded-removal-target", owner.rootIdentity == preservedTarget)
        expect(owner.rootIdentity == preservedTarget && owner.interaction.committedRevision == preservedRouting)
        expect(root.generation(identity: preservedTarget, ordinal: 0, publishable: false) != nil)
        let beforePreservedAction = trace.pointee.applied
        trace.pointee.show = true; trace.pointee.fault = nil; trace.pointee.mutate = true
        result = owner.runTracedPipeline()
        guard case .completed = result else { preconditionFailure("action after discarded removal") }
        expect(trace.pointee.applied == beforePreservedAction + 1 && owner.rootIdentity == preservedTarget)
        trace.pointee.fault = nil
        let staleIdentity = owner.rootIdentity!
        let staleRecord = owner.interaction.committedRecord(for: owner.actionIdentity!)!
        let staleAction = CapturedAction(identity: staleRecord.identity, generation: staleRecord.generation)
        trace.pointee.show = false; owner.changed = true; trace.pointee.offer = .backpressured
        result = owner.runTracedPipeline()
        guard case .completed = result else { preconditionFailure("retired target refused offer") }
        expect(owner.rootIdentity == nil && owner.interaction.committedRecordCount == 1)
        let staleTarget = ObservableStateRootTargetAccess(root: root, identity: staleIdentity, ordinal: 0)
        let appliedBeforeStale = trace.pointee.applied
        let cancelled = RuntimeRecordInteractionBridge.dispatch(staleAction, records: owner.interaction, target: staleTarget, actionType: CycleAction.self, operation: CycleHandler.operation)
        cycleTrace("stale-target", cancelled)
        expect(cancelled == .interaction(.cancelled) && trace.pointee.applied == appliedBeforeStale)
        expect(staleTarget.currentGeneration() == nil)
        trace.pointee.offer = .accepted
        result = owner.runTracedPipeline()
        guard case .completed = result else { preconditionFailure("retirement pipeline") }
        expect(owner.rootIdentity == nil && owner.interaction.committedRecordCount == 0)
        expect(models.phase == .mutating && values.count == 0)
        trace.pointee.show = true; owner.changed = true
        checks += exercisePendingSupersession(&owner, admission: &admission)
        var returned = cycleConcreteCoordinator(owner: consume owner, dynamic: dynamic, control: trace, audit: audit, admission: consume admission)
        returned.checks += checks
        return consume returned
    }
}
