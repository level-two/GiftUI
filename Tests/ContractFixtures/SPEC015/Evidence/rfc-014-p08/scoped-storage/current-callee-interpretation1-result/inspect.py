"""Read retained text/JSON only; never compile, decode modules, or run a fixture.

Run from the repository root with Python's standard library. Outputs are derived
inspection records beside this file, not replacements for any raw receipt.
Reference closure is intentionally conservative: a referenced closure is included
even when not directly applied; no path feasibility or witness devirtualization
is inferred. Object relocations distinguish code branches from data references.
"""
import collections
import gzip
import hashlib
import json
import pathlib
import re

HERE = pathlib.Path(__file__).resolve().parent
RAW = HERE.parent / "current-callee-collection1-result/raw"
PREP = HERE.parent / "current-callee-readiness1-preparation"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write(name, value):
    payload = (json.dumps(value, indent=2, sort_keys=True) + "\n").encode()
    if name.endswith(".gz"):
        (HERE / name).write_bytes(gzip.compress(payload, mtime=0))
    else:
        (HERE / name).write_bytes(payload)


functions = {}
last_label = ""
current = None
for line_no, line in enumerate((RAW / "actual-host.sil").read_text().splitlines(), 1):
    if line.startswith("// ") and not line.startswith(("// Isolation:", "// %")):
        last_label = line[3:]
    match = re.match(r"sil .*?@([^ :]+) :", line)
    if match:
        current = {"symbol": match[1], "label": last_label, "line": line_no,
                   "header": line, "blocks": 0, "refs": [], "calls": [],
                   "operations": [], "definitions": {}}
        functions[match[1]] = current
    elif current is not None:
        if re.match(r"bb\d+", line):
            current["blocks"] += 1
        ref = re.search(r"(%\d+) = (?:function_ref|dynamic_function_ref|previous_dynamic_function_ref) @([^ :]+)", line)
        if ref:
            current["refs"].append({"line": line_no, "value": ref[1], "target": ref[2]})
        definition = re.match(r"\s*(%\d+) = (.*)", line)
        if definition:
            current["definitions"][definition[1]] = {"line": line_no, "text": definition[2].split(" // ")[0]}
        call = re.search(r"\b(apply|try_apply|begin_apply|partial_apply)\b(?: \[[^\]]+\])* (%\d+)", line)
        if call:
            current["calls"].append({"line": line_no, "kind": call[1], "value": call[2], "text": line.strip()})
        if re.search(r"\b(alloc_box|alloc_ref|alloc_existential_box|alloc_stack|dealloc_stack|strong_retain|strong_release|retain_value|release_value|destroy_addr|destroy_value|copy_addr|copy_value|mark_dependence|mark_dependence_addr|witness_method|class_method|unchecked_ref_cast|unconditional_checked_cast|builtin)\b", line):
            # Keep allocation, lifetime, ownership and indirect-dispatch sites;
            # scalar builtins are not listed except allocation/destruction.
            if "builtin" not in line or re.search(r'"(alloc|dealloc|destroy|copy)', line):
                current["operations"].append({"line": line_no, "text": line.strip()})
        if line.startswith("} // end sil function"):
            current["end_line"] = line_no
            current = None

indexes = json.loads((RAW / "boundary-physical-index.json").read_text())
serialized = collections.defaultdict(list)
for module, index in indexes.items():
    for function in index["functions"]:
        serialized[function["name"]].append({"module": module, **function})

object_functions = {}
symbols = collections.defaultdict(list)
objects = []
for path in sorted(RAW.glob("*-symbols.stdout")):
    module = path.name.removesuffix("-symbols.stdout")
    for line_no, line in enumerate(path.read_text().splitlines(), 1):
        match = re.match(r"\s*(?:([0-9a-fA-F]+)\s+)?([A-Za-z?])\s+(\S+)$", line)
        if match:
            symbols[match[3]].append({"module": module, "line": line_no, "type": match[2], "address": match[1]})
    disassembly = RAW / (module + "-disassembly.stdout")
    fn = None
    for line_no, line in enumerate(disassembly.read_text().splitlines(), 1):
        match = re.match(r"([0-9a-fA-F]+) <(.+)>:$", line)
        if match:
            fn = {"module": module, "symbol": match[2], "line": line_no,
                  "address": match[1], "relocations": [], "indirect_branches": [], "direct_instruction_branches": [], "stack_adjustments": []}
            object_functions[(module, match[2])] = fn
        reloc = re.search(r"([0-9a-fA-F]+):\s+(ARM64_RELOC_\S+)\s+(\S+)", line)
        if fn is not None and reloc:
            fn["relocations"].append({"line": line_no, "address": reloc[1], "kind": reloc[2], "target": reloc[3]})
        if fn is not None and re.search(r"\b(?:blr|br|blraa|braa)\s+x\d+", line):
            fn["indirect_branches"].append({"line": line_no, "text": line.strip()})
        direct_branch = re.search(r"\b(bl|b)\s+0x[0-9a-f]+ <([^>]+)>", line)
        if fn is not None and direct_branch:
            fn["direct_instruction_branches"].append({"line": line_no, "kind": direct_branch[1], "target": direct_branch[2]})
        if fn is not None and re.search(r"\b(?:sub|add|mov|stp|str|ldp|ldr)\b.*(?:\bsp\b|\[sp)", line):
            fn["stack_adjustments"].append({"line": line_no, "text": line.strip()})
    objects.append({"module": module, "symbols_sha256": digest(path), "disassembly_sha256": digest(disassembly)})

