@usableFromInline
package enum RuntimeCoordinatorStage: UInt8, Equatable, Sendable {
    case observableBindingOrSemanticExpansion = 0
    case layout = 1
    case canvasInvocationOrPlan = 2
    case combinedRenderPreflight = 3
    case interactionBuildOrGeneration = 4
    case offerProductionOrEndpoint = 5
    case acceptedOffer = 6
}

@usableFromInline
package enum RuntimeCleanupAction: UInt8, Equatable, Sendable {
    case releaseCanvasCallable = 0
    case discardInteractionCandidate = 1
    case commitInteractionCandidate = 2
    case resetRenderWorkspace = 3
    case resetDrawingPlan = 4
    case resetLayoutCandidate = 5
    case discardSemanticCandidate = 6
    case discardObservableCandidate = 7
    case resetAttemptStorage = 8
}

@usableFromInline
package struct RuntimeCleanupActions: OptionSet, Equatable, Sendable {
    @usableFromInline
    package let rawValue: UInt16

    @usableFromInline
    package init(rawValue: UInt16) {
        self.rawValue = rawValue & 0x01FF
    }

    @usableFromInline
    package static let releaseCanvasCallable = action(.releaseCanvasCallable)
    @usableFromInline
    package static let discardInteractionCandidate = action(.discardInteractionCandidate)
    @usableFromInline
    package static let commitInteractionCandidate = action(.commitInteractionCandidate)
    @usableFromInline
    package static let resetRenderWorkspace = action(.resetRenderWorkspace)
    @usableFromInline
    package static let resetDrawingPlan = action(.resetDrawingPlan)
    @usableFromInline
    package static let resetLayoutCandidate = action(.resetLayoutCandidate)
    @usableFromInline
    package static let discardSemanticCandidate = action(.discardSemanticCandidate)
    @usableFromInline
    package static let discardObservableCandidate = action(.discardObservableCandidate)
    @usableFromInline
    package static let resetAttemptStorage = action(.resetAttemptStorage)

    private static func action(_ action: RuntimeCleanupAction) -> Self {
        Self(rawValue: 1 << action.rawValue)
    }

    package func contains(_ action: RuntimeCleanupAction) -> Bool {
        contains(Self.action(action))
    }

}

@usableFromInline
package struct RuntimeCleanupPlan: Equatable, Sendable {
    package let stage: RuntimeCoordinatorStage
    package let actions: RuntimeCleanupActions
    package let laterFallibleWorkIsPermitted: Bool
}

@usableFromInline
package enum RuntimeCoordinatorCleanupOracle {
    @usableFromInline
    package static func plan(
        after stage: RuntimeCoordinatorStage
    ) -> RuntimeCleanupPlan {
        let actions: RuntimeCleanupActions =
            switch stage {
            case .observableBindingOrSemanticExpansion:
                [
                    .releaseCanvasCallable,
                    .discardSemanticCandidate,
                    .discardObservableCandidate,
                    .resetAttemptStorage,
                ]
            case .layout:
                [
                    .resetLayoutCandidate,
                    .discardSemanticCandidate,
                    .discardObservableCandidate,
                    .resetAttemptStorage,
                ]
            case .canvasInvocationOrPlan:
                [
                    .releaseCanvasCallable,
                    .resetDrawingPlan,
                    .resetLayoutCandidate,
                    .discardSemanticCandidate,
                    .discardObservableCandidate,
                    .resetAttemptStorage,
                ]
            case .combinedRenderPreflight:
                [
                    .resetRenderWorkspace,
                    .resetDrawingPlan,
                    .resetLayoutCandidate,
                    .discardSemanticCandidate,
                    .discardObservableCandidate,
                    .resetAttemptStorage,
                ]
            case .interactionBuildOrGeneration:
                [
                    .discardInteractionCandidate,
                    .resetRenderWorkspace,
                    .resetDrawingPlan,
                    .resetLayoutCandidate,
                    .discardSemanticCandidate,
                    .discardObservableCandidate,
                    .resetAttemptStorage,
                ]
            case .offerProductionOrEndpoint:
                [
                    .discardInteractionCandidate,
                    .resetRenderWorkspace,
                    .resetDrawingPlan,
                    .resetAttemptStorage,
                ]
            case .acceptedOffer:
                [.commitInteractionCandidate, .resetAttemptStorage]
            }
        return RuntimeCleanupPlan(
            stage: stage,
            actions: actions,
            laterFallibleWorkIsPermitted: false
        )
    }
}

@usableFromInline
package struct RuntimeCleanupTracker: Equatable, Sendable {
    private var outstanding: RuntimeCleanupActions

    @usableFromInline
    package init(plan: RuntimeCleanupPlan, acquired: RuntimeCleanupActions) {
        outstanding = plan.actions.intersection(acquired)
    }

    package var isComplete: Bool {
        outstanding.isEmpty
    }

    @usableFromInline
    package mutating func takeNext() -> RuntimeCleanupAction? {
        if take(.releaseCanvasCallable) { return .releaseCanvasCallable }
        if take(.discardInteractionCandidate) { return .discardInteractionCandidate }
        if take(.commitInteractionCandidate) { return .commitInteractionCandidate }
        if take(.resetRenderWorkspace) { return .resetRenderWorkspace }
        if take(.resetDrawingPlan) { return .resetDrawingPlan }
        if take(.resetLayoutCandidate) { return .resetLayoutCandidate }
        if take(.discardSemanticCandidate) { return .discardSemanticCandidate }
        if take(.discardObservableCandidate) { return .discardObservableCandidate }
        if take(.resetAttemptStorage) { return .resetAttemptStorage }
        return nil
    }

    private mutating func take(_ action: RuntimeCleanupAction) -> Bool {
        guard outstanding.contains(action) else { return false }
        outstanding.remove(RuntimeCleanupActions(rawValue: 1 << action.rawValue))
        return true
    }
}

package struct RuntimeMutationApplicationState: Equatable, Sendable {
    package private(set) var wasApplied = false

    package init() {}

    package mutating func markApplied() -> Bool {
        guard !wasApplied else { return false }
        wasApplied = true
        return true
    }
}
