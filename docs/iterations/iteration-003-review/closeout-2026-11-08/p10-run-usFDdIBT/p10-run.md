# P10 all-hardware-free run — `run-usFDdIBT`

## Disposition

**P10 remains FAILED / UNMET. Iteration 3 remains active; P08 remains FROZEN / UNMET.**
The required `scripts/test.sh all-hardware-free` command completed all 83
serialized checks and exited 1: 24 passed and 59 failed. The aggregate result
does not prove any of the 189 owner-plan rows. Failure destinations remain split
by actual cause; I4 transfers do not waive the P10 gate.

**Approved bounded dispositions — 2026-11-10.** Eugene approved the exact
SPEC-006 package-SPI clarification and transfer of only the named
`DynamicRuntimeProfileBinding` compatibility path and its lifecycle/differential
tests to I4-07. These dispositions do not alter the archived 24/59 result or
turn any failed execution into a pass. The named transfer remains unmet and
I4 reuse remains blocked until replacement, validation, and independent review.
Other shared Dynamic storage and compile obligations remain in I3.

## Run identity and retained receipt

- Run: `run-usFDdIBT`, recorded revision `c7c7da31c245b7a5afb68ee64d5f57bf2cab12a7`.
- Host selection: `/usr/bin/swift`, Apple Swift 6.3.3; SDK 26.5.
- Command: `scripts/test.sh all-hardware-free`.
- Detailed identity: [run-identity.txt](run-identity.txt).
- Raw report directory at execution: `.build/test-reports/all-hardware-free/run-usFDdIBT`.
- `metadata.txt` SHA-256: `a07a8906380a9555c22303deb3b38ae7342b189c808b1e119cb03d1e6b396716`.
- `results.tsv` SHA-256: `a140241b389f3cde526ee5c755659b2db12e079480c897d387e065164d4e821c`.
- `child-reports.tsv` SHA-256: `f4dd1bb71a09265b167e74f71bdd56f12ba3ace27a15245cfe65090e4c22a72b`.
- [Archived logs, metadata, results and child-report ledger](receipt.tar.gz), SHA-256 `17b8347c1ff26440fc8becfb1029e186da41fa47f9630e61c5684067b1c7292e`.

The result records a dirty worktree at the stated HEAD. The outer runner does
not capture a complete source-tree snapshot; each published child report has
its own declared input and artifact identity where supported. Do not treat this
receipt as clean-tree conformance evidence. Post-run focused checks described
below use the shared dirty working tree, not a reconstruction of the run tree.

| Check group | Passed | Failed | Total |
| --- | ---: | ---: | ---: |
| Fixed checks | 12 | 3 | 15 |
| SPEC-001–015 registered profile rows | 6 | 54 | 60 |
| RFC-014 SPEC-002 and SPEC-006 profile rows | 6 | 2 | 8 |
| **Total** | **24** | **59** | **83** |

The fixed failures are the SPEC-013 macOS Static precheck, `root-tests`, and
SPEC-003 diagnostic-buffer. All four registered SPEC-013 profile checks pass.
The passing registered rows are SPEC-002 nRF and SPEC-014 nRF; RFC-014
SPEC-006 passes on all four profiles and RFC-014 SPEC-002 passes on Pi and
nRF. The exact row ledger is in the archive.

## Failure classification

Every row below is one failed execution from the archived `results.tsv`, assigned exactly one category. A repeated profile failure remains a failed execution; groups describe common causes, not independent defect counts. A downstream check that could not run is not removed from the 59 failures.

