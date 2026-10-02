import GiftUIFailureCore
import SignalAnalyzerDomain
import SignalAnalyzerHost
import SignalAnalyzerPresentation

package protocol DynamicSignalAnalyzerApplicationFailureHandling: AnyObject {
    var isAvailable: Bool { get }
    var terminalCondition: SignalAnalyzerRuntimeCondition? { get }
    var lastFailureFact: GiftUIFailureFact? { get }
    func handle(_ condition: SignalAnalyzerRuntimeCondition) -> Bool
}

private final class DynamicSignalAnalyzerApplicationFailureEffects:
    SignalAnalyzerMandatoryEffectSink
{
    private let model: SignalAnalyzerViewModel
    private let stop: StopSignalAcquisitionUseCase
    private let admission: DynamicSignalAnalyzerHostFactAdmission
    weak var observation: SignalAnalyzerPresentationAdmissionAdapter?
    var pendingFailure: SignalAnalyzerOperationalFailure?
    var isHandlingRuntime = false
    private(set) var requiresFreshGraph = false
    private(set) var completedEffects: UInt16 = 0

    init(
        model: SignalAnalyzerViewModel, stop: StopSignalAcquisitionUseCase,
        admission: DynamicSignalAnalyzerHostFactAdmission
    ) {
        self.model = model
        self.stop = stop
        self.admission = admission
    }

    func apply(_ effect: SignalAnalyzerMandatoryEffect) {
        completedEffects |= UInt16(1) << effect.rawValue
        switch effect {
        case .detachObservation: observation?.stopObserving()
        case .stopAcquisitionDelivery: stop.execute()
        case .markPresentationFailed:
            if let pendingFailure { _ = model.apply(.operationalFailure(pendingFailure)) }
        case .requireFreshGraph, .preventNormalCycle, .quiesceRuntimeHealth:
            requiresFreshGraph = true
            admission.quiesce()
        case .quiesceAffectedScope:
            if isHandlingRuntime || requiresFreshGraph {
                requiresFreshGraph = true
                admission.quiesce()
            }
        case .rejectWithoutOverwrite, .reservedFailureAttempted, .preserveLastCompleteRevision,
            .removePartialCandidate, .preserveExistingModel, .schedulePacedRetry,
            .discardPartialPublication:
            // Admission and common-runner containment have already performed these effects.
            break
        }
    }
}

/// Installed by the production lifecycle owner. Calls remain synchronous inside
/// the owned opportunity and use the root's mutation phase for failed-model state.
package final class DynamicSignalAnalyzerApplicationFailureOwner:
    DynamicSignalAnalyzerApplicationFailureHandling, SignalAnalyzerOperationalFailureFactory
{
    package private(set) var terminalCondition: SignalAnalyzerRuntimeCondition?
    package private(set) var lastFailureFact: GiftUIFailureFact?
    private let effects: DynamicSignalAnalyzerApplicationFailureEffects
    private let adapter:
        SignalAnalyzerOwnerFailureAdapter<DynamicSignalAnalyzerApplicationFailureEffects>

    package init(
        model: SignalAnalyzerViewModel, stop: StopSignalAcquisitionUseCase,
        admission: DynamicSignalAnalyzerHostFactAdmission
    ) {
        let effects = DynamicSignalAnalyzerApplicationFailureEffects(
            model: model, stop: stop, admission: admission)
        self.effects = effects
        adapter = SignalAnalyzerOwnerFailureAdapter(effects: effects, stopAcquisition: stop)
    }

    package var isAvailable: Bool { !effects.requiresFreshGraph }
    package var policyCallCount: UInt8 { adapter.policyCallCount }
    package var lastDisposition: GiftUIResidualDisposition? { adapter.lastDisposition }
    package var completedEffects: UInt16 { effects.completedEffects }
    package var factory: any SignalAnalyzerOperationalFailureFactory { self }

    package func failure(
        for rejection: SignalSinkDeliveryRejection,
        context: SignalAnalyzerResidualPolicyContext
    ) -> SignalAnalyzerOperationalFailure {
        let failure = adapter.failure(for: rejection, context: context)
        lastFailureFact = failure.failure
        return failure
    }

    package func failure(
        for condition: SignalAnalyzerRepositoryCondition,
        diagnostic: SignalAnalyzerDiagnostic
    ) -> SignalAnalyzerOperationalFailure {
        let failure = adapter.failure(for: condition, diagnostic: diagnostic)
        lastFailureFact = failure.failure
        return failure
    }

    package func completeAdmissionFailure(
        _ failure: SignalAnalyzerOperationalFailure,
        rejection: SignalSinkDeliveryRejection, context: SignalAnalyzerResidualPolicyContext,
        reservedOutcome: SignalSinkDeliveryOutcome
    ) {
        adapter.completeAdmissionFailure(
            failure, rejection: rejection, context: context, reservedOutcome: reservedOutcome)
        if case .rejected = reservedOutcome {
            terminalCondition = .reservedFailureCapacityExhausted
            lastFailureFact = SignalAnalyzerRuntimeFailureNormalizer.fact(
                for: .reservedFailureCapacityExhausted,
                stableStateProven: false)
        }
    }

    package func completeRepositoryFailure(
        _ failure: SignalAnalyzerOperationalFailure,
        condition: SignalAnalyzerRepositoryCondition, reservedOutcome: SignalSinkDeliveryOutcome
    ) {
        adapter.completeRepositoryFailure(
            failure, condition: condition, reservedOutcome: reservedOutcome)
    }

    package func installObservation(_ observation: SignalAnalyzerPresentationAdmissionAdapter) {
        effects.observation = observation
    }

    package func handle(_ condition: SignalAnalyzerRuntimeCondition) -> Bool {
        let diagnostic = SignalAnalyzerDiagnostic(exactUTF8: [])!
        effects.isHandlingRuntime = true
        defer { effects.isHandlingRuntime = false }
        effects.pendingFailure = SignalAnalyzerFailureNormalizer.operationalFailure(
            for: condition, stableStateProven: false, diagnostic: diagnostic)
        lastFailureFact = effects.pendingFailure?.failure
        _ = adapter.handleRuntimeFailure(
            condition, context: .activeDelivery, stableStateProven: false,
            existingLiveModel: true, diagnostic: diagnostic)
        effects.pendingFailure = nil
        return effects.requiresFreshGraph || adapter.lastDisposition == .quiesceAffectedScope
    }
}
