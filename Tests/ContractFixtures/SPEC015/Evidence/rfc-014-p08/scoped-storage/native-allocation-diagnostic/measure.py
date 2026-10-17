#!/usr/bin/env python3
"""Prepare exact-object diagnostic links; run matched windows only with --run.

This produces observations, not an allocation/stack conformance verdict.
"""
import argparse
import hashlib
import json
import pathlib
import platform
import shlex
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[7]
HERE = pathlib.Path(__file__).resolve().parent
RETAINED = {'dynamic': '.build/contracts/p08-counter-dyq5u3vb',
            'static': '.build/contracts/p08-counter-w700p_zi'}


def digest(path):
    return hashlib.sha256(pathlib.Path(path).read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True, type=pathlib.Path)
    parser.add_argument('--run', action='store_true', help='execute both matched links in three fresh processes each')
    args = parser.parse_args()
    if pathlib.Path.cwd().resolve() != ROOT:
        parser.error('run from repository root')
    out = args.output.resolve()
    if ROOT / '.build/contracts' not in out.parents or out.exists():
        parser.error('output must be a NEW directory under .build/contracts/')
    out.mkdir(parents=True)
    commands = []

    def execute(argv, name):
        commands.append({'argv': list(map(str, argv)), 'log': name})
        with (out / name).open('wb') as log:
            subprocess.run(list(map(str, argv)), check=True, stdout=log, stderr=subprocess.STDOUT)

    manifest = {'purpose': 'diagnostic-public-allocation-observations-not-conformance',
                'platform': platform.platform(), 'profiles': {}, 'sources': {},
                'environment': {k: v for k, v in __import__('os').environ.items()
                                if k.startswith(('DYLD_', 'Malloc', 'SWIFT_'))}}
    unexpected = {k: v for k, v in manifest['environment'].items() if (k, v) != ('MallocNanoZone', '0')}
    if unexpected:
        raise SystemExit('remove unexpected DYLD_ / Malloc / SWIFT_ environment overrides first')
    for source in HERE.glob('*'):
        if source.is_file():
            manifest['sources'][str(source.relative_to(ROOT))] = digest(source)
    clang = subprocess.check_output(['xcrun', '--find', 'clang'], text=True).strip()
    manifest['clang'] = {'path': clang, 'sha256': digest(clang)}
    flags = [clang, '-std=c11', '-O1', '-fno-omit-frame-pointer', '-fno-optimize-sibling-calls',
             '-fno-typed-memory-operations-experimental', '-Wall', '-Wextra', '-Werror']
    dylib = out / 'libP08AllocationObserver.dylib'
    execute(flags + ['-dynamiclib', '-Wl,-install_name,@rpath/libP08AllocationObserver.dylib', HERE / 'AllocationObserver.c', '-o', dylib], 'observer-build.log')
    library = ['-L' + str(out), '-lP08AllocationObserver', '-Wl,-rpath,@executable_path']
    execute(flags + ['-DVALIDATE_ONLY', HERE / 'Driver.c'] + library + ['-o', out / 'validate'], 'validation-build.log')
    execute([out / 'validate'], 'validation.log')
    validation = (out / 'validation.log').read_text()
    if 'VALIDATION failures=0' not in validation or 'direct_zone_callback expected=0 bypass=1' not in validation:
        raise SystemExit('missing positive/negative validation controls')
    driver = out / 'Driver.o'
    execute(flags + ['-c', HERE / 'Driver.c', '-o', driver], 'driver-build.log')
    for profile, retained in RETAINED.items():
        receipt_path = ROOT / retained / 'result.json'
        receipt = json.loads(receipt_path.read_text())
        stale = [p for p, h in receipt['inputs'].items() if not (ROOT / p).is_file() or digest(ROOT / p) != h]
        if stale:
            raise SystemExit(f'{profile}: stale inputs {stale}')
        compiler = ROOT / receipt['compiler']
        if digest(compiler) != receipt['compiler_sha256']:
            raise SystemExit(f'{profile}: compiler changed')
        matches = [c for c in receipt['commands'] if 'Main.swift' in c and ' -o ' in c]
        if len(matches) != 1:
            raise SystemExit(f'{profile}: ambiguous retained link')
        original = shlex.split(matches[0])
        objects = [pathlib.Path(x) for x in original if x.endswith('.o')]
        if len(objects) != 25 or len(set(objects)) != 25:
            raise SystemExit(f'{profile}: expected 25 exact objects')
        object_receipts = {}
        for obj in objects:
            owner_receipt = obj.parent / 'result.json'
            owner = json.loads(owner_receipt.read_text())
            expected_owner = (digest(receipt_path) if obj.parent == receipt_path.parent else
                              receipt['host_receipt_sha256'] if obj.parent == (ROOT / receipt['host_build']).resolve() else
                              receipt['core_receipt_sha256'])
            artifact = owner['artifacts'][obj.name]
            if digest(owner_receipt) != expected_owner or digest(obj) != artifact['sha256'] or obj.stat().st_size != artifact['bytes']:
                raise SystemExit(f'{profile}: retained object/owner receipt changed: {obj}')
            object_receipts[str(owner_receipt)] = expected_owner
        new = []
        i = 0
        while i < len(original):
            item = original[i]
            if item.endswith('/Main.swift'):
                i += 1
                continue
            if item in ('-o', '-module-cache-path'):
                if item == '-module-cache-path':
                    new += [item, str(out / (profile + '-cache'))]
                i += 2
                continue
            new.append(item)
            i += 1
        executable = out / (profile + '-counter')
        new += [str(driver), '-L' + str(out), '-lP08AllocationObserver', '-Xlinker', '-rpath', '-Xlinker', '@executable_path', '-o', str(executable)]
        execute(new, profile + '-link.log')
        execute(['xcrun', 'nm', '-n', executable], profile + '-symbols.txt')
        execute(['xcrun', 'otool', '-L', executable], profile + '-libraries.txt')
        execute(['xcrun', 'size', '-m', executable], profile + '-sections.txt')
        manifest['profiles'][profile] = {'receipt': str(receipt_path.relative_to(ROOT)),
            'receipt_sha256': digest(receipt_path), 'original_link': original,
            'diagnostic_link': new, 'executable_sha256': digest(executable),
            'objects': {str(p): digest(p) for p in objects}, 'object_receipts': object_receipts,
            'input_count': len(receipt['inputs']), 'current_inputs': True,
            'compiler_sha256': digest(compiler)}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (out / 'commands.json').write_text(json.dumps(commands, indent=2) + '\n')
    if args.run:
        for repeat in range(1, 4):
            for profile in RETAINED:
                name = f'{profile}-{repeat}'
                with (out / (name + '.stdout')).open('wb') as stdout, (out / (name + '.stderr')).open('wb') as stderr:
                    subprocess.run([str(out / (profile + '-counter'))], check=True, stdout=stdout, stderr=stderr)
                text = (out / (name + '.stderr')).read_text()
                summary = [s for s in text.splitlines() if s.startswith(('HOST ', 'ENTRY ', 'WINDOW ', 'CONTROL '))]
                (out / (name + '-summary.txt')).write_text('\n'.join(summary) + '\n')
                print(name + ': ' + next(s for s in summary if s.startswith('ENTRY ')))
    for profile in manifest['profiles'].values():
        for obj, expected in profile['objects'].items():
            if digest(obj) != expected:
                raise SystemExit(f'retained object changed during diagnostic: {obj}')
    artifacts = {str(p.relative_to(out)): digest(p) for p in out.rglob('*') if p.is_file()}
    (out / 'artifact-hashes.json').write_text(json.dumps(artifacts, indent=2) + '\n')
    print(f'Prepared {out}; matched entry executed={args.run}. Public-route coverage only; direct-zone/VM and complete stack remain unclosed.')


if __name__ == '__main__':
    main()