roots = [f["symbol"] for f in functions.values() if f["label"] in (
    "p08CounterHost(write:backing:)", "p08CounterScopedStorage(backing:write:)",
    "p08CounterRoute(write:backing:)")]
assert len(roots) == 3
seen, parents, queue = set(), {}, collections.deque(roots)
while queue:
    symbol = queue.popleft()
    if symbol in seen:
        continue
    seen.add(symbol)
    fn = functions.get(symbol)
    if fn is not None:
        for edge in fn["refs"]:
            if edge["target"] not in seen:
                parents.setdefault(edge["target"], {"caller": symbol, "line": edge["line"]})
                queue.append(edge["target"])

nodes, edges, calls, operations = [], [], [], []
for symbol in sorted(seen):
    fn = functions.get(symbol)
    indexed = serialized.get(symbol, [])
    obj = [x for x in symbols.get("_" + symbol, []) if x["type"].upper() != "U"]
    nodes.append({"symbol": symbol, "label": fn["label"] if fn else None,
                  "sil_line": fn["line"] if fn else None, "sil_blocks": fn["blocks"] if fn else 0,
                  "serialized": [{k: v for k, v in x.items() if k in ("module", "function_id", "offset_bits", "serialized_kind", "basic_blocks", "demangled")} for x in indexed],
                  "object_definitions": obj, "first_parent": parents.get(symbol)})
    if fn is None:
        continue
    refs = {ref["value"]: ref for ref in fn["refs"]}
    for edge in fn["refs"]:
        edges.append({"caller": symbol, **edge})
    for call in fn["calls"]:
        direct = refs.get(call["value"])
        calls.append({"caller": symbol, **call, "direct_target": direct["target"] if direct else None,
                      "callee_definition": None if direct else fn["definitions"].get(call["value"])})
    operations.extend({"caller": symbol, **op} for op in fn["operations"])

# Object reference closure uses a (module, symbol) key: OUTLINED_FUNCTION numbers are local
# to an object and must never be resolved by matching another object's number.
object_queue = collections.deque()
object_root_joins = []
for root in roots:
    matches = [(obj["module"], "_" + root) for obj in symbols.get("_" + root, []) if obj["type"].upper() != "U"]
    object_root_joins.append({"sil_symbol": root, "exact_disassembly_headers": [list(x) for x in matches if x in object_functions]})
    object_queue.extend(matches)
for node in nodes:
    if not node["sil_blocks"]:
        for obj in node["object_definitions"]:
            object_queue.append((obj["module"], "_" + node["symbol"]))
object_seen = set()
while object_queue:
    key = object_queue.popleft()
    if key in object_seen or key not in object_functions:
        continue
    object_seen.add(key)
    fn = object_functions[key]
    for edge in fn["direct_instruction_branches"]:
        if "+0x" not in edge["target"] and (key[0], edge["target"]) in object_functions:
            object_queue.append((key[0], edge["target"]))
    for edge in fn["relocations"]:
        if edge["kind"] == "ARM64_RELOC_ADDEND":
            continue
        local = (key[0], edge["target"])
        if local in object_functions:
            object_queue.append(local)
        else:
            for obj in symbols.get(edge["target"], []):
                if obj["type"].upper() != "U":
                    object_queue.append((obj["module"], edge["target"]))

source = json.loads((PREP / "source42.json").read_text())
drift = [x["path"] for x in source if digest(pathlib.Path(x["path"])) != x["sha256"]]
assert not drift
required = json.loads((RAW / "required-bodies.json").read_text())
terminal = json.loads((RAW / "terminal.json").read_text())
recipe = json.loads((PREP / "collection-recipe.json").read_text())
stages = {stage["name"]: stage for stage in terminal["stages"]}
privacy = []
for control in recipe["privacy_controls"]:
    stage = stages[control["name"]]
    privacy.append({"name": control["name"], "expected": stage["expected"],
                    "actual_exit": stage["actual_exit"], "classified_errors": stage["errors"],
                    "recorded_passed": stage["passed"], "raw": stage["raw"]})
