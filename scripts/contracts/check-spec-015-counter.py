#!/usr/bin/env python3
"""Actual P08 finite counter owner/layout/drawing/render components; host and early images remain open."""
import argparse
import hashlib
import json
import pathlib
import shlex
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--runtime-build', required=True, type=pathlib.Path)
parser.add_argument('--host-build', type=pathlib.Path, default=ROOT / '.build/contracts/p08-scoped-host-c5eocina')
parser.add_argument('--profile', choices=('macos-dynamic', 'macos-static', 'raspberry-pi-armv6', 'nrf52840-embedded'))
parser.add_argument('--raster-realization', choices=('full-surface', 'tiled'), default='full-surface')
args = parser.parse_args()
base = args.runtime_build.resolve()
prior = json.loads((base / 'result.json').read_text())
if args.profile:
    assert prior['profile'] == args.profile, 'runtime recipe profile mismatch'
is_target = args.profile in ('raspberry-pi-armv6', 'nrf52840-embedded')
is_embedded = args.profile == 'nrf52840-embedded'
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
revision_path = ROOT / 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r06-import-correction/reviewed-source-revisions.json'
revision_receipt = json.loads(revision_path.read_text())
reviewed_revisions = revision_receipt['sources'] | revision_receipt['recipe_metadata']
def verify_recipe_source(name, expected):
    if name in reviewed_revisions:
        revision = reviewed_revisions[name]
        assert expected == revision['recipe_sha256'], name + ': unreviewed recipe revision'
        assert digest(ROOT / name) == revision['rebuilt_sha256'], name + ': unreviewed rebuilt revision'
    else:
        assert digest(ROOT / name) == expected, name
for name, expected in prior['inputs'].items():
    if name not in ('Sources/GiftUISemanticCore/SemanticRecordStore.swift', 'Sources/GiftUIHostConfiguration/HostScheduledOpportunityController.swift', 'Sources/GiftUIExecution/ExecutionAdmissionController.swift', 'Sources/GiftUIExecution/RecordingPresentationPendingCoordinator.swift'):
        verify_recipe_source(name, expected)
for name, expected in prior['artifacts'].items():
    assert digest(base / name) == expected['sha256'], name
command = next(shlex.split(c) for c in prior['commands'] if '-module-name RuntimeCycleProbe ' in c)
compiler = pathlib.Path(command[0])
assert digest(compiler) == prior['compiler_sha256']
flags = command[1:command.index('-module-name')]
core = pathlib.Path(flags[flags.index('-I') + 1])
core_receipt = json.loads((core / 'result.json').read_text())
macro = ROOT / core_receipt['macro_tool']
assert digest(macro) == core_receipt['macro_tool_sha256']
for name in ('GiftUI.o', 'GiftUI.swiftmodule'):
    assert digest(core / name) == core_receipt['artifacts'][name]['sha256']
host = args.host_build.resolve()
host_receipt = json.loads((host / 'result.json').read_text())
assert host_receipt['compiler_sha256'] == prior['compiler_sha256']
for name, expected in host_receipt['inputs'].items():
    if name not in ('Sources/GiftUISemanticCore/SemanticRecordStore.swift', 'Sources/GiftUIHostConfiguration/HostScheduledOpportunityController.swift', 'Sources/GiftUIExecution/ExecutionAdmissionController.swift', 'Sources/GiftUIExecution/RecordingPresentationPendingCoordinator.swift'):
        verify_recipe_source(name, expected)
for name, expected in host_receipt['artifacts'].items():
    assert digest(host / name) == expected['sha256'], name
output_root = ROOT / ('.build/raspberry-pi/contracts' if args.profile == 'raspberry-pi-armv6' else '.build/nrf52840/contracts' if is_embedded else '.build/contracts')
output_root.mkdir(parents=True, exist_ok=True)
out = pathlib.Path(tempfile.mkdtemp(prefix='p08-counter-', dir=output_root))
flags[flags.index('-module-cache-path') + 1] = str(out / 'cache')
flags = ['-I', str(out), *([] if is_target else ['-I', str(host)]), *flags]
if args.profile in ('macos-dynamic', 'raspberry-pi-armv6'):
    flags += ['-D', 'GIFTUI_COUNTER_ROUTE_DYNAMIC']
