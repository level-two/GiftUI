# RFC-014 P04 progress

## Entry and dispatch — 2026-10-11

- Input: `40c619dc`; working tree clean. P02 passed at `53de09c6`; P03
  passed at `15b47e2a`, recorded by `40c619dc` after separate Strong review.
- Package/slice: P04 runtime records and exact identity, implementation pass.
  Governing criteria: SPEC-006 DV-RD-001–004 and applicable baseline criteria
  in owner checkpoint T10.1. No successor package is authorized by this task.
- Allowed footprint: GiftUISemanticCore, Dynamic/Static semantic storage and
  codecs, corresponding tests/fixtures/drivers, narrowly required build wiring,
  the focused representation design note and existing traceability records.
- Read the repository/implementation-executor orientation, bounded sequence,
  task context guide, SPEC-006 runtime amendment and referenced baseline clauses,
  accepted ADR-035/036/037, owner checkpoint/matrix and P02/P03 receipts.
- Source starting points: `GiftUISemanticCore.swift`,
  `DynamicSemanticHostStorage.swift` and equivalent Static realization.
  Test exemplars: `SemanticExpansionTraversalTests.swift` and
  `SemanticExpansionAttemptTests.swift`.
- Independent expected results: actual declaration perturbation changes emitted
  topology without graph generation; exact paths preserve trace/modifier/State
  identity; paired matching has fixed-fanout bounded work; each first-excess
  pool failure preserves publication; borrowed readers prevent bank reuse.
  Prefix/payload maxima must fit approved logical limits.
- Settled decisions: existing typed declaration ABI and lexical State binder;
  exact paths rather than hashes/bank indices establish identity; disjoint
  candidate/published banks; no capacity increase or additional bank.
- Remaining implementation choices: internal record/path/payload representation
  and bounded reconciliation within the approved contract. Strong owns these
  choices and must escalate any contract/scope defect before relying on a change.
- Rating C3/R3: identity, lifetime and atomic bank publication. Strong maps to
  `gpt-6-astra` / `high`; Standard to `gpt-6-sol` / `medium`; Economy to
  `gpt-6-luna` / `medium`. Execution stays sequential. No cheaper assignment is
  dispatched until Strong supplies exact inputs and independent outcomes.
- Checks: `scripts/format-swift.sh`, focused P04 checks to be recorded before
  execution, four owner routes via `scripts/contracts/run-spec-006.sh --profile
  <profile> --compiler-baseline rfc-014` for `macos-dynamic`, `macos-static`,
  `raspberry-pi-armv6`, `nrf52840-embedded`, governance/link validation and
  `git diff --check`. P10 retains the broad hardware-free gate.
- Separate Strong review is required after implementation; implementation alone
  cannot pass P04. Commit each coherent completed step with evidence disposition.
- Consecutive unproductive repair count: **0 of 2**. Preserve the counter across
  handoffs; stop after two attempts without a new pass or narrowed cause.
- Result: dispatched; package exit pending. No contract/scope change requested.
