#!/usr/bin/env python3
import pathlib, json, hashlib, shlex, subprocess, sys
ROOT=pathlib.Path(__file__).resolve().parents[6]
HERE=pathlib.Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
ledger_path=HERE/'ledger.json'
ledger=json.loads(ledger_path.read_text()) if ledger_path.exists() else dict(limit=8,used=0,unproductive=0,runs=[],historical_production_guard='2/2 unchanged',historical_investigation_guard='2/2 unchanged')
assert not ledger.get('closed'), 'closed corrective candidate; unused numerical allowance is not continuation authority'
assert ledger['used']<8 and ledger['unproductive']<2
assert not ledger['runs'] or 'disposition' in ledger['runs'][-1], 'classify previous run before next compiler invocation'
base=ROOT/'.build/contracts/p08-scoped-host-ie3r3cmc'
prior=json.loads((base/'result.json').read_text())
verified=json.loads((HERE.parent/'activation-join-investigation/verified-inputs.json').read_text())
assert sha(base/'result.json')==verified['schema_receipt_sha256']
for name,expected in prior['inputs'].items(): assert sha(ROOT/name)==expected,name
for name,expected in prior['artifacts'].items(): assert sha(base/name)==expected['sha256'],name
original=next(shlex.split(c) for c in prior['commands'] if '-module-name P08ScopedHostProbe ' in c)
compiler=pathlib.Path(original[0]);assert sha(compiler)==verified['compiler_sha256']
flags=original[1:original.index('-module-name')]
flags[flags.index('-module-cache-path')+1]=str(ROOT/'.build/contracts/p08-activation-fence-cache')
n=ledger['used']+1
out=HERE/f'run-{n}';out.mkdir()
integrated = True
link = sys.argv[2] == '--link'
names = sys.argv[3:]
sources=[HERE/x for x in names]
module='P08ActivationResolution'
if integrated:
    runtime=ROOT/prior['runtime_build']
    receipt=json.loads((runtime/'result.json').read_text())
    assert sha(runtime/'result.json')==verified['runtime_receipt_sha256']
    for name, expected in receipt['inputs'].items(): assert sha(ROOT/name)==expected, name
    for name, expected in receipt['artifacts'].items(): assert sha(runtime/name)==expected['sha256'], name
    runtime_command=next(shlex.split(c) for c in receipt['commands'] if '-module-name RuntimeCycleProbe ' in c)
    sources=[(HERE/'overlays'/pathlib.Path(p).name) if (HERE/'overlays'/pathlib.Path(p).name).exists() else pathlib.Path(p) for p in runtime_command if p.endswith('.swift')]+sources
    module='RuntimeCycleProbe'

objects=[]
if link:
    link_command=next(shlex.split(c) for c in receipt['commands'] if ' -o ' in c and '-emit-' not in c)
    objects=[p for p in link_command if p.endswith('.o') and not p.endswith('/RuntimeCycleProbe.o')]
output=ROOT/'.build/contracts'/f'p08-activation-fence-{n}'
if not link: output=output.with_suffix('.o')
command=[str(compiler),*flags,'-module-name',module,*([] if link else ['-emit-object']),*map(str,sources),*objects,'-o',str(output)]
record=dict(number=n,hypothesis=sys.argv[1],command=shlex.join(command),compiler_sha256=sha(compiler),schema_receipt_sha256=sha(base/'result.json'),sources={str(p.relative_to(ROOT)):sha(p) for p in sources},link_objects={str(pathlib.Path(p).relative_to(ROOT)):sha(pathlib.Path(p)) for p in objects},status='reserved')
for p in sources:(out/p.name).write_bytes(p.read_bytes())
(out/'command.txt').write_text(record['command']+'\n')
ledger['used']=n;ledger['runs'].append(record);ledger_path.write_text(json.dumps(ledger,indent=2)+'\n')
r=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
(out/'stdout.txt').write_text(r.stdout);(out/'stderr.txt').write_text(r.stderr)
record.update(exit=r.returncode,status='completed',stdout_sha256=sha(out/'stdout.txt'),stderr_sha256=sha(out/'stderr.txt'))
(out/'result.json').write_text(json.dumps(record,indent=2)+'\n');ledger_path.write_text(json.dumps(ledger,indent=2)+'\n')
print(json.dumps(dict(number=n,exit=r.returncode,used=ledger['used'],command_file=str(out/'command.txt'))));print(r.stdout+r.stderr)
