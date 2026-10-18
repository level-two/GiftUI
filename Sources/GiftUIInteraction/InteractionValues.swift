import GiftUI
import GiftUIExecution

@usableFromInline
package struct BoundedApplicationAction: Equatable, Hashable, Sendable {
    @usableFromInline package let code: UInt16

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

@usableFromInline
package struct BoundActionRecord<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    @usableFromInline package let identity: Identity
    @usableFromInline package let generation: ActionGeneration
    @usableFromInline package let isEnabled: Bool
    @usableFromInline
    package let hitBounds: Rect
    package let paintOrder: UInt16
    @usableFromInline package let action: BoundedApplicationAction
    @usableFromInline package let targetGeneration: ObservableTargetGeneration

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

@usableFromInline
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

@usableFromInline
package enum PointerGestureOutcome<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    case captured(CapturedAction<Identity>)
    case continued(CapturedAction<Identity>)
    case activationAdmitted(CapturedAction<Identity>)
    case cancelled
    case ignored
}

@usableFromInline
package enum InteractionDispatchResult: Equatable, Sendable {
    case dispatched
    case cancelled
    case failure(InteractionError)
}

package protocol InteractionCandidateBuilder: ~Copyable, ~Escapable {
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

@usableFromInline
package protocol InteractionGestureResolver: ~Copyable, ~Escapable {
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

@usableFromInline
package protocol InteractionCommittedActionView: ~Copyable, ~Escapable {
    associatedtype Identity: Equatable & Sendable

    borrowing func committedRecord(
        for identity: Identity
    ) -> BoundActionRecord<Identity>?
}

package protocol InteractionDispatcher {
    associatedtype Identity: Equatable & Sendable

    mutating func dispatch(
        _ captured: CapturedAction<Identity>
    ) -> InteractionDispatchResult
}

/// Owned instrumentation facts describe the actual retained bank, including spare
/// payload capacity. No bank, pointer, closure or mutable capability is returned.
package struct InteractionOwnedBankMeasurement {
    package let count: UInt16
    package let capacity: UInt16
    package let retainedIdentitySlots: Int
    package let retainedPayloadBytes: Int
    package let inlineSize: Int
    package let inlineStride: Int
    package let inlineAlignment: Int

    package init(
        count: UInt16, capacity: UInt16, retainedIdentitySlots: Int,
        retainedPayloadBytes: Int, inlineSize: Int, inlineStride: Int, inlineAlignment: Int
    ) {
        precondition(retainedIdentitySlots >= Int(capacity) && retainedPayloadBytes >= 0)
        precondition(inlineSize >= 0 && inlineStride >= inlineSize && inlineAlignment > 0)
        self.count = count
        self.capacity = capacity
        self.retainedIdentitySlots = retainedIdentitySlots
        self.retainedPayloadBytes = retainedPayloadBytes
        self.inlineSize = inlineSize
        self.inlineStride = inlineStride
        self.inlineAlignment = inlineAlignment
    }
}

// This separate instrumentation contract remains Copyable and Escapable. It
// adds no requirement to any of the six scoped storage/operation protocols.
package protocol InteractionOwnedBankMeasurementSource {
    var ownedInteractionBankMeasurement: InteractionOwnedBankMeasurement { get }
}

package struct InteractionOwnedStorageMeasurement {
    package let candidate: InteractionOwnedBankMeasurement
    package let candidateHits: InteractionOwnedBankMeasurement
    package let prepared: InteractionOwnedBankMeasurement
    package let committed: InteractionOwnedBankMeasurement
    package let committedHits: InteractionOwnedBankMeasurement
}
