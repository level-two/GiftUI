#!/usr/bin/env python3
"""Verify preserved evidence and inspect objects; no compiler/link/fixture execution."""
import hashlib
import json
from pathlib import Path
import re
import subprocess

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
E=HERE/'evidence'
BIN=ROOT/'.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def inspect(label,args):
    result=subprocess.run([str(a) for a in args],cwd=ROOT,text=True,capture_output=True,check=True)
    path=E/(label+'.log');path.write_text(result.stdout+result.stderr)
    return {'command':[str(a) for a in args],'log':str(path.relative_to(ROOT)),'sha256':sha(path)},result.stdout
ledger=json.loads((E/'ledger.json').read_text())
summary={'invocations':len(ledger['trials']),'source_snapshots_verified':True,'artifacts':{},'native':{},'negative_diagnostics':[],'inspections':{}}
for t in ledger['trials']:
    path=ROOT/t['log'];assert sha(path)==t['log_sha256']
    for name,digest in t['inputs'].items():
        if name.endswith('.swift'):assert sha(E/'inputs'/(digest+'.swift.txt'))==digest
    assert t['status']=='expected',t['label']
    if t['expected']=='rejection':
        errors=[s.split('error:',1)[1].strip() for s in path.read_text().splitlines() if 'error:' in s and not s.lstrip().startswith('|')]
        assert t['exit_code']!=0 and errors
        assert any(word in '\n'.join(errors) for word in t['diagnostic'])
        summary['negative_diagnostics'].append({'trial':t['number'],'label':t['label'],'errors':errors,'superseded_control':t['label'].startswith('escape_helper-')})
        if t['label'].startswith('corrected-escape-helper'):
            assert len(errors)==1 and errors[0]=='lifetime-dependent value escapes its scope'
    if t['exit_code']==0 and '-o' in t['command']:
        artifact=Path(t['command'][t['command'].index('-o')+1]);assert artifact.exists()
        summary['artifacts'][str(artifact.relative_to(ROOT))]={'sha256':sha(artifact),'file_bytes':artifact.stat().st_size}
    if t['label'].startswith('execute-'):
        log=path.read_text();passed=re.findall(r'^([a-z-]+) PASS$',log,re.M)
        assert len(passed)==21 and 'FAIL' not in log
        summary['native'][t['label']]={'passed':passed,'layout':dict(re.findall(r'^([a-z-]+-stride) ([0-9]+)$',log,re.M))}
assert len(summary['negative_diagnostics'])==28
assert sum(not row['superseded_control'] for row in summary['negative_diagnostics'])==24
base=ROOT/'.build/nrf52840/spike-071'
for name in ['positive.o','sectioned-positive.o','reachable.o']:
    for operation,tool,flags in [('symbols','nm',['-a']),('attributes','readelf',['-A']),('relocations','readelf',['-rW']),('sections','readelf',['-SW']),('disassembly','objdump',['-dr'])]:
        label=name.replace('.o','')+'-'+operation
        record,output=inspect(label,[BIN/('arm-zephyr-eabi-'+tool),*flags,base/name])
        summary['inspections'][label]=record
        if name=='reachable.o' and operation=='attributes':
            assert 'Tag_ABI_VFP_args: VFP registers' in output
            assert 'Tag_CPU_arch: v7E-M' in output
        if name=='reachable.o' and operation=='relocations':
            summary['reachable_allocator_relocations']=[s for s in output.splitlines() if re.search(r'\b(posix_memalign|malloc|calloc|realloc|free|swift_\w*[Aa]lloc\w*)\b',s)]
        if name=='reachable.o' and operation=='disassembly':
            summary['indirect_call_lines']=[s for s in output.splitlines() if re.search(r'\bblx?\s+r[0-9]+\b',s)]
        if name=='reachable.o' and operation=='symbols':
            summary['undefined_symbols']=[s for s in output.splitlines() if re.search(r'\bU\b',s)]
record,output=inspect('pi-attributes',[BIN/'arm-zephyr-eabi-readelf','-A',ROOT/'.build/raspberry-pi/spike-071/positive.o'])
assert 'Tag_CPU_arch: v6' in output and 'Tag_ABI_VFP_args: VFP registers' in output
summary['inspections']['pi-attributes']=record
for target in ['raspberry-pi','nrf52840']:
    record,_=inspect(target+'-doctor',[ROOT/'scripts'/target/'doctor.sh'])
    summary['inspections'][target+'-doctor']=record
(E/'inspection.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({k:summary[k] for k in ['invocations','reachable_allocator_relocations','indirect_call_lines','undefined_symbols']},indent=2))
