#!/usr/bin/env python3
"""SPIKE-075: explicit run-1 continuation, one helper correction, no further repairs."""
from pathlib import Path
import datetime
import hashlib
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import time
import uuid

ROOT = Path(__file__).resolve().parents[2]
FIXTURE = Path(__file__).resolve().parent
if sys.argv[1:] != ['--continue-run-1']:
    sys.exit('Initial SPIKE-075 package is closed; only --continue-run-1 is supported.')
PARENT_EVIDENCE = FIXTURE / 'evidence/run-1'
EXPERIMENT_LIMIT = 30
RUN_ID = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ-') + uuid.uuid4().hex[:8]
RUN = ROOT / '.build/spike-075' / RUN_ID
RUN.mkdir(parents=True, exist_ok=False)
RECEIPT = RUN / 'receipt.json'
receipt = dict(run_id=RUN_ID, status='preparing', repair_rounds=1, further_repair_limit=0,
               experiment_limit=EXPERIMENT_LIMIT, identity_limit=2, deadline_seconds=1200,
               invocations=[], hashes={}, profile_outputs={})
first_compiler = None
experiments = 0
identities = 0


def save():
    temp = RECEIPT.with_suffix('.tmp')
    temp.write_text(json.dumps(receipt, indent=2) + '\n')
    temp.replace(RECEIPT)


