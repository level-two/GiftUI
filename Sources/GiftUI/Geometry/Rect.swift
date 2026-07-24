public struct Rect: Equatable, Hashable, Sendable {
    public var origin: Point
    public var size: Size

    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }

    public func contains(_ point: Point) -> Bool {
        point.x >= origin.x
            && point.y >= origin.y
            && point.x < origin.x + size.width
            && point.y < origin.y + size.height
    }
}
