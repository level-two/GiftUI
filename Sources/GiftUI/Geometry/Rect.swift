public struct Rect: Equatable, Hashable, Sendable {
    public var origin: Point
    public var size: Size

    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }

    public func contains(_ point: Point) -> Bool {
        guard point.x >= origin.x, point.y >= origin.y else {
            return false
        }
        guard
            let relativeX = try? LayoutArithmetic.subtract(point.x, origin.x),
            let relativeY = try? LayoutArithmetic.subtract(point.y, origin.y)
        else {
            return false
        }
        return relativeX < size.width && relativeY < size.height
    }
}
