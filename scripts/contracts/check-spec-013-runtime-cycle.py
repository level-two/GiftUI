#!/usr/bin/env python3
"""P07 finite runtime migration checks; full application/resource gates remain P08-P12."""
import argparse
import hashlib
import json
import pathlib
import re
import shlex
import subprocess
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
command = next(shlex.split(line) for line in (base / 'commands.txt').read_text().splitlines()
               if '-module-name GiftUI ' in line)
flags = command[1:command.index('-module-name')]
parent = ROOT / '.build'
if profile == 'raspberry-pi-armv6': parent /= 'raspberry-pi'
if profile == 'nrf52840-embedded': parent /= 'nrf52840'
parent /= 'contracts/spec-013-runtime-cycle'
parent.mkdir(parents=True, exist_ok=True)
out = pathlib.Path(tempfile.mkdtemp(dir=parent)) / profile
out.mkdir()
flags[flags.index('-module-cache-path') + 1] = str(out / 'cache')
flags += ['-I', str(out), '-I', str(base), '-enable-testing']
commands = []
inputs = [pathlib.Path(__file__).resolve(), ROOT / 'Package.swift', ROOT / 'scripts/contracts/run-spec-013.sh', ROOT / 'scripts/contracts/driver-registry.tsv']
checks = []

def run(label, args, failure=None):
    args = list(map(str, args))
    commands.append(shlex.join(args))
    (out / 'commands.txt').write_text('\n'.join(commands) + '\n')
    result = subprocess.run(args, cwd=ROOT, text=True, capture_output=True)
    (out / (label + '.log')).write_text(result.stdout + result.stderr)
    okay = result.returncode == 0 if failure is None else result.returncode != 0 and failure in result.stdout + result.stderr
    checks.append({'name': label, 'exit': result.returncode, 'pass': okay, 'expected_failure': failure})
    if not okay:
        raise SystemExit(f'{label}: {out}\n{result.stdout}{result.stderr}')
    return result.stdout

def module(name, sources):
    inputs.extend(sources)
    run(name, [compiler, *flags, '-module-name', name, '-emit-module', '-emit-object', *sources,
               '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')])

module('GiftUISemanticCore', [ROOT / 'Sources/GiftUISemanticCore/GiftUISemanticCore.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRuntimeRecords.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRecordStore.swift', ROOT / 'Sources/GiftUISemanticCore/SemanticRecordExpansion.swift', *[ROOT / 'Sources/GiftUISemanticCore' / name for name in ('SemanticStandardPayload.swift', 'SemanticLayoutView.swift', 'SemanticRenderView.swift', 'SemanticRecordLayoutView.swift', 'SemanticRecordRenderView.swift')]])
module('GiftUITextResources', sorted((ROOT / 'Sources/GiftUITextResources').glob('*.swift')))
module('GiftUIReferenceTextResources', sorted((ROOT / 'Sources/GiftUIReferenceTextResources').glob('*.swift')) + sorted((ROOT / 'Sources/GiftUIReferenceTextResources/Generated').glob('*.swift')) + sorted((ROOT / 'Sources/GiftUIReferenceTextResources/PiCompactGenerated').glob('*.swift')))
module('GiftUILayout', sorted((ROOT / 'Sources/GiftUILayout').glob('*.swift')))
module('GiftUIRenderCore', sorted((ROOT / 'Sources/GiftUIRenderCore').glob('*.swift')))
module('GiftUIExecution', sorted((ROOT / 'Sources/GiftUIExecution').glob('*.swift')))
module('GiftUIInteraction', sorted((ROOT / 'Sources/GiftUIInteraction').glob('*.swift')))
module('GiftUIObservableState', [ROOT / 'Sources/GiftUIObservableState' / name for name in (
    'ObservableStateValues.swift', 'ObservableModelIdentity.swift', 'ObservableModelOwnership.swift',
    'ObservableModelTicket.swift', 'ObservableModelScope.swift', 'ObservableModelMutation.swift',
    'ObservableStateModel.swift', 'ObservableStateRegistrationLifecycle.swift', 'ObservableStateRootScope.swift',
    'ObservableStateRootTargetAccess.swift', 'ObservableStateBindingDecorator.swift', 'ObservableSemanticBodyBinding.swift')])
