import P08CounterTable
import P08CounterSchema
import GiftUI
import GiftUIDrawing
@testable import GiftUIExecution
@testable import GiftUIHostConfiguration
import GiftUIObservableState
@testable import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore

extension CounterSelectedStaticProfileStorage {
    mutating func rejectCounterHostEscape(failAfterRuntime: Bool) -> Int {
        var escaped: SignalAnalyzerPresetHostInstance<CounterHostOwner>? = nil
        guard case .valid(let audit) = audit(), let assembly = CounterHostAssembly.validate(audit, kind: counterStaticHostKind) else { preconditionFailure("counter valid-only host") }
        return counterForeignJoinScope { foreignModels, foreignRoot, foreignControl in
            let ownedChecks = 0
            // Declared producer-projection negatives, not analyzer producer behavior.
            precondition(CounterHostAssembly.validate(audit, kind: counterStaticHostKind, sourceCallbacks: 21) == nil)
            precondition(CounterHostAssembly.validate(audit, kind: counterStaticHostKind, repositoryCallbacks: 2) == nil)
            precondition(CounterHostAssembly.validate(audit, kind: counterStaticHostKind, useCaseCallbacks: 2) == nil)
            precondition(CounterHostAssembly.validate(audit, kind: counterStaticHostKind, nonTransitionPublications: 2) == nil)
            let limits = self.limits
            #if hasFeature(Embedded)
            // Copy only the small typed descriptors; their disjoint banks stay
            // in the caller slot until all nested scopes and teardown end.
            var semanticBacking = self.semanticBacking
            var canvasBacking = self.canvasBacking
            #endif
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
                                            let joinChecks = counterCheckRejectedBindings(owner: &owner, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: pointer, foreignControl: foreignControl, audit: audit, report: assembly.report, expected: expected, foreignExpected: foreignExpected)
                                            #if hasFeature(Embedded)
                                            var host = SignalAnalyzerPresetHostInstances.nrf52840Static(report: assembly.report, owner: consume owner)!
                                            #else
                                            var host = SignalAnalyzerPresetHostInstances.macOSStatic(report: assembly.report, owner: consume owner)!
                                            #endif
                                        _ = host.activate()
                                        escaped = consume host
                                        return 1
                                        }
                                    }
                                }
                            } catch { preconditionFailure("counter host Canvas") }
                        }
                    } catch { preconditionFailure("counter host semantics") }
                }
            } catch { preconditionFailure("counter host model") }
            var escapedOwner = escaped.take()!
            _ = escapedOwner.runOpportunity()
            escapedOwner.teardown()
            return checks + ownedChecks + 4
        }
    }
}

@inline(never)
private func counterCheckRejectedBindings(
    owner: inout CounterHostOwner,
    models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>,
    root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>,
    foreignModels: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>,
    foreignRoot: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>,
    control pointer: UnsafeMutablePointer<CounterControl>,
    foreignControl: UnsafeMutablePointer<CounterControl>,
    audit: RuntimeStorageAudit, report: HostAssemblyReport,
    expected: CounterJoinSnapshot, foreignExpected: CounterJoinSnapshot
) -> Int {
    var joinChecks = 0
    let rejected0 = owner.constructRuntimeAndEndpoint(models: models, root: root, control: foreignControl, audit: audit, report: report)
    precondition(rejected0 == .failure(.configuration(.invalidWakeIntegration), progress: .init()))
    precondition(owner.constructions == 0 && owner.activationStep == 0)
    precondition(counterJoinSnapshot(pointer) == expected && counterJoinSnapshot(foreignControl) == foreignExpected)
    joinChecks += 3
    let rejected1 = owner.constructRuntimeAndEndpoint(models: foreignModels, root: foreignRoot, control: pointer, audit: audit, report: report)
    precondition(rejected1 == .failure(.configuration(.invalidModelTarget), progress: .init()))
    precondition(owner.constructions == 0 && owner.activationStep == 0)
    precondition(counterJoinSnapshot(pointer) == expected && counterJoinSnapshot(foreignControl) == foreignExpected)
    joinChecks += 3
    let rejected2 = owner.constructRuntimeAndEndpoint(models: models, root: foreignRoot, control: pointer, audit: audit, report: report)
    precondition(rejected2 == .failure(.configuration(.invalidModelTarget), progress: .init()))
    precondition(owner.constructions == 0 && owner.activationStep == 0)
    precondition(counterJoinSnapshot(pointer) == expected && counterJoinSnapshot(foreignControl) == foreignExpected)
    joinChecks += 3
    let rejected3 = owner.constructRuntimeAndEndpoint(models: models, root: root, control: pointer, audit: counterJoinAudit(audit, profile: .dynamic), report: report)
    precondition(rejected3 == .failure(.configuration(.profileMismatch), progress: .init()))
    precondition(owner.constructions == 0 && owner.activationStep == 0)
    precondition(counterJoinSnapshot(pointer) == expected && counterJoinSnapshot(foreignControl) == foreignExpected)
    joinChecks += 3
    let rejected4 = owner.constructRuntimeAndEndpoint(models: models, root: root, control: pointer, audit: counterJoinAudit(audit, profile: audit.profile), report: report)
    precondition(rejected4 == .failure(.configuration(.invalidWorkload), progress: .init()))
    precondition(owner.constructions == 0 && owner.activationStep == 0)
    precondition(counterJoinSnapshot(pointer) == expected && counterJoinSnapshot(foreignControl) == foreignExpected)
    joinChecks += 3
    let rejected5 = owner.constructRuntimeAndEndpoint(models: models, root: root, control: pointer, audit: audit, report: counterJoinReport(report))
    precondition(rejected5 == .failure(.configuration(.invalidWakeIntegration), progress: .init()))
    precondition(owner.constructions == 0 && owner.activationStep == 0)
    precondition(counterJoinSnapshot(pointer) == expected && counterJoinSnapshot(foreignControl) == foreignExpected)
    joinChecks += 3
    return joinChecks
}

