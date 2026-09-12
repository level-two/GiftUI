import GiftUIExecution
import Testing

@testable import GiftUIRuntimeCore

func makeRuntimeCoordinatorLifecycleAudit() -> RuntimeStorageAudit {
    guard
        case .valid(let audit) = RuntimeStorageAudit.checked(
            profile: .dynamic,
            limits: makeRuntimeCoreAuditLimits(),
            byteCounts: makeRuntimeCoreByteCounts()
        )
    else {
        fatalError("fixture audit must be valid")
    }
    return audit
}

private func context(
    cycle: UInt32? = nil,
    semanticRevision: UInt32? = nil,
    candidateFrame: UInt32? = nil,
    phase: ExecutionPhase
) -> ExecutionContext {
    ExecutionContext(
        cycle: cycle.map(RunCycleID.init(rawValue:)),
        semanticRevision: semanticRevision.map(SemanticRevision.init(rawValue:)),
        candidateFrame: candidateFrame.map(CandidateFrameID.init(rawValue:)),
        phase: phase
    )
}

func makeIdleRuntimeCoordinatorLifecycle() -> RuntimeCoordinatorLifecycle {
    var lifecycle = RuntimeCoordinatorLifecycle()
    let validation = lifecycle.validate(.valid(makeRuntimeCoordinatorLifecycleAudit()))
    if validation != nil { fatalError("fixture validation must succeed") }
    let activation = lifecycle.enterIdle()
    if activation != nil { fatalError("fixture activation must succeed") }
    return lifecycle
}

@Test
func successfulConstructionTraversesValidatedAndRetainsImmutableAudit() {
    var lifecycle = RuntimeCoordinatorLifecycle()
    let audit = makeRuntimeCoordinatorLifecycleAudit()

    #expect(lifecycle.state == .unvalidated)
    let validation = lifecycle.validate(.valid(audit))
    #expect(validation == nil)
    #expect(lifecycle.state == .validated)
    #expect(lifecycle.storageAudit == audit)
    let activation = lifecycle.enterIdle()
    #expect(activation == nil)
    #expect(lifecycle.state == .idle)
    #expect(lifecycle.storageAudit == audit)
}

@Test
func rejectedConstructionIsTerminalAndNeverEntersIdle() {
    var lifecycle = RuntimeCoordinatorLifecycle()

    let rejection = lifecycle.validate(.invalid(.insufficientStorage))
    #expect(rejection == .insufficientStorage)
    #expect(lifecycle.state == .rejected)
    #expect(lifecycle.validationFailure == .insufficientStorage)
    #expect(lifecycle.storageAudit == nil)
    #expect(lifecycle.enterIdle() == .invariantViolation)
    #expect(lifecycle.beginAdmission() == .requiredFacilityUnavailable)
}

@Test
func admissionEntryIsSerializedAndRetainsReturnedContext() {
    var lifecycle = makeIdleRuntimeCoordinatorLifecycle()

    #expect(lifecycle.beginAdmission() == nil)
    #expect(lifecycle.beginAdmission() == .reentrancyViolation)
    #expect(
        lifecycle.beginOpportunity(context: context(cycle: 1, phase: .admitting))
            == .reentrancyViolation
    )
    let returned = context(semanticRevision: 7, phase: .idle)
    #expect(lifecycle.finishAdmission(context: returned) == nil)
    #expect(lifecycle.executionContext == returned)
    #expect(lifecycle.state == .idle)
}

@Test
func opportunityEntryIsExclusiveAndRetainsEveryContextSnapshot() {
    var lifecycle = makeIdleRuntimeCoordinatorLifecycle()
    let admitting = context(cycle: 1, phase: .admitting)

    #expect(lifecycle.beginOpportunity(context: admitting) == nil)
    #expect(lifecycle.state == .active)
    #expect(lifecycle.executionContext == admitting)
    #expect(lifecycle.beginOpportunity(context: admitting) == .reentrancyViolation)
    #expect(lifecycle.beginAdmission() == .reentrancyViolation)

    let deriving = context(cycle: 1, candidateFrame: 2, phase: .deriving)
    #expect(lifecycle.recordActiveContext(deriving) == nil)
    #expect(lifecycle.executionContext == deriving)

    let idle = context(semanticRevision: 3, phase: .idle)
    #expect(lifecycle.finishOpportunity(context: idle) == nil)
    #expect(lifecycle.executionContext == idle)
    #expect(lifecycle.state == .idle)
}

@Test
func invalidOpportunityContextCannotAcquireOrReleaseTheSerializedEntry() {
    var lifecycle = makeIdleRuntimeCoordinatorLifecycle()

    #expect(
        lifecycle.beginOpportunity(context: context(cycle: 1, phase: .deriving))
            == .invalidPhase
    )
    #expect(lifecycle.state == .idle)
    let admitting = context(cycle: 1, phase: .admitting)
    #expect(lifecycle.beginOpportunity(context: admitting) == nil)
    #expect(
        lifecycle.finishOpportunity(context: context(cycle: 1, phase: .finalizing))
            == .invalidPhase
    )
    #expect(lifecycle.state == .active)
}

@Test
func activeQuiescenceDefersTerminalTransitionUntilOpportunityFinishes() {
    var lifecycle = makeIdleRuntimeCoordinatorLifecycle()
    #expect(
        lifecycle.beginOpportunity(context: context(cycle: 1, phase: .admitting)) == nil
    )

    lifecycle.requestQuiescence()
    #expect(lifecycle.state == .active)
    #expect(!lifecycle.isQuiescent)
    #expect(lifecycle.finishOpportunity(context: context(phase: .idle)) == nil)
    #expect(lifecycle.state == .quiescent)
    #expect(lifecycle.isQuiescent)
    #expect(lifecycle.beginAdmission() == .requiredFacilityUnavailable)
    let didTearDown = lifecycle.completeTeardown()
    #expect(didTearDown)
    #expect(lifecycle.state == .tornDown)
    #expect(lifecycle.isQuiescent)
    let didRepeatTeardown = lifecycle.completeTeardown()
    #expect(!didRepeatTeardown)
}

@Test
func idleQuiescenceIsSynchronousAndIdempotentlyUnavailable() {
    var lifecycle = makeIdleRuntimeCoordinatorLifecycle()

    lifecycle.requestQuiescence()
    lifecycle.requestQuiescence()
    #expect(lifecycle.state == .quiescent)
    #expect(lifecycle.beginAdmission() == .requiredFacilityUnavailable)
    #expect(
        lifecycle.beginOpportunity(context: context(cycle: 1, phase: .admitting))
            == .requiredFacilityUnavailable
    )
}
