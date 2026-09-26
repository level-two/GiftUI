import GiftUI
import GiftUIDisplayCore
import GiftUIHostConfiguration
import GiftUIPlatformRaspberryPi
import SignalAnalyzerData
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
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
    case workload
    case action
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
        try runWorkload(owner: &owner, device: device)
        try runActions(owner: &owner, device: device)
        controller.teardown(owner: &owner)
        guard controller.lifecycleState == .quiescent,
            owner.teardownSteps == Array(UInt8(1) ... UInt8(8)),
            owner.production.phase == .quiescent, !owner.production.sourceIsActive,
            !owner.production.inputIsEligible, !owner.production.reportRuntimeUseIsValid
        else { throw PiHostNativeRehearsalError.teardown }
        print("frames=\(device.payloads)\tregions=\(device.regions)\tbytes=\(device.bytes)")
    }

    private static func runWorkload(
        owner: inout PiRecordingLifecycleOwner<PiScreenDisplayTarget<PiRecordingDevice>>,
        device: PiRecordingDevice
    ) throws {
        var transitions = 0
        var frames = 0
        for window in 1 ... 120 {
            for event in 1 ... 20 {
                device.clock = UInt64((window - 1) * 250_000 + event * 12_500)
                guard owner.production.deliverScheduledSourceTransition() else {
                    print("source-failed window=\(window) event=\(event)")
                    throw PiHostNativeRehearsalError.workload
                }
                transitions += 1
            }
            let result = owner.production.service(at: device.clock)
            guard
                case .completed(_, .completed(let summary)) = result,
                summary.application.factCount == (window == 1 ? 25 : 20),
                summary.presentation != nil,
                owner.production.applicationCaptureRevision != nil
            else {
                print("service-failed window=\(window) result=\(result)")
                throw PiHostNativeRehearsalError.workload
            }
            frames += 1
        }
        guard transitions == 2_400, frames == 120,
            owner.production.applicationState?.acquisitionState == .running,
            owner.production.applicationState?.capture.transitions.count ?? 0 > 0
        else {
            print("final-state=\(String(describing: owner.production.applicationState))")
            throw PiHostNativeRehearsalError.workload
        }
        print("workload_transitions=\(transitions)\tworkload_frames=\(frames)")
    }

    private static func runActions(
        owner: inout PiRecordingLifecycleOwner<PiScreenDisplayTarget<PiRecordingDevice>>,
        device: PiRecordingDevice
    ) throws {
        let actions: [(SignalAnalyzerAction, AcquisitionState, VisibleTimeWindow)] = [
            (.stop, .stopped, .twoSeconds),
            (.start, .running, .twoSeconds),
            (.clear, .running, .twoSeconds),
            (.selectOneSecond, .running, .oneSecond),
            (.selectFiveSeconds, .running, .fiveSeconds),
            (.selectTwoSeconds, .running, .twoSeconds),
        ]
        try tapAction(.start, expectedDispatch: 0, owner: &owner, device: device)
        for (code, expectedState, expectedWindow) in actions {
            let beforeRevision = owner.production.currentPresentationRevision
            try tapAction(code, expectedDispatch: 1, owner: &owner, device: device)
            if code == .stop || code == .start || code == .clear {
                device.clock += 250_000
                guard
                    case .completed(_, .completed(let applied)) =
                        owner.production.service(at: device.clock),
                    applied.application.factCount > 0
                else { throw PiHostNativeRehearsalError.action }
            }
            guard owner.production.applicationState?.acquisitionState == expectedState,
                owner.production.applicationState?.visibleWindow == expectedWindow,
                owner.production.currentPresentationRevision != beforeRevision
            else { throw PiHostNativeRehearsalError.action }
            if code == .clear {
                guard owner.production.applicationState?.capture.transitions.isEmpty == true
                else { throw PiHostNativeRehearsalError.action }
            }
            if code == .selectOneSecond || code == .selectFiveSeconds
                || code == .selectTwoSeconds
            {
                try tapAction(code, expectedDispatch: 0, owner: &owner, device: device)
            }
            print("action=\(code)\tstate=\(expectedState)\twindow=\(expectedWindow)")
        }
    }

    private static func tapAction(
        _ code: SignalAnalyzerAction,
        expectedDispatch: UInt16,
        owner: inout PiRecordingLifecycleOwner<PiScreenDisplayTarget<PiRecordingDevice>>,
        device: PiRecordingDevice
    ) throws {
        guard let record = owner.production.committedAction(code: code),
            record.isEnabled == (expectedDispatch == 1)
        else {
            print("action-unavailable code=\(code)")
            throw PiHostNativeRehearsalError.action
        }
        let point = Point(
            x: record.hitBounds.origin.x + record.hitBounds.size.width / 2,
            y: record.hitBounds.origin.y + record.hitBounds.size.height / 2
        )
        let priorState = owner.production.applicationState
        let priorRevision = owner.production.currentPresentationRevision
        device.clock += 250_000
        let ingress = owner.production.admit(
            [
                DynamicSignalAnalyzerPiContact(
                    phase: .down, position: point,
                    priorPhysicalSequenceIsComplete: true
                ),
                DynamicSignalAnalyzerPiContact(phase: .up, position: point),
            ], at: device.clock
        )
        let result = owner.production.service(at: device.clock)
        guard case .admitted(let admitted) = ingress, admitted.queuedCount == 2,
            case .completed(_, .completed(let summary)) = result,
            summary.input.dispatchedActionCount == expectedDispatch
        else {
            print("action-failed code=\(code) ingress=\(ingress) result=\(result)")
            throw PiHostNativeRehearsalError.action
        }
        if expectedDispatch == 0 {
            guard owner.production.applicationState == priorState,
                owner.production.currentPresentationRevision == priorRevision,
                summary.presentation == nil
            else { throw PiHostNativeRehearsalError.action }
        }
    }
}
