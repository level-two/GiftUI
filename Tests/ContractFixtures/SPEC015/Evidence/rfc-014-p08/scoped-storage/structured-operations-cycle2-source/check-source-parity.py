#!/usr/bin/env python3
"""Invert only the reviewed finite extractions; exact whole-file operand/order parity."""
import json
import pathlib
import re
import subprocess

BASE = 'b4dc58ba'
DIRECTORY = pathlib.Path('Tests/ContractFixtures/SPEC015/RuntimeDerived')


def function(text, anchor):
    start = text.index('{', text.index(anchor)); depth = 1
    for end in range(start + 1, len(text)):
        depth += (text[end] == '{') - (text[end] == '}')
        if depth == 0:
            return text[start + 1:end], end + 1
    raise AssertionError(anchor)


def compact(text):
    return re.sub(r'\s+', '', text)


def verify(scope, pipeline):
    checks = []
    def require(name, value):
        assert value, name
        checks.append(name)
    restored = scope
    for profile in ['Static', 'Dynamic']:
        name = 'p08Construct' + profile + 'StorageSession'
        body, end = function(restored, 'fileprivate func ' + name)
        start = restored.index('// Construction returns before the active body;', 0, end)
        helper = restored[start:end]
        require(profile + ' exact token lifetime and no callback parameter', '@_lifetime(copy token)' in helper and 'token: borrowing P08SessionLifetime' in helper and '_ body:' not in helper)
        slots, _ = function(scope, 'fileprivate struct P08' + profile + 'Slots')
        for field, typ in re.findall(r'let (\w+): P08TypedSlot<([^\n]+)>', slots):
            require(profile + ' original typed pointer ' + field,
                    field + ': UnsafeMutablePointer<' + typ + '>' in helper)
        if profile == 'Static':
            for field in ['b0', 'b1', 'b2', 'b3']:
                require('Static original byte loan ' + field,
                        field + ': UnsafeMutableRawBufferPointer' in helper)
        for field, capacity, kind in [('c0', 0, 'Candidate'), ('h0', 1, 'Hit'), ('r0', 2, 'Committed'), ('r1', 3, 'Committed'), ('h1', 4, 'Hit')]:
            require(profile + ' original ' + field + ' role/capacity', 'descriptor: .' + profile.lower() + '(' + field + ', ' + field + 'Entry, configuration[' + str(capacity) + '])' in body and 'P08' + kind + 'Access.lend(sessionLifetime: token' in body)
            body = body.replace(field + 'Entry', 'entry(.' + field + ')')
        restored = restored[:start] + restored[end:]
        body = body.strip().replace('return P08StorageSession(', 'return body(P08StorageSession(') + ')'
        replacement = '\n'.join('                    ' + line.strip() for line in body.splitlines())
        expression = re.compile(r'                    return body\(' + name + r'\([^\n]+\)\)')
        match = expression.search(restored); require(profile + ' one direct inner original-body call', match is not None)
        call = match.group()
        fields = ['b0','b1','b2','b3','g0','g1','g2','g3','g4','c0','h0','r0','r1','h1'] if profile == 'Static' else ['g0','g1','g3','g4','c0','h0','r0','r1','h1']
        for field in fields:
            require(profile + ' original loan argument ' + field, field + ': ' + field in call)
        for field in ['c0','h0','r0','r1','h1']:
            require(profile + ' original entry ' + field, field + 'Entry: entry(.' + field + ')' in call)
        for field in ['configuration','transcript','ownerIdentity','sessionSerial']:
            require(profile + ' original scalar argument ' + field, field + ': ' + field in call)
        restored = expression.sub(lambda _: replacement, restored, count=1)
    # Remove only empty conditional/comment scaffolding left by extracted definitions.
    restored = restored.replace('#if !hasFeature(Embedded)\n\n#endif\n', '')
    body, end = function(restored, 'fileprivate func p08FinishMetadataTwoHosts(')
    start = restored.rindex('@inline(never)', 0, restored.index('fileprivate func p08FinishMetadataTwoHosts('))
    restored = restored[:start] + restored[end:]
    oldbody = body.replace('let checks = p08VerifyDestruction', 'checks += p08VerifyDestruction').strip()
    needle = '    return checks + p08FinishMetadataTwoHosts(owner: &owner, original: &original, control: control, transcript: transcript)'
    require('actual original owner/inventory finalizer once', restored.count(needle) == 1)
    restored = restored.replace(needle, '    ' + oldbody)
    oldscope = subprocess.check_output(['git', 'show', BASE + ':' + str(DIRECTORY / 'CounterScopedStorage.swift')], text=True)
    require('whole Scope original expressions/lenders/cases/cleanup/order after exact extraction inverse', compact(restored) == compact(oldscope))
    restored = pipeline
    for saved, actual in [('backend','backend'), ('root','runtimeRootIdentity'), ('action','runtimeActionIdentity'), ('candidateRoot','runtimeCandidateRootIdentity'), ('candidateAction','runtimeCandidateActionIdentity')]:
        cap = saved[0].upper() + saved[1:]; name = 'matches' + cap
        body, end = function(restored, 'private mutating func ' + name + '(')
        expected = saved + ' == ' + ('counterObserveBackend(control.pointee.backend)' if saved == 'backend' else 'control.pointee.' + actual)
        require('full original equality ' + saved, compact(body) == compact('let same = ' + expected + '\nreturn same'))
        start = restored.rindex('    @inline(never)', 0, restored.index('private mutating func ' + name + '('))
        restored = restored[:start] + restored[end:]
        needle = 'let same' + saved + ' = ' + name + '(control)'
        require('sequential equality dispatch once ' + saved, restored.count(needle) == 1)
        restored = restored.replace(needle, 'let same' + saved + ' = ' + expected)
    oldpipeline = subprocess.check_output(['git', 'show', BASE + ':' + str(DIRECTORY / 'CounterPipelineOwner.swift')], text=True)
    require('whole Pipeline exact fields/first-failure/full endpoint/backend/keys after inverse', compact(restored) == compact(oldpipeline))
    return checks


