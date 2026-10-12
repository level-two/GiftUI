import P08CounterSchema
import GiftUI
import GiftUIDrawing
@testable import GiftUIExecution
@testable import GiftUIHostConfiguration
import GiftUIObservableState
@testable import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore

extension StaticCounterProfileStorage {
    mutating func runCounterHost(failAfterRuntime: Bool) -> Int {
        guard case .valid(let audit) = audit(), let assembly = CounterHostAssembly.validate(audit, kind: .macOSStatic) else { preconditionFailure("counter valid-only host") }
        return counterForeignJoinScope { foreignModels, foreignRoot, foreignControl in
            let ownedChecks = counterOwnedSchedulerCompatibility(assembly.report)
            // Declared producer-projection negatives, not analyzer producer behavior.
            precondition(CounterHostAssembly.validate(audit, kind: .macOSStatic, sourceCallbacks: 21) == nil)
            precondition(CounterHostAssembly.validate(audit, kind: .macOSStatic, repositoryCallbacks: 2) == nil)
            precondition(CounterHostAssembly.validate(audit, kind: .macOSStatic, useCaseCallbacks: 2) == nil)
            precondition(CounterHostAssembly.validate(audit, kind: .macOSStatic, nonTransitionPublications: 2) == nil)
            let limits = self.limits
            var keys = interaction.take()
            var checks = 0
            do throws(ObservableStateError) {
                try root.withLifetime(limits: limits.observableState) { (models, root) throws(ObservableStateError) in
                    do throws(SemanticExpansionError) {
                        var records = semanticBacking.records.mutableSpan
                        var paths = semanticBacking.paths.mutableSpan
                        var payloads = semanticBacking.payloads.mutableSpan
                        var scalars = semanticBacking.scalars.mutableSpan
                        try semantic.withLifetime(configuredLimits: counterSemanticConfiguration(limits), records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (semantic) throws(SemanticExpansionError) in
                            do throws(DrawingError) {
                                var entries = canvasBacking.mutableSpan
                                try canvas.withLifetime(entries: &entries, table: CounterValueTable(), capacity: 1, limits: limits.staticCanvas!) { values in
                                    checks = workspace.withGeometry { geometry in
                                        withUnsafeMutablePointer(to: &control) { pointer in
                                            let activationBacking: InlineArray<1, UInt8> = [1]
                                            let supplied = CounterHostSupplied(models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic.borrowedStore(), values: values.borrowedValues(), control: pointer, audit: audit, geometry: geometry, interaction: keys.take()!)
                                            var owner = CounterHostOwner(supplied: consume supplied, activationSpan: activationBacking.span, assembly: assembly, failAfterRuntime: failAfterRuntime)
                                            let expected = counterJoinSnapshot(pointer)
                                            let foreignExpected = counterJoinSnapshot(foreignControl)
                                            var joinChecks = 0
                                            let rejected0 = owner.constructRuntimeAndEndpoint(models: models, root: root, control: foreignControl, audit: audit, report: assembly.report)
                                            precondition(rejected0 == .failure(.configuration(.invalidWakeIntegration), progress: .init()))
                                            precondition(owner.constructions == 0 && owner.activationStep == 0)
                                            precondition(counterJoinSnapshot(pointer) == expected && counterJoinSnapshot(foreignControl) == foreignExpected)
                                            joinChecks += 3
                                            let rejected1 = owner.constructRuntimeAndEndpoint(models: foreignModels, root: foreignRoot, control: pointer, audit: audit, report: assembly.report)
                                            precondition(rejected1 == .failure(.configuration(.invalidModelTarget), progress: .init()))
                                            precondition(owner.constructions == 0 && owner.activationStep == 0)
                                            precondition(counterJoinSnapshot(pointer) == expected && counterJoinSnapshot(foreignControl) == foreignExpected)
                                            joinChecks += 3
                                            let rejected2 = owner.constructRuntimeAndEndpoint(models: models, root: foreignRoot, control: pointer, audit: audit, report: assembly.report)
                                            precondition(rejected2 == .failure(.configuration(.invalidModelTarget), progress: .init()))
                                            precondition(owner.constructions == 0 && owner.activationStep == 0)
                                            precondition(counterJoinSnapshot(pointer) == expected && counterJoinSnapshot(foreignControl) == foreignExpected)
                                            joinChecks += 3
                                            let rejected3 = owner.constructRuntimeAndEndpoint(models: models, root: root, control: pointer, audit: counterJoinAudit(audit, profile: .dynamic), report: assembly.report)
                                            precondition(rejected3 == .failure(.configuration(.profileMismatch), progress: .init()))
                                            precondition(owner.constructions == 0 && owner.activationStep == 0)
                                            precondition(counterJoinSnapshot(pointer) == expected && counterJoinSnapshot(foreignControl) == foreignExpected)
                                            joinChecks += 3
                                            let rejected4 = owner.constructRuntimeAndEndpoint(models: models, root: root, control: pointer, audit: counterJoinAudit(audit, profile: audit.profile), report: assembly.report)
                                            precondition(rejected4 == .failure(.configuration(.invalidWorkload), progress: .init()))
                                            precondition(owner.constructions == 0 && owner.activationStep == 0)
                                            precondition(counterJoinSnapshot(pointer) == expected && counterJoinSnapshot(foreignControl) == foreignExpected)
                                            joinChecks += 3
                                            let rejected5 = owner.constructRuntimeAndEndpoint(models: models, root: root, control: pointer, audit: audit, report: counterJoinReport(assembly.report))
                                            precondition(rejected5 == .failure(.configuration(.invalidWakeIntegration), progress: .init()))
                                            precondition(owner.constructions == 0 && owner.activationStep == 0)
                                            precondition(counterJoinSnapshot(pointer) == expected && counterJoinSnapshot(foreignControl) == foreignExpected)
                                            joinChecks += 3
                                            var host = SignalAnalyzerPresetHostInstances.macOSStatic(report: assembly.report, owner: consume owner)!
                                            precondition(host.lifecycleState == .valid && host.owner.constructions == 0 && pointer.pointee.finalized == 0)
                                            precondition(host.runOpportunity() == .invalidLifecycle)
                                            var count = 2 + joinChecks
                                            let activation = host.activate()
                                            if failAfterRuntime {
                                                precondition(activation == .failure(.configuration(.arithmeticOverflow)) && host.lifecycleState == .failed)
                                                precondition(pointer.pointee.teardowns == 1 && pointer.pointee.finalized == 0)
                                                count += 2
                                            } else {
                                                precondition(activation == .active && host.owner.activationStep == 7 && host.owner.constructions == 1)
                                                precondition(pointer.pointee.finalized == 2 && pointer.pointee.commits == 1 && pointer.pointee.committedRecords == 2)
                                                precondition(pointer.pointee.admission.pendingStateCount == 1)
                                                let wakeControl = CounterHostControl(pointer: pointer)
                                                guard case .wait(untilMicroseconds: 250000) = counterServiceHost(at: 0, host: &host, control: wakeControl) else { preconditionFailure("counter actual wake pacing") }
                                                guard case .cycle(.admittedWork, .cycle(.success)) = counterServiceHost(at: 250000, host: &host, control: wakeControl) else { preconditionFailure("counter actual paced wake") }
                                                precondition(pointer.pointee.finalized == 3 && pointer.pointee.admission.pendingStateCount == 0)
                                                guard case .noWork = counterServiceHost(at: 250000, host: &host, control: wakeControl) else { preconditionFailure("counter no idle polling") }
                                                count += 7 + counterHostCorpus(host: &host, control: pointer)
                                            }
                                            precondition(host.activate() == .failure(.invariant) && host.owner.constructions == 1)
                                            host.teardown()
                                            precondition(host.lifecycleState == .quiescent && !host.controller.assemblyReportRuntimeUseIsValid && host.owner.teardownStep == 8)
                                            precondition(pointer.pointee.teardowns == 1 && pointer.pointee.committedRecords == 0 && !pointer.pointee.hasRoot)
                                            host.teardown()
                                            precondition(host.owner.teardownStep == 8 && host.runOpportunity() == .invalidLifecycle)
                                            precondition(host.assemblyReport == assembly.report)
                                            let expectedApplication = failAfterRuntime ? 0 : 1
                                            precondition(pointer.pointee.applicationConstructions == expectedApplication)
                                            precondition(pointer.pointee.applicationCallbacks == expectedApplication && pointer.pointee.reentrantApplicationRejections == expectedApplication)
                                            precondition(pointer.pointee.observationsInstalled == expectedApplication && pointer.pointee.observationsDetached == expectedApplication)
                                            precondition(pointer.pointee.stoppedApplicationChecks >= expectedApplication)
                                            var stoppedAdmission = CounterAdmission(borrowing: pointer)
                                            precondition(stoppedAdmission.submit(stateChange: 9).result == .unavailable)
                                            precondition(pointer.pointee.admission.pendingStateCount == 0)
                                            precondition(!pointer.pointee.inputGate.inputIsEligible)
                                            let rejectedInput = pointer.pointee.inputGate.submit(phase: .down, position: .init(x: 0, y: 0), source: .init(rawValue: 0), observedPresentationRevision: pointer.pointee.runtime.committedPresentation, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &stoppedAdmission)
                                            precondition(rejectedInput == .sourceQuiesced(.inputUnavailable))
                                            return count + 13
                                        }
                                    }
                                }
                            } catch { preconditionFailure("counter host Canvas") }
                        }
                    } catch { preconditionFailure("counter host semantics") }
                }
            } catch { preconditionFailure("counter host model") }
            return checks + ownedChecks + 4
        }
    }
}

