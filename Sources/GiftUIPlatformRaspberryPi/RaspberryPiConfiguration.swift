import GiftUI
import GiftUIPlatformLinux

public struct RaspberryPiConfiguration: Equatable, Sendable {
    public var framebufferDevice: String
    public var logicalSize: Size
    public var rotation: DisplayRotation
    public var idleSleepMilliseconds: UInt32
    public var exitAfterInitialFrame: Bool

    public init(
        framebufferDevice: String = "/dev/fb1",
        logicalSize: Size = Size(width: 240, height: 240),
        rotation: DisplayRotation = .degrees0,
        idleSleepMilliseconds: UInt32 = 20,
        exitAfterInitialFrame: Bool = false
    ) {
        precondition(!framebufferDevice.isEmpty, "Framebuffer device must not be empty")
        precondition(
            logicalSize.width > 0 && logicalSize.height > 0,
            "Logical display dimensions must be positive"
        )
        precondition(
            idleSleepMilliseconds > 0,
            "Idle sleep duration must be positive"
        )
        self.framebufferDevice = framebufferDevice
        self.logicalSize = logicalSize
        self.rotation = rotation
        self.idleSleepMilliseconds = idleSleepMilliseconds
        self.exitAfterInitialFrame = exitAfterInitialFrame
    }

    public init(arguments: [String]) throws {
        var framebufferDevice = "/dev/fb1"
        var width = 240
        var height = 240
        var rotation = DisplayRotation.degrees0
        var idleSleepMilliseconds: UInt32 = 20
        var exitAfterInitialFrame = false
        var index = 0

        while index < arguments.count {
            let argument = arguments[index]
            switch argument {
            case "--display":
                let value = try Self.value(after: argument, at: &index, in: arguments)
                guard value == "fbdev" else {
                    throw RaspberryPiConfigurationError(
                        "unsupported display backend '\(value)'; expected fbdev"
                    )
                }
            case "--device":
                framebufferDevice = try Self.value(
                    after: argument,
                    at: &index,
                    in: arguments
                )
                guard !framebufferDevice.isEmpty else {
                    throw RaspberryPiConfigurationError(
                        "--device requires a non-empty path"
                    )
                }
            case "--width":
                width = try Self.positiveInt(
                    try Self.value(after: argument, at: &index, in: arguments),
                    option: argument
                )
            case "--height":
                height = try Self.positiveInt(
                    try Self.value(after: argument, at: &index, in: arguments),
                    option: argument
                )
            case "--rotation":
                let value = try Self.value(after: argument, at: &index, in: arguments)
                guard
                    let degrees = Int(value),
                    let parsedRotation = DisplayRotation(rawValue: degrees)
                else {
                    throw RaspberryPiConfigurationError(
                        "--rotation must be 0, 90, 180, or 270"
                    )
                }
                rotation = parsedRotation
            case "--idle-ms":
                let value = try Self.positiveInt(
                    try Self.value(after: argument, at: &index, in: arguments),
                    option: argument
                )
                guard let milliseconds = UInt32(exactly: value) else {
                    throw RaspberryPiConfigurationError(
                        "--idle-ms is outside the supported range"
                    )
                }
                idleSleepMilliseconds = milliseconds
            case "--once":
                exitAfterInitialFrame = true
            default:
                throw RaspberryPiConfigurationError(
                    "unknown argument '\(argument)'"
                )
            }
            index += 1
        }

        guard Int32(exactly: width) != nil, Int32(exactly: height) != nil else {
            throw RaspberryPiConfigurationError(
                "logical display dimensions exceed Linux limits"
            )
        }

        self.init(
            framebufferDevice: framebufferDevice,
            logicalSize: Size(width: width, height: height),
            rotation: rotation,
            idleSleepMilliseconds: idleSleepMilliseconds,
            exitAfterInitialFrame: exitAfterInitialFrame
        )
    }

    public static let usage = """
        Usage: GiftUIExampleThermostatRaspberryPi [options]

          --display fbdev    Use a Linux-managed framebuffer device (default).
          --device PATH      Framebuffer path (default: /dev/fb1).
          --width PIXELS     Logical GiftUI width (default: 240).
          --height PIXELS    Logical GiftUI height (default: 240).
          --rotation DEG     Clockwise output rotation: 0, 90, 180, or 270.
          --idle-ms MS       Idle-loop sleep duration (default: 20).
          --once             Present one frame and exit.
          -h, --help         Show this help.
        """

    private static func value(
        after option: String,
        at index: inout Int,
        in arguments: [String]
    ) throws -> String {
        index += 1
        guard index < arguments.count else {
            throw RaspberryPiConfigurationError("\(option) requires a value")
        }
        return arguments[index]
    }

    private static func positiveInt(
        _ value: String,
        option: String
    ) throws -> Int {
        guard let parsed = Int(value), parsed > 0 else {
            throw RaspberryPiConfigurationError(
                "\(option) requires a positive integer"
            )
        }
        return parsed
    }
}

public struct RaspberryPiConfigurationError:
    Error,
    CustomStringConvertible,
    Equatable,
    Sendable
{
    public let description: String

    public init(_ description: String) {
        self.description = description
    }
}
