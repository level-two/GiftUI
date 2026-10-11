#!/usr/bin/env python3
"""P02 declaration/lowering exit followed by the registered P04 component checks."""
import argparse
import hashlib
import json
import pathlib
import re
import shlex
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
FIXTURE = ROOT / 'Tests/ContractFixtures/SPEC006/RuntimeDerived'
PROFILES = ('macos-dynamic', 'macos-static', 'raspberry-pi-armv6', 'nrf52840-embedded')
parser = argparse.ArgumentParser()
parser.add_argument('--profile', required=True, choices=PROFILES)
args = parser.parse_args()
profile = args.profile
host_compiler = ROOT / '.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swiftc'
compiler = (ROOT / '.toolchains/nrf52840/swift/swift-6.4.0-RELEASE-osx/usr/bin/swiftc'
            if profile == 'nrf52840-embedded' else host_compiler)
inputs = sorted(set(list((ROOT / 'Sources/GiftUI').glob('*.swift'))
                    + list((ROOT / 'Sources/GiftUIMacros').glob('*.swift'))
                    + list(FIXTURE.rglob('*'))
                    + list((ROOT / 'Tests/ContractFixtures/SPEC010/MacroExpansion').rglob('*'))
                    + list((ROOT / 'Sources/SignalAnalyzerDomain').glob('*.swift'))
                    + [ROOT / 'Package.swift', ROOT / 'Package.resolved',
                       ROOT / 'scripts/raspberry-pi/toolchain.env', ROOT / 'scripts/nrf52840/toolchain.env',
                       pathlib.Path(__file__).resolve(),
                       ROOT / 'scripts/contracts/run-spec-006.sh',
                       ROOT / 'scripts/contracts/compiler-baseline.sh']))
input_hashes = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                for p in inputs if p.is_file()}
source_commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()
compiler_hash = hashlib.sha256(compiler.read_bytes()).hexdigest()
identity = hashlib.sha256(json.dumps({'inputs': input_hashes, 'commit': source_commit,
                                     'compiler': compiler_hash}, sort_keys=True).encode()).hexdigest()
parent = ROOT / '.build'
if profile == 'raspberry-pi-armv6':
    parent /= 'raspberry-pi'
elif profile == 'nrf52840-embedded':
    parent /= 'nrf52840'
parent /= 'contracts/spec-006-rfc-014-swift64'
parent.mkdir(parents=True, exist_ok=True)
# A new receipt never overwrites an earlier run, including dirty-tree experiments.
out = pathlib.Path(tempfile.mkdtemp(prefix=identity[:16] + '-', dir=parent)) / profile
out.mkdir()
commands = []
checks = []

def run(label, command, failure=None):
    command = [str(part) for part in command]
    commands.append(shlex.join(command))
    (out / 'commands.txt').write_text('\n'.join(commands) + '\n')
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    (out / (label + '.log')).write_text(result.stdout + result.stderr)
    okay = result.returncode == 0 if failure is None else result.returncode != 0 and failure in result.stdout + result.stderr
    checks.append({'check': label, 'pass': okay, 'exit': result.returncode})
    if not okay:
        raise SystemExit(f'{label} failed; see {out / (label + ".log")}\n{result.stdout[-2000:]}{result.stderr[-4000:]}')
    return result.stdout + result.stderr

version = run('compiler-version', [compiler, '--version'])
assert 'Apple Swift version 6.4 (swift-6.4-RELEASE)' in version
flags = ['-swift-version', '6', '-Osize', '-whole-module-optimization',
         '-enable-experimental-feature', 'LifetimeDependence',
         '-enable-experimental-feature', 'Lifetimes', '-package-name', 'giftui',
         '-module-cache-path', out / 'cache', '-disable-sandbox']
if profile.startswith('macos'):
    sdk = subprocess.check_output(['xcrun', '--sdk', 'macosx', '--show-sdk-path'], text=True).strip()
    flags += ['-target', 'arm64-apple-macosx26.0', '-sdk', sdk]
    if profile == 'macos-dynamic':
        flags += ['-D', 'GIFTUI_DYNAMIC_PROFILE']
elif profile == 'raspberry-pi-armv6':
    sdk = ROOT / '.toolchains/sdk/swift-6.4.0-RELEASE-raspios-bookworm-armv6/raspios-bookworm'
    flags += ['-target', 'armv6-unknown-linux-gnueabihf', '-sdk', sdk,
              '-resource-dir', sdk / 'usr/lib/swift_static', '-use-ld=lld',
              '-Xcc', f'--gcc-toolchain={sdk / "usr"}', '-Xcc', '-march=armv6',
              '-Xcc', '-mfloat-abi=hard', '-Xcc', '-mfpu=vfp']
else:
    flags += ['-target', 'armv7em-none-none-eabi', '-enable-experimental-feature', 'Embedded',
              '-Xcc', '-mcpu=cortex-m4', '-Xcc', '-mfloat-abi=hard', '-Xcc', '-mfpu=fpv4-sp-d16']
