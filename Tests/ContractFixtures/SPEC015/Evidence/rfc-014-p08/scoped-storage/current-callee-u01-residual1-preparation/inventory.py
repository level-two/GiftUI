"""U01 residual preparation: standard-library file inventory and hashing only.

No binary metadata/instruction decoding or production tool invocation occurs.
The only subprocess calls are read-only Git identity/blob reads. Writes are
limited to inventory.json and request.json beside this evidence program.
"""
import hashlib
import json
import pathlib
import plistlib
import re
import shlex
import subprocess

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[6]
PREP = HERE.parent / "current-callee-readiness1-preparation"
U01 = HERE.parent / "current-callee-u01-attribution1-result"
BASE = subprocess.check_output(["git", "rev-parse", "c91d82f9"], cwd=ROOT, text=True).strip()


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def name(path):
    return str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path)


def item(path):
    return {"path": name(path), "exists": path.exists(),
            **({"bytes": path.stat().st_size, "sha256": sha(path)} if path.is_file() else {})}


prior = json.loads((U01 / "inspection.json").read_text())
assert all(sha(ROOT / p) == v["sha256"] for p, v in prior["frozen_files"].items())
packet = {}
for p in sorted(U01.iterdir()):
    if p.is_file():
        committed = subprocess.check_output(["git", "show", f"{BASE}:{name(p)}"], cwd=ROOT)
        assert p.read_bytes() == committed
        packet[name(p)] = item(p)
sources = json.loads((PREP / "source42.json").read_text())
assert len(sources) == 42 and all(sha(ROOT / p["path"]) == p["sha256"] for p in sources)
dirty = json.loads((PREP / "preserved-dirty-files.json").read_text())["files"]
assert len(dirty) == 5 and all(sha(ROOT / p) == expected for p, expected in dirty.items())
cache = {name(p): sha(p) for p in sorted((ROOT / "scripts/contracts/__pycache__").rglob("*")) if p.is_file()}
assert cache == prior["preexisting_cache_file_sha256"]

recipe = json.loads((PREP / "collection-recipe.json").read_text())
freeze = json.loads((PREP / "input-freeze.json").read_text())
receipt = ROOT / recipe["retained_counter"]["path"]
assert sha(receipt) == recipe["retained_counter"]["sha256"]
counter = json.loads(receipt.read_text())
argv = shlex.split(counter["commands"][405])
assert argv[-2:] == ["-o", str(receipt.parent / "counter")]
objects = [pathlib.Path(p) for p in argv if p.endswith(".o")]
captured_objects = {c["command"][-1] for c in recipe["object_captures"]}
assert len(objects) == 25 and {str(p) for p in objects} == captured_objects
object_rows = []
for p in objects:
    assert sha(p) == freeze[name(p)]
    object_rows.append(item(p))
retained = []
for n in ("counter", "Main.swift", "link.log", "so06-native-exclusivity-positive", "so06-native-exclusivity-negative"):
    p = receipt.parent / n
    assert sha(p) == counter["artifacts"][n]["sha256"]
    assert p.stat().st_size == counter["artifacts"][n]["bytes"]
    retained.append(item(p) | {"matches_frozen_counter_artifact": True})

