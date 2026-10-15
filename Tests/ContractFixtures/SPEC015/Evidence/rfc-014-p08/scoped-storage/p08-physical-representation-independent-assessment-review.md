# P08 physical representation — independent assessment review

**Measured assessment PASS; control-slot proposal NOT READY FOR SOURCE until its
concrete ownership/exclusivity/reset design is completed.** Review of `4f35a030`
and the [assessment](../../../../../../docs/implementation-designs/spec-015-p08-physical-representation-assessment.md)
finds a credible private physical direction, not a proved fit or an inherently
required contract amendment. Complete the grouped design gaps below within this
assessment, then reassess it; do not start another blind implementation package.

Independently verified actual diagnostic object SHA-256
`28d5cda318d460ddc08d54c8a856b91316699d6fbd0b30a7cdab9ba04020348e`,
all recorded packet identities, exact four argv substitutions and original-source
plus accessor suffix. Re-read all **120** exact defined GLOBAL/FUNC/PROTECTED(3)
roots using the unchanged strict constant decoder; all complete proofs and all
40 ledger rows match. The decoder correction is exactly visibility 0→3, with no
body, relocation, alias or tail grammar change and no recompilation. One diagnostic
invocation is consumed; it is not an acceptance module, runtime or image result.

Pipeline 3,532; coordinator 3,860; state 3,889; owner 4,439; host/Optional host both
4,808; endpoint 1,868; each complete Optional identity 206; fingerprint 1,404 are
supported target sizes. Scoped geometry/bank accesses remain small descriptors.
Endpoint plus four identities is **2,692** data bytes; four retained slots add at
least **10,768** payload bytes before new packing. Neither member arithmetic nor
historical RAM+10,768 proves new slot layout, net stack savings or fit.

Authority does not mandate these five private pipeline fields' inline location.
[ADR-039 Decision](../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md#decision),
lines 56–84, requires final original typed regions, one owner/session, no duplicated
mutable authority, alias/reentry exclusion and complete structured cleanup.
[SPEC-013 S13.1/S13.2](../../../../../../docs/specs/spec-013-runtime-profiles.md#s131-physical-owner-session-and-coordinator-contract)
(lines 307–370) requires prefix unwind, idle/reset before reuse, structural/runtime
exclusivity and accounting for every control, padding and temporary.
[SPEC-015 S15.1](../../../../../../docs/specs/spec-015-host-configuration.md#s151-construction-transfers-and-retirement)
(lines 323–367) preserves scoped fields/unions, mandatory state cases, full owned
keys and reset order. **Inference:** enlarging one existing CounterControl typed
region with private owned payload is compatible in principle, provided these
conditions are proved. “Original inventory” is not permission for an untracked
second owner or an immutable 4,200-byte size promise.

**G01 — exact disjoint callback seams are required before source.** Moving endpoint
into control makes current offerAndProduce (CounterPipelineOwner.swift:526–537)
mutably access a stored endpoint while producer code touches streams/semantic/
geometry and endpoint/backend callbacks touch sibling control fields. Tiled offer
and target methods (CounterTiledRaster.swift:104–158, 216–225), native offer/target
methods (CounterNativeRaster.swift:237–249) and wake/admission operations must be
included in the borrow map. List actual lender, field, access kind and duration
for initialization, offer, finish/cancel, snapshot and reset. No whole-Control or
whole-payload inout may span a callback that reaccesses it. A new `_modify`, raw
pointer identity or absent runtime trap does not prove disjointness; no disabled
exclusivity/unsafe field projection is allowed. Retain whole-pipeline borrows only
where callback projections are structurally separate. Concrete native positive
and overlapping-access negatives must cover the actual new seam later.

**G02 — explicit slot ownership/disposition is required.** Define empty→installed→
quiesced→empty transitions and their exact responsible pipeline, for both current
constructors (198 and 630), including the trusted unbound owned coordinator route;
a nonnil selected producer origin cannot become a new universal prerequisite.
Reject duplicate installation without destroying another live slot. Inert and
pre-pipeline failures own no payload. Cover every failed activation/candidate,
repeated teardown, scoped retireQuiescedStorage (212), owned returnWorkspaces (657),
reconstruction and original control destruction. Both release routes must finish
endpoint work, release exactly their single payload and four complete keys, then
preserve semantic→geometry→Interaction reset/backing-last. No clear by an unrelated
or already-retired owner, no retention until eventual control destruction, and no
whole-Control copy/reconstruction while an active payload is authoritative.

**G03 — exact observation and physical deltas are required.** Keep candidate/current
root/action identities independently owned, full and distinct; never derive them
from a borrowed semantic bank, hash or accepted-frame recording. Name owned snapshot
fields for slot emptiness, all four keys and endpoint state/recording, retaining
lastFrame independently. Stale guards must reject before touching the new slot.
Update every fresh/empty/failure-prefix/destruction/zero-effect control and both
actual constructor paths. The next source design's minimal scope must allow
CounterTiledRaster.swift and CounterNativeRaster.swift if G01 needs callback seams;
CounterAdmission/WakeIntegration only if their concrete borrow graph requires a
change. Existing two-file scope is a proposal, not proof these edits are unnecessary.
No core coordinator, Interaction or mandated CounterHostState change is selected.
Measure actual enlarged control and all four slots/C reservation, including
Optional padding, alignment, setup/deinit temporaries, Dynamic retained/allocation
costs and complete feasible live stacks. Preserve all corpus/label/image gates.

Recommendation: complete this concrete original-control design first under the
assessment authorization. No ADR/Spec amendment is needed merely to document this
private layout choice. If safe realization instead needs a separate lender/owner,
escaping capability, weakened protocol/state case, key representation or limit,
present that exact change for the applicable upstream decision. This review grants
no implementation/repair allowance. Historical 2/2 is closed; diagnostic 1/1 used;
P08/R07/T8.1/HC-RD-003 and fit remain open/failed. No maintained source, compiler,
build, test, link, runtime, image or hardware action was performed in this review.
