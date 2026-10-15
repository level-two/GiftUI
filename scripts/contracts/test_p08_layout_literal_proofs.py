"""Compiler-free proof of the single owned inline-literal leaf, not arbitrary loads."""
import struct
import unittest

import p08_layout_facts as facts
from test_p08_layout_facts import constant
from test_p08_layout_tail_proofs import fixture, set_relocation


def literal(value):
    return bytes.fromhex('00487047') + struct.pack('<I', value)


def leaf(body=None, kind=1):
    return fixture([('root', literal(138880) if body is None else body, 1, 3)],
                   kind=kind, text_alignment=4)


class InlineLiteralTests(unittest.TestCase):
    def test_exact_actual_shape_and_word_boundaries(self):
        for value in (0, 1, 65535, 65536, 138880, 0x80000000, 0xFFFFFFFF):
            for kind in (1, 2):
                with self.subTest(value=value, kind=kind):
                    proof = leaf(literal(value), kind).constant('root')
                    self.assertEqual(proof['value'], value)
                    node = proof['proof'][0]
                    self.assertEqual(node['kind'], 'inline-literal-return-leaf')
                    self.assertEqual(node['literal']['literal_offset'], 4)
                    self.assertEqual(node['literal']['literal_address'], 4 if kind == 1 else 0x1004)
                    self.assertEqual(node['literal']['literal_bytes'], 4)
        self.assertEqual(literal(138880).hex(), '00487047801e0200')

    def test_zero_one_two_hops_use_actual_leaf_pc(self):
        for kind in (1, 2):
            for hops in (0, 1, 2):
                names = ['root', *['local' + str(i) for i in range(hops)]]
                elf = fixture([(name, literal(138880), 1 if i == 0 else 0, 3)
                               for i, name in enumerate(names)], zip(names, names[1:]),
                              kind=kind, text_alignment=4)
                proof = elf.constant('root')
                self.assertEqual(proof['tail_hops'], hops)
                self.assertEqual(proof['value'], 138880)
                self.assertEqual(proof['proof'][-1]['literal']['literal_address'],
                                 (0x1000 if kind == 2 else 0) + hops * 4 + 4)

    def test_other_load_register_offset_opcode_and_return_rejected(self):
        original = literal(138880)
        for prefix in ('00497047', '01487047', '00687047', '00480047', '00477047',
                       '004800bf', 'dff80000', '004800bd'):
            with self.subTest(prefix=prefix), self.assertRaises(ValueError):
                leaf(bytes.fromhex(prefix) + original[4:]).constant('root')

    def test_exact_extent_no_truncation_padding_or_extra_code(self):
        original = literal(138880)
        for body in [original[:n] for n in range(8)] + [original + b'\x00\xbf',
                    original[:4] + b'\x00\xbf' + original[4:], original[:2] + original[4:]]:
            with self.subTest(body=body.hex()), self.assertRaises(ValueError):
                leaf(body).constant('root')

    def test_word_alignment_and_u32_address_bounds(self):
        for address, alignment in ((2, 4), (6, 4), (0, 1), (0, 2), (0, 3), (0, 6),
                                   (0xFFFFFFFC, 4), (0xFFFFFFF8, 4)):
            with self.subTest(address=address, alignment=alignment), self.assertRaises(ValueError):
                facts.decode_inline_literal_return(literal(1), address, alignment)
        for kind in (1, 2):
            elf = leaf(kind=kind)
            elf.sections[1]['alignment'] = 2
            with self.assertRaisesRegex(ValueError, 'alignment'):
                elf.constant('root')
            # A two-byte prefix puts the function at a Thumb-valid but non-word-aligned start.
            elf = fixture([('prefix', b'\x70\x47', 0, 3), ('root', literal(1), 1, 3)],
                          kind=kind, text_alignment=4)
            with self.assertRaisesRegex(ValueError, 'alignment'):
                elf.constant('root')

    def test_instruction_and_literal_relocations_rejected(self):
        for kind in (1, 2):
            for offset in (0, 2, 4, 6):
                elf = fixture([('jump', b'', 1, 3), ('root', literal(1), 0, 3)],
                              [('jump', 'root')], kind=kind, residual=kind == 2,
                              text_alignment=4)
                set_relocation(elf, offset=(0x1000 if kind == 2 else 0) + 4 + offset)
                with self.subTest(kind=kind, offset=offset), self.assertRaisesRegex(ValueError, 'relocation'):
                    elf.constant('root')

    def test_full_symbol_and_section_ownership_still_required(self):
        for kind in (1, 2):
            for mutation in ('symbol-end', 'section-end', 'alias', 'writable', 'not-executable', 'not-thumb'):
                elf = leaf(kind=kind)
                symbol, section = elf.unique('root')
                if mutation == 'symbol-end':
                    symbol['size'] = 6
                elif mutation == 'section-end':
                    section['size'] = 6
                elif mutation == 'alias':
                    elf.symbols.append(dict(symbol, name='overlapping'))
                elif mutation == 'writable':
                    section['flags'] = 7
                elif mutation == 'not-executable':
                    section['flags'] = 2
                else:
                    symbol['value'] &= ~1
                with self.subTest(kind=kind, mutation=mutation), self.assertRaises(ValueError):
                    elf.constant('root')

    def test_actual_tail_symbol_table_index_not_decoy_or_root_pc(self):
        elf = fixture([('root', b'', 1, 3), ('decoy', constant(7) + b'\x00\xbf', 0, 3),
                       ('actual', literal(99), 0, 6)], [('root', 'actual')],
                      relocation_link=6, text_alignment=4)
        proof = elf.constant('root')
        self.assertEqual(proof['value'], 99)
        self.assertEqual(proof['proof'][-1]['symbol'], 'actual')
        self.assertEqual(proof['proof'][-1]['literal']['literal_address'], 16)
        self.assertEqual(proof['proof'][0]['edge']['relocation']['symbol_table'], 6)
        elf.sections[5]['link'] = 2
        with self.assertRaisesRegex(ValueError, 'relocation owner'):
            elf.constant('root')
        elf.sections[5]['link'] = 6
        elf.symbol_tables[6][1]['index'] = 99
        with self.assertRaisesRegex(ValueError, 'identity'):
            elf.constant('root')


if __name__ == '__main__':
    unittest.main()
