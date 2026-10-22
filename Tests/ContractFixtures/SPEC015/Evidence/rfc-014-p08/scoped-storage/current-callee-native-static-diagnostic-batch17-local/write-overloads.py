from pathlib import Path
import re,json,hashlib,datetime
src=Path('Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift')
loc=Path(__file__).parent
before=src.read_text();assert hashlib.sha256(before.encode()).hexdigest()=='ea413f1bdf9e1d90ef6db7b61b9d7bb668f692d693ca1cd27df4357b76f3fc6d'
(loc/'owner-before.swift').write_text(before)
parts=[]
def emit(s):parts.append(s.strip()+'\n')
def fn(typ,body):emit('private func counterTraceWrite(_ value: '+typ+') {\n'+body+'\n}')
def enum(typ,path,module,nested=True):
 t=Path(path).read_text();m=re.search(r'enum '+re.escape(typ)+r'[^\{]*\{(.*?)\n\}',t,re.S);assert m,typ
 names=[]
 for c in re.findall(r'^    case (\w+[^\n]*)',m[1],re.M):
  names += [re.split(r'\s*=|\s',x.strip())[0] for x in c.split(',')]
 assert all(re.fullmatch(r'\w+',x) for x in names),(typ,names)
 emit('private func counterTraceName(_ value: '+typ+') -> StaticString {\n    switch value {\n'+''.join('    case .'+x+': return "'+x+'"\n' for x in names)+'    }\n}')
 if nested:fn(typ,'    counterTraceWrite("'+module+'.'+typ+'.")\n    counterTraceWrite(counterTraceName(value))')
# Explicit finite types used by the eleven affected trace shapes; switches stay exhaustive.
for typ,path,module,nested in [
 ('RuntimeCompletePipelineStage','Sources/GiftUIRuntimeCore/RuntimeCompletePipeline.swift','GiftUIRuntimeCore',False),
 ('RuntimeCleanupAction','Sources/GiftUIRuntimeCore/RuntimeCoordinatorCleanup.swift','GiftUIRuntimeCore',False),
 ('ExecutionPhase','Sources/GiftUIExecution/ExecutionValues.swift','GiftUIExecution',True),
 ('SemanticCycleDisposition','Sources/GiftUIExecution/RunCycleValues.swift','GiftUIExecution',True),
 ('ExecutionOperational','Sources/GiftUIExecution/RunCycleValues.swift','GiftUIExecution',True),
 ('PresentationIntentState','Sources/GiftUIExecution/RunCycleValues.swift','GiftUIExecution',True),
 ('ExecutionError','Sources/GiftUIExecution/RunCycleValues.swift','GiftUIExecution',True),
 ('LogicalFrameDisposition','Sources/GiftUIExecution/FrameHandoffValues.swift','GiftUIExecution',True),
 ('FrameOfferFailure','Sources/GiftUIExecution/FrameHandoffValues.swift','GiftUIExecution',True),
 ('FrameRefusalOrigin','Sources/GiftUIExecution/FrameHandoffValues.swift','GiftUIExecution',True),
 ('ExecutionAdmissionResult','Sources/GiftUIExecution/AdmissionValues.swift','GiftUIExecution',True),
 ('ObservableStateError','Sources/GiftUIObservableState/ObservableStateValues.swift','GiftUIObservableState',True),
 ('InteractionError','Sources/GiftUIInteraction/InteractionValues.swift','GiftUIInteraction',True),
 ('DrawingProductionError','Sources/GiftUIDrawing/DrawingValues.swift','GiftUIDrawing',True),
 ('LayoutError','Sources/GiftUILayout/LayoutError.swift','GiftUILayout',True),
 ('SemanticExpansionError','Sources/GiftUISemanticCore/GiftUISemanticCore.swift','GiftUISemanticCore',True),
 ('RenderProductionError','Sources/GiftUIRenderCore/RenderValues.swift','GiftUIRenderCore',True)]:enum(typ,path,module,nested)
# The nested Phase declaration ends before Address; generate its finite cases literally.
emit('''private func counterTraceWrite(_ value: ObservableModelOwnership.Phase) {
    counterTraceWrite("GiftUIObservableState.ObservableModelOwnership.Phase.")
    switch value {
    case .mutating: counterTraceWrite("mutating")
    case .writing: counterTraceWrite("writing")
    case .reading: counterTraceWrite("reading")
    case .discovering: counterTraceWrite("discovering")
    case .replacing: counterTraceWrite("replacing")
    case .retired: counterTraceWrite("retired")
    }
}''')
fn('Bool','    if value { counterTraceWrite("true") } else { counterTraceWrite("false") }')
fn('UInt16','    counterTraceWrite(UInt32(value))')
fn('UInt8','    counterTraceWrite(UInt32(value))')
fn('Int','''    if value < 0 { counterTraceWrite("-") }
    counterTraceWriteUnsigned(value.magnitude)''')
