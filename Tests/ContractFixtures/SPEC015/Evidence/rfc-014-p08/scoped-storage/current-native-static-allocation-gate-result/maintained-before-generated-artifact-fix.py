#!/usr/bin/env python3
"""Compile-only P08 allocation contract; reuse a complete matching Native receipt."""
import argparse
import hashlib
import json
import pathlib
import shlex
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
ROUTE = 'Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterRouteEntry.swift'
ENTRY = 'package func p08CounterStaticResourceEntryV1() -> Int {'
ANNOTATION = '#if GIFTUI_COUNTER_ALLOCATION_GATE\n@_noAllocation\n#endif\n'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--counter-build', required=True, type=pathlib.Path)
parser.add_argument('--output', type=pathlib.Path, help='fresh exclusive output under .build')
args = parser.parse_args()
parent = ROOT / '.build/contracts'
parent.mkdir(parents=True, exist_ok=True)
if args.output:
    out = args.output.resolve()
    if ROOT / '.build' not in out.parents:
        parser.error('--output must be under repository .build')
    out.mkdir(parents=True, exist_ok=False)
else:
    out = pathlib.Path(tempfile.mkdtemp(prefix='p08-counter-allocation-', dir=parent))


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


record = dict(scope=__doc__, passed=False, controls_passed=False,
              actual_entry_passed=False, runtime_executed=False, commands=[], checks=[],
              reused_receipts=[], reused_modules=[], inputs={}, candidate_source_deltas=[],
              baseline_role='Trusted recipe and reused dependencies; no old functional PASS transfers to candidate edits.')


def save():
    (out / 'result.json').write_text(json.dumps(record, indent=2) + '\n')


def authenticate(path, expected=None, fresh_sources=()):
    data = json.loads(path.read_text())
    actual = digest(path)
    if expected is not None:
        require(actual == expected, str(path) + ': receipt identity changed')
    record['reused_receipts'].append(dict(path=str(path), sha256=actual))
    for name, wanted in data.get('inputs', {}).items():
        source = ROOT / name
        current = digest(source)
        if current != wanted and name in fresh_sources:
            row = dict(path=name, baseline_sha256=wanted, current_sha256=current,
                       freshly_compiled=True, old_functional_pass_transferred=False)
            if row not in record['candidate_source_deltas']:
                record['candidate_source_deltas'].append(row)
        else:
            require(current == wanted, name + ': input identity changed')
        record['inputs'][name] = current
    for name, value in data.get('artifacts', {}).items():
        if name.endswith('.swiftmodule'):
            module = path.parent / name
            require(digest(module) == value['sha256'], str(module) + ': module identity changed')
            require(module.stat().st_size == value['bytes'], str(module) + ': module size changed')
            record['reused_modules'].append(dict(path=str(module), sha256=value['sha256']))
    return data


def run(name, command):
    record['commands'].append(dict(name=name, argv=command))
    save()
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    (out / (name + '.stdout')).write_bytes(result.stdout)
    (out / (name + '.stderr')).write_bytes(result.stderr)
    record['checks'].append(dict(name=name, exit=result.returncode,
                                 stdout_sha256=hashlib.sha256(result.stdout).hexdigest(),
                                 stderr_sha256=hashlib.sha256(result.stderr).hexdigest()))
    save()
    return result


