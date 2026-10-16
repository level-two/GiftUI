#!/usr/bin/env python3
"""Compiler-free exact inverse for the final three reviewed transfer seams."""
import importlib.util
import json
import pathlib
import re
import subprocess

PATH = 'Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterScopedStorage.swift'
BASE = '42c0a1e2'
PRIOR = pathlib.Path(__file__).parents[1] / 'constructor-caller-cycle1-source/check-source-parity.py'
spec = importlib.util.spec_from_file_location('cycle1_parity', PRIOR)
prior = importlib.util.module_from_spec(spec); spec.loader.exec_module(prior)
span, block, compact = prior.span, prior.block, prior.compact


def verify(source):
    old = subprocess.check_output(['git', 'show', BASE + ':' + PATH], text=True)
    inverse = source; checks = []
    def need(name, predicate):
        assert predicate, name
        checks.append(name)
    for profile in ['Static', 'Dynamic']:
        ctor = 'fileprivate func p08Construct' + profile + 'Host('
        a,b,c = span(source, ctor); frag = source[a:c]
        union = '@_lifetime(destination: copy session, copy semantic, copy values, copy models, copy root, borrow control, copy activationSpan)'
        need(profile + ' exact full original union on named inout output', union in frag and 'destination: inout P08' + profile + 'Host?' in frag)
        body = block(source, ctor)
        need(profile + ' early1/2/3 leave initialized-nil destination unchanged', body.count('\n        return\n') == 3 and body.count('destination =') == 2 and 'destination =' not in body[:body.index('#if')])
        need(profile + ' no raw placement or new release/deinit', not any(x in body for x in ['UnsafeMutableRaw', '.deinitialize(', '.release(', 'initialize(to:']))
        restored = frag.replace('@_lifetime(destination:', '@_lifetime(', 1).replace('@_lifetime( copy', '@_lifetime(copy', 1).replace('destination: inout P08' + profile + 'Host?, completion: inout P08HostConstructionFacts)', 'completion: inout P08HostConstructionFacts) -> P08' + profile + 'Host?').replace('\n        return\n', '\n        return nil\n').replace('destination = SignalAnalyzerPresetHostInstances.', 'return SignalAnalyzerPresetHostInstances.')
        restored = restored.replace('foreignControl: foreignControl, facts: &facts)', 'foreignControl: foreignControl, audit: facts.audit, report: facts.assembly.report)')
        need(profile + ' inverse exact original cold transfers/guards/joins/factory/completion', compact(restored) == compact(old[span(old, ctor)[0]:span(old, ctor)[2]]))
        a,_,c = span(inverse, ctor); inverse = inverse[:a] + restored + inverse[c:]
        phase = 'fileprivate func p08Run' + profile + 'SessionPhase('
        a,_,c = span(source, phase); frag = source[a:c]
        need(profile + ' exactly one initialized nil field and actual destination call', frag.count('var host: P08' + profile + 'Host? = nil') == 1 and frag.count('destination: &host') == 1 and frag.count('defer { host?.p08FinishOriginal') == 1)
        need(profile + ' original nil construction/use/defer order', frag.index('Host? = nil') < frag.index('destination: &host') < frag.index('defer { host?') < frag.index('host?.p08UseOriginal'))
        restored = frag.replace('var host: P08' + profile + 'Host? = nil\n    p08Construct' + profile + 'Host(', 'var host = p08Construct' + profile + 'Host(').replace('destination: &host, completion:', 'completion:')
        need(profile + ' same payload/options/early factory disposition and teardown', compact(restored) == compact(old[span(old, phase)[0]:span(old, phase)[2]]))
        a,_,c = span(inverse, phase); inverse = inverse[:a] + restored + inverse[c:]
        joins = 'fileprivate func p08Check' + profile + 'HostJoins('
        a,b,c = span(source, joins); frag = source[a:c]
        need(profile + ' joins exact actual field loan, complete owned core args', 'facts: inout P08HostRunFacts' in source[a:b] and 'audit: facts.audit, report: facts.assembly.report,' in frag)
        restored = frag.replace('facts: inout P08HostRunFacts', 'audit: RuntimeStorageAudit, report: HostAssemblyReport').replace('audit: facts.audit, report: facts.assembly.report,', 'audit: audit, report: report,')
        need(profile + ' inverse complete two snapshots/six checks/call order', compact(restored) == compact(old[span(old, joins)[0]:span(old, joins)[2]]))
        a,_,c = span(inverse, joins); inverse = inverse[:a] + restored + inverse[c:]
        config = 'fileprivate func p08Check' + profile + 'HostConfiguration('
        a,b,c = span(source, config); frag = source[a:c]
        need(profile + ' configuration actual inout field only', '_ facts: inout P08HostRunFacts' in source[a:b])
        need(profile + ' all four assertion captures are owned Boolean only', re.findall(r'precondition\(([^\n]+)\)', block(source, config)) == ['rejected' + str(i) for i in range(4)])
        restored = frag.replace('_ facts: inout P08HostRunFacts', '_ audit: RuntimeStorageAudit' + (', report: HostAssemblyReport' if profile == 'Static' else '')).replace('facts.audit', 'audit').replace('facts.assembly.report', 'report')
        restored = re.sub(r'let rejected(\d) = ([^\n]+)\n    precondition\(rejected\1\)', r'precondition(\2)', restored)
        need(profile + ' inverse all actual original configuration predicates/order', compact(restored) == compact(old[span(old, config)[0]:span(old, config)[2]]))
        a,_,c = span(inverse, config); inverse = inverse[:a] + restored + inverse[c:]
        prepared = 'fileprivate func p08RunPrepared' + profile + 'Host('
        a,_,c = span(source, prepared); frag = source[a:c]
        need(profile + ' exactly one configuration call with original field', frag.count('p08Check' + profile + 'HostConfiguration(&facts)') == 1)
        restored = frag.replace('p08Check' + profile + 'HostConfiguration(&facts)', 'p08Check' + profile + 'HostConfiguration(facts.audit' + (', report: facts.assembly.report)' if profile == 'Static' else ')'))
        need(profile + ' exact original configuration timing and whole original callback body', compact(restored) == compact(old[span(old, prepared)[0]:span(old, prepared)[2]]))
        a,_,c = span(inverse, prepared); inverse = inverse[:a] + restored + inverse[c:]
    helper = 'fileprivate func p08RequireSecondNamespaces('
    a,b,c = span(source, helper)
    expected = '''guard let secondModel, let secondSemantic else { preconditionFailure("second namespaces") }
    return (secondModel, secondSemantic)'''
    need('cold helper preserves exact guard/message and returns only same owned IDs', compact(block(source, helper)) == compact(expected))
    need('actual original inout owner/outer; no consumption/owner return', 'owner: inout P08TypedBackingOwner, outer: inout P08EmbeddedOuter' in source[a:b] and '-> (ObservableModelOwnerIdentity, SemanticRecordOwnerIdentity)' in source[a:b] and 'consuming' not in source[a:b])
    name = 'fileprivate func p08RunMetadataTwoHosts('
    a,_,c = span(source, name); frag = source[a:c]
    actual = 'let (secondModel, secondSemantic) = p08RequireSecondNamespaces(owner: &owner, outer: &outer, secondModel: secondModel, secondSemantic: secondSemantic)'
    need('exact namespace call after backing init before inventory/freshness/host', frag.count(actual) == 1 and frag.index('p08InitializeMetadataHostBacking') < frag.index(actual) < frag.index('p08CaptureMetadataHostInventory') < frag.index('p08RequireFreshControl') < frag.index('p08RunOneMetadataHost'))
    restored = frag.replace(actual, 'guard let secondModel, let secondSemantic else { preconditionFailure("second namespaces") }')
    need('inverse entire two-host/reconstruction/inventory/namespace ordering unchanged', compact(restored) == compact(old[span(old, name)[0]:span(old, name)[2]]))
    a,_,c = span(inverse, name); inverse = inverse[:a] + restored + inverse[c:]
    a,_,c = span(inverse, helper); inverse = inverse[:a] + inverse[c:]
    inverse = inverse.replace('// The exact invariant check ends before inventory/host work. Actual owner/outer\n// remain inout inputs, not transferred owners; failure cleanup requires target inspection.', '')
    need('every source token outside reviewed seams unchanged', compact(inverse) == compact(old))
    inherited = prior.verify(inverse)
    need('inverse retains prior22 checks and original112 loan/oracle/prefix checks', len(inherited) == 22)
    return checks