run('required-features', [compiler, *flags, '-typecheck', ROOT / 'Tests/ContractFixtures/SPEC002/CompilerBaseline/RequiredFeatures.swift'])
# Build the existing target, which links its existing macro executable as a dependency.
run('host-macro-build', ['bash', '-c', '''set -e
source scripts/lib/swiftpm.sh
GIFTUI_SWIFT_EXECUTABLE="$PWD/.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swift" giftui_swiftpm --package-path "$PWD" --scratch-path "$PWD/.build/rfc014-p02-swift64/tool" --cache-root "$PWD/.build/rfc014-p02-swift64/tool-cache" --configuration debug --target GiftUI --disable-sandbox -- build
'''])
macro = ROOT / '.build/rfc014-p02-swift64/tool/debug/GiftUIMacros-tool'
flags += ['-load-plugin-executable', str(macro) + '#GiftUIMacros']
# Use the exact SwiftSyntax prebuilt selected by SwiftPM for this macro tool.
plan = json.loads((macro.parent / 'plugin-tools-description.json').read_text())
macro_command = next(value for value in plan['swiftCommands'].values() if value['moduleName'] == 'GiftUIMacros')
macro_arguments = macro_command['otherArguments']
syntax_modules = next(pathlib.Path(macro_arguments[i + 1]) for i, flag in enumerate(macro_arguments[:-1])
                      if flag == '-I' and '/prebuilts/swift-syntax/' in macro_arguments[i + 1])
syntax_library = syntax_modules.parent / 'lib/libMacroSupport.a'
macro_imports = [part for i, flag in enumerate(macro_arguments[:-1]) if flag == '-I'
                 for part in ('-I', macro_arguments[i + 1])]
host_checks = out / 'macro-checks'
run('macro-check-build', [host_compiler, '-swift-version', '6', '-target', 'arm64-apple-macosx15.0',
                         '-module-cache-path', out / 'cache', '-disable-sandbox',
                         *macro_imports, '-parse-as-library',
                         FIXTURE / 'MacroChecks.swift', ROOT / 'Sources/GiftUIMacros/ObservableStateHostMacro.swift',
                         syntax_library, '-o', host_checks])
run('macro-fixtures', [host_checks, ROOT / 'Tests/ContractFixtures/SPEC010/MacroExpansion'])


def module(name, sources):
    run(name, [compiler, *flags, '-I', out, '-parse-as-library', '-module-name', name,
               '-emit-module', '-emit-object', *sources,
               '-emit-module-path', out / (name + '.swiftmodule'), '-o', out / (name + '.o')])

module('GiftUI', sorted((ROOT / 'Sources/GiftUI').glob('*.swift')))
run('counter-lowering', [macro, '--lower-source', FIXTURE / 'Counter.schema.json', FIXTURE / 'Counter.swift',
                         out / 'CounterSchema.swift', out / 'CounterPresentation.swift'])
module('CounterSchema', [out / 'CounterSchema.swift'])
module('CounterPresentation', [out / 'CounterPresentation.swift'])
module('SignalAnalyzerDomain', [ROOT / 'Sources/SignalAnalyzerDomain' / name for name in
                                 ['SignalPrimitiveValues.swift', 'AcquisitionState.swift', 'SignalAnalyzerDiagnostic.swift']])
run('analyzer-lowering', [macro, '--lower-source', FIXTURE / 'Analyzer.schema.json', FIXTURE / 'Analyzer.swift',
                          out / 'AnalyzerSchema.swift', out / 'AnalyzerPresentation.swift'])
module('AnalyzerSchema', [out / 'AnalyzerSchema.swift'])
module('AnalyzerPresentation', [out / 'AnalyzerPresentation.swift'])
module('DeclarationHost', [FIXTURE / 'DeclarationHost.swift'])
if profile.startswith('macos'):
    run('native-link', [compiler, *flags, '-I', out, '-parse-as-library', FIXTURE / 'Main.swift',
                        *[out / (name + '.o') for name in ['GiftUI', 'CounterSchema', 'CounterPresentation', 'SignalAnalyzerDomain', 'AnalyzerSchema', 'AnalyzerPresentation', 'DeclarationHost']],
                        '-o', out / 'declarations'])
    execution = run('native-execution', [out / 'declarations']).strip()
    assert 'failures=0' in execution
else:
    readelf = ROOT / '.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-readelf'
    abi = run('target-abi', [readelf, '-h', '-A', out / 'DeclarationHost.o'])
    assert 'Machine:' in abi and 'ARM' in abi and 'Tag_ABI_VFP_args: VFP registers' in abi
    architecture = 'v6' if profile == 'raspberry-pi-armv6' else 'v7E-M'
    assert re.search(r'Tag_CPU_arch: ' + architecture + r'\s*$', abi, re.MULTILINE)
    execution = 'cross-compiled; no target execution'

