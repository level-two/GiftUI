import GiftUI
import GiftUIObservableState

/// Caller-owned before activation. Neither the model buffer nor its ledger moves
/// while withLifetime is executing; the activation scope cannot escape that call.
package struct StaticObservableModelStorage<Model: ~Copyable, Schema>: ~Copyable {
    private var ownership: ObservableModelOwnership
    private var models: InlineArray<2, Model?> = .init { _ in nil }
    private let schema: UInt16
    private let needsCapture: Bool

    package init?(identity: ObservableModelOwnerIdentity, schema: UInt16, needsCapture: Bool) {
        guard
            let ownership = ObservableModelOwnership(
                identity: identity, captureLimit: needsCapture ? 1 : 0)
        else { return nil }
        self.ownership = consume ownership
        self.schema = schema
        self.needsCapture = needsCapture
    }

    package mutating func withLifetime<Result>(
        _ body: (borrowing ObservableModelScope<Model, Schema>) throws(ObservableStateError) ->
            Result
    ) throws(ObservableStateError) -> Result {
        var modelSpan = models.mutableSpan
        return try withObservableModelScope(
            ownership: &ownership, models: &modelSpan,
            schema: schema, needsCapture: needsCapture, body)
    }
}
