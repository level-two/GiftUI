#!/usr/bin/env python3
"""P01 fail-closed compiler selection and required-feature controls (no hardware)."""
from pathlib import Path
import json
import os
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
FIXTURE = ROOT / 'Tests/ContractFixtures/SPEC002/CompilerBaseline/RequiredFeatures.swift'
HELPER = ROOT / 'scripts/contracts/compiler-baseline.sh'
OUT = ROOT / '.build/rfc-014/p01/compiler-controls'
OUT.mkdir(parents=True, exist_ok=True)
checks = []


def check(label, command, expected=0, diagnostic=None):
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True)
    output = result.stdout + result.stderr
    (OUT / (label + '.log')).write_text(output)
    matched = (result.returncode == 0) if expected == 0 else (result.returncode != 0)
    if diagnostic:
        matched = matched and diagnostic in output
    checks.append(dict(label=label, command=list(map(str, command)), exit_code=result.returncode, passed=matched))
    if not matched:
        raise SystemExit(f'{label} failed:\n{output}')


def shell(label, script, arguments=(), expected=0, diagnostic=None):
    check(label, ['bash', '-eu', '-c', 'source "$1"; shift; ' + script,
                  'compiler-control', str(HELPER), *map(str, arguments)], expected, diagnostic)


try:
    for baseline in ('unknown', ''):
        args = ['--compiler-baseline'] + ([baseline] if baseline else [])
        check('reject-baseline-' + (baseline or 'missing'),
              ['scripts/contracts/run-spec-002.sh', '--profile', 'macos-dynamic', *args],
              expected=1, diagnostic='compiler baseline' if baseline else 'requires a value')
    shell('missing-compiler', 'giftui_rfc014_select_compiler "$1" macos-dynamic',
          [OUT / 'absent'], expected=1, diagnostic='pinned RFC-014 compiler is missing')
    shell('unknown-profile', 'giftui_rfc014_select_compiler "$1" armv7',
          [ROOT], expected=1, diagnostic='unknown migration profile')
    with tempfile.TemporaryDirectory(dir=OUT) as directory:
        wrong = Path(directory) / 'swiftc'
        wrong.write_text('#!/bin/sh\nprintf "Apple Swift version 6.3.3 (wrong-build)\\n"\n')
        wrong.chmod(0o755)
        shell('compiler-drift', 'giftui_rfc014_check_compiler "$1" "$2" "$3"',
              [wrong, FIXTURE, OUT], expected=1, diagnostic='compiler identity mismatch')

    sdk_json = ROOT / '.toolchains/sdk/swift-6.3.2-RELEASE-raspios-bookworm-armv6/raspios-bookworm-static.json'
    sdk = json.loads(sdk_json.read_text())
    pi_flags = sdk['extra-swiftc-flags'] + [arg for flag in sdk['extra-cc-flags'] for arg in ('-Xcc', flag)]
    profiles = {
        'macos-dynamic': ['-target', 'arm64-apple-macosx26.0', '-DGIFTUI_DYNAMIC_PROFILE'],
        'macos-static': ['-target', 'arm64-apple-macosx26.0', '-DGIFTUI_STATIC_PROFILE'],
        'raspberry-pi-armv6': ['-target', 'armv6-unknown-linux-gnueabihf', *pi_flags],
        'nrf52840-embedded': ['-target', 'armv7em-none-none-eabi', '-enable-experimental-feature', 'Embedded',
                            '-Xcc', '-mcpu=cortex-m4', '-Xcc', '-mfpu=fpv4-sp-d16', '-Xcc', '-mfloat-abi=hard'],
    }
    for profile, target_flags in profiles.items():
        flags = [*target_flags, '-module-cache-path', str(OUT / 'module-cache')]
        script = 'giftui_rfc014_select_compiler "$1" "$2"; shift 2; '
        shell(profile + '-features', script +
              'giftui_rfc014_check_compiler "$GIFTUI_CONTRACT_SWIFTC" "$1" "$2" "${GIFTUI_CONTRACT_FEATURE_FLAGS[@]}" "${@:3}"',
              [ROOT, profile, FIXTURE, OUT / profile, *flags])
        for missing, present in [('LifetimeDependence', 'Lifetimes'), ('Lifetimes', 'LifetimeDependence')]:
            shell(profile + '-missing-' + missing, script +
                  '"$GIFTUI_CONTRACT_SWIFTC" -enable-experimental-feature "$1" -typecheck "$2" "${@:3}"',
                  [ROOT, profile, present, FIXTURE, *flags], expected=1,
                  diagnostic='RFC-014 requires ' + missing)
finally:
    (OUT / 'results.json').write_text(json.dumps(checks, indent=2) + '\n')

print(f'P01 compiler baseline: {len(checks)} controls passed across four configurations.')
