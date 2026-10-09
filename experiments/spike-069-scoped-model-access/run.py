#!/usr/bin/env python3
"""Bounded, append-only compiler evidence. Run from the repository root."""
import datetime
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
EVIDENCE = HERE / 'evidence'
EVIDENCE.mkdir(exist_ok=True)
LEDGER = EVIDENCE / 'ledger.json'
COMPILER = ROOT / '.toolchains/host/swift-6.3.2-RELEASE-osx/usr/bin/swiftc'
NRF_COMPILER = ROOT / '.toolchains/nrf52840/swift/swift-6.3.2-RELEASE-osx/usr/bin/swiftc'
DESTINATION = ROOT / '.toolchains/sdk/swift-6.3.2-RELEASE-raspios-bookworm-armv6/raspios-bookworm.json'
DEADLINE = datetime.datetime(2026, 10, 9, 21, 35, tzinfo=datetime.timezone.utc)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def relative(path):
    return str(path.relative_to(ROOT))


def inventory():
    names = ['Sources/GiftUI/ObservableState.swift',
             'Sources/GiftUIRuntimeStatic/StaticObservableModelStorage.swift',
             'Sources/GiftUIObservableState/ObservableStateValues.swift',
             'Sources/GiftUI/DeclarativeView.swift', 'Sources/GiftUI/Canvas.swift']
    return {
        'source_revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        'compilers': {relative(p): {'sha256': sha(p), 'version': subprocess.check_output([str(p), '--version'], text=True).strip()} for p in (COMPILER, NRF_COMPILER)},
        'sdk_destination_sha256': sha(DESTINATION),
        'production_inputs': {name: sha(ROOT / name) for name in names},
        'fixture_inputs': {p.name: sha(p) for p in HERE.iterdir() if p.is_file()},
    }


def targets():
    common = ['-swift-version', '6', '-parse-as-library', '-package-name', 'GiftUI',
              '-module-name', 'Spike069', '-Osize', '-wmo']
    destination = json.loads(DESTINATION.read_text())
    pi = destination['extra-swiftc-flags']
    pi += [arg for flag in destination['extra-cc-flags'] for arg in ('-Xcc', flag)]
    nrf = ['-target', 'armv7em-none-none-eabi', '-enable-experimental-feature', 'Embedded',
           '-Xcc', '-mcpu=cortex-m4', '-Xcc', '-mthumb', '-Xcc', '-mabi=aapcs',
           '-Xcc', '-mfpu=fpv4-sp-d16', '-Xcc', '-mfloat-abi=hard']
    return [
        ('macos-dynamic', COMPILER, common + ['-target', 'arm64-apple-macosx15.0', '-D', 'GIFTUI_DYNAMIC_PROFILE'], ROOT / '.build/spike-069/macos-dynamic'),
        ('macos-static', COMPILER, common + ['-target', 'arm64-apple-macosx15.0', '-D', 'GIFTUI_STATIC_PROFILE'], ROOT / '.build/spike-069/macos-static'),
        ('pi-armv6', COMPILER, common + pi + ['-D', 'GIFTUI_DYNAMIC_PROFILE'], ROOT / '.build/raspberry-pi/spike-069'),
        ('nrf-embedded', NRF_COMPILER, common + nrf + ['-D', 'GIFTUI_STATIC_PROFILE'], ROOT / '.build/nrf52840/spike-069'),
    ]


def trial(label, command, inputs, expected='success', diagnostic=None):
    ledger = json.loads(LEDGER.read_text()) if LEDGER.exists() else {'limit': 48, 'trials': []}
    now = datetime.datetime.now(datetime.timezone.utc)
    if len(ledger['trials']) >= 48 or now >= DEADLINE:
        raise SystemExit('STOP: committed invocation/time ceiling reached')
    number = len(ledger['trials']) + 1
    folder = EVIDENCE / f'{number:02d}-{label}'
    folder.mkdir()
    for index, path in enumerate(inputs):
        if path.suffix == '.swift':
            (folder / f'{index:02d}-{path.name}.txt').write_bytes(path.read_bytes())
    record = {'number': number, 'label': label, 'started_utc': now.isoformat(),
              'command': [str(arg) for arg in command], 'expected': expected,
              'diagnostic': diagnostic, 'inputs': {relative(p): sha(p) for p in inputs},
              'status': 'started', 'log': relative(folder / 'output.log')}
    ledger['trials'].append(record)
    LEDGER.write_text(json.dumps(ledger, indent=2) + '\n')
    start = time.monotonic()
    try:
        result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=90)
        log = result.stdout + result.stderr
        code = result.returncode
    except subprocess.TimeoutExpired as failure:
        log = str(failure)
        code = 124
    (folder / 'output.log').write_text(log)
    errors = '\n'.join(line for line in log.splitlines() if 'error:' in line)
    matched = code == 0 if expected == 'success' else code != 0 and any(word in errors for word in diagnostic)
    record.update(exit_code=code, elapsed_seconds=round(time.monotonic() - start, 3),
                  status='expected' if matched else 'unexpected', log_sha256=sha(folder / 'output.log'))
    LEDGER.write_text(json.dumps(ledger, indent=2) + '\n')
    print(f'{number:02d} {label}: {record["status"]} (exit {code})', flush=True)
    if not matched:
        print(log[-8000:], flush=True)
        raise SystemExit(1)


