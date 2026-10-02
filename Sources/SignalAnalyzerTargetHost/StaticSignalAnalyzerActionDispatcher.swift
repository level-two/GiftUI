import GiftUIInteraction
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import SignalAnalyzerPresentation

package enum StaticSignalAnalyzerActionDispatcher {
    package static func make<Records, Identity>(
        records: Records,
        root: UnsafeMutablePointer<
            StaticObservableRootAdapter<SignalAnalyzerViewModel, Identity>
        >
    ) -> RuntimeInteractionDispatcher<
        Records,
        SignalAnalyzerActionHandler,
        StaticObservableRootTargetAccess<SignalAnalyzerViewModel, Identity>
    >
    where
        Records: InteractionCommittedActionView,
        Records.Identity == Identity,
        Identity: Equatable & Sendable
    {
        RuntimeInteractionDispatcher(
            records: records,
            handler: SignalAnalyzerActionHandler(),
            targetAccess: StaticObservableRootTargetAccess(root: root)
        )
    }
}
