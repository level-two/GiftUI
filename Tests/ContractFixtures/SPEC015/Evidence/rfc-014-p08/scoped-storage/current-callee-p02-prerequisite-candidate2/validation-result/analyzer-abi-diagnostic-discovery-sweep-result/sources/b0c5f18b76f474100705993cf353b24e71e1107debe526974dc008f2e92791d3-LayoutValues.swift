public enum HorizontalAlignment: UInt8, Sendable {
    case leading = 0
    case center = 1
}

public enum VerticalAlignment: UInt8, Sendable {
    case top = 0
    case center = 1
    case bottom = 2
}

public struct Alignment: Equatable, Sendable {
    public let horizontal: HorizontalAlignment
    public let vertical: VerticalAlignment

    public init(
        horizontal: HorizontalAlignment,
        vertical: VerticalAlignment
    ) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    public static let center = Alignment(horizontal: .center, vertical: .center)
    public static let leading = Alignment(horizontal: .leading, vertical: .center)
}

public struct EdgeInsets: Equatable, Sendable {
    public let top: GeometryScalar
    public let leading: GeometryScalar
    public let bottom: GeometryScalar
    public let trailing: GeometryScalar

    public init?(
        top: GeometryScalar,
        leading: GeometryScalar,
        bottom: GeometryScalar,
        trailing: GeometryScalar
    ) {
        guard top >= 0, leading >= 0, bottom >= 0, trailing >= 0 else {
            return nil
        }
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
}

public struct EdgeSet: OptionSet, Sendable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let top = EdgeSet(rawValue: 1 << 0)
    public static let leading = EdgeSet(rawValue: 1 << 1)
    public static let bottom = EdgeSet(rawValue: 1 << 2)
    public static let trailing = EdgeSet(rawValue: 1 << 3)
    public static let horizontal: EdgeSet = [.leading, .trailing]
    public static let vertical: EdgeSet = [.top, .bottom]
    public static let all: EdgeSet = [.top, .leading, .bottom, .trailing]
}

public enum FrameLimit: Equatable, Sendable {
    case points(GeometryScalar)
    case infinity
}
