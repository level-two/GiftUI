import GiftUIExecution
import GiftUIInteraction

package protocol RuntimeMutationApplication {
    associatedtype StateChange: Sendable
    associatedtype Completion: Sendable

    mutating func apply(stateChange: borrowing StateChange)
    mutating func apply(completion: borrowing Completion)
}

package struct RuntimeInteractionMutationOwner<Application, Dispatcher>:
    ExecutionMutationOwner
where
    Application: RuntimeMutationApplication,
    Dispatcher: InteractionDispatcher
{
    package typealias StateChange = Application.StateChange
    package typealias Completion = Application.Completion
    package typealias ActionIdentity = Dispatcher.Identity

    package private(set) var application: Application
    package private(set) var dispatcher: Dispatcher
    package private(set) var firstDispatchFailure: InteractionError?

    package init(application: Application, dispatcher: Dispatcher) {
        self.application = application
        self.dispatcher = dispatcher
    }

    package mutating func apply(stateChange: borrowing StateChange) {
        application.apply(stateChange: stateChange)
    }

    package mutating func apply(completion: borrowing Completion) {
        application.apply(completion: completion)
    }

    package mutating func dispatch(
        _ captured: borrowing CapturedAction<ActionIdentity>
    ) {
        switch dispatcher.dispatch(copy captured) {
        case .dispatched:
            break
        case .cancelled:
            break
        case .failure(let failure):
            if firstDispatchFailure == nil {
                firstDispatchFailure = failure
            }
        }
    }
}
