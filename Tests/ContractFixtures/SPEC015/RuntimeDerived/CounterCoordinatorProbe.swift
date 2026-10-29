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

func exerciseCounterCoordinator<G, C, R, H>(models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, semantic: borrowing SemanticRecordStore, semanticCodec: borrowing CounterSemanticCodec, values: borrowing CanvasStagedValues<SemanticRecordReference, CounterValueTable>, dynamic: Bool, geometry: consuming G, interaction: consuming InteractionOwnedKeyState<C, R, H>, audit: RuntimeStorageAudit, control: inout CounterControl) -> CounterReturnedWorkspaces<G, C, R, H> where G: CounterGeometry & Copyable & Escapable, C: CounterCandidateBacking & Copyable & Escapable, R: CounterCommittedBacking & Copyable & Escapable, H: CounterHitBacking & Copyable & Escapable, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity {
    guard let assembly = CounterHostAssembly.validate(audit, kind: dynamic ? .macOSDynamic : .macOSStatic) else { preconditionFailure("counter nine-stage assembly") }
    precondition(assembly.ledger.accessCount == 9 && assembly.ledger.accessedStages == 511 && assembly.ledger.sideEffectCount == 0)
    precondition(assembly.report.storageAudit == audit && assembly.report.cardinality == P08CounterWorkload.cardinality)
    var movedGeometry: G? = consume geometry
    var movedInteraction: InteractionOwnedKeyState<C, R, H>? = consume interaction
    return withUnsafeMutablePointer(to: &control) { pointer in
        let owner = CounterPipelineOwner(models: models.borrowedScope(), root: root.borrowedRoot(), semantic: semantic.borrowedStore(), semanticCodec: copy semanticCodec, values: values.borrowedValues(), geometry: movedGeometry.take()!, interaction: movedInteraction.take()!, control: pointer, limits: audit.limits, endpointConfiguration: assembly.endpoint)
        let binding = CounterExecutionBinding(models: models.borrowedScope(), root: root.borrowedRoot(), control: pointer, audit: audit)!
        let admission = CounterAdmission(control: pointer, limits: audit.limits.execution)
        #if !hasFeature(Embedded)
        if dynamic {
            var coordinator = DynamicRuntimeExecutionCoordinator(binding: binding, admission: admission, opportunity: owner)
            let checks = runCounterCoordinator(&coordinator, control: pointer) + 3
            let returned = coordinator.takeQuiescedOpportunity()!.returnWorkspaces(checks: checks)
            CounterControl.requireVacantRuntimeSlot(at: pointer)
            return returned
        }
        #endif
        var coordinator = StaticRuntimeExecutionCoordinator(binding: binding, admission: admission, opportunity: owner)
        let checks = runCounterCoordinator(&coordinator, control: pointer) + 3
        let returned = coordinator.takeQuiescedOpportunity()!.returnWorkspaces(checks: checks)
        CounterControl.requireVacantRuntimeSlot(at: pointer)
        return returned
    }
}

