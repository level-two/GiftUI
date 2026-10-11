import CycleTable
import GiftUI
import GiftUIDrawing
@testable import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
@testable import GiftUIRuntimeCore
import GiftUISemanticCore
import CycleSchema
import CyclePresentation

struct CycleRuntimeControl {
    var admission = CycleAdmissionBacking()
    var result: RuntimeCompletePipelineResult<RuntimeOwnerFailure>?
    var context = ExecutionContext(cycle: nil, semanticRevision: nil, candidateFrame: nil, phase: .idle)
    var unavailable = false
}
struct CycleControl {
    var runtime = CycleRuntimeControl()
    var admission: CycleAdmissionBacking {
        get { runtime.admission }
        set { runtime.admission = newValue }
        _modify { yield &runtime.admission }
    }
    var result: RuntimeCompletePipelineResult<RuntimeOwnerFailure>? {
        get { runtime.result }
        set { runtime.result = newValue }
    }
    var context: ExecutionContext {
        get { runtime.context }
        set { runtime.context = newValue }
    }
    var unavailable: Bool {
        get { runtime.unavailable }
        set { runtime.unavailable = newValue }
    }
    var show = true
    var mutate: Bool {
        get { admission.pendingState != nil }
        set { admission.pendingState = newValue ? 1 : nil }
    }
    var terminalRetry = false
    var failAfterMutation = false
    var cleanupOrder: InlineArray<9, UInt8> = .init(repeating: 255)
    var cleanupCount = 0
    var fault: RuntimeCompletePipelineStage?
    var offer: FrameOfferDisposition = .accepted
    var stages: UInt16 = 0
    var cleanups: UInt16 = 0
    var finalized = 0
    var applied = 0
    var streams = 0
    var commits = 0
    var committedRecords: UInt16 = 0
    var hasRoot = false
    var frameActive = false
}
struct CycleEndpoint: SynchronousFrameEndpoint {
    var disposition: FrameOfferDisposition = .accepted
    var sink = CycleRenderSink()
    var calls = 0
    var streams = 0
    mutating func offer(provenance: FrameProvenance, body: (inout CycleRenderSink) -> FrameStreamResult) -> FrameOfferResult {
        cycleTrace("offer", disposition); cycleTrace("provenance", provenance)
        calls += 1
        guard disposition == .accepted else { return .init(disposition: disposition, failure: disposition == .failed ? .invalidEnvelope : nil)! }
        sink = CycleRenderSink(); streams += 1
        switch body(&sink) {
        case .complete: return .init(disposition: .accepted, failure: nil)!
        case .producerFailed: return .init(disposition: .failed, failure: .producerFailed)!
        case .insufficientCapacity: return .init(disposition: .failed, failure: .insufficientCapacity)!
        case .endpointRefused: return .init(disposition: .nonRetryableRefusal, failure: nil)!
        case .contractViolation: return .init(disposition: .failed, failure: .contractViolation)!
        }
    }
}
struct CyclePipelineOwner<Geometry, Candidate, Committed, Hits>: ~Copyable, ~Escapable, RuntimeCompletePipelineOwner
where Geometry: CycleGeometry, Candidate: CycleCandidateBacking, Committed: CycleCommittedBacking, Hits: CycleHitBacking, Candidate.Identity == SemanticCompleteIdentity, Committed.Identity == SemanticCompleteIdentity, Hits.Identity == SemanticCompleteIdentity {
    typealias OwnerFailure = RuntimeOwnerFailure
    let models: ObservableModelScope<CycleOwnedModel, CycleModelSchema>
    let root: ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>
    let semantic: SemanticRecordStore<CyclePayload>
    let values: CanvasStagedValues<SemanticRecordReference, CycleValueTable>
    let control: UnsafeMutablePointer<CycleControl>
    var geometry: Geometry
    var interaction: InteractionOwnedKeyState<Candidate, Committed, Hits>
    var phase = ExecutionPhaseMachine()
    var cycles = RunCycleIDAllocator()
    let limits: RuntimeProfileLimits
    var revisions = SemanticRevisionAllocator()
    var candidates = CandidateFrameIDAllocator()
    var presentations = PresentationRevisionAllocator()
    var generations = RuntimeActionGenerationAllocator<SemanticCompleteIdentity>()
    var completedContext = ExecutionContext(cycle: nil, semanticRevision: nil, candidateFrame: nil, phase: .idle)
    var committedPresentation: PresentationRevision?
    var sealedAdmission: AdmissionSummary?
    var recovery = RecordingPresentationPendingCoordinator(maximumRetryableRefusals: 3, requester: CycleWake())!
    var endpoint = CycleEndpoint()
    var frameActive = false
    var observableCandidate = false
    var semanticCandidate = false
    var interactionCandidate = false
    var rootIdentity: SemanticCompleteIdentity?
    var actionIdentity: SemanticCompleteIdentity?
    var header: RenderPlanHeader?
    var provenance: FrameProvenance?
    var presentation: PresentationRevision?
    var changed = true
    var pending = false
    var quiescent = false
    @_lifetime(copy models, copy root, copy semantic, copy values, borrow control)
    init(models: consuming ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: consuming ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, semantic: consuming SemanticRecordStore<CyclePayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CycleValueTable>, geometry: consuming Geometry, interaction: consuming InteractionOwnedKeyState<Candidate, Committed, Hits>, control: borrowing UnsafeMutablePointer<CycleControl>, limits: RuntimeProfileLimits) {
        self.models = consume models; self.root = consume root; self.semantic = consume semantic; self.values = consume values
        self.limits = limits
        self.geometry = consume geometry; self.interaction = consume interaction; self.control = copy control
        precondition(self.root.belongs(to: self.models))
    }
    // Consuming the complete scoped owner ends its borrows while forwarding the
    // two escapable owned workspace values. No original owner survives the call.
    consuming func returnWorkspaces(checks: Int) -> CycleReturnedWorkspaces<Geometry, Candidate, Committed, Hits> {
        CycleReturnedWorkspaces(geometry: geometry, interaction: interaction, checks: checks)
    }

    mutating func runTracedPipeline() -> RuntimeCompletePipelineResult<RuntimeOwnerFailure> {
        let result = RuntimeCompletePipeline.run(owner: &self)
        cycleTrace("result", result)
        return result
    }
    mutating func terminatePresentation() {
        guard !control.pointee.unavailable else { return }
        // Called only after the synchronous attempt finalized and released reads.
        precondition(!frameActive && !observableCandidate && !semanticCandidate && !interactionCandidate)
        control.pointee.unavailable = true
        quiescent = true; pending = false
        control.pointee.admission.resetAll()
        interaction.resetAllStorage()
        control.pointee.committedRecords = 0
        do throws(ObservableStateError) { try root.shutdown() }
        catch { models.requireStop() }
        cycleTrace("terminal", (interaction.committedRecordCount, values.count, models.phase))
    }
    mutating func boundary(_ stage: RuntimeCompletePipelineStage) -> RunCycleFailure<RuntimeOwnerFailure>? {
        cycleTrace("stage", stage)
        control.pointee.stages |= UInt16(1) << stage.rawValue
        if control.pointee.fault == stage { return .execution(.capacityExhausted) }
        return nil
    }
    mutating func admitAndSeal() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        control.pointee.cleanups = 0; control.pointee.cleanupCount = 0
        guard !quiescent else { return .failure(.execution(.requiredFacilityUnavailable)) }
        if let error = phase.beginCycle(reservingFrom: &cycles) { return .failure(.execution(error)) }
        if let error = boundary(.admissionAndSeal) { return .failure(error) }
        guard let selection = ExecutionAdmissionSealer.select(pendingInputEvents: control.pointee.admission.pointerCount, pendingStateChangeFacts: control.pointee.admission.pendingState == nil ? 0 : 1, pendingCompletionFacts: 0, sameCycleActivationCandidates: 0, includesDirtyRederivation: changed, includesPresentationRecovery: pending, limits: limits.execution) else { return .failure(.execution(.invariantViolation)) }
        guard control.pointee.admission.seal(selection.summary) else { return .failure(.execution(.invariantViolation)) }
        sealedAdmission = selection.summary
        return .advanced
    }
    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult<RuntimeOwnerFailure> {
        if let error = phase.transition(to: .mutating) { return .failure(.execution(error), mutationApplied: false) }
        if let error = boundary(.applyAdmittedWork) { return .failure(error, mutationApplied: false) }
        // Pointer gesture cases are completed by the later P07 admission slice;
        // do not silently discard a sealed pointer that this adapter cannot apply.
        guard control.pointee.admission.sealedPointerCount == 0 else {
            return .failure(.execution(.requiredFacilityUnavailable), mutationApplied: false)
        }
        guard control.pointee.admission.takeState() != nil else { return .applied(false) }
        guard let rootIdentity, let actionIdentity, let record = interaction.committedRecord(for: actionIdentity) else { return .failure(.execution(.invalidProvenance), mutationApplied: false) }
        let target = ObservableStateRootTargetAccess(root: root, identity: rootIdentity, ordinal: 0)
        let captured = CapturedAction(identity: actionIdentity, generation: record.generation)
        switch RuntimeRecordInteractionBridge.dispatch(captured, records: interaction, target: target, actionType: CycleAction.self, operation: CycleHandler.operation) {
        case .interaction(.dispatched):
            control.pointee.applied += 1; changed = true
            if control.pointee.failAfterMutation { return .failure(.execution(.capacityExhausted), mutationApplied: true) }
            return .applied(true)
        case .observableFailure(let error): return .failure(.focusedOwner(.observableState(error)), mutationApplied: false)
        default: return .failure(.execution(.invalidProvenance), mutationApplied: false)
        }
    }
    mutating func freezeObservableMutation() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.freezeObservableMutation) { return .failure(error) }
        do throws(ObservableStateError) { try models.beginFrame(); frameActive = true }
        catch { return .failure(.focusedOwner(.observableState(error))) }
        if let error = phase.transition(to: .deriving) { return .failure(.execution(error)) }
        return .advanced
    }
    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.observableCandidateAndSemanticExpansion) { return .failure(error) }
        do throws(ObservableStateError) {
            try models.withDiscovery { () throws(ObservableStateError) in
                if case .failure(let error) = root.beginCandidate() { throw error }
            }
            observableCandidate = true
        } catch { return .failure(.focusedOwner(.observableState(error))) }
        let result = semantic.expand(CycleScene<CycleDomain>(show: control.pointee.show), roles: CycleRoles.self, codec: CanvasSemanticPayloadCodec<CycleRoles, CycleValueTable>.self, limits: limits.semantic, binding: ObservableSemanticBodyBinding(models: models.borrowedScope(), root: root.borrowedRoot(), domain: CycleDomain.self))
        switch result {
        case .success: semanticCandidate = true
        case .semanticFailure(let error): discardLocalCandidates(); return .failure(.focusedOwner(.semantic(error)))
        case .bindingFailure(let error): discardLocalCandidates(); return .failure(.focusedOwner(.observableState(error)))
        case .accessFailure: discardLocalCandidates(); return .failure(.focusedOwner(.observableState(.staleModel)))
        }
        do throws(DrawingError) { try CanvasSemanticTransfer.stage(from: semantic, into: values, table: CycleValueTable()) }
        catch {
            discardLocalCandidates()
            let production: DrawingProductionError = switch error {
            case .invalidModelAccess: .invalidModelAccess
            case .invalidValue: .invalidValue
            case .invalidPathState: .invalidPathState
            case .arithmeticOverflow: .arithmeticOverflow
            case .capacityExhausted: .capacityExhausted
            case .invalidScope: .invalidScope
            case .invalidPhase: .invalidPhase
            case .reentrancyViolation: .reentrancyViolation
            case .invariantViolation: .invariantViolation
            }
            return .failure(.focusedOwner(.drawing(production)))
        }
        return .advanced
    }
    mutating func resolveLayout() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.layout) { return .failure(error) }
        do throws(SemanticExpansionError) {
            return try semantic.withCandidateView { bank in
                switch geometry.layout(bank, limits: limits) { case .success: return .advanced; case .failure(let error): return .failure(.focusedOwner(.layout(error))) }
            }
        } catch { return .failure(.focusedOwner(.semantic(error))) }
    }
    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.canvasInvocationAndPlan) { return .failure(error) }
        var source = CycleSource(models: models.borrowedScope(), values: values.borrowedValues(), table: CycleValueTable())
        switch geometry.draw(source: &source, context: phase.context, limits: limits) { case .success: return .advanced; case .failure(let error): return .failure(.focusedOwner(.drawing(error))) }
    }
    mutating func preflightCombinedRender() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.combinedRenderPreflight) { return .failure(error) }
        do throws(SemanticExpansionError) {
            return try semantic.withCandidateView { bank in
                switch geometry.preflight(bank, limits: limits) { case .success(let value): header = value; return .advanced; case .failure(let error): return .failure(.renderProduction(error)) }
            }
        } catch { return .failure(.focusedOwner(.semantic(error))) }
    }
    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.interactionCandidate) { return .failure(error) }
        if let error = interaction.beginCandidate(limits: limits.interaction) { return .failure(.focusedOwner(.interaction(error))) }
        interactionCandidate = true
        do throws(SemanticExpansionError) {
            return try semantic.withCandidateView { bank in
                var target: SemanticCompleteIdentity?
                for index: UInt16 in 0..<bank.recordCount {
                    var identity = bank.completeIdentity(for: bank.reference(at: index)!)!
                    guard identity.append(.init(kind: .customBody)) else { return .failure(.execution(.invariantViolation)) }
                    if root.generation(identity: identity, ordinal: 0, publishable: true) != nil { target = identity; break }
                }
                for index: UInt16 in 0..<bank.recordCount {
                    let ref = bank.reference(at: index)!
                    guard bank.record(ref)?.kind == .action else { continue }
                    guard let target, let bounds = geometry.bounds(ref), let clip = geometry.clip(ref) else { return .failure(.execution(.invariantViolation)) }
                    let identity = bank.completeIdentity(for: ref)!
                    switch RuntimeRecordInteractionBridge.append(record: ref, semantic: bank, root: root, rootIdentity: target, rootOrdinal: 0, actionType: CycleAction.self, roles: CycleRoles.self, isEnabled: true, bounds: bounds, clip: clip, paintOrder: 0, interaction: &interaction) {
                    case .failure(let error): return .failure(.focusedOwner(.interaction(error)))
                    case .requiresGeneration:
                        guard let generation = generations.generation(for: identity), interaction.assignGeneration(generation, to: identity) == nil else { return .failure(.execution(.identityExhausted)) }
                    case .preserved: break
                    }
                    actionIdentity = identity
                }
                rootIdentity = target
                if let error = interaction.finishCandidate() { return .failure(.focusedOwner(.interaction(error))) }
                return .advanced
            }
        } catch { return .failure(.focusedOwner(.semantic(error))) }
    }
    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult<RuntimeOwnerFailure> {
        if let error = boundary(.semanticAndObservablePublication) { return .failure(error) }
        let revision: SemanticRevision
        if changed || phase.context.semanticRevision == nil { guard let next = revisions.reserve() else { return .failure(.execution(.identityExhausted)) }; revision = next }
        else { revision = phase.context.semanticRevision! }
        if let error = phase.transition(to: .publishing) { return .failure(.execution(error)) }
        do throws(ObservableStateError) {
            try models.withDiscovery { () throws(ObservableStateError) in
                if case .failure(let error) = root.finishCandidate(.publish) { throw error }
            }
            observableCandidate = false
        } catch { quiescent = true; return .failure(.focusedOwner(.observableState(error))) }
        do throws(SemanticExpansionError) { try semantic.publishCandidate(); semanticCandidate = false }
        catch { quiescent = true; return .failure(.focusedOwner(.semantic(error))) }
        if let error = phase.recordPublishedSemanticRevision(revision) { return .failure(.execution(error)) }
        return .published(.init(semanticRevision: revision, changed: changed))
    }
    mutating func allocateCandidate() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.candidateAllocation) { return .failure(error) }
        guard let candidate = candidates.reserve(), let presentation = presentations.reserve(), let cycle = phase.context.cycle, let revision = phase.context.semanticRevision else { return .failure(.execution(.identityExhausted)) }
        if let error = phase.recordCandidateFrame(candidate) { return .failure(.execution(error)) }
        self.presentation = presentation; provenance = .init(cycle: cycle, semanticRevision: revision, candidateFrame: candidate)
        return .advanced
    }
    mutating func offerAndProduce() -> RuntimePipelineOfferResult<RuntimeOwnerFailure> {
        if let error = boundary(.offerAndProduction) { return .failure(error) }
        if let error = phase.transition(to: .offering) { return .failure(.execution(error)) }
        endpoint.disposition = control.pointee.offer
        var retained: RenderProductionError?
        let offer = endpoint.offer(provenance: provenance!) { sink in
            control.pointee.streams += 1
            do throws(SemanticExpansionError) {
                return try semantic.withPublishedView { bank in
                    switch geometry.produce(bank, header: header!, sink: &sink, limits: limits) {
                    case .success: return .complete
                    case .failure(let error): retained = error; return RecordingRenderProductionAdapter.observe(error: error).streamResult!
                    }
                }
            } catch { retained = .invariantViolation; return .contractViolation }
        }
        if let retained { return .failure(.renderProduction(retained)) }
        switch offer.disposition {
        case .accepted: return .accepted(presentation!)
        case .backpressured: return .backpressured
        case .retryableRefusal: return .retryableRefusal
        case .nonRetryableRefusal: return .nonRetryableRefusal(.endpoint)
        case .failed: return .failure(.frameOffer(offer.failure!))
        }
    }
    mutating func discardLocalCandidates() {
        values.discard()
        if semanticCandidate { do throws(SemanticExpansionError) { try semantic.discardCandidate() } catch { quiescent = true }; semanticCandidate = false }
        if observableCandidate {
            do throws(ObservableStateError) { try models.withDiscovery { () throws(ObservableStateError) in
                if case .failure(let error) = root.finishCandidate(.discard) { throw error }
            } } catch { quiescent = true }
            observableCandidate = false
        }
    }
    mutating func cleanup(_ action: RuntimeCleanupAction) {
        precondition(control.pointee.cleanupCount < 9)
        cycleTrace("cleanup", action)
        control.pointee.cleanupOrder[control.pointee.cleanupCount] = action.rawValue
        control.pointee.cleanupCount += 1
        precondition(control.pointee.cleanups & (UInt16(1) << action.rawValue) == 0)
        control.pointee.cleanups |= UInt16(1) << action.rawValue
        switch action {
        case .releaseCanvasCallable: values.discard()
        case .resetRenderWorkspace: geometry.resetRender()
        case .resetDrawingPlan: geometry.resetPlan()
        case .resetLayoutCandidate: geometry.resetLayout()
        case .discardSemanticCandidate: if semanticCandidate { do throws(SemanticExpansionError) { try semantic.discardCandidate() } catch { quiescent = true }; semanticCandidate = false }
        case .discardObservableCandidate:
            if observableCandidate { discardLocalCandidates() }
        case .discardInteractionCandidate: interaction.resolveCandidate(.discard); generations.resolveCandidate(committed: false); interactionCandidate = false
        case .commitInteractionCandidate: interaction.resolveCandidate(.commit(presentation!)); generations.resolveCandidate(committed: true); interactionCandidate = false; control.pointee.commits += 1
        case .resetAttemptStorage:
            discardLocalCandidates()
            if interactionCandidate { interaction.resolveCandidate(.discard); generations.resolveCandidate(committed: false); interactionCandidate = false }
            geometry.reset()
            if frameActive { do throws(ObservableStateError) { try models.endFrame() } catch { quiescent = true }; frameActive = false }
        }
    }
    mutating func applyDisposition(_ disposition: RuntimePipelineDisposition) {
        cycleTrace("disposition", disposition)
        changed = disposition.semanticDisposition == .dirty
        pending = disposition.presentationIntentState == .pending
    }
    mutating func finalizePipeline() {
        control.pointee.admission.finishAttempt()
        completedContext = phase.context
        control.pointee.committedRecords = interaction.committedRecordCount
        control.pointee.hasRoot = rootIdentity != nil
        control.pointee.frameActive = frameActive
        if phase.context.phase != .idle {
            precondition(phase.transition(to: .finalizing) == nil)
            precondition(phase.transition(to: .idle) == nil)
        }
        control.pointee.context = phase.context
        cycleTrace("finalized", (completedContext, control.pointee.applied, control.pointee.commits, interaction.committedRecordCount, values.count, models.phase))
        control.pointee.finalized += 1
    }
}