emit('''private func counterTraceWriteUnsigned(_ value: UInt) {
    let low = BoundedText(Int32(value % 1_000_000_000))
    if value >= 1_000_000_000 {
        counterTraceWriteUnsigned(value / 1_000_000_000)
        for _ in Int(low.utf8ByteCount)..<9 { _ = putchar(48) }
    }
    counterTraceWrite(low)
}''')
for typ,module in [('RunCycleID','GiftUIExecution'),('SemanticRevision','GiftUIExecution'),('CandidateFrameID','GiftUIExecution'),('ActionGeneration','GiftUIExecution'),('PresentationRevision','GiftUI')]:
 fn(typ,'    counterTraceWrite("'+module+'.'+typ+'(rawValue: ")\n    counterTraceWrite(value.rawValue)\n    counterTraceWrite(")")')
 fn(typ+'?','    if let value {\n        counterTraceWrite("Optional(")\n        counterTraceWrite(value)\n        counterTraceWrite(")")\n    } else { counterTraceWrite("nil") }')
fn('ExecutionContext','''    counterTraceWrite("GiftUIExecution.ExecutionContext(cycle: ")
    counterTraceWrite(value.cycle)
    counterTraceWrite(", semanticRevision: ")
    counterTraceWrite(value.semanticRevision)
    counterTraceWrite(", candidateFrame: ")
    counterTraceWrite(value.candidateFrame)
    counterTraceWrite(", phase: ")
    counterTraceWrite(value.phase)
    counterTraceWrite(")")''')
fn('ExecutionOperational?','''    if let value {
        counterTraceWrite("Optional("); counterTraceWrite(value); counterTraceWrite(")")
    } else { counterTraceWrite("nil") }''')
fn('PresentationPendingIntent?','''    if let value {
        counterTraceWrite("Optional(GiftUIExecution.PresentationPendingIntent(semanticRevision: ")
        counterTraceWrite(value.semanticRevision)
        counterTraceWrite(", retryableRefusalCount: ")
        counterTraceWrite(value.retryableRefusalCount)
        counterTraceWrite("))")
    } else { counterTraceWrite("nil") }''')
# Top-level structs omit their module; nested structs retain it, matching pinned Swift print.
emit('''private func counterTraceWrite(_ value: RuntimePipelineDisposition, nested: Bool) {
    if nested { counterTraceWrite("GiftUIRuntimeCore.") }
    counterTraceWrite("RuntimePipelineDisposition(semanticDisposition: ")
    counterTraceWrite(value.semanticDisposition)
    counterTraceWrite(", logicalFrameDisposition: ")
    counterTraceWrite(value.logicalFrameDisposition)
    counterTraceWrite(", presentationIntentState: ")
    counterTraceWrite(value.presentationIntentState)
    counterTraceWrite(", wakeReasons: GiftUIExecution.ExecutionWakeReasons(rawValue: ")
    counterTraceWrite(value.wakeReasons.rawValue)
    counterTraceWrite("), commitsInteractionCandidate: ")
    counterTraceWrite(value.commitsInteractionCandidate)
    counterTraceWrite(", preservesPublishedSemanticRevision: ")
    counterTraceWrite(value.preservesPublishedSemanticRevision)
    counterTraceWrite(")")
}''')
fn('RuntimePipelinePublication','''    counterTraceWrite("GiftUIRuntimeCore.RuntimePipelinePublication(semanticRevision: ")
    counterTraceWrite(value.semanticRevision)
    counterTraceWrite(", changed: "); counterTraceWrite(value.changed); counterTraceWrite(")")''')
fn('RuntimePipelinePublication?','''    if let value { counterTraceWrite("Optional("); counterTraceWrite(value); counterTraceWrite(")") }
    else { counterTraceWrite("nil") }''')
fn('RuntimeOwnerFailure','''    counterTraceWrite("GiftUIRuntimeCore.RuntimeOwnerFailure.")
    switch value {
    case .semantic(let error): counterTraceWrite("semantic("); counterTraceWrite(error)
    case .layout(let error): counterTraceWrite("layout("); counterTraceWrite(error)
    case .observableState(let error): counterTraceWrite("observableState("); counterTraceWrite(error)
    case .interaction(let error): counterTraceWrite("interaction("); counterTraceWrite(error)
    case .drawing(let error): counterTraceWrite("drawing("); counterTraceWrite(error)
    }
    counterTraceWrite(")")''')
