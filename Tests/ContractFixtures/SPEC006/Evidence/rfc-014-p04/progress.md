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

## Step 1 — scoped production traversal join

The existing `SemanticExpansionTraversal` now implements the approved Domain
and scoped accessor ABI. Its body bridge is noncopyable/nonescapable and follows
the actual borrowed State owner lifetime. `ObservableSemanticBodyBinding` uses
P03's existing State binding and model-read operations; Semantic Core still
imports only GiftUI. Binding precedes body-count reservation/evaluation, each
read ends before recursive child discovery, and all traversal helpers stop on
the first semantic, binding or access failure. Access failures remain typed and
separate for the coordinator's SPEC-010 route. The old unscoped entry helper is
removed rather than retained as a compatibility fallback.

`ScopedTraversalProbe.swift` exercises actual generated State witnesses through
the production Semantic Core visitor. Its small test workspace/sink isolates
that join; it is explicitly not record, exact-identity or bank-lifetime evidence.
The fixture uses P03's Static owner even in a Dynamic compiler configuration.
No whole-module, Dynamic storage, application, heap/stack or connected-target
claim follows from this step. Historical baseline callers remain migration work.

Commands: `scripts/format-swift.sh`; both platform `doctor.sh` commands; then
`python3 scripts/contracts/check-spec-006-runtime-records.py --giftui-build <core>`
using the four exact P03-approved core directories in `step-1-receipts.json`.
Pinned Swift 6.3.2 compiles the selected Semantic Core and owner/profile files;
macOS Static and Dynamic configurations each execute 30 counted assertions with zero
failures. ARMv6 and nRF component compilation/ABI checks are recorded separately.
The receipt snapshots include commands, input/compiler/core-receipt identities,
artifact hashes and byte sizes. Sizes are not complete runtime resource costs.

Initial native compilation and every subsequent check passed. Consecutive
unproductive repair count remains **0 of 2**. P04 exit and T10.1 remain open.
Next step: bounded runtime records, exact path pools and paired reconciliation,
then bank/payload realization and first-excess/reader-aware publication checks.


## Step 2 — bounded bank primitives and profile storage

`SemanticRuntimeRecords`, `SemanticRecordStore`, `SemanticRecordExpansion` and
`SemanticStandardPayload` implement typed records/prefixes/payloads, disjoint
banks, exact complete keys, bounded paired matching and the join into the sole
visitor. Static lends caller-owned typed backing; Dynamic owns exactly configured
arrays. The [focused note](../../../../../docs/implementation-designs/spec-006-runtime-record-banks.md)
explains lifetimes, physical versus logical bounds and remaining owner joins.

Targeted native check: `python3 scripts/contracts/check-spec-006-runtime-records.py
--giftui-build .build/contracts/spec-006-rfc-014/f967611596d09deb-vzdyfrzf/macos-static`.
The receipt in `step-2-native-receipt.json` records 55 independent bank checks and
30 scoped traversal checks. The bank fixture covers exact-at-limit/first-excess
records, prefixes, depth, payload slots, scalar slots and payload bytes; prior
publication on failure; fanout; malformed/duplicate paths; roles/modifiers/prefix
inequality; payload-independent exact matches; borrowed retired banks; stale
references and independently copied keys. These are primitive tests: actual
traversal-to-record declaration perturbation is the next step. Both profile
storage files compile, but their full differential execution is not yet claimed.

The first codec compilation failed because InlineArray itself has no
`withUnsafeBufferPointer`; the corrected Span projection passes the same check.
This was one productive local repair. Consecutive unproductive repair count
remains **0 of 2**. Native receipt/source hashes identify the current code; final
four-profile owner routes, negative lifetimes, resource layouts and independent
exit review remain pending. No Spec criterion or package is marked passed.
