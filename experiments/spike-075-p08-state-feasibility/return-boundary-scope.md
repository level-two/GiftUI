# Final SPIKE-075 control pair — 2026-10-13

Eugene accepted the two-check function-return proposal with the explicit direction
to keep this work scoped and avoid indefinite iterations. This is the final
experiment package in this task. After its result, stop and report; do not
propose or start an automatic successor experiment.

## Fixed scope

- One positive/negative native control pair. Positive: return the existing
  wrapped state from five caller-owned spans with the full declared lifetime
  union. Negative: attempt to return it with candidate bank zero backed by a
  local InlineArray inside the returning function, while the other banks use a
  caller-owned anchor. Keep RFC declarations and the compiled shadow module fixed.
- At most two native object compilations and one compiler identity query, five
  minutes from the first invocation, no repairs. Stop on the first unexpected
  result. No target matrix, linking, execution or production edits.
- Verify saved native module artifacts, original sources and compiler/configuration
  hashes before reuse. Missing/mismatched inputs stop without rebuilding.
- Review the pair statically before execution. Preserve commands, snapshots,
  diagnostics and receipts. Cumulative ceiling: seven experiments, three identity
  queries, one previously authorized helper correction and no new repair rounds.
- Commit scope, reviewed fixture, evidence and final disposition separately.

## Completion rule

If the positive compiles and the negative is rejected for the local-owner return,
record only that bounded native result. If either is unexpected, preserve it as
inconclusive or failed according to the evidence. Neither outcome authorizes more
experiments, RFC acceptance, production migration or a compiler workaround.
Conclude the task with remaining limitations and a recommendation based on the
evidence already available. Historical repair limits and failed runs stay intact.
