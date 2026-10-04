"""Validate the follow-up research record without asserting production conformance."""
from pathlib import Path
import ast
import gzip
import hashlib
import json
import re
import subprocess

root = Path.cwd()
review = root / "docs/iterations/iteration-002-review"
validation_path = review / "evidence/17-document-validation.json"
changed = subprocess.check_output(["git", "diff", "c8bf4560", "--name-only"], text=True).splitlines()
changed += subprocess.check_output(["git", "ls-files", "--others", "--exclude-standard"], text=True).splitlines()
markdown = sorted({root / p for p in changed if p.endswith(".md")})
links = 0
for path in markdown:
    for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", path.read_text()):
        if "://" in target or target.startswith("#"):
            continue
        relative = target.strip("<>").split("#")[0]
        destination = (path.parent / relative).resolve()
        if destination != validation_path:
            assert destination.exists(), (path, target)
        links += 1
python_paths = sorted(review.glob("*.py")) + [root / "experiments/spike-009-nrf-hierarchy-roles/run.py"]
for path in python_paths:
    ast.parse(path.read_text(), filename=str(path))
json_paths = sorted(review.glob("evidence/1[3-6]-*.json")) + sorted(
    (root / "experiments/spike-009-nrf-hierarchy-roles/evidence").glob("*.json"))
for path in json_paths:
    json.loads(path.read_text())
hash_bytes = lambda data: hashlib.sha256(data).hexdigest()
elfs = []
for path in [review / f"evidence/{step}-{name}-elf.json" for step, name in
             ((13, "startup-text"), (14, "retention"), (15, "file-selection"))] + [
             root / "experiments/spike-009-nrf-hierarchy-roles/evidence/elf-comparison.json"]:
    for name, image in json.loads(path.read_text())["images"].items():
        assert hash_bytes((root / image["elf"]).read_bytes()) == image["sha256"]
        elfs.append(image["elf"])
spike = root / "experiments/spike-009-nrf-hierarchy-roles/evidence"
result = json.loads((spike / "result.json").read_text())
transcript = gzip.decompress((spike / "semantic-transcript.txt.gz").read_bytes())
for side in result["native"].values():
    assert hash_bytes(transcript) == side["transcript_sha256"] and len(transcript) == side["bytes"]
for path, value in result["inputs"].items():
    assert hash_bytes((root / path).read_bytes()) == value, path
maintained = subprocess.check_output(["git", "diff", "6cf31f26", "--name-only", "--",
                                     "Sources", "Tests", "firmware", "scripts", "Package.swift", "demo",
                                     ".agents", "skills"], text=True).splitlines()
assert not maintained, maintained
subprocess.run(["git", "diff", "--check"], check=True)
subprocess.run(["bash", "-n", str(review / "build-research-firmware.sh")], check=True)
archive = review / "evidence/11-validation-logs.tar.gz"
assert hash_bytes(archive.read_bytes()) == "b97efdfec757fdeaed82e542a12edde021fa47b49f16d9ea156c36857a1c60d8"
record = {"head_before_reconciliation_commit": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
          "markdown_files_checked": len(markdown), "local_links_checked": links,
          "python_scripts_parsed": len(python_paths), "json_files_parsed": len(json_paths),
          "elf_identities_verified": len(elfs), "spike_transcript_bytes_verified": len(transcript),
          "spike_input_hashes_verified": len(result["inputs"]), "production_gate_archive_unchanged": True,
          "maintained_inputs_unchanged_from_initial_snapshot": True, "whitespace_and_shell_syntax": "passed",
          "governance": (root / ".build/iteration-002-audit/followup-governance.log").read_text().strip(),
          "formatter": (root / ".build/iteration-002-audit/followup-format.log").read_text().strip(),
          "research_log_hashes": {},
          "limitations": "Documentation/provenance and isolated hardware-free experiments; no new universal conformance, approval or connected proof"}
assert "validation passed" in record["governance"]
for name in ("startup-text-research", "startup-text-firmware", "startup-text-tests", "retention-candidate",
             "retention-firmware", "file-selection-native", "file-selection-firmware",
             "hierarchy-roles-native", "hierarchy-roles-firmware"):
    path = root / f".build/iteration-002-audit/{name}.log"
    record["research_log_hashes"][str(path.relative_to(root))] = hash_bytes(path.read_bytes())
validation_path.write_text(json.dumps(record, indent=2) + "\n")
assert validation_path.exists()
print(json.dumps({key: value for key, value in record.items() if key not in ("research_log_hashes",)}, indent=2))
