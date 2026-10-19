"""Prepared one-shot A capture with an explicit closed B gate; not executed."""
import hashlib
import json
import os
import pathlib
import selectors
import signal
import subprocess
import time

ROOT = pathlib.Path("/Users/eugene/work/GiftUI")
PACKET = ROOT / "Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-u01-residual1-preparation"
OUT = ROOT / ".build/contracts/p08-u01-residual-static1"

class Stop(Exception):
    pass

def main(pins, started, packet_bytes, git):
    deadline = started + 360
    process = None
    received_total = 0
    retained_total = 0
    outcomes = []
    owns_output = False
    reason = "STOP_unfinished"

    def require(value, message):
        if not value:
            raise Stop(message)

    def check_time():
        if time.monotonic() >= deadline:
            raise Stop("aggregate_deadline")

    def remaining():
        check_time()
        return deadline - time.monotonic()

    def stop_signal(signum, frame):
        raise Stop("signal_" + str(signum))

    for signum in (signal.SIGALRM, signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
        signal.signal(signum, stop_signal)
    signal.setitimer(signal.ITIMER_REAL, max(0.001, remaining()))

    def read_packet(name):
        return json.loads(packet_bytes[name])

    def digest(path):
        value = hashlib.sha256()
        with path.open("rb") as stream:
            for block in iter(lambda: stream.read(1024 * 1024), b""):
                check_time()
                value.update(block)
        return value.hexdigest()

    def sync_dir():
        fd = os.open(OUT, os.O_RDONLY)
        try:
            os.fsync(fd)
        finally:
            os.close(fd)

    def write_once(name, value):
        path = OUT / name
        payload = (json.dumps(value, indent=2, sort_keys=True) + "\n").encode()
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, "wb") as stream:
            stream.write(payload)
            stream.flush()
            os.fsync(stream.fileno())
        sync_dir()

    def kill_group():
        if process is not None:
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass

    request = read_packet("request.json")
    policy = read_packet("loader-policy.json")
    context = read_packet("controller-inputs.json")
    gate = read_packet("gate-policy.json")
    accounting = read_packet("controller-accounting.json")
    commands = request["commands"]
    require(request["output_root"] == str(OUT), "fixed output root")
    require(len(commands) == 6 and [c["stage"] for c in commands] == ["A"] * 3 + ["B"] * 3, "fixed six-command request")
    require(accounting["controller_bootstrap_launches_proposed"] == 1 and accounting["executed"] is False, "one proposed bootstrap")
    require(gate["mode"] == "STOP_AFTER_A_PROVIDER_PROOF_UNESTABLISHED" and gate["B_launch_enabled"] is False, "closed provider gate")
    require(sum(c["max_combined_output_bytes"] for c in commands) <= 512 * 1024**2, "total output ceiling")
    for c in commands:
        require(c["max_wall_seconds"] == 60 and c["executed"] is False and c["cwd"] == str(ROOT), "fixed command limits")
        env = c["environment"]
        allowed = dict(policy["controller_environment"])
        if pathlib.Path(c["argv"][0]).name.startswith("llvm-"):
            allowed["DYLD_LIBRARY_PATH"] = str(ROOT / ".toolchains/p08-serialization-decoder/prefix/lib")
        require(env == allowed, "complete fixed decoder environment")
        require(c["argv"][0] == str(ROOT / c["tool"]["path"]) and c["argv"][-1] == str(ROOT / c["input"]["path"]), "tool/input argv join")

    def verify_context(label):
        check_time()
        require(git("rev-parse", "HEAD").decode().strip() == pins["commit"], "final reviewed HEAD drift")
        require(PACKET.resolve() == PACKET and {p.name for p in PACKET.iterdir()} == set(packet_bytes), "packet membership drift")
        for filename, data in packet_bytes.items():
            check_time()
            path = PACKET / filename
            require(not path.is_symlink() and path.is_file() and path.read_bytes() == data, "packet byte drift: " + filename)
        for path_name, row in context["files"].items():
            check_time()
            path = pathlib.Path(path_name)
            require(path.is_file() and str(path.resolve(strict=True)) == row["resolved"], "input alias drift: " + path_name)
            require(path.is_symlink() == row["is_symlink"], "input file-kind drift: " + path_name)
            if row["is_symlink"]:
                require(os.readlink(path) == row["target"], "input symlink target drift")
            require(path.stat().st_size == row["bytes"] and digest(path) == row["sha256"], "input bytes drift: " + path_name)
        for path_name in context["absent_paths"]:
            require(not os.path.lexists(path_name), "previously absent input now present: " + path_name)
        for root_name, expected in read_packet("loader-roots.json").items():
            root = pathlib.Path(root_name)
            require(root.resolve() == root and root.is_dir(), "loader root alias/missing")
            actual = {}
            for directory, dirs, files in os.walk(root, followlinks=False):
                for basename in dirs + files:
                    check_time()
                    path = pathlib.Path(directory) / basename
                    relative = str(path.relative_to(root))
                    if path.is_symlink():
                        actual[relative] = {"kind": "symlink", "target": os.readlink(path)}
                    elif path.is_dir():
                        actual[relative] = {"kind": "directory"}
                    else:
                        require(path.is_file(), "nonregular loader input")
                        actual[relative] = {"kind": "file", "bytes": path.stat().st_size, "sha256": digest(path)}
            require(actual == expected, "complete loader tree drift: " + root_name)
        for path_name, row in read_packet("loader-aliases.json").items():
            path = pathlib.Path(path_name)
            require(path.is_symlink() and os.readlink(path) == row["target"] and str(path.resolve(strict=True)) == row["resolved"], "loader alias drift")
            require(path.is_dir() if row["kind"] == "directory" else path.is_file(), "loader endpoint kind drift")
            if row["kind"] == "file" and not row["system_trust"]:
                require(path.stat().st_size == row["bytes"] and digest(path) == row["sha256"], "loader endpoint byte drift")
        for root in ("/usr/lib", "/System/Library/Frameworks"):
            require(pathlib.Path(root).is_dir(), "installed system trust root missing")
        cache = ROOT / "scripts/contracts/__pycache__"
        require({str(p) for p in cache.rglob("*") if p.is_file()} == set(context["cache_file_sha256"]), "preexisting cache membership drift")
        check_time()
        write_once(label + "-authentication.json", {"passed": True, "monotonic": time.monotonic(),
            "direct_files": len(context["files"]), "loader_roots": len(policy["loader_roots"]), "all_source_dirty_cache_hashes_checked": True})

    def capture(c):
        nonlocal process, received_total, retained_total
        label = c["id"]
        verify_context(label)
        check_time()
        write_once(label + ".claim.json", {"command": c, "authentication": label + "-authentication.json",
            "monotonic": time.monotonic(), "aggregate_deadline": deadline})
        stdout_path = OUT / (label + ".stdout")
        stderr_path = OUT / (label + ".stderr")
        stdout = stdout_path.open("xb", buffering=0)
        stderr = stderr_path.open("xb", buffering=0)
        selector = selectors.DefaultSelector()
        observed = 0
        retained = 0
        condition = None
        spawned_at = None
        actual_exit = None
        receipt_error = None
        try:
            check_time()
            spawned_at = time.monotonic()
            command_deadline = min(deadline, spawned_at + 60)
            process = subprocess.Popen(c["argv"], cwd=ROOT, env=c["environment"],
                stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                start_new_session=True, close_fds=True)
            write_once(label + ".start.json", {"pid": process.pid, "pgid": process.pid,
                "monotonic": spawned_at, "command_deadline": command_deadline, "aggregate_deadline": deadline})
            for pipe, target in ((process.stdout, stdout), (process.stderr, stderr)):
                os.set_blocking(pipe.fileno(), False)
                selector.register(pipe, selectors.EVENT_READ, target)
            exit_seen_at = None
            while selector.get_map():
                now = time.monotonic()
                if now >= command_deadline:
                    condition = "aggregate_timeout" if now >= deadline else "command_timeout"
                    kill_group()
                    break
                if process.poll() is not None:
                    if exit_seen_at is None:
                        exit_seen_at = now
                        kill_group()  # No descendant may retain inherited output pipes.
                    elif now - exit_seen_at >= 0.5:
                        condition = "output_pipe_not_closed_after_actual_exit"
                        break
                for key, event in selector.select(min(0.1, command_deadline - now)):
                    try:
                        data = os.read(key.fileobj.fileno(), 65536)
                    except BlockingIOError:
                        continue
                    if not data:
                        selector.unregister(key.fileobj)
                        key.fileobj.close()
                        continue
                    observed += len(data)
                    received_total += len(data)
                    available = min(c["max_combined_output_bytes"] - retained, 512 * 1024**2 - retained_total)
                    keep = data[:max(0, available)]
                    if keep:
                        pending = memoryview(keep)
                        while pending:
                            written = key.data.write(pending)
                            require(written is not None and written > 0, "raw stream short write")
                            retained += written
                            retained_total += written
                            pending = pending[written:]
                    if len(keep) != len(data):
                        condition = "output_cap"
                        kill_group()
                        break
                if condition:
                    break
            if not condition and process.poll() is None:
                try:
                    process.wait(timeout=max(0.001, command_deadline - time.monotonic()))
                except subprocess.TimeoutExpired:
                    condition = "command_or_aggregate_timeout"
                    kill_group()
        except BaseException as error:
            condition = condition or "capture_exception"
            receipt_error = type(error).__name__ + ": " + str(error)
            kill_group()
        finally:
            previous_mask = signal.pthread_sigmask(signal.SIG_BLOCK, {signal.SIGALRM, signal.SIGINT, signal.SIGTERM, signal.SIGHUP})
            # Cleanup/receipt persistence has a separate finite 2-second reap;
            # no decoder is allowed to continue past its deadline/cap.
            if process is not None:
                if process.poll() is None or condition:
                    kill_group()
                try:
                    actual_exit = process.wait(timeout=2)
                except subprocess.TimeoutExpired:
                    condition = "unreaped_after_kill"
                kill_group()
                for pipe in (process.stdout, process.stderr):
                    if pipe is not None and not pipe.closed:
                        pipe.close()
            selector.close()
            for stream in (stdout, stderr):
                stream.flush()
                os.fsync(stream.fileno())
                stream.close()
            # Hash raw prefixes without a deadline exception so actual-exit
            # evidence survives an expired attempt. Work cannot resume here.
            raw = {}
            for path in (stdout_path, stderr_path):
                value = hashlib.sha256()
                with path.open("rb") as stream:
                    for block in iter(lambda: stream.read(1024 * 1024), b""):
                        value.update(block)
                raw[path.name] = {"bytes": path.stat().st_size, "sha256": value.hexdigest()}
            row = {"id": label, "stage": c["stage"], "actual_exit": actual_exit,
                "spawned": spawned_at is not None and process is not None,
                "condition": condition, "exception": receipt_error, "raw": raw,
                "bytes_observed": observed, "bytes_retained": retained,
                "raw_truncated_or_incomplete": condition is not None,
                "finished_monotonic": time.monotonic(), "passed_capture_only": actual_exit == 0 and condition is None}
            write_once(label + ".exit.json", row)
            outcomes.append(row)
            process = None
            signal.pthread_sigmask(signal.SIG_SETMASK, previous_mask)
        require(row["passed_capture_only"], "capture_failure:" + label)
        check_time()
        required_tokens = {
            "counter-metadata": ["LC_LOAD_DYLIB", "libswiftCore.dylib", "ARM64", "swift_getTypeByMangledNameInContext2"],
            "counter-symbols": ["_$s6GiftUI11BoundedTextV8withUTF8yxxSRys5UInt8VGKXEKlF", "swift_getTypeByMangledNameInContext2"],
            "counter-body-data": ["$s6GiftUI11BoundedTextV8withUTF8yxxSRys5UInt8VGKXEKlF", "p08B5Route"],
        }[label]
        missing = {token.encode() for token in required_tokens}
        overlap = b""
        with stdout_path.open("rb") as stream:
            for block in iter(lambda: stream.read(1024 * 1024), b""):
                check_time()
                data = overlap + block
                missing = {token for token in missing if token not in data}
                overlap = data[-512:]
        write_once(label + ".record-check.json", {"minimum_raw_records_present": not missing,
            "missing_tokens": sorted(token.decode() for token in missing), "semantic_provider_proof": False})
        require(not missing, "missing_required_raw_records:" + label)
        check_time()

    try:
        require(OUT.parent.resolve() == OUT.parent and OUT.parent.is_dir(), "canonical existing output parent")
        os.mkdir(OUT, 0o700)  # Atomic duplicate/resume refusal; never removed.
        owns_output = True
        write_once("attempt-consumed.json", {"attempts_consumed": 1, "repairs": 0, "retries": 0,
            "external_pins": pins, "started_monotonic": started, "aggregate_deadline": deadline,
            "marker_identity": [OUT.stat().st_dev, OUT.stat().st_ino],
            "historical_collection_marker_untouched": True})
        verify_context("prelaunch")
        for command in commands[:3]:
            capture(command)
        check_time()
        write_once("provider-gate.json", {"verdict": "STOP_provider_proof_unestablished",
            "policy": gate, "A_raw_receipts": [row["id"] + ".exit.json" for row in outcomes],
            "B_authorized": False, "monotonic": time.monotonic(),
            "reason": "No reviewed exact linked/provider verifier or authenticated provider proof exists. Raw symbol/name/version matches cannot release B."})
        check_time()
        reason = "STOP_provider_proof_unestablished"
    except BaseException as error:
        kill_group()
        reason = "STOP_" + type(error).__name__ + ":" + str(error)
    finally:
        # After work stops, persist actual outcomes/skips even if deadline expired.
        signal.setitimer(signal.ITIMER_REAL, 0)
        if owns_output:
            completed = {row["id"] for row in outcomes}
            for c in commands:
                if c["id"] not in completed:
                    write_once(c["id"] + ".exit.json", {"id": c["id"], "stage": c["stage"],
                        "status": "skipped", "actual_exit": None, "spawned": False, "reason": reason})
            write_once("terminal.json", {"status": reason, "attempts_consumed": 1, "repairs": 0, "retries": 0,
                "decoder_commands_spawned": sum(row["spawned"] for row in outcomes),
                "bytes_observed": received_total, "bytes_retained": retained_total,
                "elapsed_seconds_including_authentication_and_gate": time.monotonic() - started,
                "aggregate_work_deadline_seconds": 360, "outcomes": outcomes,
                "B_commands_skipped": True, "current_callee_pass": False,
                "strict_cold_eligible": False, "p08_closed": False, "r07_closed": False, "t8_1_closed": False})
    return 1
