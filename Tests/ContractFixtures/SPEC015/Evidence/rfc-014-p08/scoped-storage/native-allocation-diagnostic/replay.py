#!/usr/bin/env python3
"""Strict exact-event replay; no full-stack-path capacity limit or hash merging."""
import argparse
import gzip
import json
import pathlib
import re
import struct

HEADER = struct.Struct('<8Q')
COLUMNS = ('allocations', 'frees', 'requested_total', 'reserved_total',
           'live_requested', 'live_reserved', 'live_count', 'peak_requested',
           'peak_reserved', 'peak_rounding', 'peak_live_count',
           'baseline_requested', 'baseline_reserved', 'baseline_count')


def replay(events, stderr, output, validation=False):
    reports = []
    for line in stderr.read_text().splitlines():
        if line.startswith('WINDOW '):
            fields = line.split()
            reports.append((fields[1], {k: int(v) for k, v in (x.split('=') for x in fields[2:])}))
    if not validation:
        assert len(reports) == 2 and [r[0] for r in reports] == ['cold', 'reuse'], 'missing matched windows'
        entry = re.search(r'^ENTRY cold=(\d+) reuse=(\d+)$', stderr.read_text(), re.M)
        assert entry and int(entry[1]) > 0 and entry[1] == entry[2], 'invalid entry counts'
    live = {}
    groups = []
    group_ids = {}
    windows = []
    last_sequence = 0
    active = None
    lr = lv = lc = 0
    max_frames = 0
    saw_truncation = False
    with events.open('rb') as source:
        assert source.read(8) == b'P08ALLO1', 'missing trace header (including I/O-failure control)'
        while True:
            raw = source.read(HEADER.size)
            if not raw:
                break
            assert len(raw) == HEADER.size, 'partial event header'
            kind, window, cohort, sequence, pointer, requested, reserved, tag = HEADER.unpack(raw)
            assert sequence == last_sequence + 1, 'missing/reordered event'
            last_sequence = sequence
            if kind == 1:
                assert active is None and window == len(windows) + 1, 'nested/missing window'
                assert (requested, reserved, tag) == (lr, lv, lc), 'baseline mismatch'
                active = dict.fromkeys(COLUMNS, 0)
                active.update(live_requested=lr, live_reserved=lv, live_count=lc,
                              peak_requested=lr, peak_reserved=lv, peak_rounding=lv-lr, peak_live_count=lc,
                              baseline_requested=lr, baseline_reserved=lv, baseline_count=lc,
                              window=window, cohort=cohort)
            elif kind == 2:
                assert active and active['window'] == window and active['cohort'] == cohort
                frames, route, status = tag & 0xffff, (tag >> 16) & 0xffff, tag >> 32
                assert 0 < frames <= 512 and status in (0, 1, 2), 'invalid capture encoding'
                vector = source.read(frames * 8)
                assert len(vector) == frames * 8, 'partial PC vector'
                if status:
                    assert validation and reports[window-1][0] == 'negative-truncation' and status == 1, 'capture did not reach driver root'
                    saw_truncation = True
                max_frames = max(max_frames, frames)
                assert pointer and pointer not in live and reserved >= requested, 'invalid live allocation'
                # Exact bytes are the key: Python hashing never collapses unequal vectors.
                key = (cohort, route, vector)
                if key not in group_ids:
                    group_ids[key] = len(groups)
                    groups.append({'cohort': cohort, 'route': route, 'vector': vector,
                                   'count': 0, 'requested': 0, 'reserved': 0,
                                   'live_requested': 0, 'live_reserved': 0, 'peak_reserved': 0})
                group_id = group_ids[key]
                group = groups[group_id]
                group['count'] += 1; group['requested'] += requested; group['reserved'] += reserved
                group['live_requested'] += requested; group['live_reserved'] += reserved
                group['peak_reserved'] = max(group['peak_reserved'], group['live_reserved'])
                live[pointer] = (sequence, requested, reserved, group_id)
                lr += requested; lv += reserved; lc += 1
                active['allocations'] += 1; active['requested_total'] += requested; active['reserved_total'] += reserved
                active.update(peak_requested=max(active['peak_requested'], lr),
                              peak_reserved=max(active['peak_reserved'], lv),
                              peak_rounding=max(active['peak_rounding'], lv-lr),
                              peak_live_count=max(active['peak_live_count'], lc))
            elif kind == 3:
                assert active and active['window'] == window and active['cohort'] == cohort
                allocation, expected_requested, expected_reserved, group_id = live.pop(pointer)
                assert (allocation, expected_requested, expected_reserved) == (tag, requested, reserved), 'retirement identity mismatch'
                lr -= requested; lv -= reserved; lc -= 1
                groups[group_id]['live_requested'] -= requested; groups[group_id]['live_reserved'] -= reserved
                active['frees'] += 1
            elif kind == 4:
                assert active and active['window'] == window and active['cohort'] == cohort
                assert (pointer, requested, reserved, tag) == (active['allocations'], lr, lv, lc), 'end mismatch'
                active.update(live_requested=lr, live_reserved=lv, live_count=lc)
                windows.append(active); active = None
            else:
                raise AssertionError('unknown event kind')
    assert active is None and len(windows) == len(reports) and windows, 'missing final window/end/report'
    for window, (name, report) in zip(windows, reports):
        for key in COLUMNS:
            assert window[key] == report[key], f'{name}: {key} differs from C ledger'
        for key in ('saturated', 'truncated', 'bad_chain', 'io_errors', 'foreign'):
            allowed = validation and ((name.startswith('negative-') and key in ('saturated', 'truncated')) or (name == 'foreign-thread' and key == 'foreign'))
            assert not report[key] or allowed, f'{name}: invalid {key}'
        window['name'] = name
    if validation:
        assert saw_truncation and 'VALIDATION failures=0' in stderr.read_text(), 'missing validation controls'
    with gzip.open(output, 'wt', encoding='utf-8') as sink:
        # PC symbols/image identities remain in stderr once per unique PC.
        sink.write('{"format":"P08-exact-full-stack-groups-v1","groups":[\n')
        for index, group in enumerate(groups):
            vector = group.pop('vector')
            group['pcs'] = [hex(x[0]) for x in struct.iter_unpack('<Q', vector)]
            sink.write((',' if index else '') + json.dumps(group, separators=(',', ':')) + '\n')
        sink.write(']}\n')
    summary = {'event_sequence': last_sequence, 'group_count': len(groups), 'max_frames': max_frames,
               'live_allocations': lc, 'windows': windows,
               'scope': 'exact replay of observed public API events, not allocation-route completeness or fit'}
    output.with_suffix('.summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    return summary


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('events', type=pathlib.Path)
    parser.add_argument('stderr', type=pathlib.Path)
    parser.add_argument('output', type=pathlib.Path)
    parser.add_argument('--validation', action='store_true')
    args = parser.parse_args()
    summary = replay(args.events, args.stderr, args.output, args.validation)
    print(json.dumps({k: v for k, v in summary.items() if k != 'windows'}))


if __name__ == '__main__':
    main()
