// Scoped adapters borrow actual InlineArray spans; no unsafe pointer manufacture.
package struct OwnedCandidate: InteractionCandidateRecordStorage {
    package typealias Identity = SemanticCompleteIdentity
    private let value: UInt64
    package init(_ value: UInt64) { self.value = value }
    package var count: UInt16 { 1 }
    package var capacity: UInt16 { 1 }
    package mutating func reset() {}
    @inline(never) package borrowing func record(at index: UInt16) -> InteractionCandidateRecord<Identity>? {
        guard index == 0 else { return nil }
        return .init(value: value)
    }
    package mutating func append(_ record: consuming InteractionCandidateRecord<Identity>) -> Bool { true }
    package mutating func replace(at index: UInt16, with record: consuming InteractionCandidateRecord<Identity>) -> Bool { true }
}
package struct ScopedCandidate: ~Copyable, ~Escapable, InteractionCandidateRecordStorage {
    package typealias Identity = SemanticCompleteIdentity
    private let values: Span<UInt64>
    @_lifetime(copy values)
    package init(_ values: Span<UInt64>) { self.values = values }
    package var count: UInt16 { 1 }
    package var capacity: UInt16 { 1 }
    package mutating func reset() {}
    @inline(never) package borrowing func record(at index: UInt16) -> InteractionCandidateRecord<Identity>? {
        guard index == 0 else { return nil }
        return .init(value: values[Int(index)])
    }
    package mutating func append(_ record: consuming InteractionCandidateRecord<Identity>) -> Bool { true }
    package mutating func replace(at index: UInt16, with record: consuming InteractionCandidateRecord<Identity>) -> Bool { true }
}
package struct OwnedCommitted: InteractionCommittedRecordStorage {
    package typealias Identity = SemanticCompleteIdentity
    private let value: UInt64
    package init(_ value: UInt64) { self.value = value }
    package var count: UInt16 { 1 }
    package var capacity: UInt16 { 1 }
    package mutating func reset() {}
    @inline(never) package borrowing func record(at index: UInt16) -> BoundActionRecord<Identity>? {
        guard index == 0 else { return nil }
        return .init(value: value)
    }
    package mutating func append(_ record: consuming BoundActionRecord<Identity>) -> Bool { true }
    package mutating func exchangeContents(with other: inout Self) {}
}
package struct ScopedCommitted: ~Copyable, ~Escapable, InteractionCommittedRecordStorage {
    package typealias Identity = SemanticCompleteIdentity
    private let values: Span<UInt64>
    @_lifetime(copy values)
    package init(_ values: Span<UInt64>) { self.values = values }
    package var count: UInt16 { 1 }
    package var capacity: UInt16 { 1 }
    package mutating func reset() {}
    @inline(never) package borrowing func record(at index: UInt16) -> BoundActionRecord<Identity>? {
        guard index == 0 else { return nil }
        return .init(value: values[Int(index)])
    }
    package mutating func append(_ record: consuming BoundActionRecord<Identity>) -> Bool { true }
    package mutating func exchangeContents(with other: inout Self) {}
}
package struct OwnedHit: InteractionHitRegionStorage {
    package typealias Identity = SemanticCompleteIdentity
    private let value: UInt64
    package init(_ value: UInt64) { self.value = value }
    package var count: UInt16 { 1 }
    package var capacity: UInt16 { 1 }
    package mutating func reset() {}
    @inline(never) package borrowing func region(at index: UInt16) -> InteractionHitRegion<Identity>? {
        guard index == 0 else { return nil }
        return .init(value: value)
    }
    package mutating func append(_ region: consuming InteractionHitRegion<Identity>) -> Bool { true }
    package mutating func exchangeContents(with other: inout Self) {}
}
package struct ScopedHit: ~Copyable, ~Escapable, InteractionHitRegionStorage {
    package typealias Identity = SemanticCompleteIdentity
    private let values: Span<UInt64>
    @_lifetime(copy values)
    package init(_ values: Span<UInt64>) { self.values = values }
    package var count: UInt16 { 1 }
    package var capacity: UInt16 { 1 }
    package mutating func reset() {}
    @inline(never) package borrowing func region(at index: UInt16) -> InteractionHitRegion<Identity>? {
        guard index == 0 else { return nil }
        return .init(value: values[Int(index)])
    }
    package mutating func append(_ region: consuming InteractionHitRegion<Identity>) -> Bool { true }
    package mutating func exchangeContents(with other: inout Self) {}
}
