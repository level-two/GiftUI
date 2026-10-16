"""Compiler-free tests of the strict target-byte decoder and layout evidence."""
import copy
import json
import pathlib
import re
import struct
import tempfile
import unittest

import p08_layout_facts as facts


def wide(base, value):
    return struct.pack('<HH', base | (value >> 12 & 15) | (value >> 11 & 1) << 10,
                       (value >> 8 & 7) << 12 | value & 255)


def constant(value):
    return wide(0xF240, value & 65535) + (wide(0xF2C0, value >> 16) if value >> 16 else b'') + b'\x70\x47'


def layout_values():
    values = {}
    for index, field in enumerate(facts.FIELDS):
        for key, value in zip(facts.COMPONENTS, (index * 4, 1, 4, 4, 4)):
            values['giftui_p08_layout_' + field + '_' + key] = value
    values.update({'giftui_p08_layout_cursor': 100, 'giftui_p08_layout_maximumAlignment': 4,
                   'giftui_p08_layout_slotBytes': 100, 'giftui_p08_layout_totalBytes': 400})
    return values


def metadata_values():
    values = {}
    for index, field in enumerate(facts.METADATA_FIELDS):
        for key, value in zip(facts.METADATA_COMPONENTS, (index * 8, 5, 8, 8)):
            values['giftui_p08_metadata_' + field + '_' + key] = value
    values.update(giftui_p08_metadata_cursor=56, giftui_p08_metadata_maximumAlignment=8,
                  giftui_p08_metadata_extent=56)
    return values


def elf_bytes(values=None, kind=1, duplicate=None, missing=None, relocation=None, body_override=None,
              backing_size=512, backing_address=0x20000000, backing_name=facts.C_SYMBOL, section_alignment=8):
    values = (layout_values() | metadata_values()) if values is None else values
    names = ['.text', '.strtab', '.symtab', '.shstrtab', '.rel.text', '.bss']
    shstrings = b'\0'
    shnames = {}
    for name in names:
        shnames[name] = len(shstrings)
        shstrings += name.encode() + b'\0'
    strings = b'\0'
    symbols = bytes(16)
    text = b''
    for name, value in values.items():
        if name == missing:
            continue
        offset = len(text)
        body = body_override if body_override is not None else constant(value)
        text += body
        position = len(strings)
        strings += name.encode() + b'\0'
        entry = struct.pack('<IIIBBH', position, (0x1000 if kind == 2 else 0) + offset + 1,
                            len(body), 0x12, 0, 1)
        symbols += entry * (2 if name == duplicate else 1)
    position = len(strings)
    strings += backing_name.encode() + b'\0'
    symbols += struct.pack('<IIIBBH', position, backing_address, backing_size, 1, 0, 6)
    relocation_data = b'' if relocation is None else struct.pack('<II', relocation, 2)
    payload = bytearray(bytes(52))
    sections = [(0,) * 10]
    entries = [(1, 6, text, 0x1000 if kind == 2 else 0, 0, 0, 2, 0),
               (3, 0, strings, 0, 0, 0, 1, 0), (2, 0, symbols, 0, 2, 1, 4, 16),
               (3, 0, shstrings, 0, 0, 0, 1, 0), (9, 0, relocation_data, 0, 3, 1, 4, 8),
               (8, 3, b'', backing_address, 0, 0, section_alignment, 0)]
    for name, (kind_code, flags, data, address, link, info, alignment, entry_size) in zip(names, entries):
        offset = len(payload)
        payload.extend(data)
        sections.append((shnames[name], kind_code, flags, address, offset,
                         backing_size if kind_code == 8 else len(data), link, info, alignment, entry_size))
    section_offset = len(payload)
    payload.extend(b''.join(struct.pack('<10I', *entry) for entry in sections))
    payload[:52] = struct.pack('<16sHHIIIIIHHHHHH', b'\x7fELF\x01\x01\x01' + bytes(9), kind, 40,
                               1, 0, 0, section_offset, 0x05000400, 52, 0, 0, 40, len(sections), 4)
    return bytes(payload)


