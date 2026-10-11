#!/usr/bin/env python3
"""P06 protocol Canvas selected-component checks; broad P10/P11 gates stay open."""
import argparse
import hashlib
import json
import pathlib
import re
import shlex
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
FIXTURE = ROOT / 'Tests/ContractFixtures/SPEC012/RuntimeDerived'
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
parent /= 'contracts/spec-012-protocol-canvas'
parent.mkdir(parents=True, exist_ok=True)
out = pathlib.Path(tempfile.mkdtemp(dir=parent)) / profile
out.mkdir()
flags[flags.index('-module-cache-path') + 1] = str(out / 'cache')
flags += ['-I', str(out), '-I', str(base), '-enable-testing']
commands = []
inputs = [pathlib.Path(__file__).resolve(), ROOT / 'scripts/contracts/run-spec-012.sh',
          ROOT / 'scripts/contracts/driver-registry.tsv']
checks = []

def run(label, args, failure=None):
    args = list(map(str, args))
    commands.append(shlex.join(args))
    (out / 'commands.txt').write_text('\n'.join(commands) + '\n')
    result = subprocess.run(args, cwd=ROOT, text=True, capture_output=True)
    output = result.stdout + result.stderr
    (out / (label + '.log')).write_text(output)
    okay = result.returncode == 0 if failure is None else result.returncode != 0 and failure in output
    checks.append({'name': label, 'exit': result.returncode, 'pass': okay, 'expected_failure': failure})
    if not okay: raise SystemExit(f'{label}: {out}\n{output}')
    return output

def module(name, sources):
    inputs.extend(sources)
    run(name, [compiler, *flags, '-module-name', name, '-emit-module', '-emit-object', *sources,
               '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')])

module('GiftUISemanticCore', [ROOT / 'Sources/GiftUISemanticCore' / name for name in (
    'GiftUISemanticCore.swift', 'SemanticRuntimeRecords.swift', 'SemanticRecordStore.swift',
    'SemanticRecordExpansion.swift', 'SemanticStandardPayload.swift', 'SemanticLayoutView.swift',
    'SemanticRenderView.swift', 'SemanticRecordLayoutView.swift', 'SemanticRecordRenderView.swift')])
module('GiftUITextResources', sorted((ROOT / 'Sources/GiftUITextResources').glob('*.swift')))
module('GiftUILayout', sorted((ROOT / 'Sources/GiftUILayout').glob('*.swift')))
module('GiftUIRenderCore', sorted((ROOT / 'Sources/GiftUIRenderCore').glob('*.swift')))
module('GiftUIExecution', [ROOT / 'Sources/GiftUIExecution' / name for name in (
    'ObservableTargetGeneration.swift', 'ExecutionValues.swift', 'FrameHandoffValues.swift')])
module('GiftUIObservableState', [ROOT / 'Sources/GiftUIObservableState' / name for name in (
    'ObservableStateValues.swift', 'ObservableModelIdentity.swift', 'ObservableModelOwnership.swift',
    'ObservableModelTicket.swift', 'ObservableModelScope.swift', 'ObservableModelMutation.swift',
    'ObservableStateModel.swift', 'ObservableStateRegistrationLifecycle.swift', 'ObservableStateRootScope.swift',
    'ObservableStateRootTargetAccess.swift', 'ObservableStateBindingDecorator.swift', 'ObservableSemanticBodyBinding.swift')])
module('GiftUIDrawing', [ROOT / 'Sources/GiftUIDrawing' / name for name in (
    'CanvasInvocationSource.swift', 'CanvasPlanProducer.swift', 'CanvasStagedValues.swift', 'CanvasSemanticPayload.swift',
    'DrawingLimits.swift', 'DrawingPlan.swift', 'DrawingValues.swift', 'StaticCanvasCallableTable.swift',
    'PathConstruction.swift', 'StrokeSnapshot.swift')])
module('GiftUIRuntimeCore', [ROOT / 'Sources/GiftUIRuntimeCore/ObservableCanvasInvocationSource.swift'])
module('GiftUIRuntimeStatic', [ROOT / 'Sources/GiftUIRuntimeStatic' / name for name in (
    'StaticObservableModelStorage.swift', 'StaticCanvasValueStorage.swift', 'StaticSemanticRecordStorage.swift')])
if profile != 'nrf52840-embedded':
    module('GiftUIRuntimeDynamic', [ROOT / 'Sources/GiftUIRuntimeDynamic' / name for name in (
        'DynamicCanvasCallableStorage.swift',)])

macro = ROOT / '.build/rfc014-p02/tool/debug/GiftUIMacros-tool'
assert digest(macro) == core['macro_tool_sha256']
inputs.append(macro)
for application in ('Counter', 'Analyzer'):
    source_schema = ROOT / 'Tests/ContractFixtures/SPEC006/RuntimeDerived' / (application + '.schema.json')
    inputs.append(source_schema)
    config = json.loads(source_schema.read_text())
    config['calls'] = ['GeometryScalar']
    schema = out / (application + '.json')
    schema.write_text(json.dumps(config))
    source = FIXTURE / (application + 'Canvas.swift')
    inputs.append(source)
    run(application + '-lowering', [macro, '--lower-source', schema, source,
                                   out / (application + 'Schema.swift'), out / (application + 'Canvas.swift'),
                                   out / (application + 'CanvasTable.swift'), application + 'Canvas'])
    module(application + 'Schema', [out / (application + 'Schema.swift')])
    module(application + 'Canvas', [out / (application + 'Canvas.swift')])
    module(application + 'CanvasTable', [out / (application + 'CanvasTable.swift')])