if is_embedded:
    flags += ['-Xfrontend', '-function-sections', '-Xfrontend', '-disable-stack-protector']
if args.raster_realization == 'tiled' or is_target:
    flags += ['-D', 'GIFTUI_COUNTER_TILED']
fixture = ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived'
inputs = [pathlib.Path(__file__).resolve(), revision_path, fixture / 'Counter.swift', fixture / 'Counter.schema.json', fixture / 'CounterModel.swift', fixture / 'CounterModelProbe.swift', fixture / 'CounterSemantic.swift', fixture / 'CounterSemanticProbe.swift', fixture / 'CounterGeometry.swift', fixture / 'CounterStaticGeometry.swift', fixture / 'CounterRender.swift', fixture / 'CounterFixedStorageProbe.swift']
storage_sources = sorted(fixture.glob('StaticCounter*.swift'))
join_sources = [fixture / name for name in ('CounterScopedStorage.swift', 'CounterScopedStorageProbe.swift', 'CounterAdmission.swift', 'CounterPipelineOwner.swift', 'CounterProfileStorage.swift', 'CounterStorageMeasurement.swift', 'CounterStorageRegions.swift', 'CounterCoordinatorProbe.swift', 'CounterWorkload.swift', 'CounterHostAssembly.swift', 'CounterHostOwner.swift', 'CounterHostProbe.swift', 'CounterDynamicHostOwner.swift', 'CounterDynamicHostProbe.swift', 'CounterHostCorpus.swift', 'CounterNativeRaster.swift', 'CounterTiledRaster.swift', 'CounterPixelOracle.swift', 'CounterApplication.swift', 'CounterWakeIntegration.swift', 'CounterGraphProbe.swift', 'CounterRouteEntry.swift')]
inputs.extend(join_sources)
inputs.extend(storage_sources)
commands, checks = [], []
def run(label, command, diagnostic=None):
    command = list(map(str, command))
    commands.append(shlex.join(command))
    (out / 'commands.txt').write_text('\n'.join(commands) + '\n')
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    (out / (label + '.log')).write_text(result.stdout + result.stderr)
    okay = result.returncode == 0 if diagnostic is None else result.returncode != 0 and all(value in result.stdout + result.stderr for value in diagnostic)
    checks.append(dict(name=label, exit=result.returncode, passed=okay, diagnostic=diagnostic))
    if not okay:
        raise SystemExit(f'{label}: {out}\n{result.stdout}{result.stderr}')
    return result.stdout
# Rebuild the unchanged selected runtime graph with the one newly guarded
# Semantic Core reset method. Never import the historical module as fresh source.
rebuilt_runtime = []
for old in prior['commands']:
    pieces = shlex.split(old)
    if '-module-name' not in pieces or '-emit-module' not in pieces:
        continue
    module_name = pieces[pieces.index('-module-name') + 1]
    if not module_name.startswith('GiftUI'):
        continue
    sources = [pathlib.Path(value) for value in pieces[pieces.index('-module-name') + 2:] if value.endswith('.swift')]
    inputs.extend(sources)
    run(module_name, [compiler, *flags, '-module-name', module_name, '-emit-module', '-emit-object', *sources,
                      '-emit-module-path', out / (module_name + '.swiftmodule'), '-o', out / (module_name + '.o')])
    rebuilt_runtime.append(module_name)
# The verified native host receipt supplies source recipes only on targets.
# Every lower host module is freshly compiled with the selected target flags.
if is_target:
    for old in host_receipt['commands']:
        pieces = shlex.split(old)
        if '-module-name' not in pieces or '-emit-module' not in pieces:
            continue
        name = pieces[pieces.index('-module-name') + 1]
        if name not in ('GiftUICapabilities', 'GiftUIFailureCore', 'GiftUISurfaceCore', 'GiftUIDisplayCore', 'GiftUIRasterCore', 'GiftUIBackendIntegration'):
            continue
        sources = [pathlib.Path(value) for value in pieces[pieces.index('-module-name') + 2:] if value.endswith('.swift')]
        inputs.extend(sources)
        run(name, [compiler, *flags, '-module-name', name, '-emit-module', '-emit-object', *sources,
                   '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')])
