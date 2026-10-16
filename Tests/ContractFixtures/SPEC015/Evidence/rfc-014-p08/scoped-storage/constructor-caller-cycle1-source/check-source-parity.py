#!/usr/bin/env python3
"""Exact compiler-free inverse of the reviewed plan/constructor ABI correction."""
import importlib.util
import json
import pathlib
import re
import subprocess

PATH = 'Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterScopedStorage.swift'
BASE = '8bd6c784'
PRIOR = pathlib.Path(__file__).parents[1] / 'constructor-caller-source/check-source-parity.py'
spec = importlib.util.spec_from_file_location('prior_parity', PRIOR)
prior = importlib.util.module_from_spec(spec); spec.loader.exec_module(prior)
span, block, compact = prior.span, prior.block, prior.compact


def verify(source):
    old = subprocess.check_output(['git', 'show', BASE + ':' + PATH], text=True)
    checks = []
    def need(name, predicate):
        assert predicate, name
        checks.append(name)
    inverse = source
    for profile in ['Static', 'Dynamic']:
        ctor = 'fileprivate func p08Construct' + profile + 'Host('
        phase = 'fileprivate func p08Run' + profile + 'SessionPhase('
        a, b, c = span(source, ctor)
        header = source[a:b]
        previous_header = old[span(old, phase)[0]:span(old, phase)[1]]
        expected_header = previous_header.replace('p08Run' + profile + 'SessionPhase', 'p08Construct' + profile + 'Host').replace('control: UnsafeMutablePointer<CounterControl>', 'control: borrowing UnsafeMutablePointer<CounterControl>', 1).replace('audit: RuntimeStorageAudit, assembly: CounterHostAssembly', 'facts: inout P08HostRunFacts').replace(', candidateFailure: RuntimeCompletePipelineStage?, reuse: UnsafeMutablePointer<P08HostReuseTranscript>?, baseline: UnsafeMutablePointer<P08ReuseFingerprint>?', ', completion: inout P08HostConstructionFacts').replace('-> P08BodyResult', '-> P08' + profile + 'Host?')
        union = '@_lifetime(copy session, copy semantic, copy values, copy models, copy root, borrow control, copy activationSpan)\n'
        need(profile + ' exact original return union and actual inout plan; no new capability', compact(header) == compact(union + expected_header))
        expected_phase_header = previous_header.replace('audit: RuntimeStorageAudit, assembly: CounterHostAssembly', 'facts: inout P08HostRunFacts')
        need(profile + ' exact original phase permissions except owned plan ABI', compact(source[span(source, phase)[0]:span(source, phase)[1]]) == compact(expected_phase_header))
        cold = block(source, ctor)
        need(profile + ' only three owned early completions; no consumed owner defer', cold.count('completion.completed = P08BodyResult(') == 3 and 'defer' not in cold and cold.count('return nil') == 3)
        restored = cold.replace('facts.audit', 'audit').replace('facts.assembly', 'assembly')
        for constructed in ['false', 'true']:
            restored = restored.replace('completion.completed = P08BodyResult(checks: 1, constructed: ' + constructed + ', activationAttempted: false)\n        return nil', 'return P08BodyResult(checks: 1, constructed: ' + constructed + ', activationAttempted: false)')
        restored = restored.replace('completion.joinChecks =', 'let joinChecks =').replace('return SignalAnalyzerPresetHostInstances.', 'var host = SignalAnalyzerPresetHostInstances.')
        restored += '\n    defer { host?.p08FinishOriginal' + profile + 'Host() }\n    guard let result = host?.p08UseOriginal' + profile + 'Host(control: control, report: assembly.report, failAfterRuntime: failAfterRuntime, joinChecks: joinChecks, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline) else { preconditionFailure("original host factory invariant") }\n    return result\n'
        need(profile + ' full inverse early cleanup/transfers/two snapshots/joins/factory/options', compact(restored) == compact(block(old, phase)))
        live = block(source, phase)
        expected_live = '''
    var completion = P08HostConstructionFacts()
    var host = p08ConstructPROFILEHost(session: session, semantic: semantic, values: values, activationSpan: activationSpan, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, facts: &facts, failAfterRuntime: failAfterRuntime, early: early, completion: &completion)
    defer { host?.p08FinishOriginalPROFILEHost() }
    if let result = host?.p08UseOriginalPROFILEHost(control: control, report: facts.assembly.report, failAfterRuntime: failAfterRuntime, joinChecks: completion.joinChecks, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline) {
        let noEarlyCompletion = completion.completed == nil; precondition(noEarlyCompletion)
        return result
    }
    guard let result = completion.completed else { preconditionFailure("original host factory invariant") }
    return result
'''.replace('PROFILE', profile)
        need(profile + ' single Optional and exact live result/defer/early-factory disposition', compact(live) == compact(expected_live))
        need(profile + ' constructor returns before live/defer; no owner second home', live.index('var host = p08Construct') < live.index('defer') < live.index('p08UseOriginal') and live.count('var host =') == 1)
        prepared = 'fileprivate func p08RunPrepared' + profile + 'Host('
        frag = source[span(source, prepared)[0]:span(source, prepared)[2]]
        need(profile + ' actual inout callback transfer exactly once', frag.count('facts: &facts, foreignModels:') == 1)
        inverse_frag = frag.replace('facts: &facts, foreignModels:', 'audit: facts.audit, assembly: facts.assembly, foreignModels:')
        need(profile + ' all original callbacks/lenders/configuration timing unchanged', compact(inverse_frag) == compact(old[span(old, prepared)[0]:span(old, prepared)[2]]))
        # All edits to both constructor/phase bodies are now checked, so invert the region.
        a, _, _ = span(inverse, ctor); _, _, c = span(inverse, phase)
        inverse = inverse[:a] + old[span(old, phase)[0]:span(old, phase)[2]] + inverse[c:]
        a, _, c = span(inverse, prepared)
        inverse = inverse[:a] + inverse_frag + inverse[c:]
    scoped = 'fileprivate func runP08ScopedBody('
    a, _, c = span(source, scoped); frag = source[a:c]
    need('scoped actual inout facts to all three conditional profile routes', frag.count('facts: &facts, failAfterRuntime:') == 3)
    inverse_frag = frag.replace('facts: inout P08HostRunFacts', 'audit: RuntimeStorageAudit, assembly: CounterHostAssembly').replace('facts: &facts, failAfterRuntime:', 'audit: audit, assembly: assembly, failAfterRuntime:')
    need('producer activation/retirement/result and every original argument unchanged', compact(inverse_frag) == compact(old[span(old, scoped)[0]:span(old, scoped)[2]]))
    a, _, c = span(inverse, scoped); inverse = inverse[:a] + inverse_frag + inverse[c:]
    need('only private unscoped carrier becomes noncopyable', 'fileprivate struct P08HostRunFacts: ~Copyable {' in source and compact(block(source, 'fileprivate struct P08HostRunFacts')) == compact(block(old, 'fileprivate struct P08HostRunFacts')))
    completion = 'fileprivate struct P08HostConstructionFacts'
    need('completion carries owned result/count only', compact(block(source, completion)) == compact('var completed: P08BodyResult? = nil\nvar joinChecks: Int = 0'))
    a, _, c = span(inverse, completion); inverse = inverse[:a] + inverse[c:]
    inverse = inverse.replace('// No capability or scoped owner is retained in construction completion facts.', '').replace('// One private owned plan; no scope, pointer, callback or mutable backend.', '// Ordinary owned validation facts; no scope, pointer, callback or mutable backend.').replace('fileprivate struct P08HostRunFacts: ~Copyable {', 'fileprivate struct P08HostRunFacts {')
    need('all original tag predicates/writes and every byte outside reviewed cones unchanged', compact(inverse) == compact(old))
    inherited = prior.verify(inverse)
    need('inverse retains all112 original field/loan/oracle/prefix/cleanup checks', len(inherited) == 112)
    return checks


