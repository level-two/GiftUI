"""Inventory existing U01 system-provider evidence; launch no decoder/controller.

Only stdlib file/JSON/plist/text/hash and literal UUID-byte comparisons are used.
No instruction or cache-format decoder runs. No cache/report bytes are copied.
Writes are limited to inventory.json and request.json beside this file.
"""
import hashlib
import json
import pathlib
import plistlib
import re
import uuid

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[6]
RELATIVE = "Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage"
BASE = "8e3c74694f75a233221b32fe179ddfde9cf00fcb"
OLD = HERE.parent / "current-callee-u01-residual1-preparation"
LINKED = HERE.parent / "u01-linked-provider-interpretation1-result"

def digest(path):
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()

def row(path):
    path = pathlib.Path(path)
    return {"path": str(path), "exists": path.exists(),
        **({"bytes": path.stat().st_size, "sha256": digest(path)} if path.is_file() else {})}

context = json.loads((OLD / "controller-inputs.json").read_text())
for name, value in context["files"].items():
    path = pathlib.Path(name)
    assert path.stat().st_size == value["bytes"] and digest(path) == value["sha256"]
assert {str(p) for p in (ROOT / "scripts/contracts/__pycache__").rglob("*") if p.is_file()} == set(context["cache_file_sha256"])
for name, expected in context["cache_file_sha256"].items():
    assert digest(pathlib.Path(name)) == expected
markers = {}
for name, identity in (("p08-current-callee-collection1", [16777234, 29640436]), ("p08-u01-residual-static1", [16777234, 29650609])):
    p = ROOT / ".build/contracts" / name
    assert [p.stat().st_dev, p.stat().st_ino] == identity
    markers[name] = identity

counter_dir = ROOT / ".build/contracts/p08-counter-npoej3u2"
receipt = json.loads((counter_dir / "result.json").read_text())
log = counter_dir / "so06-native-exclusivity-negative-execute.log"
negative = counter_dir / "so06-native-exclusivity-negative"
for path in (log, negative):
    assert digest(path) == receipt["artifacts"][path.name]["sha256"]
report_path = pathlib.Path("/Users/eugene/Library/Logs/DiagnosticReports/so06-native-exclusivity-negative-2026-10-19-131150.ips")
text = report_path.read_text()
decoder = json.JSONDecoder()
header, end = decoder.raw_decode(text)
report, end = decoder.raw_decode(text, end + len(text[end:]) - len(text[end:].lstrip()))
images = [im for im in report["usedImages"] if im.get("name") in
    ("so06-native-exclusivity-negative", "libswiftCore.dylib", "libsystem_c.dylib", "dyld")]
selected_report = {"header": {k: header[k] for k in ("app_name", "timestamp", "slice_uuid", "bug_type", "os_version")},
    "report": {k: report[k] for k in ("captureTime", "procLaunch", "procName", "procPath", "osVersion", "sharedCache", "cpuType", "translated")},
    "images": [{k: im[k] for k in ("name", "path", "uuid", "arch", "base", "size")} for im in images],
    "ordinary_counter_process": False, "previously_in_counter_manifest": False}
negative_uuid_bytes = uuid.UUID(header["slice_uuid"]).bytes
negative_bytes = negative.read_bytes()
negative_offsets = [m.start() for m in re.finditer(re.escape(negative_uuid_bytes), negative_bytes)]
assert negative_offsets == [2808]

cache_root = pathlib.Path("/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld")
cache_paths = sorted(p for p in cache_root.iterdir() if p.name.startswith("dyld_shared_cache_arm64e"))
assert len(cache_paths) == 15
primary = cache_root / "dyld_shared_cache_arm64e"
with primary.open("rb") as stream:
    primary_header = stream.read(4096)
known_cache_uuid = uuid.UUID(report["sharedCache"]["uuid"]).bytes
header_offsets = [m.start() for m in re.finditer(re.escape(known_cache_uuid), primary_header)]
assert header_offsets == [88]
needles = {im["name"]: uuid.UUID(im["uuid"]).bytes for im in images if im["name"] in ("libswiftCore.dylib", "libsystem_c.dylib")}
cache_rows = []
for path in cache_paths:
    before = path.stat()
    value = hashlib.sha256()
    matches = {key: [] for key in needles}
    offset = 0
    overlap = b""
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
            data = overlap + block
            for key, needle in needles.items():
                for match in re.finditer(re.escape(needle), data):
                    absolute = offset - len(overlap) + match.start()
                    if absolute not in matches[key]:
                        matches[key].append(absolute)
            offset += len(block)
            overlap = data[-15:]
    after = path.stat()
    assert (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns) == (after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns)
    cache_rows.append({"path": str(path), "bytes": before.st_size, "sha256": value.hexdigest(),
        "reported_image_UUID_byte_occurrences": {k: v for k, v in matches.items() if v}})