module('CanvasStoreProbe', [FIXTURE / 'CanvasStoreProbe.swift', FIXTURE / 'CanvasSemanticProbe.swift', ROOT / 'Tests/ContractFixtures/SPEC007/RuntimeDerived/LayoutSupport.swift'])
if profile.startswith('macos'):
    main = out / 'Main.swift'
    main.write_text('import CanvasStoreProbe\n@main struct Main { static func main() { print("P06 stores assertions=\\(giftuiP06Stores(dynamic: false) + giftuiP06Stores(dynamic: true)) failures=0") } }\n')
    run('native-link', [compiler, *flags, main, base / 'GiftUI.o', base / 'SignalAnalyzerDomain.o',
                        *sorted(out.glob('*.o')), '-o', out / 'canvas-stores'])
    run('native-execute', [out / 'canvas-stores'])

for name, source, diagnostic in (
    ('missing-witness', 'struct Bad: Canvas {}', 'requires exactly one draw witness'),
    ('async-draw', 'struct Bad: Canvas { func draw(in bounds: Rect, context: inout GraphicsContext) async throws(DrawingError) {} }', 'requires synchronous draw'),
    ('effect', 'struct Bad: Canvas { func draw(in bounds: Rect, context: inout GraphicsContext) throws(DrawingError) { service.run() } }', 'unsupported call/effect'),
    ('inout-effect', 'struct Bad: Canvas { func draw(in bounds: Rect, context: inout GraphicsContext) throws(DrawingError) { min(&context) } }', 'unchecked inout'),
    ('closure-fallback', 'struct Bad: View { var body: some View { Canvas { context, size in } } }', 'unsupported call/effect'),
):
    source_file = out / (name + '.swift')
    source_file.write_text('import GiftUI\n' + source + '\n')
    generated = out / (name + '-lowered.swift')
    run(name, [macro, '--lower-source', out / 'Counter.json', source_file,
               out / (name + '-schema.swift'), generated], failure=diagnostic)
    assert not generated.exists()

for name, source, diagnostic in (
    ('escape-source', '''import GiftUI
        import GiftUIDrawing
        import GiftUIObservableState
        import GiftUIRuntimeCore
        import CounterSchema
        import CanvasStoreProbe
        struct Escape: ~Copyable { let source: ObservableCanvasInvocationSource<CanvasModel, CounterModelSchema, UInt16, CanvasTable> }
        ''', 'non-Escapable'),
    ('copy-source', '''import GiftUI
        import GiftUIDrawing
        import GiftUIObservableState
        import GiftUIRuntimeCore
        import CounterSchema
        import CanvasStoreProbe
        func copySource(_ source: borrowing ObservableCanvasInvocationSource<CanvasModel, CounterModelSchema, UInt16, CanvasTable>) {
            let other = copy source
            _ = other.canvasOccurrenceCount
        }
        ''', 'noncopyable'),
    ('wrong-domain', '''import GiftUI
        import CounterCanvas
        enum Other: _GiftUIReadDomain { typealias Slot = UInt8 }
        func wrong<C: Canvas>(_ canvas: C, read: borrowing _GiftUIFrameRead<Other>, context: inout GraphicsContext, bounds: Rect) throws(DrawingError) {
            try canvas._giftUIDraw(in: bounds, context: &context, read: read)
        }''', 'cannot convert'),
    ('escape-read', '''import GiftUI
        struct Escape<D: _GiftUIReadDomain> { let read: _GiftUIFrameRead<D> }''', 'non-Escapable'),
    ('escape-context', '''import GiftUI
        func escape(_ context: inout GraphicsContext) -> () -> Void {
            { _ = context }
        }''', 'escaping closure captures'),
    ('missing-compiled-witness', '''import GiftUI
        struct Bad: Canvas { typealias Domain = _GiftUIEmptyReadDomain }''', 'does not conform'),
):
    source_file = out / (name + '.swift')
    source_file.write_text(source)
    run(name, [compiler, *flags, '-module-name', name.replace('-', ''), '-emit-object', source_file,
               '-o', out / (name + '.o')], failure=diagnostic)

report = {'package': 'P06', 'step': 'protocol-lowering', 'profile': profile,
          'source_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
          'source_dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True)),
          'inputs': {str(p.relative_to(ROOT)): digest(p) for p in sorted(set(inputs))},
          'core_receipt': str((base / 'result.json').relative_to(ROOT)), 'core_receipt_sha256': digest(base / 'result.json'),
          'compiler': core['compiler'], 'compiler_sha256': core['compiler_sha256'],
          'commands': commands, 'checks': checks,
          'artifacts': {p.name: {'sha256': digest(p), 'bytes': p.stat().st_size} for p in out.iterdir()
                        if p.is_file() and p.name != 'result.json'}}
(out / 'result.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
print(f'P06 {profile}: {out / "result.json"}')
