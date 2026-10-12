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
                                    let owner = CounterDynamicHostOwner(supplied: consume supplied, activationSpan: activationBacking.span, assembly: assembly, failAfterRuntime: failAfterRuntime)
                                    var host = SignalAnalyzerPresetHostInstances.macOSDynamic(report: assembly.report, owner: consume owner)!
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
                                        guard case .success = scheduler.recordAcceptedFact(at: 0) else { preconditionFailure("counter Dynamic accepted wake") }
                                        guard case .wait(untilMicroseconds: 250000) = scheduler.service(at: 0, instance: &host) else { preconditionFailure("counter Dynamic pacing") }
                                        guard case .cycle(_, .cycle(.success)) = scheduler.service(at: 250000, instance: &host) else { preconditionFailure("counter Dynamic paced opportunity") }
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
                                    var stoppedAdmission = CounterAdmission(borrowing: pointer)
                                    precondition(stoppedAdmission.submit(stateChange: 9).result == .unavailable)
                                    precondition(pointer.pointee.admission.pendingStateCount == 0)
                                    precondition(!pointer.pointee.inputGate.inputIsEligible)
                                    let rejectedInput = pointer.pointee.inputGate.submit(phase: .down, position: .init(x: 0, y: 0), source: .init(rawValue: 0), observedPresentationRevision: pointer.pointee.runtime.committedPresentation, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &stoppedAdmission)
                                    precondition(rejectedInput == .sourceQuiesced(.inputUnavailable))
                                    return count + 9
                                }
                            }
                        } catch { preconditionFailure("counter Dynamic Canvas") }
                    }
                } catch { preconditionFailure("counter Dynamic semantic") }
            }
        } catch { preconditionFailure("counter Dynamic model") }
        return checks
    }
}

package func p08CounterDynamicHost() -> Int {
    var models = ObservableModelOwnerNamespace()
    var semantics = SemanticRecordOwnerNamespace()
    do {
        var complete = DynamicCounterProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantics.issue())
        var partial = DynamicCounterProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantics.issue())
        return complete.runCounterDynamicHost(failAfterRuntime: false) + partial.runCounterDynamicHost(failAfterRuntime: true)
    } catch { preconditionFailure("counter Dynamic identities") }
}
#endif
