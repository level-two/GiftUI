import GiftUI
import GiftUIExecution

struct ObservableStateAttachmentReservation: Equatable, Sendable {
    let attachment: _GiftUIObservationAttachment

    var targetGeneration: ObservableTargetGeneration {
        ObservableTargetGeneration(rawValue: attachment.generation)
    }
}

enum ObservableStateAttachmentReservationResult: Equatable, Sendable {
    case success(ObservableStateAttachmentReservation)
    case failure(ObservableStateError)
}

struct ObservableStateAttachmentGenerationAllocator: Equatable, Sendable {
    private var nextGeneration: UInt32?

    init() {
        nextGeneration = 0
    }

    init(nextGeneration: UInt32?) {
        self.nextGeneration = nextGeneration
    }

    mutating func reserve(
        slot: UInt16
    ) -> ObservableStateAttachmentReservationResult {
        guard let generation = nextGeneration else {
            return .failure(.registrationGenerationExhausted)
        }

        let successor = generation.addingReportingOverflow(1)
        nextGeneration = successor.overflow ? nil : successor.partialValue
        return .success(
            ObservableStateAttachmentReservation(
                attachment: _GiftUIObservationAttachment(
                    slot: slot,
                    generation: generation
                )
            )
        )
    }
}
