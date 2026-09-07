import GiftUI
import Testing

@testable import GiftUIExecution

private struct FixtureStateChangeFact: Equatable, Sendable {
    let rawValue: UInt8
}

private struct FixtureCompletionFact: Equatable, Sendable {
    let rawValue: UInt8
}

private enum FixtureOwnerFailure: UInt8, Equatable, Sendable {
    case failed = 0
}

private struct FixtureAdmissionSink: ExecutionAdmissionSink {
    var context: ExecutionContext

    mutating func submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome {
        ExecutionAdmissionOutcome(result: .queued, context: context)
    }

    mutating func submit(stateChange: FixtureStateChangeFact) -> ExecutionAdmissionOutcome {
        ExecutionAdmissionOutcome(result: .queued, context: context)
    }

    mutating func submit(completion: FixtureCompletionFact) -> ExecutionAdmissionOutcome {
        ExecutionAdmissionOutcome(result: .queued, context: context)
    }
}

private struct FixtureOpportunityRunner: ExecutionOpportunityRunner {
    let result: RunCycleResult<FixtureOwnerFailure>

    mutating func runOpportunity() -> RunCycleResult<FixtureOwnerFailure> {
        result
    }
}

private struct FixtureSemanticActionIdentity: Equatable, Sendable {
    let path: UInt16
    let role: UInt16
}

private struct FixtureActionView: ExecutionActionView {
    let identity: FixtureSemanticActionIdentity
    let generation: ActionGeneration

    func generation(for identity: FixtureSemanticActionIdentity) -> ActionGeneration? {
        identity == self.identity ? generation : nil
    }

    func isEnabled(_ identity: FixtureSemanticActionIdentity) -> Bool? {
        identity == self.identity ? true : nil
    }

    func hit(at point: Point) -> FixtureSemanticActionIdentity? {
        point == Point(x: 3, y: 5) ? identity : nil
    }
}

private let fixtureLimits = ExecutionLimits(
    maximumInputEvents: 4,
    maximumStateChangeFacts: 3,
    maximumCompletionFacts: 2,
    maximumSemanticActions: 4,
    maximumActiveInputSources: 1,
    maximumCommittedActions: 4
)!

private let idleContext = ExecutionContext(
    cycle: nil,
    semanticRevision: nil,
    candidateFrame: nil,
    phase: .idle
)

private func requireSendable<T: Sendable>(_: T.Type) {}

@Test
func admissionKindsAndResultsHaveExactClosedRawValues() {
    #expect(AdmissionKind.pointer.rawValue == 0)
    #expect(AdmissionKind.stateChange.rawValue == 1)
    #expect(AdmissionKind.completion.rawValue == 2)
    #expect(AdmissionKind.semanticAction.rawValue == 3)
    #expect(AdmissionKind.dirtyRederivation.rawValue == 4)
    #expect(AdmissionKind.presentationRecovery.rawValue == 5)
    #expect(AdmissionKind(rawValue: 6) == nil)
    #expect(ExecutionAdmissionResult.queued.rawValue == 0)
    #expect(ExecutionAdmissionResult.capacityRefused.rawValue == 1)
    #expect(ExecutionAdmissionResult.unavailable.rawValue == 2)
    #expect(ExecutionAdmissionResult.invalidValue.rawValue == 3)
    #expect(ExecutionAdmissionResult.invalidProvenance.rawValue == 4)
    #expect(ExecutionAdmissionResult(rawValue: 5) == nil)
    #expect(MemoryLayout<AdmissionKind>.size == 1)
    #expect(MemoryLayout<ExecutionAdmissionResult>.size == 1)
}

@Test
func admissionOutcomeAndProducerProtocolsPreserveTypedValues() {
    let activeContext = ExecutionContext(
        cycle: RunCycleID(rawValue: 8),
        semanticRevision: SemanticRevision(rawValue: 13),
        candidateFrame: nil,
        phase: .mutating
    )
    let outcome = ExecutionAdmissionOutcome(result: .capacityRefused, context: activeContext)

    #expect(outcome.result == .capacityRefused)
    #expect(outcome.context == activeContext)
    #expect(MemoryLayout<ExecutionAdmissionOutcome>.size <= 28)
    requireSendable(ExecutionAdmissionOutcome.self)

    var sink = FixtureAdmissionSink(context: activeContext)
    #expect(sink.submit(stateChange: FixtureStateChangeFact(rawValue: 1)).context == activeContext)
    #expect(sink.submit(completion: FixtureCompletionFact(rawValue: 2)).result == .queued)
}

