import AppKit
import CoreGraphics

@MainActor
final class FramebufferView: NSView {
    var frameImage: CGImage? {
        didSet {
            needsDisplay = true
        }
    }

    init(frame: NSRect, frameImage: CGImage?) {
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
}
