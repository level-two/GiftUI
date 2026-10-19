"""Interpret retained I text/JSON with stdlib and read-only Git; no image decoder."""
import hashlib
import json
import os
import pathlib
import re
import subprocess

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[6]
BASE = "2c6570e6daf716d632a91cc2f15445de7e8a36c4"
PREP = HERE.parent / "u01-system-provider1-preparation"
ARCHIVE = HERE.parent / "u01-system-provider-static1-i-only-result1"
LINKED = HERE.parent / "u01-linked-provider-interpretation1-result"


def digest(path):
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


def frozen(path):
    data = path.read_bytes()
    expected = subprocess.check_output(["/usr/bin/git", "--no-replace-objects", "--no-pager", "show",
        BASE + ":" + str(path.relative_to(ROOT))], cwd=ROOT)
    assert data == expected, "frozen Git bytes drift: " + str(path)
    return data

manifest = json.loads(frozen(ARCHIVE / "manifest.json"))
for row in manifest["members"]:
    path = ARCHIVE / row["path"]
    data = frozen(path)
    assert len(data) == row["bytes"] and hashlib.sha256(data).hexdigest() == row["sha256"]
for name in ("README.md", "independent-review.md", "independent-review-inspection.json"):
    frozen(ARCHIVE / name)
inventory = json.loads(frozen(PREP / "inventory.json"))
context = json.loads(frozen(PREP / "controller-inputs.json"))
linked = json.loads(frozen(LINKED / "inspection.json"))
for name, row in context["files"].items():
    path = pathlib.Path(name)
    before = path.stat()
    assert path.is_file() and path.is_symlink() == row["is_symlink"] and str(path.resolve(strict=True)) == row["resolved"]
    if row["is_symlink"]:
        assert os.readlink(path) == row["target"]
    assert before.st_size == row["bytes"] and digest(path) == row["sha256"]
    after = path.stat()
    assert (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns) == (after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns)
assert sorted(str(p) for p in pathlib.Path(context["cache_root"]).iterdir() if p.name.startswith(context["cache_prefix"])) == context["cache_membership"]
for name, expected in context["cache_file_sha256"].items():
    assert digest(pathlib.Path(name)) == expected
assert {str(p) for p in (ROOT / "scripts/contracts/__pycache__").rglob("*") if p.is_file()} == set(context["cache_file_sha256"])
markers = dict(context["consumed_markers"])
markers[str(ROOT / ".build/contracts/p08-u01-system-provider-static1")] = [16777234, 29652748]
for name, identity in markers.items():
    stat = pathlib.Path(name).stat()
    assert [stat.st_dev, stat.st_ino] == identity

raw_path = ARCHIVE / "system-image-identities.stdout"
lines = raw_path.read_text().splitlines()
heads = [(i, re.fullmatch(r"(/usr/lib/[^\n]+) \[([^]]+)\]:", line)) for i, line in enumerate(lines)]
heads = [(i, m) for i, m in heads if m]
assert len(heads) == 4
records = []
selected = []
symbols = {"_swift_getTypeByMangledNameInContext2", "_$ss5ErrorWS", "_memcpy", "_memmove",
    "___stack_chk_guard", "___stack_chk_fail", "__platform_memmove", "__platform_memmove+736", "___sme_memcpy", "___sme_memmove"}
