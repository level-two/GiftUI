# RFC-014 P04 progress

## Independent exit-review dispatch — 2026-10-11

- Slice: separate Strong review of P04, DV-RD-002–004 and applicable retained
  baseline criteria; P02/P03 dependencies passed. Input `593e2cf9`, clean tree;
  implementation range `3a6927c4..593e2cf9`, compiled source `7be2c837`.
- Allowed output: independent findings and P04 exit disposition in this evidence
  directory. Do not implement repairs, change contracts or start successors.
- Context: SPEC-006 runtime records/exact identity and baseline traversal,
  ADR-035/036, the current owner checkpoint/matrix, scoped visitor amendment,
  `spec-006-runtime-record-banks.md`, this receipt and final profile snapshots.
- Review exact identity algebra, paired matching and fanout bound, typed backing
  and borrow lifetimes, complete candidate failure/reader-aware reuse, finite
  payload copying, State binding/read order and independent oracle provenance.
  Verify that pool/physical-bound evidence satisfies the finite P04 exit while
  honestly preserving P05–P12 obligations.
- Fixed expected outcomes are the approved contract, existing independent
  baseline controls and the recorded package exit; passing fixtures alone do
  not establish them. No remaining contract decision is delegated to the reviewer.
- C3/R3 → Strong `gpt-6-astra` / `high`, separate from implementation. Read-only
  inspection and narrowly justified reproductions; reuse valid passed receipts.
  Inspect receipt command arrays for exact reproduction arguments. Do not rerun
  all four routes merely because review uses another agent.
- Commands: `git diff 3a6927c4..593e2cf9`, source/receipt hash verification,
  focused reproductions only for an identified concern, and `git diff --check`.
  Record any added command and its result. Do not claim connected evidence.
- Repair allowance remains **0 of 2** consecutive unproductive attempts;
  switching to review does not reset it. Return blockers to implementation or
  contract/scope questions to the maintainer via the parent. Package exit pending.

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


## Step 3 — actual declaration emission and profile differential

The actual production visitor now has independent expected record/payload tests
for nested State, conditional 3→5→3 topology, UTF scalar decoding, source-order
modifier indices with inner-to-outer payload emission, action-before-label,
unknown-role refusal preserving publication, and State key/model preservation
after repeated bank reuse. Both Static and Dynamic storage execute **57** checks;
primitive bank checks now total **58**, including five-child exact matching with
22 comparisons for 12 prefixes (below N×K = 60). Scoped join checks remain 30.
The native receipt is `step-3-native-receipt.json`.

Measured actual-declaration fixture high water is 5 records, 11 prefixes,
3 payload slots, 2 scalars, depth 9, and 100 payload bytes on arm64 macOS.
These compare with retained logical ceilings 126 records, semantic depth 34,
48 semantic nodes, 14 bodies, 50 modifiers, six actions, and 224 text slots.
The selected component backing has 378 independently bounded prefixes and
98 typed payload slots. This is a conservative envelope, not a measured
application maximum; P08/P09 must measure the real application vocabulary and
P11 must account for full physical fit. The note explains the derivation.

Compiler IR measures record stride 20, prefix 22, component 6, complete key 206,
metadata 48, typed optional payload slot 32 and reference 16 bytes on macOS.
The two reserved component banks total 29,832 bytes, excluding the owner,
Dynamic array headers/allocation overhead, scope descriptors, recursive stack
and codec scratch. A borrowed view cannot escape its callback (compiler rejects
non-Escapable result); this negative is compiled, not just typechecked.

Two fixture corrections were productive: Action construction needed `try`;
and the new same-association State revisit initially expected
`.associationsCommitted`. SPEC-010 table lines 607–608 and 615–616 require
`.unchanged` for an unchanged live set, as already independently checked by
P03 `RuntimeDerived/RootProbe.swift` lines 112–118. The initial failing execution
is `.build/contracts/spec-006-records/tmpy3mx4s2g/macos-static/execute.log`;
LLDB narrowed it to that fixture disposition assertion. Corrected expectations
pass. The preflight additionally guards huge scalar counts before UInt32
conversion, and complete-key export rejects non-role endpoints.
Consecutive unproductive repairs remain **0 of 2**. Four final owner-profile
routes and independent exit review remain open; no owner criterion is closed.


