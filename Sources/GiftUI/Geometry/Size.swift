public struct Size: Equatable, Hashable, Sendable {
    public var width: Int
    public var height: Int

    public init(width: Int, height: Int) {
        precondition(width >= 0 && height >= 0, "Size dimensions must not be negative")
        self.width = width
        self.height = height
    }
}
