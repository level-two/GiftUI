import GiftUIRuntimeStatic

package enum StaticSignalAnalyzerNRFSemanticPublicationResult: Equatable, Sendable {
    case published(StaticSignalAnalyzerNRFSemanticRegionHeader)
    case stageRejected
    case publicationRejected
}

/// Stages and atomically publishes the complete generated semantic table
/// before the attempt borrows its layout, Drawing, and render regions.
package enum StaticSignalAnalyzerNRFSemanticPublication {
    package static func publish(
        inputs: inout StaticSignalAnalyzerNRFGeneratedPresentationInputs,
        revision: UInt32,
        profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> StaticSignalAnalyzerNRFSemanticPublicationResult {
        guard inputs.stageGeneratedSemanticCandidate(in: &profile) != nil else {
            return .stageRejected
        }
        guard
            let header = inputs.publishGeneratedSemanticCandidate(
                revision: revision,
                in: &profile
            )
        else { return .publicationRejected }
        return .published(header)
    }
}
