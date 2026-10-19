"""Exactly one sequential schema4/384 continuation after independent review."""
from pathlib import Path
import fcntl
import json
import os
import signal
import subprocess
import sys
import time
import traceback
from readiness import (actual, git, require, sha, stream_sha, tree_entries,
                       verify_context, verify_reviewed_packet,
                       qualify_schema4, qualify_counter)

ROOT = Path('/Users/eugene/work/GiftUI')
PACKET = Path(__file__).resolve().parent


def snapshot(parent):
    require(parent.resolve() == parent and parent.is_dir(), 'output parent alias')
    return {p.name: [p.stat().st_dev, p.stat().st_ino] for p in parent.iterdir()}


def main():
    require(len(sys.argv) == 4, 'external independent review pins required')
    pins = sys.argv[1:]
    recipe = json.loads(actual(PACKET / 'recipe.json'))
    lock = None
    def verify():
        if lock is not None:
            require(not lock_path.is_symlink() and os.fstat(lock.fileno()).st_ino == lock_path.stat().st_ino and os.fstat(lock.fileno()).st_dev == lock_path.stat().st_dev, 'permanent lock identity drift')
        verify_reviewed_packet(ROOT, PACKET, *pins)
        verify_context(ROOT, PACKET, recipe)
    verify()
    out = Path(recipe['output_root'])
    require(not out.exists() and not out.is_symlink(), 'consumed output root; no retry')
    lock_path = ROOT / '.build/validation.lock'
    require(not lock_path.is_symlink(), 'validation lock alias')
    lock = lock_path.open('a+b')
    fcntl.flock(lock, fcntl.LOCK_EX)
    require(os.fstat(lock.fileno()).st_ino == lock_path.stat().st_ino, 'permanent lock inode')
    verify()
    require(not out.exists() and not out.is_symlink(), 'consumed under lock')
    out.mkdir()  # Permanent consumed marker: never remove to enable another run.
    report = dict(status='STOP', source_candidates=1, retries=0, automatic_repairs=0,
                  reviewed_commit=pins[0], started_ns=time.time_ns(), stages=[])
    input_tools = json.loads(actual(PACKET / 'tools.json'))
    parent = ROOT / '.build/contracts'
    code = 1
    schema_snapshot = None
    host = None
    try:
        for stage in ('schema4', 'counter384'):
            verify()  # Complete applicability immediately before each launch.
            if schema_snapshot is not None:
                require(tree_entries(host) == schema_snapshot, 'schema4 producer boundary drift')
                qualify_schema4(ROOT, Path(recipe['p07_root']), host, input_tools)
            argv = recipe['schema4_argv'] if stage == 'schema4' else recipe['counter_argv_prefix'] + [str(host)] + recipe['counter_argv_suffix']
            before = snapshot(parent)
            item = dict(name=stage, argv=argv, started_ns=time.time_ns(), before=before)
            report['stages'].append(item)
            report['working_tree_before'] = git(ROOT, 'status', '--porcelain').decode()
            (out / 'launch.json').write_text(json.dumps(report, indent=2) + '\n')
            environment = dict(recipe['environment'])
            with (out / (stage + '.stdout')).open('wb') as stdout, (out / (stage + '.stderr')).open('wb') as stderr:
                process = subprocess.Popen(argv, executable=recipe['python_executable'], cwd=ROOT, env=environment, stdout=stdout, stderr=stderr, pass_fds=(lock.fileno(),))
                def stop(signum, frame):
                    process.send_signal(signum)
                for sig in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
                    signal.signal(sig, stop)
                item['exit'] = process.wait()
            item['finished_ns'] = time.time_ns()
            after = snapshot(parent)
            item['after'] = after
            item['raw_logs'] = {stream: stream_sha(out / (stage + '.' + stream)) for stream in ('stdout', 'stderr')}
            verify()  # Complete applicability even after a material stage failure.
            if schema_snapshot is not None:
                require(tree_entries(host) == schema_snapshot, 'schema4 changed during consumer')
            require(all(after.get(k) == v for k, v in before.items()), 'existing output identity drift')
            added = set(after) - set(before)
            require(len(added) == 1, 'missing/ambiguous fresh output')
            fresh = parent / added.pop()
            prefix = recipe['schema4_prefix'] if stage == 'schema4' else recipe['counter_prefix']
            require(fresh.name.startswith(prefix) and fresh.resolve() == fresh and fresh.is_dir(), 'driver output identity')
            streams = actual(out / (stage + '.stdout')) + actual(out / (stage + '.stderr'))
            require(str(fresh).encode() in streams, 'fresh output raw stream binding')
            item['output_root'] = str(fresh)
            item['files'] = tree_entries(fresh)
            require(item['exit'] == 0, 'first material failure; all later launches prohibited')
            if stage == 'schema4':
                qualify_schema4(ROOT, Path(recipe['p07_root']), fresh, input_tools)
                host = fresh
                schema_snapshot = item['files']
            else:
                qualify_counter(ROOT, Path(recipe['p07_root']), host, fresh, input_tools)
        report['status'] = 'PASS_separate_retained_applicability_schema4_activation_counter384_only'
        code = 0
    except BaseException:
        report['error'] = traceback.format_exc()
    finally:
        report['finished_ns'] = time.time_ns()
        report['working_tree_after'] = git(ROOT, 'status', '--porcelain').decode()
        report['observed_contract_roots_after'] = snapshot(parent)
        # Preserve every observed new output even if qualification/authentication
        # failed. Such roots remain observations, never accepted dependencies.
        for item in report['stages']:
            item['observed_new_roots'] = {}
            for name in set(item.get('after', report['observed_contract_roots_after'])) - set(item['before']):
                candidate = parent / name
                try:
                    item['observed_new_roots'][name] = tree_entries(candidate)
                except BaseException:
                    item['observed_new_roots'][name] = dict(collection_error=traceback.format_exc())
        (out / 'terminal.json').write_text(json.dumps(report, sort_keys=True, indent=2) + '\n')
    print(out / 'terminal.json')
    return code


if __name__ == '__main__':
    raise SystemExit(main())
