#!/usr/bin/env python3
"""Offline failed-gate verification. No compiler, decoder or runtime execution."""

import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = next(p for p in HERE.parents if (p / ".git").exists())
record = json.loads((HERE / "result.json").read_text())
sha = lambda value: hashlib.sha256(value).hexdigest()
archive = HERE / "evidence.tar.gz"
assert sha(archive.read_bytes()) == record["archive_sha256"]
with tarfile.open(archive) as tar:
    data = {m.name: tar.extractfile(m).read() for m in tar.getmembers()}
assert {name: sha(value) for name, value in data.items()} == record["archive_members_sha256"]
log = data["diagnostic/P08CounterPresentation.log"].decode()
assert log.count(": error:") == 24
assert log.count("error: property '_model' is private") == 5
assert "visitor.visit(&_model, declarationOrdinal: 0)" in log
source = data["diagnostic/Counter.swift"].decode()
assert "private var model: _GiftUIModelKey<CounterModelSchema>?" in source
assert "@ObservableStateHost" in source and "@usableFromInline" in source
for module in ("P08CounterSchema", "P08CounterPresentation"):
    command = json.loads(data["diagnostic/" + module + "-command.json"])
    assert all(flag in command for flag in ("-Osize", "-whole-module-optimization", "-enable-testing"))
    assert any("/p08-native-cold-correction2-codegen/" in arg and arg.endswith(".swift") for arg in command)
    assert "p08-native-cold-correction2-codegen/macro/GiftUIMacros-tool#GiftUIMacros" in command[
        command.index("-load-plugin-executable") + 1]
assert "diagnostic/P08CounterSchema.swiftmodule" in data
assert "diagnostic/P08CounterPresentation.swiftmodule" not in data
assert record["corrective_cycles_used"] == record["corrective_cycle_limit"] == 2
assert not record["third_candidate_authorized"] and not record["runtime_run"]
for path, expected in record["external_files_sha256"].items():
    assert sha((ROOT / path).read_bytes()) == expected, path
assert sha(subprocess.check_output(["git", "diff", "--", *sorted(record["external_files_sha256"])],
                                   cwd=ROOT)) == record["external_diff_sha256"]
for name, expected in record.get("derived_files_sha256", {}).items():
    assert sha((HERE / name).read_bytes()) == expected, name
print(json.dumps({"archive_members": len(data), "private_state_errors": 5,
                  "result": "presentation compile/privacy FAIL; unaccepted",
                  "corrective_cycles_used": 2, "runtime_run": False}, indent=2))
