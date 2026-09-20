#if os(Linux)
    import GiftUI
    import GiftUIPlatformRaspberryPi
    import SignalAnalyzerTargetHost

    struct LinuxSignalAnalyzerPiInputPump {
        let ingress: DynamicSignalAnalyzerPiContactIngress

        init(source: InputSourceID) {
            ingress = DynamicSignalAnalyzerPiContactIngress(source: source)
        }

        func poll(
            touch: LinuxPiScreenTouchDevice,
            observedPresentationRevision: PresentationRevision?,
            at timestampMicroseconds: UInt64,
            coordinator: inout DynamicSignalAnalyzerPiInputCoordinator,
            pacing: DynamicSignalAnalyzerPiWakePacingOwner
        ) throws(LinuxPiScreenDeviceError) -> DynamicSignalAnalyzerPiContactIngressResult {
            let contacts = try touch.poll().map {
                DynamicSignalAnalyzerPiContact(
                    phase: $0.phase,
                    position: $0.point
                )
            }
            return ingress.admit(
                contacts,
                observedPresentationRevision: observedPresentationRevision,
                at: timestampMicroseconds,
                coordinator: &coordinator,
                pacing: pacing
            )
        }
    }
#endif
