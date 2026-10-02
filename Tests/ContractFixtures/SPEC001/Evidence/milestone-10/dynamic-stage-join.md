# T10.5 Dynamic production stage join — first increment

The Pi live owner conforms to the canonical `RuntimeCompletePipelineOwner` and
calls `RuntimeCompletePipeline.run`; its input coordinator no longer sequences
application mutation and presentation. The exact production application sum from
SPEC-013 T9 survives the result and detecting context.

Validation on 2026-10-02:

- `scripts/format-swift.sh` completed.
- `swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE --filter 'SignalAnalyzerDynamicSemanticJoinTests|dynamicPi'` passed 28 tests, including the reference acquisition workload.
- `swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE --filter 'dynamicProduction|dynamicDerivationFailure|dynamicPi|rawFramebufferTouches'` passed 21 tests, including 11 raw touch scenarios, six injected focused production stages, and partial fact application followed by an exact capture revision mismatch.
- Fault tests retain the previous accepted routing, report dirty/wake after applied mutation, finalize once, discard the rest of the sealed batch, and recompute from current state with zero replayed facts.

An initial ad hoc test invocation omitted the required Dynamic profile define;
Canvas intentionally has no Dynamic callable in that configuration. The commands
above are the corrected profile evidence. Temporary tracing was removed.

This increment does not complete T10.5. Exact production normalization and
mandatory-effect/policy handling, bounded refusal recovery, wake propagation,
ARMv6 build and final Pi rehearsal remain required. It provides no reviewed-pixel
or connected-hardware evidence.
