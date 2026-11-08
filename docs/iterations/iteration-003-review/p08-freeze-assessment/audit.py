#!/usr/bin/env python3
"""Bounded read-only receipt/input audit; no compiler, runtime or target execution."""
import hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
 return h.hexdigest()
def match(path,expected):
 p=ROOT/path
 actual=sha(p) if p.is_file() else None
 return {'path':str(path),'expected':expected,'actual':actual,'match':actual==expected}
receipts=['.build/contracts/p08-counter-g8ocpi1a/result.json','.build/contracts/p08-counter-7f4ij74w/result.json','.build/raspberry-pi/contracts/p08-counter-k02awr3h/result.json','.build/nrf52840/contracts/p08-counter-7pxb5h5m/result.json']
out={'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'scope':'Input/receipt integrity only; not a full artifact or semantic applicability verifier','receipts':[]}
for name in receipts:
 p=ROOT/name;d=json.loads(p.read_text());inputs=[match(k,v) for k,v in d['inputs'].items()]
 artifact_failures=[]
 for key,value in d['artifacts'].items():
  artifact=p.parent/key
  if not artifact.is_file() or sha(artifact)!=value['sha256'] or artifact.stat().st_size!=value['bytes']:
   artifact_failures.append(key)
 pre=[]
 for field in ['runtime','host']:
  path=Path(d[field+'_build'])/'result.json';pre.append(match(path,d[field+'_receipt_sha256']))
 out['receipts'].append({'path':name,'sha256':sha(p),'profile':d['profile'],'collection_complete':d['collection_complete'],'passed':d['passed'],'checks':len(d['checks']),'passing_checks':sum(c['passed'] for c in d['checks']),'inputs':inputs,'compiler':match(d['compiler'],d['compiler_sha256']),'prerequisites':pre,'declared_artifact_count':len(d['artifacts']),'artifact_validation':{'checked':len(d['artifacts']),'failures':artifact_failures}})
changed=subprocess.check_output(['git','diff','--name-only','HEAD','--','Sources','Tests/ContractFixtures/SPEC015','scripts','Package.swift','CMakeLists.txt','firmware'],cwd=ROOT,text=True).splitlines()
untracked=subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','Sources','Tests/ContractFixtures/SPEC015/RuntimeDerived','Tests/ContractFixtures/SPEC015/AllocationGate','scripts','firmware'],cwd=ROOT,text=True).splitlines()
out['dirty_inputs']=[{'path':p,'sha256':sha(ROOT/p) if (ROOT/p).is_file() else None,'untracked':p in untracked} for p in sorted(set(changed+untracked)) if '__pycache__' not in p]
base=ROOT/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage'
evidence=['pi-current-stack-analysis-2026-11-07/callback21-freeze-session-handoff.md','pi-current-stack-analysis-2026-11-07/callback21-freeze-session-handoff-independent-review.md','p08-native-closure-2026-11-07/native-assessment.md','p08-native-closure-2026-11-07/native-assessment-review.md','dynamic-allocator-private-accounting-2026-11-07/README.md']
out['reviewed_documents']=[{'path':str((base/p).relative_to(ROOT)),'sha256':sha(base/p)} for p in evidence]
print(json.dumps(out,indent=2))
