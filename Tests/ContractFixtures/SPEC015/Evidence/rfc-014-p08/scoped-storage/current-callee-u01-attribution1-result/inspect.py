"""Derive U01 evidence from frozen text using the Python standard library only.

No compiler, decoder, controller, qualifier or application is imported/invoked.
The sole subprocess operation is read-only `git show` for frozen-blob equality.
Only inspection.json and retained-excerpts.txt beside this file are written.
"""
import hashlib
import json
import pathlib
import re
import subprocess

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[6]
# Resolve the full identity of the exact retained baseline.
BASE = subprocess.check_output(["git", "rev-parse", "b1eb9ea2"], cwd=ROOT, text=True).strip()
RAW = HERE.parent / "current-callee-collection1-result/raw"
PREP = HERE.parent / "current-callee-readiness1-preparation"
PRIOR = HERE.parent / "current-callee-interpretation1-result"


def sha(data):
    return hashlib.sha256(data).hexdigest()


def relative(path):
    return str(path.relative_to(ROOT))


review = json.loads((PRIOR / "independent-review-inspection.json").read_text())
paths = {ROOT / p for p in review["frozen_file_sha256"]}
paths.update((PRIOR / n) for n in ("independent-review.md", "independent-review-inspection.json"))
paths.update(PREP / n for n in ("source42.json", "preserved-dirty-files.json"))
paths.update(ROOT / p for p in (
    "Sources/GiftUI/BoundedText.swift",
    "Sources/GiftUISemanticCore/SemanticStandardPayload.swift",
))
frozen = {}
for path in sorted(paths):
    data = path.read_bytes()
    committed = subprocess.check_output(["git", "show", f"{BASE}:{relative(path)}"], cwd=ROOT)
    assert data == committed, relative(path)
    frozen[relative(path)] = {"bytes": len(data), "sha256": sha(data)}

sources = json.loads((PREP / "source42.json").read_text())
assert len(sources) == 42
assert all(sha((ROOT / p["path"]).read_bytes()) == p["sha256"] for p in sources)
dirty = json.loads((PREP / "preserved-dirty-files.json").read_text())["files"]
assert len(dirty) == 5
assert all(sha((ROOT / p).read_bytes()) == expected for p, expected in dirty.items())
cache = {relative(p): sha(p.read_bytes()) for p in sorted((ROOT / "scripts/contracts/__pycache__").rglob("*")) if p.is_file()}
previous = HERE / "inspection.json"
if previous.exists():
    assert cache == json.loads(previous.read_text())["preexisting_cache_file_sha256"]

texts = {}
excerpts = []


def lines(name):
    if name not in texts:
        texts[name] = (RAW / name).read_text().splitlines()
    return texts[name]


def excerpt(name, first, last):
    excerpts.append(f"\n=== {name}:{first}-{last} ===\n")
    excerpts.extend(f"{n}:" + (f" {lines(name)[n-1]}" if lines(name)[n-1] else "") + "\n"
                    for n in range(first, last + 1))


for first, last in ((598688, 598706), (600938, 600956), (601528, 601696)):
    excerpt("actual-host.sil", first, last)
for first, last in ((552, 693), (18434, 18441), (18681, 18688)):
    excerpt("GiftUI-disassembly.stdout", first, last)
for first, last in ((200608, 200639), (202029, 202058), (202368, 202418), (222471, 222478), (226670, 226676)):
    excerpt("P08CounterRuntime-disassembly.stdout", first, last)
excerpt("GiftUISemanticCore-disassembly.stdout", 42293, 42350)
excerpt("GiftUIReferenceTextResources-disassembly.stdout", 21405, 21441)

callback = lines("actual-host.sil")[601529:601687]
assert callback[0].startswith("sil shared @")
assert callback[-1].startswith("} // end sil function")
assert not any(re.search(r"\b(?:apply|try_apply|begin_apply|partial_apply|throw|alloc_box|alloc_ref|alloc_existential_box)\b", line.split("//")[0]) for line in callback)
sil_callback = {
    "line": 601530,
    "end_line": 601687,
    "symbol": re.search(r"@([^ :]+)", callback[0])[1],
    "blocks": sum(bool(re.match(r"bb\d+", x)) for x in callback),
    "cond_fail_sites": [601530 + n for n, x in enumerate(callback) if "cond_fail " in x],
    "apply_family_sites": 0,
    "throw_sites": 0,
    "heap_allocation_instruction_sites": 0,
}

