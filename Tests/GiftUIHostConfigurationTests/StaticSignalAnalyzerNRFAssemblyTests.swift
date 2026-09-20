import GiftUI
import GiftUICapabilities
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIInteraction
import GiftUIRuntimeCore
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import SignalAnalyzerTargetHost
import Testing

private final class StaticNRFApplicationStorageRepositoryProbe {
    var startCount = 0
    var stopCount = 0
    var clearCount = 0
    var repositoryWasReleased = false
}

private final class StaticNRFApplicationStorageRepository:
    SignalAcquisitionRepository
{
    private let probe: StaticNRFApplicationStorageRepositoryProbe

    init(probe: StaticNRFApplicationStorageRepositoryProbe) {
        self.probe = probe
    }

    deinit { probe.repositoryWasReleased = true }

    func startObservingCapture(sink _: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink _: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws { probe.startCount += 1 }
    func stop() { probe.stopCount += 1 }
    func clear() { probe.clearCount += 1 }
}

@Test func staticNRFAssemblyValidatesExactGeneratedEndpointContract() {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate() else {
        Issue.record("Static nRF production assembly did not validate")
        return
    }

    #expect(report.kind == .nrf52840Static)
    #expect(report.profile == .static)
    #expect(report.storageAudit == preset.validatedStorageAudit().audit)
    #expect(report.effectivePresentation.extent == preset.capabilityRequirement.extent)
    #expect(report.effectivePresentation.realization == .tiled)
    #expect(report.effectivePresentation.regionExtent.width == 480)
    #expect(report.effectivePresentation.regionExtent.height == 4)
    #expect(report.effectivePresentation.requiredRasterBytes.rawValue == 3_840)
    #expect(report.effectivePresentation.requiredPayloadBytes.rawValue == 3_840)
    #expect(report.effectivePresentation.submissionLifetime == .synchronousBorrow)
    #expect(report.drawingPlanOperationLimit == 5)
    #expect(report.minimumSinkOperationCapacity == 35)
    #expect(report.cardinality == preset.cardinality)
    #expect(report.maximumCompactFactsPerServiceWindow == 28)
}

@Test func staticNRFApplicationStorageUsesValidatedGeneratedOwners() {
    guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate(),
        var storage = StaticSignalAnalyzerNRFApplicationStorage(
            assemblyReport: report,
            inputSourceRawValue: 51
        )
    else {
        Issue.record("Static nRF application storage did not construct")
        return
    }

    #expect(storage.assemblyReport == report)
    #expect(storage.root.targetGeneration() == nil)
    #expect(storage.input.pendingCount == 0)
    #expect(
        storage.interaction.beginCandidate(
            limits: InteractionLimits(maximumActions: 6, maximumHitRegions: 6)!
        ) == nil
    )
    storage.interaction.resolveCandidate(.discard)
    #expect(
        storage.interaction.beginCandidate(
            limits: InteractionLimits(maximumActions: 7, maximumHitRegions: 7)!
        ) == .capacityExhausted
    )
}

@Test func staticNRFApplicationStorageRejectsAnotherTargetReport() {
    guard case .valid(let report) = DynamicSignalAnalyzerPiAssembly.validate() else {
        Issue.record("Dynamic Pi assembly did not validate")
        return
    }

    let storage = StaticSignalAnalyzerNRFApplicationStorage(
        assemblyReport: report,
        inputSourceRawValue: 51
    )
    switch consume storage {
    case nil:
        break
    case .some:
        Issue.record("Static nRF storage accepted another target report")
    }
}

@Test func staticNRFAddressStableOwnerBindsDispatchesAndDetachesRoot() {
    guard case .valid(let report) = StaticSignalAnalyzerNRFAssembly.validate(),
        var storage = StaticSignalAnalyzerNRFApplicationStorage(
            assemblyReport: report,
            inputSourceRawValue: 51
        )
    else {
        Issue.record("Static nRF application storage did not construct")
        return
    }
    let revision = PresentationRevision(rawValue: 27)
    let repositoryProbe = StaticNRFApplicationStorageRepositoryProbe()

    storage.withAddressStableOwner { owner in
        do {
            let repository = StaticNRFApplicationStorageRepository(
                probe: repositoryProbe
            )
            #expect(
                owner.bindRoot(repository: repository)
                    == .bound(ObservableTargetGeneration(rawValue: 0))
            )
        }
        #expect(!repositoryProbe.repositoryWasReleased)
        let rootIsActive = owner.rootIsActive
        #expect(rootIsActive)
        owner.withModel { model in
            model.startTapped()
            model.stopTapped()
            model.clearTapped()
        }
        #expect(repositoryProbe.startCount == 1)
        #expect(repositoryProbe.stopCount == 1)
        #expect(repositoryProbe.clearCount == 1)

        owner.withInteraction { interaction in
            #expect(
                interaction.beginCandidate(
                    limits: InteractionLimits(maximumActions: 6, maximumHitRegions: 6)!
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
                    targetGeneration: ObservableTargetGeneration(rawValue: 0)
                ) == .requiresGeneration
            )
            #expect(
                interaction.assignGeneration(ActionGeneration(rawValue: 8), to: 4)
                    == nil
            )
            #expect(interaction.finishCandidate() == nil)
            interaction.resolveCandidate(.commit(revision))
        }

        owner.installPhysicalPresentation(rawValue: revision.rawValue)
        for phase in [PointerPhase.down, .up] {
            #expect(
                owner.admit(
                    phaseRawValue: phase.rawValue,
                    x: 4,
                    y: 4,
                    observedPresentationRevisionRawValue: revision.rawValue,
                    priorPhysicalSequenceIsCompleteRawValue: 0
                )?.disposition == .queued
            )
        }
        #expect(
            owner.runInputOpportunity()
                == .completed(
                    StaticSignalAnalyzerNRFInputDrainSummary(
                        eventCount: 2,
                        dispatchedActionCount: 1,
                        cancelledOrRejectedCount: 0
                    )
                )
        )
        #expect(owner.withModel { $0.state.visibleWindow } == .oneSecond)
        let rootIsDirty = owner.rootIsDirty
        #expect(rootIsDirty)
    }

    let rootIsActiveAfterScope = storage.root.isActive
    #expect(!rootIsActiveAfterScope)
    #expect(storage.root.withModel { _ in true } == nil)
    #expect(storage.input.pendingCount == 0)
    #expect(repositoryProbe.repositoryWasReleased)
}

private extension RuntimeProfileValidationResult {
    var audit: RuntimeStorageAudit? {
        guard case .valid(let audit) = self else { return nil }
        return audit
    }
}
