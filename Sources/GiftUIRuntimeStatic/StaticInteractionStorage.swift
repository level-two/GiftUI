import GiftUIExecution
import GiftUIInteraction

private struct StaticInteractionSlots<Element> {
    private var values:
        (
            Element?, Element?, Element?, Element?, Element?, Element?, Element?, Element?,
            Element?, Element?, Element?, Element?, Element?, Element?, Element?, Element?,
            Element?, Element?, Element?, Element?, Element?, Element?, Element?, Element?,
            Element?, Element?, Element?, Element?, Element?, Element?, Element?, Element?
        ) = (
            nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil
        )

    subscript(index: UInt16) -> Element? {
        borrowing get {
            switch index {
            case 0: values.0
            case 1: values.1
            case 2: values.2
            case 3: values.3
            case 4: values.4
            case 5: values.5
            case 6: values.6
            case 7: values.7
            case 8: values.8
            case 9: values.9
            case 10: values.10
            case 11: values.11
            case 12: values.12
            case 13: values.13
            case 14: values.14
            case 15: values.15
            case 16: values.16
            case 17: values.17
            case 18: values.18
            case 19: values.19
            case 20: values.20
            case 21: values.21
            case 22: values.22
            case 23: values.23
            case 24: values.24
            case 25: values.25
            case 26: values.26
            case 27: values.27
            case 28: values.28
            case 29: values.29
            case 30: values.30
            case 31: values.31
            default: nil
            }
        }
        set {
            switch index {
            case 0: values.0 = newValue
            case 1: values.1 = newValue
            case 2: values.2 = newValue
            case 3: values.3 = newValue
            case 4: values.4 = newValue
            case 5: values.5 = newValue
            case 6: values.6 = newValue
            case 7: values.7 = newValue
            case 8: values.8 = newValue
            case 9: values.9 = newValue
            case 10: values.10 = newValue
            case 11: values.11 = newValue
            case 12: values.12 = newValue
            case 13: values.13 = newValue
            case 14: values.14 = newValue
            case 15: values.15 = newValue
            case 16: values.16 = newValue
            case 17: values.17 = newValue
            case 18: values.18 = newValue
            case 19: values.19 = newValue
            case 20: values.20 = newValue
            case 21: values.21 = newValue
            case 22: values.22 = newValue
            case 23: values.23 = newValue
            case 24: values.24 = newValue
            case 25: values.25 = newValue
            case 26: values.26 = newValue
            case 27: values.27 = newValue
            case 28: values.28 = newValue
            case 29: values.29 = newValue
            case 30: values.30 = newValue
            case 31: values.31 = newValue
            default: break
            }
        }
    }

    mutating func reset(count: UInt16) {
        var index: UInt16 = 0
        while index < count {
            self[index] = nil
            index += 1
        }
    }
}

package struct StaticInteractionCandidateStorage<Identity>:
    InteractionCandidateRecordStorage
where Identity: Equatable & Sendable {
    package let capacity: UInt16
    package private(set) var count: UInt16 = 0
    private var slots = StaticInteractionSlots<InteractionCandidateRecord<Identity>>()

    package init?(capacity: UInt16) {
        guard capacity > 0, capacity <= 32 else { return nil }
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

package struct StaticInteractionCommittedStorage<Identity>:
    InteractionCommittedRecordStorage
where Identity: Equatable & Sendable {
    package private(set) var capacity: UInt16
    package private(set) var count: UInt16 = 0
    private var slots = StaticInteractionSlots<BoundActionRecord<Identity>>()

    package init?(capacity: UInt16) {
        guard capacity > 0, capacity <= 32 else { return nil }
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

package struct StaticInteractionHitStorage<Identity>:
    InteractionHitRegionStorage
where Identity: Equatable & Sendable {
    package private(set) var capacity: UInt16
    package private(set) var count: UInt16 = 0
    private var slots = StaticInteractionSlots<InteractionHitRegion<Identity>>()

    package init?(capacity: UInt16) {
        guard capacity > 0, capacity <= 32 else { return nil }
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

package typealias StaticInteractionState<Identity> = InteractionState<
    StaticInteractionCandidateStorage<Identity>,
    StaticInteractionCommittedStorage<Identity>,
    StaticInteractionHitStorage<Identity>
> where Identity: Equatable & Sendable
