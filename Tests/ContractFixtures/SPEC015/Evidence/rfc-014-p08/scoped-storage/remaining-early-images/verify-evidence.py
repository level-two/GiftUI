#!/usr/bin/env python3
"""Compiler-free documentary verification; never runs a target or build tool."""
import hashlib
import json
import lzma
import pathlib
import tarfile

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[6]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(name):
    return json.loads((HERE / name).read_text())


packet = read('packet-files.json')
for item in packet:
    data = (HERE / item['path']).read_bytes()
    assert len(data) == item['bytes'] and sha(data) == item['sha256'], item['path']
manifest = read('image-manifest.json')
archive = HERE / manifest['archive']['path']
assert sha(archive.read_bytes()) == manifest['archive']['sha256']
with tarfile.open(archive, 'r:xz') as tar:
    members = {m.name: m for m in tar.getmembers()}
    assert len(members) == len(manifest['members'])
    for item in manifest['members']:
        data = tar.extractfile(members[item['path']]).read()
        assert len(data) == item['bytes'] and sha(data) == item['sha256'], item['path']
for item in manifest['binaries']:
    path = ROOT / item['path']
    assert path.stat().st_size == item['bytes'] and sha(path.read_bytes()) == item['sha256']
for item in read('nrf-compiled-input-identities.json')['identities']:
    path = ROOT / item['path']
    assert path.stat().st_size == item['bytes'] and sha(path.read_bytes()) == item['sha256'], item['path']
commands = lzma.decompress((HERE / 'nrf-compile-commands.json.xz').read_bytes())
assert sha(commands) == read('nrf-compiled-input-identities.json')['compile_commands_sha256']
disassembly = lzma.decompress((HERE / 'nrf-disassembly.txt.xz').read_bytes())
assert sha(disassembly) == read('nrf-disassembly-command.json')['output_sha256']
for item in read('entry-and-frame-symbols.json')['observations']:
    assert sha((HERE / item['output']).read_bytes()) == item['output_sha256']
caller = json.loads((HERE.parent / 'so01-current-callers.json').read_text())
assert len(caller['files']) == 176
for item in caller['files']:
    assert sha((ROOT / item['path']).read_bytes()) == item['sha256'], item['path']
symbols = read('entry-and-frame-symbols.json')['observations']
frame = next(x for x in symbols if x['output'] == 'scoped-storage-complete.log')
assert frame['symbol']['value'] & ~1 == 0x214f4
assert frame['symbol']['name'] == '$e17P08CounterRuntime28counterExerciseScopedStorage7backing5writeSiSwSg_s5Int32Vs6UInt16V_A3ISPys5UInt8VGSgSitXCSgtF'
body = (HERE / frame['output']).read_text()
assert 'sub.w\tsp, sp, #29952' in body and 'sub\tsp, #108' in body
assert 'stmdb\tsp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}' in body
assert 29952 + 108 + 9 * 4 == 30096 > 27648
assert 'bl\t214f4' in (HERE / 'swift-entry.log').read_text()
assert 'bl\t5c206' in (HERE / 'main.log').read_text()
print(f'PASS: {len(packet)} packet files, {len(manifest["members"])} archive members, '
      '2 ELF identities, 681 compiled-input identities, 176 caller hashes; '
      'exact symbol/entry/prologue lower-bound facts. No compiler or target execution.')