fn('RunCycleFailure<RuntimeOwnerFailure>','''    counterTraceWrite("GiftUIExecution.RunCycleFailure<GiftUIRuntimeCore.RuntimeOwnerFailure>.")
    switch value {
    case .execution(let error): counterTraceWrite("execution("); counterTraceWrite(error)
    case .renderProduction(let error): counterTraceWrite("renderProduction("); counterTraceWrite(error)
    case .frameOffer(let error): counterTraceWrite("frameOffer("); counterTraceWrite(error)
    case .nonRetryableRefusal(let error): counterTraceWrite("nonRetryableRefusal("); counterTraceWrite(error)
    case .focusedOwner(let error): counterTraceWrite("focusedOwner("); counterTraceWrite(error)
    }
    counterTraceWrite(")")''')
fn('RuntimeCompletePipelineResult<RuntimeOwnerFailure>','''    switch value {
    case .completed(let completion):
        counterTraceWrite("completed(GiftUIRuntimeCore.RuntimePipelineCompletion(publication: ")
        counterTraceWrite(completion.publication)
        counterTraceWrite(", committedPresentationRevision: "); counterTraceWrite(completion.committedPresentationRevision)
        counterTraceWrite(", operational: "); counterTraceWrite(completion.operational)
        counterTraceWrite(", disposition: "); counterTraceWrite(completion.disposition, nested: true)
        counterTraceWrite("))")
    case .failed(let record):
        counterTraceWrite("failed(GiftUIRuntimeCore.RuntimePipelineFailureRecord<GiftUIRuntimeCore.RuntimeOwnerFailure>(stage: GiftUIRuntimeCore.RuntimeCompletePipelineStage.")
        counterTraceWrite(counterTraceName(record.stage))
        counterTraceWrite(", failure: "); counterTraceWrite(record.failure)
        counterTraceWrite(", publication: "); counterTraceWrite(record.publication)
        counterTraceWrite(", disposition: "); counterTraceWrite(record.disposition, nested: true)
        counterTraceWrite("))")
    }''')
fn('CapturedAction<SemanticCompleteIdentity>','''    counterTraceWrite("GiftUIExecution.CapturedAction<GiftUISemanticCore.SemanticCompleteIdentity>(identity: GiftUISemanticCore.SemanticCompleteIdentity(components: Swift.InlineArray<34, GiftUISemanticCore.SemanticPathComponent>(_storage: (Unknown)), count: ")
    counterTraceWrite(value.identity.count)
    counterTraceWrite("), generation: "); counterTraceWrite(value.generation); counterTraceWrite(")")''')
fn('PointerGestureOutcome<SemanticCompleteIdentity>','''    switch value {
    case .captured(let action): counterTraceWrite("captured("); counterTraceWrite(action); counterTraceWrite(")")
    case .continued(let action): counterTraceWrite("continued("); counterTraceWrite(action); counterTraceWrite(")")
    case .activationAdmitted(let action): counterTraceWrite("activationAdmitted("); counterTraceWrite(action); counterTraceWrite(")")
    case .cancelled: counterTraceWrite("cancelled")
    case .ignored: counterTraceWrite("ignored")
    }''')
fn('RuntimeRecordInteractionDispatchResult','''    switch value {
    case .interaction(let result):
        counterTraceWrite("interaction(GiftUIInteraction.InteractionDispatchResult.")
        switch result {
        case .dispatched: counterTraceWrite("dispatched")
        case .cancelled: counterTraceWrite("cancelled")
        case .failure(let error): counterTraceWrite("failure("); counterTraceWrite(error); counterTraceWrite(")")
        }
        counterTraceWrite(")")
    case .observableFailure(let error):
        counterTraceWrite("observableFailure("); counterTraceWrite(error); counterTraceWrite(")")
    }''')
fn('RunCycleSummary','''    counterTraceWrite("RunCycleSummary(cycle: "); counterTraceWrite(value.cycle)
    counterTraceWrite(", admission: GiftUIExecution.AdmissionSummary(inputEventCount: "); counterTraceWrite(value.admission.inputEventCount)
    counterTraceWrite(", stateChangeFactCount: "); counterTraceWrite(value.admission.stateChangeFactCount)
    counterTraceWrite(", completionFactCount: "); counterTraceWrite(value.admission.completionFactCount)
    counterTraceWrite(", semanticActionCount: "); counterTraceWrite(value.admission.semanticActionCount)
    counterTraceWrite(", includesDirtyRederivation: "); counterTraceWrite(value.admission.includesDirtyRederivation)
    counterTraceWrite(", includesPresentationRecovery: "); counterTraceWrite(value.admission.includesPresentationRecovery)
    counterTraceWrite("), semanticRevision: "); counterTraceWrite(value.semanticRevision)
    counterTraceWrite(", semanticDisposition: "); counterTraceWrite(value.semanticDisposition)
    counterTraceWrite(", logicalFrameDisposition: "); counterTraceWrite(value.logicalFrameDisposition)
    counterTraceWrite(", committedPresentationRevision: "); counterTraceWrite(value.committedPresentationRevision)
    counterTraceWrite(", presentationIntentState: "); counterTraceWrite(value.presentationIntentState)
    counterTraceWrite(", presentationPending: "); counterTraceWrite(value.presentationPending)
    counterTraceWrite(", operationalEvents: GiftUIExecution.ExecutionOperationalEvents(rawValue: ")
    counterTraceWrite(value.operationalEvents.rawValue); counterTraceWrite("))")''')
