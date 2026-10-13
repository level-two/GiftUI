// Disposable SPIKE-075 domain stand-ins. No production imports.
package struct SemanticCompleteIdentity: Equatable, Sendable {
    package let raw: UInt64
    package init(_ raw: UInt64) { self.raw = raw }
}
package struct InteractionCandidateRecord<I: Equatable & Sendable> { package let value: UInt64 }
package struct BoundActionRecord<I: Equatable & Sendable> { package let value: UInt64 }
package struct InteractionHitRegion<I: Equatable & Sendable> { package let value: UInt64 }
package struct InteractionLimits {}
package struct InteractionError {}
package struct Rect {}
package struct BoundedApplicationAction {}
package struct ObservableTargetGeneration {}
package struct InteractionCandidateAppendResult {}
package struct ActionGeneration {}
package struct InteractionCandidateDisposition {}
package struct Point {}
package struct PresentationRevision {}
package struct PointerGestureOutcome<I: Equatable & Sendable> {}
package struct CapturedAction<I: Equatable & Sendable> {}

// Six declarations copied verbatim from RFC-015.
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

package protocol InteractionCommittedRecordStorage: ~Copyable, ~Escapable {
    associatedtype Identity: Equatable & Sendable

    var count: UInt16 { get }
    var capacity: UInt16 { get }
    mutating func reset()
    borrowing func record(at index: UInt16) -> BoundActionRecord<Identity>?
    mutating func append(_ record: consuming BoundActionRecord<Identity>) -> Bool
    mutating func exchangeContents(with other: inout Self)
}

package protocol InteractionHitRegionStorage: ~Copyable, ~Escapable {
    associatedtype Identity: Equatable & Sendable

    var count: UInt16 { get }
    var capacity: UInt16 { get }
    mutating func reset()
    borrowing func region(at index: UInt16) -> InteractionHitRegion<Identity>?
    mutating func append(_ region: consuming InteractionHitRegion<Identity>) -> Bool
    mutating func exchangeContents(with other: inout Self)
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

package protocol InteractionCommittedActionView: ~Copyable, ~Escapable {
    associatedtype Identity: Equatable & Sendable

    borrowing func committedRecord(
        for identity: Identity
    ) -> BoundActionRecord<Identity>?
}

