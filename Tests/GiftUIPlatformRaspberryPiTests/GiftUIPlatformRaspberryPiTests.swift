import GiftUI
import GiftUIPlatformLinux
import GiftUIPlatformRaspberryPi
import Testing

@Test
func raspberryPiConfigurationUsesPiScreenDefaults() throws {
    let configuration = try RaspberryPiConfiguration(arguments: [])

    #expect(configuration.framebufferDevice == "/dev/fb1")
    #expect(configuration.logicalSize == Size(width: 240, height: 240))
    #expect(configuration.rotation == .degrees0)
    #expect(configuration.idleSleepMilliseconds == 20)
    #expect(!configuration.exitAfterInitialFrame)
    #expect(configuration.gpioButtons == nil)
    #expect(configuration.touchInput == nil)
}

@Test
func raspberryPiConfigurationParsesTouchInput() throws {
    let configuration = try RaspberryPiConfiguration(arguments: [
        "--touch-device", "/dev/input/by-path/piscreen-event",
        "--touch-swap-xy",
        "--touch-invert-x",
        "--touch-invert-y",
    ])

    let touch = try #require(configuration.touchInput)
    #expect(touch.devicePath == "/dev/input/by-path/piscreen-event")
    #expect(touch.swapXY)
    #expect(touch.invertX)
    #expect(touch.invertY)
}

@Test
func raspberryPiConfigurationRejectsEmptyTouchDevice() {
    #expect(throws: RaspberryPiConfigurationError.self) {
        _ = try RaspberryPiConfiguration(arguments: [
            "--touch-device", "",
        ])
    }
}

@Test
func touchCoordinatesFollowAspectFitContent() {
    let mapper = TouchCoordinateMapper(
        xRange: TouchAxisRange(minimum: 0, maximum: 479),
        yRange: TouchAxisRange(minimum: 0, maximum: 319),
        physicalSize: Size(width: 480, height: 320),
        logicalSize: Size(width: 240, height: 240)
    )

    #expect(mapper.point(rawX: 79, rawY: 160) == nil)
    #expect(mapper.point(rawX: 80, rawY: 0) == Point(x: 0, y: 0))
    #expect(mapper.point(rawX: 399, rawY: 319) == Point(x: 239, y: 239))
    #expect(mapper.point(rawX: 400, rawY: 160) == nil)
}

@Test
func touchCoordinatesInvertFramebufferRotation() {
    let range = TouchAxisRange(minimum: 0, maximum: 239)
    let mapper = TouchCoordinateMapper(
        xRange: range,
        yRange: range,
        physicalSize: Size(width: 240, height: 240),
        logicalSize: Size(width: 240, height: 240),
        rotation: .degrees90
    )

    #expect(mapper.point(rawX: 0, rawY: 0) == Point(x: 0, y: 239))
    #expect(mapper.point(rawX: 239, rawY: 0) == Point(x: 0, y: 0))
    #expect(mapper.point(rawX: 0, rawY: 239) == Point(x: 239, y: 239))
    #expect(mapper.point(rawX: 239, rawY: 239) == Point(x: 239, y: 0))
}

@Test
func touchCoordinatesApplyAxisCalibration() {
    let range = TouchAxisRange(minimum: 0, maximum: 99)
    let mapper = TouchCoordinateMapper(
        xRange: range,
        yRange: range,
        physicalSize: Size(width: 100, height: 100),
        logicalSize: Size(width: 100, height: 100),
        swapXY: true,
        invertX: true,
        invertY: true
    )

    #expect(mapper.point(rawX: 10, rawY: 20) == Point(x: 79, y: 89))
}

@Test
func raspberryPiConfigurationParsesGPIOButtons() throws {
    let configuration = try RaspberryPiConfiguration(arguments: [
        "--gpio-buttons",
        "--gpio-chip", "/dev/gpiochip4",
        "--gpio-previous", "5",
        "--gpio-next", "6",
        "--gpio-activate", "13",
        "--gpio-active-high",
        "--gpio-bias", "disabled",
        "--gpio-debounce-ms", "50",
    ])

    let gpio = try #require(configuration.gpioButtons)
    #expect(gpio.chipPath == "/dev/gpiochip4")
    #expect(gpio.lineOffsets == [5, 6, 13])
    #expect(!gpio.activeLow)
    #expect(gpio.bias == .disabled)
    #expect(gpio.debounceMilliseconds == 50)
}

@Test
func raspberryPiConfigurationRejectsDuplicateGPIOLines() {
    #expect(throws: RaspberryPiConfigurationError.self) {
        _ = try RaspberryPiConfiguration(arguments: [
            "--gpio-previous", "17",
            "--gpio-next", "17",
        ])
    }
}

@Test
func gpioDebouncerIsPerButtonAndUsesInclusiveBoundary() {
    var debouncer = GPIOButtonDebouncer(debounceMilliseconds: 35)

    let firstPrevious = debouncer.accepts(
        .previous,
        timestampNanoseconds: 1_000_000_000
    )
    let bouncedPrevious = debouncer.accepts(
        .previous,
        timestampNanoseconds: 1_034_999_999
    )
    let independentNext = debouncer.accepts(
        .next,
        timestampNanoseconds: 1_010_000_000
    )
    let boundaryPrevious = debouncer.accepts(
        .previous,
        timestampNanoseconds: 1_035_000_000
    )

    #expect(firstPrevious)
    #expect(!bouncedPrevious)
    #expect(independentNext)
    #expect(boundaryPrevious)
}

@Test
func gpioDebouncerRecoversFromTimestampRegression() {
    var debouncer = GPIOButtonDebouncer(debounceMilliseconds: 35)

    let initial = debouncer.accepts(
        .activate,
        timestampNanoseconds: 100_000_000
    )
    let afterRegression = debouncer.accepts(
        .activate,
        timestampNanoseconds: 10_000_000
    )
    let bounce = debouncer.accepts(
        .activate,
        timestampNanoseconds: 20_000_000
    )

    #expect(initial)
    #expect(afterRegression)
    #expect(!bounce)
}

@Test
func raspberryPiConfigurationParsesFramebufferOptions() throws {
    let configuration = try RaspberryPiConfiguration(arguments: [
        "--display", "fbdev",
        "--device", "/dev/fb0",
        "--width", "320",
        "--height", "240",
        "--rotation", "90",
        "--idle-ms", "35",
        "--once",
    ])

    #expect(configuration.framebufferDevice == "/dev/fb0")
    #expect(configuration.logicalSize == Size(width: 320, height: 240))
    #expect(configuration.rotation == .degrees90)
    #expect(configuration.idleSleepMilliseconds == 35)
    #expect(configuration.exitAfterInitialFrame)
}

@Test
func raspberryPiConfigurationRejectsUnsupportedDisplay() {
    #expect(throws: RaspberryPiConfigurationError.self) {
        _ = try RaspberryPiConfiguration(arguments: [
            "--display", "spi",
        ])
    }
}

@Test
func raspberryPiConfigurationRejectsInvalidRotation() {
    #expect(throws: RaspberryPiConfigurationError.self) {
        _ = try RaspberryPiConfiguration(arguments: [
            "--rotation", "45",
        ])
    }
}
