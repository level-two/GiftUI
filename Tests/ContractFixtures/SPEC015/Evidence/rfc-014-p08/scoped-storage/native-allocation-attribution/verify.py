#!/usr/bin/env python3
"""Verify compact packet and the narrow selected-Static rejecting subset offline."""
import gzip
import hashlib
import json
import pathlib
import tarfile

p=pathlib.Path(__file__).resolve().parent
sha=lambda data:hashlib.sha256(data).hexdigest()
m=json.loads((p/'manifest.json').read_text())
assert sha((p/m['archive']).read_bytes())==m['archive_sha256']
with tarfile.open(p/m['archive'],'r:xz') as tar:
    assert sorted(tar.getnames())==sorted(m['members'])
    for item in tar.getmembers():
        data=tar.extractfile(item).read();expected=m['members'][item.name]
        assert len(data)==expected['bytes'] and sha(data)==expected['sha256'],item.name
for name,expected in m['analysis'].items():assert sha((p/name).read_bytes())==expected,name
r=json.load(gzip.open(p/'attribution.json.gz','rt'))
assert len(r['results'])==6
for run in r['results']:
    assert run['raw_summary']['max_frames']==137
    if not run['name'].startswith('static-'):continue
    groups=run['selected_static_metadata']
    assert sum(g['count'] for g in groups)==11
    assert sum(g['requested'] for g in groups)==sum(g['reserved'] for g in groups)==336
    assert sum(g['live_requested'] for g in groups)==64
    assert all(g['cohort']==1 and g['route']==13 for g in groups)
    assert all(any('p08CounterHost(' in frame['demangled'] for frame in g['frames']) for g in groups)
    assert all(not any('counterTrace' in frame['demangled'] or 'Swift._print' in frame['demangled'] or 'Swift._debugPrint' in frame['demangled'] for frame in g['frames']) for g in groups)
print('PASS compact member/analysis hashes; all3 Static repetitions reject zero heap with11events/336bytes,64retained')
