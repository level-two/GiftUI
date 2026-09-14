# Bounded presentation recovery

`HostPresentationRecovery` joins the approved SPEC-009 pending-intent value to
SPEC-015's fixed three-refusal host policy. Backpressure preserves the current
count, retryable refusals expose pre-increment ordinals zero and one, and the
third refusal clears the intent, marks presentation unavailable, and quiesces
presentation-coupled input. No fourth offer can be represented.

A newer semantic revision supersedes the former intent and resets its refusal
count in one fixed-size slot. Acceptance clears only a matching revision.
Non-retryable refusal terminates immediately. The production state contains
only `PresentationPendingIntent`, availability, eligibility, and the immutable
limit; its measured stride remains at most 16 bytes. It retains no frame,
fact, action, Canvas closure, Drawing plan, operation stream, or endpoint
payload, so recovery cannot replay admitted work or refused payloads.

Each transition records the exact completed mandatory effects and host policy
context consumed by `HostResidualFailureRouting`.

Reproduction:

```sh
scripts/format-swift.sh
swift test --filter HostPresentationRecovery
```
