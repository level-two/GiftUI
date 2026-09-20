import GiftUI
import GiftUIExecution
import GiftUIObservableState

package struct DynamicObservableStateReconciler<Model, Identity>:
    ObservableStateReconciler, ObservableStateTargetView
where Model: _GiftUIObservableReference, Identity: Equatable & Sendable {
    package typealias StructuralIdentity = Identity

    private let root: DynamicObservableRootAdapter<Model, Identity>

    package init(root: DynamicObservableRootAdapter<Model, Identity>) {
        self.root = root
    }

    package mutating func beginCandidate() -> ObservableStateResult {
        root.beginCandidate()
    }

    package mutating func encounter<EncounteredModel: _GiftUIObservableReference>(
        structuralIdentity: Identity,
        declarationOrdinal: UInt16,
        state: inout State<EncounteredModel>
    ) -> ObservableStateResult {
        guard EncounteredModel.self == Model.self else {
            return .failure(.invariantViolation)
        }
        let root = root

        return withUnsafeMutablePointer(to: &state) { statePointer in
            statePointer.withMemoryRebound(to: State<Model>.self, capacity: 1) {
                modelStatePointer in
                root.encounter(
                    structuralIdentity: structuralIdentity,
                    declarationOrdinal: declarationOrdinal,
                    state: &modelStatePointer.pointee,
                    replacementRoute: { replacement in
                        _ = root.replace(with: replacement)
                    }
                )
            }
        }
    }

    package mutating func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> ObservableStateResult {
        root.finishCandidate(disposition)
    }

    package borrowing func targetGeneration(
        structuralIdentity: Identity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        root.targetGeneration(
            structuralIdentity: structuralIdentity,
            declarationOrdinal: declarationOrdinal
        )
    }

    package borrowing func publishableTargetGeneration(
        structuralIdentity: Identity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        root.publishableTargetGeneration(
            structuralIdentity: structuralIdentity,
            declarationOrdinal: declarationOrdinal
        )
    }
}
