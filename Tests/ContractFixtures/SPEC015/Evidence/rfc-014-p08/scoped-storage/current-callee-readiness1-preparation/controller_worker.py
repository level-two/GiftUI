"""Detached one-shot collection; missing terminal never authorizes a retry."""
from pathlib import Path
import hashlib
import json
import os
import re
import signal
import subprocess
import sys
import time
import traceback
from controller_common import (ROOT, PACKET, OUT, LOCK, require, sha, read_json,
                               verify_packet, verify_context, verify_recipe,
                               verify_python, check_lock, atomic_json,
                               permanent_claim, tree_entries)


def observation():
    return dict(observed_wall_ns=time.time_ns(), observed_monotonic_ns=time.monotonic_ns())


def privacy_pass(control, row, text):
    errors = re.findall(r'^.*?:\d+:\d+: error: (.*)$', text, re.M)
    row['errors'] = errors
    if 'expected_errors' in control:
        expected = control['expected_errors']
        return (row['actual_exit'] == 0 and not errors) if not expected else (
            row['actual_exit'] != 0 and len(errors) == len(expected) and sorted(errors) == sorted(expected))
    expected = control['expected_error_regex']
    return (row['actual_exit'] == 0 and not errors) if expected is None else (
        row['actual_exit'] != 0 and len(errors) == control['expected_count'] and
        all(re.search(expected, error) for error in errors))