if __name__ == '__main__':
    source = pathlib.Path(PATH).read_text(); checks = verify(source)
    mutations = [
        ('copyable planning carrier', source.replace('P08HostRunFacts: ~Copyable {', 'P08HostRunFacts {', 1)),
        ('weaker returned union', source.replace('copy session, copy semantic, copy values, copy models, copy root, borrow control, copy activationSpan', 'copy session, copy semantic, copy values, copy models, copy root, copy activationSpan', 1)),
        ('early3 omitted hook route', source.replace('p08FinishStaticOwner(&owner)', 'p08FinishDynamicOwner(&owner)', 1)),
        ('wrong complete owned audit', source.replace('audit: facts.audit)', 'audit: counterActualAudit)', 1)),
        ('wrong join report', source.replace('report: facts.assembly.report)', 'report: CounterHostAssembly.emptyReport)', 1)),
        ('wrong same-owner constructor lender', source.replace('foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, facts: &facts', 'foreignRoot: root, control: control, foreignControl: foreignControl, facts: &facts', 1)),
        ('scoped callback copied planning values', source.replace('facts: &facts, foreignModels:', 'audit: facts.audit, assembly: facts.assembly, foreignModels:', 1)),
        ('removed actual plan nil write', source.replace('    facts = nil', '    // no clear', 1)),
        ('changed original physical capacity', source.replace('configuration: capacities)', 'configuration: [1, 1, 1, 1, 1])', 1)),
        ('weaker full current baseline field', source.replace('let sameapplied = joins!.applied == control.pointee.applied', 'let sameapplied = true', 1)),
    ]
    for name, mutated in mutations:
        assert mutated != source, name
        try: verify(mutated)
        except (AssertionError, ValueError): pass
        else: raise AssertionError('undetected mutation: ' + name)
    print(json.dumps(dict(kind='compiler-free-constructor-caller-cycle1-inverse-parity', baseline=BASE, checks_passed=len(checks), checks=checks, inherited_initial_checks=112, negative_mutations_rejected=[n for n,_ in mutations], compiler_or_runtime=False), indent=2))
