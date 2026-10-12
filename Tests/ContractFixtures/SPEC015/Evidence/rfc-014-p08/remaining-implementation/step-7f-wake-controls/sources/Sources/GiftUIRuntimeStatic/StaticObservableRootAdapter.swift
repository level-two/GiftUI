import GiftUI
import GiftUIObservableState

/// Caller-owned model and registration storage precede activation. Their
/// independent borrows end only after root retirement has detached every sink.
package struct StaticObservableRootAdapter<
    Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable
>: ~Copyable {
    private var models: StaticObservableModelStorage<Model, Model.Schema>
    private var registration = ObservableStateRootStorage<Identity>()

    package init?(
        identity: ObservableModelOwnerIdentity, schema: UInt16, needsCapture: Bool,
        modelLimit: UInt16 = 2, claimLimit: UInt16 = 4, pinLimit: UInt16 = 2,
        captureLimit: UInt16? = nil
    ) {
        guard
            let models = StaticObservableModelStorage<Model, Model.Schema>(
                identity: identity, schema: schema, needsCapture: needsCapture,
                modelLimit: modelLimit, claimLimit: claimLimit, pinLimit: pinLimit,
                captureLimit: captureLimit)
        else { return nil }
        self.models = consume models
    }

    package var storageLayout:
        (
            owner: ObservableModelOwnerIdentity, models: UInt16, claims: UInt16, pins: UInt16,
            captures: UInt16, metadataBytes: Int, modelBytes: Int, pinBytes: Int, liveBytes: Int,
            candidateBytes: Int
        )
    {
        let layout = models.storageLayout
        let fields =
            layout.metadataBytes + layout.modelBytes + layout.pinBytes
            + ObservableStateRootStorage<Identity>.liveStorageBytes
            + ObservableStateRootStorage<Identity>.candidateStorageBytes
        let padding = MemoryLayout<Self>.size - fields
        return (
            layout.owner, layout.models, layout.claims, layout.pins, layout.captures,
            layout.metadataBytes + padding, layout.modelBytes, layout.pinBytes,
            ObservableStateRootStorage<Identity>.liveStorageBytes,
            ObservableStateRootStorage<Identity>.candidateStorageBytes
        )
    }

    package mutating func withLifetime<Result>(
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
