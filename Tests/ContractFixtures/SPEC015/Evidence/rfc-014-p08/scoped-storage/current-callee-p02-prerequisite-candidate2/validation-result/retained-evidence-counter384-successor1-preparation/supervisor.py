"""Detached one-child supervisor. Lost supervisor never implies a terminal result."""
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
                       verify_context, verify_reviewed_packet, qualify_counter)

ROOT = Path('/Users/eugene/work/GiftUI')
PACKET = Path(__file__).resolve().parent


def atomic_json(path, data):
    """Flush content and parent directory around a same-directory atomic rename."""
    temporary = path.with_name(path.name + '.writing-' + str(os.getpid()))
    with temporary.open('x') as stream:
        json.dump(data, stream, sort_keys=True, indent=2)
        stream.write('\n')
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(temporary, path)
    fd = os.open(str(path.parent), os.O_RDONLY)
    try:
        os.fsync(fd)
    finally:
        os.close(fd)


def process_identity(pid):
    return dict(pid=pid, observed_ns=time.time_ns(),
                ps=subprocess.check_output(['/bin/ps', '-p', str(pid), '-o', 'pid=,ppid=,pgid=,lstart=']).decode().strip())


def check_lock(fd, path):
    require(not path.is_symlink() and path.resolve() == path, 'permanent lock path')
    value = os.fstat(fd)
    require((value.st_dev, value.st_ino) == (path.stat().st_dev, path.stat().st_ino), 'permanent lock identity')
    # The inherited open-file description already holds this exclusive flock.
    fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)


def snapshot(parent):
    require(parent.resolve() == parent and parent.is_dir(), 'output parent alias')
    return {p.name: [p.stat().st_dev, p.stat().st_ino] for p in parent.iterdir()}


def supervise_child(out, argv, executable, cwd, environment, lock_fd, report):
    """One Popen only; shared with harmless detached fixture verification."""
    require(not (out / 'child-launch-consumed.json').exists(), 'child claim consumed; no relaunch')
    # O_EXCL provides permanent at-most-once consumption even if two supervisors race.
    with (out / 'child-launch-consumed.json').open('x') as stream:
        json.dump(dict(claimed_ns=time.time_ns(), supervisor=process_identity(os.getpid()), argv=argv), stream)
        stream.flush()
        os.fsync(stream.fileno())
    signal.signal(signal.SIGHUP, signal.SIG_IGN)
    with (out / 'counter384.stdout').open('xb') as stdout, (out / 'counter384.stderr').open('xb') as stderr:
        process = subprocess.Popen(argv, executable=executable, cwd=cwd,
                                   env=environment, stdin=subprocess.DEVNULL,
                                   stdout=stdout, stderr=stderr, pass_fds=(lock_fd,))
        report['child_pid'] = process.pid
        report['child_started_ns'] = time.time_ns()
        try:
            for sig in (signal.SIGINT, signal.SIGTERM):
                signal.signal(sig, lambda signum, frame: process.send_signal(signum))
            # A very short child can exit before ps; spawn facts remain durable.
            try:
                report['child_identity'] = process_identity(process.pid)
            except subprocess.CalledProcessError:
                report['child_identity'] = dict(pid=process.pid, already_exited=True)
            atomic_json(out / 'child-start.json', report)
        finally:
            # Once spawned, always reap the actual child even if recording fails.
            report['child_exit'] = process.wait()
            report['child_finished_ns'] = time.time_ns()
        stdout.flush(); stderr.flush()
        os.fsync(stdout.fileno()); os.fsync(stderr.fileno())
    report['raw_logs'] = {name: stream_sha(out / ('counter384.' + name)) for name in ('stdout', 'stderr')}


def main():
    require(len(sys.argv) == 7, 'supervisor needs reviewed pins, inherited lock and marker identity')
    pins = sys.argv[1:4]
    lock_fd, device, inode = map(int, sys.argv[4:])
    recipe = json.loads(actual(PACKET / 'recipe.json'))
    out = Path(recipe['output_root'])
    require(out.resolve() == out and (out.stat().st_dev, out.stat().st_ino) == (device, inode), 'consumed marker identity')
    # Permanent exclusive worker claim; no second supervisor can launch a child.
    with (out / 'supervisor-claim.json').open('x') as stream:
        json.dump(dict(pid=os.getpid(), started_ns=time.time_ns()), stream)
        stream.flush(); os.fsync(stream.fileno())
    report = dict(status='STOP', initial_launches=1, automatic_repairs=0, retries=0,
                  schema4_launches=0, reviewed_pins=pins, started_ns=time.time_ns(),
                  supervisor=process_identity(os.getpid()), child_exit=None)
    parent = ROOT / '.build/contracts'
    def verify():
        check_lock(lock_fd, ROOT / '.build/validation.lock')
        require(out.resolve() == out and (out.stat().st_dev, out.stat().st_ino) == (device, inode), 'consumed marker drift')
        verify_reviewed_packet(ROOT, PACKET, *pins)
        verify_context(ROOT, PACKET, recipe)
    code = 1
    try:
        signal.signal(signal.SIGHUP, signal.SIG_IGN)
        verify()
        launch = json.loads(actual(out / 'launch.json'))
        require(launch['reviewed_pins'] == pins and launch['marker_identity'] == [device, inode] and launch['argv'] == recipe['counter_argv'], 'durable launch provenance')
        report['before'] = snapshot(parent)
        report['working_tree_before'] = git(ROOT, 'status', '--porcelain').decode()
        atomic_json(out / 'supervisor-start.json', report)
        supervise_child(out, recipe['counter_argv'], recipe['python_executable'], ROOT,
                        recipe['environment'], lock_fd, report)
        report['after'] = snapshot(parent)
        verify()  # Authenticate retained evidence even if the child failed.
        require(all(report['after'].get(k) == v for k, v in report['before'].items()), 'existing root identity drift')
        added = set(report['after']) - set(report['before'])
        require(len(added) == 1, 'missing/ambiguous fresh output')
        fresh = parent / added.pop()
        require(fresh.name.startswith(recipe['counter_prefix']) and fresh.resolve() == fresh and fresh.is_dir(), 'fresh counter output identity')
        report['output_root'] = str(fresh)
        require(str(fresh).encode() in actual(out / 'counter384.stdout') + actual(out / 'counter384.stderr'), 'fresh root raw stream binding')
        report['files'] = tree_entries(fresh)
        require(report['child_exit'] == 0, 'material counter failure; no retry')
        qualify_counter(ROOT, Path(recipe['p07_root']), Path(recipe['schema4_root']), fresh,
                        json.loads(actual(PACKET / 'tools.json')))
        report['status'] = 'PASS_separate_fresh_macos_static_counter384_only'
        code = 0
    except BaseException:
        report['error'] = traceback.format_exc()
    finally:
        report['finished_ns'] = time.time_ns()
        try:
            report['working_tree_after'] = git(ROOT, 'status', '--porcelain').decode()
            report['observed_roots_after'] = snapshot(parent)
            report['observed_new_roots'] = {}
            for name in set(report['observed_roots_after']) - set(report.get('before', report['observed_roots_after'])):
                try:
                    report['observed_new_roots'][name] = tree_entries(parent / name)
                except BaseException:
                    report['observed_new_roots'][name] = dict(collection_error=traceback.format_exc())
        except BaseException:
            report['collection_error'] = traceback.format_exc()
        atomic_json(out / 'terminal.json', report)
    os.close(lock_fd)
    return code


if __name__ == '__main__':
    raise SystemExit(main())
