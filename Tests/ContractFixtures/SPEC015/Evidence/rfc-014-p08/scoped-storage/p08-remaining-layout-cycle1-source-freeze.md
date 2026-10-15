# P08 layout correction 1 source freeze — 2026-10-15

This coherent source correction consumes **cycle 1/2** under the existing
[remaining-completion activity](p08-remaining-completion-activity.md). The
[initial diagnosis](p08-remaining-layout-initial-diagnosis.md) and its exact
failure packet remain immutable. Two actual causes are identified and addressed;
corrected compiler folding and resource fit are pending, not passing evidence.

The Swift slot constant and C `[4][...]` reservation now both use the
target-disassembly-derived minimum **32000**. Four slots charge **128000 bytes**,
including any retained surplus: **7296 bytes** more than the provisional input.
All semantic capacities, 25 original regions, alignment, workload, guards,
compiler/flags and resource ceilings are unchanged. Other live uses continue
deriving route byte counts, checked slot spacing and the two-slot surplus extent
from the same Swift constant. The source-consistency test pins both new literals.

Inventory now requires exactly 129 global defined function roots and records
only the known local nonexported `giftui_p08_layout_limits_offsetTm` separately.
Unknown/duplicate/local/weak/undefined roots and any other prefixed helper remain
errors. The body decoder and relocation rejection are **unchanged**; recognizing
the helper cannot validate a root that calls it. Actual-object-shaped regressions
cover the observed local/function/Thumb helper, malformed/helper/root mutations,
and continued rejection of the original call body and relocation.

**52 compiler-free tests** pass (29 collector, 23 layout), along with Python AST,
exact manifest hashes, seven original qualification proofs, local links and
whitespace checks. `CounterScopedStorage.swift` is unchanged, so the existing
[exact metadata qualification](p08-remaining-layout-applicability.json) remains
current and is pinned again without rewriting it. Changed compiled backing/C
inputs and the extractor invalidate old counter/image evidence; no old compiled
result is reused. No compiler, build, target runtime, image, formatter or agent
was invoked for this source correction.

The [manifest](p08-remaining-layout-cycle1-source-manifest.json) pins current files,
the unchanged strict decoder, original failure and next recipe. Parent obtains
independent Strong source assessment, then runs the same fresh nRF focused
`so07-layout-facts` command once. All four full collections remain held. Surviving
thunks/calls/stack work, a different unknown helper or any nonconstant output
still fail closed; no additional decoder form or automatic variant is inferred.
Final layout/C-symbol evidence, complete retained code/RAM/flash and feasible
stack/IRQ proof, caller inventory and P08 acceptance remain open.
