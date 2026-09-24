#if GIFTUI_NRF_EMBEDDED
    /// Drains normalized input against the retained committed presentation.
    /// Action codes remain buffered until the repository dispatch phase.
    package struct StaticSignalAnalyzerNRFEmbeddedInputHandler:
        StaticSignalAnalyzerNRFInputHandler
    {
        private let gestures: UnsafeMutablePointer<StaticSignalAnalyzerNRFEmbeddedGestureSession>
        private let interaction:
            UnsafeMutablePointer<StaticSignalAnalyzerNRFEmbeddedInteractionOwner>
        private let model: UnsafeMutablePointer<StaticSignalAnalyzerNRFModelLocation>
        private var actionCodes: (UInt16?, UInt16?, UInt16?, UInt16?, UInt16?, UInt16?) =
            (nil, nil, nil, nil, nil, nil)
        package private(set) var actionCount: UInt16 = 0

        package init(
            gestures: UnsafeMutablePointer<StaticSignalAnalyzerNRFEmbeddedGestureSession>,
            interaction: UnsafeMutablePointer<StaticSignalAnalyzerNRFEmbeddedInteractionOwner>,
            model: UnsafeMutablePointer<StaticSignalAnalyzerNRFModelLocation>
        ) {
            self.gestures = gestures
            self.interaction = interaction
            self.model = model
        }

        package mutating func beginOpportunity() -> Bool {
            guard gestures.pointee.hasPresentation,
                model.pointee.activeGeneration != nil,
                interaction.pointee.committedRevision != nil
            else { return false }
            return true
        }

        package mutating func handle(
            _ event: NormalizedPointerEvent
        ) -> StaticSignalAnalyzerNRFInputHandling {
            guard let generation = model.pointee.activeGeneration else {
                return .cancelledOrRejected
            }
            switch gestures.pointee.handle(
                event, interaction: interaction.pointee,
                modelGeneration: generation
            ) {
            case .consumed:
                return .consumed
            case .rejected:
                return .cancelledOrRejected
            case .admitted(let actionCode):
                guard actionCount < 6 else { return .cancelledOrRejected }
                switch actionCount {
                case 0: actionCodes.0 = actionCode
                case 1: actionCodes.1 = actionCode
                case 2: actionCodes.2 = actionCode
                case 3: actionCodes.3 = actionCode
                case 4: actionCodes.4 = actionCode
                case 5: actionCodes.5 = actionCode
                default: return .cancelledOrRejected
                }
                actionCount += 1
                return .consumed
            }
        }

        package func actionCode(at index: UInt16) -> UInt16? {
            switch index {
            case 0: actionCodes.0
            case 1: actionCodes.1
            case 2: actionCodes.2
            case 3: actionCodes.3
            case 4: actionCodes.4
            case 5: actionCodes.5
            default: nil
            }
        }
    }
#endif