index = json.loads((RAW / "boundary-physical-index.json").read_text())
abi = "$s6GiftUI11BoundedTextV8withUTF8yxxSRys5UInt8VGKXEKlF"
generic = "_$ss15withUnsafeBytes2of_q0_x_q0_SWq_YKXEtq_YKs5ErrorR_Ri_zRi_0_r1_lF"
index_matches = [{"module": mod, **{k: f[k] for k in ("name", "function_id", "basic_blocks", "serialized_kind")}}
                 for mod, val in index.items() for f in val["functions"] if f["name"] == abi]
targets = ("_$ss5ErrorWS", "_$ss5Error_pMD", "_swift_getTypeByMangledNameInContext2", generic,
           "_" + sil_callback["symbol"])
symbol_matches = []
headers = []
for path in sorted(RAW.glob("*-symbols.stdout")):
    mod = path.name.removesuffix("-symbols.stdout")
    for n, line in enumerate(path.read_text().splitlines(), 1):
        if line.split() and line.split()[-1] in targets:
            symbol_matches.append({"module": mod, "line": n, "text": line.strip()})
for path in sorted(RAW.glob("*-disassembly.stdout")):
    mod = path.name.removesuffix("-disassembly.stdout")
    for n, line in enumerate(lines(path.name), 1):
        match = re.fullmatch(r"([0-9a-f]+) <(.+)>:", line)
        if match and match[2] in targets:
            headers.append({"module": mod, "line": n, "address": match[1], "symbol": match[2]})

terminal = json.loads((RAW / "terminal.json").read_text())
record = {
    "reviewed_baseline": BASE,
    "method": "Standard-library text/JSON/SHA-256 inspection and read-only Git show/rev-parse; no production execution.",
    "frozen_files_equal_baseline": len(frozen),
    "frozen_files": frozen,
    "source42_hashes_match": True,
    "five_preexisting_dirty_hashes_match": True,
    "preexisting_cache_file_sha256": cache,
    "sil_callback": sil_callback,
    "ordinary_abi_serialized_index_matches": index_matches,
    "target_symbol_matches_across_25_objects": symbol_matches,
    "target_disassembly_headers_across_25_objects": headers,
    "collection_boundary_unchanged": {k: terminal[k] for k in ("collection_attempts", "automatic_source_repairs", "automatic_tooling_repairs", "retries", "marker_identity")},
    "selected_callback_targets": {
        "traversal_call": "P08CounterRuntime 0xa2adc -> GiftUI 0x77c; captured callback local 0xb6928 -> local 0xb3700 -> shared symbol with retained P08 body 0xa429c / GiftUISemanticCore body 0x21e70",
        "canvas_call": "P08CounterRuntime 0xa3e6c -> GiftUI 0x77c; captured callback local 0xb3700 -> same shared symbol",
        "generic_blr_x9": "GiftUI thunk 0x838, supplied by relocations 0x7d4/0x7d8",
        "thunk_blr_x10": "original selected callback pointer, stored at sp+0x88 and loaded through context+0x18",
        "generic_conditional_blr_x8": "*(*(Error_metadata-8)+0x20); exact code target absent, not called on selected normal-return callback path",
        "ErrorWS": "external data witness symbol; loaded into x6 at 0x7e8, no x6 use/call in retained generic body",
    },
    "temporary_stack": {
        "metadata_source": "0x7cc helper result for _$ss5Error_pMD, passed as x4",
        "size_load": "S = *(*(M-8)+0x40), GiftUI 0x894/0x898",
        "reservation": "D = (S+15) & ~15; sp -= D, 0x89c-0x8ac, before callback/error test",
        "numeric_size_or_upper_bound_from_retained_text": None,
        "fixed_local_frames_bytes": {"GiftUI_withUTF8": 240, "GiftUI_generic": 64, "GiftUI_thunk": 32, "P08_callback_TA": 16, "P08_callback_TA_65_additional": 16, "P08_decoder": 0, "metadata_helper_separate_phase": 32},
        "whole_stack_bound_established": False,
    },
    "bounded_attribution": "selected callback/local helper identity and selected no-throw feasibility resolved in retained emitted bodies; external cold/metadata/linked evidence unresolved",
    "current_callee_review": "STOP_required_complete_callee_and_safety_not_proved",
    "strict_cold_eligible": False,
    "u02_u05_status": "not investigated by this U01-only slice; prior open dispositions retained",
}
(HERE / "inspection.json").write_text(json.dumps(record, indent=2, sort_keys=True) + "\n")
(HERE / "retained-excerpts.txt").write_text("U01 retained text excerpts; original one-based raw line numbers.\n" + "".join(excerpts))
print(json.dumps({"baseline": BASE, "frozen_files_equal_baseline": len(frozen), "callback_blocks": sil_callback["blocks"], "strict_cold_eligible": False}, sort_keys=True))
