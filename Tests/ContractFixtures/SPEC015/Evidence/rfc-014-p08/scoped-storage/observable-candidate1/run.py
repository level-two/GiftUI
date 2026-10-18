"""One frozen candidate: fresh compile, gated privacy/physical/consumer collection."""
from pathlib import Path
import hashlib,json,subprocess,sys,time
ROOT=Path('/Users/eugene/work/GiftUI');PACKET=Path(__file__).resolve().parent
PLAN=json.loads((PACKET/'prepared.json').read_text());OUT=Path(PLAN['output'])
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def verify_recipes():
 for name,expected in json.loads((PACKET/'recipe-freeze.json').read_text()).items():assert digest(ROOT/name)==expected,('prepared recipe changed',name)
 assert not OUT.exists(),'No retry/output reuse'
verify_recipes()
if sys.argv[1:]==['--validate']:
 for command in [PLAN['compile_command'],PLAN['qualification_command']]:subprocess.run(command+['--validate'],cwd=ROOT,check=True)
 print('PASS combinedstaticrecipes/gates; futurefreshartifacts hashsealed only after25PASS; no compiler/decoder/runtime executed');raise SystemExit(0)
assert not sys.argv[1:]
OUT.mkdir();(OUT/'logs').mkdir();result={'status':'running','candidate':'1/1','automatic_source_repairs':0,'source_identity':PLAN['source_identity'],'historical_budgets':'all exhausted/fixedprioractivities unchanged','phases':[]}
def save():(OUT/'result.json').write_text(json.dumps(result,indent=2)+'\n')
def phase(name,command):
 start=time.monotonic()
 with (OUT/'logs'/(name+'.log')).open('xb') as stream:p=subprocess.run(command,cwd=ROOT,stdout=stream,stderr=subprocess.STDOUT)
 row={'name':name,'command':command,'exit':p.returncode,'seconds':round(time.monotonic()-start,3),'log_sha256':digest(OUT/'logs'/(name+'.log'))};result['phases'].append(row);save();print(name,'PASS' if p.returncode==0 else 'FAIL',flush=True);return p.returncode
try:
 save()
 if phase('compile',PLAN['compile_command'])!=0:
  result.update(status='compile_failed_qualification_blocked',remaining='no source repair/retry; privacy/physical/consumer/full safety/cold blocked');save();raise SystemExit(1)
 compileout=OUT/'compile';receipt=json.loads((compileout/'result.json').read_text());assert receipt['status']=='compile_closure_passed' and receipt['counts']=={'passed':25,'failed':0,'blocked':0} and receipt['lower']['status']=='passed'
 artifacts={str(compileout/'result.json'):digest(compileout/'result.json')}
 for row in receipt['checks']+[receipt['lower']]:
  assert row['status']=='passed'
  for name,expected in row.get('source_sha256',{}).items():assert digest(Path(name))==expected,('compiled source changed',name)
  for key in ('outputs_sha256','published_imports_sha256','generated_sha256'):
   for name,expected in row.get(key,{}).items():
    assert str(Path(name)).startswith(str(compileout)+'/') and digest(Path(name))==expected,('fresh output changed',name);artifacts[name]=expected
  name=row['log'];assert str(Path(name)).startswith(str(compileout)+'/') and digest(Path(name))==row['log_sha256'];artifacts[name]=row['log_sha256']
 seal=Path(PLAN['future_artifact_seal']);seal.write_text(json.dumps(artifacts,indent=2)+'\n');sealed_digest=digest(seal);result['qualified_fresh_artifacts']={'count':len(artifacts),'seal':str(seal),'sha256':sealed_digest};save()
 code=phase('qualification',PLAN['qualification_command']);assert digest(seal)==sealed_digest
 for name,expected in artifacts.items():assert digest(Path(name))==expected,('fresh artifact changed afterqualification',name)
 result.update(status='focused_qualification_passed_collection_unreviewed' if code==0 else 'qualification_failed_consumer_gated',remaining='actual42/privatecallee/normal-error provenance/model/report/reclaim/metadataTLScontextobserver interpretation; fullprivateP08/14loan safety and strictcold/P08 unaccepted');save();raise SystemExit(code)
except Exception as error:
 result.update(status='collection_failed_frozen',error=repr(error),remaining='no automatic repair/retry; preserve logs,dependentgates blocked');save();raise
