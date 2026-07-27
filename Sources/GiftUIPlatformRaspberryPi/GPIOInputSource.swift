import CGiftUILinux
import GiftUIPlatformLinux

public final class GPIOInputSource: LinuxNavigationInputSource {
    public let configuration: GPIOButtonConfiguration

    private let input: OpaquePointer
    private var debouncer: GPIOButtonDebouncer

    public init(configuration: GPIOButtonConfiguration) throws {
        var openedInput: OpaquePointer?
        var lineOffsets = configuration.lineOffsets
        var errorBuffer = [CChar](repeating: 0, count: 256)
        let result = lineOffsets.withUnsafeMutableBufferPointer { linePointer in
            errorBuffer.withUnsafeMutableBufferPointer { errorPointer in
                configuration.chipPath.withCString { chipPath in
                    giftui_gpio_open(
                        chipPath,
                        linePointer.baseAddress,
                        linePointer.count,
                        configuration.bias == .pullUp ? 1 : 0,
                        &openedInput,
                        errorPointer.baseAddress,
                        errorPointer.count
                    )
                }
            }
        }
        guard result == 0, let openedInput else {
            throw LinuxPlatformError(Self.message(from: errorBuffer))
        }

        input = openedInput
        self.configuration = configuration
        debouncer = GPIOButtonDebouncer(
            debounceMilliseconds: configuration.debounceMilliseconds
        )
    }

    deinit {
        giftui_gpio_close(input)
    }

    public func pollNavigation() throws -> [NavigationInput] {
        var rawEvents = [GiftUIGPIOEvent](
            repeating: GiftUIGPIOEvent(
                line_index: 0,
                edge: 0,
                timestamp_nanoseconds: 0
            ),
            count: 16
        )
        var eventCount = 0
        var errorBuffer = [CChar](repeating: 0, count: 256)
        let result = rawEvents.withUnsafeMutableBufferPointer { eventPointer in
            errorBuffer.withUnsafeMutableBufferPointer { errorPointer in
                giftui_gpio_poll(
                    input,
                    eventPointer.baseAddress,
                    eventPointer.count,
                    &eventCount,
                    errorPointer.baseAddress,
                    errorPointer.count
                )
            }
        }
        guard result == 0 else {
            throw LinuxPlatformError(Self.message(from: errorBuffer))
        }

        let pressedEdge = configuration.activeLow
            ? UInt32(GIFTUI_GPIO_EDGE_FALLING)
            : UInt32(GIFTUI_GPIO_EDGE_RISING)
        var navigationEvents: [NavigationInput] = []
        navigationEvents.reserveCapacity(eventCount)

        for rawEvent in rawEvents.prefix(eventCount) {
            guard
                rawEvent.edge == pressedEdge,
                let button = GPIOButton(rawValue: Int(rawEvent.line_index)),
                debouncer.accepts(
                    button,
                    timestampNanoseconds: rawEvent.timestamp_nanoseconds
                )
            else {
                continue
            }

            switch button {
            case .previous:
                navigationEvents.append(.previous)
            case .next:
                navigationEvents.append(.next)
            case .activate:
                navigationEvents.append(.activate)
            }
        }
        return navigationEvents
    }

    private static func message(from buffer: [CChar]) -> String {
        buffer.withUnsafeBufferPointer { pointer in
            guard let baseAddress = pointer.baseAddress, baseAddress.pointee != 0 else {
                return "unknown GPIO input error"
            }
            return String(cString: baseAddress)
        }
    }
}
