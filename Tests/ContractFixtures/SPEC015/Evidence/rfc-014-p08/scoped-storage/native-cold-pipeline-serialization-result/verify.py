#!/usr/bin/env python3
"""Offline verification only: no decoder, compiler, cache or workload execution."""

import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

sys.dont_write_bytecode = True
from interpret import interpret

HERE = Path(__file__).resolve().parent
ROOT = next(p for p in HERE.parents if (p / ".git").exists())
record = json.loads((HERE / "result.json").read_text())
sha = lambda data: hashlib.sha256(data).hexdigest()
archive = HERE / "evidence.tar.gz"
assert sha(archive.read_bytes()) == record["archive_sha256"]
with tarfile.open(archive) as tar:
    data = {m.name: tar.extractfile(m).read() for m in tar.getmembers()}
assert {name: sha(value) for name, value in data.items()} == record["archive_members_sha256"]
module = data["decode/P08CounterPresentation.swiftmodule"]
assert len(module) == 44856 and sha(module) == record["module_sha256"]
result = interpret(data["decode/decode.stdout"].decode(), module)
assert result == json.loads((HERE / "interpretation.json").read_text())
assert result["metadata_version"] == [0, 1003]
index = result["complete_function_index"]
assert sum("0B6ScreenV15_giftUITraverse" in row["name"] for row in index) == 1
assert sum("0B6ScreenV15_giftUIEvaluate" in row["name"] for row in index) == 1
decode = json.loads(data["decode/decode-result.json"])
assert decode["exit"] == 0 and decode["input_unchanged"] and not decode["stderr"]
assert record["decode_count"] == 1 and record["corrective_cycles_used"] == 1
assert not record["consumer_recompiled"] and not record["corrective2_started"]
assert "1003;" in data["schema/ModuleFormat.h"].decode()
assert "SIL_LINKAGE_PUBLIC_EXTERNAL" in data["schema/SILFormat.h"].decode()
assert b"if (!funcAccess.isPublic())" in data["schema/DeclContext.cpp"]
assert b"access = std::min(access, enclosingAccess)" in data["schema/Decl.cpp"]
for name, expected in record.get("derived_files_sha256", {}).items():
    assert sha((HERE / name).read_bytes()) == expected, name
previous = json.loads((HERE.parent / "native-cold-pipeline-correction1-result/manifest.json").read_text())
for path, expected in previous["external_files_sha256"].items():
    assert sha((ROOT / path).read_bytes()) == expected, path
assert sha(subprocess.check_output(["git", "diff", "--", *sorted(previous["external_files_sha256"])],
                                   cwd=ROOT)) == previous["external_diff_sha256"]
print(json.dumps({"archive_members": len(data), "complete_function_index_entries": len(index),
                  "traversal": "ID26 / Function28 / bit167594: body absent",
                  "evaluate": "ID30 / Function27: body absent",
                  "control": "ID24 / Function3: body present", "decode_count": 1,
                  "corrective_cycles_used": 1}, indent=2))
