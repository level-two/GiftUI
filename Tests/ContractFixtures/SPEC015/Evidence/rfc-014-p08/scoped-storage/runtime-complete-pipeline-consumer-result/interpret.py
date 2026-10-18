from pathlib import Path
import json,re,hashlib,shutil
R=Path('/Users/eugene/work/GiftUI');B=R/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage';O=R/'.build/contracts/p08-runtime-complete-pipeline-qualification1';P=B/'runtime-complete-pipeline-consumer-result';P.mkdir(exist_ok=True);(P/'evidence').mkdir(exist_ok=True)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
S=(O/'actual-host.sil').read_text().splitlines();A=(O/'logs/host-disassembly.stdout').read_text().splitlines();F={}
for i,l in enumerate(S):
 if l.startswith('sil ') and '@' in l:
  m=re.search(r'@([^ :]+)\s*:',l)
  if not m:continue
  j=next((a for a in range(i+1,len(S)) if S[a].startswith('} // end sil function')),i) if l.rstrip().endswith('{') else i
  comments=[x for x in S[max(0,i-4):i] if x.startswith('// ') and not x.startswith('// Isolation') and not x.startswith('// end')]
  F[m.group(1)]={'symbol':m.group(1),'line':i+1,'end_line':j+1,'header':l,'comment':comments[-1] if comments else '', 'basic_blocks':sum(x.startswith('bb') for x in S[i:j+1])}
def body(f):return S[f['line']-1:f['end_line']]
def refs(f):
 rows=[]
 for k in range(f['line']-1,f['end_line']):
  m=re.search(r'function_ref @([^ :]+)',S[k])
  if m:rows.append({'line':k+1,'symbol':m.group(1),'reference':S[k],'next':S[k+1],'callee':F.get(m.group(1))})
 return rows
def obj(f):
 starts=[i for i,x in enumerate(A) if x.endswith('<_'+f['symbol']+'>:')];assert len(starts)==1,(f['comment'],starts);i=starts[0];j=next((k for k in range(i+1,len(A)) if re.match(r'^[0-9a-f]{16} <',A[k])),len(A));return {'start_line':i+1,'end_line':j,'header':A[i],'lines':A[i:j]}
def write(n,d):(P/n).write_text(json.dumps(d,indent=2)+'\n')
def slice_file(name,lines,start=1):
 (P/'evidence'/name).write_text('\n'.join((str(start+i)+': '+x).rstrip() for i,x in enumerate(lines))+'\n')
scoped=[f for f in F.values() if 'CounterPipelineOwner<P08GeometryAccess, P08CandidateAccess, P08CommittedAccess, P08HitAccess>' in f['header'] and f['basic_blocks']]
lookup=lambda method:next(f for f in scoped if f['comment']=='// specialized CounterPipelineOwner<>.'+method+'()')
root=lookup('runTracedPipeline');opp=lookup('runOpportunity');admit=lookup('admitAndSeal');cleanup=next(f for f in scoped if f['comment']=='// specialized static RuntimeCompletePipeline.cleanup<A>(after:acquired:owner:)')
run_symbol='$s17GiftUIRuntimeCore23RuntimeCompletePipelineO3run5ownerAA0deF6ResultOy12OwnerFailureQzGxz_tAA0defJ0RzRi_zRi0_zlFZ'
assert not any(x['symbol']==run_symbol for x in refs(root)+refs(opp));assert root['basic_blocks']==126
prior=json.loads((B/'runtime-complete-pipeline-grouped-inventory/owner16-stage-frontier.json').read_text());symbols={x['symbol']:x for x in prior['unique_latent_project_symbols']};assert len(symbols)==23
requirements=[];selected=[]
for old in prior['requirements_inspected']:
 name=old['owner_requirement'];matches=[f for f in scoped if f['comment'].startswith('// specialized CounterPipelineOwner<>.'+name+'(')]
 if name in ['presentationIntentState','hasAllocatedCandidateFrame']:
  requirements.append({'requirement':name,'disposition':'inlined direct field/control operations in concrete runTracedPipeline; no generic witness call','source':'Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift:'+str(333 if name=='presentationIntentState' else 334),'sil_ranges':[[10719,10775]] if name=='presentationIntentState' else [[11542,11564],[11756,11777],[11863,11884],[12003,12024]]});continue
 assert len(matches)==1,(name,len(matches));f=matches[0];selected.append(f)
 requirements.append({'requirement':name,'function':f,'direct_project_frontier_refs':[{k:v for k,v in x.items() if k!='callee'}|{'callee':x['callee']} for x in refs(f) if x['symbol'] in symbols],'witness_method_count':sum('witness_method ' in x for x in body(f)),'disposition':'concrete owner body exists; transitive lifetime/cost/continuation acceptance UNQUALIFIED'})
