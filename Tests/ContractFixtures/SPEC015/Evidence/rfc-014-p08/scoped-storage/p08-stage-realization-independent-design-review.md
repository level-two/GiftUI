# P08 typed stage realization — independent Strong design review

**DESIGN PASS at `8bc9c9a4`; safe to implement within the recorded activity.**
Review of the [design](../../../../../../docs/implementation-designs/spec-015-p08-typed-stage-realization.md),
[current source](../../../RuntimeDerived/CounterScopedStorage.swift) at `9cac6bfa`
and SPEC-015 S15.1/S15.2 finds no contract or scope blocker. This is an internal
realization assessment, not compiler acceptance, measured savings, fit or full
conformance. No source, compiler, test, image or runtime action was performed.

The required CounterHostState inert/active/retired representation and lifetime
union remain unchanged. P08BodyStage/Cleanup are private fixture orchestration,
not the mandated state. Replacing their take/switch/reinsert envelope with concrete
consuming functions does not remove the actual supplied→pipeline→coordinator→host→
retirement chain. The root retains original model/root lenders and activation
backing while helpers consume only the existing scoped projections/carriers;
owned completion flags cannot carry capabilities out. This is plausible with
existing ownership operations, but unsupported lifetime syntax or consumed captures
must fail source/compiler review rather than justify an unchecked workaround.

The proposed cleanup matches current source at 1939–1972: early 1 resets session;
early 2 consumes inert storage into retirement and resets; early 3 runs all eight
owner hooks; early 4 and all later host returns run host teardown and step-eight
assertion. Early 3 must stay before rejected-binding joins, exactly as current
1987–1989; early 4 stays before activation. Host defer may capture only the mutable
host that is never subsequently consumed. Common completion follows that defer,
uses the original constructed/activation flags and preserves every finish assertion
and one producer-origin retirement. Retain model/root/activation lenders until
that completion; no direct early return may bypass it. Reuse's existing teardown
plus the host defer preserves the second, idempotent teardown.

Reuse decomposition keeps the admission's original creation and instance, one
complete stale fingerprint/model baseline across all stale groups, comparisons
after each original operation and both stale action controls. The original action
capture, down/up cycle counts, sealed/mutating dispatch correlation and exactly
one model/bridge effect remain mandatory. All 26 labels, positive twins, actual
retained producers, identity collisions, transcript end and backing-last destruction
remain. Sequential helper boundaries introduce no new authority or retained scope.

Keeping namespace issuance and loops in the root while factoring concrete case
bodies preserves the fault, prefix, surplus, invalid-capacity and early/failure
corpus. Exact assertion/count/order equivalence must be checked against the source
diff, not inferred from a smaller function. Physical IDs, slots, layout and full
128,000-byte backing charge remain. Charge new caller frames, consumed argument
homes, complete snapshots, cleanup/destructors and all required live ancestor
frames; no assumed elision, tail calls or noninline saving closes stack fit.

The early current nRF module/layout screen is a rejection diagnostic only. The
202 omitted controls and native runtime/exclusivity/Static/Dynamic behavior remain
unproved until current validation. Full current collection remains an image
prerequisite; linked path/IRQ/ABI/allocator/RAM/flash and independent exit duties
are preserved. Seven new metadata-only component qualifications must recheck exact
argv exclusions and receipt/artifact identities; no changed compiled input is reused.

Proceed to the grouped initial source candidate and independent source review
under [the existing authorization](p08-stage-realization-activity.md). Corrections
remain **0/2**, with the two-consecutive-unproductive guard; all older allowances
stay closed. No further contract decision is required for this design. If the
required state itself still prevents fit, report that evidence before proposing
any representation or limit change. P08/R07/T8.1/HC-RD-003 remain open.