tc = ROOT / ".toolchains/host/swift-6.4.0-RELEASE-osx"
core = tc / "usr/lib/swift/macosx/libswiftCore.dylib"
interface = tc / "usr/lib/swift/macosx/Swift.swiftmodule/arm64-apple-macos.swiftinterface"
trees_path = HERE.parent / "current-callee-p02-prerequisite-candidate2/validation-result/retained-evidence-counter384-successor1-preparation/retained-trees.json"
assert sha(trees_path) == freeze[name(trees_path)]
trees = json.loads(trees_path.read_text())
payload_root = ROOT / ".toolchains/p08-comparison/expanded/swift-6.4.0-RELEASE-osx/swift-6.4.0-RELEASE-osx-package.pkg/Payload/usr/lib/swift"
payload_core = payload_root / "macosx/libswiftCore.dylib"
assert sha(core) == sha(payload_core) == trees[str(payload_root)]["macosx/libswiftCore.dylib"]["sha256"]
assert sha(interface) == trees[str(payload_root)]["macosx/Swift.swiftmodule/arm64-apple-macos.swiftinterface"]["sha256"]
sdk = pathlib.Path("/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk")
apple = pathlib.Path("/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr")
tool = apple / "bin/otool-classic"
nm = ROOT / ".toolchains/p08-serialization-decoder/prefix/bin/llvm-nm-21"
objdump = ROOT / ".toolchains/p08-serialization-decoder/prefix/bin/llvm-objdump-21"
assert sha(nm) == freeze[name(nm)] and sha(objdump) == freeze[name(objdump)]
deps = json.loads((PREP / "decoder-library-tree.json").read_text())
for rel, info in deps["entries"].items():
    p = pathlib.Path(deps["root"]) / rel
    if info["kind"] == "file":
        assert sha(p) == info["sha256"]
    elif info["kind"] == "symlink":
        assert p.is_symlink() and str(p.readlink()) == info["target"]

metadata_paths = [tc / "Info.plist", pathlib.Path("/System/Library/CoreServices/SystemVersion.plist"),
                  pathlib.Path("/Applications/Xcode.app/Contents/Info.plist"), sdk / "SDKSettings.json"]
metadata = []
for p in metadata_paths:
    v = plistlib.loads(p.read_bytes()) if p.suffix == ".plist" else json.loads(p.read_text())
    fields = {k: val for k, val in v.items()
              if any(t in k.lower() for t in ("version", "identifier", "build", "displayname", "canonicalname"))}
    metadata.append(item(p) | {"selected_fields": fields})

stubs = [sdk / "usr/lib/swift/libswiftCore.tbd", sdk / "usr/lib/libSystem.tbd",
         sdk / "usr/lib/system/libsystem_c.tbd", sdk / "usr/lib/system/libsystem_platform.tbd"]
stub_rows = []
for p in stubs:
    matches = [{"line": n, "text": line} for n, line in enumerate(p.read_text().splitlines(), 1)
               if any(x in line for x in ("_swift_getTypeByMangledNameInContext2", "_$ss5ErrorWS", "_memcpy,", "___stack_chk_fail", "___stack_chk_guard"))]
    stub_rows.append(item(p) | {"selected_symbol_text": matches, "implementation_bytes": False})

system_candidates = [pathlib.Path("/usr/lib/swift/libswiftCore.dylib"), pathlib.Path("/usr/lib/libSystem.B.dylib"),
                     pathlib.Path("/usr/lib/system/libsystem_c.dylib"), pathlib.Path("/usr/lib/system/libsystem_platform.dylib"),
                     pathlib.Path("/usr/lib/system/libsystem_kernel.dylib")]
cache_root = pathlib.Path("/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld")
cache_map = cache_root / "dyld_shared_cache_arm64e.map"
map_text = cache_map.read_text()
map_entries = []
for install in ("/usr/lib/swift/libswiftCore.dylib", "/usr/lib/system/libsystem_c.dylib", "/usr/lib/system/libsystem_platform.dylib"):
    block = re.search(r"(?m)^" + re.escape(install) + r"\n(?:\t[^\n]*\n)+", map_text)
    map_entries.append({"install_name": install, "entry": block[0] if block else None})
cache_members = [{"path": str(p), "bytes": p.stat().st_size, "hashed_or_decoded": False}
                 for p in sorted(cache_root.iterdir()) if p.name.startswith("dyld_shared_cache_arm64e") and p != cache_map]
abi_paths = [tc / "usr/include/swift/ABI/Metadata.h", tc / "usr/include/swift/Runtime/ExistentialContainer.h",
             tc / "usr/include/swift/Runtime/Metadata.h"]