fn('ExecutionAdmissionOutcome','''    counterTraceWrite("ExecutionAdmissionOutcome(result: "); counterTraceWrite(value.result)
    counterTraceWrite(", context: "); counterTraceWrite(value.context); counterTraceWrite(")")''')
# Actual concrete overloads: no generic Native Static fallback remains.
for typ,body in [
 ('RuntimeCompletePipelineResult<RuntimeOwnerFailure>','counterTraceWrite(value)'),
 ('RuntimeCompletePipelineStage','counterTraceWrite(counterTraceName(value))'),
 ('RuntimeCleanupAction','counterTraceWrite(counterTraceName(value))'),
 ('RuntimePipelineDisposition','counterTraceWrite(value, nested: false)'),
 ('PointerGestureOutcome<SemanticCompleteIdentity>','counterTraceWrite(value)'),
 ('RuntimeRecordInteractionDispatchResult','counterTraceWrite(value)'),
 ('RunCycleSummary','counterTraceWrite(value)'),
 ('ExecutionAdmissionOutcome','counterTraceWrite(value)'),
 ('(UInt16, UInt16, ObservableModelOwnership.Phase)','counterTraceWrite("("); counterTraceWrite(value.0); counterTraceWrite(", "); counterTraceWrite(value.1); counterTraceWrite(", "); counterTraceWrite(value.2); counterTraceWrite(")")'),
 ('(ExecutionContext, Int, Int, UInt16, UInt16, ObservableModelOwnership.Phase)','counterTraceWrite("("); counterTraceWrite(value.0); counterTraceWrite(", "); counterTraceWrite(value.1); counterTraceWrite(", "); counterTraceWrite(value.2); counterTraceWrite(", "); counterTraceWrite(value.3); counterTraceWrite(", "); counterTraceWrite(value.4); counterTraceWrite(", "); counterTraceWrite(value.5); counterTraceWrite(")")'),
 ('(PresentationPendingIntent?, Bool, UInt32)','counterTraceWrite("("); counterTraceWrite(value.0); counterTraceWrite(", "); counterTraceWrite(value.1); counterTraceWrite(", "); counterTraceWrite(value.2); counterTraceWrite(")")')]:
 emit('func counterTrace(_ label: StaticString, _ value: '+typ+') {\n    counterTraceWrite(label); counterTraceWrite(" ")\n    '+body+'\n    counterTraceWrite("\\n")\n}')
# Place only the finite Native Static facilities in the existing conditional.
block='''    // Finite Native Static trace shapes. The generic print fallback is unavailable
    // in this profile, so new call-site types require an explicit bounded writer.
    // The captured-key InlineArray spelling mirrors this pinned compiler's opaque
    // reflection output; key values are not reconstructed from that placeholder.
'''+ '\n'.join(parts)
anchor='    private func counterTraceWrite(_ text: StaticString) {';assert before.count(anchor)==1
s=before.replace('func counterTrace<T>(_ label: StaticString, _ value: T) {','#if !os(macOS) || GIFTUI_COUNTER_ROUTE_DYNAMIC || hasFeature(Embedded)\nfunc counterTrace<T>(_ label: StaticString, _ value: T) {',1).replace('\n#if os(macOS) && !GIFTUI_COUNTER_ROUTE_DYNAMIC && !hasFeature(Embedded)\n    // Preserve','\n#endif\n\n#if os(macOS) && !GIFTUI_COUNTER_ROUTE_DYNAMIC && !hasFeature(Embedded)\n    // Preserve',1).replace(anchor,block+'\n'+anchor)
src.write_text(s)
(loc/'implementation-start.json').write_text(json.dumps({'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'before_sha256':hashlib.sha256(before.encode()).hexdigest(),'after_unformatted_sha256':hashlib.sha256(s.encode()).hexdigest(),'concrete_overloads_added':11,'generic_fallback_native_static':False,'full_prior_package_clock_certification':False,'scope':'Ordinary implementation; failed U02 proof not requalified'},indent=2)+'\n')
print('Applied eleven-shape owner-only correction; before',len(before),'after',len(s))