preserved = json.loads((PREP / "preserved-dirty-files.json").read_text())["files"]
assert all(digest(pathlib.Path(path)) == expected for path, expected in preserved.items())
write("privacy-control-join.json", privacy)
required_rows = []
for entry in required:
    match = entry["matches"][0]
    fn = functions.get(match["name"])
    required_rows.append({"module": entry["target"]["module"], "symbol": match["name"],
                          "label": match["demangled"], "serialized_blocks": match["basic_blocks"],
                          "serialized_kind": match["serialized_kind"],
                          "sil_line": fn["line"] if fn else None,
                          "sil_blocks": fn["blocks"] if fn else 0,
                          "reference_closure": match["name"] in seen,
                          "specialization_prefix_candidates_in_closure": [s for s in sorted(seen) if s.startswith(match["name"]) and s != match["name"]]})
node_ids = {node["symbol"]: f"S{i:04d}" for i, node in enumerate(nodes, 1)}
root_coverage = []
for root in roots:
    reached, pending = set(), [root]
    while pending:
        item = pending.pop()
        if item in reached:
            continue
        reached.add(item)
        pending.extend(e["target"] for e in functions.get(item, {}).get("refs", []))
    root_coverage.append({"root": node_ids[root], "nodes": sorted(node_ids[x] for x in reached),
                          "bodyless": sum(not functions.get(x, {}).get("blocks", 0) for x in reached)})
for node in nodes:
    node["id"] = node_ids[node["symbol"]]
    if node["first_parent"]:
        node["first_parent"]["caller"] = node_ids[node["first_parent"]["caller"]]
for row in edges + calls + operations:
    row["caller"] = node_ids[row["caller"]]
for row in edges:
    row["target"] = node_ids[row["target"]]
for row in calls:
    if row["direct_target"]:
        row["direct_target"] = node_ids[row["direct_target"]]
    # The immutable source line supplies the exact full instruction/type.
    del row["text"]
write("sil-inventory.json.gz", {"roots": root_coverage, "nodes": nodes, "references": edges, "calls": calls, "ownership_lifetime_dispatch_operations": operations})
object_external_branches = []
for key in sorted(object_seen):
    for edge in object_functions[key]["relocations"]:
        if edge["kind"] == "ARM64_RELOC_BRANCH26" and not any(
            (obj["module"], edge["target"]) in object_functions
            for obj in symbols.get(edge["target"], []) if obj["type"].upper() != "U"
        ) and (key[0], edge["target"]) not in object_functions:
            object_external_branches.append({"module": key[0], "caller": key[1], **edge})
write("object-inventory.json.gz", {"objects": objects, "root_joins": object_root_joins,
                              "reference_closure_from_roots_and_bodyless_sil_definitions": [object_functions[k] for k in sorted(object_seen)],
                              "external_branch_sites_without_exact_disassembly_header": object_external_branches})
write("required-body-join.json", required_rows)
summary = {"input_sil_sha256": digest(RAW / "actual-host.sil"), "source42_hashes_match": not drift,
           "five_preexisting_dirty_hashes_match": True,
           "privacy_recorded_passes": sum(x["recorded_passed"] for x in privacy),
           "privacy_exit_zero": sum(x["actual_exit"] == 0 for x in privacy),
           "privacy_exit_nonzero": sum(x["actual_exit"] != 0 for x in privacy),
           "sil_function_records": len(functions), "sil_records_with_blocks": sum(f["blocks"] > 0 for f in functions.values()),
           "serialized_indexes": len(indexes), "serialized_function_records": sum(len(x["functions"]) for x in indexes.values()),
           "required_bodies": len(required), "objects": len(objects), "object_function_records": len(object_functions),
           "roots": [{"symbol": x, "line": functions[x]["line"], "label": functions[x]["label"]} for x in roots],
           "reference_closure_nodes": len(nodes), "reference_sites": len(edges), "call_sites": len(calls),
           "indirect_call_sites_including_closure_construction": sum(x["direct_target"] is None for x in calls),
           "bodyless_nodes": sum(not x["sil_blocks"] for x in nodes),
           "bodyless_with_serialized_body": sum(not x["sil_blocks"] and any(y["basic_blocks"] for y in x["serialized"]) for x in nodes),
           "bodyless_with_object_definition": sum(not x["sil_blocks"] and bool(x["object_definitions"]) for x in nodes),
           "object_closure_functions": len(object_seen),
           "object_closure_indirect_branches": sum(len(object_functions[x]["indirect_branches"]) for x in object_seen),
           "object_closure_external_branch_sites": len(object_external_branches),
           "object_closure_external_branch_symbols": len({x["target"] for x in object_external_branches}),
           "required_exact_in_reference_closure": sum(x["reference_closure"] for x in required_rows),
           "required_exact_with_sil_blocks": sum(x["sil_blocks"] > 0 for x in required_rows),
           "required_with_specialization_prefix_candidates_in_closure": sum(bool(x["specialization_prefix_candidates_in_closure"]) for x in required_rows),
           "interpretation_status": "STOP_required_current_callee_and_safety_not_proved",
           "strict_cold_eligible": False,
           "method_limit": "Conservative reference closure; no feasible-path, indirect-target, metadata/value-witness, linked-branch, allocator, cost or safety completion claim."}
write("inspection-summary.json", summary)
print(json.dumps(summary, indent=2))
