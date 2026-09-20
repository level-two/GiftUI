import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeStatic
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import SignalAnalyzerTargetHost
import Testing

private final class StaticNRFInteractionRepository: SignalAcquisitionRepository {
    func startObservingCapture(sink _: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink _: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws {}
    func stop() {}
    func clear() {}
}

private let staticNRFInteractionSource = InputSourceID(rawValue: 51)
private let staticNRFInteractionRevision = PresentationRevision(rawValue: 27)
private let staticNRFInteractionPoint = Point(x: 4, y: 4)
private let staticNRFInteractionContext = ExecutionContext(
    cycle: RunCycleID(rawValue: 13),
    semanticRevision: SemanticRevision(rawValue: 17),
    candidateFrame: CandidateFrameID(rawValue: 19),
    phase: .idle
)

@Test func staticNRFInteractionDispatchesAcrossSerializedOpportunities() {
    var root = StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt16>(
        structuralIdentity: 1,
        declarationOrdinal: 0
    )
    var interaction = makeStaticNRFInteraction(targetGeneration: 0)
    var coordinator = makeStaticNRFInteractionCoordinator()

    withUnsafeMutablePointer(to: &root) { rootPointer in
        bindStaticNRFInteractionRoot(rootPointer)
        withUnsafeMutablePointer(to: &interaction) { interactionPointer in
            var handler = StaticSignalAnalyzerNRFInteractionHandler(
                interaction: interactionPointer,
                root: rootPointer
            )
            handler.installPhysicalPresentation(staticNRFInteractionRevision)

            admitStaticNRFInteraction(.down, into: &coordinator)
            #expect(
                coordinator.runOpportunity(into: &handler)
                    == .completed(
                        StaticSignalAnalyzerNRFInputDrainSummary(
                            eventCount: 1,
                            dispatchedActionCount: 0,
                            cancelledOrRejectedCount: 0
                        )
                    )
            )
            #expect(
                rootPointer.pointee.withModel { $0.state.visibleWindow }
                    == .twoSeconds
            )

            admitStaticNRFInteraction(.up, into: &coordinator)
            #expect(
                coordinator.runOpportunity(into: &handler)
                    == .completed(
                        StaticSignalAnalyzerNRFInputDrainSummary(
                            eventCount: 1,
                            dispatchedActionCount: 1,
                            cancelledOrRejectedCount: 0
                        )
                    )
            )
            #expect(
                rootPointer.pointee.withModel { $0.state.visibleWindow }
                    == .oneSecond
            )
            let rootIsDirty = rootPointer.pointee.isDirty
            #expect(rootIsDirty)
        }
    }
}

@Test func staticNRFInteractionRejectsAStaleObservableTargetGeneration() {
    var root = StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt16>(
        structuralIdentity: 1,
        declarationOrdinal: 0
    )
    var interaction = makeStaticNRFInteraction(targetGeneration: 1)
    var coordinator = makeStaticNRFInteractionCoordinator()

    withUnsafeMutablePointer(to: &root) { rootPointer in
        bindStaticNRFInteractionRoot(rootPointer)
        withUnsafeMutablePointer(to: &interaction) { interactionPointer in
            var handler = StaticSignalAnalyzerNRFInteractionHandler(
                interaction: interactionPointer,
                root: rootPointer
            )
            handler.installPhysicalPresentation(staticNRFInteractionRevision)
            admitStaticNRFInteraction(.down, into: &coordinator)
            admitStaticNRFInteraction(.up, into: &coordinator)

            #expect(
                coordinator.runOpportunity(into: &handler)
                    == .completed(
                        StaticSignalAnalyzerNRFInputDrainSummary(
                            eventCount: 2,
                            dispatchedActionCount: 0,
                            cancelledOrRejectedCount: 1
                        )
                    )
            )
            #expect(
                rootPointer.pointee.withModel { $0.state.visibleWindow }
                    == .twoSeconds
            )
            let rootIsDirty = rootPointer.pointee.isDirty
            #expect(!rootIsDirty)
        }
    }
}

