"""Validate and preserve the bounded production software-input observations."""
from pathlib import Path
import hashlib,json,re,tarfile
root=Path.cwd();source=root/'.build/nrf52840/iteration-002-followup';out=root/'docs/iterations/iteration-002-review/evidence'
cases={}
for label,actions in [('window-one',[0,3,4]),('window-two',[0,3,5]),('window-five',[0,4,5]),('disabled-plus',[0,4,5]),('movement-cancel',[0,3,5]),('stale-revision',[0,3,5])]:
 text=(source/(label+'.log')).read_text()
 b=re.search(r'BEFORE .* revision=(\d+) point=(\d+) enabled=(\d+)',text)
 a=re.search(r'AFTER .* revision=(\d+) state=(\d+) pending=(\d+) capture=(\d+) actions=(\d+),(\d+),(\d+)',text)
 assert a and b and re.search(r'\$\d+ = \{0, 0, 0, 0, 0\}',text)
 before=list(map(int,b.groups()));after=list(map(int,a.groups()))
 assert after[1:4]==[2,0,8] and after[4:]==actions
 assert after[0]==before[0]+int(label.startswith('window-'))
 assert '0x00000000\t0x00000000\t' in text
 admits=list(map(int,re.findall(r'\$\d+ = (\d+)\n',text)))
 assert admits==([258]*2 if label=='stale-revision' else [255]*(3 if label=='movement-cancel' else 2))
 if label=='disabled-plus':assert before[2]==0 and before[1]>0
 cases[label]=dict(before_revision=before[0],point=before[1],enabled_point=before[2],revision=after[0],state=after[1],pending=after[2],capture_count=after[3],published_action_codes=after[4:],admission_codes=admits)
for label,state,rev in [('quiescent-start',1,2),('quiescent-stop',2,6)]:
 text=(source/(label+'.log')).read_text()
 after=text.split('QUIESCENT SERVICE BOUNDARY AFTER')[-1]
 values=list(map(int,re.findall(r'\$\d+ = (\d+)\n',after)))
 assert values[:3]==[state,rev,0]
 cases[label]=dict(acquisition_state=state,revision=rev,pending=0,scope='See raw typed GDB output; no physical contact claim')
paths=sorted(p for p in source.iterdir() if p.suffix in ('.gdb','.log'))
archive=out/'25-quiescent-input-logs.tar.gz'
with tarfile.open(archive,'w:gz') as tar:
 for p in paths:tar.add(p,arcname=p.name)
record=dict(elf_sha256='c6d0f12c8585cad3f3949fb596e13fa7328989239a31a1f6e428afadb541ed5c',probe_serial='683833660',cases=cases,archive_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),files={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},excluded=['Unlinked hit_point getter attempt; enabled action_point used instead; disabled control uses its prior enabled point.','quiescent-clear has no UI hit target, then asks for an unlinked visible_window getter; not a Clear test.'],limits='Software input at production service entry; no independent full trace, physical provenance, overlapping disabled fixture or exact-once dispatch count.')
(out/'25-quiescent-input.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(cases,indent=2))
