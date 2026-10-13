import P08Shadow

typealias Wrapped = InteractionOwnedKeyState<ScopedCandidate, ScopedCommitted, ScopedHit>

@inline(never)
@_lifetime(copy bank0, copy bank1, copy bank2, copy bank3, copy bank4)
func returnLive(_ bank0: Span<UInt64>, _ bank1: Span<UInt64>,
                _ bank2: Span<UInt64>, _ bank3: Span<UInt64>,
                _ bank4: Span<UInt64>) -> Wrapped? {
    let state = InteractionState(candidateRecords: ScopedCandidate(bank0),
        candidateHitRegions: ScopedHit(bank1), candidateCommittedRecords: ScopedCommitted(bank2),
        committedRecords: ScopedCommitted(bank3), committedHitRegions: ScopedHit(bank4))
    return Wrapped(state: state, maximumComponentsPerKey: 1, maximumComponents: 1)
}

@inline(never) public func positive(_ seed: UInt64) -> UInt64 {
    let bank0 = InlineArray<1, UInt64>(repeating: seed)
    let bank1 = InlineArray<1, UInt64>(repeating: seed &+ 1)
    let bank2 = InlineArray<1, UInt64>(repeating: seed &+ 2)
    let bank3 = InlineArray<1, UInt64>(repeating: seed &+ 3)
    let bank4 = InlineArray<1, UInt64>(repeating: seed &+ 4)
    let returned = returnLive(bank0.span, bank1.span, bank2.span, bank3.span, bank4.span)!
    return returned.probe()
}
