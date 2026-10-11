# Independent review: callback-local token correction

Reviewed 2026-10-11 by independent Strong Astra 6 Medium at frozen commit
`25806a1e`, under the bounded [scope](scope.md). This is an evidence review,
not P08 package conformance. No compiler invocation or executable run was
performed by this reviewer.

**Reject adoption. The required reachable callback-escape negative compiles
and links for the final token candidate.** The 7/8 bench is closed; the unused
slot does not justify continuing the failed hypothesis.

## Blocking evidence

[Run 7](run-7/result.json) successfully links `CallbackMain.swift` calling
`rejectActiveAfterCallbacks()`. In [the exact negative](run-7/CallbackNegative.swift),
the owner is activated inside the supplying callbacks, assigned to an outer
optional, and used through `runOpportunity()` after every callback has returned.
The token is local to the innermost control-pointer callback. It has an observable
destructor, and the final positive separately observes one destruction.
No lifetime rejection occurs. The accepted negative executable was not run.

This is stronger than the first bench's uncalled internal negative and run 4:
a reachable main invokes the post-callback operation, eliminating absence of a
caller as an explanation for acceptance. It does not establish a compiler root
cause or prove that all possible implementations fail.

SPEC-015 lines 771–775 forbid activation-callback escape. Physical retention of
the enclosing profile cannot extend model/root activation, semantic banks or
Canvas scope: their factory cleanup retires or discards state at callback exit.
The source therefore violates the intended negative boundary even though the
profile allocation still exists. Physical-backing-expiry rejection remains
untested; the prepared backing-negative source has no compiler receipt.

## Positive and scope findings

Runs 2 and 6 compile, link and execute actual runtime opportunities and
quiescence. Run 6 observes the token destructor once after callback completion.
These demonstrate the positive assembly and execution mechanism; they do not
compensate for accepted forbidden escape. Run 3 rejects copying for the original
empty-token candidate only. Run 1 is a setup failure, correctly excluded from
lifetime conclusions.

The supplied structure remains generic over geometry and retains concrete scoped
model/root, semantic and Canvas values. Actual geometry buffers and control
pointee storage remain enclosed by their real lending scopes in the positive.
Coordinator and endpoint construction occurs in activation, not inert setup.
Fixture initializer extensions preserve all original P07 files and do not change
maintained module contracts, compiler features or host semantics.

The token is module-internal in evidence. Any successful maintained pattern must
restrict construction to the trusted callback boundary; an arbitrary longer-lived
token cannot establish backing ownership. The current initializer extensions
consume `InvestigationControl` but store only its raw pointer, while the active
enum retains only the coordinator. Consequently the source has no retained
concrete token/view field in its active state. Whether compiler dependency
refinement at these projections explains the result is an unproved hypothesis,
not a finding or permission to ignore the negative.

This remains a concrete storage-join experiment, not generic `MVPHostInstance`
conformance, complete validation/failure containment, final owner cleanup,
resource accounting, target execution or P08 acceptance. No hardware claims
are supported.

## Evidence integrity and follow-up

All 220 frozen manifest entries match their SHA256 values. The raw receipts,
source snapshots, positive execution records and closed ledger agree with the
author's [result](result.md). Prior evidence and compiler guards are preserved.

The first bench's rejection of adoption remains correct because its mandatory
negative did not reject. Its uncalled source alone should not be read as proof
of a reachable executable escape or compiler unsoundness. This correction now
has reachable negative evidence for both the empty and nontrivial token forms.

A separately bounded retained-data/view anchor experiment is reasonable only
under a new explicit assignment. It must first prove the chosen primitive rejects
a reachable escape, then preserve that actual scoped value through the active
host state and retest the same real join. No approval of that untested mechanism
or expansion of P08 scope is implied by this review.
