# Failure Precedence and Atomic Lifecycle Evidence

The constructible precedence test layers every later fault beneath each earlier
one: active reentry over all input faults, invalid input over capacity/resource/
sink/invariant faults, capacity over resource/sink/invariant faults, resource
incompatibility over sink/invariant faults, and begin refusal over a late
snapshot invariant. This establishes every constructible pair in the closed
order. All before-begin results have zero operation and discard calls.

The sink-refusal matrix injects every post-begin call from fill through finish;
each becomes `invariantViolation`, discards once, resets once, and clears the
foreground stack. Root and scoped foreground push refusal plus scoped and root
pop refusal cover the amended workspace failure boundaries. Existing recording
storage tests prove discard clears only staged output and preserves prior
current output.

The source audit counts all three checked-intersection calls and their three
defensive arithmetic branches without forging an invalid rectangle. It also
checks the direct `.arithmeticOverflow` to SPEC-003 mapping.

Run:

```sh
swift test --filter constructibleFailurePrecedenceFollowsTheExactClosedOrder
swift test --filter everyPostBeginSinkAndForegroundRefusalDiscardsOnceAndResets
scripts/contracts/check-spec-008-failure-precedence.rb
```
