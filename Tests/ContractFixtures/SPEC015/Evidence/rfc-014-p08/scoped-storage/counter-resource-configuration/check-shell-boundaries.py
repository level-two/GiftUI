"""Exercise actual resource/check-parser shell fragments with synthetic text inputs.
No compiler, west, image helper, target execution or hardware operation is invoked.
Run from repository root. This checks guards, not firmware fit.
"""
import hashlib
import json
import os
import pathlib
import subprocess
import tempfile

ROOT = pathlib.Path.cwd()
script = (ROOT / 'scripts/nrf52840/build.sh').read_text()
memory = script[script.index('flash_bytes=0'):script.index("grep -Fq 'Machine:")]
checks = script[script.index('checks_file='):script.index("printf 'ELF=")]
application = ROOT / 'firmware/nrf52840/applications/signal-analyzer-static'
rows = (application / 'counter-build-checks.conf').read_text().splitlines()
symbols = [row.split('=', 1)[1] for row in rows if row.startswith(('required-symbol=', 'swift-entry-symbol='))]
sizes = dict(row.split('=', 1)[1].split(':') for row in rows if row.startswith('required-symbol-size='))
symbols += list(sizes)
records = []
with tempfile.TemporaryDirectory(prefix='p08-resource-guards-') as work:
    base = pathlib.Path(work)
    (base / 'zephyr').mkdir()
    (base / 'reports').mkdir()
    def run(name, *, counter=True, charge=255612, extent=None, limit=None,
            main=106496, isr=8192, heap=0, malloc=False, wrong_guard=False, expected=True, diagnostic=''):
        limit = (262144 if counter else 196608) if limit is None else limit
        extent = charge if extent is None else extent
        # Charge can be smaller than address extent because RAM LOAD spans have gaps.
        # Two disjoint RAM segments, second ending at physical-base + extent.
        first = 804
        gap = extent - charge
        headers = f'LOAD 0x0 0x00000000 0x0 0x1000 0x1000\nLOAD 0x0 0x20000000 0x0 0x0 {first:#x}\nLOAD 0x0 {0x20000000+first+gap:#x} 0x0 0x0 {charge-first:#x}\n'
        (base / 'reports/program-headers.txt').write_text(headers)
        (base / 'zephyr/.config').write_text(f'CONFIG_MAIN_STACK_SIZE={main}\nCONFIG_ISR_STACK_SIZE={isr}\nCONFIG_HEAP_MEM_POOL_SIZE={heap}\nCONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0\n')
        (base / 'reports/symbols.txt').write_text(''.join(f'{i}: 00000001 {1 if wrong_guard and symbol == "z_main_stack" else sizes.get(symbol, 1)} FUNC GLOBAL DEFAULT 1 {symbol}\n' for i, symbol in enumerate(symbols + (['malloc'] if malloc else []))))
        env = dict(os.environ, build_dir=str(base), application_dir=str(application),
                   application='signal-analyzer-static', counter_build='synthetic' if counter else '',
                   ram_limit_bytes=str(limit), resource_scope='p08-counter' if counter else 'application-default',
                   GIFTUI_NRF_FLASH_WARNING_BYTES='917504', GIFTUI_NRF_FLASH_LIMIT_BYTES='1048576')
        # Analyzer's symbol checks are unrelated here; exercise its unchanged memory branch.
        body = memory + (checks if counter else '')
        result = subprocess.run(['bash', '-c', 'set -euo pipefail\ngiftui_nrf_error() { printf "%s\\n" "$*" >&2; exit 1; }\n' + body], env=env, text=True, capture_output=True)
        assert (result.returncode == 0) == expected, (name, result.returncode, result.stderr)
        if diagnostic:
            assert diagnostic in result.stderr, (name, result.stderr)
        report = (base / 'reports/memory-summary.txt').read_text()
        assert f'RAM_LIMIT_BYTES={limit}\n' in report
        assert f'MAIN_STACK_SIZE_BYTES={main}\n' in report
        assert f'ISR_STACK_SIZE_BYTES={isr}\n' in report
        assert f'RAM_ADDRESS_EXTENT_BYTES={extent}\n' in report
        records.append(dict(case=name, passed=True, expected_success=expected))
    run('counter reviewed projection', extent=255616)
    run('counter physical boundary', charge=262144)
    run('counter charge overflow', charge=262145, expected=False, diagnostic='262144-byte')
    run('counter extent overflow despite allowed charge', charge=262144, extent=262148, expected=False, diagnostic='physical 256 KiB')
    run('counter wrong main', main=27648, expected=False, diagnostic='CONFIG_MAIN_STACK_SIZE=106496')
    run('counter wrong ISR', isr=2048, expected=False, diagnostic='CONFIG_ISR_STACK_SIZE=8192')
    run('counter incorrect guarded stack symbol', wrong_guard=True, expected=False, diagnostic='expected 106560')
    run('counter wrong budget', limit=262143, expected=False, diagnostic='RAM limit 262144')
    run('counter heap rejection retained', heap=1, expected=False, diagnostic='heap disabled')
    run('counter allocator symbol rejection retained', malloc=True, expected=False, diagnostic='heap allocation entry')
    run('analyzer baseline boundary', counter=False, charge=196608, main=27648, isr=2048)
    run('analyzer baseline overflow', counter=False, charge=196609, main=27648, isr=2048, expected=False, diagnostic='196608-byte')
# Execute the actual route-selection branch with only its handoff subprocess stubbed.
# A failed handoff must abort before a route can be accepted.
route = script[script.index('counter_cmake_arguments=()'):script.index('giftui_nrf_note "building')]
for name, counter, app, guard, expected in [
    ('default route keeps original budget and no overlay', '', 'signal-analyzer-static', 'pass', True),
    ('counter route selects overlay and physical budget', 'synthetic', 'signal-analyzer-static', 'pass', True),
    ('counter route rejects another application', 'synthetic', 'probe', 'pass', False),
    ('counter failed complete-receipt handoff stops route', 'synthetic', 'signal-analyzer-static', 'fail', False),
]:
    env = dict(os.environ, GIFTUI_NRF_RAM_LIMIT_BYTES='196608', counter_build=counter,
               application=app, application_dir=str(application), stub_guard=guard,
               GIFTUI_NRF_BUILD_ROOT='/synthetic-no-build', GIFTUI_NRF_PROJECT_ROOT=str(ROOT))
    body = ('set -euo pipefail\ngiftui_nrf_error() { printf "%s\\n" "$*" >&2; exit 1; }\n'
            'python3() { [[ "${stub_guard}" == pass ]]; }\n' + route +
            'printf "%s\\n" "${ram_limit_bytes}" "${resource_scope}"\n'
            'declare -p counter_cmake_arguments\n')
    result = subprocess.run(['bash', '-c', body], env=env, text=True, capture_output=True)
    assert (result.returncode == 0) == expected, (name, result.stderr)
    if expected:
        assert ('262144' if counter else '196608') in result.stdout
        assert ('-DEXTRA_CONF_FILE=' in result.stdout) == bool(counter)
        if counter:
            assert str(application / 'counter.conf') in result.stdout
    records.append(dict(case=name, passed=True, expected_success=expected))
print(json.dumps(dict(kind='synthetic shell guard checks only; no firmware build or execution',
    memory_fragment_sha256=hashlib.sha256(memory.encode()).hexdigest(),
    checks_fragment_sha256=hashlib.sha256(checks.encode()).hexdigest(), cases=records), indent=2))
