import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import GiftUIRuntimeStatic
import SignalAnalyzerDomain
import SignalAnalyzerHost
import SignalAnalyzerPresentation
import Testing

private final class ActionRepository: SignalAcquisitionRepository {
    private(set) var calls: [String] = []
    var onStart: (() -> Void)?

    func startObservingCapture(sink: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws {
        calls.append("start")
        onStart?()
    }
    func stop() { calls.append("stop") }
    func clear() { calls.append("clear") }
}

private enum ActionApplicationExecutorMode {
    case sameThread
    case distinctExecutor
}

private final class ActionApplicationExecutor {
    let mode: ActionApplicationExecutorMode
    private var pending: (() -> Void)?

    init(mode: ActionApplicationExecutorMode) {
        self.mode = mode
    }

    func submit(_ operation: @escaping () -> Void) {
        switch mode {
        case .sameThread: operation()
        case .distinctExecutor: pending = operation
        }
    }

    func drain() {
        let operation = pending
        pending = nil
        operation?()
    }
}

private struct ActionCallbackTranscript: Equatable {
    let dispatch: InteractionDispatchResult
    let outcomeBeforeDrain: SignalSinkDeliveryOutcome?
    let stateBeforeLaterMutation: SignalAnalyzerViewState
    let admittedFact: SignalAnalyzerPresentationFact?
    let stateAfterLaterMutation: SignalAnalyzerViewState
}

private struct ActionReplacementTranscript: Equatable {
    let afterPointerDownReplacement: InteractionDispatchResult
    let afterAdmittedActionReplacement: InteractionDispatchResult
    let afterRemoval: InteractionDispatchResult
    let failedStagingReplacement: ObservableStateResult
    let afterFailedReplacement: InteractionDispatchResult
    let disabled: InteractionDispatchResult
    let formerCalls: [String]
    let replacementCalls: [String]
}

private struct AnalyzerActionRecords: InteractionCommittedActionView {
    let record: BoundActionRecord<UInt16>?

    func committedRecord(for identity: UInt16) -> BoundActionRecord<UInt16>? {
        guard record?.identity == identity else { return nil }
        return record
    }
}

private let analyzerActionBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 4, height: 4)!
)!

private func analyzerActionRecord(
    code: UInt16,
    actionGeneration: UInt32 = 8,
    targetGeneration: UInt32 = 0,
    enabled: Bool = true
) -> BoundActionRecord<UInt16> {
    BoundActionRecord(
        identity: 4,
        generation: ActionGeneration(rawValue: actionGeneration),
        isEnabled: enabled,
        hitBounds: analyzerActionBounds,
        paintOrder: 0,
        action: BoundedApplicationAction(code: code),
        targetGeneration: ObservableTargetGeneration(rawValue: targetGeneration)
    )
}

@Test(arguments: Array(UInt16(0) ... UInt16(5)))
func everyAnalyzerActionCodeDispatchesToTheExactCurrentModel(code: UInt16) {
    let repository = ActionRepository()
    let model = makeActionModel(repository: repository)
    let root = makeActionRoot(model)
    var dispatcher = DynamicSignalAnalyzerActionDispatcher.make(
        records: AnalyzerActionRecords(record: analyzerActionRecord(code: code)),
        root: root
    )

    let result = dispatcher.dispatch(
        CapturedAction(
            identity: 4,
            generation: ActionGeneration(rawValue: 8)
        )
    )

    #expect(result == .dispatched)
    switch SignalAnalyzerAction(rawValue: code)! {
    case .start: #expect(repository.calls == ["start"])
    case .stop: #expect(repository.calls == ["stop"])
    case .clear: #expect(repository.calls == ["clear"])
    case .selectOneSecond: #expect(model.state.visibleWindow == .oneSecond)
    case .selectTwoSeconds: #expect(model.state.visibleWindow == .twoSeconds)
    case .selectFiveSeconds: #expect(model.state.visibleWindow == .fiveSeconds)
    }
}

@Test(arguments: Array(UInt16(0) ... UInt16(5)))
func everyAnalyzerActionCodeDispatchesThroughTheStaticRoot(code: UInt16) {
    let repository = ActionRepository()
    var root = makeStaticActionRoot(makeActionModel(repository: repository))

    withUnsafeMutablePointer(to: &root) { rootPointer in
        var dispatcher = StaticSignalAnalyzerActionDispatcher.make(
            records: AnalyzerActionRecords(record: analyzerActionRecord(code: code)),
            root: rootPointer
        )

        #expect(
            dispatcher.dispatch(
                CapturedAction(identity: 4, generation: ActionGeneration(rawValue: 8))
            ) == .dispatched
        )
    }

    switch SignalAnalyzerAction(rawValue: code)! {
    case .start: #expect(repository.calls == ["start"])
    case .stop: #expect(repository.calls == ["stop"])
    case .clear: #expect(repository.calls == ["clear"])
    case .selectOneSecond:
        #expect(root.withModel { $0.state.visibleWindow } == .oneSecond)
    case .selectTwoSeconds:
        #expect(root.withModel { $0.state.visibleWindow } == .twoSeconds)
    case .selectFiveSeconds:
        #expect(root.withModel { $0.state.visibleWindow } == .fiveSeconds)
    }
}

