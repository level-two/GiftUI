import GiftUI
import GiftUIDisplayCore
import GiftUIHostConfiguration
import GiftUIPlatformRaspberryPi
import SignalAnalyzerData
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import SignalAnalyzerTargetHost

#if os(macOS)
    import Foundation
#endif

private final class PiRecordingDevice: PiScreenFramebufferSink {
    var payloads = 0
    var bytes = 0
    var regions = 0
    var clock: UInt64 = 0
    var failAtPayload: Int?
    private var logicalPixels = [UInt16](repeating: 0, count: 240 * 240)
    private var physicalPixels = [UInt16](repeating: 0, count: 480 * 320)

    var frameHash: UInt64 {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for pixel in logicalPixels {
            hash = (hash ^ UInt64(pixel >> 8)) &* 1_099_511_628_211
            hash = (hash ^ UInt64(pixel & 0xff)) &* 1_099_511_628_211
        }
        return hash
    }

    func capture(_ name: String) throws {
        #if os(macOS)
            guard let directory = ProcessInfo.processInfo.environment["GIFTUI_REHEARSAL_RASTERS"]
            else { return }
            for (suffix, pixels) in [
                ("", logicalPixels), ("-physical", physicalPixels),
            ] {
                var bytes = [UInt8]()
                bytes.reserveCapacity(pixels.count * 2)
                for pixel in pixels {
                    bytes.append(UInt8(pixel >> 8))
                    bytes.append(UInt8(pixel & 0xff))
                }
                try Data(bytes).write(
                    to: URL(fileURLWithPath: directory).appendingPathComponent(
                        "pi-\(name)\(suffix).rgb565"
                    ),
                    options: .atomic
                )
            }
        #endif
    }

