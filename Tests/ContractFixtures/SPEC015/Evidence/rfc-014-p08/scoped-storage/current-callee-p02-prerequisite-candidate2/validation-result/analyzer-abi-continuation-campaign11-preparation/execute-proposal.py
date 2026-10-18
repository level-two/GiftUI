#!/usr/bin/env python3
"""Frozen PROPOSED campaign wrapper. No authority is conferred by this file.

Only a separately authorized invocation with a reviewed postformat freeze may run.
Preparation validates this file with ast.parse; preparation never imports/runs it.
"""
from pathlib import Path
import hashlib
import fcntl
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
    assert freeze_path == PACKET / 'postformat-freeze.json'
    assert freeze_path.is_absolute() and freeze_path.is_file()
    assert digest(freeze_path) == '0cb2c32520e4344940c4801c9bfea21206e828dd2d6db07dfb8ae06dd4840333', 'changed exact 541-input freeze'
    plan, selectors, sources, controls = [read(n) for n in (
        'recipe.json', 'selectors.json', 'scratch-sources.json', 'controls.json')]
    assert Path.cwd().resolve() == ROOT, 'exact repository cwd required'
    assert sys.argv == plan['execution_argv'][1:], 'exact frozen campaign11 invocation required'
    assert plan['lock'] == ['ruby', 'scripts/lib/serialize-validation.rb', *plan['execution_argv']], 'lock argv drift'
    baseline = read('baseline-inputs.json')
    frozen = json.loads(freeze_path.read_text())
    assert set(frozen) == set(baseline), 'postformat freeze path set differs'
    assert {k for k in frozen if frozen[k] != baseline[k]} <= set(selectors['files'])
    if not os.environ.get('GIFTUI_VALIDATION_LOCK_OWNER'):
        os.execvp('ruby', plan['lock'])
    lock_owner = int(os.environ['GIFTUI_VALIDATION_LOCK_OWNER'])
    assert lock_owner == os.getppid(), 'campaign must be direct child of lock owner'
    lock_path = ROOT / '.build/validation.lock'
    lock_inode = lock_path.stat().st_ino

    def verify_lock():
        assert os.getppid() == lock_owner and lock_path.stat().st_ino == lock_inode, 'lock owner/inode drift'
        with lock_path.open('rb') as probe:
            try:
                fcntl.flock(probe, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                return
            fcntl.flock(probe, fcntl.LOCK_UN)
            raise AssertionError('validation lock is not held by parent')

    verify_lock()
    assert shutil.disk_usage(ROOT).free >= plan['minimum_free_bytes'], 'storage below frozen launch threshold'
    out = ROOT / plan['output_root']
    assert not out.exists(), 'No output reuse or retry'
    assert all(not (ROOT / p).exists() for p in plan['output_roots'].values())
    assert all(not (ROOT / plan['output_roots'][profile]).parent.exists()
               for profile in ('raspberry-pi-armv6', 'nrf52840-embedded')), 'cross-target campaign root reuse'
    state = {'status': 'running', 'source_candidates': 1, 'automatic_repairs': 0,
             'retries': 0, 'postformat_freeze': str(freeze_path),
             'postformat_freeze_sha256': digest(freeze_path), 'stages': [],
             'control_receipts': [], 'producer_receipts': [],
             'omissions': controls['explicit_omissions'], 'strict_cold_eligible': False}
    refs = {}
    fresh_captures = {}
    producer_snapshots = {}
    import fresh_policy
    batch_policy = (PACKET / 'batch1-policy.json').read_bytes()
    batch_templates = (PACKET / 'fresh-templates.json').read_bytes()
    domain_producers = {}
    private_captures = {}
    private_count_captures = {}
    private_helper_continuation_captures = {}
    private_helper_leading_captures = {}
    armv6_a4_captures = {}
    current_commit = subprocess.check_output(
        ['git', 'rev-parse', '--verify', 'HEAD'], cwd=ROOT, text=True).strip()
    assert re.fullmatch(r'[0-9a-f]{40}', current_commit)
    state['authenticated_current_commit'] = current_commit
    private_policy = read('private-storage-policy.json')
    private_count_policy = read('private-count-policy.json')
    private_helper_continuation_policy = read('private-helper-continuation-policy.json')
    private_helper_leading_policy = read('private-helper-leading-policy.json')

    def verify():
        verify_lock()
        assert shutil.disk_usage(ROOT).free >= plan['minimum_free_bytes'], 'storage below frozen stage threshold'
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
    import diagnostic_parser as diagnostic_policy
    classify_negative_diagnostics = diagnostic_policy.classify_negative_diagnostics
    bind_armv6_a4_campaign11 = diagnostic_policy.bind_armv6_a4_campaign11
    assert diagnostic_policy.ARMV6_A4_POLICY == read('armv6-A4-archived-policy.json')
    assert diagnostic_policy.ARMV6_A4_CORE_FIELDS == read('armv6-A4-core-fields.json')
    assert diagnostic_policy.ARMV6_A4_BINDING_RELOCATIONS == read('armv6-A4-binding-relocations.json')
    out.mkdir()
    (out / 'logs').mkdir()
    (out / 'receipts').mkdir()
    (out / 'macro/macro').mkdir(parents=True)
    (out / 'postformat-freeze.json').write_bytes(freeze_path.read_bytes())

    def save():
        (out / 'result.json').write_text(json.dumps(state, indent=2) + '\n')

    def stream_digest(path):
        value = hashlib.sha256()
        with Path(path).open('rb') as source:
            for block in iter(lambda: source.read(1024 * 1024), b''):
                value.update(block)
        return value.hexdigest()

    def authenticate_armv6_sdk():
        inventory = read(plan['armv6_sdk_inventory'])
        root = Path(inventory['root'])
        assert root == Path(read('armv6-A4-archived-policy.json')['precompile_identity']['sdk']['path']).parent, 'SDK inventory must cover fixed SDK root'
        assert root.resolve() == root and root.is_dir(), 'SDK install root drift'
        actual_names = {str(path.relative_to(root)) for path in root.rglob('*')}
        assert actual_names == {item['path'] for item in inventory['entries']}, 'SDK entry inventory drift'
        for item in inventory['entries']:
            path = root / item['path']
            if item['kind'] == 'symlink':
                assert path.is_symlink() and os.readlink(path) == item['target'], ('SDK symlink drift', path)
            elif item['kind'] == 'directory':
                assert not path.is_symlink() and path.is_dir(), ('SDK directory drift', path)
            else:
                assert not path.is_symlink() and path.is_file(), ('SDK file kind drift', path)
                assert path.stat().st_size == item['bytes'] and stream_digest(path) == item['sha256'], ('SDK byte drift', path)
        archived = inventory['archive']
        assert Path(archived['path']).stat().st_size == archived['bytes']
        assert stream_digest(archived['path']) == archived['sha256']
        provenance = inventory['install_provenance']
        assert stream_digest(provenance['path']) == provenance['sha256']
        return {'inventory_sha256': digest(PACKET / plan['armv6_sdk_inventory']),
                'archive_sha256': archived['sha256'], 'install_sha256': provenance['sha256'],
                'entry_count': len(inventory['entries'])}

    def remember_producer(row):
        if type(row['exit']) is not int or row['exit'] != 0:
            return
        argv = row['argv']
        paths = []
        for flag in ('-o', '-emit-module-path'):
            if flag in argv:
                paths.append(Path(argv[argv.index(flag) + 1]))
        if '--lower-source' in argv:
            paths.extend(map(Path, argv[-2:]))
        artifacts = {}
        for path in paths:
            data = actual_bytes(path, row['started_ns'])
            artifacts[str(path)] = {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}
        producer_snapshots[row['name']] = {'stage': dict(row), 'artifacts': artifacts}

    def fresh_context(label, argv, env):
        key = next((key for key, case in json.loads(batch_policy)['cases'].items()
                    if label == case['profile'] + '-' + case['control'] + '-' + case['stage']), None)
        if key is None:
            return None
        case = json.loads(batch_policy)['cases'][key]
        profile = case['profile']
        core = refs[profile]
        row = next(stage for stage in state['stages'] if stage['name'] == 'P02-' + profile)
        command = next(stage['argv'] for stage in plan['profile_commands'] if stage['profile'] == profile)
        authenticate_stage(row, row['name'], command)
        receipt_path = Path(core['path'])
        receipt_bytes = actual_bytes(receipt_path, row['started_ns'])
        assert hashlib.sha256(receipt_bytes).hexdigest() == core['sha256']
        receipt = json.loads(receipt_bytes)
        assert exact_identity(receipt, core['data'])
        assert all(exact_identity(receipt.get(k), v) for k, v in read('fresh-core-fields.json')[profile].items()), 'fresh P02 frozen fields'
        assert receipt['source_commit'] == current_commit
        identity = hashlib.sha256(json.dumps({'inputs': receipt['inputs'], 'commit': current_commit,
                                             'compiler': receipt['compiler_sha256']}, sort_keys=True).encode()).hexdigest()
        assert receipt['input_sha256'] == identity
        base = receipt_path.parent
        assert base.name == profile and base.parent.name.startswith(identity[:16] + '-') and len(base.parent.name) > 17
        assert base.parent.parent == ROOT / read('fresh-core-parents.json')[profile]
        assert str(base) not in preexisting_fresh_core_roots[profile], 'P02 root reused'
        assert receipt_path == Path(core['discovered_path']) and receipt_path.resolve() == receipt_path
        archived = next(item for item in state['producer_receipts'] if item['path'] == str(receipt_path))
        assert actual_bytes(archived['copy']) == receipt_bytes
        for name, value in receipt['inputs'].items():
            assert frozen.get(name) == value and digest(ROOT / name) == value
        for key_name, hash_name in (('compiler', 'compiler_sha256'), ('macro_tool', 'macro_tool_sha256'),
                                   ('swift_syntax_library', 'swift_syntax_sha256')):
            assert digest(ROOT / receipt[key_name]) == receipt[hash_name]
        core_artifacts = {}
        for name, value in receipt['artifacts'].items():
            path = base / name
            assert path.resolve() == path and path.is_relative_to(base)
            data = actual_bytes(path, row['started_ns'])
            actual = {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}
            assert exact_identity(actual, value)
            core_artifacts[str(path)] = actual
        control = next(c for c in controls['controls'] if c['id'] == case['control'])
        selected = {}
        # Authenticate the complete preceding successful stage history. Stage logs,
        # exact recipe argv/environment and output bytes must all retain identity.
        for name, captured in producer_snapshots.items():
            if not name.startswith(profile + '-'):
                continue
            producer = captured['stage']
            authenticate_stage(producer, name, producer['argv'])
            for path, value in captured['artifacts'].items():
                data = actual_bytes(path, producer['started_ns'])
                assert {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()} == value, ('preceding producer drift', path)
            selected[name] = captured
        preceding_controls = []
        for candidate in controls['controls']:
            if candidate['id'] == control['id']:
                break
            preceding_controls.append(candidate['id'])
        completed_controls = [item for item in state['control_receipts'] if item['profile'] == profile]
        assert [item['control'] for item in completed_controls] == preceding_controls, 'control order/omission'
        for item in completed_controls:
            assert digest(item['path']) == item['sha256'], 'preceding control receipt drift'
        if control['kind'] == 'abi-negative':
            order = ['SignalAnalyzerDomain', 'lower-Analyzer-source', 'AnalyzerSchema', 'AnalyzerPresentation']
            prerequisite_names = order[:order.index(case['stage'])]
            prefix = profile + '-' + control['id'] + '-'
        else:
            prerequisite_names = ['SignalAnalyzerDomain', 'lower-Analyzer-source', 'AnalyzerSchema',
                                  'AnalyzerPresentation', 'DeclarationHost']
            prefix = profile + '-positive-actual-lowering-'
        assert all(prefix + name in selected for name in prerequisite_names), 'missing preceding stage'
        module_paths = {path for item in selected.values() for path in item['artifacts']
                        if path.endswith('.swiftmodule')}
        # Every imported module named by the archived prelaunch inventory must be
        # joined to the current receipt or the actual preceding producer output.
        archive = read('batch1-archived-captures.json')[key]
        for imported in archive.get('inputs', []):
            if not imported['path'].endswith('.swiftmodule'):
                continue
            old_core = json.loads(batch_templates)[key]['core']
            old_path = imported['path']
            actual_path = str(base) + old_path[len(old_core):] if old_path.startswith(old_core + '/') else fresh_policy.relocate(old_path)
            assert actual_path in core_artifacts or actual_path in module_paths, ('missing imported producer', actual_path)
        sources_now = {fresh_policy.relocate(path): actual_bytes(Path(fresh_policy.relocate(path)))
                       for path in case['sources']}
        # Generated text must be attached to the actual completed lowerer output.
        for path in sources_now:
            if Path(path).name in ('AnalyzerSchema.swift', 'AnalyzerPresentation.swift'):
                assert any(path in item['artifacts'] for item in selected.values()), 'missing actual lowerer output'
        context = {'key': key, 'profile': profile, 'stage': case['stage'], 'control': control,
                   'policy_sha256': fresh_policy.POLICY_SHA, 'argv': list(argv), 'cwd': str(ROOT),
                   'effective_environment_sha256': hashlib.sha256(fresh_policy.canonical(env)).hexdigest(),
                   'current_commit': current_commit, 'freeze_sha256': digest(freeze_path),
                   'compiler_identities': read('provenance.json')['compiler_identities'],
                   'sdk': state['armv6_sdk_preflight'], 'p02': {'root': str(base), 'receipt_sha256': core['sha256'],
                   'stage': dict(row), 'artifacts': core_artifacts}, 'preceding_producers': selected,
                   'root_map': fresh_policy.MAP}
        return key, context, sources_now, str(base)

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
        if label == 'raspberry-pi-armv6-negative-A4-SignalAnalyzerDomain':
            capture = armv6_a4_captures['raspberry-pi-armv6']
            recheck_armv6_a4_capture(capture)
            assert extra_environment is None
            assert hashlib.sha256(json.dumps(env, sort_keys=True).encode()).hexdigest() == capture['effective_environment_sha256'], 'ARM effective environment changed since capture'
            assert argv == capture['arguments']['trusted_precompile']['planned_stage']['argv']
            assert plan['environment'] == capture['arguments']['trusted_precompile']['planned_stage']['environment_overrides']
            arm_audit = state['armv6_a4_precompile_authentication']
            assert digest(arm_audit['path']) == arm_audit['sha256']
        fresh = fresh_context(label, argv, env)
        if fresh is not None:
            key, context, source_bytes, core_root = fresh
            capture = fresh_policy.prepare(batch_policy, context, source_bytes, argv, core_root, batch_templates)
            audit_path = out / 'receipts' / (label + '-fresh-prelaunch.json')
            audit = {'context': context, 'sources': json.loads(capture.sources), 'completed_ns': time.time_ns()}
            with audit_path.open('x') as destination:
                json.dump(audit, destination, indent=2, sort_keys=True)
                destination.write('\n')
            audit_hash = digest(audit_path)
            assert fresh_context(label, argv, env) == fresh, 'prelaunch recheck drift'
            fresh_captures[label] = (capture, fresh, str(audit_path), audit_hash, audit['completed_ns'])
        started, timer = time.time_ns(), time.monotonic()
        if label == 'raspberry-pi-armv6-negative-A4-SignalAnalyzerDomain':
            assert arm_audit['completed_ns'] <= started and Path(arm_audit['path']).stat().st_mtime_ns <= started, 'ARM audit must precede compiler start'
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
        if label == 'raspberry-pi-armv6-negative-A4-SignalAnalyzerDomain':
            row['effective_environment_sha256'] = hashlib.sha256(json.dumps(env, sort_keys=True).encode()).hexdigest()
        state['stages'].append(row)
        remember_producer(row)
        if fresh is not None:
            capture, prior, audit_path, audit_hash, completed = fresh_captures[label]
            assert completed <= started and digest(audit_path) == audit_hash
            assert fresh_context(label, argv, env) == prior, 'postlaunch provenance drift'
            row['fresh_policy_binding'] = fresh_policy.finish(capture, prior[1], prior[2],
                Path(str(prefix) + '.stdout').read_bytes(), Path(str(prefix) + '.stderr').read_bytes(), row['exit'])
            row['prelaunch_audit'] = {'path': audit_path, 'sha256': audit_hash, 'completed_ns': completed}
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
                assert check['pass'] is True and type(check['exit']) is int and check['exit'] in (0, 1), check
            elif 'passed' in check:
                assert check['passed'] is True and type(check.get('exit', 0)) is int, check
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

    def exact_identity(actual, expected):
        return type(actual) is type(expected) and json.dumps(actual, sort_keys=True) == json.dumps(expected, sort_keys=True)

    def authenticate_armv6_core():
        verify()
        profile = 'raspberry-pi-armv6'
        core = refs[profile]
        row = next(stage for stage in state['stages'] if stage['name'] == 'P02-' + profile)
        command = next(stage['argv'] for stage in plan['profile_commands'] if stage['profile'] == profile)
        authenticate_stage(row, 'P02-' + profile, command)
        path = Path(core['path'])
        assert path == Path(core['discovered_path']) and path.resolve() == path
        receipt_bytes = actual_bytes(path, row['started_ns'])
        assert hashlib.sha256(receipt_bytes).hexdigest() == core['sha256']
        receipt = json.loads(receipt_bytes)
        assert exact_identity(receipt, core['data'])
        archived = next(item for item in state['producer_receipts'] if item['path'] == str(path))
        assert archived['sha256'] == core['sha256'] and actual_bytes(archived['copy']) == receipt_bytes
        assert all(exact_identity(receipt.get(key), value) for key, value in read('armv6-A4-core-fields.json').items()), 'ARM P02 complete frozen fields mismatch'
        assert receipt['source_commit'] == current_commit
        input_hash = hashlib.sha256(json.dumps({'inputs': receipt['inputs'], 'commit': current_commit,
                                               'compiler': receipt['compiler_sha256']}, sort_keys=True).encode()).hexdigest()
        base = path.parent
        assert receipt['input_sha256'] == input_hash
        assert base.parent.parent == Path(read('armv6-A4-binding-policy.json')['core_parent'])
        assert base.name == profile and base.parent.name.startswith(input_hash[:16] + '-') and len(base.parent.name) > 17
        assert str(base) not in preexisting_armv6_core_roots, 'ARM P02 core must be fresh'
        for name, value in receipt['inputs'].items():
            assert frozen.get(name) == value and digest(ROOT / name) == value, ('ARM core input drift', name)
        for key, hash_key in (('compiler', 'compiler_sha256'), ('macro_tool', 'macro_tool_sha256'),
                              ('swift_syntax_library', 'swift_syntax_sha256')):
            assert digest(ROOT / receipt[key]) == receipt[hash_key]
        for name, identity in receipt['artifacts'].items():
            artifact = base / name
            assert artifact.resolve().is_relative_to(base) and artifact.resolve() == artifact
            payload = actual_bytes(artifact, row['started_ns'])
            assert exact_identity(identity, {'bytes': len(payload), 'sha256': hashlib.sha256(payload).hexdigest()})
        stdout = (out / 'logs/P02-raspberry-pi-armv6.stdout').read_text(errors='replace')
        assert discover(stdout, r'^P02 raspberry-pi-armv6:[\s\S]*?;\s*(\S+/result\.json)\s*$') == path
        module = base / 'GiftUI.swiftmodule'
        return {'root': str(base), 'receipt_path': str(path), 'receipt_sha256': core['sha256'],
                'receipt_bytes': receipt_bytes, 'artifact_path': str(module),
                'artifact_bytes': actual_bytes(module, row['started_ns'])}, dict(row)

    def capture_armv6_a4(control, profile, cell, argv):
        verify()
        assert (profile, control['id'], control['first_expected_stage']) == ('raspberry-pi-armv6', 'negative-A4', 'SignalAnalyzerDomain')
        declared_root = ROOT / plan['output_roots'][profile]
        campaign_root = declared_root.parent
        assert str(campaign_root) == read('armv6-A4-binding-policy.json')['declared_campaign_root']
        assert cell == declared_root / 'scratch/negative-A4' and cell.resolve() == cell
        selected = read('raspberry-pi-armv6-A4-opt-in-control.json')
        comparable = dict(selected)
        del comparable['armv6_a4_display_only_note']
        comparable['diagnostic_source'] = control['diagnostic_source']
        comparable['dependency_note_sources'] = control['dependency_note_sources']
        assert exact_identity(comparable, control), 'ARM A4 complete original control mismatch'
        source = cell / 'inputs/SignalPrimitiveValues.swift'
        assert selected['diagnostic_source'] == str(source) and selected['dependency_note_sources'] == [str(source)]
        trusted_core, core_stage = authenticate_armv6_core()
        assert list(map(str, argv)) == module_argv('SignalAnalyzerDomain', profile, cell, Path(trusted_core['root'])), 'ARM planned argv differs from active recipe'
        snapshot = {}
        source_inputs = {}
        for name in ('SignalPrimitiveValues.swift', 'AcquisitionState.swift', 'SignalAnalyzerDiagnostic.swift'):
            path = cell / 'inputs' / name
            data = actual_bytes(path)
            selector = 'negative-A4/' if name == 'SignalPrimitiveValues.swift' else 'positive/'
            assert data == sources['sources'][selector + name]['text'].encode()
            snapshot[str(path)] = data
            source_inputs[str(path)] = {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}
        sdk_authentication = authenticate_armv6_sdk()
        compiler = Path(argv[0])
        assert str(compiler) == plan['compilers'][profile]
        pin = ROOT / 'scripts/raspberry-pi/toolchain.env'
        precompile = {'campaign_root': str(campaign_root),
                      'compiler': {'path': str(compiler), 'sha256': digest(compiler)},
                      'target': argv[argv.index('-target') + 1],
                      'sdk': {'path': argv[argv.index('-sdk') + 1],
                              'archive_sha256': sdk_authentication['archive_sha256'],
                              'toolchain_pin_path': str(pin), 'toolchain_pin_sha256': digest(pin)},
                      'planned_stage': {'name': 'raspberry-pi-armv6-negative-A4-SignalAnalyzerDomain',
                                        'argv': list(map(str, argv)), 'environment_overrides': dict(plan['environment'])},
                      'source_inputs': source_inputs}
        binding = bind_armv6_a4_campaign11(str(campaign_root), current_commit, trusted_core, precompile, selected)
        arguments = {'armv6_a4_binding': binding, 'declared_campaign_root': str(campaign_root),
                     'trusted_precompile': precompile, 'trusted_core': trusted_core,
                     'trusted_current_commit': current_commit,
                     'context': {'profile': profile, 'module': 'SignalAnalyzerDomain', 'stage': 'SignalAnalyzerDomain'},
                     'trusted_input': {'path': str(source), 'bytes': snapshot[str(source)]}}
        effective_environment = dict(os.environ)
        effective_environment.update(plan['environment'])
        capture = {'arguments': arguments, 'control': selected, 'source_snapshot': snapshot,
                   'sdk_authentication': sdk_authentication, 'core_stage': core_stage,
                   'effective_environment_sha256': hashlib.sha256(json.dumps(effective_environment, sort_keys=True).encode()).hexdigest()}
        def audit(value):
            if isinstance(value, bytes): return {'bytes': len(value), 'sha256': hashlib.sha256(value).hexdigest()}
            if isinstance(value, dict): return {key: audit(item) for key, item in value.items()}
            if isinstance(value, list): return [audit(item) for item in value]
            return value
        # Immutable serialized binding and actual byte snapshots are sealed here,
        # before launch can acquire any diagnostic bytes.
        capture['audit_payload'] = audit(capture)
        path = out / 'receipts/armv6-A4-precompile-authentication.json'
        assert not path.exists()
        with path.open('x') as destination:
            json.dump(capture['audit_payload'], destination, indent=2, sort_keys=True)
            destination.write('\n')
        state['armv6_a4_precompile_authentication'] = {'path': str(path), 'sha256': digest(path),
                                                     'binding_sha256': hashlib.sha256(binding.encode()).hexdigest(),
                                                     'completed_ns': time.time_ns()}
        save()
        return capture

    def recheck_armv6_a4_capture(capture):
        verify()
        arguments = capture['arguments']
        effective_environment = dict(os.environ)
        effective_environment.update(plan['environment'])
        assert hashlib.sha256(json.dumps(effective_environment, sort_keys=True).encode()).hexdigest() == capture['effective_environment_sha256']
        core, core_stage = authenticate_armv6_core()
        assert core == arguments['trusted_core'] and exact_identity(core_stage, capture['core_stage'])
        assert authenticate_armv6_sdk() == capture['sdk_authentication']
        for path, data in capture['source_snapshot'].items():
            assert actual_bytes(path) == data, ('ARM source changed since capture', path)
        compiler = arguments['trusted_precompile']['compiler']
        assert digest(compiler['path']) == compiler['sha256']
        pin = arguments['trusted_precompile']['sdk']
        assert digest(pin['toolchain_pin_path']) == pin['toolchain_pin_sha256']
        planned = arguments['trusted_precompile']['planned_stage']
        cell = Path(arguments['trusted_input']['path']).parent.parent
        assert planned['argv'] == module_argv('SignalAnalyzerDomain', 'raspberry-pi-armv6', cell, Path(core['root']))
        assert planned['environment_overrides'] == plan['environment']
        assert bind_armv6_a4_campaign11(arguments['declared_campaign_root'], current_commit, core,
                                      arguments['trusted_precompile'], capture['control']) == arguments['armv6_a4_binding']
        audit_ref = state['armv6_a4_precompile_authentication']
        assert digest(audit_ref['path']) == audit_ref['sha256']
        assert json.loads(Path(audit_ref['path']).read_text()) == capture['audit_payload']
        assert hashlib.sha256(arguments['armv6_a4_binding'].encode()).hexdigest() == audit_ref['binding_sha256']

    def diagnostic(control, row, text, errors, expected_path, cell, positive_cell, profile, module):
        if row['name'] in fresh_captures:
            assert row['fresh_policy_binding']['key'] == fresh_captures[row['name']][0].key
            row['expected_nonzero'] = True
            row['classified_category'] = control['category']
            row['diagnostic_source'] = str(expected_path)
            save()
            return
        dependencies = [Path(name.replace('{cell}', str(cell)).replace('{positive-cell}', str(positive_cell)))
                        for name in control['dependency_note_sources']]
        selected_control = control
        policy_arguments = {}
        classifier_path, classifier_dependencies = expected_path, dependencies
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
        elif (profile, control['id'], module) == ('raspberry-pi-armv6', 'negative-A4', 'SignalAnalyzerDomain'):
            capture = armv6_a4_captures[profile]
            recheck_armv6_a4_capture(capture)
            policy_arguments = capture['arguments']
            selected_control = capture['control']
            assert str(expected_path) == policy_arguments['trusted_input']['path']
            assert list(map(str, dependencies)) == selected_control['dependency_note_sources']
            planned = policy_arguments['trusted_precompile']['planned_stage']
            authenticate_stage(row, planned['name'], planned['argv'], 1)
            assert exact_identity(row['environment_overrides'], planned['environment_overrides'])
            assert row['effective_environment_sha256'] == capture['effective_environment_sha256']
            audit_ref = state['armv6_a4_precompile_authentication']
            assert audit_ref['completed_ns'] <= row['started_ns']
            assert Path(audit_ref['path']).stat().st_mtime_ns <= row['started_ns']
            classifier_path, classifier_dependencies = str(expected_path), list(map(str, dependencies))
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
                                                classifier_path, classifier_dependencies, **policy_arguments)
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

    preexisting_armv6_core_roots = {str(path) for path in Path(read('armv6-A4-binding-policy.json')['core_parent']).glob('*/raspberry-pi-armv6')}

    preexisting_fresh_core_roots = {}
    for profile, parent_name in read('fresh-core-parents.json').items():
        parent = ROOT / parent_name
        preexisting_fresh_core_roots[profile] = {str(child / profile) for child in parent.iterdir()} if parent.exists() else set()

    try:
        state['armv6_sdk_preflight'] = authenticate_armv6_sdk()
        save()
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
                        if (profile, control['id'], name) == ('raspberry-pi-armv6', 'negative-A4', 'SignalAnalyzerDomain'):
                            armv6_a4_captures[profile] = capture_armv6_a4(control, profile, cell, argv)
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
