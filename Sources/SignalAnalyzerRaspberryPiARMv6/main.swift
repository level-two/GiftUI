import GiftUIPlatformRaspberryPi
import SignalAnalyzerPresetHarness

#if os(Linux)
    import Glibc
#endif

#if os(Linux)
    if CommandLine.arguments.dropFirst().contains("--inspect-piscreen") {
        do {
            let framebuffer = try LinuxPiScreenFramebuffer()
            guard
                let transform = PiScreenAspectFitTransform(
                    physicalWidth: Int32(framebuffer.layout.width),
                    physicalHeight: Int32(framebuffer.layout.height),
                    logicalWidth: 240,
                    logicalHeight: 240
                ),
                let calibration = PiScreenTouchCalibration(
                    minimumX: 0,
                    maximumX: 4_095,
                    minimumY: 0,
                    maximumY: 4_095
                )
            else {
                fatalError("PiScreen geometry is invalid")
            }
            _ = try LinuxPiScreenTouchDevice(
                transform: transform,
                calibration: calibration
            )
            print(
                "status=ready\tframebuffer=\(framebuffer.layout.width)x\(framebuffer.layout.height)"
                    + "\tbpp=\(framebuffer.layout.bitsPerPixel)"
                    + "\tstride=\(framebuffer.layout.bytesPerRow)\ttouch=/dev/input/event0"
            )
            exit(EXIT_SUCCESS)
        } catch {
            print("status=failed\terror=\(error)")
            exit(EXIT_FAILURE)
        }
    }
#endif

do {
    let report = try HardwareFreePresetRunner.run(.raspberryPiDynamic)
    print(report.normalizedLine)
} catch {
    print("status=failed\terror=\(error)")
    fatalError("Raspberry Pi ARMv6 hardware-free preset failed")
}