if __name__ == '__main__':
    source = pathlib.Path(PATH).read_text(); checks = verify(source)
    mutations = [
        ('missing destination dependency', source.replace('copy values, copy models, copy root, borrow control', 'copy values, copy models, borrow control', 1)),
        ('ordinary return without destination union', source.replace('@_lifetime(destination:', '@_lifetime(', 1)),
        ('nonempty original destination', source.replace('var host: P08StaticHost? = nil', 'var host: P08StaticHost? = anotherHost', 1)),
        ('wrong destination field', source.replace('destination: &host, completion:', 'destination: &anotherHost, completion:', 1)),
        ('early path destroys destination', source.replace('completion.completed = P08BodyResult(checks: 1, constructed: false, activationAttempted: false)', 'destination = nil\n        completion.completed = P08BodyResult(checks: 1, constructed: false, activationAttempted: false)', 1)),
        ('weakened configuration', source.replace('sourceCallbacks: 21) == nil', 'sourceCallbacks: 20) == nil', 1)),
        ('wrong complete join audit', source.replace('audit: facts.audit, report: facts.assembly.report, expected:', 'audit: otherAudit, report: facts.assembly.report, expected:', 1)),
        ('wrong original namespace input', source.replace('secondModel: secondModel, secondSemantic: secondSemantic)', 'secondModel: secondModel, secondSemantic: nil)', 1)),
        ('new release before guard', source.replace('guard let secondModel, let secondSemantic else', 'owner.release()\n    guard let secondModel, let secondSemantic else', 1)),
        ('weaker complete baseline', source.replace('let sameapplied = joins!.applied == control.pointee.applied', 'let sameapplied = true', 1)),
    ]
    for name, mutated in mutations:
        assert mutated != source, name
        try: verify(mutated)
        except (AssertionError, ValueError): pass
        else: raise AssertionError('undetected mutation: ' + name)
    print(json.dumps(dict(kind='compiler-free-constructor-caller-cycle2-inverse-parity', baseline=BASE, checks_passed=len(checks), checks=checks, inherited_cycle1_checks=22, inherited_initial_checks=112, negative_mutations_rejected=[n for n,_ in mutations], compiler_or_runtime=False), indent=2))
