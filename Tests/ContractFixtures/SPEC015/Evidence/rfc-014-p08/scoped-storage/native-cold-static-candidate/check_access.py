#!/usr/bin/env python3
"""Compile-only source-access controls for serialized internal scope factories."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[7]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--prepared', type=Path, required=True)
    args = parser.parse_args()
    out = args.prepared.resolve() / 'source-access'
    out.mkdir(exist_ok=False)
    manifest = json.loads((args.prepared / 'manifest.json').read_text())
    compiler = Path(manifest['compiler'])
    assert hashlib.sha256(compiler.read_bytes()).hexdigest() == manifest['compiler_sha256']
    command = json.loads((args.prepared / 'commands.json').read_text())
    model = next(c['argv'] for c in command if c['log'] == 'counter-model.log')
    prefix = model[:model.index('-module-name')]
    prefix = [field for field in prefix if field != '-parse-as-library']
    cases = {
        'borrowed-access-positive': (True, '''import GiftUIObservableState
@_lifetime(copy input)
func model<M: ~Copyable, S>(_ input: borrowing ObservableModelScope<M, S>) -> ObservableModelScope<M, S> {
    input.borrowedScope()
}
@_lifetime(copy input)
func root<M: ObservableStateModel & ~Copyable, I: Equatable & Sendable>(
    _ input: borrowing ObservableStateRootScope<M, I>) -> ObservableStateRootScope<M, I> {
    input.borrowedRoot()
}
'''),
        'model-construction-negative': (False, '''import GiftUIObservableState
func bad(_ owner: borrowing UnsafeMutablePointer<ObservableModelOwnership>,
         _ models: borrowing UnsafeMutableBufferPointer<Int?>) {
    let scope = ObservableModelScope<Int, UInt8>(ownership: owner, models: models, schema: 1, needsCapture: false)
    _ = scope
}
'''),
        'root-construction-negative': (False, '''import GiftUIObservableState
func bad<M: ObservableStateModel & ~Copyable, I: Equatable & Sendable>(
    _ input: borrowing ObservableStateRootScope<M, I>) {
    let constructor = ObservableStateRootScope<M, I>.init
    _ = constructor
}
'''),
        'root-extraction-negative': (False, '''import GiftUIObservableState
func bad<M: ObservableStateModel & ~Copyable, I: Equatable & Sendable>(
    _ input: borrowing ObservableStateRootScope<M, I>) { _ = input.records }
'''),
    }
    results = {}
    for name, (positive, source) in cases.items():
        path = out / (name + '.swift')
        path.write_text(source)
        argv = prefix + ['-typecheck', '-module-name', 'P08ScopeSourceClient', str(path)]
        result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        (out / (name + '.log')).write_bytes(result.stdout)
        text = result.stdout.decode()
        assert (result.returncode == 0) == positive, (name, text)
        if not positive:
            assert "inaccessible due to 'internal' protection level" in text, (name, text)
        results[name] = {'passed': True, 'argv': argv, 'source_sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                         'log_sha256': hashlib.sha256(result.stdout).hexdigest()}
        print('PASS ' + name)
    (out / 'result.json').write_text(json.dumps(results, indent=2) + '\n')


if __name__ == '__main__':
    main()
