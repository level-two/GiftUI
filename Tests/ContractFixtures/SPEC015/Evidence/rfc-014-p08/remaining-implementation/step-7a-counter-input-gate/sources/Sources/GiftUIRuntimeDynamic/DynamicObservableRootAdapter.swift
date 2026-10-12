import GiftUI
import GiftUIObservableState

/// Retains actual typed backing for the entire activation. Host assembly issues
/// the identity from its longer-lived namespace; this adapter never resets it.
package final class DynamicObservableRootAdapter<
    Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable
> {
    private let models: DynamicObservableModelStorage<Model, Model.Schema>
    private var registration = DynamicObservableModelRegistration<Identity>()

    package init?(
        identity: ObservableModelOwnerIdentity, schema: UInt16, needsCapture: Bool,
        modelLimit: UInt16 = 2, claimLimit: UInt16 = 4, pinLimit: UInt16 = 2,
        captureLimit: UInt16? = nil
    ) {
        guard
            let models = DynamicObservableModelStorage<Model, Model.Schema>(
                identity: identity, schema: schema, needsCapture: needsCapture,
                modelLimit: modelLimit, claimLimit: claimLimit, pinLimit: pinLimit,
                captureLimit: captureLimit)
        else { return nil }
        self.models = models
    }

    package var storageLayout:
        (
            owner: ObservableModelOwnerIdentity, models: UInt16, claims: UInt16, pins: UInt16,
            captures: UInt16, metadataBytes: Int, modelBytes: Int, pinBytes: Int, liveBytes: Int,
            candidateBytes: Int
        )
    {
        let layout = models.storageLayout
        return (
            layout.owner, layout.models, layout.claims, layout.pins, layout.captures,
            layout.metadataBytes
                + MemoryLayout<DynamicObservableModelStorage<Model, Model.Schema>>.size,
            layout.modelBytes, layout.pinBytes,
            ObservableStateRootStorage<Identity>.liveStorageBytes,
            ObservableStateRootStorage<Identity>.candidateStorageBytes
        )
    }

    package func withLifetime<Result>(
        limits: ObservableStateLimits = .init(
            maximumLocations: 2, maximumRegistrations: 2, maximumStagedAssociations: 2)!,
        _ body: (
            borrowing ObservableModelScope<Model, Model.Schema>,
            borrowing ObservableStateRootScope<Model, Identity>
        ) throws(ObservableStateError) -> Result
    ) throws(ObservableStateError) -> Result {
        try models.withLifetime { (scope) throws(ObservableStateError) in
            try scope.withRoot(storage: &registration, limits: limits) {
                (root) throws(ObservableStateError) in
                try body(scope, root)
            }
        }
    }
}
