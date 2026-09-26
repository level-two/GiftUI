import GiftUI
import GiftUIDisplayCore
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

private struct PiRecordingLifecycleOwner<Target: DisplayTarget>:
    MVPHostActivationOwner, MVPHostTeardownOwner
{
    typealias ActivationFailure = RaspberryPiDynamicHostActivationFailure

    var production: DynamicSignalAnalyzerPiLifecycleOwner<Target>
    var activationSteps: [UInt8] = []
    var teardownSteps: [UInt8] = []

    mutating func constructRuntimeAndEndpoint() -> HostActivationStepResult<ActivationFailure> {
        activationSteps.append(1)
        return production.constructRuntimeAndEndpoint()
    }

    mutating func constructApplicationOwners() -> HostActivationStepResult<ActivationFailure> {
        activationSteps.append(2)
        return production.constructApplicationOwners()
    }

    mutating func attachRootModelInFirstCandidate() -> HostActivationStepResult<ActivationFailure> {
        activationSteps.append(3)
        return production.attachRootModelInFirstCandidate()
    }

    mutating func installRepositoryObservationAndAdmitCurrentValues()
        -> HostActivationStepResult<ActivationFailure>
    {
        activationSteps.append(4)
        return production.installRepositoryObservationAndAdmitCurrentValues()
    }

    mutating func acceptFirstPresentationAndEnableInput() -> HostActivationStepResult<
        ActivationFailure
    > {
        activationSteps.append(5)
        return production.acceptFirstPresentationAndEnableInput()
    }

    mutating func startAcquisitionThroughApplicationOpportunity()
        -> HostActivationStepResult<ActivationFailure>
    {
        activationSteps.append(6)
        return production.startAcquisitionThroughApplicationOpportunity()
    }

    mutating func establishWakeAndPacingHostLoop() -> HostActivationStepResult<ActivationFailure> {
        activationSteps.append(7)
        return production.establishWakeAndPacingHostLoop()
    }

    mutating func stopSourceDeliveryAndRepositoryObservation() {
        production.stopSourceDeliveryAndRepositoryObservation()
    }

    mutating func preventInputEligibility() {
        production.preventInputEligibility()
    }

    mutating func quiesceConstructedRuntime() {
        production.quiesceConstructedRuntime()
    }

    mutating func refuseApplicationDeliveryAndInput() {
        teardownSteps.append(1)
        production.refuseApplicationDeliveryAndInput()
    }

    mutating func stopSourceDeliveryAndDetachObservations() {
        teardownSteps.append(2)
        production.stopSourceDeliveryAndDetachObservations()
    }

    mutating func cancelPointerSequencesAndHostCallbacks() {
        teardownSteps.append(3)
        production.cancelPointerSequencesAndHostCallbacks()
    }

    mutating func quiesceRuntimeAndFinalizeActiveCycle() {
        teardownSteps.append(4)
        production.quiesceRuntimeAndFinalizeActiveCycle()
    }

    mutating func retireObservableRegistrationAndRouting() {
        teardownSteps.append(5)
        production.retireObservableRegistrationAndRouting()
    }

    mutating func releasePlatformOwners() {
        teardownSteps.append(6)
        production.releasePlatformOwners()
    }

    mutating func resetProfileStorage() {
        teardownSteps.append(7)
        production.resetProfileStorage()
    }

    mutating func invalidateAssemblyReportRuntimeUse() {
        teardownSteps.append(8)
        production.invalidateAssemblyReportRuntimeUse()
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

        let production = DynamicSignalAnalyzerPiLifecycleOwner(
            target: target,
            assemblyReport: report,
            inputSource: InputSourceID(rawValue: 1),
            initialFrameOriginMicroseconds: 0,
            timingScale: SignalSourceTimingScale(numerator: 1, denominator: 1)!,
            nowMicroseconds: { device.clock }
        )
        var owner = PiRecordingLifecycleOwner(production: production)
        var controller = MVPHostActivationController<
            RaspberryPiDynamicHostActivationFailure
        >()
        let activation = controller.activate(owner: &owner, invariantFailure: .invariant)
        guard activation == .active else {
            print("activation=\(activation)")
            controller.teardown(owner: &owner)
            throw PiHostNativeRehearsalError.activation
        }
        guard owner.activationSteps == Array(UInt8(1) ... UInt8(7)),
            owner.production.loopIsEstablished, owner.production.inputIsEligible,
            owner.production.sourceIsActive,
            device.payloads > 0, device.regions > 0, device.bytes > 0
        else {
            controller.teardown(owner: &owner)
            throw PiHostNativeRehearsalError.missingFrame
        }
        controller.teardown(owner: &owner)
        guard controller.lifecycleState == .quiescent,
            owner.teardownSteps == Array(UInt8(1) ... UInt8(8)),
            owner.production.phase == .quiescent, !owner.production.sourceIsActive,
            !owner.production.inputIsEligible, !owner.production.reportRuntimeUseIsValid
        else { throw PiHostNativeRehearsalError.teardown }
        print("frames=\(device.payloads)\tregions=\(device.regions)\tbytes=\(device.bytes)")
    }
}
