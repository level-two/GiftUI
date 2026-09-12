# SPEC-011 T5.2 Generation and Offer Evidence

The Runtime Core transaction uses SPEC-009's monotonic
`ActionGenerationAllocator` only for `.requiresGeneration` appends. An accepted
offer commits Interaction under the exact reserved `PresentationRevision`; all
refusal and failure dispositions discard the candidate and permanently retire
its already-consumed action generations.

Focused tests prove that a generation retired by refusal is never reused and
that generation exhaustion returns `ExecutionError.identityExhausted`,
discards Interaction and Observable State candidates, and cancels all pointer
captures before later work.

Reproduce with:

```sh
swift test --filter RuntimeInteractionCandidateTransactionTests
```
