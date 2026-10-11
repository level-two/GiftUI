#!/usr/bin/env python3
"""Candidate 2: the real consuming owner, observed while still coordinator-owned."""
from pathlib import Path
import hashlib, json, shlex, subprocess
import run as bench
ROOT, HERE, BUILD = bench.ROOT, bench.HERE, bench.BUILD
NAME='c02-owned-audit'
OUT=BUILD/NAME

def execute(label, command):
    result=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
    record={'name':label,'command':command,'exit_code':result.returncode,'stdout':result.stdout,'stderr':result.stderr}
    (HERE/'results'/f'{label}.json').write_text(json.dumps(record,indent=2)+'\n')
    print(label,'exit',result.returncode); print(result.stdout+result.stderr)
    return result.returncode

def base(name):
    return subprocess.check_output(['git','show',bench.BASE+':Tests/ContractFixtures/SPEC013/RuntimeDerived/'+name],cwd=ROOT,text=True)

def add_observer(source, typename, arrays, extra=''):
    start=source.index('package struct '+typename)
    marker=source.index('    package init',start)
    body='    // Bench-only observation of actual retained buffers; never dereferenced after return.\n'
    body+='    package borrowing func benchBackingAddresses() -> [UInt] {\n        var addresses: [UInt] = []\n'
    for array in arrays:
        body+=f'        {array}.withUnsafeBufferPointer {{ addresses.append(UInt(bitPattern: $0.baseAddress)) }}\n'
    body+=extra+'        return addresses\n    }\n\n'
    return source[:marker]+body+source[marker:]

def instrument_dynamic():
    lines=(ROOT/'.build/contracts/spec-013-runtime-cycle/tmpuzqrfive/macos-static/commands.txt').read_text().splitlines()
    command=shlex.split(next(x for x in lines if '-module-name GiftUIRuntimeDynamic ' in x and '-emit-module ' in x))
    inputs={}
    for i,arg in enumerate(command):
        if not arg.endswith('.swift'): continue
        relative=Path(arg).relative_to(ROOT)
        original=bench.INPUTS/relative
        source=original.read_text() if original.exists() else subprocess.check_output(['git','show',bench.BASE+':'+str(relative)],cwd=ROOT,text=True)
        name=relative.name
        if name=='DynamicLayoutHostStorage.swift':
            source=add_observer(source,'DynamicLayoutWorkspace',['scopes','scopeIndex','lines','glyphs','depth'])
            source=add_observer(source,'DynamicResolvedLayoutStorage',['candidateScopes','candidateLines','candidateGlyphs','publishedScopes','publishedLines','publishedGlyphs'])
        if name=='DynamicDrawingPlanWorkspace.swift':
            source=add_observer(source,'DynamicDrawingPlanWorkspace',['canvasIdentities','strokes','points','subpaths'],'        addresses += livePath.storage.benchBackingAddresses()\n')
        if name=='DynamicLivePathStorage.swift':source=add_observer(source,'DynamicLivePathStorage',['points','subpaths'])
        if name=='DynamicRenderWorkspace.swift':source=add_observer(source,'DynamicRenderWorkspace',['semanticVisits','layoutVisits','foregrounds'])
        path=OUT/'instrumented'/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_text(source)
        command[i]=str(path); inputs[str(path.relative_to(ROOT))]=bench.digest(path)
    for flag,value in [('-module-cache-path',OUT/'cache'),('-emit-module-path',OUT/'GiftUIRuntimeDynamic.swiftmodule'),('-o',OUT/'GiftUIRuntimeDynamic.o')]:
        command[command.index(flag)+1]=str(value)
    (HERE/'results'/'c02-instrumented-source-hashes.json').write_text(json.dumps(inputs,indent=2)+'\n')
    return execute('c02-dynamic-observer-build',command)

