"""Interpret retained U01 A text/hex using stdlib and read-only Git only.

No decoder, controller, compiler, runtime or repository producer is imported or
invoked. Signed BL-immediate arithmetic uses already captured __text hex words
solely to disambiguate duplicated local symbol names in the archived rendering.
Only inspection.json and retained-excerpts.txt beside this file are written.
"""
import bisect
import hashlib
import json
import pathlib
import re
import shlex
import struct
import subprocess

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[6]
BASE = subprocess.check_output(["git", "rev-parse", "a298d71c"], cwd=ROOT, text=True).strip()
A = HERE.parent / "u01-residual-static1-a-only-result1"
U = HERE.parent / "current-callee-u01-attribution1-result"
PREP = HERE.parent / "current-callee-u01-residual1-preparation"
RAW = HERE.parent / "current-callee-collection1-result/raw"

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def relative(path):
    return str(path.relative_to(ROOT))

def read(path):
    return json.loads(path.read_text())

manifest = read(A / "manifest.json")
archive_hashes = {}
for path in sorted(A.iterdir()):
    assert path.is_file() and not path.is_symlink()
    expected = subprocess.check_output(["git", "show", f"{BASE}:{relative(path)}"], cwd=ROOT)
    assert path.read_bytes() == expected
    archive_hashes[relative(path)] = {"bytes": len(expected), "sha256": sha(path)}
for row in manifest["members"]:
    p = A / row["path"]
    assert p.stat().st_size == row["bytes"] and sha(p) == row["sha256"]
context = read(PREP / "controller-inputs.json")
for name, row in context["files"].items():
    p = pathlib.Path(name)
    assert p.stat().st_size == row["bytes"] and sha(p) == row["sha256"]
    assert str(p.resolve(strict=True)) == row["resolved"]
for name in context["absent_paths"]:
    assert not pathlib.Path(name).exists()
assert {str(p) for p in (ROOT / "scripts/contracts/__pycache__").rglob("*") if p.is_file()} == set(context["cache_file_sha256"])
receipt_path = ROOT / ".build/contracts/p08-counter-npoej3u2/result.json"
counter = read(receipt_path)
link_argv = shlex.split(counter["commands"][405])
objects = [p for p in link_argv if p.endswith(".o")]
collection_recipe = read(HERE.parent / "current-callee-readiness1-preparation/collection-recipe.json")
assert len(objects) == 25 and set(objects) == {x["command"][-1] for x in collection_recipe["object_captures"]}
assert link_argv[-2:] == ["-o", str(receipt_path.parent / "counter")]
assert sha(receipt_path.parent / "counter") == counter["artifacts"]["counter"]["sha256"]
markers = {}
for name, expected in (("p08-current-callee-collection1", [16777234, 29640436]), ("p08-u01-residual-static1", [16777234, 29650609])):
    p = ROOT / ".build/contracts" / name
    actual = [p.stat().st_dev, p.stat().st_ino]
    assert actual == expected
    markers[name] = actual

metadata = (A / "counter-metadata.stdout").read_text().splitlines()
symbols = (A / "counter-symbols.stdout").read_text().splitlines()
body = (A / "counter-body-data.stdout").read_text().splitlines()
loads = []
for n, line in enumerate(metadata):
    if re.fullmatch(r"Load command \d+", line):
        end = next((i for i in range(n + 1, len(metadata)) if metadata[i].startswith(("Load command ", "Indirect symbols for"))), len(metadata))
        block = metadata[n:end]
        command = next(x.strip().split()[1] for x in block if re.match(r"\s+cmd LC_", x))
        values = {"index": int(line.split()[-1]), "line": n + 1, "command": command}
        for key in ("name", "path", "uuid", "platform", "minos", "sdk"):
            match = next((re.match(r"\s*" + key + r"\s+(.+?)(?: \(offset \d+\))?$", x) for x in block if re.match(r"\s*" + key + r"\s+", x)), None)
            if match:
                values[key] = match[1]
        loads.append(values)
assert len(loads) == 22 and [x["index"] for x in loads] == list(range(22))
libraries = []
for x in loads:
    if x["command"] in ("LC_LOAD_DYLIB", "LC_LOAD_WEAK_DYLIB"):
        libraries.append(dict(x, ordinal=len(libraries) + 1))
assert len(libraries) == 5 and libraries[2]["name"] == "/usr/lib/swift/libswiftCore.dylib"
assert not any(x["command"] == "LC_RPATH" for x in loads)

