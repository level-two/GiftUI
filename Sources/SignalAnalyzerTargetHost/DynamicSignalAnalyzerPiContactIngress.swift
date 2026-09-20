import GiftUI
import GiftUIExecution
import GiftUIHostConfiguration

package struct DynamicSignalAnalyzerPiContact: Equatable, Sendable {
    package let phase: PointerPhase
    package let position: Point

    package init(phase: PointerPhase, position: Point) {
        self.phase = phase
        self.position = position
    }
}

package struct DynamicSignalAnalyzerPiContactIngressSummary: Equatable, Sendable {
    package let contactCount: UInt16
    package let queuedCount: UInt16
    package let rejectedCount: UInt16
    package let wakeRequestCount: UInt16
    package let coalescedWakeCount: UInt16

    package init(
        contactCount: UInt16,
        queuedCount: UInt16,
        rejectedCount: UInt16,
        wakeRequestCount: UInt16,
        coalescedWakeCount: UInt16
    ) {
        self.contactCount = contactCount
        self.queuedCount = queuedCount
        self.rejectedCount = rejectedCount
        self.wakeRequestCount = wakeRequestCount
        self.coalescedWakeCount = coalescedWakeCount
    }
}

package enum DynamicSignalAnalyzerPiContactIngressFailure: Equatable, Sendable {
    case contactCountOverflow
    case wake(HostWakePacingError)
}

package enum DynamicSignalAnalyzerPiContactIngressResult: Equatable, Sendable {
    case admitted(DynamicSignalAnalyzerPiContactIngressSummary)
    case failure(DynamicSignalAnalyzerPiContactIngressFailure)
}

/// Joins already decoded target contacts to normalized admission and pacing.
/// This seam assigns no sequence or ordinal itself and performs no model work.
package struct DynamicSignalAnalyzerPiContactIngress: Sendable {
    package let source: InputSourceID

    package init(source: InputSourceID) {
        self.source = source
    }

    package func admit(
        _ contacts: [DynamicSignalAnalyzerPiContact],
        observedPresentationRevision: PresentationRevision?,
        at timestampMicroseconds: UInt64,
        coordinator: inout DynamicSignalAnalyzerPiInputCoordinator,
        pacing: DynamicSignalAnalyzerPiWakePacingOwner
    ) -> DynamicSignalAnalyzerPiContactIngressResult {
        guard let contactCount = UInt16(exactly: contacts.count) else {
            return .failure(.contactCountOverflow)
        }

        var queuedCount: UInt16 = 0
        var rejectedCount: UInt16 = 0
        var wakeRequestCount: UInt16 = 0
        var coalescedWakeCount: UInt16 = 0
        for contact in contacts {
            let disposition = coordinator.admit(
                phase: contact.phase,
                position: contact.position,
                source: source,
                observedPresentationRevision: observedPresentationRevision
            )
            switch disposition {
            case .queued:
                queuedCount += 1
                switch pacing.recordQueuedInput(at: timestampMicroseconds) {
                case .success(.requestWake):
                    wakeRequestCount += 1
                case .success(.coalesced):
                    coalescedWakeCount += 1
                case .failure(let error):
                    return .failure(.wake(error))
                }
            case .dropped, .sequenceCancelled, .sourceQuiesced:
                rejectedCount += 1
            }
        }
        return .admitted(
            DynamicSignalAnalyzerPiContactIngressSummary(
                contactCount: contactCount,
                queuedCount: queuedCount,
                rejectedCount: rejectedCount,
                wakeRequestCount: wakeRequestCount,
                coalescedWakeCount: coalescedWakeCount
            )
        )
    }
}
