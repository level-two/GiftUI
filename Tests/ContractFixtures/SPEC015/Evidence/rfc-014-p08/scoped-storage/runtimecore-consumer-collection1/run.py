"""Collect one fresh actual-host SIL file; never reuse the unqualified old output."""
from pathlib import Path
import hashlib,json,os,subprocess,sys,time
ROOT=Path('/Users/eugene/work/GiftUI');PACKET=Path(__file__).resolve().parent
PLAN=json.loads((PACKET/'prepared.json').read_text());OUT=Path(PLAN['output'])
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def verify():
 for receipt in ('input-freeze.json','recipe-freeze.json'):
  for name,expected in json.loads((PACKET/receipt).read_text()).items():
   path=Path(name) if Path(name).is_absolute() else ROOT/name;assert digest(path)==expected,('frozen input changed',name)
 assert not OUT.exists(),'No output reuse/retry; preserve existing files'
 old=json.loads((PACKET.parent/'runtimecore-fixed-qualification1/consumer-command.json').read_text())['command'];new=PLAN['command']
 assert len(old)==len(new) and [i for i,(a,b) in enumerate(zip(old,new)) if a!=b]==[x['argument_index'] for x in PLAN['path_only_adjustments']]
 assert len([x for x in new if x.endswith('.swift')])==42
 required=json.loads(Path(PLAN['qualification_result']).read_text());assert required['status']=='qualification_prerequisites_passed' and all(required[k] for k in ('privacy_controls_passed','physical_six_available','object_capture_passed'))
verify()
if sys.argv[1:]==['--validate']:
 print('PASS573hashes/prerequisites/42sources/two path-only argv changes; old SIL preserved; no compiler invoked');raise SystemExit(0)
assert not sys.argv[1:]
OUT.mkdir();(OUT/'logs').mkdir();environment=dict(os.environ);environment.update(PLAN['environment']);started=time.monotonic()
with Path(PLAN['stdout']).open('xb') as stdout,Path(PLAN['stderr']).open('xb') as stderr:
 process=subprocess.run(PLAN['command'],cwd=ROOT,env=environment,stdout=stdout,stderr=stderr)
for name,expected in json.loads((PACKET/'input-freeze.json').read_text()).items():
 path=Path(name) if Path(name).is_absolute() else ROOT/name;assert digest(path)==expected,('input changed during collection',name)
sil=OUT/'actual-host.sil';present=sil.is_file() and sil.stat().st_size>0
result={'status':'sil_collected_unreviewed' if process.returncode==0 and present else 'sil_collection_failed','source_commit':PLAN['source_commit'],'command':PLAN['command'],'environment':PLAN['environment'],'exit':process.returncode,'duration_seconds':round(time.monotonic()-started,3),'path_only_adjustments':PLAN['path_only_adjustments'],'input_hashes_verified':573,'source_mutations':0,'automatic_source_repairs':0,'outputs':{str(p):{'bytes':p.stat().st_size,'sha256':digest(p)} for p in [Path(PLAN['stdout']),Path(PLAN['stderr']),sil] if p.is_file()},'remaining':'actual42origins/privatecallee/concretehost/continuation/destruction/metadata/TLS/observer review; full14loan/Optional/lifetime/provenance/exclusivity/failurecleanup safety; strictcold/P08 unaccepted'}
(OUT/'result.json').write_text(json.dumps(result,indent=2)+'\n');print(result['status'],flush=True);raise SystemExit(0 if result['status']=='sil_collected_unreviewed' else 1)
