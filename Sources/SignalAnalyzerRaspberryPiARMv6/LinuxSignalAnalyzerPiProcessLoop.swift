#if os(Linux)
    import Glibc
    import GiftUI
    import GiftUIDisplayCore
    import GiftUIHostConfiguration
    import GiftUIPlatformRaspberryPi
    import SignalAnalyzerTargetHost

    private nonisolated(unsafe) var signalAnalyzerStopRequested: sig_atomic_t = 0

    @_cdecl("giftui_signal_analyzer_stop")
    private func giftUISignalAnalyzerStop(_: Int32) {
        signalAnalyzerStopRequested = 1
    }

    enum LinuxSignalAnalyzerPiProcessFailure: Error {
        case clock
        case invalidDisplay
        case activation(RaspberryPiDynamicHostActivationFailure)
        case input(LinuxPiScreenDeviceError)
        case ingress(DynamicSignalAnalyzerPiContactIngressFailure)
        case pacing(HostWakePacingError)
        case sourceSchedule
    }

    enum LinuxSignalAnalyzerPiClock {
        static func nowMicroseconds() -> UInt64? {
            var value = timespec()
            guard Glibc.clock_gettime(CLOCK_MONOTONIC, &value) == 0,
                value.tv_sec >= 0, value.tv_nsec >= 0
            else { return nil }
            let seconds = UInt64(value.tv_sec).multipliedReportingOverflow(by: 1_000_000)
            guard !seconds.overflow else { return nil }
            let microseconds = UInt64(value.tv_nsec) / 1_000
            let total = seconds.partialValue.addingReportingOverflow(microseconds)
            return total.overflow ? nil : total.partialValue
        }
    }

    enum LinuxSignalAnalyzerPiProcessLoop {
        private static func traceFrameDuration(
            startedAt: UInt64,
            result: DynamicSignalAnalyzerPiPacedOpportunityResult
        ) {
            guard case .completed = result,
                Glibc.getenv("GIFTUI_PI_TRACE") != nil,
                let finishedAt = LinuxSignalAnalyzerPiClock.nowMicroseconds()
            else { return }
            let line = "pi-frame-duration-us \(finishedAt - startedAt)\n"
            _ = line.withCString { Glibc.write(STDERR_FILENO, $0, Glibc.strlen($0)) }
        }

        static func run(
            framebuffer: LinuxPiScreenFramebuffer,
            touch: LinuxPiScreenTouchDevice,
            assemblyReport: HostAssemblyReport
        ) throws(LinuxSignalAnalyzerPiProcessFailure) {
            guard
                let target = PiScreenDisplayTarget(
                    sink: framebuffer,
                    layout: framebuffer.layout
                ), let origin = LinuxSignalAnalyzerPiClock.nowMicroseconds()
            else { throw .invalidDisplay }

            var owner = DynamicSignalAnalyzerPiLifecycleOwner(
                target: target,
                assemblyReport: assemblyReport,
                inputSource: InputSourceID(rawValue: 1),
                initialFrameOriginMicroseconds: origin,
                nowMicroseconds: { LinuxSignalAnalyzerPiClock.nowMicroseconds() ?? origin }
            )
            var controller = MVPHostActivationController<
                RaspberryPiDynamicHostActivationFailure
            >()
            switch controller.activate(owner: &owner, invariantFailure: .invariant) {
            case .active:
                break
            case .failure(let failure):
                controller.teardown(owner: &owner)
                throw .activation(failure)
            }
            defer { controller.teardown(owner: &owner) }

            signalAnalyzerStopRequested = 0
            _ = Glibc.signal(SIGINT, giftUISignalAnalyzerStop)
            _ = Glibc.signal(SIGTERM, giftUISignalAnalyzerStop)
            defer {
                _ = Glibc.signal(SIGINT, SIG_DFL)
                _ = Glibc.signal(SIGTERM, SIG_DFL)
            }

            var scheduledSourceGeneration = owner.activeSourceGeneration
            var nextSource: UInt64? = try sourceDeadline(owner: owner, from: origin)
            let inputPump = LinuxSignalAnalyzerPiInputPump()
            while signalAnalyzerStopRequested == 0 {
                guard let now = LinuxSignalAnalyzerPiClock.nowMicroseconds() else {
                    throw .clock
                }
                let inputResult: DynamicSignalAnalyzerPiContactIngressResult
                do {
                    inputResult = try inputPump.poll(touch: touch, at: now, owner: &owner)
                } catch let failure {
                    throw .input(failure)
                }
                if case .failure(let failure) = inputResult {
                    throw .ingress(failure)
                }
                if case .admitted(let summary) = inputResult,
                    summary.contactCount > 0,
                    Glibc.getenv("GIFTUI_PI_TRACE") != nil
                {
                    print("pi-input \(summary)")
                }

                if let deadline = nextSource, now >= deadline {
                    guard owner.deliverScheduledSourceTransition() else {
                        throw .sourceSchedule
                    }
                    nextSource = try sourceDeadline(owner: owner, from: now)
                }

                // Fact callbacks can observe a later clock value than the one
                // sampled before input and source delivery.
                guard let serviceNow = LinuxSignalAnalyzerPiClock.nowMicroseconds() else {
                    throw .clock
                }
                let pollBoundary = serviceNow.addingReportingOverflow(10_000)
                guard !pollBoundary.overflow else { throw .clock }
                var nextWake = pollBoundary.partialValue
                let result = owner.service(at: serviceNow)
                traceFrameDuration(startedAt: serviceNow, result: result)
                if case .completed(_, .completed(let summary)) = result,
                    summary.input.eventCount > 0,
                    Glibc.getenv("GIFTUI_PI_TRACE") != nil
                {
                    print("pi-opportunity-input \(summary.input)")
                }
                switch result {
                case .noWork, .completed:
                    break
                case .wait(let boundary):
                    nextWake = min(nextWake, boundary)
                case .rejected(let error):
                    throw .pacing(error)
                }
                let currentSourceGeneration = owner.activeSourceGeneration
                if currentSourceGeneration != scheduledSourceGeneration {
                    scheduledSourceGeneration = currentSourceGeneration
                    if currentSourceGeneration != nil {
                        guard let restartedAt = LinuxSignalAnalyzerPiClock.nowMicroseconds()
                        else { throw .clock }
                        nextSource = try sourceDeadline(owner: owner, from: restartedAt)
                    } else {
                        nextSource = nil
                    }
                }
                if let nextSource { nextWake = min(nextWake, nextSource) }
                if nextWake > serviceNow {
                    let delay = min(nextWake - serviceNow, 10_000)
                    _ = Glibc.usleep(useconds_t(delay))
                }
            }
        }

        private static func sourceDeadline<Target>(
            owner: DynamicSignalAnalyzerPiLifecycleOwner<Target>,
            from origin: UInt64
        ) throws(LinuxSignalAnalyzerPiProcessFailure) -> UInt64
        where Target: DisplayTarget {
            guard let delay = owner.nextScheduledSourceDelay,
                let microseconds = durationMicroseconds(delay)
            else { throw .sourceSchedule }
            let deadline = origin.addingReportingOverflow(microseconds)
            guard !deadline.overflow else { throw .sourceSchedule }
            return deadline.partialValue
        }

        private static func durationMicroseconds(_ duration: Duration) -> UInt64? {
            let components = duration.components
            guard components.seconds >= 0, components.attoseconds >= 0 else { return nil }
            let seconds = UInt64(components.seconds).multipliedReportingOverflow(by: 1_000_000)
            guard !seconds.overflow else { return nil }
            let fractional = UInt64(components.attoseconds) / 1_000_000_000_000
            let total = seconds.partialValue.addingReportingOverflow(fractional)
            return total.overflow ? nil : total.partialValue
        }
    }
#endif
