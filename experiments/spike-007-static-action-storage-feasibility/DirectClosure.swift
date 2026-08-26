// Disposable direct stored-closure candidate for SPIKE-007.

@resultBuilder
public enum ViewBuilder {
    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        content
    }
}

public protocol View {}

public struct Text: View {
    public let value: StaticString
    public init(_ value: StaticString) { self.value = value }
}

public struct BoundedText: View {
    public let value: StaticString
    public init(_ value: StaticString) { self.value = value }
}

public struct Button<Label: View>: View {
    public let action: () -> Void
    public let label: Label

    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }
}

public extension Button where Label == Text {
    init(_ title: StaticString, action: @escaping () -> Void) {
        self.init(action: action) { Text(title) }
    }

    init(_ title: BoundedText, action: @escaping () -> Void) {
        self.init(action: action) { Text(title.value) }
    }
}

public struct Disabled<Content: View>: View {
    public let content: Content
    public let isDisabled: Bool
}

public extension View {
    func disabled(_ disabled: Bool) -> some View {
        Disabled(content: self, isDisabled: disabled)
    }
}

struct DirectActionRecord: ~Copyable {
    let identity: UInt32
    let generation: UInt32
    let isEnabled: Bool
    let action: () -> Void

    init(
        identity: UInt32,
        generation: UInt32,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) {
        self.identity = identity
        self.generation = generation
        self.isEnabled = isEnabled
        self.action = action
    }

    borrowing func invoke(expectedGeneration: UInt32) -> UInt32 {
        guard isEnabled, generation == expectedGeneration else { return 0 }
        action()
        return identity
    }
}

nonisolated(unsafe) var installedDirectRecord: DirectActionRecord? = nil

@inline(never)
func installDirect(_ identity: UInt32, _ payload: UInt32) {
    let button = Button("Action") {
        directResult = (payload &* 16777619) ^ identity
    }
    installedDirectRecord = DirectActionRecord(
        identity: identity,
        generation: payload,
        isEnabled: true,
        action: button.action
    )
}

nonisolated(unsafe) var directResult: UInt32 = 0

@inline(never)
func dispatchDirect(_ generation: UInt32) -> UInt32 {
    guard let identity = installedDirectRecord?.invoke(
        expectedGeneration: generation
    ) else { return 0 }
    installedDirectRecord = nil
    return directResult ^ identity
}

@_cdecl("spike007_swift_run")
public func spike007SwiftRun(_ seed: UInt32) -> UInt32 {
    var checksum = seed ^ 0x007D_0000
    installDirect(1, seed)
    checksum ^= dispatchDirect(seed)
    installDirect(2, seed &+ 1)
    checksum ^= dispatchDirect(seed &+ 1)
    installDirect(3, seed &+ 2)
    checksum ^= dispatchDirect(seed &+ 2)
    installDirect(4, seed &+ 3)
    checksum ^= dispatchDirect(seed &+ 3)
    return checksum
}
