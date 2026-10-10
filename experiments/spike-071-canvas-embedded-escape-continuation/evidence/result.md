# SPIKE-071 terminal result

**Supported recommendation for the bounded C mechanism.** Separately evaluating
the typed throwing reads fixes SPIKE-070's Embedded assertion failure. The
corrected candidate compiles on all four configurations, passes both native
runs, rejects the six scoped-access violations and has no allocator relocation
in the rooted nRF fixture. RFC-014 remains draft: this is not complete application
integration, source compatibility, production compiler-policy approval or a
whole-firmware resource proof.

## Results

| Gate | Observed evidence |
| --- | --- |
| Positive compilation | nRF Embedded first, then native Dynamic/Static and ARMv6: all pass, trials 1, 2, 4, 6. Same tested LifetimeDependence + Lifetimes flags. |
| Native execution | 21 checks pass per profile, trials 3 and 5. No target execution. |
| Return local context | Four intended lifetime-escape rejections, trials 7–10. |
| Outer storage | Four intended variable lifetime-escape rejections, trials 11–14. |
| Escaping closure | Four intended captured-variable lifetime-escape rejections, trials 15–18. |
| Stored field | Four rejections of non-Escapable FrameRead in an Escapable struct, trials 19–22. |
| Overlapping mutation | Four exclusive-access rejections, trials 27–30. |
| Nested-helper controls | Four valid forwarding controls pass, trials 33–36; four dead-owner returns reject solely for lifetime escape, trials 37–40. |
| nRF sectioned object / rooted link | Both pass, trials 31–32, rooted at `spike071_driver` with caller-supplied backing/recorder. |
| nRF object inspection | Cortex-M4, v7E-M, Thumb-2, VFPv4-D16 and `Tag_ABI_VFP_args: VFP registers`. No reachable allocator relocations; five indirect call sites inside `drawBar`. |
| ARMv6 object inspection | v6 and VFP-register argument attributes present. |
| Generator controls | Seven rejection samples and three output-changing perturbations reproduced; no new grammar or compiled-perturbation claim. |

Native checks remain those listed in SPIKE-070: coherent values/defaults, indexed
capture reads, stale/foreign/invalid key outcomes, protocol leaf traversal,
deferred repeated Canvas invocation, synthetic layout ordering, actual path
cleanup, frozen-write refusal, revision and modeled publication/dirty outcomes.
Native strides remain Transition 16, ModelKey 12 and ModelOwner 72 bytes.
Repeated equal Canvas values do not prove painter order; injected failure is
in the first Canvas, not midway through the list. Those limitations are retained.

## Repair and budget accounting

**40/48 invocations, 2/3 repair rounds**, completed before the 60-minute deadline.
No excluded waiting. All calls and source snapshots are preserved in the ledger.

1. The authorized initial assertion correction is repair round 1. Both scalar
   reads are evaluated as `throws(AccessFailure)` before a nonthrowing `&&`.
   Native behavior and expected values are unchanged; Embedded now compiles.
2. Review of the initial nested-helper rejections (trials 23–26) found an extra
   “borrowed and cannot be consumed” diagnostic in the forwarding helper itself.
   Repair round 2 adds explicit `copy read`, then independently validates that
   live-owner forwarding compiles before retesting dead-owner returns. The four
   old controls remain recorded as confounded/superseded. The final matrix uses
   trials 37–40 for this case: **24 valid negative controls**, plus four historical
   confounded rejections and four supporting positive controls.

No candidate change was needed beyond the assertion fix. The helper repair is a
test correction. No third repair or remaining invocation allowance is opened
for additional questions. SPIKE-070 stays terminal with its original result.

## Resource interpretation

The rooted relocatable object's relocation table has no references to the
recognized allocation functions. Undefined symbol-table entries for `free` and
`posix_memalign` survive without corresponding references; they are not counted
as live allocator calls. All five indirect call sites occur inside `drawBar`,
which uses the actual GraphicsContext operations table constructed by the finite
fixture. This is not a blanket “no indirect calls” result or a full call-target/
stack proof. External ABI memory helpers and stack-check machinery also remain.

These observations apply only to this optimized rooted fixture and its supplied
backing. They do not establish the complete firmware's heap behavior, ABI of
all linked libraries, model-pool storage, recursion/IRQ stack, target execution
or frame/acquisition performance. Raw host pointer construction remains an
explicit precondition outside compiler lifetime enforcement.

## RFC implication

SPIKE-071 closes the missing compiler matrix and object-inspection questions
from SPIKE-070 for this finite candidate. The context borrow, safe key-bearing
Canvas values and leaf witness are supported under the tested compiler policy.
This provides a concrete basis for the next RFC design decision, without
approving it.

Keep B1/B4 open for production contextual View evaluation/error transport,
complete model/getter/helper and current-write lowering, actual State/owner
integration, public authoring compatibility and adoption of experimental
lifetime features. C-P3 application ownership, five-bank B0 storage, B2 exact
layout/accounting and B3 full-image costs remain separate. The next work should
specify the production evaluation/binding seam and its authority amendments;
there is no need to repeat this generic escape matrix without a changed candidate.
No additional experiment or production migration is launched by this result.
