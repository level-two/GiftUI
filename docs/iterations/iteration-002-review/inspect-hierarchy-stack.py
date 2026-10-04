"""Bounded static stack audit: addressed entry frames and call-graph barriers.

This is not a verified machine-code stack analyzer. It deliberately does not
convert prologue samples or unresolved control flow into a whole-stack bound.
"""
from pathlib import Path
import bisect
import hashlib
import json
import re
import subprocess

root = Path.cwd()
prefix = root / ".toolchains/nrf52840/zephyr-sdk-0.17.4/arm-zephyr-eabi/bin/arm-zephyr-eabi-"
result = {"revision": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(), "images": {},
          "method": "nm-sized function intervals, addressed objdump instructions, direct-call/external-branch reachability, entry-only allocations",
          "whole_stack_bound_established": False,
          "limitations": "Entry frames are local observations, not upper bounds. Indirect targets, recursion bounds, body stack mutations, exceptions/interrupts and caller stack require independent proof. No physical high-water or target timing."}

def registers(text, width):
    count = 0
    for value in text.split(","):
        value = value.strip()
        match = re.fullmatch(r"([rd])(\d+)-\1(\d+)", value)
        count += int(match[3]) - int(match[2]) + 1 if match else 1
    return count * width

for name, directory in (("production", "signal-analyzer-static"), ("named_roles", "spike-009-hierarchy-roles/firmware"),
                        ("snapshot_counting", "spike-010-bounded-declaration-traversal/firmware"),
                        ("clean_generation", "spike-011-clean-topology-generation/firmware")):
    build = root / ".build/nrf52840" / directory
    elf = build / "zephyr/zephyr.elf"
    symbols = subprocess.check_output([str(prefix) + "nm", "-n", "-S", str(elf)], text=True)
    disassembly = subprocess.check_output([str(prefix) + "objdump", "-d", str(elf)], text=True)
    functions = {}
    for line in symbols.splitlines():
        values = line.split()
        if len(values) != 4 or values[2] not in "TWt" or int(values[1], 16) == 0:
            continue
        address, size = int(values[0], 16), int(values[1], 16)
        item = functions.setdefault(address, {"address": address, "size": size, "symbols": [], "instructions": []})
        item["size"] = max(item["size"], size)
        item["symbols"].append(values[3])
    starts = sorted(functions)
    def owner(address):
        index = bisect.bisect_right(starts, address) - 1
        if index >= 0:
            item = functions[starts[index]]
            if address < item["address"] + item["size"]:
                return starts[index]
        return None
    for line in disassembly.splitlines():
        fields = line.strip().split("\t")
        if len(fields) < 3 or not re.fullmatch(r"[0-9a-f]+:", fields[0]):
            continue
        address = int(fields[0][:-1], 16)
        key = owner(address)
        if key is not None:
            functions[key]["instructions"].append({"address": address, "mnemonic": fields[2].strip(),
                                                   "operands": fields[3].strip() if len(fields) > 3 else ""})
    for key, item in functions.items():
        edges, indirect, unresolved = set(), [], []
        for instruction in item["instructions"]:
            mnemonic, operands = instruction["mnemonic"], instruction["operands"]
            base = mnemonic.split(".")[0]
            if base in ("bl", "blx"):
                target = re.match(r"([0-9a-f]+)\s+<", operands)
                if target:
                    called = owner(int(target[1], 16))
                    if called is None:
                        unresolved.append(instruction)
                    else:
                        edges.add(called)
                else:
                    indirect.append(instruction)
            elif base.startswith("b") and base not in ("bx", "bic", "bics", "bfi", "bfc", "bkpt"):
                target = re.match(r"([0-9a-f]+)\s+<", operands)
                if target and not key <= int(target[1], 16) < key + item["size"]:
                    called = owner(int(target[1], 16))
                    if called is None:
                        unresolved.append(instruction)
                    else:
                        edges.add(called)
            elif base == "bx" and operands not in ("lr", "r14"):
                indirect.append(instruction)
        item["edges"], item["indirect"], item["unresolved"] = edges, indirect, unresolved
        allocation = 0
        prologue = []
        for instruction in item["instructions"][:20]:
            mnemonic, operands = instruction["mnemonic"], instruction["operands"]
            base = mnemonic.split(".")[0]
            if base.startswith("b") or base in ("cbz", "cbnz", "pop", "ldmia", "vpop"):
                break
            match = re.search(r"\{([^}]+)\}", operands)
            if base == "push" or (base == "stmdb" and operands.startswith("sp!")):
                allocation += registers(match[1], 4)
                prologue.append(instruction)
            elif base == "vpush":
                allocation += registers(match[1], 8 if match[1].startswith("d") else 4)
                prologue.append(instruction)
            elif base in ("sub", "subs", "subw") and operands.startswith("sp,"):
                immediate = re.search(r"#(\d+)", operands)
                if immediate:
                    allocation += int(immediate[1])
                prologue.append(instruction)
        item["entry_allocation_bytes"], item["entry_instructions"] = allocation, prologue
    roots = [address for address, item in functions.items()
             if any("NRFEmbeddedSemanticRegionO5stage" in symbol or symbol == "giftui_spike010_derive" for symbol in item["symbols"])]
    assert roots, name
    reach, pending = set(), list(roots)
    while pending:
        address = pending.pop()
        if address not in reach:
            reach.add(address)
            pending.extend(functions[address]["edges"])
    cycles, visited, active = set(), set(), set()
    def visit(address):
        if address in active:
            cycles.add(address)
            return
        if address in visited:
            return
        visited.add(address); active.add(address)
        for next_address in functions[address]["edges"]:
            visit(next_address)
        active.remove(address)
    for address in roots:
        visit(address)
    entry = {"elf": str(elf.relative_to(root)), "sha256": hashlib.sha256(elf.read_bytes()).hexdigest(),
             "roots": [{k: functions[a][k] for k in ("address", "size", "symbols", "entry_allocation_bytes", "entry_instructions")} for a in roots],
             "reachable_function_count": len(reach),
             "direct_graph_cycle_entries": [{"address": a, "symbols": functions[a]["symbols"]} for a in sorted(cycles)],
             "indirect_calls_or_tail_branches": [{"function_symbols": functions[a]["symbols"], **instruction}
                                                    for a in sorted(reach) for instruction in functions[a]["indirect"]],
             "unresolved_direct_edges": [{"function_symbols": functions[a]["symbols"], **instruction}
                                          for a in sorted(reach) for instruction in functions[a]["unresolved"]],
             "largest_observed_entry_allocations": [{k: functions[a][k] for k in ("address", "size", "symbols", "entry_allocation_bytes", "entry_instructions")}
                                                     for a in sorted(reach, key=lambda a: functions[a]["entry_allocation_bytes"], reverse=True)[:5]],
             "stack_config": [line for line in (build / "zephyr/.config").read_text().splitlines() if "STACK_SIZE=" in line]}
    result["images"][name] = entry
