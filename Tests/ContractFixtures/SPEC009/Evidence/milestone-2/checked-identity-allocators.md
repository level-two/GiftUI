# SPEC-009 Checked Identity Allocator Evidence

Plan task: `SPEC-009 T2.1`

Five distinct package-scoped allocators own run-cycle, semantic-revision,
candidate-frame, presentation-revision, and runtime-wide action-generation
reservations. They share only a private finite checked cursor. Each begins at
raw zero, returns the exact successor, permits `UInt32.max` as the final valid
identity, and enters permanent exhaustion when no successor can be formed.
No raw identity is a sentinel.

Focused tests prove zero/one allocation, independent namespaces, the maximum
boundary, repeated post-exhaustion refusal, `Equatable` and `Sendable`
behavior, and caller normalization to `.execution(.identityExhausted)`.
The exhaustion seed is internal test access rather than package SPI.
`ObservableTargetGeneration` intentionally has no allocator in Execution;
SPEC-010 retains that ownership.

Reproduce from the repository root:

```text
swift test --filter IdentityAllocatorTests
scripts/contracts/check-spec-009-identity-allocators.rb
```
