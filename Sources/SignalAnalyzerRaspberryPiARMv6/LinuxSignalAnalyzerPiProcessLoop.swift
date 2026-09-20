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

            var nextSource = try sourceDeadline(owner: owner, from: origin)
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

                if now >= nextSource {
                    guard owner.deliverScheduledSourceTransition() else {
                        throw .sourceSchedule
                    }
                    nextSource = try sourceDeadline(owner: owner, from: now)
                }

                let pollBoundary = now.addingReportingOverflow(10_000)
                guard !pollBoundary.overflow else { throw .clock }
                var nextWake = pollBoundary.partialValue
                switch owner.service(at: now) {
                case .noWork, .completed:
                    break
                case .wait(let boundary):
                    nextWake = min(nextWake, boundary)
                case .rejected(let error):
                    throw .pacing(error)
                }
                nextWake = min(nextWake, nextSource)
                if nextWake > now {
                    let delay = min(nextWake - now, 10_000)
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
