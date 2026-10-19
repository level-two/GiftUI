"""Build pinned controller input/accounting records without importing/running it."""
import hashlib
import json
import os
import pathlib

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[6]
files = {}
absent = set()

def add(path, expected):
    path = pathlib.Path(path)
    if not path.is_absolute():
        path = ROOT / path
    data = path.read_bytes()
    actual = hashlib.sha256(data).hexdigest()
    assert actual == expected, str(path)
    row = {"sha256": actual, "bytes": len(data), "resolved": str(path.resolve(strict=True)), "is_symlink": path.is_symlink()}
    if path.is_symlink():
        row["target"] = os.readlink(path)
    if str(path) in files:
        assert files[str(path)] == row
    files[str(path)] = row

def walk(value):
    if isinstance(value, dict):
        if isinstance(value.get("path"), str):
            path = pathlib.Path(value["path"])
            if not path.is_absolute():
                path = ROOT / path
            if "sha256" in value:
                add(path, value["sha256"])
            elif value.get("exists") is False:
                assert not os.path.lexists(path)
                absent.add(str(path))
        for item in value.values():
            walk(item)
    elif isinstance(value, list):
        for item in value:
            walk(item)

inventory = json.loads((HERE / "inventory.json").read_text())
walk(inventory)
prior = json.loads((HERE.parent / "current-callee-u01-attribution1-result/inspection.json").read_text())
for name, row in prior["frozen_files"].items():
    add(name, row["sha256"])
preparation = HERE.parent / "current-callee-readiness1-preparation"
for row in json.loads((preparation / "source42.json").read_text()):
    add(row["path"], row["sha256"])
for name, expected in json.loads((preparation / "preserved-dirty-files.json").read_text())["files"].items():
    add(name, expected)
cache = {}
for name, expected in prior["preexisting_cache_file_sha256"].items():
    add(name, expected)
    cache[str(ROOT / name)] = expected
for name in ("request.json", "loader-policy.json", "loader-roots.json", "loader-aliases.json"):
    path = HERE / name
    add(path, hashlib.sha256(path.read_bytes()).hexdigest())
context = {"files": files, "absent_paths": sorted(absent), "cache_file_sha256": cache,
    "scope": "Frozen prior evidence, exact retained linked/object/runtime/tool/source inputs, preservation files/cache, complete loader trees and aliases. No producer code imported or executed."}
gate = {"mode": "STOP_AFTER_A_PROVIDER_PROOF_UNESTABLISHED", "B_launch_enabled": False,
    "reason": "No reviewed exact linked/provider verifier or authenticated applicable provider proof exists before this attempt. A raw captures are necessary evidence, not a release certificate.",
    "permitted_A_commands": ["counter-metadata", "counter-symbols", "counter-body-data"],
    "B_disposition": "Always record all three B commands skipped for this concrete controller; retain request's conditional B forms for later separately reviewed/authorized work only.",
    "future_gate_change": "New reviewed proof/verifier and external final pins plus separately explicit allowance required; never edit gate data during an active attempt."}
accounting = {"executed": False, "controller_bootstrap_launches_proposed": 1, "controller_bootstrap_launches_used": 0,
    "concrete_decoder_commands_max": 3, "request_decoder_commands_ceiling": 6, "B_launch_enabled": False,
    "attempts_proposed": 1, "attempts_used": 0, "repairs": 0, "retries": 0, "acquisitions": 0,
    "runtime_compiler_build_test_strict_cold_launches": 0,
    "aggregate_seconds_including_authentication_and_gate": 360, "per_decoder_seconds": 60,
    "maximum_retained_decoder_bytes": 512 * 1024**2,
    "historical_collection_attempts_consumed": 1,
    "boundary": "This proposes one new orchestration bootstrap only; it grants no execution and borrows/resets no historical marker or allowance. Deadline expiry stops work; only finite reaping and durable receipt persistence follow."}
for filename, value in (("controller-inputs.json", context), ("gate-policy.json", gate), ("controller-accounting.json", accounting)):
    (HERE / filename).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")
print(json.dumps({"authenticated_direct_files": len(files), "absent_paths": len(absent), "controller_launches": 0, "decoder_launches": 0, "B_launch_enabled": False}, sort_keys=True))
