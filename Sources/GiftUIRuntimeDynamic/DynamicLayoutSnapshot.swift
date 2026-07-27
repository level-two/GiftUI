import GiftUI

public struct DynamicLayoutSnapshot: Equatable, Sendable {
    public let layout: LayoutNode
    public let identifiedHitRegions: [HitRegion]

    package init(layout: LayoutNode, identifiedHitRegions: [HitRegion]) {
        self.layout = layout
        self.identifiedHitRegions = identifiedHitRegions
    }

    public func action(at point: Point) -> ActionID? {
        identifiedHitRegions.last { $0.bounds.contains(point) }?.action
    }
}
