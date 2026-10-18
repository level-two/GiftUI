"""Static archive and adversarial tests; never launch a compiler or campaign."""
import copy
import dataclasses
import json
from pathlib import Path
import sys
import unittest
sys.dont_write_bytecode = True
from policy_binder import bind, canonical, digest, Rejected, POLICY_SHA256, authenticate_prelaunch, finish

ROOT = Path(__file__).resolve().parent
POLICY_BYTES = (ROOT / 'policy.json').read_bytes()
POLICY = json.loads(POLICY_BYTES)
CONTEXTS = json.loads((ROOT / 'archived-captures.json').read_bytes())
REJECTED_CASES = 0
ACCEPTED_CASES = 0


def args(key):
    case = POLICY['cases'][key]
    return dict(policy_bytes=POLICY_BYTES, key=key,
                context_bytes=canonical(CONTEXTS[key]),
                source_bytes={p: POLICY['source_pool'][v['sha256']].encode()
                              for p, v in case['sources'].items()},
                stdout=case['stdout'].encode(), stderr=case['stderr'].encode(),
                exit_code=1, launch_error=None)


class PolicyTests(unittest.TestCase):
    def reject(self, call):
        global REJECTED_CASES
        REJECTED_CASES += 1
        with self.assertRaises(Rejected):
            bind(**call)

    def test_scope(self):
        cases = POLICY['cases']
        for profile, counts in [('raspberry-pi-armv6', (2, 9)),
                                ('nrf52840-embedded', (8, 9)),
                                ('macos-dynamic', (8, 9))]:
            scoped = [x for x in cases.values() if x['profile'] == profile]
            self.assertEqual(sum(x['control'].startswith('negative-A') for x in scoped), counts[0])
            self.assertEqual(sum(not x['control'].startswith('negative-A') for x in scoped), counts[1])
        self.assertEqual(len(cases), 45)
        self.assertEqual(digest(POLICY_BYTES), POLICY_SHA256)

    def test_all_archived_forms(self):
        global ACCEPTED_CASES
        for key, case in POLICY['cases'].items():
            with self.subTest(key=key):
                call = args(key)
                binding = bind(**call)
                ACCEPTED_CASES += 1
                self.assertIs(binding.qualified, False)
                # Caller mutations cannot mutate the returned immutable capture.
                before = binding.context
                call['source_bytes'].clear()
                self.assertEqual(binding.context, before)
                with self.assertRaises(dataclasses.FrozenInstanceError):
                    binding.key = 'changed'
                for row in case['diagnostics']:
                    if 'source_sha256' in row:
                        text = POLICY['source_pool'][row['source_sha256']]
                        self.assertEqual(text.splitlines()[row['line'] - 1], row['source_row'])
                    else:
                        self.assertIs(row['display_only'], True)
                        self.assertEqual(row['kind'], 'note')

    def test_all_forms_reject_stream_and_exit_anomalies(self):
        for key in POLICY['cases']:
            original = args(key)
            stream = original['stderr']
            mutations = {
                'missing-all': b'', 'missing-tail': stream[:-1],
                'missing-first-block': b'\n\n'.join(stream.split(b'\n\n')[1:]),
                'extra-error': stream + b'other.swift:1:1: error: unrelated failure\n',
                'extra-warning': stream + b'warning: unrelated\n',
                'wrong-error': stream.replace(b'error:', b'warning:', 1),
                'wrong-line': stream.replace(b':2:', b':999:', 1) if b':2:' in stream else stream.replace(b':', b':999', 1),
                'wrong-path': stream.replace(b'/Users/eugene/', b'/tmp/other/', 1),
                'reordered-rows': b'\n'.join(reversed(stream.split(b'\n'))),
                'crlf': stream.replace(b'\n', b'\r\n'),
                'source-row': stream.replace(b' | ', b' | forged ', 1),
                'gutter-message': stream.replace(b'`- ', b'`- forged ', 1),
                'unrelated-failure': b'error: unable to load standard library\n',
                'nul': stream + b'\x00',
            }
            for label, value in mutations.items():
                with self.subTest(key=key, mutation=label):
                    self.assertNotEqual(value, stream)
                    call = args(key); call['stderr'] = value; self.reject(call)
            for value in [0, 2, -1, -9, 127, 134, 139, True, False, 1.0, '1', None]:
                with self.subTest(key=key, exit=value):
                    call = args(key); call['exit_code'] = value; self.reject(call)
            for field, value in [('stdout', b'extra'), ('launch_error', ''), ('launch_error', 'timeout')]:
                call = args(key); call[field] = value; self.reject(call)

    def test_context_and_source_swaps(self):
        keys = list(POLICY['cases'])
        for index, key in enumerate(keys):
            original = args(key)
            for label, mutate in [
                ('unknown-profile', lambda c: c.update(key='macos-static--' + key)),
                ('other-case-context', lambda c: c.update(context_bytes=canonical(CONTEXTS[keys[(index+1)%len(keys)]]))),
                ('extra-context', lambda c: c.update(context_bytes=canonical(dict(CONTEXTS[key], extra=True)))),
                ('missing-source', lambda c: c['source_bytes'].pop(next(iter(c['source_bytes'])))),
                ('extra-source', lambda c: c['source_bytes'].update({'/tmp/forged.swift': b''})),
                ('changed-source', lambda c: c['source_bytes'].update({next(iter(c['source_bytes'])): b'forged'})),
                ('policy-tamper', lambda c: c.update(policy_bytes=POLICY_BYTES+b' ')),
            ]:
                with self.subTest(key=key, mutation=label):
                    call = args(key); mutate(call); self.reject(call)
            # Every independently recorded top-level provenance field is bound.
            for field in CONTEXTS[key]:
                with self.subTest(key=key, context_field=field):
                    context = copy.deepcopy(CONTEXTS[key]); context[field] = 'swapped'
                    call = args(key); call['context_bytes'] = canonical(context); self.reject(call)
            # Snapshot input maps cannot substitute another correct archived source.
            for path in original['source_bytes']:
                call = args(key); call['source_bytes'][path] += b'\n'; self.reject(call)

    def test_primary_order_symbols_and_virtual_notes(self):
        for profile in ['nrf52840-embedded', 'macos-dynamic']:
            for number in [1, 2, 7]:
                key = next(k for k in POLICY['cases'] if k.startswith(profile+'--negative-A'+str(number)+'--'))
                call = args(key)
                blocks = call['stderr'].split(b'\n\n')
                self.assertGreater(len(blocks), 2)
                call['stderr'] = b'\n\n'.join([blocks[1], blocks[0]] + blocks[2:])
                self.reject(call)
        for key, case in POLICY['cases'].items():
            for row in case['diagnostics']:
                if row.get('display_only'):
                    call = args(key)
                    call['stderr'] = call['stderr'].replace(row['path'].encode(), b'/tmp/forged.swift')
                    self.reject(call)
            if any(row.get('display_only') for row in case['diagnostics']):
                call = args(key)
                call['stderr'] = call['stderr'].replace(b'declared here', b'declared elsewhere')
                self.reject(call)
        key = 'raspberry-pi-armv6--negative-A7--AnalyzerPresentation'
        call = args(key); call['stderr'] = call['stderr'].replace(b"'model'", b"'index'"); self.reject(call)

    def test_compiler_sdk_package_and_producer_swaps(self):
        for key in POLICY['cases']:
            context = CONTEXTS[key]
            argv = context.get('argv', context.get('stage', {}).get('argv'))
            for flag in ['-target', '-sdk', '-package-name', '-module-name',
                         '-resource-dir', '-load-plugin-executable']:
                if flag not in argv:
                    continue
                changed = copy.deepcopy(context)
                target = changed.get('argv', changed.get('stage', {}).get('argv'))
                target[target.index(flag) + 1] = '/tmp/swapped-or-wrong-value'
                call = args(key); call['context_bytes'] = canonical(changed)
                self.reject(call)
            changed = copy.deepcopy(context)
            target = changed.get('argv', changed.get('stage', {}).get('argv'))
            target[0] = '/tmp/wrong-swiftc'
            call = args(key); call['context_bytes'] = canonical(changed); self.reject(call)
            if 'inputs' in context:
                for field in ['path', 'resolved', 'sha256', 'bytes']:
                    changed = copy.deepcopy(context)
                    changed['inputs'][-1][field] = 'swapped-producer'
                    call = args(key); call['context_bytes'] = canonical(changed); self.reject(call)
            if 'compiler_and_tool_identities' in context:
                changed = copy.deepcopy(context)
                changed['compiler_and_tool_identities'][0]['sha256'] = '0' * 64
                call = args(key); call['context_bytes'] = canonical(changed); self.reject(call)

    def test_immutable_prelaunch_and_finish(self):
        for key in POLICY['cases']:
            call = args(key)
            prelaunch = authenticate_prelaunch(call['policy_bytes'], key,
                                                call['context_bytes'], call['source_bytes'])
            final = dict(call); final.pop('key')
            self.assertEqual(finish(prelaunch, **final), bind(**call))
            with self.assertRaises(dataclasses.FrozenInstanceError):
                prelaunch.context = b'forged'
            for field in ['context', 'source_hashes', 'policy_sha256']:
                changed = dataclasses.replace(prelaunch, **{field: b'forged' if field != 'policy_sha256' else 'forged'})
                with self.assertRaises(Rejected):
                    finish(changed, **final)
            with self.assertRaises(Rejected):
                finish(None, **final)
            call['source_bytes'].clear()
            with self.assertRaises(Rejected):
                finish(prelaunch, **final)

    def test_duplicate_and_malformed_context_json(self):
        key = next(iter(POLICY['cases']))
        for value in [b'{"a":1,"a":1}', b'{"a":NaN}', b'{} trailing', b'[]', b'null']:
            call = args(key); call['context_bytes'] = value; self.reject(call)


if __name__ == '__main__':
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(PolicyTests)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    print(json.dumps({'groups': result.testsRun, 'accepted_archived_forms': ACCEPTED_CASES,
                      'rejected_adversarial_cases': REJECTED_CASES,
                      'compiler_invocations': 0, 'campaign_invocations': 0,
                      'qualified_controls': 0, 'pass': result.wasSuccessful()}, sort_keys=True))
    sys.exit(0 if result.wasSuccessful() else 1)
