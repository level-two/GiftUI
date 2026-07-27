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
