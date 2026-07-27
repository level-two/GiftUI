import CGiftUILinux
import GiftUI
import GiftUIBackendFramebuffer
import GiftUIRuntimeDynamic

public final class GiftUILinuxApplication<Root: View> {
    public private(set) var frameCount = 0
    public var hitRegions: [HitRegion] {
        application.hitRegions
    }
    public var focusedHitRegionIndex: Int? {
        focusInputAdapter.focusedIndex
    }

    private let display: any DisplaySurface
    private let inputSources: [any LinuxInputSource]
    private let navigationInputSources: [any LinuxNavigationInputSource]
    private let configuration: LinuxApplicationConfiguration
    private let logger: (String) -> Void
    private let application: GiftUIApplication<Root>
    private var backend: FramebufferBackend
    private var focusInputAdapter = FocusInputAdapter()

    public init(
        root: Root,
        display: any DisplaySurface,
        inputSources: [any LinuxInputSource] = [],
        navigationInputSources: [any LinuxNavigationInputSource] = [],
        runtime: DynamicRuntime = DynamicRuntime(),
        identifiedActionHandler: ((ActionID) -> Void)? = nil,
        configuration: LinuxApplicationConfiguration = LinuxApplicationConfiguration(),
        logger: @escaping (String) -> Void = { print($0) }
    ) {
        self.display = display
        self.inputSources = inputSources
        self.navigationInputSources = navigationInputSources
        self.configuration = configuration
        self.logger = logger
        application = GiftUIApplication(
            root: root,
            runtime: runtime,
            identifiedActionHandler: identifiedActionHandler
        )
        backend = FramebufferBackend(
            surface: MemoryFramebufferSurface(
                width: display.logicalSize.width,
                height: display.logicalSize.height
            )
        )
    }

    @discardableResult
    public func send(_ event: InputEvent) -> Bool {
        application.send(event)
    }

    @discardableResult
    public func runCycle() throws -> Bool {
        var focusChanged = false
        for inputSource in inputSources {
            for event in try inputSource.poll() {
                application.send(event)
            }
        }
        for inputSource in navigationInputSources {
            for navigation in try inputSource.pollNavigation() {
                let previousFocus = focusInputAdapter.focusedIndex
                for event in focusInputAdapter.events(
                    for: navigation,
                    hitRegions: application.hitRegions
                ) {
                    application.send(event)
                }
                focusChanged = focusChanged
                    || focusInputAdapter.focusedIndex != previousFocus
            }
        }
        if focusChanged {
            application.runtime.invalidate()
        }

        guard application.renderIfNeeded(into: &backend) else {
            return false
        }
        focusInputAdapter.synchronize(with: application.hitRegions)
        drawFocusIndicatorIfNeeded()
        try display.present(framebuffer: backend.surface)
        frameCount += 1
        return true
    }

    private func drawFocusIndicatorIfNeeded() {
        guard
            !navigationInputSources.isEmpty,
            let focusedIndex = focusInputAdapter.focusedIndex,
            application.hitRegions.indices.contains(focusedIndex)
        else {
            return
        }
        backend.stroke(
            application.hitRegions[focusedIndex].bounds,
            color: Color(red: 255, green: 196, blue: 64),
            lineWidth: 2
        )
    }

    public func run() throws {
        guard giftui_linux_is_supported() != 0 else {
            throw LinuxPlatformError(
                "GiftUILinuxApplication requires a Linux runtime"
            )
        }

        var errorBuffer = [CChar](repeating: 0, count: 256)
        let signalResult = errorBuffer.withUnsafeMutableBufferPointer { pointer in
            giftui_linux_install_signal_handlers(
                pointer.baseAddress,
                pointer.count
            )
        }
        guard signalResult == 0 else {
            throw LinuxPlatformError(Self.message(from: errorBuffer))
        }

        giftui_linux_reset_termination()
        logger(
            "GiftUI Linux application started at "
                + "\(display.logicalSize.width)x\(display.logicalSize.height)"
        )

        while giftui_linux_should_terminate() == 0 {
            let rendered = try runCycle()
            if configuration.exitAfterInitialFrame, frameCount > 0 {
                break
            }
            if !rendered {
                giftui_linux_sleep_milliseconds(
                    configuration.idleSleepMilliseconds
                )
            }
        }

        logger("GiftUI Linux application stopped after \(frameCount) frame(s)")
    }

    private static func message(from buffer: [CChar]) -> String {
        buffer.withUnsafeBufferPointer { pointer in
            guard let baseAddress = pointer.baseAddress, baseAddress.pointee != 0 else {
                return "unknown Linux platform error"
            }
            return String(cString: baseAddress)
        }
    }
}
