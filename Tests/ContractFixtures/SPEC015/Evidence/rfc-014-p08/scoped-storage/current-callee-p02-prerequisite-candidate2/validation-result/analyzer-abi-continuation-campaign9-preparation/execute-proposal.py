#!/usr/bin/env python3
"""Frozen PROPOSED campaign wrapper. No authority is conferred by this file.

Only a separately authorized invocation with a reviewed postformat freeze may run.
Preparation validates this file with ast.parse; preparation never imports/runs it.
"""
from pathlib import Path
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import time

ROOT = Path('/Users/eugene/work/GiftUI')
PACKET = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def read(name):
    return json.loads((PACKET / name).read_text())




def main():
    assert len(sys.argv) == 3 and sys.argv[1] == '--execute-newly-authorized-campaign', (
        'STOP: proposal only; separate explicit source/campaign authorization required')
    if not __debug__ or sys.flags.optimize:
        raise SystemExit('STOP: assertions must be active')
    sys.dont_write_bytecode = True
    freeze_path = Path(sys.argv[2])
    assert freeze_path == ROOT / 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/analyzer-abi-continuation-freeze/postformat-freeze.json'
    assert freeze_path.is_absolute() and freeze_path.is_file()
    assert digest(freeze_path) == '0cb2c32520e4344940c4801c9bfea21206e828dd2d6db07dfb8ae06dd4840333', 'changed exact 541-input freeze'
    plan, selectors, sources, controls = [read(n) for n in (
        'recipe.json', 'selectors.json', 'scratch-sources.json', 'controls.json')]
    baseline = read('baseline-inputs.json')
    frozen = json.loads(freeze_path.read_text())
    assert set(frozen) == set(baseline), 'postformat freeze path set differs'
    assert {k for k in frozen if frozen[k] != baseline[k]} <= set(selectors['files'])
    if not os.environ.get('GIFTUI_VALIDATION_LOCK_OWNER'):
        os.execvp('ruby', ['ruby', str(ROOT / 'scripts/lib/serialize-validation.rb'),
                          sys.executable, str(Path(__file__).resolve()), *sys.argv[1:]])
    out = ROOT / plan['output_root']
    assert not out.exists(), 'No output reuse or retry'
    assert all(not (ROOT / p).exists() for p in plan['output_roots'].values())
    state = {'status': 'running', 'source_candidates': 1, 'automatic_repairs': 0,
             'retries': 0, 'postformat_freeze': str(freeze_path),
             'postformat_freeze_sha256': digest(freeze_path), 'stages': [],
             'control_receipts': [], 'producer_receipts': [],
             'omissions': controls['explicit_omissions'], 'strict_cold_eligible': False}
    refs = {}
    domain_producers = {}
    private_captures = {}
    private_count_captures = {}
    private_helper_continuation_captures = {}
    private_helper_leading_captures = {}
    current_commit = subprocess.check_output(
        ['git', 'rev-parse', '--verify', 'HEAD'], cwd=ROOT, text=True).strip()
    assert re.fullmatch(r'[0-9a-f]{40}', current_commit)
    state['authenticated_current_commit'] = current_commit
    private_policy = read('private-storage-policy.json')
    private_count_policy = read('private-count-policy.json')
    private_helper_continuation_policy = read('private-helper-continuation-policy.json')
    private_helper_leading_policy = read('private-helper-leading-policy.json')

    def verify():
        assert subprocess.check_output(['git', 'rev-parse', '--verify', 'HEAD'],
                                       cwd=ROOT, text=True).strip() == current_commit, 'HEAD drift'
        assert digest(freeze_path) == state['postformat_freeze_sha256']
        manifest = read('packet-hashes.json')
        assert {str(p.relative_to(PACKET)) for p in PACKET.rglob('*') if p.is_file()} == set(manifest) | {'packet-hashes.json'}, 'packet inventory drift'
        assert all(not p.is_symlink() for p in PACKET.rglob('*')), 'symlinked packet'
        for name, value in manifest.items():
            assert digest(PACKET / name) == value['sha256'], ('changed packet', name)
        for name, value in frozen.items():
            assert digest(ROOT / name) == value, ('changed frozen input', name)
        for name in selectors['files']:
            actual = (ROOT / name).read_text()
            positive = sources['sources']['positive/' + Path(name).name]['text']
            if name.startswith('Tests/'):
                assert actual == positive, ('fixture differs from exact candidate', name)
            else:
                assert re.sub(r'\s+', '', actual) == re.sub(r'\s+', '', positive), (
                    'nonformat candidate change', name)
        for name, value in read('provenance.json')['compiler_identities'].items():
            assert digest(ROOT / name) == value['sha256']
        for name, value in sources['sources'].items():
            assert hashlib.sha256(value['text'].encode()).hexdigest() == value['sha256']

    verify()
    from diagnostic_parser import classify_negative_diagnostics
    out.mkdir()
    (out / 'logs').mkdir()
    (out / 'receipts').mkdir()
    (out / 'macro/macro').mkdir(parents=True)
    (out / 'postformat-freeze.json').write_bytes(freeze_path.read_bytes())

    def save():
        (out / 'result.json').write_text(json.dumps(state, indent=2) + '\n')

    def launch(label, argv, extra_environment=None):
        verify()
        env = dict(os.environ)
        env.update(plan['environment'])
        if extra_environment:
            env.update(extra_environment)
        argv = list(map(str, argv))
        prefix = out / 'logs' / label
        if label == 'macos-static-private-helper-continuation-client-emit-object':
            helper_audit = state['private_helper_continuation_preclient_authentication']
            assert digest(helper_audit['path']) == helper_audit['sha256']
            planned = private_helper_continuation_captures['macos-static']['trusted_provenance']['consumer']
            assert argv == planned['argv'] and plan['environment'] == planned['environment_overrides']
        if label == 'macos-static-private-helper-leading-client-emit-object':
            helper_audit = state['private_helper_leading_preclient_authentication']
            assert digest(helper_audit['path']) == helper_audit['sha256']
            planned = private_helper_leading_captures['macos-static']['trusted_provenance']['consumer']
            assert argv == planned['argv'] and plan['environment'] == planned['environment_overrides']
        started, timer = time.time_ns(), time.monotonic()
        if label == 'macos-static-private-helper-continuation-client-emit-object':
            assert helper_audit['completed_ns'] <= started
            assert Path(helper_audit['path']).stat().st_mtime_ns <= started
        if label == 'macos-static-private-helper-leading-client-emit-object':
            assert helper_audit['completed_ns'] <= started
            assert Path(helper_audit['path']).stat().st_mtime_ns <= started
        with Path(str(prefix) + '.stdout').open('xb') as stdout, Path(str(prefix) + '.stderr').open('xb') as stderr:
            process = subprocess.run(argv, cwd=ROOT, env=env, stdout=stdout, stderr=stderr)
        text = Path(str(prefix) + '.stdout').read_text(errors='replace')
        diagnostics = Path(str(prefix) + '.stderr').read_text(errors='replace')
        row = {'name': label, 'argv': argv, 'environment_overrides': {
            **plan['environment'], **(extra_environment or {})}, 'started_ns': started,
            'finished_ns': time.time_ns(), 'seconds': round(time.monotonic() - timer, 3),
            'exit': process.returncode, 'stdout_sha256': digest(str(prefix) + '.stdout'),
            'stderr_sha256': digest(str(prefix) + '.stderr')}
        state['stages'].append(row)
        save()
        return row, text, diagnostics

    def positive(label, argv, extra_environment=None):
        row, text, diagnostics = launch(label, argv, extra_environment)
        assert row['exit'] == 0, ('material stage failure', label, row['exit'])
        return row, text, diagnostics

    def qualify(path, started, profile, package=None):
        path = Path(path).resolve()
        allowed = ROOT / ('.build/raspberry-pi' if profile == 'raspberry-pi-armv6'
                          else '.build/nrf52840' if profile == 'nrf52840-embedded' else '.build')
        assert path.is_relative_to(allowed) and path.is_file()
        assert path.stat().st_mtime_ns >= started, ('stale receipt', path)
        data = json.loads(path.read_text())
        assert data['profile'] == profile
        if package:
            assert data['package'] == package
        for name, value in data['inputs'].items():
            assert digest(ROOT / name) == value, ('producer input', name)
            if not name.startswith('.build/'):
                assert frozen.get(name) == value, ('unfrozen producer input', name)
        for name, value in data.get('artifacts', {}).items():
            artifact = (path.parent / name).resolve()
            assert artifact.is_relative_to(path.parent) and artifact.is_file()
            assert digest(artifact) == value['sha256'], ('producer artifact', name)
        if 'compiler' in data:
            assert digest(ROOT / data['compiler']) == data['compiler_sha256']
        for check in data.get('checks', []):
            if 'pass' in check:
                assert check['pass'] is True, check
            elif 'passed' in check:
                assert check['passed'] is True, check
            elif check.get('expected_failure') is True:
                assert check['exit'] != 0, check
            else:
                assert check['exit'] == 0, check
        reference = {'path': str(path), 'sha256': digest(path), 'data': data}
        archived = out / 'receipts' / (str(len(state['producer_receipts'])) + '.json')
        shutil.copyfile(path, archived)
        state['producer_receipts'].append({'path': str(path), 'sha256': reference['sha256'],
                                          'copy': str(archived), 'bytes': path.stat().st_size})
        save()
        return reference

    def discover(text, pattern, directory=False):
        matches = re.findall(pattern, text, re.M)
        assert len(matches) == 1, ('receipt discovery', pattern, matches)
        path = Path(matches[0].strip())
        return path / 'result.json' if directory else path

    def expand(argv, profile, cell, core, positive_cell=None, module=None, source_list=None, negative=None, outside=False):
        flags = plan['base_flags'] + plan['profile_flags'][profile] + plan['plugin_flags']
        if outside:
            flags = flags.copy()
            index = flags.index('-package-name')
            assert flags[index:index + 2] == ['-package-name', 'giftui']
            del flags[index:index + 2]
        values = {'compiler': plan['compilers'][profile], 'cell': str(cell),
                  'core': str(core), 'positive-cell': str(positive_cell or cell),
                  'module': module or '', 'negative-source': str(negative or '')}
        def text(token):
            for key, value in values.items():
                token = token.replace('{' + key + '}', value)
            assert '{' not in token and '}' not in token, ('unknown token', token)
            return token
        result = []
        for token in argv:
            result.extend([text(x) for x in flags] if token == '{flags...}'
                          else [text(x) for x in (source_list or [])] if token == '{sources...}'
                          else [text(token)])
        return result

    def materialize(cell, replacement=None):
        cell.mkdir(parents=True, exist_ok=False)
        (cell / 'inputs').mkdir()
        for name, value in sources['sources'].items():
            if name.startswith('positive/'):
                (cell / 'inputs' / Path(name).name).write_bytes(value['text'].encode())
        if replacement:
            value = sources['sources'][replacement]
            (cell / 'inputs' / Path(replacement).name).write_bytes(value['text'].encode())

    def module_argv(name, profile, cell, core):
        return expand(plan['module_argv'], profile, cell, core, module=name,
                      source_list=plan['scratch_sources_by_module'][name])

    def actual_bytes(path, started=None):
        path = Path(path)
        assert path.is_absolute() and path.resolve() == path and path.is_file(), ('noncanonical actual input', path)
        if started is not None:
            assert path.stat().st_mtime_ns >= started, ('stale actual input', path)
        return path.read_bytes()

    def stage_identity(row):
        return {key: row[key] for key in ('name', 'argv', 'environment_overrides', 'exit')}

    def authenticate_stage(row, label, argv, exit_code=0):
        assert row in state['stages'] and row['name'] == label and row['exit'] == exit_code
        assert row['argv'] == list(map(str, argv)) and row['environment_overrides'] == plan['environment']
        for stream in ('stdout', 'stderr'):
            assert digest(out / 'logs' / (label + '.' + stream)) == row[stream + '_sha256'], ('stage log drift', label)

    def authenticate_core(core, row, command, policy):
        # The caller obtains HEAD independently; receipt data cannot choose it.
        verify()
        authenticate_stage(row, 'P02-macos-static', command)
        assert refs['macos-static'] is core
        path = Path(core['path'])
        cp = policy['core_policy']
        assert path == Path(core['discovered_path']), 'receipt discovery/path drift'
        receipt_bytes = actual_bytes(path, row['started_ns'])
        assert hashlib.sha256(receipt_bytes).hexdigest() == core['sha256']
        data = json.loads(receipt_bytes)
        assert data == core['data']
        archived = next(item for item in state['producer_receipts'] if item['path'] == str(path))
        assert archived['sha256'] == core['sha256'] and actual_bytes(archived['copy']) == receipt_bytes, 'archived current P02 receipt drift'
        assert all(data.get(k) == v for k, v in cp['receipt_fields'].items()), 'current P02 frozen identity mismatch'
        assert data['source_commit'] == current_commit
        identity = hashlib.sha256(json.dumps({'inputs': data['inputs'], 'commit': current_commit,
                                             'compiler': data['compiler_sha256']}, sort_keys=True).encode()).hexdigest()
        assert data['input_sha256'] == identity
        base = path.parent
        assert base.parent.parent == Path(cp['parent']) and base.name == 'macos-static'
        assert base.parent.name.startswith(identity[:16] + '-') and len(base.parent.name) > 17
        assert str(base) not in preexisting_core_roots, 'reused P02 root'
        assert str(base) != cp['archived_root']
        for name, value in data['inputs'].items():
            assert frozen.get(name) == value and digest(ROOT / name) == value
        for key, hash_key in (('compiler', 'compiler_sha256'), ('macro_tool', 'macro_tool_sha256'),
                              ('swift_syntax_library', 'swift_syntax_sha256')):
            assert digest(ROOT / data[key]) == data[hash_key]
        for name, value in data['artifacts'].items():
            artifact = base / name
            payload = actual_bytes(artifact, row['started_ns'])
            assert value == {'bytes': len(payload), 'sha256': hashlib.sha256(payload).hexdigest()}
        # Unique stdout discovery must still name these actual receipt bytes.
        text = (out / 'logs/P02-macos-static.stdout').read_text(errors='replace')
        assert discover(text, r'^P02 macos-static:[\s\S]*?;\s*(\S+/result\.json)\s*$') == path
        artifact_path = base / cp['artifact_leaf']
        return {'root': str(base), 'receipt_path': str(path), 'receipt_sha256': core['sha256'],
                'receipt_bytes': receipt_bytes, 'artifact_path': str(artifact_path),
                'artifact_bytes': actual_bytes(artifact_path, row['started_ns'])}

    def capture_private_storage(control, profile, cell, positive_cell, path, argv):
        assert (profile, control['id'], control['first_expected_stage']) == ('macos-static', 'private-storage', 'client-emit-object')
        verify()
        declared_cell = ROOT / plan['output_roots']['macos-static'] / 'scratch/private-storage'
        assert cell == declared_cell and path == cell / 'inputs/private-storage.swift'
        assert positive_cell == ROOT / plan['output_roots']['macos-static'] / 'scratch/positive-actual-lowering'
        core = refs['macos-static']
        core_row = next(s for s in state['stages'] if s['name'] == 'P02-macos-static')
        command = next(s['argv'] for s in plan['profile_commands'] if s['profile'] == profile)
        trusted_core = authenticate_core(core, core_row, command, private_policy)
        current_core = trusted_core['root']
        p = private_policy
        root = str(ROOT / plan['output_root'])
        def remap(v):
            if isinstance(v, str):
                mapped = v.replace(p['campaign_root'] + '/', root + '/')
                return current_core if mapped == p['core_policy']['archived_root'] else mapped
            if isinstance(v, list): return [remap(x) for x in v]
            if isinstance(v, dict): return {k: remap(x) for k, x in v.items()}
            return v
        producer_snapshot = domain_producers[profile]
        producer_row = producer_snapshot['row']
        expected_producer = remap(p['producer'])
        authenticate_stage(producer_row, expected_producer['name'], expected_producer['argv'])
        assert stage_identity(producer_row) == expected_producer
        assert argv == remap(p['consumer']['argv'])
        artifacts = {}
        for key, declared in p['artifacts'].items():
            actual_path = Path(remap(declared['path']))
            payload = actual_bytes(actual_path)
            assert payload == producer_snapshot['artifacts'][str(actual_path)], ('Domain output/source changed after producer', key)
            if key != 'imported_module':
                assert len(payload) == declared['bytes'] and hashlib.sha256(payload).hexdigest() == declared['sha256']
            else:
                assert len(payload) > 0  # Current producer bytes, never historical module hash.
            artifacts[key] = {'path': str(actual_path), 'bytes': payload}
        for artifact_path, captured_bytes in producer_snapshot['artifacts'].items():
            assert actual_bytes(artifact_path) == captured_bytes, ('Domain producer artifact drift', artifact_path)
        producer = stage_identity(producer_row)
        module = artifacts['imported_module']
        module_receipt = {'module_name': 'SignalAnalyzerDomain', 'module_path': module['path'],
                          'module_sha256': hashlib.sha256(module['bytes']).hexdigest(), 'producer': producer,
                          'source_inputs': {k: {'path': v['path'], 'sha256': hashlib.sha256(v['bytes']).hexdigest()}
                                            for k, v in artifacts.items() if k != 'imported_module'}}
        trusted_input = {'path': str(path), 'bytes': actual_bytes(path)}
        assert trusted_input['bytes'] == sources['sources']['privacy/private-storage.swift']['text'].encode()
        assert hashlib.sha256(trusted_input['bytes']).hexdigest() == p['client_sha256']
        capture = {'trusted_current_commit': current_commit, 'trusted_core': trusted_core,
                   'trusted_input': trusted_input, 'context': p['context'],
                   'trusted_provenance': {'artifacts': artifacts, 'producer': producer,
                                          'consumer': remap(p['consumer']), 'module_receipt': module_receipt}}
        # Persist audit hashes while immutable bytes remain in memory for classification.
        def audit(v):
            if isinstance(v, bytes): return {'bytes': len(v), 'sha256': hashlib.sha256(v).hexdigest()}
            if isinstance(v, dict): return {k: audit(x) for k, x in v.items()}
            if isinstance(v, list): return [audit(x) for x in v]
            return v
        audit_path = out / 'receipts/private-storage-preclient-authentication.json'
        assert not audit_path.exists()
        audit_payload = {'parser_arguments': audit(capture),
                         'core_producer_stage': dict(core_row),
                         'domain_producer_stage': dict(producer_row),
                         'domain_producer_artifacts': audit(producer_snapshot['artifacts'])}
        audit_path.write_text(json.dumps(audit_payload, indent=2, sort_keys=True) + '\n')
        state['private_storage_preclient_authentication'] = {'path': str(audit_path), 'sha256': digest(audit_path)}
        save()
        return capture

    def capture_private_count(control, profile, cell, positive_cell, path, argv):
        assert (profile, control['id'], control['first_expected_stage']) == ('macos-static', 'private-count', 'client-emit-object')
        verify()
        selected_control = read('macos-static-private-count-opt-in-control.json')
        comparable = dict(selected_control)
        del comparable['virtual_display_note']
        comparable['dependency_note_sources'] = control['dependency_note_sources']
        assert comparable == control, 'private-count control semantics changed'
        assert selected_control['virtual_display_note'] == {'policy_id': private_count_policy['id']}
        declared_cell = ROOT / plan['output_roots']['macos-static'] / 'scratch/private-count'
        assert cell == declared_cell and path == cell / 'inputs/private-count.swift'
        assert positive_cell == ROOT / plan['output_roots']['macos-static'] / 'scratch/positive-actual-lowering'
        core = refs['macos-static']
        core_row = next(s for s in state['stages'] if s['name'] == 'P02-macos-static')
        command = next(s['argv'] for s in plan['profile_commands'] if s['profile'] == profile)
        trusted_core = authenticate_core(core, core_row, command, private_count_policy)
        current_core = trusted_core['root']
        p = private_count_policy
        root = str(ROOT / plan['output_root'])
        def remap(v):
            if isinstance(v, str):
                mapped = v.replace(p['campaign_root'] + '/', root + '/')
                return current_core if mapped == p['core_policy']['archived_root'] else mapped
            if isinstance(v, list): return [remap(x) for x in v]
            if isinstance(v, dict): return {k: remap(x) for k, x in v.items()}
            return v
        producer_snapshot = domain_producers[profile]
        producer_row = producer_snapshot['row']
        expected_producer = remap(p['producer'])
        authenticate_stage(producer_row, expected_producer['name'], expected_producer['argv'])
        assert stage_identity(producer_row) == expected_producer
        assert argv == remap(p['consumer']['argv'])
        assert selected_control['dependency_note_sources'] == remap(p['dependency_paths'])
        artifacts = {}
        for key, declared in p['artifacts'].items():
            actual_path = Path(remap(declared['path']))
            payload = actual_bytes(actual_path)
            assert payload == producer_snapshot['artifacts'][str(actual_path)], ('Domain output/source changed after producer', key)
            if key != 'imported_module':
                assert len(payload) == declared['bytes'] and hashlib.sha256(payload).hexdigest() == declared['sha256']
            else:
                assert len(payload) > 0  # Current producer bytes, never historical module hash.
            artifacts[key] = {'path': str(actual_path), 'bytes': payload}
        for artifact_path, captured_bytes in producer_snapshot['artifacts'].items():
            assert actual_bytes(artifact_path) == captured_bytes, ('Domain producer artifact drift', artifact_path)
        producer = stage_identity(producer_row)
        module = artifacts['imported_module']
        module_receipt = {'module_name': 'SignalAnalyzerDomain', 'module_path': module['path'],
                          'module_sha256': hashlib.sha256(module['bytes']).hexdigest(), 'producer': producer,
                          'source_inputs': {k: {'path': v['path'], 'sha256': hashlib.sha256(v['bytes']).hexdigest()}
                                            for k, v in artifacts.items() if k != 'imported_module'}}
        trusted_input = {'path': str(path), 'bytes': actual_bytes(path)}
        assert trusted_input['bytes'] == sources['sources']['privacy/private-count.swift']['text'].encode()
        assert hashlib.sha256(trusted_input['bytes']).hexdigest() == p['client_sha256']
        capture = {'trusted_current_commit': current_commit, 'trusted_core': trusted_core,
                   'trusted_input': trusted_input, 'context': p['context'],
                   'trusted_provenance': {'artifacts': artifacts, 'producer': producer,
                                          'consumer': remap(p['consumer']), 'module_receipt': module_receipt}}
        # Persist audit hashes while immutable bytes remain in memory for classification.
        def audit(v):
            if isinstance(v, bytes): return {'bytes': len(v), 'sha256': hashlib.sha256(v).hexdigest()}
            if isinstance(v, dict): return {k: audit(x) for k, x in v.items()}
            if isinstance(v, list): return [audit(x) for x in v]
            return v
        audit_path = out / 'receipts/private-count-preclient-authentication.json'
        assert not audit_path.exists()
        audit_payload = {'parser_arguments': audit(capture),
                         'core_producer_stage': dict(core_row),
                         'domain_producer_stage': dict(producer_row),
                         'domain_producer_artifacts': audit(producer_snapshot['artifacts'])}
        audit_path.write_text(json.dumps(audit_payload, indent=2, sort_keys=True) + '\n')
        state['private_count_preclient_authentication'] = {'path': str(audit_path), 'sha256': digest(audit_path)}
        save()
        return capture

    def capture_private_helper_continuation(control, profile, cell, positive_cell, path, argv):
        assert (profile, control['id'], control['first_expected_stage']) == ('macos-static', 'private-helper-continuation', 'client-emit-object')
        verify()
        selected_control = read('macos-static-private-helper-continuation-opt-in-control.json')
        comparable = dict(selected_control)
        del comparable['virtual_display_note']
        comparable['dependency_note_sources'] = control['dependency_note_sources']
        assert type(control['expected_nonzero']) is bool
        assert json.dumps(comparable, sort_keys=True) == json.dumps(control, sort_keys=True), 'private-helper-continuation control semantics changed'
        assert selected_control['virtual_display_note'] == {'policy_id': private_helper_continuation_policy['id']}
        declared_cell = ROOT / plan['output_roots']['macos-static'] / 'scratch/private-helper-continuation'
        assert cell == declared_cell and path == cell / 'inputs/private-helper-continuation.swift'
        assert positive_cell == ROOT / plan['output_roots']['macos-static'] / 'scratch/positive-actual-lowering'
        core = refs['macos-static']
        core_row = next(s for s in state['stages'] if s['name'] == 'P02-macos-static')
        command = next(s['argv'] for s in plan['profile_commands'] if s['profile'] == profile)
        trusted_core = authenticate_core(core, core_row, command, private_helper_continuation_policy)
        receipt = json.loads(trusted_core['receipt_bytes'])
        assert all(json.dumps(receipt.get(k), sort_keys=True) == json.dumps(v, sort_keys=True)
                   for k, v in private_helper_continuation_policy['core_policy']['receipt_fields'].items()), 'helper exact JSON core identity mismatch'
        current_core = trusted_core['root']
        p = private_helper_continuation_policy
        root = str(ROOT / plan['output_root'])
        def remap(v):
            if isinstance(v, str):
                mapped = v.replace(p['campaign_root'] + '/', root + '/')
                return current_core if mapped == p['core_policy']['archived_root'] else mapped
            if isinstance(v, list): return [remap(x) for x in v]
            if isinstance(v, dict): return {k: remap(x) for k, x in v.items()}
            return v
        producer_snapshot = domain_producers[profile]
        producer_row = producer_snapshot['row']
        expected_producer = remap(p['producer'])
        authenticate_stage(producer_row, expected_producer['name'], expected_producer['argv'])
        assert json.dumps(stage_identity(producer_row), sort_keys=True) == json.dumps(expected_producer, sort_keys=True), 'helper exact JSON producer identity mismatch'
        consumer = remap(p['consumer'])
        assert type(consumer['exit']) is int and consumer['exit'] == 1
        assert consumer['name'] == 'macos-static-private-helper-continuation-client-emit-object'
        assert consumer['environment_overrides'] == plan['environment']
        assert argv == consumer['argv']
        assert argv == expand(plan['scratch_negative_argv'], profile, cell, Path(current_core), positive_cell, negative=path)
        assert selected_control['dependency_note_sources'] == remap(p['dependency_paths'])
        artifacts = {}
        for key, declared in p['artifacts'].items():
            actual_path = Path(remap(declared['path']))
            payload = actual_bytes(actual_path)
            assert payload == producer_snapshot['artifacts'][str(actual_path)], ('Domain output/source changed after producer', key)
            if key != 'imported_module':
                assert len(payload) == declared['bytes'] and hashlib.sha256(payload).hexdigest() == declared['sha256']
            else:
                assert len(payload) > 0  # Current producer bytes, never historical module hash.
            artifacts[key] = {'path': str(actual_path), 'bytes': payload}
        for artifact_path, captured_bytes in producer_snapshot['artifacts'].items():
            assert actual_bytes(artifact_path) == captured_bytes, ('Domain producer artifact drift', artifact_path)
        producer = stage_identity(producer_row)
        module = artifacts['imported_module']
        module_receipt = {'module_name': 'SignalAnalyzerDomain', 'module_path': module['path'],
                          'module_sha256': hashlib.sha256(module['bytes']).hexdigest(), 'producer': producer,
                          'source_inputs': {k: {'path': v['path'], 'sha256': hashlib.sha256(v['bytes']).hexdigest()}
                                            for k, v in artifacts.items() if k != 'imported_module'}}
        trusted_input = {'path': str(path), 'bytes': actual_bytes(path)}
        assert trusted_input['bytes'] == sources['sources']['privacy/private-helper-continuation.swift']['text'].encode()
        assert hashlib.sha256(trusted_input['bytes']).hexdigest() == p['client_sha256']
        capture = {'trusted_current_commit': current_commit, 'trusted_core': trusted_core,
                   'trusted_input': trusted_input, 'context': p['context'],
                   'trusted_provenance': {'artifacts': artifacts, 'producer': producer,
                                          'consumer': remap(p['consumer']), 'module_receipt': module_receipt}}
        # Persist audit hashes while immutable bytes remain in memory for classification.
        def audit(v):
            if isinstance(v, bytes): return {'bytes': len(v), 'sha256': hashlib.sha256(v).hexdigest()}
            if isinstance(v, dict): return {k: audit(x) for k, x in v.items()}
            if isinstance(v, list): return [audit(x) for x in v]
            return v
        audit_path = out / 'receipts/private-helper-continuation-preclient-authentication.json'
        assert not audit_path.exists()
        audit_payload = {'authenticated_at_ns': time.time_ns(),
                         'control': selected_control,
                         'planned_consumer': consumer,
                         'parser_arguments': audit(capture),
                         'core_producer_stage': dict(core_row),
                         'domain_producer_stage': dict(producer_row),
                         'domain_producer_artifacts': audit(producer_snapshot['artifacts'])}
        audit_path.write_text(json.dumps(audit_payload, indent=2, sort_keys=True) + '\n')
        state['private_helper_continuation_preclient_authentication'] = {'path': str(audit_path), 'sha256': digest(audit_path),
                                                                          'completed_ns': time.time_ns()}
        save()
        return capture

    def capture_private_helper_leading(control, profile, cell, positive_cell, path, argv):
        assert (profile, control['id'], control['first_expected_stage']) == ('macos-static', 'private-helper-leading', 'client-emit-object')
        verify()
        selected_control = read('macos-static-private-helper-leading-opt-in-control.json')
        comparable = dict(selected_control)
        del comparable['virtual_display_note']
        comparable['dependency_note_sources'] = control['dependency_note_sources']
        assert type(control['expected_nonzero']) is bool
        assert json.dumps(comparable, sort_keys=True) == json.dumps(control, sort_keys=True), 'private-helper-leading control semantics changed'
        assert selected_control['virtual_display_note'] == {'policy_id': private_helper_leading_policy['id']}
        declared_cell = ROOT / plan['output_roots']['macos-static'] / 'scratch/private-helper-leading'
        assert cell == declared_cell and path == cell / 'inputs/private-helper-leading.swift'
        assert positive_cell == ROOT / plan['output_roots']['macos-static'] / 'scratch/positive-actual-lowering'
        core = refs['macos-static']
        core_row = next(s for s in state['stages'] if s['name'] == 'P02-macos-static')
        command = next(s['argv'] for s in plan['profile_commands'] if s['profile'] == profile)
        trusted_core = authenticate_core(core, core_row, command, private_helper_leading_policy)
        receipt = json.loads(trusted_core['receipt_bytes'])
        assert all(json.dumps(receipt.get(k), sort_keys=True) == json.dumps(v, sort_keys=True)
                   for k, v in private_helper_leading_policy['core_policy']['receipt_fields'].items()), 'helper exact JSON core identity mismatch'
        current_core = trusted_core['root']
        p = private_helper_leading_policy
        root = str(ROOT / plan['output_root'])
        def remap(v):
            if isinstance(v, str):
                mapped = v.replace(p['campaign_root'] + '/', root + '/')
                return current_core if mapped == p['core_policy']['archived_root'] else mapped
            if isinstance(v, list): return [remap(x) for x in v]
            if isinstance(v, dict): return {k: remap(x) for k, x in v.items()}
            return v
        producer_snapshot = domain_producers[profile]
        producer_row = producer_snapshot['row']
        expected_producer = remap(p['producer'])
        assert expected_producer['argv'] == module_argv('SignalAnalyzerDomain', profile, positive_cell, Path(current_core))
        authenticate_stage(producer_row, expected_producer['name'], expected_producer['argv'])
        assert json.dumps(stage_identity(producer_row), sort_keys=True) == json.dumps(expected_producer, sort_keys=True), 'helper exact JSON producer identity mismatch'
        consumer = remap(p['consumer'])
        assert type(consumer['exit']) is int and consumer['exit'] == 1
        assert consumer['name'] == 'macos-static-private-helper-leading-client-emit-object'
        assert consumer['environment_overrides'] == plan['environment']
        assert argv == consumer['argv']
        assert argv == expand(plan['scratch_negative_argv'], profile, cell, Path(current_core), positive_cell, negative=path)
        assert selected_control['dependency_note_sources'] == remap(p['dependency_paths'])
        artifacts = {}
        for key, declared in p['artifacts'].items():
            actual_path = Path(remap(declared['path']))
            payload = actual_bytes(actual_path)
            assert payload == producer_snapshot['artifacts'][str(actual_path)], ('Domain output/source changed after producer', key)
            if key != 'imported_module':
                assert len(payload) == declared['bytes'] and hashlib.sha256(payload).hexdigest() == declared['sha256']
            else:
                assert len(payload) > 0  # Current producer bytes, never historical module hash.
            artifacts[key] = {'path': str(actual_path), 'bytes': payload}
        for artifact_path, captured_bytes in producer_snapshot['artifacts'].items():
            assert actual_bytes(artifact_path) == captured_bytes, ('Domain producer artifact drift', artifact_path)
        producer = stage_identity(producer_row)
        module = artifacts['imported_module']
        module_receipt = {'module_name': 'SignalAnalyzerDomain', 'module_path': module['path'],
                          'module_sha256': hashlib.sha256(module['bytes']).hexdigest(), 'producer': producer,
                          'source_inputs': {k: {'path': v['path'], 'sha256': hashlib.sha256(v['bytes']).hexdigest()}
                                            for k, v in artifacts.items() if k != 'imported_module'}}
        trusted_input = {'path': str(path), 'bytes': actual_bytes(path)}
        assert trusted_input['bytes'] == sources['sources']['privacy/private-helper-leading.swift']['text'].encode()
        assert hashlib.sha256(trusted_input['bytes']).hexdigest() == p['client_sha256']
        capture = {'trusted_current_commit': current_commit, 'trusted_core': trusted_core,
                   'trusted_input': trusted_input, 'context': p['context'],
                   'trusted_provenance': {'artifacts': artifacts, 'producer': producer,
                                          'consumer': remap(p['consumer']), 'module_receipt': module_receipt}}
        # Persist audit hashes while immutable bytes remain in memory for classification.
        def audit(v):
            if isinstance(v, bytes): return {'bytes': len(v), 'sha256': hashlib.sha256(v).hexdigest()}
            if isinstance(v, dict): return {k: audit(x) for k, x in v.items()}
            if isinstance(v, list): return [audit(x) for x in v]
            return v
        audit_path = out / 'receipts/private-helper-leading-preclient-authentication.json'
        assert not audit_path.exists()
        audit_payload = {'authenticated_at_ns': time.time_ns(),
                         'control': selected_control,
                         'planned_consumer': consumer,
                         'parser_arguments': audit(capture),
                         'core_producer_stage': dict(core_row),
                         'domain_producer_stage': dict(producer_row),
                         'domain_producer_artifacts': audit(producer_snapshot['artifacts'])}
        audit_path.write_text(json.dumps(audit_payload, indent=2, sort_keys=True) + '\n')
        state['private_helper_leading_preclient_authentication'] = {'path': str(audit_path), 'sha256': digest(audit_path),
                                                                          'completed_ns': time.time_ns()}
        save()
        return capture

    def diagnostic(control, row, text, errors, expected_path, cell, positive_cell, profile, module):
        dependencies = [Path(name.replace('{cell}', str(cell)).replace('{positive-cell}', str(positive_cell)))
                        for name in control['dependency_note_sources']]
        selected_control = control
        policy_arguments = {}
        if (profile, control['id'], module) == ('macos-static', 'negative-A4', 'SignalAnalyzerDomain'):
            declared_cell = ROOT / plan['output_roots']['macos-static'] / 'scratch/negative-A4'
            declared_input = declared_cell / 'inputs/SignalPrimitiveValues.swift'
            assert cell == declared_cell and expected_path == declared_input
            assert declared_input.resolve() == declared_input, 'symlinked trusted input'
            selected_control = read('macos-static-A4-opt-in-control.json')
            comparable = dict(selected_control)
            del comparable['display_only_note']
            comparable['diagnostic_source'] = control['diagnostic_source']
            comparable['dependency_note_sources'] = control['dependency_note_sources']
            assert comparable == control, 'A4 control semantics changed'
            assert selected_control['diagnostic_source'] == str(declared_input)
            assert selected_control['dependency_note_sources'] == list(map(str, dependencies))
            trusted_bytes = declared_input.read_bytes()
            assert trusted_bytes == sources['sources']['negative-A4/SignalPrimitiveValues.swift']['text'].encode()
            assert hashlib.sha256(trusted_bytes).hexdigest() == selected_control['display_only_note']['input_sha256']
            policy_arguments = {'context': {'profile': profile, 'module': module},
                                'trusted_input': {'path': str(declared_input), 'bytes': trusted_bytes}}
        elif (profile, control['id'], module) == ('macos-static', 'negative-A7', 'AnalyzerPresentation'):
            declared_cell = ROOT / plan['output_roots']['macos-static'] / 'scratch/negative-A7'
            declared_input = declared_cell / 'AnalyzerPresentation.swift'
            assert cell == declared_cell and expected_path == declared_input
            assert declared_input.resolve() == declared_input, 'symlinked trusted generated input'
            selected_control = read('macos-static-A7-opt-in-control.json')
            comparable = dict(selected_control)
            del comparable['display_only_note']
            comparable['diagnostic_source'] = control['diagnostic_source']
            comparable['dependency_note_sources'] = control['dependency_note_sources']
            assert comparable == control, 'A7 control semantics changed'
            assert selected_control['diagnostic_source'] == str(declared_input)
            assert selected_control['dependency_note_sources'] == list(map(str, dependencies))
            trusted_bytes = declared_input.read_bytes()
            assert trusted_bytes == (PACKET / 'A7-frozen-AnalyzerPresentation.swift').read_bytes()
            assert hashlib.sha256(trusted_bytes).hexdigest() == '3e3429824b630c383408b3a9d8cf9bca4b614f19ac61fa333a2b6eb5c8521dd2'
            assert selected_control['display_only_note']['input_sha256'] == '3e3429824b630c383408b3a9d8cf9bca4b614f19ac61fa333a2b6eb5c8521dd2'
            policy_arguments = {'context': {'profile': profile, 'module': module},
                                'trusted_input': {'path': str(declared_input), 'bytes': trusted_bytes}}
        elif (profile, control['id'], module) == ('macos-static', 'negative-A8', 'AnalyzerPresentation'):
            declared_cell = ROOT / plan['output_roots']['macos-static'] / 'scratch/negative-A8'
            declared_input = declared_cell / 'AnalyzerPresentation.swift'
            assert cell == declared_cell and expected_path == declared_input
            assert declared_input.resolve() == declared_input, 'symlinked trusted generated input'
            selected_control = read('macos-static-A8-opt-in-control.json')
            comparable = dict(selected_control)
            del comparable['display_only_note']
            comparable['diagnostic_source'] = control['diagnostic_source']
            comparable['dependency_note_sources'] = control['dependency_note_sources']
            assert comparable == control, 'A8 control semantics changed'
            assert selected_control['diagnostic_source'] == str(declared_input)
            assert selected_control['dependency_note_sources'] == list(map(str, dependencies))
            trusted_bytes = declared_input.read_bytes()
            assert trusted_bytes == (PACKET / 'A8-frozen-AnalyzerPresentation.swift').read_bytes()
            assert hashlib.sha256(trusted_bytes).hexdigest() == '1085b6e5c6126cc31dabf25b65234143fb2292400b4fd45e6d6246e3d8879b1c'
            assert selected_control['display_only_note']['input_sha256'] == '1085b6e5c6126cc31dabf25b65234143fb2292400b4fd45e6d6246e3d8879b1c'
            policy_arguments = {'context': {'profile': profile, 'module': module},
                                'trusted_input': {'path': str(declared_input), 'bytes': trusted_bytes}}
        elif (profile, control['id'], control['first_expected_stage']) == ('macos-static', 'private-storage', 'client-emit-object'):
            policy_arguments = private_captures[profile]
            assert expected_path == Path(policy_arguments['trusted_input']['path'])
            assert actual_bytes(expected_path) == policy_arguments['trusted_input']['bytes']
            assert stage_identity(row) == policy_arguments['trusted_provenance']['consumer']
            authenticate_stage(row, row['name'], policy_arguments['trusted_provenance']['consumer']['argv'], 1)
            # Semantic control is unchanged; only declared dependency paths and explicit opt-in are added.
            selected_control = dict(control)
            selected_control['dependency_note_sources'] = list(map(str, dependencies))
            selected_control['virtual_display_note'] = {'policy_id': private_policy['id']}
            audit_ref = state['private_storage_preclient_authentication']
            assert digest(audit_ref['path']) == audit_ref['sha256']
        elif (profile, control['id'], control['first_expected_stage']) == ('macos-static', 'private-count', 'client-emit-object'):
            policy_arguments = private_count_captures[profile]
            assert expected_path == Path(policy_arguments['trusted_input']['path'])
            assert actual_bytes(expected_path) == policy_arguments['trusted_input']['bytes']
            assert stage_identity(row) == policy_arguments['trusted_provenance']['consumer']
            authenticate_stage(row, row['name'], policy_arguments['trusted_provenance']['consumer']['argv'], 1)
            # Semantic control is unchanged; only declared dependency paths and explicit opt-in are added.
            selected_control = read('macos-static-private-count-opt-in-control.json')
            comparable = dict(selected_control)
            del comparable['virtual_display_note']
            comparable['dependency_note_sources'] = control['dependency_note_sources']
            assert comparable == control, 'private-count control semantics changed'
            assert selected_control['dependency_note_sources'] == list(map(str, dependencies))
            assert selected_control['virtual_display_note'] == {'policy_id': private_count_policy['id']}
            audit_ref = state['private_count_preclient_authentication']
            assert digest(audit_ref['path']) == audit_ref['sha256']
        elif (profile, control['id'], control['first_expected_stage']) == ('macos-static', 'private-helper-continuation', 'client-emit-object'):
            policy_arguments = private_helper_continuation_captures[profile]
            assert expected_path == Path(policy_arguments['trusted_input']['path'])
            assert actual_bytes(expected_path) == policy_arguments['trusted_input']['bytes']
            assert json.dumps(stage_identity(row), sort_keys=True) == json.dumps(policy_arguments['trusted_provenance']['consumer'], sort_keys=True), 'helper exact JSON consumer identity mismatch'
            authenticate_stage(row, row['name'], policy_arguments['trusted_provenance']['consumer']['argv'], 1)
            # Semantic control is unchanged; only declared dependency paths and explicit opt-in are added.
            selected_control = read('macos-static-private-helper-continuation-opt-in-control.json')
            comparable = dict(selected_control)
            del comparable['virtual_display_note']
            comparable['dependency_note_sources'] = control['dependency_note_sources']
            assert json.dumps(comparable, sort_keys=True) == json.dumps(control, sort_keys=True), 'private-helper-continuation control semantics changed'
            assert selected_control['dependency_note_sources'] == list(map(str, dependencies))
            assert selected_control['virtual_display_note'] == {'policy_id': private_helper_continuation_policy['id']}
            audit_ref = state['private_helper_continuation_preclient_authentication']
            assert digest(audit_ref['path']) == audit_ref['sha256']
            assert audit_ref['completed_ns'] <= row['started_ns'], 'helper audit must precede compiler start'
        elif (profile, control['id'], control['first_expected_stage']) == ('macos-static', 'private-helper-leading', 'client-emit-object'):
            policy_arguments = private_helper_leading_captures[profile]
            assert expected_path == Path(policy_arguments['trusted_input']['path'])
            assert actual_bytes(expected_path) == policy_arguments['trusted_input']['bytes']
            assert json.dumps(stage_identity(row), sort_keys=True) == json.dumps(policy_arguments['trusted_provenance']['consumer'], sort_keys=True), 'helper exact JSON consumer identity mismatch'
            authenticate_stage(row, row['name'], policy_arguments['trusted_provenance']['consumer']['argv'], 1)
            # Semantic control is unchanged; only declared dependency paths and explicit opt-in are added.
            selected_control = read('macos-static-private-helper-leading-opt-in-control.json')
            comparable = dict(selected_control)
            del comparable['virtual_display_note']
            comparable['dependency_note_sources'] = control['dependency_note_sources']
            assert json.dumps(comparable, sort_keys=True) == json.dumps(control, sort_keys=True), 'private-helper-leading control semantics changed'
            assert selected_control['dependency_note_sources'] == list(map(str, dependencies))
            assert selected_control['virtual_display_note'] == {'policy_id': private_helper_leading_policy['id']}
            audit_ref = state['private_helper_leading_preclient_authentication']
            assert digest(audit_ref['path']) == audit_ref['sha256']
            assert audit_ref['completed_ns'] <= row['started_ns'], 'helper audit must precede compiler start'
        records = classify_negative_diagnostics(selected_control, row['exit'], text, errors,
                                                expected_path, dependencies, **policy_arguments)
        row['primary_diagnostics'] = records
        row['expected_nonzero'] = True
        row['classified_category'] = control['category']
        row['diagnostic_source'] = str(expected_path)
        save()

    def control_receipt(control, profile, cell, core, positive_cell):
        data = {'profile': profile, 'control': control['id'], 'passed': True,
                'category': control.get('category'), 'core_receipt_sha256': digest(core / 'result.json'),
                'positive_cell': str(positive_cell), 'compiler': plan['compilers'][profile],
                'compiler_sha256': digest(plan['compilers'][profile]),
                'artifacts': {str(p.relative_to(cell)): {'sha256': digest(p), 'bytes': p.stat().st_size}
                              for p in cell.rglob('*') if p.is_file() and 'cache' not in p.relative_to(cell).parts},
                'command_labels': [s['name'] for s in state['stages']
                                   if s['name'].startswith(profile + '-' + control['id'] + '-')],
                'transitive_imports': {'core': {'path': str(core / 'result.json'), 'sha256': digest(core / 'result.json')},
                                       'positive_scratch': {str(p.relative_to(positive_cell)): digest(p)
                                                            for p in positive_cell.glob('*')
                                                            if p.suffix in ('.o', '.swiftmodule')}}}
        path = cell / ('control-' + control['id'] + '.json')
        path.write_text(json.dumps(data, indent=2) + '\n')
        state['control_receipts'].append({'profile': profile, 'control': control['id'],
                                          'path': str(path), 'sha256': digest(path)})
        save()

    assert private_count_policy['core_policy']['parent'] == private_policy['core_policy']['parent']
    assert private_helper_continuation_policy['core_policy']['parent'] == private_policy['core_policy']['parent']
    assert private_helper_leading_policy['core_policy']['parent'] == private_policy['core_policy']['parent']
    preexisting_core_roots = {str(p) for p in Path(private_policy['core_policy']['parent']).glob('*/macos-static')}

    try:
        _, sdk, _ = positive('sdk-preflight', ['xcrun', '--sdk', 'macosx', '--show-sdk-path'])
        expected_sdk = plan['profile_flags']['macos-static'][3]
        assert sdk.strip() == expected_sdk, 'SDK drift: stop before compiler'
        macro = read('macro-stages.json')
        methods = re.findall(r'^    func (test\w+)\(', (ROOT / 'Tests/GiftUIMacrosTests/ObservableStateHostMacroTests.swift').read_text(), re.M)
        historical = PACKET.parent.parent / 'validation'
        assert methods == json.loads((historical / 'registered-methods.json').read_text()) and len(methods) == 19
        assert re.findall(r'#selector\(ObservableStateHostMacroTests\.(test\w+)\)',
                          (historical / 'TestMain-macos.swift').read_text()) == methods
        for stage in macro['stages']:
            _, text, _ = positive(stage['name'], stage['command'],
                                  macro['environment'] if stage.get('runner_environment') else None)
            if stage['name'] == 'macro-tests':
                assert re.findall(r'^executions=19 failures=0 skips=0$', text, re.M) == ['executions=19 failures=0 skips=0']
        state['fresh_macro_artifacts'] = {str(p.relative_to(out / 'macro')): digest(p)
                                          for p in (out / 'macro').rglob('*')
                                          if p.is_file() and 'cache' not in p.parts and 'index' not in p.parts}
        save()
        for profile in plan['profile_order']:
            stage = next(s for s in plan['profile_commands'] if s['profile'] == profile)
            row, text, _ = positive('P02-' + profile, stage['argv'])
            discovered_core = discover(text, r'^P02 ' + profile + r':[\s\S]*?;\s*(\S+/result\.json)\s*$')
            core = qualify(discovered_core, row['started_ns'], profile, 'P02')
            core['discovered_path'] = str(discovered_core)
            p04 = qualify(discover(text, r'^P04 ' + profile + r':[\s\S]*?;\s*(\S+/result\.json)\s*$'), row['started_ns'], profile, 'P04')
            assert p04['data']['core_receipt_sha256'] == core['sha256']
            assert {'CounterPresentation.swift', 'CounterPresentation.o', 'AnalyzerPresentation.swift', 'AnalyzerPresentation.o', 'DeclarationHost.o'} <= core['data']['artifacts'].keys()
            checks = {c['check'] for c in core['data']['checks']}
            assert {'AnalyzerPresentation', 'DeclarationHost', 'native-execution' if profile.startswith('macos') else 'target-abi'} <= checks
            if profile.startswith('macos'):
                assert core['data']['execution'] == 'checks=120 failures=0'
            base = Path(core['path']).parent
            assert digest(ROOT / core['data']['macro_tool']) == core['data']['macro_tool_sha256']
            refs[profile] = core
            profile_root = ROOT / plan['output_roots'][profile]
            profile_root.mkdir(parents=True, exist_ok=False)
            positive_cell = profile_root / 'scratch/positive-actual-lowering'
            for control in controls['controls']:
                label = profile + '-' + control['id'] + '-'
                kind = control['kind']
                if control['id'] == 'positive-actual-lowering':
                    cell = positive_cell
                    materialize(cell)
                    for name in ('SignalAnalyzerDomain', 'lower-Analyzer-source', 'AnalyzerSchema', 'AnalyzerPresentation', 'DeclarationHost'):
                        argv = expand(plan['lower_argv'], profile, cell, base) if name == 'lower-Analyzer-source' else module_argv(name, profile, cell, base)
                        producer_row, _, _ = positive(label + name, argv)
                        if profile == 'macos-static' and name == 'SignalAnalyzerDomain':
                            domain_paths = [cell / 'inputs' / n for n in ('SignalPrimitiveValues.swift', 'AcquisitionState.swift', 'SignalAnalyzerDiagnostic.swift')]
                            module_path = cell / 'SignalAnalyzerDomain.swiftmodule'
                            domain_producers[profile] = {'row': dict(producer_row), 'artifacts': {
                                str(p): actual_bytes(p, producer_row['started_ns'] if p.suffix in ('.o', '.swiftmodule') else None)
                                for p in [*domain_paths, module_path, cell / 'SignalAnalyzerDomain.o']}}
                    if profile.startswith('macos'):
                        positive(label + 'link', expand(plan['scratch_declaration_native_link_argv'], profile, cell, base))
                        _, output, _ = positive(label + 'execute', expand(plan['scratch_declaration_native_execute_argv'], profile, cell, base))
                        assert output.strip() == 'checks=120 failures=0'
                    else:
                        _, abi, _ = positive(label + 'target-abi', expand(plan['target_readelf_argv'], profile, cell, base))
                        arch = 'v6' if profile == 'raspberry-pi-armv6' else 'v7E-M'
                        assert 'Machine:' in abi and 'ARM' in abi
                        assert 'Tag_ABI_VFP_args: VFP registers' in abi
                        assert re.search(r'Tag_CPU_arch: ' + arch + r'\s*$', abi, re.M)
                elif control['id'] in ('positive-serialized-read', 'positive-semantics'):
                    cell = positive_cell
                    name = 'ABIRead' if control['id'] == 'positive-serialized-read' else 'ABISemantics'
                    positive(label + name, module_argv(name, profile, cell, base))
                    if control['id'] == 'positive-semantics' and profile.startswith('macos'):
                        positive(label + 'link', expand(plan['native_semantics_link_argv'], profile, cell, base))
                        _, output, _ = positive(label + 'execute', expand(plan['native_semantics_execute_argv'], profile, cell, base))
                        assert output.strip() == 'analyzer-abi semantics=18 failures=0'
                elif kind == 'abi-negative':
                    cell = profile_root / 'scratch' / control['id']
                    materialize(cell, control['files'][0])
                    for name in ('SignalAnalyzerDomain', 'lower-Analyzer-source', 'AnalyzerSchema', 'AnalyzerPresentation'):
                        argv = expand(plan['lower_argv'], profile, cell, base) if name == 'lower-Analyzer-source' else module_argv(name, profile, cell, base)
                        row, output, errors = launch(label + name, argv)
                        if name == control['first_expected_stage']:
                            expected_path = Path(control['diagnostic_source'].replace('{cell}', str(cell)))
                            diagnostic(control, row, output, errors, expected_path, cell, positive_cell, profile, name)
                            break
                        assert row['exit'] == 0, ('unexpected earlier failure', control['id'], name)
                    else:
                        raise AssertionError(('missing expected negative stage', control['id']))
                else:
                    cell = profile_root / 'scratch' / control['id']
                    cell.mkdir(parents=True, exist_ok=False)
                    (cell / 'inputs').mkdir()
                    name = control['files'][0]
                    path = cell / 'inputs' / Path(name).name
                    path.write_bytes(sources['sources'][name]['text'].encode())
                    argv = expand(plan['scratch_negative_argv'], profile, cell, base, positive_cell,
                                  negative=path, outside=control['package_name'] is None)
                    if (profile, control['id']) == ('macos-static', 'private-storage'):
                        private_captures[profile] = capture_private_storage(control, profile, cell, positive_cell, path, argv)
                    if (profile, control['id'], control['first_expected_stage']) == ('macos-static', 'private-count', 'client-emit-object'):
                        private_count_captures[profile] = capture_private_count(control, profile, cell, positive_cell, path, argv)
                    if (profile, control['id'], control['first_expected_stage']) == ('macos-static', 'private-helper-continuation', 'client-emit-object'):
                        private_helper_continuation_captures[profile] = capture_private_helper_continuation(control, profile, cell, positive_cell, path, argv)
                    if (profile, control['id'], control['first_expected_stage']) == ('macos-static', 'private-helper-leading', 'client-emit-object'):
                        private_helper_leading_captures[profile] = capture_private_helper_leading(control, profile, cell, positive_cell, path, argv)
                    row, output, errors = launch(label + 'client-emit-object', argv)
                    diagnostic(control, row, output, errors, path, cell, positive_cell, profile, name)
                control_receipt(control, profile, cell, base, positive_cell)
        assert len(state['control_receipts']) == len(controls['controls']) * 4 == 80
        values = {'core-macos-static': str(Path(refs['macos-static']['path']).parent)}
        for stage in plan['dependent_stages']:
            argv = [values[token[1:-1]] if token.startswith('{') and token.endswith('}') else token for token in stage['argv']]
            row, text, _ = positive(stage['name'], argv)
            receipt = qualify(discover(text, stage['receipt_regex'], stage['name'] != 'P07'), row['started_ns'], 'macos-static', 'P07' if stage['name'] == 'P07' else None)
            data = receipt['data']
            if stage['name'] == 'P07':
                assert data['core_receipt_sha256'] == refs['macos-static']['sha256']
                refs['runtime'] = receipt
                values['runtime'] = str(Path(receipt['path']).parent)
            elif stage['name'] == 'schema4-activation':
                assert data['runtime_receipt_sha256'] == refs['runtime']['sha256']
                assert {'activation-join', 'activation-copy', 'activation-callback', 'activation-constant-callback', 'activation-backing', 'execute'} <= {c['name'] for c in data['checks']}
                refs['host'] = receipt
                values['host'] = str(Path(receipt['path']).parent)
            else:
                assert data['runtime_receipt_sha256'] == refs['runtime']['sha256']
                assert data['host_receipt_sha256'] == refs['host']['sha256']
                assert data['collection_complete'] and data['passed'] and not data['fresh_focused']
                assert len(data['planned_scoped_labels']) == len(set(data['planned_scoped_labels'])) == 384
        verify()
        state['status'] = 'proposed_prerequisite_campaign_passed_P08_currentcallee_cold_resources_acceptance_open'
        save()
    except BaseException as error:
        state['status'] = 'STOP_first_material_failure_dependents_unrun_no_retry_zero_repairs'
        state['error'] = repr(error)
        save()
        raise


if __name__ == '__main__':
    main()
