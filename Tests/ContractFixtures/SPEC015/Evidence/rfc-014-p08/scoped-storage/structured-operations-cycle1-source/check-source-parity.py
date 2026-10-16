#!/usr/bin/env python3
"""Bounded source operand/lifecycle parity; no compiler, execution or fit claim."""
import json
import pathlib
import re
import subprocess

ROOT = pathlib.Path.cwd()
BASE = '81f5ed80'
DIRECTORY = 'Tests/ContractFixtures/SPEC015/RuntimeDerived/'
checks = []


def require(name, condition):
    assert condition, name
    checks.append(name)


def old(name):
    return subprocess.check_output(['git', 'show', BASE + ':' + DIRECTORY + name + '.swift'], text=True)


def current(name):
    return (ROOT / (DIRECTORY + name + '.swift')).read_text()


def block(text, anchor):
    start = text.index('{', text.index(anchor))
    depth = 1
    for end in range(start + 1, len(text)):
        depth += (text[end] == '{') - (text[end] == '}')
        if depth == 0:
            return text[start + 1:end]
    raise AssertionError(anchor)


def compact(text):
    return re.sub(r'\s+', '', text)


def pointer_queries(text):
    text = re.sub(r'(\b\w+(?:\.\w+)*)\.pointee\.requireVacantRuntimeSlot\(\)', r'CounterControl.requireVacantRuntimeSlot(at: \1)', text)
    text = re.sub(r'(\b\w+(?:\.\w+)*)\.pointee\.requireRuntimeClaim\(([^()]*)\)', r'CounterControl.requireRuntimeClaim(at: \1, \2)', text)
    text = re.sub(r'(\b\w+(?:\.\w+)*)\.pointee\.snapshotProducerOrigin\(\)', r'CounterControl.snapshotProducerOrigin(at: \1)', text)
    return re.sub(r'(\b\w+(?:\.\w+)*)\.pointee\.acceptsProducer\(([^()]*)\)', r'CounterControl.acceptsProducer(at: \1, \2)', text)


def host_formal(text):
    for name in ['p08ReuseModelValue', 'p08ReuseProducedAction', 'p08ReusePrepareAction', 'p08ReuseDeliverAction', 'p08ReuseTeardownStep', 'p08ReuseRejectAction']:
        text = text.replace('func ' + name + '<Owner>(host: borrowing', 'func ' + name + '<Owner>(host: inout')
        text = text.replace(name + '(host: host', name + '(host: &host').replace(name + '(host: self', name + '(host: &self')
    return text


before, after = old('CounterScopedStorage'), current('CounterScopedStorage')
for name in ['P08CallerCustody', 'p08EmbeddedGraph', 'p08EmbeddedHost', 'p08EmbeddedScoped',
             'p08DeriveMetadataLayout', 'p08RunEmbeddedCorpus', 'p08RequireSameInventory',
             'p08MetadataOuterView', 'p08RunMetadataCase', 'p08RunMetadataHost',
             'p08RunMetadataExchange', 'p08PrepareMetadata', 'p08DestroyMetadata',
             'p08RunMetadataTwoHosts', 'p08RunOneMetadataHost', 'p08ReconstructMetadataHost',
             'p08CompleteBody', 'runP08ScopedBody', 'p08RequireFreshControl', 'p08RequireRetiredControl']:
    require(name + ' exact except actual pointer queries', pointer_queries(block(before, name)) == block(after, name))
for profile in ['Static', 'Dynamic']:
    for name in ['p08Finish' + profile + 'Owner', 'p08Run' + profile + 'HostPhase',
                 'p08Construct' + profile + 'Host', 'p08Run' + profile + 'SessionPhase',
                 'p08UseOriginal' + profile + 'Host', 'p08FinishOriginal' + profile + 'Host']:
        require(name + ' original transfers/early/hooks/payload unchanged', host_formal(block(before, name)) == block(after, name))
for name in ['p08ReuseModelValue', 'p08ReuseProducedAction', 'p08ReusePrepareAction', 'p08ReuseDeliverAction',
             'p08ReuseTeardownStep', 'p08ReuseRejectAction', 'p08ReuseRejectOldOrigins', 'p08ReuseRejectInput',
             'p08ReuseRejectAdmission', 'p08ReuseRejectSource', 'p08ReuseCurrentAction', 'p08RunReuseHost']:
    require(name + ' exact effects/fields except inout host formal', host_formal(block(before, 'func ' + name + '<Owner>')) == block(after, 'func ' + name + '<Owner>'))
require('full fingerprint incl probe sequences unchanged', block(before, 'fileprivate struct P08ReuseFingerprint') == block(after, 'fileprivate struct P08ReuseFingerprint'))
require('156 sensitivity checks exact', block(before, 'func p08CheckBaselineSensitivity') == block(after, 'func p08CheckBaselineSensitivity'))
require('26 reuse label source multiset unchanged', sorted(re.findall(r'p08ReuseLabel\([^\n]+', before)) == sorted(re.findall(r'p08ReuseLabel\([^\n]+', after)))
for name in ['CounterAdmission', 'CounterApplication', 'CounterCoordinatorProbe']:
    require(name + ' solely mechanical actual-pointer queries', pointer_queries(old(name)) == current(name))
