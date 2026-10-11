#!/usr/bin/env python3
import pathlib, json, hashlib, shlex, subprocess, sys
ROOT=pathlib.Path(__file__).resolve().parents[6]
HERE=pathlib.Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
ledger_path=HERE/'ledger.json'
ledger=json.loads(ledger_path.read_text()) if ledger_path.exists() else dict(limit=12,used=0,unproductive=0,runs=[],historical_production_guard='2/2 unchanged',historical_investigation_guard='2/2 unchanged')
assert ledger['used']<12 and ledger['unproductive']<2
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
flags[flags.index('-module-cache-path')+1]=str(ROOT/'.build/contracts/p08-activation-resolution-cache')
n=ledger['used']+1
out=HERE/f'run-{n}';out.mkdir()
integrated = sys.argv[2] == '--integrated'
names = sys.argv[3:] if integrated else sys.argv[2:]
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

command=[str(compiler),*flags,'-module-name',module,'-emit-object',*map(str,sources),'-o',str(ROOT/'.build/contracts'/f'p08-activation-resolution-{n}.o')]
record=dict(number=n,hypothesis=sys.argv[1],command=shlex.join(command),compiler_sha256=sha(compiler),schema_receipt_sha256=sha(base/'result.json'),sources={str(p.relative_to(ROOT)):sha(p) for p in sources},status='reserved')
for p in sources:(out/p.name).write_bytes(p.read_bytes())
(out/'command.txt').write_text(record['command']+'\n')
ledger['used']=n;ledger['runs'].append(record);ledger_path.write_text(json.dumps(ledger,indent=2)+'\n')
r=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
(out/'stdout.txt').write_text(r.stdout);(out/'stderr.txt').write_text(r.stderr)
record.update(exit=r.returncode,status='completed',stdout_sha256=sha(out/'stdout.txt'),stderr_sha256=sha(out/'stderr.txt'))
(out/'result.json').write_text(json.dumps(record,indent=2)+'\n');ledger_path.write_text(json.dumps(ledger,indent=2)+'\n')
print(json.dumps(record,indent=2));print(r.stdout+r.stderr)
