# RFC-014: analyzer capture capacity choice

**2026-10-10 — reviewable choice; awaiting maintainer direction.** Parent:
[RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md).
The maintainer requested resolution of typed access and three-bank ownership,
with explicit choices brought back for decision. This is the capacity choice;
independent access-contract work can continue while it is pending.

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

## Concrete option-A candidate sequence

Model metadata/owner records and transition banks are separate. Propose two
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

## Decision requested

Choose A's bounded-refusal behavior or B's additional capacity as the RFC working
policy. This is necessary because the options change which populated-analyzer
replacement scenarios the selected configuration promises to admit. Choosing B
would authorize preparing the architecture/resource amendment, not automatically
accept it or change production constants. Choosing A would authorize completing
its ownership contract and validation, not claim that the sequence above is proven.

No option changes capture horizon, source density, admission capacity, mutation
ordering, domain snapshot meaning, stale-action behavior or owner validity.