old_pipeline, pipeline = old('CounterPipelineOwner'), current('CounterPipelineOwner')
old_control, control = block(old_pipeline, 'struct CounterControl {'), block(pipeline, 'struct CounterControl {')
fields = lambda x: re.findall(r'^    (?:private(?:\(set\))? )?(?:var|let) [^\n]+', x, re.M)
require('all Control stored/computed declarations identical', fields(old_control) == fields(control))
for name in ['claimRuntimeSlot', 'tryClaimRuntimeSlot', 'completeRuntimeInstallation', 'clearRuntimeSlot',
             'installProducerOrigin', 'retireProducerOrigin', 'snapshotProducerOrigin()', 'acceptsProducer(_ origin:']:
    anchor = 'func ' + name if '(' in name else 'func ' + name + '('
    require(name + ' original state/provenance operation unchanged', block(old_control, anchor) == block(control, anchor))
expected = pointer_queries(old_pipeline).replace('endpoint.health = control.pointee.runtimeEndpoint?.baselineHealth()', 'endpoint.health = CounterEndpoint.runtimeBaselineHealth(at: control)').replace('endpoint.health == control.pointee.runtimeEndpoint?.baselineHealth()', 'endpoint.health == CounterEndpoint.runtimeBaselineHealth(at: control)')
# All other owned observations, capture maps, guards and pipeline operations are identical.
require('all non-Control pipeline source exact except selected query seams', expected.replace(block(expected, 'struct CounterControl {'), '<CONTROL>') == pipeline.replace(control, '<CONTROL>'))
for method, common, tail in [('requireVacantRuntimeSlot()', 'requireVacantFacts', '        let vacant ='), ('requireRuntimeClaim(_ claim:', 'requireClaimFacts', '        let matches =')]:
    original = block(old_control, 'func ' + method)
    prefix, original_logic = original.split(tail, 1)
    require(method + ' original seven/four named predicates/order', prefix in block(control, 'borrowing func ' + method))
    pointer_prefix = prefix
    for field in ['runtimeSlotPhase', 'runtimeSlotOwner', 'runtimeEndpoint', 'runtimeRootIdentity', 'runtimeActionIdentity', 'runtimeCandidateRootIdentity', 'runtimeCandidateActionIdentity']:
        pointer_prefix = re.sub(r'\b' + field + r'\b', 'control.pointee.' + field, pointer_prefix)
    static = 'static func ' + ('requireVacantRuntimeSlot(at ' if common == 'requireVacantFacts' else 'requireRuntimeClaim(at ')
    require(method + ' same actual-pointer field projection/order', pointer_prefix in block(control, static))
    require(common + ' exact original Boolean truth table', compact(tail + original_logic) == compact(block(control, 'private static func ' + common)))
require('actual origin snapshot private field only', compact(block(control, 'static func snapshotProducerOrigin(at ')) == 'control.pointee.producerOrigin')
require('actual producer origin complete equality and nil skip', compact(block(control, 'static func acceptsProducer(at ')) == compact('if control.pointee.selectedProducer { guard origin != nil else { return false } return origin == control.pointee.producerOrigin } return origin == nil'))
for name in ['CounterNativeRaster', 'CounterTiledRaster']:
    previous, present = old(name), current(name)
    old_health = '    borrowing func baselineHealth() -> GiftUIOperationalHealth { actual.health() }'
    begin = present.index('    // Same actual installed target')
    end = present.index('    mutating func captureBaselineSuffix', begin)
    require(name + ' only concrete health operation changed', previous.replace(old_health + '\n', '<HEALTH>\n') == present[:begin] + '<HEALTH>\n' + present[end:])
    target = 'actual.sink.target' if name == 'CounterNativeRaster' else 'actual.sink.session.target'
    require(name + ' actual installed target health, not enclosing backend', compact(block(present, 'static func runtimeBaselineHealth')) == compact('control.pointee.runtimeEndpoint?.' + target + '.control.pointee.backend.health'))
    require(name + ' idle direct field equivalence', compact(block(present, 'var isIdleForRuntimeRelease:')) == compact('actual.sink.isIdleForOffer'))
