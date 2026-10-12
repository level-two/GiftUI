import GiftUI
import GiftUIExecution

package struct InteractionCandidateRecord<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    package let identity: Identity
    package var generation: ActionGeneration?
    package let isEnabled: Bool
    package let hitBounds: Rect
    package let paintOrder: UInt16
    package let action: BoundedApplicationAction
    package let targetGeneration: ObservableTargetGeneration
}

package struct InteractionHitRegion<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    package let identity: Identity
    package let bounds: Rect
    package let paintOrder: UInt16
}

package protocol InteractionCandidateRecordStorage {
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

package protocol InteractionCommittedRecordStorage {
    associatedtype Identity: Equatable & Sendable

    var count: UInt16 { get }
    var capacity: UInt16 { get }
    mutating func reset()
    borrowing func record(at index: UInt16) -> BoundActionRecord<Identity>?
    mutating func append(_ record: consuming BoundActionRecord<Identity>) -> Bool
    mutating func exchangeContents(with other: inout Self)
}

package protocol InteractionHitRegionStorage {
    associatedtype Identity: Equatable & Sendable

    var count: UInt16 { get }
    var capacity: UInt16 { get }
    mutating func reset()
    borrowing func region(at index: UInt16) -> InteractionHitRegion<Identity>?
    mutating func append(_ region: consuming InteractionHitRegion<Identity>) -> Bool
    mutating func exchangeContents(with other: inout Self)
}