launch = ROOT / ".build/contracts/p08-retained-evidence-counter384-successor1/launch.json"
launch_record = json.loads(launch.read_text())
assert not any(k.startswith(("DYLD_", "Malloc", "SWIFT_")) for k in launch_record["environment"])
provenance_paths = [receipt, PREP / "input-freeze.json", PREP / "collection-recipe.json", trees_path, launch,
                    ROOT / "scripts/contracts/p08_check_collection.py", ROOT / "scripts/contracts/check-spec-015-counter.py"]
for p in provenance_paths[-2:]:
    assert sha(p) == freeze[name(p)]
out = ROOT / ".build/contracts/p08-u01-residual-static1"
assert not out.exists(), "proposed output must remain absent during preparation"
inventory = {
    "baseline": BASE, "method": "Standard-library file membership/text/JSON/plist/SHA-256 inventory and read-only Git; no binary decoding/acquisition/runtime/tool launch.",
    "frozen_prior_inputs_match": len(prior["frozen_files"]), "reviewed_u01_packet_files": packet,
    "source42_hashes_match": True, "five_dirty_hashes_match": True, "preexisting_cache_sha256": cache,
    "provenance_files": [item(p) for p in provenance_paths],
    "retained_counter_artifacts": retained, "link_command_index_zero_based": 405, "link_argv": argv,
    "link_objects_equal_collection_capture_set": object_rows,
    "historical_execution_environment": launch_record["environment"],
    "collector_environment_join": "p08_check_collection.py:272 invokes subprocess.run without env; inherits sanitized launch environment. No historical loaded-image or OS-build capture identified in these receipts.",
    "runtime_candidate": item(core) | {"matches_frozen_predecessor_payload_bytes": True, "historical_provider_match_established": False},
    "frozen_payload_runtime": item(payload_core) | {"frozen_tree_record": trees[str(payload_root)]["macosx/libswiftCore.dylib"]},
    "interface": item(interface) | {"version_header": interface.read_text().splitlines()[:4], "numeric_Error_existential_layout_established": False},
    "current_installation_metadata": metadata, "sdk_stubs": stub_rows,
    "system_standalone_candidates": [item(p) for p in system_candidates],
    "current_cache_map": item(cache_map) | {"selected_entries": map_entries, "matches_historical_process_cache": False},
    "cache_members_stat_only": cache_members, "exact_abi_header_candidates": [item(p) for p in abi_paths],
    "tools": [item(tool), item(nm), item(objdump), item(apple / "share/man/man1/otool-classic.1")],
    "decoder_dependencies_equal_frozen_tree": len(deps["entries"]),
    "proposed_output_absent": str(out), "production_invocations": 0, "strict_cold_eligible": False,
}
if (HERE / "inventory.json").exists():
    old = json.loads((HERE / "inventory.json").read_text())
    for key in ("tools", "current_installation_metadata", "sdk_stubs", "current_cache_map", "system_standalone_candidates"):
        assert inventory[key] == old[key], "newly inventoried input drift: " + key

common_env = {"HOME": "/Users/eugene", "USER": "eugene", "LOGNAME": "eugene", "PATH": "/usr/bin:/bin:/usr/sbin:/sbin", "TMPDIR": "/private/tmp", "LC_CTYPE": "C.UTF-8"}
commands = []
for stage, p in (("A", receipt.parent / "counter"), ("B", core)):
    label = "counter" if stage == "A" else "toolchain-core"
    commands.extend([
        {"id": label + "-metadata", "stage": stage, "argv": [str(tool), "-arch", "arm64", "-hv", "-l", "-L", "-Iv", "-dyld_info", "-chained_fixups", str(p)], "environment": common_env, "max_combined_output_bytes": 8 * 1024**2},
        {"id": label + "-symbols", "stage": stage, "argv": [str(nm), "--numeric-sort", str(p)], "environment": common_env | recipe["decoder_environment"], "max_combined_output_bytes": 16 * 1024**2},
        {"id": label + "-body-data", "stage": stage, "argv": [str(objdump), "--macho", "--arch=arm64", "--disassemble", "--reloc", "--full-contents", "--no-show-raw-insn", str(p)], "environment": common_env | recipe["decoder_environment"], "max_combined_output_bytes": (128 if stage == "A" else 256) * 1024**2},
    ])
    for command in commands[-3:]:
        command.update({"cwd": str(ROOT), "input": item(p), "tool": item(pathlib.Path(command["argv"][0])), "max_wall_seconds": 60, "executed": False})
