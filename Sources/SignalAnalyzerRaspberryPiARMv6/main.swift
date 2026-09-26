import GiftUIPlatformRaspberryPi
import SignalAnalyzerPresetHarness
import SignalAnalyzerTargetHost

#if canImport(Darwin)
    import Darwin
#endif

if CommandLine.arguments.dropFirst().contains("--rehearse-host") {
    do {
        try PiHostNativeRehearsal.run()
        print("status=passed\tprofile=raspberry-pi-dynamic\tevidence=host-native-fixture")
    } catch {
        print("status=failed\tprofile=raspberry-pi-dynamic\terror=\(error)")
        exit(1)
    }
    exit(0)
}

#if os(Linux)
    import Glibc
#endif

#if os(Linux)
    if CommandLine.arguments.dropFirst().contains("--run-signal-analyzer") {
        guard case .valid(let assemblyReport) = DynamicSignalAnalyzerPiAssembly.validate() else {
            print("status=failed\terror=invalid-host-assembly")
            exit(EXIT_FAILURE)
        }
        do {
            let console = try LinuxPiScreenConsoleSession()
            let framebuffer = try LinuxPiScreenFramebuffer()
            guard
                let transform = PiScreenAspectFitTransform(
                    physicalWidth: Int32(framebuffer.layout.width),
                    physicalHeight: Int32(framebuffer.layout.height),
                    logicalWidth: 240,
                    logicalHeight: 240
                ),
                let calibration = PiScreenTouchCalibration.signalAnalyzerPiScreen
            else {
                fatalError("PiScreen geometry is invalid")
            }
            let touch = try LinuxPiScreenTouchDevice(
                transform: transform,
                calibration: calibration
            )
            try LinuxSignalAnalyzerPiProcessLoop.run(
                framebuffer: framebuffer,
                touch: touch,
                assemblyReport: assemblyReport
            )
            try console.restore()
            print("status=completed")
            exit(EXIT_SUCCESS)
        } catch {
            print("status=failed\terror=\(error)")
            exit(EXIT_FAILURE)
        }
    }

    if CommandLine.arguments.dropFirst().contains("--exercise-piscreen") {
        do {
            let framebuffer = try LinuxPiScreenFramebuffer()
            guard
                let transform = PiScreenAspectFitTransform(
                    physicalWidth: Int32(framebuffer.layout.width),
                    physicalHeight: Int32(framebuffer.layout.height),
                    logicalWidth: 240,
                    logicalHeight: 240
                ),
                let calibration = PiScreenTouchCalibration.signalAnalyzerPiScreen
            else {
                fatalError("PiScreen geometry is invalid")
            }
            let touch = try LinuxPiScreenTouchDevice(
                transform: transform,
                calibration: calibration
            )
            let report = try LinuxPiScreenExercise.run(
                framebuffer: framebuffer,
                touch: touch
            )
            print(
                "status=completed\tpayloads=\(report.payloads)"
                    + "\tregions=\(report.regions)\tbytes=\(report.bytes)"
                    + "\tcontact-events=\(report.contactEvents)"
            )
            exit(EXIT_SUCCESS)
        } catch {
            print("status=failed\terror=\(error)")
            exit(EXIT_FAILURE)
        }
    }

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
                let calibration = PiScreenTouchCalibration.signalAnalyzerPiScreen
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
