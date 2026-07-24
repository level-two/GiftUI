import AppKit
import CoreGraphics
import GiftUI

@MainActor
final class FramebufferView: NSView {
    let scale: Int
    var onInput: ((InputEvent) -> Void)?

    var frameImage: CGImage? {
        didSet {
            needsDisplay = true
        }
    }

    init(
        frame: NSRect,
        frameImage: CGImage?,
        scale: Int
    ) {
        self.scale = scale
        self.frameImage = frameImage
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isFlipped: Bool {
        true
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    override func mouseDown(with event: NSEvent) {
        onInput?(.pointerDown(logicalPoint(from: event)))
    }

    override func mouseDragged(with event: NSEvent) {
        onInput?(.pointerMove(logicalPoint(from: event)))
    }

    override func mouseUp(with event: NSEvent) {
        onInput?(.pointerUp(logicalPoint(from: event)))
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor(white: 0.08, alpha: 1).setFill()
        dirtyRect.fill()

        guard
            let frameImage,
            let context = NSGraphicsContext.current?.cgContext
        else {
            return
        }

        context.interpolationQuality = .none
        context.draw(frameImage, in: bounds)
    }

    private func logicalPoint(from event: NSEvent) -> Point {
        MouseInputAdapter.logicalPoint(
            from: event,
            in: self,
            scale: scale
        )
    }
}
