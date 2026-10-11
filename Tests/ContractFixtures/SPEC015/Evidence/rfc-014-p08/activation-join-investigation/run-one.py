#!/usr/bin/env python3
"""One authorized compiler invocation; persistent six-run/two-layout hard cap.

No automatic correction, retry, module rebuild, historical rerun or integration.
"""
import argparse
import hashlib
import json
import pathlib
import shlex
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[6]
HERE = pathlib.Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('candidate', choices=['A', 'B'])
parser.add_argument('control', choices=['positive', 'copy', 'outlive'])
parser.add_argument('--correct-caller', action='store_true', help='one exact two-token caller correction, counted as a fresh invocation')
args = parser.parse_args()
ledger_path = HERE / 'ledger.json'
ledger = json.loads(ledger_path.read_text())
assert not ledger.get('held_for_guard_accounting_review'), 'held pending independent guard-accounting review; no compiler invocation permitted'
assert ledger['compiler_invocations_used'] < 6, 'six-invocation allowance exhausted'
assert ledger['consecutive_unproductive_candidates'] < 2, 'two-candidate stop reached'
assert not ledger.get('completed_candidate'), 'first passing candidate already closes investigation'
if not args.correct_caller:
    assert not any(r['candidate'] == args.candidate and r['control'] == args.control for r in ledger['runs']), 'frozen control already invoked'
else:
    assert args.candidate == 'A' and args.control == 'positive' and ledger['compiler_invocations_used'] == 1
    assert (HERE / 'run-1/Positive.swift').read_text().replace('consume profile.canvasBacking', 'profile.canvasBacking').replace('consume profile.workspace', 'profile.workspace') == (HERE / 'Positive.swift').read_text()
    assert (HERE / 'run-1/LayoutA.swift').read_bytes() == (HERE / 'LayoutA.swift').read_bytes()
    assert (HERE / 'run-1/Supplied.swift').read_bytes() == (HERE / 'Supplied.swift').read_bytes()
previous = [r for r in ledger['runs'] if r['candidate'] == args.candidate]
if not args.correct_caller:
    assert not any(r.get('accepted') is False and not r.get('caller_setup_superseded') for r in previous), 'candidate failed; skip remaining controls'
else:
    previous[0]['caller_setup_superseded'] = 'two-token caller correction uses fresh run2; original failure retained'
if args.control != 'positive':
    assert any(r['control'] == 'positive' and r['accepted'] for r in previous), 'positive required before negatives'
if args.candidate == 'B':
    assert any(r['candidate'] == 'A' and r.get('accepted') is False for r in ledger['runs']), 'B only after A fails'
base = ROOT / '.build/contracts/p08-scoped-host-ie3r3cmc'
prior = json.loads((base / 'result.json').read_text())
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
verified = json.loads((HERE / 'verified-inputs.json').read_text())
assert digest(base / 'result.json') == verified['schema_receipt_sha256']
for name, expected in prior['inputs'].items():
    assert digest(ROOT / name) == expected, name
for name, expected in prior['artifacts'].items():
    assert digest(base / name) == expected['sha256'], name
original = next(shlex.split(c) for c in prior['commands'] if '-module-name P08ScopedHostProbe ' in c)
compiler = pathlib.Path(original[0])
assert digest(compiler) == verified['compiler_sha256']
flags = original[1:original.index('-module-name')]
number = ledger['compiler_invocations_used'] + 1
out = HERE / ('run-' + str(number))
out.mkdir()
flags[flags.index('-module-cache-path') + 1] = str(ROOT / '.build/contracts/p08-activation-investigation-cache')
control_file = {'positive': 'Positive.swift', 'copy': 'CopyNegative.swift', 'outlive': 'OutliveNegative.swift'}[args.control]
sources = [HERE / 'Supplied.swift', HERE / ('Layout' + args.candidate + '.swift'), HERE / control_file]
command = [str(compiler), *flags, '-module-name', 'P08ActivationJoinInvestigation', '-emit-object', *map(str, sources), '-o', str(ROOT / '.build/contracts' / ('p08-activation-investigation-run-' + str(number) + '.o'))]
record = dict(number=number, candidate=args.candidate, control=args.control, command=shlex.join(command), compiler_sha256=digest(compiler), inputs={str(p.relative_to(ROOT)): digest(p) for p in sources}, status='reserved before compiler invocation')
if not previous:
    ledger['candidate_layouts_used'] += 1
assert ledger['candidate_layouts_used'] <= 2
ledger['compiler_invocations_used'] = number
ledger['status'] = f'run {number} reserved; historical production guard 2/2 unchanged'
ledger['runs'].append(record)
ledger_path.write_text(json.dumps(ledger, indent=2) + '\n')
(out / 'command.txt').write_text(record['command'] + '\n')
record['source_snapshots'] = {}
for source in sources:
    (out / source.name).write_bytes(source.read_bytes())
    record['source_snapshots'][source.name] = str((out / source.name).relative_to(HERE))
result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
(out / 'stdout.txt').write_text(result.stdout)
(out / 'stderr.txt').write_text(result.stderr)
log = result.stdout + result.stderr
accepted = result.returncode == 0 if args.control == 'positive' else result.returncode != 0 and ('noncopyable' in log if args.control == 'copy' else 'escapes its scope' in log)
record.update(exit=result.returncode, accepted=accepted, status='completed', stdout_sha256=digest(out / 'stdout.txt'), stderr_sha256=digest(out / 'stderr.txt'))
if not accepted:
    ledger['consecutive_unproductive_candidates'] += 1
    ledger['status'] = f'candidate {args.candidate} failed; negatives skipped; investigation open only if limits allow'
elif args.control == 'outlive' and any(r['candidate'] == args.candidate and r['control'] == 'copy' and r.get('accepted') for r in ledger['runs']):
    ledger['completed_candidate'] = args.candidate
    ledger['status'] = 'first candidate passes all three controls; investigation closed, no production authority'
else:
    if args.control == 'positive':
        ledger['consecutive_unproductive_candidates'] = 0
    ledger['status'] = f'run {number} accepted; next reserved control only'
if ledger['consecutive_unproductive_candidates'] >= 2 or ledger['compiler_invocations_used'] >= 6:
    ledger['status'] += '; allowance stopped'
ledger_path.write_text(json.dumps(ledger, indent=2) + '\n')
(out / 'result.json').write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps(dict(number=number, candidate=args.candidate, control=args.control, exit=result.returncode, accepted=accepted, used=ledger['compiler_invocations_used'], layouts=ledger['candidate_layouts_used'], consecutive_unproductive_candidates=ledger['consecutive_unproductive_candidates'], status=ledger['status'])))
print(result.stdout + result.stderr)