@Test func staticNRFInteractionRetainsInputUntilItsPresentationIsInstalled() {
    var root = StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt16>(
        structuralIdentity: 1,
        declarationOrdinal: 0
    )
    var interaction = makeStaticNRFInteraction(targetGeneration: 0)
    var coordinator = makeStaticNRFInteractionCoordinator()

    withUnsafeMutablePointer(to: &root) { rootPointer in
        bindStaticNRFInteractionRoot(rootPointer)
        withUnsafeMutablePointer(to: &interaction) { interactionPointer in
            var handler = StaticSignalAnalyzerNRFInteractionHandler(
                interaction: interactionPointer,
                root: rootPointer
            )
            admitStaticNRFInteraction(.down, into: &coordinator)

            #expect(
                coordinator.runOpportunity(into: &handler)
                    == .rejected(.handlerUnavailable)
            )
            #expect(coordinator.pendingCount == 1)

            handler.installPhysicalPresentation(staticNRFInteractionRevision)
            #expect(
                coordinator.runOpportunity(into: &handler)
                    == .completed(
                        StaticSignalAnalyzerNRFInputDrainSummary(
                            eventCount: 1,
                            dispatchedActionCount: 0,
                            cancelledOrRejectedCount: 0
                        )
                    )
            )
            #expect(coordinator.pendingCount == 0)
        }
    }
}

private func makeStaticNRFInteractionCoordinator()
    -> StaticSignalAnalyzerNRFInputCoordinator
{
    var coordinator = StaticSignalAnalyzerNRFInputCoordinator(
        source: staticNRFInteractionSource,
        context: staticNRFInteractionContext
    )
    coordinator.installPhysicalPresentation(staticNRFInteractionRevision)
    return coordinator
}

private func makeStaticNRFInteraction(
    targetGeneration: UInt32
) -> StaticInteractionState<UInt16> {
    var interaction = StaticInteractionState<UInt16>(
        candidateRecords: StaticInteractionCandidateStorage(capacity: 1)!,
        candidateHitRegions: StaticInteractionHitStorage(capacity: 1)!,
        candidateCommittedRecords: StaticInteractionCommittedStorage(capacity: 1)!,
        committedRecords: StaticInteractionCommittedStorage(capacity: 1)!,
        committedHitRegions: StaticInteractionHitStorage(capacity: 1)!
    )
    #expect(
        interaction.beginCandidate(
            limits: InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!
        ) == nil
    )
    #expect(
        interaction.append(
            identity: 4,
            isEnabled: true,
            bounds: Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 8, height: 8)!
            )!,
            clip: Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 8, height: 8)!
            )!,
            paintOrder: 0,
            action: BoundedApplicationAction(
                code: SignalAnalyzerAction.selectOneSecond.rawValue
            ),
            targetGeneration: ObservableTargetGeneration(
                rawValue: targetGeneration
            )
        ) == .requiresGeneration
    )
    #expect(
        interaction.assignGeneration(
            ActionGeneration(rawValue: 8),
            to: 4
        ) == nil
    )
    #expect(interaction.finishCandidate() == nil)
    interaction.resolveCandidate(.commit(staticNRFInteractionRevision))
    return interaction
}

private func bindStaticNRFInteractionRoot(
    _ root: UnsafeMutablePointer<
        StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt16>
    >
) {
    let repository = StaticNRFInteractionRepository()
    let model = SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
    #expect(root.pointee.beginCandidate() == .success(.candidateStarted))
    let encounter = root.pointee.withEncounter(
        state: State(wrappedValue: model),
        replacementRoute: { _ in },
        reportRoute: { attachment in
            root.pointee.acceptReport(attachment)
        },
        body: { _ in () }
    )
    switch encounter {
    case .bound(.success(.materialized), ()): break
    default: Issue.record("expected the Static analyzer model to materialize")
    }
    #expect(
        root.pointee.finishCandidate(.publish)
            == .success(.associationsCommitted)
    )
}

private func admitStaticNRFInteraction(
    _ phase: PointerPhase,
    into coordinator: inout StaticSignalAnalyzerNRFInputCoordinator
) {
    guard
        case .queued = coordinator.admit(
            phase: phase,
            position: staticNRFInteractionPoint,
            source: staticNRFInteractionSource,
            observedPresentationRevision: staticNRFInteractionRevision
        )
    else {
        Issue.record("expected Static nRF interaction admission")
        return
    }
}