host_sources = sorted((ROOT / 'Sources/GiftUIHostConfiguration').glob('*.swift')) + sorted((ROOT / 'Sources/GiftUIHostConfiguration/Generated').glob('*.swift'))
inputs.extend(host_sources)
run('GiftUIHostConfiguration', [compiler, *flags, '-module-name', 'GiftUIHostConfiguration', '-emit-module', '-emit-object', *host_sources,
                               '-emit-module-path', out / 'GiftUIHostConfiguration.swiftmodule', '-o', out / 'GiftUIHostConfiguration.o'])
run('counter-lowering', [macro, '--lower-source', fixture / 'Counter.schema.json', fixture / 'Counter.swift',
                        out / 'CounterSchema.swift', out / 'Counter.swift', out / 'CounterTable.swift', 'P08CounterPresentation'])
for name, source in (('P08CounterSchema', 'CounterSchema.swift'), ('P08CounterPresentation', 'Counter.swift'), ('P08CounterTable', 'CounterTable.swift')):
    run(name, [compiler, *flags, '-module-name', name, '-emit-module', '-emit-object', out / source,
               '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')])
run('counter-model', [compiler, *flags, '-module-name', 'P08CounterRuntime', '-emit-module', '-emit-object',
                      fixture / 'CounterModel.swift', fixture / 'CounterModelProbe.swift', fixture / 'CounterSemantic.swift', fixture / 'CounterSemanticProbe.swift', fixture / 'CounterGeometry.swift', fixture / 'CounterStaticGeometry.swift', fixture / 'CounterRender.swift', fixture / 'CounterFixedStorageProbe.swift', *storage_sources, *join_sources,
                      '-emit-module-path', out / 'P08CounterRuntime.swiftmodule', '-o', out / 'P08CounterRuntime.o'])
# All variants use the same trusted source; each intended negative first compiles
# its exact positive twin. No stale moved-body line substitution is reused.
trusted = fixture / 'CounterScopedStorage.swift'
trusted_source = trusted.read_text()
counter_sources = [fixture / name for name in ('CounterModel.swift', 'CounterModelProbe.swift', 'CounterSemantic.swift', 'CounterSemanticProbe.swift', 'CounterGeometry.swift', 'CounterStaticGeometry.swift', 'CounterRender.swift', 'CounterFixedStorageProbe.swift')]
without_trusted = [path for path in join_sources if path != trusted]
planned_scoped_labels = []
def scoped_variant(label, source, diagnostic=None):
    path = out / (label + '.swift')
    path.write_text(trusted_source + '\n' + source + '\n')
    planned_scoped_labels.append(label)
    run(label, [compiler, *flags, '-module-name', 'P08CounterRuntime', '-emit-object', *counter_sources, *storage_sources, *without_trusted, path, '-o', out / (label + '.o')], diagnostic)
    # Positive variant objects are diagnostic controls, never extra linked owners.
    object_path = out / (label + '.o')
    if object_path.exists(): object_path.unlink()

origins = ('geometry', 'candidateRecords', 'candidateHitRegions', 'candidateCommittedRecords',
           'committedRecords', 'committedHitRegions', 'models', 'root', 'semantic', 'values', 'control', 'activationSpan')
