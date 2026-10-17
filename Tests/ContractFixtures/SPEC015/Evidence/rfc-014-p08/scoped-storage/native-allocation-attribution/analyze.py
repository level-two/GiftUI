#!/usr/bin/env python3
"""Read-only matched event attribution. Component tags are custody, not exemptions."""
import argparse
import collections
import gzip
import hashlib
import json
import pathlib
import re
import struct
import subprocess

HEADER = struct.Struct('<8Q')
EXPECTED_IMAGES = {'dynamic':'e2ddbb3a4ce17380a3b4c5c822cd300caed5c0d513b2872c9de4aba7c83336b1',
                   'static':'6c3c3c6b1d1ba5a0d57def8bb7e367484f438f15ffd0eec17afddfe22e6414f3'}
PRINT_PREPARATION = {'0x138ec8', '0x138f0c', '0x151410', '0x151444'}


def digest(p):
    h = hashlib.sha256()
    with p.open('rb') as f:
        for block in iter(lambda: f.read(1024*1024), b''): h.update(block)
    return h.hexdigest()


def records(path):
    with path.open('rb') as f:
        assert f.read(8) == b'P08ALLO1'
        while raw := f.read(64):
            assert len(raw) == 64
            row = HEADER.unpack(raw)
            vector = f.read((row[7] & 0xffff)*8) if row[0] == 2 else b''
            yield row, vector


def classify(pcs, symbols, demangled, profile):
    frames = [demangled[symbols[hex(pc)]['symbol']] for pc in pcs]
    if any('P08CounterRuntime.p08CounterDynamicHost(' in f for f in frames): component = 'selected-dynamic-host'
    elif any('P08CounterRuntime.p08CounterHost(' in f for f in frames): component = 'selected-static-host'
    elif any('P08CounterRuntime.counterExerciseScopedStorage(' in f for f in frames): component = 'common-scoped'
    elif any('p08CounterGraph(' in f or '$s17P08CounterRuntime03p08B5Graph' in f for f in frames): component = 'common-graph'
    else: component = 'unresolved-component'
    direct = symbols[hex(pcs[3])] if len(pcs) > 3 and frames[2] == 'swift_allocObject' else None
    direct_main = direct and direct['image'].endswith('/'+profile+'-counter')
    if any('counterTrace' in f or re.search(r'Swift\.(print|_print|_debugPrint)', f) for f in frames): cause = 'explicit-trace'
    elif direct_main and direct['offset'] in PRINT_PREPARATION: cause = 'trace-preparation'
    elif any('p08ReuseLabel' in f for f in frames): cause = 'reuse-label-trace'
    elif any('p08VerifyRoleTranscript' in f for f in frames): cause = 'role-oracle-trace'
    elif direct_main and direct['offset'] == '0x14a708': cause = 'host-corpus-array-literal'
    elif any('counterHostCorpus' in f for f in frames) and any(symbols[hex(pc)]['offset'] == '0x14a700' and symbols[hex(pc)]['image'].endswith('/'+profile+'-counter') for pc in pcs): cause = 'host-corpus-array-metadata'
    elif any(('Metadata' in f or 'WitnessTable' in f or 'getWitnessTable' in f) and (f.startswith('_Z') or f.startswith('swift_')) for f in frames): cause = 'runtime-metadata-witness'
    elif component == 'selected-dynamic-host' and 'swift_allocObject' in frames: cause = 'dynamic-storage-object'
    else: cause = 'other-common-or-library'
    return component, cause


