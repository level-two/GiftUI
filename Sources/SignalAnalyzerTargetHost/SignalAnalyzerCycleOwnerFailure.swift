import GiftUIRuntimeCore
import SignalAnalyzerPresentation

/// Finite application specialization of the shared cycle failure carrier.
package enum SignalAnalyzerCycleOwnerFailure: Equatable, Sendable {
    case runtime(RuntimeOwnerFailure)
    case application(SignalAnalyzerRuntimeCondition)
}