constraints = 'where G: CounterGeometry & ~Copyable & ~Escapable, C: CounterCandidateBacking & ~Copyable & ~Escapable, R: CounterCommittedBacking & ~Copyable & ~Escapable, H: CounterHitBacking & ~Copyable & ~Escapable, C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity, H.Identity == SemanticCompleteIdentity'
for route in ('static', 'dynamic'):
    if route == 'dynamic' and is_embedded: continue
    owner = 'CounterHostOwner' if route == 'static' else 'CounterDynamicHostOwner'
    supplied = 'CounterHostSuppliedStorage' if route == 'static' else 'CounterDynamicHostSuppliedStorage'
    for mode in ('direct', 'generic'):
        types = ('P08GeometryAccess', 'P08CandidateAccess', 'P08CommittedAccess', 'P08HitAccess') if mode == 'direct' else ('G', 'C', 'R', 'H')
        generic = '' if mode == 'direct' else '<G, C, R, H>'
        where = '' if mode == 'direct' else constraints
        g, c, r, h = types
        parameters = ('geometry: consuming ' + g + ', candidateRecords: consuming ' + c + ', candidateHitRegions: consuming ' + h + ', candidateCommittedRecords: consuming ' + r + ', committedRecords: consuming ' + r + ', committedHitRegions: consuming ' + h + ', models: consuming ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: consuming ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, semantic: consuming SemanticRecordStore<CounterPayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>, control: consuming CounterHostControl, activationSpan: Span<UInt8>, assembly: CounterHostAssembly')
        result = owner + '<' + ', '.join(types) + '>'
        body = ('let state = InteractionState(candidateRecords: candidateRecords, candidateHitRegions: candidateHitRegions, candidateCommittedRecords: candidateCommittedRecords, committedRecords: committedRecords, committedHitRegions: committedHitRegions)\n'
                'let interaction = InteractionOwnedKeyState(state: state, maximumComponentsPerKey: 24, maximumComponents: 48)!\n'
                'let supplied = ' + supplied + '<' + ', '.join(types) + '>(models: models, root: root, semantic: semantic, values: values, scopedControl: control, audit: assembly.report.storageAudit, geometry: geometry, interaction: interaction)\n'
                'return ' + result + '(supplied: supplied, activationSpan: activationSpan, assembly: assembly, failAfterRuntime: false)')
        for origin in origins:
            stem = 'so06-union-' + route + '-' + mode + '-' + origin
            for negative in (False, True):
                union = ', '.join('copy ' + name for name in origins if not negative or name != origin)
                source = '@_lifetime(' + union + ')\nfileprivate func unionProbe' + generic + '(' + parameters + ') -> ' + result + ' ' + where + ' {\n' + body + '\n}'
                scoped_variant(stem + ('-negative' if negative else '-positive'), source,
                               ('lifetime', origin) if negative else None)

