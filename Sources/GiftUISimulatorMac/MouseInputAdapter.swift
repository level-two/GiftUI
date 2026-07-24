import AppKit
import GiftUI

enum MouseInputAdapter {
    @MainActor
    static func logicalPoint(
        from event: NSEvent,
        in view: NSView,
        scale: Int
    ) -> Point {
        let location = view.convert(event.locationInWindow, from: nil)
        return Point(
            x: Int(location.x) / scale,
            y: Int(location.y) / scale
        )
    }
}