class DecoderTests(unittest.TestCase):
    def test_movs_boundaries(self):
        for value in (0, 1, 255):
            self.assertEqual(facts.decode_return(struct.pack('<HH', 0x2000 | value, 0x4770)), value)

    def test_movw_movt_boundaries(self):
        for value in (0, 255, 256, 4095, 65535, 65536, 0x80000000, 0xFFFFFFFF, 0x12345678):
            self.assertEqual(facts.decode_return(constant(value)), value)

    def test_modified_immediates(self):
        for body, value in ((b'\x4f\xf0\xff\x00\x70\x47', 255),
                            (b'\x4f\xf0\x01\x20\x70\x47', 0x01000100),
                            (b'\x4f\xf0\xff\x30\x70\x47', 0xFFFFFFFF),
                            (b'\x4f\xf0\x00\x40\x70\x47', 0x80000000)):
            self.assertEqual(facts.decode_return(body), value)

    def test_movt_after_movs(self):
        self.assertEqual(facts.decode_return(b'\x01\x20' + wide(0xF2C0, 0x1234) + b'\x70\x47'), 0x12340001)

    def test_reject_effects_and_noncanonical_bodies(self):
        for body in (b'\x00\x68\x70\x47', b'\x00\xb5\x70\x47', b'\x00\xe0\x70\x47',
                     b'\x00\xf0\x00\xf8\x70\x47', wide(0xF2C0, 1) + b'\x70\x47',
                     constant(1) + b'\x00\xbf', constant(1)[:-1], b'\x01\x21\x70\x47',
                     b'\x4f\xf0\x00\x10\x70\x47', b'\x4f\xf0\x01\x01\x70\x47'):
            with self.subTest(body=body.hex()), self.assertRaises(ValueError):
                facts.decode_return(body)


class ELFTests(unittest.TestCase):
    def test_object_and_executable_thumb_normalization(self):
        for kind in (1, 2):
            elf = facts.ELF(elf_bytes(kind=kind))
            found = elf.constant(facts.SYMBOLS[0])
            self.assertEqual(found['value'], 0)
            self.assertEqual(found['address'] & 1, 1)

    def test_missing_duplicate_and_undefined_symbols(self):
        name = facts.SYMBOLS[0]
        for data in (elf_bytes(missing=name), elf_bytes(duplicate=name)):
            with self.assertRaises(ValueError):
                facts.ELF(data).constant(name)
        elf = facts.ELF(elf_bytes())
        elf.symbols[1]['owner'] = 0
        with self.assertRaises(ValueError):
            elf.constant(name)

    def test_relocation_rejected(self):
        for kind, address in ((1, 0), (1, 2), (2, 0x1000)):
            with self.assertRaisesRegex(ValueError, 'relocation'):
                facts.ELF(elf_bytes(kind=kind, relocation=address)).constant(facts.SYMBOLS[0])

    def test_bounds_permissions_and_full_consumption(self):
        for key, value in (('size', 1 << 31), ('value', 0xFFFFFFFF)):
            elf = facts.ELF(elf_bytes())
            elf.symbols[1][key] = value
            with self.assertRaises(ValueError):
                elf.constant(facts.SYMBOLS[0])
        for flags in (2, 3, 7):
            elf = facts.ELF(elf_bytes())
            elf.sections[1]['flags'] = flags
            with self.assertRaises(ValueError):
                elf.constant(facts.SYMBOLS[0])
        with self.assertRaises(ValueError):
            facts.ELF(elf_bytes(body_override=constant(1) + b'\x00\xbf')).constant(facts.SYMBOLS[0])

    def test_malformed_file_bounds(self):
        data = elf_bytes()
        for bad in (data[:30], data[:-1], data[:6] + b'\x02' + data[7:]):
            with self.assertRaises(ValueError):
                facts.ELF(bad)

    def test_exact_inventory(self):
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / 'test.o'
            path.write_bytes(elf_bytes())
            _, extracted = facts.extract(path, dict(slot_bytes=128, slot_count=4, retained_bytes=512))
            self.assertEqual(len(extracted['symbols']), 160)
            extra = layout_values() | {'giftui_p08_layout_unexpected': 0}
            path.write_bytes(elf_bytes(values=extra))
            with self.assertRaises(ValueError):
                facts.extract(path, dict(slot_bytes=128, slot_count=4, retained_bytes=512))


    def test_decoded_facts_survive_reservation_failure_without_accepted_layout(self):
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / 'test.o'
            raw = pathlib.Path(directory) / 'decoded.json'
            path.write_bytes(elf_bytes())
            with self.assertRaises(ValueError):
                facts.extract(path, dict(slot_bytes=96, slot_count=4, retained_bytes=384), raw, 'a' * 64)
            record = json.loads(raw.read_text())
            self.assertFalse(record['accepted'])
            self.assertTrue(record['diagnostic_only'])
            self.assertEqual(record['values'], layout_values() | metadata_values())
            self.assertNotIn('layout', record)
            self.assertEqual(record['compiler_sha256'], 'a' * 64)
            self.assertEqual(record['artifact_sha256'], facts.digest(path))

    def test_failed_byte_proof_cannot_emit_decoded_fact_packet(self):
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / 'test.o'
            raw = pathlib.Path(directory) / 'decoded.json'
            path.write_bytes(elf_bytes(body_override=b'\x00\x68\x70\x47'))
            with self.assertRaises(ValueError):
                facts.extract(path, dict(slot_bytes=128, slot_count=4, retained_bytes=512), raw)
            self.assertFalse(raw.exists())


