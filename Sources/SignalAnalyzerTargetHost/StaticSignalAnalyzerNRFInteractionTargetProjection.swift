import GiftUI
import GiftUIExecution
import GiftUIObservableState

/// A scoped projection of the already registered generated root target.
/// Registration/materialization remains owned by the model's enclosing borrow.
package struct StaticSignalAnalyzerNRFInteractionTargetProjection:
    ObservableStateReconciler, ObservableStateTargetView
{
    package typealias StructuralIdentity = UInt32
    private let generation: ObservableTargetGeneration
    private var candidateActive = true

    package init(generation: ObservableTargetGeneration) { self.generation = generation }

    package mutating func beginCandidate() -> ObservableStateResult {
        guard !candidateActive else { return .failure(.invalidPhaseContained) }
        candidateActive = true
        return .success(.candidateStarted)
    }

    package mutating func encounter<Model: _GiftUIObservableReference>(
        structuralIdentity: UInt32, declarationOrdinal: UInt16, state: inout State<Model>
    ) -> ObservableStateResult {
        // This projection does not own a model or materialize State values.
        .failure(.incompatibleAssociation)
    }

    package mutating func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> ObservableStateResult {
        guard candidateActive else { return .failure(.invalidPhaseContained) }
        candidateActive = false
        return .success(disposition == .publish ? .associationsCommitted : .candidateDiscarded)
    }

    package borrowing func targetGeneration(
        structuralIdentity: UInt32, declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        structuralIdentity == 0 && declarationOrdinal == 0 ? generation : nil
    }

    package borrowing func publishableTargetGeneration(
        structuralIdentity: UInt32, declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        candidateActive
            ? targetGeneration(
                structuralIdentity: structuralIdentity,
                declarationOrdinal: declarationOrdinal) : nil
    }
}
