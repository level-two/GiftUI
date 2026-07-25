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

    public func run<Root: View>(root: Root) throws {
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

        let application = GiftUILinuxApplication(
            root: root,
            display: display,
            configuration: LinuxApplicationConfiguration(
                idleSleepMilliseconds: configuration.idleSleepMilliseconds,
                exitAfterInitialFrame: configuration.exitAfterInitialFrame
            ),
            logger: logger
        )
        try application.run()
    }
}
