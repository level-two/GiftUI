import GiftUI

public enum ILI9341Orientation: Int, CaseIterable, Sendable {
    case degrees0 = 0
    case degrees90 = 90
    case degrees180 = 180
    case degrees270 = 270
}

public struct ILI9341ReadCapabilities: Equatable, Sendable {
    public let registerReads: Bool
    public let gramReads: Bool

    public init(registerReads: Bool = false, gramReads: Bool = false) {
        self.registerReads = registerReads
        self.gramReads = gramReads
    }

    public static let writeOnly = ILI9341ReadCapabilities()
}

/// Describes the logical surface already configured by the controller driver.
/// Rotation is owned by that driver; RGB565 renderers used with this surface
/// must therefore use software rotation zero.
public struct ILI9341DisplayConfiguration: Equatable, Sendable {
    public static let nativeWidth = 240
    public static let nativeHeight = 320
    public static let bytesPerPixel = 2

    public let orientation: ILI9341Orientation
    public let readCapabilities: ILI9341ReadCapabilities

    public var logicalSize: Size {
        switch orientation {
        case .degrees0, .degrees180:
            Size(width: Self.nativeWidth, height: Self.nativeHeight)
        case .degrees90, .degrees270:
            Size(width: Self.nativeHeight, height: Self.nativeWidth)
        }
    }

    public init(
        orientation: ILI9341Orientation = .degrees0,
        readCapabilities: ILI9341ReadCapabilities = .writeOnly
    ) {
        self.orientation = orientation
        self.readCapabilities = readCapabilities
    }
}
