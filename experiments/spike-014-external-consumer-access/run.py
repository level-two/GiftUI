#!/usr/bin/env python3
"""Disposable compile/access evidence; does not build a host or alter GiftUI."""
import hashlib
import json
from pathlib import Path
import shlex
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / '.build/iteration-003/spike-014'
OUTPUT.mkdir(parents=True, exist_ok=True)
SOURCES = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def execute(name, command, output=OUTPUT):
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, timeout=120)
    log = result.stdout + result.stderr
    (output / (name + '.log')).write_text(log)
    return {'command': command, 'exit_code': result.returncode, 'log': str((output / (name + '.log')).relative_to(ROOT)), 'log_sha256': digest(output / (name + '.log'))}, log


manifest_result, manifest_log = execute('manifest', ['bash', '-c',
    'source scripts/lib/swiftpm.sh\ngiftui_swiftpm --package-path ' + shlex.quote(str(ROOT))
    + ' --cache-root ' + shlex.quote(str(OUTPUT / 'cache'))
    + ' --disable-sandbox -- package dump-package'])
if manifest_result['exit_code']:
    print(manifest_log)
    raise SystemExit(manifest_result['exit_code'])
manifest = json.loads((OUTPUT / 'manifest.log').read_text().split('swiftpm-command:')[0])
products = {p['name']: p['targets'] for p in manifest['products']}
needed = ['GiftUIRuntimeCore', 'GiftUIRuntimeDynamic', 'GiftUIRuntimeStatic', 'GiftUISurfaceCore', 'GiftUIRasterCore', 'GiftUIDisplayCore', 'GiftUIBackendIntegration', 'GiftUIHostConfiguration']
exported = {target for targets in products.values() for target in targets}
summary = {
    'repository_revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
    'manifest': manifest_result, 'products': products,
    'needed_modules_without_direct_product': [name for name in needed if name not in exported],
    'inputs': {str(p.relative_to(ROOT)): digest(p) for p in SOURCES.glob('*') if p.is_file()},
    'probes': [],
}
native_compiler = shutil.which('swiftc')
nrf_compiler = ROOT / '.toolchains/nrf52840/swift/swift-6.3.2-RELEASE-osx/usr/bin/swiftc'
native_modules = ROOT / '.build/arm64-apple-macosx/debug/Modules'
nrf_modules = ROOT / '.build/nrf52840/signal-analyzer-static/swift-modules'
for profile, compiler, module_paths, flags in [
    ('native', native_compiler, [native_modules], []),
    ('embedded', str(nrf_compiler), sorted(p for p in nrf_modules.iterdir() if p.is_dir()), [
        '-target', 'armv7em-none-none-eabi', '-enable-experimental-feature', 'Embedded', '-wmo', '-Osize',
        '-Xcc', '-mcpu=cortex-m4', '-Xcc', '-mthumb', '-Xcc', '-mabi=aapcs', '-Xcc', '-mfpu=fpv4-sp-d16', '-Xcc', '-mfloat-abi=hard']),
]:
    output = OUTPUT / profile if profile == 'native' else ROOT / '.build/nrf52840/spike-014'
    output.mkdir(parents=True, exist_ok=True)
    version = subprocess.check_output([compiler, '--version'], cwd=ROOT, text=True).strip()
    includes = [arg for path in module_paths for arg in ['-I', str(path)]]
    module_hashes = {str(p.relative_to(ROOT)): digest(p) for path in module_paths for p in path.glob('GiftUI*.swiftmodule')}
    for source, diagnostic in [('PortableCounter.swift', None), ('DisplayAccess.swift', 'DisplayTarget'), ('HostAccess.swift', 'HostPresetBootstrap')]:
        name = Path(source).stem
        object_file = output / (name + '.o')
        command = [compiler, '-parse-as-library', '-module-name', 'IndependentCounter', '-package-name', 'IndependentCounter', '-module-cache-path', str(output / 'module-cache'), *flags, *includes, '-c', str(SOURCES / source), '-o', str(object_file)]
        result, log = execute(name, command, output)
        classification = 'positive-object' if diagnostic is None and result['exit_code'] == 0 and object_file.exists() else 'inconclusive'
        if diagnostic and result['exit_code'] != 0 and diagnostic in log and ('inaccessible' in log or 'no type named' in log or 'no member named' in log):
            classification = 'expected-access-barrier'
        if diagnostic is None and result['exit_code'] != 0 and 'not supported in embedded Swift' in log:
            classification = 'embedded-declaration-barrier'
        summary['probes'].append({'profile': profile, 'source': source, 'compiler_version': version, 'classification': classification, 'module_sha256': module_hashes, **result, 'object_sha256': digest(object_file) if result['exit_code'] == 0 and object_file.exists() else None})
        print(profile, source, classification, result['exit_code'])
(OUTPUT / 'results.json').write_text(json.dumps(summary, indent=2) + '\n')
if any(p['classification'] == 'inconclusive' for p in summary['probes']):
    raise SystemExit(1)
