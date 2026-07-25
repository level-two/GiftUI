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