pairs = (
    ('counter-host-copy', 'fileprivate func probe(_ host: consuming P08StaticHost) { _ = consume host }', 'fileprivate func probe(_ host: borrowing P08StaticHost) { let duplicate = copy host; _ = duplicate }', ("'copy' cannot be applied to noncopyable types",)),
    ('counter-host-backing', 'fileprivate func probe(_ owner: inout P08TypedBackingOwner) -> Int { withP08Storage(backing: &owner) { session in var current = consume session; current.reset(); return 1 } }', 'fileprivate func probe(_ owner: inout P08TypedBackingOwner) -> Int { var escaped: P08StorageSession? = nil; _ = withP08Storage(backing: &owner) { session in escaped = consume session; return 1 }; var current = escaped.take()!; current.reset(); return 1 }', ('lifetime', 'escaped')),
    ('so06-use-after-consume', 'fileprivate func probe(_ input: consuming P08StorageSession) { var first = consume input; first.reset() }', 'fileprivate func probe(_ input: consuming P08StorageSession) { let first = consume input; let second = consume input; _ = consume first; _ = consume second }', ('consumed',)),
    ('so06-owned-return', 'fileprivate func probe(_ pipeline: consuming CounterPipelineOwner<StaticCounterGeometry, CounterStaticCandidate, CounterStaticCommitted, CounterStaticHits>) -> Int { pipeline.returnWorkspaces(checks: 1).checks }', 'fileprivate func probe(_ pipeline: consuming CounterPipelineOwner<P08GeometryAccess, P08CandidateAccess, P08CommittedAccess, P08HitAccess>) -> Int { pipeline.returnWorkspaces(checks: 1).checks }', ('Copyable', 'returnWorkspaces')),
    ('so06-private-construction', '@_lifetime(copy token)\nfileprivate func probe(_ token: borrowing P08SessionLifetime, _ descriptor: P08GeometryDescriptor) -> P08GeometryAccess { P08GeometryAccess.lend(sessionLifetime: token, descriptor: descriptor) }', '@_lifetime(copy token)\nfileprivate func probe(_ token: borrowing P08SessionLifetime, _ descriptor: P08GeometryDescriptor) -> P08GeometryAccess { P08GeometryAccess(sessionLifetime: token, descriptor: descriptor) }', ('private',)),
    ('so06-private-extraction', 'fileprivate func probe(_ session: borrowing P08StorageSession) -> Int { 1 }', 'fileprivate func probe(_ session: borrowing P08StorageSession) -> Int { session.interaction.committedRecordCount }', ('private', 'interaction')),
    ('so06-arbitrary-factory', 'fileprivate func probe(_ owner: inout P08TypedBackingOwner) -> Int { withP08Storage(backing: &owner) { session in var current = consume session; current.reset(); return 1 } }', 'fileprivate struct ForeignOwner: ~Copyable {}\nfileprivate func probe(_ owner: inout ForeignOwner) -> Int { withP08Storage(backing: &owner) { session in var current = consume session; current.reset(); return 1 } }', ('P08TypedBackingOwner', 'ForeignOwner')),
    ('so06-optional-erasure', 'fileprivate struct Box<T: ~Copyable>: ~Copyable { var value: T? }\nfileprivate func probe(_ value: Int) { _ = Box(value: value) }', 'fileprivate struct Box<T: ~Copyable>: ~Copyable { var value: T? }\nfileprivate func probe(_ value: consuming P08StorageSession) { _ = Box(value: value) }', ('Escapable',)),
    ('so06-tuple-erasure', 'fileprivate func probe(_ value: Int) -> (Int, Int) { (value, 1) }', 'fileprivate func probe(_ value: consuming P08StorageSession) -> (P08StorageSession, Int) { (value, 1) }', ('Escapable',)),
    ('so06-generic-erasure', 'fileprivate func erase<T: ~Copyable>(_ value: consuming T) {}\nfileprivate func probe(_ value: Int) { erase(value) }', 'fileprivate func erase<T: ~Copyable>(_ value: consuming T) {}\nfileprivate func probe(_ value: consuming P08StorageSession) { erase(value) }', ('Escapable',)),
    ('so06-closure-erasure', 'fileprivate func probe(_ value: Int) -> () -> Int { { value } }', 'fileprivate func probe(_ input: consuming P08StorageSession) -> () -> Int { var value = consume input; return { value.reset(); return 1 } }', ('escaping',)),
    ('so06-sendable', 'fileprivate func send<T: Sendable & ~Copyable & ~Escapable>(_ value: borrowing T) {}\nfileprivate func probe(_ value: Int) { send(value) }', 'fileprivate func send<T: Sendable & ~Copyable & ~Escapable>(_ value: borrowing T) {}\nfileprivate func probe(_ value: borrowing P08StorageSession) { send(value) }', ('Sendable',)),
    ('so06-static-overlap', 'fileprivate func probe(_ owner: inout P08TypedBackingOwner) -> Int { let count = withP08Storage(backing: &owner) { session in var current = consume session; current.reset(); return 1 }; owner.release(); return count }', 'fileprivate func probe(_ owner: inout P08TypedBackingOwner) -> Int { withP08Storage(backing: &owner) { session in owner.release(); var current = consume session; current.reset(); return 1 } }', ('overlapping accesses',)),
)
for stem, positive, negative, diagnostic in pairs:
    scoped_variant(stem + '-positive', positive)
    scoped_variant(stem + '-negative', negative, diagnostic)
if not is_embedded:
    scoped_variant('counter-dynamic-host-backing-positive', 'fileprivate func probe(_ owner: inout P08TypedBackingOwner) -> Int { withP08Storage(backing: &owner) { session in var current = consume session; current.reset(); return 1 } }')
    scoped_variant('counter-dynamic-host-backing-negative', 'fileprivate func probe(_ owner: inout P08TypedBackingOwner) -> Int { var escaped: P08StorageSession? = nil; _ = withP08Storage(backing: &owner) { session in escaped = consume session; return 1 }; var current = escaped.take()!; current.reset(); return 1 }', ('lifetime', 'escaped'))
    for stem, positive, negative in (
        ('so06-task', 'fileprivate func probe(_ value: Int) { _ = Task { value } }', 'fileprivate func probe(_ input: consuming P08StorageSession) { _ = Task { _ = consume input; return 1 } }'),
        ('so06-async', 'fileprivate func probe(_ input: consuming P08StorageSession) -> Int { var value = consume input; value.reset(); return 1 }', 'fileprivate func probe(_ input: consuming P08StorageSession) async -> Int { var value = consume input; value.reset(); return 1 }'),
    ):
        scoped_variant(stem + '-positive', positive)
        scoped_variant(stem + '-negative', negative, ('Escapable',))
