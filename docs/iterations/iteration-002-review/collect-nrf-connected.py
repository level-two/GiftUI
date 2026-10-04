"""Identified-probe nonhalting SWD baseline; addresses derived from the ELF."""
from pathlib import Path
import datetime
import hashlib
import json
import subprocess
import sys
import time

root = Path.cwd()
out = root / ".build/nrf52840/iteration-002-connected" / (sys.argv[1] if len(sys.argv) > 1 else "baseline-idle")
out.mkdir(parents=True, exist_ok=True)
elf = root / ".build/nrf52840/signal-analyzer-static/zephyr/zephyr.elf"
nm = subprocess.check_output([str(root / ".toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-nm"), "-n", str(elf)], text=True)
symbols = {fields[-1]: int(fields[0], 16) for line in nm.splitlines() if len(fields := line.split()) == 3}
commands = ["connect", "go"]
count = int(sys.argv[2]) if len(sys.argv) > 2 else 120
assert 1 <= count <= 600
for _ in range(count):
    commands += [f"mem32 0x{symbols['production'] + 48:08X}, 10", f"mem32 0x{symbols['fault_counts']:08X}, 5",
                 "mem32 0xE000ED28, 3", "mem32 0xE000EDF0, 1", "sleep 100"]
commands += ["q"]
script = out / "monitor.jlink"
script.write_text("\n".join(commands) + "\n")
command = ["JLinkExe", "-device", "NRF52840_XXAA", "-if", "SWD", "-speed", "4000", "-SelectEmuBySN", "683833660",
           "-autoconnect", "1", "-CommanderScript", str(script)]
identity = dict(elf_sha256=hashlib.sha256(elf.read_bytes()).hexdigest(), elf=str(elf.relative_to(root)),
                probe_serial="683833660", production=symbols["production"], fault_counts=symbols["fault_counts"],
                command=command, requested_samples=count, requested_sleep_ms=100,
                kind="connected nonhalting SWD reads; host timestamps include probe overhead",
                started_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
started = time.monotonic()
process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
with (out / "monitor.log").open("w") as log:
    for line in process.stdout:
        log.write(datetime.datetime.now(datetime.timezone.utc).isoformat() + " " + line)
        log.flush()
identity["exit_code"] = process.wait()
identity["elapsed_seconds"] = time.monotonic() - started
(out / "identity.json").write_text(json.dumps(identity, indent=2) + "\n")
print(json.dumps(identity))
raise SystemExit(identity["exit_code"])
