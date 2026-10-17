#!/usr/bin/env python3
"""Synthetic collector controls, never application/resource acceptance evidence."""
import contextlib
import io
import pathlib
import sys
from replay import HEADER, COLUMNS, replay

out = pathlib.Path(sys.argv[1])
events = out / 'synthetic-path-diversity.events'
stderr = out / 'synthetic-path-diversity.stderr'
count = 20000
seq = 0
with events.open('wb') as stream:
    stream.write(b'P08ALLO1')

    def event(kind, window, cohort, pointer, requested, reserved, tag):
        global seq
        seq += 1
        stream.write(HEADER.pack(kind, window, cohort, seq, pointer, requested, reserved, tag))
        return seq

    event(1, 1, 1, 0x1000, 0, 0, 0)
    for i in range(count):
        # Equal eight-PC prefixes, distinct ninth PCs: no prefix/hash collapse.
        allocation = event(2, 1, 1, 0x2000, 113, 128, 9)
        stream.write(__import__('struct').pack('<9Q', *range(0x10000, 0x10008), 0x20000+i))
        event(3, 1, 1, 0x2000, 113, 128, allocation)
    event(4, 1, 1, count, 0, 0, 0)
    event(1, 2, 2, 0x1000, 0, 0, 0)
    event(4, 2, 2, 0, 0, 0, 0)


def window(name, allocations):
    fields = dict.fromkeys(COLUMNS, 0)
    if allocations:
        fields.update(allocations=allocations, frees=allocations,
                      requested_total=113*allocations, reserved_total=128*allocations,
                      peak_requested=113, peak_reserved=128, peak_rounding=15, peak_live_count=1)
    fields.update(unknown_frees=0, failures=0, nested=0, foreign=0,
                  saturated=0, truncated=0, bad_chain=0, io_errors=0)
    return 'WINDOW ' + name + ' ' + ' '.join(f'{k}={v}' for k, v in fields.items()) + '\n'

stderr.write_text('ENTRY cold=1 reuse=1\n' + window('cold', count) + window('reuse', 0))
summary = replay(events, stderr, out / 'synthetic-groups.json.gz')
assert summary['group_count'] == count and summary['event_sequence'] == 2*count+4
partial = out / 'synthetic-partial.events'
partial.write_bytes(events.read_bytes()[:-1])
try:
    replay(partial, stderr, out / 'invalid-partial-groups.json.gz')
except AssertionError as error:
    assert 'partial event header' in str(error)
else:
    raise AssertionError('accepted partial event header')
# A capture without driver-root termination must be rejected, not called covered.
raw = bytearray(events.read_bytes())
allocation_tag_offset = 8 + HEADER.size + 56
raw[allocation_tag_offset:allocation_tag_offset+8] = (9 | (1 << 32)).to_bytes(8, 'little')
clipped = out / 'synthetic-truncated.events'
clipped.write_bytes(raw)
try:
    replay(clipped, stderr, out / 'invalid-truncated-groups.json.gz')
except AssertionError as error:
    assert 'capture did not reach driver root' in str(error)
else:
    raise AssertionError('accepted truncated capture')
print('SYNTHETIC PASS: 20,000 exact full paths sharing8-PC prefix; partial I/O and truncated-root records rejected')
