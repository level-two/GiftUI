import GiftUI
import GiftUIHostConfiguration
import GiftUIPlatformRaspberryPi
import SignalAnalyzerData
import SignalAnalyzerTargetHost

private final class PiRecordingDevice: PiScreenFramebufferSink {
    var payloads = 0
    var bytes = 0
    var regions = 0
    var clock: UInt64 = 0

    func presentRGB565BigEndian(
        bytes: UnsafeRawBufferPointer,
        regions: [PiScreenPayloadRegion],
        transform: PiScreenAspectFitTransform
    ) -> Bool {
        guard transform.logicalWidth == 240, transform.logicalHeight == 240
        else { return false }
        payloads += 1
        self.bytes += bytes.count
        self.regions += regions.count
        clock = 1_000_000
        return true
    }
}

enum PiHostNativeRehearsalError: Error {
    case invalidAssembly
    case invalidDisplay
    case activation
    case missingFrame
    case teardown
}

enum PiHostNativeRehearsal {
    static func run() throws {
        guard case .valid(let report) = DynamicSignalAnalyzerPiAssembly.validate() else {
            throw PiHostNativeRehearsalError.invalidAssembly
        }
        let device = PiRecordingDevice()
        guard
            let layout = PiScreenFramebufferLayout(
                width: 480, height: 320, bitsPerPixel: 16,
                bytesPerRow: 960, mappedBytes: 307_200
            ), let target = PiScreenDisplayTarget(sink: device, layout: layout)
        else { throw PiHostNativeRehearsalError.invalidDisplay }

        var owner = DynamicSignalAnalyzerPiLifecycleOwner(
            target: target,
            assemblyReport: report,
            inputSource: InputSourceID(rawValue: 1),
            initialFrameOriginMicroseconds: 0,
            timingScale: SignalSourceTimingScale(numerator: 1, denominator: 1)!,
            nowMicroseconds: { device.clock }
        )
        var controller = MVPHostActivationController<
            RaspberryPiDynamicHostActivationFailure
        >()
        let activation = controller.activate(owner: &owner, invariantFailure: .invariant)
        guard activation == .active else {
            print("activation=\(activation)")
            controller.teardown(owner: &owner)
            throw PiHostNativeRehearsalError.activation
        }
        guard owner.loopIsEstablished, owner.inputIsEligible, owner.sourceIsActive,
            device.payloads > 0, device.regions > 0, device.bytes > 0
        else {
            controller.teardown(owner: &owner)
            throw PiHostNativeRehearsalError.missingFrame
        }
        controller.teardown(owner: &owner)
        guard controller.lifecycleState == .quiescent,
            owner.phase == .quiescent, !owner.sourceIsActive,
            !owner.inputIsEligible, !owner.reportRuntimeUseIsValid
        else { throw PiHostNativeRehearsalError.teardown }
        print("frames=\(device.payloads)\tregions=\(device.regions)\tbytes=\(device.bytes)")
    }
}
