#!/usr/bin/env python3
"""One source-unchanged diagnostic replay. No retry, cleanup or flag fallback."""

import datetime
import hashlib
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = next(p for p in HERE.parents if (p / ".git").exists())
assert Path.cwd() == ROOT, "Run from repository root"
record = json.loads((HERE / "result.json").read_text())
argv = json.loads((HERE / "next-observer-command.json").read_text())


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


assert sha(argv[0]) == record["compiler_sha256"]
for path, expected in record["input_source_hashes"].items():
    assert sha(ROOT / path) == expected, path
for row in record["loaded_modules"]:
    if row["sha256"] is not None:
        assert sha(row["loaded"]) == row["sha256"], row["loaded"]
plugin = argv[argv.index("-load-plugin-executable") + 1].split("#")[0]
assert sha(plugin) == record["plugin_sha256"]
sdk = Path(argv[argv.index("-sdk") + 1])
assert sha(sdk / "SDKSettings.json") == record["sdk_settings_sha256"]
cache = Path(argv[argv.index("-module-cache-path") + 1])


def inventory():
    return {str(p.relative_to(cache)): sha(p) for p in sorted(cache.rglob("*")) if p.is_file()}


before = inventory()
assert before == record["consumer_run"]["cache_after"], "Original cache changed; stop"
out = ROOT / record["next_observer"]["output_directory"]
out.mkdir(exist_ok=False)  # A second execution must stop, preserving the first.
(out / "command.json").write_text(json.dumps(argv, indent=2) + "\n")
start = datetime.datetime.now(datetime.timezone.utc)
with (out / "stdout.log").open("wb") as stdout, (out / "stderr.log").open("wb") as stderr:
    process = subprocess.run(argv, stdout=stdout, stderr=stderr)
finish = datetime.datetime.now(datetime.timezone.utc)
after = inventory()
result = {
    "exit": process.returncode,
    "started": start.isoformat(),
    "finished": finish.isoformat(),
    "elapsed_seconds": (finish - start).total_seconds(),
    "cache_before": before,
    "cache_after": after,
    "cache_unchanged": before == after,
    "files": {p.name: {"bytes": p.stat().st_size, "sha256": sha(p)}
              for p in sorted(out.iterdir()) if p.is_file()},
    "corrective_cycles_used": 1,
    "runtime_executed": False,
}
(out / "result.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
raise SystemExit(process.returncode if before == after else 2)
