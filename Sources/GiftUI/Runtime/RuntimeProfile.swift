/// A compile-time declaration of the language and storage profile a GiftUI
/// runtime implements.
///
/// Profile selection belongs in package dependencies and generic constraints,
/// not in runtime branches inside view declarations.
public protocol GiftUIRuntimeProfile {
    static var name: StaticString { get }
}

/// The bounded profile shared by static and dynamic runtime implementations.
public enum PortableRuntimeProfile: GiftUIRuntimeProfile {
    public static let name: StaticString = "portable"
}

/// The allocating profile used by the current macOS and Linux runtime.
public enum DynamicRuntimeProfile: GiftUIRuntimeProfile {
    public static let name: StaticString = "dynamic"
}

/// Adopted by runtime implementations to expose profile selection as an
/// associated type.
public protocol GiftUIRuntime {
    associatedtype Profile: GiftUIRuntimeProfile
}
