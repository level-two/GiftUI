#!/usr/bin/env python3
"""Maintained clean-generation, freshness and input-refusal corpus."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile

ROOT = Path(__file__).resolve().parents[2]
module = importlib.util.spec_from_file_location('nrf_topology', ROOT / 'scripts/contracts/generate-spec-001-nrf-topology.py')
generator = importlib.util.module_from_spec(module)
module.loader.exec_module(generator)


def check(condition, message):
    if not condition:
        raise SystemExit(message)


with tempfile.TemporaryDirectory(prefix='giftui-clean-topology-') as directory:
    scratch = Path(directory)
    bundle = scratch / 'inputs'
    shutil.copytree(ROOT / 'scripts/contracts/nrf-topology', bundle)
    policy_path = bundle / 'policy.json'
    policy = json.loads(policy_path.read_text())
    source_root = scratch / 'sources'
    for name in list(policy['source_hashes']) + [entry['path'] for entry in policy['projection_sources'].values()]:
        destination = source_root / name
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / name, destination)
    outputs = [scratch / 'first', scratch / 'second']
    hashes = [generator.generate(bundle, source_root, output) for output in outputs]
    check(hashes[0] == hashes[1], 'clean generation differs')
    for name in generator.NAMES:
        check((outputs[0] / name).read_bytes() == (ROOT / 'Sources/SignalAnalyzerTargetHost/Generated' / name).read_bytes(), 'maintained output stale: ' + name)
    normal_path = source_root / policy['projection_sources']['normal']['path']
    original = normal_path.read_bytes()
    normal = json.loads(original)
    failures = 0

    def reject(label):
        global failures
        output = scratch / ('reject-' + label)
        try:
            generator.generate(bundle, source_root, output)
        except (ValueError, KeyError, TypeError, IndexError, OSError):
            check(not output.exists(), 'partial publication on ' + label)
            failures += 1
        else:
            raise SystemExit('accepted invalid input: ' + label)

    for label, mutate in [
        ('duplicate-identity', lambda rows: rows[1].update(identity=rows[0]['identity'])),
        ('zero-identity', lambda rows: rows[0].update(identity=0)),
        ('ordinal', lambda rows: rows[1].update(ordinal=2)),
        ('out-of-range-child', lambda rows: rows[0].update(child=999)),
        ('child-cycle', lambda rows: rows[0].update(child=0)),
        ('parent-disagreement', lambda rows: rows[2].update(parent=0)),
        ('unsupported-modifier', lambda rows: rows[0].update(flags=255)),
        ('variant-disagreement', lambda rows: rows[0].update(identity=1)),
        ('invariant-payload', lambda rows: rows[3].update(p0=123)),
        ('scope-capacity', lambda rows: rows.extend(copy.deepcopy(rows))),
        ('missing-field', lambda rows: rows[0].pop('kind')),
    ]:
        rows = copy.deepcopy(normal)
        mutate(rows)
        normal_path.write_text(json.dumps(rows))
        candidate_policy = copy.deepcopy(policy)
        candidate_policy['projection_sources']['normal']['sha256'] = hashlib.sha256(normal_path.read_bytes()).hexdigest()
        policy_path.write_text(json.dumps(candidate_policy))
        reject(label)
    normal_path.write_bytes(original)
    policy_path.write_text(json.dumps(policy))
    for label, mutate in [
        ('missing-registration', lambda item: item['source_hashes'].clear()),
        ('unsupported-schema', lambda item: item.update(schema=2)),
        ('unsupported-geometry', lambda item: item['geometry_by_identity'].update({'1': ['arbitrarySwift()', '0']})),
    ]:
        candidate_policy = copy.deepcopy(policy)
        mutate(candidate_policy)
        policy_path.write_text(json.dumps(candidate_policy))
        reject(label)
    policy_path.write_text(json.dumps(policy))
    normal_path.write_bytes(original + b'\n')
    reject('stale-projection')
    normal_path.write_bytes(original)
    source = source_root / next(iter(policy['source_hashes']))
    source.write_bytes(source.read_bytes() + b'\n// stale source\n')
    reject('stale-source')
    shutil.copyfile(ROOT / next(iter(policy['source_hashes'])), source)
    template = bundle / 'templates/Topology.swift.in'
    original_template = template.read_bytes()
    template.write_bytes(original_template + b'@@UNKNOWN_TOKEN@@')
    reject('unsupported-template')
    template.write_bytes(original_template)
    try:
        generator.generate(bundle, source_root, outputs[0])
    except ValueError:
        failures += 1
    else:
        raise SystemExit('accepted nonempty output')
    check(hashes[0] == {name: hashlib.sha256((outputs[0] / name).read_bytes()).hexdigest() for name in generator.NAMES}, 'nonempty-output refusal changed existing files')
    print(f'nRF topology generation passed: two clean identical outputs, maintained byte parity, {failures} refusals without partial publication.')
