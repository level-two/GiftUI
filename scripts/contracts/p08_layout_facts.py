"""Read-only, fail-closed P08 ARMv7E-M layout evidence; never execute target code."""
import argparse
import hashlib
import json
import pathlib
import re
import struct

ROOT = pathlib.Path(__file__).resolve().parents[2]
SWIFT_SOURCE = ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived/StaticCounterEmbeddedBacking.swift'
ACCESSOR_SOURCE = ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived/StaticCounterLayoutFacts.swift'
C_SOURCE = ROOT / 'firmware/nrf52840/applications/signal-analyzer-static/src/counter_main.c'
C_SYMBOL = 'counter_backing.0'  # Exact spelling in the existing supported GCC recipe.
FIELDS = ('limits', 'root', 'semantic', 'semanticRecords', 'semanticPaths', 'semanticPayloads',
          'semanticScalars', 'values', 'canvasEntry', 'b0', 'b1', 'b2', 'b3', 'g0', 'g1', 'g2',
          'g3', 'g4', 'c0', 'h0', 'r0', 'r1', 'h1', 'control', 'used')
COMPONENTS = ('offset', 'count', 'size', 'stride', 'alignment')
SUMMARY = ('cursor', 'maximumAlignment', 'slotBytes', 'totalBytes')
SYMBOLS = tuple('giftui_p08_layout_' + field + '_' + component
                for field in FIELDS for component in COMPONENTS) + tuple(
                    'giftui_p08_layout_' + name for name in SUMMARY)
MAX_TAIL_HOPS = 2
MAX_LOCAL_HELPERS = len(SYMBOLS) * MAX_TAIL_HOPS
U32_MAX = (1 << 32) - 1


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checked_add(left, right):
    require(0 <= left <= U32_MAX and 0 <= right <= U32_MAX - left, 'UInt32 addition overflow')
    return left + right


