#!/usr/bin/env python3
"""Bounded source operand/lifecycle parity; no compiler, execution or fit claim."""
import json
import pathlib
import re
import subprocess

ROOT = pathlib.Path.cwd()
BASE = 'ee56c020'
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


before, after = old('CounterScopedStorage'), current('CounterScopedStorage')
for name in ['P08CallerCustody', 'p08EmbeddedGraph', 'p08EmbeddedHost', 'p08EmbeddedScoped',
             'p08DeriveMetadataLayout', 'p08RunEmbeddedCorpus', 'p08RequireSameInventory',
             'p08MetadataOuterView', 'p08CompleteBody', 'runP08ScopedBody', 'runP08StaticHost',
             'runP08DynamicHost', 'p08RunMetadataCase', 'p08RunMetadataHost',
             'p08RunMetadataExchange', 'p08PrepareMetadata', 'p08DestroyMetadata',
             'p08ReuseRejectOldOrigins', 'p08ReuseCurrentPointer']:
    require(name + ' unchanged', block(before, name) == block(after, name))
for profile in ['Static', 'Dynamic']:
    for name in ['p08Finish' + profile + 'Owner', 'p08Run' + profile + 'HostPhase']:
        require(name + ' exact eight-hook/host operations', block(before, name) == block(after, name))
    original = block(before, 'func p08Run' + profile + 'SessionPhase')
    expected = original[:original.index('    // This lexical host')]
    expected = expected.replace('return P08BodyResult(checks: 1, constructed: false, activationAttempted: false)', 'facts.completed = P08BodyResult(checks: 1, constructed: false, activationAttempted: false)\n        return nil')
    expected = expected.replace('return P08BodyResult(checks: 1, constructed: true, activationAttempted: false)', 'facts.completed = P08BodyResult(checks: 1, constructed: true, activationAttempted: false)\n        return nil')
    expected = expected.replace('let joins = counterCheck', 'facts.joinChecks = counterCheck')
    expected = re.sub(r'var host = (SignalAnalyzerPresetHostInstances.\w+\(report: assembly.report, owner: owner\))!', r'return \1', expected)
    require(profile + ' cold early cleanup/joins/factory exact', compact(expected) == compact(block(after, 'func p08Construct' + profile + 'Host')))
    runner = block(after, 'func p08Run' + profile + 'SessionPhase')
    require(profile + ' one Optional host declaration', runner.count('var host = ') == 1 and 'guard var host' not in runner and 'host!' not in runner and '.take()' not in runner)
    require(profile + ' same payload use/teardown', 'defer { host?.p08FinishOriginal' + profile + 'Host() }' in runner and 'host?.p08UseOriginal' + profile + 'Host(' in runner)
    use = block(after, 'func p08UseOriginal' + profile + 'Host')
    require(profile + ' early4 before activation path', use.index('if early == 4') < use.index('return p08Run' + profile + 'HostPhase(host: &self'))
    finish = block(after, 'func p08FinishOriginal' + profile + 'Host')
    require(profile + ' teardown then original owned step8', finish.index('self.teardown()') < finish.index('p08ReuseTeardownStep(host: self)') < finish.index('let finished = teardownStep == 8; precondition(finished)'))
expected = block(before, 'func p08RunMetadataTwoHosts(')
expected = expected.replace('    let initialized = initializeP08Backing(&owner) == nil\n    precondition(initialized)', '    p08InitializeMetadataHostBacking(&owner)')
expected = expected.replace('    let view = p08MetadataOuterView(outer)\n', '')
expected = expected.replace('original = owner.originalInventory()', 'p08CaptureMetadataHostInventory(&owner, into: &original)')
expected = expected.replace('let control = view.control, address = UInt(bitPattern: view.control)', 'let control = outer.control, address = UInt(bitPattern: outer.control)')
expected = expected.replace('runP08StaticHost(owner: &owner, outer: view, failAfterRuntime: false, write: write, reuse: transcript, baseline: before, foreignRootStorage: foreignRoot, foreignControlStorage: foreignControl)', 'p08RunOneMetadataHost(owner: &owner, outer: &outer, before: before, transcript: transcript, foreignRoot: foreignRoot, foreignControl: foreignControl, write: write)')
expected = expected.replace('    view.reconstruct(modelOwner: secondModel, semanticOwner: secondSemantic)\n    p08ResetForeignMetadata(root: foreignRoot, control: foreignControl)', '    p08ReconstructMetadataHost(outer: &outer, model: secondModel, semantic: secondSemantic, foreignRoot: foreignRoot, foreignControl: foreignControl)')
expected = expected.replace('owner.requireEmpty()', 'p08RequireMetadataHostEmpty(&owner)').replace('p08RequireRetiredControl(control)', 'p08RequireMetadataHostRetired(control)')
require('two-host original effects/oracle order retained through concrete operations', expected == block(after, 'func p08RunMetadataTwoHosts('))
require('two calls one per-host operation', block(after, 'func p08RunMetadataTwoHosts(').count('p08RunOneMetadataHost(') == 2)
require('one original view inside per-host operation', block(after, 'func p08RunOneMetadataHost(').count('p08MetadataOuterView(outer)') == 1)
require('two complete return lifetime unions', after.count('@_lifetime(copy session, copy semantic, copy values, copy models, copy root, borrow control, copy activationSpan)') == 2)
require('two explicit negative owner constraints', after.count('extension SignalAnalyzerPresetHostInstance where Owner: SignalAnalyzerPresetLiveOwner & ~Copyable & ~Escapable, Owner == P08') == 2)
old_fp, new_fp = block(before, 'fileprivate struct P08ReuseFingerprint'), block(after, 'fileprivate struct P08ReuseFingerprint')
require('same complete baseline stored fields', old_fp[:old_fp.index('mutating func capture')] == new_fp[:new_fp.index('mutating func capture')])
require('capture once same all facts', block(old_fp, 'mutating func capture').replace('acceptedRecording.capture(control.pointee.lastFrame)', 'acceptedRecording.captureAccepted(control)') == block(new_fp, 'mutating func capture'))
for name in ['matchesJoins', 'matchesSemantic', 'matchesAdmission']:
    require(name + ' exact full field map', block(old_fp, 'func ' + name) == block(new_fp, 'func ' + name))
