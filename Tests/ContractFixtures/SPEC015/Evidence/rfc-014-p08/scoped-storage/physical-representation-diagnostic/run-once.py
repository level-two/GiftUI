#!/usr/bin/env python3
"""One diagnostic module compilation; no linking, execution or repair loop."""
import datetime, hashlib, json, pathlib, subprocess
packet = pathlib.Path(__file__).resolve().parent
prepared = json.loads((packet / "prepared.json").read_text())
sha = lambda p: hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
assert sha(packet / "compile.argv.json") == prepared["compile_argv_sha256"]
assert sha(packet / "accessors.swift.txt") == prepared["accessors_sha256"]
assert sha(packet / "roots.json") == prepared["roots_sha256"]
for path, expected in prepared["pinned_inputs"].items():
    assert sha(path) == expected, "pinned input drift: " + path
scratch = pathlib.Path(prepared["scratch"])
marker = scratch / "invocation-started.json"
assert not marker.exists(), "one invocation already started; no automatic retry"
argv = json.loads((packet / "compile.argv.json").read_text())
started = datetime.datetime.now(datetime.timezone.utc).isoformat()
marker.write_text(json.dumps(dict(started=started, argv=argv), indent=2) + "\n")
with (scratch / "stdout.log").open("wb") as out, (scratch / "stderr.log").open("wb") as err:
    result = subprocess.run(argv, stdout=out, stderr=err, check=False)
artifacts = {str(p): dict(sha256=sha(p), bytes=p.stat().st_size) for p in scratch.iterdir() if p.is_file()}
(scratch / "diagnostic-result.json").write_text(json.dumps(dict(
    diagnostic_only=True, acceptance_receipt=False, exit_code=result.returncode,
    started=started, finished=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    argv_sha256=sha(packet / "compile.argv.json"), artifacts=artifacts), indent=2) + "\n")
raise SystemExit(result.returncode)
