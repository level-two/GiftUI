import GiftUI
import GiftUIHostConfiguration
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import GiftUISemanticCore
import P08CounterSchema

func exerciseCounterCoordinator<G, C, R, H>(models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, semantic: borrowing SemanticRecordStore<CounterPayload>, values: borrowing CanvasStagedValues<SemanticRecordReference, CounterValueTable>, dynamic: Bool, geometry: consuming G, interaction: consuming InteractionOwnedKeyState<C, R, H>, audit: RuntimeStorageAudit, control: inout CounterControl) -> CounterReturnedWorkspaces<G, C, R, H> where G: CounterGeometry & Copyable & Escapable, C: CounterCandidateBacking & Copyable & Escapable, R: CounterCommittedBacking & Copyable & Escapable, H: CounterHitBacking & Copyable & Escapable, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    guard let assembly = CounterHostAssembly.validate(audit, kind: dynamic ? .macOSDynamic : .macOSStatic) else { preconditionFailure("counter nine-stage assembly") }
    precondition(assembly.ledger.accessCount == 9 && assembly.ledger.accessedStages == 511 && assembly.ledger.sideEffectCount == 0)
    precondition(assembly.report.storageAudit == audit && assembly.report.cardinality == P08CounterWorkload.cardinality)
    var movedGeometry: G? = consume geometry
    var movedInteraction: InteractionOwnedKeyState<C, R, H>? = consume interaction
    return withUnsafeMutablePointer(to: &control) { pointer in
        let owner = CounterPipelineOwner(models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic.borrowedStore(), values: values.borrowedValues(), geometry: movedGeometry.take()!, interaction: movedInteraction.take()!, control: pointer, limits: audit.limits, endpointConfiguration: assembly.endpoint)
        let binding = CounterExecutionBinding(models: models.borrowedScope(), root: root.borrowedRoot(), control: pointer, audit: audit)!
        let admission = CounterAdmission(control: pointer, limits: audit.limits.execution)
        #if !hasFeature(Embedded)
        if dynamic {
            var coordinator = DynamicRuntimeExecutionCoordinator(binding: binding, admission: admission, opportunity: owner)
            let checks = runCounterCoordinator(&coordinator, control: pointer) + 3
            let returned = coordinator.takeQuiescedOpportunity()!.returnWorkspaces(checks: checks)
            pointer.pointee.requireVacantRuntimeSlot()
            return returned
        }
        #endif
        var coordinator = StaticRuntimeExecutionCoordinator(binding: binding, admission: admission, opportunity: owner)
        let checks = runCounterCoordinator(&coordinator, control: pointer) + 3
        let returned = coordinator.takeQuiescedOpportunity()!.returnWorkspaces(checks: checks)
        pointer.pointee.requireVacantRuntimeSlot()
        return returned
    }
}

func runCounterCoordinator<C: GiftUIRuntimeProfileCoordinator & ~Copyable & ~Escapable>(_ coordinator: inout C, control: UnsafeMutablePointer<CounterControl>) -> Int where C.StateChangeFact == UInt8, C.CompletionFact == UInt16, C.OwnerFailure == RuntimeOwnerFailure {
    var checks = 0
    func expect(_ condition: Bool) { checks += 1; precondition(condition) }
    guard case .success(let initial) = coordinator.runOpportunity() else { preconditionFailure("counter initial opportunity") }
    expect(initial.logicalFrameDisposition == .committed && initial.semanticDisposition == .published)
    expect(control.pointee.finalized == 1 && control.pointee.commits == 1 && control.pointee.committedRecords == 2)
    for value: UInt8 in 0...9 {
        expect(coordinator.submit(stateChange: value).result == .queued)
        expect(coordinator.submit(completion: 0).result == .queued)
        expect(coordinator.submit(completion: 0).result == .capacityRefused)
        guard case .success(let summary) = coordinator.runOpportunity() else { preconditionFailure("counter fact opportunity") }
        expect(summary.admission.stateChangeFactCount == 1 && summary.admission.completionFactCount == 1)
        expect(summary.logicalFrameDisposition == .committed && summary.presentationIntentState == .satisfied)
        expect(control.pointee.admission.pendingStateCount == 0 && !control.pointee.admission.sealActive && !control.pointee.frameActive)
    }
    expect(coordinator.submit(stateChange: 10).result == .invalidValue)
    for index in 0..<34 { expect(coordinator.submit(stateChange: UInt8(index % 10)).result == .queued) }
    expect(coordinator.submit(stateChange: 0).result == .capacityRefused)
    guard case .success(let full) = coordinator.runOpportunity() else { preconditionFailure("counter full bounded queue") }
    expect(full.admission.stateChangeFactCount == 34)
    coordinator.quiesce(); coordinator.quiesce()
    expect(coordinator.isQuiescent && control.pointee.teardowns == 1 && control.pointee.committedRecords == 0)
    expect(!control.pointee.hasRoot && control.pointee.admission.pendingStateCount == 0)
    expect(coordinator.submit(stateChange: 0).result == .unavailable)
    return checks
}

package func p08CounterCoordinator() -> Int {
    var models = ObservableModelOwnerNamespace()
    var semantics = SemanticRecordOwnerNamespace()
    do {
        var storage = StaticCounterProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantics.issue())
        let staticAudit = storage.audit();
        #if !hasFeature(Embedded)
        print("counter static audit", staticAudit)
        #endif
        guard case .valid = staticAudit else { preconditionFailure("counter static audit") }
        var checks = storage.run() + 1
        #if !hasFeature(Embedded)
        var dynamic = DynamicCounterProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantics.issue())
        let dynamicAudit = dynamic.audit();
        #if !hasFeature(Embedded)
        print("counter dynamic audit", dynamicAudit)
        #endif
        guard case .valid = dynamicAudit else { preconditionFailure("counter dynamic audit") }
        checks += dynamic.run() + 1
        #endif
        return checks
    } catch { preconditionFailure("counter owner namespace") }
}
