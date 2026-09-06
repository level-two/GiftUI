public struct Color: Equatable, Hashable, Sendable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public static let black = Color(red: 0, green: 0, blue: 0)
    public static let white = Color(red: 255, green: 255, blue: 255)
    public static let red = Color(red: 255, green: 0, blue: 0)
    public static let green = Color(red: 0, green: 255, blue: 0)
    public static let blue = Color(red: 0, green: 0, blue: 255)
    public static let gray = Color(red: 128, green: 128, blue: 128)
}
