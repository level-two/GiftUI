"""Verify saved connected research/restoration without accessing hardware."""
from pathlib import Path
import datetime,hashlib,json,re,struct,subprocess,tarfile
root=Path.cwd();out=root/'.build/nrf52840/iteration-002-connected'
record={'revision':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),
 'source_baseline':'6cf31f266987e917458f31f05ed8c390cda9a202','checks':{}}
source_paths=['Sources','Tests','firmware','scripts','Package.swift','demo','.agents','skills']
changed=subprocess.check_output(['git','diff','--name-only',record['source_baseline'],'--',*source_paths],text=True).splitlines()
assert not changed,changed;record['checks']['maintained_inputs_unchanged']=source_paths
baseline=root/'docs/iterations/iteration-002-review/evidence/11-validation-logs.tar.gz'
assert hashlib.sha256(baseline.read_bytes()).hexdigest()=='b97efdfec757fdeaed82e542a12edde021fa47b49f16d9ea156c36857a1c60d8'
record['checks']['original_72_check_archive_sha256']=hashlib.sha256(baseline.read_bytes()).hexdigest()
for path in (root/'docs/iterations/iteration-002-review/evidence/22-connected-baseline.json',
 root/'experiments/spike-012-connected-hierarchy-costs/evidence/summary.json'):
 data=json.loads(path.read_text());archive=data['archive'];archive_path=root/archive['path']
 assert hashlib.sha256(archive_path.read_bytes()).hexdigest()==archive['sha256']
 with tarfile.open(archive_path) as tar:
  for name,digest in archive['files'].items():assert hashlib.sha256(tar.extractfile(name).read()).hexdigest()==digest
 record['checks'][str(path.relative_to(root))]=archive['sha256']
# Check PC/SP on both sides of each paint against that exact ELF's vector table.
paints={}
for mode in ('packed','roles','snapshot'):
 data=json.loads((root/f'experiments/spike-012-connected-hierarchy-costs/evidence/{mode}.json').read_text())
 elf=(root/data['elf']).read_bytes();phoff=struct.unpack_from('<I',elf,28)[0]
 entsize,count=struct.unpack_from('<HH',elf,42)
 vector=None
 for i in range(count):
  typ,offset,vaddr,paddr,filesz,memsz,flags,align=struct.unpack_from('<8I',elf,phoff+i*entsize)
  if typ==1 and vaddr==0 and filesz>=8:vector=struct.unpack_from('<II',elf,offset)
 assert vector is not None
 log=(root/f'.build/nrf52840/spike-012-connected-{mode}/connected/paint.log').read_text()
 before,after=log.split('J-Link>loadbin ',1)
 prepc=int(re.findall(r'PC = ([A-F0-9]{8})',before)[-1],16)
 postpc=int(re.findall(r'PC = ([A-F0-9]{8})',after)[-1],16)
 presp=int(re.findall(r'SP\(R13\)= ([A-F0-9]{8})',before)[-1],16)
 postsp=int(re.findall(r'SP\(R13\)= ([A-F0-9]{8})',after)[-1],16)
 assert prepc==postpc==vector[1]&~1 and presp==postsp==vector[0]
 assert before.count('E000EDF0 = 00030003')==1 and after.count('E000EDF0 = 00030003')==1
 paints[mode]=dict(vector_sp=vector[0],reset_pc=vector[1]&~1,prepaint_pc=prepc,postpaint_pc=postpc)
