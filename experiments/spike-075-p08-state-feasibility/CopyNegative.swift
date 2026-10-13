import P08Shadow

typealias OwnedState = InteractionState<OwnedCandidate, OwnedCommitted, OwnedHit>
typealias OwnedWrapped = InteractionOwnedKeyState<OwnedCandidate, OwnedCommitted, OwnedHit>
typealias ScopedWrapped = InteractionOwnedKeyState<ScopedCandidate, ScopedCommitted, ScopedHit>

@inline(never) func consumeWrapped(_ value: consuming ScopedWrapped) -> UInt64 { value.probe() }

@inline(never) func requireCopy<T: Copyable>(_ value: T) -> UInt64 { 1 }
@inline(never) public func copyRejected(_ seed: UInt64) -> UInt64 {
    let bank0 = InlineArray<1, UInt64>(repeating: seed)
    let bank1 = InlineArray<1, UInt64>(repeating: seed &+ 1)
    let bank2 = InlineArray<1, UInt64>(repeating: seed &+ 2)
    let bank3 = InlineArray<1, UInt64>(repeating: seed &+ 3)
    let bank4 = InlineArray<1, UInt64>(repeating: seed &+ 4)
    let state = InteractionState(candidateRecords: ScopedCandidate(bank0.span),
        candidateHitRegions: ScopedHit(bank1.span), candidateCommittedRecords: ScopedCommitted(bank2.span),
        committedRecords: ScopedCommitted(bank3.span), committedHitRegions: ScopedHit(bank4.span))
    let wrapped = InteractionOwnedKeyState(state: state, maximumComponentsPerKey: 1, maximumComponents: 1)!
    return requireCopy(wrapped) &+ consumeWrapped(wrapped)
}
