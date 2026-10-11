#!/usr/bin/env python3
"""Bounded compile-only decision evidence; does not modify production contracts."""
import hashlib, json, pathlib, shlex, subprocess, sys
root = pathlib.Path(__file__).resolve().parents[6]
proof = pathlib.Path(__file__).resolve().parent
base = (root / sys.argv[1]).resolve()
receipt = json.loads((base / 'result.json').read_text())
def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
assert receipt['profile'] == 'macos-static'
assert digest(pathlib.Path(receipt['compiler'])) == receipt['compiler_sha256']
for name, expected in receipt['inputs'].items():
    assert digest(root / name) == expected, name
command = shlex.split((base / 'commands.txt').read_text().splitlines()[0])
flags = command[1:command.index('-module-name')]
results = []
for name, expected in [('CurrentStorage', 'does not conform to \'Copyable\''),
                       ('UnsupportedSuppression', "cannot suppress 'Copyable' requirement of an associated type"),
                       ('CurrentTarget', 'does not conform to protocol'),
                       ('ProposedOperational', None)]:
    cmd = [command[0], *flags, '-module-name', 'AssociatedTypeProof', '-typecheck', str(proof / (name + '.swift'))]
    result = subprocess.run(cmd, cwd=root, text=True, capture_output=True)
    log = result.stdout + result.stderr
    (proof / (name + '.log')).write_text(log)
    passed = result.returncode == 0 if expected is None else result.returncode != 0 and expected in log
    results.append({'case': name, 'command': cmd, 'exit': result.returncode, 'expected': expected, 'pass': passed,
                    'source_sha256': digest(proof / (name + '.swift')), 'log_sha256': digest(proof / (name + '.log'))})
    print(name, result.returncode, 'PASS' if passed else log)
    assert passed
report = {'profile': 'macos-static', 'kind': 'compile-only contract decision evidence',
          'source_commit': subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),
          'source_dirty': bool(subprocess.check_output(['git','status','--porcelain'],cwd=root,text=True)),
          'module_receipt': str((base / 'result.json').relative_to(root)), 'module_receipt_sha256': digest(base / 'result.json'),
          'compiler': receipt['compiler'], 'compiler_sha256': receipt['compiler_sha256'],
          'actual_contract_sha256': digest(root / 'Sources/GiftUIRuntimeCore/RuntimeCoordinatorContracts.swift'),
          'checks': results}
(proof / 'result.json').write_text(json.dumps(report, indent=2, sort_keys=True)+'\n')