module('GiftUIRenderLowering', sorted((ROOT / 'Sources/GiftUIRenderLowering').glob('*.swift')))
module('GiftUIDrawing', [ROOT / 'Sources/GiftUIDrawing' / name for name in ('CanvasRenderProducer.swift', 'CanvasInvocationSource.swift', 'CanvasPlanProducer.swift', 'CanvasStagedValues.swift', 'CanvasSemanticPayload.swift', 'DrawingLimits.swift', 'DrawingPlan.swift', 'DrawingValues.swift', 'StaticCanvasCallableTable.swift', 'PathConstruction.swift', 'StrokeSnapshot.swift')])
module('GiftUIRuntimeCore', [ROOT / 'Sources/GiftUIRuntimeCore' / name for name in (
    'RuntimeRecordInteractionBridge.swift', 'RuntimeRecordCanvasInteractionBridge.swift', 'RuntimeInteractionCandidateResolution.swift', 'ObservableCanvasInvocationSource.swift', 'RuntimeProfileValues.swift', 'RuntimeProfileValidation.swift', 'RuntimeStorageRegistry.swift',
    'RuntimeOwnerFailure.swift', 'RuntimeCoordinatorCleanup.swift', 'RuntimeCompletePipeline.swift', 'RuntimeCoordinatorContracts.swift', 'RuntimeProfileStorage.swift')])
module('GiftUIRuntimeStatic', [ROOT / 'Sources/GiftUIRuntimeStatic' / name for name in ('StaticRuntimeExecutionCoordinator.swift', 'StaticObservableModelStorage.swift', 'StaticObservableRootAdapter.swift', 'StaticObservableRootTargetAccess.swift', 'StaticCanvasValueStorage.swift', 'StaticSemanticRecordStorage.swift', 'StaticInteractionStorage.swift', 'StaticRecordDrawingWorkspace.swift')])
if profile != 'nrf52840-embedded':
    module('GiftUIRuntimeDynamic', [ROOT / 'Sources/GiftUIRuntimeDynamic' / name for name in ('DynamicRuntimeExecutionCoordinator.swift', 'DynamicObservableModelStorage.swift', 'DynamicObservableModelRegistration.swift', 'DynamicObservableRootAdapter.swift', 'DynamicObservableRootTargetAccess.swift', 'DynamicObservableStateReconciler.swift', 'DynamicCanvasCallableStorage.swift', 'DynamicSemanticRecordStorage.swift', 'DynamicInteractionStorage.swift', 'DynamicLayoutHostStorage.swift', 'DynamicDrawingPlanWorkspace.swift', 'DynamicLivePathStorage.swift', 'DynamicRenderWorkspace.swift')])
macro = ROOT / '.build/rfc014-p02/tool/debug/GiftUIMacros-tool'
assert digest(macro) == core['macro_tool_sha256']
fixture = ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived'
inputs.extend([macro, fixture / 'Cycle.schema.json', fixture / 'Cycle.swift'])
run('cycle-lowering', [macro, '--lower-source', fixture / 'Cycle.schema.json', fixture / 'Cycle.swift',
                      out / 'CycleSchema.swift', out / 'Cycle.swift', out / 'CycleTable.swift', 'CyclePresentation'])
module('CycleSchema', [out / 'CycleSchema.swift'])
module('CyclePresentation', [out / 'Cycle.swift'])
module('CycleTable', [out / 'CycleTable.swift'])
module('P07TargetWorkspace', [ROOT / 'Sources/SignalAnalyzerTargetHost' / name for name in ('StaticSignalAnalyzerNRFLayoutScopeCodec.swift', 'StaticSignalAnalyzerNRFLayoutTextCodec.swift', 'StaticSignalAnalyzerNRFLayoutWorkspace.swift', 'StaticSignalAnalyzerNRFResolvedLayout.swift', 'StaticSignalAnalyzerNRFRenderWorkspace.swift', 'StaticSignalAnalyzerNRFDrawingPlanRecords.swift', 'StaticSignalAnalyzerNRFDrawingPlanStorage.swift', 'StaticSignalAnalyzerNRFLivePathStorage.swift', 'StaticSignalAnalyzerNRFDrawingWorkspace.swift')])
module('RuntimeCycleProbe', [ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/RuntimeValuesProbe.swift', ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/ScopedOwnerProbe.swift', ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/ScopedCoordinatorProbe.swift', ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/FrameLeaseProbe.swift', ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/ScopedSemanticProbe.swift', ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/ConcreteBindingProbe.swift', fixture / 'CycleStorageMeasurement.swift', fixture / 'CycleProfileStorage.swift', fixture / 'CycleStorageRegions.swift', fixture / 'CycleModel.swift', fixture / 'CycleSemanticProbe.swift', fixture / 'CycleDynamicDrawing.swift', fixture / 'CycleStaticDrawing.swift', fixture / 'CycleRenderProbe.swift', fixture / 'CycleGeometry.swift', fixture / 'CyclePipelineOwner.swift', fixture / 'CyclePipelineProbe.swift', fixture / 'CycleCoordinatorProbe.swift'])
for name, source, diagnostic in (
    ('escape-owner', 'struct Escape<M: ~Copyable, S>: ~Copyable { let owner: ScopedOwner<M, S> }', 'non-Escapable'),
    ('copy-owner', 'func copyOwner<M: ~Copyable, S>(_ owner: borrowing ScopedOwner<M, S>) { let other = copy owner; _ = other }', 'noncopyable'),
):
    negative = out / (name + '.swift')
    negative.write_text(source + '\n')
    run(name, [compiler, *flags, '-module-name', 'ScopedOwnerNegative', '-emit-object',
               ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/ScopedOwnerProbe.swift', negative,
               '-o', out / (name + '.o')], failure=diagnostic)
