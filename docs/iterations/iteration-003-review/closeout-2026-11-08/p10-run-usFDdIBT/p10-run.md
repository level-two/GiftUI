# P10 all-hardware-free run — `run-usFDdIBT`

## Disposition

**P10 remains FAILED / UNMET. Iteration 3 remains active; P08 remains FROZEN / UNMET.**
The required `scripts/test.sh all-hardware-free` command completed all 83
serialized checks and exited 1: 24 passed and 59 failed. The aggregate result
does not prove any of the 189 owner-plan rows. Failure destinations remain split
by actual cause; I4 transfers do not waive the P10 gate.

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
| Root tests, diagnostic-buffer, SPEC-001, and the fixed SPEC-013 macOS Static precheck stop before a product verdict | `root-tests`, `spec-003-diagnostic-buffer`, `spec-013-macos-static`, `SPEC-001-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (7) | SPEC-001 owner scope: `SA-AC-001..045`, `SA-RD-001..004`. The fixed SPEC-013 precheck gates `RP-001`; registered SPEC-013 macOS Static is a separate passing execution. The two other fixed checks have no per-AC mapping. | `receipt.tar.gz!/logs/012-spec-013-macos-static.log`, `014-root-tests.log`, `015-spec-003-diagnostic-buffer.log`, `016-SPEC-001-macos-dynamic.log`, `033-SPEC-001-macos-static.log`, `050-SPEC-001-raspberry-pi-armv6.log`, and `067-SPEC-001-nrf52840-embedded.log`: shared Semantic Core and `SignalAnalyzerView` compile errors; no complete test result. | **Blocked by prerequisite** | Unblock shared compilation in I3. Only the analyzer-specific portion is covered by the existing I4 transfer; shared core errors remain I3. No check is transferred wholesale and no product verdict is inferred. |
| SPEC-014 macOS production-corpus prerequisite is blocked by compile errors | `SPEC-014-{macos-dynamic,macos-static}` (2) | Spec scope `BI-001..015`; the driver/reproduction gate `BI-015` and corpus-dependent behavior/resource criteria are blocked, not individually failed. | Retained SPEC-014 reports mark `macos-production-corpus` blocked; diagnostics include shared `InlineArray` availability and application compilation errors. | **Blocked by prerequisite** | Unblock shared compilation in I3. Analyzer-owned errors may follow the existing I4 allocation; shared and remaining backend criteria stay in I3. |
| SPEC-002 Foundation surface checker rejects valid package-interface declarations | `SPEC-002-{macos-dynamic,macos-static}`, `SPEC-002-rfc-014-{macos-dynamic,macos-static}` (4) | No product criterion failure is established by these four checks; they exercise the PF-001..010 public/package boundary, with no per-profile-to-individual-PF mapping retained. | Archived child logs report `public interface exposes package SPI`. The checker applied a blanket `^package ` rejection to the public interface even though retained Swift interfaces contain the expected five public and seven package owners. SPEC-002 defines package visibility as SPI outside the public client API. Exact public/package owner-set comparisons remain in the checker. P10 metadata records Swift 6.3.3 for these macOS profiles, while the approved RFC-014 baseline is Swift 6.4. | **Validation infrastructure** | SPEC-002 validation owner. Corrected checker is retained in the working tree; rerun affected macOS profiles with the approved compiler baseline. Keep exact public/package owner sets and the four historical rows failed. |
| SPEC-003/004 host dependency registries lag the approved composition | `SPEC-003-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}`, `SPEC-004-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (8) | No normative AC failure is established by the mismatched list alone: SPEC-003 `FAIL-AC-02` constrains `GiftUIFailureExecution` imports, and SPEC-004 `CR-002` does not prohibit the host's composition-owner dependencies. | Archived reports stop at `GiftUIHostConfiguration dependencies differ`. Current `Package.swift` declares 17 direct host dependencies used by current host source; SPEC-015 permits host composition from approved contract-owner modules. The two fixtures listed only 10. Their expected lists now match the current 17-edge manifest, and both exact dependency checkers pass on `dump-package` output. | **Validation infrastructure** | SPEC-003/004 validation owner. Preserve exact edge checking and the accepted directionality constraints. Eight historical executions remain failed; complete affected profile validation after the other repairs. |
| SPEC-005 generated asset hashes are stale at the gate | `SPEC-005-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | Directly implicated: `TR-004` provenance/build inputs. The fixture manifest and 45-case corpus passed before the hash check; later assertions did not run. | First child report says the generator hash is stale (`expected 8433302f…`, `got 3674e029…`). | **Validation infrastructure** | Text-resource evidence owner; accepted SPEC-005. The inventory was refreshed after this run and focused provenance checks pass, but the four archived rows remain failed. The later 22-versus-20 package surface finding is separate, not the cause of these four failures. |
| SPEC-006 action/view fragments were searched in stale locations | `SPEC-006-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | The assertion intended to cover `DV-001` and `DV-003`; it does not establish those criteria fail. | The archived checker missed `@ViewBuilder` in `LayoutContainers.swift` and expected pre-amendment fragments. Current source contains the generated traversal witness and `visitCustomView`; the focused RFC-014 Dynamic driver passes. | **Validation infrastructure** | SPEC-006 validation owner; checker drift corrected against accepted RFC-014 source. Four historical executions remain failed. |
| SPEC-007 consumer allowlist omits an accepted host composition target | `SPEC-007-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | The assertion concerns the module boundary; it does not independently establish `LY-007` failure. | Both imports are in `GiftUIHostConfiguration`; accepted composition allows this host consumer. Added the exact target to the allowlist, preserving exact dependency checks and import-negative cases. Focused boundary check passes with pinned Swift 6.4. | **Validation infrastructure** | SPEC-007 validation owner; no dependency edge was removed and no accepted contract was weakened. Four historical executions remain failed. |
| SPEC-008 checker rejects the equivalent empty-stack guard spelling | `SPEC-008-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | The assertion was intended to cover `RD-003` event order; it does not establish an ordering defect. | Source uses `guard case .none = workspace.currentForeground` before pushing the root foreground and calling `sink.begin`. The corrected focused checker passes. | **Validation infrastructure** | SPEC-008 validation owner; event ordering requirements remain checked. Four historical executions remain failed. |
| SPEC-009 checker misses attributed package fields | `SPEC-009-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | The assertion was intended to cover `EX-001` and `EX-008`; it does not establish missing capture storage. | `CapturedAction` has the required identity and generation fields, each with `@usableFromInline package let`; the old anchored scan ignored the attribute. The corrected exact field scan passes. | **Validation infrastructure** | SPEC-009 validation owner; captured values and no-retained-payload checks remain enforced. Four historical executions remain failed. |
| SPEC-010 checker expects a superseded decorator implementation shape | `SPEC-010-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | The assertion was intended to cover the state binding contract, including `OS-008`; it does not establish a dependency or binding failure. | Current implementation aliases the noncopyable borrowed `ObservableStateRootScope`; `withBoundDeclaration` visits declarations before the body and suppresses the body on binding failure. `ObservableSemanticBodyBinding` performs the typed read. The corrected checker and Swift 6.4/macOS 26 target build pass. | **Validation infrastructure** | SPEC-010 validation owner; exact target imports, body ordering, and no-retained-declaration checks remain enforced. Four historical executions remain failed. |
| SPEC-011 task evidence key set differs | `SPEC-011-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | No normative `IN-*` acceptance criterion is directly shown false; `IN-012` is only the nearest evidence-provenance topic. Owner scope: `IN-001..013`, `IN-RD-001..002`. | Each `check-spec-011-harness.rb` invocation fails at `task evidence keys differ`, before a profile conformance result. | **Validation infrastructure** | SPEC-011 evidence/harness owner; accepted task inventory governs. Reconcile expected keys and emitted evidence, then validate the affected checks. |
| SPEC-012 declaration/value probes were stale against the approved protocol Canvas API | `SPEC-012-{macos-dynamic,macos-static,raspberry-pi-armv6,nrf52840-embedded}` (4) | The archived checks do not establish a product failure; the declaration fixtures used the removed closure initializer and focused profile source lists omitted required framework declarations. | With the approved Swift 6.4.0 compiler at `arm64-apple-macosx26.0`, declaration fixtures now pass (7 positive, 9 negative), and the macOS Dynamic value-profile check passes all seven bounded layouts. The checker now compares normalized module-qualified interface text and compiles a complete GiftUI source module. | **Validation infrastructure** | SPEC-012 validation owner; fixture/checker sources follow the approved RFC-014 Canvas protocol and current module. Four archived rows remain failed; the focused Dynamic receipts do not replace all-profile validation. |
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

### Smallest coherent follow-up batches and closure recommendation

1. **Unblock compilation before drawing product conclusions.** Resolve the
   shared target-compatibility diagnostics, then separate the Signal Analyzer
   compile issue under its split I4 ownership. Re-run blocked fixed/profile
   checks only after those prerequisites are repaired. Analyzer transfer does
   not include shared semantic-core failures.
2. **Repair direct shared-contract mismatches by owner.** The SPEC-006–010
   rows now have focused evidence of stale checker assumptions, not a
   demonstrated source defect. SPEC-003/004 fixtures now reflect the permitted
   current composition and their exact dependency checks pass; validate those
   profile routes after the remaining compilation prerequisites.
   Re-run SPEC-002 macOS validation with the corrected exact-set checker and
   approved compiler baseline; the archived output is not a product SPI
   failure. Validate the affected profiles, then run the full P10 gate when
   these inputs are ready. For SPEC-015, recover the missing
   compiler/test diagnostics before choosing a repair; do not treat its
   ambiguous failure as a proven source defect.
3. **Repair validation inputs without weakening accepted contracts.** Reconcile
   the SPEC-005 asset manifest, SPEC-011 evidence keys, and SPEC-012
   declaration/value fixtures. The post-run SPEC-005 22-versus-20 package
   surface mismatch is a separate unresolved shared API issue: retain the exact
   20-item contract unless maintainers approve a Spec change through lifecycle
   review. The corrected Pi invocation has separate focused pass receipts; it
   does not change this archived result.

The first compilation batch has two distinct questions. The RFC-014 lifetime
diagnostics in this archive came from Swift 6.3.3, not the approved Swift 6.4.0
baseline; the smallest useful follow-up is a focused shared-core compile using
the project-local 6.4.0 compiler, both required language features, and the
approved macOS 26 target. Separately, `Package.swift` still declares macOS 15
while shared Semantic Core uses `InlineArray` APIs whose retained diagnostics
require macOS 26. If macOS 15 remains a supported deployment, the source must
use compatible bounded storage; if macOS 26 is intended as the minimum, the
package and profile-check target need an approved lifecycle correction. The
current evidence does not authorize choosing between those contract outcomes.
SPEC-015 has no retained compiler or test diagnostics, so the smallest next
step is to recover its child output; if unavailable, retain stderr on the next
already-authorized affected profile run before choosing a source repair.

**Recommendation:** Keep P10 FAILED / UNMET and iteration 3 open. Complete the
bounded shared fixes and validation-input repairs, then run one fresh
`scripts/test.sh all-hardware-free` with a new exact-identity receipt. Do not
mark completion from the 24 passes, post-run Pi checks, or focused SPEC-005
asset checks. Do not reopen P08: it remains FROZEN / UNMET; analyzer-specific
P09–P12 work follows its authorized I4 path; counter-composition certification
follows I4-AC-013; affected I4 reuse remains blocked by S1–S3 until resolved or
replaced with validated, independently reviewed evidence. Other shared
failures remain I3 obligations.

The maintainer decision is whether to fund the listed shared/validation repair
batches under accepted contracts. Keeping those contracts requires the exact
mismatches to be resolved and affected validation rerun; changing one requires
the existing Specification/RFC approval process and still does not change this
archived run. P11/P12, independent overall freeze acceptance, final
accounting/handoff, and human iteration-3 closure remain separate gates. `R1`
compiler allocation-effect failure remains explicit; the reviewed Native
Static no-heap conclusion applies only to its exact image and predicates.

## Post-run focused checks

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
  The compiler hash is
  `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`, SDK
  `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk`.
  These checks do not retroactively change the four archived failures or
  establish the three other SPEC-012 profile runs.
- The current SPEC-011 harness check passes with the approved `T12.1` evidence
  task included: `ruby scripts/contracts/check-spec-011-harness.rb` reported 14
  ordered fixtures, 53 task edges, and 13 criteria. The four archived profile
  rows remain failed; this focused harness pass does not establish profile
  conformance.
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
  This confirms the target-compatibility issue without resolving the supported
  minimum deployment policy.
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
  complete SPEC-010 profile run or a resolution of the macOS 15 deployment
  question.
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