record['checks']['paint_registers_match_each_elf_vectors']=paints
# Original production image was restored and is running/ready in nonhalting reads.
elf=root/'.build/nrf52840/signal-analyzer-static/zephyr/zephyr.elf'
assert hashlib.sha256(elf.read_bytes()).hexdigest()=='c6d0f12c8585cad3f3949fb596e13fa7328989239a31a1f6e428afadb541ed5c'
log=(out/'production-restored-ready/monitor.log').read_text();cpu=[];faults=[]
revisions=[int(m.split()[2],16) for m in re.findall(r'200009C0 = ([A-F0-9 ]+)',log)]
for values in re.findall(r'E000ED28 = ([A-F0-9 ]+)',log):cpu.extend(int(v,16) for v in values.split()[:2])
for values in re.findall(r'200273(?:00|10) = ([A-F0-9 ]+)',log):faults.extend(int(v,16) for v in values.split())
assert revisions[-1]==1 and set(cpu)=={0} and set(faults)=={0} and 'E000EDF0 = 01010001' in log
record['restoration']={'nrf_elf_sha256':hashlib.sha256(elf.read_bytes()).hexdigest(),
 'nrf_ready_revision':revisions[-1],'sample_count':len(revisions),'driver_fault_values':sorted(set(faults)),
 'cfsr_hfsr_values':sorted(set(cpu)),'running_dhcsr_observed':True,
 'pi':{'architecture':'armv6l','binary_sha256':'acf57db5625eb1d2802210aaa6e30128749277d81ad26a3f313b79f8448d8d7e',
 'application_processes':[],'verification':'Final SSH uname/hash/ps inspection reported these values; no remote service changed.'},
 'debug_processes':[],'process_verification':'Final local ps showed no J-Link/GDB process from this campaign.'}
# The pinned Zephyr formulas establish the single-thread stack buffer/end convention.
stack_sources=['.toolchains/nrf52840/workspace/zephyr/arch/arm/core/cortex_m/thread.c',
 '.toolchains/nrf52840/workspace/zephyr/include/zephyr/kernel/thread_stack.h']
record['checks']['pinned_stack_formula_sources']={p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in stack_sources}
assert 'K_THREAD_STACK_BUFFER(z_main_stack) + K_THREAD_STACK_SIZEOF(z_main_stack)' in (root/stack_sources[0]).read_text()
# Current documentation links and guards.
changed_docs=subprocess.check_output(['git','diff','--name-only','HEAD','--','docs'],text=True).splitlines()
changed_docs+=['docs/iterations/iteration-002-review/24-connected-reconciliation.md',
 'docs/iterations/iteration-002-review/22-connected-baseline.md', 'docs/iterations/iteration-002-review/23-connected-hierarchy-candidates.md',
 'docs/spikes/spike-012-connected-hierarchy-costs.md']
links=0
pending_outputs={root/'docs/iterations/iteration-002-review/evidence/24-connected-closeout.json',root/'docs/iterations/iteration-002-review/evidence/24-restoration-logs.tar.gz'}
for name in sorted(set(changed_docs)):
 p=root/name
 if p.suffix!='.md':continue
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  target=target.split('#')[0]
  if not target or re.match(r'[a-z]+:',target):continue
  target=target.strip('<>');resolved=(p.parent/target).resolve();assert resolved.exists() or resolved in pending_outputs,(name,target);links+=1
record['checks']['local_links_checked']=links
for label,command in [('python_syntax',['python3','-c',"import ast,pathlib; paths=list(pathlib.Path('experiments/spike-012-connected-hierarchy-costs').glob('*.py'))+list(pathlib.Path('docs/iterations/iteration-002-review').glob('*connected*.py')); [ast.parse(p.read_text()) for p in paths]"]),
 ('shell_syntax',['bash','-n','docs/iterations/iteration-002-review/build-research-firmware.sh']),
 ('diff_whitespace',['git','diff','--check']),('governance',['ruby','scripts/governance/build-authority-graph.rb'])]:
 result=subprocess.run(command,capture_output=True,text=True);assert result.returncode==0,result.stdout+result.stderr
 record['checks'][label]={'exit_code':result.returncode,'output':result.stdout+result.stderr}
archive=root/'docs/iterations/iteration-002-review/evidence/24-restoration-logs.tar.gz';manifest={}
files=[out/'production-restored-flash.log',out/'format.log']
for label in ('production-restored-startup','production-restored-ready'):files+=sorted((out/label).glob('*'))
with tarfile.open(archive,'w:gz') as tar:
 for path in files:
  name=str(path.relative_to(root/'.build'));manifest[name]=hashlib.sha256(path.read_bytes()).hexdigest();tar.add(path,arcname=name)
record['archive']={'path':str(archive.relative_to(root)),'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'files':manifest}
record['validated_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat()
(root/'docs/iterations/iteration-002-review/evidence/24-connected-closeout.json').write_text(json.dumps(record,indent=2)+'\n')
assert all(p.is_file() for p in pending_outputs)
print(json.dumps({'restoration':record['restoration'],'checks':record['checks']},indent=2))
