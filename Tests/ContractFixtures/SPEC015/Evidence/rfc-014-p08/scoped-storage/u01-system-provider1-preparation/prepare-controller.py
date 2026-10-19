"""Read/hash existing inputs and write controller-inputs.json only; no launches."""
import hashlib
import json
import os
import pathlib

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[6]
OLD = HERE.parent / "current-callee-u01-residual1-preparation"


def digest(path):
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


def row(path):
    path = pathlib.Path(path)
    result = {"bytes": path.stat().st_size, "sha256": digest(path),
        "resolved": str(path.resolve(strict=True)), "is_symlink": path.is_symlink()}
    if path.is_symlink():
        result["target"] = os.readlink(path)
    return result

context = json.loads((OLD / "controller-inputs.json").read_text())
for name, expected in context["files"].items():
    assert row(name) == expected, "prior input drift: " + name
inventory = json.loads((HERE / "inventory.json").read_text())
extra = inventory["prior_linked_evidence"] + inventory["cache_family"] + [inventory[key] for key in
    ("historical_supplemental_report", "historical_negative_artifact", "historical_negative_log", "current_OS", "tool", "tool_manual")]
extra += [r for r in inventory["virtual_system_images"] if r["exists"]]
for value in extra:
    actual = row(value["path"])
    assert actual["bytes"] == value["bytes"] and actual["sha256"] == value["sha256"], "inventoried input drift"
    context["files"][value["path"]] = actual
context["loader_manifests"] = {name: str(OLD / (name + ".json")) for name in ("loader-policy", "loader-roots", "loader-aliases")}
for name in ("controller-inputs.json", "loader-policy.json", "loader-roots.json", "loader-aliases.json"):
    context["files"][str(OLD / name)] = row(OLD / name)
for name in ("independent-review.md", "independent-review-inspection.json"):
    # New packet review bytes are independently authenticated by its complete Git tree.
    assert (HERE / name).is_file()
context["cache_root"] = str(pathlib.Path(inventory["cache_membership"][0]).parent)
context["cache_membership"] = inventory["cache_membership"]
context["cache_prefix"] = "dyld_shared_cache_arm64e"
context["cache_root_resolved"] = str(pathlib.Path(context["cache_root"]).resolve(strict=True))
context["consumed_markers"] = {str(ROOT / ".build/contracts" / key): value for key,value in inventory["consumed_markers_unchanged"].items()}
context["absent_paths"] = sorted(set(context["absent_paths"]) | {str(ROOT / ".build/contracts/p08-u01-system-provider-static1")})
# The output path becomes present after the atomic claim; it is checked separately.
context["absent_paths"].remove(str(ROOT / ".build/contracts/p08-u01-system-provider-static1"))
for value in inventory["system_ABI_source_candidates"]:
    if not value["exists"]:
        context["absent_paths"].append(value["path"])
context["absent_paths"] = sorted(set(context["absent_paths"]))
for name, expected in context["cache_file_sha256"].items():
    assert digest(pathlib.Path(name)) == expected
for name, expected in context["consumed_markers"].items():
    stat = pathlib.Path(name).stat()
    assert [stat.st_dev,stat.st_ino] == expected
assert not (ROOT / ".build/contracts/p08-u01-system-provider-static1").exists()
(HERE / "controller-inputs.json").write_text(json.dumps(context, indent=2,sort_keys=True) + "\n")
print(json.dumps({"direct_files":len(context["files"]),"cache_members":len(context["cache_membership"]),"tools_launched":0}))
