# SPEC-013 T5.1-T5.5 Complete Production Pipeline

Date: 2026-09-13

`RuntimeCompletePipeline` is the one profile-neutral production-owner join for
the normative run cycle. It calls eleven explicitly named fallible boundaries
in order: admission/seal, admitted mutation, Observable mutation freeze,
Observable candidate plus Semantic expansion, Layout, Canvas invocation and
plan derivation, combined render preflight, Interaction candidate generation,
atomic Semantic/Observable publication, candidate allocation, and one-shot
offer/production. The boundary methods borrow the maintained focused owners;
the runner owns only orchestration, cleanup, disposition, and finalization.

`DynamicRuntimeProfileBinding` and `StaticRuntimeProfileBinding` both reject
the entry point outside an active storage attempt and otherwise delegate to
that same runner. Neither profile contains a second stage algorithm or result
vocabulary.

The focused corpus proves:

- accepted execution follows the exact eleven-stage transcript, commits the
  Interaction candidate under the returned presentation revision, resets
  attempt storage, and finalizes once;
- injected failure at every stage stops all later fallible work and runs only
  the acquired reverse-order cleanup obligations;
- Semantic, Layout, Observable State, Interaction, and Drawing values survive
  the generic failure carrier without collapsing;
- Drawing failure before publication releases/reset acquired attempt state,
  preserves applied mutation as dirty, requests paced semantic rederivation,
  and never commits routing;
- atomic changed and unchanged publication choose their exact semantic
  dispositions;
- no-change, backpressure, and retryable refusal remain distinct bounded
  operational results rather than collapsing into one completion value;
- backpressure preserves the published revision, discards candidate routing,
  resets render/plan/attempt state, and retains only pending presentation
  intent;
- postpublication nonretryable refusal preserves the published revision,
  discards candidate routing, clears presentation availability, and emits no
  dirty wake; and
- value-equal profile-neutral owners produce identical result, stage, cleanup,
  disposition, and finalization transcripts.

Reproduction:

```sh
scripts/format-swift.sh
source scripts/lib/swiftpm.sh
giftui_swiftpm \
  --package-path "$PWD" \
  --cache-root "$PWD/.build/codex-cache" \
  --disable-sandbox -- test --filter RuntimeCompletePipelineTests
```

This is host-executed focused integration evidence. It makes no cross-build,
resource-bound, timing, connected-display, or connected-board claim; those
remain assigned to SPEC-013 Milestones 6 through 8.
