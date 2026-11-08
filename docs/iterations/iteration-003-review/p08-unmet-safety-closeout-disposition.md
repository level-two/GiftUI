# Approved closeout disposition for unmet P08 safety gaps — 2026-11-08

## Authority and exact boundary

Eugene explicitly instructed:

> Agreed. Update the governing documents to allow iteration 3 closeout with these gaps explicitly unmet, blocking affected reuse in iteration 4 until resolved or replaced and validated. Preserve the remaining closure gates and commit.

This approves ITERATION-003 revision 8 and ITERATION-004 revision 11. It is an
explicit scheduling/closure disposition for **S1–S3 as bounded in the
[assessment](p08-freeze-assessment/assessment.md)**, not a safety PASS, Specification
exception, architecture decision or iteration closure. P08 stays FROZEN / UNMET;
R07/T8.1, incomplete SO-09 and affected criteria remain open. Accepted contracts
and budgets are unchanged. Do not classify the gaps as mere resource certification.

The named gaps may remain unresolved at iteration-3 closure if the remaining
closure gates below pass or receive their own explicit applicable dispositions.
They continue to block affected reuse in iteration 4 until resolved or the
mechanism is replaced and validated. This supersedes earlier wording requiring
S1–S3 resolution before iteration-3 closure, including blocker 1 of the assessment.
It does not cover unrelated/new shared defects, other failed tests or blanket
unknown-safety waivers. No full-suite PASS follows from this disposition.

## Restricted reuse register

| Gap | Unmet boundary to retain | Accountable owner / delivery | Condition for releasing affected reuse |
| --- | --- | --- | --- |
| S1 | Unknown C callback/callee behavior, pointer aliasing, borrowed lifetime and reentry premises in the retained callback-owner ledger; exact discharged stores/intervals remain discharged only within their reviewed scope | Runtime/Observable/Drawing/Raster owners, coordinated by I4-03/07 | Identify actual supported callbacks and consumer paths; establish the required no-retention, alias/lifetime and reentry obligations, or replace the affected mechanism and validate those obligations. Existing typed Swift scope checks do not prove arbitrary foreign behavior. |
| S2 | Endpoint → Session/temporary Target → offer/render/emitter ownership and Control.backend.write identity/lifetime; failed spill-verifier mismatch and unresolved owner join remain proof gaps | Host/Runtime/BackendIntegration owners, I4-03/07 | Demonstrate complete backing/owner/borrow/cleanup chain for the adopted path, or replace that chain and validate equivalent ownership/lifetime/refusal/cleanup guarantees. Moving the same code into GiftUI is not resolution. |
| S3 | submitPayload and nested Stroke callback-owner/context/lifetime joins; nil-writer claims remain route-specific | Drawing/Raster/BackendIntegration owners, I4-03/07 | Qualify each adopted callback context and its lifetime/reentry conditions, or replace and validate the affected mechanism. No general nil-callback or synchronous-safety inference from one route. |

Before dependent work, the iteration-4 owner plan must map each affected source
mechanism/consumer to these IDs and label its reuse blocked. A qualified unrelated
path can proceed only with an applicability argument showing it does not rely on
an unmet premise. Investigation, design and implementing a replacement may proceed
under normal lifecycle gates; they do not authorize treating the affected mechanism
as a qualified dependency or adopting it in a supported host.

Release requires criterion-linked evidence and independent review of the actual
adopted owner-to-consumer-to-retirement path, including applicable failure/refusal,
negative lifetime/alias/reentry controls and target/profile coverage. Preserve
independent behavioral oracles and refresh invalidated resource/ABI evidence.
If the intended remedy changes architecture or contracts, obtain the usual RFC,
ADR and Spec approvals first. Update the register and owner conformance reports
with the disposition; never infer release from compilation, a move/rename, P08
collection PASS or a planned rewrite. Replacement need not prove a retired machine
address chain, but must meet the same applicable semantic and safety obligations.

## Iteration-3 closure gates retained

1. P10's required `scripts/test.sh all-hardware-free` and the 180-criterion
   dispositions remain. Locate/qualify a retained run or run the required gate;
   preserve Unit FAILED / Interaction UNEXECUTED until superseded or explicitly
   dispositioned. Map any result attributed to S1–S3 exactly; this approval does
   not automatically excuse other failures or turn an incomplete run into PASS.
2. Obtain independent acceptance of the overall freeze assessment, its input
   inventory, criterion map and this restricted-use handoff. The existing scoped
   safety-classification review is reusable but does not replace that acceptance.
3. Complete retained P11 accounting and P12/ME-09 documentation: exact source,
   toolchain, artifact and evidence identities, preserved failures, S1–S3 restrictions,
   transferred counter/analyzer certification and owner destinations. Remove only
   inputs with satisfied adoption gates; otherwise record justified no-removal.
4. Obtain an explicit human iteration-3 closure decision. Record S1–S3 as
   **unmet, accepted for iteration closeout with affected reuse blocked**. Keep
   the affected Spec criteria and P08 incomplete; this is not product safety
   certification or an implemented transition.

This approval permits closeout preparation now, not automatic closure or activation
of iteration 4. Full old-host certification remains transferred under I4-AC-013.
The compiler allocation-effect failure retains its separate R1 applicability
and P10 disposition; this S1–S3 approval does not relabel it PASS.

## Iteration-4 entry and completion

Entry retains the human iteration-3 handoff/closure, reviewed overall freeze
packet, exact retained inputs and normal contract/plan approvals. S1–S3 resolution
is no longer a blanket iteration-entry prerequisite. Unrelated qualified work and
approved resolution/replacement work can proceed; affected reuse/adoption cannot.
Counter-first extraction must respect this register. I4-03/07 and I4-AC-013 retain
the safety evidence before supported counter adoption and dependent analyzer
adoption; I4-AC-004/008 cover affected compatibility/ownership. No iteration-4
completion or full conformance can hide an unreleased affected-use blocker.
