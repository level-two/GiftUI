import P08Shadow

typealias OwnedState = InteractionState<OwnedCandidate, OwnedCommitted, OwnedHit>
typealias OwnedWrapped = InteractionOwnedKeyState<OwnedCandidate, OwnedCommitted, OwnedHit>
typealias ScopedWrapped = InteractionOwnedKeyState<ScopedCandidate, ScopedCommitted, ScopedHit>

@inline(never) func consumeWrapped(_ value: consuming ScopedWrapped) -> UInt64 { value.probe() }

struct OwnedStore { let state: OwnedState; let wrapped: OwnedWrapped }
@inline(never) func copiedState(_ state: OwnedState) -> OwnedState { state }
@inline(never) func copiedWrapper(_ state: OwnedWrapped) -> OwnedWrapped { state }
@inline(never) public func ownedCoverage(_ seed: UInt64) -> UInt64 {
    let state = OwnedState(candidateRecords: OwnedCandidate(seed), candidateHitRegions: OwnedHit(seed &+ 1),
        candidateCommittedRecords: OwnedCommitted(seed &+ 2), committedRecords: OwnedCommitted(seed &+ 3),
        committedHitRegions: OwnedHit(seed &+ 4))
    let returned = copiedState(state)
    let wrapped = OwnedWrapped(state: returned, maximumComponentsPerKey: 1, maximumComponents: 1)!
    let returnedWrapper = copiedWrapper(wrapped)
    let stored = OwnedStore(state: state, wrapped: wrapped)
    return returned.probe() &+ returnedWrapper.probe() &+ stored.state.probe() &+ stored.wrapped.probe()
}

@inline(never) public func twin0(_ seed: UInt64) -> UInt64 {
    let bank0 = InlineArray<1, UInt64>(repeating: seed &+ 0)
    let bank1 = InlineArray<1, UInt64>(repeating: seed &+ 1)
    let bank2 = InlineArray<1, UInt64>(repeating: seed &+ 2)
    let bank3 = InlineArray<1, UInt64>(repeating: seed &+ 3)
    let bank4 = InlineArray<1, UInt64>(repeating: seed &+ 4)
    var escaped: ScopedWrapped? = nil
    do {
        let state = InteractionState(candidateRecords: ScopedCandidate(bank0.span),
            candidateHitRegions: ScopedHit(bank1.span), candidateCommittedRecords: ScopedCommitted(bank2.span),
            committedRecords: ScopedCommitted(bank3.span), committedHitRegions: ScopedHit(bank4.span))
        escaped = InteractionOwnedKeyState(state: state, maximumComponentsPerKey: 1, maximumComponents: 1)
    }
    return consumeWrapped(escaped.take()!)
}
@inline(never) public func twin1(_ seed: UInt64) -> UInt64 {
    let bank0 = InlineArray<1, UInt64>(repeating: seed &+ 0)
    let bank1 = InlineArray<1, UInt64>(repeating: seed &+ 1)
    let bank2 = InlineArray<1, UInt64>(repeating: seed &+ 2)
    let bank3 = InlineArray<1, UInt64>(repeating: seed &+ 3)
    let bank4 = InlineArray<1, UInt64>(repeating: seed &+ 4)
    var escaped: ScopedWrapped? = nil
    do {
        let state = InteractionState(candidateRecords: ScopedCandidate(bank0.span),
            candidateHitRegions: ScopedHit(bank1.span), candidateCommittedRecords: ScopedCommitted(bank2.span),
            committedRecords: ScopedCommitted(bank3.span), committedHitRegions: ScopedHit(bank4.span))
        escaped = InteractionOwnedKeyState(state: state, maximumComponentsPerKey: 1, maximumComponents: 1)
    }
    return consumeWrapped(escaped.take()!)
}
@inline(never) public func twin2(_ seed: UInt64) -> UInt64 {
    let bank0 = InlineArray<1, UInt64>(repeating: seed &+ 0)
    let bank1 = InlineArray<1, UInt64>(repeating: seed &+ 1)
    let bank2 = InlineArray<1, UInt64>(repeating: seed &+ 2)
    let bank3 = InlineArray<1, UInt64>(repeating: seed &+ 3)
    let bank4 = InlineArray<1, UInt64>(repeating: seed &+ 4)
    var escaped: ScopedWrapped? = nil
    do {
        let state = InteractionState(candidateRecords: ScopedCandidate(bank0.span),
            candidateHitRegions: ScopedHit(bank1.span), candidateCommittedRecords: ScopedCommitted(bank2.span),
            committedRecords: ScopedCommitted(bank3.span), committedHitRegions: ScopedHit(bank4.span))
        escaped = InteractionOwnedKeyState(state: state, maximumComponentsPerKey: 1, maximumComponents: 1)
    }
    return consumeWrapped(escaped.take()!)
}
@inline(never) public func twin3(_ seed: UInt64) -> UInt64 {
    let bank0 = InlineArray<1, UInt64>(repeating: seed &+ 0)
    let bank1 = InlineArray<1, UInt64>(repeating: seed &+ 1)
    let bank2 = InlineArray<1, UInt64>(repeating: seed &+ 2)
    let bank3 = InlineArray<1, UInt64>(repeating: seed &+ 3)
    let bank4 = InlineArray<1, UInt64>(repeating: seed &+ 4)
    var escaped: ScopedWrapped? = nil
    do {
        let state = InteractionState(candidateRecords: ScopedCandidate(bank0.span),
            candidateHitRegions: ScopedHit(bank1.span), candidateCommittedRecords: ScopedCommitted(bank2.span),
            committedRecords: ScopedCommitted(bank3.span), committedHitRegions: ScopedHit(bank4.span))
        escaped = InteractionOwnedKeyState(state: state, maximumComponentsPerKey: 1, maximumComponents: 1)
    }
    return consumeWrapped(escaped.take()!)
}
@inline(never) public func twin4(_ seed: UInt64) -> UInt64 {
    let bank0 = InlineArray<1, UInt64>(repeating: seed &+ 0)
    let bank1 = InlineArray<1, UInt64>(repeating: seed &+ 1)
    let bank2 = InlineArray<1, UInt64>(repeating: seed &+ 2)
    let bank3 = InlineArray<1, UInt64>(repeating: seed &+ 3)
    let bank4 = InlineArray<1, UInt64>(repeating: seed &+ 4)
    var escaped: ScopedWrapped? = nil
    do {
        let state = InteractionState(candidateRecords: ScopedCandidate(bank0.span),
            candidateHitRegions: ScopedHit(bank1.span), candidateCommittedRecords: ScopedCommitted(bank2.span),
            committedRecords: ScopedCommitted(bank3.span), committedHitRegions: ScopedHit(bank4.span))
        escaped = InteractionOwnedKeyState(state: state, maximumComponentsPerKey: 1, maximumComponents: 1)
    }
    return consumeWrapped(escaped.take()!)
}
