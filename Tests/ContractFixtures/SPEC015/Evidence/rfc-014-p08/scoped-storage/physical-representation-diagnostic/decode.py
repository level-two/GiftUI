#!/usr/bin/env python3
"""Decode only exact assessment scalar roots with the unchanged strict helper."""
import hashlib, importlib.util, json, pathlib, sys
packet = pathlib.Path(__file__).resolve().parent
prepared = json.loads((packet / "prepared.json").read_text())
helper = pathlib.Path("scripts/contracts/p08_layout_facts.py").resolve()
assert hashlib.sha256(helper.read_bytes()).hexdigest() == prepared["pinned_inputs"][str(helper)]
spec = importlib.util.spec_from_file_location("p08_layout_facts", helper)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
path = pathlib.Path(prepared["scratch"]) / "P08CounterRuntime.o"
elf = module.ELF(path.read_bytes())
roots = json.loads((packet / "roots.json").read_text())
actual = [s for s in elf.symbols if s["name"].startswith("giftui_p08_assess_")]
assert len(actual) == len(roots) and {s["name"] for s in actual} == set(roots), "exact assessment inventory"
assert all(s["binding"] == 1 and s["type"] == 2 and s["visibility"] == 0 and 0 < s["owner"] < len(elf.sections) for s in actual), "defined global function roots only"
facts, errors = {}, {}
for name, identity in roots.items():
    try:
        facts[name] = dict(**identity, **elf.constant(name))
    except ValueError as error:
        errors[name] = str(error)
output = dict(diagnostic_only=True, acceptance_receipt=False,
    object_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
    helper_sha256=hashlib.sha256(helper.read_bytes()).hexdigest(),
    expected_roots=len(roots), decoded_roots=len(facts), facts=facts, errors=errors)
(path.parent / "type-layout-facts.json").write_text(json.dumps(output, indent=2) + "\n")
print(json.dumps(dict(decoded=len(facts), errors=len(errors), diagnostic_only=True)))
raise SystemExit(bool(errors))