expected = block(old_fp, 'mutating func matches(').replace('        var now = control.pointee.scheduler, deadline = control.pointee.scheduler\n        let schedulerReport = control.pointee.scheduler?.assemblyReport\n', '')
expected = expected.replace('schedulerNow == now?.begin(at: control.pointee.wakeClockMicroseconds, lifecycleState: .active, assemblyReport: schedulerReport!)', 'matchesSchedulerNow(control)').replace('schedulerDeadline == deadline?.begin(at: boundary.partialValue, lifecycleState: .active, assemblyReport: schedulerReport!)', 'matchesSchedulerDeadline(control, boundary: boundary.partialValue)')
require('main full fingerprint guard operands and order', expected == block(new_fp, 'mutating func matches('))
require('literal reuse label multiset unchanged', sorted(re.findall(r'p08ReuseLabel\([^\n]+', before)) == sorted(re.findall(r'p08ReuseLabel\([^\n]+', after)))
require('all original checked model skips/effects unchanged', block(before, 'func p08ReuseRejectAction<Owner>') == block(after, 'func p08ReuseRejectAction<Owner>'))
old_pipe, new_pipe = old('CounterPipelineOwner'), current('CounterPipelineOwner')
require('owned recording equality witness unchanged', block(old_pipe, 'borrowing func matches(_ current:') == block(new_pipe, 'borrowing func matches(_ current:'))
require('runtime baseline stored inventory unchanged', compact(block(old_pipe, 'struct CounterRuntimeSlotBaseline')[:block(old_pipe, 'struct CounterRuntimeSlotBaseline').index('mutating func capture')]) == compact(block(new_pipe, 'struct CounterRuntimeSlotBaseline')[:block(new_pipe, 'struct CounterRuntimeSlotBaseline').index('    @inline(never)')]))
expected_slot = block(old_pipe, 'borrowing func matches(_ control:')
expected_slot = expected_slot.replace('            let sameEndpoint = control.pointee.runtimeEndpoint?.matchesBaseline(endpoint) == true\n            guard sameEndpoint else { return false }', '            let samePrefix = control.pointee.runtimeEndpoint?.matchesBaselinePrefix(&endpoint) == true\n            guard samePrefix else { return false }\n            let sameHealth = endpoint.health == control.pointee.runtimeEndpoint?.baselineHealth()\n            guard sameHealth else { return false }\n            let sameSuffix = control.pointee.runtimeEndpoint?.matchesBaselineSuffix(&endpoint) == true\n            guard sameSuffix else { return false }')
require('runtime slot all actual backend/phase/keys and endpoint order', expected_slot == block(new_pipe, 'mutating func matches(_ control:'))
for filename in ['CounterNativeRaster', 'CounterTiledRaster']:
    previous, present = old(filename), current(filename)
    expected_capture = block(previous, 'func captureBaseline(').replace('        baseline.health = actual.health()\n', '').replace('baseline.recording.capture(actual.sink.recording)', 'baseline.recording.captureEndpoint(&self)')
    actual_capture = block(present, 'func captureBaselinePrefix(') + block(present, 'func captureBaselineSuffix(')
    require(filename + ' exact all non-health capture operands/order', compact(expected_capture) == compact(actual_capture))
    expected_match = block(previous, 'func matchesBaseline(').replace('        let samehealth = baseline.health == actual.health()\n        guard samehealth else { return false }\n', '').replace('baseline.recording.matches(actual.sink.recording)', 'baseline.recording.matchesEndpoint(&self)')
    actual_match = block(present, 'func matchesBaselinePrefix(')
    actual_match = actual_match.rsplit('        return true', 1)[0] + block(present, 'func matchesBaselineSuffix(')
    require(filename + ' exact all non-health guard operands/order', compact(expected_match) == compact(actual_match))
    require(filename + ' pure actual health', 'borrowing func baselineHealth() -> GiftUIOperationalHealth { actual.health() }' in present)
    require(filename + ' old owned guard oracle unchanged', block(previous, 'var ownedObservation:') == block(present, 'var ownedObservation:'))
    require(filename + ' no unsafe writable core sink projection', '&actual.sink' not in present)
require('checked metadata derivation unchanged', block(after, 'p08DeriveMetadataLayout') == block(before, 'p08DeriveMetadataLayout'))
print(json.dumps({'kind': 'compiler-free-structured-operations-source-parity', 'baseline': BASE,
                  'checks_passed': len(checks), 'checks': checks, 'compiler_or_runtime': False}, indent=2))
