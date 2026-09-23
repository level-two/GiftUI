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
    var captureObservationStartCount = 0
    var captureObservationStopCount = 0
    var stateObservationStartCount = 0
    var stateObservationStopCount = 0
    var repositoryWasReleased = false
}

private final class StaticNRFApplicationStorageRepository:
    SignalAcquisitionRepository
{
    private let probe: StaticNRFApplicationStorageRepositoryProbe
    private var captureSink: (any SignalCaptureSink)?
    private var stateSink: (any AcquisitionStateSink)?

    init(probe: StaticNRFApplicationStorageRepositoryProbe) {
        self.probe = probe
    }

    deinit { probe.repositoryWasReleased = true }

    func startObservingCapture(sink: some SignalCaptureSink) {
        probe.captureObservationStartCount += 1
        captureSink = sink
        _ = sink.receive(.snapshot(revision: 0, capture: .empty()))
    }

    func stopObservingCapture() {
        probe.captureObservationStopCount += 1
        captureSink = nil
    }

    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {
        probe.stateObservationStartCount += 1
        stateSink = sink
        _ = sink.receive(.running)
    }

    func stopObservingAcquisitionState() {
        probe.stateObservationStopCount += 1
        stateSink = nil
    }

    func start() throws {
        probe.startCount += 1
        _ = stateSink?.receive(.running)
    }

    func stop() {
        probe.stopCount += 1
        _ = stateSink?.receive(.stopped)
    }

    func clear() {
        probe.clearCount += 1
        _ = captureSink?.receive(.snapshot(revision: 1, capture: .empty()))
    }
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
    #expect(report.minimumSinkOperationCapacity == 150)
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
        #expect(
            owner.installRepositoryObservation()
                == .started(captureSequence: 1, stateSequence: 2)
        )
        #expect(repositoryProbe.captureObservationStartCount == 1)
        #expect(repositoryProbe.stateObservationStartCount == 1)
        #expect(owner.withModel { $0.state.acquisitionState } == .idle)
        let initialFactApplication = owner.applyRepositoryFactsAtOpportunity()
        guard case .applied(let initialFactSummary) = initialFactApplication else {
            Issue.record("Static repository facts were not applied")
            return
        }
        #expect(initialFactSummary.factCount == 2)
        #expect(initialFactSummary.changed)
        #expect(owner.withModel { $0.state.acquisitionState } == .running)
        let repositoryFactsDirtiedRoot = owner.rootIsDirty
        #expect(repositoryFactsDirtiedRoot)
        let repeatedFactApplication = owner.applyRepositoryFactsAtOpportunity()
        guard case .applied(let repeatedFactSummary) = repeatedFactApplication else {
            Issue.record("Empty Static repository opportunity was unavailable")
            return
        }
        #expect(repeatedFactSummary.factCount == 0)
        #expect(!repeatedFactSummary.changed)
        owner.withInteraction { interaction in
            #expect(
                interaction.beginCandidate(
                    limits: InteractionLimits(maximumActions: 6, maximumHitRegions: 6)!
                ) == nil
            )
            let actions: [(UInt32, UInt16, SignalAnalyzerAction)] = [
                (4, 0, .start),
                (5, 8, .stop),
                (6, 16, .clear),
            ]
            var paintOrder: UInt16 = 0
            for (identity, x, action) in actions {
                #expect(
                    interaction.append(
                        identity: identity,
                        isEnabled: true,
                        bounds: Rect(
                            origin: Point(x: Int32(x), y: 0),
                            size: Size(width: 8, height: 8)!
                        )!,
                        clip: Rect(
                            origin: Point(x: Int32(x), y: 0),
                            size: Size(width: 8, height: 8)!
                        )!,
                        paintOrder: paintOrder,
                        action: BoundedApplicationAction(code: action.rawValue),
                        targetGeneration: ObservableTargetGeneration(rawValue: 0)
                    ) == .requiresGeneration
                )
                #expect(
                    interaction.assignGeneration(
                        ActionGeneration(rawValue: identity + 4),
                        to: identity
                    ) == nil
                )
                paintOrder += 1
            }
            #expect(interaction.finishCandidate() == nil)
            interaction.resolveCandidate(.commit(revision))
        }

        owner.installPhysicalPresentation(rawValue: revision.rawValue)
        for x in [UInt16(4), 12, 20] {
            for phase in [PointerPhase.down, .up] {
                #expect(
                    owner.admit(
                        phaseRawValue: phase.rawValue,
                        x: x,
                        y: 4,
                        observedPresentationRevisionRawValue: revision.rawValue,
                        priorPhysicalSequenceIsCompleteRawValue: 0
                    )?.disposition == .queued
                )
            }
        }
        let actionOpportunity = owner.runApplicationOpportunity()
        guard case .completed(let actionSummary) = actionOpportunity else {
            Issue.record("Static action opportunity did not complete")
            return
        }
        #expect(actionSummary.application.factCount == 0)
        #expect(!actionSummary.application.changed)
        #expect(
            actionSummary.input
                == StaticSignalAnalyzerNRFInputDrainSummary(
                    eventCount: 6,
                    dispatchedActionCount: 3,
                    cancelledOrRejectedCount: 0
                )
        )
        #expect(repositoryProbe.startCount == 1)
        #expect(repositoryProbe.stopCount == 1)
        #expect(repositoryProbe.clearCount == 1)
        #expect(owner.withModel { $0.state.acquisitionState } == .running)
        #expect(owner.withModel { $0.captureRevision } == 0)
        let actionFactOpportunity = owner.runApplicationOpportunity()
        guard case .completed(let actionFactSummary) = actionFactOpportunity else {
            Issue.record("Static action-produced facts were not applied")
            return
        }
        #expect(actionFactSummary.application.factCount == 3)
        #expect(actionFactSummary.application.changed)
        #expect(actionFactSummary.input.eventCount == 0)
        #expect(owner.withModel { $0.state.acquisitionState } == .stopped)
        #expect(owner.withModel { $0.captureRevision } == 1)
        let rootIsDirty = owner.rootIsDirty
        #expect(rootIsDirty)
    }

    let rootIsActiveAfterScope = storage.root.isActive
    #expect(!rootIsActiveAfterScope)
    #expect(storage.root.withModel { _ in true } == nil)
    #expect(storage.input.pendingCount == 0)
    #expect(repositoryProbe.captureObservationStopCount == 1)
    #expect(repositoryProbe.stateObservationStopCount == 1)
    #expect(repositoryProbe.repositoryWasReleased)
}

private extension RuntimeProfileValidationResult {
    var audit: RuntimeStorageAudit? {
        guard case .valid(let audit) = self else { return nil }
        return audit
    }
}
