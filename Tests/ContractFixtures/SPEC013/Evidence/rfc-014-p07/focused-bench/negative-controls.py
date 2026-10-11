#!/usr/bin/env python3
"""Actual candidate-2 owner controls, compiled in its complete fixture module."""
import json, subprocess
import run as bench
bench.prepare()
base=json.loads((bench.HERE/'results/c02-owned-audit.json').read_text())['command']
source=(bench.BUILD/'c02-owned-audit/CycleCoordinatorProbe.swift').read_text()
header=source[source.index('func cycleConcreteCoordinator<'):].split(' {',1)[0]
constraints=header.split(' where ',1)[1]
imports='import GiftUIInteraction\nimport GiftUISemanticCore\n'
type_name='CyclePipelineOwner<G, C, R, H>'
cases={
 'positive-borrow': ('borrowing', '_ = owner.benchBackingEvidence()', True),
 'negative-copy': ('borrowing', 'let duplicate = copy owner\n    _ = consume duplicate', False),
 'negative-use-after-consume': ('consuming', 'accept(owner: consume owner)\n    _ = owner.benchBackingEvidence()', False),
}
helper=f'func accept<G, C, R, H>(owner: consuming {type_name}) where {constraints} {{}}\n'
for name,(ownership,body,positive) in cases.items():
    text=imports+helper+f'func check<G, C, R, H>(owner: {ownership} {type_name}) where {constraints} {{\n    {body}\n}}\n'
    out=bench.BUILD/name;out.mkdir(parents=True,exist_ok=True)
    path=out/'Control.swift';path.write_text(text)
    cmd=base+[str(path)]
    for flag,value in [('-module-cache-path',out/'cache'),('-emit-module-path',out/'RuntimeCycleProbe.swiftmodule'),('-o',out/'RuntimeCycleProbe.o')]:cmd[cmd.index(flag)+1]=str(value)
    result=subprocess.run(cmd,cwd=bench.ROOT,capture_output=True,text=True)
    record={'command':cmd,'source':text,'source_sha256':bench.digest(path),'exit_code':result.returncode,'stdout':result.stdout,'stderr':result.stderr,'expected_success':positive}
    (bench.HERE/'results'/f'c02-{name}.json').write_text(json.dumps(record,indent=2)+'\n')
    print(name,result.returncode,result.stderr)
    if (result.returncode==0)!=positive:raise SystemExit('Unexpected control result')
    expected={'negative-copy': "'copy' cannot be applied to noncopyable types", 'negative-use-after-consume': "'owner' used after consume"}
    if not positive and expected[name] not in result.stderr:raise SystemExit('Wrong rejection reason')
name='negative-escape';out=bench.BUILD/name;out.mkdir(parents=True,exist_ok=True)
text=imports+f'struct Escape<G, C, R, H>: ~Copyable where {constraints} {{\n    let owner: {type_name}\n}}\n'
path=out/'Control.swift';path.write_text(text);cmd=base+[str(path)]
for flag,value in [('-module-cache-path',out/'cache'),('-emit-module-path',out/'RuntimeCycleProbe.swiftmodule'),('-o',out/'RuntimeCycleProbe.o')]:cmd[cmd.index(flag)+1]=str(value)
result=subprocess.run(cmd,cwd=bench.ROOT,capture_output=True,text=True)
record={'command':cmd,'source':text,'source_sha256':bench.digest(path),'exit_code':result.returncode,'stdout':result.stdout,'stderr':result.stderr,'expected_success':False}
(bench.HERE/'results'/f'c02-{name}.json').write_text(json.dumps(record,indent=2)+'\n')
print(name,result.returncode,result.stderr)
if result.returncode==0 or "has non-Escapable type" not in result.stderr:raise SystemExit('Escape not rejected for intended reason')
