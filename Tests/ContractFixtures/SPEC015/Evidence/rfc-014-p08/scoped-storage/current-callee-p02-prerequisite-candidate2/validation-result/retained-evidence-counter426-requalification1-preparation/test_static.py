"""Compiler-free tests. Production launcher/main/marker are never invoked."""
from pathlib import Path
import copy
import hashlib
import json
import os
import runpy
import subprocess
import sys
import tempfile
import types
import unittest

PACKET = Path(__file__).resolve().parent

def module(name):
    result = types.ModuleType(name)
    result.__dict__.update(runpy.run_path(str(PACKET / (name + '.py'))))
    sys.modules[name] = result
    return result

q = module('qualify')
enumeration = module('enumerate_labels')
runner = module('run')
RECIPE = q.read(PACKET / 'recipe.json')
DRIVER = Path(RECIPE['driver_root'])
DATA = q.read(DRIVER / 'result.json')
CHECKS = q.read(DRIVER / 'checks.json')
ROWS = q.read(PACKET / 'labels.json')
IDENTITIES = q.read(PACKET / 'driver-identities.json')
ARTIFACTS = q.read(PACKET / 'artifacts.json')

class StaticTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.marker = Path(RECIPE['output_root'])
        if cls.marker.exists() or cls.marker.is_symlink():
            raise AssertionError('production requalification already consumed')
        cls.historical = q.actual(Path(RECIPE['wrapper_root']) / 'terminal.json')

    @classmethod
    def tearDownClass(cls):
        if cls.marker.exists() or cls.marker.is_symlink():
            raise AssertionError('static test consumed production marker')
        if cls.historical != q.actual(Path(RECIPE['wrapper_root']) / 'terminal.json'):
            raise AssertionError('static test altered historical STOP')

    def collection(self, data=None, checks=None, rows=None, identities=None, artifacts=None, reader=q.actual):
        q.verify_collection(DATA if data is None else data, CHECKS if checks is None else checks,
                            ROWS if rows is None else rows, IDENTITIES if identities is None else identities,
                            ARTIFACTS if artifacts is None else artifacts, DRIVER, reader)

    def negative(self):
        expected = copy.deepcopy(next(r for r in ROWS if r['kind'] == 'compiler-negative'))
        row = copy.deepcopy(next(c for c in DATA['checks'] if c['name'] == expected['name']))
        return row, expected, q.actual(DRIVER / expected['log'])

    def test_01_complete_real_context_without_production_claim(self):
        result = q.verify_context(q.ROOT, PACKET)
        self.assertEqual(result['checks'], 426)
        self.assertEqual(result['artifacts'], 904)
        self.assertFalse(result['p08_closed'])
        self.assertEqual(result['historical_wrapper_status'], 'STOP')

    def test_02_missing_label(self):
        data = copy.deepcopy(DATA); data['checks'].pop()
        with self.assertRaisesRegex(ValueError, '426 unique'):
            self.collection(data=data)

    def test_03_duplicate_label(self):
        data = copy.deepcopy(DATA); data['checks'][-1] = data['checks'][0]
        with self.assertRaisesRegex(ValueError, '426 unique'):
            self.collection(data=data)

    def test_04_unknown_label(self):
        data = copy.deepcopy(DATA); data['checks'][-1]['name'] = 'invented-positive'
        with self.assertRaisesRegex(ValueError, '426 unique'):
            self.collection(data=data)

    def test_05_mispartitioned_driver_label(self):
        data = copy.deepcopy(DATA)
        data['planned_scoped_labels'][0], data['planned_supplemental_labels'][0] = data['planned_supplemental_labels'][0], data['planned_scoped_labels'][0]
        with self.assertRaisesRegex(ValueError, 'partition joins'):
            self.collection(data=data)

    def test_06_mispartitioned_frozen_label(self):
        rows = copy.deepcopy(ROWS); rows[0]['partition'] = 'reuse'
        with self.assertRaisesRegex(ValueError, 'mispartitioned'):
            self.collection(rows=rows)

    def test_29_negative_cannot_be_reclassified_as_positive(self):
        rows = copy.deepcopy(ROWS)
        row = next(r for r in rows if r['kind'] == 'compiler-negative')
        row['kind'], row['exit'] = 'positive', 0
        with self.assertRaisesRegex(ValueError, 'independent label kind/exit'):
            self.collection(rows=rows)

    def test_30_no_wildcard_or_wrong_named_control_diagnostic(self):
        row, expected, log = self.negative()
        expected['qualified_diagnostic']['name'] = '*'
        with self.assertRaisesRegex(ValueError, 'exact qualified control diagnostic name'):
            q.verify_diagnostic(row, expected, log, q.actual)

    def test_31_python_and_git_environment_injection(self):
        environment = dict(HOME='/Users/eugene', TMPDIR='/private/tmp', PATH='/usr/bin:/bin:/usr/sbin:/sbin')
        q.verify_environment(environment)
        for name in ('PYTHONPATH', 'PYTHONHOME', 'GIT_DIR', 'GIT_WORK_TREE', 'GIT_CONFIG_COUNT', 'LD_PRELOAD', 'DYLD_INSERT_LIBRARIES'):
            injected = dict(environment); injected[name] = 'untrusted'
            with self.assertRaisesRegex(ValueError, 'controlled qualification environment'):
                q.verify_environment(injected)

    def test_07_bad_status_or_failed_boolean(self):
        for field, value in [('status', 'running'), ('passed', False)]:
            data = copy.deepcopy(DATA); data['checks'][0][field] = value
            checks = copy.deepcopy(CHECKS); checks['checks'] = data['checks']
            with self.assertRaisesRegex(ValueError, 'passing row'):
                self.collection(data=data, checks=checks)

    def test_08_positive_nonzero_exit(self):
        row = copy.deepcopy(next(c for c in DATA['checks'] if c['exit'] == 0))
        expected = next(r for r in ROWS if r['name'] == row['name'])
        row['exit'] = 1
        with self.assertRaisesRegex(ValueError, 'positive zero'):
            q.verify_diagnostic(row, expected, q.actual(DRIVER / expected['log']), q.actual)

    def test_09_compiler_negative_zero_or_other_nonzero_exit(self):
        for value in [0, 2, -6, None]:
            row, expected, log = self.negative(); row['exit'] = value
            with self.assertRaisesRegex(ValueError, 'exact exit 1'):
                q.verify_diagnostic(row, expected, log, q.actual)

    def test_10_missing_or_wrong_diagnostic(self):
        row, expected, log = self.negative()
        expected['qualified_diagnostic']['primary_errors'][0]['message'] = 'unrelated parser failure'
        with self.assertRaisesRegex(ValueError, 'exact named primary'):
            q.verify_diagnostic(row, expected, log, q.actual)
        expected['qualified_diagnostic']['primary_errors'] = []
        with self.assertRaisesRegex(ValueError, 'exact named primary'):
            q.verify_diagnostic(row, expected, log, q.actual)

    def test_11_wrong_diagnostic_location_even_with_resealed_log(self):
        row, expected, log = self.negative()
        replacement = log.replace(b':4028:96: error:', b':1:96: error:')
        self.assertNotEqual(log, replacement)
        row['log_sha256'] = expected['log_sha256'] = q.sha(replacement)
        with self.assertRaisesRegex(ValueError, 'diagnostic location'):
            q.verify_diagnostic(row, expected, replacement, q.actual)

    def test_12_wrong_diagnostic_filename_even_with_resealed_log(self):
        row, expected, log = self.negative()
        replacement = log.replace((row['name'] + '.swift').encode(), b'Unrelated.swift')
        row['log_sha256'] = expected['log_sha256'] = q.sha(replacement)
        with self.assertRaisesRegex(ValueError, 'diagnostic location'):
            q.verify_diagnostic(row, expected, replacement, q.actual)

    def test_13_wrong_raw_log_hash(self):
        row, expected, log = self.negative()
        with self.assertRaisesRegex(ValueError, 'raw log hash'):
            q.verify_diagnostic(row, expected, log + b'\n', q.actual)

    def test_14_altered_generated_source(self):
        row, expected, log = self.negative()
        with self.assertRaisesRegex(ValueError, 'generated source hash'):
            q.verify_diagnostic(row, expected, log, lambda path: q.actual(path) + b'\n')

    def test_15_altered_per_command_source(self):
        target = next(iter(DATA['checks'][0]['identity']['sources']))
        def reader(path):
            return q.actual(path) + (b'\n' if str(path) == target else b'')
        with self.assertRaisesRegex(ValueError, 'per-command source'):
            self.collection(reader=reader)

    def test_16_altered_receipt_join(self):
        checks = copy.deepcopy(CHECKS); checks['collection_complete'] = False
        with self.assertRaisesRegex(ValueError, 'receipt join'):
            self.collection(checks=checks)
        data = copy.deepcopy(DATA); data['host_receipt_sha256'] = '0' * 64
        with self.assertRaisesRegex(ValueError, 'compiler/flags/profile/dependency'):
            self.collection(data=data)

    def test_17_wrong_profile_flags_and_compiler(self):
        for key, value in [('profile', 'macos-dynamic'), ('target_flags', ['-Onone']), ('compiler_sha256', '0' * 64)]:
            data = copy.deepcopy(DATA); data[key] = value
            with self.assertRaisesRegex(ValueError, 'compiler/flags/profile/dependency'):
                self.collection(data=data)

    def test_18_missing_or_altered_artifact_identity(self):
        data = copy.deepcopy(DATA); data['artifacts'].pop(next(iter(data['artifacts'])))
        with self.assertRaisesRegex(ValueError, '904 artifact'):
            self.collection(data=data)

    def test_19_altered_904th_artifact_bytes(self):
        target = str(DRIVER / list(ARTIFACTS)[-1])
        def reader(path):
            return q.actual(path) + (b'\n' if str(path) == target else b'')
        with self.assertRaisesRegex(ValueError, 'artifact bytes/size|generated source hash|per-command source'):
            self.collection(reader=reader)

    def test_20_observation_and_execution_are_not_inferred(self):
        data = copy.deepcopy(DATA)
        row = next(c for c in data['checks'] if c['name'].startswith('so06-reuse-'))
        row['evidence_sha256'] = '0' * 64
        checks = copy.deepcopy(CHECKS); checks['checks'] = data['checks']
        with self.assertRaisesRegex(ValueError, 'actual row'):
            self.collection(data=data, checks=checks)

    def test_21_native_runtime_failure_requires_qualified_named_diagnostic(self):
        expected = copy.deepcopy(next(r for r in ROWS if r['kind'] == 'runtime-negative'))
        row = copy.deepcopy(next(c for c in DATA['checks'] if c['name'] == expected['name']))
        log = q.actual(DRIVER / expected['log'])
        q.verify_diagnostic(row, expected, log, q.actual)
        expected['qualified_diagnostic']['required_exact_lines'][0] = 'Fatal access conflict somewhere'
        with self.assertRaisesRegex(ValueError, 'exact fatal access'):
            q.verify_diagnostic(row, expected, log, q.actual)
        row['exit'] = 1
        with self.assertRaisesRegex(ValueError, 'fatal-access exit'):
            q.verify_diagnostic(row, expected, log, q.actual)

    def test_22_historical_stop_and_stale_terminal(self):
        terminal = json.loads(self.historical)
        frozen = q.read(PACKET / 'historical-terminal.json')
        q.verify_historical(terminal, frozen, RECIPE)
        terminal['status'] = 'PASS'
        with self.assertRaisesRegex(ValueError, 'historical terminal drift'):
            q.verify_historical(terminal, frozen, RECIPE)

    def test_23_closed_recipe_no_new_launches(self):
        q.verify_recipe(RECIPE)
        for key in ('compiler_launches', 'counter_launches', 'schema4_launches', 'repairs', 'retries', 'qualification_attempts'):
            recipe = copy.deepcopy(RECIPE); recipe[key] += 1
            with self.assertRaisesRegex(ValueError, 'fixed recipe'):
                q.verify_recipe(recipe)
        recipe = copy.deepcopy(RECIPE); recipe['argv'] = ['swiftc']
        with self.assertRaisesRegex(ValueError, 'extra recipe'):
            q.verify_recipe(recipe)

    def test_24_permanent_claim_success_and_replay(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temporary:
            out = Path(temporary) / 'qualification'; calls = []
            def harmless():
                calls.append(1)
                return dict(status='PASS_retained_macos_static_counter426_only', compiler_launches=0)
            self.assertEqual(runner.claim_and_qualify(out, ['fixture'], lambda: None, harmless, {}), 0)
            self.assertEqual(len(calls), 2)
            before = (out / 'terminal.json').read_bytes()
            with self.assertRaisesRegex(ValueError, 'consumed; no replay'):
                runner.claim_and_qualify(out, ['fixture'], lambda: None, harmless, {})
            self.assertEqual((out / 'terminal.json').read_bytes(), before)
            self.assertEqual(len(calls), 2)

    def test_25_failure_after_claim_stays_consumed(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temporary:
            out = Path(temporary) / 'qualification'
            def failed():
                raise ValueError('fixture receipt altered')
            self.assertEqual(runner.claim_and_qualify(out, ['fixture'], lambda: None, failed, {}), 1)
            terminal = q.read(out / 'terminal.json')
            self.assertEqual(terminal['status'], 'STOP_compiler_free_qualification_failed')
            self.assertIn('fixture receipt altered', terminal['error'])
            with self.assertRaisesRegex(ValueError, 'consumed; no replay'):
                runner.claim_and_qualify(out, ['fixture'], lambda: None, failed, {})

    def test_26_atomic_terminal_cannot_overwrite_stale_receipt(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temporary:
            terminal = Path(temporary) / 'terminal.json'
            runner.atomic_new_json(terminal, dict(status='STOP'))
            before = terminal.read_bytes()
            with self.assertRaises(FileExistsError):
                runner.atomic_new_json(terminal, dict(status='PASS'))
            self.assertEqual(terminal.read_bytes(), before)

    def test_27_lock_alias_or_replacement(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temporary:
            lock = Path(temporary) / 'validation.lock'; lock.touch()
            with lock.open('r+b') as held:
                runner.check_lock(held.fileno(), lock)
                replacement = Path(temporary) / 'replacement'; replacement.touch(); os.replace(replacement, lock)
                with self.assertRaisesRegex(ValueError, 'lock replaced'):
                    runner.check_lock(held.fileno(), lock)

    def test_28_review_pins_and_packet_inventory(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temporary:
            root = Path(temporary); packet = root / 'packet'; packet.mkdir()
            (packet / 'qualify.py').write_bytes(q.actual(PACKET / 'qualify.py'))
            def git(*args):
                return subprocess.check_output(['git', '--no-replace-objects', *args], cwd=root, stderr=subprocess.DEVNULL)
            git('init', '-q'); git('config', 'user.email', 'fixture@example.invalid'); git('config', 'user.name', 'Static fixture')
            git('add', 'packet'); git('commit', '-qm', 'fixture')
            commit = git('rev-parse', 'HEAD').decode().strip(); tree = git('rev-parse', 'HEAD^{tree}').decode().strip(); ptree = git('rev-parse', 'HEAD:packet').decode().strip()
            q.verify_packet(root, packet, commit, tree, ptree)
            with self.assertRaises((ValueError, subprocess.CalledProcessError)):
                q.verify_packet(root, packet, commit, ptree, tree)
            (packet / 'injected.py').write_text('raise SystemExit(0)\n')
            with self.assertRaisesRegex(ValueError, 'inventory'):
                q.verify_packet(root, packet, commit, tree, ptree)
            (packet / 'injected.py').unlink(); (packet / 'qualify.py').write_text('raise SystemExit(0)\n')
            with self.assertRaisesRegex(ValueError, 'committed directory bytes'):
                q.verify_packet(root, packet, commit, tree, ptree)

if __name__ == '__main__':
    unittest.main(verbosity=2)
