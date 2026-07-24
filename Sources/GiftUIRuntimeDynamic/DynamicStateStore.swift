import GiftUI

@MainActor
public final class DynamicStateStore: StateStorage {
    private var storage: [StateKey: Any] = [:]
    private let didWrite: () -> Void

    public init(didWrite: @escaping () -> Void = {}) {
        self.didWrite = didWrite
    }

    public func read<Value>(
        key: StateKey,
        initialValue: @autoclosure () -> Value
    ) -> Value {
        guard let stored = storage[key] else {
            let initialValue = initialValue()
            storage[key] = initialValue
            return initialValue
        }

        precondition(
            stored is Value,
            "State type mismatch for path '\(key.path)', slot \(key.slot)"
        )
        return stored as! Value
    }

    public func write<Value>(_ value: Value, key: StateKey) {
        storage[key] = value
        didWrite()
    }
}
