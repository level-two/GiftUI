#!/usr/bin/env python3
"""Prepare bounded cold-screen links only. Never execute a profile workload."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[7]
HERE = Path(__file__).resolve().parent
DIAGNOSTIC = HERE.parent / 'native-allocation-diagnostic'
ORIGINAL = ROOT / '.build/contracts/p08-counter-w700p_zi'
OBSERVER = ROOT / '.build/contracts/p08-native-allocation-matched-repair1-20261017'
# Extra files beyond the reviewed initial allowlist are serialization visibility
# forwarding only. The source diff and activity record enumerate their reasons.
ALLOWLIST = {
    'Sources/GiftUI/DeclarativeView.swift',
    'Sources/GiftUIExecution/AdmissionValues.swift',
    'Sources/GiftUIExecution/ExecutionValues.swift',
    'Sources/GiftUIExecution/ObservableTargetGeneration.swift',
    'Sources/GiftUIExecution/PointerActionCapture.swift',
    'Sources/GiftUIInteraction/ExecutionGestureAdapter.swift',
    'Sources/GiftUIInteraction/InteractionValues.swift',
    'Sources/GiftUIObservableState/ObservableModelMutation.swift',
    'Sources/GiftUIObservableState/ObservableModelOwnership.swift',
    'Sources/GiftUIObservableState/ObservableModelScope.swift',
    'Sources/GiftUIObservableState/ObservableModelTicket.swift',
    'Sources/GiftUIObservableState/ObservableStateModel.swift',
    'Sources/GiftUIObservableState/ObservableStateRootScope.swift',
    'Sources/GiftUIObservableState/ObservableStateRootTargetAccess.swift',
    'Sources/GiftUIObservableState/ObservableStateValues.swift',
    'Sources/GiftUIRuntimeCore/RuntimeRecordInteractionBridge.swift',
    *('Tests/ContractFixtures/SPEC015/RuntimeDerived/' + name for name in (
        'CounterProfileStorage.swift', 'CounterScopedStorage.swift',
        'CounterHostProbe.swift', 'CounterSemanticProbe.swift')),
}
MODULES = ('GiftUI', 'GiftUIExecution', 'GiftUIInteraction', 'GiftUIObservableState',
           'GiftUIRuntimeCore', 'GiftUIRuntimeStatic', 'GiftUIRuntimeDynamic',
           'GiftUIHostConfiguration', 'counter-model')


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    assert Path.cwd().resolve() == ROOT, 'run from repository root'
    out = args.output.resolve()
    assert ROOT / '.build/contracts' in out.parents and not out.exists()
    out.mkdir(parents=True)
    commands = []

    def execute(command, label):
        command = list(map(str, command))
        commands.append({'argv': command, 'log': label + '.log'})
        (out / 'commands.json').write_text(json.dumps(commands, indent=2) + '\n')
        with (out / (label + '.log')).open('wb') as log:
            subprocess.run(command, check=True, stdout=log, stderr=subprocess.STDOUT)
        print('prepared ' + label, flush=True)

    receipt = json.loads((ORIGINAL / 'result.json').read_text())
    checks = json.loads((ORIGINAL / 'checks.json').read_text())['checks']
    compiler = ROOT / receipt['compiler']
    assert digest(compiler) == receipt['compiler_sha256']
    recorded = json.loads((HERE.parent / 'native-strict-construction-probe/manifest.json').read_text())
    for name, identity in recorded['retained_dependencies'].items():
        assert digest(ROOT / name) == identity['sha256'], name
    original_link = shlex.split(next(c for c in receipt['commands'] if 'Main.swift' in c and ' -o ' in c))
    objects = [Path(field) for field in original_link if field.endswith('.o')]
    assert len(objects) == len(set(objects)) == 25
    original_hashes = {}
    source_hashes = {}
    retained_owner_source_deltas = {}
    for owner_path in {obj.parent / 'result.json' for obj in objects}:
        owner = json.loads(owner_path.read_text())
        expected_owner = (digest(ORIGINAL / 'result.json') if owner_path.parent == ORIGINAL else
                          receipt['host_receipt_sha256'] if owner_path.parent == (ROOT / receipt['host_build']).resolve() else
                          receipt['core_receipt_sha256'])
        assert digest(owner_path) == expected_owner, owner_path
        for name, expected in owner.get('inputs', {}).items():
            source = ROOT / name
            actual = digest(source) if source.is_file() else None
            if owner_path.parent == ORIGINAL:
                assert actual is not None and (actual == expected or name in ALLOWLIST), 'unexpected source delta: ' + name
                source_hashes[name] = actual
            elif actual != expected:
                retained_owner_source_deltas.setdefault(str(owner_path), {})[name] = {'retained': expected, 'current': actual}
        # Qualified old binary dependencies are not relabeled current-source
        # receipts; only explicitly rebuilt current owners replace their objects.
    for obj in objects:
        owner = json.loads((obj.parent / 'result.json').read_text())
        identity = owner['artifacts'][obj.name]
        assert digest(obj) == identity['sha256'] and obj.stat().st_size == identity['bytes'], obj
        original_hashes[str(obj)] = digest(obj)
    for name in ALLOWLIST:
        source_hashes[name] = digest(ROOT / name)
    for path in (HERE / 'prepare.py', HERE / 'run.py', DIAGNOSTIC / 'Driver.c',
                 DIAGNOSTIC / 'Probe.h', DIAGNOSTIC / 'replay.py'):
        source_hashes[str(path.relative_to(ROOT))] = digest(path)
    candidate = out / 'candidate'
    candidate.mkdir()
    for path in ORIGINAL.iterdir():
        if path.is_file() and path.suffix in ('.o', '.swiftmodule', '.swiftdoc', '.swiftsourceinfo', '.swift'):
            shutil.copyfile(path, candidate / path.name)

    def compile_command(name, destination):
        key = 'GiftUIExecution' if name == 'GiftUI' else name
        command = next(c['identity']['command'] for c in checks if c['name'] == key)
        command = [field.replace('${OUT}', str(destination)).replace(str(ORIGINAL), str(destination)) for field in command]
        if name == 'GiftUI':
            command = [field.replace('GiftUIExecution', 'GiftUI') for field in command if not field.endswith('.swift')]
            at = command.index('-emit-module-path')
            command[at:at] = [str(path) for path in sorted((ROOT / 'Sources/GiftUI').glob('*.swift'))]
        return command

    module_commands = [(name, compile_command(name, candidate)) for name in MODULES]
    for name, command in module_commands:
        for field in command:
            if field.endswith('.swift') and Path(field).is_file():
                source_hashes[str(Path(field).relative_to(ROOT))] = digest(field)
        if '-load-plugin-executable' in command:
            plugin = Path(command[command.index('-load-plugin-executable') + 1].split('#')[0])
            source_hashes[str(plugin.relative_to(ROOT))] = digest(plugin)
    for name, command in module_commands:
        execute(command, name)
    rebuilt_names = {'GiftUI.o', *(name + '.o' for name in MODULES if name not in ('GiftUI', 'counter-model')), 'P08CounterRuntime.o'}
    wrapper = out / 'HostFirst.swift'
    wrapper.write_text('''import P08CounterRuntime
@_cdecl("p08_native_host_first_entry")
func p08NativeHostFirstEntry(_ unused: UnsafeMutableRawPointer?) -> UInt32 {
    UInt32(p08CounterHost())
}
''')
    original_flags = next(c['identity']['command'] for c in checks if c['name'] == 'counter-model')
    prefix = original_flags[:original_flags.index('-module-name')]
    prefix = [field.replace('${OUT}', str(ORIGINAL)) for field in prefix]
    clang = subprocess.check_output(['xcrun', '--find', 'clang'], text=True).strip()
    execute([clang, '-std=c11', '-O1', '-fno-omit-frame-pointer', '-fno-optimize-sibling-calls',
             '-fno-typed-memory-operations-experimental', '-Wall', '-Wextra', '-Werror',
             '-Dgiftui_rfc014_counter_entry=p08_native_host_first_entry', '-c',
             DIAGNOSTIC / 'Driver.c', '-o', out / 'HostFirstDriver.o'], 'host-first-driver')

    def link(label, runtime_dir=None, ordinary=False):
        command = []
        skip = False
        for index, field in enumerate(original_link):
            if skip:
                skip = False
                continue
            if field.endswith('/Main.swift'):
                continue
            if field in ('-o', '-module-cache-path'):
                if field == '-module-cache-path':
                    command += [field, str(out / (label + '-cache'))]
                skip = True
                continue
            if field.endswith('.o') and runtime_dir and Path(field).name in rebuilt_names:
                field = str((runtime_dir if Path(field).name == 'P08CounterRuntime.o' else candidate) / Path(field).name)
            command.append(field)
        if not ordinary:
            destination = runtime_dir or ORIGINAL
            flags = [str(compiler), '-I', str(destination)] + prefix[1:]
            flags[flags.index('-module-cache-path') + 1] = str(out / (label + '-wrapper-cache'))
            wrapper_object = out / (label + '-wrapper.o')
            execute(flags + ['-module-name', 'P08ColdHostFirst', '-emit-object', wrapper, '-o', wrapper_object], label + '-wrapper')
            command += [str(wrapper_object), str(out / 'HostFirstDriver.o')]
        else:
            command += [str(OBSERVER / 'Driver.o')]
        command += ['-L' + str(OBSERVER), '-lP08AllocationObserver', '-Xlinker', '-rpath', '-Xlinker', str(OBSERVER), '-o', str(out / label)]
        execute(command, label + '-link')
        execute(['xcrun', 'nm', '-n', out / label], label + '-symbols')
        execute(['xcrun', 'otool', '-L', out / label], label + '-libraries')
        execute(['xcrun', 'size', '-m', out / label], label + '-sections')

    link('baseline-host-first')
    link('candidate-host-first', candidate)
    link('candidate-ordinary', candidate, ordinary=True)
    silent = out / 'silent'
    silent.mkdir()
    for path in candidate.iterdir():
        if path.is_file() and path.suffix in ('.o', '.swiftmodule', '.swiftdoc', '.swiftsourceinfo', '.swift'):
            shutil.copyfile(path, silent / path.name)
    # Three diagnostic-only normal-output statements. Assertions/error output,
    # workloads, loan structure and the registered source files are untouched.
    copies = {}
    for name, replacements in {
        'CounterPipelineOwner.swift': [('print(label, value)', '// diagnostic trace-free control')],
        'CounterScopedStorage.swift': [
            ('print("so06-reuse-\\(route)-\\(suffix)")', '// diagnostic trace-free reuse label'),
            ('print("SO06 role", event.bankKind, event.leftBefore.id.rawValue, event.leftBefore.address, event.leftCount, event.leftBefore.retainedBytes, event.rightBefore.id.rawValue, event.rightBefore.address, event.rightCount, event.rightBefore.retainedBytes, "=>", event.leftAfter.id.rawValue, event.rightAfter.id.rawValue)', '// diagnostic trace-free role label')],
    }.items():
        original = ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived' / name
        text = original.read_text()
        for before, after in replacements:
            assert text.count(before) == 1, (name, before)
            text = text.replace(before, after)
        copy = silent / name
        copy.write_text(text)
        copies[str(original)] = str(copy)
    command = compile_command('counter-model', silent)
    command = [copies.get(field, field) for field in command]
    execute(command, 'silent-counter-model')
    link('candidate-silent-host-first', silent)
    for name, expected in source_hashes.items():
        assert digest(ROOT / name) == expected, name
    for path, expected in original_hashes.items():
        assert digest(path) == expected, path
    manifest = {'kind': 'candidate preparation only; zero-heap unproved',
                'candidate_executed': False, 'corrective_cycles_used': 0, 'corrective_cycle_limit': 2,
                'compiler': str(compiler), 'compiler_sha256': digest(compiler),
                'original_receipt': str(ORIGINAL / 'result.json'),
                'original_receipt_sha256': digest(ORIGINAL / 'result.json'),
                'source_hashes': source_hashes, 'original_objects': original_hashes,
                'retained_owner_source_deltas': retained_owner_source_deltas,
                'retained_dependencies': recorded['retained_dependencies'],
                'silent_copies': {copy: {'source': original, 'sha256': digest(copy)} for original, copy in copies.items()},
                'executables': {name: digest(out / name) for name in ('baseline-host-first', 'candidate-host-first', 'candidate-silent-host-first', 'candidate-ordinary')},
                'commands_sha256': digest(out / 'commands.json')}
    manifest['prepared_artifacts'] = {str(p.relative_to(out)): digest(p) for p in out.rglob('*') if p.is_file() and not any('cache' in part for part in p.relative_to(out).parts) and p.name != 'manifest.json'}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print('PREPARED only; hand run.py to the sequential mechanical executor')


if __name__ == '__main__':
    main()
