#!/usr/bin/env python3
"""Finite SO-03 owned/scoped Interaction checks; later conformance stays open."""
import argparse
import atexit
import hashlib
import json
import pathlib
import re
import shlex
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--profile', required=True)
parser.add_argument('--giftui-build', type=pathlib.Path, required=True)
args = parser.parse_args()
base = args.giftui_build.resolve()
core = json.loads((base / 'result.json').read_text())
profile = core['profile']
assert args.profile == profile

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

for name, expected in core['inputs'].items():
    if name.startswith(('Sources/GiftUI/', 'Sources/GiftUIMacros/')):
        assert digest(ROOT / name) == expected, name
for name in ('GiftUI.o', 'GiftUI.swiftmodule'):
    assert digest(base / name) == core['artifacts'][name]['sha256']
compiler = ROOT / core['compiler']
assert digest(compiler) == core['compiler_sha256']
macro = ROOT / core.get('macro_tool', '.build/rfc014-p02-swift64/tool/debug/GiftUIMacros-tool')
assert digest(macro) == core['macro_tool_sha256']
command = next(shlex.split(line) for line in (base / 'commands.txt').read_text().splitlines()
               if '-module-name GiftUI ' in line)
flags = command[1:command.index('-module-name')]
parent = ROOT / '.build'
if profile == 'raspberry-pi-armv6': parent /= 'raspberry-pi'
if profile == 'nrf52840-embedded': parent /= 'nrf52840'
# Allocate once, then freeze every exact argv before the first compiler.
# Future separately authorized invocations retain separate immutable outputs.
parent /= 'contracts/spec-011-owned-keys'
parent.mkdir(parents=True, exist_ok=True)
out = pathlib.Path(tempfile.mkdtemp(dir=parent)) / profile
out.mkdir()
(out / 'probe-objects').mkdir()
flags[flags.index('-module-cache-path') + 1] = str(out / 'cache')
flags += ['-I', str(out), '-I', str(base), '-enable-testing']
commands, checks, plan, module_names = [], [], [], []
inputs = [pathlib.Path(__file__).resolve(), ROOT / 'Package.swift',
          ROOT / 'scripts/contracts/run-spec-011.sh', ROOT / 'scripts/contracts/driver-registry.tsv',
          ROOT / 'scripts/contracts/check-spec-013-runtime-cycle.py', macro]
# Selected SO-06 delivery remains the separately invoked counter driver; hash its
# source boundary without importing fixture-private access types into owned routes.
inputs.extend([ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterScopedStorage.swift', ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterScopedStorageProbe.swift'])
# Freeze the edited noncompiled measurement callers as source applicability,
# without pretending this component route compiles the later Counter/Cycle graph.
for spec, names in (
    ('SPEC015', ('CounterStorageMeasurement', 'CounterStorageRegions', 'CounterProfileStorage')),
    ('SPEC013', ('CycleStorageMeasurement', 'CycleStorageRegions', 'CycleProfileStorage', 'CycleCoordinatorProbe', 'CyclePipelineProbe')),
):
    inputs.extend(ROOT / 'Tests/ContractFixtures' / spec / 'RuntimeDerived' / (name + '.swift') for name in names)
inputs.extend(ROOT / 'Sources/SignalAnalyzerTargetHost' / name for name in (
    'DynamicSignalAnalyzerActionDispatcher.swift', 'StaticSignalAnalyzerActionDispatcher.swift'))
source_commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
source_dirty = bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True))
status, failure, execution, layouts = 'planned', None, None, {}
frozen_inputs = {}

