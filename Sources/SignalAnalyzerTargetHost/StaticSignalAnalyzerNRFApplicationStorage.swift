import GiftUI
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeStatic
import SignalAnalyzerDomain
import SignalAnalyzerHost
import SignalAnalyzerPresentation

package enum StaticSignalAnalyzerNRFRootBindingOutcome: Equatable, Sendable {
    case bound(ObservableTargetGeneration)
    case rejected(ObservableStateError)
}

package struct StaticSignalAnalyzerNRFFactApplicationSummary: Equatable, Sendable {
    package let factCount: UInt16
    package let changed: Bool
}

package enum StaticSignalAnalyzerNRFFactApplicationResult: Equatable, Sendable {
    case applied(StaticSignalAnalyzerNRFFactApplicationSummary)
    case rejected(SignalAnalyzerRuntimeCondition)
    case unavailable
}

/// Caller-owned, address-stable storage for the generated Static nRF
/// application join. Construction remains inert and requires the exact
/// validated assembly report.
package struct StaticSignalAnalyzerNRFApplicationStorage: ~Copyable {
    package let assemblyReport: HostAssemblyReport
    package var root: StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>
    package var interaction: StaticInteractionState<UInt32>
    package var input: StaticSignalAnalyzerNRFApplicationInputOwner
    package var factAdmission: StaticSignalAnalyzerHostFactAdmissionStorage

    package init?(
        assemblyReport: HostAssemblyReport,
        inputSourceRawValue: UInt16
    ) {
        let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
        guard StaticSignalAnalyzerNRFAssembly.validate() == .valid(assemblyReport),
            let descriptor = preset.staticRoot,
            let candidateRecords = StaticInteractionCandidateStorage<UInt32>(
                capacity: preset.runtimeLimits.interaction.maximumActions
            ),
            let candidateHitRegions = StaticInteractionHitStorage<UInt32>(
                capacity: preset.runtimeLimits.interaction.maximumHitRegions
            ),
            let candidateCommittedRecords = StaticInteractionCommittedStorage<UInt32>(
                capacity: preset.runtimeLimits.interaction.maximumActions
            ),
            let committedRecords = StaticInteractionCommittedStorage<UInt32>(
                capacity: preset.runtimeLimits.interaction.maximumActions
            ),
            let committedHitRegions = StaticInteractionHitStorage<UInt32>(
                capacity: preset.runtimeLimits.interaction.maximumHitRegions
            )
        else { return nil }

        self.assemblyReport = assemblyReport
        root = StaticObservableRootAdapter(
            structuralIdentity: descriptor.structuralIdentity,
            declarationOrdinal: descriptor.declarationOrdinal
        )
        interaction = StaticInteractionState(
            candidateRecords: candidateRecords,
            candidateHitRegions: candidateHitRegions,
            candidateCommittedRecords: candidateCommittedRecords,
            committedRecords: committedRecords,
            committedHitRegions: committedHitRegions
        )
        input = StaticSignalAnalyzerNRFApplicationInputOwner(
            sourceRawValue: inputSourceRawValue
        )
        factAdmission = StaticSignalAnalyzerHostFactAdmissionStorage()
    }

    /// Lends stable field addresses for one complete application lifetime.
    /// The owner quiesces and detaches the root before this scope returns.
    package mutating func withAddressStableOwner<Result>(
        _ body: (inout StaticSignalAnalyzerNRFApplicationOwner) -> Result
    ) -> Result {
        withUnsafeMutablePointer(to: &root) { root in
            withUnsafeMutablePointer(to: &interaction) { interaction in
                withUnsafeMutablePointer(to: &input) { input in
                    withUnsafeMutablePointer(to: &factAdmission) { factAdmission in
                        var owner = StaticSignalAnalyzerNRFApplicationOwner(
                            root: root,
                            interaction: interaction,
                            input: input,
                            factAdmission: factAdmission
                        )
                        defer { _ = owner.quiesce() }
                        return body(&owner)
                    }
                }
            }
        }
    }
}