assert cache_paths == sorted(p for p in cache_root.iterdir() if p.name.startswith("dyld_shared_cache_arm64e"))
map_path = cache_root / "dyld_shared_cache_arm64e.map"
map_text = map_path.read_text()
map_joins = []
for image in images:
    if image["name"] in needles:
        match = re.search(re.escape(image["path"]) + r"\n\s+__TEXT (0x[0-9A-F]+) -> (0x[0-9A-F]+)", map_text)
        assert match
        map_joins.append({"path": image["path"], "reported_base": hex(image["base"]), "map_text_base": match[1],
            "map_text_end": match[2], "common_slide_candidate": hex(image["base"] - int(match[1], 16))})
assert {x["common_slide_candidate"] for x in map_joins} == {"0x2810000"}

os_path = pathlib.Path("/System/Library/CoreServices/SystemVersion.plist")
os_info = plistlib.loads(os_path.read_bytes())
assert os_info["ProductBuildVersion"] == report["osVersion"]["build"] == "25G83"
tool = pathlib.Path("/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/dyld_info")
manual = tool.parent.parent / "share/man/man1/dyld_info.1"
assert "paths to dylibs that are in the dyld cache and not on disk" in manual.read_text()
virtual_paths = ["/usr/lib/swift/libswiftCore.dylib", "/usr/lib/libSystem.B.dylib", "/usr/lib/system/libsystem_c.dylib", "/usr/lib/system/libsystem_platform.dylib"]
abi_candidates = [pathlib.Path("/usr/include/swift/ABI/Metadata.h"), pathlib.Path("/usr/include/swift/Runtime/ExistentialContainer.h"),
    pathlib.Path("/usr/lib/swift/Swift.swiftmodule/arm64e-apple-macos.swiftinterface")]
out = ROOT / ".build/contracts/p08-u01-system-provider-static1"
assert not out.exists()
inventory = {
    "linked_review_baseline": BASE, "method": "Existing file/text/JSON/plist/SHA-256 and literal UUID-byte inventory only; no decoder/controller/runtime/acquisition.",
    "prior_direct_inputs_verified": 180, "source42_five_dirty_cache_preserved": True, "consumed_markers_unchanged": markers,
    "prior_linked_evidence": [row(LINKED / n) for n in ("README.md", "inspection.json", "retained-excerpts.txt", "independent-review.md")],
    "historical_supplemental_report": row(report_path) | {"selected_fields": selected_report},
    "historical_negative_artifact": row(negative) | {"matches_frozen_receipt": True, "reported_UUID_literal_byte_offsets": negative_offsets},
    "historical_negative_log": row(log),
    "cache_family": cache_rows, "cache_membership": [str(p) for p in cache_paths], "cache_total_bytes": sum(x["bytes"] for x in cache_rows),
    "primary_header": {"path": str(primary), "first_4096_sha256": hashlib.sha256(primary_header).hexdigest(),
        "magic_literal_bytes": primary_header[:16].hex(), "reported_shared_cache_UUID_literal_byte_offsets": header_offsets,
        "format_qualification": "Literal known UUID bytes occur at 0x58; this inventory does not invoke a cache-format decoder. Independent review/provider gate must validate field semantics."},
    "historical_to_current_map_correspondence": map_joins,
    "current_OS": row(os_path) | {"ProductVersion": os_info["ProductVersion"], "ProductBuildVersion": os_info["ProductBuildVersion"]},
    "tool": row(tool), "tool_manual": row(manual), "virtual_system_images": [row(p) for p in virtual_paths],
    "system_ABI_source_candidates": [row(p) for p in abi_candidates],
    "missing": ["Direct ordinary-counter historical loaded-image/UUID receipt; supplemental crash report is a different process",
        "Independently decoded path/architecture/image UUID identity for the proposed cache-backed virtual images",
        "Historical libSystem/platform image UUIDs observed directly in this supplemental crash report",
        "Exact selected system Swift source revision/type-layout header or populated Error metadata/value-witness size",
        "Selected cold runtime, memcpy/resolver/canary implementation/body/cost and complete feasible transitive attribution"],
    "proposed_output_absent": str(out), "ordinary_counter_runtime_applicability_complete": False,
    "production_tools_launched": 0, "cache_extractions": 0, "acquisitions": 0, "strict_cold_eligible": False,
}
if (HERE / "inventory.json").exists():
    old = json.loads((HERE / "inventory.json").read_text())
    assert old == inventory, "system-provider inventory drift"

