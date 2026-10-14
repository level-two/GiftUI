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
        receipt = dict(collection_schema=1, collection_complete=True, passed=passed,
                       checks=collector.checks, inputs=inputs or {},
                       artifacts={path.name: dict(sha256=digest(path)) for path in self.old.iterdir() if path.is_file()})
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
        collector.observation('so06-reuse-dynamic-action-current', True, ['execute'], 'execute.log')
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


if __name__ == '__main__':
    unittest.main()
