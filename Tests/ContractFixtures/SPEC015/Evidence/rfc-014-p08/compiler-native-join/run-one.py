import pathlib,json,hashlib,shlex,subprocess
H=pathlib.Path(__file__).resolve().parent;R=H.parents[5];sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
plan=json.loads((H/'plan.json').read_text());lp=H/'ledger.json';l=json.loads(lp.read_text()) if lp.exists() else dict(limit=32,used=0,command_corrections=0,closed=False,runs=[])
assert not l['closed'] and l['used']<32
assert not l['runs'] or l['runs'][-1]['exit']==0
assert sha(pathlib.Path(plan['compiler']))==plan['compiler_sha256']
p=plan['plans'][l['used']];a=shlex.split(p['command']);sources={s:plan['sources'][str(pathlib.Path(s).relative_to(R))] for s in a if s.endswith('.swift')}
for s,h in sources.items():assert sha(pathlib.Path(s))==h
for i,v in enumerate(a):
 if v=='-I':assert a[i+1]==str(R/'.build/contracts/p08-native-6.4')
 if v.endswith('.o') and a[i-1]!='-o':assert pathlib.Path(v).exists() and pathlib.Path(v).parent==R/'.build/contracts/p08-native-6.4'
rd=H/f"run-{p['number']}";rd.mkdir();(rd/'command.txt').write_text(p['command']+'\n');rec=dict(p,status='reserved',sources=sources);l['runs'].append(rec);l['used']+=1;lp.write_text(json.dumps(l,indent=2)+'\n')
r=subprocess.run(a,cwd=R,capture_output=True,text=True);(rd/'stdout.txt').write_text(r.stdout);(rd/'stderr.txt').write_text(r.stderr);rec.update(status='complete',exit=r.returncode,stdout_sha256=sha(rd/'stdout.txt'),stderr_sha256=sha(rd/'stderr.txt'))
if r.returncode==0:
 rec['artifacts']={a[i+1]:sha(pathlib.Path(a[i+1])) for i,v in enumerate(a) if v in ('-o','-emit-module-path')}
 if p['label']=='positive':
  exe=subprocess.run([a[a.index('-o')+1]],cwd=R,capture_output=True,text=True);(rd/'execution-stdout.txt').write_text(exe.stdout);(rd/'execution-stderr.txt').write_text(exe.stderr);rec['execution_exit']=exe.returncode;rec['execution_stdout_sha256']=sha(rd/'execution-stdout.txt');rec['execution_stderr_sha256']=sha(rd/'execution-stderr.txt')
if r.returncode!=0 or p['label']=='callback-negative':l['closed']=True
(rd/'result.json').write_text(json.dumps(rec,indent=2)+'\n');lp.write_text(json.dumps(l,indent=2)+'\n');print(json.dumps(dict(number=p['number'],label=p['label'],exit=r.returncode,execution_exit=rec.get('execution_exit'))));print(r.stdout+r.stderr)
