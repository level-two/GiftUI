import GiftUIExecution

package protocol PresentationFactAdmissionAdapter {
    associatedtype Fact: Sendable

    mutating func submit(_ fact: Fact) -> ExecutionAdmissionOutcome
}
