import AppKit
import GiftUI
import GiftUIBackendFramebuffer
import GiftUIRuntimeDynamic

@MainActor
public final class GiftUISimulator<Root: View> {
    private let root: Root
    private let logicalSize: Size
    private let scale: Int
    private var window: SimulatorWindow?
    private var framebufferView: FramebufferView?
    private var backend: FramebufferBackend?
    private var application: GiftUIApplication<Root>?

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
        let giftUIApplication = GiftUIApplication(root: root)
        giftUIApplication.renderIfNeeded(into: &backend)

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
        let framebufferView = FramebufferView(
            frame: contentFrame,
            frameImage: FramePresenter.makeImage(from: backend.surface),
            scale: scale
        )
        framebufferView.onInput = { [weak self] event in
            self?.send(event)
        }
        window.contentView = framebufferView
        window.makeFirstResponder(framebufferView)
        window.makeKeyAndOrderFront(nil)
        self.window = window
        self.framebufferView = framebufferView
        self.backend = backend
        self.application = giftUIApplication

        application.activate(ignoringOtherApps: true)
        application.run()
    }

    private func send(_ event: InputEvent) {
        guard
            let application,
            var backend
        else {
            return
        }

        application.send(event)
        if application.renderIfNeeded(into: &backend) {
            self.backend = backend
            framebufferView?.frameImage = FramePresenter.makeImage(
                from: backend.surface
            )
        }
    }
}
