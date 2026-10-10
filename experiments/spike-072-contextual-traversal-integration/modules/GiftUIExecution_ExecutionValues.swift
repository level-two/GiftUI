import GiftUI
import GiftUIRenderCore

package struct RunCycleID: Equatable, Hashable, Sendable {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

package struct SemanticRevision: Equatable, Hashable, Sendable {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

package struct CandidateFrameID: Equatable, Hashable, Sendable {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

package struct ActionGeneration: Equatable, Hashable, Sendable {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

package struct ObservableTargetGeneration: Equatable, Hashable, Sendable {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

package enum ExecutionPhase: UInt8, Equatable, Sendable {
    case idle = 0
    case admitting = 1
    case mutating = 2
    case deriving = 3
    case publishing = 4
    case offering = 5
    case finalizing = 6
}

package struct ExecutionLimits: Equatable, Sendable {
    package let maximumInputEvents: UInt16
    package let maximumStateChangeFacts: UInt16
    package let maximumCompletionFacts: UInt16
    package let maximumSemanticActions: UInt16
    package let maximumActiveInputSources: UInt16
    package let maximumCommittedActions: UInt16

    package init?(
        maximumInputEvents: UInt16,
        maximumStateChangeFacts: UInt16,
        maximumCompletionFacts: UInt16,
        maximumSemanticActions: UInt16,
        maximumActiveInputSources: UInt16,
        maximumCommittedActions: UInt16
    ) {
        guard maximumInputEvents > 0,
            maximumStateChangeFacts > 0,
            maximumSemanticActions > 0,
            maximumActiveInputSources > 0,
            maximumCommittedActions > 0
        else { return nil }

        self.maximumInputEvents = maximumInputEvents
        self.maximumStateChangeFacts = maximumStateChangeFacts
        self.maximumCompletionFacts = maximumCompletionFacts
        self.maximumSemanticActions = maximumSemanticActions
        self.maximumActiveInputSources = maximumActiveInputSources
        self.maximumCommittedActions = maximumCommittedActions
    }
}

package struct ExecutionContext: Equatable, Sendable {
    package let cycle: RunCycleID?
    package let semanticRevision: SemanticRevision?
    package let candidateFrame: CandidateFrameID?
    package let phase: ExecutionPhase

    package init(
        cycle: RunCycleID?,
        semanticRevision: SemanticRevision?,
        candidateFrame: CandidateFrameID?,
        phase: ExecutionPhase
    ) {
        self.cycle = cycle
        self.semanticRevision = semanticRevision
        self.candidateFrame = candidateFrame
        self.phase = phase
    }
}