## Step 4 — Embedded finite type witness repair

The first final Embedded route rejected the fixture's `type(of: Text.padding)`
opaque metatype expression (preserved in `step-4-initial-embedded-failure.log`).
The finite codec now uses the inferred `Body` type of an ordinary padding witness
View; it never evaluates that witness or generates occurrences. This preserves
the same role and uses the approved inferred ordinary-body surface.
Targeted nRF object generation/ABI/lifetime/layout checks pass, and the native
rerun still executes 57 + 57 declaration, 58 bank and 30 scoped checks.
`step-4-repair-receipts.json` identifies both artifacts and all source inputs.
The negative driver now requires the exact non-Escapable-result diagnostic,
preventing an unrelated lifetime error from counting as the rejection proof.
This was one productive repair; consecutive unproductive counter is **0 of 2**.
All four registered routes will be recollected against this fixture revision.


## Implementation exit packet — independent review pending

Implementation commits: `36834e01` (scoped join), `7e6fdcd6` (bank/codec
primitives), `c75d3105` (actual declaration/profile checks), `7be2c837`
(Embedded finite witness repair). Dispatch is `3a6927c4`; P02/P03 input is
`40c619dc`. `final-profile-receipts.json` snapshots the four clean-source
`7be2c837` receipts, paired core receipts, exact commands, source/compiler/core
hashes, object/module/executable identities and target layouts. Every recorded
input and artifact hash was reread and matched before this packet was saved.

Sequential final commands, after `scripts/format-swift.sh`:

- `scripts/contracts/run-spec-006.sh --profile nrf52840-embedded --compiler-baseline rfc-014`
- `scripts/contracts/run-spec-006.sh --profile macos-static --compiler-baseline rfc-014`
- `scripts/contracts/run-spec-006.sh --profile macos-dynamic --compiler-baseline rfc-014`
- `scripts/contracts/run-spec-006.sh --profile raspberry-pi-armv6 --compiler-baseline rfc-014`

All four commands passed. Each native route executes 120 P02 assertions, 30
scoped traversal checks, 58 bank checks, and 57 actual-record checks for each
of Static and Dynamic storage. Cross routes compile the selected components,
check ARMv6 or v7E-M/VFP-register ABI, extract layouts and reject the view escape;
they do **not** execute on a target. All four require the exact negative
non-Escapable-result diagnostic. P02 compiler checks remain 28 native/27 cross.

Every measured target has record/prefix/component/key/metadata/payload/reference
strides of 20/22/6/206/48/32/16 bytes and 29,832 bytes for the configured two
reserved record banks. This excludes owner backing, Dynamic allocation/header
overhead, descriptors, independent Interaction keys, codec scratch and complete
feasible-path stack. Actual declaration high water remains 5/11/3/2 records,
prefixes, payloads and scalars, depth 9, 100 payload bytes on native. The
conservative 378-prefix/98-payload envelope preserves approved logical limits;
full application peak measurement and byte/stack budget fit remain P08/P09/P11.

Review boundary: selected current core/State/profile files; a single production
visitor; finite codecs; no generated occurrence tables, retained expanded tree,
second engine, capacity increase or compatibility fallback. P03 Static model
ownership is used by the component fixture in both record profiles. This is not
a full Dynamic model owner, whole-module, application, coordinator atomic join,
Layout/Interaction adapter, Canvas, connected target, broad regression or
allocation/stack certification. Those joins remain P05–P12 as specified.

Required independent Strong review should inspect the dispatch-to-head diff,
approved SPEC-006/013/015 bounds, exact key algebra and paired matcher, typed
backing/reader lifetimes, failure/discard behavior, finite payload copying,
scoped State ordering and the independent test oracles/receipt boundaries.
No missing authority or contract/scope decision was found. No new deferred item
was introduced. Consecutive unproductive repair count is **0 of 2**.
**P04 is not marked passed. SPEC-006 T10.1 and all final owner criteria remain
open through P10–P12.** Parent arranges the separate Strong exit review.