assert len(requirements)==16 and len(selected)==14
physical=json.loads((O/'boundary-physical-index.json').read_text());physicalby={x['name']:{'module':m,**x} for m,v in physical.items() for x in v['functions']}
frontier=[]
for symbol,old in symbols.items():
 edges=[{'requirement':row['requirement'],**x} for row in requirements for x in row.get('direct_project_frontier_refs',[]) if x['symbol']==symbol]
 outside=[{'caller':f,'edge':x} for f in scoped if f not in selected for x in refs(f) if x['symbol']==symbol]
 assert edges or outside,symbol
 callee=F.get(symbol);entry={'symbol':symbol,'name':old['callee_comment'],'previous_requirement_group':old['owner_requirements'],'direct_current16_edges':edges,'other_scoped_concrete_edges':outside,'current_callee':callee,'physical_record':physicalby.get(symbol),'classification':'surviving generic opaque edge; concrete applicability needs grouped closure review' if callee and re.search(r'\$@convention\([^)]*\)\s*<',callee['header']) else 'ordinary nongeneric ABI leaf; zeroBB alone is not a body-availability failure','source_edits_authorized':False}
 frontier.append(entry)
write('owner16-current.json',requirements);write('frontier23-current.json',frontier)
keys=[x for x in refs(admit) if x['symbol'] in symbols and 'InteractionOwnedKeyState' in x['reference']];assert len(keys)==3
object_admit=obj(admit);object_root=obj(root);object_opp=obj(opp)
for x in keys:assert x['callee']['basic_blocks']==0 and physicalby[x['symbol']]['serialized_kind']==0
keyobject=[{'line':object_admit['start_line']+i,'text':l} for i,l in enumerate(object_admit['lines']) if 'ARM64_RELOC_BRANCH26' in l and any(x['symbol'] in l for x in keys)];assert len(keyobject)==3
# Exact actual activation/opportunity callers; inspect only references to this concrete operation.
actualcallers=[]
for f in F.values():
 if f['basic_blocks'] and ('CounterHostState' in f['comment'] or 'CounterHostState' in f['header'] or '0B9HostState' in f['symbol']):
  for x in refs(f):
   if x['symbol']==opp['symbol']:actualcallers.append({'caller':f,'edge':x})
