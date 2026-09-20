import GiftUI
import GiftUIRuntimeStatic
import SignalAnalyzerPresentation

/// Owns the fixed input and pointer-session state while borrowing the
/// generated Static root and interaction storage only for a synchronous drain.
package struct StaticSignalAnalyzerNRFApplicationInputOwner: ~Copyable {
    private var input: StaticSignalAnalyzerNRFInputABI
    private var interactionSession = StaticSignalAnalyzerNRFInteractionSession()

    package init(sourceRawValue: UInt16) {
        input = StaticSignalAnalyzerNRFInputABI(sourceRawValue: sourceRawValue)
    }

    package var pendingCount: UInt16 { input.pendingCount }

    package mutating func installPhysicalPresentation(rawValue: UInt32) {
        input.installPhysicalPresentation(rawValue: rawValue)
        interactionSession.installPhysicalPresentation(
            PresentationRevision(rawValue: rawValue)
        )
    }

    package mutating func admit(
        phaseRawValue: UInt8,
        x: UInt16,
        y: UInt16,
        observedPresentationRevisionRawValue: UInt32,
        priorPhysicalSequenceIsCompleteRawValue: UInt8
    ) -> StaticSignalAnalyzerNRFInputABIOutcome? {
        input.admit(
            phaseRawValue: phaseRawValue,
            x: x,
            y: y,
            observedPresentationRevisionRawValue:
                observedPresentationRevisionRawValue,
            priorPhysicalSequenceIsCompleteRawValue:
                priorPhysicalSequenceIsCompleteRawValue
        )
    }

    package mutating func runOpportunity(
        interaction: inout StaticInteractionState<UInt32>,
        root: inout StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>
    ) -> StaticSignalAnalyzerNRFInputOpportunityResult {
        withUnsafeMutablePointer(to: &interactionSession) { sessionPointer in
            withUnsafeMutablePointer(to: &interaction) { interactionPointer in
                withUnsafeMutablePointer(to: &root) { rootPointer in
                    var handler = StaticSignalAnalyzerNRFInteractionHandler(
                        session: sessionPointer,
                        interaction: interactionPointer,
                        root: rootPointer
                    )
                    return input.runOpportunity(into: &handler)
                }
            }
        }
    }

    package mutating func quiesce() {
        input.quiesce()
        interactionSession.quiesce()
    }
}
