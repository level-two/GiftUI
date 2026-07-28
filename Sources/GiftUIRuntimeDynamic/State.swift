/// Heap-backed state binding for the dynamic runtime profile.
@propertyWrapper
public struct State<Value> {
    private final class Storage {
        var localValue: Value
        var location: StateLocation<Value>?

        init(value: Value) {
            localValue = value
        }
    }

    private let storage: Storage

    public init(wrappedValue: Value) {
        storage = Storage(value: wrappedValue)
    }

    public var wrappedValue: Value {
        get {
            if let location = storage.location {
                return location.read()
            }

            guard let binding = StateBindingContext.current else {
                return storage.localValue
            }

            let location = StateLocation<Value>(
                storage: binding.storage,
                key: binding.nextKey()
            )
            storage.location = location
            return location.read(initialValue: storage.localValue)
        }
        nonmutating set {
            if let location = storage.location {
                location.write(newValue)
            } else {
                storage.localValue = newValue
            }
        }
    }
}

private final class StateLocation<Value> {
    private let storage: any StateStorage
    private let key: StateKey

    init(storage: any StateStorage, key: StateKey) {
        self.storage = storage
        self.key = key
    }

    func read(initialValue: @autoclosure () -> Value) -> Value {
        storage.read(key: key, initialValue: initialValue())
    }

    func read() -> Value {
        let value: Value = storage.read(
            key: key,
            initialValue: missingStateValue()
        )
        return value
    }

    func write(_ value: Value) {
        storage.write(value, key: key)
    }

    private func missingStateValue() -> Value {
        preconditionFailure("Bound state was removed from runtime storage")
    }
}
