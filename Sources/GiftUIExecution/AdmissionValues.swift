import GiftUI

package enum AdmissionKind: UInt8, Equatable, Sendable {
    case pointer = 0
    case stateChange = 1
    case completion = 2
    case semanticAction = 3
    case dirtyRederivation = 4
    case presentationRecovery = 5
}

package enum ExecutionAdmissionResult: UInt8, Equatable, Sendable {
    case queued = 0
    case capacityRefused = 1
    case unavailable = 2
    case invalidValue = 3
    case invalidProvenance = 4
}

package struct ExecutionAdmissionOutcome: Equatable, Sendable {
    package let result: ExecutionAdmissionResult
    package let context: ExecutionContext

    package init(
        result: ExecutionAdmissionResult,
        context: ExecutionContext
    ) {
        self.result = result
        self.context = context
    }
}

package protocol ExecutionAdmissionSink {
    associatedtype StateChangeFact: Sendable
    associatedtype CompletionFact: Sendable

    mutating func submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome
    mutating func submit(stateChange: StateChangeFact) -> ExecutionAdmissionOutcome
    mutating func submit(completion: CompletionFact) -> ExecutionAdmissionOutcome
}

package struct AdmissionSummary: Equatable, Sendable {
    package let inputEventCount: UInt16
    package let stateChangeFactCount: UInt16
    package let completionFactCount: UInt16
    package let semanticActionCount: UInt16
    package let includesDirtyRederivation: Bool
    package let includesPresentationRecovery: Bool

    package init?(
        inputEventCount: UInt16,
        stateChangeFactCount: UInt16,
        completionFactCount: UInt16,
        semanticActionCount: UInt16,
        includesDirtyRederivation: Bool,
        includesPresentationRecovery: Bool,
        limits: ExecutionLimits
    ) {
        guard inputEventCount <= limits.maximumInputEvents,
            stateChangeFactCount <= limits.maximumStateChangeFacts,
            completionFactCount <= limits.maximumCompletionFacts,
            semanticActionCount <= limits.maximumSemanticActions,
            semanticActionCount <= inputEventCount
        else { return nil }

        self.inputEventCount = inputEventCount
        self.stateChangeFactCount = stateChangeFactCount
        self.completionFactCount = completionFactCount
        self.semanticActionCount = semanticActionCount
        self.includesDirtyRederivation = includesDirtyRederivation
        self.includesPresentationRecovery = includesPresentationRecovery
    }
}

package protocol ExecutionActionView {
    associatedtype Identity: Equatable, Sendable

    func generation(for identity: Identity) -> ActionGeneration?
    func isEnabled(_ identity: Identity) -> Bool?
    func hit(at point: Point) -> Identity?
}

package struct CapturedAction<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    package let identity: Identity
    package let generation: ActionGeneration

    package init(identity: Identity, generation: ActionGeneration) {
        self.identity = identity
        self.generation = generation
    }
}