def write_receipt():
    report = {
        'package': 'P08', 'step': 'SO-03', 'profile': profile,
        'status': status, 'failure': failure, 'source_commit': source_commit, 'source_dirty': source_dirty,
        'inputs': frozen_inputs, 'compiler': core['compiler'], 'compiler_sha256': digest(compiler),
        'macro_tool': str(macro.relative_to(ROOT)), 'macro_tool_sha256': digest(macro), 'flags': flags,
        'owner_command': 'scripts/contracts/run-spec-011.sh --profile ' + profile +
            ' --compiler-baseline rfc-014 --giftui-build ' + str(base.relative_to(ROOT)),
        'core_receipt': str((base / 'result.json').relative_to(ROOT)), 'core_receipt_sha256': digest(base / 'result.json'),
        'planned_commands': plan, 'commands': commands, 'checks': checks,
        'planned_compiler_count': sum(cell['compiler'] for cell in plan),
        'attempted_compiler_count': sum(cell['compiler'] for cell in checks),
        'planned_total_commands': len(plan), 'attempted_total_commands': len(checks),
        'automatic_repairs': 0, 'driver_invocations': 1, 'execution': execution,
        'physical_key_layout': layouts,
        'applicability': 'shared state/operations/owned dispatcher only; unchanged actual analyzer factories unresolved mandatory I4-07; measurement callers source-inspected only',
        'artifacts': {str(p.relative_to(out)): {'sha256': digest(p), 'bytes': p.stat().st_size}
            for p in out.rglob('*') if p.is_file() and p.name != 'result.json' and 'cache' not in p.relative_to(out).parts},
    }
    (out / 'result.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')

atexit.register(write_receipt)

def register(label, argv, expected=None, context=None):
    plan.append({'label': label, 'argv': list(map(str, argv)), 'expected_failure': expected,
                 'diagnostic_context': context, 'compiler': pathlib.Path(argv[0]) == compiler})

def module(name, sources, label=None):
    inputs.extend(sources)
    module_names.append(name)
    register(label or name, [compiler, *flags, '-module-name', name, '-emit-module', '-emit-object', *sources,
        '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')])

module('GiftUISemanticCore', [ROOT / 'Sources/GiftUISemanticCore/GiftUISemanticCore.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRuntimeRecords.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRecordStore.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRecordExpansion.swift', *[ROOT / 'Sources/GiftUISemanticCore' / name for name in ('SemanticStandardPayload.swift', 'SemanticLayoutView.swift', 'SemanticRenderView.swift', 'SemanticRecordLayoutView.swift', 'SemanticRecordRenderView.swift')]])
module('GiftUITextResources', sorted((ROOT / 'Sources/GiftUITextResources').glob('*.swift')))
module('GiftUILayout', sorted((ROOT / 'Sources/GiftUILayout').glob('*.swift')))
module('GiftUIRenderCore', sorted((ROOT / 'Sources/GiftUIRenderCore').glob('*.swift')))
module('GiftUIExecution', sorted((ROOT / 'Sources/GiftUIExecution').glob('*.swift')))
module('GiftUIInteraction', sorted((ROOT / 'Sources/GiftUIInteraction').glob('*.swift')))
module('GiftUIObservableState', [ROOT / 'Sources/GiftUIObservableState' / name for name in (
    'ObservableStateProtocols.swift', 'ObservableStateValues.swift', 'ObservableModelIdentity.swift', 'ObservableModelOwnership.swift',
    'ObservableModelTicket.swift', 'ObservableModelScope.swift', 'ObservableModelMutation.swift',
    'ObservableStateModel.swift', 'ObservableStateRegistrationLifecycle.swift', 'ObservableStateRootScope.swift',
    'ObservableStateRootTargetAccess.swift', 'ObservableStateBindingDecorator.swift', 'ObservableSemanticBodyBinding.swift')])
module('GiftUIRenderLowering', [ROOT / 'Sources/GiftUIRenderLowering' / name for name in ('RenderExtensions.swift', 'RenderPreflight.swift', 'RenderProducer.swift', 'RenderProductionValues.swift', 'RenderStreaming.swift')], label='so03-prereq-render-lowering')
module('GiftUIDrawing', [ROOT / 'Sources/GiftUIDrawing' / name for name in ('CanvasRenderProducer.swift', 'CanvasInvocationSource.swift', 'CanvasPlanProducer.swift', 'CanvasStagedValues.swift', 'CanvasSemanticPayload.swift', 'DrawingLimits.swift', 'DrawingPlan.swift', 'DrawingValues.swift', 'StaticCanvasCallableTable.swift', 'PathConstruction.swift', 'StrokeSnapshot.swift')], label='so03-prereq-drawing')
module('GiftUIRuntimeStatic', [ROOT / 'Sources/GiftUIRuntimeStatic' / name for name in (
    'StaticObservableModelStorage.swift', 'StaticObservableRootAdapter.swift', 'StaticObservableRootTargetAccess.swift', 'StaticSemanticRecordStorage.swift', 'StaticInteractionStorage.swift')])
