import GiftUI
import GiftUIObservableState

package enum StaticObservableModelBindingOutcome<Result> {
    case bound(ObservableStateOperational, Result)
    case failure(ObservableStateError)
}

package struct StaticObservableModelStorage<Model>: ~Copyable
where Model: _GiftUIObservableReference {
    private var model: Model?

    package init() {
        model = nil
    }

    package var isOccupied: Bool {
        model != nil
    }

    package mutating func withBoundState<Result>(
        _ state: State<Model>,
        replacementRoute: @escaping (Model) -> Void,
        body: (borrowing State<Model>) -> Result
    ) -> StaticObservableModelBindingOutcome<Result> {
        withUnsafeMutablePointer(to: &model) { modelPointer in
            var transientState = state
            let initializer = transientState._giftUIBind(
                read: {
                    guard let model = modelPointer.pointee else {
                        fatalError("observable model read before materialization")
                    }
                    return model
                },
                replace: replacementRoute
            )
            guard let initializer else {
                return .failure(.invariantViolation)
            }

            let operation: ObservableStateOperational
            if modelPointer.pointee == nil {
                modelPointer.pointee = initializer
                operation = .materialized
            } else {
                operation = .preserved
            }
            return .bound(operation, body(transientState))
        }
    }

    package borrowing func withModel<Result>(
        _ body: (borrowing Model) -> Result
    ) -> Result? {
        guard let model else { return nil }
        return body(model)
    }

    package mutating func attachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        guard model != nil else { return nil }
        return model!._giftUIAttachChangeSink(consume sink)
    }

    package mutating func detachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) -> Bool {
        guard model != nil else { return false }
        model!._giftUIDetachChangeSink(attachment)
        return true
    }

    @discardableResult
    package mutating func removeModel() -> Model? {
        defer { model = nil }
        return model
    }
}