package func p08CounterHost() -> Int {
    var models = ObservableModelOwnerNamespace()
    var semantics = SemanticRecordOwnerNamespace()
    do {
        var complete = StaticCounterProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantics.issue())
        var partial = StaticCounterProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantics.issue())
        return complete.runCounterHost(failAfterRuntime: false) + partial.runCounterHost(failAfterRuntime: true)
    } catch { preconditionFailure("counter host identities") }
}

// Ordinary owned conformers remain valid callers of the same widened internal
// helper; runtime failures and lifecycle gating remain unchanged.
private struct CounterOwnedSchedulerHost: MVPHostInstance {
    typealias ActivationFailure = MacOSStaticHostActivationFailure
    let assemblyReport: HostAssemblyReport
    var lifecycleState: MVPHostLifecycleState = .active
    var calls = 0
    mutating func activate() -> HostActivationResult<ActivationFailure> { .active }
    mutating func runOpportunity() -> HostOpportunityResult<RuntimeOwnerFailure> {
        calls += 1
        return .cycle(.failure(.init(cycle: nil, semanticRevision: nil, candidateFrame: nil, phase: .idle), .execution(.capacityExhausted), nil))
    }
    mutating func teardown() { lifecycleState = .quiescent }
}
private func counterOwnedSchedulerCompatibility(_ report: HostAssemblyReport) -> Int {
    var instance = CounterOwnedSchedulerHost(assemblyReport: report)
    var scheduler = HostScheduledOpportunityController(assemblyReport: report, initialFrameOriginMicroseconds: 0)
    precondition(scheduler.recordAcceptedFact(at: 1) == .success(.requestWake))
    precondition(scheduler.record(.semanticDirty, at: 1) == .success(.coalesced))
    guard case .wait(untilMicroseconds: 250000) = scheduler.service(at: 1, instance: &instance) else { preconditionFailure("owned pacing") }
    guard case .cycle(_, .cycle(.failure(_, .execution(.capacityExhausted), nil))) = scheduler.service(at: 250000, instance: &instance) else { preconditionFailure("owned exact failure") }
    instance.teardown()
    precondition(scheduler.service(at: 500000, instance: &instance) == .rejected(.invalidLifecycle, pacing: nil))
    precondition(instance.calls == 1)
    return 6
}


