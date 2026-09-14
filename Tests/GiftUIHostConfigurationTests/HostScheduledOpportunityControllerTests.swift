import GiftUIExecution
import GiftUIRuntimeCore
import Testing

@testable import GiftUIHostConfiguration

private enum ScheduledFixtureFailure: UInt8, Equatable, Sendable {
    case unused
}

private final class ScheduledProbe {
    private var storage = HostSequencedFactAdmission<UInt16, UInt16, UInt16>(
        producerLimits: HostFactProducerLimits(
            transition: 20,
            bootstrap: 2,
            action: 6
        )!
    )!
    var runCount = 0
    var applied: [UInt16] = []
    var changeReports: [UInt16] = []
    var derivationCount = 0

    func admit(_ fact: UInt16) -> HostFactAdmissionOutcome {
        storage.admitCompact(fact, category: .transition)
    }

    func applySealedFacts() {
        let didSeal = storage.seal()
        #expect(didSeal)
        while let sealed = storage.takeNextSealed() {
            guard case .compact(let fact) = sealed else {
                Issue.record("expected a transition compact fact")
                continue
            }
            applied.append(fact.value)
            changeReports.append(fact.value)
        }
    }
}

private struct ScheduledFixtureInstance: MVPHostInstance {
    let assemblyReport: HostAssemblyReport
    let probe: ScheduledProbe
    var lifecycleState: MVPHostLifecycleState

    mutating func activate() -> HostActivationResult<ScheduledFixtureFailure> {
        .active
    }

    mutating func runOpportunity() -> HostOpportunityResult {
        guard lifecycleState == .active else { return .invalidLifecycle }
        probe.runCount += 1
        probe.applySealedFacts()
        probe.derivationCount += 1
        return .cycle(
            .failure(
                ExecutionContext(
                    cycle: nil,
                    semanticRevision: nil,
                    candidateFrame: nil,
                    phase: .idle
                ),
                .execution(.invariantViolation),
                nil
            )
        )
    }

    mutating func teardown() {
        lifecycleState = .quiescent
    }
}

@Test func wakeRecordingReturnsBeforeRuntimeEntryAndCoalesces() {
    let report = scheduledReport()
    let probe = ScheduledProbe()
    var instance = ScheduledFixtureInstance(
        assemblyReport: report,
        probe: probe,
        lifecycleState: .active
    )
    var controller = HostScheduledOpportunityController(
        assemblyReport: report,
        initialFrameOriginMicroseconds: 0
    )

    #expect(probe.admit(1) == .accepted(sequence: 1))
    #expect(controller.recordAcceptedFact(at: 1) == .success(.requestWake))
    #expect(controller.record(.semanticDirty, at: 2) == .success(.coalesced))
    #expect(probe.runCount == 0)
    #expect(
        controller.service(at: 249_999, instance: &instance)
            == .wait(untilMicroseconds: 250_000)
    )
    #expect(probe.runCount == 0)

    let result = controller.service(at: 250_000, instance: &instance)
    guard case .cycle(let reasons, _) = result else {
        Issue.record("expected one scheduled runtime opportunity")
        return
    }
    #expect(reasons == [.admittedWork, .semanticDirty])
    #expect(probe.runCount == 1)
}

@Test func lifecycleAndReportMismatchInvokeNoRuntimeOwner() {
    let report = scheduledReport()
    let probe = ScheduledProbe()
    var inactive = ScheduledFixtureInstance(
        assemblyReport: report,
        probe: probe,
        lifecycleState: .valid
    )
    var controller = HostScheduledOpportunityController(
        assemblyReport: report,
        initialFrameOriginMicroseconds: 0
    )
    #expect(controller.recordAcceptedFact(at: 1) == .success(.requestWake))
    #expect(
        controller.service(at: 250_000, instance: &inactive)
            == .rejected(.invalidLifecycle, pacing: nil)
    )
    #expect(probe.runCount == 0)

    var mismatched = ScheduledFixtureInstance(
        assemblyReport: differentScheduledReport(report),
        probe: probe,
        lifecycleState: .active
    )
    #expect(
        controller.service(at: 250_000, instance: &mismatched)
            == .rejected(.assemblyReportMismatch, pacing: nil)
    )
    #expect(probe.runCount == 0)
    #expect(controller.assemblyReport == report)
}

@Test func eightyOrderedFactsProduceFourPacedDerivations() {
    let report = scheduledReport()
    let probe = ScheduledProbe()
    var instance = ScheduledFixtureInstance(
        assemblyReport: report,
        probe: probe,
        lifecycleState: .active
    )
    var controller = HostScheduledOpportunityController(
        assemblyReport: report,
        initialFrameOriginMicroseconds: 0
    )
    var wakeCount = 0

    for rawFact in UInt16(1) ... 80 {
        #expect(probe.admit(rawFact) == .accepted(sequence: UInt32(rawFact)))
        let timestamp = UInt64(rawFact) * 12_500
        if controller.recordAcceptedFact(at: timestamp) == .success(.requestWake) {
            wakeCount += 1
        }
        if rawFact.isMultiple(of: 20) {
            guard
                case .cycle = controller.service(
                    at: timestamp,
                    instance: &instance
                )
            else {
                Issue.record("expected paced opportunity at fact \(rawFact)")
                return
            }
        }
    }

    #expect(probe.applied == Array(UInt16(1) ... 80))
    #expect(probe.changeReports == probe.applied)
    #expect(probe.derivationCount == 4)
    #expect(probe.runCount == 4)
    #expect(wakeCount == 4)
}

@Test func quiescenceRejectsLaterSchedulingWithoutRuntimeEntry() {
    let report = scheduledReport()
    let probe = ScheduledProbe()
    var instance = ScheduledFixtureInstance(
        assemblyReport: report,
        probe: probe,
        lifecycleState: .active
    )
    var controller = HostScheduledOpportunityController(
        assemblyReport: report,
        initialFrameOriginMicroseconds: 0
    )

    #expect(controller.quiesce() == nil)
    #expect(controller.recordAcceptedFact(at: 1) == .failure(.unavailable))
    #expect(
        controller.service(at: 250_000, instance: &instance)
            == .rejected(.pacingRejected, pacing: .unavailable)
    )
    #expect(probe.runCount == 0)
}

private func scheduledReport() -> HostAssemblyReport {
    var validator = makeValidHostValidator()
    guard case .valid(let report) = validator.validate() else {
        fatalError("valid generated host report required")
    }
    return report
}

private func differentScheduledReport(
    _ report: HostAssemblyReport
) -> HostAssemblyReport {
    HostAssemblyReport(
        kind: report.kind,
        profile: report.profile,
        storageAudit: report.storageAudit,
        capabilitySnapshot: report.capabilitySnapshot,
        effectivePresentation: report.effectivePresentation,
        drawingPlanOperationLimit: report.drawingPlanOperationLimit,
        minimumSinkOperationCapacity: report.minimumSinkOperationCapacity,
        cardinality: report.cardinality,
        minimumFrameIntervalMicroseconds: report.minimumFrameIntervalMicroseconds,
        maximumFactServiceLatencyMicroseconds:
            report.maximumFactServiceLatencyMicroseconds,
        minimumAcceptedTransitionSpacingMicroseconds:
            report.minimumAcceptedTransitionSpacingMicroseconds,
        maximumCompactFactsPerServiceWindow:
            report.maximumCompactFactsPerServiceWindow,
        maximumRetryableRefusals: report.maximumRetryableRefusals - 1
    )
}
