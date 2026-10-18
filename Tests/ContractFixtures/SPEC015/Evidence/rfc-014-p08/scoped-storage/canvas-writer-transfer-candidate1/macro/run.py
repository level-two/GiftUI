"""One fresh pinned macOS macro build and all17 maintained tests; no source repair."""
from pathlib import Path
import hashlib,json,os,re,subprocess,sys,time
ROOT=Path('/Users/eugene/work/GiftUI');PACKET=Path(__file__).resolve().parent
PLAN=json.loads((PACKET/'prepared.json').read_text());OUT=Path(PLAN['output'])
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def verify():
 for receipt in ['input-freeze.json','recipe-freeze.json']:
  for name,expected in json.loads((PACKET/receipt).read_text()).items():
   p=Path(name) if Path(name).is_absolute() else ROOT/name;assert digest(p)==expected,('frozen macro input changed',name)
 assert not OUT.exists(),'No retry/output reuse'
 assert len(PLAN['stages'])==4 and PLAN['method_count']==17
 for row in PLAN['stages']:
  assert not any('p08-witness-annotation-compatibility' in x for x in row['command'])
 assert len(json.loads((PACKET/'registered-methods.json').read_text()))==17
verify()
if sys.argv[1:]==['--validate']:
 print('PASS frozen freshmacro recipes, original macOS L/rpath/4framework environment, all17methods; no compiler/test invoked');raise SystemExit(0)
assert not sys.argv[1:]
OUT.mkdir();(OUT/'macro').mkdir();(OUT/'logs').mkdir();result={'status':'running','source_identity':PLAN['source_identity'],'checks':[],'source_candidate':'1/1 zeroautomaticSOURCErepairs'}
def save():(OUT/'result.json').write_text(json.dumps(result,indent=2)+'\n')
for row in PLAN['stages']:
 name=row['name'];log=OUT/'logs'/(name+'.log');env=dict(os.environ)
 if row.get('runner_environment'):env.update(PLAN['environment'])
 start=time.monotonic()
 with log.open('xb') as stream:p=subprocess.run(row['command'],cwd=ROOT,stdout=stream,stderr=subprocess.STDOUT,env=env)
 passed=p.returncode==0
 if name=='macro-tests':passed &= 'executions=17 failures=0 skips=0' in log.read_text(errors='replace')
 result['checks'].append({'name':name,'command':row['command'],'exit':p.returncode,'passed':passed,'seconds':round(time.monotonic()-start,3),'log':str(log),'log_sha256':digest(log)});save();print(name,'PASS' if passed else 'FAIL',flush=True)
 if not passed:result['status']='macro_gate_failed_no_source_repair';save();raise SystemExit(1)
for name,expected in json.loads((PACKET/'input-freeze.json').read_text()).items():
 p=Path(name) if Path(name).is_absolute() else ROOT/name;assert digest(p)==expected,('macro input changed during gate',name)
result['status']='fresh_macro_build_and_all17_tests_passed';save()
