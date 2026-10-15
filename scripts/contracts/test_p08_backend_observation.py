"""Compiler-free coverage of actual original-backend facts in the full baseline."""
import pathlib
import re
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]
FIXTURE = ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived'
PAYLOAD_FIELDS = {'tile', 'coverage', 'displayed', 'write', 'surface', 'payload'}


def projected_fields(source, typename):
    storage = source.split('struct ' + typename + ' {', 1)[1].split('\n// Borrow only', 1)[0]
    stored = set(re.findall(r'^    var (\w+)', storage, re.M)) - PAYLOAD_FIELDS
    body = source.split('func counterObserveBackend(_ backend: borrowing ' + typename + ') -> CounterBackendObservation {', 1)[1].split('\n}', 1)[0]
    observed = set(re.findall(r'backend\.(\w+)', body))
    if stored != observed:
        raise ValueError('actual scalar backend fields omitted/substituted: ' + str(stored ^ observed))
    for field in stored:
        if not re.search(r'\b' + field + r': (?:UInt32\()?backend\.' + field + r'\b', body):
            raise ValueError('field does not observe its original value: ' + field)
    return stored


class BackendObservationTests(unittest.TestCase):
    def test_both_actual_profiles_observe_every_nonpayload_stored_field(self):
        owner = (FIXTURE / 'CounterPipelineOwner.swift').read_text()
        fields = owner.split('struct CounterBackendObservation: Equatable {', 1)[1].split('\n}', 1)[0]
        declared = set(re.findall(r'^    let (\w+):', fields, re.M))
        for file, typename in (('CounterNativeRaster.swift', 'CounterNativeBackendStorage'),
                               ('CounterTiledRaster.swift', 'CounterTiledBackendStorage')):
            with self.subTest(profile=typename):
                self.assertEqual(projected_fields((FIXTURE / file).read_text(), typename), declared)
        self.assertTrue({'active', 'reservations', 'submissions', 'finishes', 'cancellations',
                         'submittedBytes', 'submittedRows', 'health'} <= declared)

    def test_missing_or_fabricated_completion_value_is_rejected(self):
        for file, typename in (('CounterNativeRaster.swift', 'CounterNativeBackendStorage'),
                               ('CounterTiledRaster.swift', 'CounterTiledBackendStorage')):
            source = (FIXTURE / file).read_text()
            for field in ('active', 'reservations', 'submittedBytes', 'submittedRows', 'health'):
                with self.subTest(profile=typename, field=field), self.assertRaises(ValueError):
                    projected_fields(source.replace('backend.' + field, 'fabricated', 1), typename)

    def test_row_width_uses_exact_actual_native_and_tiled_values(self):
        native = (FIXTURE / 'CounterNativeRaster.swift').read_text()
        tiled = (FIXTURE / 'CounterTiledRaster.swift').read_text()
        self.assertIn('var submittedRows: UInt16 = 0', native)
        self.assertIn('submittedRows: UInt32(backend.submittedRows)', native)
        self.assertIn('var submittedRows: UInt32 = 0', tiled)
        self.assertIn('submittedRows: backend.submittedRows', tiled)

    def test_backend_is_in_same_equatable_baseline_and_guard_comparison(self):
        owner = (FIXTURE / 'CounterPipelineOwner.swift').read_text()
        slot = owner.split('struct CounterRuntimeSlotObservation: Equatable {', 1)[1]
        self.assertIn('let backend: CounterBackendObservation', slot)
        self.assertIn('backend = counterObserveBackend(control.pointee.backend)', slot)
        scoped = (FIXTURE / 'CounterScopedStorage.swift').read_text()
        self.assertIn('let runtimeSlot: CounterRuntimeSlotObservation', scoped)
        self.assertIn('runtimeSlot = CounterRuntimeSlotObservation(control)', scoped)
        guards = scoped.split('fileprivate func p08RuntimeSlotGuardControls(', 1)[1]
        self.assertEqual(guards.count('let before = CounterRuntimeSlotObservation(control)'), 1)
        self.assertIn('let same = CounterRuntimeSlotObservation(control) == before', guards)
        self.assertIn('let duplicate = control.pointee.tryClaimRuntimeSlot()', guards)
        self.assertIn('let wrongClear = control.pointee.tryClearRuntimeSlot(wrong.partialValue)', guards)


if __name__ == '__main__':
    unittest.main()
