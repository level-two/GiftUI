#!/usr/bin/env python3
"""Compiler-free finite source/dataflow parity; no ownership/codegen claim."""
import json
import pathlib
import re
import subprocess

PATH = 'Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterScopedStorage.swift'
BASE = '51cb92b7'
IDS = ['b0','b1','b2','b3','g0','g1','g2','g3','g4','c0','h0','r0','r1','h1']
BANKS = ['c0','h0','r0','r1','h1']


def span(text, anchor):
    pos = text.index(anchor); first = text.rfind('\n',0,pos)+1
    while first:
        previous = text.rfind('\n',0,first-1)+1
        if not text[previous:first].strip().startswith('@'): break
        first = previous
    brace = text.index('{',pos); depth = 1
    for end in range(brace+1,len(text)):
        depth += (text[end]=='{')-(text[end]=='}')
        if not depth: return first,brace,end+1
    raise AssertionError(anchor)


def block(text, anchor):
    a,b,c = span(text,anchor); return text[b+1:c-1]


def compact(text): return re.sub(r'\s+','',text)


def without(text, anchor):
    a,b,c = span(text,anchor); return text[:a]+text[c:]


def verify(new):
    old = subprocess.check_output(['git','show',BASE+':'+PATH],text=True)
    checks = []
    def need(name, value):
        assert value, name
        checks.append(name)
    # Same complete callback expressions, argument order, field maps and errors.
    for profile in ['Static','Dynamic']:
        original = block(old,'fileprivate func runP08'+profile+'Host(')
        prepared = block(new,'fileprivate func p08RunPrepared'+profile+'Host(')
        nested = original[original.index('    return counterForeignJoinScope'):]
        for field in ['limits','audit','assembly']: prepared=prepared.replace('facts.'+field,field)
        if profile=='Dynamic':prepared=prepared.replace('    p08CheckDynamicHostConfiguration(audit)\n','',1)
        need(profile+' complete original callback/effect/argument body', compact(prepared)==compact(nested))
        header = new[span(new,'fileprivate func p08RunPrepared'+profile+'Host(')[0]:span(new,'fileprivate func p08RunPrepared'+profile+'Host(')[1]]
        need(profile+' actual facts inout; no whole outer route', 'facts: inout P08HostRunFacts' in header and 'outer:' not in header)
        active = block(new,'fileprivate func p08RunPrepared'+profile+'Host(')
        need(profile+' no whole-facts copy/outer callback capture', not re.search(r'\b(?:let|var)\s+\w+\s*=\s*facts\b(?!\.)',active) and not re.search(r'\bouter\b',active))
        adapter = block(new,'fileprivate func runP08'+profile+'Host(')
        projection = original[:original.index('    let limits = outer.limits')]
        need(profile+' original scalar typed projection before facts loan', compact(adapter[:adapter.index('    var facts:')])==compact(projection))
        need(profile+' cold install then actual field run then clear', adapter.index('p08Install'+profile+'HostPlan') < adapter.index('facts: &facts!') < adapter.index('p08ClearHostPlan(&facts)'))
        arguments = ['rootStorage','semanticStorage','canvasStorage','control','failAfterRuntime','early','candidateFailure','reuse','baseline']
        if profile=='Static':arguments += ['recordsBacking','pathsBacking','payloadsBacking','scalarsBacking','entriesBacking','foreignRootStorage','foreignControlStorage']
        for field in arguments:
            need(profile+' exact adapter actual argument '+field,field+': '+field in adapter)
        install=block(new,'fileprivate func p08Install'+profile+'HostPlan(')
        expected_install='let vacant = facts == nil; precondition(vacant)'
        if profile=='Static':expected_install+='\n#if hasFeature(Embedded) || GIFTUI_COUNTER_TILED\nif let write { outer.control.pointee.backend.write = write }\n#endif'
        expected_install+='\nlet (audit, assembly) = p08Prepare'+profile+'Host(outer: outer, owner: &owner)\nfacts = .init(limits: outer.limits, audit: audit, assembly: assembly)'
        need(profile+' complete cold install actual facts/write order',compact(install)==compact(expected_install))
        # Expected lexical construction is the exact old constructor, with only
        # private completion/return-edge representation changed.
        expected = block(old,'fileprivate func p08Construct'+profile+'Host(')
        expected=expected.replace('        facts.completed = P08BodyResult(checks: 1, constructed: false, activationAttempted: false)\n        return nil','        return P08BodyResult(checks: 1, constructed: false, activationAttempted: false)').replace('        facts.completed = P08BodyResult(checks: 1, constructed: true, activationAttempted: false)\n        return nil','        return P08BodyResult(checks: 1, constructed: true, activationAttempted: false)')
        start=expected.index('    let expected = counterJoinSnapshot(control), foreignExpected = counterJoinSnapshot(foreignControl)');end=expected.index('\n    #if',start)
        oldjoin=expected[start:end]
        expected=expected[:start]+'    let joinChecks = p08Check'+profile+'HostJoins(owner: &owner, models: models, root: root, foreignModels: foreignModels, foreignRoot: foreignRoot, control: control, foreignControl: foreignControl, audit: audit, report: assembly.report)'+expected[end:]
        expected=expected.replace('    return SignalAnalyzerPresetHostInstances.','    var host = SignalAnalyzerPresetHostInstances.')
        expected+='\n    defer { host?.p08FinishOriginal'+profile+'Host() }\n    guard let result = host?.p08UseOriginal'+profile+'Host(control: control, report: assembly.report, failAfterRuntime: failAfterRuntime, joinChecks: joinChecks, early: early, candidateFailure: candidateFailure, reuse: reuse, baseline: baseline) else { preconditionFailure("original host factory invariant") }\n    return result\n'
        actual=block(new,'fileprivate func p08Run'+profile+'SessionPhase(')
        need(profile+' exact lexical early1/2/3/type transfers/factory/Optional/defer',compact(actual)==compact(expected))
        need(profile+' one Optional, no consumed-owner defer',actual.count('var host = SignalAnalyzerPresetHostInstances.')==2 and 'defer { owner' not in actual and 'guard var host' not in actual)
        # The removed facts.completed was nil on every path reaching the host;
        # every assignment in the old constructor returned immediately.
        need(profile+' old completion guard redundant on every host path',oldjoin.count('facts.joinChecks = ')==1 and block(old,'fileprivate func p08Construct'+profile+'Host(').count('facts.completed = ')==3 and actual.count('return P08BodyResult(checks: 1,')==3)
        call=oldjoin.split('    facts.joinChecks = ')[1].replace('report: assembly.report','report: report')
        expectedjoin='    let expected = counterJoinSnapshot(control), foreignExpected = counterJoinSnapshot(foreignControl)\n    return '+call
        need(profile+' complete original two snapshots/check args/order once',compact(block(new,'fileprivate func p08Check'+profile+'HostJoins('))==compact(expectedjoin))
        need(profile+' original borrowing/lifetime operation helpers unchanged',block(old,'fileprivate mutating func p08UseOriginal'+profile+'Host(')==block(new,'fileprivate mutating func p08UseOriginal'+profile+'Host(') and block(old,'fileprivate mutating func p08FinishOriginal'+profile+'Host(')==block(new,'fileprivate mutating func p08FinishOriginal'+profile+'Host('))
    # Original field lending: reverse only aliases and pure fact projection.
    current=block(new,'fileprivate mutating func withStorage<')
    prepared_start=current.index('        let prepared = prepareSession()');prepared_end=current.index('        let result: Result',prepared_start)
    original=block(old,'fileprivate mutating func withStorage<')
    entry_start=original.index('        let regions = inventory;');entry_end=original.index('        let result: Result',entry_start)
    current=current[:prepared_start]+original[entry_start:entry_end]+current[prepared_end:]
    current=current.replace('switch slots {','switch physical {')
    for field in IDS:
        current=re.sub(r'            let '+field+r'Slot = s\.'+field+r'\n','',current)
        current=current.replace(field+'Slot.withBorrow','s.'+field+'.withBorrow')
        current=current.replace('== '+field+'Address','== entry(.'+field+').address')
    current=current.replace('precondition(UInt(bitPattern: c0) == entry(.c0).address)','for pair in [(c0, P08PhysicalID.c0)] { precondition(UInt(bitPattern: pair.0) == entry(pair.1).address) }')
    for field in BANKS:current=current.replace(field+'Entry: '+field+'Entry',field+'Entry: entry(.'+field+')')
    need('whole original14/9 loans/address checks/token/capacity/body/idle after inverse',compact(current)==compact(original))
    expected_lookup=block(original,'func entry(_ id:').replace('regions[index]','inventory[index]')
    need('cold lookup returns complete entry from same actual owner inventory',compact(block(new,'private borrowing func sessionEntry('))==compact(expected_lookup))
    prepare=block(new,'private borrowing func prepareSession(')
    static=prepare.split('case .static:')[1].split('#if')[0]
    dynamic=prepare.split('case .dynamic:')[1].split('#endif')[0]
    read=lambda t: re.findall(r'addresses\[(\d+)\] = sessionEntry\(\.(\w+)\)\.address',t)
    need('Static14 exact original entry ID/index map',read(static)==[(str(i),n) for i,n in enumerate(IDS)])
    need('Dynamic9 exact original entries; absent Static regions unused',read(dynamic)==[(str(i),n) for i,n in enumerate(IDS) if i in [4,5,7,8,9,10,11,12,13]])
    for i,field in enumerate(IDS):need('owned original address projection '+field,field+'Address: addresses['+str(i)+']' in prepare)
    for field in BANKS:need('complete original bank entry '+field,field+'Entry: sessionEntry(.'+field+')' in prepare)
    need('original five capacities, no guessed entries', 'configuration: capacities)' in prepare and '.init(repeating: 0)' in prepare)
    storage=block(new,'fileprivate mutating func withStorage<')
    nested=block(storage, 'result = b0Slot.withBorrow') + block(storage, 'result = g0Slot.withBorrow')
    need('loan callbacks capture neither preparation/inventory nor whole slot selection',not re.search(r'\b(?:prepared|regions|physical|s)\.',nested))
    # Plan ownership and loan phases.
    need('plan owns only exact original values',compact(block(new,'fileprivate struct P08HostRunFacts'))==compact('let limits: RuntimeProfileLimits\nlet audit: RuntimeStorageAudit\nlet assembly: CounterHostAssembly'))
    installer=block(new,'fileprivate func p08InstallEmbeddedHostPlan(')
    need('cold view before original case writes/checks before write before audit',installer.index('let view = p08MetadataOuterView(outer)')<installer.index('switch plan')<installer.index('if let write')<installer.index('p08PrepareStaticHost'))
    need('Embedded plan contains same actual validated view/audit/assembly','let (audit, assembly) = p08PrepareStaticHost(outer: view, owner: &owner)' in installer and 'outer.hostPlan = .init(limits: view.limits, audit: audit, assembly: assembly)' in installer)
    need('Embedded plan configures actual original control','view.control.pointee.terminalRetry = scenario == 2' in installer and 'view.control.pointee.idleQuiesceMode = scenario >= 3 ? scenario - 1 : 0' in installer and 'if let write { view.control.pointee.backend.write = write }' in installer)
    for predicate in ['scenario == 2','scenario >= 3 ? scenario - 1 : 0','early >= 1 && early <= 5','raw <= 10']:
        need('original metadata case predicate '+predicate,predicate in installer)
    one=block(new,'fileprivate func p08RunOneMetadataHost(')
    install=one.index('p08InstallEmbeddedHostPlan(');loan=one.index('facts: &outer.hostPlan!');clear=one.index('p08ClearHostPlan(&outer.hostPlan)')
    need('whole-outer install ends before actual plan field loan; clear follows return',install<one.index('let root = outer.root')<loan<clear)
    projected=['root','semantic','canvas','control','records','paths','payloads','scalars','entries']
    for field in projected:need('actual original projected '+field,field+' = outer.'+field in one[:loan])
    for label,actual in [('rootStorage','root'),('semanticStorage','semantic'),('canvasStorage','canvas'),('control','control'),('reuse','transcript'),('baseline','before'),('foreignRootStorage','foreignRoot'),('foreignControlStorage','foreignControl')]:
        need('Embedded prepared same actual '+label,label+': '+actual in one)
    for label,actual,count in [('recordsBacking','records',128),('pathsBacking','paths',384),('payloadsBacking','payloads',256),('scalarsBacking','scalars',128),('entriesBacking','entries',1)]:
        need('Embedded complete original buffer '+label,label+': .init(start: '+actual+', count: '+str(count)+')' in one)
    for option in ['failAfterRuntime = scenario == 1; early = 0; candidateFailure = nil','failAfterRuntime = false; early = value; candidateFailure = nil','failAfterRuntime = false; early = 0; candidateFailure = RuntimeCompletePipelineStage(rawValue: raw)!']:
        need('Embedded original case option '+option,option in one)
    during=one[loan:clear]
    need('no whole-outer access/capture during plan loan',re.findall(r'outer\.(\w+)',during)==['hostPlan'])
    need('clear only owned field after complete runner',compact(block(new,'fileprivate func p08ClearHostPlan('))==compact('let installed = facts != nil; precondition(installed)\nfacts = nil'))
    host=block(new,'fileprivate func p08RunMetadataHost(')
    need('all Embedded host cases share actual plan route', 'p08RunOneMetadataHost(owner: &owner, outer: &outer, before: nil, transcript: nil,' in host and 'write: write, plan: plan)' in host)
    need('outer begins nil and destruction requires ended plan','var hostPlan: P08HostRunFacts? = nil' in new and 'let planningEnded = hostPlan == nil; precondition(planningEnded)' in new)
    need('actual owned planning storage ledger both profiles exactly once',new.count('MemoryLayout<P08HostRunFacts?>.stride, family: 24)')==2)
    # Whole-file inverse mask: every other byte/token remains the old implementation.
    changed=['fileprivate mutating func withStorage<', 'fileprivate func runP08StaticHost(', 'fileprivate func runP08DynamicHost(', 'fileprivate func p08RunStaticSessionPhase(', 'fileprivate func p08RunDynamicSessionPhase(', 'fileprivate func p08RunOneMetadataHost(', 'fileprivate func p08RunMetadataHost(']
    left,right=old,new
    for anchor in changed:
        for side in ['left','right']:
            value=left if side=='left' else right;a,b,c=span(value,anchor);value=value[:a]+'<'+anchor+'>'+value[c:]
            if side=='left':left=value
            else:right=value
    for profile in ['Static','Dynamic']:
        left=without(left,'fileprivate func p08Construct'+profile+'Host(')
        for name in ['p08Check'+profile+'HostJoins','p08Install'+profile+'HostPlan','p08RunPrepared'+profile+'Host']:
            right=without(right,'fileprivate func '+name+'(')
    left=without(left,'fileprivate struct P08HostConstructionFacts')
    left=left.replace('// No capability or scoped owner is retained in construction completion facts.','')
    for anchor in ['private borrowing func sessionEntry(', 'private borrowing func prepareSession(', 'fileprivate struct P08SessionPreparation', 'fileprivate struct P08HostRunFacts', 'fileprivate func p08ClearHostPlan(', 'fileprivate func p08InstallEmbeddedHostPlan(']:right=without(right,anchor)
    right=right.replace('// Ordinary owned validation facts; no scope, pointer, callback or mutable backend.','')
    right=re.sub(r'extension P08TypedBackingOwner\s*\{\s*\}', '', right)
    right=right.replace('    var hostPlan: P08HostRunFacts? = nil\n','').replace('        let planningEnded = hostPlan == nil; precondition(planningEnded)\n','').replace(' + MemoryLayout<P08HostRunFacts?>.stride','')
    need('whole fixture outside finite reviewed cones exactly unchanged',compact(left)==compact(right))
    return checks


