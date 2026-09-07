import GiftUI
import GiftUIExecution

package protocol ObservableStateReconciler {
    associatedtype StructuralIdentity: Equatable & Sendable

    mutating func beginCandidate() -> ObservableStateResult

    mutating func encounter<Model: _GiftUIObservableReference>(
        structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16,
        state: inout State<Model>
    ) -> ObservableStateResult

    mutating func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> ObservableStateResult
}

package protocol ObservableStateMutationOwner {
    associatedtype StructuralIdentity: Equatable & Sendable

    mutating func replace<Model: _GiftUIObservableReference>(
        structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16,
        with candidate: consuming Model
    ) -> ObservableStateResult

    mutating func acceptReport(
        attachment: _GiftUIObservationAttachment
    ) -> ObservableStateResult
}

package protocol ObservableStateTargetView {
    associatedtype StructuralIdentity: Equatable & Sendable

    borrowing func targetGeneration(
        structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration?

    borrowing func publishableTargetGeneration(
        structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration?
}
