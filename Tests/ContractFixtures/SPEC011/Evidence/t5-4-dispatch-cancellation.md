# SPEC-011 T5.4 Dispatch Cancellation Evidence

The Runtime Core dispatcher tests cover missing committed records, changed
action generations, disabled records, changed target generations, and a target
that disappears between the initial generation read and the nonescaping model
borrow. Every ordinary invalidation returns `cancelled`, invokes no handler,
and neither falls back to nor searches for another model.

An invalid action code in a committed record returns
`failure(.invariantViolation)` before any model borrow. The Interaction action
validation tests separately prove that wrong-domain and non-total candidate
values are discarded before append or offer, so they cannot reach a handler.

Reproduce with:

```sh
swift test --filter RuntimeInteractionDispatcherTests
swift test --filter InteractionValueTests
```