request = {
    "status": "PREPARATION_ONLY_independent_review_and_explicit_execution_authorization_required",
    "baseline": BASE, "scope": "U01 R01-R04 static identity/body/data request on existing pinned bytes only",
    "commands": commands, "output_root": str(out), "output_created": False,
    "stage_A": "Capture exact retained executable metadata/bind/fixup records, symbols and linked body/data; standard-library interpretation must prove architecture, object route joins and library resolution before B.",
    "stage_B_gate": "Run B only if A establishes this exact pinned toolchain core as applicable under retained no-override environment, with an unambiguous arm64 image/binding join; never select it by compiler version or matching filename. Otherwise STOP with missing provider/cache identity.",
    "interpretation_limit": "Only U01 callbacks/generic/metadata helper/cold runtime entry and their feasible transitive code/data, Error size, memcpy and stack-guard leaves; external/indirect/library/cache uncertainty is a residual, never permission to expand inputs or invoke more tools.",
    "budgets": {"attempts_proposed": 1, "attempts_used": 0, "maximum_decoder_commands": 6, "maximum_acquisitions": 0, "maximum_compiler_build_test_runtime_controller_strict_cold_launches": 0, "source_or_tooling_repairs": 0, "retries": 0, "maximum_attempt_wall_seconds": 360, "maximum_total_output_bytes": 512 * 1024**2},
    "permanent_marker_policy": "No existing collection/requalification marker is read for control, reused, modified or reset. Any later authorized launcher must create a new request-specific permanent attempt receipt; launcher/readiness is not supplied here.",
    "stop_conditions": ["Any missing/hash-drifted input/tool/library/dependency/source/preservation/cache identity", "Any nonzero exit, timeout, output cap, missing required record or unsupported decoder option/format", "No unambiguous arm64 linked route/provider/binding join, or selected provider unavailable as pinned standalone bytes", "Cold/runtime transitive target, selected library/IFUNC/cache resolver, metadata size or external leaf cannot be proved from the frozen captures", "Need for cache extraction, downloaded ABI/runtime source, populated process metadata, runtime loader observation or additional tools/commands", "Any contract/scope/ownership/privacy/heap/bound/warm-up exception choice"],
    "receipt_requirements": "Authenticate inputs/tools/dependencies before each command; preserve exact argv/environment, raw stdout/stderr, actual start/exit/timeout/output-cap and hashes before interpretation. Record gated/skipped commands, permanent consumption and exact remaining R01-R04 rows. Failures cannot be relabelled PASS by output parsing.",
    "missing_not_command_ready": ["Actual historical loaded runtime/system-cache UUID/build identity if static records cannot establish it", "Selected libSystem/libsystem_c implementation bytes and memcpy resolver choice; SDK .tbd/map names are not code", "Numeric Error metadata layout or exact applicable runtime data/constructor/source proof if static core capture cannot establish S", "Additional transitive runtime/library bodies beyond selected pinned core; no recursive acquisition budget"],
    "strict_cold_eligible": False, "collection1_consumed": True,
}
for filename, value in (("inventory.json", inventory), ("request.json", request)):
    (HERE / filename).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")
print(json.dumps({"baseline": BASE, "linked_objects": len(objects), "counter_sha256": retained[0]["sha256"], "proposed_commands": len(commands), "production_invocations": 0, "strict_cold_eligible": False}, sort_keys=True))
