"""Exact returned-view control pair; reuse accepted prerequisites, then gated fresh SIL."""
from pathlib import Path
import hashlib,json,os,re,subprocess,sys,time
ROOT=Path('/Users/eugene/work/GiftUI');PACKET=Path(__file__).resolve().parent
PLAN=json.loads((PACKET/'prepared.json').read_text());OUT=Path(PLAN['output'])
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def verify():
 for receipt in ['input-freeze.json','recipe-freeze.json']:
  for name,expected in json.loads((PACKET/receipt).read_text()).items():
   path=Path(name)if Path(name).is_absolute()else ROOT/name;assert digest(path)==expected,('frozen input changed',name)
 assert not OUT.exists(),'No retry/output reuse'
 prior=json.loads(Path(PLAN['qualified_focused_result']).read_text());assert prior['physical87_available']and len(prior['physical'])==87 and all(x['body_available']for x in prior['physical'])
 assert [x['passed']for x in prior['checks']]==[True,True,False]
 assert prior['checks'][2]['exit']==0 and prior['checks'][2]['errors']==[]
 assert len(PLAN['controls'])==2 and PLAN['controls'][0]['expected_errors']==[]and len(PLAN['controls'][1]['expected_errors'])==1
 old=json.loads((PACKET.parent/'semantic-c-harness-continuation1/prepared.json').read_text())['command'];new=PLAN['command']
 assert len(old)==len(new)and[i for i,(a,b)in enumerate(zip(old,new))if a!=b]==[x['argument_index']for x in PLAN['path_only_sil_adjustments']]
 assert len([x for x in new if x.endswith('.swift')])==42
 original=(PACKET.parent/'semantic-c-harness-continuation1/privacy/semantic-c-borrow-escape-negative.swift').read_text();needle='_ = try borrowed.withCandidateView { view in view }';assert original.count(needle)==1
 for control in PLAN['controls']:
  replacement='_ = try borrowed.withCandidateView { (view) -> '+control['expected_callback_result']+' in\n            return '+control['expected_return_expression']+'\n        }'
  assert Path(control['command'][-1]).read_text()==original.replace(needle,replacement)
verify()
if sys.argv[1:]==['--validate']:
 print('PASS frozen inputs/retained87+72privacy/exactexplicit-returnpair/twoSILpaths; no compiler/tests/runtime');raise SystemExit(0)
assert not sys.argv[1:]
OUT.mkdir();(OUT/'logs').mkdir();result={'status':'checking_explicit_return_controls','source_commit':PLAN['source_commit'],'source_mutations':0,'automatic_source_repairs':0,'checks':[],'reused':PLAN['reuse'],'qualified_physical87':PLAN['qualified_focused_result']}
def save():(OUT/'result.json').write_text(json.dumps(result,indent=2)+'\n')
env=dict(os.environ);env.update(PLAN['environment'])
for control in PLAN['controls']:
 name=control['name'];stdout=OUT/'logs'/(name+'.stdout');stderr=OUT/'logs'/(name+'.stderr');start=time.monotonic()
 with stdout.open('xb')as a,stderr.open('xb')as b:process=subprocess.run(control['command'],cwd=ROOT,env=env,stdout=a,stderr=b)
 text=stdout.read_text(errors='replace')+stderr.read_text(errors='replace');errors=re.findall(r'^.*?:\d+:\d+: error: (.*)$',text,re.M);expected=control['expected_errors']
 passed=(process.returncode==0 and not errors)if not expected else(process.returncode!=0 and sorted(errors)==sorted(expected))
 result['checks'].append({'name':name,'command':control['command'],'exit':process.returncode,'errors':errors,'expected':expected,'passed':passed,'seconds':round(time.monotonic()-start,3),'outputs':{str(q):{'bytes':q.stat().st_size,'sha256':digest(q)}for q in[stdout,stderr]}});save();print(name,'PASS'if passed else'FAIL',flush=True)
if not all(x['passed']for x in result['checks']):
 result.update(status='explicit_return_control_failed_consumer_blocked',remaining='preserve evidence/no source repair or unreviewed retry');save();raise SystemExit(1)
start=time.monotonic();stdout=OUT/'logs/actual-host-sil.stdout';stderr=OUT/'logs/actual-host-sil.stderr'
with stdout.open('xb')as a,stderr.open('xb')as b:process=subprocess.run(PLAN['command'],cwd=ROOT,env=env,stdout=a,stderr=b)
for name,expected in json.loads((PACKET/'input-freeze.json').read_text()).items():
 path=Path(name)if Path(name).is_absolute()else ROOT/name;assert digest(path)==expected,('input changed',name)
sil=OUT/'actual-host.sil';present=sil.is_file()and sil.stat().st_size>0;result.update(status='explicit_return_pair_passed_sil_collected_unreviewed'if process.returncode==0 and present else'sil_collection_failed',command=PLAN['command'],exit=process.returncode,seconds=round(time.monotonic()-start,3),outputs={str(q):{'bytes':q.stat().st_size,'sha256':digest(q)}for q in[stdout,stderr,sil]if q.is_file()},remaining='actualCmetadata/publication/borrow/cost interpretation, fullsafety/14loan/Optional/lifetime/strictcold/P08 unqualified');save();print(result['status'],flush=True);raise SystemExit(0 if result['status']=='explicit_return_pair_passed_sil_collected_unreviewed'else 1)
