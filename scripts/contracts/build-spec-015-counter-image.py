#!/usr/bin/env python3
"""Link or hand off the two existing P08 target counter object recipes."""
import argparse
import hashlib
import json
import pathlib
import re
import shlex
import subprocess
from p08_layout_facts import ALL_SYMBOLS

ROOT = pathlib.Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--profile', required=True, choices=('raspberry-pi-armv6', 'nrf52840-embedded'))
parser.add_argument('--counter-build', required=True, type=pathlib.Path)
parser.add_argument('--output', required=True, type=pathlib.Path)
parser.add_argument('--destination-json', type=pathlib.Path)
args = parser.parse_args()
base = args.counter_build.resolve()
output = args.output.resolve()
target_root = ROOT / ('.build/raspberry-pi' if args.profile == 'raspberry-pi-armv6' else '.build/nrf52840')
assert base.is_relative_to(target_root) and output.is_relative_to(target_root), 'target output root mismatch'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

receipt_path = base / 'result.json'
receipt = json.loads(receipt_path.read_text())
assert receipt['selected_host_profile'] == args.profile
assert receipt['raster_realization'] == 'tiled'
assert receipt['collection_complete'] is True and receipt['passed'] is True, 'complete successful counter collection required'
assert all(check['passed'] for check in receipt['checks'])
for name, expected in receipt['inputs'].items():
    assert digest(ROOT / name) == expected, 'stale counter input: ' + name
for name, expected in receipt['artifacts'].items():
    assert digest(base / name) == expected['sha256'], 'stale counter artifact: ' + name
compiler = ROOT / receipt['compiler']
assert digest(compiler) == receipt['compiler_sha256']
objects = [pathlib.Path(line) for line in (base / 'objects.list').read_text().splitlines()]
assert objects and len(objects) == len(set(objects))
for path in objects:
    assert path.is_relative_to(target_root) and path.suffix == '.o' and path.is_file(), path
    if path.parent != base:
        # The sole reused object is the pinned portable declaration module.
        assert path.name == 'GiftUI.o'
        core = json.loads((path.parent / 'result.json').read_text())
        assert digest(path) == core['artifacts']['GiftUI.o']['sha256']
        assert core['compiler_sha256'] == receipt['compiler_sha256']
output.mkdir(parents=True, exist_ok=True)
record = dict(profile=args.profile, counter_build=str(base.relative_to(ROOT)),
              counter_receipt_sha256=digest(receipt_path), compiler_sha256=digest(compiler),
              objects={str(path.relative_to(ROOT)): digest(path) for path in objects},
              execution='not executed; early image link only')
