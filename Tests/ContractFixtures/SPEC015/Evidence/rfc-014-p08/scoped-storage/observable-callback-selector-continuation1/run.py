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
 assert old['privacy_controls_passed'] and old['object_capture_passed'] and len(old['checks'])==75 and all(x['passed'] for x in old['checks'])
 assert sum(x['body_available'] for x in old['required_bodies'])==48 and len(old['required_bodies'])==50
 before=json.loads((PACKET.parent/'observable-callback-candidate1/qualification/required-body-targets.json').read_text());after=json.loads((PACKET/'proposed-required-fifty.json').read_text());mapping=json.loads((PACKET/'selector-correction-map.json').read_text())
 changed=[i for i,(a,b) in enumerate(zip(before,after)) if a!=b];assert len(before)==len(after)==50 and changed==[x['target_index'] for x in mapping['rows']]
 original=json.loads((PACKET.parent/'observable-callback-candidate1/qualification/prepared.json').read_text())['consumer_command'];new=PLAN['command']
 assert len(original)==len(new) and [i for i,(a,b) in enumerate(zip(original,new)) if a!=b]==[x['argument_index'] for x in PLAN['path_only_adjustments']]
 assert len([x for x in new if x.endswith('.swift')])==42
verify()
if sys.argv[1:]==['--validate']:
 print('PASS frozen861inputs/prerequisites/exact2change-map/twoSILpaths; proposedselection NOT applied; no compiler/decoder/runtime invoked');raise SystemExit(0)
assert not sys.argv[1:]
OUT.mkdir();(OUT/'logs').mkdir();result={'status':'selecting_pinned_physical_records','source_commit':PLAN['source_commit'],'source_mutations':0,'automatic_source_repairs':0,'source_budget':'candidate1/1 fixed/all oldbudgets unchanged; selector correction only','reused':'compile25/privacy64/8decode+completeindex/2objectcaptures; no repeats','physical':[]}
def save():(OUT/'result.json').write_text(json.dumps(result,indent=2)+'\n')
index=json.loads(Path(PLAN['qualified_index']).read_text());mapping=json.loads((PACKET/'selector-correction-map.json').read_text());expected={x['target_index']:x['physical_record'] for x in mapping['rows']}
for i,target in enumerate(json.loads((PACKET/'proposed-required-fifty.json').read_text())):
 functions=index[target['module']]['functions']
 if 'name' in target:matches=[x for x in functions if x['name']==target['name']]
 elif 'demangled_prefix' in target:matches=[x for x in functions if x['demangled'].startswith(target['demangled_prefix'])]
 else:matches=[x for x in functions if re.search(target['demangled_regex'],x['demangled'])]
 passed=len(matches)==1 and matches[0]['serialized_kind']!=0 and matches[0]['basic_blocks']>0
 if i in expected:passed &= matches==[expected[i]]
 result['physical'].append({'target':target,'matches':matches,'body_available':passed})
physical_pass=len(result['physical'])==50 and all(x['body_available'] for x in result['physical']);result['physical_fifty_available']=physical_pass;save()
if not physical_pass:
 result.update(status='physical_selection_failed_consumer_blocked',remaining='preserve evidence/no repair or source allowance');save();raise SystemExit(1)
environment=dict(os.environ);environment.update(PLAN['environment']);start=time.monotonic()
with (OUT/'logs/actual-host-sil.stdout').open('xb') as stdout,(OUT/'logs/actual-host-sil.stderr').open('xb') as stderr:process=subprocess.run(PLAN['command'],cwd=ROOT,env=environment,stdout=stdout,stderr=stderr)
for name,expected in json.loads((PACKET/'input-freeze.json').read_text()).items():
 path=Path(name) if Path(name).is_absolute() else ROOT/name;assert digest(path)==expected,('input changed during continuation',name)
sil=OUT/'actual-host.sil';present=sil.is_file() and sil.stat().st_size>0;result.update(status='physical50_passed_sil_collected_unreviewed' if process.returncode==0 and present else 'sil_collection_failed',command=PLAN['command'],exit=process.returncode,seconds=round(time.monotonic()-start,3),outputs={str(p):{'bytes':p.stat().st_size,'sha256':digest(p)} for p in [OUT/'logs/actual-host-sil.stdout',OUT/'logs/actual-host-sil.stderr',sil] if p.is_file()},remaining='actual42/modelmatching/mutation/report/read/reclaim callbacks/rawkeymetadataTLScontextobserver interpretation; fullprivateP08/14loan safety and strictcold/P08 unaccepted');save();print(result['status'],flush=True);raise SystemExit(0 if result['status']=='physical50_passed_sil_collected_unreviewed' else 1)
