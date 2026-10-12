import GiftUIExecution
import GiftUIInteraction

private struct StaticTwoInteractionSlots<Element> {
    private var values: InlineArray<2, Element?> = .init(repeating: nil)
    subscript(index: UInt16) -> Element? {
        borrowing get { index < 2 ? values[Int(index)] : nil }
        set { if index < 2 { values[Int(index)] = newValue } }
    }
    mutating func reset(count: UInt16) { for index in 0..<Int(count) { values[index] = nil } }
}

package struct StaticTwoInteractionCandidateStorage<Identity>:
    InteractionCandidateRecordStorage
where Identity: Equatable & Sendable {
    package let capacity: UInt16
    package private(set) var count: UInt16 = 0
    private var slots = StaticTwoInteractionSlots<InteractionCandidateRecord<Identity>>()

    package init?(capacity: UInt16) {
        guard capacity > 0, capacity <= 2 else { return nil }
        self.capacity = capacity
    }

    package mutating func reset() {
        slots.reset(count: count)
        count = 0
    }

    package borrowing func record(
        at index: UInt16
    ) -> InteractionCandidateRecord<Identity>? {
        guard index < count else { return nil }
        return slots[index]
    }

    package mutating func append(
        _ record: consuming InteractionCandidateRecord<Identity>
    ) -> Bool {
        guard count < capacity else { return false }
        slots[count] = consume record
        count += 1
        return true
    }

    package mutating func replace(
        at index: UInt16,
        with record: consuming InteractionCandidateRecord<Identity>
    ) -> Bool {
        guard index < count else { return false }
        slots[index] = consume record
        return true
    }
}

package struct StaticTwoInteractionCommittedStorage<Identity>:
    InteractionCommittedRecordStorage
where Identity: Equatable & Sendable {
    package private(set) var capacity: UInt16
    package private(set) var count: UInt16 = 0
    private var slots = StaticTwoInteractionSlots<BoundActionRecord<Identity>>()

    package init?(capacity: UInt16) {
        guard capacity > 0, capacity <= 2 else { return nil }
        self.capacity = capacity
    }

    package mutating func reset() {
        slots.reset(count: count)
        count = 0
    }

    package borrowing func record(
        at index: UInt16
    ) -> BoundActionRecord<Identity>? {
        guard index < count else { return nil }
        return slots[index]
    }

    package mutating func append(
        _ record: consuming BoundActionRecord<Identity>
    ) -> Bool {
        guard count < capacity else { return false }
        slots[count] = consume record
        count += 1
        return true
    }

    package mutating func exchangeContents(with other: inout Self) {
        swap(&capacity, &other.capacity)
        swap(&count, &other.count)
        swap(&slots, &other.slots)
    }
}

package struct StaticTwoInteractionHitStorage<Identity>:
    InteractionHitRegionStorage
where Identity: Equatable & Sendable {
    package private(set) var capacity: UInt16
    package private(set) var count: UInt16 = 0
    private var slots = StaticTwoInteractionSlots<InteractionHitRegion<Identity>>()

    package init?(capacity: UInt16) {
        guard capacity > 0, capacity <= 2 else { return nil }
        self.capacity = capacity
    }

    package mutating func reset() {
        slots.reset(count: count)
        count = 0
    }

    package borrowing func region(
        at index: UInt16
    ) -> InteractionHitRegion<Identity>? {
        guard index < count else { return nil }
        return slots[index]
    }

    package mutating func append(
        _ region: consuming InteractionHitRegion<Identity>
    ) -> Bool {
        guard count < capacity else { return false }
        slots[count] = consume region
        count += 1
        return true
    }

    package mutating func exchangeContents(with other: inout Self) {
        swap(&capacity, &other.capacity)
        swap(&count, &other.count)
        swap(&slots, &other.slots)
    }
}

package typealias StaticTwoInteractionState<Identity> = InteractionState<
    StaticTwoInteractionCandidateStorage<Identity>,
    StaticTwoInteractionCommittedStorage<Identity>,
    StaticTwoInteractionHitStorage<Identity>
> where Identity: Equatable & Sendable
