/// Type-erased storage contract used by the dynamic state wrapper.
public protocol StateStorage: AnyObject {
    func read<Value>(
        key: StateKey,
        initialValue: @autoclosure () -> Value
    ) -> Value

    func write<Value>(_ value: Value, key: StateKey)
}
