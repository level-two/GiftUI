# Independent P07 repair exit review — 2026-10-11

**Finite P07 exit: PASS.** R1 and R2 from the original
[failed review](independent-exit-review.md) are resolved. No remaining blocker was
identified in this bounded rereview. The original FAIL remains valid for its
frozen `c1500b86` candidate; this report evaluates the repaired candidate.
P08 has not started. SPEC-009 T9.1, SPEC-013 T11.1 and P10–P12 remain open.

## Frozen scope and authority

Reviewed clean revision `329570ab392895686cf2b5dbd017d00a2fdf0ad3`:
R1 repair `0741894a8aafea28685615fbda86846bae6912d5`, R2 repair
`ad671ea6c212171cab1228d51d8f6eabf6c033f5`, and reconciled four-route evidence.
Every repaired final receipt freezes clean implementation `ad671ea6` with the
same driver and compiled source. Separate sequential Strong rereview, Sol 6.1
High, C3/R3; no implementation edits or additional agents.

The authority and finite P07 boundary are unchanged from the original review:
approved SPEC-009/013 coordinator amendments, accepted ADR-035/036/037,
[explicit consuming-owner resumption](consuming-owner-resumption.md) and the
[bounded package plan](../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md#ordered-work-packages).
SPEC-009 SHA-256 remains
`60c9d9d2b5446ff15c12d66827c36eed5fa476fb2ce3bec598c49bc857ece845`;
SPEC-013 remains
`2f6ddecc67b000ec6da8047be5875e793c5cd00813d30c5c1b444e6168cbde79`.
ITERATION-003 I3-04/05 supplies runtime derivation/efficiency scope and the closed
MVP supplies behavior and target-stack regression requirements. Both Specs remain
`implementing`; this review grants no lifecycle transition or exception.

## Finding dispositions

| Finding | Result and independently assessed correction |
| --- | --- |
| **P07-R1: ordinary post-publication failure intent/frame** | **Resolved.** The common runner observes actual allocated candidate state before cleanup. Ordinary post-publication failure is satisfied; candidate-ID exhaustion before acquisition is notProduced, presentation-ID exhaustion after acquisition and ordinary offer failure are aborted. Nonretryable refusal and required-facility loss retain unavailable. Prior intent is preserved before publication. The actual-profile fault loop now asserts frame/intent/preservation/wake/commit fields under SPEC-009's exhaustive outcome table (lines 1226–1237). Genuine existing allocator exhaustion and a real endpoint invalidEnvelope result check the two allocation states and offer failure. Pending recovery clears stored intent and wakes without replay, retaining prior committed routing and semantic publication. |
| **P07-R2: incomplete idle concrete quiescence** | **Resolved.** Both concrete coordinators stop binding admission and call cleanup on the consumed opportunity. The binding no longer retires root state prematurely. The same actual opportunity clears pointer capture/source/sequence, admission, Interaction routing and pending recovery/wakes, then retires root identities; repeated and terminal stops share one completion guard. Idle return satisfies SPEC-013's quiescence duties (lines 797–805). During a real scoped derivation, stop leaves active backing alive; mandatory attempt cleanup/finalization ends the frame and performs exactly one teardown. Coordinator quiescence and ownership extraction require both admission stop and actual opportunity cleanup completion. |

The package-only `hasAllocatedCandidateFrame` observation and
`RuntimeOpportunityQuiescence` cleanup/completion seam are direct implementation
of the existing outcome and teardown duties. They preserve the approved common
coordinator and ExecutionOpportunityRunner operational signatures, exact failure
carriers, finite Model/Schema/action bindings and consuming lifetime dependence.
They add no public authored API, host policy, capacity, compiler change, owner move
or architecture decision. The eight ownership/consuming-return and four mismatch
negatives remain enforced on all four routes. No contract amendment is needed.

## Independent checks

Rehashed all repaired final receipt inputs, compiler/core receipts and retained
artifact byte counts/SHA-256 values against the reviewed tree: **647 input-file
checks and 521 artifact checks**. All four receipts are clean `ad671ea6`, use the
same driver, and have twelve passing intended compiler negatives each.

| Route | Independent result |
| --- | --- |
| macos-static | Re-executed `.build/contracts/spec-013-runtime-cycle/tmpwj8mqyyn/macos-static/runtime-cycle`: 5904 assertions, zero failures; all 26 complete actual Static/Dynamic pairs reproduce preserved values exactly. |
| macos-dynamic | Re-executed `.build/contracts/spec-013-runtime-cycle/tmpke3zvfyl/macos-dynamic/runtime-cycle`: same 5904/0 and 26 exact pairs; complete native outputs match the other route. |
| raspberry-pi-armv6 | Verified 165 inputs/120 retained artifacts and selected object's v6 CPU/VFP-register attributes. Cross-compilation only. |
| nrf52840-embedded | Verified 152 inputs/115 retained artifacts and selected object's v7E-M CPU/VFP-register attributes. Cross-compilation only. |

Both native routes have 165 inputs/143 artifacts each. Their
[complete logical values](repair-final-logical-transcripts.json) and
[26-field storage descriptors](repair-final-storage-regions.json) equal each
other. Checked sums and per-family region partitions reconcile to Static
**68,503** / Dynamic **166,240** bytes. Each rises one byte for actual cleanup
completion state; no other bound or backing family changed.

In addition to executing the permanent regression assertions, independently
inspected all original ordinary capacity-failure transcript rows at
candidateAllocation and offerAndProduction: each now reports satisfied, with
notProduced before acquisition and aborted afterward. Independently checked
the actual repaired quiescence observations:

```text
idle-quiesce (1, 1, 0, true)
idle-quiesce (2, 1, 0, true)
deferred-quiesce (true, 1)
```

Modes 1/2 prove healthy live capture and pending recovery respectively, each with
one teardown, zero committed records and cancelled capture. The deferred result
proves exactly one completed teardown after real frame cleanup. Source assertions
also check no extra stream, mutation or finalization on idle/repeated stop, all
later admission/opportunity refusals, cleared actual owner recovery/root state,
and unchanged retained workspace backing before extraction/reset.

Reproduction commands, compiler/flags/core identities, checks and artifacts are
in the four [repaired final receipts](repair-final-evidence.md#reproduction-and-identity).
This rereview reused the freshly hash-verified compiled modules and binaries;
there was no unresolved concern requiring a second full compilation or P10 gate.

## Package criterion scope and remaining gates

| P07 duty | Finite exit disposition |
| --- | --- |
| RP-RD-001 / actual audited construction | Pass for the selected composition: actual scoped factories, all 26 measured families, checked exclusive partitions, immutable configured limits, foreign-owner and four mismatch negatives, existing below/equal/above and configured-limit controls. |
| RP-RD-002 / complete actual cycle | Pass for P07: real Static/Dynamic focused owners and concrete coordinators; phase/failure/early-acquisition and cleanup transcripts, first/partial application, no replay, retirement, bank reuse, published-vs-accepted routing, stale-target cancellation, latest recovery, idle/terminal/deferred quiescence and malformed Drawing rollback. R1/R2 are now checked against the contract as well as profile equality. |
| RP-RD-003 / four-route lifetime and ABI portion | Pass for P07 selected modules, twelve negatives per route, separate finite schema/presentation/bridge composition and target CPU/VFP checks. Full linked-image resource proof is a later gate. |
| RP-RD-004 / unchanged selected limits | Pass within P07's finite composition and fault outcomes. Full migrated applications and loaded acquisition/frame/timing obligations remain unmet later-package evidence. |
| SPEC-009 T9.1 integration | P07 portion passes: scoped seams, copy/escape/consuming-return rejection, actual admission/provenance/dispatch/report, exact dispositions and quiescence. The owner checkpoint remains open through P10–P12. |

Complete schema-4 hosts/counter and analyzer migration remain P08/P09. Complete
owner regression and the broad hardware-free gate remain P10. Linked Static zero
heap, complete stack/RAM/flash/IRQ overlap, matched Dynamic allocation/dispatch
costs and loaded acquisition/frame/timing/connected evidence remain P11. Final
production cutover and full conformance dispositions remain P12. Selected backing
totals and target objects do not satisfy those requirements. No deploy, restart,
flash, full-image or hardware execution is claimed.

P07 is complete at its finite package boundary. Stop package work here; do not
expand testing or polish without a new failure. The resumed consecutive
unproductive-repair count remains **0/2** and the historical exhausted **2/2** stop
is preserved. No optional follow-up or scope/contract decision was introduced.
