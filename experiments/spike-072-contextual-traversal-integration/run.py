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
DEADLINE = datetime.datetime(2026, 10, 10, 8, 48, 52, tzinfo=datetime.timezone.utc)


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
              '-module-name', 'Spike072', '-Osize', '-wmo']
    destination = json.loads(DESTINATION.read_text())
    pi = destination['extra-swiftc-flags']
    pi += [arg for flag in destination['extra-cc-flags'] for arg in ('-Xcc', flag)]
    nrf = ['-target', 'armv7em-none-none-eabi', '-enable-experimental-feature', 'Embedded',
           '-Xcc', '-mcpu=cortex-m4', '-Xcc', '-mthumb', '-Xcc', '-mabi=aapcs',
           '-Xcc', '-mfpu=fpv4-sp-d16', '-Xcc', '-mfloat-abi=hard']
    return [
        ('macos-dynamic', COMPILER, common + ['-target', 'arm64-apple-macosx15.0', '-D', 'GIFTUI_DYNAMIC_PROFILE'], ROOT / '.build/spike-072/macos-dynamic'),
        ('macos-static', COMPILER, common + ['-target', 'arm64-apple-macosx15.0', '-D', 'GIFTUI_STATIC_PROFILE'], ROOT / '.build/spike-072/macos-static'),
        ('pi-armv6', COMPILER, common + pi + ['-D', 'GIFTUI_DYNAMIC_PROFILE'], ROOT / '.build/raspberry-pi/spike-072'),
        ('nrf-embedded', NRF_COMPILER, common + nrf + ['-D', 'GIFTUI_STATIC_PROFILE'], ROOT / '.build/nrf52840/spike-072'),
    ]


def trial(label, command, inputs, expected='success', diagnostic=None):
    if (EVIDENCE / 'result.json').exists():
        raise SystemExit('STOP: SPIKE-072 has a terminal result')
    ledger = json.loads(LEDGER.read_text()) if LEDGER.exists() else {'limit': 64, 'trials': []}
    now = datetime.datetime.now(datetime.timezone.utc)
    if len(ledger['trials']) >= 64 or now >= DEADLINE:
        raise SystemExit('STOP: committed invocation/time ceiling reached')
    number = len(ledger['trials']) + 1
    folder = EVIDENCE / f'{number:02d}-{label}'
    folder.mkdir()
    for path in inputs:
        if path.suffix == '.swift':
            snapshots = EVIDENCE / 'inputs'
            snapshots.mkdir(exist_ok=True)
            (snapshots / (sha(path) + '.swift.txt')).write_bytes(path.read_bytes())
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
    matched = expected == 'observation' or (code == 0 if expected == 'success' else code != 0 and any(word in errors for word in diagnostic))
    record.update(exit_code=code, elapsed_seconds=round(time.monotonic() - start, 3),
                  status='expected' if matched else 'unexpected', log_sha256=sha(folder / 'output.log'))
    LEDGER.write_text(json.dumps(ledger, indent=2) + '\n')
    print(f'{number:02d} {label}: {record["status"]} (exit {code})', flush=True)
    if not matched:
        print(log[-8000:], flush=True)
        raise SystemExit(1)


def compile_trial(label, target, inputs, defines=(), expected='success', diagnostic=None, executable=False, lifetime=True):
    name, compiler, flags, output = target
    output.mkdir(parents=True, exist_ok=True)
    artifact = output / (label + ('' if executable else '.o'))
    command = [str(compiler), *flags, '-module-cache-path', str(output / 'module-cache')]
    if lifetime:
        command += ['-enable-experimental-feature', 'LifetimeDependence', '-enable-experimental-feature', 'Lifetimes']
    command += [arg for define in defines for arg in ('-D', define)]
    command += [str(path) for path in inputs]
    command += ([] if executable else ['-c']) + ['-o', str(artifact)]
    trial(f'{label}-{name}', command, inputs, expected, diagnostic)
    return artifact


if __name__ == '__main__':
    mode=sys.argv[1]
    (EVIDENCE / f'inventory-{mode}-{time.time_ns()}.json').write_text(json.dumps(inventory(),indent=2)+'\n')
    base=sorted((HERE/'adapted').glob('*.swift'))+[HERE/p for p in ['Access.swift','Generated.swift','Fixtures.swift','GraphicsRecorder.swift']]
    if mode=='compile':
        compile_trial('integration-initial',targets()[-1],base)
    elif mode=='negative':
        for target in targets():
            compile_trial('live-parent-discovery',target,base+[HERE/'Driver.swift',HERE/'Negative.swift'],expected='rejection',diagnostic=['overlapping accesses','lifetime-dependent value escapes'])
    elif mode=='positive':
        for target in [targets()[-1],*targets()[:-1]]:
            native=target[0].startswith('macos')
            inputs=base+[HERE/'Driver.swift']+([HERE/'Main.swift'] if native else [])
            artifact=compile_trial('integration',target,inputs,executable=native)
            if native: trial('execute-'+target[0],[str(artifact)],inputs)
    else: raise SystemExit('unknown mode')
