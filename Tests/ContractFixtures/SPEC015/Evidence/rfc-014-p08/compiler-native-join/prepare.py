import pathlib,json,shlex,hashlib
R=pathlib.Path.cwd();H=R/'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/compiler-native-join';O=R/'.build/contracts/p08-native-6.4';O.mkdir(exist_ok=False)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
core=R/'.build/contracts/spec-006-rfc-014/189dda86d331e15d-wpk82ft7/macos-dynamic';runtime=R/'.build/contracts/spec-013-runtime-cycle/tmpke3zvfyl/macos-dynamic';host=R/'.build/contracts/p08-scoped-host-ie3r3cmc'
receipts=[core/'result.json',runtime/'result.json',host/'result.json']; ds=[json.loads(p.read_text()) for p in receipts]
setup=json.loads((H.parent/'compiler-comparison/setup-receipt.json').read_text());pkg=next(p for p in setup['packages'] if p['version']=='6.4.0');compiler=R/pkg['compiler'];assert sha(compiler)==pkg['compiler_sha256']
commands=[shlex.split(line) for line in (core/'commands.txt').read_text().splitlines() if ' -module-name GiftUI ' in line and ' -emit-object ' in line]
for d in ds[1:]:
 for c in d['commands']:
  a=shlex.split(c)
  if '-emit-module' in a and '-emit-object' in a and a[a.index('-module-name')+1] not in ('RuntimeCycleProbe','P08ScopedHostProbe'):commands.append(a)
assert len(commands)==25,len(commands)
inputs={}; plans=[]
for a in commands:
 sources=[pathlib.Path(s) for s in a if s.endswith('.swift')]
 for s in sources:
  key=str(s.relative_to(R));expected=[d['inputs'][key] for d in ds if key in d['inputs']];assert expected,key;assert all(sha(s)==v for v in expected),key;inputs[key]=sha(s)
for n in (1,2):
 d=json.loads((H.parent/f'activation-boundary/run-{n}/result.json').read_text());a=shlex.split(d['command']);commands.append(a)
 for s in [pathlib.Path(x) for x in a if x.endswith('.swift')]:
  key=str(s.relative_to(R));assert sha(s)==d['sources'][key];inputs[key]=sha(s)
for i,a in enumerate(commands,1):
 old=list(a);a[0]=str(compiler)
 for flag in ('-I','-module-cache-path','-emit-module-path','-o'):
  for j,v in enumerate(a):
   if v==flag:
    a[j+1]=str(O/('cache' if flag=='-module-cache-path' else pathlib.Path(a[j+1]).name)) if flag!='-I' else str(O)
 for j,v in enumerate(a):
  if v.endswith('.o') and (j==0 or a[j-1]!='-o'):a[j]=str(O/pathlib.Path(v).name)
 module=a[a.index('-module-name')+1];plans.append(dict(number=i,label=module if i<=25 else ('positive' if i==26 else 'callback-negative'),original_command=shlex.join(old),command=shlex.join(a)))
plugin=R/'.build/rfc014-p02/tool/debug/GiftUIMacros-tool';assert sha(plugin)==ds[0]['macro_tool_sha256']
for s,h in inputs.items():
 dest=H/'sources'/s;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes((R/s).read_bytes())
(H/'plan.json').write_text(json.dumps(dict(compiler=str(compiler),compiler_sha256=sha(compiler),reported_version=pkg['version_stdout'],receipts={str(p.relative_to(R)):sha(p) for p in receipts},macro_tool=dict(path=str(plugin),sha256=sha(plugin),usage='Existing separate host macro process via -load-plugin-executable; no compiler module or linked object reuse; macro tool not rebuilt.'),sources=inputs,plans=plans),indent=2)+'\n')
print('Prepared',len(plans),'calls;',len(inputs),'verified source inputs; no compile yet')