def main():
    require(len(sys.argv) == 7, 'worker needs three review pins, lock fd and marker device/inode')
    pins = sys.argv[1:4]
    lock_fd, device, inode = map(int, sys.argv[4:])
    marker = [device, inode]
    claimed = False
    report = dict(status='STOP', collection_attempts=1, max_swiftc_invocations=94,
                  swiftc_claims=0, swiftc_actual_exits=0, automatic_source_repairs=0,
                  automatic_tooling_repairs=0, retries=0, source_candidates=0,
                  reviewed_pins=pins, marker_identity=marker, stages=[],
                  strict_cold_eligible=False, current_callee_review='pending',
                  p08_closed=False, r07_closed=False, t8_1_closed=False)
    current = None
    stopped = []

    def verify():
        check_lock(lock_fd)
        require(OUT.resolve() == OUT and [OUT.stat().st_dev, OUT.stat().st_ino] == marker,
                'permanent marker identity drift')
        verify_packet(pins)
        verify_context()
        verify_recipe()

    def terminate(signum, frame):
        stopped.append(signum)
        if current is not None:
            try:
                current.send_signal(signum)
            except ProcessLookupError:
                pass

    def execute(name, argv, environment, compiler=False):
        nonlocal current
        require(not stopped, 'termination requested; no later child')
        require(re.fullmatch('[A-Za-z0-9_-]+', name) is not None, 'finite raw stage filename')
        verify()
        if compiler:
            require(report['swiftc_claims'] < 94, 'compiler invocation budget exhausted')
            report['swiftc_claims'] += 1
        row = dict(name=name, argv=argv, environment=environment, actual_exit=None,
                   compiler=compiler, reviewed_pins=pins, marker_identity=marker,
                   claimed_observation=observation())
        # This permanent O_EXCL claim is consumed even if spawn fails.
        permanent_claim(OUT / (name + '.claim.json'), row)
        report['stages'].append(row)
        atomic_json(OUT / 'progress.json', report)
        stdout_path, stderr_path = OUT / (name + '.stdout'), OUT / (name + '.stderr')
        with stdout_path.open('xb') as stdout, stderr_path.open('xb') as stderr:
            row['spawn_before'] = observation()
            process = subprocess.Popen(argv, cwd=ROOT, env=environment,
                                       stdin=subprocess.DEVNULL, stdout=stdout,
                                       stderr=stderr, pass_fds=(lock_fd,))
            current = process
            try:
                row['spawn_after'] = observation()
                row['pid'] = process.pid
                atomic_json(OUT / (name + '.start.json'), row)
            finally:
                # Only Popen.wait supplies the actual exit, even on recording error.
                row['actual_exit'] = process.wait()
                row['wait_observation'] = observation()
                current = None
                if compiler:
                    report['swiftc_actual_exits'] += 1
                stdout.flush()
                stderr.flush()
                os.fsync(stdout.fileno())
                os.fsync(stderr.fileno())
                row['raw'] = {str(p.name): dict(bytes=p.stat().st_size, sha256=sha(p))
                              for p in (stdout_path, stderr_path)}
                atomic_json(OUT / (name + '.exit.json'), row)
        verify()
        require(not stopped, 'termination requested after actual child exit')
        text = stdout_path.read_text(errors='replace') + stderr_path.read_text(errors='replace')
        atomic_json(OUT / 'progress.json', report)
        return row, text

    try:
        require(OUT.resolve() == OUT and [OUT.stat().st_dev, OUT.stat().st_ino] == marker,
                'consumed worker marker')
        permanent_claim(OUT / 'worker-claim.json', dict(reviewed_pins=pins, marker_identity=marker,
                                                       pid=os.getpid(), **observation()))
        claimed = True
        verify_python('controller')
        signal.signal(signal.SIGHUP, signal.SIG_IGN)
        signal.signal(signal.SIGTERM, terminate)
        signal.signal(signal.SIGINT, terminate)
        verify()
        launch = read_json(OUT / 'launch.json')
        require(launch['reviewed_pins'] == pins and launch['marker_identity'] == marker and
                launch['collection_attempts'] == 1, 'durable launch provenance')
        recipe = read_json(PACKET / 'collection-recipe.json')
        environments = read_json(PACKET / 'process-environment.json')
        atomic_json(OUT / 'worker-start.json', dict(reviewed_pins=pins, marker_identity=marker,
                                                  pid=os.getpid(), **observation()))

        # Collect all independent controls, retaining the reviewed original classifiers.
        privacy = []
        for control in recipe['privacy_controls']:
            row, text = execute(control['name'], control['command'],
                                environments['compiler_and_macro'], compiler=True)
            row['passed'] = privacy_pass(control, row, text)
            row['expected'] = {k: v for k, v in control.items() if k not in ('command', 'provenance')}
            privacy.append(row['passed'])
            atomic_json(OUT / 'progress.json', report)
        report['privacy_passed'] = len(privacy) == 93 and all(privacy)

        captures = []
        for item in recipe['serialized_module_captures']:
            row, _ = execute(item['name'], item['command'], environments['decoder'])
            row['passed'] = row['actual_exit'] == 0
            captures.append(row['passed'])
        report['indexes_captured'] = len(captures) == 11 and all(captures)

        bodies = False
        if report['indexes_captured']:
            commands = {row['name'].removesuffix('-decode'): row['command']
                        for row in recipe['serialized_module_captures']}
            atomic_json(OUT / 'boundaries-decode-prepared.json', dict(commands=commands))
            interpreter = recipe['decode_interpreter_command']
            source_path = interpreter[-2]
            expected = read_json(PACKET / 'input-freeze.json')[str(Path(source_path).relative_to(ROOT))]
            interpreter_source = Path(source_path).read_bytes()
            require(hashlib.sha256(interpreter_source).hexdigest() == expected, 'pinned interpreter code')
            # Execute the authenticated source string, avoiding a later mutable script import.
            argv = [*interpreter[:-2], '-c', interpreter_source.decode(), str(OUT)]
            row, _ = execute('body-index-interpret', argv, environments['interpreter_and_demangler'])
            row['passed'] = row['actual_exit'] == 0
            if row['passed']:
                index = read_json(OUT / 'boundary-physical-index.json')
                require(set(index) == set(commands), 'complete eleven-module index')
                for value in index.values():
                    require(value['metadata_version'] == [0, 1003] and
                            value['entry_count'] == len(value['functions']), 'full serialized index schema')
                body_rows = []
                for target in read_json(recipe['required_body_targets']):
                    matches = [f for f in index[target['module']]['functions']
                               if (f['name'] == target['name'] if 'name' in target
                                   else f['demangled'] == target['demangled_exact'])]
                    passed = len(matches) == 1 and matches[0]['serialized_kind'] != 0 and matches[0]['basic_blocks'] > 0
                    body_rows.append(dict(target=target, matches=matches, passed=passed))
                atomic_json(OUT / 'required-bodies.json', body_rows)
                bodies = len(body_rows) == 92 and all(row['passed'] for row in body_rows)
        report['required_bodies_passed'] = bodies

        objects = []
        for item in recipe['object_captures']:
            row, _ = execute(item['name'], item['command'], environments['decoder'])
            row['passed'] = row['actual_exit'] == 0
            objects.append(row['passed'])
        report['objects_captured'] = len(objects) == 50 and all(objects)

        if report['privacy_passed'] and bodies and report['objects_captured']:
            row, _ = execute('actual-host-sil', recipe['fresh_sil_command'],
                             environments['compiler_and_macro'], compiler=True)
            sil = OUT / 'actual-host.sil'
            row['passed'] = row['actual_exit'] == 0 and sil.is_file() and not sil.is_symlink() and sil.stat().st_size > 0
            require(row['passed'], 'actual host SIL failure; no repair/retry')
            report['sil'] = dict(bytes=sil.stat().st_size, sha256=sha(sil))
            report['status'] = 'PASS_collection_only_current_callee_interpretation_pending'
        else:
            report['sil_blocked'] = 'privacy, full body-index or matching-object prerequisite failed'
        verify()
        require(report['swiftc_claims'] <= 94, 'compiler budget')
    except BaseException:
        report['error'] = traceback.format_exc()
        report['status'] = 'STOP'
    finally:
        report['finished_observation'] = observation()
        report['termination_requests'] = stopped
        if claimed:
            try:
                report['raw_output_manifest_before_terminal'] = tree_entries(OUT)
            except BaseException:
                report['manifest_error'] = traceback.format_exc()
                report['status'] = 'STOP'
            atomic_json(OUT / 'terminal.json', report)
        os.close(lock_fd)
    return 0 if report['status'].startswith('PASS_collection_only') else 1


if __name__ == '__main__':
    raise SystemExit(main())
