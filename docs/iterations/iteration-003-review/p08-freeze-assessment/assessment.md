# Bounded P08 freeze assessment — 2026-11-08

## Decision

**Assessment complete; iteration-3 closure NOT READY. P08 remains FROZEN / UNMET.**
This is an evidence-only classification under the [approved freeze](../p08-freeze-and-certification-transfer.md),
not the independent acceptance of this assessment, a P08/SO-09 PASS, a repair
campaign or an implemented transition. No compiler, runtime test, target query,
deployment or flash ran. The assessment reuses the existing independently reviewed
Pi handoff and Native results; it does not independently re-prove their semantics.

The expensive old-composition stack/provider/launch certification is transferred.
The remaining technical stop is narrower: unresolved alias/lifetime/reentrancy and
callback-owner premises for affected shared mechanisms, plus retained framework
validation and closure-accounting gaps. No new demonstrated memory-safety defect
was established in this assessment. Unknown required premises still block use.

## Review inputs and reproducible integrity check

Run `python3 docs/iterations/iteration-003-review/p08-freeze-assessment/audit.py`
from the repository root to print the bounded audit. It hashes retained inputs
and declared artifacts, reads Git status inputs and emits JSON; it does not mutate
source or run a producer. The [captured audit](input-audit.json) pins review HEAD,
receipt hashes, compiler hashes, runtime/host prerequisite hashes, 129 modified or
untracked source/script/fixture-related paths and five primary review documents.
This is a current input inventory, not a clean source commit or a complete archive
of all untracked proof artifacts. Subsequent source changes require applicability
review. The script itself is review tooling, not a product test or proof solver.

| Collection | Recorded checks | Declared inputs verified | Artifact hashes and sizes verified | Reuse disposition |
| --- | ---: | ---: | ---: | --- |
| macOS Static `p08-counter-g8ocpi1a` | 466 | 202 | 956 | Retain finite native behavior/constraint evidence with its existing predicates |
| macOS Dynamic `p08-counter-7f4ij74w` | 450 | 202 | 952 | Retain finite native behavior/constraint evidence with its existing predicates |
| Pi ARMv6 `p08-counter-k02awr3h` | 433 | 229 | 943 | Retain cross-compilation/declared ABI evidence; no target execution inferred |
| nRF `p08-counter-7pxb5h5m` | 239 (106 fresh + 133 reused in receipt) | 216 | 553 | Retain Embedded collection and prior reuse qualification; not target execution |

All 849 declared input comparisons and all 3,404 declared artifact comparisons
match; all four compiler identities and eight runtime/host prerequisite receipt
hashes match. The audit does not recursively re-prove prerequisite semantics,
SDK installation identity, all transitive artifact inventories or nRF's reuse
algorithm. Those retain their original reviewed applicability conditions. Do not
rerun the four collections merely to prepare a handoff; refresh when affected
inputs or predicates change, especially during host extraction.

Primary evidence:

