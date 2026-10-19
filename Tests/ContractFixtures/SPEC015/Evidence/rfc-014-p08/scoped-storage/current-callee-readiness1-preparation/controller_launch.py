"""Authenticate, consume one permanent marker and detach one reviewed worker."""
import fcntl
import os
import subprocess
import sys
import time
import traceback
from controller_common import (ROOT, PACKET, OUT, LOCK, require, read_json,
                               verify_packet, verify_context, verify_recipe,
                               verify_python, check_lock, atomic_json,
                               fsync_directory, reviewed_source)


def main():
    require(len(sys.argv) == 4, 'three full independent reviewed Git pins required')
    pins = sys.argv[1:]
    verify_python('bootstrap')
    verify_packet(pins)
    verify_context()
    recipe = verify_recipe()
    environments = read_json(PACKET / 'process-environment.json')
    require(OUT.parent.resolve() == OUT.parent and OUT.parent.is_dir(), 'canonical existing output parent')
    require(not OUT.exists() and not OUT.is_symlink(), 'one-shot marker already consumed')
    require(LOCK.resolve() == LOCK and LOCK.is_file() and not LOCK.is_symlink(), 'existing permanent validation lock')
    fd = os.open(str(LOCK), os.O_RDWR | os.O_NOFOLLOW)
    try:
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        check_lock(fd)
        verify_packet(pins)
        verify_context()
        verify_recipe()
        require(not OUT.exists() and not OUT.is_symlink(), 'consumed under validation lock')
        # mkdir is the permanent exclusive allowance claim. It is never removed.
        OUT.mkdir()
        fsync_directory(OUT.parent)
        identity = [OUT.stat().st_dev, OUT.stat().st_ino]
        launch = dict(status='CONSUMED_not_terminal', collection_attempts=1,
                      max_swiftc_invocations=94, source_candidates=0,
                      automatic_source_repairs=0, automatic_tooling_repairs=0,
                      retries=0, reviewed_pins=pins, marker_identity=identity,
                      consumed_wall_ns=time.time_ns(), launcher_pid=os.getpid(),
                      proposed_sil_argv=recipe['fresh_sil_command'],
                      environments=environments)
        atomic_json(OUT / 'launch.json', launch)
        sources = {name: reviewed_source(name, pins)
                   for name in ('controller_common', 'controller_worker')}
        bootstrap = 'import sys,types\n'
        bootstrap += "m=types.ModuleType('controller_common')\nm.__file__=" + repr(str(PACKET / 'controller_common.py')) + '\n'
        bootstrap += 'exec(compile(' + repr(sources['controller_common']) + ",'<reviewed controller common Git blob>','exec'),m.__dict__)\nsys.modules['controller_common']=m\n"
        bootstrap += 'exec(compile(' + repr(sources['controller_worker']) + ",'<reviewed detached worker Git blob>','exec'),{'__name__':'__main__','__file__':" + repr(str(PACKET / 'controller_worker.py')) + '})\n'
        argv = [environments['python_executable'], *environments['python_flags'], '-c',
                bootstrap, *pins, str(fd), str(identity[0]), str(identity[1])]
        with (OUT / 'worker.stdout').open('xb') as stdout, (OUT / 'worker.stderr').open('xb') as stderr:
            try:
                before = dict(observed_wall_ns=time.time_ns(), observed_monotonic_ns=time.monotonic_ns())
                worker = subprocess.Popen(argv, cwd=ROOT, env=environments['controller'],
                                          stdin=subprocess.DEVNULL, stdout=stdout, stderr=stderr,
                                          start_new_session=True, pass_fds=(fd,))
                after = dict(observed_wall_ns=time.time_ns(), observed_monotonic_ns=time.monotonic_ns())
                atomic_json(OUT / 'detach.json', dict(worker_pid=worker.pid, spawn_before=before,
                                                     spawn_after=after, reviewed_pins=pins,
                                                     marker_identity=identity, separate_session=True))
            except BaseException:
                atomic_json(OUT / 'detach-error.json', dict(error=traceback.format_exc(),
                                                           recorded_ns=time.time_ns()))
                raise
    finally:
        os.close(fd)
    print(OUT)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
