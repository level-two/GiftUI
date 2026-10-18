"""One fixed-source privacy/physical-availability collection; no dependent runtime."""
from pathlib import Path
import hashlib,json,os,re,shutil,subprocess,sys,time
ROOT=Path('/Users/eugene/work/GiftUI'); PACKET=Path(__file__).resolve().parent
PLAN=json.loads((PACKET/'prepared.json').read_text()); OUT=Path(PLAN['output'])
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def verify():
 for receipt in ('input-freeze.json','recipe-freeze.json'):
  for name,expected in json.loads((PACKET/receipt).read_text()).items():
   path=Path(name) if Path(name).is_absolute() else ROOT/name
   assert digest(path)==expected,('input changed',name)
 assert not OUT.exists(),'No retry/output reuse'
 assert len(PLAN['privacy_controls'])==22 and len(PLAN['decode_commands'])==6
 assert json.loads(Path(PLAN['qualified_compile_result']).read_text())['counts']=={'passed':25,'failed':0,'blocked':0}
 for row in PLAN['privacy_controls']:
  argv=row['command'];assert [argv[i+1] for i,x in enumerate(argv) if x=='-I']==[str(Path(PLAN['qualified_compile_result']).parent/'modules')]
verify()
if sys.argv[1:]==['--validate']:
 print('PASS frozen source/current25 outputs/22privacy/6decode commands; no compiler/decoder/runtime executed');raise SystemExit(0)
assert not sys.argv[1:]
OUT.mkdir();(OUT/'logs').mkdir();shutil.copyfile(PACKET/'boundaries-decode-prepared.json',OUT/'boundaries-decode-prepared.json')
result={'status':'running','source_commit':PLAN['source_commit'],'automatic_source_repairs':0,'checks':[]}
def save():(OUT/'result.json').write_text(json.dumps(result,indent=2)+'\n')
def execute(name,argv,environment=None,decode=False):
 env=dict(os.environ);env.update(environment or {});prefix=OUT/(name if decode else 'logs/'+name);started=time.monotonic()
 with Path(str(prefix)+'.stdout').open('xb') as out,Path(str(prefix)+'.stderr').open('xb') as err:
  process=subprocess.run(argv,cwd=ROOT,env=env,stdout=out,stderr=err)
 text=Path(str(prefix)+'.stdout').read_text(errors='replace')+Path(str(prefix)+'.stderr').read_text(errors='replace')
 return {'name':name,'command':argv,'exit':process.returncode,'duration_seconds':round(time.monotonic()-started,3),'errors':re.findall(r'^.*?:\d+:\d+: error: (.*)$',text,re.M),'stdout_sha256':digest(Path(str(prefix)+'.stdout')),'stderr_sha256':digest(Path(str(prefix)+'.stderr'))}
for control in PLAN['privacy_controls']:
 row=execute(control['name'],control['command'],PLAN['environment']);errors=row['errors']
 if 'expected_errors' in control:
  expected=control['expected_errors'];passed=(row['exit']==0 and not errors) if not expected else (row['exit']!=0 and len(errors)==len(expected) and sorted(errors)==sorted(expected))
 else:
  expected=control['expected_error_regex'];passed=(row['exit']==0 and not errors) if expected is None else (row['exit']!=0 and len(errors)==control['expected_count'] and all(re.search(expected,x) for x in errors))
 row['expected']=control.get('expected_errors',control.get('expected_error_regex'));row['passed']=passed;result['checks'].append(row);save();print(row['name'],'PASS' if passed else 'FAIL',flush=True)
privacy_pass=all(x['passed'] for x in result['checks']);decode_pass=True
for module,argv in PLAN['decode_commands'].items():
 row=execute(module+'-decode',argv,PLAN['decoder_environment'],True);row['passed']=row['exit']==0;decode_pass &= row['passed'];result['checks'].append(row);save();print(row['name'],'PASS' if row['passed'] else 'FAIL',flush=True)
physical=[]
if decode_pass:
 row=execute('interpret',PLAN['interpreter_command'],PLAN['decoder_environment']);row['passed']=row['exit']==0;result['checks'].append(row);save();decode_pass &= row['passed']
 if row['passed']:
  index=json.loads((OUT/'boundary-physical-index.json').read_text())
  for target in json.loads((PACKET/'required-six.json').read_text()):
   matches=[x for x in index[target['module']]['functions'] if x['name']==target['name']];present=len(matches)==1 and matches[0]['serialized_kind']!=0 and matches[0]['basic_blocks']>0
   physical.append({'module':target['module'],'name':target['name'],'matches':matches,'body_available':present})
result['required_six']=physical;body_pass=decode_pass and len(physical)==6 and all(x['body_available'] for x in physical)
# Raw object capture is independent evidence only; no allocation/specialization pass is inferred.
object_pass=True
for name,argv in PLAN['object_commands'].items():
 row=execute(name,argv,PLAN['decoder_environment']);row['passed']=row['exit']==0;object_pass &= row['passed'];result['checks'].append(row);save()
for name,expected in json.loads((PACKET/'input-freeze.json').read_text()).items():
 path=Path(name) if Path(name).is_absolute() else ROOT/name;assert digest(path)==expected,('input changed during collection',name)
result.update(privacy_controls_passed=privacy_pass,physical_six_available=body_pass,object_capture_passed=object_pass,status='qualification_prerequisites_passed' if privacy_pass and body_pass and object_pass else 'qualification_prerequisites_failed',later_gates='actual42source optimized SIL/callee/continuation/destruction/observer review and full privacy/lifetime/14loan/Optional/provenance/exclusivity/failure-cleanup safety remain unqualified; strict cold blocked')
save();print(result['status'],flush=True);raise SystemExit(0 if result['status']=='qualification_prerequisites_passed' else 1)
