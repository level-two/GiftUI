import GiftUIFailureCore

package enum SignalAnalyzerMandatoryEffect: UInt8, Equatable, Sendable {
    case rejectWithoutOverwrite
    case reservedFailureAttempted
    case detachObservation
    case stopAcquisitionDelivery
    case preserveLastCompleteRevision
    case removePartialCandidate
    case preserveExistingModel
    case markPresentationFailed
    case schedulePacedRetry
    case discardPartialPublication
    case preventNormalCycle
    case requireFreshGraph
    case quiesceAffectedScope
    case quiesceRuntimeHealth
}

package protocol SignalAnalyzerMandatoryEffectSink {
    func apply(_ effect: SignalAnalyzerMandatoryEffect)
}

package struct SignalAnalyzerResidualFailurePolicy: GiftUIResidualFailurePolicy {
    package init() {}

    package mutating func disposition(
        for input: GiftUIResidualPolicyInput<SignalAnalyzerResidualPolicyContext>
    ) -> GiftUIResidualDisposition {
        if input.allowed.contains(.continueOperation),
            input.context == .modelReplacement || input.context == .modelChangeReport
        {
            return .continueOperation
        }
        return .quiesceAffectedScope
    }
}

package enum SignalAnalyzerResidualPolicyContext: UInt8, Equatable, Sendable {
    case observationStart
    case activeDelivery
    case initialModelAttachment
    case modelReplacement
    case modelChangeReport
    case captureFactApplication
}