- [Current P08 receipt and nine-row reconciliation](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/progress.md#integrated-so-09-gap-disposition--2026-11-07).
- [Pi freeze handoff](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/pi-current-stack-analysis-2026-11-07/callback21-freeze-session-handoff.md)
  and [independent classification review](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/pi-current-stack-analysis-2026-11-07/callback21-freeze-session-handoff-independent-review.md).
- [Native assessment](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-native-closure-2026-11-07/native-assessment.md)
  and [independent scoped PASS](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-native-closure-2026-11-07/native-assessment-review.md).
- [Dynamic accounting scope](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/dynamic-allocator-private-accounting-2026-11-07/README.md).

## Gap classification

S = retained shared-safety/unknown blocker to the affected use. T = transferred
composition certification under I4-AC-013. R = retained evidence or limitation,
not an instruction to repeat work. Mixed items are explicitly split below.

| ID / criterion | Mechanism and exact remaining gap | Class / reuse | Owner, destination and closure effect |
| --- | --- | --- | --- |
| S1 — RP-SO-001/002, HC-SO-001/002; IT-AC-004 | Pointer/callee stores, borrowed-object lifetime, callback slot aliasing, reentrancy, and residual predicates across the five-literal, Canvas, UTF8/pixel and Raster consumers | S. Reuse only the exact local facts described below with their premises. The raw callback20 ledger's five-literal section has 54 `remaining_store_alias_checks` (7+10+10+27+0) across four live-store lists; these are unresolved disjointness/callee/reentry predicates rather than observed alias events, and are not an aggregate count for the other callback groups. The separate known-CFG list has 36 stores outside selected callback-word live intervals plus one throw-buffer store excluded only under the exact `stack_chk_fail` no-return premise. Do not subtract or add those as if they were the same predicate population. | Runtime/Observable/Drawing/Raster owners with I4-03/07. Resolve required alias/lifetime/reentry predicates or establish non-applicability for each adopted use before relying on it. Not transferable as “just stack work.” |
| S2 — RP-SO-002, HC-SO-001/002; IT-AC-004 | `Control.backend.write` ownership/lifetime through scoped closures, Session/Endpoint temporary Target copy and offer→render→emitter consumer; `verify-offer-adapter-spill-forwarding.py` was executed and failed: the query at 0x5218d8 reaches writer 0x521a28 rather than expected 0x521ff0, and owner 0x55ea88 remains unresolved | S/mixed. The retained chain conditionally establishes that the incoming Control pointer is copied through Target/Session to Endpoint output+176 and installed into the runtime Endpoint. It does not close the later offer→render→temporary Target→emitter path or all writes/lifetime of `backend.write`. The failed verifier emitted no passing output; this is a proof gap, not established product corruption. | Host/Runtime/BackendIntegration owners with I4-03/07. Shared identity/lifetime/mutation premises remain blockers; route-specific provider costs transfer only after separation. |
| S3 — RP-SO-002/003, HC-SO-002/003 | `submitPayload` 0x581574 and nested Stroke callbacks 0x291864/0x2918a0: complete callback-owner, field lifetime and no-reentry premises absent | S/mixed. The selected implementation declares synchronous borrow/handoff, invokes the optional C writer while borrowing tile bytes, and guards nested offers/reservations; these source controls narrow the selected path. They do not prove that an arbitrary C callback will not retain the raw pointer, that every route leaves the writer nil, or that the two nested Stroke callback environments remain valid. Reuse finite target/caller proofs; no blanket nil-callback exclusion. | Drawing/Raster/BackendIntegration owners with I4-03/07 must qualify adopted callback uses. Their exact linked-provider costs/bounds are T, not grounds to resume whole-image proof now. |
| T1 — RP-SO-003, HC-SO-003; IT-AC-007/008 | Pi whole-route mixed instruction/provider stack composition, unknown SP updates, loaded-provider identity, launch/headroom, final allocation coverage and fit | T. Keep callback21 graph/local-frame/recursion results as conditional facts, not complete fit. Target DNS failure is missing evidence, not a new shared defect. | I4-03/04/07 → I4-AC-013. Early supported-host feasibility and final counter certification. Does not block iteration-3 closure solely because old-image proof is unfinished. |
| T2 — RP-SO-003, HC-SO-003; IT-AC-007/008 | Dynamic private allocator attribution, wrapper-bypass coverage, complete lifetime/route peak and four-route resource joins not established by sampled default-zone results | T. Retain bookkeeping reporting, client requested/usable/rounding and sampled zone scopes. Private bytes remain unmeasured; never substitute rounding or zone extent as metadata. | I4-03/04/07 → I4-AC-013. Preserve budgets and reporting contract on the final composition. |
| R1 — RP-SO-003; MR-04/05 | Compiler rejects CounterSemanticCodec lifetime/deallocation allocation promise | R plus shared-use applicability condition. MP-09 distinguishes rejected promise from observed allocation. The maintained gate injects an annotation into a qualification build; the reviewed finite Native linked argument independently supports its scoped NoHeap result. Do not relabel the compiler result PASS or assume arbitrary generic consumers covered. | Runtime/Profile owner must map the failure explicitly in P10. No compiler repair is required merely to repeat the already accepted finite Native result. Any consumer relying on an unproved allocation guarantee remains blocked until separately evidenced or normally dispositioned; no blanket waiver. |
| R2 — RP-SO-003, HC-SO-003 | Native Static finite workload NoHeap and charged-entry headroom | R. Independent review covers exact image 8e9cf62c… and source/provider/launch premises; 2,936,768 B bound versus 8,340,976 B available. Retain rather than repeat. | I4 refresh on changed image/provider/launch/boundaries; no inference for Pi, arbitrary apps or whole-process memory. |
| R3/T3 — RP-SO-003, HC-SO-003 | nRF existing exact-image resource proof, target execution and final extracted-host certification | Retain the reviewed image proof cited by the P08 receipt; this audit verifies collection artifacts, not that separate whole-image proof again. Missing execution/changed-image certification stays T. | I4-AC-013. No nRF rebuild or hardware action needed for this assessment. |
| T4 — IN-SO-001/003, HC-SO-001 | Legacy analyzer dispatcher factory/model/root/target/owned-return integration and analyzer certification/cutover | T, already accepted analyzer transfer. Counter compiler positives/negatives do not satisfy actual analyzer factory integration. | P09–P12 / I4-03/04/07/10 and I4-AC-012; not an iteration-3 prerequisite. |
| R4/T5 — HC-SO-003 / SO-09 | Full historical P08 independent exit incomplete | Keep P08/R07/T8.1 UNMET; bounded classification is not that exit. | Final replacement criterion coverage belongs to I4. Independent acceptance of this bounded freeze assessment is still a retained handoff requirement. |

Do not equate the 187 unresolved computed graph records, 124 local-analyzer
successors and 28 unknown SP updates: they describe different retained analyses.
The unreviewed VLA aggregate and unexecuted draft analyzer edit are not evidence.
Nothing here requests further old-image graph expansion or a target launch.

## Bounded shared-safety evidence review

This pass used the retained source and proof artifacts only. The worker's
read-only source-hash audit found the owner-ledger, Endpoint identity, runtime
installation, Canvas, and UTF8/pixel proof inputs still match their pinned source
hashes. It did not run a proof producer or certification gate. This resolves the
input-applicability question for those retained packets; it does not strengthen
their conditional conclusions.

| Mechanism | Existing fact that narrows the risk | Exact remaining boundary |
| --- | --- | --- |
| Selected offer reentry | [`OneShotRasterBackendEndpoint.offer`](../../../../Sources/GiftUIBackendIntegration/OneShotRasterBackendEndpoint.swift#L125) rejects a nested offer and sets/clears `offerActive` around the synchronous body. The selected tiled target rejects a second reservation while `backend.active` is true ([`CounterTiledRaster.swift`](../../../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterTiledRaster.swift#L119)). | These guards cover the same endpoint/target reservation path. They do not establish absence of all reentry through aliased owners or arbitrary callbacks, nor rule out writes through unknown pointer/callee effects. |
| Swift callback and buffer scope | [`FullSurfacePayloadEmitter`](../../../../Sources/GiftUIBackendIntegration/FullSurfacePayloadEmitter.swift#L50) nests `surface.withBytes` and `target.withWriter` synchronously. The protocol closure parameters are nonescaping, and the selected target invokes `withWriter` immediately. [`counterProduceStoredEndpoint`](../../../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift#L2058) takes separate formal borrows and its closure body has no direct `Control` capture. | The selected C writer receives an `UnsafePointer` under the synchronous-borrow contract. Its implementation is outside this source proof and can retain or alias that pointer; typed borrow rules do not validate arbitrary foreign behavior or pointer corruption. [ADR-039](../../../adrs/adr-039-scoped-storage-ownership.md) and [SPEC-013 RP-TB-002/003](../../../specs/spec-013-runtime-profiles.md#native-static-typed-backed-model-construction--approved-2026-10-24) retain actual-borrow, no-alias/reentry, cleanup, and last-borrow duties; lifetime checking alone does not establish callback quiescence. |
| Callback-slot store order | The [`callback20-owner-residual-ledger.json`](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/pi-current-stack-analysis-2026-11-07/callback20-owner-residual-ledger.json) (SHA-256 `31d7b4f9826bfc1f177f218156a78c003716f42623dcfb4c5f0a27bad2745317`) records 36 exact known-CFG stores outside selected callback-word live intervals. The [`withPath` slot audit](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/pi-current-stack-analysis-2026-11-07/withpath-callback-slot-audit.json) has no remaining direct live-store candidate for its selected callback slot; its one throw-buffer store cannot reach the load only under the retained `stack_chk_fail` no-return premise. | This removes only those exact known stores from those exact loads. The ledger's 54 live alias candidates are separately retained. Unknown provider/callee effects, computed-entry coverage, frame ownership, and reentry remain per-consumer premises. |
| Foreign Control fields | [`foreign-root-halfword-disjointness.json`](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/pi-current-stack-analysis-2026-11-07/foreign-root-halfword-disjointness.json) (SHA-256 `3692c5654ba5605d13c8e18e72cf769d73b318f45e2afcc2f2fe309e27d4362a`) proves three stores (`0x433e2c`, `0x433e34`, `0x433e38`) target root fields disjoint from the audited callback words; these are outside the 54 ledger entries. | This discharges those three byte ranges only; it does not establish general foreign-root nonaliasing or endpoint/control lifetime. |
| Scoped stack overlap | [`scoped-foreign-frame-nesting.json`](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/pi-current-stack-analysis-2026-11-07/scoped-foreign-frame-nesting.json) (SHA-256 `6ce67e1899e9800215905921c3831aad2c189fd2124b979f8e4761e7b964ea34`) proves active/fresh stack interval disjointness on four selected caller chains under normal frame nesting (`E ≤ S`). | This closes only the selected stack interval overlap predicate. Alternate roots, callee/provider effects, callback reentry, and Control identity/lifetime through Endpoint/Session/emitter remain open. |
| Endpoint identity | The retained normal-success chain proves input Control → Target word 0 → Session field +68 → Endpoint output +176; the runtime-install packet proves the same Control is installed and passed to the offer receiver, under typed immutable owner/lifetime premises. | The currently failed offer-adapter spill verifier and unresolved 0x55ea88 edge leave the offer→render→temporary Target→emitter join incomplete. No all-route `backend.write` nil or lifetime claim follows from the selected nil-argument route. |
| Nested Stroke / submit | The selected DisplayTarget advertises `.synchronousBorrow`, `.synchronous` handoff and one in-flight payload; local active/reservation checks are present. | `0x581574`, `0x291864` and `0x2918a0` still lack complete owner/context/lifetime joins. These callback identities and conditions cannot be removed from the affected-use blocker. |

The first five rows close or narrow only the named predicates. None demonstrates
that all retained uses are independent of S1–S3, and none converts the conditional
P08 packets into a shared-safety PASS. [`CounterControl`](../../../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift#L68)
claims a vacant runtime slot and only clears it after quiescence, with the endpoint
idle and the backend inactive; these lifecycle guards do not substitute for the
missing callback-slot and Endpoint consumer joins. The exact foreign-store and
stack-interval conclusions above are reusable; the ledger's remaining 54 store
candidates and unresolved Endpoint/Stroke/submit consumers are still blockers for
dependent adoption.

## Independent bounded classification review

The `so09_gap_audit` reviewer performed a read-only final check of this shared-
safety classification on 2026-11-08. It confirmed the 54 live-store count is
scoped to the four five-literal lists; the 36 known-CFG exclusions and one
`stack_chk_fail`-conditional exclusion are distinct; and the foreign-store and
scoped-frame conclusions remain narrow. No remaining factual, count, or
classification issue was found. This review did not accept the overall freeze
assessment, close iteration 3, or change P08 from FROZEN / UNMET.

## Nine scoped-ownership criteria

These are dispositions of the remaining P08 obligations, not full Spec acceptance.
The original 180-criterion P10 matrix is still required separately.

| Criterion | Retained evidence | Open allocation |
| --- | --- | --- |
| IN-SO-001 | Qualified union/carrier/erasure and lifetime controls on four routes | T4 analyzer actual owned returns |
| IN-SO-002 | Native exchange/refusal/generation/action/pixel controls and physical rows | Target runtime claims remain limited; refresh changed consumers in I4 |
| IN-SO-003 | SO-01 caller inventory and focused shared Interaction/Activation controls | T4; P10 current shared compatibility disposition still required |
| RP-SO-001 | Typed acquisition, prefix/refusal and recorded physical custody | S1 where required borrowed/alias premises remain; complete composition costs T1/T2 |
| RP-SO-002 | Native early return, activation/candidate failure, quiescence, reuse and cleanup controls | S1–S3 cannot be closed by generic corpus PASS alone |
| RP-SO-003 | Current collections; scoped Native/nRF resource results; Dynamic reporting | T1/T2/T3; R1 explicit failure/applicability disposition |
| HC-SO-001 | Supplied→pipeline→coordinator→host→retirement constraints/controls | S2/S3 affected ownership joins; T4 |
| HC-SO-002 | Validation/error order, refusal, retirement and independent behavior oracles | S1–S3 remaining affected premises |
| HC-SO-003 | Four routes, declared ABI and linked evidence within original scope | T1–T3/T5; no full P08 PASS |

## Exact remaining iteration-3 closure blockers

1. **Affected shared-safety premises S1–S3 are unresolved.** Establish their
   applicability to retained shared paths and resolve required premises or prove
   those paths do not rely on them. This is not a request to finish the Pi whole
   stack graph. The approved freeze does not permit a blanket transfer of these
   unknowns. Any explicit maintainer disposition must identify its exact scope;
   this assessment grants none.
2. **P10 integrated validation/dispositions are missing.** The configured runner
   report location `.build/test-reports/all-hardware-free` does not exist in the
   inspected workspace. The historical checkpoint records Unit FAILED and
   Interaction UNEXECUTED; no current result was found that supersedes that
   disposition. This is not a fresh test failure or proof that a run never occurred
   elsewhere. Locate and qualify an existing full-gate receipt or execute the
   required formatted-source gate as a separate closure activity. Classify each
   failure as shared, transferred analyzer/composition, or unrelated with evidence;
   the four Counter collections do not substitute for it. Finish all 180 owner
   criterion dispositions, including R1, without claiming a full-suite PASS from
   focused evidence.
3. **Independent acceptance of the overall freeze assessment is pending.** The
   Pi handoff has independent acceptance and the Native result has scoped independent
   acceptance. Neither reviews this iteration-wide classification, input inventory,
   nine-row mapping and closure list. Reuse those reviews; require only the missing
   bounded overall review, not another semantic proof campaign.
4. **Retained P11/P12/ME-09 closeout packet is not yet complete.** The current audit
   supplies input identities and identifies reusable collections. Reconcile the
   retained accounting/oracle facts and owner conformance reports into one final
   source/artifact/criterion handoff with T1–T5 destinations. Record actual removals
   or justified no-removal disposition; keep uncertified counter/analyzer baseline
   inputs. Do not claim the current dirty workspace is an adopted certified image.
   Transferred fit/target certification is not part of this closure blocker.
5. **Human iteration-3 closure decision remains absent.** Both scope and Spec
   transitions stay unchanged. Request closure only after the retained gates above
   have evidence or exact explicit applicable dispositions. Full P08 PASS, Pi target
   availability, old-image stack completion, external-counter host extraction and
   analyzer migration are not additional iteration-3 entry/closure requirements.

No product-code changes, broad gate, new tests, P08 certification, target query,
or remote action were performed. This follow-up classified retained source and
proof evidence only. The separately open work is the scoped shared-safety
applicability resolution and P10 gate/disposition package, followed by overall
review and handoff closeout; not resumption of P08 certification. This assessment
is ready for review, not for an implemented or iteration-closed transition.
