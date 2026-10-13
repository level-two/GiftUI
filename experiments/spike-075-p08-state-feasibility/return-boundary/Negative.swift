import P08Shadow

typealias Wrapped = InteractionOwnedKeyState<ScopedCandidate, ScopedCommitted, ScopedHit>

@inline(never)
@_lifetime(copy anchor)
func returnLocal(_ anchor: Span<UInt64>, _ seed: UInt64) -> Wrapped? {
    let bank0 = InlineArray<1, UInt64>(repeating: seed)
    let state = InteractionState(candidateRecords: ScopedCandidate(bank0.span),
        candidateHitRegions: ScopedHit(anchor), candidateCommittedRecords: ScopedCommitted(anchor),
        committedRecords: ScopedCommitted(anchor), committedHitRegions: ScopedHit(anchor))
    return Wrapped(state: state, maximumComponentsPerKey: 1, maximumComponents: 1)
}

@inline(never) public func negative(_ seed: UInt64) -> UInt64 {
    let anchor = InlineArray<1, UInt64>(repeating: seed &+ 1)
    let returned = returnLocal(anchor.span, seed)!
    return returned.probe()
}
