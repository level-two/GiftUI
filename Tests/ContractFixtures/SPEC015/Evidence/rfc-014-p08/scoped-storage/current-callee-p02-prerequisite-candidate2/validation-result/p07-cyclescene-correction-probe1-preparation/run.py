"""One isolated maintained P07 invocation; use the reviewed Git bootstrap only."""
from pathlib import Path
import json
import fcntl
import os
import signal
import subprocess
import sys
import time
import traceback
from readiness import actual, git, require, sha, verify_context, verify_reviewed_packet

ROOT = Path('/Users/eugene/work/GiftUI')
PACKET = Path(__file__).resolve().parent

def snapshot(parent):
    if not parent.exists():
        return {}
    require(parent.resolve() == parent and not parent.is_symlink(), 'output parent alias')
    return {p.name: [p.stat().st_dev, p.stat().st_ino] for p in parent.iterdir()}

def main():
    require(len(sys.argv) == 4, 'external review pins required')
    commit, tree, packet_tree = sys.argv[1:4]
    def verify():
        verify_reviewed_packet(ROOT, PACKET, commit, tree, packet_tree)
        verify_context(ROOT, PACKET, recipe)
    recipe = json.loads(actual(PACKET / 'recipe.json'))
    verify()
    out = Path(recipe['output_root'])
    require(not out.exists() and not out.is_symlink(), 'fresh receipt output root required')
    # Use the same permanent flock inode as the repository Ruby lock wrapper.
    # No environment flag or extra CLI argument can assert lock ownership.
    lock_path = ROOT / '.build/validation.lock'
    require(not lock_path.is_symlink(), 'validation lock alias')
    lock_path.parent.mkdir(parents=True, exist_ok=True)
    lock = lock_path.open('a+b')
    fcntl.flock(lock, fcntl.LOCK_EX)
    verify()
    require(not out.exists() and not out.is_symlink(), 'fresh root under lock required')
    out.mkdir()  # Permanent consumed marker: no reset, retry, cleanup or repair route.
    report = {'status': 'STOP', 'source_candidates': 1, 'retries': 0, 'automatic_repairs': 0,
              'reviewed_commit': commit, 'argv': recipe['argv'], 'started_ns': time.time_ns()}
    parent = Path(recipe['driver_output_parent'])
    before = snapshot(parent)
    report['driver_parent_before'] = before
    code = 1
    try:
        verify()
        report['working_tree_before'] = git(ROOT, 'status', '--porcelain').decode()
        environment = dict(os.environ, **recipe['environment_overrides'])
        report['environment_sha256'] = sha(json.dumps(environment, sort_keys=True).encode())
        (out / 'launch.json').write_text(json.dumps(report, indent=2) + '\n')
        with (out / 'stdout').open('wb') as stdout, (out / 'stderr').open('wb') as stderr:
            process = subprocess.Popen(recipe['argv'], cwd=ROOT, env=environment, stdout=stdout, stderr=stderr, pass_fds=(lock.fileno(),))
            def stop(signum, frame):
                process.send_signal(signum)
            for sig in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
                signal.signal(sig, stop)
            code = process.wait()
        report['exit'] = code
        verify()
        after = snapshot(parent)
        require(all(after.get(k) == v for k, v in before.items()), 'existing output directory identity drift')
        added = set(after) - set(before)
        require(len(added) == 1, 'ambiguous or missing new P07 output root')
        scratch = parent / added.pop() / 'macos-static'
        require(scratch.is_dir() and scratch.resolve() == scratch, 'new P07 profile root')
        report['driver_output_root'] = str(scratch)
        require(str(scratch) in (actual(out / 'stdout') + actual(out / 'stderr')).decode(), 'new output root stream binding')
        report['driver_files'] = {str(p.relative_to(scratch)): sha(actual(p)) for p in scratch.rglob('*') if p.is_file() or p.is_symlink()}
        require(code == 0, 'P07 material failure; dependents unrun')
        receipt = json.loads(actual(scratch / 'result.json'))
        require(receipt['package'] == 'P07' and receipt['profile'] == 'macos-static', 'terminal P07 receipt')
        require(receipt['source_commit'] == commit and receipt['core_receipt_sha256'] == recipe['producer']['sha256'], 'terminal provenance')
        require(receipt['checks'] and all(x['pass'] for x in receipt['checks']), 'terminal check failure')
        report['status'] = 'PASS_isolated_P07_only_no_dependent_release'
    except BaseException:
        report['error'] = traceback.format_exc()
        code = 1
    finally:
        report['finished_ns'] = time.time_ns()
        report['driver_parent_after'] = snapshot(parent)
        report['working_tree_after'] = git(ROOT, 'status', '--porcelain').decode()
        report['raw_logs'] = {n: sha(actual(out / n)) for n in ('stdout','stderr') if (out / n).exists()}
        (out / 'terminal.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
    print(out / 'terminal.json')
    return code

if __name__ == '__main__':
    raise SystemExit(main())