def geometry_source(_):
    s=base('CycleGeometry.swift')
    s=s.replace('protocol CycleGeometry {','''struct CycleBackingEvidence: Equatable {
    let addresses: [UInt]
    let payloadBytes: UInt64
}
protocol CycleGeometry {
    borrowing func benchBackingEvidence() -> CycleBackingEvidence''',1)
    s=s.replace('struct DynamicCycleGeometry: CycleGeometry {','''struct DynamicCycleGeometry: CycleGeometry {
    borrowing func benchBackingEvidence() -> CycleBackingEvidence {
        let addresses = workspace.benchBackingAddresses() + resolved.benchBackingAddresses()
            + plan.benchBackingAddresses() + render.benchBackingAddresses()
        precondition(addresses.count == 20)
        return CycleBackingEvidence(addresses: addresses.sorted(), payloadBytes:
            workspace.reservedPayloadBytes + resolved.reservedPayloadBytes
            + plan.planReservedPayloadBytes + plan.livePathReservedPayloadBytes
            + UInt64(render.reservedPayloadBytes))
    }''',1)
    s=s.replace('struct StaticCycleGeometry: CycleGeometry {','''struct StaticCycleGeometry: CycleGeometry {
    let benchScopeAddress: UInt
    let benchTextAddress: UInt
    let benchPathAddress: UInt
    let benchPlanAddress: UInt
    borrowing func benchBackingEvidence() -> CycleBackingEvidence {
        CycleBackingEvidence(addresses: [benchScopeAddress, benchTextAddress, benchPathAddress, benchPlanAddress].sorted(),
            payloadBytes: 3136 + 4704 + 3280 + 13536)
    }''',1)
    s=s.replace('        workspace = StaticSignalAnalyzerNRFLayoutWorkspace', '''        benchScopeAddress = UInt(bitPattern: scopes.baseAddress)
        benchTextAddress = UInt(bitPattern: text.baseAddress)
        benchPathAddress = UInt(bitPattern: path.baseAddress)
        benchPlanAddress = UInt(bitPattern: plan.baseAddress)
        workspace = StaticSignalAnalyzerNRFLayoutWorkspace''',1)
    return s

def owner_source(_):
    s=base('CyclePipelineOwner.swift')
    return s.replace('    mutating func boundary', '''    // Audit access while the existing coordinator retains this consuming owner.
    borrowing func benchBackingEvidence() -> CycleBackingEvidence {
        geometry.benchBackingEvidence()
    }
    mutating func boundary''',1)

def coordinator_source(_):
    s=base('CycleCoordinatorProbe.swift')
    s=s.replace('    let binding = CycleExecutionBinding', '    let beforeTransfer = owner.benchBackingEvidence()\n    let binding = CycleExecutionBinding',1)
    for profile, indentation in [('Dynamic', '        '), ('Static', '    ')]:
        marker = indentation + 'var coordinator = ' + profile + 'RuntimeExecutionCoordinator(binding: binding, admission: admission, opportunity: owner)'
        s=s.replace(marker, marker + '\n' + indentation + 'precondition(coordinator.opportunity.benchBackingEvidence() == beforeTransfer)', 1)
    # Both branches recheck the same allocations after quiescence and unchanged use refusal.
    s=s.replace('coordinator.quiesce(); coordinator.quiesce()', 'coordinator.quiesce(); coordinator.quiesce()\n        precondition(coordinator.opportunity.benchBackingEvidence() == beforeTransfer)')
    s=s.replace('        return 7','        return 9',1).replace('    return 7','    return 9',1)
    return s

def link_and_run():
    original_dir=ROOT/'.build/contracts/spec-013-runtime-cycle/tmp_zcszbtn/macos-static'
    lines=(original_dir/'commands.txt').read_text().splitlines()
    command=shlex.split(next(x for x in lines if '/Main.swift ' in x and ' -o ' in x))
    main=OUT/'Main.swift';main.write_text((original_dir/'Main.swift').read_text())
    for i,arg in enumerate(command):
        if arg.endswith('/Main.swift'):command[i]=str(main)
        elif arg.endswith('/RuntimeCycleProbe.o'):command[i]=str(OUT/'RuntimeCycleProbe.o')
        elif arg.endswith('/GiftUIRuntimeDynamic.o'):command[i]=str(OUT/'GiftUIRuntimeDynamic.o')
        elif str(original_dir) in arg:command[i]=arg.replace(str(original_dir),str(ROOT/'.build/contracts/spec-013-runtime-cycle/tmpuzqrfive/macos-static'))
    command[1:1]=['-I',str(OUT)]
    command[command.index('-module-cache-path')+1]=str(OUT/'cache')
    command[command.index('-o')+1]=str(OUT/'runtime-cycle')
    if execute('c02-link',command):return 1
    return execute('c02-run',[str(OUT/'runtime-cycle')])

if __name__=='__main__':
    bench.prepare();OUT.mkdir(parents=True,exist_ok=True)
    if instrument_dynamic():raise SystemExit(1)
    changes={Path(arg).name:(lambda _,name=Path(arg).name:base(name)) for arg in bench.original if arg.endswith('.swift')}
    changes.update({'CycleGeometry.swift':geometry_source,'CyclePipelineOwner.swift':owner_source,'CycleCoordinatorProbe.swift':coordinator_source})
    if bench.run(NAME,changes,imports=OUT):raise SystemExit(1)
    raise SystemExit(link_and_run())
