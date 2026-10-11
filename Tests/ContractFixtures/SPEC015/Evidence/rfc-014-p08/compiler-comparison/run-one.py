#!/usr/bin/env python3
import pathlib,json,hashlib,shlex,subprocess,sys
ROOT=pathlib.Path(__file__).resolve().parents[6]
HERE=pathlib.Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
version,control=sys.argv[1:]
assert version in ('6.3.3','6.4.0') and control in ('positive','wrapped-negative','span-negative')
ledger_path=HERE/'ledger.json'
ledger=json.loads(ledger_path.read_text()) if ledger_path.exists() else dict(limit=6,used=0,runs=[],closed_versions=[],closed=False)
assert not ledger['closed'] and version not in ledger['closed_versions'] and ledger['used']<6
assert not ledger['runs'] or 'disposition' in ledger['runs'][-1]
assert not any(r['version_label']==version and r['control']==control for r in ledger['runs'])
if control!='positive':assert any(r['version_label']==version and r['control']=='positive' and r['exit']==0 for r in ledger['runs'])
setup=json.loads((HERE/'setup-receipt.json').read_text())
verified=json.loads((HERE/'verified-inputs.json').read_text())
assert sha(HERE/'setup-receipt.json')==verified['setup_receipt_sha256']
pkg=next(p for p in setup['packages'] if p['version']==version)
compiler=ROOT/pkg['compiler'];assert sha(compiler)==pkg['compiler_sha256']
frozen={'positive':('activation-receiver',1),'wrapped-negative':('activation-receiver',2),'span-negative':('activation-extraction',1)}
folder,old_number=frozen[control]
old=HERE.parent/folder/f'run-{old_number}'
receipt=json.loads((old/'result.json').read_text())
command=shlex.split(receipt['command'])
sources=[pathlib.Path(p) for p in command if p.endswith('.swift')]
for source in sources:
 assert sha(source)==receipt['sources'][str(source.relative_to(ROOT))]
 assert not any(line.startswith('import ') or line.startswith('@testable import ') for line in source.read_text().splitlines()),'comparison sources must remain Swift-only'
assert not any(p.endswith('.o') for p in command),'no GiftUI object reuse'
number=ledger['used']+1
out=HERE/f'run-{number}';out.mkdir()
command[0]=str(compiler)
command[command.index('-module-cache-path')+1]=str(ROOT/'.build/contracts'/f'p08-compiler-comparison-{version}-cache')
output=ROOT/'.build/contracts'/f'p08-compiler-comparison-{version}-{control}'
command[command.index('-o')+1]=str(output)
record=dict(number=number,version_label=version,reported_version=pkg['version_stdout'],control=control,command=shlex.join(command),compiler_sha256=sha(compiler),package_sha256=pkg['package_sha256'],frozen_receipt_sha256=sha(old/'result.json'),sources={str(p.relative_to(ROOT)):sha(p) for p in sources},status='reserved')
for source in sources:(out/source.name).write_bytes(source.read_bytes())
(out/'command.txt').write_text(record['command']+'\n')
ledger['used']=number;ledger['runs'].append(record);ledger_path.write_text(json.dumps(ledger,indent=2)+'\n')
r=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
(out/'stdout.txt').write_text(r.stdout);(out/'stderr.txt').write_text(r.stderr)
record.update(exit=r.returncode,status='completed',stdout_sha256=sha(out/'stdout.txt'),stderr_sha256=sha(out/'stderr.txt'))
if r.returncode==0:record['executable_sha256']=sha(output)
(out/'result.json').write_text(json.dumps(record,indent=2)+'\n');ledger_path.write_text(json.dumps(ledger,indent=2)+'\n')
print(json.dumps(dict(number=number,version=version,control=control,exit=r.returncode,used=ledger['used'])));print(r.stdout+r.stderr)