@Test(arguments: [UInt16(6), UInt16.max])
func invalidAnalyzerActionCodesFailClosed(code: UInt16) {
    let repository = ActionRepository()
    let model = makeActionModel(repository: repository)
    let root = makeActionRoot(model)
    var dispatcher = DynamicSignalAnalyzerActionDispatcher.make(
        records: AnalyzerActionRecords(record: analyzerActionRecord(code: code)),
        root: root
    )

    #expect(
        dispatcher.dispatch(
            CapturedAction(identity: 4, generation: ActionGeneration(rawValue: 8))
        ) == .failure(.invariantViolation)
    )
    #expect(repository.calls.isEmpty)
    #expect(model.state == SignalAnalyzerViewState())
}

@Test func staleActionAndTargetGenerationsCancelBeforeBorrowingTheModel() {
    for fixture in [
        (recordGeneration: UInt32(9), targetGeneration: UInt32(0)),
        (recordGeneration: UInt32(8), targetGeneration: UInt32(1)),
    ] {
        let repository = ActionRepository()
        let model = makeActionModel(repository: repository)
        let root = makeActionRoot(model)
        var dispatcher = DynamicSignalAnalyzerActionDispatcher.make(
            records: AnalyzerActionRecords(
                record: analyzerActionRecord(
                    code: SignalAnalyzerAction.start.rawValue,
                    actionGeneration: fixture.recordGeneration,
                    targetGeneration: fixture.targetGeneration
                )
            ),
            root: root
        )

        #expect(
            dispatcher.dispatch(
                CapturedAction(identity: 4, generation: ActionGeneration(rawValue: 8))
            ) == .cancelled
        )
        #expect(repository.calls.isEmpty)
    }
}

@Test func replacementBetweenCaptureAndDispatchCancelsAndRetainsNeitherModel() {
    let repository = ActionRepository()
    var former: SignalAnalyzerViewModel? = makeActionModel(repository: repository)
    weak let weakFormer = former
    let root = makeActionRoot(former!)
    var dispatcher = DynamicSignalAnalyzerActionDispatcher.make(
        records: AnalyzerActionRecords(
            record: analyzerActionRecord(code: SignalAnalyzerAction.start.rawValue)
        ),
        root: root
    )
    let captured = CapturedAction(
        identity: UInt16(4),
        generation: ActionGeneration(rawValue: 8)
    )

    root.setExecutionPhase(.mutating)
    #expect(
        root.replace(with: makeActionModel(repository: repository))
            == .success(.replaced)
    )
    former = nil

    #expect(weakFormer == nil)
    #expect(dispatcher.dispatch(captured) == .cancelled)
    #expect(repository.calls.isEmpty)
}

@Test func actionReplacementInterleavingsAreEqualAcrossProfiles() {
    let dynamic = dynamicActionReplacementTranscript()
    let fixed = staticActionReplacementTranscript()

    #expect(dynamic == fixed)
    #expect(dynamic.afterPointerDownReplacement == .cancelled)
    #expect(dynamic.afterAdmittedActionReplacement == .cancelled)
    #expect(dynamic.afterRemoval == .cancelled)
    #expect(
        dynamic.failedStagingReplacement
            == ObservableStateResult.failure(.replacementStagingCapacityExhausted)
    )
    #expect(dynamic.afterFailedReplacement == .dispatched)
    #expect(dynamic.disabled == .cancelled)
    #expect(dynamic.formerCalls == ["start"])
    #expect(dynamic.replacementCalls.isEmpty)
}

@Test func sameThreadAndDistinctActionCallbacksStopAtLaterFactAdmission() {
    let sameThread = runActionCallback(mode: .sameThread)
    let distinct = runActionCallback(mode: .distinctExecutor)

    #expect(sameThread.dispatch == .dispatched)
    #expect(distinct.dispatch == .dispatched)
    #expect(sameThread.outcomeBeforeDrain == .accepted(sequence: 1))
    #expect(distinct.outcomeBeforeDrain == nil)
    #expect(sameThread.stateBeforeLaterMutation == SignalAnalyzerViewState())
    #expect(distinct.stateBeforeLaterMutation == SignalAnalyzerViewState())
    #expect(sameThread.admittedFact == .acquisitionState(.running))
    #expect(distinct.admittedFact == .acquisitionState(.running))
    #expect(sameThread.stateAfterLaterMutation == distinct.stateAfterLaterMutation)
    #expect(sameThread.stateAfterLaterMutation.acquisitionState == .running)
}

