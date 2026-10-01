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
private let staticNRFRootIdentity: UInt32 = 1_410_692_621
@Test func staticNRFInteractionDispatchesAcrossSerializedOpportunities() {
    var root = StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>(
        structuralIdentity: staticNRFRootIdentity,
        declarationOrdinal: 0
    )
    var interaction = makeStaticNRFInteraction(targetGeneration: 0)
    var owner = makeStaticNRFApplicationInputOwner()

    withUnsafeMutablePointer(to: &root) { rootPointer in
        bindStaticNRFInteractionRoot(rootPointer)
    }

    admitStaticNRFInteraction(.down, into: &owner)
    #expect(
        owner.runOpportunity(interaction: &interaction, root: &root)
            == .completed(
                StaticSignalAnalyzerNRFInputDrainSummary(
                    eventCount: 1,
                    dispatchedActionCount: 0,
                    cancelledOrRejectedCount: 0
                )
            )
    )
    #expect(root.withModel { $0.state.visibleWindow } == .twoSeconds)

    admitStaticNRFInteraction(.up, into: &owner)
    #expect(
        owner.runOpportunity(interaction: &interaction, root: &root)
            == .completed(
                StaticSignalAnalyzerNRFInputDrainSummary(
                    eventCount: 1,
                    dispatchedActionCount: 1,
                    cancelledOrRejectedCount: 0
                )
            )
    )
    #expect(root.withModel { $0.state.visibleWindow } == .oneSecond)
    let rootIsDirty = root.isDirty
    #expect(rootIsDirty)
}

@Test func staticNRFInteractionRejectsAStaleObservableTargetGeneration() {
    var root = StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>(
        structuralIdentity: staticNRFRootIdentity,
        declarationOrdinal: 0
    )
    var interaction = makeStaticNRFInteraction(targetGeneration: 1)
    var owner = makeStaticNRFApplicationInputOwner()

    withUnsafeMutablePointer(to: &root) { rootPointer in
        bindStaticNRFInteractionRoot(rootPointer)
    }
    admitStaticNRFInteraction(.down, into: &owner)
    admitStaticNRFInteraction(.up, into: &owner)

    #expect(
        owner.runOpportunity(interaction: &interaction, root: &root)
            == .completed(
                StaticSignalAnalyzerNRFInputDrainSummary(
                    eventCount: 2,
                    dispatchedActionCount: 0,
                    cancelledOrRejectedCount: 1
                )
            )
    )
    #expect(root.withModel { $0.state.visibleWindow } == .twoSeconds)
    let rootIsDirty = root.isDirty
    #expect(!rootIsDirty)
}

@Test func staticNRFInteractionCancelsCaptureWhenPresentationChanges() {
    var root = StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>(
        structuralIdentity: staticNRFRootIdentity,
        declarationOrdinal: 0
    )
    var interaction = makeStaticNRFInteraction(targetGeneration: 0)
    var owner = makeStaticNRFApplicationInputOwner()

    withUnsafeMutablePointer(to: &root) { rootPointer in
        bindStaticNRFInteractionRoot(rootPointer)
    }
    admitStaticNRFInteraction(.down, into: &owner)
    #expect(
        owner.runOpportunity(interaction: &interaction, root: &root)
            == .completed(
                StaticSignalAnalyzerNRFInputDrainSummary(
                    eventCount: 1,
                    dispatchedActionCount: 0,
                    cancelledOrRejectedCount: 0
                )
            )
    )

    let replacementRevision = PresentationRevision(rawValue: 28)
    owner.installPhysicalPresentation(rawValue: replacementRevision.rawValue)
    admitStaticNRFInteraction(
        .up,
        revision: replacementRevision,
        into: &owner
    )
    #expect(
        owner.runOpportunity(interaction: &interaction, root: &root)
            == .completed(
                StaticSignalAnalyzerNRFInputDrainSummary(
                    eventCount: 1,
                    dispatchedActionCount: 0,
                    cancelledOrRejectedCount: 1
                )
            )
    )
    #expect(root.withModel { $0.state.visibleWindow } == .twoSeconds)
}

@Test func staticNRFApplicationInputOwnerQuiescesAdmissionAndCapture() {
    var root = StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>(
        structuralIdentity: staticNRFRootIdentity,
        declarationOrdinal: 0
    )
    var interaction = makeStaticNRFInteraction(targetGeneration: 0)
    var owner = makeStaticNRFApplicationInputOwner()

    withUnsafeMutablePointer(to: &root) { rootPointer in
        bindStaticNRFInteractionRoot(rootPointer)
    }
    admitStaticNRFInteraction(.down, into: &owner)
    #expect(
        owner.runOpportunity(interaction: &interaction, root: &root)
            == .completed(
                StaticSignalAnalyzerNRFInputDrainSummary(
                    eventCount: 1,
                    dispatchedActionCount: 0,
                    cancelledOrRejectedCount: 0
                )
            )
    )
    owner.quiesce()

    #expect(
        owner.admit(
            phaseRawValue: PointerPhase.up.rawValue,
            x: UInt16(staticNRFInteractionPoint.x),
            y: UInt16(staticNRFInteractionPoint.y),
            observedPresentationRevisionRawValue:
                staticNRFInteractionRevision.rawValue,
            priorPhysicalSequenceIsCompleteRawValue: 0
        )?.disposition == .sourceQuiesced
    )
    #expect(owner.pendingCount == 0)
    #expect(
        owner.runOpportunity(interaction: &interaction, root: &root)
            == .rejected(.application(.unavailable))
    )
}