for name, source, diagnostic in (
    ('escape-coordinator', 'struct Escape<M: ~Copyable, S>: ~Copyable { let coordinator: ScopedCoordinator<M, S> }', 'non-Escapable'),
    ('copy-coordinator', 'func copyCoordinator<M: ~Copyable, S>(_ coordinator: borrowing ScopedCoordinator<M, S>) { let other = copy coordinator; _ = other }', 'noncopyable'),
):
    negative = out / (name + '.swift')
    negative.write_text(source + '\n')
    run(name, [compiler, *flags, '-module-name', 'ScopedCoordinatorNegative', '-emit-object',
               ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/ScopedCoordinatorProbe.swift', negative,
               '-o', out / (name + '.o')], failure=diagnostic)
for name, source, diagnostic in (
    ('escape-semantic', 'struct Escape<P>: ~Copyable { let owner: ScopedSemanticOwner<P> }', 'non-Escapable'),
    ('copy-semantic', 'func copySemantic<P>(_ owner: borrowing ScopedSemanticOwner<P>) { let other = copy owner; _ = other }', 'noncopyable'),
):
    negative = out / (name + '.swift')
    negative.write_text(source + '\n')
    run(name, [compiler, *flags, '-module-name', 'ScopedSemanticNegative', '-emit-object',
               ROOT / 'Tests/ContractFixtures/SPEC013/RuntimeDerived/ScopedSemanticProbe.swift', negative,
               '-o', out / (name + '.o')], failure=diagnostic)
extraction_imports = 'import GiftUI\nimport GiftUIObservableState\nimport GiftUIRuntimeStatic\n'
extraction_type = 'StaticRuntimeExecutionCoordinator<ScopedBinding<M, S>, ScopedCoordinator<M, S>, ScopedCoordinator<M, S>>'
for name, source, diagnostic in (
    ('returned-owner-use-after-consume', f'func reject<M: ~Copyable, S>(_ coordinator: consuming {extraction_type}) {{ _ = coordinator.takeQuiescedOpportunity(); _ = coordinator.runOpportunity() }}', 'used after consume'),
    ('returned-owner-escape', f'@_lifetime(immortal) func reject<M: ~Copyable, S>(_ coordinator: consuming {extraction_type}) -> ScopedCoordinator<M, S> {{ coordinator.takeQuiescedOpportunity()! }}', 'escapes'),
):
    negative = out / (name + '.swift')
    negative.write_text(extraction_imports + source + '\n')
    run(name, [compiler, *flags, '-module-name', 'ReturnedOwnerNegative', '-emit-object',
               fixture / 'ScopedCoordinatorProbe.swift', negative,
               '-o', out / (name + '.o')], failure=diagnostic)
binding_imports = 'import GiftUI\nimport GiftUIObservableState\nimport GiftUISemanticCore\nimport CycleSchema\nimport CyclePresentation\nimport RuntimeCycleProbe\n'
for name, source, diagnostic in (
    ('mismatched-model', 'func reject<M: ObservableStateModel & ~Copyable>(_ models: borrowing ObservableModelScope<M, M.Schema>, _ root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>) { _ = ObservableSemanticBodyBinding(models: models.borrowedScope(), root: root.borrowedRoot(), domain: CycleDomain.self) }', "requires the types"),
    ('mismatched-schema', 'func reject<S>(_ models: borrowing ObservableModelScope<CycleOwnedModel, S>, _ root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>) { _ = ObservableSemanticBodyBinding(models: models.borrowedScope(), root: root.borrowedRoot(), domain: CycleDomain.self) }', "cannot convert value"),
    ('mismatched-action', 'enum ForeignAction: UInt16, GiftUIAction { case increment = 1 }; func reject() { _ = CycleHandler.operation(ForeignAction.increment) }', "cannot convert value"),
    ('mismatched-mutation', 'enum ForeignMutation { case increment }; func reject(_ root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, _ key: _GiftUIModelKey<CycleModelSchema>) { _ = root.mutate(key, mutation: ForeignMutation.increment) }', "cannot convert value"),
):
    negative = out / (name + '.swift')
    negative.write_text(binding_imports + source + '\n')
    run(name, [compiler, *flags, '-module-name', 'ConcreteBindingNegative', '-typecheck', negative], failure=diagnostic)