def checked_multiply(left, right):
    require(0 <= left <= U32_MAX and 0 <= right <= U32_MAX and
            (left == 0 or right <= U32_MAX // left), 'UInt32 multiplication overflow')
    return left * right


def decode_return(body):
    """Only immediate r0 initialization, optional movt r0, then bx lr (Thumb)."""
    require(4 <= len(body) <= 10 and len(body) % 2 == 0, 'constant-return body size')
    words = struct.unpack('<' + 'H' * (len(body) // 2), body)
    first = words[0]
    if first & 0xFF00 == 0x2000:  # movs r0, #imm8
        value, index = first & 0xFF, 1
    else:
        require(len(words) >= 3, 'truncated wide immediate')
        second = words[1]
        require(second & 0x8F00 == 0, 'immediate destination must be r0')
        immediate = ((first >> 10) & 1) << 11 | ((second >> 12) & 7) << 8 | second & 0xFF
        if first & 0xFBF0 == 0xF240:  # movw r0, #imm16
            value = (first & 15) << 12 | immediate
        else:
            require(first & 0xFBFF == 0xF04F, 'unsupported low immediate instruction')
            # ThumbExpandImm, excluding architecturally unpredictable zero repeats.
            low = immediate & 0xFF
            if immediate >> 10 == 0:
                mode = (immediate >> 8) & 3
                require(mode == 0 or low != 0, 'unpredictable modified immediate')
                value = (low, low | low << 16, low << 8 | low << 24,
                         low | low << 8 | low << 16 | low << 24)[mode]
            else:
                rotation = immediate >> 7
                base = 0x80 | immediate & 0x7F
                value = ((base >> rotation) | (base << (32 - rotation))) & U32_MAX
        index = 2
    if index + 1 < len(words) and words[index] & 0xFBF0 == 0xF2C0:  # movt r0
        first, second = words[index:index + 2]
        require(second & 0x8F00 == 0, 'movt destination must be r0')
        high = (first & 15) << 12 | ((first >> 10) & 1) << 11 | ((second >> 12) & 7) << 8 | second & 0xFF
        value = value & 0xFFFF | high << 16
        index += 2
    require(index == len(words) - 1 and words[index] == 0x4770, 'body must end exactly at bx lr')
    return value


def decode_tail_displacement(body):
    """Only an entire unconditional Thumb B.W (T4); never BL or conditional B."""
    if len(body) != 4:
        return None
    first, second = struct.unpack('<HH', body)
    if first & 0xF800 != 0xF000 or second & 0xD000 != 0x9000:
        return None
    sign = first >> 10 & 1
    i1 = 1 ^ (second >> 13 & 1) ^ sign
    i2 = 1 ^ (second >> 11 & 1) ^ sign
    immediate = sign << 24 | i1 << 23 | i2 << 22 | (first & 0x3FF) << 12 | (second & 0x7FF) << 1
    return immediate - (1 << 25) if sign else immediate


class ELF:
    """The supported target's ELF32 little-endian symbol/section/relocation subset."""
    def __init__(self, data):
        self.data = data
        require(len(data) >= 52 and data[:7] == b'\x7fELF\x01\x01\x01', 'expected ELF32 little endian')
        header = struct.unpack_from('<16sHHIIIIIHHHHHH', data)
        self.kind, machine, version = header[1:4]
        require(self.kind in (1, 2) and machine == 40 and version == 1, 'expected ARM object/executable')
        section_offset, entry_size, count, names = header[6], header[11], header[12], header[13]
        require(entry_size == 40 and count > 0 and names < count, 'invalid section table')
        self.slice(section_offset, checked_multiply(entry_size, count))
        self.sections = []
        for index in range(count):
            values = struct.unpack_from('<IIIIIIIIII', data, section_offset + index * entry_size)
            section = dict(zip(('name_offset', 'type', 'flags', 'address', 'offset', 'size',
                                'link', 'info', 'alignment', 'entry_size'), values))
            require(section['alignment'] == 0 or section['alignment'] & (section['alignment'] - 1) == 0,
                    'invalid section alignment')
            if section['type'] != 8:
                self.slice(section['offset'], section['size'])
            self.sections.append(section)
        name_section = self.sections[names]
        require(name_section['type'] == 3, 'invalid section names')
        names_data = self.section_data(name_section)
        for section in self.sections:
            section['name'] = self.string(names_data, section['name_offset'])
        self.symbols, self.symbol_tables = [], {}
        for table, section in enumerate(self.sections):
            if section['type'] != 2:
                continue
            require(section['entry_size'] == 16 and section['size'] % 16 == 0 and
                    section['link'] < count and self.sections[section['link']]['type'] == 3,
                    'invalid symbol table')
            strings = self.section_data(self.sections[section['link']])
            entries = []
            for offset in range(section['offset'], section['offset'] + section['size'], 16):
                name, value, size, info, other, owner = struct.unpack_from('<IIIBBH', data, offset)
                symbol = dict(name=self.string(strings, name), value=value, size=size,
                              type=info & 15, binding=info >> 4, owner=owner, visibility=other & 3,
                              table=table, index=len(entries))
                entries.append(symbol)
                self.symbols.append(symbol)
            self.symbol_tables[table] = entries

    def slice(self, offset, size):
        require(0 <= offset <= len(self.data) and 0 <= size <= len(self.data) - offset, 'ELF file bounds')
        return self.data[offset:offset + size]

    def section_data(self, section):
        require(section['type'] != 8, 'section has no file bytes')
        return self.slice(section['offset'], section['size'])

    @staticmethod
    def string(data, offset):
        require(offset < len(data) and b'\0' in data[offset:], 'invalid ELF string')
        return data[offset:data.index(0, offset)].decode('ascii')

    def unique(self, name):
        matches = [symbol for symbol in self.symbols if symbol['name'] == name]
        require(len(matches) == 1, 'missing/duplicate exact symbol: ' + name)
        symbol = matches[0]
        require(0 < symbol['owner'] < len(self.sections), 'undefined/special symbol: ' + name)
        return symbol, self.sections[symbol['owner']]

    def function(self, symbol):
        require(0 < symbol['owner'] < len(self.sections), 'undefined/special function')
        section = self.sections[symbol['owner']]
        require(symbol['type'] == 2 and symbol['binding'] in (0, 1) and symbol['value'] & 1 and symbol['size'] > 0 and
                section['type'] == 1 and section['flags'] & 7 == 6, 'expected allocated executable Thumb function')
        start = (symbol['value'] & ~1) - section['address']
        end = checked_add(start, symbol['size'])
        require(start >= 0 and end <= section['size'], 'function section bounds')
        checked_add(section['address'], end)
        for other in self.symbols:
            if other is symbol or other['type'] != 2 or not other['size'] or not 0 < other['owner'] < len(self.sections):
                continue
            if other['owner'] == symbol['owner']:
                other_start = (other['value'] & ~1) - section['address']
                overlaps = other_start < end and other_start + other['size'] > start
            elif self.kind == 2:
                other_section = self.sections[other['owner']]
                other_start, absolute = other['value'] & ~1, symbol['value'] & ~1
                overlaps = other_section['flags'] & 7 == 6 and other_start < absolute + symbol['size'] and other_start + other['size'] > absolute
            else:
                overlaps = False
            require(not overlaps, 'ambiguous overlapping function aliases')
        return dict(symbol=symbol['name'], symbol_table=symbol['table'], symbol_index=symbol['index'],
                    address=symbol['value'], bytes=symbol['size'], section=section['name'],
                    body_hex=self.slice(section['offset'] + start, symbol['size']).hex())

    def relocations(self, symbol):
        section = self.sections[symbol['owner']]
        start = (symbol['value'] & ~1) - section['address']
        end = checked_add(start, symbol['size'])
        found = []
        for relocation in self.sections:
            if relocation['type'] not in (4, 9):
                continue
            entry_size = 12 if relocation['type'] == 4 else 8
            require(relocation['entry_size'] == entry_size and relocation['size'] % entry_size == 0,
                    'invalid relocation table')
            require(relocation['link'] in self.symbol_tables and
                    relocation['info'] < len(self.sections), 'invalid relocation owner')
            # ET_REL offsets address their sh_info section; executable relocation offsets are absolute.
            if self.kind == 1 and relocation['info'] != symbol['owner']:
                continue
            for offset in range(relocation['offset'], relocation['offset'] + relocation['size'], entry_size):
                address, info = struct.unpack_from('<II', self.data, offset)
                position = address if self.kind == 1 else address - section['address']
                if position < end and position + 4 > start:
                    entries, index = self.symbol_tables[relocation['link']], info >> 8
                    require(index < len(entries), 'invalid relocation symbol index')
                    target = entries[index]
                    require(target['table'] == relocation['link'] and target['index'] == index,
                            'relocation symbol table identity mismatch')
                    found.append(dict(section=relocation['name'], section_type=relocation['type'],
                                      offset=position - start, type=info & 255,
                                      symbol_table=relocation['link'], symbol_index=index,
                                      symbol=target['name'], explicit_addend=struct.unpack_from('<i', self.data, offset + 8)[0]
                                      if relocation['type'] == 4 else None))
        return found

    def target_at(self, address):
        matches = [symbol for symbol in self.symbols if symbol['type'] == 2 and
                   0 < symbol['owner'] < len(self.sections) and symbol['value'] & 1 and
                   symbol['value'] & ~1 == address]
        require(len(matches) == 1, 'tail target must be a unique defined Thumb function start')
        return matches[0]

    def constant(self, name):
        current, _ = self.unique(name)
        seen, proof = set(), []
        while True:
            identity = current['table'], current['index']
            require(identity not in seen, 'tail cycle')
            seen.add(identity)
            node = self.function(current)
            body, relocations = bytes.fromhex(node['body_hex']), self.relocations(current)
            displacement = decode_tail_displacement(body)
            if displacement is None:
                require(not relocations, 'relocation in constant-return leaf')
                value = decode_return(body)
                node['kind'] = 'immediate-return-leaf'
                node['relocations'] = []
                proof.append(node)
                return dict(value=value, **{key: proof[0][key] for key in ('address', 'bytes', 'section', 'body_hex')},
                            proof=proof, tail_hops=len(proof) - 1)
            require(len(proof) < MAX_TAIL_HOPS, 'tail hop bound exceeded')
            if self.kind == 1:
                require(body == bytes.fromhex('fff7febf') and displacement == -4, 'noncanonical tail relocation addend')
                require(len(relocations) == 1 and relocations[0]['offset'] == 0 and
                        relocations[0]['type'] == 30 and relocations[0]['section_type'] == 9,
                        'tail requires sole R_ARM_THM_JUMP24 REL relocation at zero')
                relocation = relocations[0]
                target = self.symbol_tables[relocation['symbol_table']][relocation['symbol_index']]
                # Resolve the actual sh_link table/index, never a same-named flat symbol.
                self.function(target)
                edge = dict(kind='object-tail-relocation', canonical_encoded_addend=-4, relocation=relocation,
                            target_symbol=target['name'], target_table=target['table'], target_index=target['index'])
            else:
                require(not relocations, 'residual relocation in firmware tail')
                pc = checked_add(current['value'] & ~1, 4)
                destination = pc + displacement
                require(0 <= destination <= U32_MAX and destination % 2 == 0, 'tail destination overflow/alignment')
                target = self.target_at(destination)
                self.function(target)
                edge = dict(kind='firmware-direct-tail', pc=pc, signed_displacement=displacement,
                            target_address=destination, target_symbol=target['name'],
                            target_table=target['table'], target_index=target['index'])
            node.update(kind='direct-tail-thunk', relocations=relocations, edge=edge)
            proof.append(node)
            current = target


def source_reservation(swift_text, c_text=None):
    def one(pattern, text):
        matches = re.findall(pattern, text, re.M)
        require(len(matches) == 1, 'ambiguous/missing source reservation constant')
        return matches[0]
    slot = int(one(r'^let counterEmbeddedSlotBytes = ([0-9]+)$', swift_text))
    count = int(one(r'^let counterEmbeddedSlotCount = ([0-9]+)$', swift_text))
    require(slot > 0 and count == 4, 'unsupported reservation source')
    result = dict(slot_bytes=slot, slot_count=count, retained_bytes=checked_multiply(slot, count))
    if c_text is not None:
        alignment, c_count, c_slot = map(int, one(
            r'static _Alignas\(([0-9]+)\) uint8_t counter_backing\[([0-9]+)\]\[([0-9]+)\];', c_text))
        require((c_count, c_slot) == (count, slot) and alignment > 0 and alignment & (alignment - 1) == 0,
                'C/Swift source reservation mismatch')
        result['c_alignment'] = alignment
    return result


def validate_layout(values, reservation):
    require(set(values) == set(SYMBOLS) and all(type(value) is int and 0 <= value <= U32_MAX
                                             for value in values.values()), 'exact bounded fact inventory')
    cursor, maximum, regions = 0, 1, []
    for field in FIELDS:
        region = {key: values['giftui_p08_layout_' + field + '_' + key] for key in COMPONENTS}
        alignment = region['alignment']
        require(alignment > 0 and alignment & (alignment - 1) == 0 and region['stride'] >= region['size'],
                'invalid field layout')
        start = checked_add(cursor, (alignment - cursor % alignment) % alignment)
        extent = checked_multiply(region['count'], region['stride'])
        end = checked_add(start, extent)
        require(region['offset'] == start and end <= reservation['slot_bytes'], 'field offset/bounds/disjointness')
        regions.append(dict(name=field, **region, extent=extent, end=end))
        cursor, maximum = end, max(maximum, alignment)
    slot = checked_add(cursor, (maximum - cursor % maximum) % maximum)
    expected = dict(cursor=cursor, maximumAlignment=maximum, slotBytes=slot,
                    totalBytes=checked_multiply(slot, reservation['slot_count']))
    require(all(values['giftui_p08_layout_' + key] == value for key, value in expected.items()), 'layout summary mismatch')
    require(slot <= reservation['slot_bytes'] and reservation['slot_bytes'] % maximum == 0,
            'actual retained slot spacing must align all four origins')
    return dict(regions=regions, **expected, retained_slot_bytes=reservation['slot_bytes'],
                retained_bytes=reservation['retained_bytes'],
                retained_surplus=reservation['retained_bytes'] - expected['totalBytes'])


def classify_inventory(elf):
    roots, helpers = [], []
    for symbol in elf.symbols:
        name = symbol['name']
        if not name.startswith('giftui_p08_layout_'):
            continue
        require(symbol['type'] == 2 and 0 < symbol['owner'] < len(elf.sections),
                'layout name must define a function')
        if name in SYMBOLS:
            require(symbol['binding'] == 1, 'measurement root must be global')
            roots.append(name)
        else:
            require(symbol['binding'] == 0, 'unexpected exported/weak layout symbol')
            helpers.append(dict(**elf.function(symbol), binding='local', measurement_root=False))
    require(len(roots) == len(SYMBOLS) and set(roots) == set(SYMBOLS), 'unexpected/missing/duplicate layout root inventory')
    require(len(helpers) <= MAX_LOCAL_HELPERS and len({helper['symbol'] for helper in helpers}) == len(helpers),
            'duplicate/excess local layout helpers')
    return dict(global_roots=list(SYMBOLS), nonroot_local_helpers=helpers)


def extract(path, reservation, decoded_output=None, compiler_sha256=None):
    elf = ELF(path.read_bytes())
    inventory = classify_inventory(elf)
    facts = {name: elf.constant(name) for name in SYMBOLS}
    values = {name: fact['value'] for name, fact in facts.items()}
    if decoded_output is not None:
        # Preserve exact target facts before retained-reservation validation. This
        # file is diagnostic only and never substitutes for accepted SO07 output.
        decoded_output.write_text(json.dumps(dict(
            schema=1, kind='decoded-unvalidated-layout-facts', executed=False,
            accepted=False, diagnostic_only=True, artifact_sha256=digest(path),
            compiler_sha256=compiler_sha256, extractor_sha256=digest(pathlib.Path(__file__)),
            source_sha256=digest(SWIFT_SOURCE), accessor_source_sha256=digest(ACCESSOR_SOURCE),
            reservation=reservation, values=values, symbols=facts,
            measurement_inventory=inventory), indent=2) + '\n')
    return elf, dict(values=values, symbols=facts, layout=validate_layout(values, reservation),
                     measurement_inventory=inventory)


def compare_firmware(extracted, prior, elf, reservation, map_text):
    require(prior['values'] == extracted['values'] and prior['layout'] == extracted['layout'], 'SO07/SO08 layout mismatch')
    for name in SYMBOLS:
        require(re.search(r'(?<![A-Za-z0-9_.$])' + re.escape(name) + r'(?![A-Za-z0-9_.$])', map_text), 'layout symbol absent from map')
    symbol, section = elf.unique(C_SYMBOL)
    require(elf.kind == 2 and symbol['type'] == 1 and section['type'] in (1, 8) and section['flags'] & 3 == 3,
            'C backing must be allocated writable object')
    maximum = extracted['layout']['maximumAlignment']
    require(symbol['size'] == reservation['retained_bytes'], 'C backing symbol size mismatch')
    require(section['alignment'] >= max(reservation['c_alignment'], maximum) and
            symbol['value'] % reservation['c_alignment'] == 0 and symbol['value'] % maximum == 0,
            'C backing base/section alignment mismatch')
    start = symbol['value'] - section['address']
    require(start >= 0 and checked_add(start, symbol['size']) <= section['size'], 'C backing section bounds')
    require(reservation['slot_bytes'] % maximum == 0, 'C backing slot-origin alignment mismatch')
    mapping = re.findall(r'^\s*\.bss\.' + re.escape(C_SYMBOL) +
                         r'\s*\n\s*(0x[0-9a-fA-F]+)\s+(0x[0-9a-fA-F]+)\s+([^\n]+)$', map_text, re.M)
    require(len(mapping) == 1 and int(mapping[0][0], 16) == symbol['value'] and
            int(mapping[0][1], 16) == symbol['size'] and mapping[0][2].endswith('(counter_main.c.obj)'),
            'exact C backing map ownership/address/size mismatch')
    return dict(symbol=C_SYMBOL, address=symbol['value'], bytes=symbol['size'], section=section['name'],
                section_alignment=section['alignment'], source_alignment=reservation['c_alignment'],
                slot_origins=[checked_add(symbol['value'], checked_multiply(index, reservation['slot_bytes']))
                              for index in range(reservation['slot_count'])])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('object', 'firmware'))
    parser.add_argument('--input', required=True, type=pathlib.Path)
    parser.add_argument('--output', required=True, type=pathlib.Path)
    parser.add_argument('--compiler-sha256', required=True)
    parser.add_argument('--decoded-output', type=pathlib.Path, help='diagnostic facts retained even if reservation validation fails')
    parser.add_argument('--so07', type=pathlib.Path)
    parser.add_argument('--map', type=pathlib.Path)
    args = parser.parse_args()
    require(re.fullmatch(r'[0-9a-f]{64}', args.compiler_sha256), 'invalid compiler identity')
    reservation = source_reservation(SWIFT_SOURCE.read_text(), C_SOURCE.read_text() if args.mode == 'firmware' else None)
    elf, extracted = extract(args.input, reservation, args.decoded_output, args.compiler_sha256)
    require(elf.kind == (1 if args.mode == 'object' else 2), 'wrong artifact kind')
    record = dict(schema=1, kind='target-compiled-constant-return-layout-facts', executed=False,
                  artifact=str(args.input.resolve().relative_to(ROOT)), artifact_sha256=digest(args.input),
                  compiler_sha256=args.compiler_sha256, extractor_sha256=digest(pathlib.Path(__file__)),
                  source_sha256=digest(SWIFT_SOURCE), accessor_source_sha256=digest(ACCESSOR_SOURCE),
                  reservation=reservation, **extracted)
    if args.mode == 'firmware':
        require(args.so07 is not None and args.map is not None, 'firmware needs exact SO07 and map')
        prior = json.loads(args.so07.read_text())
        require(prior['schema'] == 1 and prior['kind'] == record['kind'] and prior['executed'] is False and
                prior['source_sha256'] == record['source_sha256'] and
                prior['accessor_source_sha256'] == record['accessor_source_sha256'] and
                prior['extractor_sha256'] == record['extractor_sha256'] and
                prior['compiler_sha256'] == record['compiler_sha256'], 'stale SO07 extraction identity')
        require(digest(ROOT / prior['artifact']) == prior['artifact_sha256'], 'stale SO07 object')
        record.update(c_reservation=compare_firmware(extracted, prior, elf, reservation, args.map.read_text()),
                      c_source_sha256=digest(C_SOURCE), so07_sha256=digest(args.so07), map_sha256=digest(args.map))
    args.output.write_text(json.dumps(record, indent=2) + '\n')


if __name__ == '__main__':
    main()
