#if os(Linux)
    import GiftUI
    import GiftUIDisplayCore
    import GiftUIPlatformRaspberryPi
    import SignalAnalyzerTargetHost

    struct LinuxSignalAnalyzerPiInputPump {
        func poll<Target>(
            touch: LinuxPiScreenTouchDevice,
            at timestampMicroseconds: UInt64,
            owner: inout DynamicSignalAnalyzerPiLifecycleOwner<Target>
        ) throws(LinuxPiScreenDeviceError) -> DynamicSignalAnalyzerPiContactIngressResult
        where Target: DisplayTarget {
            let contacts = try touch.poll().map {
                DynamicSignalAnalyzerPiContact(
                    phase: $0.phase,
                    position: $0.point
                )
            }
            return owner.admit(contacts, at: timestampMicroseconds)
        }
    }
#endif
