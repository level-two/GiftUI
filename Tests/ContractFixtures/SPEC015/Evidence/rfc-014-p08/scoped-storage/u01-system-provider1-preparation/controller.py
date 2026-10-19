"""Prepared I-only capture; cache schema unestablished and S always skipped; not executed."""
import hashlib
import json
import os
import pathlib
import selectors
import signal
import subprocess
import time
import types

ROOT = pathlib.Path("/Users/eugene/work/GiftUI")
PACKET = ROOT / "Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/u01-system-provider1-preparation"
OUT = ROOT / ".build/contracts/p08-u01-system-provider-static1"

class Stop(Exception):
    pass

def main(pins, started, packet_bytes, git):
    deadline = started + 240
    process = None
    received_total = 0
    retained_total = 0
    receipt_total = 0
    receipt_count = 0
    total_cap = 320 * 1024**2
    receipt_reserve = 1024**2
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
        nonlocal receipt_total, receipt_count
        path = OUT / name
        payload = (json.dumps(value, indent=2, sort_keys=True) + "\n").encode()
        require(len(payload) <= 64 * 1024 and receipt_count < 24, "finite receipt shape/count cap")
        require(receipt_total + len(payload) <= receipt_reserve and
            retained_total + receipt_total + len(payload) <= total_cap, "raw_plus_receipt_cap")
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, "wb") as stream:
            stream.write(payload)
            stream.flush()
            os.fsync(stream.fileno())
        receipt_total += len(payload)
        receipt_count += 1
        sync_dir()

    def kill_group():
        if process is not None:
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass

    request = read_packet("request.json")
    context = read_packet("controller-inputs.json")
    inventory = read_packet("inventory.json")
    gate = read_packet("gate-policy.json")
    accounting = read_packet("controller-accounting.json")
    def read_manifest(name):
        path = pathlib.Path(context["loader_manifests"][name])
        row = context["files"][str(path)]
        require(path.stat().st_size == row["bytes"] and digest(path) == row["sha256"], "loader manifest drift")
        return json.loads(path.read_bytes())
    policy = read_packet("loader-policy.json")
    require(policy == read_manifest("loader-policy"), "exact externally pinned environment join")
    verifier = types.ModuleType("u01_authenticated_identity_verifier")
    exec(compile(packet_bytes["identity-verifier.py"], "<externally pinned identity verifier Git blob>", "exec"), verifier.__dict__)
    commands = request["commands"]
    require(request["output_root"] == str(OUT), "fixed output root")
    require(len(commands) == 3 and [c["stage"] for c in commands] == ["I", "S", "S"], "fixed three-command request")
    require(accounting["controller_bootstrap_launches_proposed"] == 1 and accounting["executed"] is False and
        accounting["concrete_decoder_commands_max"] == 1 and accounting["S_launch_enabled"] is False and
        accounting["aggregate_seconds_including_authentication_and_gate"] == 240 and
        accounting["maximum_retained_raw_and_receipt_bytes"] == total_cap and
        accounting["receipt_reserve_bytes"] == receipt_reserve, "fixed I-only accounting")
    require(gate["mode"] == "STOP_AFTER_I_CACHE_SCHEMA_UNESTABLISHED" and gate["S_launch_enabled"] is False, "closed schema gate")
    require([c["max_combined_output_bytes"] for c in commands] == [16 * 1024**2, 192 * 1024**2, 64 * 1024**2], "fixed output ceilings")
    tool = inventory["tool"]
    operands = [row["path"] for row in inventory["virtual_system_images"]]
    expected_argv = [tool["path"], "-arch", "arm64e", "-uuid", "-platform", "-linked_dylibs", "-exports", "-imports", "-function_starts", "-function_variants", *operands]
    require(commands[0]["id"] == "system-image-identities" and commands[0]["argv"] == expected_argv, "exact identity argv")
    for c in commands:
        require(c["max_wall_seconds"] == 60 and c["executed"] is False and c["cwd"] == str(ROOT), "fixed command limits")
        require(c["environment"] == policy["controller_environment"], "complete system-only environment")
        require(c["tool"] == tool and c["argv"][0] == tool["path"], "exact tool pin")
    require(commands[1]["argv"] == [tool["path"], "-arch", "arm64e", "-disassemble", "-all_sections_bytes", operands[0]] and
        commands[2]["argv"] == [tool["path"], "-arch", "arm64e", "-disassemble", "-all_sections_bytes", *operands[1:]], "unchanged skipped S argv")

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
            before = path.stat()
            require(before.st_size == row["bytes"] and digest(path) == row["sha256"], "input bytes drift: " + path_name)
            after = path.stat()
            require((before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns) ==
                (after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns), "input changed while hashing")
        for path_name in context["absent_paths"]:
            require(not os.path.lexists(path_name), "previously absent input now present: " + path_name)
        for root_name, expected in read_manifest("loader-roots").items():
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
        for path_name, row in read_manifest("loader-aliases").items():
            path = pathlib.Path(path_name)
            require(path.is_symlink() and os.readlink(path) == row["target"] and str(path.resolve(strict=True)) == row["resolved"], "loader alias drift")
            require(path.is_dir() if row["kind"] == "directory" else path.is_file(), "loader endpoint kind drift")
            if row["kind"] == "file" and not row["system_trust"]:
                require(path.stat().st_size == row["bytes"] and digest(path) == row["sha256"], "loader endpoint byte drift")
        for root in ("/usr/lib", "/System/Library/Frameworks"):
            require(pathlib.Path(root).is_dir(), "installed system trust root missing")
        cache = ROOT / "scripts/contracts/__pycache__"
        require({str(p) for p in cache.rglob("*") if p.is_file()} == set(context["cache_file_sha256"]), "preexisting cache membership drift")
        for name, expected in context["cache_file_sha256"].items():
            require(digest(pathlib.Path(name)) == expected, "preexisting cache content drift")
        cache_root = pathlib.Path(context["cache_root"])
        require(str(cache_root.resolve(strict=True)) == context["cache_root_resolved"], "cache root alias drift")
        require(sorted(str(p) for p in cache_root.iterdir() if p.name.startswith(context["cache_prefix"])) == context["cache_membership"], "15-member cache membership drift")
        for name, identity in context["consumed_markers"].items():
            stat = pathlib.Path(name).stat()
            require([stat.st_dev, stat.st_ino] == identity, "historical consumed marker drift")
        check_time()
        joins = verifier.verify(inventory, gate, check_time)
        require(joins["S_authorized"] is False, "S must stay closed")
        write_once(label + "-authentication.json", {"passed": True, "monotonic": time.monotonic(),
            "direct_files": len(context["files"]), "cache_members": len(context["cache_membership"]),
            "loader_roots": len(policy["loader_roots"]), "all_source_dirty_cache_hashes_checked": True,
            "identity_input_joins": joins})
        check_time()

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
                    available = min(c["max_combined_output_bytes"] - retained, total_cap - receipt_reserve - retained_total)
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
        require(stdout_path.stat().st_size > 0, "empty_identity_stdout")
        write_once(label + ".record-check.json", {"nonempty_raw_output": True,
            "actual_zero_exit": True, "semantic_provider_proof": False,
            "I_output_semantically_parsed": False, "S_authorized": False})
        check_time()

    try:
        require(OUT.parent.resolve() == OUT.parent and OUT.parent.is_dir(), "canonical existing output parent")
        os.mkdir(OUT, 0o700)  # Atomic duplicate/resume refusal; never removed.
        owns_output = True
        write_once("attempt-consumed.json", {"attempts_consumed": 1, "repairs": 0, "retries": 0,
            "external_pins": pins, "started_monotonic": started, "aggregate_deadline": deadline,
            "marker_identity": [OUT.stat().st_dev, OUT.stat().st_ino],
            "both_historical_consumed_markers_untouched": True})
        verify_context("prelaunch")
        capture(commands[0])
        check_time()
        joins = verifier.verify(inventory, gate, check_time)
        write_once("provider-gate.json", {"verdict": "STOP_cache_schema_unestablished",
            "policy": gate, "identity_input_joins": joins,
            "I_raw_receipts": [row["id"] + ".exit.json" for row in outcomes],
            "S_authorized": False, "monotonic": time.monotonic(),
            "reason": "No applicable independently justified cache-header schema exists. I output cannot release S."})
        check_time()
        reason = "STOP_cache_schema_unestablished"
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
                "bytes_observed": received_total, "raw_bytes_retained": retained_total,
                "receipt_bytes_before_terminal": receipt_total, "retained_total_before_terminal": retained_total + receipt_total,
                "maximum_retained_raw_and_receipt_bytes": total_cap,
                "elapsed_seconds_including_authentication_and_gate": time.monotonic() - started,
                "aggregate_work_deadline_seconds": 240, "outcomes": outcomes,
                "S_commands_skipped": True, "current_callee_pass": False,
                "strict_cold_eligible": False, "p08_closed": False, "r07_closed": False, "t8_1_closed": False})
    return 1
