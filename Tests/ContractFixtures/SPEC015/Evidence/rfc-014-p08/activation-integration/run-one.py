import pathlib,json,hashlib,shlex,subprocess,sys
R=pathlib.Path.cwd();H=R/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-integration';D=R/'Tests/ContractFixtures/SPEC015/RuntimeDerived';dep=json.loads((H/'dependencies.json').read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();mode=sys.argv[1];lp=H/'ledger.json';l=json.loads(lp.read_text()) if lp.exists() else dict(limit=12,used=0,unproductive=0,closed=False,runs=[])
assert not l['closed'] and l['used']<12 and l['unproductive']<2
assert not l['runs'] or 'disposition' in l['runs'][-1]
for s,h in dep['artifacts'].items():assert sha(pathlib.Path(s))==h,s
assert sha(pathlib.Path(dep['compiler']))==dep['compiler_sha256']
base=json.loads((H.parent/'compiler-native-join/run-26/result.json').read_text());a=shlex.split(base['command']);a=[x for x in a if not x.endswith('.o') and not (x.endswith('.swift') and '/activation-boundary/' in x)]
a[a.index('-o')+1]=str(R/'.build/contracts'/f'p08-integration-{l["used"]+1}');a[a.index('-module-cache-path')+1]=str(R/'.build/contracts/p08-integration-cache')
a += [str(D/f'ActivationJoin{n}.swift') for n in ['Owner','Report','Probe']]
a += [str(H/'Main.swift') if mode=='positive' else str(D/f'ActivationJoin{mode}Negative.swift')]
a += [s for s in dep['artifacts'] if s.endswith('.o')]
sources={str(pathlib.Path(s).relative_to(R)):sha(pathlib.Path(s)) for s in a if s.endswith('.swift')};n=l['used']+1;out=H/f'run-{n}';out.mkdir()
for s,h in sources.items():
 d=out/'sources'/s;d.parent.mkdir(parents=True,exist_ok=True);d.write_bytes((R/s).read_bytes())
r=dict(number=n,mode=mode,command=shlex.join(a),sources=sources,status='reserved');l['used']=n;l['runs'].append(r);lp.write_text(json.dumps(l,indent=2)+'\n');(out/'command.txt').write_text(r['command']+'\n');p=subprocess.run(a,capture_output=True,text=True);(out/'stdout.txt').write_text(p.stdout);(out/'stderr.txt').write_text(p.stderr);r.update(exit=p.returncode,status='complete',stdout_sha256=sha(out/'stdout.txt'),stderr_sha256=sha(out/'stderr.txt'))
if p.returncode==0:
 binary=pathlib.Path(a[a.index('-o')+1]);r['executable_sha256']=sha(binary)
 if mode=='positive':
  e=subprocess.run([str(binary)],capture_output=True,text=True);(out/'execution-stdout.txt').write_text(e.stdout);(out/'execution-stderr.txt').write_text(e.stderr);r['execution_exit']=e.returncode
(out/'result.json').write_text(json.dumps(r,indent=2)+'\n');lp.write_text(json.dumps(l,indent=2)+'\n');print(json.dumps({k:r[k] for k in ['number','mode','exit']}));print(p.stdout+p.stderr)