if profile != 'nrf52840-embedded':
    module('GiftUIRuntimeDynamic', [ROOT / 'Sources/GiftUIRuntimeDynamic' / name for name in ('DynamicSemanticRecordStorage.swift', 'DynamicInteractionStorage.swift', 'DynamicObservableModelStorage.swift', 'DynamicObservableModelRegistration.swift', 'DynamicObservableRootAdapter.swift', 'DynamicObservableRootTargetAccess.swift')])
module('GiftUIRuntimeCore', [ROOT / 'Sources/GiftUIRuntimeCore' / name for name in ('RuntimeRecordInteractionBridge.swift', 'RuntimeRecordCanvasInteractionBridge.swift', 'RuntimeInteractionCandidateTransaction.swift', 'RuntimeInteractionCandidateCoordinator.swift', 'RuntimeInteractionCandidateResolution.swift', 'RuntimeInteractionDispatcher.swift', 'RuntimeOwnerFailure.swift')])

fixture = ROOT / 'Tests/ContractFixtures/SPEC011/RuntimeDerived'
layout_source = fixture / 'KeyLayoutProbe.swift'
inputs.append(layout_source)
register('key-layout', [compiler, *flags, '-module-name', 'KeyLayoutProbe', '-emit-ir', layout_source, '-o', out / 'key-layout.ll'])
probe_sources = [ROOT / 'Tests/ContractFixtures/SPEC010/RuntimeDerived/RootProbe.swift',
                 fixture / 'InteractionProbe.swift', fixture / 'ScopedStorageProbe.swift']
module('OwnedKeyProbe', probe_sources)
probe_cells = [('so03-state-owned', ['SO03_STATE_OWNED'], None, None),
               ('so03-state-scoped', ['SO03_STATE_SCOPED'], None, None),
               ('so03-state-failable', ['SO03_STATE_FAILABLE'], None, None)]
for bank in ('C', 'H0', 'R0', 'R1', 'H1'):
    for route in ('direct', 'generic'):
        for result in ('positive', 'escape'):
            defines = ['SO03_INPUT_' + bank]
            if route == 'generic': defines.append('SO03_GENERIC')
            if result == 'escape': defines.append('SO03_ESCAPE')
            probe_cells.append(('so03-union-' + bank + '-' + route + '-' + result,
                defines, 'lifetime-dependent value escapes its scope' if result == 'escape' else None,
                'so03Union' if result == 'escape' else None))
probe_cells += [
    ('so03-state-copy-negative', ['SO03_COPY_NEGATIVE'], "'copy' cannot be applied to noncopyable types", 'copy state'),
    ('so03-consumer-operations-positive', ['SO03_CONSUMER_OPERATIONS'], None, None),
    ('so03-retained-dispatcher-owned-positive', ['SO03_DISPATCHER_OWNED'], None, None),
    ('so03-retained-dispatcher-scoped-negative', ['SO03_DISPATCHER_SCOPED_NEGATIVE'],
        "requires that.*conform to '(?:Copyable|Escapable)'", 'RuntimeInteractionDispatcher'),
]
assert len(probe_cells) == 27
for label, defines, expected, context in probe_cells:
    define_flags = [item for define in defines for item in ('-D', define)]
    register(label, [compiler, *flags, *define_flags, '-module-name', 'SO03Probe', '-emit-object',
        *probe_sources, '-o', out / 'probe-objects' / (label + '.o')], expected, context)
if profile.startswith('macos'):
    main = out / 'Main.swift'
    main.write_text('import OwnedKeyProbe\n@main struct Main { static func main() { let count = giftuiP05Interaction(); precondition(count > 0); let roots = giftuiP03Root(); precondition(roots > 0); let scoped = giftuiSO03ScopedStorage(); precondition(scoped > 0); print("P05 Interaction assertions=\\(count) P03 root regressions=\\(roots) SO03 scoped/owned assertions=\\(scoped) failures=0") } }\n')
    inputs.append(main)
    register('link', [compiler, *flags, main, base / 'GiftUI.o',
        *sorted(out / (name + '.o') for name in module_names), '-o', out / 'interaction'])
    register('execute', [out / 'interaction'])