def analyze(directory, profile, repeat, demangler):
    name = f'{profile}-{repeat}'; text = (directory/(name+'.stderr')).read_text()
    symbols = {}
    for line in text.splitlines():
        match = re.match(r'PC pc=(\S+) base=(\S+) offset=(\S+) image=(.*?) symbol=(.*)', line)
        if match: symbols[match[1]] = dict(zip(('pc','base','offset','image','symbol'),match.groups()))
    unique = sorted({s['symbol'] for s in symbols.values()})
    names = subprocess.check_output([str(demangler),'--compact'], input='\n'.join(unique)+'\n',text=True).splitlines()
    assert len(names) == len(unique)
    demangled = dict(zip(unique,names))
    groups = json.load(gzip.open(directory/(name+'-groups.json.gz'),'rt'))['groups']
    kinds = {}
    proof_groups = []
    for group_id, group in enumerate(groups):
        pcs = tuple(int(x,16) for x in group['pcs']); key = (group['cohort'],group['route'],struct.pack('<'+'Q'*len(pcs),*pcs))
        category = classify(pcs,symbols,demangled,profile); kinds[key] = category
        if category == ('selected-static-host','runtime-metadata-witness'):
            proof_groups.append({'group':group_id, **{k:v for k,v in group.items() if k!='pcs'},
                'frames':[{'offset':symbols[hex(pc)]['offset'],'image':symbols[hex(pc)]['image'],
                           'symbol':symbols[hex(pc)]['symbol'],'demangled':demangled[symbols[hex(pc)]['symbol']]} for pc in pcs]})
    allocations = {}; roots = {}; image_lines = [s for s in text.splitlines() if s.startswith(('IMAGE ','HOST ','SIGNALS ','CONTROL '))]
    for row, vector in records(directory/(name+'.events')):
        kind,window,cohort,seq,pointer,requested,reserved,tag = row
        if kind == 2:
            category = kinds[(cohort,(tag>>16)&0xffff,vector)]
            allocations[seq] = {'window':window,'category':category,'requested':requested,'reserved':reserved,'retired':None}
        elif kind == 3: allocations[tag]['retired'] = window
        elif kind == 1: roots[window] = pointer
    stats = collections.defaultdict(lambda:collections.Counter())
    live = collections.Counter(); live_req = collections.Counter(); temp_live = collections.Counter()
    for row, vector in records(directory/(name+'.events')):
        kind,window,cohort,seq,pointer,requested,reserved,tag = row
        if kind == 1:
            for category, extent in live.items():
                r = stats[(window,*category)];r['baseline_reserved']=extent;r['baseline_requested']=live_req[category];r['peak_reserved']=extent;r['peak_requested']=live_req[category]
        elif kind in (2,3):
            allocation = allocations[seq if kind==2 else tag];category=allocation['category'];r=stats[(window,*category)]
            sign = 1 if kind==2 else -1
            live[category]+=sign*reserved;live_req[category]+=sign*requested
            if kind==2:r['allocations']+=1;r['requested_total']+=requested;r['reserved_total']+=reserved
            else:r['retirements']+=1
            r['peak_reserved']=max(r['peak_reserved'],live[category]);r['peak_requested']=max(r['peak_requested'],live_req[category]);r['peak_rounding']=max(r['peak_rounding'],live[category]-live_req[category])
            if allocation['retired']==allocation['window']:
                temp_live[category]+=sign*reserved;r['temporary_peak_reserved']=max(r['temporary_peak_reserved'],temp_live[category])
        elif kind==4:
            for category,extent in live.items():
                r=stats[(window,*category)];r['end_reserved']=extent;r['end_requested']=live_req[category]
    summarized = [{'window':w,'component':c,'cause':cause,**dict(s)} for (w,c,cause),s in sorted(stats.items())]
    raw_summary=json.loads((directory/(name+'-groups.json.summary.json')).read_text())
    for w in (1,2):
        selected=[r for r in summarized if r['window']==w]
        assert sum(r.get('allocations',0) for r in selected)==raw_summary['windows'][w-1]['allocations']
        assert sum(r.get('requested_total',0) for r in selected)==raw_summary['windows'][w-1]['requested_total']
        assert sum(r.get('reserved_total',0) for r in selected)==raw_summary['windows'][w-1]['reserved_total']
    return {'name':name,'entries':next(s for s in text.splitlines() if s.startswith('ENTRY ')),
            'actual_environment':image_lines,'raw_summary':raw_summary,'attribution':summarized,
            'selected_static_metadata':proof_groups}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory',type=pathlib.Path);parser.add_argument('output',type=pathlib.Path)
    args=parser.parse_args();root=pathlib.Path.cwd()
    for profile, expected in EXPECTED_IMAGES.items(): assert digest(args.directory/(profile+'-counter'))==expected, 'address-specific classifier requires frozen image'
    frozen=json.loads((args.directory/'artifact-hashes.json').read_text())
    # Recheck all original frozen measurement artifacts before attribution.
    for relative,sha in frozen.items(): assert digest(args.directory/relative)==sha,relative
    demangler=root/'.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swift-demangle'
    results=[analyze(args.directory,p,n,demangler) for n in range(1,4) for p in ['dynamic','static']]
    args.output.write_text(json.dumps({'scope':'measured public-event attribution; not route-completeness/stack/fit proof',
        'directory':str(args.directory),'measurement_manifest_sha256':digest(args.directory/'manifest.json'),
        'artifact_inventory_sha256':digest(args.directory/'artifact-hashes.json'),
        'demangler_sha256':digest(demangler),'results':results},indent=2)+'\n')
    for result in results:
        print(result['name'],[(r['window'],r.get('allocations',0),r.get('requested_total',0),r.get('reserved_total',0)) for r in result['attribution'] if r['component']=='selected-static-host' and r['cause']=='runtime-metadata-witness'])


if __name__=='__main__': main()
