# P08 typed-stage initial candidate — independent Strong source review

**SOURCE PASS at `8ae0fb1c`; ready for the initial registered nRF screen.**
Review of the [freeze](p08-stage-realization-source-freeze.md),
[manifest/diff](stage-realization-source/manifest.json) and
[reviewed design](../../../../../../docs/implementation-designs/spec-015-p08-typed-stage-realization.md)
finds no source blocker. Source-only readiness does not establish Swift compiler
acceptance, runtime correctness, stack savings or fit. No compiler, formatter,
test gate, build, image, runtime or hardware action was performed in this review.

Concrete Static/Dynamic session→supplied→owner→host functions consume the existing
exact carriers and return only Int/Bool completion facts. Original model/root
lenders and activation backing stay in runP08ScopedBody. No helper returns a
scope, borrows from a dying carrier, weakens a lifetime union or captures a value
that is later consumed. Mutable host defer captures the local host after its
initial move and thereafter uses only inout operations. Supported lifetime/codegen
acceptance remains for the actual screen; no obvious source type/receiver mismatch
was found. Required CounterHostState and all other Swift files remain unchanged.

Early 1 resets session, early 2 retires/reset inert supplied storage, early 3
performs the exact eight owner hooks before snapshots/joins, and early 4 tears
down without attempting activation. Both host phases preserve reuse, early-5,
candidate-failure and ordinary lifecycle branches and the original joins count.
Every normal result reaches p08CompleteBody after local cleanup; all original
conditional finish assertions and exactly one producer-origin retirement remain.
Reuse terminal teardown followed by the host defer preserves idempotency coverage.
Fatal guard/forced-factory paths retain their original behavior.

Reuse operations are ordered as before. The main action, admission and presentation
revision are observed at their original point, before stale operations. One full
stale fingerprint and model observation are borrowed through all reject groups;
five full comparisons remain. Independently compared complete precondition,
preconditionFailure, frame-check, fingerprint-comparison and label call multisets.
The exact current pointer/admission instance, retained producers, original captured
action, down-only zero actions, up/sealed mutating correlation and one model/bridge
effect are preserved. All 26 labels and same-address/two-host/transcript retirement
controls remain; no refreshed baseline or shortened fingerprint is introduced.

Embedded case helpers preserve each original operation and count; root namespaces,
issuance order, loops, selected backing, surplus/invalid extent and whole/prefix
fault bounds stay. Native reservation loops are unchanged. Physical/fingerprint,
outer/supplied, actual host routes and session-only/exclusivity source regions are
independently byte-identical. Capacity/layout/workload/toolchain/limits remain.
Live caller frames, consumed-value homes, full snapshots and cleanup still count.

Verified source SHA-256
`db3b91b9ab935043032ce3d3182dd384fca40b3d18f016d73820e62a24877e95`,
manifest `daf6ca9c9aac34cb295755386f31c361adde8f971a2dd9964493519d6dd035d2`,
qualification `3274499cf3d610307900b7e682c5ebc2e0ed3acaee4f71a29af96d48e9d8cf9f`,
glue hashes and decompressed exact diff against d7df2c80. Seven predecessor receipt
identities, original metadata and argv-derived counts/digests (53, 53, 112, 173,
173, 159, 172) verify; the changed source is excluded from every compilation argv.
Other four candidate-A source exclusions remain true. Driver changes only exact
path/activity pins; drift guards and registrations are unchanged. AST and pinned
384/202 compiler labels, native five-control inventories and 26 reuse labels verify.
The broader unchanged dependency-artifact ledger was not needlessly repeated.

Initial candidate **1**, corrections **0/2**, screens **0**. Proceed with the exact
screen command in the freeze, then inspect actual phase/case/reuse and live caller
frames before expensive validation. The partial screen cannot satisfy the full
current-collection prerequisite for images. All historical allowances remain
closed; P08/R07/T8.1/HC-RD-003 and complete acceptance/resource proof remain open.
