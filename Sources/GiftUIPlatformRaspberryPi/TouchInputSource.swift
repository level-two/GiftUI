import CGiftUILinux
import GiftUI
import GiftUIPlatformLinux

public final class TouchInputSource: LinuxInputSource {
    public let configuration: TouchInputConfiguration
    public let xRange: TouchAxisRange
    public let yRange: TouchAxisRange

    private let input: OpaquePointer
    private let mapper: TouchCoordinateMapper
    private var activeContact = false

    public init(
        configuration: TouchInputConfiguration,
        physicalSize: Size,
        logicalSize: Size,
        rotation: DisplayRotation
    ) throws {
        var openedInput: OpaquePointer?
        var errorBuffer = [CChar](repeating: 0, count: 256)
        let result = errorBuffer.withUnsafeMutableBufferPointer { errorPointer in
            configuration.devicePath.withCString { devicePath in
                giftui_touch_open(
                    devicePath,
                    &openedInput,
                    errorPointer.baseAddress,
                    errorPointer.count
                )
            }
        }
        guard result == 0, let openedInput else {
            throw LinuxPlatformError(Self.message(from: errorBuffer))
        }

        let xRange = TouchAxisRange(
            minimum: Int(giftui_touch_minimum_x(openedInput)),
            maximum: Int(giftui_touch_maximum_x(openedInput))
        )
        let yRange = TouchAxisRange(
            minimum: Int(giftui_touch_minimum_y(openedInput)),
            maximum: Int(giftui_touch_maximum_y(openedInput))
        )
        input = openedInput
        self.configuration = configuration
        self.xRange = xRange
        self.yRange = yRange
        mapper = TouchCoordinateMapper(
            xRange: xRange,
            yRange: yRange,
            physicalSize: physicalSize,
            logicalSize: logicalSize,
            rotation: rotation,
            swapXY: configuration.swapXY,
            invertX: configuration.invertX,
            invertY: configuration.invertY
        )
    }

    deinit {
        giftui_touch_close(input)
    }

    public func poll() throws -> [InputEvent] {
        var rawEvents = [GiftUITouchEvent](
            repeating: GiftUITouchEvent(x: 0, y: 0, kind: 0),
            count: 32
        )
        var eventCount = 0
        var errorBuffer = [CChar](repeating: 0, count: 256)
        let result = rawEvents.withUnsafeMutableBufferPointer { eventPointer in
            errorBuffer.withUnsafeMutableBufferPointer { errorPointer in
                giftui_touch_poll(
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

        var events: [InputEvent] = []
        events.reserveCapacity(eventCount)
        for rawEvent in rawEvents.prefix(eventCount) {
            let point = mapper.point(
                rawX: Int(rawEvent.x),
                rawY: Int(rawEvent.y)
            )
            switch rawEvent.kind {
            case UInt32(GIFTUI_TOUCH_DOWN):
                guard let point else { continue }
                activeContact = true
                events.append(.pointerDown(point))
            case UInt32(GIFTUI_TOUCH_MOVE):
                guard activeContact else { continue }
                events.append(.pointerMove(point ?? Point(x: -1, y: -1)))
            case UInt32(GIFTUI_TOUCH_UP):
                guard activeContact else { continue }
                activeContact = false
                events.append(.pointerUp(point ?? Point(x: -1, y: -1)))
            default:
                continue
            }
        }
        return events
    }

    private static func message(from buffer: [CChar]) -> String {
        buffer.withUnsafeBufferPointer { pointer in
            guard let baseAddress = pointer.baseAddress, baseAddress.pointee != 0 else {
                return "unknown touch input error"
            }
            return String(cString: baseAddress)
        }
    }
}