for profile in ['Static', 'Dynamic']:
    original = block(before, 'fileprivate func runP08' + profile + 'Host(')
    # Cold initial audit/assembly operation is byte-equivalent to the old initial guard.
    initial = re.search(r'    guard case \.valid\(let audit\).*\n', original).group(0)
    require(profile + ' original initial audit/factory/failure order', initial in block(after, 'func p08Prepare' + profile + 'Host'))
    if profile == 'Static':
        start = original.index('        let ownedChecks = counterOwnedSchedulerCompatibility(assembly.report)')
        end = original.index('        var checks = 0', start)
        cold = original[start:end]
        prepared = block(after, 'func p08CheckStaticHostConfiguration').replace('counterOwnedSchedulerCompatibility(report)', 'counterOwnedSchedulerCompatibility(assembly.report)')
        require('Static cold check operations/order before original root scope', compact(cold) == compact(prepared[:prepared.index('    return ownedChecks')]))
        expected = original[:start] + '        let ownedChecks = p08CheckStaticHostConfiguration(audit, report: assembly.report)\n' + original[end:]
    else:
        start = original.index('    precondition(CounterHostAssembly.validate')
        end = original.index('    return counterForeignJoinScope', start)
        require('Dynamic cold rejection checks/order unchanged', compact(original[start:end]) == compact(block(after, 'func p08CheckDynamicHostConfiguration')))
        expected = original[:start] + '    p08CheckDynamicHostConfiguration(audit)\n' + original[end:]
    expected = expected.replace(initial, '    let (audit, assembly) = p08Prepare' + profile + 'Host(outer: outer, owner: &owner)\n')
    require(profile + ' original foreign/root/semantic/canvas/body topology unchanged', expected == block(after, 'fileprivate func runP08' + profile + 'Host('))
    view = block(after, 'fileprivate struct P08' + profile + 'OuterView:')
    recon = block(view, 'borrowing func reconstruct')
    expected = '''
        p08RequireRetiredControl(control)
        CounterControl.requireVacantRuntimeSlot(at: control)
        p08DeinitializeOuterControl(control); p08DeinitializePROFILECanvas(canvas)
        p08DeinitializePROFILESemantic(semantic); p08DeinitializePROFILERoot(root)
        p08InitializePROFILERoot(root, owner: modelOwner)
        p08InitializePROFILESemantic(semantic, owner: semanticOwner)
        p08InitializePROFILECanvas(canvas); p08InitializeOuterControl(control)
        p08RequireFreshControl(control)
    '''.replace('PROFILE', profile)
    require(profile + ' exact per-object reconstruction sequence', compact(recon) == compact(expected))
    for member in ['Canvas', 'Semantic', 'Root']:
        require(profile + member + ' deinit original field exactly once', compact(block(after, 'func p08Deinitialize' + profile + member)) == 'field.deinitialize(count:1)')
        body = block(after, 'func p08Initialize' + profile + member)
        require(profile + member + ' original initializer expression retained', 'field.initialize(to:' in body and 'withUnsafe' not in body)
def call(text, anchor):
    start = text.index('(', text.index(anchor)); depth = 1
    for end in range(start + 1, len(text)):
        depth += (text[end] == '(') - (text[end] == ')')
        if depth == 0: return text[text.index(anchor):end + 1]
    raise AssertionError(anchor)

for profile in ['Static', 'Dynamic']:
    original = block(block(before, 'fileprivate struct P08' + profile + 'OuterView:'), 'borrowing func reconstruct')
    for member, parameter in [('Root', 'modelOwner'), ('Semantic', 'semanticOwner'), ('Canvas', None)]:
        expected = call(original, member.lower() + '.initialize(').replace(member.lower() + '.initialize(', 'field.initialize(')
        if parameter: expected = expected.replace(parameter, 'owner')
        actual = call(block(after, 'func p08Initialize' + profile + member), 'field.initialize(')
        require(profile + member + ' exact original initializer fields/capacities/namespace', compact(expected) == compact(actual))
core = (ROOT / 'Sources/GiftUIBackendIntegration/OneShotRasterBackendEndpoint.swift').read_text()
require('actual maintained endpoint health is only sink health delegation', compact(block(core, 'package borrowing func health(')) == 'sink.health()')
core = (ROOT / 'Sources/GiftUIBackendIntegration/OperationMajorRGB565RasterSession.swift').read_text()
require('actual Tiled session health is only target delegation', compact(block(core, 'package borrowing func health(')) == 'target.health()')
for name, adapter, delegate, target in [('CounterNativeRaster', 'CounterNativeRasterAdapter', 'target.health()', 'CounterNativeDisplayTarget'), ('CounterTiledRaster', 'CounterTiledRasterAdapter', 'session.health()', 'CounterTiledDisplayTarget')]:
    source = current(name)
    require(name + ' adapter health actual delegate', compact(block(block(source, 'struct ' + adapter), 'borrowing func health(')) == delegate)
    require(name + ' target health actual original pointer field', compact(block(block(source, 'struct ' + target), 'borrowing func health(')) == 'control.pointee.backend.health')
require('common Control init/deinit same typed operations', compact(block(after, 'func p08InitializeOuterControl')) == 'field.initialize(to:CounterControl())' and compact(block(after, 'func p08DeinitializeOuterControl')) == 'field.deinitialize(count:1)')
print(json.dumps({'kind': 'compiler-free-structured-operations-cycle1-source-parity', 'baseline': BASE,
                  'checks_passed': len(checks), 'checks': checks, 'compiler_or_runtime': False}, indent=2))