negative_sources = {
    'owned-facade-escape': ('non-Escapable', """import GiftUI
        import CounterSchema
        package struct Escape<D: CounterReadDomain> { let read: CounterRead<D> }
    """),
    'custom-body-domain': ('does not conform', """import GiftUI
        enum A: _GiftUIReadDomain { typealias Slot = UInt8 }
        enum B: _GiftUIReadDomain { typealias Slot = UInt8 }
        struct Wrong: View {
            typealias Domain = A
            func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<A>) throws(_GiftUIAccessFailure) -> some View<B> { Text<B>("wrong") }
        }
    """),
    'mixed-domains': ('be equivalent', '''import GiftUI
        enum A: _GiftUIReadDomain { typealias Slot = UInt8 }
        enum B: _GiftUIReadDomain { typealias Slot = UInt8 }
        @ViewBuilder func mixed() -> some View { Text<A>("a"); Text<B>("b") }
    '''),
    'missing-body': ('does not conform', '''import GiftUI
        struct Missing: View { typealias Domain = _GiftUIEmptyReadDomain }
    '''),
    'six-children': ('extra argument', '''import GiftUI
        @ViewBuilder func excess() -> some View {
            Text<_GiftUIEmptyReadDomain>("a"); Text<_GiftUIEmptyReadDomain>("b")
            Text<_GiftUIEmptyReadDomain>("c"); Text<_GiftUIEmptyReadDomain>("d")
            Text<_GiftUIEmptyReadDomain>("e"); Text<_GiftUIEmptyReadDomain>("f")
        }
    '''),
    'escaping-read': ('escaping', '''import GiftUI
        func escape<D: _GiftUIReadDomain>(_ read: borrowing _GiftUIFrameRead<D>) -> () -> D.Slot {
            { read.slots[0] }
        }
    '''),
}
for name, (diagnostic, source) in negative_sources.items():
    path = out / (name + '.swift')
    path.write_text(source)
    run(name, [compiler, *flags, '-I', out, '-parse-as-library', '-emit-object', path, '-o', out / (name + '.o')], failure=diagnostic)

negative_schema = out / 'negative-schema.json'
configuration = json.loads((FIXTURE / 'Counter.schema.json').read_text())
configuration['calls'] = []
negative_schema.write_text(json.dumps(configuration))
for name, source, diagnostic in [
    ('unknown-effect', 'externalService.start()', "unsupported call/effect 'externalService.start'"),
    ('unchecked-inout', 'Text(&value)', 'unchecked inout'),
    ('disguised-effect', 'externalService.frame()', "unsupported call/effect 'externalService.frame'"),
    ('unknown-model-member', 'model.service', "has no checked schema operation"),
]:
    path = out / (name + '.swift')
    path.write_text('import GiftUI\nstruct Bad: View { let model: CounterModel; var body: some View {\n' + source + '\nText("bad")\n} }\n')
    diagnostic_output = run(name, [macro, '--lower-source', negative_schema, path,
               out / (name + '-schema.swift'), out / (name + '-presentation.swift')], failure=diagnostic)
    assert re.search(re.escape(str(path)) + r':\d+:\d+: error:', diagnostic_output)
    assert not (out / (name + '-presentation.swift')).exists()

outside_flags = flags.copy()
position = outside_flags.index('-package-name')
del outside_flags[position:position + 2]
for name, source in [
    ('private-key-construction', 'let key = _GiftUIModelKey<UInt8>(ownerInstance: 1, allocationGeneration: 1, slot: 0)'),
    ('private-read-construction', 'func make(_ slots: Span<UInt8>) { _ = _GiftUIFrameRead<_GiftUIEmptyReadDomain>(slots: slots) }'),
]:
    path = out / (name + '.swift')
    path.write_text('import GiftUI\n' + source + '\n')
    run(name, [compiler, *outside_flags, '-I', out, '-parse-as-library', '-emit-object', path, '-o', out / (name + '.o')], failure='inaccessible')
assert 'func counterText<' not in (out / 'CounterPresentation.swift').read_text()

report = {'package': 'P02', 'profile': profile, 'source_commit': source_commit,
          'input_sha256': identity, 'inputs': input_hashes, 'compiler': str(compiler.relative_to(ROOT)),
          'compiler_sha256': compiler_hash, 'version': version.strip(),
          'macro_tool': str(macro.relative_to(ROOT)),
          'macro_tool_sha256': hashlib.sha256(macro.read_bytes()).hexdigest(),
          'swift_syntax_library': str(syntax_library.relative_to(ROOT)),
          'swift_syntax_sha256': hashlib.sha256(syntax_library.read_bytes()).hexdigest(),
          'execution': execution, 'checks': checks,
          'artifacts': {p.name: {'sha256': hashlib.sha256(p.read_bytes()).hexdigest(), 'bytes': p.stat().st_size}
                        for p in out.iterdir() if p.suffix in ('.swiftmodule', '.o', '.swift')
                        or p.name in ('declarations', 'macro-checks')}}
(out / 'result.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
print(f'P02 {profile}: {len(checks)} checks passed; {execution}; {out / "result.json"}')

# Keep the existing four-profile owner route explicit during staged migration.
subprocess.run(["python3", str(ROOT / "scripts/contracts/check-spec-006-runtime-records.py"),
                "--giftui-build", str(out)], cwd=ROOT, check=True)