imports = []
for n, line in enumerate(metadata):
    m = re.fullmatch(r"dyld chained import\[(\d+)\] = (0x[0-9a-fA-F]+)", line)
    if m:
        ordinal = re.search(r"lib_ordinal = (\d+) \(([^)]+)\)", metadata[n + 1])
        weak = re.search(r"weak_import = (\d+)", metadata[n + 2])
        symbol = re.search(r"name_offset = (\d+) \((.+)\)", metadata[n + 3])
        imports.append({"index": int(m[1]), "encoded_import": m[2], "line": n + 1,
                        "ordinal": int(ordinal[1]), "provider_label": ordinal[2], "weak_import": int(weak[1]),
                        "symbol": symbol[2], "name_offset": int(symbol[1])})
assert len(imports) == 203
selected = {"_swift_getTypeByMangledNameInContext2", "_$ss5ErrorWS", "_memcpy", "___stack_chk_guard", "___stack_chk_fail"}
selected_imports = []
for row in imports:
    if row["symbol"] in selected:
        row = dict(row, install_name=libraries[row["ordinal"] - 1]["name"])
        row["fixups"] = [{"line": n + 1, "text": line} for n, line in enumerate(metadata)
                         if line.startswith("__") and " bind " in line and line.split()[-1] == row["symbol"]]
        row["indirect_symbols"] = [{"line": n + 1, "text": line} for n, line in enumerate(metadata)
                                   if re.match(r"^0x[0-9a-fA-F]+ \d+ ", line) and line.split()[-1] == row["symbol"]]
        assert len(row["fixups"]) == 1
        selected_imports.append(row)
assert len(selected_imports) == 5

functions = {}
instructions = {}
current = None
for n, line in enumerate(body, 1):
    if line.startswith("Contents of section "):
        break
    if line.endswith(":") and not re.match(r"^[0-9a-f]+:", line) and not line.startswith("/"):
        current = {"symbol": line[:-1], "line": n, "instructions": []}
    m = re.fullmatch(r"([0-9a-f]+):\s+(.+)", line)
    if m and current:
        address = int(m[1], 16)
        if not current["instructions"]:
            current["address"] = address
            functions[address] = current
        row = {"address": address, "line": n, "text": m[2], "function": current["address"]}
        current["instructions"].append(row)
        assert address not in instructions
        instructions[address] = row

hex_rows = []
section = None
for n, line in enumerate(body, 1):
    if line.startswith("Contents of section "):
        section = line.removeprefix("Contents of section ").removesuffix(":")
    m = re.match(r"^\s(1[0-9a-f]{8})\s+((?:[0-9a-f]{8}\s+){0,3}[0-9a-f]{8})(?:\s|$)", line)
    if m:
        hex_rows.append((int(m[1], 16), bytes.fromhex(m[2]), n, section))
hex_rows.sort()
starts = [x[0] for x in hex_rows]

def bytes_at(address, count):
    output = bytearray()
    source_lines = []
    while len(output) < count:
        pos = address + len(output)
        row = hex_rows[bisect.bisect_right(starts, pos) - 1]
        offset = pos - row[0]
        assert 0 <= offset < len(row[1]), hex(pos)
        output.extend(row[1][offset:offset + count - len(output)])
        source_lines.append(row[2])
    return bytes(output), sorted(set(source_lines))

branches = []
for address in (0x100001674, 0x100001698, 0x1000016d0, 0x1000016e0,
                0x1001b87d4, 0x1001b9b64, 0x1001cc2b8, 0x1001c90d8, 0x100106640,
                0x100000e90, 0x100001684, 0x100001700):
    data, source_lines = bytes_at(address, 4)
    word = int.from_bytes(data, "little")
    assert word & 0xfc000000 == 0x94000000
    imm = word & 0x3ffffff
    signed = imm - (1 << 26) if imm & (1 << 25) else imm
    target = address + signed * 4
    branches.append({"address": hex(address), "raw_word": hex(word), "little_endian_bytes": data.hex(),
                     "signed_imm26": signed, "target": hex(target), "instruction_line": instructions[address]["line"],
                     "retained_rendering": instructions[address]["text"], "hex_source_lines": source_lines,
                     "target_symbol": functions[target]["symbol"] if target in functions else None})
assert next(x for x in branches if x["address"] == "0x1001cc2b8")["target"] == "0x1001c90cc"
assert next(x for x in branches if x["address"] == "0x1001c90d8")["target"] == "0x100106574"