if args.profile == 'nrf52840-embedded':
    facts_path = base / 'so07-layout-facts.json'
    facts = json.loads(facts_path.read_text())
    assert facts['compiler_sha256'] == receipt['compiler_sha256']
    assert facts['artifact_sha256'] == digest(base / 'P08CounterRuntime.o')
    assert digest(facts_path) == receipt['artifacts']['so07-layout-facts.json']['sha256']
    # Rebuild the same selected sources with the supported firmware flags.
    # The route objects remain frozen evidence; none is linked into this image.
    core_path = next(path.parent for path in objects if path.name == 'GiftUI.o')
    core_receipt = json.loads((core_path / 'result.json').read_text())
    core_commands = [line for line in (core_path / 'commands.txt').read_text().splitlines()
                     if '-module-name GiftUI ' in line and '-emit-module' in line]
    assert len(core_commands) == 1
    commands = [core_commands[0], *receipt['commands']]
    owners = {}
    source_hashes = {}
    for command in commands:
        parts = shlex.split(command)
        if '-emit-module' not in parts or '-emit-object' not in parts:
            continue  # Failed negative controls are not image inputs.
        owner = parts[parts.index('-module-name') + 1]
        assert re.fullmatch(r'[A-Za-z0-9_]+', owner) and owner not in owners
        sources = [pathlib.Path(part) for part in parts if part.endswith('.swift')]
        assert sources
        for source in sources:
            name = str(source.relative_to(ROOT))
            expected = (core_receipt['inputs'] if owner == 'GiftUI' else receipt['inputs']).get(name)
            if expected is None:
                assert source.parent == base and source.name in receipt['artifacts']
                expected = receipt['artifacts'][source.name]['sha256']
            assert digest(source) == expected, 'stale image source: ' + name
            source_hashes[name] = expected
        owners[owner] = sources
    assert len(owners) == 24 and 'P08CounterRuntime' in owners
    imports = {}
    for owner, sources in owners.items():
        dependencies = set()
        for source in sources:
            if source.read_text().startswith('#if !hasFeature(Embedded)\n'):
                continue  # The existing Dynamic-only file is wholly inactive.
            text = source.read_text().replace(
                '#if !hasFeature(Embedded)\nimport GiftUIRuntimeDynamic\n#endif', '')
            dependencies.update(re.findall(r'^\s*(?:@[^\n]+?\s+)?import\s+(\w+)', text, re.M))
        assert dependencies <= owners.keys(), (owner, dependencies - owners.keys())
        imports[owner] = sorted(dependencies)
    macro = pathlib.Path(core_receipt['macro_tool'])
    if not macro.is_absolute():
        macro = ROOT / macro
    assert digest(macro) == core_receipt['macro_tool_sha256']
    lines = ['set(giftui_counter_owners ' + ' '.join(owners) + ')',
             'set(giftui_counter_macro "' + str(macro) + '#GiftUIMacros")',
             'set(giftui_counter_layout_symbols ' + ' '.join(ALL_SYMBOLS) + ')']
    for owner, sources in owners.items():
        lines.append('set(giftui_counter_sources_' + owner + '\n' +
                     ''.join('    "' + str(source) + '"\n' for source in sources) + ')')
        lines.append('set(giftui_counter_imports_' + owner + ' ' + ' '.join(imports[owner]) + ')')
    (output / 'counter-sources.cmake').write_text('\n'.join(lines) + '\n')
    record.update(source_hashes=source_hashes, owners=list(owners), imports=imports,
                  core_receipt_sha256=digest(core_path / 'result.json'),
                  core_commands_sha256=digest(core_path / 'commands.txt'),
                  macro_tool=str(macro.relative_to(ROOT)), macro_tool_sha256=digest(macro),
                  source_handoff_sha256=digest(output / 'counter-sources.cmake'),
                  layout_facts=str(facts_path.relative_to(ROOT)), layout_facts_sha256=digest(facts_path),
                  layout_symbols=list(ALL_SYMBOLS),
                  object_use='identity verification only; fresh firmware objects required')
else:
    assert args.destination_json is not None, 'existing static SDK destination is required'
    destination_path = args.destination_json.resolve()
    destination = json.loads(destination_path.read_text())
    assert destination['target'] == 'armv6-unknown-linux-gnueabihf'
    assert destination['sdk'] == receipt['target_flags'][receipt['target_flags'].index('-sdk') + 1]
    record['destination_json'] = str(destination_path.relative_to(ROOT))
    record['destination_sha256'] = digest(destination_path)
    record['destination_link_flags'] = destination['extra-swiftc-flags']
    main = output / 'Main.swift'
    main.write_text('import P08CounterRuntime\n@main struct Main { static func main() { precondition(p08CounterRoute() > 0) } }\n')
    command = [str(compiler), *receipt['target_flags'], *destination['extra-swiftc-flags'], str(main), *map(str, objects),
               '-static-stdlib', '-Xlinker', '-Map', '-Xlinker', str(output / 'counter.map'),
               '-o', str(output / 'counter.elf')]
    record['command'] = shlex.join(command)
    (output / 'command.txt').write_text(record['command'] + '\n')
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    (output / 'link.log').write_text(result.stdout + result.stderr)
    record['exit_status'] = result.returncode
    (output / 'input-receipt.json').write_text(json.dumps(record, indent=2) + '\n')
    if result.returncode:
        raise SystemExit(result.stdout + result.stderr)
    record['elf_sha256'] = digest(output / 'counter.elf')
    record['map_sha256'] = digest(output / 'counter.map')
(output / 'input-receipt.json').write_text(json.dumps(record, indent=2) + '\n')
print('COUNTER_INPUTS=' + str(output / 'input-receipt.json'))
