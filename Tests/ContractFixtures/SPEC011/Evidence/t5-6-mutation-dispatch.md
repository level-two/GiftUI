# SPEC-011 T5.6 Mutation-Phase Dispatch Evidence

`GiftUIExecution` now owns a bounded, one-shot mutation batch over a generic
sealed view. It accepts only profile-declared state-change, completion, and
semantic-action counts, runs only in `.mutating`, and applies those categories
in contract order. Runtime Core's mutation owner forwards semantic actions to
the Interaction dispatcher while preserving the first focused dispatch
failure for the later SPEC-011 failure adapter.

The focused integration fixture proves:

- state-change facts precede completion facts, which precede actions;
- admitted actions retain pointer order and dispatch at most once;
- each typed handler call is synchronous, and its observable change report is
  recorded before the handler returns;
- two reports coalesce into one dirty transition and one wake; and
- repository callbacks enqueue bounded state-change facts without entering the
  active sealed batch, then apply in producer order through a later batch.

Reproduce with:

```sh
swift test --filter RuntimeInteractionMutationOwnerTests
swift test --filter RecordingMutationBatchTests
```