def sha(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def tree_sha(path):
    # Hash all regular SDK files, with relative names; include symlink targets.
    digest = hashlib.sha256()
    count = 0
    for child in sorted(path.rglob('*')):
        relative = str(child.relative_to(path))
        if child.is_symlink():
            digest.update((relative + '\0link\0' + os.readlink(child) + '\n').encode())
        elif child.is_file():
            digest.update((relative + '\0' + sha(child) + '\n').encode())
            count += 1
    return dict(path=str(path), tree_sha256=digest.hexdigest(), regular_files=count)


def verify_parent():
    # This preflight performs no subprocess/compiler invocation and never repairs.
    parent_path = PARENT_EVIDENCE / 'receipt.json'
    receipt.update(parent_receipt=str(parent_path), parent_receipt_sha256=sha(parent_path),
                   parent_experiment_invocations=3, parent_identity_queries=1,
                   parent_failed_experiment='macos-dynamic/copy-negative',
                   cumulative_experiment_invocations=3, cumulative_identity_queries=1,
                   cumulative_repair_rounds=1, cumulative_experiment_limit=33,
                   cumulative_identity_limit=3,
                   fixture_correction='requireCopy<T: Copyable & ~Escapable>(_ value: borrowing T)')
    save()
    evidence_hashes = json.loads((PARENT_EVIDENCE / 'SHA256.json').read_text())
    for relative, expected in evidence_hashes.items():
        if sha(PARENT_EVIDENCE / relative) != expected:
            raise RuntimeError('parent evidence hash mismatch: ' + relative)
    parent = json.loads(parent_path.read_text())
    if (parent['status'] != 'stopped' or parent['experiment_invocations'] != 3
            or parent['identity_queries'] != 1 or parent['repair_rounds'] != 0):
        raise RuntimeError('unexpected parent disposition/counts')
    parent_native = Path(parent['profile_outputs']['macos-dynamic'])
    original_sources = parent_native.parent / 'sources'
    old_helper = 'func requireCopy<T: Copyable>(_ value: T)'
    new_helper = 'func requireCopy<T: Copyable & ~Escapable>(_ value: borrowing T)'
    original_swift = {Path(name).name: digest for name, digest in parent['hashes'].items()
                      if name.endswith('.swift')}
    if {path.name for path in FIXTURE.glob('*.swift')} != set(original_swift):
        raise RuntimeError('Swift input set differs from parent')
    for name, expected in original_swift.items():
        original = original_sources / name
        if sha(original) != expected:
            raise RuntimeError('original source snapshot hash mismatch: ' + name)
        current = FIXTURE / name
        if name == 'CopyNegative.swift':
            original_bytes = original.read_bytes()
            if original_bytes.count(old_helper.encode()) != 1:
                raise RuntimeError('original copy helper shape mismatch')
            if current.read_bytes() != original_bytes.replace(old_helper.encode(), new_helper.encode()):
                raise RuntimeError('copy fixture differs beyond the one agreed helper correction')
        elif sha(current) != expected:
            raise RuntimeError('unchanged Swift input hash mismatch: ' + name)
    manifest = json.loads((PARENT_EVIDENCE / 'emitted-artifacts.json').read_text())
    expected_native = {str((parent_native / name).relative_to(ROOT)) for name in (
        'P08Shadow.swiftmodule', 'P08Shadow.swiftdoc', 'P08Shadow.swiftsourceinfo',
        'P08Shadow.abi.json',
        'shadow.o', 'positive.o')}
    if set(manifest['artifacts']) != expected_native:
        raise RuntimeError('parent native artifact set mismatch')
    actual_module_files = {str(path.relative_to(ROOT))
                           for path in parent_native.glob('P08Shadow.*') if path.is_file()}
    if actual_module_files != {name for name in expected_native if '/P08Shadow.' in name}:
        raise RuntimeError('whole parent native module artifact set mismatch')
    for name, expected in manifest['artifacts'].items():
        path = ROOT / name
        if path.stat().st_size != expected['bytes'] or sha(path) != expected['sha256']:
            raise RuntimeError('parent emitted artifact hash mismatch: ' + name)
    # Original runner/docs remain available in the untouched original snapshot.
    for name, expected in parent['hashes'].items():
        if name.startswith(str(FIXTURE.relative_to(ROOT)) + '/'):
            if sha(original_sources / Path(name).name) != expected:
                raise RuntimeError('original package snapshot hash mismatch: ' + name)
        elif sha(ROOT / name) != expected:
            raise RuntimeError('compiler/configuration baseline hash mismatch: ' + name)
    receipt.update(parent_receipt=str(parent_path), parent_receipt_sha256=sha(parent_path),
                   parent_experiment_invocations=3, parent_identity_queries=1,
                   parent_failed_experiment='macos-dynamic/copy-negative',
                   fixture_correction='requireCopy<T: Copyable & ~Escapable>(_ value: borrowing T)',
                   cumulative_experiment_invocations=3, cumulative_identity_queries=1,
                   cumulative_repair_rounds=1, cumulative_experiment_limit=33,
                   cumulative_identity_limit=3, verified_parent_artifacts=manifest['artifacts'],
                   reused_checks=['macos-dynamic/shadow-module', 'macos-dynamic/positive'])
    save()
    return parent, parent_native


def invoke(label, command, directory, kind='setup'):
    global first_compiler, experiments, identities
    if kind != 'setup':
        if first_compiler is None:
            first_compiler = time.monotonic()
            receipt['first_compiler_utc'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
        if time.monotonic() - first_compiler >= 1200:
            raise RuntimeError('20-minute compiler deadline reached')
        if kind == 'experiment':
            if experiments >= EXPERIMENT_LIMIT:
                raise RuntimeError('30 continuation experiment invocation ceiling reached')
            experiments += 1
        else:
            if identities >= 2:
                raise RuntimeError('two identity query ceiling reached')
            identities += 1
    remaining = 1200 if first_compiler is None else 1200 - (time.monotonic() - first_compiler)
    timeout = min(180, remaining)
    directory.mkdir(parents=True, exist_ok=True)
    stdout_path = directory / (label + '.stdout')
    stderr_path = directory / (label + '.stderr')
    entry = dict(label=label, kind=kind, command=list(map(str, command)), cwd=str(ROOT),
                 timeout_seconds=timeout, status='recorded-before-spawn',
                 stdout=str(stdout_path), stderr=str(stderr_path))
    receipt['invocations'].append(entry)
    receipt.update(experiment_invocations=experiments, identity_queries=identities,
                   cumulative_experiment_invocations=3 + experiments,
                   cumulative_identity_queries=1 + identities)
    save()
    start = time.monotonic()
    with stdout_path.open('xb') as stdout, stderr_path.open('xb') as stderr:
        try:
            process = subprocess.Popen(entry['command'], cwd=ROOT, stdout=stdout, stderr=stderr,
                                       start_new_session=True)
            entry['pid'] = process.pid
            entry['status'] = 'running'
            save()
            try:
                entry['exit_code'] = process.wait(timeout=timeout)
                entry['status'] = 'exited'
            except BaseException:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
                entry['status'] = 'interrupted-or-timeout'
                entry['exit_code'] = process.returncode
                raise
        finally:
            entry['elapsed_seconds'] = time.monotonic() - start
            save()
    output = stdout_path.read_text(errors='replace') + stderr_path.read_text(errors='replace')
    if first_compiler is not None and time.monotonic() - first_compiler >= 1200:
        raise RuntimeError('20-minute deadline reached after invocation')
    if entry['exit_code'] < 0 or re.search(r'Stack dump:|PLEASE submit a bug|Program arguments:|Assertion.*failed|Segmentation fault|signal [0-9]+', output, re.I):
        raise RuntimeError(label + ': crash diagnostics; stop without repair')
    return entry, output


def expect_success(label, command, directory, kind='experiment'):
    entry, output = invoke(label, command, directory, kind)
    if entry['exit_code'] != 0 or re.search(r'\berror:', output):
        raise RuntimeError(label + ': unexpected failure; inspect saved diagnostics')
    entry['accepted'] = True
    save()
    return output


def expect_negative(label, command, directory, diagnostic):
    entry, output = invoke(label, command, directory, 'experiment')
    errors = [line for line in output.splitlines() if re.search(r'\berror:', line)]
    # Every error must be attributable to the intended rejection. This never accepts
    # access-control/missing-witness errors accompanying a desired diagnostic.
    if entry['exit_code'] == 0 or not errors or not all(re.search(diagnostic, line, re.I) for line in errors):
        raise RuntimeError(label + ': unexpected rejection or acceptance; stop without repair')
    entry['accepted'] = True
    entry['matching_errors'] = errors
    save()


def interrupted(signum, frame):
    raise InterruptedError('signal ' + str(signum))


signal.signal(signal.SIGTERM, interrupted)
signal.signal(signal.SIGINT, interrupted)
save()
try:
    parent, parent_native = verify_parent()
    snapshot = RUN / 'sources'
    snapshot.mkdir()
    for source in sorted(FIXTURE.iterdir()):
        if source.suffix in ('.swift', '.py', '.md'):
            shutil.copy2(source, snapshot / source.name)
            receipt['hashes'][str(source.relative_to(ROOT))] = sha(source)
    swift_lines = sum(len(p.read_text().splitlines()) for p in snapshot.glob('*.swift'))
    if swift_lines > 800:
        raise RuntimeError('800 Swift line ceiling exceeded')
    receipt['swift_lines'] = swift_lines
    helper = ROOT / 'scripts/contracts/compiler-baseline.sh'
    recipe = ROOT / 'scripts/contracts/check-spec-002-compiler-baseline.py'
    sdk_json = ROOT / '.toolchains/sdk/swift-6.4.0-RELEASE-raspios-bookworm-armv6/raspios-bookworm-static.json'
    for path in (helper, recipe, sdk_json):
        receipt['hashes'][str(path.relative_to(ROOT))] = sha(path)
    sdk = json.loads(sdk_json.read_text())
    if sdk['target'] != 'armv6-unknown-linux-gnueabihf':
        raise RuntimeError('ARMv6 SDK target mismatch')
    native_sdk = Path(expect_success('native-sdk', ['xcrun', '--sdk', 'macosx', '--show-sdk-path'], RUN, 'setup').strip())
    pi_flags = sdk['extra-swiftc-flags'] + [arg for flag in sdk['extra-cc-flags'] for arg in ('-Xcc', flag)]
    profiles = [
        ('macos-dynamic', ['-target', 'arm64-apple-macosx26.0', '-sdk', str(native_sdk), '-DGIFTUI_DYNAMIC_PROFILE'], ROOT / '.build/spike-075' / RUN_ID / 'macos-dynamic'),
        ('macos-static', ['-target', 'arm64-apple-macosx26.0', '-sdk', str(native_sdk), '-DGIFTUI_STATIC_PROFILE'], ROOT / '.build/spike-075' / RUN_ID / 'macos-static'),
        ('raspberry-pi-armv6', ['-target', 'armv6-unknown-linux-gnueabihf', '-DGIFTUI_DYNAMIC_PROFILE', *pi_flags], ROOT / '.build/raspberry-pi/spike-075' / RUN_ID),
        ('nrf52840-embedded', ['-target', 'armv7em-none-none-eabi', '-DGIFTUI_STATIC_PROFILE', '-enable-experimental-feature', 'Embedded', '-Xcc', '-mcpu=cortex-m4', '-Xcc', '-mfpu=fpv4-sp-d16', '-Xcc', '-mfloat-abi=hard'], ROOT / '.build/nrf52840/spike-075' / RUN_ID),
    ]
    compilers = {}
    for profile, _, directory in profiles:
        directory.mkdir(parents=True, exist_ok=False)
        receipt['profile_outputs'][profile] = str(directory)
        selection = expect_success('select-' + profile,
            ['bash', '-eu', '-c', 'source "$1"; giftui_rfc014_select_compiler "$2" "$3"; printf "%s\\n" "$GIFTUI_CONTRACT_SWIFTC"', 'spike-075', str(helper), str(ROOT), profile], directory, 'setup')
        compiler = Path(selection.strip())
        compilers[profile] = compiler
        for binary in (compiler, compiler.parent / 'swift-frontend', compiler.parent / 'swift-driver'):
            receipt['hashes'][str(binary.relative_to(ROOT))] = sha(binary)
    # SDK/resource hashes finish before the first compiler invocation starts the clock.
    receipt['sdk_hashes'] = [tree_sha(native_sdk), tree_sha(Path(sdk['sdk'])),
        tree_sha(compilers['nrf52840-embedded'].parent.parent / 'lib/swift/embedded')]
    if receipt['sdk_hashes'] != parent['sdk_hashes']:
        raise RuntimeError('SDK/resource tree differs from parent')
    save()
    checked = set()
    for profile, target_flags, directory in profiles:
        compiler = compilers[profile]
        if str(compiler) not in checked:
            version = expect_success('compiler-version', [str(compiler), '--version'], directory, 'identity')
            if 'Apple Swift version 6.4 (swift-6.4-RELEASE)' not in version:
                raise RuntimeError('compiler identity mismatch')
            checked.add(str(compiler))
        flags = [str(compiler), '-swift-version', '6', '-enable-experimental-feature', 'LifetimeDependence',
                 '-enable-experimental-feature', 'Lifetimes', '-Osize', '-whole-module-optimization',
                 '-parse-as-library', '-package-name', 'giftui', '-module-cache-path', str(directory / 'module-cache'), *target_flags]
        if profile == 'macos-dynamic':
            # Import the verified original complete module; do not emit it again.
            import_directory = parent_native
        else:
            import_directory = directory
            module = directory / 'P08Shadow.swiftmodule'
            sources = [snapshot / name for name in ('DomainAndProtocols.swift', 'Banks.swift', 'States.swift')]
            expect_success('shadow-module', [*flags, '-module-name', 'P08Shadow', '-emit-module',
                '-emit-module-path', str(module), '-emit-object', '-o', str(directory / 'shadow.o'), *map(str, sources)], directory)
        client = [*flags, '-module-name', 'P08Client', '-I', str(import_directory), '-emit-object']
        if profile != 'macos-dynamic':
            expect_success('positive', [*client, str(snapshot / 'Positive.swift'), '-o', str(directory / 'positive.o')], directory)
        expect_negative('copy-negative', [*client, str(snapshot / 'CopyNegative.swift'), '-o', str(directory / 'copy-negative.o')], directory, r'Copyable|noncopyable|non-copyable')
        for bank in range(5):
            expect_negative('escape-' + str(bank), [*client, str(snapshot / ('Escape' + str(bank) + '.swift')), '-o', str(directory / ('escape-' + str(bank) + '.o'))], directory,
                            r'lifetime|escap(?:e|es|ing)|dependen(?:t|ce|cy)|outlive')
        receipt.setdefault('passed_profiles', []).append(profile)
        save()
    receipt['status'] = 'passed-language-feasibility-only'
except BaseException as error:
    receipt['status'] = 'stopped'
    receipt['stop_reason'] = type(error).__name__ + ': ' + str(error)
    print(receipt['stop_reason'], file=sys.stderr)
finally:
    receipt['finished_utc'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    if first_compiler is not None:
        receipt['compiler_window_seconds'] = time.monotonic() - first_compiler
    save()
    print(RECEIPT)
if receipt['status'] != 'passed-language-feasibility-only':
    sys.exit(1)
