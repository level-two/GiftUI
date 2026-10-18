"""One frozen Canvas candidate: macro tests, fresh modules, variants, gated qualification."""
from pathlib import Path
import hashlib,json,os,subprocess,sys,time
ROOT=Path('/Users/eugene/work/GiftUI');PACKET=Path(__file__).resolve().parent
PLAN=json.loads((PACKET/'prepared.json').read_text());OUT=Path(PLAN['output'])
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def verify_recipes():
 for n,h in json.loads((PACKET/'recipe-freeze.json').read_text()).items():assert digest(ROOT/n)==h,('recipe changed',n)
 assert not OUT.exists(),'No retry/output reuse'
verify_recipes()
if sys.argv[1:]==['--validate']:
 for cmd in [PLAN['macro_command'],PLAN['compile_command'],PLAN['qualification_command']]:subprocess.run(cmd+['--validate'],cwd=ROOT,check=True)
 assert len(PLAN['variant_commands'])==4
 print('PASS combinedmacro17/fresh25/variants4/privacy70/index11/body76/same42 gates; no compiler/test/decoder/runtime');raise SystemExit(0)
assert not sys.argv[1:]
OUT.mkdir();(OUT/'logs').mkdir();result={'status':'running','source_identity':PLAN['source_identity'],'candidate':'1/1 zeroautomaticSOURCErepairs','historical_budgets':'all previous fixed/exhausted unchanged','phases':[]}
def save():(OUT/'result.json').write_text(json.dumps(result,indent=2)+'\n')
def phase(name,cmd):
 start=time.monotonic();log=OUT/'logs'/(name+'.log')
 with log.open('xb') as stream:p=subprocess.run(cmd,cwd=ROOT,stdout=stream,stderr=subprocess.STDOUT,env={**os.environ,**PLAN['environment']})
 row={'name':name,'command':cmd,'exit':p.returncode,'seconds':round(time.monotonic()-start,3),'log':str(log),'log_sha256':digest(log)};result['phases'].append(row);save();print(name,'PASS' if p.returncode==0 else 'FAIL',flush=True);return row
try:
 if phase('macro',PLAN['macro_command'])['exit']!=0:result['status']='macro_failed_later_gates_blocked';save();raise SystemExit(1)
 macroout=OUT/'macro';mr=json.loads((macroout/'result.json').read_text());assert mr['status']=='fresh_macro_build_and_all17_tests_passed'
 ma={str(p):digest(p) for p in macroout.rglob('*') if p.is_file() and not any(x in p.relative_to(macroout).parts for x in ['cache','test-cache','index'])};seal=Path(PLAN['future_macro_seal']);seal.write_text(json.dumps(ma,indent=2)+'\n');mh=digest(seal);result['qualified_fresh_macro_artifacts']={'count':len(ma),'seal':str(seal),'sha256':mh};save()
 if phase('compile',PLAN['compile_command'])['exit']!=0:result['status']='compile_failed_later_gates_blocked';save();raise SystemExit(1)
 co=OUT/'compile';cr=json.loads((co/'result.json').read_text());assert cr['status']=='compile_closure_passed' and cr['counts']=={'passed':25,'failed':0,'blocked':0} and cr['lower']['status']=='passed'
 artifacts={str(co/'result.json'):digest(co/'result.json')}
 for row in cr['checks']+[cr['lower']]:
  assert row['status']=='passed'
  for n,h in row.get('source_sha256',{}).items():assert digest(Path(n))==h,('compiled source changed',n)
  for key in ['outputs_sha256','published_imports_sha256','generated_sha256']:
   for n,h in row.get(key,{}).items():assert str(Path(n)).startswith(str(co)+'/') and digest(Path(n))==h;artifacts[n]=h
  n=row['log'];assert digest(Path(n))==row['log_sha256'];artifacts[n]=row['log_sha256']
 variants=[]
 for v in PLAN['variant_commands']:
  directory=Path(v['directory']);directory.mkdir(parents=True,exist_ok=False);assert v['source'] in ma and digest(Path(v['source']))==ma[v['source']]
  row=phase(v['name'],v['command']);row['source']=v['source'];row['source_sha256']=ma[v['source']];row['passed']=row['exit']==0;variants.append(row)
  if not row['passed']:
   result['status']='actual_lowering_variant_compile_failed_later_gates_blocked';(co/'variants-result.json').write_text(json.dumps({'status':'failed','checks':variants},indent=2)+'\n');save();raise SystemExit(1)
  for p in directory.rglob('*'):
   if p.is_file():artifacts[str(p)]=digest(p)
 vr=co/'variants-result.json';vr.write_text(json.dumps({'status':'passed','checks':variants,'count':4},indent=2)+'\n');artifacts[str(vr)]=digest(vr)
 seal=Path(PLAN['future_artifact_seal']);seal.write_text(json.dumps(artifacts,indent=2)+'\n');ch=digest(seal);result['qualified_fresh_artifacts']={'count':len(artifacts),'seal':str(seal),'sha256':ch};save()
 code=phase('qualification',PLAN['qualification_command'])['exit'];assert digest(seal)==ch and digest(Path(PLAN['future_macro_seal']))==mh
 for n,h in {**ma,**artifacts}.items():assert digest(Path(n))==h,('fresh artifact changed',n)
 result['status']='focused_qualification_passed_collection_unreviewed' if code==0 else 'qualification_failed_consumer_gated';result['remaining']='actual grouped payload/writer/transfer/textcallback/destruction/privatecallee/metadataTLScontextobserver interpretation then full safety/14loan/Optional/lifetime/cold/P08; no allocation acceptance';save();raise SystemExit(code)
except Exception as e:
 result.update(status='collection_failed_frozen',error=repr(e));save();raise
