#!/usr/bin/env python3
"""Audit the actual firmware compiler invocations, including forbidden imports."""
from pathlib import Path
import os
import re
import shlex
import subprocess

root = Path(__file__).resolve().parents[2]
build = root / '.build/nrf52840/signal-analyzer-static'
output = root / '.build/contract-reports/spec-001/milestone-10/actual-owner-isolation'
output.mkdir(parents=True, exist_ok=True)
(output / 'clang-cache').mkdir(exist_ok=True)
environment = dict(os.environ, CLANG_MODULE_CACHE_PATH=str(output / 'clang-cache'))
cache = (build / 'CMakeCache.txt').read_text()
ninja = re.search(r'^CMAKE_MAKE_PROGRAM:[^=]+=(.+)$', cache, re.M).group(1)
commands = subprocess.check_output([ninja, '-t', 'commands'], cwd=build, text=True)

for owner, forbidden in [
    ('GiftUISemanticCore', 'GiftUIReferenceTextResources'),
    ('GiftUILayout', 'GiftUIRuntimeDynamic'),
    ('GiftUI', 'SignalAnalyzerTargetHost'),
]:
    source = build / f'{owner}.swift'
    line = next(line for line in commands.splitlines()
                if '-c ' in line and line.endswith(str(source)))
    arguments = shlex.split(line)
    mutated = output / f'{owner}.swift'
    mutated.write_text(source.read_text() + f'\nimport {forbidden}\n')
    rewritten = []
    index = 0
    while index < len(arguments):
        argument = arguments[index]
        if argument == '-output-file-map':
            index += 2
            continue
        if argument == '-emit-module-path':
            rewritten.extend([argument, str(output / f'{owner}.swiftmodule')])
            index += 2
            continue
        rewritten.append('-emit-module' if argument == '-c' else
                         str(mutated) if argument == str(source) else argument)
        index += 1
    result = subprocess.run(rewritten, cwd=build, env=environment, capture_output=True, text=True)
    diagnostic = result.stdout + result.stderr
    (output / f'{owner}.log').write_text(diagnostic)
    if result.returncode == 0 or f"no such module '{forbidden}'" not in diagnostic:
        raise SystemExit(f'{owner}: forbidden import was not rejected: {diagnostic}')
    print(f'actual-owner={owner}; forbidden={forbidden}; status=pass')

print('compiler=firmware-selected; imports=retained; profile=embedded-static')
