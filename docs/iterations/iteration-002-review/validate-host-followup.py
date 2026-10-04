"""Validate this follow-up's saved evidence without accessing either device."""
from pathlib import Path
import ast,datetime,hashlib,json,re,subprocess,tarfile
root=Path.cwd();review=root/'docs/iterations/iteration-002-review';spike=root/'experiments/spike-013-connected-host-followup/evidence'
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
record={'revision':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'source_baseline':'6cf31f266987e917458f31f05ed8c390cda9a202','checks':{},'utc':datetime.datetime.now(datetime.timezone.utc).isoformat()}
paths=['Sources','Tests','firmware','scripts','Package.swift','demo','.agents','skills']
assert not subprocess.check_output(['git','diff','--name-only',record['source_baseline'],'--',*paths],text=True).strip()
record['checks']['maintained_inputs_unchanged']=paths
assert digest(review/'evidence/11-validation-logs.tar.gz')=='b97efdfec757fdeaed82e542a12edde021fa47b49f16d9ea156c36857a1c60d8'
record['checks']['production_gate_archive_unchanged']=True
# Verify new immutable archives against the recorded file manifests.
input_record=json.loads((review/'evidence/25-quiescent-input.json').read_text())
archive=review/'evidence/25-quiescent-input-logs.tar.gz';assert digest(archive)==input_record['archive_sha256']
with tarfile.open(archive) as tar:
 for name,sha in input_record['files'].items():assert hashlib.sha256(tar.extractfile(name).read()).hexdigest()==sha
record['checks']['step25_archive']=digest(archive)
archives=json.loads((spike/'nrf-archives.json').read_text())
for mode in ('normal','refusal'):
 result=json.loads((spike/(mode+'.json')).read_text());archive=spike/(mode+'-logs.tar.gz')
 assert digest(archive)==archives[mode]['archive_sha256']
 with tarfile.open(archive) as tar:
  for name,sha in result['files'].items():assert hashlib.sha256(tar.extractfile('connected/'+name).read()).hexdigest()==sha
  assert hashlib.sha256(tar.extractfile('zephyr.hex').read()).hexdigest()==archives[mode]['hex_sha256']
 assert result['cfsr_hfsr']==[0,0] and all(v==0 for name in ('retired_revision','retired_pending','retired_needs','retired_touch_valid') for v in result[name])
 assert result['resource']['ram_bytes']<=196608 and digest(root/result['resource']['elf'])==result['elf_sha256']
 record['checks'][mode+'_archive']=digest(archive)
for name in ('preparation.json','pi-preparation.json'):
 data=json.loads((spike/name).read_text())
 for relative,sha in data['inputs'].items():assert digest(root/relative)==sha,relative
record['checks']['preparation_inputs_match']=True
pi=json.loads((spike/'pi-prepared.json').read_text());assert pi['status']=='blocked'
archive=spike/'pi-preparation-logs.tar.gz';assert digest(archive)==pi['archive_sha256']
with tarfile.open(archive) as tar:
 for name,sha in pi['files'].items():assert hashlib.sha256(tar.extractfile(name).read()).hexdigest()==sha
assert digest(root/'.build/raspberry-pi/artifacts/SignalAnalyzerPiResearch')==pi['identity']['binary_sha256']
record['pi']={'status':'measurement_blocked','preparation_verified':True,'blocker':pi['blocker'],'final_remote_state_unavailable':True}
# Verify this campaign's restored original image and nonhalting ready snapshot.
elf=root/'.build/nrf52840/signal-analyzer-static/zephyr/zephyr.elf'
assert digest(elf)=='c6d0f12c8585cad3f3949fb596e13fa7328989239a31a1f6e428afadb541ed5c'
ready=root/'.build/nrf52840/iteration-002-connected/step-28-production-ready';text=(ready/'monitor.log').read_text()
revisions=[int(row.split()[2],16) for row in re.findall(r'200009C0 = ([A-F0-9 ]+)',text)]
assert len(revisions)==10 and set(revisions)=={1}
for pattern in (r'E000ED28 = ([A-F0-9 ]+)',r'200273(?:00|10) = ([A-F0-9 ]+)'):
 rows=re.findall(pattern,text);assert rows and all(int(w,16)==0 for row in rows for w in row.split()[:2 if pattern.startswith('E') else 4])
assert 'E000EDF0 = 01010001' in text
record['nrf']={'elf_sha256':digest(elf),'probe_serial':'683833660','ready_revision':1,'samples':10,'cfsr_hfsr':[0,0],'driver_faults':[0]*5,'running_dhcsr':True}
process_log=root/'.build/nrf52840/iteration-002-final-restoration/process-final.log'
assert not process_log.read_text().strip()
record['checks']['local_debugger_upload_processes']=[]
# Documentation/syntax/governance checks do not relabel a hardware criterion.
names=subprocess.check_output(['git','diff','--name-only','cabb826c','--','docs'],text=True).splitlines()
names+=subprocess.check_output(['git','ls-files','--others','--exclude-standard'],text=True).splitlines()
pending={review/'evidence/28-host-followup-validation.json',review/'evidence/28-host-restoration-logs.tar.gz'};links=0
for name in sorted(set(names)):
 p=root/name
 if p.suffix!='.md':continue
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  target=target.strip('<>').split('#')[0]
  if not target or re.match(r'[a-z]+:',target):continue
  dest=(p.parent/target).resolve();assert dest.exists() or dest in pending,(name,target);links+=1
record['checks']['local_links']=links
python=list((root/'experiments/spike-013-connected-host-followup').glob('*.py'))+list(review.glob('*quiescent*.py'))+[review/'run-nrf-connected-gdb.py',Path(__file__)]
for p in python:ast.parse(p.read_text())
record['checks']['python_syntax_files']=len(python)
for label,cmd in [('shell',['bash','-n',str(review/'build-research-firmware.sh')]),('whitespace',['git','diff','--check']),('format',['scripts/format-swift.sh']),('governance',['ruby','scripts/governance/build-authority-graph.rb'])]:
 result=subprocess.run(cmd,capture_output=True,text=True);assert result.returncode==0,result.stdout+result.stderr
 record['checks'][label]={'exit_code':result.returncode,'output':result.stdout+result.stderr}
archive=review/'evidence/28-host-restoration-logs.tar.gz';files=[process_log,root/'.build/nrf52840/iteration-002-final-restoration/flash.log',*sorted(ready.iterdir()),root/'.build/raspberry-pi/spike-013/preflight.log',root/'.build/raspberry-pi/spike-013/resumption-attempt.log']
with tarfile.open(archive,'w:gz') as tar:
 for p in files:tar.add(p,arcname=str(p.relative_to(root/'.build')))
record['archive']={'sha256':digest(archive),'files':{str(p.relative_to(root/'.build')):digest(p) for p in files}}
(review/'evidence/28-host-followup-validation.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({'nrf':record['nrf'],'pi':record['pi'],'checks':list(record['checks'])},indent=2))
