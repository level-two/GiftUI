import GiftUIRuntimeCore

package struct StaticObservableProfileSlotStorage<Identity>:
    RuntimeObservableProfileSlotStorage
where Identity: Equatable & Sendable {
    private var onlySlot: RuntimeObservableProfileSlot<Identity>

    package init() {
        onlySlot = RuntimeObservableProfileSlot()
    }

    package var capacity: UInt16 { 1 }

    package borrowing func slot(
        at index: UInt16
    ) -> RuntimeObservableProfileSlot<Identity>? {
        index == 0 ? onlySlot : nil
    }

    package mutating func update(
        _ slot: RuntimeObservableProfileSlot<Identity>,
        at index: UInt16
    ) -> Bool {
        guard index == 0 else { return false }
        onlySlot = slot
        return true
    }
}
