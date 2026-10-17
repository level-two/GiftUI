#!/usr/bin/env python3
"""Compact frozen diagnostic failure inventory; never a resource acceptance result."""
import collections
import hashlib
import json
import pathlib
import re
import sys

p = pathlib.Path(sys.argv[1])
paths = ('manifest.json', 'commands.json', 'dynamic-1.stderr', 'dynamic-1.stdout',
         'dynamic-counter', 'static-counter', 'Driver.o', 'libP08AllocationObserver.dylib')
result = {'scope': 'first failed Dynamic diagnostic, not accepted workload/profile allocation evidence',
          'directory': str(p), 'files': {}, 'windows': {}, 'groups': 0, 'unknown_pc_frames': 0}
for name in paths:
    data = (p / name).read_bytes()
    result['files'][name] = {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}
routes = collections.Counter(); frames = collections.Counter(); vectors = []; vector = []
for line in (p / 'dynamic-1.stderr').open():
    if line.startswith(('HOST ', 'ENTRY ', 'CONTROL ')):
        result[line.split()[0].lower()] = line.strip()
    elif line.startswith('WINDOW '):
        fields = line.split(); result['windows'][fields[1]] = dict(x.split('=') for x in fields[2:])
    elif line.startswith('GROUP '):
        fields = dict(x.split('=', 1) for x in line.split()[2:]); routes[fields['route']] += 1; frames[fields['frames']] += 1
        if vector: vectors.append(tuple(vector)); vector = []
    elif line.startswith('FRAME '):
        m = re.match(r'FRAME \d+ \d+ pc=(\S+) base=\S+ offset=\S+ image=(.*?) symbol=', line)
        assert m
        vector.append(m[1]); result['unknown_pc_frames'] += m[2] == '?'
if vector: vectors.append(tuple(vector))
result.update(groups=len(vectors), routes=dict(routes), frame_counts=dict(frames),
              unique_pcs=len({pc for vector in vectors for pc in vector}),
              unique_prefixes={str(n): len({vector[:n] for vector in vectors}) for n in [2, 8, 12, 16, 24]})
print(json.dumps(result, indent=2))