if __name__ == '__main__':
    scope = (DIRECTORY / 'CounterScopedStorage.swift').read_text(); pipeline = (DIRECTORY / 'CounterPipelineOwner.swift').read_text()
    checks = verify(scope, pipeline)
    mutations = [
        (scope.replace('@_lifetime(copy token)', '@_lifetime(borrow token)', 1), pipeline),
        (scope.replace('g0: UnsafeMutablePointer<StaticCounterLayoutWorkspace>', 'g0: UnsafeMutableRawPointer', 1), pipeline),
        (scope.replace('c0Entry, configuration[0]', 'c0Entry, configuration[1]', 1), pipeline),
        (scope.replace('g4: g4, c0:', 'g4: g3, c0:', 1), pipeline),
        (scope.replace('p08RequireSameInventory(owner.originalInventory(), original)', 'p08RequireSameInventory(original, original)', 1), pipeline),
        (scope.replace('owner.release()\n    precondition(transcript.pointee.hosts == 2)', 'precondition(transcript.pointee.hosts == 2)\n    owner.release()', 1), pipeline),
    ] + [(scope, pipeline.replace('let same = ' + key + ' ==', 'let same = nil ==', 1)) for key in ['backend','root','action','candidateRoot','candidateAction']]
    for index, pair in enumerate(mutations):
        assert pair != (scope, pipeline), index
        try: verify(*pair)
        except AssertionError: pass
        else: raise AssertionError('undetected mutation ' + str(index))
    print(json.dumps({'kind':'compiler-free-cycle2-exact-extraction-parity','baseline':BASE,'checks_passed':len(checks),'checks':checks,'negative_mutations_rejected':len(mutations),'compiler_or_runtime':False}, indent=2))
