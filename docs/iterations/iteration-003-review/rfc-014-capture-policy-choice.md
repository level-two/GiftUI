# RFC-014: analyzer capture capacity choice

**2026-10-10 — option A selected by the maintainer for the RFC working design.** Parent:
[RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md).
The maintainer requested resolution of typed access and three-bank ownership,
with explicit choices brought back for decision. Eugene answered the concrete
comparison: “Keep three banks with bounded replacement refusal (Recommended)”.
This settles the capacity direction, not RFC approval or implementation proof.

## What the existing contracts establish

[ADR-034](../../adrs/adr-034-five-second-transition-capture.md) fixes source,
admission and model capture backing at exactly 3 × 404 × 16 = 19,392 bytes,
with no fourth buffer. [ADR-024](../../adrs/adr-024-structurally-owned-observable-reference-state.md)
preserves atomic replacement and application ownership after detachment.
[ADR-026](../../adrs/adr-026-profile-equivalent-bounded-observable-state.md) and
[SPEC-010](../../specs/spec-010-observable-reference-state.md) permit explicit
capacity refusal before changing a live association; they do not promise that
arbitrary retained models fit a particular application configuration.
[SPEC-001](../../specs/spec-001-signal-analyzer-reference-application.md), observable
state/admission sections, configures one model capture and independent snapshot
admission. Its portable analyzer does not replace its model after materialization,
but shared runtime conformance must support successful and failed atomic replacement.

The earlier K=2 proposal assigned a full capture bank to each model slot. That
is a candidate policy, not a consequence of having two identities or two scalar
counter values. We can separate model metadata capacity from capture capacity.

## Options

| | A — preserve three banks (recommended) | B — reserve a fourth bank |
| --- | --- | --- |
| Capture transition bytes | 19,392 | 25,856 (+6,464), excluding all metadata |
| Large model payload capacity | One independently populated analyzer capture | Two independently populated analyzer captures |
| Atomic replacement | Succeeds when candidate resources fit, including an empty candidate and an explicitly transferable former bank; otherwise refuses before changing the association | Can stage a second populated capture and retain a former model at K=2; a third model still refuses |
| Retained former model | Never revoked or overwritten; may prevent another capture-owning model from being installed | Can coexist with the installed populated model within K=2 |
| Source/admission | Separate fixed banks; no stealing, delayed required facts or reduced capture horizon | Same |
| Compatibility | Keeps ADR-034 resource decision; requires exact new capacity/access behavior in reviewed RFC/Spec work | Requires an explicit ADR-034 amendment/successor and new complete resource evidence |

A does not disable replacement generically: scalar counter models can use two
small typed slots without analyzer buffers. A also does not claim that every
replacement of an arbitrary populated analyzer model can succeed in three banks.
B is not claimed to fit the complete nRF image merely because the additional
transition cost is known.

## Selected option-A ownership contract

Model metadata/owner records and transition banks are separate. The draft uses two
bounded metadata records and one model-capture bank for the analyzer; counter
has its own two scalar records and no capture bank. Those metadata counts still
need layout/resource validation and Specification review.

| Step | Old model A | Candidate B | Model capture bank |
| --- | --- | --- | --- |
| Normal operation | Installed, populated, application ownership recorded | Absent | A owns it |
| Prepare an empty replacement | Remains installed; host may explicitly transfer its owning ticket into the transaction | Inert owned empty seed and reserved registration; no capture bytes | A still owns it, unchanged |
| Validate ownership/capacity | All owners/pins accounted; external retention cannot be guessed away | Empty initial capture; reserve the right to obtain the bank after commit | Transfer permitted only if A has no surviving independent owner and no reader |
| Candidate attach fails | Original identity, data, registration and host ticket restored/preserved | Candidate-only registration undone; caller retains its empty candidate ticket | Still A, byte-for-byte unchanged |
| Commit succeeds | Old registration retired; transaction releases the last A ownership | B installed with its own empty initial state | Becomes available to B; old bytes need no clearing, B count/baselines define empty state |
| Next admitted capture update | A keys stale; no destroyed owner can read | B updates during mutation phase | B owns it; source/admission stay separate |
| A has an independent retained owner | A remains valid and installed if reservation fails | Replacement requiring unavailable backing is refused before attachment/commit | Never overwritten or silently revoked |

