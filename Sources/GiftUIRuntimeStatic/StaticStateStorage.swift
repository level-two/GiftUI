public struct StaticStateSlot<Value>: Equatable, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public enum StaticStateStorageError: Error, Equatable, Sendable {
    case slotCapacityExceeded(capacity: Int)
}

/// Fixed-capacity homogeneous state storage for generated static runtimes.
///
/// Applications assign stable numeric slots at generation time. Distinct
/// value types use distinct storage instances, avoiding heterogeneous `Any`
/// storage and string structural paths.
public struct StaticStateStorage<Value> {
    public static var capacity: Int { 16 }

    #if hasFeature(Embedded)
    private var values: InlineArray<16, Value?> = .init { _ in nil }
    #else
    private var values = Array<Value?>(repeating: nil, count: 16)
    #endif

    public private(set) var isInvalid = true

    public init() {}

    public mutating func value(
        at slot: StaticStateSlot<Value>,
        initialValue: @autoclosure () -> Value
    ) throws(StaticStateStorageError) -> Value {
        let index = try index(for: slot)
        if let value = values[index] {
            return value
        }
        let value = initialValue()
        values[index] = value
        isInvalid = true
        return value
    }

    public mutating func write(
        _ value: Value,
        at slot: StaticStateSlot<Value>
    ) throws(StaticStateStorageError) {
        let index = try index(for: slot)
        values[index] = value
        isInvalid = true
    }

    public mutating func markRendered() {
        isInvalid = false
    }

    private func index(
        for slot: StaticStateSlot<Value>
    ) throws(StaticStateStorageError) -> Int {
        guard slot.rawValue >= 0, slot.rawValue < Self.capacity else {
            throw .slotCapacityExceeded(capacity: Self.capacity)
        }
        return slot.rawValue
    }
}
