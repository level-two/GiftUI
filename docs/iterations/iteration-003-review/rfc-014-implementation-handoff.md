# RFC-014: final investigation disposition and implementation handoff

**2026-10-10 — investigation and RFC review complete; proceed to ADR extraction
and contract preparation.** This is a routing and acceptance
checklist, not a ready Specification Implementation Plan or approval to modify
production. Parent [RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md)
is approved under the [final review and delegated finalization record](rfc-014-final-review.md).
ADR acceptance and affected Specification approvals remain outstanding.

## Authorization and result

Eugene authorized one final bounded package, then instructed that subsequent
activities should move to implementation rather than more investigation rounds.
[SPIKE-074](../../spikes/spike-074-final-access-ownership.md) is terminal:
48/48 invocations, one repair, four compiler configurations, 47 checks in each
native run and eight intended negative rejections. Its
[result](../../../experiments/spike-074-final-access-ownership/evidence/result.md)
supports the typed module contract, finite three-bank transaction and incremental
layout within the registered scope. No selected assumption failed in that scope.

There is **no next investigation round** in this plan. Neither unused repair/time
allowance nor future implementation difficulty authorizes a successor Spike.
The normal response to a local implementation problem is a bounded task/test
under the approved Spec. A concrete architectural contradiction returns for a
maintainer decision, with the failing case and options; it is not investigated
indefinitely or silently repaired by changing the contract.

## Decisions carried forward

- Canvas is a View leaf with Body == Never; custom view bodies remain inferred.
- One fixed typed read domain per compiled conformance; application schema
  requirements sit outside GiftUI and portable presentation imports no Runtime.
- Stable storage and serialized mutation exclusion cover graph/layout/draw;
  ordinary frame reads do not require a copied model version or an OS lock.
- Scoped facades do not escape. Owned model identity and small payloads may be
  staged for Canvas; backing remains alive through the last read/discard.
- Three capture banks remain: source, admission, model. Two metadata slots do not
  mean two model banks. Retained owners remain valid; insufficient capacity
  refuses before commit. An installed empty analyzer reserves its entitlement.
- Generated access/write lowering is finite and checked; no unchecked fallback,
  universal application registry or change to owned Domain capture meaning.

These choices are approved at the RFC design level. The compiler dependency,
compiled View changes and explicit presentation-capture migration must appear
in the downstream ADRs/Specs before production relies on them. RFC approval does
not accept those ADRs, approve the Specs or certify implementation feasibility.

## Remaining work belongs to implementation

Each row names the task boundary, prerequisite and acceptance evidence. These
rows do not allocate a new investigation budget or weaken existing requirements.

| ID | Task and prerequisite | Required acceptance evidence |
| --- | --- | --- |
| IH-1 | RFC review is complete; extract the three proposed ADR decisions, obtain acceptance, then amend/review affected Specs. | Explicit compiled View/Canvas contract, generated schema/access boundary, supported compiler policy, model ticket/generation/phase rules, capture-selection migration and configured refusal behavior. Human approvals before relying on changed authority. Preserve ADR-034's three banks. |
| IH-2 | Implement supported source lowering after contract approval. Use the existing [counter/analyzer inventory](../../../experiments/spike-072-contextual-traversal-integration/application-coverage.md). | Both real applications compile with unchanged authored body/property/Canvas intent; inferred Body, helper/conditional evaluation order and typed failure transport; deterministic rejection of unsupported effects/escapes. No claim of general Swift source support. |
| IH-3 | Integrate owner storage, State and registration with both runtimes and actual host owners. | All ticket retain/release and pointer-pointee lifetimes, root/nested binding, ignored seeds, successful replacement, retained-owner refusal, attach/detach/report failures, generation exhaustion/reuse, early draw rejection and teardown. Both profiles produce equivalent outcomes at the same limits. Compiler controls plus behavioral tests; phase bits alone are insufficient. |
| IH-4 | Implement runtime records, codecs, exact structural identity and Canvas/geometry staging under the approved limits. | Actual counter/analyzer traversal and graph-publication equivalence; bounded resource refusal, no expanded generated topology; last-reader cleanup before reuse, later geometry/backend work independent of model data. Existing SPEC-006/007/010/011/012/013/015 obligations remain. |
| IH-5 | Complete end-to-end conformance of the migrated applications after IH-2–4. | Full action/acquisition/capture replay and error ordering, no-op/report behavior, retained-model semantics, domain snapshot meaning, publication/failure/retry behavior on supported configurations. The 47-check fixture is not this conformance suite. Hardware work requires its existing explicit authorization. |
| IH-6 | Measure and enforce final resource/performance limits on actual supported artifacts. | Complete pool/descriptor/registration/host-ticket/stack/IRQ accounting, linked ELF RAM/flash, allocator reachability and zero heap where required, matched Dynamic costs, accepted capture/admission limits and frame/acquisition requirements. Inspect the fixture's allocator references in the actual linked implementation; never treat unresolved references or unknown stack paths as zero. |

The remaining ADR/Spec portion of IH-1 is the immediate next deliverable. IH-2–6 become ordered tasks in the ready
Implementation Plan only after the relevant Specification is approved. Full
migration/conformance/cost work is deliberately not a prerequisite to *finishing
architectural investigation*. It is still mandatory before production adoption
or an implemented/conformant claim.

## B0–B4 disposition

| Former open question | Investigation outcome | Remaining gate |
| --- | --- | --- |
| B0, capacity / ownership | Three banks selected; guarded empty-candidate transfer and retained-owner refusal demonstrated. | IH-3 actual owners/callbacks and IH-6 complete costs; no fourth-bank amendment. |
| B1, typed model access / compiler | Six compiled module boundaries, inferred custom Body, typed nested reads and eight borrow/escape rejections support the selected contract. | IH-1 compiler/API policy; IH-2/3 actual lowering, runtime binding and safe backing lifetime. |
| B2, complete storage / lifetimes | Exact fixture metadata/key/Canvas layouts measured; no mandatory extra bank. | IH-3/4 complete layouts and every live owner/payload, IH-6 all resource totals. |
| B3, whole-image costs | No complete-image or zero-heap proof claimed; object allocator symbols explicitly recorded. | IH-6 acceptance of the actual linked images, stack paths and Dynamic costs. |
| B4, complete source / migration | Representative selected syntax and real Domain types compile; source inventory preserved. | IH-2/4/5 complete supported-source migration and conformance. |

No known architectural contradiction is hidden in this routing. It also does not
turn any unmeasured implementation property into a pass. If implementation cannot
satisfy an accepted contract within its approved limits, stop the affected task,
bring the exact conflict back for decision, and leave its acceptance gate unmet.

## Review boundary

RFC review is closed with [approval provenance](rfc-014-final-review.md).
The next gates are ADR acceptance and Spec approval, followed by implementation
and conformance. No further product choice or investigation is requested here;
production adoption remains subject to those gates.