private func runActionCallback(
    mode: ActionApplicationExecutorMode
) -> ActionCallbackTranscript {
    let admission = DynamicSignalAnalyzerHostFactAdmission()
    let executor = ActionApplicationExecutor(mode: mode)
    let repository = ActionRepository()
    let model = makeActionModel(repository: repository)
    let root = makeActionRoot(model)
    var callbackOutcome: SignalSinkDeliveryOutcome?
    repository.onStart = {
        executor.submit {
            callbackOutcome = admission.submit(.acquisitionState(.running))
        }
    }
    var dispatcher = DynamicSignalAnalyzerActionDispatcher.make(
        records: AnalyzerActionRecords(
            record: analyzerActionRecord(code: SignalAnalyzerAction.start.rawValue)
        ),
        root: root
    )

    #expect(admission.beginProducer(.action))
    let dispatch = dispatcher.dispatch(
        CapturedAction(identity: 4, generation: ActionGeneration(rawValue: 8))
    )
    let outcomeBeforeDrain = callbackOutcome
    let stateBeforeLaterMutation = model.state
    executor.drain()
    admission.endProducer()

    #expect(callbackOutcome == .accepted(sequence: 1))
    #expect(admission.seal())
    let admittedFact = admission.takeNextSealed()?.2
    if let admittedFact {
        root.setExecutionPhase(.mutating)
        #expect(model.apply(admittedFact) == .applied(changed: true))
        #expect(root.isDirty)
    }
    return ActionCallbackTranscript(
        dispatch: dispatch,
        outcomeBeforeDrain: outcomeBeforeDrain,
        stateBeforeLaterMutation: stateBeforeLaterMutation,
        admittedFact: admittedFact,
        stateAfterLaterMutation: model.state
    )
}

private func dynamicActionReplacementTranscript() -> ActionReplacementTranscript {
    let formerRepository = ActionRepository()
    let replacementRepository = ActionRepository()
    let root = makeActionRoot(makeActionModel(repository: formerRepository))
    var formerDispatcher = DynamicSignalAnalyzerActionDispatcher.make(
        records: AnalyzerActionRecords(
            record: analyzerActionRecord(code: SignalAnalyzerAction.start.rawValue)
        ),
        root: root
    )
    let pointerDownCapture = CapturedAction(
        identity: UInt16(4),
        generation: ActionGeneration(rawValue: 8)
    )

    root.setExecutionPhase(.mutating)
    _ = root.replace(with: makeActionModel(repository: replacementRepository))
    let afterPointerDownReplacement = formerDispatcher.dispatch(pointerDownCapture)
    let admittedAction = pointerDownCapture
    let afterAdmittedActionReplacement = formerDispatcher.dispatch(admittedAction)
    _ = root.beginCandidate()
    _ = root.finishCandidate(.publish)
    let afterRemoval = formerDispatcher.dispatch(admittedAction)

    let preservedRoot = makeActionRoot(makeActionModel(repository: formerRepository))
    preservedRoot.setExecutionPhase(.mutating)
    let failedStagingReplacement = preservedRoot.replace(
        with: makeActionModel(repository: replacementRepository),
        replacementStagingAvailable: false
    )
    var preservedDispatcher = DynamicSignalAnalyzerActionDispatcher.make(
        records: AnalyzerActionRecords(
            record: analyzerActionRecord(code: SignalAnalyzerAction.start.rawValue)
        ),
        root: preservedRoot
    )
    let afterFailedReplacement = preservedDispatcher.dispatch(pointerDownCapture)
    var disabledDispatcher = DynamicSignalAnalyzerActionDispatcher.make(
        records: AnalyzerActionRecords(
            record: analyzerActionRecord(
                code: SignalAnalyzerAction.start.rawValue,
                enabled: false
            )
        ),
        root: preservedRoot
    )
    let disabled = disabledDispatcher.dispatch(pointerDownCapture)
    return ActionReplacementTranscript(
        afterPointerDownReplacement: afterPointerDownReplacement,
        afterAdmittedActionReplacement: afterAdmittedActionReplacement,
        afterRemoval: afterRemoval,
        failedStagingReplacement: failedStagingReplacement,
        afterFailedReplacement: afterFailedReplacement,
        disabled: disabled,
        formerCalls: formerRepository.calls,
        replacementCalls: replacementRepository.calls
    )
}

