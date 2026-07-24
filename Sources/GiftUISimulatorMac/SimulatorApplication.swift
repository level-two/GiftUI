import AppKit
import GiftUI
import GiftUIBackendFramebuffer

@MainActor
public final class GiftUISimulator<Root: View> {
    private let root: Root
    private let logicalSize: Size
    private let scale: Int
    private var window: SimulatorWindow?

    public init(
        root: Root,
        logicalSize: Size = Size(width: 240, height: 240),
        scale: Int = 3
    ) {
        precondition(scale > 0, "Simulator scale must be positive")
        self.root = root
        self.logicalSize = logicalSize
        self.scale = scale
    }

    public func run() {
        let application = NSApplication.shared
        application.setActivationPolicy(.regular)

        var backend = FramebufferBackend(
            surface: MemoryFramebufferSurface(
                width: logicalSize.width,
                height: logicalSize.height
            )
        )
        drawScaffoldFrame(into: &backend)

        let window = SimulatorWindow(
            logicalSize: logicalSize,
            scale: scale
        )
        let contentFrame = NSRect(
            x: 0,
            y: 0,
            width: logicalSize.width * scale,
            height: logicalSize.height * scale
        )
        window.contentView = FramebufferView(
            frame: contentFrame,
            frameImage: FramePresenter.makeImage(from: backend.surface)
        )
        window.makeKeyAndOrderFront(nil)
        self.window = window

        application.activate(ignoringOtherApps: true)
        application.run()
    }

    private func drawScaffoldFrame(
        into backend: inout FramebufferBackend
    ) {
        _ = root
        backend.beginFrame()
        backend.clear(Color(red: 24, green: 26, blue: 32))
        backend.stroke(
            Rect(
                origin: Point(x: 48, y: 56),
                size: Size(width: 144, height: 128)
            ),
            color: Color(red: 116, green: 130, blue: 160),
            lineWidth: 2
        )
        backend.fill(
            Rect(
                origin: Point(x: 72, y: 132),
                size: Size(width: 40, height: 28)
            ),
            color: Color(red: 62, green: 68, blue: 82)
        )
        backend.fill(
            Rect(
                origin: Point(x: 128, y: 132),
                size: Size(width: 40, height: 28)
            ),
            color: Color(red: 62, green: 68, blue: 82)
        )
        backend.endFrame()
        backend.present()
    }
}
