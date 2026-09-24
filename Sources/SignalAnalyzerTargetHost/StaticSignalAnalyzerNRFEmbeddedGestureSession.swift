#if GIFTUI_NRF_EMBEDDED
    package enum StaticSignalAnalyzerNRFEmbeddedGestureResult: Equatable {
        case consumed
        case admitted(actionCode: UInt16)
        case rejected
    }

    /// Retains one normalized pointer sequence between serialized firmware
    /// opportunities. A release rechecks committed action and model generation.
    package struct StaticSignalAnalyzerNRFEmbeddedGestureSession {
        private var presentationRevision: PresentationRevision?
        private var activeSource: InputSourceID?
        private var activeSequence: PointerSequenceID?
        private var lastOrdinal: InputOrdinal?
        private var capture = PointerActionCapture<UInt32>()

        package init() {}

        package var hasPresentation: Bool { presentationRevision != nil }

        package mutating func installPhysicalPresentation(_ revision: PresentationRevision) {
            cancelSequence()
            presentationRevision = revision
        }

        package mutating func quiesce() {
            presentationRevision = nil
            cancelSequence()
        }

        package mutating func handle(
            _ event: NormalizedPointerEvent,
            interaction: borrowing StaticSignalAnalyzerNRFEmbeddedInteractionOwner,
            modelGeneration: UInt32
        ) -> StaticSignalAnalyzerNRFEmbeddedGestureResult {
            guard let revision = presentationRevision,
                revision == interaction.committedRevision,
                event.presentationRevision == revision
            else {
                cancelSequence()
                return .rejected
            }
            switch event.phase {
            case .down:
                guard event.ordinal.rawValue == 0 else {
                    cancelSequence()
                    return .rejected
                }
                cancelSequence()
                activeSource = event.source
                activeSequence = event.sequence
                lastOrdinal = event.ordinal
                switch ExecutionGestureAdapter.down(
                    at: event.position,
                    capture: &capture,
                    resolver: interaction
                ) {
                case .captured, .ignored: return .consumed
                default:
                    cancelSequence()
                    return .rejected
                }
            case .move:
                guard validateContinuation(event) else {
                    cancelSequence()
                    return .rejected
                }
                switch ExecutionGestureAdapter.move(
                    at: event.position,
                    capture: &capture,
                    resolver: interaction
                ) {
                case .continued: return .consumed
                default:
                    cancelSequence()
                    return .rejected
                }
            case .up:
                guard validateContinuation(event) else {
                    cancelSequence()
                    return .rejected
                }
                defer { cancelSequence() }
                guard
                    case .activationAdmitted(let admitted) =
                        ExecutionGestureAdapter.up(
                            at: event.position,
                            capture: &capture,
                            resolver: interaction
                        ), let record = interaction.committedRecord(for: admitted.identity),
                    record.generation == admitted.generation,
                    record.targetGeneration.rawValue == modelGeneration,
                    record.action.code < 6
                else { return .rejected }
                return .admitted(actionCode: record.action.code)
            }
        }

        private mutating func validateContinuation(
            _ event: NormalizedPointerEvent
        ) -> Bool {
            guard activeSource == event.source,
                activeSequence == event.sequence,
                let previous = lastOrdinal,
                previous.rawValue < UInt32.max,
                event.ordinal.rawValue == previous.rawValue + 1
            else { return false }
            lastOrdinal = event.ordinal
            return true
        }

        private mutating func cancelSequence() {
            activeSource = nil
            activeSequence = nil
            lastOrdinal = nil
            capture.cancel()
        }
    }
#endif
