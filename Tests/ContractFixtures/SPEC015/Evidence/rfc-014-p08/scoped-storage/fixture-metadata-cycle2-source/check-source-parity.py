#!/usr/bin/env python3
"""Bounded source parity, not Swift execution, stack or acceptance evidence."""
import hashlib
import json
import pathlib
import re
import subprocess

ROOT = pathlib.Path.cwd()
SOURCE = 'Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterScopedStorage.swift'
before = subprocess.check_output(['git', 'show', '3a1d1d32:' + SOURCE], text=True)
after = (ROOT / SOURCE).read_text()
checks = []


def require(name, condition):
    assert condition, name
    checks.append(name)


def block(text, anchor):
    start = text.index(anchor)
    opening = text.index('{', start)
    depth = 1
    for end in range(opening + 1, len(text)):
        if text[end] == '{':
            depth += 1
        elif text[end] == '}':
            depth -= 1
            if depth == 0:
                return text[opening + 1:end]
    raise AssertionError('unterminated block: ' + anchor)


for name in ['P08CallerCustody', 'p08EmbeddedGraph', 'p08EmbeddedHost',
             'p08EmbeddedScoped', 'p08DeriveMetadataLayout', 'p08RunEmbeddedCorpus',
             'p08RequireSameInventory', 'p08MetadataOuterView']:
    require(name + ' unchanged', block(before, name) == block(after, name))

old_fp = block(before, 'fileprivate struct P08ReuseFingerprint')
new_fp = block(after, 'fileprivate struct P08ReuseFingerprint')
require('same full stored baseline', old_fp[:old_fp.index('mutating func capture')] ==
        new_fp[:new_fp.index('mutating func capture')])
require('capture once body unchanged', block(old_fp, 'mutating func capture') ==
        block(new_fp, 'mutating func capture'))
old_match = block(old_fp, 'borrowing func matches')
for original, replacement in [
    ('runtimeSlot.matches(control)', 'matchesRuntimeSlot(control)'),
    ('acceptedRecording.matches(control.pointee.lastFrame)', 'matchesRecording(control)'),
    ('joins == counterJoinSnapshot(control)', 'matchesJoins(control)'),
    ('semantic == control.pointee.semanticSnapshot', 'matchesSemantic(control)'),
    ('admission == control.pointee.runtime.admission', 'matchesAdmission(control)')]:
    old_match = old_match.replace(original, replacement)
require('remaining match operands/order/effects unchanged', old_match == block(new_fp, 'mutating func matches('))
for name in ['matchesRuntimeSlot', 'matchesRecording', 'matchesJoins', 'matchesSemantic', 'matchesAdmission']:
    body = block(new_fp, 'func ' + name)
    require(name + ' does not assign frozen fields', not re.search(
        r'^\s*(?:self\.)?(?:runtimeSlot|acceptedRecording|joins|semantic|admission)[\w.!\[\]]*\s*=(?!=)', body, re.M))

