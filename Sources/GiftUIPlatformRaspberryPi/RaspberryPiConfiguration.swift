import GiftUI
import GiftUIPlatformLinux

public struct RaspberryPiConfiguration: Equatable, Sendable {
    public var framebufferDevice: String
    public var logicalSize: Size
    public var rotation: DisplayRotation
    public var idleSleepMilliseconds: UInt32
    public var exitAfterInitialFrame: Bool
    public var gpioButtons: GPIOButtonConfiguration?
    public var touchInput: TouchInputConfiguration?

    public init(
        framebufferDevice: String = "/dev/fb1",
        logicalSize: Size = Size(width: 240, height: 240),
        rotation: DisplayRotation = .degrees0,
        idleSleepMilliseconds: UInt32 = 20,
        exitAfterInitialFrame: Bool = false,
        gpioButtons: GPIOButtonConfiguration? = nil,
        touchInput: TouchInputConfiguration? = nil
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
        self.gpioButtons = gpioButtons
        self.touchInput = touchInput
    }

    public init(arguments: [String]) throws {
        var framebufferDevice = "/dev/fb1"
        var width = 240
        var height = 240
        var rotation = DisplayRotation.degrees0
        var idleSleepMilliseconds: UInt32 = 20
        var exitAfterInitialFrame = false
        var gpioEnabled = false
        var gpioChip = "/dev/gpiochip0"
        var gpioPrevious: UInt32 = 17
        var gpioNext: UInt32 = 27
        var gpioActivate: UInt32 = 22
        var gpioActiveLow = true
        var gpioBias = GPIOBias.pullUp
        var gpioDebounceMilliseconds: UInt32 = 35
        var touchEnabled = false
        var touchDevice = "/dev/input/event0"
        var touchSwapXY = false
        var touchInvertX = false
        var touchInvertY = false
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
            case "--gpio-buttons":
                gpioEnabled = true
            case "--gpio-chip":
                gpioEnabled = true
                gpioChip = try Self.value(
                    after: argument,
                    at: &index,
                    in: arguments
                )
                guard !gpioChip.isEmpty else {
                    throw RaspberryPiConfigurationError(
                        "--gpio-chip requires a non-empty path"
                    )
                }
            case "--gpio-previous":
                gpioEnabled = true
                gpioPrevious = try Self.uint32(
                    try Self.value(after: argument, at: &index, in: arguments),
                    option: argument
                )
            case "--gpio-next":
                gpioEnabled = true
                gpioNext = try Self.uint32(
                    try Self.value(after: argument, at: &index, in: arguments),
                    option: argument
                )
            case "--gpio-activate":
                gpioEnabled = true
                gpioActivate = try Self.uint32(
                    try Self.value(after: argument, at: &index, in: arguments),
                    option: argument
                )
            case "--gpio-active-low":
                gpioEnabled = true
                gpioActiveLow = true
            case "--gpio-active-high":
                gpioEnabled = true
                gpioActiveLow = false
            case "--gpio-bias":
                gpioEnabled = true
                let value = try Self.value(
                    after: argument,
                    at: &index,
                    in: arguments
                )
                guard let parsedBias = GPIOBias(rawValue: value) else {
                    throw RaspberryPiConfigurationError(
                        "--gpio-bias must be pull-up or disabled"
                    )
                }
                gpioBias = parsedBias
            case "--gpio-debounce-ms":
                gpioEnabled = true
                let value = try Self.positiveInt(
                    try Self.value(after: argument, at: &index, in: arguments),
                    option: argument
                )
                guard let milliseconds = UInt32(exactly: value) else {
                    throw RaspberryPiConfigurationError(
                        "--gpio-debounce-ms is outside the supported range"
                    )
                }
                gpioDebounceMilliseconds = milliseconds
            case "--touch":
                touchEnabled = true
            case "--touch-device":
                touchEnabled = true
                touchDevice = try Self.value(
                    after: argument,
                    at: &index,
                    in: arguments
                )
                guard !touchDevice.isEmpty else {
                    throw RaspberryPiConfigurationError(
                        "--touch-device requires a non-empty path"
                    )
                }
            case "--touch-swap-xy":
                touchEnabled = true
                touchSwapXY = true
            case "--touch-invert-x":
                touchEnabled = true
                touchInvertX = true
            case "--touch-invert-y":
                touchEnabled = true
                touchInvertY = true
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
        if gpioEnabled {
            guard Set([gpioPrevious, gpioNext, gpioActivate]).count == 3 else {
                throw RaspberryPiConfigurationError(
                    "GPIO previous, next, and activate lines must be distinct"
                )
            }
        }

        let gpioButtons = gpioEnabled ? GPIOButtonConfiguration(
            chipPath: gpioChip,
            previousLine: gpioPrevious,
            nextLine: gpioNext,
            activateLine: gpioActivate,
            activeLow: gpioActiveLow,
            bias: gpioBias,
            debounceMilliseconds: gpioDebounceMilliseconds
        ) : nil
        let touchInput = touchEnabled ? TouchInputConfiguration(
            devicePath: touchDevice,
            swapXY: touchSwapXY,
            invertX: touchInvertX,
            invertY: touchInvertY
        ) : nil

        self.init(
            framebufferDevice: framebufferDevice,
            logicalSize: Size(width: width, height: height),
            rotation: rotation,
            idleSleepMilliseconds: idleSleepMilliseconds,
            exitAfterInitialFrame: exitAfterInitialFrame,
            gpioButtons: gpioButtons,
            touchInput: touchInput
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
          --gpio-buttons     Enable previous/next/activate GPIO buttons.
          --gpio-chip PATH   GPIO character device (default: /dev/gpiochip0).
          --gpio-previous N  Previous button line offset (default: 17).
          --gpio-next N      Next button line offset (default: 27).
          --gpio-activate N  Activate button line offset (default: 22).
          --gpio-active-low  Buttons pull their lines low (default).
          --gpio-active-high Buttons pull their lines high.
          --gpio-bias MODE   pull-up (default) or disabled.
          --gpio-debounce-ms MS
                             Debounce window (default: 35).
          --touch            Enable evdev touchscreen input.
          --touch-device PATH
                             Touch event device (default: /dev/input/event0).
          --touch-swap-xy    Swap touchscreen X and Y axes.
          --touch-invert-x   Invert the mapped touchscreen X axis.
          --touch-invert-y   Invert the mapped touchscreen Y axis.
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

    private static func uint32(
        _ value: String,
        option: String
    ) throws -> UInt32 {
        guard let parsed = UInt32(value) else {
            throw RaspberryPiConfigurationError(
                "\(option) requires a non-negative 32-bit integer"
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
