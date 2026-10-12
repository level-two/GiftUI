import P08CounterTable
import GiftUI
import GiftUIDrawing
@testable import GiftUIExecution
import GiftUIInteraction
import GiftUIHostConfiguration
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
@testable import GiftUIRuntimeCore
import GiftUISemanticCore
import P08CounterSchema
import P08CounterPresentation

struct CounterRuntimeControl {
    var admission = CounterAdmissionBacking()
    var pointer = CounterPointerState()
    var committedPresentation: PresentationRevision?
    var result: RuntimeCompletePipelineResult<RuntimeOwnerFailure>?
    var context = ExecutionContext(cycle: nil, semanticRevision: nil, candidateFrame: nil, phase: .idle)
    var unavailable = false
}
struct CounterControl {
    #if hasFeature(Embedded) || GIFTUI_COUNTER_TILED
    var backend = CounterTiledBackendStorage()
    #else
    var backend = CounterNativeBackendStorage()
    #endif
    var runtime = CounterRuntimeControl()
    // The coordinator and finite callback adapter share this single controller.
    var admissionController: CounterAdmission.Controller?
    var wake: ExecutionWakeAccumulator<CounterWake>?
    var scheduler: HostScheduledOpportunityController?
    var wakeClockMicroseconds: UInt64 = 0
    var wakeFirstFactMicroseconds: UInt64?
    var wakeEnabled = false
    var forwardedWakeRequestCount: UInt32 = 0
    var hostWakeRequests = 0
    var wakeTakes = 0
    var lastTakenWakeReasons: ExecutionWakeReasons = []
    var acceptedFactWakeRecords = 0
    var disabledWakeRejections = 0
    var injectCompletionAtApply = false
    var lateCallbackObservedActive = false
    var lateCallbackDidNotRunRuntime = false
    var inputGate = HostNormalizedInputGate(configuredSource: .init(rawValue: 0))
    var semanticSnapshot = CounterSemanticSnapshot()
    var lastFrame = CounterRenderSink()
    var actionPoints: InlineArray<2, Point> = .init(repeating: Point(x: 0, y: 0))
    var admission: CounterAdmissionBacking {
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
    var applicationConstructions = 0
    var applicationCallbacks = 0
    var observationsInstalled = 0
    var observationsDetached = 0
    var reentrantApplicationRejections = 0
    var stoppedApplicationChecks = 0
    var show = true
    var mutate: Bool {
        get { admission.pendingState != nil }
        set { admission.pendingState = newValue ? 1 : nil }
    }
    mutating func cancelPointerSequence(source: InputSourceID, sequence: PointerSequenceID) {
        // Already queued phases passed producer-order admission. Preserve that
        // trusted baseline when cancellation removes them before seal.
        for index in 0..<2 {
            guard let event = admission.pendingPointers[index], event.source == source, event.sequence == sequence else { continue }
            let outcome = runtime.pointer.sequence.validate(phase: event.phase, sequence: event.sequence, ordinal: event.ordinal, targetGateAllowsResynchronization: true)
            if outcome == .accepted || outcome == .consumedWhileCancelled { runtime.pointer.source = source }
        }
        runtime.pointer.cancel(source: source)
        for index in 0..<Int(admission.sealedPointerCount) {
            if let event = admission.sealedPointers[index], event.source == source && event.sequence == sequence {
                admission.sealedAction = nil
            }
        }
        admission.cancel(source: source, sequence: sequence)
    }
    var actionPoint = Point(x: 0, y: 0)
    var idleQuiesceMode: UInt8 = 0
    var teardowns = 0
    var terminalRetry = false
    var failAfterMutation = false
    var cleanupOrder: InlineArray<9, UInt8> = .init(repeating: 255)
    var cleanupCount = 0
    var boundaryFailure: RunCycleFailure<RuntimeOwnerFailure> = .execution(.capacityExhausted)
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
struct CounterPipelineOwner<Geometry, Candidate, Committed, Hits>: ~Copyable, ~Escapable, RuntimeCompletePipelineOwner
where Geometry: CounterGeometry, Candidate: CounterCandidateBacking, Committed: CounterCommittedBacking, Hits: CounterHitBacking, Candidate.Identity == SemanticCompleteIdentity, Committed.Identity == SemanticCompleteIdentity, Hits.Identity == SemanticCompleteIdentity {
    typealias OwnerFailure = RuntimeOwnerFailure
    let models: ObservableModelScope<CounterOwnedModel, CounterModelSchema>
    let root: ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>
    let semantic: SemanticRecordStore<CounterPayload>
    let values: CanvasStagedValues<SemanticRecordReference, CounterValueTable>
    let control: UnsafeMutablePointer<CounterControl>
    var geometry: Geometry
    var interaction: InteractionOwnedKeyState<Candidate, Committed, Hits>
    var phase = ExecutionPhaseMachine()
    var counters = RunCycleIDAllocator()
    let limits: RuntimeProfileLimits
    var revisions = SemanticRevisionAllocator()
    var candidates = CandidateFrameIDAllocator()
    var presentations = PresentationRevisionAllocator()
    var generations = RuntimeActionGenerationAllocator<SemanticCompleteIdentity>()
    var completedContext = ExecutionContext(cycle: nil, semanticRevision: nil, candidateFrame: nil, phase: .idle)
    var committedPresentation: PresentationRevision?
    var sealedAdmission: AdmissionSummary?
    var recovery = PresentationPendingState(maximumRetryableRefusals: 3)!
    var endpoint: CounterEndpoint
    var frameActive = false
    var observableCandidate = false
    var semanticCandidate = false
    var interactionCandidate = false
    var rootIdentity: SemanticCompleteIdentity?
    var actionIdentity: SemanticCompleteIdentity?
    var candidateRootIdentity: SemanticCompleteIdentity?
    var candidateActionIdentity: SemanticCompleteIdentity?
    var header: RenderPlanHeader?
    var provenance: FrameProvenance?
    var presentation: PresentationRevision?
    var changed = true
    var pending = false
    var presentationIntentState: PresentationIntentState { quiescent || control.pointee.unavailable ? .unavailable : pending ? .pending : .satisfied }
    var hasAllocatedCandidateFrame: Bool { phase.context.candidateFrame != nil }
    var quiescent = false
    var presentationTeardownComplete = false
    @_lifetime(copy models, copy root, copy semantic, copy values, borrow control)
    init(models: consuming ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: consuming ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, semantic: consuming SemanticRecordStore<CounterPayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>, geometry: consuming Geometry, interaction: consuming InteractionOwnedKeyState<Candidate, Committed, Hits>, control: borrowing UnsafeMutablePointer<CounterControl>, limits: RuntimeProfileLimits, endpointConfiguration: HostEndpointConfiguration) {
        self.models = consume models; self.root = consume root; self.semantic = consume semantic; self.values = consume values
        self.limits = limits
        control.pointee.initializeCounterWake()
        self.endpoint = CounterEndpoint(configuration: endpointConfiguration, control: control)
        self.geometry = consume geometry; self.interaction = consume interaction; self.control = copy control
        precondition(self.root.belongs(to: self.models))
    }
    // Consuming the complete scoped owner ends its borrows while forwarding the
    // two escapable owned workspace values. No original owner survives the call.


    consuming func returnWorkspaces(checks: Int) -> CounterReturnedWorkspaces<Geometry, Candidate, Committed, Hits> {
        CounterReturnedWorkspaces(geometry: geometry, interaction: interaction, checks: checks)
    }
    mutating func runTracedPipeline() -> RuntimeCompletePipelineResult<RuntimeOwnerFailure> {
        let result = RuntimeCompletePipeline.run(owner: &self)
        counterTrace("result", result)
        return result
    }
    mutating func terminatePresentation() {
        guard !presentationTeardownComplete else { return }
        // Called only after the synchronous attempt finalized and released reads.
        precondition(!frameActive && !observableCandidate && !semanticCandidate && !interactionCandidate)
        presentationTeardownComplete = true
        control.pointee.teardowns += 1
        control.pointee.unavailable = true
        control.pointee.inputGate.quiesce()
        quiescent = true; pending = false
        control.pointee.admission.resetAll()
        control.pointee.runtime.pointer.capture.cancel()
        control.pointee.runtime.pointer.sequence.cancelCurrentSequence()
        control.pointee.runtime.pointer.source = nil
        if let retained = recovery.pendingIntent { recovery.clearPending(for: retained.semanticRevision) }
        control.pointee.disableCounterWake()
        interaction.resetAllStorage()
        control.pointee.committedRecords = 0
        do throws(ObservableStateError) { try root.shutdown() }
        catch { models.requireStop() }
        rootIdentity = nil; actionIdentity = nil
        control.pointee.hasRoot = false
        counterTrace("terminal", (interaction.committedRecordCount, values.count, models.phase))
    }
    mutating func boundary(_ stage: RuntimeCompletePipelineStage) -> RunCycleFailure<RuntimeOwnerFailure>? {
        control.pointee.context = phase.context
        counterTrace("stage", stage)
        control.pointee.stages |= UInt16(1) << stage.rawValue
        if stage == .applyAdmittedWork && control.pointee.injectCompletionAtApply {
            control.pointee.injectCompletionAtApply = false
            let finalized = control.pointee.finalized
            var producer = CounterAdmission(borrowing: control)
            precondition(producer.submit(completion: 0).result == .queued)
            control.pointee.lateCallbackObservedActive = phase.context.phase == .mutating
            control.pointee.lateCallbackDidNotRunRuntime = control.pointee.finalized == finalized
        }
        if control.pointee.unavailable { return .execution(.requiredFacilityUnavailable) }
        if control.pointee.fault == stage { return control.pointee.boundaryFailure }
        return nil
    }
    mutating func admitAndSeal() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        control.pointee.cleanups = 0; control.pointee.cleanupCount = 0
        guard !quiescent else { return .failure(.execution(.requiredFacilityUnavailable)) }
        if let error = phase.beginCycle(reservingFrom: &counters) { return .failure(.execution(error)) }
        if let error = boundary(.admissionAndSeal) { return .failure(error) }
        sealedAdmission = nil
        var transaction = ExecutionAdmissionSealTransaction(limits: limits.execution)!
        precondition(transaction.begin())
        var staged = control.pointee.runtime.pointer
        var activation: CapturedAction<SemanticCompleteIdentity>?
        var selected: UInt16 = 0
        for index in 0..<2 where selected < limits.execution.maximumInputEvents {
            guard let pointer = control.pointee.admission.pendingPointers[index] else { continue }
            let validRevision = pointer.presentationRevision == interaction.committedRevision
            let validSource = staged.source == nil || staged.source == pointer.source
            let validation = staged.sequence.validate(phase: pointer.phase, sequence: pointer.sequence, ordinal: pointer.ordinal, targetGateAllowsResynchronization: true)
            let valid = validRevision && validSource && (validation == .accepted || validation == .consumedWhileCancelled)
            var createsActivation = false
            if valid && validation == .accepted {
                staged.source = pointer.source
                let gesture: PointerGestureOutcome<SemanticCompleteIdentity>
                switch pointer.phase {
                case .down: gesture = ExecutionGestureAdapter.down(at: pointer.position, capture: &staged.capture, resolver: interaction)
                case .move: gesture = ExecutionGestureAdapter.move(at: pointer.position, capture: &staged.capture, resolver: interaction)
                case .up: gesture = ExecutionGestureAdapter.up(at: pointer.position, capture: &staged.capture, resolver: interaction)
                }
                if case .activationAdmitted(let captured) = gesture { activation = captured; createsActivation = true }
                counterTrace("gesture", gesture)
            }
            guard transaction.stagePointer(pointer, provenanceValid: valid, createsActivation: createsActivation, transitionReservationAvailable: true) else { break }
            selected += 1
        }
        switch transaction.finish(pendingStateChangeFacts: control.pointee.admission.pendingStateCount, pendingCompletionFacts: control.pointee.admission.pendingCompletion == nil ? 0 : 1, includesDirtyRederivation: changed, includesPresentationRecovery: pending, batchReservationAvailable: true) {
        case .failure(let failure):
            if let cancelled = failure.cancelledSequence {
                control.pointee.cancelPointerSequence(source: cancelled.source, sequence: cancelled.sequence)
            }
            sealedAdmission = failure.summary
            return .failure(.execution(failure.failure == .invalidProvenance ? .invalidProvenance : .capacityExhausted))
        case .success(let selection):
            guard control.pointee.admission.seal(selection.summary) else { return .failure(.execution(.invariantViolation)) }
            control.pointee.runtime.pointer = staged
            control.pointee.admission.sealedAction = activation
            sealedAdmission = selection.summary
        }
        return .advanced
    }
    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult<RuntimeOwnerFailure> {
        if let error = phase.transition(to: .mutating) { return .failure(.execution(error), mutationApplied: false) }
        if let error = boundary(.applyAdmittedWork) { return .failure(error, mutationApplied: false) }
        var applied = false
        while let value = control.pointee.admission.takeState() {
            guard let rootIdentity, let key = root.modelKey(identity: rootIdentity, ordinal: 0) else { return .failure(.execution(.invalidProvenance), mutationApplied: applied) }
            switch root.mutate(key, mutation: .fact(value)) {
            case .success(.unchanged): break
            case .success: applied = true; changed = true; control.pointee.applied += 1
            case .failure(let error): return .failure(.focusedOwner(.observableState(error)), mutationApplied: applied)
            }
        }
        control.pointee.admission.sealedCompletion = nil
        if let captured = control.pointee.admission.sealedAction.take() {
            switch dispatch(captured) {
            case .applied(let changed): applied = applied || changed
            case .failure(let failure, let changed): return .failure(failure, mutationApplied: applied || changed)
            }
        }
        return .applied(applied)
    }
    mutating func dispatch(_ captured: CapturedAction<SemanticCompleteIdentity>) -> RuntimePipelineMutationResult<RuntimeOwnerFailure> {
        guard let rootIdentity else { return .applied(false) }
        let target = ObservableStateRootTargetAccess(root: root, identity: rootIdentity, ordinal: 0)
        let result = RuntimeRecordInteractionBridge.dispatch(captured, records: interaction, target: target, actionType: CounterAction.self, operation: CounterHandler.operation)
        counterTrace("dispatch", result)
        switch result {
        case .interaction(.dispatched):
            control.pointee.applied += 1; changed = true
            if control.pointee.failAfterMutation { return .failure(.execution(.capacityExhausted), mutationApplied: true) }
            return .applied(true)
        case .interaction(.cancelled): return .applied(false)
        case .observableFailure(let error): return .failure(.focusedOwner(.observableState(error)), mutationApplied: false)
        case .interaction(.failure(let error)): return .failure(.focusedOwner(.interaction(error)), mutationApplied: false)
        }
    }
    mutating func freezeObservableMutation() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.freezeObservableMutation) { return .failure(error) }
        do throws(ObservableStateError) { try models.beginFrame(); frameActive = true }
        catch { return .failure(.focusedOwner(.observableState(error))) }
        if let error = phase.transition(to: .deriving) { return .failure(.execution(error)) }
        control.pointee.context = phase.context
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
        let result = semantic.expand(CounterScreen<CounterDomain>(), roles: CounterRoles.self, codec: CanvasSemanticPayloadCodec<CounterRoles, CounterValueTable>.self, limits: limits.semantic, binding: ObservableSemanticBodyBinding(models: models.borrowedScope(), root: root.borrowedRoot(), domain: CounterDomain.self))
        switch result {
        case .success: semanticCandidate = true
        case .semanticFailure(let error): discardLocalCandidates(); return .failure(.focusedOwner(.semantic(error)))
        case .bindingFailure(let error): discardLocalCandidates(); return .failure(.focusedOwner(.observableState(error)))
        case .accessFailure: discardLocalCandidates(); return .failure(.focusedOwner(.observableState(.staleModel)))
        }
        do throws(DrawingError) { try CanvasSemanticTransfer.stage(from: semantic, into: values, table: CounterValueTable()) }
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
                control.pointee.semanticSnapshot = CounterSemanticSnapshot(bank)
                switch geometry.layout(bank, limits: limits) { case .success: return .advanced; case .failure(let error): return .failure(.focusedOwner(.layout(error))) }
            }
        } catch { return .failure(.focusedOwner(.semantic(error))) }
    }
    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.canvasInvocationAndPlan) { return .failure(error) }
        var source = CounterSource(models: models.borrowedScope(), values: values.borrowedValues(), table: CounterValueTable())
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
        candidateRootIdentity = nil; candidateActionIdentity = nil
        do throws(SemanticExpansionError) {
            return try semantic.withCandidateView { bank in
                var target: SemanticCompleteIdentity?
                var paintOrder: UInt16 = 0
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
                    switch RuntimeRecordInteractionBridge.append(record: ref, semantic: bank, root: root, rootIdentity: target, rootOrdinal: 0, actionType: CounterAction.self, roles: CounterRoles.self, isEnabled: counterActionIsEnabled(ref, bank: bank), bounds: bounds, clip: clip, paintOrder: paintOrder, interaction: &interaction) {
                    case .failure(let error): return .failure(.focusedOwner(.interaction(error)))
                    case .requiresGeneration:
                        guard let generation = generations.generation(for: identity), interaction.assignGeneration(generation, to: identity) == nil else { return .failure(.execution(.identityExhausted)) }
                    case .preserved: break
                    }
                    paintOrder += 1
                    candidateActionIdentity = identity
                    control.pointee.actionPoint = bounds.origin
                    let code = counterActionCode(ref, bank: bank)
                    precondition(code < 2)
                    control.pointee.actionPoints[Int(code)] = bounds.origin
                }
                candidateRootIdentity = target
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
        rootIdentity = candidateRootIdentity
        if let error = phase.recordPublishedSemanticRevision(revision) { return .failure(.execution(error)) }
        control.pointee.context = phase.context
        return .published(.init(semanticRevision: revision, changed: changed))
    }
    mutating func allocateCandidate() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.candidateAllocation) { return .failure(error) }
        guard let candidate = candidates.reserve(), let counter = phase.context.cycle, let revision = phase.context.semanticRevision else { return .failure(.execution(.identityExhausted)) }
        if let error = phase.recordCandidateFrame(candidate) { return .failure(.execution(error)) }
        guard let presentation = presentations.reserve() else { return .failure(.execution(.identityExhausted)) }
        self.presentation = presentation; provenance = .init(cycle: counter, semanticRevision: revision, candidateFrame: candidate)
        return .advanced
    }
    mutating func offerAndProduce() -> RuntimePipelineOfferResult<RuntimeOwnerFailure> {
        if let error = boundary(.offerAndProduction) { return .failure(error) }
        if let error = phase.transition(to: .offering) { return .failure(.execution(error)) }
        control.pointee.context = phase.context
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
        if offer.disposition == .accepted { control.pointee.lastFrame = endpoint.sink }
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
        counterTrace("cleanup", action)
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
        case .commitInteractionCandidate: interaction.resolveCandidate(.commit(presentation!)); generations.resolveCandidate(committed: true); interactionCandidate = false; control.pointee.commits += 1; actionIdentity = candidateActionIdentity; committedPresentation = presentation; control.pointee.runtime.committedPresentation = presentation; control.pointee.inputGate.installPhysicalPresentation(presentation!)
        case .resetAttemptStorage:
            discardLocalCandidates()
            if interactionCandidate { interaction.resolveCandidate(.discard); generations.resolveCandidate(committed: false); interactionCandidate = false }
            candidateRootIdentity = nil; candidateActionIdentity = nil
            geometry.reset()
            if frameActive { do throws(ObservableStateError) { try models.endFrame() } catch { quiescent = true }; frameActive = false }
        }
    }
    mutating func applyDisposition(_ disposition: RuntimePipelineDisposition) {
        counterTrace("disposition", disposition)
        changed = disposition.semanticDisposition == .dirty
        if changed { control.pointee.emitCounterWake(.semanticDirty) }
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
        counterTrace("finalized", (completedContext, control.pointee.applied, control.pointee.commits, interaction.committedRecordCount, values.count, models.phase))
        control.pointee.finalized += 1
        if quiescent { terminatePresentation() }
    }
}

// Enabled state comes from the actual traversed modifier chain, not a copied
// host value or precomputed action table.
private func counterActionIsEnabled(_ ref: SemanticRecordReference, bank: borrowing SemanticRecordView<CounterPayload>) -> Bool {
    var current = ref
    while let record = bank.record(current) {
        if let payload = bank.payload(at: record.payload), case .standard(.disabled(true)) = payload { return false }
        guard record.parent < current.ordinal, let parent = bank.reference(at: record.parent) else { break }
        current = parent
    }
    return true
}
func counterTrace<T>(_ label: StaticString, _ value: T) { print(label, value) }

private func counterActionCode(_ ref: SemanticRecordReference, bank: borrowing SemanticRecordView<CounterPayload>) -> UInt16 {
    guard let record = bank.record(ref), let payload = bank.payload(at: record.payload), case .standard(.action(_, let code)) = payload else { preconditionFailure("counter action payload") }
    return code
}
