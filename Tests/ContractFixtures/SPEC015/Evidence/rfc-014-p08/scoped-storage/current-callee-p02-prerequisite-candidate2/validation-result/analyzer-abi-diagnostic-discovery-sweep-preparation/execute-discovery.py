#!/usr/bin/env python3
"""Reviewed, one-shot diagnostic discovery. Preparation must never execute/import this.

No diagnostic parser, campaign qualification, repair, retry or successor is present.
All compiler/lowerer/oracle commands and dependency edges are literal plan data.
"""
from pathlib import Path
import fcntl
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time

ROOT = Path('/Users/eugene/work/GiftUI')
PACKET = Path(__file__).resolve().parent


def sha(path):
    result = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            result.update(block)
    return result.hexdigest()


def read(name):
    return json.loads((PACKET / name).read_text())


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':')).encode()


def identity(path):
    path = Path(path)
    return {'path': str(path), 'resolved': str(path.resolve(strict=True)),
            'bytes': path.stat().st_size, 'sha256': sha(path)}


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def main():
    sys.dont_write_bytecode = True
    require(__debug__ and not sys.flags.optimize, 'assertions must be active')
    plan = read('plan.json')
    require(str(Path(sys.executable).resolve(strict=True)) ==
            str(Path(plan['execution_argv'][0]).resolve(strict=True)), 'Python runtime drift')
    require(Path.cwd() == ROOT, 'repository cwd required')
    require(sys.argv == plan['execution_argv'][1:], 'exact reviewed invocation required')
    require(os.environ.get('HOME') == plan['environment']['HOME'], 'actual HOME drift')
    if not os.environ.get('GIFTUI_VALIDATION_LOCK_OWNER'):
        os.execv(plan['lock_argv'][0], plan['lock_argv'])
    owner = int(os.environ['GIFTUI_VALIDATION_LOCK_OWNER'])
    lock = ROOT / '.build/validation.lock'
    inode = lock.stat().st_ino
    environment = dict(plan['environment'])
    environment['GIFTUI_VALIDATION_LOCK_OWNER'] = str(owner)
    environment_hash = hashlib.sha256(canonical(environment)).hexdigest()
    head = subprocess.check_output(['/usr/bin/git', 'rev-parse', '--verify', 'HEAD'], cwd=ROOT,
                                   env=environment).decode().strip()
    out = Path(plan['output_root'])
    state = {'status': 'running', 'current_commit': head, 'source_candidates': 1,
             'retries': 0, 'repairs': 0, 'qualified_controls': 0,
             'target_count': 50, 'cells': [], 'stages': [], 'acceptance': False,
             'environment': environment, 'effective_environment_sha256': environment_hash}
    completed = {}
    produced = {}
    sealed_evidence = {}

    def verify_lock():
        require(os.getppid() == owner and lock.stat().st_ino == inode, 'lock owner/inode drift')
        with lock.open('rb') as probe:
            try:
                fcntl.flock(probe, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                return
            fcntl.flock(probe, fcntl.LOCK_UN)
            raise RuntimeError('parent does not hold permanent validation lock')

    def verify_files(records):
        for record in records:
            require(identity(record['path']) == record, 'input/provenance drift: ' + record['path'])

    def verify_inventory(inventory):
        root = Path(inventory['root'])
        require(str(root.resolve(strict=True)) == inventory['resolved'], 'inventory root drift')
        require({str(p.relative_to(root)) for p in root.rglob('*')} ==
                {r['path'] for r in inventory['entries']}, 'inventory path set drift: ' + str(root))
        for record in inventory['entries']:
            path = root / record['path']
            if record['kind'] == 'symlink':
                require(path.is_symlink() and os.readlink(path) == record['target'], 'symlink drift: ' + str(path))
                if 'resolved_directory' in record:
                    require(path.is_dir() and str(path.resolve(strict=True)) == record['resolved_directory'],
                            'symlink directory target drift: ' + str(path))
                # Symlink file targets are authenticated too, including targets outside root.
                if 'resolved_file' in record:
                    require(identity(path) == record['resolved_file'], 'symlink target drift: ' + str(path))
            elif record['kind'] == 'directory':
                require(path.is_dir() and not path.is_symlink(), 'directory drift: ' + str(path))
            else:
                require(path.is_file() and not path.is_symlink() and path.stat().st_size == record['bytes']
                        and sha(path) == record['sha256'], 'inventory byte drift: ' + str(path))

    def verify():
        verify_lock()
        require(shutil.disk_usage(ROOT).free >= plan['minimum_free_bytes'], 'storage threshold')
        require(subprocess.check_output(['/usr/bin/git', 'rev-parse', '--verify', 'HEAD'], cwd=ROOT,
                                        env=environment).decode().strip() == head,
                'HEAD drift')
        packet_hashes = read('packet-hashes.json')
        require({str(p.relative_to(PACKET)) for p in PACKET.rglob('*') if p.is_file()} ==
                set(packet_hashes) | {'packet-hashes.json'}, 'packet path set drift')
        require(not any(p.is_symlink() for p in PACKET.rglob('*')), 'packet symlink')
        for name, record in packet_hashes.items():
            require(sha(PACKET / name) == record['sha256'] and (PACKET / name).stat().st_size == record['bytes'],
                    'packet drift: ' + name)
        verify_files(read('external-identities.json'))
        freeze = Path(plan['freeze']['path'])
        require(sha(freeze) == plan['freeze']['sha256'], 'freeze drift')
        for name, value in json.loads(freeze.read_text()).items():
            require(sha(ROOT / name) == value, '541-input drift: ' + name)
        for record in produced.values():
            require(identity(record['path']) == record, 'producer byte drift: ' + record['path'])
        for record in sealed_evidence.values():
            require(identity(record['path']) == record, 'raw evidence drift: ' + record['path'])

    def verify_platform():
        for name in plan['platform_inventories']:
            verify_inventory(read(name))
        for config in read('home-config-identities.json'):
            path = Path(config['path'])
            if config['kind'] == 'absent':
                require(not path.exists() and not path.is_symlink(), 'HOME config appeared: ' + str(path))
            elif config['kind'] == 'directory':
                verify_inventory(config['inventory'])
            else:
                require(identity(path) == config['identity'], 'HOME config drift: ' + str(path))

    def save():
        temporary = out / 'result.json.next'
        temporary.write_text(json.dumps(state, indent=2) + '\n')
        os.replace(temporary, out / 'result.json')

    def archive_manifest():
        # Fixed record schema; caches and compiler objects stay in place with captured hashes.
        records = {}
        for path in out.rglob('*'):
            relative = path.relative_to(out)
            if path.is_file() and path.name != 'archive-manifest.json' and 'cache' not in relative.parts:
                records[str(relative)] = {'bytes': path.stat().st_size, 'sha256': sha(path)}
        (out / 'archive-manifest.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')

    verify()
    verify_platform()
    require(all(not Path(p).exists() for p in plan['fresh_roots']), 'root reuse forbidden')
    # A run consumes every reserved root before its first compiler; even a blocked run cannot be resumed.
    for path in plan['fresh_roots']:
        Path(path).mkdir(parents=True, exist_ok=False)
    for directory in ('logs', 'audits', 'sources', 'tmp'):
        (out / directory).mkdir()
    (out / 'packet-hashes.json').write_bytes((PACKET / 'packet-hashes.json').read_bytes())
    (out / 'postformat-freeze.json').write_bytes(Path(plan['freeze']['path']).read_bytes())
    for path in (out / 'packet-hashes.json', out / 'postformat-freeze.json'):
        sealed_evidence[str(path)] = identity(path)
    save()
    try:
        for cell in plan['cells']:
            blocked = [key for key in cell['dependencies'] if completed.get(key) != 'positive_pass']
            cell_record = {'id': cell['id'], 'profile': cell['profile'], 'control': cell['control'],
                           'role': cell['role'], 'registered_control': cell.get('registered_control'),
                           'qualified': False, 'dependencies': cell['dependencies'], 'status': 'running'}
            state['cells'].append(cell_record)
            if blocked:
                cell_record.update(status='blocked_prerequisite', blocked_by=blocked)
                completed[cell['id']] = cell_record['status']
                save()
                continue
            Path(cell['root']).mkdir(parents=True, exist_ok=False)
            (Path(cell['root']) / 'inputs').mkdir()
            for material in cell['materialize']:
                path = Path(material['path'])
                path.write_bytes(material['text'].encode())
                require(sha(path) == material['sha256'], 'materialized source drift')
            # Copy every immutable source to raw evidence before launch, including maintained inputs.
            for stage in cell['stages']:
                verify()
                # SDK/compiler inventories are rechecked around every launch, not inferred from diagnostics.
                verify_platform()
                inputs = []
                for path in stage['inputs']:
                    record = identity(path)
                    if path in produced:
                        require(record == produced[path], 'prerequisite changed')
                    elif path in stage['input_sha256']:
                        require(record['sha256'] == stage['input_sha256'][path], 'source hash mismatch')
                    else:
                        raise RuntimeError('unregistered stage input: ' + path)
                    inputs.append(record)
                    if path.endswith('.swift') or path.endswith('.json'):
                        copy = out / 'sources' / (hashlib.sha256(path.encode()).hexdigest() + '-' + Path(path).name)
                        if not copy.exists():
                            copy.write_bytes(Path(path).read_bytes())
                            sealed_evidence[str(copy)] = identity(copy)
                require(all(not Path(path).exists() for path in stage['outputs']), 'stage output reuse')
                audit = {'stage': stage, 'inputs': inputs, 'environment': environment,
                         'effective_environment_sha256': environment_hash, 'current_commit': head,
                         'compiler_and_tool_identities': read('external-identities.json'),
                         'dependencies': {key: completed[key] for key in cell['dependencies']},
                         'prior_artifacts': list(produced.values()), 'completed_ns': time.time_ns()}
                audit_path = out / 'audits' / (stage['id'] + '.json')
                audit_path.write_text(json.dumps(audit, indent=2) + '\n')
                audit_hash = sha(audit_path)
                verify_files(inputs)
                require(sha(audit_path) == audit_hash, 'prelaunch audit drift')
                stdout = out / 'logs' / (stage['id'] + '.stdout')
                stderr = out / 'logs' / (stage['id'] + '.stderr')
                started = time.time_ns()
                require(audit['completed_ns'] <= started and audit_path.stat().st_mtime_ns <= started,
                        'authentication must precede launch')
                launch_error = None
                exit_status = None
                with stdout.open('xb') as output, stderr.open('xb') as errors:
                    try:
                        process = subprocess.run(stage['argv'], cwd=ROOT, env=environment,
                                                 stdout=output, stderr=errors)
                        exit_status = process.returncode
                    except OSError as error:
                        launch_error = repr(error)
                row = {'id': stage['id'], 'argv': stage['argv'], 'cwd': str(ROOT),
                       'environment': environment, 'effective_environment_sha256': environment_hash,
                       'started_ns': started, 'finished_ns': time.time_ns(), 'exit': exit_status,
                       'launch_error': launch_error,
                       'stdout': identity(stdout), 'stderr': identity(stderr),
                       'prelaunch_audit': identity(audit_path), 'inputs': inputs,
                       'expected_first_rejection': stage['negative_observation'], 'qualified': False}
                state['stages'].append(row)
                for path in (stdout, stderr, audit_path):
                    sealed_evidence[str(path)] = identity(path)
                save()
                require(launch_error is None, 'process was not launched: ' + str(launch_error))
                require(sha(audit_path) == audit_hash, 'audit changed during launch')
                verify_files(inputs)
                verify()
                verify_platform()
                row['artifacts'] = [identity(path) for path in stage['outputs'] if Path(path).is_file()]
                if stage['negative_observation']:
                    cell_record['status'] = ('observed_expected_nonzero_unqualified' if exit_status == 1
                                             else 'unexpected_success_failed_negative' if exit_status == 0
                                             else 'observed_abnormal_exit_unqualified')
                    cell_record['rejection_stage'] = stage['name']
                    # No stream decoding or diagnostic acceptance occurs here.
                    break
                passed = exit_status == 0 and len(row['artifacts']) == len(stage['outputs'])
                if 'stdout_exact_stripped' in stage:
                    passed = passed and stdout.read_bytes().strip() == stage['stdout_exact_stripped'].encode()
                if 'abi_arch' in stage:
                    raw = stdout.read_bytes()
                    passed = passed and b'Machine:' in raw and b'ARM' in raw and b'Tag_ABI_VFP_args: VFP registers' in raw
                    passed = passed and any(line.strip() == ('Tag_CPU_arch: ' + stage['abi_arch']).encode()
                                             for line in raw.splitlines())
                for record in row['artifacts']:
                    expected = stage.get('output_sha256', {}).get(record['path'])
                    if expected:
                        passed = passed and record['sha256'] == expected
                if not passed:
                    cell_record.update(status='failed_positive_or_prerequisite', failed_stage=stage['id'])
                    break
                for record in row['artifacts']:
                    produced[record['path']] = record
                row['positive_prerequisite_pass'] = True
                save()
            else:
                cell_record['status'] = 'positive_pass'
            completed[cell['id']] = cell_record['status']
            save()
        state['status'] = 'discovery_archive_complete_unqualified_review_required'
        state['target_dispositions'] = {cell['id']: cell['status'] for cell in state['cells'] if cell['role'] == 'target'}
        require(len(state['target_dispositions']) == 50, 'target inventory incomplete')
        verify()
        save()
        archive_manifest()
    except BaseException as error:
        state['status'] = 'STOP_global_identity_or_infrastructure_failure_no_retry'
        state['error'] = repr(error)
        for cell in state['cells']:
            if cell['status'] == 'running':
                cell['status'] = 'interrupted_global_stop_unqualified'
        # Ensure all 50 targets have a recorded disposition even on global prelaunch failure.
        existing = {cell['id'] for cell in state['cells']}
        for cell in plan['cells']:
            if cell['id'] not in existing:
                state['cells'].append({'id': cell['id'], 'profile': cell['profile'], 'control': cell['control'],
                                       'role': cell['role'], 'status': 'blocked_global_stop', 'qualified': False})
        state['target_dispositions'] = {cell['id']: cell['status'] for cell in state['cells'] if cell['role'] == 'target'}
        save()
        archive_manifest()
        raise


if __name__ == '__main__':
    main()