else:
    readelf = ROOT / '.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf'
    register('target-abi', [readelf, '-h', '-A', out / 'OwnedKeyProbe.o'])
expected_compilers = 40 if profile == 'nrf52840-embedded' else 41 if profile == 'raspberry-pi-armv6' else 42
assert sum(cell['compiler'] for cell in plan) == expected_compilers
assert len(plan) == expected_compilers + 1
frozen_inputs = {str(p.relative_to(ROOT)): digest(p) for p in sorted(set(inputs))}
(out / 'planned-commands.json').write_text(json.dumps(plan, indent=2, sort_keys=True) + '\n')
(out / 'input-hashes.json').write_text(json.dumps(frozen_inputs, indent=2, sort_keys=True) + '\n')
write_receipt()

# Execute only the frozen plan, once. No retry, diagnostic compile or repair.
status = 'running'
try:
    for cell in plan:
        argv, label = cell['argv'], cell['label']
        commands.append(shlex.join(argv))
        (out / 'commands.txt').write_text('\n'.join(commands) + '\n')
        result = subprocess.run(argv, cwd=ROOT, text=True, capture_output=True)
        output = result.stdout + result.stderr
        (out / (label + '.log')).write_text(output)
        expected = cell['expected_failure']
        diagnostics = re.findall(r'(?m)^[^\n]*\berror: ([^\n]+)', output)
        if expected is None:
            okay = result.returncode == 0
        else:
            # Every primary/echoed error must have the intended ownership cause.
            # Import, prerequisite or other type errors cannot pass a negative.
            okay = (result.returncode != 0 and bool(diagnostics) and
                all(re.search(expected, diagnostic) for diagnostic in diagnostics) and
                cell['diagnostic_context'] in output)
        checks.append({'name': label, 'exit': result.returncode, 'pass': okay,
            'compiler': cell['compiler'], 'expected_failure': expected, 'diagnostics': diagnostics})
        write_receipt()
        if not okay:
            raise RuntimeError(label + ': ' + str(out) + '\n' + output)
        if label == 'key-layout':
            ir = (out / 'key-layout.ll').read_text()
            for name, body in re.findall(r'define[^\n]*@p05_([a-z_]+)\([^\n]*\)[^{]*\{(.*?)^}', ir, re.S | re.M):
                value = re.search(r'ret i32 (\d+)', body)
                assert value, name
                layouts[name] = int(value.group(1))
            assert len(layouts) == 14, layouts
            layouts['candidate_inline_key_regions'] = 6 * 3 * layouts['key_stride']
            layouts['committed_inline_key_regions'] = 6 * 2 * layouts['key_stride']
            layouts['static_remaining_bytes_including_control_and_padding'] = layouts['static_owned_state_stride'] - layouts['candidate_inline_key_regions'] - layouts['committed_inline_key_regions']
            (out / 'key-layout.json').write_text(json.dumps(layouts, indent=2, sort_keys=True) + '\n')
        if label == 'execute': execution = result.stdout.strip()
        if label == 'target-abi':
            assert 'Tag_ABI_VFP_args: VFP registers' in output
            arch = 'v6' if profile == 'raspberry-pi-armv6' else 'v7E-M'
            assert re.search(r'Tag_CPU_arch: ' + arch + r'\s*$', output, re.MULTILINE)
            execution = 'cross-compiled only; no target execution'
    assert frozen_inputs == {str(p.relative_to(ROOT)): digest(p) for p in sorted(set(inputs))}
    status = 'passed'
except BaseException as error:
    status, failure = 'failed', str(error)
    write_receipt()
    print('SO-03 frozen failure: ' + str(out / 'result.json'), file=sys.stderr)
    raise
write_receipt()
print(f'SO-03 {profile}: {execution}; {out / "result.json"}')
