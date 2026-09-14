# SPEC-011 T7.3 Profile Workspace Audit

Date: 2026-09-14

The production Dynamic and Static Interaction stores run one common
`InteractionState` algorithm. A differential test gives both profiles equal
two-action/two-hit limits and compares the complete normalized result of:
beginning a candidate, accepting the exact limit, rejecting first excess,
discard/reset, assigning two generations, finishing, atomic commit, committed
record lookup, and topmost gesture resolution. The transcripts are equal.

`RuntimeProfileLimits` and startup validation jointly require Semantic action
occurrences to fit Interaction actions, Interaction hit regions to fit actions,
and Interaction actions to fit Execution committed actions. The storage audit
tracks candidate and committed bytes separately, while SPEC-009 owns bounded
source/capture capacity. Invalid relations fail before client attachment or
normal execution.

```sh
source scripts/lib/swiftpm.sh
giftui_swiftpm --package-path "$PWD" --cache-root "$PWD/.build/codex-cache" \
  --disable-sandbox -- test --filter \
  GiftUIRuntimeConformanceTests.dynamicAndStaticInteractionStorageProduceEqualBoundedTranscripts
```
