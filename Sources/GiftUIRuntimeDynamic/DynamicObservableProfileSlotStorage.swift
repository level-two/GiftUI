import GiftUIRuntimeCore

package struct DynamicObservableProfileSlotStorage<Identity>:
    RuntimeObservableProfileSlotStorage
where Identity: Equatable & Sendable {
    private var slots: [RuntimeObservableProfileSlot<Identity>]

    package init(capacity: UInt16) {
        slots = Array(
            repeating: RuntimeObservableProfileSlot(),
            count: Int(capacity)
        )
    }

    package var capacity: UInt16 {
        UInt16(slots.count)
    }

    package borrowing func slot(
        at index: UInt16
    ) -> RuntimeObservableProfileSlot<Identity>? {
        guard Int(index) < slots.count else { return nil }
        return slots[Int(index)]
    }

    package mutating func update(
        _ slot: RuntimeObservableProfileSlot<Identity>,
        at index: UInt16
    ) -> Bool {
        guard Int(index) < slots.count else { return false }
        slots[Int(index)] = slot
        return true
    }
}