excerpt_lines = set()
for index, (start, match) in enumerate(heads):
    end = heads[index + 1][0] if index + 1 < len(heads) else len(lines)
    headings = [(i, re.fullmatch(r"    -([a-z_]+):", lines[i]).group(1)) for i in range(start, end)
        if re.fullmatch(r"    -([a-z_]+):", lines[i])]
    assert [name for i, name in headings] == ["platform", "uuid", "linked_dylibs", "exports", "imports", "function_starts"]
    sections = {name: {"heading_line": i + 1, "end_line": headings[j + 1][0] if j + 1 < len(headings) else end}
        for j, (i, name) in enumerate(headings)}
    def content(name):
        section = sections[name]
        return [(i + 1, lines[i]) for i in range(section["heading_line"], section["end_line"]) if lines[i].strip()]
    plat = content("platform")
    platform_match = re.fullmatch(r"\s*(zippered\(macOS/Catalyst\))\s+(\S+)\s+(\S+)\s*", plat[-1][1])
    assert platform_match
    identity_rows = content("uuid")
    assert len(identity_rows) == 1 and re.fullmatch(r"\s*[A-F0-9-]{36}\s*", identity_rows[0][1])
    deps = []
    for number, line in content("linked_dylibs"):
        if "attributes" in line:
            continue
        dep = re.fullmatch(r"\s*(.*?)\s*(/[^\n]+)", line)
        assert dep, line
        deps.append({"line": number, "attributes": dep[1].strip(), "path": dep[2]})
    exports = []
    for number, line in content("exports"):
        if "offset      symbol" in line:
            continue
        export = re.fullmatch(r"\s*(0x[0-9A-Fa-f]+|\[re-export\])\s+(\S+)(.*)", line)
        assert export, line
        exports.append({"line": number, "offset_or_reexport": export[1], "symbol": export[2], "annotation": export[3].strip()})
    imports = []
    for number, line in content("imports"):
        imp = re.fullmatch(r"\s*(?:(0x[0-9A-Fa-f]+)\s+)?(\S+)(.*?)\s+\(from ([^)]+)\)", line)
        assert imp, line
        imports.append({"line":number,"ordinal_as_printed":imp[1],"symbol":imp[2],"attributes":imp[3].strip(),"from_as_printed":imp[4]})
    starts = []
    for number, line in content("function_starts"):
        function = re.fullmatch(r"\s*(0x[0-9A-Fa-f]+)\s+(.+)", line)
        assert function, line
        starts.append({"line":number,"address_as_printed":function[1],"symbol":function[2]})
    selected_rows = []
    for kind, rows in (("exports", exports), ("imports", imports), ("function_starts", starts)):
        for row in rows:
            if row["symbol"] in symbols:
                selected_rows.append({"section":kind, **row})
                selected.append({"image":match[1],"section":kind,**row})
                excerpt_lines.add(row["line"])
    resolver_rows = [r for r in exports if "dynamic-resolver=" in r["annotation"]]
    record = {"path":match[1],"arch":match[2],"first_line":start+1,"last_line":end,
        "platform":platform_match[1],"minOS":platform_match[2],"SDK":platform_match[3],
        "UUID":identity_rows[0][1].strip(),"UUID_line":identity_rows[0][0],"sections":sections,
        "linked_dylibs":deps,"export_rows":len(exports),"reexport_rows":sum(r["offset_or_reexport"]=="[re-export]" for r in exports),
        "import_rows":len(imports),"function_start_rows":len(starts),"selected_rows":selected_rows,
        "dynamic_resolver_exports":resolver_rows,"function_variants_heading_present":False,
        "structured_function_variant_rows_present":False,
        "variant_limit":"Flag was requested; no separate variant heading/table is emitted. No absence-of-variants or implementation-selection claim follows."}
    records.append(record)
    excerpt_lines.update(range(start+1,sections["exports"]["heading_line"]+1))
    excerpt_lines.update(section["heading_line"] for section in sections.values())
    excerpt_lines.update(row["line"] for row in resolver_rows)
assert [r["path"] for r in records] == [r["path"] for r in inventory["virtual_system_images"]]
report = inventory["historical_supplemental_report"]["selected_fields"]
image_joins = []
map_path = pathlib.Path(next(r["path"] for r in inventory["cache_family"] if r["path"].endswith(".map")))
map_text = map_path.read_text()
for record in records:
    historical = [row for row in report["images"] if row["path"] == record["path"]]
    if historical:
        assert len(historical)==1 and historical[0]["arch"]==record["arch"] and historical[0]["uuid"]==record["UUID"].lower()
    m = re.search(re.escape(record["path"]) + r"\n\s+__TEXT (0x[0-9A-F]+) -> (0x[0-9A-F]+)",map_text)
    assert m
    standalone = next(row for row in inventory["virtual_system_images"] if row["path"]==record["path"])
    image_joins.append({"path":record["path"],"UUID":record["UUID"],"arch":record["arch"],
        "supplemental_report_exact_UUID_path_arch_match":bool(historical),
        "ordinary_counter_loaded_identity":False,"map_TEXT_base":m[1],"map_TEXT_end":m[2],
        "standalone_existed_at_capture":standalone["exists"],
        "input_origin_limit":"Pinned standalone platform operand exists; do not transfer its relative offsets/UUID into cache without exact cache-image qualification" if standalone["exists"] else
            "Absent standalone operand; installed tool documents cache-backed lookup. Pinned cache family/map correspondence, not decoded header-field proof.",
        "historical_report_base":hex(historical[0]["base"]) if historical else None,
        "report_map_slide_candidate":hex(historical[0]["base"]-int(m[1],16)) if historical else None})