@inline(never)
private func counterRunHostLifecycle(
    host: inout SignalAnalyzerPresetHostInstance<CounterHostOwner>,
    control pointer: UnsafeMutablePointer<CounterControl>, report: HostAssemblyReport,
    failAfterRuntime: Bool, joinChecks: Int
) -> Int {
    precondition(host.lifecycleState == .valid && host.owner.constructions == 0 && pointer.pointee.finalized == 0)
    precondition(host.runOpportunity() == .invalidLifecycle)
    var count = 2 + joinChecks
    let activation = host.activate()
    if failAfterRuntime || pointer.pointee.idleQuiesceMode != 0 {
        precondition(activation == .failure(.configuration(.arithmeticOverflow)) && host.lifecycleState == .failed)
        let failedStep: UInt8 = failAfterRuntime ? 1 : pointer.pointee.idleQuiesceMode
        precondition(host.owner.activationStep == failedStep && host.owner.constructions == 1)
        precondition(pointer.pointee.teardowns == 1 && pointer.pointee.finalized == (failedStep < 3 ? 0 : failedStep < 5 ? 1 : 2))
        precondition(pointer.pointee.unavailable && !pointer.pointee.inputGate.inputIsEligible)
        precondition(pointer.pointee.admission.pendingStateCount == 0)
        precondition(pointer.pointee.observationsInstalled == (failedStep >= 4 ? 1 : 0) && pointer.pointee.observationsDetached == (failedStep >= 4 ? 1 : 0))
        count += 6
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
    precondition(host.assemblyReport == report)
    let selectedFailure: UInt8 = failAfterRuntime ? 1 : pointer.pointee.idleQuiesceMode
    let expectedApplication = selectedFailure == 1 ? 0 : 1
    let expectedObservation = selectedFailure == 0 || selectedFailure >= 4 ? 1 : 0
    let expectedCallback = selectedFailure == 0 || selectedFailure >= 6 ? 1 : 0
    precondition(pointer.pointee.applicationConstructions == expectedApplication)
    precondition(pointer.pointee.applicationCallbacks == expectedCallback && pointer.pointee.reentrantApplicationRejections == expectedCallback)
    precondition(pointer.pointee.observationsInstalled == expectedObservation && pointer.pointee.observationsDetached == expectedObservation)
    precondition(pointer.pointee.stoppedApplicationChecks >= expectedApplication)
    var stoppedAdmission = CounterAdmission(borrowing: pointer)
    precondition(stoppedAdmission.submit(stateChange: 9).result == .unavailable)
    precondition(pointer.pointee.admission.pendingStateCount == 0)
    precondition(!pointer.pointee.inputGate.inputIsEligible)
    let rejectedInput = pointer.pointee.inputGate.submit(phase: .down, position: .init(x: 0, y: 0), source: .init(rawValue: 0), observedPresentationRevision: pointer.pointee.runtime.committedPresentation, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &stoppedAdmission)
    precondition(rejectedInput == .sourceQuiesced(.inputUnavailable))
    return count + 13
}

