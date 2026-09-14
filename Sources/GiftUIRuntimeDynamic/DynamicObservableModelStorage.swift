import GiftUI
import GiftUIObservableState

package final class DynamicObservableModelStorage<Model>
where Model: _GiftUIObservableReference {
    private var model: Model?

    package init() {}

    package var isOccupied: Bool {
        model != nil
    }

    package func bind(
        _ state: inout State<Model>,
        replacementRoute: @escaping (Model) -> Void
    ) -> ObservableStateResult {
        let initializer = state._giftUIBind(
            read: { [unowned self] in
                guard let model = self.model else {
                    fatalError("observable model read before materialization")
                }
                return model
            },
            replace: replacementRoute
        )
        guard let initializer else {
            return .failure(.invariantViolation)
        }

        if model == nil {
            model = initializer
            return .success(.materialized)
        }
        return .success(.preserved)
    }

    package borrowing func withModel<Result>(
        _ body: (borrowing Model) -> Result
    ) -> Result? {
        guard let model else { return nil }
        return body(model)
    }

    package func withMutableModel<Result>(
        _ body: (inout Model) -> Result
    ) -> Result? {
        guard model != nil else { return nil }
        return body(&model!)
    }

    package func attachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        guard model != nil else { return nil }
        return model!._giftUIAttachChangeSink(consume sink)
    }

    package func detachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) -> Bool {
        guard model != nil else { return false }
        model!._giftUIDetachChangeSink(attachment)
        return true
    }

    @discardableResult
    package func removeModel() -> Model? {
        defer { model = nil }
        return model
    }
}