if not is_target:
    main = out / 'Main.swift'
    expression = 'p08CounterRoute() + p08CounterModel() + p08CounterSemantic() + p08CounterFixedStorage() + p08CounterCoordinator()' if args.profile else 'p08CounterGraph() + p08CounterModel() + p08CounterSemantic() + p08CounterFixedStorage() + p08CounterScopedStorage() + p08CounterCoordinator() + p08CounterHost() + p08CounterDynamicHost()'
    main.write_text('import P08CounterRuntime\nimport Darwin\n@main struct Main { static func main() { setbuf(stdout, nil); print("P08 counter components assertions=\\(' + expression + ') failures=0") } }\n')
    host_objects = [path for path in sorted(host.glob('GiftUI*.o')) if path.name != 'GiftUIHostConfiguration.o']
    run('link', [compiler, *flags, main, core / 'GiftUI.o', *host_objects, *sorted(out.glob('*.o')), '-o', out / 'counter'])
    execution = run('execute', [out / 'counter']).strip()
    trap_flags = [*flags, '-D', 'GIFTUI_COUNTER_NATIVE_EXCLUSIVITY']
    run('so06-native-exclusivity-module', [compiler, *trap_flags, '-module-name', 'P08CounterNativeExclusivity', '-emit-module', '-emit-object', *counter_sources, *storage_sources, *join_sources, '-emit-module-path', out / 'P08CounterNativeExclusivity.swiftmodule', '-o', out / 'P08CounterNativeExclusivity.o'])
    trap_objects = [path for path in sorted(out.glob('*.o')) if path.name != 'P08CounterRuntime.o']
    for negative in (False, True):
        stem = 'so06-native-exclusivity-' + ('negative' if negative else 'positive')
        main = out / (stem + '.swift')
        main.write_text('import P08CounterNativeExclusivity\n@main struct Main { @MainActor static func main() { let count = p08CounterScopedExclusivity(negative: ' + ('true' if negative else 'false') + '); precondition(count == 1) } }\n')
        run(stem + '-link', [compiler, *trap_flags, main, core / 'GiftUI.o', *host_objects, *trap_objects, '-o', out / stem])
        run(stem + '-execute', [out / stem], ('Simultaneous accesses', 'Fatal access conflict') if negative else None)

else:
    execution = 'cross-compiled current selected counter host only; no target execution or linked-image claim'
    (out / 'objects.list').write_text('\n'.join(map(str, [core / 'GiftUI.o', *sorted(out.glob('*.o'))])) + '\n')
receipt = dict(scope=__doc__, raster_realization="tiled" if is_target else args.raster_realization, profile=prior['profile'], selected_host_profile=args.profile, target_flags=flags, embedded_dynamic_escape_applicable=not is_embedded, compiler=str(compiler.relative_to(ROOT)), compiler_sha256=digest(compiler), runtime_build=str(base.relative_to(ROOT)), runtime_receipt_sha256=digest(base / 'result.json'), host_build=str(host.relative_to(ROOT)), host_receipt_sha256=digest(host / 'result.json'), inputs={str(p.relative_to(ROOT)): digest(p) for p in inputs}, commands=commands, checks=checks, planned_scoped_labels=planned_scoped_labels, execution=execution)
receipt['scoped_negative_source'] = str(trusted.relative_to(ROOT))
receipt['artifacts'] = {str(p.relative_to(out)): dict(sha256=digest(p), bytes=p.stat().st_size) for p in out.iterdir() if p.is_file()}
(out / 'result.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(execution.splitlines()[-1])
print('P08_COUNTER_EVIDENCE', out)