| Root-cause group | Failed check IDs (count) | Direct criterion evidence (not a blanket Spec verdict) | Decisive retained evidence | Category | Owner / authority / disposition |
| --- | --- | --- | --- | --- | --- |
| Root tests, diagnostic-buffer, SPEC-001, and the fixed SPEC-013 macOS Static precheck stop before a product verdict | `root-tests`, `spec-003-diagnostic-buffer`, `spec-013-macos-static`, `SPEC-001-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (7) | SPEC-001 owner scope: `SA-AC-001..045`, `SA-RD-001..004`. The fixed SPEC-013 precheck gates `RP-001`; registered SPEC-013 macOS Static is a separate passing execution. The two other fixed checks have no per-AC mapping. | `receipt.tar.gz!/logs/012-spec-013-macos-static.log`, `014-root-tests.log`, `015-spec-003-diagnostic-buffer.log`, `016-SPEC-001-macos-dynamic.log`, `033-SPEC-001-macos-static.log`, `050-SPEC-001-raspberry-pi-armv6.log`, and `067-SPEC-001-nrf52840-embedded.log`: the archived executions stop in package compilation at shared Semantic Core and `SignalAnalyzerView` errors; no complete test result. Current focused Swift 6.4 Semantic Core and all four SPEC-003 diagnostic-buffer configurations pass their isolated tests, while the current filtered package build still stops at analyzer-specific `SignalAnalyzerView` errors. | **Blocked by prerequisite** | The archived failures remain unchanged. The current diagnostic-buffer implementation has focused positive-capacity and conflict-rejection coverage; full package-level checks remain blocked by compilation. Only the analyzer-specific portion follows the existing I4 transfer; no check is transferred wholesale and no product verdict is inferred. |
| SPEC-014 macOS production-corpus prerequisite is blocked by compile errors | `SPEC-014-{macos-dynamic,macos-static}` (2) | Spec scope `BI-001..015`; the driver/reproduction gate `BI-015` and corpus-dependent behavior/resource criteria are blocked, not individually failed. | Retained SPEC-014 reports mark `macos-production-corpus` blocked; the archived run includes `InlineArray` availability and application compile diagnostics. The later approved macOS 26 minimum resolves the availability issue; separate current host-target diagnostics still stop at analyzer compilation. | **Blocked by prerequisite** | The archived prerequisite included both target availability and source compilation. Target policy is resolved; analyzer-owned errors follow I4, while any remaining shared compile issue stays in I3. |
| SPEC-002 Foundation surface checker rejects valid package-interface declarations | `SPEC-002-{macos-dynamic,macos-static}`, `SPEC-002-rfc-014-{macos-dynamic,macos-static}` (4) | No product criterion failure is established by these four checks; they exercise the PF-001..010 public/package boundary, with no per-profile-to-individual-PF mapping retained. | Archived child logs report `public interface exposes package SPI`. The checker applied a blanket `^package ` rejection to the public interface even though retained Swift interfaces contain the expected five public and seven package owners. SPEC-002 defines package visibility as SPI outside the public client API. Exact public/package owner-set comparisons remain in the checker. P10 metadata records Swift 6.3.3 for these macOS profiles, while the approved RFC-014 baseline is Swift 6.4. Later focused Dynamic and Static runs pass with the corrected exact owner-set checker; the four archived rows remain failed. | **Validation infrastructure** | SPEC-002 validation owner. Keep exact public/package owner sets and validate the complete affected profiles after the remaining blockers. |
| SPEC-003/004 host dependency registries lag the approved composition | `SPEC-003-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}`, `SPEC-004-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (8) | No normative AC failure is established by the mismatched list alone: SPEC-003 `FAIL-AC-02` constrains `GiftUIFailureExecution` imports, and SPEC-004 `CR-002` does not prohibit the host's composition-owner dependencies. | Archived reports stop at `GiftUIHostConfiguration dependencies differ`. Current `Package.swift` declares 17 direct host dependencies used by current host source; SPEC-015 permits host composition from approved contract-owner modules. The two fixtures listed only 10. Their expected lists now match the current 17-edge manifest, and both exact dependency checkers pass on `dump-package` output. | **Validation infrastructure** | SPEC-003/004 validation owner. Preserve exact edge checking and the accepted directionality constraints. Eight historical executions remain failed; complete affected profile validation after the other repairs. |
| SPEC-005 generated asset hashes are stale at the gate | `SPEC-005-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | Directly implicated: `TR-004` provenance/build inputs. The fixture manifest and 45-case corpus passed before the hash check; later assertions did not run. | First child report says the generator hash is stale (`expected 8433302f…`, `got 3674e029…`). | **Validation infrastructure** | Text-resource evidence owner; accepted SPEC-005. The refreshed inventory and all four focused hardware-free profile drivers now pass. The four archived rows remain failed. The later SPEC-006 package-surface finding is separate, not the cause of these four failures. |
| SPEC-006 archived action/view-fragment assertions searched stale locations | `SPEC-006-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | The archived assertion intended to cover `DV-001` and `DV-003`; it does not establish those criteria fail. | The archived checker missed `@ViewBuilder` in `LayoutContainers.swift` and expected pre-amendment fragments. Current source contains the generated traversal witness and `visitCustomView`; focused RFC-014 evidence covers that source shape. A separate current package-surface mismatch is a normative contract issue, recorded below; it is not the demonstrated cause of these four historical failures. | **Validation infrastructure** | SPEC-006 validation owner. Keep the archived root cause and four failed rows unchanged. The separate current package-surface decision requires a maintainer choice; checker-only changes cannot resolve it. |
| SPEC-007 consumer allowlist omits an accepted host composition target | `SPEC-007-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | The assertion concerns the module boundary; it does not independently establish `LY-007` failure. | Both imports are in `GiftUIHostConfiguration`; accepted composition allows this host consumer. Added the exact target to the allowlist, preserving exact dependency checks and import-negative cases. Focused boundary check passes with pinned Swift 6.4. | **Validation infrastructure** | SPEC-007 validation owner; no dependency edge was removed and no accepted contract was weakened. Four historical executions remain failed. |
| SPEC-008 checker rejects the equivalent empty-stack guard spelling | `SPEC-008-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | The assertion was intended to cover `RD-003` event order; it does not establish an ordering defect. | Source uses `guard case .none = workspace.currentForeground` before pushing the root foreground and calling `sink.begin`. The corrected focused checker passes. | **Validation infrastructure** | SPEC-008 validation owner; event ordering requirements remain checked. Four historical executions remain failed. |
| SPEC-009 checker misses attributed package fields | `SPEC-009-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | The assertion was intended to cover `EX-001` and `EX-008`; it does not establish missing capture storage. | `CapturedAction` has the required identity and generation fields, each with `@usableFromInline package let`; the old anchored scan ignored the attribute. The corrected exact field scan passes. | **Validation infrastructure** | SPEC-009 validation owner; captured values and no-retained-payload checks remain enforced. Four historical executions remain failed. |
| SPEC-010 checker expects a superseded decorator implementation shape | `SPEC-010-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | The assertion was intended to cover the state binding contract, including `OS-008`; it does not establish a dependency or binding failure. | Current implementation aliases the noncopyable borrowed `ObservableStateRootScope`; `withBoundDeclaration` visits declarations before the body and suppresses the body on binding failure. `ObservableSemanticBodyBinding` performs the typed read. The corrected source checker and `GiftUIObservableState` component build pass, but four later profile reports are fail-closed with `public_contract_compile=pending`, incomplete OS-001..012 evidence, and no conformance verdict. | **Validation infrastructure** | SPEC-010 validation owner; exact target imports, body ordering, and no-retained-declaration checks remain enforced. The focused evidence does not convert the four historical executions into profile passes. |
| SPEC-011 task evidence key set differs | `SPEC-011-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | No normative `IN-*` acceptance criterion is directly shown false; `IN-012` is only the nearest evidence-provenance topic. Owner scope: `IN-001..013`, `IN-RD-001..002`. | Each archived `check-spec-011-harness.rb` invocation failed at `task evidence keys differ`, before a profile conformance result. The current harness now passes with 14 ordered fixtures, 53 task edges, and 13 criteria. | **Validation infrastructure** | SPEC-011 evidence/harness owner; current task inventory is reconciled. The current harness pass is not a full profile result; the four archived executions remain failed. |
| SPEC-012 declaration/value probes were stale against the approved protocol Canvas API | `SPEC-012-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | The archived checks do not establish a product failure; the declaration fixtures used the removed closure initializer and focused profile source lists omitted required framework declarations. | All four current hardware-free profile checks pass: each declaration suite passes seven positive and nine negative fixtures, and each bounded-layout suite passes seven cases using the approved Swift 6.4/compiler targets. | **Validation infrastructure** | SPEC-012 validation owner; fixture/checker sources follow the approved RFC-014 Canvas protocol and current module. These focused fixtures do not replace the complete profiles or rewrite the four archived failures. |
| SPEC-015 profile drivers fail, but the retained records do not distinguish compiler failure from test failure | `SPEC-015-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | Directly implicated only: `HC-016` full profile driver. Other `HC` assertions were not established. `HC-SO-001..003` remain separately restricted under P08. | Archived `logs/030/047/064/081-SPEC-015-*.log` entries are empty. A later focused macOS Dynamic run passes all five input/host-surface stages, then stops at the transferred `SignalAnalyzerPresentation` source errors; this narrows the current failure but does not recover the archived four causes or establish the other three profiles. | **Unclassified** | Historical rows remain unclassified. The follow-up analyzer diagnostics retain their existing I4 destination. Recover or rerun the other profile drivers before reclassifying those historical failures; do not implement a speculative fix. |
| Integrated Pi checks cannot resolve the `linux` destination SDK | `SPEC-002-raspberry-pi-armv6`, `SPEC-014-raspberry-pi-armv6` (2) | No product criterion verdict: failure precedes cross-build/evidence assertions. Spec scopes are `PF-001..010` and `BI-001..015`; Pi composition/resource certification remains separately under I4-AC-013. | Archived child reports show SDK resolution failure. Separate post-run SPEC-002/014 ARMv6 driver receipts pass after the runner invocation was corrected. | **Validation infrastructure** | P10/Pi runner owner. Invocation repair is retained in commit `806c886`; focused receipts do not execute hardware, close I4-AC-013, or rewrite the archived result. |

### Exclusive category totals

| Category | Failed executions |
| --- | ---: |
| Fix now — direct shared/API/package failure | 0 |
| Validation infrastructure — stale checker/registry, generated inputs, fixture/evidence, or invocation | 46 |
| Blocked by prerequisite — no independent product verdict | 9 |
| Transfer — no entire P10 row qualifies; only the named analyzer-specific portion follows the existing I4 transfer | 0 |
| Restricted reuse — no failed row is solely an S1–S3 check; the restriction remains active for affected I4 use | 0 |
| Unclassified — SPEC-015 profile failure details are not retained | 4 |
| **Total** | **59** |

The exact failed identities remain in archived `results.tsv` (SHA-256
`a140241b389f3cde526ee5c755659b2db12e079480c897d387e065164d4e821c`). These
groups reconcile to 3 fixed-check failures, 54 registered profile failures,
and 2 RFC-014 failures. A cause that blocks a later assertion does not remove
the downstream failed execution from the total.

The 24 passes are 12 fixed checks (governance, governance tooling, Swift
format, SPEC-002 compiler baseline, driver registry, nRF topology and source
selection, and SPEC-013 migration, binding, generated fixture, storage, and
nRF checks), 6 registered profile rows (all four SPEC-013 profiles plus
SPEC-002 nRF and SPEC-014 nRF), and 6 RFC-014 rows (all four SPEC-006 profiles
plus SPEC-002 Pi and nRF). Reuse is limited to those exact checks and their
declared inputs; the aggregate does not establish product conformance or
criterion completion.

The 189-row criterion index is a Spec-owner disposition matrix, not a
check-to-individual-criterion map. It contains owner-plan rows for SPEC-001,
SPEC-002, SPEC-006, SPEC-007, SPEC-010, SPEC-011, SPEC-012, SPEC-013, and
SPEC-015; its generic P10 disposition reflects the failed aggregate. For
other Specs, criterion IDs above identify only directly exercised requirements.
An early-exit profile check does not establish failure of every criterion in
its Spec. Existing P10 dispositions remain UNMET until required evidence is
produced.

### Historical smallest follow-up batches and closure recommendation

This recommendation predates the 2026-11-10 maintainer approvals recorded
later in this packet. Its SPEC-006 decision request and named
`DynamicRuntimeProfileBinding` transfer request are superseded by those exact
approvals. The retained compilation, validation, P10, P08, and overall closure
gates below remain in force.

1. **Unblock compilation before drawing product conclusions.** Resolve the
   shared target-compatibility diagnostics, then separate the Signal Analyzer
   compile issue under its split I4 ownership. Re-run blocked fixed/profile
   checks only after those prerequisites are repaired. Analyzer transfer does
   not include shared semantic-core failures.
2. **Repair direct shared-contract mismatches by owner.** The SPEC-007–010
   rows now have focused evidence of stale checker assumptions, not a
   demonstrated source defect. The archived SPEC-006 fragment failures also
   reflect stale checker locations, but the separate current package-surface
   mismatch was a normative contract issue awaiting maintainer disposition at
   the time; its bounded clarification was approved and validated later in
   this packet.
   SPEC-003/004 fixtures now reflect the permitted current composition and
   their exact dependency checks pass. Current SPEC-004 four-profile runs and
   SPEC-003 Pi/nRF runs pass; the SPEC-003 macOS test build remains blocked at
   analyzer compilation. A fresh aggregate P10 run is still required after
   remaining prerequisites and contract decisions are resolved.
   SPEC-002's corrected exact-set checker has focused current macOS Dynamic
   and Static passes; the archived output is not a product SPI failure. Run
   complete affected profiles after the remaining compile and contract
   blockers are resolved, then run the full P10 gate once the inputs are
   ready. For SPEC-015, the original four compiler/test diagnostics remain
   missing; current attempts consistently stop at analyzer compilation, but
   do not retroactively establish each archived failure's cause.
3. **Complete affected validation after the current input repairs.** The
   SPEC-005 asset inventory, SPEC-011 task evidence keys, and SPEC-012
   declaration/value fixtures are reconciled and have focused current passes.
   The SPEC-005 four-profile follow-up below passes with the exact 20-item
   package surface; the earlier 22-versus-20 mismatch is resolved without a
   Spec change. These receipts do not change the archived result or replace
   complete profile runs.

The archived lifetime diagnostics came from Swift 6.3.3, not the approved
Swift 6.4.0 baseline. Subsequent target-26 component builds confirmed that the
shared Semantic Core compiles with the approved compiler, while target-15
failed on `InlineArray` availability. The later approved minimum-platform
change below resolves that availability issue and drops macOS 15 support; it
does not resolve the separate analyzer and Dynamic profile-binding compile
failures recorded in the current diagnostics. At the time of the archived
SPEC-015 failures, child compiler/test diagnostics were not retained. Later
profile attempts reached the same analyzer compile prerequisite, but they do
not retroactively establish the cause of each archived execution.

**Recommendation:** Keep P10 FAILED / UNMET and iteration 3 open. Complete the
bounded shared fixes and validation-input repairs, then run one fresh
`scripts/test.sh all-hardware-free` with a new exact-identity receipt. Do not
mark completion from the 24 passes, post-run Pi checks, or focused SPEC-005
asset checks. Do not reopen P08: it remains FROZEN / UNMET; analyzer-specific
P09–P12 work follows its authorized I4 path; counter-composition certification
follows I4-AC-013; affected I4 reuse remains blocked by S1–S3 until resolved or
replaced with validated, independently reviewed evidence. Other shared
failures remain I3 obligations.

At the time of this report, the maintainer decision was whether to fund the
listed shared/validation repair batches under accepted contracts. The
subsequent SPEC-006 and named I4-07 approvals authorize only their bounded
changes and do not satisfy the other P10 batches. P11/P12, independent overall
freeze acceptance, final accounting/handoff, and human iteration-3 closure
remain separate gates. `R1` compiler allocation-effect failure remains
explicit; the reviewed Native Static no-heap conclusion applies only to its
exact image and predicates.

## Historical pre-approval focused checks

This section records the pre-approval SPEC-006 finding. Its failing checker,
decision-required language, and “no edits” status are historical and are
superseded by the approval and post-approval implementation receipt later in
this file. The archived 83-check result remains unchanged.

### SPEC-006 package-surface follow-up

The archived 83-check run remains unchanged at 24 passes and 59 failures. A
separate pre-approval current-tree run of
`ruby scripts/contracts/check-spec-006-dependency-surface.rb` fails its exact
package-declaration comparison within `GiftUISemanticCore.swift`; this is not
an additional archived execution or a module-wide package declaration count.
The checker expects 17 declarations in that file. It finds 18:
it adds `SemanticBodyEvaluation`, `SemanticExpansionAttempt`, and
`SemanticExpansionTraversalOperations`, while it does not declare the
allowlist-only names `SemanticStateBindingOutcome` and `expandSemanticTree`.
The source instead exports `expandSemanticTreeWithStateBinding`.

The approved RFC-014 amendment requires checked scoped body access and routes
binding/access failures through the SPEC-010 bridge, but does not name the
current bridge declarations ([SPEC-006 RFC-014 section](../../../../specs/spec-006-declarative-view-semantics.md#rfc-014-runtime-amendment)). `SemanticBodyEvaluation` is used by the cross-target `GiftUIObservableState.ObservableSemanticBodyBinding` ([source](../../../../../Sources/GiftUIObservableState/ObservableSemanticBodyBinding.swift)). `SemanticExpansionAttempt` and `SemanticExpansionTraversalOperations` feed package-level `SemanticRecordTraversalRealization` ([source](../../../../../Sources/GiftUISemanticCore/SemanticRecordExpansion.swift)) and the named P08 `CounterSemanticTraversal` fixture ([source](../../../../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterSemantic.swift)); this is fixture instrumentation, not evidence of a second traversal algorithm. The derived comparison scans only `GiftUISemanticCore.swift` ([checker](../../../../../scripts/contracts/check-spec-006-dependency-surface.rb), [allowlist](../../../../../Tests/ContractFixtures/SPEC006/semantic-surface-allowlist.tsv)); the package `SemanticRecordStore.expand` overloads are elsewhere and need separate T6.3 classification. `SemanticStateBindingOutcome` is listed but absent. `expandSemanticTree` is also absent from `Sources/`, but nine current test files still call it, so the tests require an approved adapter or migration. P08 remains FROZEN / UNMET; this note does not change its fixture, accepted SPEC-006/010 text, or the allowlist.

**Pre-approval disposition:** the exact package-surface rule was normative in
accepted SPEC-006, so this was not safely resolved by changing only the derived checker
or allowlist. The historical recommendation and candidate wording are retained in
the [SPEC-006 package-surface decision packet](spec-006-package-surface-decision.md).
The pre-approval read-only review corrected the caller map: the
Roles/Codec/Binding `SemanticRecordStore.expand` overload is used by SPEC-006,
SPEC-007, and SPEC-012 fixtures; the supplied-Traversal overload is used by
SPEC-015 Counter fixtures; neither has production `Sources/` callers. The
production `SemanticBodyEvaluation` consumer is `GiftUIObservableState`; the
production stateful expansion call in `SignalAnalyzerTargetHost` remains
within the existing I4 analyzer transfer. Four record-expansion package
helpers also require explicit classification in a complete target-wide
allowlist. The packet recommended a narrow Spec clarification only if retaining
the present API shape, and otherwise a strict implementation refactor. At that
time, no Spec, source, or allowlist edits had been made. The bounded
clarification and implementation were approved later on 2026-11-10, as
recorded below. This historical issue did not block other retained P10 checks.

- `scripts/format-swift.sh --lint`, changed shell syntax checks, and
  `git diff --check` passed before the final P10 run.
- `scripts/governance/test.sh` passed all 28 tests and 200 assertions after the
  runner's selected Swift identity was recorded without mutating `PATH`.
- Both corrected-baseline SPEC-002 macOS profile drivers pass after the
  Foundation checker correction:
  `scripts/contracts/run-spec-002.sh --profile macos-dynamic --compiler-baseline rfc-014`
  and the corresponding `macos-static` command. They share input-set SHA-256
  `9b9b5c95e6c82721074f726023e83afb727279bf1d1e674ceac1e7405289d814` and run
  ID `806c886ee8d1d06e836565dd624416999bf17ee8-9b9b5c95e6c82721`; their report
  roots are `.build/contract-reports/spec-002/rfc-014/806c886ee8d1d06e836565dd624416999bf17ee8-9b9b5c95e6c82721/macos-dynamic`
  and `.../macos-static`. Metadata hashes are `fc011ef4656ef1f18009df2f004b2555ed99c66cc8da8f2a7a164f5d66c0b1ec`
  and `7c3831cb349284cddaebd5941cf6bebfe0e46814378d1e01f5efec9fc24fb161`.
  These are exact targeted profile passes, not retroactive edits to the P10
  24/59 receipt.
- SPEC-003 and SPEC-004 dependency checks pass against the current package
  manifest after reconciling their host-edge fixtures. The `dump-package`
  input SHA-256 is `7fcd6739ab2f72bd147d22cfd1a80324157e63710121c24d0fbe85f1847a3f8f`;
  both checker outputs are in
  `.build/p10-diagnostics/package-dependencies/checkers.log` (SHA-256
  `05cd6ced87d572f3d92cc0adcd9ef8aad02914ae24a9d1dd6e4cc70861d5d9a1`).
- `scripts/text-resources/verify-reference-generation.sh --verify`,
  `ruby scripts/contracts/check-spec-005-generated-assets.rb`, and
  `ruby scripts/contracts/check-spec-005-reference-generation.rb` passed in the
  shared dirty working tree after refreshing the stale SPEC-005 asset inventory.
- Focused SPEC-012 checks now pass for macOS Dynamic under the approved Swift
  6.4.0 compiler and macOS 26 target. The declaration check passes all seven
  positive and nine negative fixtures; the value-profile check passes seven
  bounded layout cases. The fixture updates replace obsolete `Canvas { ... }`
  construction with protocol witnesses required by the accepted RFC-014
  amendment. The declaration source list now includes the required current
  framework declarations; the interface comparison normalizes the equivalent
  Swift 6.4 `::` module qualification. The module contract checker’s reference
  set now includes the macro witness-table generator and excludes an unused
  dynamic storage reference. Exact logs and outputs are retained under
  `.build/p10-diagnostics/spec012-rfc014-declarations-final` and
  `.build/p10-diagnostics/spec012-rfc014-values-final`; the principal log
  hashes are `0b12080ca35e413651253957192b986446ef30d0574c4c5db3d6c006bfaaadc7`
  and `b18ed77060b3cc27816b7345194e7107733a7514ca8f7e592f00e70dfffe20a6`.
  The macOS Dynamic compiler hash is
  `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`, SDK
  `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk`.
  These checks do not retroactively change the four archived failures or
  establish the other profile checks.
- The same SPEC-012 declaration and bounded-value-layout fixtures now pass on
  the other three current profile compilers. Each declaration run passed seven
  positive and nine negative cases; each value run passed seven layouts.
  macOS Static used the pinned Swift 6.4 compiler at macOS 26.0; Pi used the
  pinned ARMv6 cross compiler; nRF used the pinned Embedded Swift compiler for
  `nrf52840dk/nrf52840`. Outputs are retained in `.build/p10-diagnostics/`
  under `spec012-static-rfc014-{declarations,values}`, `spec012-pi-{declarations,values}`,
  and `spec012-nrf-{declarations,values}`. The common declaration result file
  SHA-256 is `7c1298e1d0541f0e206c57158c9494f0554f27bd6d26263f11b2230673f4ab4e`;
  the common bounded-layout TSV SHA-256 is
  `ac71eccae46c9907a585645b13995ac56849ffe3af7103045bbc48e114bc6dd5`. Compiler
  identity file hashes are `477122d1d8380db21602a7c2caa1fdfd1e92d72c8a7bc03cc4673e1d311d37e6`
  (macOS Static), `8bbe26bafc2f35fb756de5c2a6e43cd2f6931cfd5f0f676ba4c001f59caee2e2`
  (Pi), and `664a009f2377044ff39a232c16156d567fe2f34d3725d539aad2409dece260f5`
  (nRF). These are compiler/fixture checks only, not complete SPEC-012 profile
  conformance or hardware execution, and do not rewrite the four archived
  failures.
- The current SPEC-011 harness check passes with the approved `T12.1` evidence
  task included: `ruby scripts/contracts/check-spec-011-harness.rb` reported 14
  ordered fixtures, 53 task edges, and 13 criteria. The four archived profile
  rows remain failed; this focused harness pass does not establish profile
  conformance.
- Four later SPEC-010 profile-driver runs are retained as focused diagnostics,
  not conformance passes. They were generated at dirty revision
  `d35f434f66c8c5d8b05f1e49852580b73289a4d0`, not `4c21859`. The macOS pair
  shares input-set SHA-256
  `288914e818299424a6dd86082bbba21da9812d39707301981159e840e185b92f`; Pi and
  nRF share `5b4e1da82a678432403932570c3858d6ea4885a35390d8d59313f74016849d35`.
  Each report-generation command exits 0, but each metadata record has
  `public_contract_compile=pending`, `evidence_complete=false`, and all
  `OS-001..OS-012` missing; each log ends fail-closed. The shared run-log hashes
  are `21733676f61ce762f84e031f655d2eb6c329fa36fcf0c68275efe63f79b968f7`
  (macOS pair) and
  `a2260331a1ec9d6a6194fd62d993151cd91d369d3857412dc893e67162598e66`
  (Pi/nRF pair). Commands, metadata, manifests, images, and logs are retained
  in [`spec010-four-profile-focused-runs-2026-11-09.tar.gz`](spec010-four-profile-focused-runs-2026-11-09.tar.gz),
  SHA-256 `b723e7d3b5381e2eccd7deb1292161ce90bfd81d15ae60136c72950763bd2083`.
- Under the approved Swift 6.4 compiler, `GiftUISemanticCore` builds at target
  `arm64-apple-macosx26.0` and fails at `arm64-apple-macosx15.0` with
  `InlineArray` availability diagnostics. The SPEC-015 host-test command also
  stops at the macOS 15 `SemanticStandardPayload.swift:67` diagnostic before
  test assertions. Exact commands and raw diagnostics are retained in
  `.build/p10-diagnostics/shared-core-rfc014.log`,
  `.build/p10-diagnostics/shared-core-rfc014-macos15.log`, and
  `.build/p10-diagnostics/spec015-host-tests-rfc014.log` (SHA-256 respectively
  `c8fc9f10602a628d8f7a688050f92a5804ce25f17c47223e5e347289cc4bb051`,
  `7c86246e91e42a057849c25564204e8441bfc89f1ccf53d3618620bf70796d64`, and
  `f62cb1edca6dd6dcdc65abf025702cc384b1d3013335b647685d4dea4d1d87c7`).
  This confirmed the availability issue at the time of the archived run. The
  later approved macOS 26 package-minimum decision above resolves that specific
  target incompatibility; it does not resolve the other compile failures.
- A fresh focused Static profile test used the pinned Swift 6.4 compiler and
  macOS 26.5 SDK with isolated caches. The command was
  `swift test --disable-sandbox --skip-update --package-path /Users/eugene/work/GiftUI
  --scratch-path /Users/eugene/work/GiftUI/.build/p10-diagnostics/spec013-static-macos26-swift64/swiftpm
  --cache-path /Users/eugene/work/GiftUI/.build -Xswiftc -DGIFTUI_STATIC_PROFILE
  --filter GiftUIRuntimeStaticTests`; it exits 1 during compilation at
  `SignalAnalyzerPresentation/SignalAnalyzerView.swift` with schema inference
  and cascading `View` conformance diagnostics. Raw log:
  `.build/p10-diagnostics/spec013-static-macos26-swift64/run.log`, SHA-256
  `40617734734f53af6bb838e680302cc3ef9d3972cb34e2c8393a3e083c8410e8`. The
  compiler is the pinned Swift 6.4 binary (SHA-256
  `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`); current
  HEAD is `4c21859ba6f43c09a5870de231915a5fc28cfdc8`. This is a prerequisite
  block before test assertions, with the analyzer-specific portion retaining
  its existing I4 destination.
- A separate focused `GiftUIRuntimeDynamic` target build identifies another
  shared runtime compile issue, apart from `DynamicSemanticHostStorage`'s
  analyzer-specific caller. `DynamicRuntimeProfileBinding` still instantiates
  the current `DynamicCanvasCallableStorage<Identity, Table>` with one type
  argument and calls the removed direct stage/invoke/release APIs. This binding
  has no current production constructor/caller, but Dynamic lifecycle and
  cross-profile tests still instantiate it and assert Canvas staging/cleanup;
  SPEC-013 evidence also names the binding. Accepted SPEC-012 allows bounded
  typed Dynamic Canvas storage while preserving value/invoke/release semantics,
  and SPEC-013 requires bounded storage and exact cleanup. Adding a dummy table
  argument or dropping the behavior would not meet that evidence. The concrete
  analyzer-side `DynamicSemanticHostStorage` caller and its table/domain/read
  propagation fall under the existing
  [I4-07 actual-dispatcher residual](../../rfc-015-delivery-allocation.md#accepted-pre-existing-integration-gap-disposition--2026-10-13).
  `DynamicRuntimeProfileBinding` is a separate case: SPEC-013 T3.5 and its
  implementation plan identify it as the current production profile binding,
  but source search finds no current production constructor/caller; tests still
  exercise its staging and cleanup behavior. The shared storage change in
  `6c551bb2` left that path uncompilable. Restoring its full behavior requires
  the table/domain/read plumbing currently assigned to I4-07, while treating it
  as a legacy proof-of-concept requires authority that does not follow from the
  cited generic implementation note alone. This narrow I3/I4 classification
  remains unresolved pending maintainer disposition. The generic bounded
  storage contract and unrelated shared compile failures are not transferred.
- The SPEC-002 Foundation checker was corrected to rely on exact public and
  package owner-set comparisons rather than rejecting every `package` line in
  the public interface. Against the retained Dynamic and Static interface
  pairs, the focused checker reports five public and seven package owners; this
  does not alter the four archived failures or certify the RFC-014 compiler
  baseline. Checker SHA-256: `5cf27dacb6ec757efd0598472f148a5209d8efe3aeb415c46e69a19f081f7c42`.
- Focused SPEC-007–010 source checks pass after narrow checker updates against
  the accepted/current source shapes. Commands:
  `PATH="$PWD/.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin:$PATH" CLANG_MODULE_CACHE_PATH="$PWD/.build/p10-diagnostics/clang-cache" ruby scripts/contracts/check-spec-007-boundaries.rb`
  plus `ruby scripts/contracts/check-spec-008-foreground-semantics.rb`,
  `ruby scripts/contracts/check-spec-009-admission-values.rb`, and
  `ruby scripts/contracts/check-spec-010-binding-decorator.rb`.
  SPEC-007 reports four exact targets and 12 import-negative categories;
  SPEC-008 verifies the empty-stack guard, foreground push, and begin ordering;
  SPEC-009 verifies the identity/generation pair; SPEC-010 verifies the
  noncopyable root-scope binding route and target-wide import set. Checker
  hashes are `3e263c2aec928d0cb07c74b7d5d8da190153d5e63a7fe70f2bb12e5eda6c2e0c`,
  `86247b0365fd43097856c4c6ed435698846703a48ca8554b8cb43b4327b4aa23`,
  `a4ac52be49781742c76401e7c699095b3c68a58cc7ae40018d93dc94041d6466`, and
  `23d37589177aa8bbf6e69868976ebb86a3e8febded7aa493869f7fbfcab71526`.
- A focused build of `GiftUIObservableState` with the approved Swift 6.4.0
  compiler and `arm64-apple-macosx26.0` target passed. The compiler binary
  SHA-256 is `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`;
  the exact output is retained at
  `.build/p10-diagnostics/observable-state-rfc014-build.log` (SHA-256
  `48181d7f5ef79b2ad4606e4461f1f1361a3aa185197d612505263ac8c92b88dc`). It
  emitted warnings for private setters referenced from `@inlinable` functions;
  there were no compile errors. This is a target-26 component build, not a
  complete SPEC-010 profile run. The later approved minimum-platform change
  resolves the former macOS 15 deployment question.
- A filtered package test at the same target did not reach test execution:
  compiling `SignalAnalyzerPresentation` failed in `@ObservableStateHost`
  expansion (`Schema` inference and `View` conformance). Its diagnostic log is
  `.build/p10-diagnostics/observable-state-focused-tests.log` (SHA-256
  `76c990b4350891a5d9bc13f9f34577c20a73f73ecdf5130e42449a6fb405f9c6`). A
  target-only build of `GiftUIObservableStateTests` then isolated stale test
  declarations that instantiate `State<Model>` for `_GiftUIObservableReference`
  models and use the removed `wrappedValue:` initializer; the current API
  requires `_GiftUIModelSchema`. Its diagnostic log is
  `.build/p10-diagnostics/observable-state-target.log` (SHA-256
  `d4ed32f2de678918c3732f595c4b2ef6753901d47678dd453be35ec7e024ad79`). No
  unit-test assertions ran. These diagnostics cross the frozen P08 API
  transition and are recorded without changing that implementation or its
  accepted disposition in this P10 checker-repair batch.

These focused checks do not replace the archived P10 result. The 180 P10
owner-matrix rows and nine scoped-ownership rows remain dispositioned in the
[189-row criterion index](../criterion-dispositions.csv). P08 remains frozen;
affected I4 reuse stays blocked under the approved S1–S3 restriction. P11/P12,
the independent overall freeze acceptance, final handoff, and a human
iteration-3 closure decision remain separate gates.

## Post-run targeted profile checks

The following focused drivers were run after `run-usFDdIBT` to diagnose and
repair its Pi SDK-selection failures. Both are cross-compilation/evidence
checks; neither executes on hardware.

| Check | Result and identity |
| --- | --- |
| `scripts/contracts/run-spec-002.sh --profile raspberry-pi-armv6` | Passed, exit 0. Report: `.build/contract-reports/spec-002/434f163b44f10835acb1c27fc78c1536c301c73a-be71904ba3a2b547/raspberry-pi-armv6`; input-set SHA-256 `be71904ba3a2b5472afb3dbbf87f936da81b149c967dec804f0cb7cce5fcc089`; `metadata.txt` SHA-256 `17d63743f7d4684d7f3a907349c528e507966ef8a5895f691604a9f6b520c721`. The corrected command uses `--build-system native`, explicit `--target GiftUI`, the project `.build` cache, and `--skip-update`. |
| `scripts/contracts/run-spec-014.sh --profile raspberry-pi-armv6` | Passed, exit 0, `blocking_count=0`. Report: `.build/spec-014/reports/434f163b44f10835acb1c27fc78c1536c301c73a-d68a9b94db670db3-20261108T201245Z-24504/raspberry-pi-armv6`; input-set SHA-256 `d68a9b94db670db3e6374fdc5117862bc017fab7f93c89fdacefd2873d4869f5`; `metadata.txt` SHA-256 `6cfb1601062553370fce4754d34219b9d4c77bada0a18c4e27c1af7943fd9ceb`. |

The compact committed report receipts (metadata, command list, input-hash
manifest, report-hash manifest, and driver log) are retained in
[`post-run-targeted-receipts.tar.gz`](../post-run-targeted-receipts.tar.gz),
SHA-256 `36d58dc61057dd2d2e70d05e2faa8f33483af927528f398ac07c8ff729f8bd0b`.
The Pi runner source hashes used
by these post-run executions are `15adf2102a810abf3b2536703ce211d2cdaa2901937e31c31751b21a1d340e71`
for `scripts/contracts/run-spec-002.sh` and
`e6dbd490831d09240304943ad75a9a5be6bfa5e52bc2ad3658652fd832ca4d46` for
`scripts/contracts/collect-spec-014-armv6-evidence.sh`.

The SPEC-002 runner now uses SwiftPM's native build system and explicit target
selection for both compiler baselines; the SPEC-014 ARMv6 evidence collector
also requests the native build system. These targeted passes are recorded as
post-run diagnostics, not retroactive changes to the 83-check receipt. The
focused SPEC-005 failure is retained in
[`post-run-targeted-receipts.tar.gz`](../post-run-targeted-receipts.tar.gz)
(input-set SHA-256 `8d0e9bdf6929e98957550ca35fb8d5fc9a585d4cfb058ad9936f04c5ef3d643f`;
metadata SHA-256 `8f9f44f899f12df24d2cef893e9b6cf739a77a073771bda799f3c3cd082dbb0b`;
`run.log` SHA-256 `52d3f0cebce826ac94ffbe1e9380f4ce2f2f9a31821e8f6f178eb2a393b1b45b`).
It ran in the shared dirty worktree; only the reports and hash manifests are
archived, not a complete source snapshot. It shows the exact-surface failure
after 22 declarations; P10 and the affected criterion rows remain unmet.

## Post-report platform-minimum decision — 2026-11-09

After this report was prepared, Eugene approved raising the package minimum to
macOS 26. The retained macOS 15 InlineArray availability blocker is therefore
resolved by an explicit support-boundary change, not by a compatibility-storage
implementation. `Package.swift`, the host environment preflight, maintained
macOS compiler-check targets, and SPEC-001/013/015 are aligned to macOS 26.0;
the host preflight also requires Xcode 26 or later for the matching SDK.
macOS 15 support is dropped; Raspberry Pi ARMv6 and nRF52840 targets are
unchanged. This decision does not alter the archived P10 result: it remains 24
passes and 59 failures, and the failed checks must be classified and validated
under the current baseline before P10 can pass. P08 remains FROZEN / UNMET;
analyzer migration and composition certification retain their I4 destinations,
and S1–S3 restrictions remain in force.

## Focused SPEC-015 macOS Dynamic follow-up — 2026-11-09

The approved Swift 6.4 compiler at `arm64-apple-macosx26.0` ran
`scripts/contracts/run-spec-015.sh --profile macos-dynamic` in the shared dirty
worktree. The SPEC-015 harness, negative-corpus, source-boundary,
generated-workload, validation-purity, and host-surface checks all passed. The
subsequent filtered `GiftUIHostConfigurationTests` build stopped in
`SignalAnalyzerPresentation/SignalAnalyzerView.swift` on `Schema` inference and
View-conformance errors. That analyzer-specific source work retains its I4
destination; this focused run is not a complete profile pass and does not
reclassify the four archived SPEC-015 failures.

The run exposed and corrected a package-validation setup issue: the `GiftUIDrawing`
and `GiftUIHostConfiguration` SwiftPM targets use the RFC-014
`LifetimeDependence` and `Lifetimes` features but lacked those target settings.
The focused host-surface checker now resolves `swift`/`swiftc` from the same
selected toolchain and accepts both SwiftPM product-module layouts. Its direct
run passed all exact package API and negative-compile assertions.

The partial profile receipt is retained in
[`spec-015-macos-dynamic-followup.tar.gz`](spec-015-macos-dynamic-followup.tar.gz),
SHA-256 `bdad9b6fb653b99884c871a093f0e1493915c43222fd280e0940f0a3790d2d9a`.
It contains the exact command list, combined driver log, and host-surface report.
The compiler is the project-local Swift 6.4.0 `swiftc`, SHA-256
`79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`; SDK
version is 26.5. Changed input hashes: `Package.swift`
`d0565f06d47d169cb58dba7dc9b209c06ea90a8d7ddce6bd4b9910b987531640` and
`scripts/contracts/check-spec-015-host-surfaces.sh`
`b14077ad672d6d6e2a111955c225722a1984c8422e7d40c28a32912d812e3378`. The run
was recorded from revision `33690346` with dirty sources;
it is focused diagnostic evidence only. It does not alter the archived 24-pass,
59-failure P10 receipt, close P08, or change the I4 and S1–S3 restrictions.

## Current SPEC-003 and SPEC-015 diagnostic follow-up — 2026-11-09

These later diagnostic attempts do not change the archived 24-pass/59-failure
result and are not profile-conformance receipts. Their raw logs are retained
in [`focused-current-diagnostics-2026-11-09.tar.gz`](focused-current-diagnostics-2026-11-09.tar.gz),
SHA-256 `df994abb7021e87b4fe63d00b1659ac01ad00f67741b5e871a669bf5ce811ce0`.

The current SPEC-003 macOS Dynamic driver passed its fixture, profile-corpus,
dependency, execution-correlation, integration, and Core-boundary checks. Its
filtered SwiftPM test build then failed while generating a dSYM with
`Operation not permitted`; no test assertions ran. That raw log is
`spec003/run.log` (SHA-256
`f60e9b5de0c6d7c38f294baa02fe6e01d42916b19e6039e9909b18b1e3430db7`); the
raw SwiftPM output is `spec003/complete-suite.raw.txt` (SHA-256
`33fcac86f7c5bbca71ff09e53aff7c034259f9784d55844494125ee3a7b83a06`). The
exact command ledger SHA-256 is
`2f455bc905bdfefe33274a6613d02f48dad15b5ad8bd9a531452baa1d10479b2`, and the
input manifest SHA-256 is
`8399e22c4980c57b3106f7cebe62b4c26c6c4b619fc11619474217d32c454854`. These
attempts show that the earlier dependency-list repair is not sufficient for a
full SPEC-003 profile pass; they do not establish a new SPEC-003 product
failure.

A follow-up with the same filtered suite and SwiftPM's
`-debug-info-format none` option moved past the dSYM stage but stopped on the
already-transferred `SignalAnalyzerPresentation/SignalAnalyzerView.swift`
compile errors (`any Canvas` cannot conform to `View`, and a `Text` generic
parameter is unresolved). No test assertions ran. This distinguishes the
original dSYM tooling failure from the current package-wide analyzer compile
prerequisite; it does not transfer the separate `GiftUIRuntimeDynamic`
specialization error into analyzer ownership. The command, metadata, and raw
output are retained in
[`spec003-macos-dynamic-no-debug-followup-2026-11-09.tar.gz`](spec003-macos-dynamic-no-debug-followup-2026-11-09.tar.gz),
SHA-256 `d903ded0f28b801ce5d1035bbd4b9d315c6673a2465bdb9420ae43efa8d9e1e6`;
the raw log SHA-256 is `2e07c190b6551cf50bb3fc88229595b418d281ecad80e4e29031a1c7199d1faf`.

Four later SPEC-015 host-target build attempts—macOS Dynamic, macOS Static,
Raspberry Pi ARMv6, and nRF52840 Embedded—each passed the current harness,
negative-corpus, source-boundary, generated-workload, and validation-purity
stages, then stopped while building `GiftUIHostConfiguration` at the same
`SignalAnalyzerPresentation/SignalAnalyzerView.swift` schema-inference and
View-conformance errors. Each also passed the package API, noncopyable
conformer, Sendable value, and negative compile host-surface checks. The host
target was compiled for arm64 macOS in each attempt, so these are not
embedded-device executions. All four logged
`-DGIFTUI_DYNAMIC_PROFILE`, so they are not evidence of profile-specific
validation. The logs are
`spec015-macos-dynamic-host-build.log` (SHA-256
`52d42cd23751e5fc102b8cab7dc3f5fe2936d96c44ee0645a58f265612b36607`),
`spec015-macos-static-host-build.log` (`ad6eeba65475b635587723bbc1860d80168d3d54ed281498c498af90984e8b46`),
`spec015-pi-host-build.log` (`74a7b2acf7955185280c120a5e0c6493900514b3c1481ad5046b26fbfc05c0b5`),
and `spec015-nrf-host-build.log` (`35194d9bf58cc65f45618c21a481bd5d2fa41d28f68a631407f4d1febef8268f`).
This current diagnostic points to the already-authorized I4 analyzer work; it
does not recover the missing original child diagnostics or rewrite the four
archived failed rows. The separately observed Dynamic Canvas storage API
mismatch remains a shared runtime compile blocker and is not included in the
analyzer transfer. The shared issue was independently reproduced by a focused
`GiftUIRuntimeDynamic` target build under the approved Swift 6.4 toolchain and
macOS 26 target. It fails at the one-argument `DynamicCanvasCallableStorage`
specialization before target tests run; its raw log is
`dynamic-runtime-canvas-target.log` (SHA-256
`7511b0a283a36850a95d3d9485f8f3205e5ae0ab8af9aa93cbc3a25c08ca7ad4`).

## Current SPEC-003 Pi and nRF profile follow-up — 2026-11-09

The current Pi and nRF SPEC-003 profile drivers now pass after two narrow
validation-command repairs. The Pi driver selected SwiftPM's Xcode build
system for its Linux SDK and failed with `unable to resolve run destination
SDK: 'linux'`; it now explicitly requests the native build system, matching
the accepted SPEC-002 runner pattern. The nRF driver omitted `-package-name
GiftUI` from direct compiles that use package SPI; adding the package identity
to those module, object, probe, and resource-support commands resolves the
Swift 6.4 compiler's explicit package-name diagnostic. These runner-only
repairs changed no product source or accepted API contract.

| Profile | Result / run ID / input-set SHA-256 | Metadata SHA-256 | Driver log SHA-256 |
| --- | --- | --- | --- |
| Raspberry Pi ARMv6 | Passed, `efe8a406ec3412cf6844246b3e61847d2107a6be-7ca8e3ed9ed8de47` / `7ca8e3ed9ed8de4747e20ec6ce50ee3f577a939a48f3bef5f0216e028aff6a28` | `12a644b96e3ef22f4f6ce34503b2ac0e59fe801f6aff1718baed821f5ee7ba7b` | `4001baa321070f2cb5d6b93626cc49a6ddb52d6c2e9e5212760f1aa5e80f75ed` |
| nRF52840 Embedded | Passed, `efe8a406ec3412cf6844246b3e61847d2107a6be-1e6580b92efad838` / `1e6580b92efad838948ee4dac27de691c06138ff8136528a93805812f2290028` | `8a3d08f6674a63ed8433201d17411ee7ade63463ff7e0fa986da26bccf0a250f` | `b875d839f6b9614a9888c5ac188a70284de1c30bad5df5e09ad6bd04e5329c77` |

The updated runner SHA-256 is `28542f29e424675cb6503683977b05baaf2571717fb67bfe5901721a30c1fc8c`.
The compact current run receipts (metadata, commands, source-input hashes,
driver logs, image/report hash manifests, and layout results) are retained in
[`spec003-pi-nrf-current-runs-2026-11-09.tar.gz`](spec003-pi-nrf-current-runs-2026-11-09.tar.gz),
SHA-256 `0d5b8f86f985028ad070c2bad2f622a823c547f81f3ce5bda392fdcae96d9c97`.
Both are cross-compilation and resource-evidence runs only: no Pi deployment,
nRF flashing, or hardware execution occurred. These two current profile
passes do not rewrite the corresponding archived failed executions or clear
the remaining SPEC-003 macOS test-build prerequisite.

## Current SPEC-004 four-profile follow-up — 2026-11-09

The corrected SPEC-004 dependency fixture now passes its full focused profile
driver on macOS Dynamic, macOS Static, Raspberry Pi ARMv6, and nRF52840
Embedded. All four use input-set SHA-256
`9f8d905fc37188caa4b61fea663bc4474ad58b683dbf233b398e0bc95a8f8449` and run
ID `efe8a406ec3412cf6844246b3e61847d2107a6be-9f8d905fc37188ca`. Both macOS
profiles use the pinned Swift 6.4 compiler at macOS 26.0 / SDK 26.5; the
embedded profiles use their pinned ARMv6 and nRF52840 toolchains. The compact
reports retain commands, input manifests, driver logs, image/report hash
manifests, and capability layout outputs in
[`spec004-four-profile-current-runs-2026-11-09.tar.gz`](spec004-four-profile-current-runs-2026-11-09.tar.gz),
SHA-256 `be001d16e41109e541968fefd7c6a769d15c57ad9b731822791eacf982cfecd1`.
The four current runs validate the repaired exact host-dependency fixture and
profile resource checks; they do not change the four archived SPEC-004 failed
executions or the archived P10 count of 24 passes and 59 failures. Neither
embedded profile was deployed, flashed, or run on hardware.

## Current SPEC-005 four-profile follow-up — 2026-11-09

After a bounded validator hardening, the current SPEC-005 driver passed on all
four hardware-free profiles. The archived P10 counts remain 24 passes and 59
failed executions; these current receipts do not retroactively change that
run. They use the project-local Swift 6.4.0 compiler (SHA-256
`79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`). Both
macOS profiles target `arm64-apple-macosx26.0` with SDK 26.5; Raspberry Pi
cross-build targets `armv6-unknown-linux-gnueabihf`; nRF cross-build targets
`armv7em-none-none-eabi` for `nrf52840dk/nrf52840` on Zephyr 4.3.0. Neither
embedded profile was executed on hardware, deployed, or flashed.

The shared source change saturates the validator's payload callback count at
two. SPEC-005 requires exactly one callback for a valid available payload; a
second or later invocation must remain rejected rather than allowing a
wrapping `UInt8` counter to return to one. The nRF check initially exposed a
stale compiler-label assumption: it required a compiler-generated
`OUTLINED_FUNCTION_16` name for the exact four-instruction callback epilogue.
The corrected checker accepts any numbered outlined label only after it
verifies those same exact instructions at the referenced target. The failed
first attempt is preserved under `.build/contract-reports/spec-005/.tmp-nrf52840-embedded-77760/`;
the direct checker recheck passed before the fresh profile run.

| Profile | Current run ID / input-set SHA-256 | `metadata.txt` SHA-256 | `run.log` SHA-256 |
| --- | --- | --- | --- |
| macOS Dynamic | `4c21859ba6f43c09a5870de231915a5fc28cfdc8-deb6fb9959bd2e21` / `deb6fb9959bd2e21cd961f6553a96ba2bd66f18586da2812ab06ad3ad9a71a73` | `f2901483e180267c176ce53395e4d059d90dc9904dfb99426e5da00419888ded` | `69cdcd304745cf433aa764a28da81fc1ef96fcdf248eb698d3108eebe7f04dd6` |
| macOS Static | same / same | `49894a3b65d4042ff189f77b82cb8bde962ccfcb422b559258e7b805008d5de2` | `4404b127ab6254f0db3ca49ec3aa03c79e73a01611e63e76daee22d438a4961d` |
| Raspberry Pi ARMv6 | same / same | `19873129e10128f9c076c22afbca50ea26d4443f9027e8f97c9d2cb7dc83f8e0` | `1c8243694e4117d3edb5bd79f20470c88031f92477e55a17a839166eb5dcb7e6` |
| nRF52840 Embedded | `4c21859ba6f43c09a5870de231915a5fc28cfdc8-6c26dbe9f27d9205` / `6c26dbe9f27d9205e0bf7f150009f5490443213e31fbfe4a71a4d7a8cbb1ecc0` | `47ee0ac45bc0688b01e17fc9ee7fb7a8e15390abbcc7fbfa57f3324e6698e0a3` | `09bb3b54135511b08387ccf5950a19d7e074c1f678501d5d86974a2c10556670` |

The first three profiles share an input set containing the saturated counter
change. The nRF input set additionally binds the corrected
`scripts/contracts/check-spec-005-nrf-resources.rb` checker (SHA-256
`38b5dfa1293f76aa445577b9e31eeb0b640186e456e5c67c2d82e37fa0d800c3`). The
nRF check reports zero RAM delta, 28,832 bytes flash delta, and 716 bytes
maximum stack for the qualified resource path. These focused SPEC-005 passes
do not satisfy other P10 rows or change P08's FROZEN / UNMET state.

## Approved disposition and implementation packet — SPEC-006 surface and SPEC-013 Dynamic binding

The two bounded changes were approved by Eugene on 2026-11-10, with the exact
approval wording recorded in
[`spec-006-package-surface-decision.md`](spec-006-package-surface-decision.md).
Their implementation changes derived checks and named test call paths but do
not change the archived P10 result (24 pass / 59 failed). P08 remains FROZEN /
UNMET; the supplied-Traversal P08 route and S1–S3 restricted-reuse condition
remain in force.

### Choice A — SPEC-006 package surface

**Approved scope:** clarify that the requirement is one shared bounded
traversal engine with the exact audited typed adapters described below. The
accepted clause records this approval. A checker-only edit remains
insufficient; the full interface/member inventory, delegation checks, and
caller classification must pass.

The bounded compiled inventory was generated with pinned Swift 6.4.0
(`79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`),
`arm64-apple-macosx26.0`, and SDK 26.5, once for each Dynamic/Static profile
define. The two package interfaces are byte-identical (SHA-256
`210fba09a4c627ea2c16552aa6ceb50ed72d8981fbb335e63a25135c0fa4469d`): 51
top-level package declarations and 533 source/test/fixture reference rows.
The compiled declaration index is
[`spec006-compiled-package-top-level.tsv`](spec006-compiled-package-top-level.tsv);
the reference map is
[`spec006-compiled-package-reference-map.tsv`](spec006-compiled-package-reference-map.tsv).
Full interfaces, exact expansion signatures, compiler log, input hashes,
and reproduction parameters are in
[`spec006-spi-inventory-2026-11-10.tar.gz`](spec006-spi-inventory-2026-11-10.tar.gz),
whose SHA-256 is `7540cf3a2ea0ede761935eb14b65b347b6aba5e18d536ffbdb0a4fac1c8150e8`;
the inventory manifest SHA-256 is
`7cc1e3c773cd207da5797cc975fa6bc14a944fd458d539dd280c52a409977099`.
The interface command emitted a library-evolution warning because it did not
use `-enable-library-evolution`; this is an exact package declaration snapshot,
not a stable library ABI claim. The reference map counts textual references;
production roots and fixture invocations are separately classified in the
linked SPEC-006 decision packet.

The approved amendment preserves one traversal engine, all bounds,
identity/order/failure semantics, transaction behavior, bind-before-body
ordering, backend independence, no-allocation requirements, and failure
routing. It permits only the enumerated declarations in the compiled
inventory: the state-bound expansion/result bridge; typed record-store
adapters and scoped constructors; and their named layout/render/record,
recording, runtime-identity, bank, and payload package contracts. No
unlisted package declaration is permitted by wildcard. The
`SemanticRecordStore.expand` Roles/Codec/Binding adapter has SPEC-006/007/012/013
fixture callers and no production caller. Its supplied-`Traversal` sibling
has SPEC-015 Counter fixture callers, also no production caller; that P08 path
is not generally authorized and retains the S1–S3 restriction.

The absent `expandSemanticTree` spelling is called by nine test files. The
approved migration uses the existing `expandSemanticTreeWithStateBinding`
with a test-only empty-domain binding for stateless cases and the existing
Observable State binding for tests exercising state. All success, limit,
first-excess, ordering, failure, reentrancy, and recording assertions remain.
The derived checker compares the complete target package interface, including
nested package members, to the exact archived snapshot and rejects unlisted
declarations or members. Its source and compiled-interface checks pass. The
nine test files have been migrated. The Semantic Core and Drawing test targets
build and their focused tests pass; the Dynamic target remains blocked by the
separately transferred compatibility binding, so that target's assertions
have not run.

The alternative is the strict refactor: remove extra package entry routes,
move fixture-only adapters out of production SPI, migrate tests to the single
accepted entry, and preserve typed failure and record-fixture semantics. This
is not a checker-only repair. The full candidate wording and exact interfaces
are in the linked SPEC-006 packet. The compiler-generated snapshot resolves
the earlier inventory gap, but it does not itself amend the Specification.

### Choice B — `DynamicRuntimeProfileBinding` compatibility route

**Approved disposition:** Eugene approved transfer of only this named
compatibility binding and its binding-specific tests to SPEC-013 T3.5 / I4-07,
with reuse blocked until the route is replaced or adapted, validated, and
independently reviewed. The current compile failure remains failed evidence,
not a pass. Keep the general bounded `DynamicCanvasCallableStorage` contract
and its storage/invocation tests in I3.

Current-source inventory finds no production constructor or caller of
`DynamicRuntimeProfileBinding`; only
`DynamicRuntimeExecutionBindingAdapter` and tests reference it. The retained
focused compile diagnostic is in
[focused compile diagnostic](dynamic-profile-binding-focused-compile.log)
(its durable copy is in the focused diagnostics archive above): it instantiates
`DynamicCanvasCallableStorage<DynamicStructuralIdentity>` with one type
argument although the current generic requires a `Table`, and calls removed
`stage` / direct `invoke` / `release` APIs. This is a compile prerequisite
failure, not a failed runtime assertion.

The approved transfer covers the binding-specific assertions in
`DynamicProfileBoundaryTests.swift`:
`dynamicBindingUsesCommonLifecycleAndOwnsAttemptCleanup` (shared lifecycle,
reentrancy refusal, reservation, Canvas staging, attempt reset and release
counts) and `dynamicBindingDefersActiveQuiescenceThenTearsDownOnce` (deferred
quiescence, terminal teardown and idempotence). It also covers the Dynamic
binding side of `ProfileDifferentialTests.swift`'s
`dynamicAndStaticBindingsProduceEqualCanonicalTranscripts` and
`dynamicAndStaticExecutionCoordinatorsUseTheCommonProtocolSeams`; those
cross-profile assertions must be retained through an adapted replacement,
not dropped. Relevant implementation/evidence references are SPEC-013 T3.5,
RP-001, RP-004, RP-005, RP-011 and RP-012, and
`Tests/ContractFixtures/SPEC013/Evidence/milestone-3/dynamic-profile-binding.md`.
The RP criteria themselves are not waived; any affected I4 reuse remains
blocked until equivalent evidence is accepted.

The approved transfer is limited to the named binding API and its
compile-dependent tests, because it has no current production caller. It does
not transfer `DynamicSemanticHostStorage` table/domain/read propagation
(analyzer-specific work already assigned to I4), generic Dynamic Canvas
storage, unrelated runtime/shared compile failures, or broad SPEC-013 profile
conformance. The remaining I3 obligations include generic Dynamic Canvas
storage and its bounded-order, exact-invocation, and reject-after-release
tests, unrelated shared compilation, and broad SPEC-013 profile conformance.
The transferred binding lifecycle and differential assertions remain I4
obligations.

**Approved outcomes:** the exact SPEC-006 clarification and bounded
migration/check delta are approved. The named Dynamic compatibility route is
transferred to I4-07 with affected reuse blocked. Neither changes P08 status,
S1–S3, the analyzer migration boundary, archived counts, or the requirement
for independent validation.

## Historical approval proposal (superseded by the approved outcomes above)

The following proposal text is retained to show the decision basis. Its
requested-choice and proposed-implementation wording is historical; the
approved outcomes and current focused status above and below control.

### SPEC-006 approved package SPI clarification

The current accepted SPEC-006 §“Bounded expansion” requires the expansion entry
to be the sole generic package operation over `Root`, workspace, and sink.
RFC-014 does not relax that rule. The completed Dynamic/Static compiler
interface snapshot removes the earlier incomplete-inventory caveat: 51
top-level package declarations (the two `withSemanticRecordStore` overloads
are separate rows) are indexed in
[`spec006-compiled-package-top-level.tsv`](spec006-compiled-package-top-level.tsv),
and 533 source/test/fixture text-reference rows are classified in
[`spec006-compiled-package-reference-map.tsv`](spec006-compiled-package-reference-map.tsv).
The source map is reference evidence, not a substitute for its caller-kind
classification. Full signatures, exact engine operations, compiler command,
all input/output hashes, and the compiler warning are in the linked inventory
archive and manifest above.

The approved clarification preserves one engine and unchanged semantic
behavior, but permits the exact enumerated current SPI categories: the
state-bound expansion entry/result; the typed record realization adapters and
scoped store construction; and supporting expansion, recording,
layout/render, record identity/bank/payload contracts needed across package
targets. The 51-row TSV is a top-level navigation index, not a complete member allowlist. The exact candidate set is the complete compiled interface snapshot, including nested package members; the derived checker must compare all declarations and members against a normalized inventory of that full snapshot, with no prefix or wildcard allowance. The only direct production invocation of
`expandSemanticTreeWithStateBinding` in `Sources/` is the analyzer-specific I4
pipeline; the state-binding implementation is supplied by
`GiftUIObservableState.ObservableSemanticBodyBinding`. Both
`SemanticRecordStore.expand` overloads have fixture callers only. The supplied-Traversal overload remains under the
P08/S1–S3 restricted-reuse boundary and gains no general authorization.

The migration covers the nine files that called the absent
`expandSemanticTree`: `SemanticDeclarationCorpusTests`,
`SemanticExpansionAttemptTests`, `SemanticExpansionTraversalTests`,
`SemanticExpansionValueTests`, `SemanticLayoutResultAdapterTests`,
`SemanticRecordingSinkTests`, `SemanticReentrancyTests`,
`DynamicSemanticHostStorageTests`, and `CanvasInvocationAdapterTests`. Stateless
cases use a test-only empty-domain `SemanticStatefulBinding` through the
existing entry; stateful cases retain the Observable State binding. The
success, bounds, ordering, failure, reentrancy, and recording assertions stay
intact. Focused compile and test results are recorded below; the archived
P10 execution remains unchanged.

The approved Spec clarification and exact declaration inventory/check/test
delta are recorded in the Spec and implementation plan. The exact Spec text
and authority analysis are in
[`spec-006-package-surface-decision.md`](spec-006-package-surface-decision.md).

### SPEC-013 `DynamicRuntimeProfileBinding` bounded I4-07 transfer

Current source has no production constructor or caller of
`DynamicRuntimeProfileBinding`; its only adapter is
`DynamicRuntimeExecutionBindingAdapter`, also used only by the named tests.
The retained Swift 6.4 macOS 26 focused diagnostic
([log](dynamic-profile-binding-focused-compile.log), SHA-256
`b6c5ce2d695f89a8e51cc8351f81812d5dc280f9c0b08656b6877a1530b78a59`)
shows this binding still specializes `DynamicCanvasCallableStorage` with one
type argument where the accepted typed storage requires two, and calls removed
stage/direct-invoke/release operations. The adapter has associated escaping
lifetime diagnostics. This is a compile prerequisite failure; no runtime
assertion ran. Separately, `DynamicSemanticHostStorage` has a typed table/domain
integration gap already assigned to I4-07; it is not included in this
transfer.

**Approved disposition:** Eugene explicitly transferred only this
compatibility binding, `DynamicRuntimeExecutionBindingAdapter`, and its named
test obligations under SPEC-013 T3.5 / I4-07 on 2026-11-10. Affected I4 reuse
remains blocked until the route is replaced or adapted, validated, and
independently reviewed. This exact approval resolves transfer authority for
this named route only; generic Dynamic Canvas storage and unrelated shared
compile failures remain I3 obligations. No SPEC-013 criterion is waived and
the compile failure is not a pass.

Affected code and assertions are:

- `DynamicProfileBoundaryTests.dynamicBindingUsesCommonLifecycleAndOwnsAttemptCleanup`:
  profile/audit identity, opportunity exclusivity, reservation, Canvas stage,
  attempt cleanup and release counters.
- `DynamicProfileBoundaryTests.dynamicBindingDefersActiveQuiescenceThenTearsDownOnce`:
  deferred quiescence, refusal, terminal teardown, and idempotence.
- The Dynamic side of `ProfileDifferentialTests.dynamicAndStaticBindingsProduceEqualCanonicalTranscripts`
  and `dynamicAndStaticExecutionCoordinatorsUseTheCommonProtocolSeams`; preserve
  the cross-profile comparison using a reviewed replacement rather than
  deleting its assertions.

This route touches implementation task T3.5 and evidence/criteria RP-001,
RP-004, RP-005, RP-011, and RP-012. The criteria remain outstanding until
replacement evidence is accepted. The general bounded
`DynamicCanvasCallableStorage` contract, its direct bounded-order/invocation/
release tests, other shared compile failures, the analyzer-specific
`DynamicSemanticHostStorage` propagation, and all unrelated Dynamic profile
conformance stay in I3 or their already-authorized owner. This candidate cannot
transfer a new shared regression under the current RFC-015 disposition unless
the maintainer explicitly resolves that classification. It is not a transfer
of generic Dynamic Canvas storage.

**Alternative:** retain this compatibility route in I3 and adapt it to the
current typed-table and scoped lifetime contract, preserving every listed
lifecycle and differential assertion. Because the current scoped `withLifetime`
API does not match the binding's separated stage/invoke operations, the
alternative needs an explicit lifetime-safe replacement design; do not add a
dummy table argument or weaken the assertions.

### Historical pre-approval choice and consequences

This was the combined decision request before approval and is retained as
historical context. On 2026-11-10, the maintainer approved the bounded SPEC-006
clarification and the exact `DynamicRuntimeProfileBinding` I4-07 transfer
recorded above. That approval does not alter the archived P10 receipt, waive
other shared regressions, or establish a current full-gate pass. P08 remains
FROZEN / UNMET, S1–S3 reuse remains restricted, and overall iteration-3
closure remains a separate decision.

## Focused post-approval validation — 2026-11-10

These current focused results do not replace or edit the archived 83-check run.

- The changed Semantic Core test target builds with pinned Apple Swift 6.4
  (`arm64-apple-macosx26.0`, SDK 26.5) on macOS 26.6.2. It passed 58 XCTest
  cases and 15 Swift Testing cases. This includes the restored stateful test
  that binds seeds 3 and 5, reads both through `FrameRead`, and confirms
  bind-before-body, plus the `Body == Never` pre-evaluation guard. The
  stateful `Body == Never` branch has the same guard in source but is not
  independently runtime-tested. Logs:
  [`semantic-core-build.log`](focused-2026-11-10/semantic-core-build.log),
  [`semantic-core-tests.log`](focused-2026-11-10/semantic-core-tests.log).
- The changed Drawing test target builds and passes 43 Swift Testing cases,
  including static Canvas table dispatch, ordering, and failure behavior.
  Logs: [`drawing-tests-build.log`](focused-2026-11-10/drawing-tests-build.log),
  [`drawing-tests.log`](focused-2026-11-10/drawing-tests.log).
- The focused `GiftUIRuntimeDynamicTests` target build still fails at
  `DynamicRuntimeProfileBinding`, which supplies one generic argument to
  `DynamicCanvasCallableStorage` where the current API requires two. This is
  the exact named I4-07 transfer; no Dynamic test assertion ran. Log:
  [`dynamic-runtime-tests-build.log`](focused-2026-11-10/dynamic-runtime-tests-build.log).
- A filtered package test did not reach execution because compilation stops in
  `SignalAnalyzerView.swift` at the analyzer-specific schema inference and View
  conformance errors. This remains with the approved I4 analyzer migration;
  it does not transfer shared Semantic Core or make the run a pass. Log:
  [`aggregate-semantic-filter.log`](focused-2026-11-10/aggregate-semantic-filter.log).
- The SPEC-006 source and exact compiled-interface checks pass. The compiled
  check compares the complete pinned Dynamic/Static Semantic Core package
  interface and current GiftUI interface; 21 added exact underscored references
  (32 total) are reviewed against their current owners/uses. The SPEC-012 static Canvas
  manifest check passes: three generated cases, four occurrence records, and
  14 negative build-time rejections.
- The SPEC-003 diagnostic-buffer module builds independently for all four
  selected capacities (0, 8, 16, 64) with pinned Swift 6.4. For each
  capacity, the `GiftUIFailureDiagnosticsTests` target built independently
  and its test bundle passed all six XCTest cases when run with `xcrun xctest`
  (24 case executions total). The mutually selected 8+16 capacity build also
  failed with the required `select exactly one GiftUI diagnostic-buffer
  capacity` diagnostic. The generator `--check` passes. These are focused
  target results, not a fresh complete P10 run; the archived fixed
  diagnostic-buffer execution remains a failure. The build command was
  `swift build --target GiftUIFailureDiagnosticsTests -Xswiftc
  -DGIFTUI_DIAGNOSTICS_CAPACITY_<capacity>` with the pinned toolchain at
  `.toolchains/p08-comparison/expanded/swift-6.4.0-RELEASE-osx/swift-6.4.0-RELEASE-osx-package.pkg/Payload/usr/bin/swift`;
  each build used isolated scratch and module-cache paths under
  `.build/p10-focused/diag-test-*` and `.build` as the package cache. The
  resulting test bundles ran directly with `xcrun xctest`; the pinned
  toolchain's `libTesting.dylib` was placed into each ignored build bundle.
- Strict Swift 6.4 formatting/lint on changed maintained Swift files and
  `git diff --check` pass. These results are against the current dirty working
  tree. They are not a fresh all-hardware-free gate or profile conformance
  receipt. The archived 24 pass / 59 failed counts remain unchanged.
- Short governance validation passes: `build-authority-graph.rb --check`
  reports 221 nodes / 2,128 edges. The SPEC-006 compiled check output and
  normalized report, SPEC-006 source-check log, SPEC-012 check log, formatting
  log, and authority-graph log are retained beside the focused test logs.

Focused logs and check receipts are retained with these SHA-256 identities:

| Log | SHA-256 |
| --- | --- |
| `aggregate-semantic-filter.log` | `50069e69ea15f5da7ba66e0b2104e46d18beafadcc1809fff5126efb189d16ae` |
| `drawing-tests-build.log` | `c09e788d6976c4cc3584be9aa733bed19fa6229f9de8b1c7efbf75947daa7a70` |
| `drawing-tests.log` | `a279a036c4cda7f5a4ce15a34cec71e470061c5a96d96f66a0be89d751d64994` |
| `dynamic-runtime-tests-build.log` | `374af651e5ef85db2ef875ba1782a59b43b8997e312060ec253be4a7eb886447` |
| `semantic-core-build.log` | `3c59ddbf8159647bc6032cad51ccec61903018559d0c762f4ece4c5e5fe88602` |
| `semantic-core-tests.log` | `f4dec32ee24ed8707b3f8328e5ed4b25cb31144647e6d4fe65375f6d32dda9aa` |
| `spec006-compiled-check.log` | `0a54744385c5dc8501d5ded0e2f02b0087f15c6a6f3f63f7329f68e7ef849d8c` |
| `spec006-compiled-report.tsv` | `b254e88e545e0de0b2d37e81577699bc530976b256510af3f8dc2fe52d035c35` |
| `spec006-source-check.log` | `2faf9d64f224587378874e1d95e9fa90c79d03c3e4050e2bef131c9ea70b00f4` |
| `spec012-check.log` | `deb945bf798b14a63d5aa3f68a647163787e69b17ff944403fa6355f77149c62` |
| `authority-graph-check.log` | `cceffe9b638f74af9c355aaa567f672b720d1574f9a491619e95cec35db07945` |
| `format-lint.log` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `spec003-diagnostic-capacity-zero-build.log` | `645428ecfdf9e8e13a16a0428b051d9491781f7b6dfed930f882f2f8e3a19e26` |
| `spec003-diagnostic-capacity-8-build.log` | `675a33f10aed644aaf7b4991000ff55fddeae7fff4344bdcc46ede588d0498b0` |
| `spec003-diagnostic-capacity-16-build.log` | `a4463b48df2e6e9d6eb055c88a94ec37d2934d20e9816b47879139e54a68208d` |
| `spec003-diagnostic-capacity-64-build.log` | `17dc0e77b933b8a0e6cd260c1e92318706288011f5a7aae70873d827f57390e5` |
| `spec003-diagnostic-generator-check.log` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `spec003-diagnostic-capacity-zero-tests-build.log` | `1ae9ffd2bff215c95f4df47128cd5d1dd6e2c6bedd37aca2410b5d4fa9447994` |
| `spec003-diagnostic-capacity-zero-tests.log` | `bce91a6688644e719623f3b6be288ff2e52b89f13f75fec0fef941ed1219b0e9` |
| `spec003-diagnostic-capacity-8-tests-build.log` | `44e71ee59f25ec380c6a2b83ca8235448bfde160e522346705fd30c1bd57ed4c` |
| `spec003-diagnostic-capacity-8-tests.log` | `657b4c1e4add5a1933c1d071497324f4b2a3ed69483590852df438dd2afd742c` |
| `spec003-diagnostic-capacity-16-tests-build.log` | `74e9c782cbc3672636e4826f994e5df068e4538f6b12f7aa4e0d344d6630f833` |
| `spec003-diagnostic-capacity-16-tests.log` | `f77472cc71d13041dc86c7b79aabebf5396a8ea402891a4633438c1ccef32197` |
| `spec003-diagnostic-capacity-64-tests-build.log` | `719ca446935b54128de7a0d1e39ff8d8650efa05b67a57c255e43df5ce301950` |
| `spec003-diagnostic-capacity-64-tests.log` | `ad5c16b0d652747bcaaf086ca426efd696323ebf88fae26dc63af37952bbb0a4` |
| `spec003-diagnostic-conflict-build.log` | `b6b4a13e03fc380a99f453254f669acd2a1b7b9dadb4bd2ad8865ea16f64ec41` |

## Earlier fresh integrated run, superseded — 2026-11-10

The `run-MM4217u6` result below is retained historical evidence. It is
superseded as the latest integrated run by `run-DqItCC6l`, recorded at the end
of this document.

The fresh command `GIFTUI_SWIFT_EXECUTABLE="$PWD/.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swift" GIFTUI_SWIFTC_EXECUTABLE="$PWD/.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swiftc" scripts/test.sh all-hardware-free` completed as **FAILED / UNMET: 56 passed, 27 failed of 83 checks**. This is a new integrated execution; it does not rewrite the historical 24/59 result above. It ran on the dirty worktree at HEAD `ba03d1a342187a4b79fe2fa28c6e785419461b94`; tracked-diff fingerprint at run start was `2e33459c3ed283956c89e8eca38a6d08924157cea1b3c783730791f1ce6dc475`. The pinned Swift 6.4 driver and compiler both hash to `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`. SwiftPM child invocations also used the local P08 comparison expansion of Swift 6.4.0; no global toolchain or target was changed.

| Profile group | Pass | Fail | Total |
| --- | ---: | ---: | ---: |
| macOS Dynamic | 10 | 7 | 17 |
| macOS Static | 10 | 8 | 18 |
| Raspberry Pi ARMv6 cross-build | 12 | 5 | 17 |
| nRF52840 hardware-free build | 12 | 5 | 17 |
| Common checks | 12 | 2 | 14 |
| **Total** | **56** | **27** | **83** |

The 27 failed rows are `spec-013-macos-static`, `root-tests`, `spec-003-diagnostic-buffer`, SPEC-001 (four profiles), SPEC-003 macOS Dynamic/Static, SPEC-007 (four profiles), SPEC-008 (four profiles), SPEC-011 (four profiles), SPEC-014 macOS Dynamic/Static, and SPEC-015 (four profiles). The exact names, exit codes, child-report references, and raw logs are in the receipt directory below.

Failure disposition stays attached to the actual causes. Analyzer schema-inference and `View` conformance errors block analyzer-dependent package and fixture compilation and remain on the approved I4 analyzer migration. The SPEC-001 compiler output also reports current shared Semantic Core associated-type lifetime constraint errors (`cannot suppress Copyable/Escapable requirement`); this is a retained shared compile blocker, not covered by the analyzer transfer. SPEC-007 fixture schemas and import boundaries pass, but its conformance reports are incomplete. SPEC-008's failure corpus passes; the macOS Dynamic rendering build then fails in `dsymutil` with `Operation not permitted`, while the other profile executions remain failed in their profile-specific reports. SPEC-011 reaches its exact declaration/migration checks but currently fails differing declaration/evidence/consumer inventories by profile. SPEC-014 macOS reports retain one analyzer-blocked incomplete prerequisite each. SPEC-015 remains failed across its four profiles; these results do not alter its prior approved named DynamicRuntimeProfileBinding I4-07 transfer or transfer the general shared runtime contract.

Bounded fixes exercised by this run include the SPEC-002 sandbox/profile invocation correction (all nine SPEC-002 checks pass), the SPEC-008 current generic Text probe spelling, and the SPEC-011 current consumer and selected-toolchain/scratch handling. The SPEC-008 runtime evidence build still has an environment-level `dsymutil` failure; this is retained as a failure, not waived. SPEC-007's incomplete reports and SPEC-011's remaining exact-surface/evidence mismatches are still actionable retained P10 work. No failed row is reclassified as passing, and no P08 proof campaign or hardware execution was run.

P08 remains FROZEN / UNMET. S1–S3 reuse remains blocked pending resolution or replacement plus validation and independent review. Analyzer-specific work remains transferred to I4; counter-composition certification remains I4-AC-013. General shared-runtime obligations, SPEC-007/008/011 failures, the shared associated-type lifetime compile blocker, overall freeze acceptance, retained accounting/conformance, and the separate human iteration-closure decision remain open. The gate is not complete.

The exact run command, `metadata.txt`, `results.tsv`, `child-reports.tsv`, and compressed raw `logs/` are retained in [`current-run-MM4217u6`](current-run-MM4217u6/). Receipt hashes:

| File | SHA-256 |
| --- | --- |
| `metadata.txt` | `fc3bbe48cf67d14c34d088f22384e01c2f882ae439bd3bcd62dea281d6b9aa7e` |
| `results.tsv` | `ba62ca78b7dc10f88e6a3be85ddeecc6546deb8bcb2858c8b5a75ac1e24ac3a4` |
| `child-reports.tsv` | `bdeb75400bb6493ee436139774f0d6554b4c7de1a24e6927e5ec4f90cff27b82` |
| `logs.tar.gz` | `d2caba022167ed39a7aa90270f30eb6a06489bed94b1968ad3bb013e0f5fe6c6` |
| `command.txt` | `db9abf22d3cccd6c7bbecee8458532f48f0448962cb70e56656c6e3d252f3424` |

## Superseded integrated all-hardware-free run — 2026-11-10

The prior `scripts/test.sh all-hardware-free` run was `run-DqItCC6l`. It
completed all 83 serialized checks and remains **FAILED / UNMET: 60 passed,
23 failed**. This result superseded `run-MM4217u6` at the time; both runs and
their raw receipts remain preserved. It is superseded by `run-v8GRC8xq` below.
Profile-group totals
are macOS Dynamic 11/6, macOS Static 11/7, Raspberry Pi ARMv6 13/4, nRF52840
13/4, and common checks 12/2 (pass/fail).

The exact command was:

```sh
GIFTUI_SWIFT_EXECUTABLE="$PWD/.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swift" \
GIFTUI_SWIFTC_EXECUTABLE="$PWD/.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swiftc" \
scripts/test.sh all-hardware-free
```

The run used HEAD `ba03d1a342187a4b79fe2fa28c6e785419461b94` with a dirty
worktree. Its retained source-identity receipt explicitly says it does not
contain a complete dirty-source manifest. Both Swift driver and compiler are
the pinned local Swift 6.4.0 binaries, SHA-256
`79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`; no global
toolchain selection changed. The command, metadata, result ledger, child-report
ledger, raw logs archive, and stated source identity are under
[`current-run-DqItCC6l`](current-run-DqItCC6l/).

The 23 failed checks reconcile to three causes:

| Cause | Failed checks | Disposition |
| --- | ---: | --- |
| Shared Semantic Core associated-type constraints rejected by Swift 6.4 | 5: SPEC-001 in all four profiles and `spec-003-diagnostic-buffer` | Retained shared compile blocker. Do not weaken noncopyable/nonescapable visitor and binding constraints without a separately approved contract change. |
| Analyzer schema inference / `View` conformance compilation | 14: `spec-013-macos-static`, `root-tests`, SPEC-003 macOS Dynamic/Static, SPEC-011 in all four profiles, SPEC-014 macOS Dynamic/Static, and SPEC-015 in all four profiles | Analyzer-specific failures remain on the approved I4 migration destination. Their raw executions remain failed; the transfer does not waive other checks or imply a full P10 pass. |
| SPEC-007 conformance lifecycle is incomplete while P08 is frozen | 4: SPEC-007 in all four profiles | Product fixture/schema checks pass, but the conformance report is still collecting and plan active. Do not mark the feature complete while P08 is FROZEN / UNMET. |

This run has zero failures in SPEC-008. Its four focused hardware-free profile
receipts also pass after the collector fixes; those targeted receipts are
supporting evidence and do not retroactively change earlier failed runs. The
run did not produce a clean-worktree source snapshot, a P10 pass, a P08 pass,
or an iteration closure. Existing S1–S3 restricted-reuse blocks, I4-AC-013
counter-composition certification, P11/P12 evidence, overall freeze review,
and the separate human iteration-closure decision remain unchanged.

Receipt SHA-256 values:

| File | SHA-256 |
| --- | --- |
| `metadata.txt` | `85d0e77583f7546596be16fe523b407197413e91737ededb5472a497ef719355` |
| `results.tsv` | `7eb14fab9286984ed2fb9abd369b427c64d848f15e16d12851f4392af883b3d4` |
| `child-reports.tsv` | `ac0c954ca5efdc9552f63aa576276ccac8cca29b7773088cec9da2a7b300b9b7` |
| `logs.tar.gz` | `ef4c6b288debaef1d52b85f52c1fc1ffb34f1f9e47273007ee5aaced4b1fdde6` |
| `command.txt` | `db9abf22d3cccd6c7bbecee8458532f48f0448962cb70e56656c6e3d252f3424` |
| `source-identity.txt` | `af749657d3ce9850cfe687123ca1ece79660c8d858b1c6af1e934cd1f89359ef` |

## Latest integrated all-hardware-free run — 2026-11-10

The latest `scripts/test.sh all-hardware-free` run is `run-v8GRC8xq`. It
completed all 83 serialized checks and remains **FAILED / UNMET: 55 passed,
28 failed**. Profile-group totals are common checks 12/3, macOS Dynamic 11/6,
macOS Static 10/7, Raspberry Pi ARMv6 10/7, and nRF52840 12/5 (pass/fail).
The exact command, metadata, result ledger, child-report ledger, and raw logs
archive are retained in [`current-run-v8GRC8xq`](current-run-v8GRC8xq/).

The run used HEAD `3f7558be20907767e9816477fac2b6604d80422e` with a dirty
worktree. Its metadata does not contain a complete dirty-source manifest, so
the run is tied to its revision, project-local toolchain identity, and raw
execution receipts, not claimed as a clean-source snapshot. The pinned
project-local Swift 6.4.0 driver and compiler both have SHA-256
`79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`; no
global toolchain selection changed.

The 28 failed executions group as follows:

| Root cause | Failed executions | Criterion and authority disposition |
| --- | ---: | --- |
| Analyzer/workload prerequisite | 20: `root-tests`, SPEC-001 in four profiles, SPEC-003 diagnostic-buffer and macOS Dynamic/Static, SPEC-011 in four profiles, the SPEC-013 macOS-static prerequisite and macOS Static/Pi/nRF workload reports, and SPEC-015 in four profiles | The top-level run logs show `SignalAnalyzerView.swift` schema inference and `View` conformance failures; the SPEC-013 profile prerequisite is `signal-analyzer-workload`. These are failed executions, not 20 independent product defects. The corresponding owner rows remain UNMET in the 189-row index. Only analyzer-specific implementation work follows its approved I4 destination. No entire P10 check or shared criterion is transferred or waived. The SPEC-015 failures do not show that its separately transferred Dynamic compatibility binding caused these failures. |
| Mixed SPEC-014 nested profile prerequisites and compiler mismatch | 2: SPEC-014 macOS Dynamic and macOS Static | Both nested reports contain `SignalAnalyzerView.swift` and `SemanticRecordExpansion.swift` diagnostics. Their metadata selects Xcode Swift 6.3.3, although the outer P10 run pins project-local Swift 6.4.0. The reports are dirty and their `input-hashes.tsv` files omit `SemanticRecordExpansion.swift`; those diagnostics are not bound to source bytes and do not establish a defect under the approved Swift 6.4 baseline. Retain the failed executions and owner criteria as UNMET. The analyzer-specific portion follows its existing I4 destination; the nested compiler selection/source-identity mismatch is validation infrastructure, not a whole-row transfer or waiver. |
| SPEC-007 conformance lifecycle remains collecting while P08 is frozen | 4: SPEC-007 in all profiles | Current report lists LY-001..009 as passing on its older evidence, but RFC-014 amendment criteria LY-RD-001/002 remain unchecked and the current plan keeps T9.1/T12.1 open. The current check fails its completion/status guard; the actual Specification is `implementing`, plan `active`, report `collecting`. This is a substantive open conformance/lifecycle gate, not a checker-only reason to promote status. Do not mark the Spec complete or weaken the criterion. |
| Pi profile invocation/cache environment | 2: SPEC-005 and SPEC-006 ARMv6 | Both integrated executions failed in sandbox/cache setup. Separate focused reruns with the approved project-local Swift 6.4/ARMv6 toolchain passed; they support those targeted validations but do not retroactively change these P10 execution rows or the aggregate. No individual criterion failure is inferred from the integrated environment errors. |

The exact failed execution IDs partition into the groups above as follows; the
hash-pinned `results.tsv` remains the canonical source for each exit code and
log path.

- Analyzer/workload prerequisite (20): `spec-013-macos-static`, `root-tests`,
  `spec-003-diagnostic-buffer`, `SPEC-001` in macOS Dynamic, macOS Static,
  Pi ARMv6, and nRF52840; `SPEC-003` in macOS Dynamic and macOS Static;
  `SPEC-011` in all four profiles; `SPEC-013` in macOS Static, Pi ARMv6, and
  nRF52840; and `SPEC-015` in all four profiles.
- Mixed SPEC-014 nested reports (2): `SPEC-014` macOS Dynamic and macOS
  Static. Both use Xcode Swift 6.3.3 rather than the enclosing run's approved
  project-local Swift 6.4.0 compiler and omit `SemanticRecordExpansion.swift`
  from their source hash lists. They include both analyzer and SemanticRecord
  diagnostics; retain the failures, but do not treat the nested diagnostics as
  verified defects under Swift 6.4.
- SPEC-007 lifecycle (4): `SPEC-007` in macOS Dynamic, macOS Static, Pi ARMv6,
  and nRF52840.
- Pi environment (2): `SPEC-005-raspberry-pi-armv6` and
  `SPEC-006-raspberry-pi-armv6`.

The first two groups are failed executions, not 22 independent product
defects. The Signal Analyzer-specific implementation cause follows its approved
I4 destination; downstream test/report failures remain failed P10 executions
and their owner criteria remain UNMET. The nested SPEC-014 compiler/source
identity mismatch does not waive those executions. The separately named
Dynamic runtime binding in SPEC-015 has its own narrow I4-07 transfer. The
remaining shared criteria and all lifecycle failures remain I3 obligations.
The two Pi rows are environment failures with separate focused passes, not
retroactively passing integrated rows.

The nested SPEC-014 report snapshots are retained under
[`nested-spec014`](current-run-v8GRC8xq/nested-spec014/). The Dynamic attempt
`3f7558be…-c039585c…-20261110T203627Z-4950` has metadata SHA-256
`a177017d…cf28d6a`, run-log SHA-256 `74bca3cf…9d6a75b`, and input-hash-list
SHA-256 `c039585c…a08835d`. The Static attempt
`3f7558be…-c039585c…-20261110T204211Z-12114` has metadata SHA-256
`451d218f…181be36`, run-log SHA-256 `f99779cd…fad4dd`, and the same input-hash
list. Both metadata files identify dirty worktrees and Xcode Swift 6.3.3;
neither input list contains `SemanticRecordExpansion.swift`. The source hash in
this P10 record identifies the current working file only and is not a
substitute for a missing historical input hash.

Exact failed IDs and exit codes remain in `results.tsv`; raw per-check logs are
inside the retained archive. Receipt SHA-256 values are:

| File | SHA-256 |
| --- | --- |
| `metadata.txt` | `d0253fecfd220d5f7663ac533208e270533adb6e92e5dbc0892a112fe10a7381` |
| `results.tsv` | `1ba48aaadb67bd9c396e04661c55948d332ed37d27b0738f26682fbd450ea0d9` |
| `child-reports.tsv` | `e28cc7a7cf09f2cfe64c59642b309625589459fb1e4d4dcecf13d1da02945565` |
| `logs.tar.gz` | `94d3974f9ab9e5a13da3efa10a1ff295f816296c27caaeb21c2b73c48b2541b6` |
| `command.txt` | `db9abf22d3cccd6c7bbecee8458532f48f0448962cb70e56656c6e3d252f3424` |

P10 remains **FAILED / UNMET**. SPEC-006 macOS Dynamic/Static rows pass in
this run by reusing input-hash-matched reports; this is not a fresh standalone
compile. The older standalone semantic test-build
receipt was an on-disk-description cache hit and is not independent fresh
build evidence. The top-level selected compile logs omit previously reported
SemanticRecord lifetime diagnostics, but the nested SPEC-014 macOS Dynamic and
Static reports contain such diagnostics under Xcode Swift 6.3.3. Those nested
reports are dirty and do not hash `SemanticRecordExpansion.swift`; they do not
establish a defect under the approved Swift 6.4 baseline. No P08 proof campaign, hardware execution,
or aggregate rerun was done after `run-v8GRC8xq`; the remaining causes have
existing analyzer/lifecycle dispositions, while the two Pi environment rows
have separate focused passes.

The current worktree `SemanticRecordExpansion.swift` SHA-256 is
`c283f93920c926b0ea7fda4d893c3efacdd62da026d246a4f733bb9ce795bb1e`. The
aggregate's dirty-source limitation means it is not represented as a file-level
input hash in this run receipt. This hash is recorded to distinguish the
current source from earlier compiler diagnostics, not to claim the entire
worktree was immutably snapshotted.

Focused Pi receipts are retained with the run record:
[`SPEC-005`](current-run-v8GRC8xq/focused-followups/spec005-pi/) and
[`SPEC-006`](current-run-v8GRC8xq/focused-followups/spec006-pi/). Their metadata
binds current revision `3f7558be…` and the approved ARMv6 SDK; they establish
only those targeted driver results, not P10 conformance.

## Source-bound SPEC-014 macOS follow-up — 2026-11-11

The nested compiler-selection gap was corrected in the SPEC-014 driver and
value-profile checker: both macOS profiles now select the project-local
RFC-014 Swift 6.4 compiler and driver. The two focused runs below use the same
complete input-set identity (`6634018ebfaf274a5822a7733b1cfe6860fcb9d285ad1e4795fe090b86e24a74`),
including all `Sources/`, `Package.resolved`, driver/registry inputs and the
approved target. Both input manifests include
`Sources/GiftUISemanticCore/SemanticRecordExpansion.swift`
(`c283f93920c926b0ea7fda4d893c3efacdd62da026d246a4f733bb9ce795bb1e`) and
`Sources/SignalAnalyzerPresentation/SignalAnalyzerView.swift`
(`c21ec7f17548c511a61e36e13000787b07a02746ad1720f70736d05dceb93b2d`). The
runner, profile checker, and shared compiler selector are bound in the input
manifest at SHA-256 `a501f058effaac96529672748ccff39d1f6e38dc158ac9559341661efeb5e63e`,
`e22bde1f0149a3aa58c944fe5d43284ad3bc603a6e06ac29a513c69c13413179`, and
`d1b1b075a337aa220a4694b4d22fd6da3f08a321f0ce06707f7496c7d62904c2`,
respectively. The SDK is Xcode macOS 26.5. The
compiler and Swift driver are both project-local Swift 6.4, binary SHA-256
`79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`; SDK
26.5, target `arm64-apple-macosx26.0`, optimization `-O -whole-module-optimization`.

| Profile | Run ID | Result and retained identity |
| --- | --- | --- |
| macOS Dynamic | `4fc9f936220901bccdd5c408cf8899a25cd62f4c-6634018ebfaf274a-20261111T081741Z-56128` | Blocked, exit 1, one prerequisite: `macos-production-corpus`. `metadata.txt` SHA-256 `374c2d2ab72f7c205374c1e85fc84a6f2ce6ebd2d8b524ccff5327fd4c382b63`; `run.log` SHA-256 `cc2db92bd78b1b208c78a6d5f060d5cf887b37f3b2d19ab1ea68975e96c8901e`; `report-hashes.tsv` SHA-256 `2d7853168d9ea5865d150aaa68edbee4173514768326de9855e366afc3ceb5fd`. |
| macOS Static | `4fc9f936220901bccdd5c408cf8899a25cd62f4c-6634018ebfaf274a-20261111T081858Z-56869` | Blocked, exit 1, one prerequisite: `macos-production-corpus`. `metadata.txt` SHA-256 `9b64e63625a6d3050ed48c8addd4e3f9a04230a19018c74a7542c0bc14d12f3b`; `run.log` SHA-256 `93f77aef22ef145c3dece97cc2d245076b0bdcfab286230dfc141bd2f2e0588e`; `report-hashes.tsv` SHA-256 `2f0ba219462a1121414b375e07b5998e5df05cd17de774f993e55f5c87837488`. |

Both logs report Swift 6.4 errors in `SemanticRecordExpansion.swift`: the
associated `StateBinding`/`Sink` declarations cannot suppress `Copyable` or
`Escapable` as written, and the declared lifetime dependencies are rejected.
The Static profile also contains `SignalAnalyzerView.swift` errors. The Dynamic
and Static declaration/layout/import prerequisites pass; the production corpus
does not. This is a current shared compile prerequisite under the approved
toolchain, not evidence for transferring shared SPEC-006 implementation work
to the analyzer destination. The bounded closeout made no production-source
change. The archived 55/28 P10 result is unchanged, and these focused reports
do not make either historical nested execution pass.

Full input lists, command transcripts, prerequisite/evidence tables, and raw
logs are retained in
[`focused-followups/spec014-macos-swift64/`](current-run-v8GRC8xq/focused-followups/spec014-macos-swift64/).