/// Scoped application owner over one address-stable Static nRF aggregate.
package struct StaticSignalAnalyzerNRFApplicationOwner: ~Copyable {
    private let root:
        UnsafeMutablePointer<
            StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>
        >
    private let interaction: UnsafeMutablePointer<StaticInteractionState<UInt32>>
    private let input: UnsafeMutablePointer<StaticSignalAnalyzerNRFApplicationInputOwner>
    private let factAdmission: UnsafeMutablePointer<StaticSignalAnalyzerHostFactAdmissionStorage>
    private var admissionAdapter: SignalAnalyzerPresentationAdmissionAdapter?

    fileprivate init(
        root: UnsafeMutablePointer<
            StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>
        >,
        interaction: UnsafeMutablePointer<StaticInteractionState<UInt32>>,
        input: UnsafeMutablePointer<StaticSignalAnalyzerNRFApplicationInputOwner>,
        factAdmission:
            UnsafeMutablePointer<StaticSignalAnalyzerHostFactAdmissionStorage>
    ) {
        self.root = root
        self.interaction = interaction
        self.input = input
        self.factAdmission = factAdmission
        admissionAdapter = nil
    }

    package var rootIsActive: Bool { root.pointee.isActive }
    package var rootIsDirty: Bool { root.pointee.isDirty }
    package var targetGeneration: ObservableTargetGeneration? {
        root.pointee.targetGeneration()
    }
    package var pendingInputCount: UInt16 { input.pointee.pendingCount }

    package mutating func bindRoot(
        repository: any SignalAcquisitionRepository
    ) -> StaticSignalAnalyzerNRFRootBindingOutcome {
        let model = SignalAnalyzerViewModel(
            startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
            stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
            clearCapture: ClearSignalCaptureUseCase(repository: repository)
        )
        guard root.pointee.beginCandidate() == .success(.candidateStarted) else {
            return .rejected(.invariantViolation)
        }
        let encounter = root.pointee.withEncounter(
            state: State(wrappedValue: model),
            replacementRoute: { _ in },
            reportRoute: { [root] attachment in
                root.pointee.acceptReport(attachment)
            },
            body: { _ in () }
        )
        guard case .bound(.success(.materialized), ()) = encounter else {
            _ = root.pointee.finishCandidate(.discard)
            guard case .failure(let failure) = encounter else {
                return .rejected(.invariantViolation)
            }
            return .rejected(failure)
        }
        guard root.pointee.finishCandidate(.publish) == .success(.associationsCommitted),
            let generation = root.pointee.targetGeneration()
        else { return .rejected(.invariantViolation) }
        admissionAdapter = SignalAnalyzerPresentationAdmissionAdapter(
            observeCapture: ObserveSignalCaptureUseCase(repository: repository),
            observeState: ObserveAcquisitionStateUseCase(repository: repository),
            admission: StaticSignalAnalyzerHostFactAdmission(storage: factAdmission),
            failureFactory: DefaultSignalAnalyzerOperationalFailureFactory()
        )
        return .bound(generation)
    }

    package mutating func installRepositoryObservation()
        -> SignalAnalyzerObservationStartOutcome
    {
        let admission = StaticSignalAnalyzerHostFactAdmission(storage: factAdmission)
        guard root.pointee.isActive, let admissionAdapter,
            admission.beginProducer(.bootstrap)
        else { return .rejected(.runtimeUnavailable) }
        defer { admission.endProducer() }
        return admissionAdapter.startObserving()
    }

    package func applyRepositoryFactsAtOpportunity()
        -> StaticSignalAnalyzerNRFFactApplicationResult
    {
        guard root.pointee.isActive else { return .unavailable }
        let admission = StaticSignalAnalyzerHostFactAdmission(storage: factAdmission)
        guard admission.seal() else {
            return .applied(
                StaticSignalAnalyzerNRFFactApplicationSummary(
                    factCount: 0,
                    changed: false
                )
            )
        }

        root.pointee.setExecutionPhase(.mutating)
        defer { root.pointee.setExecutionPhase(.idle) }

        var factCount: UInt16 = 0
        var changed = false
        while let (_, _, fact) = admission.takeNextSealed() {
            let nextCount = factCount.addingReportingOverflow(1)
            guard !nextCount.overflow else { return .unavailable }
            factCount = nextCount.partialValue
            guard
                let application = root.pointee.withModel({ model in
                    model.apply(fact)
                })
            else { return .unavailable }
            switch application {
            case .applied(let factChanged):
                changed = changed || factChanged
            case .rejected(let condition):
                return .rejected(condition)
            }
        }
        return .applied(
            StaticSignalAnalyzerNRFFactApplicationSummary(
                factCount: factCount,
                changed: changed
            )
        )
    }

    package mutating func withInteraction<Result>(
        _ body: (inout StaticInteractionState<UInt32>) -> Result
    ) -> Result {
        body(&interaction.pointee)
    }

    package borrowing func withModel<Result>(
        _ body: (borrowing SignalAnalyzerViewModel) -> Result
    ) -> Result? {
        root.pointee.withModel(body)
    }

    package mutating func installPhysicalPresentation(rawValue: UInt32) {
        input.pointee.installPhysicalPresentation(rawValue: rawValue)
    }

    package mutating func admit(
        phaseRawValue: UInt8,
        x: UInt16,
        y: UInt16,
        observedPresentationRevisionRawValue: UInt32,
        priorPhysicalSequenceIsCompleteRawValue: UInt8
    ) -> StaticSignalAnalyzerNRFInputABIOutcome? {
        input.pointee.admit(
            phaseRawValue: phaseRawValue,
            x: x,
            y: y,
            observedPresentationRevisionRawValue:
                observedPresentationRevisionRawValue,
            priorPhysicalSequenceIsCompleteRawValue:
                priorPhysicalSequenceIsCompleteRawValue
        )
    }

    package mutating func runInputOpportunity()
        -> StaticSignalAnalyzerNRFInputOpportunityResult
    {
        input.pointee.runOpportunity(
            interaction: &interaction.pointee,
            root: &root.pointee
        )
    }

    @discardableResult
    package mutating func quiesce() -> Bool {
        admissionAdapter?.stopObserving()
        admissionAdapter = nil
        let admission = StaticSignalAnalyzerHostFactAdmission(storage: factAdmission)
        admission.quiesce()
        admission.discardAll()
        input.pointee.quiesce()
        guard root.pointee.isActive else { return true }
        guard root.pointee.beginCandidate() == .success(.candidateStarted),
            root.pointee.finishCandidate(.publish) == .success(.associationsCommitted)
        else { return false }
        return !root.pointee.isActive
    }
}
