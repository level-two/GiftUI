#!/usr/bin/env python3
"""Read-only evidence verification. Does not compile, link, or execute fixtures."""
import hashlib
import json
from pathlib import Path
import re
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
E = HERE / 'evidence'
BIN = ROOT / '.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin'
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def inspect(label, args):
    p = subprocess.run([str(a) for a in args], cwd=ROOT, text=True, capture_output=True, check=True)
    path = E / (label + '.log')
    path.write_text(p.stdout + p.stderr)
    return {'command':[str(a) for a in args], 'log':str(path.relative_to(ROOT)), 'sha256':sha(path)}

ledger = json.loads((E/'ledger.json').read_text())
result = {'invocations':len(ledger['trials']), 'source_snapshots_verified':True, 'artifacts':{}, 'native':{}, 'inspections':{}}
assert len(ledger['trials']) == 11
for trial in ledger['trials']:
    path = ROOT / trial['log']
    assert sha(path) == trial['log_sha256']
    for name, digest in trial['inputs'].items():
        if name.endswith('.swift'):
            assert sha(E / 'inputs' / (digest + '.swift.txt')) == digest
    if trial['exit_code'] == 0 and '-o' in trial['command']:
        artifact = Path(trial['command'][trial['command'].index('-o')+1])
        result['artifacts'][str(artifact.relative_to(ROOT))] = {'sha256':sha(artifact),'file_bytes':artifact.stat().st_size}
    if trial['label'].startswith('execute-'):
        log=path.read_text()
        passed=re.findall(r'^([a-z-]+) PASS$',log,re.M)
        assert len(passed)==21 and 'FAIL' not in log
        result['native'][trial['label']]={'passed':passed, 'layout':dict(re.findall(r'^([a-z-]+-stride) ([0-9]+)$',log,re.M))}
assert [t['number'] for t in ledger['trials'] if t['status']=='unexpected']==[4,5,11]
for operation,args in [('attributes',['-A']),('symbols',['-a']),('relocations',['-rW'])]:
    executable='nm' if operation=='symbols' else 'readelf'
    result['inspections']['pi-'+operation]=inspect('pi-'+operation,[BIN/('arm-zephyr-eabi-'+executable),*args,ROOT/'.build/raspberry-pi/spike-070/positive.o'])
attrs=(E/'pi-attributes.log').read_text()
assert 'Tag_CPU_arch: v6' in attrs and 'Tag_ABI_VFP_args: VFP registers' in attrs
for script in ['raspberry-pi','nrf52840']:
    result['inspections'][script+'-doctor']=inspect(script+'-doctor',[ROOT/'scripts'/script/'doctor.sh'])
result['nrf_resource_inspection']='Not run: positive compilation failed; no nRF object or rooted image exists.'
result['escape_controls']='Not run: repair limit exhausted at nRF positive; no SPIKE-070 compiler-negative evidence.'
(E/'inspection.json').write_text(json.dumps(result,indent=2)+'\n')
print('Verified all 11 trial logs/source snapshots, 42 native checks, ARMv6/VFP attributes and toolchain inventory.')
