import GiftUI
import GiftUIObservableState

package final class DynamicObservableModelStorage<Model: ~Copyable, Schema> {
    private var ownership: ObservableModelOwnership
    private var models: InlineArray<2, Model?> = .init { _ in nil }
    private let schema: UInt16
    private let needsCapture: Bool
    private var activationActive = false

    package init?(
        identity: ObservableModelOwnerIdentity, schema: UInt16, needsCapture: Bool,
        modelLimit: UInt16 = 2, claimLimit: UInt16 = 4, pinLimit: UInt16 = 2,
        captureLimit: UInt16? = nil
    ) {
        guard
            let ownership = ObservableModelOwnership(
                identity: identity, modelLimit: modelLimit, claimLimit: claimLimit,
                pinLimit: pinLimit, captureLimit: captureLimit ?? (needsCapture ? 1 : 0))
        else { return nil }
        self.ownership = consume ownership
        self.schema = schema
        self.needsCapture = needsCapture
    }

    package var storageLayout:
        (
            owner: ObservableModelOwnerIdentity, models: UInt16, claims: UInt16, pins: UInt16,
            captures: UInt16, metadataBytes: Int, modelBytes: Int, pinBytes: Int
        )
    {
        let capacities = ownership.storageCapacities
        return (
            ownership.identity, 2, 4, 2,
            capacities.captures,
            ObservableModelOwnership.metadataStorageBytes + MemoryLayout<UInt16>.size
                + MemoryLayout<Bool>.size + MemoryLayout<Bool>.size,
            MemoryLayout<InlineArray<2, Model?>>.size, ObservableModelOwnership.framePinStorageBytes
        )
    }

    package func withLifetime<Result>(
        _ body: (borrowing ObservableModelScope<Model, Schema>) throws(ObservableStateError) ->
            Result
    ) throws(ObservableStateError) -> Result {
        guard !activationActive else { throw .reentrancyViolation }
        activationActive = true
        defer { activationActive = false }
        var modelSpan = models.mutableSpan
        return try withObservableModelScope(
            ownership: &ownership, models: &modelSpan,
            schema: schema, needsCapture: needsCapture, body)
    }
}
