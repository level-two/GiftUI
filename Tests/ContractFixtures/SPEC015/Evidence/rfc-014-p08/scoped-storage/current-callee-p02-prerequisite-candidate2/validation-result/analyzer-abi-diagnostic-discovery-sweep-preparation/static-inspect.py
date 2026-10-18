#!/usr/bin/env python3
"""Read-only AST/JSON/byte/hash inspection; never import the discovery runner."""
from pathlib import Path
import ast
import hashlib
import json
import os
import shutil
import subprocess
import sys

ROOT = Path('/Users/eugene/work/GiftUI')
PACKET = Path(__file__).resolve().parent
BASE = PACKET.parent
OLD = BASE / 'analyzer-abi-continuation-campaign10-preparation'


def sha(path):
    value = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            value.update(block)
    return value.hexdigest()


def load(path):
    return json.loads(Path(path).read_text())


def inspect():
    assert len(sys.argv) == 1 or (len(sys.argv) == 3 and sys.argv[1] == '--reviewed-packet-commit')
    plan = load(PACKET / 'plan.json')
    recipe = load(OLD / 'recipe.json')
    controls = load(OLD / 'controls.json')['controls']
    source = load(OLD / 'scratch-sources.json')['sources']
    result = load(BASE / 'analyzer-abi-continuation-campaign10-result/campaign/result.json')
    core_receipt = load(BASE / 'analyzer-abi-continuation-campaign10-result/campaign/receipts/2.json')
    seen = {(r['profile'], r['control']) for r in result['control_receipts']}
    assert len(seen) == 29
    assert any(r['name'] == 'raspberry-pi-armv6-negative-A7-AnalyzerPresentation' for r in result['stages'])
    expected = [(profile, c['id']) for profile in plan['profile_order'] for c in controls
                if profile != 'raspberry-pi-armv6' or c['id'] == 'negative-A8' or c['kind'] == 'privacy-negative']
    actual = [(c['profile'], c['control']) for c in plan['cells'] if c['role'] == 'target']
    assert actual == expected and len(actual) == len(set(actual)) == 50
    assert not set(actual) & seen and ('raspberry-pi-armv6', 'negative-A7') not in actual
    assert [sum(p == profile for p, _ in actual) for profile in plan['profile_order']] == [10, 20, 20]
    assert len(plan['cells']) == 56 and sum(len(c['stages']) for c in plan['cells']) == 118
    assert plan['retries'] == plan['automatic_repairs'] == plan['qualified_controls'] == 0
    environment = load(PACKET / 'environment-context.json')
    assert environment['discovery_environment_template'] == plan['environment']
    assert plan['environment']['HOME'] == os.environ['HOME'] == '/Users/eugene'
    assert not set(environment['absent_named_variables']) & set(plan['environment'])
    assert hashlib.sha256(json.dumps(plan['environment'], sort_keys=True, separators=(',', ':')).encode()).hexdigest() == environment['template_sha256']
    for config in load(PACKET / 'home-config-identities.json'):
        path = Path(config['path'])
        if config['kind'] == 'absent':
            assert not path.exists() and not path.is_symlink()
        elif config['kind'] == 'file':
            assert sha(path) == config['identity']['sha256']
        else:
            data = config['inventory']
            assert str(path.resolve(strict=True)) == data['resolved']
            assert {str(p.relative_to(path)) for p in path.rglob('*')} == {r['path'] for r in data['entries']}
            for item in data['entries']:
                q = path / item['path']
                if item['kind'] == 'file':
                    assert not q.is_symlink() and q.stat().st_size == item['bytes'] and sha(q) == item['sha256']
                elif item['kind'] == 'directory':
                    assert q.is_dir() and not q.is_symlink()
                else:
                    assert q.is_symlink() and os.readlink(q) == item['target']
                    if 'resolved_file' in item:
                        assert sha(q) == item['resolved_file']['sha256']
                    if 'resolved_directory' in item:
                        assert str(q.resolve(strict=True)) == item['resolved_directory']
    assert plan['lock_argv'] == ['/usr/bin/ruby', str(ROOT / 'scripts/lib/serialize-validation.rb'), *plan['execution_argv']]
    assert plan['execution_argv'][1:] == [str(PACKET / 'execute-discovery.py'), '--execute-reviewed-discovery-once',
                                        '--reviewed-packet-commit', '{reviewed_packet_commit}']
    assert plan['immutable_packet_anchor']['source'] == 'full Git commit ID supplied by external reviewed invocation; never selected from plan/manifest/HEAD'
    correction = load(PACKET / 'anchor-correction-provenance.json')
    assert correction['reviewed_preparation_base_commit'] == 'b8935ba312302d856f0a46ff68d2d2bf1be05c50'
    for name, record in correction['unchanged_base_payload_blobs'].items():
        data = (PACKET / name).read_bytes()
        assert hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest() == record['blob']
    assert all(not Path(p).exists() for p in plan['fresh_roots'])
    assert shutil.disk_usage(ROOT).free >= plan['minimum_free_bytes'] == 34359738368
    freeze = load(plan['freeze']['path'])
    assert len(freeze) == 541 and sha(plan['freeze']['path']) == '0cb2c32520e4344940c4801c9bfea21206e828dd2d6db07dfb8ae06dd4840333'
    assert all(sha(ROOT / n) == h for n, h in freeze.items())
    for local, original in [('registered-controls.json', 'controls.json'), ('selectors.json', 'selectors.json'),
                            ('scratch-sources.json', 'scratch-sources.json')]:
        assert (PACKET / local).read_bytes() == (OLD / original).read_bytes()
    for v in source.values():
        assert hashlib.sha256(v['text'].encode()).hexdigest() == v['sha256']
    prior = set()
    stage_ids = set()
    generated = set()
    commands_checked = 0
    for cell in plan['cells']:
        assert set(cell['dependencies']) <= prior
        assert not any('negative-' in key or '--private-' in key or '--outside-package-' in key for key in cell['dependencies'])
        prior.add(cell['id'])
        profile = cell['profile']
        core = Path(plan['profile_roots'][profile]) / 'core'
        positive = Path(plan['profile_roots'][profile]) / 'scratch/positive-actual-lowering'
        actual_cell = positive if cell['control'] in ('positive-serialized-read', 'positive-semantics') else Path(cell['root'])
        registration = next((c for c in controls if c['id'] == cell['control']), None)
        if registration:
            assert cell['registered_control'] == registration
        expected_materials = {}
        if registration and (registration['id'] == 'positive-actual-lowering' or registration['kind'] == 'abi-negative'):
            expected_materials = {str(actual_cell / 'inputs' / Path(n).name): v
                                  for n, v in source.items() if n.startswith('positive/')}
            if registration['kind'] == 'abi-negative':
                replacement = registration['files'][0]
                expected_materials[str(actual_cell / 'inputs' / Path(replacement).name)] = source[replacement]
        elif registration and registration['kind'] == 'privacy-negative':
            name = registration['files'][0]
            expected_materials = {str(actual_cell / 'inputs' / Path(name).name): source[name]}
        assert {m['path']: (m['text'], m['sha256']) for m in cell['materialize']} == {
            name: (v['text'], v['sha256']) for name, v in expected_materials.items()}
        if profile == 'raspberry-pi-armv6' and cell['control'].startswith('positive-'):
            assert cell['role'] == 'prerequisite'
        if registration and registration['kind'] != 'positive':
            assert cell['dependencies'] == [profile + '--' + s for s in (
                ['isolated-core-producer', 'positive-actual-lowering', 'positive-serialized-read'] +
                (['positive-semantics'] if registration['kind'] == 'privacy-negative' else []))]
            assert cell['stages'][-1]['name'] == registration['first_expected_stage']
            assert sum(s['negative_observation'] for s in cell['stages']) == 1
        for material in cell['materialize']:
            assert hashlib.sha256(material['text'].encode()).hexdigest() == material['sha256']
            assert any(material['text'] == v['text'] and material['sha256'] == v['sha256'] for v in source.values())
        def expand(template, name='', sources=None, outside=False):
            flags = recipe['base_flags'] + recipe['profile_flags'][profile] + recipe['plugin_flags']
            if outside:
                i = flags.index('-package-name')
                flags = flags[:i] + flags[i + 2:]
            tokens = {'compiler': recipe['compilers'][profile], 'cell': str(actual_cell), 'core': str(core),
                      'positive-cell': str(positive), 'module': name,
                      'negative-source': cell['materialize'][0]['path'] if cell['materialize'] else ''}
            def text(value):
                for key, replacement in tokens.items():
                    value = value.replace('{' + key + '}', replacement)
                assert '{' not in value and '}' not in value
                return value
            answer = []
            for token in template:
                answer.extend(map(text, flags if token == '{flags...}' else sources or []
                                  if token == '{sources...}' else [token]))
            return answer
        for stage in cell['stages']:
            assert stage['id'] not in stage_ids
            stage_ids.add(stage['id'])
            name = stage['name']
            if cell['control'] == 'isolated-core-producer':
                if name == 'counter-lowering':
                    argv = [recipe['lower_argv'][0], '--lower-source',
                            str(ROOT / 'Tests/ContractFixtures/SPEC006/RuntimeDerived/Counter.schema.json'),
                            str(ROOT / 'Tests/ContractFixtures/SPEC006/RuntimeDerived/Counter.swift'),
                            str(core / 'CounterSchema.swift'), str(core / 'CounterPresentation.swift')]
                else:
                    src = [str(ROOT / n) for n in sorted(freeze) if n.startswith('Sources/GiftUI/')] if name == 'GiftUI' else [str(core / (name + '.swift'))]
                    argv = expand(recipe['module_argv'], name, src)
                    i = argv.index('-I')
                    assert argv[i:i + 4] == ['-I', str(core), '-I', str(core)]
                    del argv[i:i + 2]
            elif name in recipe['scratch_sources_by_module']:
                argv = expand(recipe['module_argv'], name, recipe['scratch_sources_by_module'][name])
            elif name == 'lower-Analyzer-source':
                argv = expand(recipe['lower_argv'])
            elif name == 'client-emit-object':
                argv = expand(recipe['scratch_negative_argv'], outside=registration['package_name'] is None)
            elif name == 'target-abi':
                argv = expand(recipe['target_readelf_argv'])
            elif name in ('link', 'execute'):
                key = ('native_semantics_' if cell['control'] == 'positive-semantics' else 'scratch_declaration_native_') + name + '_argv'
                argv = expand(recipe[key])
            else:
                raise AssertionError(name)
            assert argv == stage['argv'], stage['id']
            if name in ('counter-lowering', 'lower-Analyzer-source'):
                expected_hashes = {}
                for path in stage['outputs']:
                    basename = Path(path).name
                    if basename == 'AnalyzerPresentation.swift' and cell['control'] in ('negative-A7', 'negative-A8'):
                        expected_hashes[path] = sha(OLD / (cell['control'][-2:] + '-frozen-AnalyzerPresentation.swift'))
                    else:
                        expected_hashes[path] = core_receipt['artifacts'][basename]['sha256']
                assert stage['output_sha256'] == expected_hashes
            if name == 'target-abi':
                assert stage['abi_arch'] == ('v6' if profile == 'raspberry-pi-armv6' else 'v7E-M')
            if name == 'execute':
                assert stage['stdout_exact_stripped'] == ('analyzer-abi semantics=18 failures=0' if cell['control'] == 'positive-semantics' else 'checks=120 failures=0')
            assert all(Path(p).is_absolute() for p in stage['inputs'] + stage['outputs'])
            for path in stage['inputs']:
                assert path in generated or path in stage['input_sha256'], (stage['id'], path)
            assert not set(stage['outputs']) & generated
            generated.update(stage['outputs'])
            commands_checked += 1
    assert commands_checked == 118
    for record in load(PACKET / 'external-identities.json'):
        path = Path(record['path'])
        assert str(path.resolve(strict=True)) == record['resolved']
        assert path.stat().st_size == record['bytes'] and sha(path) == record['sha256'], path
    preserved = load(PACKET / 'historical-preservation.json')
    assert set(preserved) <= {str(p) for p in BASE.rglob('*') if p.is_file() and not p.is_relative_to(PACKET)}
    inventory_counts = {}
    for filename in plan['platform_inventories']:
        data = load(PACKET / filename)
        root = Path(data['root'])
        assert str(root.resolve(strict=True)) == data['resolved']
        assert {str(p.relative_to(root)) for p in root.rglob('*')} == {r['path'] for r in data['entries']}
        for record in data['entries']:
            path = root / record['path']
            if record['kind'] == 'symlink':
                assert path.is_symlink() and os.readlink(path) == record['target']
                if 'resolved_file' in record:
                    value = record['resolved_file']
                    assert str(path.resolve(strict=True)) == value['resolved'] and sha(path) == value['sha256'] and path.stat().st_size == value['bytes']
                if 'resolved_directory' in record:
                    assert path.is_dir() and str(path.resolve(strict=True)) == record['resolved_directory']
                    assert path.resolve().is_relative_to(root.resolve())
            elif record['kind'] == 'directory':
                assert path.is_dir() and not path.is_symlink()
            else:
                assert path.is_file() and not path.is_symlink() and path.stat().st_size == record['bytes'] and sha(path) == record['sha256']
        inventory_counts[filename] = len(data['entries'])
    for path in PACKET.glob('*.py'):
        tree = ast.parse(path.read_text(), filename=str(path))
        imports = [n.module or '' for n in ast.walk(tree) if isinstance(n, ast.ImportFrom)] + [v.name for n in ast.walk(tree) if isinstance(n, ast.Import) for v in n.names]
        assert not any('diagnostic_parser' in name for name in imports)
    runner_tree = ast.parse((PACKET / 'execute-discovery.py').read_text())
    main = next(n for n in runner_tree.body if isinstance(n, ast.FunctionDef) and n.name == 'main')
    anchor_capture = next(n for n in main.body if isinstance(n, ast.Assign) and
                          isinstance(n.value, ast.Call) and isinstance(n.value.func, ast.Name) and
                          n.value.func.id == 'authenticate_reviewed_packet')
    plan_read = next(n for n in main.body if isinstance(n, ast.Assign) and
                     isinstance(n.value, ast.Call) and isinstance(n.value.func, ast.Name) and n.value.func.id == 'read')
    assert anchor_capture.lineno < plan_read.lineno
    anchor_calls = [n for n in ast.walk(main) if isinstance(n, ast.Call) and
                    isinstance(n.func, ast.Name) and n.func.id == 'authenticate_reviewed_packet']
    assert len(anchor_calls) == 3  # Before plan trust, verify(), and immediately before launch.
    for path in PACKET.glob('*.json'):
        load(path)
    seal = PACKET / 'packet-hashes.json'
    if seal.exists():
        hashes = load(seal)
        assert {str(p.relative_to(PACKET)) for p in PACKET.rglob('*') if p.is_file()} == set(hashes) | {'packet-hashes.json'}
        for name, value in hashes.items():
            assert (PACKET / name).stat().st_size == value['bytes'] and sha(PACKET / name) == value['sha256']
    external_anchor = None
    if len(sys.argv) == 3:
        external_anchor = sys.argv[2]
        assert len(external_anchor) == 40 and all(c in '0123456789abcdef' for c in external_anchor)
        git_environment = {'PATH': '/usr/bin:/bin:/usr/sbin:/sbin', 'HOME': os.environ['HOME'],
                           'LANG': 'C', 'LC_ALL': 'C', 'GIT_CONFIG_NOSYSTEM': '1', 'GIT_CONFIG_GLOBAL': '/dev/null'}
        def git(*args):
            return subprocess.check_output(['/usr/bin/git', '--no-replace-objects', '--git-dir=' + str(ROOT / '.git'),
                                            *args], cwd=ROOT, env=git_environment)
        assert git('rev-parse', '--verify', external_anchor + '^{commit}').decode().strip() == external_anchor
        relative = str(PACKET.relative_to(ROOT))
        anchored_files = set()
        for row in git('ls-tree', '-r', '-z', '--full-tree', external_anchor, '--', relative).split(b'\0'):
            if not row:
                continue
            metadata, name = row.split(b'\t', 1)
            mode, kind, blob = metadata.decode().split(' ')
            assert mode in ('100644', '100755') and kind == 'blob'
            name = name.decode()
            path = ROOT / name
            assert not path.is_symlink() and path.resolve(strict=True) == path
            data = git('cat-file', 'blob', blob)
            assert path.read_bytes() == data
            assert hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest() == blob
            assert bool(path.stat().st_mode & 0o111) == (mode == '100755')
            anchored_files.add(str(path.relative_to(PACKET)))
        anchored_entries = set(anchored_files)
        for name in anchored_files:
            anchored_entries.update(str(parent) for parent in Path(name).parents if str(parent) != '.')
        assert {str(path.relative_to(PACKET)) for path in PACKET.rglob('*')} == anchored_entries
        assert not any(path.is_symlink() for path in PACKET.rglob('*'))
    print(json.dumps({'status': 'STATIC_ONLY_PASS_UNEXECUTED', 'targets': 50, 'profile_targets': [10, 20, 20],
                      'cells': 56, 'expanded_argv_checked': commands_checked, 'frozen_inputs': 541,
                      'historical_files_preserved': len(preserved), 'platform_inventory_entries': inventory_counts,
                      'calls_to_compiler_parser_runner_producer_tests_formatter': 0,
                      'external_anchor_gate': 'required before plan trust and immediately before every launch',
                      'externally_anchored_commit_checked': external_anchor,
                      'independent_readiness_review_required': True}, indent=2))


if __name__ == '__main__':
    inspect()