def compile_trial(label, target, inputs, defines=(), expected='success', diagnostic=None, executable=False):
    name, compiler, flags, output = target
    output.mkdir(parents=True, exist_ok=True)
    artifact = output / (label + ('' if executable else '.o'))
    command = [str(compiler), *flags, '-module-cache-path', str(output / 'module-cache')]
    if label != 'copyable-escape':
        command += ['-enable-experimental-feature', 'LifetimeDependence']
    command += [arg for define in defines for arg in ('-D', define)]
    command += [str(path) for path in inputs]
    command += ([] if executable else ['-c']) + ['-o', str(artifact)]
    trial(f'{label}-{name}', command, inputs, expected, diagnostic)
    return artifact


def production_control():
    output = ROOT / '.build/spike-069'
    output.mkdir(parents=True, exist_ok=True)
    state_path = ROOT / 'Sources/GiftUI/ObservableState.swift'
    state = state_path.read_text()
    # Remove only macro declaration; all State/sink/protocol code is exact.
    state = state[state.index('@propertyWrapper'):]
    values = (ROOT / 'Sources/GiftUIObservableState/ObservableStateValues.swift').read_text()
    storage = (ROOT / 'Sources/GiftUIRuntimeStatic/StaticObservableModelStorage.swift').read_text()
    combined = state + '\n' + values + '\n' + storage
    combined = '\n'.join(line for line in combined.splitlines() if not line.startswith('import ')) + '\n'
    path = output / 'ProductionControl.swift'
    path.write_text(combined)
    return path


mode = sys.argv[1]
if (EVIDENCE / 'result.json').exists():
    raise SystemExit('STOP: SPIKE-069 has a terminal result; further trials require a new bounded authorization')
metadata = inventory()
metadata_path = EVIDENCE / f'inventory-{mode}-{time.time_ns()}.json'
metadata_path.write_text(json.dumps(metadata, indent=2) + '\n')
if mode == 'a':
    for target in targets():
        compile_trial('copyable-escape', target, [production_control(), HERE / 'CopyableEscape.swift'])
elif mode == 'b':
    for target in targets():
        compile_trial('scoped-positive', target, [HERE / 'ScopedCapture.swift'])
elif mode == 'negatives':
    cases = {
        'ESCAPE_RETURN': ['lifetime', 'escapes', 'depend'],
        'ESCAPE_OUTER': ['lifetime', 'escapes', 'depend'],
        'ESCAPE_CLOSURE': ['non-escapable', 'nonescapable', 'escap', 'lifetime'],
        'OVERLAP_MUTATION': ['overlapping accesses', 'exclusiv', 'lifetime'],
        'CURRENT_DECLARATION_SHAPE': ['Escapable', 'non-escapable', 'nonescapable'],
    }
    for define, diagnostic in cases.items():
        for target in targets():
            compile_trial(define.lower(), target, [HERE / 'ScopedCapture.swift', HERE / 'Negative.swift'],
                          [define], 'rejection', diagnostic)
elif mode == 'driver':
    for target in targets():
        if target[0].startswith('macos'):
            artifact = compile_trial('lifetime-driver', target,
                                     [HERE / 'ScopedCapture.swift', HERE / 'LifetimeDriver.swift', HERE / 'Main.swift'], executable=True)
            trial('execute-' + target[0], [str(artifact)], [HERE / 'LifetimeDriver.swift', HERE / 'Main.swift'])
        else:
            compile_trial('lifetime-driver', target, [HERE / 'ScopedCapture.swift', HERE / 'LifetimeDriver.swift'])
elif mode == 'composition':
    inputs = sorted((ROOT / 'Sources/GiftUI').glob('*.swift')) + [HERE / 'ScopedCapture.swift', HERE / 'GiftUIComposition.swift']
    for target in targets():
        compile_trial('actual-owned-body', target, inputs)
    for target in targets():
        compile_trial('actual-borrowed-canvas', target, inputs, ['CAPTURE_IN_ACTUAL_CANVAS'],
                      'rejection', ['lifetime-dependent', 'non-escapable', 'nonescapable'])
elif mode == 'reachability':
    target = targets()[-1]
    name, compiler, flags, output = target
    target = (name, compiler, flags + ['-Xfrontend', '-function-sections'], output)
    obj = compile_trial('sectioned-lifetime-driver', target, [HERE / 'ScopedCapture.swift', HERE / 'LifetimeDriver.swift'])
    linker = ROOT / '.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-ld'
    trial('reachable-nrf-object', [str(linker), '-r', '--gc-sections',
          '--undefined=spike069_lifecycle', '--undefined=spike069_read',
          str(obj), '-o', str(output / 'reachable.o')], [obj])
else:
    raise SystemExit('Unknown mode')
