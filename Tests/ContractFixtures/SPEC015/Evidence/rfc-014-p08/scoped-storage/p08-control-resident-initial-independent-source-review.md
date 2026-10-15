# P08 control-resident initial candidate — independent source review

**SOURCE BLOCKED at `aa36a4ae`: one G03 observation omission.** Review of the
[freeze](p08-control-resident-initial-source-freeze.md), exact manifest/patch and
[approved design](../../../../../../docs/implementation-designs/spec-015-p08-physical-representation-assessment.md)
finds one local coverage blocker below. It is not an architecture decision or an
observed runtime failure. Initial corrections remain **0/2**; this review consumed
no source correction or compiler invocation. No source was edited.

## B01 — blocking coverage: backend completion facts are absent

CounterPipelineOwner.swift:842–881 defines endpoint/slot observations without the
backend submitted bytes/rows, active flag and backend reservation count required
by the reviewed design at lines 397–399. NativeRaster.swift's ownedObservation
adds endpoint reservationCallCount, adapter reservation and glyph header, which
are different facts. CounterRuntimeSlotObservation and the preserved
P08ReuseFingerprint/CounterJoinSnapshot also do not supply those missing backend
fields. Therefore a change confined to backend completion state can compare equal
to the claimed full zero-effect baseline. This does not establish that current
stale guards actually perform such a change; it makes the planned independent
coverage incomplete.

Minimal correction: add pure owned observations of the specified actual backend
active/reservation/submitted-byte/submitted-row fields, and compare them in the
same existing baseline before/after stale operations and duplicate/wrong-owner
checks. Preserve the independent endpoint and lastFrame facts. A small shared
owned backend observation may serve both Native/Tiled; record any additional
completion counters/health explicitly rather than substituting endpoint counters
for target counters. Do not copy a whole active control, retain pointers/callbacks,
refresh the baseline, shorten recording/keys or weaken an oracle. Include a
compiler-free source/observation-field check or equivalent focused regression,
refreeze exact identities and obtain focused reassessment. No new scope/contract
permission is needed for this bounded correction.

## Other reviewed paths

No additional blocker found. The actual production helper lends separate endpoint,
streams, geometry and borrowed semantic formals, with no self/control capture.
Boundary/claim work finishes before the loans; endpoint health/envelope/lastFrame
publication follows them. Native/Tiled offer leaves preserve invalid-envelope,
real-offer, body/reservation and health checks; existing backend leaves address
sibling stored fields. No whole-Control callback mutation or new scoped capability
is introduced. Actual compiler/runtime exclusivity acceptance remains unproved;
the additional projection compiler pair does not replace native execution controls.

Both constructors preserve root provenance before claim and support unbound use.
Checked serial/phase, duplicate/wrong-owner no-effect checks, matching quiescent
clear through both consuming release routes, original logical key nil assignments,
eight host hooks, idle/backend checks and reconstruction/prefix/vacancy guards
match the design. HostState, Interaction, Admission and Wake source are unchanged.
All four complete keys and all 64 recording entries are compared; accepted
lastFrame is independent. No baseline/action/admission/corpus order is weakened.

Layout has one checked 25-region derivation. Its unbounded measurement path only
derives arithmetic facts; actual layout construction still rejects insufficient
storage before binding/initialization, with the per-field bound retained. The
reservation remains old pending measured sizing. Strict decoder byte/tail/relocation
grammar is unchanged. Diagnostic raw facts are written only after all strict proofs,
with accepted=false/no accepted layout before reservation validation. The planned
collecting fresh screen cannot turn expected reservation failure into SO07 success.
Endpoint accounting is relocated to its actual control partition, subtracting its
backend-owned data once in the combined accounting; padding/control/C charges and
actual nested stacks remain future measurement duties, not a fit claim.

Independently verified all 11 source/helper/test before/after hashes, unchanged
contract/C hashes, exact patch and pinned qualification. Eight changed fixture
paths are excluded from seven exact predecessor compilation argvs; counts/digests
53/53/112/173/173/159/172 and eight recorded metadata exceptions match. Executed
only the isolated qualifier: exact positives pass, a newly compiled candidate and
unknown source are rejected. Python AST checks and **27 compiler-free layout tests
PASS**, including unaccepted raw facts surviving reservation failure and no raw
packet on failed byte proof. Also verified 895 compiled/generated-source hashes and 180 core Swift hashes
against the exact original receipts and existing reviewed revision exceptions;
the explicitly recorded Package metadata drift is not a compiled Swift input.
No Swift compiler/build/runtime/image was invoked;
no old counter execution evidence is promoted. Base 384/202, five native controls,
26 reuse labels and separately registered supplemental labels remain.

Bundle B01 within the authorized activity, then reassess; no routine user stop is
needed. Historical budgets remain closed. Source readiness is blocked until that
coverage correction; P08/fit and full-current-source acceptance remain open.
