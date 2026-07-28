import GiftUI
import GiftUIPlatformLinux

public final class RaspberryPiPlatform {
    public let configuration: RaspberryPiConfiguration

    private let logger: (String) -> Void

    public init(
        configuration: RaspberryPiConfiguration = RaspberryPiConfiguration(),
        logger: @escaping (String) -> Void = { print($0) }
    ) {
        self.configuration = configuration
        self.logger = logger
    }

    public func run<Root: View>(
        root: Root,
        identifiedActionHandler: ((ActionID) -> Void)? = nil
    ) throws {
        let display = try LinuxFramebufferDisplaySurface(
            devicePath: configuration.framebufferDevice,
            logicalSize: configuration.logicalSize,
            rotation: configuration.rotation
        )
        logger(
            "GiftUI Raspberry Pi framebuffer \(configuration.framebufferDevice): "
                + "\(display.physicalWidth)x\(display.physicalHeight), "
                + "\(display.bitsPerPixel) bpp, "
                + "rotation \(configuration.rotation.rawValue)°"
        )

        var inputSources: [any LinuxInputSource] = []
        if let touchConfiguration = configuration.touchInput {
            let touchInput = try TouchInputSource(
                configuration: touchConfiguration,
                physicalSize: Size(
                    width: display.physicalWidth,
                    height: display.physicalHeight
                ),
                logicalSize: configuration.logicalSize,
                rotation: configuration.rotation
            )
            inputSources.append(touchInput)
            logger(
                "GiftUI Raspberry Pi touch \(touchConfiguration.devicePath): "
                    + "x=\(touchInput.xRange.minimum)...\(touchInput.xRange.maximum), "
                    + "y=\(touchInput.yRange.minimum)...\(touchInput.yRange.maximum), "
                    + "swapXY=\(touchConfiguration.swapXY), "
                    + "invertX=\(touchConfiguration.invertX), "
                    + "invertY=\(touchConfiguration.invertY)"
            )
        }

        var navigationInputSources: [any LinuxNavigationInputSource] = []
        if let gpioConfiguration = configuration.gpioButtons {
            navigationInputSources.append(
                try GPIOInputSource(configuration: gpioConfiguration)
            )
            logger(
                "GiftUI Raspberry Pi GPIO \(gpioConfiguration.chipPath): "
                    + "previous=\(gpioConfiguration.previousLine), "
                    + "next=\(gpioConfiguration.nextLine), "
                    + "activate=\(gpioConfiguration.activateLine), "
                    + "debounce=\(gpioConfiguration.debounceMilliseconds) ms"
            )
        }

        let application = GiftUILinuxApplication(
            root: root,
            display: display,
            inputSources: inputSources,
            navigationInputSources: navigationInputSources,
            identifiedActionHandler: identifiedActionHandler,
            configuration: LinuxApplicationConfiguration(
                idleSleepMilliseconds: configuration.idleSleepMilliseconds,
                exitAfterInitialFrame: configuration.exitAfterInitialFrame
            ),
            logger: logger
        )
        logger(
            "GiftUI Raspberry Pi renderer: "
                + (application.usesRGB565TileRenderer
                    ? "bounded RGB565 tiles"
                    : "RGBA8888 compatibility framebuffer")
                + ", pixel buffer \(application.pixelBufferByteCapacity) bytes"
        )
        try application.run()
    }
}
