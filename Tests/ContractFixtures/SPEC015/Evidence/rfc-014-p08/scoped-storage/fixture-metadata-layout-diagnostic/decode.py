#!/usr/bin/env python3
"""Diagnostic-only strict scalar proof, followed by independent checked packing."""
import hashlib
import importlib.util
import json
import pathlib

packet = pathlib.Path(__file__).resolve().parent
prepared = json.loads((packet / "prepared.json").read_text())
sha = lambda p: hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
for path, expected in prepared["pinned_inputs"].items():
    assert sha(path) == expected, "pinned input drift: " + path
assert sha(packet / "roots.json") == prepared["roots_sha256"]
helper = pathlib.Path("scripts/contracts/p08_layout_facts.py").resolve()
spec = importlib.util.spec_from_file_location("p08_layout_facts", helper)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
path = pathlib.Path(prepared["scratch"]) / "P08CounterRuntime.o"
elf = module.ELF(path.read_bytes())
roots = json.loads((packet / "roots.json").read_text())
actual = [s for s in elf.symbols if s["name"].startswith("giftui_p08_fixture_diagnostic_")]
facts, errors = {}, {}
try:
    module.require(len(roots) == 31 and len(actual) == len(roots)
                   and {s["name"] for s in actual} == set(roots), "exact 31-root inventory")
    # Swift C exports may be DEFAULT or PROTECTED. Record the actual visibility;
    # hidden/internal, weak, undefined and nonfunction roots remain forbidden.
    module.require(all(s["binding"] == 1 and s["type"] == 2
                       and s["visibility"] in (0, 3)
                       and 0 < s["owner"] < len(elf.sections) for s in actual),
                   "defined global exported function roots only")
    for name, identity in roots.items():
        try:
            facts[name] = dict(**identity, **elf.constant(name))
        except ValueError as error:
            errors[name] = str(error)
except ValueError as error:
    errors["inventory"] = str(error)

packing = None
if not errors:
    try:
        value = lambda label: facts["giftui_p08_fixture_diagnostic_" + label]["value"]
        cursor, maximum = 0, 1
        rows = []
        for index, (label, type_name) in enumerate(prepared["types"]):
            size, stride, alignment = (value(label + "_" + field)
                                       for field in ("size", "stride", "alignment"))
            module.require(alignment > 0 and alignment & (alignment - 1) == 0,
                           "invalid measured alignment")
            module.require(0 <= size <= stride and stride % alignment == 0,
                           "invalid measured size/stride")
            offset = module.checked_add(cursor, (-cursor) % alignment)
            module.require(value(label + "_offset") == offset, "offset derivation mismatch")
            end = module.checked_add(offset, stride)
            rows.append(dict(index=index, type=type_name, count=1, size=size,
                             stride=stride, alignment=alignment, offset=offset, end=end))
            cursor, maximum = end, max(maximum, alignment)
        extent = module.checked_add(cursor, (-cursor) % maximum)
        module.require(value("cursor") == cursor
                       and value("maximum_alignment") == maximum
                       and value("rounded_extent") == extent, "summary derivation mismatch")
        packing = dict(rows=rows, cursor=cursor, maximum_alignment=maximum,
                       rounded_extent=extent, donor_bytes=34720, donor_alignment=8,
                       fits_declared_donor=(extent <= 34720 and 8 % maximum == 0),
                       measures_existing_baseline=True,
                       proposed_linear_baseline_and_custody_measured=False)
    except ValueError as error:
        errors["packing"] = str(error)

output = dict(diagnostic_only=True, acceptance_receipt=False,
              object_sha256=sha(path), helper_sha256=sha(helper),
              expected_roots=31, decoded_roots=len(facts), actual_root_symbols=actual,
              facts=facts, errors=errors, packing=packing)
(path.parent / "fixture-metadata-layout-facts.json").write_text(json.dumps(output, indent=2) + "\n")
print(json.dumps(dict(decoded=len(facts), errors=len(errors), packing=packing,
                     diagnostic_only=True)))
raise SystemExit(bool(errors) or packing is None or not packing["fits_declared_donor"])