# Export-offset + authenticated map-base arithmetic only, checked against printed start.
arithmetic = []
for image,symbol in ((records[0]["path"],"_swift_getTypeByMangledNameInContext2"),(records[2]["path"],"___stack_chk_fail")):
    record = next(r for r in records if r["path"]==image)
    base = int(next(r for r in image_joins if r["path"]==image)["map_TEXT_base"],16)
    export = next(r for r in record["selected_rows"] if r["section"]=="exports" and r["symbol"]==symbol)
    start = next(r for r in record["selected_rows"] if r["section"]=="function_starts" and r["symbol"]==symbol)
    assert base+int(export["offset_or_reexport"],16)==int(start["address_as_printed"],16)
    arithmetic.append({"image":image,"symbol":symbol,"map_base":hex(base),"export_offset":export["offset_or_reexport"],
        "printed_function_start":start["address_as_printed"],"export_line":export["line"],"function_line":start["line"],"implementation_bytes_present":False})
result = {"baseline":BASE,"method":"Retained text/JSON/Git and pinned existing-file SHA-256 only; no instruction/cache-format decoder or controller/target execution",
    "archive_members_equal_manifest_Git":len(manifest["members"]),"stdout_bytes":raw_path.stat().st_size,"stdout_sha256":digest(raw_path),
    "stdout_lines":len(lines),"direct_context_files_verified":len(context["files"]),"cache_members_verified":len(context["cache_membership"]),
    "source42_five_dirty_cache_preserved":True,"three_consumed_marker_identities_unchanged":markers,"records":records,
    "selected_symbol_rows":selected,"image_joins":image_joins,"export_start_arithmetic":arithmetic,
    "report_OS_build":report["report"]["osVersion"],"reported_shared_cache_UUID":report["report"]["sharedCache"]["uuid"],
    "cache_header_schema_authenticated":False,"cache_UUID_field_decoded":False,"ordinary_counter_loaded_identity_complete":False,
    "selected_linked_imports_unchanged":linked["selected_imports_and_fixups"],"old_B_applicable":False,"S_executed_or_released":False,
    "R01":"OPEN: matching supplemental/current Swift image identity and cold-entry export/start; no implementation instructions, cache initialization or feasible transitive costs",
    "R02":"OPEN: ErrorWS export offset is not Error value size; metadata/value-witness bytes/layout applicability/numeric S and D remain missing",
    "R03":"PARTIAL: four I image identities, two supplemental UUID matches and pinned cache/map/input correspondence; ordinary historical loaded identity and cache schema unestablished; platform standalone/cache identity not equated",
    "R04":"OPEN_COST: recorded libSystem umbrella/C reexport/platform target and C canary exports/starts; no unique complete umbrella search/runtime variant/resolver selection or bodies/data/cost proof",
    "runtime_compiler_build_test_decoder_controller_acquisition_launches":0,"repairs":0,"retries":0,"strict_cold_eligible":False,
    "current_callee_and_safety":"STOP","u02_u05":"OPEN","p08_r07_t8_1":"OPEN"}
(HERE / "inspection.json").write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
(HERE / "retained-excerpts.txt").write_text('Source: '+str(raw_path.relative_to(ROOT))+'\nSHA-256: '+digest(raw_path)+'\nDisplay excerpts strip trailing whitespace; canonical stdout bytes are unchanged.\n\n'+''.join(str(i)+': '+lines[i-1].rstrip()+'\n' for i in sorted(excerpt_lines)))
print(json.dumps({"records":[{k:r[k] for k in ("path","first_line","last_line","UUID","export_rows","reexport_rows","import_rows","function_start_rows")} for r in records],"selected":selected,"tools_launched":0},indent=2))