if __name__ == '__main__':
    source=pathlib.Path(PATH).read_text();checks=verify(source)
    mutations=[
        ('wrong Static original address',source.replace('addresses[0] = sessionEntry(.b0)', 'addresses[0] = sessionEntry(.b1)',1)),
        ('fabricated Dynamic region',source.replace('case .dynamic:\n            addresses[4]', 'case .dynamic:\n            addresses[0] = sessionEntry(.b0).address\n            addresses[4]',1)),
        ('wrong complete bank entry',source.replace('c0Entry: sessionEntry(.c0)', 'c0Entry: sessionEntry(.h0)',1)),
        ('forged original entry',source.replace('if let entry = inventory[index], entry.id == id { return entry }', 'if let entry = inventory[index], entry.id == id { return inventory[0]! }',1)),
        ('stale plan before runner return',source.replace('    let checks = p08RunPreparedStaticHost(owner: &owner, facts: &outer.hostPlan!,','    p08ClearHostPlan(&outer.hostPlan)\n    let checks = p08RunPreparedStaticHost(owner: &owner, facts: &outer.hostPlan!,',1)),
        ('plan capability',source.replace('let audit: RuntimeStorageAudit\n    let assembly:', 'let audit: UnsafeMutablePointer<CounterControl>\n    let assembly:',1)),
        ('omitted join snapshot field',source.replace('let expected = counterJoinSnapshot(control), foreignExpected = counterJoinSnapshot(foreignControl)', 'let expected = counterJoinSnapshot(control), foreignExpected = expected',1)),
        ('wrong early3 cleanup',source.replace('p08FinishStaticOwner(&owner)\n        return', 'p08FinishDynamicOwner(&owner)\n        return',1)),
        ('weaker prepared callback',source.replace('audit: facts.audit, assembly: facts.assembly, foreignModels:', 'audit: facts.audit, assembly: facts.assembly, foreignModels: models, ignoredForeignModels:',1)),
        ('wrong prepared actual root',source.replace('rootStorage: root, semanticStorage: semantic, canvasStorage: canvas,','rootStorage: foreignRoot, semanticStorage: semantic, canvasStorage: canvas,',1)),
    ]
    for name,mutated in mutations:
        assert mutated!=source,name
        try:verify(mutated)
        except (AssertionError,ValueError):pass
        else:raise AssertionError('undetected mutation: '+name)
    print(json.dumps({'kind':'compiler-free-constructor-caller-source-parity','baseline':BASE,'checks_passed':len(checks),'checks':checks,'negative_mutations_rejected':[n for n,_ in mutations],'compiler_or_runtime':False},indent=2))
