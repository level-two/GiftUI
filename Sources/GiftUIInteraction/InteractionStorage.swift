import GiftUI
import GiftUIExecution

@usableFromInline
package struct InteractionCandidateRecord<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    @usableFromInline
    package let identity: Identity
    @usableFromInline
    package var generation: ActionGeneration?
    @usableFromInline
    package let isEnabled: Bool
    @usableFromInline
    package let hitBounds: Rect
    @usableFromInline
    package let paintOrder: UInt16
    @usableFromInline
    package let action: BoundedApplicationAction
    @usableFromInline
    package let targetGeneration: ObservableTargetGeneration

    @inlinable
    package init(
        identity: Identity,
        generation: ActionGeneration?,
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
package struct InteractionHitRegion<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    @usableFromInline
    package let identity: Identity
    @usableFromInline
    package let bounds: Rect
    @usableFromInline
    package let paintOrder: UInt16

    @inlinable
    package init(identity: Identity, bounds: Rect, paintOrder: UInt16) {
        self.identity = identity
        self.bounds = bounds
        self.paintOrder = paintOrder
    }
}

@usableFromInline
package protocol InteractionCandidateRecordStorage: ~Copyable, ~Escapable {
    associatedtype Identity: Equatable & Sendable

    var count: UInt16 { get }
    var capacity: UInt16 { get }
    mutating func reset()
    borrowing func record(at index: UInt16) -> InteractionCandidateRecord<Identity>?
    mutating func append(_ record: consuming InteractionCandidateRecord<Identity>) -> Bool
    mutating func replace(
        at index: UInt16,
        with record: consuming InteractionCandidateRecord<Identity>
    ) -> Bool
}

@usableFromInline
package protocol InteractionCommittedRecordStorage: ~Copyable, ~Escapable {
    associatedtype Identity: Equatable & Sendable

    var count: UInt16 { get }
    var capacity: UInt16 { get }
    mutating func reset()
    borrowing func record(at index: UInt16) -> BoundActionRecord<Identity>?
    mutating func append(_ record: consuming BoundActionRecord<Identity>) -> Bool
    mutating func exchangeContents(with other: inout Self)
}

@usableFromInline
package protocol InteractionHitRegionStorage: ~Copyable, ~Escapable {
    associatedtype Identity: Equatable & Sendable

    var count: UInt16 { get }
    var capacity: UInt16 { get }
    mutating func reset()
    borrowing func region(at index: UInt16) -> InteractionHitRegion<Identity>?
    mutating func append(_ region: consuming InteractionHitRegion<Identity>) -> Bool
    mutating func exchangeContents(with other: inout Self)
}
