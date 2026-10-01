#!/usr/bin/env python3
"""Regenerate the bounded nRF tables from measured portable render projections."""
import json
from pathlib import Path
import re
import struct

ROOT = Path(__file__).resolve().parents[2]
FIXTURE = ROOT / 'Tests/ContractFixtures/SPEC001'
OUT = ROOT / 'Sources/SignalAnalyzerTargetHost/Generated'
rows = json.loads((FIXTURE / 'nrf-touch-ui-projection.json').read_text())
diag = json.loads((FIXTURE / 'nrf-touch-ui-diagnostic-projection.json').read_text())
assert len(rows) == 91 and len(diag) == 93
kinds = {1:'proxy',2:'vStack',3:'hStack',4:'zStack',5:'spacer',6:'text',7:'canvas',8:'modifier'}
live = [11,16,17,19,31,33,34,36,55,57,58,60,68,75,82,89]
primitives = [r for r in rows if r['kind'] in (2,3,4,5)]
modifiers = [r for r in rows if r['kind']==8 and r['flags'] in (2,11,12)]
styles = [r for r in rows if r['kind']==8 and r['ordinal'] not in live and r['flags'] not in (2,11,12)] + [diag[91]]
actions = [r for r in rows if r['kind']==1]
canvases = [r for r in rows if r['kind']==7]


def shape(records):
    return b''.join(struct.pack('<HHHHB',r['identity'],r['parent'],r['child'],r['sibling'],r['kind']) for r in records).hex()


def fingerprint(records):
    h=0xcbf29ce484222325
    for b in bytes.fromhex(shape(records)):
        h=((h^b)*0x100000001b3)&((1<<64)-1)
    return h


def replace_func(source, name, text):
    start=source.index('    private static func '+name+'(')
    opening=source.index('{', start)
    depth=1; end=opening+1
    while depth:
        depth += (source[end]=='{')-(source[end]=='}'); end+=1
    return source[:start]+text+source[end:]


def ordinal_func(name, records, field='ordinal'):
    cases='\n'.join(f'        case {i}: {r[field]}' for i,r in enumerate(records[:-1]))
    return f'''    private static func {name}(at index: UInt16) -> UInt16 {{
        switch index {{
{cases}
        default: {records[-1][field]}
        }}
    }}'''

src=(OUT/'StaticSignalAnalyzerNRFTopologyWriter.generated.swift').read_text()
src=re.sub(r'private static let normalShape: StaticString = "[^"]*"',f'private static let normalShape: StaticString = "{shape(rows)}"',src)
src=re.sub(r'private static let diagnosticShape: StaticString = "[^"]*"',f'private static let diagnosticShape: StaticString = "{shape(diag)}"',src)
src=src.replace('count = 96','count = 91').replace('count = 98','count = 93').replace('scopeCount == 96 || scopeCount == 98','scopeCount == 91 || scopeCount == 93')
# Change each method's loop count without altering unrelated bounds.
for method, count in [('populateInvariantPrimitives',len(primitives)),('populateInvariantLayoutModifiers',len(modifiers)),('populateLiveModifiers',len(live))]:
 a=src.index('    package static func '+method+'('); b=src.find('    package static func ',a+1)
 if b<0: b=len(src)
 src=src[:a]+re.sub(r'while slot < \d+',f'while slot < {count}',src[a:b])+src[b:]
for name, records, field in [('invariantPrimitiveOrdinal',primitives,'ordinal'),('invariantModifierOrdinal',modifiers,'ordinal'),('liveModifierOrdinal',[{'ordinal':n} for n in live],'ordinal'),('actionOrdinal',actions,'ordinal'),('actionIdentity',actions,'identity'),('canvasOrdinal',canvases,'ordinal'),('canvasIdentity',canvases,'identity')]:
 src=replace_func(src,name,ordinal_func(name,records,field))
prim_cases='\n'.join(f"        case {i}: (.{kinds[r['kind']]}, {r['aux']}, {r['p0']})" for i,r in enumerate(primitives[:-1]))
r=primitives[-1]
src=replace_func(src,'invariantPrimitivePayload',f'''    private static func invariantPrimitivePayload(at slot: UInt16)
        -> (kind: StaticSignalAnalyzerNRFScopeKind, auxiliary: UInt16, payload0: UInt32) {{
        switch slot {{
{prim_cases}
        default: (.{kinds[r['kind']]}, {r['aux']}, {r['p0']})
        }}
    }}''')
geometry={4:('0','UInt32(layout.headerHeight)'),6:('UInt32(layout.headerTextWidth)','0'),26:('UInt32(layout.gridWidth)','UInt32(layout.gridHeight)'),40:('UInt32(layout.traceWidth)','0')}
for n in (20,37,61): geometry[n]=('UInt32(layout.buttonSize - 4)','UInt32(layout.buttonSize - 4)')
for n in (44,48,52): geometry[n]=('UInt32(layout.rulerLabelWidth)','0')
for n in (64,71,78,85): geometry[n]=('UInt32(layout.labelWidth)','0')
for n in (66,73,80,87): geometry[n]=('UInt32(layout.traceWidth)','UInt32(layout.traceHeight)')
mod_cases=[]
for i,r in enumerate(modifiers):
 p0,p1=geometry.get(r['ordinal'],(str(r['p0']),str(r['p1'])))
 mod_cases.append(f"        {'default' if i==len(modifiers)-1 else 'case '+str(i)}: ({r['flags']}, {r['aux']}, {p0}, {p1})")
src=replace_func(src,'invariantModifierPayload','''    private static func invariantModifierPayload(at slot: UInt16)
        -> (flags: UInt8, auxiliary: UInt16, payload0: UInt32, payload1: UInt32) {
        let layout = SignalAnalyzerLayoutConstraints.reference
        return switch slot {
'''+ '\n'.join(mod_cases)+'''
        }
    }''')
src=replace_func(src,'invariantStyle','''    private static func invariantStyle(at ordinal: UInt16) -> (flags: UInt8, color: UInt32)? {
        switch ordinal {
'''+ '\n'.join(f"        case {r['ordinal']}: ({r['flags']}, {r['p0']})" for r in styles)+'''
        default: nil
        }
    }''')
src=src.replace('scopeCount == 96 ? 20 : 21', 'scopeCount == 91 ? 17 : 18')
src=src.replace('The 19 padding and frame modifiers','The generated padding and frame modifiers')
(OUT/'StaticSignalAnalyzerNRFTopologyWriter.generated.swift').write_text(src)
p=OUT/'StaticSignalAnalyzerNRFPackedSemanticRecords.generated.swift';src=p.read_text()
for kind,rs in [('normal',rows),('diagnostic',diag)]:
 src=re.sub(rf'{kind}TopologyFingerprint: UInt64 = [\d_]+',f'{kind}TopologyFingerprint: UInt64 = {fingerprint(rs)}',src)
p.write_text(src)
print(f'Generated 91/93 scopes, {len(primitives)} primitive payloads, {len(modifiers)} layout modifiers, 16 live modifiers and three actions')
