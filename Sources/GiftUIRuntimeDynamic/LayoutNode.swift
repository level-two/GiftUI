import GiftUI

public struct LayoutNode: Equatable, Sendable {
    public var frame: Rect
    public var children: [LayoutNode]

    public init(frame: Rect, children: [LayoutNode] = []) {
        self.frame = frame
        self.children = children
    }
}
