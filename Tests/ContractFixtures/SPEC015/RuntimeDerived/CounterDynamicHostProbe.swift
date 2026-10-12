#if !hasFeature(Embedded)
import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import GiftUISemanticCore

extension DynamicCounterProfileStorage {
    mutating func runCounterDynamicHost(failAfterRuntime: Bool) -> Int {
        guard case .valid(let audit) = audit(), let assembly = CounterHostAssembly.validate(audit, kind: .macOSDynamic) else { preconditionFailure("counter Dynamic valid-only host") }
        // Declared producer-projection negatives, not analyzer producer behavior.
        precondition(CounterHostAssembly.validate(audit, kind: .macOSDynamic, sourceCallbacks: 21) == nil)
        precondition(CounterHostAssembly.validate(audit, kind: .macOSDynamic, repositoryCallbacks: 2) == nil)
        precondition(CounterHostAssembly.validate(audit, kind: .macOSDynamic, useCaseCallbacks: 2) == nil)
        precondition(CounterHostAssembly.validate(audit, kind: .macOSDynamic, nonTransitionPublications: 2) == nil)
        return counterForeignJoinScope { foreignModels, foreignRoot, foreignControl in
            let limits = self.limits
            var movedGeometry = geometry.take()
            var keys = interaction.take()
            var checks = 0
            do throws(ObservableStateError) {
                try root.withLifetime(limits: limits.observableState) { (models, root) throws(ObservableStateError) in
                    do throws(SemanticExpansionError) {
                        try semantic.withLifetime(configuredLimits: counterSemanticConfiguration(limits)) { (semantic) throws(SemanticExpansionError) in
                            do throws(DrawingError) {
                                try canvas.withLifetime(table: CounterValueTable(), limits: counterCanvasLimits, configuredCapacity: 1) { values in
                                    checks = withUnsafeMutablePointer(to: &control) { pointer in
                                        let activationBacking: InlineArray<1, UInt8> = [1]
                                        let supplied = CounterDynamicHostSupplied(models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic.borrowedStore(), values: values.borrowedValues(), control: pointer, audit: audit, geometry: movedGeometry.take()!, interaction: keys.take()!)
                                        var owner = CounterDynamicHostOwner(supplied: consume supplied, activationSpan: activationBacking.span, assembly: assembly, failAfterRuntime: failAfterRuntime)
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
                                        let rejected3 = owner.constructRuntimeAndEndpoint(models: models, root: root, control: pointer, audit: counterJoinAudit(audit, profile: .static), report: assembly.report)
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
                                        var host = SignalAnalyzerPresetHostInstances.macOSDynamic(report: assembly.report, owner: consume owner)!
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
                                        precondition(host.assemblyReport == assembly.report)
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
                                }
                            } catch { preconditionFailure("counter Dynamic Canvas") }
                        }
                    } catch { preconditionFailure("counter Dynamic semantic") }
                }
            } catch { preconditionFailure("counter Dynamic model") }
            return checks + 4
        }
    }
}

package func p08CounterDynamicHost() -> Int {
    var models = ObservableModelOwnerNamespace()
    var semantics = SemanticRecordOwnerNamespace()
    do {
        var complete = DynamicCounterProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantics.issue())
        var partial = DynamicCounterProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantics.issue())
        var nonRetryable = DynamicCounterProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantics.issue())
        nonRetryable.control.terminalRetry = true
        var failures = 0
        for step: UInt8 in 2...7 {
            var failed = DynamicCounterProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantics.issue())
            failed.control.idleQuiesceMode = step
            failures += failed.runCounterDynamicHost(failAfterRuntime: false)
        }
        return complete.runCounterDynamicHost(failAfterRuntime: false) + partial.runCounterDynamicHost(failAfterRuntime: true) + nonRetryable.runCounterDynamicHost(failAfterRuntime: false) + failures
    } catch { preconditionFailure("counter Dynamic identities") }
}
#endif
