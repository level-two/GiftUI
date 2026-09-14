import GiftUIExecution
import GiftUIInteraction

package struct DynamicInteractionCandidateStorage<Identity>:
    InteractionCandidateRecordStorage
where Identity: Equatable & Sendable {
    package let capacity: UInt16
    private var records: [InteractionCandidateRecord<Identity>]

    package init(capacity: UInt16) {
        self.capacity = capacity
        records = []
        records.reserveCapacity(Int(capacity))
    }

    package var count: UInt16 { UInt16(records.count) }

    package mutating func reset() {
        records.removeAll(keepingCapacity: true)
    }

    package borrowing func record(
        at index: UInt16
    ) -> InteractionCandidateRecord<Identity>? {
        guard Int(index) < records.count else { return nil }
        return records[Int(index)]
    }

    package mutating func append(
        _ record: consuming InteractionCandidateRecord<Identity>
    ) -> Bool {
        guard count < capacity else { return false }
        records.append(consume record)
        return true
    }

    package mutating func replace(
        at index: UInt16,
        with record: consuming InteractionCandidateRecord<Identity>
    ) -> Bool {
        guard Int(index) < records.count else { return false }
        records[Int(index)] = consume record
        return true
    }
}

package struct DynamicInteractionCommittedStorage<Identity>:
    InteractionCommittedRecordStorage
where Identity: Equatable & Sendable {
    package private(set) var capacity: UInt16
    private var records: [BoundActionRecord<Identity>]

    package init(capacity: UInt16) {
        self.capacity = capacity
        records = []
        records.reserveCapacity(Int(capacity))
    }

    package var count: UInt16 { UInt16(records.count) }

    package mutating func reset() {
        records.removeAll(keepingCapacity: true)
    }

    package borrowing func record(
        at index: UInt16
    ) -> BoundActionRecord<Identity>? {
        guard Int(index) < records.count else { return nil }
        return records[Int(index)]
    }

    package mutating func append(
        _ record: consuming BoundActionRecord<Identity>
    ) -> Bool {
        guard count < capacity else { return false }
        records.append(consume record)
        return true
    }

    package mutating func exchangeContents(with other: inout Self) {
        swap(&capacity, &other.capacity)
        swap(&records, &other.records)
    }
}

package struct DynamicInteractionHitStorage<Identity>:
    InteractionHitRegionStorage
where Identity: Equatable & Sendable {
    package private(set) var capacity: UInt16
    private var regions: [InteractionHitRegion<Identity>]

    package init(capacity: UInt16) {
        self.capacity = capacity
        regions = []
        regions.reserveCapacity(Int(capacity))
    }

    package var count: UInt16 { UInt16(regions.count) }

    package mutating func reset() {
        regions.removeAll(keepingCapacity: true)
    }

    package borrowing func region(
        at index: UInt16
    ) -> InteractionHitRegion<Identity>? {
        guard Int(index) < regions.count else { return nil }
        return regions[Int(index)]
    }

    package mutating func append(
        _ region: consuming InteractionHitRegion<Identity>
    ) -> Bool {
        guard count < capacity else { return false }
        regions.append(consume region)
        return true
    }

    package mutating func exchangeContents(with other: inout Self) {
        swap(&capacity, &other.capacity)
        swap(&regions, &other.regions)
    }
}

package typealias DynamicInteractionState<Identity> = InteractionState<
    DynamicInteractionCandidateStorage<Identity>,
    DynamicInteractionCommittedStorage<Identity>,
    DynamicInteractionHitStorage<Identity>
> where Identity: Equatable & Sendable