func runCounterCoordinator<C: GiftUIRuntimeProfileCoordinator & ~Copyable & ~Escapable>(_ coordinator: inout C, control: UnsafeMutablePointer<CounterControl>) -> Int where C.StateChangeFact == UInt8, C.CompletionFact == UInt16, C.OwnerFailure == RuntimeOwnerFailure {
    var checks = 0
    func expect(_ condition: Bool) { checks += 1; precondition(condition) }
    guard case .success(let initial) = coordinator.runOpportunity() else { preconditionFailure("counter initial opportunity") }
    let p08ExactCase46: Bool;
    if case .committed = initial.logicalFrameDisposition {
        if case .published = initial.semanticDisposition {
            p08ExactCase46 = true
        } else {
            p08ExactCase46 = false
        }
    } else {
        p08ExactCase46 = false
    }; expect(p08ExactCase46)
    expect(control.pointee.finalized == 1 && control.pointee.commits == 1 && control.pointee.committedRecords == 2)
    for value: UInt8 in 0...9 {
        let p08ExactCase47: Bool;
        if case .queued = coordinator.submit(stateChange: value).result {
            p08ExactCase47 = true
        } else {
            p08ExactCase47 = false
        }; expect(p08ExactCase47)
        let p08ExactCase48: Bool;
        if case .queued = coordinator.submit(completion: 0).result {
            p08ExactCase48 = true
        } else {
            p08ExactCase48 = false
        }; expect(p08ExactCase48)
        let p08ExactCase49: Bool;
        if case .capacityRefused = coordinator.submit(completion: 0).result {
            p08ExactCase49 = true
        } else {
            p08ExactCase49 = false
        }; expect(p08ExactCase49)
        guard case .success(let summary) = coordinator.runOpportunity() else { preconditionFailure("counter fact opportunity") }
        expect(summary.admission.stateChangeFactCount == 1 && summary.admission.completionFactCount == 1)
        let p08ExactCase50: Bool;
        if case .committed = summary.logicalFrameDisposition {
            if case .satisfied = summary.presentationIntentState {
                p08ExactCase50 = true
            } else {
                p08ExactCase50 = false
            }
        } else {
            p08ExactCase50 = false
        }; expect(p08ExactCase50)
        expect(control.pointee.admission.pendingStateCount == 0 && !control.pointee.admission.sealActive && !control.pointee.frameActive)
    }
    let p08ExactCase51: Bool;
    if case .invalidValue = coordinator.submit(stateChange: 10).result {
        p08ExactCase51 = true
    } else {
        p08ExactCase51 = false
    }; expect(p08ExactCase51)
    for index in 0 ..< 34 {
        let p08ExactCase52: Bool;
        if case .queued = coordinator.submit(stateChange: UInt8(index % 10)).result {
            p08ExactCase52 = true
        } else {
            p08ExactCase52 = false
        }; expect(p08ExactCase52)
    }
    let p08ExactCase53: Bool;
    if case .capacityRefused = coordinator.submit(stateChange: 0).result {
        p08ExactCase53 = true
    } else {
        p08ExactCase53 = false
    }; expect(p08ExactCase53)
    guard case .success(let full) = coordinator.runOpportunity() else { preconditionFailure("counter full bounded queue") }
    expect(full.admission.stateChangeFactCount == 34)
    coordinator.quiesce(); coordinator.quiesce()
    expect(coordinator.isQuiescent && control.pointee.teardowns == 1 && control.pointee.committedRecords == 0)
    expect(!control.pointee.hasRoot && control.pointee.admission.pendingStateCount == 0)
    let p08ExactCase54: Bool;
    if case .unavailable = coordinator.submit(stateChange: 0).result {
        p08ExactCase54 = true
    } else {
        p08ExactCase54 = false
    }; expect(p08ExactCase54)
    return checks
}

package func p08CounterCoordinator() -> Int {
    var models = ObservableModelOwnerNamespace()
    var semantics = SemanticRecordOwnerNamespace()
    do {
        var storage = StaticCounterProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantics.issue())
        let staticAudit = storage.audit();
        #if os(macOS) && !GIFTUI_COUNTER_ROUTE_DYNAMIC && !hasFeature(Embedded)
            counterDiagnosticAudit("counter static audit", staticAudit)
        #elseif !hasFeature(Embedded)
            print("counter static audit", staticAudit)
        #endif
        guard case .valid = staticAudit else { preconditionFailure("counter static audit") }
        var checks = storage.run() + 1
        #if !hasFeature(Embedded)
        var dynamic = DynamicCounterProfileStorage(modelOwner: try models.issue(), semanticOwner: try semantics.issue())
        let dynamicAudit = dynamic.audit();
            #if os(macOS) && !GIFTUI_COUNTER_ROUTE_DYNAMIC && !hasFeature(Embedded)
                counterDiagnosticAudit("counter dynamic audit", dynamicAudit)
            #elseif !hasFeature(Embedded)
                print("counter dynamic audit", dynamicAudit)
            #endif
        guard case .valid = dynamicAudit else { preconditionFailure("counter dynamic audit") }
        checks += dynamic.run() + 1
        #endif
        return checks
    } catch { preconditionFailure("counter owner namespace") }
}
