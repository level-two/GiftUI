"""Run remotely via ssh python3 -; bounded production Pi measurement only."""
from pathlib import Path
import datetime
import json
import subprocess
import threading
import time
import hashlib
import sys

def emit(kind, **values):
    print(json.dumps(dict(kind=kind, utc=datetime.datetime.now(datetime.timezone.utc).isoformat(), **values)), flush=True)

binary = Path.home() / "giftui/experiments/iteration-002-spike-013/SignalAnalyzerPiResearch"
arch = subprocess.check_output(["uname", "-m"], text=True).strip()
assert arch == "armv6l", arch
assert len(sys.argv) == 2 and hashlib.sha256(binary.read_bytes()).hexdigest() == sys.argv[1]
emit("identity", architecture=arch, hostname=subprocess.check_output(["hostname"], text=True).strip(),
     binary_digest=subprocess.check_output(["sha256sum", str(binary)], text=True).split()[0],
     temperature_millidegrees=Path("/sys/class/thermal/thermal_zone0/temp").read_text().strip())
command = ["sudo", "-n", "env", "GIFTUI_PI_TRACE=1", "SWIFT_BACKTRACE=enable=yes", "timeout",
           "--signal=INT", "--kill-after=10", "45", "stdbuf", "-oL", "-eL", str(binary), "--run-signal-analyzer"]
emit("command", argv=command, input_kind="production automatic Start; real source loop; no supplied physical contacts")
process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
def collect_output():
    for line in process.stdout:
        emit("trace", line=line.rstrip())
thread = threading.Thread(target=collect_output)
thread.start()
started = time.monotonic()
while process.poll() is None:
    listing = subprocess.check_output(["ps", "-eo", "pid,ppid,rss,pcpu,comm,args"], text=True)
    samples = []
    for line in listing.splitlines()[1:]:
        fields = line.split(None, 5)
        if len(fields) == 6 and fields[4].startswith("SignalAnalyzer"):
            status = Path(f"/proc/{fields[0]}/status")
            try:
                memory = [value for value in status.read_text().splitlines() if value.startswith(("VmRSS:", "VmHWM:", "Threads:"))]
            except FileNotFoundError:
                memory = []
            samples.append(dict(pid=int(fields[0]), rss_kib=int(fields[2]), cpu_percent=fields[3], status=memory))
    emit("process", elapsed_seconds=time.monotonic() - started, samples=samples)
    time.sleep(1)
thread.join()
emit("exit", wrapper_exit_code=process.returncode, elapsed_seconds=time.monotonic() - started,
     stop_reason="45-second SIGINT timeout; application status is recorded separately")
