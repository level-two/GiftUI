#if os(Linux)
    import Glibc
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
                    position: $0.point,
                    // The touch decoder emits another down only after an up.
                    priorPhysicalSequenceIsComplete: $0.phase == .down
                )
            }
            if Glibc.getenv("GIFTUI_PI_TRACE") != nil {
                for contact in contacts where contact.phase != .move {
                    print("pi-contact \(contact.phase) \(contact.position)")
                }
            }
            return owner.admit(contacts, at: timestampMicroseconds)
        }
    }
#endif
