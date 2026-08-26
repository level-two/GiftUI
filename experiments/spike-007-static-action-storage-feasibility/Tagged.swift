// Disposable generated tagged-callable candidate for SPIKE-007.

// These compile-only declarations preserve SPEC-011's public source spelling.
// The static profile's generated lowering does not retain these closures.
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

enum GeneratedActionTag: UInt8 {
    case start = 0
    case stop = 1
    case clear = 2
    case selectWindow = 3
}

protocol InteractionCallable: ~Copyable {
    borrowing func invoke()
}

nonisolated(unsafe) var taggedResult: UInt32 = 0

struct GeneratedCallable: InteractionCallable, ~Copyable {
    let tag: GeneratedActionTag
    let payload: UInt32

    borrowing func invoke() {
        switch tag {
        case .start: taggedResult = (payload &* 16777619) ^ 1
        case .stop: taggedResult = (payload &* 16777619) ^ 2
        case .clear: taggedResult = (payload &* 16777619) ^ 3
        case .selectWindow: taggedResult = (payload &* 16777619) ^ 4
        }
    }
}

struct StaticActionRecord<Callable: ~Copyable & InteractionCallable>: ~Copyable {
    let identity: UInt32
    let generation: UInt32
    let isEnabled: Bool
    let callable: GeneratedCallable

    borrowing func invoke(expectedGeneration: UInt32) -> UInt32 {
        guard isEnabled, generation == expectedGeneration else { return 0 }
        callable.invoke()
        return taggedResult ^ identity
    }
}

nonisolated(unsafe) var installedStaticRecord:
    StaticActionRecord<GeneratedCallable>? = nil

@inline(never)
func installGenerated(
    _ tag: GeneratedActionTag,
    identity: UInt32,
    generation: UInt32,
    payload: UInt32
) {
    installedStaticRecord = StaticActionRecord(
        identity: identity,
        generation: generation,
        isEnabled: true,
        callable: GeneratedCallable(tag: tag, payload: payload)
    )
}

@inline(never)
func dispatchGenerated(_ generation: UInt32) -> UInt32 {
    guard let result = installedStaticRecord?.invoke(
        expectedGeneration: generation
    ) else { return 0 }
    installedStaticRecord = nil
    return result
}

@_cdecl("spike007_swift_run")
public func spike007SwiftRun(_ seed: UInt32) -> UInt32 {
    var checksum = seed ^ 0x0077_0000
    installGenerated(.start, identity: 1, generation: 11, payload: seed)
    checksum ^= dispatchGenerated(11)
    installGenerated(.stop, identity: 2, generation: 12, payload: seed &+ 1)
    checksum ^= dispatchGenerated(12)
    installGenerated(.clear, identity: 3, generation: 13, payload: seed &+ 2)
    checksum ^= dispatchGenerated(13)
    installGenerated(.selectWindow, identity: 4, generation: 14, payload: seed &+ 3)
    checksum ^= dispatchGenerated(14)
    return checksum
}
