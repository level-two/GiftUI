#!/usr/bin/env python3
"""Link or hand off the two existing P08 target counter object recipes."""
import argparse
import hashlib
import json
import pathlib
import shlex
import subprocess

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
    # Each object remains in its actual owner module; no Swift source flattening.
    (output / 'counter-objects.cmake').write_text('set(giftui_counter_objects\n' +
        ''.join('    "' + str(path) + '"\n' for path in objects) + ')\n')
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
