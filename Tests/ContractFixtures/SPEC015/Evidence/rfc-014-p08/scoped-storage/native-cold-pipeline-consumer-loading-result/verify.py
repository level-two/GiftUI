#!/usr/bin/env python3
"""Verify the frozen loading diagnostic and unexecuted observer recipe offline."""

import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = next(p for p in HERE.parents if (p / ".git").exists())
record = json.loads((HERE / "result.json").read_text())


def sha(data):
    return hashlib.sha256(data).hexdigest()


archive = HERE / "diagnostic.tar.gz"
assert sha(archive.read_bytes()) == record["archive_sha256"]
with tarfile.open(archive) as tar:
    data = {m.name: tar.extractfile(m).read() for m in tar.getmembers()}
assert {name: sha(value) for name, value in data.items()} == record["archive_members_sha256"]
run = json.loads(data["consumer/result.json"])
assert run["exit"] == 0 and run["cache_before"] == run["cache_after"]
argv = json.loads(data["consumer/command.json"])
assert "-emit-loaded-module-trace-path" not in argv
assert all(flag in argv for flag in ("-Rmodule-loading", "-Rmacro-loading", "-Rmodule-serialization"))
assert all(flag in argv for flag in ("-Osize", "-whole-module-optimization"))
provider_module = data["provider-prior-pass/P08CounterPresentation.swiftmodule"]
assert sha(provider_module) == "aa24dafcd48c8dc1079bae766633e723f980767af04240b7f11bd4b125e71439"
physical = {row["name"]: row for row in record["loaded_modules"]}
stderr = data["consumer/stderr.log"].decode()
for name in ("P08CounterPresentation", "P08CounterSchema", "GiftUI", "GiftUISemanticCore", "GiftUIObservableState"):
    path = physical[name]["loaded"]
    assert "/p08-native-cold-correction1-codegen/" in path
    assert "loaded module '" + name + "'" in stderr and "loaded: '" + path + "'" in stderr
assert physical["P08CounterPresentation"]["sha256"] == sha(provider_module)
expansion = data["provider-prior-pass/stderr.log"].decode()
assert "@inlinable\n@inline(__always)\npackage func _giftUITraverse" in expansion
sil = data["consumer/P08CounterRuntime.sil"].decode()
assert sil.count("// function_ref CounterScreen._giftUITraverse<A>(_:)") == 2
assert "apply %808<CounterDomain, SemanticExpansionTraversal" in sil

next_argv = json.loads((HERE / "next-observer-command.json").read_text())
expected = list(argv)
out = ROOT / record["next_observer"]["output_directory"]
for flag, name in (("-emit-module-path", "P08CounterRuntime-probe.swiftmodule"), ("-o", "P08CounterRuntime.sil")):
    expected[expected.index(flag) + 1] = str(out / name)
expected += ["-Xllvm", "-sil-print-all", "-Xllvm", "-sil-print-functions=0B6ScreenV15_giftUITraverse",
             "-Xllvm", "-sil-print-pass-name"]
assert next_argv == expected
help_text = data["inspection/llvm-help-with-null.stdout"].decode()
assert all("--" + term in help_text for term in ("sil-print-all", "sil-print-functions=", "sil-print-pass-name"))
assert json.loads(data["inspection/llvm-help-with-null-command.json"])["exit"] == 0
assert not record["corrective2_started"] and record["corrective_cycles_used"] == 1

previous = json.loads((HERE.parent / "native-cold-pipeline-correction1-result/manifest.json").read_text())
for path, expected_hash in previous["external_files_sha256"].items():
    assert sha((ROOT / path).read_bytes()) == expected_hash, path
assert sha(subprocess.check_output(["git", "diff", "--", *sorted(previous["external_files_sha256"])],
                                   cwd=ROOT)) == previous["external_diff_sha256"]
print(json.dumps({"archive_members": len(data), "physical_fresh_imports": "verified",
                  "original_cache": "unchanged", "surviving_generic_applies": 2,
                  "body_serialization_reason": "unresolved", "next_observer_argv": "verified",
                  "corrective_cycles_used": 1}, indent=2))
