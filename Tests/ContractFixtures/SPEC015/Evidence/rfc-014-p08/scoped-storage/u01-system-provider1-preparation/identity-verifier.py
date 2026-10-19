"""Authenticated retained-input joins only; never interpret cache-header fields."""
import json
import pathlib
import plistlib


def verify(inventory, gate, check_time):
    def require(value, message):
        if not value:
            raise ValueError(message)

    require(gate["mode"] == "STOP_AFTER_I_CACHE_SCHEMA_UNESTABLISHED" and
        gate["S_launch_enabled"] is False and gate["cache_header_schema_authenticated"] is False and
        gate["cache_uuid_field_offset"] is None and gate["cache_uuid_parser"] is None and
        gate["schema_evidence"] == [], "closed schema policy required")
    check_time()
    expected = inventory["historical_supplemental_report"]["selected_fields"]
    text = pathlib.Path(inventory["historical_supplemental_report"]["path"]).read_text()
    decoder = json.JSONDecoder()
    header, end = decoder.raw_decode(text)
    report, end = decoder.raw_decode(text, end + len(text[end:]) - len(text[end:].lstrip()))
    require(not text[end:].strip(), "unexpected report trailing data")
    names = {row["name"] for row in expected["images"]}
    images = [im for im in report["usedImages"] if im.get("name") in names]
    selected = {"header": {k: header[k] for k in expected["header"]},
        "report": {k: report[k] for k in expected["report"]},
        "images": [{k: im[k] for k in ("name", "path", "uuid", "arch", "base", "size")} for im in images],
        "ordinary_counter_process": False, "previously_in_counter_manifest": False}
    require(selected == expected, "supplemental report selected-field drift")
    require(report["procName"] == "so06-native-exclusivity-negative" and
        report["cpuType"] == "ARM-64" and report["translated"] is False,
        "exact distinct supplemental process required")
    require(report["sharedCache"]["uuid"] == gate["expected_supplemental_cache_uuid"], "report cache UUID drift")
    require(report["osVersion"]["build"] == gate["expected_os_build"] and
        report["osVersion"]["train"] == "macOS " + gate["expected_os_version"], "report OS drift")
    targets = {"/usr/lib/swift/libswiftCore.dylib": "83794fb3-de9b-3d23-ab5e-2c1d5d30f134",
        "/usr/lib/system/libsystem_c.dylib": "d77ceb62-aff6-3cec-ba9b-4f057fbe2eb5"}
    for path, identity in targets.items():
        matches = [im for im in images if im["path"] == path]
        require(len(matches) == 1 and matches[0]["arch"] == "arm64e" and matches[0]["uuid"] == identity,
            "exact supplemental path/arch/UUID join missing")
    check_time()
    os_info = plistlib.loads(pathlib.Path(inventory["current_OS"]["path"]).read_bytes())
    require(os_info["ProductVersion"] == gate["expected_os_version"] and
        os_info["ProductBuildVersion"] == gate["expected_os_build"], "current OS/report build correspondence drift")
    linked_path = next(row["path"] for row in inventory["prior_linked_evidence"] if row["path"].endswith("/inspection.json"))
    linked = json.loads(pathlib.Path(linked_path).read_text())
    require(linked["counter_artifact"]["sha256"] == "12d51381b0a776a3a05c60aa3f97b732a0490434435194d6eda0e29ef0d89242" and
        linked["rpaths"] == [] and linked["pinned_toolchain_core_selected_by_static_records"] is False,
        "retained linked provider drift")
    ordinals = {row["ordinal"]: row["name"] for row in linked["library_ordinals"]}
    require(ordinals[1] == "/usr/lib/libSystem.B.dylib" and ordinals[3] == "/usr/lib/swift/libswiftCore.dylib", "linked ordinals drift")
    expected_imports = {"___stack_chk_fail": 1, "___stack_chk_guard": 1, "_memcpy": 1,
        "_$ss5ErrorWS": 3, "_swift_getTypeByMangledNameInContext2": 3}
    imports = linked["selected_imports_and_fixups"]
    require(len(imports) == len(expected_imports), "selected import set drift")
    for row in imports:
        ordinal = expected_imports[row["symbol"]]
        require(row["ordinal"] == ordinal and row["install_name"] == ordinals[ordinal] and row["weak_import"] == 0,
            "strong linked system import drift")
    check_time()
    return {"authenticated_retained_input_correspondence": True,
        "supplemental_report_path_arch_UUID_OS_joins": True,
        "linked_system_import_joins": True, "cache_header_schema_authenticated": False,
        "cache_UUID_field_decoded": False, "I_output_semantically_parsed": False,
        "S_authorized": False, "ordinary_counter_loaded_identity_complete": False,
        "strict_cold_eligible": False,
        "reason": "No applicable independently justified cache-header schema; I raw requires independent interpretation; both S commands skipped regardless of I bytes."}
