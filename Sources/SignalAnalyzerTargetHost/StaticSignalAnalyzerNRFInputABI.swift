import GiftUI
import GiftUIExecution
import GiftUIHostConfiguration

package enum StaticSignalAnalyzerNRFInputABIDisposition: UInt8, Equatable, Sendable {
    case queued = 0
    case dropped = 1
    case sequenceCancelled = 2
    case sourceQuiesced = 3
}

package struct StaticSignalAnalyzerNRFInputABIOutcome: Equatable, Sendable {
    package static let noRejection: UInt8 = .max

    package let disposition: StaticSignalAnalyzerNRFInputABIDisposition
    package let rejection: UInt8

    package var packedValue: Int32 {
        Int32(disposition.rawValue) << 8 | Int32(rejection)
    }
}

/// Converts the C-compatible touch representation into the production Static
/// input coordinator without assigning provenance on the device side.
package struct StaticSignalAnalyzerNRFInputABI {
    private let source: InputSourceID
    private var coordinator: StaticSignalAnalyzerNRFInputCoordinator

    package init(sourceRawValue: UInt16) {
        let source = InputSourceID(rawValue: sourceRawValue)
        self.source = source
        coordinator = StaticSignalAnalyzerNRFInputCoordinator(
            source: source,
            context: ExecutionContext(
                cycle: nil,
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .idle
            )
        )
    }

    package var pendingCount: UInt16 { coordinator.pendingCount }

    package mutating func installPhysicalPresentation(rawValue: UInt32) {
        coordinator.installPhysicalPresentation(
            PresentationRevision(rawValue: rawValue)
        )
    }

    package mutating func admit(
        phaseRawValue: UInt8,
        x: UInt16,
        y: UInt16,
        observedPresentationRevisionRawValue: UInt32,
        priorPhysicalSequenceIsCompleteRawValue: UInt8
    ) -> StaticSignalAnalyzerNRFInputABIOutcome? {
        guard let phase = PointerPhase(rawValue: phaseRawValue),
            x < 480,
            y < 320,
            priorPhysicalSequenceIsCompleteRawValue <= 1
        else { return nil }

        let disposition = coordinator.admit(
            phase: phase,
            position: Point(x: Int32(x), y: Int32(y)),
            source: source,
            observedPresentationRevision: PresentationRevision(
                rawValue: observedPresentationRevisionRawValue
            ),
            priorPhysicalSequenceIsComplete:
                priorPhysicalSequenceIsCompleteRawValue != 0
        )
        return switch disposition {
        case .queued:
            StaticSignalAnalyzerNRFInputABIOutcome(
                disposition: .queued,
                rejection: StaticSignalAnalyzerNRFInputABIOutcome.noRejection
            )
        case .dropped(let rejection):
            StaticSignalAnalyzerNRFInputABIOutcome(
                disposition: .dropped,
                rejection: rejection.rawValue
            )
        case .sequenceCancelled(let rejection):
            StaticSignalAnalyzerNRFInputABIOutcome(
                disposition: .sequenceCancelled,
                rejection: rejection.rawValue
            )
        case .sourceQuiesced(let rejection):
            StaticSignalAnalyzerNRFInputABIOutcome(
                disposition: .sourceQuiesced,
                rejection: rejection.rawValue
            )
        }
    }

    package mutating func takeNext() -> NormalizedPointerEvent? {
        coordinator.takeNext()
    }

    package mutating func quiesce() {
        coordinator.quiesce()
    }
}
