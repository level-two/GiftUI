"""Compiler-free complete-function tail proof fixtures, including real failed bodies."""
import json
import struct
import unittest

import p08_layout_facts as facts
from test_p08_layout_facts import constant


def branch(displacement):
    assert -(1 << 24) <= displacement < (1 << 24) and displacement % 2 == 0
    bits = displacement & ((1 << 25) - 1)
    sign, i1, i2 = bits >> 24, bits >> 23 & 1, bits >> 22 & 1
    first = 0xF000 | sign << 10 | (bits >> 12 & 0x3FF)
    second = 0x9000 | (1 ^ i1 ^ sign) << 13 | (1 ^ i2 ^ sign) << 11 | (bits >> 1 & 0x7FF)
    return struct.pack('<HH', first, second)


def fixture(nodes, edges=(), kind=1, relocation_link=3, residual=False, duplicate_relocation=False,
            text_alignment=2):
    """A real ELF32 with independently linked primary/auxiliary symbol tables."""
    edges = dict(edges)
    base = 0x1000 if kind == 2 else 0
    positions, cursor = {}, 0
    for name, body, binding, table in nodes:
        positions[name] = cursor
        cursor += 4 if name in edges else len(body)
    names = ['', '.text', '.strtab', '.symtab', '.shstrtab', '.rel.text', '.symtab.aux']
    section_strings, section_names = b'\0', {}
    for name in names[1:]:
        section_names[name] = len(section_strings)
        section_strings += name.encode() + b'\0'
    strings, text = b'\0', b''
    tables, indices = {3: bytes(16), 6: bytes(16)}, {}
    for name, body, binding, table in nodes:
        if name in edges:
            body = branch(-4) if kind == 1 else branch(positions[edges[name]] - positions[name] - 4)
        offset = len(strings)
        strings += name.encode() + b'\0'
        indices[name] = table, len(tables[table]) // 16
        tables[table] += struct.pack('<IIIBBH', offset, base + positions[name] + 1, len(body),
                                     binding << 4 | 2, 0, 1)
        text += body
    relocations = b''
    if kind == 1 or residual:
        for source, target in edges.items():
            table, index = indices[target]
            assert table == relocation_link
            entry = struct.pack('<II', base + positions[source], index << 8 | 30)
            relocations += entry
            if duplicate_relocation:
                relocations += struct.pack('<II', base + positions[source] + 2, index << 8 | 30)
    payload, sections = bytearray(bytes(52)), [(0,) * 10]
    definitions = [(1, 6, text, base, 0, 0, text_alignment, 0), (3, 0, strings, 0, 0, 0, 1, 0),
                   (2, 0, tables[3], 0, 2, 1, 4, 16), (3, 0, section_strings, 0, 0, 0, 1, 0),
                   (9, 0, relocations, 0, relocation_link, 1, 4, 8), (2, 0, tables[6], 0, 2, 1, 4, 16)]
    for name, (kind_code, flags, data, address, link, info, alignment, entry_size) in zip(names[1:], definitions):
        offset = len(payload)
        payload.extend(data)
        sections.append((section_names[name], kind_code, flags, address, offset, len(data), link, info, alignment, entry_size))
    section_offset = len(payload)
    payload.extend(b''.join(struct.pack('<10I', *section) for section in sections))
    payload[:52] = struct.pack('<16sHHIIIIIHHHHHH', b'\x7fELF\x01\x01\x01' + bytes(9), kind, 40, 1,
                               0, 0, section_offset, 0x05000400, 52, 0, 0, 40, len(sections), 4)
    return facts.ELF(bytes(payload))


def chain(hops, kind=1, **kwargs):
    names = ['root', *['local' + str(index) for index in range(hops)]]
    nodes = [(name, constant(0x12345678), 1 if index == 0 else 0, 3) for index, name in enumerate(names)]
    return fixture(nodes, zip(names, names[1:]), kind=kind, **kwargs)


