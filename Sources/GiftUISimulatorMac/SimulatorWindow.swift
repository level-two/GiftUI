import AppKit
import GiftUI

@MainActor
final class SimulatorWindow: NSWindow {
    init(logicalSize: Size, scale: Int) {
        let contentSize = NSSize(
            width: logicalSize.width * scale,
            height: logicalSize.height * scale
        )

        super.init(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        title = "GiftUI Simulator"
        backgroundColor = NSColor(white: 0.04, alpha: 1)
        isReleasedWhenClosed = false
        center()
    }
}