storage_reports = {}
logical_transcripts = {}
if profile.startswith('macos'):
    main = out / 'Main.swift'
    main.write_text('import RuntimeCycleProbe\n@main struct Main { static func main() { print("P07 values assertions=\\(giftuiP07Values() + Int(giftuiP07FrameLease()) + giftuiP07CycleSemantic()) failures=0") } }\n')
    run('link', [compiler, *flags, main, base / 'GiftUI.o', *sorted(out.glob('*.o')), '-o', out / 'runtime-cycle'])
    output = run('execute', [out / 'runtime-cycle']).strip()
    execution = output.splitlines()[-1]
    active = None
    for line in output.splitlines():
        if line.startswith('P07TRACE begin '):
            assert active is None
            active = line.split()[-1]
            logical_transcripts.setdefault(active, []).append([])
        elif line.startswith('P07TRACE end '):
            assert active == line.split()[-1]
            active = None
        elif active is not None and line.startswith('P07TRACE '):
            logical_transcripts[active][-1].append(line.removeprefix('P07TRACE '))
    assert active is None
    assert set(logical_transcripts) == {'static', 'dynamic'}
    assert logical_transcripts['static'] and logical_transcripts['static'] == logical_transcripts['dynamic'], 'actual profile logical transcripts differ'
    for case in logical_transcripts['static']:
        commits = [line for line in case if line.startswith('model.commit ')]
        reports = [line for line in case if line.startswith('model.report ')]
        dispatched = [line for line in case if line == 'dispatch interaction(GiftUIInteraction.InteractionDispatchResult.dispatched)']
        assert len(commits) == len(reports) == len(dispatched), 'checked mutation/report/dispatch must be exactly once'
        assert all(line.endswith('true)') for line in commits)
        assert all(line in ('model.report dirtied', 'model.report coalesced') for line in reports)
    (out / 'logical-transcripts.json').write_text(json.dumps(logical_transcripts, indent=2) + '\n')
    for line in output.splitlines():
        parts = line.split()
        if not parts or not parts[0].startswith('P07-'): continue
        report = storage_reports.setdefault(parts[1], {'regions': [], 'fields': []})
        if parts[0] == 'P07-REGION':
            report['regions'].append(dict(zip(('family', 'kind', 'count', 'size', 'stride', 'alignment', 'charged_bytes'), map(int, parts[2:]))))
        elif parts[0] == 'P07-FIELD':
            report['fields'].append({'index': int(parts[2]), 'name': parts[3], 'bytes': int(parts[4])})
        elif parts[0] == 'P07-TOTAL': report['checked_total_bytes'] = int(parts[2])
    assert set(storage_reports) == {'static', 'dynamic'}
    for report in storage_reports.values():
        assert [f['index'] for f in report['fields']] == list(range(26))
        for field in report['fields']:
            assert sum(r['charged_bytes'] for r in report['regions'] if r['family'] == field['index']) == field['bytes']
        assert sum(f['bytes'] for f in report['fields']) == report['checked_total_bytes']
    (out / 'storage-regions.json').write_text(json.dumps(storage_reports, indent=2, sort_keys=True) + '\n')
else:
    readelf = ROOT / '.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf'
    abi = run('target-abi', [readelf, '-h', '-A', out / 'RuntimeCycleProbe.o'])
    assert 'Tag_ABI_VFP_args: VFP registers' in abi
    arch = 'v6' if profile == 'raspberry-pi-armv6' else 'v7E-M'
    assert re.search(r'Tag_CPU_arch: ' + arch + r'\s*$', abi, re.MULTILINE)
    execution = 'cross-compiled only; no target execution'
report = {'package': 'P07', 'step': 'actual-profile-logical-transcripts', 'profile': profile,
          'source_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
          'source_dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True)),
          'inputs': {str(p.relative_to(ROOT)): digest(p) for p in sorted(set(inputs))},
          'core_receipt': str((base / 'result.json').relative_to(ROOT)), 'core_receipt_sha256': digest(base / 'result.json'),
          'compiler': core['compiler'], 'compiler_sha256': core['compiler_sha256'],
          'commands': commands, 'checks': checks, 'execution': execution, 'storage_reports': storage_reports, 'logical_transcript_cases': len(logical_transcripts.get('static', [])),
          'artifacts': {p.name: {'sha256': digest(p), 'bytes': p.stat().st_size} for p in out.iterdir()
                        if p.is_file() and p.name != 'result.json'}}
(out / 'result.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
print(f'P07 {profile}: {execution}; {out / "result.json"}')
