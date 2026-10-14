"""Compiler-free tests for failure collection, dependencies, and focused evidence reuse."""
import json
import pathlib
import subprocess
import tempfile
import unittest
from unittest.mock import patch

from p08_check_collection import Collector, diagnostic_matches, digest, family


class CollectionTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = pathlib.Path(self.temporary.name)
        self.old = self.root / 'old'
        self.old.mkdir()

    def execute(self, outcomes):
        def fake(command, **_):
            exit_code, output = outcomes[command[0]]
            return subprocess.CompletedProcess(command, exit_code, output, '')
        return patch('p08_check_collection.subprocess.run', side_effect=fake)

    def receipt(self, collector, inputs=None):
        passed = collector.finish()
        receipt = dict(collection_schema=2, collection_complete=True, passed=passed,
                       checks=collector.checks, inputs=inputs or {},
                       artifacts={path.name: dict(sha256=digest(path)) for path in self.old.iterdir() if path.is_file() and path.name != 'result.json'})
        (self.old / 'result.json').write_text(json.dumps(receipt))

    def test_collect_failure_and_block_negative_without_blocking_independents(self):
        collector = Collector(self.root, self.old, collect=True)
        with self.execute({'bad': (1, 'broken positive'), 'good': (0, 'live runtime')}):
            collector.run('so06-union-static-direct-root-positive', ['bad'])
            collector.run('so06-union-static-direct-root-negative', ['unused'], ('lifetime',),
                          ['so06-union-static-direct-root-positive'])
            collector.run('execute', ['good'])
            collector.run('so06-native-exclusivity-module', ['good'])
        self.assertEqual([check['status'] for check in collector.checks], ['failed', 'blocked', 'passed', 'passed'])
        self.assertEqual(collector.checks[0]['exit'], 1)
        self.assertIsNone(collector.checks[1]['exit'])
        self.assertFalse(collector.finish())
        self.assertFalse(json.loads((self.old / 'checks.json').read_text())['passed'])

    def test_classifier_failure_collects_later_checks(self):
        collector = Collector(self.root, self.old, collect=True)
        with self.execute({'positive': (0, ''), 'negative': (1, 'escapes its scope'), 'next': (0, '')}):
            collector.run('so06-erasure-static-generic-active-host-closure-positive', ['positive'])
            collector.run('so06-erasure-static-generic-active-host-closure-negative', ['negative'], ('escaping',))
            collector.run('next-positive', ['next'])
        self.assertFalse(collector.checks[1]['passed'])
        self.assertTrue(collector.checks[2]['passed'])
        self.assertFalse(collector.finish())

    def seed_focus(self):
        collector = Collector(self.root, self.old, collect=True)
        with self.execute({'positive': (0, ''), 'negative': (1, 'escapes its scope'), 'stable': (0, '')}):
            collector.run('so06-erasure-static-generic-active-host-closure-positive', ['positive'])
            collector.run('so06-erasure-static-generic-active-host-closure-negative', ['negative'], ('escaping',))
            collector.run('stable-positive', ['stable'])
        self.receipt(collector)
        fresh = self.root / 'fresh'
        fresh.mkdir()
        return fresh

    def test_family_selection_reruns_positive_twin_and_preserves_all_coverage(self):
        fresh = self.seed_focus()
        collector = Collector(self.root, fresh, resume=self.old, selected=['so06-erasure-closure'])
        with self.execute({'positive': (0, ''), 'negative': (1, 'escapes its scope')}) as executor:
            collector.run('so06-erasure-static-generic-active-host-closure-positive', ['positive'])
            collector.run('so06-erasure-static-generic-active-host-closure-negative', ['negative'], ('escapes its scope',))
            collector.run('stable-positive', ['stable'])
        self.assertEqual(executor.call_count, 2)
        self.assertEqual(collector.checks[-1]['status'], 'reused')
        self.assertTrue(collector.finish())
        self.assertEqual(len(collector.checks), 3)

    def test_unchanged_failed_family_is_retained_as_failure(self):
        fresh = self.seed_focus()
        collector = Collector(self.root, fresh, resume=self.old, selected=['stable'])
        collector.run('so06-erasure-static-generic-active-host-closure-positive', ['positive'])
        collector.run('so06-erasure-static-generic-active-host-closure-negative', ['negative'], ('escaping',))
        with self.execute({'stable': (0, '')}):
            collector.run('stable-positive', ['stable'])
        self.assertFalse(collector.finish())

    def test_changed_unselected_matcher_rejected(self):
        fresh = self.seed_focus()
        collector = Collector(self.root, fresh, resume=self.old, selected=['stable'])
        with self.assertRaisesRegex(ValueError, 'complete --select-family so06-erasure-closure'):
            collector.run('so06-erasure-static-generic-active-host-closure-negative', ['negative'], ('escapes its scope',))

    def test_tampered_log_rejected_before_reuse(self):
        fresh = self.seed_focus()
        (self.old / 'stable-positive.log').write_text('changed')
        with self.assertRaisesRegex(ValueError, 'artifact drift'):
            Collector(self.root, fresh, resume=self.old, selected=['stable'])

    def test_input_drift_and_missing_coverage_rejected(self):
        fresh = self.seed_focus()
        collector = Collector(self.root, fresh, resume=self.old, selected=['stable'])
        with self.assertRaisesRegex(ValueError, 'compiled input drift'):
            collector.verify_inputs({'fixture.swift': 'new'}, {})
        with self.execute({'stable': (0, '')}):
            collector.run('stable-positive', ['stable'])
        with self.assertRaisesRegex(ValueError, 'coverage inventory drift'):
            collector.finish()

    def test_runtime_observations_require_successful_execution(self):
        collector = Collector(self.root, self.old, collect=True)
        with self.execute({'trap': (1, 'so06-reuse-dynamic-action-current')}):
            collector.run('execute', ['trap'])
        collector.observation('so06-reuse-dynamic-action-current', dict(kind='exact-line-count', line='so06-reuse-dynamic-action-current', count=1), ['execute'], 'execute.log')
        self.assertEqual(collector.checks[-1]['status'], 'blocked')
        self.assertFalse(collector.checks[-1]['passed'])

    def test_legacy_packet_has_exact_immutable_pin(self):
        packet = self.root / 'packet'
        packet.mkdir()
        (packet / 'manifest.json').write_text('{}')
        with self.assertRaisesRegex(ValueError, 'immutable compatibility2'):
            Collector(self.root, self.old, legacy=packet)

    def test_family_mapping_groups_all_erasure_twins(self):
        self.assertEqual(family('so06-erasure-static-generic-active-host-closure-negative'), 'so06-erasure-closure')
        self.assertEqual(family('so06-erasure-dynamic-direct-retired-host-closure-positive'), 'so06-erasure-closure')

    def test_structured_oracle_requires_probe_errors_and_finite_alternatives(self):
        oracle = dict(any_of=[['borrowed', 'cannot be consumed'], ['lifetime-dependent', 'escapes its scope']],
                      error_site=dict(filename='probe.swift', first_line=100))
        output = "/tmp/probe.swift:102:3: error: 'input' is borrowed and cannot be consumed\n/tmp/probe.swift:102:3: error: lifetime-dependent variable 'input' escapes its scope\n"
        self.assertTrue(diagnostic_matches(oracle, output, 1))
        self.assertFalse(diagnostic_matches(oracle, output.replace(':102:', ':99:'), 1))
        self.assertFalse(diagnostic_matches(oracle, output.replace('probe.swift', 'Trusted.swift'), 1))
        self.assertFalse(diagnostic_matches(oracle, output + '/tmp/probe.swift:105:4: error: unrelated type mismatch\n', 1))
        self.assertFalse(diagnostic_matches(oracle, output + 'Stack dump:\n', 1))
        self.assertFalse(diagnostic_matches(oracle, output, -6))
        self.assertFalse(diagnostic_matches(oracle, output, 0))

    def test_structured_oracle_rejects_unlocated_errors_and_malformed_data(self):
        oracle = dict(any_of=[['lifetime']], error_site=dict(filename='probe.swift', first_line=1))
        self.assertFalse(diagnostic_matches(oracle, 'error: lifetime failure\n', 1))
        with self.assertRaisesRegex(ValueError, 'invalid structured'):
            diagnostic_matches(oracle | dict(any_of=[[]]), '', 1)

    def legacy_identity(self):
        return dict(profile='macos-dynamic', selected_host_profile='macos-dynamic', raster_realization='full-surface',
                    runtime_receipt_sha256='ec640f13aedd202725ad02e52a5e56e56357b5d3e034b3792788fe95feae4446',
                    host_receipt_sha256='8ccd2c004117f31f1843584fb157b5a0b5f93669505db88166eafe83f871c64d',
                    core_receipt_sha256='05f06a2eb45db2a196b7a76bdfbd5ee1429a802640dd00aa1ce251020b699402',
                    compiler_sha256='79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69',
                    macro_tool_sha256='6bb5eae9d0b726905f893b0f1fa4c0739fee61830f33404aa5cdb8321212c691',
                    swift_syntax_sha256='63b1b2670bd94e946bf660aeeda8efccacfce666316cf205e3bbbe9bfbbda308')

    def legacy_collector(self):
        collector = Collector(self.root, self.old, collect=True)
        collector.legacy = {'control-positive': {}}
        collector.legacy_identity = {}
        return collector

    def test_legacy_generation_and_preparation_inputs_require_original_content(self):
        for name in ('Counter.schema.json', 'Counter.swift', 'Preparation.swift'):
            with self.subTest(name=name):
                collector = self.legacy_collector()
                path = self.root / name
                path.write_text('modified generation or dependency source')
                original = subprocess.CompletedProcess([], 0, b'original source', b'')
                with patch('p08_check_collection.subprocess.run', return_value=original) as git:
                    with self.assertRaisesRegex(ValueError, 'generation input drift'):
                        collector.verify_inputs({name: digest(path)}, self.legacy_identity())
                self.assertEqual(git.call_args.args[0], ['git', 'show', 'cab1c415:' + name])
                self.assertFalse(collector.legacy_inputs_qualified)

    def test_legacy_compiler_macro_and_transitive_dependency_identity_drift(self):
        for key in ('compiler_sha256', 'macro_tool_sha256', 'swift_syntax_sha256', 'core_receipt_sha256', 'runtime_receipt_sha256', 'host_receipt_sha256'):
            with self.subTest(key=key):
                collector = self.legacy_collector()
                with self.assertRaisesRegex(ValueError, key):
                    collector.verify_inputs({}, self.legacy_identity() | {key: 'drift'})

    def test_legacy_preparation_commands_and_success_are_mandatory(self):
        collector = self.legacy_collector()
        collector.verify_inputs({}, self.legacy_identity())
        collector.legacy_out = self.root / 'historical'
        collector.legacy_commands = ['original-command'] * 19
        with self.assertRaisesRegex(ValueError, 'preparation command'):
            collector.legacy_preparation('Preparation', ['changed-command'])
        with self.assertRaisesRegex(ValueError, 'successful historical-equivalent preparation'):
            collector.run('control-positive', ['original-command'])

    def test_failed_target_has_no_success_claim_or_retained_object_inventory(self):
        collector = Collector(self.root, self.old, collect=True)
        object_path = self.old / 'P08CounterRuntime.o'
        object_path.write_text('leftover object is insufficient')
        (self.old / 'objects.list').write_text('historical list')
        collector.record(dict(name='counter-model', passed=False, status='failed', exit=1))
        statement = collector.target_compilation(['counter-model'], [object_path])
        self.assertIn('unavailable', statement)
        self.assertNotIn('cross-compiled', statement)
        self.assertFalse((self.old / 'objects.list').exists())

    def test_target_claim_requires_all_preparation_and_actual_declared_objects(self):
        collector = Collector(self.root, self.old, collect=True)
        collector.record(dict(name='counter-model', passed=True, status='passed', exit=0))
        object_path = self.old / 'P08CounterRuntime.o'
        self.assertIn('unavailable', collector.target_compilation(['counter-model'], [object_path]))
        object_path.write_text('current verified object')
        self.assertIn('unavailable', collector.target_compilation(['Preparation', 'counter-model'], [object_path]))
        collector.record(dict(name='Preparation', passed=True, status='passed', exit=0))
        self.assertIn('cross-compiled', collector.target_compilation(['Preparation', 'counter-model'], [object_path]))
        self.assertEqual((self.old / 'objects.list').read_text(), str(object_path) + '\n')

    def seed_observations(self):
        collector = Collector(self.root, self.old, collect=True)
        with self.execute({'execute': (0, 'old output\n'), 'stable': (0, '')}):
            collector.run('execute', ['execute'])
            collector.observation('runtime-summary', dict(kind='positive-counter-summary', failures=0), ['execute'], 'execute.log')
            collector.run('stable-positive', ['stable'])
        self.receipt(collector)
        fresh = self.root / 'fresh'
        fresh.mkdir()
        return fresh

    def test_unselected_observation_oracle_drift_cannot_upgrade_failure(self):
        fresh = self.seed_observations()
        collector = Collector(self.root, fresh, resume=self.old, selected=['stable'])
        collector.run('execute', ['execute'])
        with self.assertRaisesRegex(ValueError, 'observation requires complete --select-family runtime'):
            collector.observation('runtime-summary', dict(kind='exact-line-count', line='old output', count=1), ['execute'], 'execute.log')
        self.assertEqual(family('runtime-summary'), 'runtime')

    def test_selected_runtime_reruns_execution_and_checks_owned_oracle(self):
        fresh = self.seed_observations()
        collector = Collector(self.root, fresh, resume=self.old, selected=['runtime'])
        with self.execute({'execute': (0, 'P08 counter components assertions=10 failures=0\n')}) as executor:
            collector.run('execute', ['execute'])
            collector.observation('runtime-summary', dict(kind='positive-counter-summary', failures=0), ['execute'], 'execute.log')
            collector.run('stable-positive', ['stable'])
        self.assertEqual(executor.call_count, 1)
        self.assertTrue(collector.finish())

    def test_observation_prerequisite_and_evidence_identity_drift_rejected(self):
        for requires, evidence in (([], 'execute.log'), (['execute'], 'another.log')):
            with self.subTest(requires=requires, evidence=evidence):
                fresh = self.seed_observations()
                collector = Collector(self.root, fresh, resume=self.old, selected=['stable'])
                collector.run('execute', ['execute'])
                with self.assertRaisesRegex(ValueError, 'observation requires complete --select-family runtime'):
                    collector.observation('runtime-summary', dict(kind='positive-counter-summary', failures=0), requires, evidence)
                # Keep this temporary-directory case independent of the next subtest.
                (self.root / 'fresh').rename(self.root / ('fresh-' + str(len(requires))))


if __name__ == '__main__':
    unittest.main()