assert len(actualcallers)>=2
resolved={'prior_blocker':'genericRuntimeCompletePipeline.run zeroBB/call0x198c','status':'RESOLVED for concrete scoped Static run opportunity','physical_run':physicalby[run_symbol],'runTracedPipeline':root,'runOpportunity':opp,'runTraced_has_original_generic_run_refs':False,'scoped_runTraced_object':{k:v for k,v in object_root.items() if k!='lines'},'scoped_runOpportunity_object':{k:v for k,v in object_opp.items() if k!='lines'},'actual_activation_opportunity_callers':actualcallers,'three_helpers':'finishOfferWithoutCommit/fail bodies inlined into runTracedPipeline (no directgeneric helper refs there); cleanup specialized4BB directconcreteownercleanup; tenphysicalbody receipt retained','specialized_cleanup':cleanup,'failure_enum_lines':[i+1 for i in range(root['line']-1,root['end_line']) if '#RuntimeCompletePipelineResult.failed' in S[i]],'completed_enum_lines':[i+1 for i in range(root['line']-1,root['end_line']) if '#RuntimeCompletePipelineResult.completed' in S[i]],'not_claimed':'not complete cleanup/branch safety or fullcost proof'}
write('resolved-root.json',resolved)
blocker={'gate':'FAIL required generic callee availability / concrete stage specialization; STOP dependent safety/cold','source_commit':'1db805a6','scope':'one concrete scopedStatic pipeline ->admitAndSeal ->keyresolver family; finite23knownedge update, no broader42catalog','concrete_owner':'CounterPipelineOwner<P08GeometryAccess,P08CandidateAccess,P08CommittedAccess,P08HitAccess>','path':[{'from':opp,'edge':next(x for x in refs(opp) if x['symbol']==root['symbol'])},{'from':root,'edge':next(x for x in refs(root) if x['symbol']==admit['symbol'])}],'admitAndSeal':admit,'keyresolver_edges':keys,'physical_records':[physicalby[x['symbol']] for x in keys],'object_admitAndSeal':{k:v for k,v in object_admit.items() if k!='lines'},'object_keyresolver_relocations':keyobject,'matched_object_sha256':h(R/'.build/contracts/p08-runtime-complete-pipeline-candidate1/owners/P08CounterRuntime/P08CounterRuntime.o'),'observer_distinction':'operational pointer down/move/up branch applies genericresolver and uses returnedgesture to update capture/result; no trace call intervenes in scopedadmit body. Pipeline callsadmit before downstreamtrace. No allocation claim follows. Full metadataTLScontextobserver attribution remainsunqualified.','next_boundary':'grouped read-only source/serialization/ABI/privacy/lifetime review of exact23current refs and required finite transitive callees, prioritize three InteractionOwnedKeyState resolver wrappers +state/raw constructors; no sourcecandidate/automaticrepair allowance','not_claimed':'no measured allocation/heapcount, no all23fail/bodyrequired claim, no contractimpossibility; ordinarynongeneric ABI leaves may remainbodyopaque'}
write('blocker.json',blocker)
for label,f in [('concrete-runTracedPipeline',root),('concrete-runOpportunity',opp),('concrete-admitAndSeal',admit),('concrete-cleanup',cleanup)]:slice_file(label+'.sil',body(f),f['line'])
for label,x in [('concrete-runTracedPipeline',object_root),('concrete-runOpportunity',object_opp),('concrete-admitAndSeal',object_admit)]:slice_file(label+'.object',x['lines'],x['start_line'])
for i,x in enumerate(keys):
 f=x['callee'];slice_file('missing-keyresolver-'+str(i)+'.sil',S[f['line']-3:f['line']+4],f['line']-2)
source=R/'Sources/GiftUIInteraction/InteractionOwnedKeyState.swift';ss=source.read_text().splitlines();slice_file('key-state-source.swift',ss,1)
write('receipt.json',{'source_commit':'1db805a6','source_mutations':0,'compiler_decoder_runtime_executions':0,'automatic_source_repairs':0,'qualification':'../runtime-complete-pipeline-qualification1-result/README.md','sil_sha256':h(O/'actual-host.sil'),'object_sha256':blocker['matched_object_sha256'],'index_sha256':h(O/'boundary-physical-index.json'),'root_resolved':True,'next_material_gate':'keyresolver required genericbody absent on actual concreteadmission','requirements':16,'method_bodies':14,'direct16_frontier_refs':sum(len(x.get('direct_project_frontier_refs',[])) for x in requirements),'known_frontier_symbols':23,'currentallscopedrefs':sum(len(x['direct_current16_edges'])+len(x['other_scoped_concrete_edges']) for x in frontier),'remaining':'all42/privatecallee/Stateborrow/metadataTLScontextobserver/full safety/cold UNQUALIFIED'})
shutil.copyfile('/private/tmp/interpret-complete-pipeline.py',P/'interpret.py');print(json.loads((P/'receipt.json').read_text()))
