import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore

extension StaticCounterProfileStorage {
    mutating func runCounterHost(failAfterRuntime: Bool) -> Int {
        guard case .valid(let audit) = audit(), let assembly = CounterHostAssembly.validate(audit, kind: .macOSStatic) else { preconditionFailure("counter valid-only host") }
        let ownedChecks = counterOwnedSchedulerCompatibility(assembly.report)
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
                                        let owner = CounterHostOwner(supplied: consume supplied, activationSpan: activationBacking.span, assembly: assembly, failAfterRuntime: failAfterRuntime)
                                        var host = SignalAnalyzerPresetHostInstances.macOSStatic(report: assembly.report, owner: consume owner)!
                                        precondition(host.lifecycleState == .valid && host.owner.constructions == 0 && pointer.pointee.finalized == 0)
                                        precondition(host.runOpportunity() == .invalidLifecycle)
                                        var count = 2
                                        let activation = host.activate()
                                        if failAfterRuntime {
                                            precondition(activation == .failure(.configuration(.arithmeticOverflow)) && host.lifecycleState == .failed)
                                            precondition(pointer.pointee.teardowns == 1 && pointer.pointee.finalized == 0)
                                            count += 2
                                        } else {
                                            precondition(activation == .active && host.owner.activationStep == 7 && host.owner.constructions == 1)
                                            precondition(pointer.pointee.finalized == 2 && pointer.pointee.commits == 1 && pointer.pointee.committedRecords == 2)
                                            precondition(pointer.pointee.admission.pendingStateCount == 1)
                                            var scheduler = HostScheduledOpportunityController(assemblyReport: host.assemblyReport, initialFrameOriginMicroseconds: 0)
                                            guard case .success = scheduler.recordAcceptedFact(at: 0) else { preconditionFailure("counter accepted fact wake") }
                                            guard case .wait(untilMicroseconds: 250000) = scheduler.service(at: 0, instance: &host) else { preconditionFailure("counter pacing") }
                                            guard case .cycle(_, .cycle(.success)) = scheduler.service(at: 250000, instance: &host) else { preconditionFailure("counter paced host opportunity") }
                                            precondition(pointer.pointee.finalized == 3 && pointer.pointee.admission.pendingStateCount == 0)
                                            precondition(scheduler.quiesce() == nil)
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
        return checks + ownedChecks
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
