"""Reviewed-selector continuation only: reuse fixed evidence, then collect fresh SIL."""
from pathlib import Path
import hashlib,json,os,re,subprocess,sys,time
ROOT=Path('/Users/eugene/work/GiftUI');PACKET=Path(__file__).resolve().parent
PLAN=json.loads((PACKET/'prepared.json').read_text());OUT=Path(PLAN['output'])
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def verify():
 for receipt in ['input-freeze.json','recipe-freeze.json']:
  for name,expected in json.loads((PACKET/receipt).read_text()).items():
   path=Path(name) if Path(name).is_absolute() else ROOT/name;assert digest(path)==expected,('frozen input changed',name)
 assert not OUT.exists(),'No retry/output reuse'
 old=json.loads(Path(PLAN['qualified_prerequisites']).read_text());compile=json.loads(Path(PLAN['qualified_compile_result']).read_text())
 assert compile['counts']=={'passed':25,'failed':0,'blocked':0} and compile['lower']['status']=='passed'
 assert old['object_capture_passed'] and len(old['checks'])==87 and all(x['passed'] for x in old['checks'][:70]+old['checks'][73:])
 assert sum(x['body_available'] for x in old['required_bodies'])==86 and len(old['required_bodies'])==87
 before=json.loads((PACKET.parent/'semantic-c-candidate1/qualification/required-body-targets.json').read_text());after=json.loads((PACKET/'proposed-required-87.json').read_text());mapping=json.loads((PACKET/'harness-correction-map.json').read_text())
 changed=[i for i,(a,b) in enumerate(zip(before,after)) if a!=b];assert len(before)==len(after)==87 and changed==[x['target_index'] for x in mapping['rows']]
 original=json.loads((PACKET.parent/'semantic-c-candidate1/qualification/prepared.json').read_text())['consumer_command'];new=PLAN['command']
 assert len(original)==len(new) and [i for i,(a,b) in enumerate(zip(original,new)) if a!=b]==[x['argument_index'] for x in PLAN['path_only_adjustments']]
 assert len([x for x in new if x.endswith('.swift')])==42
 assert len(mapping['rows'])==1
 assert len(PLAN['privacy_controls'])==3 and not any(x['passed']for x in old['checks'][70:73])
 assert [x['name']for x in PLAN['privacy_controls']]==[x['name']for x in old['checks'][70:73]]
 original_controls=json.loads((PACKET.parent/'semantic-c-candidate1/qualification/prepared.json').read_text())['privacy_controls'][-3:]
 for oldcontrol,newcontrol,change in zip(original_controls,PLAN['privacy_controls'],mapping['fixture_changes']):
  beforetext=Path(change['old_path']).read_text();aftertext=Path(change['new_path']).read_text()
  assert beforetext.count(') { store in')==1 and aftertext==beforetext.replace(') { store in',') { (store) throws(SemanticExpansionError) in')
  expectedindices=[x['argument_index']for x in newcontrol['path_only_adjustments']]
  assert [i for i,(a,b)in enumerate(zip(oldcontrol['command'],newcontrol['command']))if a!=b]==expectedindices
 variants=json.loads(Path(PLAN['original_output']).joinpath('compile/variants-result.json').read_text());assert variants['status']=='passed' and variants['count']==4 and all(x['passed']for x in variants['checks'])
 macro=json.loads(Path(PLAN['original_output']).joinpath('macro/result.json').read_text());assert macro['status']=='fresh_macro_build_and_all17_tests_passed'
verify()
if sys.argv[1:]==['--validate']:
 print('PASS frozen inputs/prerequisites/exact1selector+3typedcontrols/twoSILpaths; correctedcontrols/selection NOT executed; no compiler/decoder/runtime invoked');raise SystemExit(0)