private func makeStaticNRFApplicationInputOwner()
    -> StaticSignalAnalyzerNRFApplicationInputOwner
{
    var owner = StaticSignalAnalyzerNRFApplicationInputOwner(
        sourceRawValue: staticNRFInteractionSource.rawValue
    )
    owner.installPhysicalPresentation(
        rawValue: staticNRFInteractionRevision.rawValue
    )
    return owner
}

private func makeStaticNRFInteraction(
    targetGeneration: UInt32,
    enabled: Bool = true,
    side: Int32 = 8
) -> StaticInteractionState<UInt32> {
    var interaction = StaticInteractionState<UInt32>(
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
            isEnabled: enabled,
            bounds: Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: side, height: side)!
            )!,
            clip: Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: side, height: side)!
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
        StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>
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
    revision: PresentationRevision = staticNRFInteractionRevision,
    into owner: inout StaticSignalAnalyzerNRFApplicationInputOwner
) {
    guard
        owner.admit(
            phaseRawValue: phase.rawValue,
            x: UInt16(staticNRFInteractionPoint.x),
            y: UInt16(staticNRFInteractionPoint.y),
            observedPresentationRevisionRawValue: revision.rawValue,
            priorPhysicalSequenceIsCompleteRawValue: 0
        )?.disposition == .queued
    else {
        Issue.record("expected Static nRF interaction admission")
        return
    }
}

@Test(arguments: [
    "tap", "hold", "move-inside", "move-outside", "miss", "disabled", "stale", "up-only",
])
func staticTouchABIReachesCurrentModelOnlyOnValidRelease(scenario: String) {
    var root = StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>(
        structuralIdentity: staticNRFRootIdentity, declarationOrdinal: 0)
    var interaction = makeStaticNRFInteraction(
        targetGeneration: 0,
        enabled: scenario != "disabled", side: 44)
    var owner = makeStaticNRFApplicationInputOwner()
    withUnsafeMutablePointer(to: &root) { bindStaticNRFInteractionRoot($0) }
    func admit(_ phase: PointerPhase, x: UInt16, y: UInt16) {
        let outcome = owner.admit(
            phaseRawValue: phase.rawValue, x: x, y: y,
            observedPresentationRevisionRawValue: scenario == "stale"
                ? 0 : staticNRFInteractionRevision.rawValue,
            priorPhysicalSequenceIsCompleteRawValue: phase == .down ? 1 : 0)
        #expect(outcome?.disposition == (scenario == "stale" ? .dropped : .queued))
    }
    if scenario != "up-only" { admit(.down, x: scenario == "miss" ? 80 : 22, y: 22) }
    let down = owner.runOpportunity(interaction: &interaction, root: &root)
    guard case .completed(let summary) = down else {
        Issue.record("Static down failed")
        return
    }
    #expect(summary.dispatchedActionCount == 0)
    #expect(root.withModel { $0.state.visibleWindow } == .twoSeconds)
    let dirtyBeforeRelease = root.isDirty
    #expect(!dirtyBeforeRelease)
    if scenario == "hold" {
        let held = owner.runOpportunity(interaction: &interaction, root: &root)
        guard case .completed(let summary) = held else {
            Issue.record("Static hold failed")
            return
        }
        #expect(summary.dispatchedActionCount == 0)
    }
    if scenario == "move-inside" { admit(.move, x: 30, y: 22) }
    if scenario == "move-outside" { admit(.move, x: 80, y: 22) }
    if scenario != "up-only" { admit(.up, x: scenario == "miss" ? 80 : 22, y: 22) }
    let up = owner.runOpportunity(interaction: &interaction, root: &root)
    guard case .completed(let summary) = up else {
        Issue.record("Static up failed")
        return
    }
    let dispatches: UInt16 = ["tap", "hold", "move-inside"].contains(scenario) ? 1 : 0
    #expect(summary.dispatchedActionCount == dispatches)
    #expect(
        root.withModel { $0.state.visibleWindow } == (dispatches == 1 ? .oneSecond : .twoSeconds))
    let dirtyAfterRelease = root.isDirty
    #expect(dirtyAfterRelease == (dispatches == 1))
}
