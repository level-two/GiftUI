public struct HitRegion: Equatable, Sendable {
    public var bounds: Rect
    public var action: ActionID

    public init(bounds: Rect, action: ActionID) {
        self.bounds = bounds
        self.action = action
    }
}
