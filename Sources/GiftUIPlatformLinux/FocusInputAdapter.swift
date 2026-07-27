import GiftUI

public struct FocusInputAdapter: Sendable {
    public private(set) var focusedIndex: Int?

    public init() {}

    public mutating func synchronize(with hitRegions: [HitRegion]) {
        guard !hitRegions.isEmpty else {
            focusedIndex = nil
            return
        }
        focusedIndex = min(focusedIndex ?? 0, hitRegions.count - 1)
    }

    public mutating func events(
        for input: NavigationInput,
        hitRegions: [HitRegion]
    ) -> [InputEvent] {
        synchronize(with: hitRegions)
        guard let focusedIndex else { return [] }

        switch input {
        case .previous:
            self.focusedIndex = (
                focusedIndex + hitRegions.count - 1
            ) % hitRegions.count
            return []
        case .next:
            self.focusedIndex = (focusedIndex + 1) % hitRegions.count
            return []
        case .activate:
            let bounds = hitRegions[focusedIndex].bounds
            let point = Point(
                x: bounds.origin.x + bounds.size.width / 2,
                y: bounds.origin.y + bounds.size.height / 2
            )
            return [
                .pointerDown(point),
                .pointerUp(point),
            ]
        }
    }
}