class InventoryTests(unittest.TestCase):
    @staticmethod
    def actual_rows():
        packet = facts.ROOT / 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/remaining-layout-initial-failure'
        return json.loads((packet / 'measurement-symbols-and-bytes.json').read_text())

    def with_observed_helper(self, elf):
        observed = next(row for row in self.actual_rows() if row['name'] == 'giftui_p08_layout_limits_offsetTm')
        # Preserve the actual local/function/Thumb/size shape in a bounded synthetic section.
        helper = {key: observed[key] for key in ('name', 'value', 'size', 'type', 'binding')}
        helper.update(owner=len(elf.sections), table=3, index=len(elf.symbol_tables[3]))
        body = bytes.fromhex(observed['body_hex'])
        elf.sections.append(dict(name='.text.local-helper', type=1, flags=6, address=0,
                                 offset=len(elf.data), size=len(body)))
        elf.data += body
        elf.symbols.append(helper)
        elf.symbol_tables[3].append(helper)
        return elf

    def test_exact_known_local_helper_is_separately_recorded(self):
        elf = self.with_observed_helper(facts.ELF(elf_bytes()))
        inventory = facts.classify_inventory(elf)
        self.assertEqual(inventory['global_roots'], list(facts.SYMBOLS))
        self.assertEqual(inventory['nonroot_local_helpers'][0]['symbol'], 'giftui_p08_layout_limits_offsetTm')
        self.assertIs(inventory['nonroot_local_helpers'][0]['measurement_root'], False)

    def test_reject_exported_duplicate_or_malformed_helper(self):
        for key, value in (('binding', 1), ('binding', 2), ('type', 1),
                           ('owner', 0), ('value', 0), ('size', 1 << 31)):
            elf = self.with_observed_helper(facts.ELF(elf_bytes()))
            elf.symbols[-1][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                facts.classify_inventory(elf)

    def test_local_names_are_not_a_whitelist_or_fact_authority(self):
        elf = self.with_observed_helper(facts.ELF(elf_bytes()))
        elf.symbols[-1]['name'] = 'giftui_p08_layout_differentCompilerLocal'
        inventory = facts.classify_inventory(elf)
        self.assertIs(inventory['nonroot_local_helpers'][0]['measurement_root'], False)
        # Every required root still must prove its complete byte semantics.
        self.assertEqual(elf.constant(facts.SYMBOLS[0])['value'], 0)

    def test_local_inventory_has_a_finite_bound(self):
        elf = facts.ELF(elf_bytes())
        for index in range(facts.MAX_LOCAL_HELPERS + 1):
            self.with_observed_helper(elf)
            elf.symbols[-1]['name'] = 'giftui_p08_layout_local' + str(index)
        with self.assertRaisesRegex(ValueError, 'excess'):
            facts.classify_inventory(elf)
        elf = self.with_observed_helper(facts.ELF(elf_bytes()))
        elf.symbols.append(elf.symbols[-1].copy())
        with self.assertRaises(ValueError):
            facts.classify_inventory(elf)

    def test_every_root_must_remain_exact_global_defined_function(self):
        for key, value in (('binding', 0), ('binding', 2), ('type', 1), ('owner', 0)):
            elf = facts.ELF(elf_bytes())
            elf.symbols[1][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                facts.classify_inventory(elf)
        for data in (elf_bytes(missing=facts.SYMBOLS[0]), elf_bytes(duplicate=facts.SYMBOLS[0])):
            with self.assertRaises(ValueError):
                facts.classify_inventory(facts.ELF(data))

    def test_actual_call_body_remains_rejected_after_inventory_classification(self):
        root = next(row for row in self.actual_rows() if row['name'] == facts.SYMBOLS[0])
        elf = self.with_observed_helper(facts.ELF(elf_bytes(body_override=bytes.fromhex(root['body_hex']), relocation=0)))
        facts.classify_inventory(elf)
        with self.assertRaisesRegex(ValueError, 'relocation'):
            elf.constant(root['name'])
        with self.assertRaises(ValueError):
            facts.decode_return(bytes.fromhex(root['body_hex']))


class LayoutTests(unittest.TestCase):
    def setUp(self):
        self.reservation = dict(slot_bytes=128, slot_count=4, retained_bytes=512, c_alignment=8)
        self.values = layout_values()
        self.layout = facts.validate_layout(self.values, self.reservation)

    def test_source_constants(self):
        value = facts.source_reservation(facts.SWIFT_SOURCE.read_text(), facts.C_SOURCE.read_text())
        self.assertEqual(value, dict(slot_bytes=34720, slot_count=4, retained_bytes=138880, c_alignment=8))
        with self.assertRaises(ValueError):
            facts.source_reservation(facts.SWIFT_SOURCE.read_text(), facts.C_SOURCE.read_text().replace('[34720]', '[34719]'))

    def test_exact_accessor_source_inventory_and_projection(self):
        source = facts.ACCESSOR_SOURCE.read_text()
        self.assertEqual(tuple(re.findall(r'@_cdecl\("([^"]+)"\)', source)), facts.SYMBOLS)
        for index, field in enumerate(facts.FIELDS):
            for component, name in enumerate(facts.COMPONENTS):
                self.assertIn('func counterEmbeddedFact' + str(index) + '_' + str(component) +
                              '() -> UInt32 { counterEmbeddedRegionFact(' + str(index) + ', ' + str(component) + ') }', source)
        self.assertIn('counterDeriveEmbeddedLayout(', source)
        runtime = facts.SWIFT_SOURCE.read_text()
        self.assertIn('summary.slotBytes <= suppliedByteCount', runtime)
        self.assertIn('counterDeriveEmbeddedLayout(r1Surplus: r1Surplus, visit)', runtime)
        self.assertNotIn('CounterEmbeddedLayout(suppliedByteCount:', source)
        self.assertNotIn('.init(repeating:', source)

    def test_surplus_is_fully_charged(self):
        self.assertEqual(self.layout['retained_surplus'], 112)
        self.assertEqual(self.layout['retained_bytes'], 512)

    def test_wrong_bounds_overlap_and_summaries(self):
        for key, value in (('giftui_p08_layout_root_offset', 0), ('giftui_p08_layout_limits_alignment', 3),
                           ('giftui_p08_layout_limits_stride', 2), ('giftui_p08_layout_limits_count', 0xFFFFFFFF),
                           ('giftui_p08_layout_slotBytes', 101), ('giftui_p08_layout_totalBytes', 399)):
            values = self.values | {key: value}
            with self.subTest(key=key), self.assertRaises(ValueError):
                facts.validate_layout(values, self.reservation)

    def test_actual_slot_spacing_alignment(self):
        with self.assertRaisesRegex(ValueError, 'spacing'):
            facts.validate_layout(self.values, self.reservation | dict(slot_bytes=129, retained_bytes=516))

    def test_checked_arithmetic(self):
        for function, args in ((facts.checked_add, (facts.U32_MAX, 1)),
                               (facts.checked_multiply, (facts.U32_MAX, 4)), (facts.checked_add, (-1, 0))):
            with self.assertRaises(ValueError):
                function(*args)

    def compare(self, data=None, prior=None, map_text=None):
        elf = facts.ELF(elf_bytes(kind=2) if data is None else data)
        extracted = dict(values=self.values, layout=self.layout,
                         metadata_layout=facts.validate_metadata_layout(metadata_values(), self.reservation))
        mapping = '\n'.join(facts.ALL_SYMBOLS) + '\n .bss.counter_backing.0\n 0x20000000 0x200 app/libapp.a(counter_main.c.obj)\n'
        return facts.compare_firmware(extracted, copy.deepcopy(extracted) if prior is None else prior,
                                      elf, self.reservation, mapping if map_text is None else map_text)

    def test_firmware_c_exact_symbol_size_alignment_and_origins(self):
        result = self.compare()
        self.assertEqual(result['slot_origins'], [0x20000000, 0x20000080, 0x20000100, 0x20000180])
        for kwargs in (dict(backing_size=511), dict(backing_address=0x20000004),
                       dict(section_alignment=4), dict(backing_name='other_counter_backing.0')):
            with self.subTest(kwargs=kwargs), self.assertRaises(ValueError):
                self.compare(elf_bytes(kind=2, **kwargs))

    def test_object_elf_mismatch_and_missing_map(self):
        prior = dict(values=self.values | {facts.SYMBOLS[0]: 1}, layout=self.layout)
        with self.assertRaisesRegex(ValueError, 'SO07/SO08'):
            self.compare(prior=prior)
        with self.assertRaises(ValueError):
            self.compare(map_text='')


class MetadataLayoutTests(unittest.TestCase):
    def setUp(self):
        self.reservation = dict(slot_bytes=128, slot_count=4, retained_bytes=512)
        self.values = metadata_values()

    def test_seven_full_stride_objects_and_complete_charge(self):
        layout = facts.validate_metadata_layout(self.values, self.reservation)
        self.assertEqual(len(layout['regions']), 7)
        self.assertEqual(layout['extent'], 56)
        self.assertEqual(layout['donor_padding'], 72)
        self.assertEqual(layout['retained_bytes'], 512)
        self.assertEqual(layout['additional_retained_bytes'], 0)
        self.assertTrue(all(row['extent'] == 8 and row['count'] == 1 for row in layout['regions']))

    def test_reject_missing_extra_bad_bound_padding_and_arithmetic(self):
        cases = [self.values | {'extra': 1}]
        missing = self.values.copy(); missing.pop(next(iter(missing))); cases.append(missing)
        for key, value in [('owner_offset', 0), ('owner_alignment', 3), ('owner_stride', 4),
                           ('owner_size', 9), ('owner_stride', 0xFFFFFFFF),
                           ('cursor', 55), ('extent', 55), ('maximumAlignment', 4)]:
            cases.append(self.values | {'giftui_p08_metadata_' + key: value})
        for values in cases:
            with self.subTest(values=values), self.assertRaises(ValueError):
                facts.validate_metadata_layout(values, self.reservation)
        for reservation in [self.reservation | dict(slot_bytes=55), self.reservation | dict(slot_bytes=129)]:
            with self.assertRaises(ValueError): facts.validate_metadata_layout(self.values, reservation)

    def test_exact_roots_for_object_and_elf_and_fail_closed(self):
        for kind in (1, 2):
            elf = facts.ELF(elf_bytes(self.values, kind=kind))
            inventory = facts.classify_inventory(elf, facts.METADATA_SYMBOLS, 'giftui_p08_metadata_')
            self.assertEqual(len(inventory['global_roots']), 31)
            for name, value in self.values.items(): self.assertEqual(elf.constant(name)['value'], value)
        for data in [elf_bytes(self.values, missing=facts.METADATA_SYMBOLS[0]),
                     elf_bytes(self.values, duplicate=facts.METADATA_SYMBOLS[0]),
                     elf_bytes(self.values | {'giftui_p08_metadata_extra': 0})]:
            with self.assertRaises(ValueError):
                facts.classify_inventory(facts.ELF(data), facts.METADATA_SYMBOLS, 'giftui_p08_metadata_')

    def test_final_root_source_and_single_derivation(self):
        source = facts.METADATA_SOURCE.read_text()
        actual = re.findall(r'@_cdecl\("(giftui_p08_metadata_[^"]+)"\)', source)
        self.assertEqual(tuple(actual), facts.METADATA_SYMBOLS)
        self.assertIn('p08DeriveMetadataLayout(', source)
        self.assertIn('let p = P08MetadataPointers(donor: donor)', source)
        self.assertNotIn('fileprivate func p08EmbeddedFaultCase', source)
        self.assertNotIn('fileprivate func p08SurplusBacking', source)

    def test_complete_donor_map_and_shared_custody_routes(self):
        scoped = facts.METADATA_SOURCE.read_text()
        self.assertIn('return (active, 1, active == 3 ? 2 : 3)', scoped)
        self.assertIn('return (0, surplus == 0 ? 1 : 2, 3)', scoped)
        self.assertIn('activeEnd <= donorStart || donorEnd <= activeStart', scoped)
        self.assertIn('_ = consume p', scoped)
        for active, count, donor in [(0,1,3),(1,1,3),(2,1,3),(3,1,2),(0,2,3)]:
            start, end = active*34720, (active+count)*34720
            donor_start, donor_end = donor*34720, (donor+1)*34720
            self.assertTrue(end <= donor_start or donor_end <= start)
        self.assertFalse(69440 <= 34720 or 69440 <= 0) # S1 is not a surplus donor.
        self.assertIn('for prefix: UInt8 in 0...7', scoped)
        self.assertIn('case .reserved: return acquired == 0', scoped)
        self.assertIn('case .active: return false', scoped)
        self.assertIn('p08PrepareMetadata(p,', scoped)
        self.assertIn('let checks = p08RunMetadataCase(plan,', scoped)
        self.assertIn('p08DestroyMetadata(p, prefix:', scoped)
        # Existing selection count: graph1, hosts9, reuse1, exchange2, invalid1,
        # fourteen before/after faults, every nonempty short byte prefix, early5/candidate11.
        self.assertEqual(1+9+1+2+1+28+(1023+1055+19+111)+5+11,2266)

    def test_inventory_and_borrowed_host_assertions_use_owned_bools(self):
        source = facts.METADATA_SOURCE.read_text()
        inventory = source.split('fileprivate func p08RequireSameInventory(')[1].split('fileprivate struct P08ReuseFingerprint')[0]
        self.assertEqual(inventory.count('borrowing InlineArray<14, P08InitializedEntry?>'), 2)
        self.assertIn('for index in 0..<14', inventory)
        self.assertIn('let same = current[index] == original[index]', inventory)
        self.assertIn('precondition(same)', inventory)
        self.assertNotIn('precondition(current', inventory)
        action = source.split('fileprivate func p08ReuseRejectAction<Owner>')[1].split('fileprivate func p08ReuseRejectInput<Owner>')[0]
        self.assertIn('host: inout', action)
        for step in ('Prepare', 'Delivery'):
            self.assertIn('let modelUnchangedAfter' + step + ': Bool', action)
            self.assertIn('if fingerprintUnchangedAfter' + step + ' {\n        modelUnchangedAfter' + step + ' = p08ReuseModelValue(host: &host) == modelBefore\n    } else {\n        modelUnchangedAfter' + step + ' = false', action)
            self.assertIn('fingerprintUnchangedAfter' + step + ' && modelUnchangedAfter' + step, action)
        self.assertNotIn('&& p08ReuseModelValue', action)

    def test_full_endpoint_and_baseline_observation_inventory(self):
        directory = facts.METADATA_SOURCE.parent
        pipeline = (directory / 'CounterPipelineOwner.swift').read_text()
        observation = pipeline.split('struct CounterEndpointObservation:')[1].split('// Captured only once')[0]
        fields = re.findall(r'    let (\w+):', observation)
        for filename in ('CounterNativeRaster.swift', 'CounterTiledRaster.swift'):
            source = (directory / filename).read_text()
            capture = source.split('func captureBaselinePrefix(')[1].split('func matchesBaselinePrefix(')[0]
            match = source.split('func matchesBaselinePrefix(')[1].split('var ownedObservation:')[0]
            for field in fields:
                if field == 'health':
                    self.assertIn('static func runtimeBaselineHealth(at control: UnsafeMutablePointer<CounterControl>) -> GiftUIOperationalHealth?', capture)
                    target = 'actual.sink.target' if filename == 'CounterNativeRaster.swift' else 'actual.sink.session.target'
                    self.assertIn('control.pointee.runtimeEndpoint?.' + target + '.control.pointee.backend.health', capture)
                    self.assertNotIn('\n        control.pointee.backend.health', capture)
                    runtime = pipeline.split('struct CounterRuntimeSlotBaseline:')[1]
                    self.assertIn('endpoint.health = CounterEndpoint.runtimeBaselineHealth(at: control)', runtime)
                    self.assertIn('endpoint.health == CounterEndpoint.runtimeBaselineHealth(at: control)', runtime)
                else:
                    self.assertIn('baseline.' + field, capture)
                    self.assertIn('baseline.' + field, match)
            self.assertIn('baseline.recording.captureEndpoint(&self)', capture)
            self.assertIn('baseline.recording.matchesEndpoint(&self)', match)
            self.assertNotIn('recording.matches(actual.sink.recording)', match)
            self.assertNotIn('&actual.sink', capture + match)
        recording = pipeline.split('struct CounterRecordingObservation:')[1].split('struct CounterWriterObservation:')[0]
        self.assertIn('for index in 0..<64', recording)
        self.assertNotIn('let a =', recording)
        scoped = facts.METADATA_SOURCE.read_text()
        self.assertNotIn('P08ReuseFingerprint(control)', scoped)
        self.assertIn('let canCapture = !frozen; precondition(canCapture)', scoped)
        origins = scoped.split('fileprivate func p08ReuseRejectOldOrigins<Owner>', 1)[1].split('fileprivate func p08ReuseCurrentPointer<Owner>', 1)[0]
        self.assertIn('baseline: inout P08ReuseFingerprint', origins)
        self.assertEqual(origins.count('baseline.capture(control)'), 1)
        self.assertIn('p08CheckBaselineSensitivity(&baseline, control: control)', origins)
        self.assertNotIn('baseline.pointee', origins)

    def test_original_recording_operations_compare_complete_actual_fields(self):
        pipeline = (facts.METADATA_SOURCE.parent / 'CounterPipelineOwner.swift').read_text()
        recording = pipeline.split('struct CounterRecordingObservation:')[1].split('struct CounterWriterObservation:')[0]
        fields = ('capacity', 'header', 'operations', 'glyphs', 'strokes', 'finishes', 'discards', 'firstPoint', 'secondPoint', 'strokeHeader')
        for operation, current in [('Accepted', 'control.pointee.lastFrame'), ('Endpoint', 'endpoint.actual.sink.recording')]:
            body = recording.split('mutating func matches' + operation + '(')[1].split('return true')[0]
            def complete(text):
                return all('value.' + field + ' == ' + current + '.' + field in text for field in fields) and 'for index in 0..<64' in text and 'value.glyphRecords[index] == ' + current + '.glyphRecords[index]' in text
            self.assertTrue(complete(body))
            for field in fields:
                self.assertFalse(complete(body.replace('value.' + field + ' == ', 'nil == ', 1)))
            self.assertFalse(complete(body.replace('0..<64', '0..<63')))
            self.assertNotIn('borrowing CounterRenderSink', body)

    def test_complete_key_probe_recipes_and_saved_restoration(self):
        pipeline = (facts.METADATA_SOURCE.parent / 'CounterPipelineOwner.swift').read_text()
        slot = pipeline.split('struct CounterRuntimeSlotBaseline:')[1]
        for index, (saved, actual) in enumerate([('root', 'runtimeRootIdentity'), ('action', 'runtimeActionIdentity'), ('candidateRoot', 'runtimeCandidateRootIdentity'), ('candidateAction', 'runtimeCandidateActionIdentity')]):
            body = slot.split('mutating func installKeyProbe' + str(index) + '(')[1].split('mutating func restoreKeyProbe' + str(index) + '(')[0]
            self.assertEqual(body.count('kind: .root'), 2)
            self.assertIn('ordinal: 4', body)
            self.assertIn('ordinal: 3', body)
            self.assertIn('let distinct = ' + saved + ' != changed; precondition(distinct)', body)
            self.assertIn('control.pointee.' + actual + ' = changed', body)
            restore = slot.split('mutating func restoreKeyProbe' + str(index) + '(')[1].split('}')[0]
            self.assertIn('control.pointee.' + actual + ' = ' + saved, restore)
            self.assertNotIn('ordinal: 31', body)

    def test_sensitivity_full_false_then_restore_then_full_true(self):
        source = facts.METADATA_SOURCE.read_text()
        sensitivity = source.split('fileprivate func p08CheckBaselineSensitivity(')[1].split('// Borrow the host only')[0]
        self.assertIn('for index in 0..<64', sensitivity)
        for index in range(4):
            install = sensitivity.index('before.installKeyProbe' + str(index) + '(control)')
            rejected = sensitivity.index('let rejects' + str(index) + ' = !before.matches(control)', install)
            restore = sensitivity.index('before.restoreKeyProbe' + str(index) + '(control)', rejected)
            positive = sensitivity.index('let restored' + str(index) + ' = before.matches(control)', restore)
            self.assertLess(install, rejected)
            self.assertLess(rejected, restore)
            self.assertLess(restore, positive)
        self.assertEqual(sensitivity.count('let restored = before.matches(control)'), 10)
        self.assertIn('return 156', sensitivity)
        self.assertNotIn('.capture(', sensitivity)

    def test_scalar_guard_truth_tables_and_actual_field_map(self):
        import itertools
        pipeline = (facts.METADATA_SOURCE.parent / 'CounterPipelineOwner.swift').read_text()
        vacant = pipeline.split('static func requireVacantRuntimeSlot(at ')[1].split('borrowing func requireRuntimeClaim')[0]
        projections = [('phaseVacant', 'runtimeSlotPhase == .vacant'), ('ownerAbsent', 'runtimeSlotOwner == nil'), ('endpointAbsent', 'runtimeEndpoint == nil'), ('rootAbsent', 'runtimeRootIdentity == nil'), ('actionAbsent', 'runtimeActionIdentity == nil'), ('candidateRootAbsent', 'runtimeCandidateRootIdentity == nil'), ('candidateActionAbsent', 'runtimeCandidateActionIdentity == nil')]
        def complete(text):
            return all('let ' + name + ' = control.pointee.' + expression in text for name, expression in projections)
        self.assertTrue(complete(vacant))
        for name, expression in projections:
            self.assertFalse(complete(vacant.replace(expression, 'runtimeSlotPhase == .installed', 1)))
        common = pipeline.split('private static func requireVacantFacts(')[1].split('private static func requireClaimFacts')[0]
        expressions = dict(re.findall(r'let (\w+) = ([^\n]+)', common))
        for bits in itertools.product([False, True], repeat=7):
            values = dict(zip([name for name, _ in projections], bits))
            for name in ['vacant', 'noKeys']:
                values[name] = eval(expressions[name].replace('&&', ' and '), {'__builtins__': {}}, values)
            self.assertEqual(values['vacant'] and values['noKeys'], all(bits))
        claim = pipeline.split('private static func requireClaimFacts(')[1].split('borrowing func requireVacantRuntimeSlot')[0]
        expression = re.search(r'let matches = ([^\n]+)', claim).group(1)
        for sameOwner, installed, quiesced, endpointPresent in itertools.product([False, True], repeat=4):
            expected = sameOwner and (installed or quiesced) and endpointPresent
            self.assertEqual(eval(expression.replace('&&', ' and ').replace('||', ' or '), {'__builtins__': {}}, locals()), expected)
        self.assertNotIn('requireVacantRuntimeSlot()\n        return true', pipeline)

    def test_health_uses_actual_target_and_ends_endpoint_loans(self):
        pipeline = (facts.METADATA_SOURCE.parent / 'CounterPipelineOwner.swift').read_text()
        runtime = pipeline.split('struct CounterRuntimeSlotBaseline:')[1]
        match = runtime.split('mutating func matches(_ control:')[1]
        self.assertLess(match.index('matchesBaselinePrefix(&endpoint)'), match.index('CounterEndpoint.runtimeBaselineHealth(at: control)'))
        self.assertLess(match.index('CounterEndpoint.runtimeBaselineHealth(at: control)'), match.index('matchesBaselineSuffix(&endpoint)'))
        self.assertNotIn('&control.pointee', match)
        for name, target in [('CounterNativeRaster.swift', 'actual.sink.target'), ('CounterTiledRaster.swift', 'actual.sink.session.target')]:
            source = (facts.METADATA_SOURCE.parent / name).read_text()
            body = source.split('static func runtimeBaselineHealth(')[1].split('}')[0]
            expression = 'control.pointee.runtimeEndpoint?.' + target + '.control.pointee.backend.health'
            self.assertIn(expression, body)
            self.assertNotIn(expression, body.replace(target + '.control', 'control'))
            self.assertNotIn('return control', body)
            self.assertNotIn('inout', body)

    def test_new_inout_model_and_teardown_rhs_preserve_skips(self):
        source = facts.METADATA_SOURCE.read_text()
        for name, expected in [('p08ReuseCurrentActionDown', '1'), ('p08ReuseCurrentActionUp', '2')]:
            body = source.split('fileprivate func ' + name + '<Owner>')[1].split('@inline(never)')[0]
            self.assertIn('if captureMatches { captureAndModelMatch = p08ReuseModelValue(host: &host) == ' + expected + ' }', body)
            self.assertIn('else { captureAndModelMatch = false }', body)
            self.assertNotIn('&& p08ReuseModelValue', body)
        terminal = source.split('fileprivate func p08ReuseTerminal<Owner>')[1].split('fileprivate func p08RunReuseHost')[0]
        self.assertIn('if quiescent { terminalState = p08ReuseTeardownStep(host: &host) == 8 }', terminal)
        self.assertIn('else { terminalState = false }', terminal)


if __name__ == '__main__':
    unittest.main()
