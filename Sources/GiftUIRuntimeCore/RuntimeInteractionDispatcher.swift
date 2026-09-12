import GiftUI
import GiftUIExecution
import GiftUIInteraction

package struct RuntimeInteractionDispatcher<Records, Handler, TargetAccess>:
    InteractionDispatcher
where
    Records: InteractionCommittedActionView,
    Handler: GiftUIActionHandler,
    TargetAccess: ActionModelTargetAccess,
    TargetAccess.Model == Handler.Model
{
    package typealias Identity = Records.Identity

    private let records: Records
    private var handler: Handler
    private var targetAccess: TargetAccess

    package init(
        records: Records,
        handler: Handler,
        targetAccess: TargetAccess
    ) {
        self.records = records
        self.handler = handler
        self.targetAccess = targetAccess
    }

    package mutating func dispatch(
        _ captured: CapturedAction<Records.Identity>
    ) -> InteractionDispatchResult {
        guard let record = records.committedRecord(for: captured.identity),
            record.identity == captured.identity,
            record.generation == captured.generation,
            record.isEnabled,
            targetAccess.currentGeneration() == record.targetGeneration
        else { return .cancelled }

        guard let action = Handler.Action(rawValue: record.action.code),
            action.rawValue == record.action.code
        else { return .failure(.invariantViolation) }

        let invoked = targetAccess.withCurrentModel(
            matching: record.targetGeneration
        ) { model in
            handler.handle(action, model: model)
        }
        return invoked ? .dispatched : .cancelled
    }
}