    func presentRGB565BigEndian(
        bytes: UnsafeRawBufferPointer,
        regions: [PiScreenPayloadRegion],
        transform: PiScreenAspectFitTransform
    ) -> Bool {
        if payloads + 1 == failAtPayload { return false }
        guard transform.logicalWidth == 240, transform.logicalHeight == 240
        else { return false }
        for region in regions {
            let x = Int(region.origin.x)
            let y = Int(region.origin.y)
            let count = Int(region.pixelCount)
            let offset = Int(region.byteOffset)
            guard x >= 0, y >= 0, y < 240, x + count <= 240,
                offset + count * 2 <= bytes.count
            else { return false }
            for pixel in 0 ..< count {
                logicalPixels[y * 240 + x + pixel] =
                    UInt16(bytes[offset + pixel * 2]) << 8
                    | UInt16(bytes[offset + pixel * 2 + 1])
            }
            guard
                let physical = transform.physicalBounds(
                    origin: region.origin, pixelCount: region.pixelCount
                )
            else { return false }
            for physicalY in physical.minY ..< physical.maxY {
                for physicalX in physical.minX ..< physical.maxX {
                    let sourcePixel = Int(
                        Int64(physicalX - physical.minX) * Int64(region.pixelCount)
                            / Int64(physical.size.width)
                    )
                    physicalPixels[Int(physicalY) * 480 + Int(physicalX)] =
                        UInt16(bytes[offset + sourcePixel * 2]) << 8
                        | UInt16(bytes[offset + sourcePixel * 2 + 1])
                }
            }
        }
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
        #if os(macOS)
            let faultMode = ProcessInfo.processInfo.environment["GIFTUI_REHEARSAL_FAULT"]
            if faultMode == "display-initial" { device.failAtPayload = 1 }
        #endif
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
        #if os(macOS)
            if faultMode == "display-initial" {
                guard activation == .failure(.endpoint(.invariantViolation)),
                    controller.lifecycleState == .failed,
                    !owner.production.inputIsEligible,
                    !owner.production.sourceIsActive,
                    device.payloads == 0
                else { throw PiHostNativeRehearsalError.activation }
                controller.teardown(owner: &owner)
                guard controller.lifecycleState == .quiescent,
                    owner.production.phase == .quiescent,
                    owner.teardownSteps == Array(UInt8(1) ... UInt8(8))
                else { throw PiHostNativeRehearsalError.teardown }
                print(
                    "fault=display-initial\tresult=endpoint.invariantViolation"
                        + "\tpayloads=0\tstatus=passed")
                return
            }
        #endif
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
        #if os(macOS)
            if faultMode == "display-next" {
                let priorHash = device.frameHash
                let priorRevision = owner.production.currentPresentationRevision
                device.failAtPayload = device.payloads + 1
                for event in 1 ... 20 {
                    device.clock = UInt64(event * 12_500)
                    guard owner.production.deliverScheduledSourceTransition() else {
                        throw PiHostNativeRehearsalError.workload
                    }
                }
                let result = owner.production.service(at: device.clock)
                guard case .completed(_, .failure(.presentation)) = result,
                    owner.production.lastCommittedPresentationRevision == priorRevision,
                    owner.production.currentPresentationRevision == nil,
                    !owner.production.inputIsEligible,
                    !owner.production.sourceIsActive,
                    owner.production.phase == .quiescent,
                    device.frameHash == priorHash
                else {
                    print(
                        "display-next-result=\(result)"
                            + "\trevision=\(String(describing: owner.production.currentPresentationRevision))"
                            + "\thash=\(device.frameHash)")
                    throw PiHostNativeRehearsalError.missingFrame
                }
                controller.teardown(owner: &owner)
                guard controller.lifecycleState == .quiescent,
                    owner.teardownSteps == Array(UInt8(1) ... UInt8(8))
                else { throw PiHostNativeRehearsalError.teardown }
                print(
                    "fault=display-next\tresult=presentationFailure"
                        + "\tlast_frame_hash=\(priorHash)\tstatus=passed")
                return
            }
            if faultMode == "diagnostic" {
                let priorRevision = owner.production.currentPresentationRevision
                guard owner.production.injectHostNativeDiagnostic() else {
                    throw PiHostNativeRehearsalError.action
                }
                device.clock += 250_000
                let result = owner.production.service(at: device.clock)
                guard case .completed(_, .completed) = result,
                    owner.production.currentPresentationRevision != priorRevision,
                    owner.production.applicationState?.errorMessage != nil
                else {
                    print("diagnostic-result=\(result)")
                    throw PiHostNativeRehearsalError.missingFrame
                }
                try device.capture("diagnostic")
                controller.teardown(owner: &owner)
                guard controller.lifecycleState == .quiescent,
                    owner.teardownSteps == Array(UInt8(1) ... UInt8(8))
                else { throw PiHostNativeRehearsalError.teardown }
                print("diagnostic=visible\tframe_hash=\(device.frameHash)\tstatus=passed")
                return
            }
            if faultMode == "input-overflow" {
                let priorHash = device.frameHash
                let priorRevision = owner.production.currentPresentationRevision
                let priorState = owner.production.applicationState
                let contacts = Array(
                    repeating: DynamicSignalAnalyzerPiContact(
                        phase: .down, position: Point(x: 0, y: 0)
                    ), count: 65_536
                )
                let ingress = owner.production.admit(contacts, at: device.clock)
                guard ingress == .failure(.contactCountOverflow),
                    owner.production.currentPresentationRevision == priorRevision,
                    device.frameHash == priorHash,
                    owner.production.applicationState == priorState
                else {
                    print(
                        "input-overflow-result=\(ingress)"
                            + "\trevision=\(String(describing: owner.production.currentPresentationRevision))"
                            + "\thash=\(device.frameHash)"
                            + "\tstate=\(String(describing: owner.production.applicationState?.acquisitionState))"
                    )
                    throw PiHostNativeRehearsalError.action
                }
                controller.teardown(owner: &owner)
                guard controller.lifecycleState == .quiescent,
                    owner.teardownSteps == Array(UInt8(1) ... UInt8(8))
                else { throw PiHostNativeRehearsalError.teardown }
                print(
                    "fault=input-overflow\tresult=contactCountOverflow"
                        + "\tlast_frame_hash=\(priorHash)\tstatus=passed")
                return
            }
        #endif
        try traceOtherFrame(code: nil, owner: owner, device: device)
        try device.capture("idle")
        try runWorkload(owner: &owner, device: device)
        try runActions(owner: &owner, device: device)
        #if os(macOS)
            if ProcessInfo.processInfo.environment["GIFTUI_REHEARSAL_CLEARED"] != nil {
                let previous = owner.production.applicationCaptureRevision
                guard owner.production.clearHostNativeCapture() else {
                    throw PiHostNativeRehearsalError.action
                }
                device.clock += 250_000
                let result = owner.production.service(at: device.clock)
                guard case .completed(_, .completed) = result,
                    let state = owner.production.applicationState,
                    state.capture.transitions.isEmpty,
                    state.acquisitionState == .running,
                    owner.production.applicationCaptureRevision == previous.map({ $0 + 1 })
                else {
                    print(
                        "cleared-result=\(result)\tprevious=\(String(describing: previous))\tcurrent=\(String(describing: owner.production.applicationCaptureRevision))\tstate=\(String(describing: owner.production.applicationState))"
                    )
                    throw PiHostNativeRehearsalError.action
                }
                try device.capture("cleared")
                print("cleared=captured\tcapture_count=0\tstate=running\tstatus=passed")
            }
        #endif
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
                let presentation = summary.presentation,
                owner.production.applicationCaptureRevision != nil
            else {
                print("service-failed window=\(window) result=\(result)")
                throw PiHostNativeRehearsalError.workload
            }
            guard let state = owner.production.applicationState,
                let captureRevision = owner.production.applicationCaptureRevision,
                let presentationRevision = owner.production.currentPresentationRevision
            else { throw PiHostNativeRehearsalError.workload }
            print(
                "trace=frame\tordinal=\(window)\trevision=\(presentationRevision.rawValue)"
                    + "\tfacts=\(summary.application.factCount)"
                    + "\tcapture_revision=\(captureRevision)"
                    + "\tcapture_count=\(state.capture.transitions.count)"
                    + "\tstate=\(state.acquisitionState)\twindow=\(state.visibleWindow)"
                    + "\tsemantic_nodes=\(presentation.semantic.semanticNodeCount)"
                    + "\tlayout_scopes=\(presentation.layout.scopeCount)"
                    + "\tdrawing_strokes=\(presentation.drawing.strokeCount)"
                    + "\tdrawing_points=\(presentation.drawing.pointCount)"
                    + "\trender_operations=\(presentation.render.operationCount)"
                    + "\tframe_hash=\(device.frameHash)"
            )
            frames += 1
            if window == 120 { try device.capture("running-four-traces") }
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
        let actions: [(SignalAnalyzerAction, UInt16, AcquisitionState, VisibleTimeWindow)] = [
            (.stop, 1, .stopped, .twoSeconds),
            (.start, 1, .running, .twoSeconds),
            (.selectOneSecond, 1, .running, .oneSecond),
            (.selectOneSecond, 0, .running, .oneSecond),
            (.selectOneSecond, 0, .running, .oneSecond),
            (.selectTwoSeconds, 1, .running, .twoSeconds),
            (.selectFiveSeconds, 1, .running, .fiveSeconds),
            (.selectFiveSeconds, 0, .running, .fiveSeconds),
            (.selectFiveSeconds, 0, .running, .fiveSeconds),
            (.selectTwoSeconds, 1, .running, .twoSeconds),
            (.selectOneSecond, 1, .running, .oneSecond),
            (.selectTwoSeconds, 1, .running, .twoSeconds),
        ]
        for (code, dispatched, expectedState, expectedWindow) in actions {
            let beforeRevision = owner.production.currentPresentationRevision
            try tapAction(code, expectedDispatch: dispatched, owner: &owner, device: device)
            if dispatched == 1 {
                if code == .stop || code == .start {
                    device.clock += 250_000
                    guard
                        case .completed(_, .completed(let applied)) = owner.production.service(
                            at: device.clock),
                        applied.application.factCount > 0
                    else { throw PiHostNativeRehearsalError.action }
                }
                guard owner.production.currentPresentationRevision != beforeRevision else {
                    throw PiHostNativeRehearsalError.action
                }
                try traceOtherFrame(code: code, owner: owner, device: device)
                let captureName: String?
                switch code {
                case .stop: captureName = "stopped"
                case .selectOneSecond: captureName = "window-one-second"
                case .selectFiveSeconds: captureName = "window-five-seconds"
                case .selectTwoSeconds: captureName = "window-two-seconds"
                default: captureName = nil
                }
                if let captureName { try device.capture(captureName) }
            }
            guard owner.production.applicationState?.acquisitionState == expectedState,
                owner.production.applicationState?.visibleWindow == expectedWindow
            else { throw PiHostNativeRehearsalError.action }
            try traceAction(code, dispatched: dispatched, owner: owner)
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
        // Substitute the device sample, preserving production calibration and
        // contact decoding before entering the serialized application owner.
        guard
            let transform = PiScreenAspectFitTransform(
                physicalWidth: 480, physicalHeight: 320, logicalWidth: 240, logicalHeight: 240
            ), let calibration = PiScreenTouchCalibration.signalAnalyzerPiScreen
        else {
            throw PiHostNativeRehearsalError.action
        }
        let physicalX = transform.contentOriginX + point.x * transform.contentWidth / 240
        let physicalY = transform.contentOriginY + point.y * transform.contentHeight / 240
        let rawX =
            calibration.minimumX
            + Int32((Int64(physicalX) * 4095 + 478) / 479)
        let rawY =
            calibration.minimumY
            + Int32((Int64(physicalY) * 4095 + 318) / 319)
        guard
            let normalized = transform.logicalPoint(
                rawX: rawX, rawY: rawY, calibration: calibration
            ), record.hitBounds.contains(normalized)
        else {
            throw PiHostNativeRehearsalError.action
        }
        var decoder = PiScreenInputEventDecoder(transform: transform, calibration: calibration)
        guard decoder.consume(type: 3, code: 0, value: rawX) == nil,
            decoder.consume(type: 3, code: 1, value: rawY) == nil,
            decoder.consume(type: 1, code: 330, value: 1) == nil,
            let down = decoder.consume(type: 0, code: 0, value: 0),
            decoder.consume(type: 0, code: 0, value: 0) == nil,
            decoder.consume(type: 1, code: 330, value: 0) == nil,
            let up = decoder.consume(type: 0, code: 0, value: 0),
            decoder.consume(type: 0, code: 0, value: 0) == nil
        else { throw PiHostNativeRehearsalError.action }
        let ingress = owner.production.admit(
            [
                DynamicSignalAnalyzerPiContact(
                    phase: down.phase, position: down.point, priorPhysicalSequenceIsComplete: true),
                DynamicSignalAnalyzerPiContact(phase: up.phase, position: up.point),
            ], at: device.clock)
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

    private static func traceAction(
        _ code: SignalAnalyzerAction,
        dispatched: UInt16,
        owner: PiRecordingLifecycleOwner<PiScreenDisplayTarget<PiRecordingDevice>>
    ) throws {
        guard let state = owner.production.applicationState,
            let revision = owner.production.currentPresentationRevision
        else { throw PiHostNativeRehearsalError.action }
        print(
            "trace=action\tcode=\(code.rawValue)\tdispatched=\(dispatched)"
                + "\trevision=\(revision.rawValue)"
                + "\tcapture_count=\(state.capture.transitions.count)"
                + "\tstate=\(state.acquisitionState)\twindow=\(state.visibleWindow)"
        )
    }

    private static func traceOtherFrame(
        code: SignalAnalyzerAction?,
        owner: PiRecordingLifecycleOwner<PiScreenDisplayTarget<PiRecordingDevice>>,
        device: PiRecordingDevice
    ) throws {
        guard let summary = owner.production.lastPresentedSummary,
            let state = owner.production.applicationState,
            let captureRevision = owner.production.applicationCaptureRevision,
            let revision = owner.production.currentPresentationRevision
        else { throw PiHostNativeRehearsalError.missingFrame }
        print(
            "trace=other_frame\tcode=\(code?.rawValue ?? UInt16.max)"
                + "\trevision=\(revision.rawValue)"
                + "\tcapture_revision=\(captureRevision)"
                + "\tcapture_count=\(state.capture.transitions.count)"
                + "\tstate=\(state.acquisitionState)\twindow=\(state.visibleWindow)"
                + "\tsemantic_nodes=\(summary.semantic.semanticNodeCount)"
                + "\tlayout_scopes=\(summary.layout.scopeCount)"
                + "\tdrawing_strokes=\(summary.drawing.strokeCount)"
                + "\tdrawing_points=\(summary.drawing.pointCount)"
                + "\trender_operations=\(summary.render.operationCount)"
                + "\tpayloads=\(device.payloads)\tregions=\(device.regions)"
                + "\tbytes=\(device.bytes)"
                + "\tframe_hash=\(device.frameHash)"
        )
    }
}