This is a proposed ownership transfer protocol, not measured implementation.
Attachment is not permitted to borrow a fabricated populated B capture or mutate
A. It observes B's actual empty seed. A candidate supplied with a different
populated capture requires additional real backing and is refused under A when
none is available. Candidate construction cannot hide that capture on the stack
or in unaccounted application storage. A callback/report failure during attach
must follow SPEC-010's existing stale-attachment/rollback rules.

Unrelated host caches must use a current-root route; actual owning tickets remain
explicit. An unowned handle is not evidence that a historical owner has released.
Ownership transfer is requested explicitly by the host, never inferred from
reference counts that are not tracked or from observer detachment.

## Reservation, refusal and cleanup

Reserve a **capture entitlement**, not merely the zero bytes occupied by an
empty candidate. A newly installed analyzer must be able to accept the same
bounded capture updates as the original. Consequently, installing empty B while
independently retained populated A owns the only model bank is refused too;
installation must not succeed only to fail the first normal capture admission.
Two empty metadata records do not promise two simultaneously usable analyzers.

A populated candidate can be initially materialized when it already owns the
model bank and no installed model needs it. An installed analyzer always reserves
its bank entitlement, even while empty; another candidate cannot acquire that
bank merely because the installed count is zero. Identity/duplicate-owner
validation precedes capacity reservation; this policy adds no special
self-replacement semantics.
After a successful transfer, stale A keys fail by generation even though the
physical bytes have not been cleared. Generation exhaustion refuses before commit.

Reservation through attach/commit/discard is one synchronous transaction. No
callback may add owners/pins, start frame reads, mutate either model, or reenter
replacement and invalidate the reserved transfer. The bridge checks these routes;
a callback rejection that invalidates attachment causes ordinary precommit
rollback under SPEC-010. The attach hook may inspect B's actual empty seed within its scoped callback;
it may not retain a reader. Do not infer exclusion just from single-threaded code.
A failure while preparing/attaching preserves A's data, attachment generation,
registration, ownership and dirty state; B's caller-owned seed remains valid.
Transaction-owned reservations and temporary tickets are released exactly once.

Commit activates B and retires A's association atomically, then releases the
explicitly transferred last A ticket. All capacity/generation checks precede
commit. Required detach hooks execute under the same reservation guard; they
cannot invalidate the transfer or acquire an independent owner. A teardown
invariant violation follows SPEC-010's safety-not-proven path, not an invented
rollback of a committed replacement. Detachment
cannot release independent application ownership. Later derivation or drawing
failure keeps the committed B, as required by SPEC-010; it does not resurrect A.
A backend retry does not retain a model read or require another capture bank.
The source and admission banks retain their existing roles throughout.

| Required conformance case | Expected result |
| --- | --- |
| Populated A, no independent retained owner, empty B, all reservations fit | Atomic replacement succeeds; B is empty and owns the model-bank entitlement. |
| Independent populated A remains owned; B needs the model bank | Refuse before attachment/commit; A remains installed and readable. |
| Initially materialized B already holds the sole model bank; no installed analyzer exists | May succeed when metadata/registration/ownership checks pass; no extra bank. |
| Candidate attach reports, metadata/registration capacity is exhausted, or generation cannot advance | Preserve old association and bytes; release candidate-only reservations. |
| Callback tries to invalidate a transfer reservation | Reject the operation; failed attachment cannot commit. |
| Frame reads or staged Canvas are outstanding | Replacement is not admitted; phase/lifetime rules apply before bank reuse. |
| Failure after replacement commit | Keep B; clean up attempt-local readers/payloads. |
| Counter replacement within its two scalar slots | No analyzer-bank dependency; retain the same atomic failure semantics. |

## Decision and remaining proof

**Selected: A, three banks with bounded refusal.** No fourth-bank amendment is
requested. No extra transition storage is charged for a model metadata record.
The earlier conditional K=2 four-bank ledger is not the selected configuration.

The contract above is the proposed realization of the selected policy. Before
RFC approval, validate reservation/attach/rollback and stale-generation behavior
against the actual ownership routes on both profiles, lay out the two metadata
records and tickets, and include them in B2/B3 complete resource accounting.
These are engineering obligations; they do not reopen the capacity choice.
The source/admission/model transition subtotal remains 19,392 bytes, not a claim
that the complete image fits. Existing Specs and production code are unchanged.

No option changes capture horizon, source density, admission capacity, mutation
ordering, domain snapshot meaning, stale-action behavior or owner validity.