object_file = root / ".build/nrf52840/spike-010-bounded-declaration-traversal/LoweredBody.o"
sections = subprocess.check_output([str(prefix) + "readelf", "-SW", str(object_file)], text=True)
result["compiler_stack_section_probe"] = {"object": str(object_file.relative_to(root)),
    "sha256": hashlib.sha256(object_file.read_bytes()).hexdigest(), "requested_flags": ["-Xllvm", "-stack-size-section"],
    "stack_sizes_present": bool(re.search(r"\s\.stack_sizes\s", sections)),
    "section_listing_sha256": hashlib.sha256(sections.encode()).hexdigest(),
    "section_listing_line_count": len(sections.splitlines()),
    "stack_related_section_lines": [line for line in sections.splitlines() if "stack" in line]}
path = root / "docs/iterations/iteration-002-review/evidence/20-static-stack-inspection.json"
path.write_text(json.dumps(result, indent=2) + "\n")
print({name: {"reachable_functions": entry["reachable_function_count"], "indirect_sites": len(entry["indirect_calls_or_tail_branches"]),
              "cycle_entries": len(entry["direct_graph_cycle_entries"]), "largest_entry_bytes": entry["largest_observed_entry_allocations"][0]["entry_allocation_bytes"]}
       for name, entry in result["images"].items()})