environment = json.loads((OLD / "loader-policy.json").read_text())["controller_environment"]
identity = [str(tool), "-arch", "arm64e", "-uuid", "-platform", "-linked_dylibs", "-exports", "-imports", "-function_starts", "-function_variants", *virtual_paths]
commands = [
    {"id": "system-image-identities", "stage": "I", "argv": identity, "max_combined_output_bytes": 16 * 1024**2},
    {"id": "system-swift-body-data", "stage": "S", "argv": [str(tool), "-arch", "arm64e", "-disassemble", "-all_sections_bytes", virtual_paths[0]], "max_combined_output_bytes": 192 * 1024**2},
    {"id": "system-c-body-data", "stage": "S", "argv": [str(tool), "-arch", "arm64e", "-disassemble", "-all_sections_bytes", *virtual_paths[1:]], "max_combined_output_bytes": 64 * 1024**2},
]
for command in commands:
    command.update({"environment": environment, "cwd": str(ROOT), "tool": row(tool), "max_wall_seconds": 60, "executed": False})
request = {"status": "PREPARATION_ONLY_independent_review_required_no_execution_authorized", "scope": "U01 R01-R04 selected system-provider static cache-backed evidence; new request, old B unchanged/inapplicable",
    "commands": commands, "output_root": str(out), "input_authentication": "Pin inventory/request/code/environment externally after review. Reauthenticate all 15 cache-family member hashes/membership, report/artifact/log, linked evidence, tool/manual and applicable prior complete interpreter/Xcode loader roots/aliases, source42 and dirty/cache identities before launch and each command.",
    "provider_gate": {"before_S": "I must identify each exact install path/arm64e image; Swift UUID83794fb3-de9b-3d23-ab5e-2c1d5d30f134 and C UUIDd77ceb62-aff6-3cec-ba9b-4f057fbe2eb5 must match the existing historical supplemental report. Validate current cache UUID field against reported f2e86c53-6052-388b-ba71-5a0c9b569413 and OS25G83 before relying on cache membership. Static linked providers must remain system Swift/libSystem. No name/version/map-only release.",
        "ordinary_process_limit": "These joins establish matching historical supplemental/cache candidates, not direct ordinary-counter loaded-image observation. Body capture may contribute conditional static evidence only; R03 ordinary-process applicability cannot be marked complete by this gate.",
        "failure": "Immediate STOP; all S commands skipped. No human wait/reset inside aggregate budget, no tool/provider substitution or cache extraction."},
    "budgets": {"attempts_proposed": 1, "attempts_used": 0, "decoder_commands_max": 3, "per_command_seconds": 60,
        "aggregate_seconds_including_authentication_gate": 240, "total_retained_output_bytes_max": 320 * 1024**2,
        "acquisitions": 0, "cache_extractions": 0, "network_fetches": 0, "runtime_compiler_build_test_launches": 0,
        "repairs": 0, "retries": 0, "controller_bootstrap_proposed_separately": 1, "controller_bootstrap_used": 0},
    "receipts": "New request-specific permanent attempt marker before child, durable exact argv/environment/authentication/claim/start/raw stdout/stderr/actual exit/hash/cap/timeout and skipped-command records. Raw caps must stop/kill owned process groups, not truncate into PASS. No historical marker/attempt reuse.",
    "stop_conditions": ["Any source/tool/loader/report/cache membership/hash drift", "Unsupported cache-path/architecture/flag format, nonzero exit, empty/missing UUID/provider/body records, timeout/output cap", "Historical/current UUID/build/provider correspondence fails or field semantics remain unauthenticated", "Exact Error size, transitive implementation/resolver or ordinary-counter image applicability remains missing: preserve residual, no automatic new operation", "Need for extraction, downloading source/tool, runtime metadata/loader observation, warm-up/heap/ownership/privacy/bound/scope exception"],
    "next_prerequisite": "Independent Strong preparation review, then concrete externally pinned controller/gate/readiness and explicit authorization before any proposed decoder command. No controller is prepared or launched here.",
    "R01_R02_R03_R04_complete": False, "old_B_retargeted": False, "strict_cold_eligible": False,
}
for filename, data in (("inventory.json", inventory), ("request.json", request)):
    (HERE / filename).write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
print(json.dumps({"cache_family_files": len(cache_rows), "cache_bytes_hashed": inventory["cache_total_bytes"],
    "historical_report_UUID_bytes_in_primary_header": header_offsets, "proposed_decoder_commands": len(commands), "tools_launched": 0}, sort_keys=True))
