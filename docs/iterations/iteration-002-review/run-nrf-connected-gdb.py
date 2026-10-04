"""Bounded application action injection with register-preserving J-Link attach.

Run only for an explicitly authorized connected experiment. GDB input is a
reviewed local script, not discovered device data. No flashing or reset occurs.
"""
from pathlib import Path
import subprocess
import sys
import time

script = Path(sys.argv[1]).resolve()
assert script.is_file() and script.suffix == '.gdb'
out = script.parent
with script.with_suffix('.server.log').open('w') as server_log, script.with_suffix('.log').open('w') as action_log:
    server = subprocess.Popen([
        'JLinkGDBServer', '-device', 'NRF52840_XXAA', '-if', 'SWD', '-speed', '4000',
        '-select', 'USB=683833660', '-port', '2331', '-localhostonly', '1', '-nogui',
        '-nohalt', '-noir', '-noreset'], stdout=server_log, stderr=subprocess.STDOUT)
    try:
        time.sleep(2)
        result = subprocess.run([
            '.toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-gdb',
            '-batch', '.build/nrf52840/signal-analyzer-static/zephyr/zephyr.elf', '-x', str(script)],
            stdout=action_log, stderr=subprocess.STDOUT, timeout=35)
    finally:
        server.terminate()
        server.wait(timeout=5)
print(script.with_suffix('.log').read_text())
raise SystemExit(result.returncode)
