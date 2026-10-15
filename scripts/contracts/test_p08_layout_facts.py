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


def elf_bytes(values=None, kind=1, duplicate=None, missing=None, relocation=None, body_override=None,
              backing_size=512, backing_address=0x20000000, backing_name=facts.C_SYMBOL, section_alignment=8):
    values = layout_values() if values is None else values
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
            self.assertEqual(len(extracted['symbols']), 129)
            extra = layout_values() | {'giftui_p08_layout_unexpected': 0}
            path.write_bytes(elf_bytes(values=extra))
            with self.assertRaises(ValueError):
                facts.extract(path, dict(slot_bytes=128, slot_count=4, retained_bytes=512))


class InventoryTests(unittest.TestCase):
    @staticmethod
    def actual_rows():
        packet = facts.ROOT / 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/remaining-layout-initial-failure'
        return json.loads((packet / 'measurement-symbols-and-bytes.json').read_text())

    def with_observed_helper(self, elf):
        observed = next(row for row in self.actual_rows() if row['name'] == facts.LOCAL_HELPER)
        # Preserve the actual local/function/Thumb/size shape in a bounded synthetic section.
        helper = {key: observed[key] for key in ('name', 'value', 'size', 'type', 'binding')}
        helper['owner'] = 1
        elf.symbols.append(helper)
        return elf

    def test_exact_known_local_helper_is_separately_recorded(self):
        elf = self.with_observed_helper(facts.ELF(elf_bytes()))
        inventory = facts.classify_inventory(elf)
        self.assertEqual(inventory['global_roots'], list(facts.SYMBOLS))
        self.assertEqual(inventory['nonroot_local_helpers'][0]['name'], facts.LOCAL_HELPER)
        self.assertIs(inventory['nonroot_local_helpers'][0]['measurement_root'], False)

    def test_reject_unknown_exported_duplicate_or_malformed_helper(self):
        for key, value in (('name', facts.LOCAL_HELPER + '1'), ('binding', 1), ('type', 1),
                           ('owner', 0), ('value', 0), ('size', 1 << 31)):
            elf = self.with_observed_helper(facts.ELF(elf_bytes()))
            elf.symbols[-1][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
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
        self.assertEqual(value, dict(slot_bytes=32000, slot_count=4, retained_bytes=128000, c_alignment=8))
        with self.assertRaises(ValueError):
            facts.source_reservation(facts.SWIFT_SOURCE.read_text(), facts.C_SOURCE.read_text().replace('[32000]', '[31999]'))

    def test_exact_accessor_source_inventory_and_projection(self):
        source = facts.ACCESSOR_SOURCE.read_text()
        self.assertEqual(tuple(re.findall(r'@_cdecl\("([^"]+)"\)', source)), facts.SYMBOLS)
        for index, field in enumerate(facts.FIELDS):
            for component, name in enumerate(facts.COMPONENTS):
                self.assertIn('func counterEmbeddedFact' + str(index) + '_' + str(component) +
                              '() -> UInt32 { counterEmbeddedRegionFact(' + str(index) + ', ' + str(component) + ') }', source)
        self.assertIn('CounterEmbeddedLayout(suppliedByteCount: counterEmbeddedSlotBytes)', source)

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
        extracted = dict(values=self.values, layout=self.layout)
        mapping = '\n'.join(facts.SYMBOLS) + '\n .bss.counter_backing.0\n 0x20000000 0x200 app/libapp.a(counter_main.c.obj)\n'
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


if __name__ == '__main__':
    unittest.main()
