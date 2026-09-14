import GiftUI
import GiftUIObservableState

package enum StaticObservableModelBindingOutcome<Result> {
    case bound(ObservableStateOperational, Result)
    case failure(ObservableStateError)
}

package struct StaticObservableModelStorage<Model>: ~Copyable
where Model: _GiftUIObservableReference {
    private var model: Model?
    private var candidate: Model?

    package init() {
        model = nil
        candidate = nil
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

    package mutating func withMaterializedBoundState<Result>(
        _ state: State<Model>,
        replacementRoute: @escaping (Model) -> Void,
        makeSink: () -> _GiftUIObservableChangeSink?,
        acceptAttachment: (_GiftUIObservationAttachment?) -> ObservableStateError?,
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
            guard let initializer, modelPointer.pointee == nil else {
                return .failure(.invariantViolation)
            }
            guard let sink = makeSink() else {
                return .failure(.invariantViolation)
            }

            let expectedAttachment = sink.attachment
            modelPointer.pointee = initializer
            let returned = modelPointer.pointee!._giftUIAttachChangeSink(
                consume sink
            )
            if let failure = acceptAttachment(returned) {
                if returned != nil {
                    modelPointer.pointee!._giftUIDetachChangeSink(
                        expectedAttachment
                    )
                }
                modelPointer.pointee = nil
                return .failure(failure)
            }
            return .bound(.materialized, body(transientState))
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

    package var hasStagedReplacement: Bool {
        candidate != nil
    }

    package mutating func stageReplacement(
        _ replacement: consuming Model
    ) -> Bool {
        guard candidate == nil else { return false }
        candidate = replacement
        return true
    }

    package mutating func attachCandidateChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        guard candidate != nil else { return nil }
        return candidate!._giftUIAttachChangeSink(consume sink)
    }

    package mutating func detachCandidateChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) -> Bool {
        guard candidate != nil else { return false }
        candidate!._giftUIDetachChangeSink(attachment)
        return true
    }

    package mutating func commitReplacement() -> Model? {
        guard let candidate else { return nil }
        let former = model
        model = candidate
        self.candidate = nil
        return former
    }

    @discardableResult
    package mutating func discardReplacement() -> Model? {
        defer { candidate = nil }
        return candidate
    }
}
