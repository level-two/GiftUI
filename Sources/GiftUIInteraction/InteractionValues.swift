import GiftUI
import GiftUIExecution

package struct BoundedApplicationAction: Equatable, Hashable, Sendable {
    package let code: UInt16

    package init(code: UInt16) {
        self.code = code
    }
}

package struct InteractionLimits: Equatable, Sendable {
    package let maximumActions: UInt16
    package let maximumHitRegions: UInt16

    package init?(
        maximumActions: UInt16,
        maximumHitRegions: UInt16
    ) {
        guard maximumActions > 0,
            maximumHitRegions > 0,
            maximumHitRegions <= maximumActions
        else { return nil }
        self.maximumActions = maximumActions
        self.maximumHitRegions = maximumHitRegions
    }
}

package struct BoundActionRecord<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    package let identity: Identity
    package let generation: ActionGeneration
    package let isEnabled: Bool
    package let hitBounds: Rect
    package let paintOrder: UInt16
    package let action: BoundedApplicationAction
    package let targetGeneration: ObservableTargetGeneration

    package init(
        identity: Identity,
        generation: ActionGeneration,
        isEnabled: Bool,
        hitBounds: Rect,
        paintOrder: UInt16,
        action: BoundedApplicationAction,
        targetGeneration: ObservableTargetGeneration
    ) {
        self.identity = identity
        self.generation = generation
        self.isEnabled = isEnabled
        self.hitBounds = hitBounds
        self.paintOrder = paintOrder
        self.action = action
        self.targetGeneration = targetGeneration
    }
}

package enum InteractionError: UInt8, Equatable, Sendable {
    case capacityExhausted = 0
    case invalidIdentity = 1
    case invalidGeometry = 2
    case invalidPhase = 3
    case reentrancyViolation = 4
    case invariantViolation = 5
    case incompatibleActionDomain = 6
    case invalidActionValue = 7
    case missingModelTarget = 8
}

package enum InteractionCandidateDisposition: Equatable, Sendable {
    case commit(PresentationRevision)
    case discard
}

package enum InteractionCandidateAppendResult: Equatable, Sendable {
    case preserved
    case requiresGeneration
    case failure(InteractionError)
}

package enum PointerGestureOutcome<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    case captured(CapturedAction<Identity>)
    case continued(CapturedAction<Identity>)
    case activationAdmitted(CapturedAction<Identity>)
    case cancelled
    case ignored
}

package enum InteractionDispatchResult: Equatable, Sendable {
    case dispatched
    case cancelled
    case failure(InteractionError)
}

package protocol InteractionCandidateBuilder {
    associatedtype Identity: Equatable & Sendable

    mutating func beginCandidate(limits: InteractionLimits) -> InteractionError?
    mutating func append(
        identity: Identity,
        isEnabled: Bool,
        bounds: Rect,
        clip: Rect,
        paintOrder: UInt16,
        action: BoundedApplicationAction,
        targetGeneration: ObservableTargetGeneration
    ) -> InteractionCandidateAppendResult
    mutating func assignGeneration(
        _ generation: ActionGeneration,
        to identity: Identity
    ) -> InteractionError?
    mutating func finishCandidate() -> InteractionError?
    mutating func resolveCandidate(_ disposition: InteractionCandidateDisposition)
}

package protocol InteractionGestureResolver {
    associatedtype Identity: Equatable & Sendable

    borrowing func resolveDown(at point: Point) -> PointerGestureOutcome<Identity>
    borrowing func resolveMove(
        _ captured: CapturedAction<Identity>,
        at point: Point
    ) -> PointerGestureOutcome<Identity>
    borrowing func resolveUp(
        _ captured: CapturedAction<Identity>,
        at point: Point
    ) -> PointerGestureOutcome<Identity>
}

package protocol ActionModelTargetAccess {
    associatedtype Model: _GiftUIObservableReference

    borrowing func currentGeneration() -> ObservableTargetGeneration?
    mutating func withCurrentModel(
        matching generation: ObservableTargetGeneration,
        _ body: (borrowing Model) -> Void
    ) -> Bool
}
