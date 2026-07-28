import GiftUI

public struct HitTestMap: Equatable, Sendable {
    public private(set) var regions: [HitRegion]

    public init(regions: [HitRegion] = []) {
        self.regions = regions
    }

    public func action(at point: Point) -> ActionID? {
        regions.last { $0.bounds.contains(point) }?.action
    }
}

package struct InteractionSnapshot {
    package var hitTestMap: HitTestMap
    package var actions: [ActionID: ButtonAction]

    package init(
        hitTestMap: HitTestMap = HitTestMap(),
        actions: [ActionID: ButtonAction] = [:]
    ) {
        self.hitTestMap = hitTestMap
        self.actions = actions
    }

    package func action(at point: Point) -> ActionID? {
        hitTestMap.action(at: point)
    }

    package func perform(
        _ action: ActionID,
        identifiedActionHandler: ((ActionID) -> Void)? = nil
    ) -> Bool {
        guard let action = actions[action] else {
            return false
        }

        switch action.storage {
        case .identified(let identifier):
            guard let identifiedActionHandler else { return false }
            identifiedActionHandler(identifier)
            return true
        #if !hasFeature(Embedded)
        case .callback(let callback):
            callback()
            return true
        #endif
        }
    }
}
