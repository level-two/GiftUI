"""Verify reopened research provenance without claiming product conformance."""
from pathlib import Path
import ast
import gzip
import hashlib
import json
import re
import subprocess

root = Path.cwd()
review = root / "docs/iterations/iteration-002-review"
validation = review / "evidence/21-document-validation.json"
sha = lambda data: hashlib.sha256(data).hexdigest()
changed = subprocess.check_output(["git", "diff", "09424b14", "--name-only"], text=True).splitlines()
changed += subprocess.check_output(["git", "ls-files", "--others", "--exclude-standard"], text=True).splitlines()
markdown = sorted({root / path for path in changed if path.endswith(".md")})
links = 0
for path in markdown:
    for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", path.read_text()):
        if "://" in target or target.startswith("#"):
            continue
        destination = (path.parent / target.strip("<>").split("#")[0]).resolve()
        assert destination == validation or destination.exists(), (path, target)
        links += 1
python_paths = sorted(review.glob("*.py"))
json_paths = []
input_count = 0
transcript_count = 0
elf_count = 0
for name in ("spike-009-nrf-hierarchy-roles", "spike-010-bounded-declaration-traversal", "spike-011-clean-topology-generation"):
    spike = root / "experiments" / name
    python_paths.extend(sorted(spike.glob("*.py")))
    json_paths.extend(sorted(spike.glob("evidence/*.json")))
    result = json.loads((spike / "evidence/result.json").read_text())
    for path, expected in result["inputs"].items():
        assert sha((root / path).read_bytes()) == expected, path
        input_count += 1
    for path, expected in result.get("native_owner_objects", result.get("native_object_hashes", {})).items():
        assert sha((root / path).read_bytes()) == expected, path
        input_count += 1
    transcript_path = spike / "evidence/semantic-transcript.txt.gz"
    if transcript_path.exists():
        transcript = gzip.decompress(transcript_path.read_bytes())
        for side in result["native"].values():
            assert sha(transcript) == side["transcript_sha256"] and len(transcript) == side["bytes"]
        transcript_count += 1
    else:
        assert result["native_run"]["exit_code"] == 0 and result["embedded_compile"]["exit_code"] == 0
        object_path = root / ".build/nrf52840/spike-010-bounded-declaration-traversal/LoweredBody.o"
        assert sha(object_path.read_bytes()) == result["embedded_object_sha256"]
    comparison = json.loads((spike / "evidence/elf-comparison.json").read_text())
    for image in comparison["images"].values():
        assert sha((root / image["elf"]).read_bytes()) == image["sha256"]
        elf_count += 1
stack = json.loads((review / "evidence/20-static-stack-inspection.json").read_text())
for image in stack["images"].values():
    assert sha((root / image["elf"]).read_bytes()) == image["sha256"]
probe = stack["compiler_stack_section_probe"]
assert sha((root / probe["object"]).read_bytes()) == probe["sha256"]
json_paths += [review / "evidence/20-static-stack-inspection.json", root / "experiments/spike-011-clean-topology-generation/policy.json"]
for path in json_paths:
    json.loads(path.read_text())
for path in python_paths:
    ast.parse(path.read_text(), filename=str(path))
maintained = subprocess.check_output(["git", "diff", "6cf31f26", "--name-only", "--",
    "Sources", "Tests", "firmware", "scripts", "Package.swift", "demo", ".agents", "skills"], text=True).splitlines()
assert not maintained, maintained
subprocess.run(["git", "diff", "--check"], check=True)
subprocess.run(["bash", "-n", str(review / "build-research-firmware.sh")], check=True)
assert sha((review / "evidence/11-validation-logs.tar.gz").read_bytes()) == "b97efdfec757fdeaed82e542a12edde021fa47b49f16d9ea156c36857a1c60d8"
logs = {}
for path in [root / ".build/nrf52840" / name for name in
             ("iteration-002-research-doctor.txt", "spike-010-run.txt", "spike-010-build.txt", "spike-011-run.txt", "spike-011-build.txt")] + [
             root / ".build/iteration-002-audit/reopened-format.log", root / ".build/iteration-002-audit/reopened-governance.log"]:
    logs[str(path.relative_to(root))] = sha(path.read_bytes())
governance = (root / ".build/iteration-002-audit/reopened-governance.log").read_text().strip()
assert "validation passed" in governance
record = {"head_before_closeout_commit": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
    "markdown_files_checked": len(markdown), "local_links_checked": links, "python_scripts_parsed": len(python_paths),
    "json_files_parsed": len(json_paths), "input_and_native_object_hashes_verified": input_count,
    "compressed_semantic_transcripts_verified": transcript_count, "paired_elf_hashes_verified": elf_count,
    "stack_elf_and_object_hashes_verified": True, "maintained_inputs_unchanged_from_initial_snapshot": True,
    "production_gate_archive_unchanged": True, "whitespace_and_shell_syntax": "passed", "governance": governance,
    "formatter": "scripts/format-swift.sh completed with exit 0 before this verification; no maintained edits",
    "formatter_log": (root / ".build/iteration-002-audit/reopened-format.log").read_text().strip(), "log_hashes": logs,
    "limitations": "Bounded disposable hardware-free research. No production remediation, scope approval, universal conformance, whole-stack bound or connected evidence claimed."}
validation.write_text(json.dumps(record, indent=2) + "\n")
print(json.dumps({key: value for key, value in record.items() if key != "log_hashes"}, indent=2))