def set_body(elf, name, body):
    symbol, section = elf.unique(name)
    start = (symbol['value'] & ~1) - section['address']
    assert len(body) == symbol['size']
    data = bytearray(elf.data)
    data[section['offset'] + start:section['offset'] + start + len(body)] = body
    elf.data = bytes(data)


def set_relocation(elf, index=0, offset=None, info=None):
    section = elf.sections[5]
    data = bytearray(elf.data)
    position = section['offset'] + index * 8
    old_offset, old_info = struct.unpack_from('<II', data, position)
    struct.pack_into('<II', data, position, old_offset if offset is None else offset, old_info if info is None else info)
    elf.data = bytes(data)


class TailProofTests(unittest.TestCase):
    def test_zero_one_two_hops_object_and_firmware(self):
        for kind in (1, 2):
            for hops in (0, 1, 2):
                with self.subTest(kind=kind, hops=hops):
                    proof = chain(hops, kind).constant('root')
                    self.assertEqual(proof['value'], 0x12345678)
                    self.assertEqual(proof['tail_hops'], hops)
                    self.assertEqual(len(proof['proof']), hops + 1)
                    self.assertEqual(proof['proof'][-1]['kind'], 'immediate-return-leaf')

    def test_signed_displacement_encoding_and_pc(self):
        for displacement in (-(1 << 24), -4096, -10, -4, 0, 2, 4096, (1 << 24) - 2):
            self.assertEqual(facts.decode_tail_displacement(branch(displacement)), displacement)
        elf = fixture([('leaf', constant(7), 0, 3), ('root', b'', 1, 3)], [('root', 'leaf')], kind=2)
        proof = elf.constant('root')
        self.assertEqual(proof['value'], 7)
        self.assertEqual(proof['proof'][0]['edge']['signed_displacement'], -10)
        self.assertEqual(proof['proof'][0]['edge']['target_address'], 0x1000)

    def test_reject_three_hops_and_cycles(self):
        for kind in (1, 2):
            with self.assertRaisesRegex(ValueError, 'hop bound'):
                chain(3, kind).constant('root')
            elf = fixture([('root', b'', 1, 3), ('local', b'', 0, 3)],
                          [('root', 'local'), ('local', 'root')], kind=kind)
            with self.assertRaisesRegex(ValueError, 'cycle'):
                elf.constant('root')

    def test_reject_calls_conditional_indirect_and_extra_bytes(self):
        for body in (bytes.fromhex('fff7feff'), bytes.fromhex('00f00080'), bytes.fromhex('004700bf')):
            for kind in (1, 2):
                elf = chain(1, kind)
                set_body(elf, 'root', body)
                with self.subTest(body=body.hex(), kind=kind), self.assertRaises(ValueError):
                    elf.constant('root')
        with self.assertRaises(ValueError):
            fixture([('root', branch(0) + b'\x00\xbf', 1, 3), ('leaf', constant(1), 0, 3)], kind=2).constant('root')

    def test_canonical_rel_addend_is_mandatory(self):
        for addend in (-2, 0, 2, -8):
            elf = chain(1)
            set_body(elf, 'root', branch(addend))
            with self.assertRaisesRegex(ValueError, 'addend'):
                elf.constant('root')

    def test_exact_relocation_type_offset_and_overlap(self):
        for code in (0, 2, 10, 29, 31):
            elf = chain(1)
            set_relocation(elf, info=2 << 8 | code)
            with self.assertRaises(ValueError):
                elf.constant('root')
        elf = chain(1)
        set_relocation(elf, offset=2)
        with self.assertRaises(ValueError):
            elf.constant('root')
        with self.assertRaises(ValueError):
            chain(1, duplicate_relocation=True).constant('root')

    def test_actual_linked_table_and_index_not_flat_name_lookup(self):
        elf = fixture([('root', b'', 1, 3), ('decoy', constant(7), 0, 3), ('actual', constant(99), 0, 6)],
                      [('root', 'actual')], relocation_link=6)
        proof = elf.constant('root')
        self.assertEqual(proof['value'], 99)
        relocation = proof['proof'][0]['edge']['relocation']
        self.assertEqual((relocation['symbol_table'], relocation['symbol_index']), (6, 1))
        self.assertEqual(proof['proof'][1]['symbol'], 'actual')
        elf.sections[5]['link'] = 2
        with self.assertRaisesRegex(ValueError, 'relocation owner'):
            elf.constant('root')

    def test_bad_relocation_symbol_index_and_identity(self):
        elf = chain(1)
        set_relocation(elf, info=999 << 8 | 30)
        with self.assertRaisesRegex(ValueError, 'symbol index'):
            elf.constant('root')
        elf = chain(1)
        elf.symbol_tables[3][2]['index'] = 99
        with self.assertRaisesRegex(ValueError, 'identity'):
            elf.constant('root')

    def test_missing_relocation_and_unsupported_rela(self):
        elf = chain(1)
        elf.sections[5]['size'] = 0
        with self.assertRaises(ValueError):
            elf.constant('root')
        elf = chain(1)
        elf.sections[5].update(type=4, entry_size=12)
        with self.assertRaises(ValueError):
            elf.constant('root')

    def test_firmware_residual_relocation_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'residual relocation'):
            chain(1, kind=2, residual=True).constant('root')

    def test_target_must_be_unique_start_not_interior_or_outside(self):
        for displacement in (2, 0x10000, -(1 << 24)):
            elf = chain(1, kind=2)
            set_body(elf, 'root', branch(displacement))
            with self.assertRaises(ValueError):
                elf.constant('root')
        for kind in (1, 2):
            elf = chain(1, kind)
            target, _ = elf.unique('local0')
            elf.symbols.append(dict(target, name='ambiguousAlias'))
            with self.assertRaisesRegex(ValueError, 'ambiguous|unique'):
                elf.constant('root')

    def test_target_definition_thumb_permissions_and_bounds(self):
        for key, value in (('owner', 0), ('type', 1), ('binding', 2), ('value', 4), ('size', 100000)):
            elf = chain(1)
            target, _ = elf.unique('local0')
            target[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                elf.constant('root')
        elf = chain(1)
        elf.sections[1]['flags'] = 3
        with self.assertRaises(ValueError):
            elf.constant('root')

    def test_firmware_cross_section_function_overlap_is_ambiguous(self):
        elf = chain(1, kind=2)
        target, section = elf.unique('local0')
        elf.sections.append(dict(section, name='.text.overlapping'))
        elf.symbols.append(dict(target, name='interiorAlias', owner=len(elf.sections) - 1,
                                value=target['value'] + 2))
        with self.assertRaisesRegex(ValueError, 'overlapping'):
            elf.constant('root')

    def test_nonconstant_or_relocated_leaf_stays_rejected(self):
        for kind in (1, 2):
            elf = fixture([('root', b'', 1, 3), ('leaf', bytes.fromhex('00b500bf10bd'), 0, 3)],
                          [('root', 'leaf')], kind=kind)
            with self.assertRaises(ValueError):
                elf.constant('root')
        elf = chain(1)
        set_relocation(elf, offset=4)
        with self.assertRaises(ValueError):
            elf.constant('local0')

    def test_all_actual_failed_initialization_templates_remain_rejected(self):
        packet = facts.ROOT / 'Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage'
        rows = json.loads((packet / 'remaining-layout-cycle1-failure/measurement-symbols-and-bytes.json').read_text())
        bodies = {row['body_hex'] for row in rows if row['size'] in (30, 32)}
        self.assertTrue(bodies)
        for body in bodies:
            with self.assertRaises(ValueError):
                facts.decode_return(bytes.fromhex(body))
            elf = fixture([('root', b'', 1, 3), ('leaf', bytes.fromhex(body), 0, 3)], [('root', 'leaf')])
            with self.assertRaises(ValueError):
                elf.constant('root')


if __name__ == '__main__':
    unittest.main()
