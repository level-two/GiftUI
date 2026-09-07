# SPEC-009 Reservation Ordering Evidence

Plan task: `SPEC-009 T2.2`

A fixture-owned finite transcript proves the exact irreversible-boundary
order without introducing production coordinator storage:

```text
cycle reservation
  -> replacement action-generation reservations
  -> semantic-revision reservation and publication
  -> candidate-frame reservation
  -> presentation-revision reservation
  -> offer
  -> commit or abort/retirement
```

Focused tests prove an accepted candidate commits only the reserved
presentation revision; a refused candidate records the action, candidate, and
presentation values as permanently retired; and the next cycle receives the
exact successors rather than reusing any aborted value. Exhaustion before
publication produces no semantic revision. Candidate or presentation
exhaustion after publication preserves that publication, makes no offer, and
aborts only a candidate that was actually allocated. Cycle exhaustion retains
the idle context boundary.

All recorded values are finite typed identities. The transcript contains no
sentinel, pointer, persistent identity, profile-private identity, semantic
graph, action payload, frame payload, or replay storage.

Reproduce from the repository root:

```text
swift test --filter IdentityReservationOrderingTests
```
