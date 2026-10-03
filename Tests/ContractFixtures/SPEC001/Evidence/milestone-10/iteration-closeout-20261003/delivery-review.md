# Scope finalization and main delivery review — 2026-10-04

The maintainer requested: “Let’s finalize current scope and deliver work to the
main branch.” This delivery preserves the previously recorded owner approvals
and the SPEC-001/011/015 exceptions; it adds no new feature or hardware work.

All fifteen Specifications are implemented. Accepted ADRs remain unchanged.
The manifest, portfolio, plans, conformance records, and deferred-work links
agree. FW-027/FW-032 preserve performance follow-up; FW-031/FW-033 preserve
connected validation. Full measured MVP conformance is still outstanding.

The top-level README now describes the delivered framework and analyzer hosts.
Current summaries distinguish approved closeout from historical open gates.
SPEC-006 DV-017's checkbox now agrees with its passing criterion row.

## Fresh validation

- `scripts/format-swift.sh` and the gate's formatting lint pass.
- `scripts/test.sh` completed 27 checks: 26 passed; SPEC-002 failed because its
  traceability guard only allowed the pre-closeout `implementing` state.
- Lifecycle guards in SPEC-002/008/014 now accept the approved implemented
  state; SPEC-006/014 conformance guards recognize recorded human approval.
  Criterion, ownership, and behavior checks remain in force.
- The full `scripts/contracts/run-spec-002.sh --profile macos-dynamic` rerun
  passes. All fifteen current macOS-dynamic drivers therefore pass, alongside
  the other twelve repository checks. The original failed row is retained.
- Root tests pass: 298 XCTest tests and 1,160 Swift Testing tests.
- The four affected Ruby checks pass directly. Fresh governance passes with
  164 authority nodes, 1,676 edges, and all registered task evidence valid.
- Both changed shell drivers pass `bash -n`; `git diff --check` passes.
- The earlier immutable four-profile packet retains its 72 passing checks.
  Its SHA-256 was independently verified before delivery.

[Fresh gate and rerun logs](delivery-validation.tar.gz) preserve the initial
results, metadata, individual check logs, and successful SPEC-002 rerun. The
archive hash is in [delivery-validation.sha256](delivery-validation.sha256).
Validation used base `ec77b3faf080517e90ba18c1664501240d892774` plus the
scope-finalization working changes. No connected operation was performed.

## Delivery boundary

`origin/main` is an ancestor of the implementation branch. Deliver the reviewed
closeout commit by fast-forward, preserving the full implementation history.
Do not reclassify failed cadence or missing connected evidence as passing.
