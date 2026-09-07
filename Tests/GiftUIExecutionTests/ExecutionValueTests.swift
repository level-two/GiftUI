import Testing

@testable import GiftUIExecution

@Test
func executionIdentitiesPreserveEveryRawBitPatternWithoutSentinels() {
    for rawValue in [UInt32.min, 1, UInt32.max] {
        #expect(RunCycleID(rawValue: rawValue).rawValue == rawValue)
        #expect(SemanticRevision(rawValue: rawValue).rawValue == rawValue)
        #expect(CandidateFrameID(rawValue: rawValue).rawValue == rawValue)
        #expect(ActionGeneration(rawValue: rawValue).rawValue == rawValue)
        #expect(ObservableTargetGeneration(rawValue: rawValue).rawValue == rawValue)
    }

    #expect(MemoryLayout<RunCycleID>.size == 4)
    #expect(MemoryLayout<SemanticRevision>.size == 4)
    #expect(MemoryLayout<CandidateFrameID>.size == 4)
    #expect(MemoryLayout<ActionGeneration>.size == 4)
    #expect(MemoryLayout<ObservableTargetGeneration>.size == 4)
}

@Test
func executionPhaseHasTheExactClosedRawOrder() {
    #expect(ExecutionPhase.idle.rawValue == 0)
    #expect(ExecutionPhase.admitting.rawValue == 1)
    #expect(ExecutionPhase.mutating.rawValue == 2)
    #expect(ExecutionPhase.deriving.rawValue == 3)
    #expect(ExecutionPhase.publishing.rawValue == 4)
    #expect(ExecutionPhase.offering.rawValue == 5)
    #expect(ExecutionPhase.finalizing.rawValue == 6)
    #expect(ExecutionPhase(rawValue: 7) == nil)
    #expect(MemoryLayout<ExecutionPhase>.size == 1)
}

@Test
func executionLimitsPermitOnlyTheSpecifiedZeroCompletionCapacity() {
    let valid = ExecutionLimits(
        maximumInputEvents: 1,
        maximumStateChangeFacts: 2,
        maximumCompletionFacts: 0,
        maximumSemanticActions: 3,
        maximumActiveInputSources: 4,
        maximumCommittedActions: 5
    )

    #expect(valid?.maximumInputEvents == 1)
    #expect(valid?.maximumStateChangeFacts == 2)
    #expect(valid?.maximumCompletionFacts == 0)
    #expect(valid?.maximumSemanticActions == 3)
    #expect(valid?.maximumActiveInputSources == 4)
    #expect(valid?.maximumCommittedActions == 5)
    #expect(MemoryLayout<ExecutionLimits>.size == 12)

    for zeroField in 0 ..< 5 {
        let values: [UInt16] = (0 ..< 5).map { $0 == zeroField ? 0 : 1 }
        #expect(
            ExecutionLimits(
                maximumInputEvents: values[0],
                maximumStateChangeFacts: values[1],
                maximumCompletionFacts: 0,
                maximumSemanticActions: values[2],
                maximumActiveInputSources: values[3],
                maximumCommittedActions: values[4]
            ) == nil
        )
    }
}

@Test
func executionContextPreservesExactOptionalCorrelation() {
    let idle = ExecutionContext(
        cycle: nil,
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .idle
    )
    let active = ExecutionContext(
        cycle: RunCycleID(rawValue: 11),
        semanticRevision: SemanticRevision(rawValue: 12),
        candidateFrame: CandidateFrameID(rawValue: 13),
        phase: .offering
    )

    #expect(idle.cycle == nil)
    #expect(idle.semanticRevision == nil)
    #expect(idle.candidateFrame == nil)
    #expect(idle.phase == .idle)
    #expect(active.cycle == RunCycleID(rawValue: 11))
    #expect(active.semanticRevision == SemanticRevision(rawValue: 12))
    #expect(active.candidateFrame == CandidateFrameID(rawValue: 13))
    #expect(active.phase == .offering)
    #expect(MemoryLayout<ExecutionContext>.size <= 24)
}
