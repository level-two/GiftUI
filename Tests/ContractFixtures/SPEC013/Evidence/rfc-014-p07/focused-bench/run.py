#!/usr/bin/env python3
"""Pinned, isolated diagnostic bench. Never edits maintained sources."""
from pathlib import Path
import hashlib, json, shlex, subprocess, sys
ROOT = Path(__file__).resolve().parents[6]
HERE = Path(__file__).resolve().parent
STOP = HERE.parent / 'audited-construction-stop'
BUILD = ROOT / '.build/p07-focused-bench'
INPUTS = BUILD / 'inputs'
BASE = 'c234058e'
original = shlex.split((STOP / 'failed-command.txt').read_text())
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def prepare():
    pinned_path = HERE / 'pinned-inputs.json'
    if pinned_path.exists():
        pinned=json.loads(pinned_path.read_text())
        compiler=Path(pinned['compiler'])
        if not compiler.is_file(): raise SystemExit('Missing pinned compiler: '+str(compiler))
        if digest(compiler) != pinned['compiler_sha256']: raise SystemExit('Compiler identity mismatch')
        for name, expected in (pinned['imported_artifacts'] | pinned.get('auxiliary_inputs', {})).items():
            path=ROOT/name
            if not path.is_file(): raise SystemExit('Missing pinned prerequisite: '+name)
            if digest(path) != expected: raise SystemExit('Changed pinned prerequisite: '+name)
    else:
        raise SystemExit('Missing pinned-inputs.json; do not silently regenerate identities')
    state = json.loads((STOP / 'source-state.json').read_text())
    paths = {f['path'] for f in state['files']}
    paths.update(str(Path(x).relative_to(ROOT)) for x in original if x.endswith('.swift'))
    for name in sorted(paths):
        p = INPUTS / name; p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(subprocess.check_output(['git', 'show', BASE + ':' + name], cwd=ROOT))
    subprocess.run(['git','apply','--directory',str(INPUTS.relative_to(ROOT)),str(STOP/'attempted-source.patch')],cwd=ROOT,check=True)
    for item in state['files']:
        assert digest(INPUTS / item['path']) == item['sha256'], item['path']
def run(name, changes=None, imports=None):
    out = BUILD / name; out.mkdir(parents=True,exist_ok=True)
    sources = []
    command = []
    for arg in original:
        if arg.endswith('.swift'):
            path = INPUTS / Path(arg).relative_to(ROOT)
            if changes and path.name in changes:
                altered = out / path.name; altered.write_text(changes[path.name](path.read_text())); path = altered
            sources.append(path); command.append(str(path))
        else: command.append(arg)
    for flag, value in [('-module-cache-path',out/'cache'),('-emit-module-path',out/'RuntimeCycleProbe.swiftmodule'),('-o',out/'RuntimeCycleProbe.o')]:
        command[command.index(flag)+1] = str(value)
    if imports:
        command[1:1] = ['-I', str(imports)]
    if name == 'd06-silgen':
        command.remove('-emit-module'); command.remove('-emit-object')
        index=command.index('-emit-module-path'); del command[index:index+2]
        command.append('-emit-silgen'); command[command.index('-o')+1]=str(out/'probe.sil')
    result = subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
    (out/'stdout.txt').write_text(result.stdout); (out/'stderr.txt').write_text(result.stderr)
    record = {'name':name,'command':command,'exit_code':result.returncode,'sources':{str(p.relative_to(ROOT)):digest(p) for p in sources},'stderr':result.stderr,'stdout':result.stdout}
    (HERE/'results'/f'{name}.json').write_text(json.dumps(record,indent=2)+'\n')
    print(name,'exit',result.returncode);print(result.stderr)
    return result.returncode
if __name__ == '__main__':
    prepare()
    name = sys.argv[1]
    changes = None
    if name == 'd01-empty-exercise':
        def empty_exercise(s):
            a=s.index('    // Give the nested'); b=s.index('\nfunc cyclePipelineProbe',a)
            return s[:a] + '    return 0\n}\n' + s[b:]
        changes = {'CyclePipelineProbe.swift':empty_exercise}
    elif name == 'd02-trap-owner-init':
        def trap_init(s):
            a=s.index('        self.models = consume models'); b=s.index('    mutating func boundary',a)
            return s[:a] + '        fatalError("diagnostic reduction")\n    }\n' + s[b:]
        changes = {'CyclePipelineOwner.swift':trap_init}
    elif name == 'd03-owned-owner-control':
        def base_file(name):
            return subprocess.check_output(['git','show',BASE+':Tests/ContractFixtures/SPEC013/RuntimeDerived/'+name],cwd=ROOT,text=True)
        changes = {
            'CyclePipelineOwner.swift':lambda _: base_file('CyclePipelineOwner.swift').replace('    var show = true','    var admission = CycleAdmissionBacking()\n    var show = true',1),
            'CyclePipelineProbe.swift':lambda _: base_file('CyclePipelineProbe.swift')}
    elif name == 'd04-trap-semantic-closure-methods':
        def trap_methods(s):
            for method in ['resolveLayout', 'preflightCombinedRender', 'buildInteractionCandidate', 'offerAndProduce']:
                marker='    mutating func '+method+'('
                if marker not in s:
                    continue
                a=s.index(marker); brace=s.index('{',a); end=brace+1; depth=1
                while depth:
                    depth += (s[end]=='{')-(s[end]=='}'); end+=1
                s=s[:brace+1]+' fatalError("diagnostic reduction") '+s[end-1:]
            return s
        changes = {'CyclePipelineOwner.swift':trap_methods}
    elif name == 'd05-empty-pipeline-caller':
        def empty_caller(s):
            a=s.index('func cyclePipelineProbe('); brace=s.index('{',a); b=s.index('\nprivate func withPipelineValues',brace)
            return s[:brace+1]+' return 0\n}\n'+s[b:]
        changes = {'CyclePipelineProbe.swift':empty_caller}
    elif name == 'd07-private-scopes-trap-external-reader':
        def private_scopes(s):
            for field in ['models','root','semantic','values']:
                s=s.replace('    let '+field+':','    private let '+field+':',1)
            return s
        def trap_reader(s):
            a=s.index('func cycleConcreteCoordinator'); brace=s.index('{',a); end=brace+1;depth=1
            while depth:
                depth += (s[end]=='{')-(s[end]=='}'); end+=1
            return s[:brace+1]+' return 0 '+s[end-1:]
        changes={'CyclePipelineOwner.swift':private_scopes,'CycleCoordinatorProbe.swift':trap_reader}
    elif name == 'c01-explicit-scope-borrows':
        def explicit_borrows(s):
            for field in ['models','root','semantic','values']:
                s=s.replace('    let '+field+':','    private let '+field+':',1)
            marker='    mutating func boundary'
            methods = """    @_lifetime(copy self)
    borrowing func borrowModels() -> ObservableModelScope<CycleOwnedModel, CycleModelSchema> {
        models.borrowedScope()
    }
    @_lifetime(copy self)
    borrowing func borrowRoot() -> ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity> {
        root.borrowedRoot()
    }
"""
            return s.replace(marker, methods+marker,1)
        changes={'CyclePipelineOwner.swift':explicit_borrows,
                 'CycleCoordinatorProbe.swift':lambda s:s.replace('owner.models.borrowedScope()', 'owner.borrowModels()').replace('owner.root.borrowedRoot()', 'owner.borrowRoot()')}
    elif name not in ['baseline', 'd06-silgen']: raise SystemExit('unknown variant')
    run(name, changes)