private func staticActionReplacementTranscript() -> ActionReplacementTranscript {
    let formerRepository = ActionRepository()
    let replacementRepository = ActionRepository()
    var root = makeStaticActionRoot(makeActionModel(repository: formerRepository))
    let pointerDownCapture = CapturedAction(
        identity: UInt16(4),
        generation: ActionGeneration(rawValue: 8)
    )
    let firstResults = withUnsafeMutablePointer(to: &root) { rootPointer in
        var formerDispatcher = StaticSignalAnalyzerActionDispatcher.make(
            records: AnalyzerActionRecords(
                record: analyzerActionRecord(code: SignalAnalyzerAction.start.rawValue)
            ),
            root: rootPointer
        )
        rootPointer.pointee.setExecutionPhase(.mutating)
        _ = rootPointer.pointee.replace(
            with: makeActionModel(repository: replacementRepository),
            reportRoute: { attachment in
                rootPointer.pointee.acceptReport(attachment)
            }
        )
        let afterPointerDownReplacement = formerDispatcher.dispatch(pointerDownCapture)
        let admittedAction = pointerDownCapture
        let afterAdmittedActionReplacement = formerDispatcher.dispatch(admittedAction)
        _ = rootPointer.pointee.beginCandidate()
        _ = rootPointer.pointee.finishCandidate(.publish)
        let afterRemoval = formerDispatcher.dispatch(admittedAction)
        return (
            afterPointerDownReplacement,
            afterAdmittedActionReplacement,
            afterRemoval
        )
    }

    var preservedRoot = makeStaticActionRoot(
        makeActionModel(repository: formerRepository)
    )
    return withUnsafeMutablePointer(to: &preservedRoot) { rootPointer in
        rootPointer.pointee.setExecutionPhase(.mutating)
        let failedStagingReplacement = rootPointer.pointee.replace(
            with: makeActionModel(repository: replacementRepository),
            reportRoute: { attachment in
                rootPointer.pointee.acceptReport(attachment)
            },
            replacementStagingAvailable: false
        )
        var preservedDispatcher = StaticSignalAnalyzerActionDispatcher.make(
            records: AnalyzerActionRecords(
                record: analyzerActionRecord(code: SignalAnalyzerAction.start.rawValue)
            ),
            root: rootPointer
        )
        let afterFailedReplacement = preservedDispatcher.dispatch(pointerDownCapture)
        var disabledDispatcher = StaticSignalAnalyzerActionDispatcher.make(
            records: AnalyzerActionRecords(
                record: analyzerActionRecord(
                    code: SignalAnalyzerAction.start.rawValue,
                    enabled: false
                )
            ),
            root: rootPointer
        )
        let disabled = disabledDispatcher.dispatch(pointerDownCapture)
        return ActionReplacementTranscript(
            afterPointerDownReplacement: firstResults.0,
            afterAdmittedActionReplacement: firstResults.1,
            afterRemoval: firstResults.2,
            failedStagingReplacement: failedStagingReplacement,
            afterFailedReplacement: afterFailedReplacement,
            disabled: disabled,
            formerCalls: formerRepository.calls,
            replacementCalls: replacementRepository.calls
        )
    }
}

private func makeActionRoot(
    _ model: SignalAnalyzerViewModel
) -> DynamicObservableRootAdapter<SignalAnalyzerViewModel, UInt16> {
    let root = DynamicObservableRootAdapter<SignalAnalyzerViewModel, UInt16>(capacity: 1)
    var state = State(wrappedValue: model)
    #expect(root.beginCandidate() == .success(.candidateStarted))
    #expect(
        root.encounter(
            structuralIdentity: 1,
            declarationOrdinal: 0,
            state: &state,
            replacementRoute: { _ in }
        ) == .success(.materialized)
    )
    #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
    return root
}

private func makeStaticActionRoot(
    _ model: SignalAnalyzerViewModel
) -> StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt16> {
    var root = StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt16>(
        structuralIdentity: 1,
        declarationOrdinal: 0
    )
    #expect(root.beginCandidate() == .success(.candidateStarted))
    let encounter = root.withEncounter(
        state: State(wrappedValue: model),
        replacementRoute: { _ in },
        reportRoute: { _ in .staleAttachment },
        body: { _ in () }
    )
    switch encounter {
    case .bound(.success(.materialized), ()): break
    default: Issue.record("expected the Static analyzer model to materialize")
    }
    #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
    return root
}

private func makeActionModel(repository: ActionRepository) -> SignalAnalyzerViewModel {
    SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
}