ordinary = "_$s6GiftUI11BoundedTextV8withUTF8yxxSRys5UInt8VGKXEKlF"
generic = "_$ss15withUnsafeBytes2of_q0_x_q0_SWq_YKXEtq_YKs5ErrorR_Ri_zRi_0_r1_lF"
callback = "_" + read(U / "inspection.json")["sil_callback"]["symbol"]
names = {ordinary, ordinary + "xSWKXEfU_TA", generic, callback, callback + "TA", callback + "TA.65", "___swift_instantiateConcreteTypeFromMangledName", "_$ss5Error_pMD"}
symbol_rows = [{"line": n + 1, "text": line} for n, line in enumerate(symbols) if line.split() and line.split()[-1] in names]
linked_starts = {0x100000e5c, 0x100001648, 0x100001704, 0x100001740, 0x10000d508, 0x10000d790,
                 0x100106574, 0x100106634, 0x1001c90cc, 0x1001cc2b0}

def object_function(module, symbol):
    found = None
    for n, line in enumerate((RAW / (module + "-disassembly.stdout")).read_text().splitlines(), 1):
        header = re.fullmatch(r"([0-9a-f]+) <(.+)>:", line)
        if header:
            if found:
                break
            if header[2] == symbol:
                found = {"address": int(header[1], 16), "line": n, "instructions": []}
        elif found:
            instruction = re.fullmatch(r"\s+([0-9a-f]+):\s+(.+)", line)
            if instruction and not instruction[2].startswith("ARM64_RELOC_"):
                found["instructions"].append({"address": int(instruction[1], 16), "line": n, "text": instruction[2]})
    assert found
    return found

def normalized(fn):
    base = fn["address"]
    limit = base + 4 * len(fn["instructions"])
    result = []
    for row in fn["instructions"]:
        text = row["text"].split(";", 1)[0]
        text = re.sub(r" <[^>]+>", "", text)
        text = re.sub(r"0x([0-9a-f]+)", lambda m: "<+" + hex(int(m[1], 16) - base) + ">" if base <= int(m[1], 16) < limit else m[0], text)
        result.append(" ".join(text.split()))
    return result

comparisons = []
for linked, module, symbol in ((0x100106574, "GiftUISemanticCore", callback), (0x100106574, "P08CounterRuntime", callback),
                               (0x100001740, "GiftUI", generic), (0x100001740, "GiftUIReferenceTextResources", generic)):
    obj = object_function(module, symbol)
    left, right = normalized(functions[linked]), normalized(obj)
    comparisons.append({"linked_address": hex(linked), "object_module": module, "object_address": hex(obj["address"]),
                         "object_header_line": obj["line"], "instruction_counts": [len(left), len(right)],
                         "normalized_instruction_sequences_equal": left == right,
                         "linked_normalized_sha256": hashlib.sha256(json.dumps(left).encode()).hexdigest(),
                         "object_normalized_sha256": hashlib.sha256(json.dumps(right).encode()).hexdigest()})
assert [x["normalized_instruction_sequences_equal"] for x in comparisons] == [True, False, True, True]
decoder_rows = functions[0x100106574]["instructions"]
assert len(decoder_rows) == 48
assert not any(re.search(r"\b(?:bl|blr|br|x21|w21|sp)\b", x["text"]) for x in decoder_rows)

cache_address = 0x10028c200
cache_bytes, cache_lines = bytes_at(cache_address, 8)
offset, negative_length = struct.unpack("<ii", cache_bytes)
mangled_address = cache_address + offset
mangled, mangled_lines = bytes_at(mangled_address, -negative_length)
cache = {"address": hex(cache_address), "symbol": "_$ss5Error_pMD", "bytes": cache_bytes.hex(),
         "word": hex(int.from_bytes(cache_bytes, "little")), "sign_bit": int.from_bytes(cache_bytes, "little") >> 63,
         "relative_name_offset": offset, "negative_name_length": negative_length, "name_address": hex(mangled_address),
         "name_length": -negative_length, "symbolic_mangled_name_bytes": mangled.hex(),
         "hex_source_lines": cache_lines, "name_hex_source_lines": mangled_lines,
         "numeric_Error_value_size": None, "populated_metadata_pointer": None,
         "runtime_cache_state_at_first_selected_Text": "not observed"}
assert cache["sign_bit"] == 1 and negative_length == -7

