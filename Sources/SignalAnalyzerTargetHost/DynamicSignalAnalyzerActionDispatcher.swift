import GiftUIInteraction
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import SignalAnalyzerPresentation

package enum DynamicSignalAnalyzerActionDispatcher {
    package static func make<Records, Identity>(
        records: Records,
        root: DynamicObservableRootAdapter<SignalAnalyzerViewModel, Identity>
    ) -> RuntimeInteractionDispatcher<
        Records,
        SignalAnalyzerActionHandler,
        DynamicObservableRootTargetAccess<SignalAnalyzerViewModel, Identity>
    >
    where
        Records: InteractionCommittedActionView,
        Records.Identity == Identity,
        Identity: Equatable & Sendable
    {
        RuntimeInteractionDispatcher(
            records: records,
            handler: SignalAnalyzerActionHandler(),
            targetAccess: DynamicObservableRootTargetAccess(root: root)
        )
    }
}
