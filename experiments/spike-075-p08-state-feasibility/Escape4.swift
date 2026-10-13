import P08Shadow

typealias OwnedState = InteractionState<OwnedCandidate, OwnedCommitted, OwnedHit>
typealias OwnedWrapped = InteractionOwnedKeyState<OwnedCandidate, OwnedCommitted, OwnedHit>
typealias ScopedWrapped = InteractionOwnedKeyState<ScopedCandidate, ScopedCommitted, ScopedHit>

@inline(never) func consumeWrapped(_ value: consuming ScopedWrapped) -> UInt64 { value.probe() }
@inline(never) public func escape4(_ seed: UInt64) -> UInt64 {
    let bank0 = InlineArray<1, UInt64>(repeating: seed &+ 0)
    let bank1 = InlineArray<1, UInt64>(repeating: seed &+ 1)
    let bank2 = InlineArray<1, UInt64>(repeating: seed &+ 2)
    let bank3 = InlineArray<1, UInt64>(repeating: seed &+ 3)
    var escaped: ScopedWrapped? = nil
    do {
        let bank4 = InlineArray<1, UInt64>(repeating: seed &+ 4)
        let state = InteractionState(candidateRecords: ScopedCandidate(bank0.span),
            candidateHitRegions: ScopedHit(bank1.span), candidateCommittedRecords: ScopedCommitted(bank2.span),
            committedRecords: ScopedCommitted(bank3.span), committedHitRegions: ScopedHit(bank4.span))
        escaped = InteractionOwnedKeyState(state: state, maximumComponentsPerKey: 1, maximumComponents: 1)
    }
    return consumeWrapped(escaped.take()!)
}
