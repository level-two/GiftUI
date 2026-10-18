"""Run four genuine maintained native validation producers once; never run cold."""
from pathlib import Path
import hashlib,json,os,re,subprocess,sys,time
ROOT=Path('/Users/eugene/work/GiftUI');PACKET=Path(__file__).resolve().parent
PLAN=json.loads((PACKET/'prepared.json').read_text());OUT=ROOT/PLAN['output']
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def verify():
 for name,h in json.loads((PACKET/'input-freeze.json').read_text()).items():assert digest(ROOT/name)==h,('changed input',name)
 assert not OUT.exists(),'No automatic retry/output reuse'
 for phase in PLAN['phases']:
  assert phase['command'][0]=='python3' and len(phase['command'])>=3
 assert len(PLAN['phases'])==4
verify()
if sys.argv[1:]==['--validate']:
 print('PASS static frozen inputs/four maintained producers/fresh receipt discovery/cold excluded; no compiler/runtime');raise SystemExit(0)
assert not sys.argv[1:]
# The ordinary repository lock serializes shared SwiftPM/cache writers.
if not os.environ.get('GIFTUI_VALIDATION_LOCK_OWNER'):
 os.execvp('ruby',['ruby',str(ROOT/'scripts/lib/serialize-validation.rb'),sys.executable,str(PACKET/'run.py')])
OUT.mkdir();(OUT/'logs').mkdir();result={'status':'running','production_source_changes':False,'source_identity':'cb4b10f0 fixed; source1/1 zero automatic repairs; historical budgets closed','phases':[],'strict_cold_eligible':False,'current_callee_review':'pending complete actualpath/ordinaryleaf/observer attribution; retained selected23 proof only'}
receipts={}
def save():(OUT/'result.json').write_text(json.dumps(result,indent=2)+'\n')
def qualify(path,started):
 path=Path(path).resolve();assert str(path).startswith(str(ROOT/'.build')+'/') and path.is_file();assert path.stat().st_mtime_ns>=started,'Stale receipt rejected'
 d=json.loads(path.read_text());assert d['profile']=='macos-static'
 for n,h in d['inputs'].items():assert digest(ROOT/n)==h,('producer input changed',n)
 for n,v in d.get('artifacts',{}).items():assert digest(path.parent/n)==v['sha256'],('producer artifact changed',n)
 return {'path':str(path),'sha256':digest(path),'data':d}
try:
 for phase in PLAN['phases']:
  argv=[receipts[x[1:-1]]['path'].rsplit('/',1)[0] if x.startswith('{') and x.endswith('}') else x for x in phase['command']]
  prefix=OUT/'logs'/phase['name'];started=time.time_ns();timer=time.monotonic()
  with Path(str(prefix)+'.stdout').open('xb') as stdout,Path(str(prefix)+'.stderr').open('xb') as stderr:p=subprocess.run(argv,cwd=ROOT,stdout=stdout,stderr=stderr)
  text=Path(str(prefix)+'.stdout').read_text(errors='replace');row={'name':phase['name'],'command':argv,'exit':p.returncode,'seconds':round(time.monotonic()-timer,3),'stdout_sha256':digest(str(prefix)+'.stdout'),'stderr_sha256':digest(str(prefix)+'.stderr')};result['phases'].append(row);save();print(phase['name'],p.returncode,flush=True)
  if p.returncode!=0:result['status']='failed_stage_frozen_dependents_blocked';save();raise SystemExit(p.returncode)
  hits=re.findall(phase['receipt_regex'],text,re.M);assert len(hits)==1,('Receipt discovery not unique',phase['name'],hits)
  path=hits[0].strip();path=str(Path(path)/'result.json') if phase.get('directory_output') else path
  receipt=qualify(path,started);receipts[phase['key']]=receipt;row['receipt']={'path':receipt['path'],'sha256':receipt['sha256']}
  if phase['key']=='core':
   assert receipt['data']['package']=='P02'
   records=re.findall(r'^P04 macos-static:[\s\S]*?;\s*(\S+/result\.json)\s*$',text,re.M);assert len(records)==1
   p04=qualify(records[0],started);row['registered_P04']={'path':p04['path'],'sha256':p04['sha256']};assert p04['data']['package']=='P04'
  if phase['key']=='counter':
   d=receipt['data'];assert d['collection_complete'] and d['passed'] and not d['fresh_focused'];assert len(d['planned_scoped_labels'])==384
  save()
 verify_inputs=json.loads((PACKET/'input-freeze.json').read_text())
 for n,h in verify_inputs.items():assert digest(ROOT/n)==h,('campaign input changed',n)
 result['status']='maintained_safety_producers_passed_currentcallee_review_and_cold_pending';result['remaining']=PLAN['remaining'];save()
except Exception as e:
 result['status']='campaign_setup_or_qualification_failure_frozen';result['error']=repr(e);save();raise