// Test snapshots observe both live controls without issuing owner work.
struct CounterJoinSnapshot: Equatable {
    let requests: UInt32?
    let reasons: ExecutionWakeReasons?
    let outstanding: Bool?
    let hostRequests: Int
    let factRecords: Int
    let firstFact: UInt64?
    let clock: UInt64
    let pointerCount: UInt16
    let stateCount: UInt16
    let completion: UInt16?
    let endpoints: Int
    let applications: Int
    let finalized: Int
    let applied: Int
}
func counterJoinSnapshot(_ control: UnsafeMutablePointer<CounterControl>) -> CounterJoinSnapshot {
    #if !hasFeature(Embedded)
    let endpoints = control.pointee.backend.constructedEndpoints
    #else
    let endpoints = 0
    #endif
    return .init(requests: control.pointee.wake?.requester.requestCount, reasons: control.pointee.wake?.accumulatedReasons, outstanding: control.pointee.wake?.wakeOutstanding, hostRequests: control.pointee.hostWakeRequests, factRecords: control.pointee.acceptedFactWakeRecords, firstFact: control.pointee.wakeFirstFactMicroseconds, clock: control.pointee.wakeClockMicroseconds, pointerCount: control.pointee.admission.pointerCount, stateCount: control.pointee.admission.pendingStateCount, completion: control.pointee.admission.pendingCompletion, endpoints: endpoints, applications: control.pointee.applicationConstructions, finalized: control.pointee.finalized, applied: control.pointee.applied)
}
func counterForeignJoinScope(_ body: (borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, UnsafeMutablePointer<CounterControl>) -> Int) -> Int {
    var namespace = ObservableModelOwnerNamespace()
    do throws(ObservableStateError) {
        let identity = try namespace.issue()
        precondition(identity.rawValue == 0)
        var backing = StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>(identity: identity, schema: 1, needsCapture: false, modelLimit: 2, claimLimit: 4, pinLimit: 2, captureLimit: 0)!
        var foreign = CounterControl()
        return try backing.withLifetime(limits: .init(maximumLocations: 1, maximumRegistrations: 1, maximumStagedAssociations: 1)!) { (models, root) throws(ObservableStateError) in
            withUnsafeMutablePointer(to: &foreign) { body(models, root, $0) }
        }
    } catch { preconditionFailure("counter foreign live scope") }
}
func counterJoinAudit(_ audit: RuntimeStorageAudit, profile: RuntimeProfileKind) -> RuntimeStorageAudit {
    let bytes = RuntimeStorageByteCounts(semanticCandidatePathBytes: audit.semanticCandidatePathBytes, semanticPublishedPathBytes: audit.semanticPublishedPathBytes, semanticCandidatePayloadBytes: audit.semanticCandidatePayloadBytes, semanticPublishedPayloadBytes: audit.semanticPublishedPayloadBytes, identityMatchWorkspaceBytes: audit.identityMatchWorkspaceBytes, interactionCandidateIdentityBytes: audit.interactionCandidateIdentityBytes, interactionCommittedIdentityBytes: audit.interactionCommittedIdentityBytes, modelMetadataBytes: audit.modelMetadataBytes, modelOwnerBytes: audit.modelOwnerBytes, framePinBytes: audit.framePinBytes, semanticCandidateBytes: audit.semanticCandidateBytes, semanticPublishedBytes: audit.semanticPublishedBytes, layoutCandidateBytes: audit.layoutCandidateBytes, renderWorkspaceBytes: audit.renderWorkspaceBytes, canvasCallableBytes: audit.canvasCallableBytes, pathWorkspaceBytes: audit.pathWorkspaceBytes, drawingPlanBytes: audit.drawingPlanBytes, observableLiveBytes: audit.observableLiveBytes, observableCandidateBytes: audit.observableCandidateBytes, interactionCandidateBytes: audit.interactionCandidateBytes, interactionCommittedBytes: audit.interactionCommittedBytes, admissionQueueBytes: audit.admissionQueueBytes, sealedBatchBytes: audit.sealedBatchBytes, pointerStateBytes: audit.pointerStateBytes, coordinatorStateBytes: audit.coordinatorStateBytes + 1, failureStateBytes: audit.failureStateBytes)
    guard case .valid(let changed) = RuntimeStorageAudit.checked(profile: profile, limits: profile == audit.profile ? audit.limits : counterActualLimits(profile), byteCounts: bytes) else { preconditionFailure("counter candidate audit") }
    return changed
}
func counterJoinReport(_ report: HostAssemblyReport) -> HostAssemblyReport {
    .init(kind: report.kind, profile: report.profile, storageAudit: report.storageAudit, capabilitySnapshot: report.capabilitySnapshot, effectivePresentation: report.effectivePresentation, drawingPlanOperationLimit: report.drawingPlanOperationLimit, minimumSinkOperationCapacity: report.minimumSinkOperationCapacity, cardinality: report.cardinality, minimumFrameIntervalMicroseconds: report.minimumFrameIntervalMicroseconds + 1, maximumFactServiceLatencyMicroseconds: report.maximumFactServiceLatencyMicroseconds, minimumAcceptedTransitionSpacingMicroseconds: report.minimumAcceptedTransitionSpacingMicroseconds, maximumCompactFactsPerServiceWindow: report.maximumCompactFactsPerServiceWindow, maximumRetryableRefusals: report.maximumRetryableRefusals)
}