excerpts = []
def excerpt(name, lines, first, last):
    excerpts.append(f"\n=== {name}:{first}-{last} ===\n")
    excerpts.extend(f"{n}:" + (" " + lines[n - 1] if lines[n - 1] else "") + "\n" for n in range(first, last + 1))
excerpt("counter-metadata.stdout", metadata, 1, 4)
excerpt("counter-metadata.stdout", metadata, 464, 551)
for row in selected_imports:
    excerpt("counter-metadata.stdout", metadata, row["line"], row["line"] + 3)
    for item in row["fixups"] + row["indirect_symbols"]:
        excerpt("counter-metadata.stdout", metadata, item["line"], item["line"])
for address in sorted(linked_starts):
    fn = functions[address]
    excerpt("counter-body-data.stdout", body, fn["line"], fn["instructions"][-1]["line"])
for address in (0x1001b87d4, 0x1001b9b64):
    n = instructions[address]["line"]
    excerpt("counter-body-data.stdout", body, n - 14, n + 2)
for n in sorted({x for row in branches for x in row["hex_source_lines"]} | set(cache_lines + mangled_lines)):
    excerpt("counter-body-data.stdout", body, n, n)
for row in symbol_rows:
    excerpt("counter-symbols.stdout", symbols, row["line"], row["line"])

record = {
    "baseline": BASE, "method": "Retained text/JSON/hex and SHA-256 reads, read-only Git; literal signed BL-immediate arithmetic disambiguates duplicate local names; no new decoder/production operation.",
    "archive_files_equal_baseline": archive_hashes, "source_packet_members_verified": len(manifest["members"]),
    "direct_context_files_verified": len(context["files"]), "source42_and_five_dirty_hashes_and_cache_preserved": True,
    "counter_receipt_sha256": sha(receipt_path), "counter_artifact": counter["artifacts"]["counter"],
    "link_command_zero_based": 405, "historical_invocation_zero_based": 406, "link_argv": link_argv,
    "link_objects_equal_original_capture_set": [{"path": p, "sha256": context["files"][p]["sha256"]} for p in objects],
    "consumed_marker_identities_unchanged": markers, "both_attempts_consumed": True, "repairs": 0, "retries": 0,
    "mach_header": metadata[3], "load_commands": loads, "library_ordinals": libraries,
    "rpaths": [], "dyld_chained_import_count": len(imports), "selected_imports_and_fixups": selected_imports,
    "selected_symbol_rows": symbol_rows,
    "linked_definitions": [{"address": hex(a), "symbol": functions[a]["symbol"], "line": functions[a]["line"], "instruction_count": len(functions[a]["instructions"])} for a in sorted(linked_starts)],
    "actual_caller_functions": [{"call_address": hex(a), "instruction_line": instructions[a]["line"], "function_address": hex(instructions[a]["function"]), "symbol": functions[instructions[a]["function"]]["symbol"]} for a in (0x1001b87d4, 0x1001b9b64)],
    "literal_BL_target_joins": branches, "object_body_comparisons": comparisons,
    "Error_cache_file_image": cache,
    "R01": "OPEN: exact system Swift install-name binding identified; selected runtime implementation/transitive cold/allocation/stack evidence absent",
    "R02": "OPEN: linked unconditional round16(value-witness size) reservation resolved; numeric Error size and populated metadata absent; seven-byte mangled-name length is not value size",
    "R03": "PARTIAL_RESOLVED: exact linked local definitions/branches and system install-name imports fixed; pinned toolchain core not selected; actual historical loaded system image UUID/bytes/cache identity unestablished",
    "R04": "OPEN_COST: memcpy/guard/fail linked stubs/GOT/import ordinal1 fixed to libSystem; concrete reexport/resolver/implementation/cost and safety disposition unestablished",
    "pinned_toolchain_core_selected_by_static_records": False, "B_applicable_or_authorized": False,
    "current_callee_and_safety": "STOP_incomplete", "strict_cold_eligible": False,
    "u02_u05": "Prior open dispositions; not investigated by this U01-only slice",
}
(HERE / "inspection.json").write_text(json.dumps(record, indent=2, sort_keys=True) + "\n")
(HERE / "retained-excerpts.txt").write_text("U01 linked/provider retained excerpts; original one-based archived raw line numbers.\n" + "".join(excerpts))
print(json.dumps({"baseline": BASE, "archive_files": len(archive_hashes), "context_files": len(context["files"]), "load_commands": len(loads), "rpaths": 0, "selected_imports": len(selected_imports), "toolchain_core_selected": False, "strict_cold_eligible": False}, sort_keys=True))
