"""Consume the reviewed counter-only attempt, then detach its pinned supervisor."""
from pathlib import Path
import fcntl
import json
import os
import subprocess
import sys
import time
from readiness import actual, git, require, verify_context, verify_reviewed_packet
from supervisor import atomic_json, process_observation, clock_observation, check_lock

ROOT = Path('/Users/eugene/work/GiftUI')
PACKET = Path(__file__).resolve().parent


def main():
    require(len(sys.argv) == 4, 'external independent review pins required')
    pins = sys.argv[1:]
    recipe = json.loads(actual(PACKET / 'recipe.json'))
    verify_reviewed_packet(ROOT, PACKET, *pins)
    verify_context(ROOT, PACKET, recipe)
    out = Path(recipe['output_root'])
    require(not out.exists() and not out.is_symlink(), 'permanent marker consumed; no relaunch')
    lock_path = ROOT / '.build/validation.lock'
    require(not lock_path.is_symlink(), 'validation lock alias')
    with lock_path.open('a+b') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        check_lock(lock.fileno(), lock_path)
        verify_reviewed_packet(ROOT, PACKET, *pins)
        verify_context(ROOT, PACKET, recipe)
        require(not out.exists() and not out.is_symlink(), 'marker consumed under lock')
        launcher_observation = process_observation(os.getpid())  # Pre-consumption observation.
        out.mkdir()  # Permanent allowance consumption, before any supervisor spawn.
        parent_fd = os.open(str(out.parent), os.O_RDONLY)
        try:
            os.fsync(parent_fd)
        finally:
            os.close(parent_fd)
        identity = [out.stat().st_dev, out.stat().st_ino]
        launch = dict(status='CONSUMED_not_terminal', initial_launches=1,
                      automatic_repairs=0, retries=0, schema4_launches=0,
                      reviewed_pins=pins, marker_identity=identity,
                      consumed_ns=time.time_ns(), launcher_observation=launcher_observation,
                      argv=recipe['counter_argv'], environment=recipe['environment'],
                      working_tree=git(ROOT, 'status', '--porcelain').decode())
        atomic_json(out / 'launch.json', launch)
        # Child code comes from the reviewed Git tree, never a local import.
        sources = {name: git(ROOT, 'show', pins[2] + ':' + name).decode()
                   for name in ('readiness.py', 'supervisor.py')}
        bootstrap = "import sys,types\n"
        bootstrap += "m=types.ModuleType('readiness')\nexec(compile(" + repr(sources['readiness.py']) + ",'<reviewed readiness>','exec'),m.__dict__)\nsys.modules['readiness']=m\n"
        bootstrap += "exec(compile(" + repr(sources['supervisor.py']) + ",'<reviewed detached supervisor>','exec'),{'__name__':'__main__','__file__':" + repr(str(PACKET / 'supervisor.py')) + "})\n"
        argv = [recipe['python_executable'], '-I', '-S', '-B', '-X',
                'pycache_prefix=/dev/null', '-c', bootstrap, *pins,
                str(lock.fileno()), str(identity[0]), str(identity[1])]
        with (out / 'supervisor.stdout').open('xb') as stdout, (out / 'supervisor.stderr').open('xb') as stderr:
            try:
                spawn_before = clock_observation()
                child = subprocess.Popen(argv, cwd=ROOT, env=recipe['environment'],
                                         stdin=subprocess.DEVNULL, stdout=stdout, stderr=stderr,
                                         start_new_session=True, pass_fds=(lock.fileno(),))
                spawn_after = clock_observation()
                atomic_json(out / 'detach.json', dict(supervisor_observation=process_observation(child.pid),
                            spawn_before=spawn_before, spawn_after=spawn_after,
                            reviewed_pins=pins, marker_identity=identity, session_independent=True))
            except BaseException:
                # Any disappearance here still leaves the permanent marker consumed.
                import traceback
                atomic_json(out / 'detach-error.json', dict(error=traceback.format_exc(), recorded_ns=time.time_ns()))
                raise
    print(out)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