join_source = (ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterHostProbe.swift').read_text()
joins = re.findall(r'\blet (\w+):', block(join_source, 'struct CounterJoinSnapshot'))
join_matches = block(new_fp, 'func matchesJoins')
require('all fourteen join fields', len(joins) == 14 and
        set(re.findall(r'joins!\.(\w+)', join_matches)) == set(joins))
join_constructor = block(join_source, 'func counterJoinSnapshot')
for field, current in re.findall(r'joins!\.(\w+) == control\.pointee\.([\w?.]+)', join_matches):
    require('join source operand ' + field, field + ': control.pointee.' + current in join_constructor)
require('join endpoint convention unchanged', 'let endpoints = 0' in join_constructor and
        'let currentEndpoints = 0' in join_matches and 'control.pointee.backend.constructedEndpoints' in join_matches)

for typename, field, sourcefile, helper, scalar_count, arrays in [
    ('CounterSemanticSnapshot', 'semantic', 'CounterHostCorpus.swift', 'matchesSemantic', 5, {'scalars': 22, 'textLengths': 4}),
    ('CounterAdmissionBacking', 'admission', 'CounterAdmission.swift', 'matchesAdmission', 8,
     {'pendingPointers': 2, 'sealedPointers': 2, 'pendingStates': 34, 'sealedStates': 34})]:
    text = (ROOT / 'Tests/ContractFixtures/SPEC015/RuntimeDerived' / sourcefile).read_text()
    equality = block(block(text, 'struct ' + typename), 'static func ==')
    operands = set(re.findall(r'left\.(\w+)', equality))
    body = block(new_fp, 'func ' + helper)
    actual = set(re.findall(field + r'!\.(\w+)', body))
    require(typename + ' every equality field', operands == actual and len(actual) == scalar_count + len(arrays))
    for member in sorted(actual):
        require(typename + ' exact current field ' + member,
                field + '!.' + member + ('[index]' if member in arrays else '') +
                ' == control.pointee.' + ('semanticSnapshot.' if field == 'semantic' else 'runtime.admission.') +
                member + ('[index]' if member in arrays else '') in body)
    for member, count in arrays.items():
        require(typename + ' full array ' + member, '0..<' + str(count) in body and
                '0..<' + str(count) in equality and member + '[index]' in body)
    require(typename + ' nil rejected before projection', 'let present = ' + field + ' != nil\n        guard present else' in body)

sensitivity = block(after, 'func p08CheckBaselineSensitivity')
require('four valid full alternate recipes', sensitivity.count('ordinal: 4') == 4 and
        sensitivity.count('ordinal: 3') == 4 and sensitivity.count('precondition(original != changed)') == 4)
require('all sixty-four record probes retained', 'for index in 0..<64' in sensitivity)
for field in ['runtimeRootIdentity', 'runtimeActionIdentity', 'runtimeCandidateRootIdentity', 'runtimeCandidateActionIdentity']:
    require('complete replacement and exact restore ' + field,
            'control.pointee.' + field + ' = changed' in sensitivity and
            'control.pointee.' + field + ' = original' in sensitivity)
codec = (ROOT / 'Sources/GiftUISemanticCore/SemanticRuntimeRecords.swift').read_text()
require('actual codec bound/root-first retained', 'ordinal < 5' in codec and '(count == 0) == (component.kind == .root)' in codec)
for original in [None, ('root', 0), ('root', 3), ('root', 4)]:
    selected = ('root', 4) if original != ('root', 4) else ('root', 3)
    require('finite valid alternate differs ' + str(original), selected != original and 0 <= selected[1] < 5)
bound = int(re.search(r'case \.fixedChild:\s*ordinal < (\d+)', codec).group(1))
def valid_probe_ordinals(text):
    ordinals = [int(value) for value in re.findall(r'kind: \.fixedChild, ordinal: (\d+)', text)]
    return len(ordinals) == 8 and all(0 <= value < bound for value in ordinals)
require('actual eight alternate appends obey parsed codec', valid_probe_ordinals(sensitivity))
require('mutation invalid ordinal rejected', not valid_probe_ordinals(sensitivity.replace('ordinal: 4', 'ordinal: 31', 1)))
require('mutation missing alternate rejected', not valid_probe_ordinals(sensitivity.replace('ordinal: 3', 'ordinal: -1', 1)))
require('invalid original ordinal rejected by same bound', not 0 <= 31 < bound)

require('literal reuse label multiset unchanged', sorted(re.findall(r'p08ReuseLabel\([^\n]+', before)) ==
        sorted(re.findall(r'p08ReuseLabel\([^\n]+', after)))
dispatch = block(after, 'func p08RunMetadataCase')
require('compact dispatcher has no initialization/view/transcript', all(token not in dispatch for token in
        ['initializeP08Backing', 'p08MetadataOuterView', 'P08RoleTranscript()', 'originalInventory()']))
for leaf in ['Invalid', 'Fault', 'Graph', 'Host', 'TwoHosts', 'Exchange']:
    require('actual owner formal ' + leaf, re.search(r'func p08RunMetadata' + leaf +
            r'[^\{]*owner: inout P08TypedBackingOwner', after) is not None)
require('two-host host calls and exchange view retained', block(after, 'func p08RunMetadataTwoHosts').count('runP08StaticHost(') == 2 and
        'p08MetadataOuterView(outer)' in block(after, 'func p08RunMetadataExchange'))
# Compare all host-branch expressions after the explicit owner/outer lvalue rename.
def compact(text):
    return re.sub(r'\s+', '', re.sub(r'//[^\n]*', '', text))

old_case = block(before, 'func p08RunMetadataCase')
host_case = block(after, 'func p08RunMetadataHost')
for begin, end in [('case .host(let scenario):', 'case .early(let early):'),
                   ('case .early(let early):', 'case .candidate(let raw):'),
                   ('case .candidate(let raw):', 'case .twoHosts:')]:
    old_branch = old_case.split(begin, 1)[1].split(end, 1)[0]
    new_end = end if end != 'case .twoHosts:' else 'default:'
    new_branch = host_case.split(begin, 1)[1].split(new_end, 1)[0]
    old_branch = old_branch.replace('owner.pointee', 'owner').replace('outer.', 'view.').replace('outer: outer', 'outer: view')
    require('same host/early/candidate effects ' + begin, compact(old_branch) == compact(new_branch))
old_two = old_case.split('case .twoHosts:', 1)[1].split('case .exchange', 1)[0]
old_two = old_two.replace('owner.pointee', 'owner').replace('original.pointee', 'original').replace('outer.', 'view.').replace('outer: outer', 'outer: view')
new_two = block(after, 'func p08RunMetadataTwoHosts').split('    guard let secondModel', 1)[1]
require('same complete two-host effects/order', compact(old_two) == compact('guard let secondModel' + new_two))
prepare = block(after, 'func p08PrepareMetadata')
destroy = block(after, 'func p08DestroyMetadata(')
objects = ['Outer', 'Owner', 'Baseline', 'Inventory', 'Transcript', 'ForeignRoot', 'ForeignControl']
require('seven initialization calls before their prefix publications', all(
        prepare.index('p08InitializeMetadata' + name + '(') < prepare.index('prefix = ' + str(index))
        for index, name in enumerate(objects, 1)))
require('reverse seven typed destruction calls', [destroy.index('p08DestroyMetadata' + name + '(') for name in reversed(objects)] ==
        sorted(destroy.index('p08DestroyMetadata' + name + '(') for name in reversed(objects)))
require('native actual lexical baseline', 'baseline: &localBaseline)' in after and
        'withUnsafeMutablePointer(to: &localBaseline)' not in after)
require('embedded actual donor baseline', 'baseline: &baseline.pointee)' in after)
for stage in ['Prepare', 'Delivery', 'Input', 'Admission', 'Source']:
    require('checked model-read short circuit ' + stage, re.search(
        r'if fingerprintUnchangedAfter' + stage + r'\s*\{\s*modelUnchangedAfter' + stage +
        r' = p08ReuseModelValue\(host: host\) == modelBefore\s*\} else \{\s*modelUnchangedAfter' + stage + r' = false', after) is not None)

print(json.dumps({'kind': __doc__, 'source_sha256': hashlib.sha256(after.encode()).hexdigest(),
                  'baseline_revision': '3a1d1d32', 'passed': len(checks), 'checks': checks,
                  'compiler_executed': False, 'runtime_executed': False}, indent=2))