assert not sys.argv[1:]
OUT.mkdir();(OUT/'logs').mkdir();result={'checks':[],'status':'checking_corrected_typed_controls','source_commit':PLAN['source_commit'],'source_mutations':0,'automatic_source_repairs':0,'source_budget':'candidate1/1 fixed/all oldbudgets unchanged; selector correction only','reused':'macro17/compile25/variants4/prior70privacy/11decode+completeindex/2objectcaptures; no repeats','physical':[]}
def save():(OUT/'result.json').write_text(json.dumps(result,indent=2)+'\n')
privacy_pass=True
for control in PLAN['privacy_controls']:
 start=time.monotonic();name=control['name'];env=dict(os.environ);env.update(PLAN['environment'])
 stdout=OUT/'logs'/(name+'.stdout');stderr=OUT/'logs'/(name+'.stderr')
 with stdout.open('xb') as a,stderr.open('xb') as b:process=subprocess.run(control['command'],cwd=ROOT,env=env,stdout=a,stderr=b)
 text=stdout.read_text(errors='replace')+stderr.read_text(errors='replace');errors=re.findall(r'^.*?:\d+:\d+: error: (.*)$',text,re.M);expected=control['expected_errors']
 passed=(process.returncode==0 and not errors)if not expected else(process.returncode!=0 and sorted(errors)==sorted(expected))
 result['checks'].append({'name':name,'command':control['command'],'exit':process.returncode,'errors':errors,'expected':expected,'passed':passed,'seconds':round(time.monotonic()-start,3),'outputs':{str(q):{'bytes':q.stat().st_size,'sha256':digest(q)}for q in[stdout,stderr]}});privacy_pass &= passed;save();print(name,'PASS'if passed else'FAIL',flush=True)
result['corrected_three_privacy_passed']=privacy_pass
index=json.loads(Path(PLAN['qualified_index']).read_text());mapping=json.loads((PACKET/'harness-correction-map.json').read_text());expected={x['target_index']:x['physical_record'] for x in mapping['rows']}
for i,target in enumerate(json.loads((PACKET/'proposed-required-87.json').read_text())):
 functions=index[target['module']]['functions']
 if 'name' in target:matches=[x for x in functions if x['name']==target['name']]
 elif 'demangled_prefix' in target:matches=[x for x in functions if x['demangled'].startswith(target['demangled_prefix'])]
 else:matches=[x for x in functions if re.search(target['demangled_regex'],x['demangled'])]
 passed=len(matches)==1 and matches[0]['serialized_kind']!=0 and matches[0]['basic_blocks']>0
 if i in expected:passed &= matches==[expected[i]]
 result['physical'].append({'target':target,'matches':matches,'body_available':passed})
physical_pass=len(result['physical'])==87 and all(x['body_available'] for x in result['physical']);result['physical87_available']=physical_pass;save()
if not physical_pass or not privacy_pass:
 result.update(status='focused_prerequisite_failed_consumer_blocked',remaining='preserve evidence/no repair or source allowance');save();raise SystemExit(1)
environment=dict(os.environ);environment.update(PLAN['environment']);start=time.monotonic()
with (OUT/'logs/actual-host-sil.stdout').open('xb') as stdout,(OUT/'logs/actual-host-sil.stderr').open('xb') as stderr:process=subprocess.run(PLAN['command'],cwd=ROOT,env=environment,stdout=stdout,stderr=stderr)
for name,expected in json.loads((PACKET/'input-freeze.json').read_text()).items():
 path=Path(name) if Path(name).is_absolute() else ROOT/name;assert digest(path)==expected,('input changed during continuation',name)
sil=OUT/'actual-host.sil';present=sil.is_file() and sil.stat().st_size>0;result.update(status='physical87_passed_sil_collected_unreviewed' if process.returncode==0 and present else 'sil_collection_failed',command=PLAN['command'],exit=process.returncode,seconds=round(time.monotonic()-start,3),outputs={str(p):{'bytes':p.stat().st_size,'sha256':digest(p)} for p in [OUT/'logs/actual-host-sil.stdout',OUT/'logs/actual-host-sil.stderr',sil] if p.is_file()},remaining='actual42/modelmatching/mutation/report/read/reclaim callbacks/rawkeymetadataTLScontextobserver interpretation; fullprivateP08/14loan safety and strictcold/P08 unaccepted');save();print(result['status'],flush=True);raise SystemExit(0 if result['status']=='physical87_passed_sil_collected_unreviewed' else 1)