@Test
func admissionSummaryAcceptsLimitsAndRejectsEachOverflow() {
    let valid = AdmissionSummary(
        inputEventCount: 4,
        stateChangeFactCount: 3,
        completionFactCount: 2,
        semanticActionCount: 4,
        includesDirtyRederivation: true,
        includesPresentationRecovery: true,
        limits: fixtureLimits
    )

    #expect(valid?.inputEventCount == 4)
    #expect(valid?.stateChangeFactCount == 3)
    #expect(valid?.completionFactCount == 2)
    #expect(valid?.semanticActionCount == 4)
    #expect(valid?.includesDirtyRederivation == true)
    #expect(valid?.includesPresentationRecovery == true)
    #expect(MemoryLayout<AdmissionSummary>.size <= 12)

    let rejectedCounts: [(UInt16, UInt16, UInt16, UInt16)] = [
        (5, 0, 0, 0),
        (0, 4, 0, 0),
        (0, 0, 3, 0),
        (4, 0, 0, 5),
        (1, 0, 0, 2),
    ]
    for counts in rejectedCounts {
        #expect(
            AdmissionSummary(
                inputEventCount: counts.0,
                stateChangeFactCount: counts.1,
                completionFactCount: counts.2,
                semanticActionCount: counts.3,
                includesDirtyRederivation: false,
                includesPresentationRecovery: false,
                limits: fixtureLimits
            ) == nil
        )
    }

    let completionDisabled = ExecutionLimits(
        maximumInputEvents: 1,
        maximumStateChangeFacts: 1,
        maximumCompletionFacts: 0,
        maximumSemanticActions: 1,
        maximumActiveInputSources: 1,
        maximumCommittedActions: 1
    )!
    #expect(
        AdmissionSummary(
            inputEventCount: 0,
            stateChangeFactCount: 0,
            completionFactCount: 1,
            semanticActionCount: 0,
            includesDirtyRederivation: false,
            includesPresentationRecovery: false,
            limits: completionDisabled
        ) == nil
    )
}

@Test
func actionViewAndCapturePreserveExactIdentityGenerationPair() {
    let identity = FixtureSemanticActionIdentity(path: 21, role: 34)
    let generation = ActionGeneration(rawValue: 55)
    let view = FixtureActionView(identity: identity, generation: generation)
    let capture = CapturedAction(identity: identity, generation: generation)

    #expect(view.hit(at: Point(x: 3, y: 5)) == identity)
    #expect(view.generation(for: identity) == generation)
    #expect(view.isEnabled(identity) == true)
    #expect(capture.identity == identity)
    #expect(capture.generation == generation)
    #expect(MemoryLayout<CapturedAction<FixtureSemanticActionIdentity>>.size == 8)
    requireSendable(CapturedAction<FixtureSemanticActionIdentity>.self)
}

@Test
func opportunityRunnerUsesTheGenericTypedResultSeam() {
    let admission = AdmissionSummary(
        inputEventCount: 0,
        stateChangeFactCount: 0,
        completionFactCount: 0,
        semanticActionCount: 0,
        includesDirtyRederivation: false,
        includesPresentationRecovery: false,
        limits: fixtureLimits
    )!
    let summary = RunCycleSummary(
        cycle: RunCycleID(rawValue: 1),
        admission: admission,
        semanticRevision: nil,
        semanticDisposition: .unchanged,
        logicalFrameDisposition: .notProduced,
        committedPresentationRevision: nil,
        presentationIntentState: .satisfied,
        presentationPending: nil,
        operationalEvents: []
    )!
    var runner = FixtureOpportunityRunner(result: .success(summary))

    #expect(runner.runOpportunity() == .success(summary))
    #expect(idleContext.phase == .idle)
}