try:
    base = args.counter_build.resolve()
    recipe_data = json.loads((base / 'result.json').read_text())
    recipe = next(shlex.split(c) for c in recipe_data['commands']
                  if '-module-name P08CounterRuntime ' in c and '-emit-object' in c)
    swift_inputs = [pathlib.Path(p) for p in recipe if p.endswith('.swift')]
    require(len(swift_inputs) == 42 and ROOT / ROUTE in swift_inputs,
            'unexpected actual Counter module source closure')
    fresh_sources = {str(p.relative_to(ROOT)) for p in swift_inputs}
    prior = authenticate(base / 'result.json', fresh_sources=fresh_sources)
    require(prior.get('passed') is True and prior.get('collection_complete') is True,
            'a complete passing Counter receipt is required')
    require(prior.get('selected_host_profile') == 'macos-static' and not prior.get('fresh_focused')
            and not prior.get('selected_families') and not prior.get('prior_collection')
            and not prior.get('legacy_import'), 'a complete Native Static recipe is required')
    require(prior.get('static_resource_entry', {}).get('passed') is True,
            'the original complete Static workload must have passed')
    compiler = pathlib.Path(recipe[0])
    require(digest(compiler) == prior['compiler_sha256'], 'compiler identity changed')
    record.update(compiler=str(compiler), compiler_sha256=prior['compiler_sha256'],
                  annotation='@_noAllocation', checker_flag='-experimental-performance-annotations')
    runtime = authenticate(ROOT / prior['runtime_build'] / 'result.json', prior['runtime_receipt_sha256'], fresh_sources)
    host = authenticate(ROOT / prior['host_build'] / 'result.json', prior['host_receipt_sha256'], fresh_sources)
    # A fresh fixture listed only as receipt metadata must not require a full
    # rerun. A source actually compiled into a reused imported module must match.
    for receipt in (prior, runtime, host):
        for command in receipt['commands']:
            parts = shlex.split(command)
            if '-module-name' not in parts or '-emit-module' not in parts:
                continue
            module = parts[parts.index('-module-name') + 1]
            if not (module.startswith('GiftUI') or module in ('P08CounterTable', 'P08CounterPresentation')):
                continue
            for value in parts:
                if value.endswith('.swift'):
                    name = str((ROOT / value).resolve().relative_to(ROOT))
                    require(digest(ROOT / name) == receipt['inputs'][name],
                            name + ': reused imported-module source changed; rebuild prerequisite')
    require(runtime['compiler_sha256'] == prior['compiler_sha256'] == host['compiler_sha256'],
            'prerequisite compiler mismatch')
    core_path = ROOT / runtime['core_receipt']
    require(digest(core_path) == runtime['core_receipt_sha256'] == prior['core_receipt_sha256'],
            'lower GiftUI receipt identity changed')
    core = json.loads(core_path.read_text())
    for name in ('GiftUI.o', 'GiftUI.swiftmodule'):
        require(digest(core_path.parent / name) == core['artifacts'][name]['sha256'], name)
    for name, wanted in core['inputs'].items():
        if name.startswith(('Sources/GiftUI/', 'Sources/GiftUIMacros/')):
            require(digest(ROOT / name) == wanted, name)
    require(digest(ROOT / core['macro_tool']) == prior['macro_tool_sha256'] == core['macro_tool_sha256'],
            'macro executable identity changed')
    require(digest(ROOT / core['swift_syntax_library']) == prior['swift_syntax_sha256'] == core['swift_syntax_sha256'],
            'macro support identity changed')
    require((ROOT / ROUTE).read_text().count(ANNOTATION + ENTRY) == 1,
            'the exact actual entry must carry the selected conditional annotation')
    record['candidate_source_hashes'] = {name: digest(ROOT / name) for name in sorted(fresh_sources)}
    require('-Osize' in recipe and '-whole-module-optimization' in recipe,
            'expected optimized whole-module recipe')
    fixtures = ROOT / 'Tests/ContractFixtures/SPEC015/AllocationGate'
    record['inputs'][str(pathlib.Path(__file__).resolve().relative_to(ROOT))] = digest(pathlib.Path(__file__))
    controls = [fixtures / 'NoAllocationPositive.swift', fixtures / 'AllocationNegative.swift']
    record['inputs'].update({str(p.relative_to(ROOT)): digest(p) for p in controls})
    flags = [str(compiler), '-swift-version', '6', '-Osize', '-whole-module-optimization',
             '-experimental-performance-annotations', '-target', recipe[recipe.index('-target') + 1],
             '-sdk', recipe[recipe.index('-sdk') + 1], '-parse-as-library',
             '-module-cache-path', str(out / 'cache')]
    positive = run('positive', flags + ['-module-name', 'NoAllocationPositive', '-emit-object',
                                      str(controls[0]), '-o', str(out / 'positive.o')])
    negative = run('allocation-negative', flags + ['-module-name', 'AllocationNegative', '-emit-object',
                                                 str(controls[1]), '-o', str(out / 'negative.o')])
    require(positive.returncode == 0, 'positive allocation control failed')
    require(negative.returncode != 0 and b'AllocationBox' in negative.stderr
            and b'can cause metadata allocation or locks' in negative.stderr,
            'allocation negative did not demonstrate the installed diagnostic mode')
    record['controls_passed'] = True
    actual = [recipe[0], '-experimental-performance-annotations', '-D',
              'GIFTUI_COUNTER_ALLOCATION_GATE', *recipe[1:]]
    for flag, path in [('-module-cache-path', out / 'cache'),
                       ('-emit-module-path', out / 'P08CounterRuntime.swiftmodule'),
                       ('-o', out / 'P08CounterRuntime.o')]:
        actual[actual.index(flag) + 1] = str(path)
    result = run('actual-static-entry', actual)
    record['actual_entry_passed'] = result.returncode == 0
    record['passed'] = record['controls_passed'] and record['actual_entry_passed']
except (ValueError, OSError, KeyError, StopIteration) as error:
    record['error'] = str(error)
save()
print('P08_COUNTER_ALLOCATION_EVIDENCE', out)
print('P08_COUNTER_ALLOCATION_GATE', 'PASS' if record['passed'] else 'FAIL')
raise SystemExit(0 if record['passed'] else 1)
