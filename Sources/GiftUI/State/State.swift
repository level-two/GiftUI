@propertyWrapper
public struct State<Value> {
    private final class Storage {
        var value: Value

        init(value: Value) {
            self.value = value
        }
    }

    private let storage: Storage

    public init(wrappedValue: Value) {
        storage = Storage(value: wrappedValue)
    }

    public var wrappedValue: Value {
        get { storage.value }
        nonmutating set { storage.value = newValue }
    }
}
