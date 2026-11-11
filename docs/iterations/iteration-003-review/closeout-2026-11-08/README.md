# Iteration-3 closeout handoff — 2026-11-08

## Disposition

**Closeout is not ready. P08 remains FROZEN / UNMET; iteration 3 remains active.**
This packet records what the retained evidence supports and what remains open
under the approved revision-8 closeout rule. The S1–S3 gaps may remain explicitly
unmet at closure, but affected I4 reuse stays blocked until resolved or replaced
and validated. This packet is not a P08 pass, Spec transition, iteration closure,
or permission to adopt affected code.

The original `run-usFDdIBT` P10 gate failed 59 of 83 checks under the archived
Swift 6.3.3 baseline; it remains historical. The latest integrated run is
`run-v8GRC8xq` on the pinned local Swift 6.4.0 compiler: 55 passed and 28 failed
of 83. Its exact identity and failure classification are in the durable
[P10 receipt](p10-run-usFDdIBT/p10-run.md); raw logs, results, and child-report
ledger are retained in
[`current-run-v8GRC8xq`](p10-run-usFDdIBT/current-run-v8GRC8xq/). An earlier
`run-b1kjDyaM` result recorded 60/23 at ancestor revision `ba03d1a`; v8 ran
later at descendant revision `3f7558be` and remains the latest aggregate. The
v8 failures group as 20 analyzer/workload prerequisites, two mixed SPEC-014
nested-profile failures, four SPEC-007 lifecycle failures, and two Pi
sandbox/cache failures.

The original nested SPEC-014 reports use Xcode Swift 6.3.3 and omit the
diagnosed SemanticRecord source from their file hash list; by themselves, they
do not establish a defect under the outer run's approved Swift 6.4 baseline.
Later source-bound attempts also initially appeared to confirm a current
`SemanticRecordExpansion.swift` compile blocker, but audit found nested SwiftPM
still selected Xcode Swift 6.3.3 because its collector invoked bare `swift`.
The collector now uses the pinned local Swift 6.4 driver and compiler; fresh
Dynamic and Static runs compile Semantic Core without those diagnostics and
remain blocked by Signal Analyzer schema/View errors. These follow-ups do not
rewrite the archived 55/28 count.
Focused SPEC-005 and SPEC-006 ARMv6 reruns pass without changing integrated
results. The v8 run used a dirty worktree without a complete source-file
manifest. P10 remains failed. No old-image P08 proof or hardware campaign was
restarted. P08 stays frozen. The scoped Native no-heap conclusion remains valid
only for its reviewed Native Static image and predicates; it does not inherit
the compiler's rejected generic allocation promise.

The corrected macOS Dynamic and Static SPEC-014 reports are retained in their
[pinned-compiler follow-up archives](p10-run-usFDdIBT/focused-followups/). Both
compile Semantic Core with project-local Swift 6.4 without the prior 6.3.3
diagnostics; both remain blocked by analyzer-owned schema/View failures.
The pinned root-test attempt is retained as a dirty-worktree diagnostic and
stops at the analyzer-owned schema/View errors. An earlier unpinned attempt
selected Xcode Swift 6.3.3 for compiler jobs; its Semantic Core diagnostics do
not establish a defect under the approved Swift 6.4 baseline.

The later focused SPEC-007 P05 bank-layout helper also compiled, linked, and
executed under macOS Dynamic and Static, passing 286 assertions per profile.
Current Pi ARMv6 and nRF52840 P02 receipts and P05 cross-compilation/ABI reports
are now retained as well; neither embedded profile executed on target. Exact
receipts and limits are in the
[T9.1 runtime-bank follow-up](../../../../Tests/ContractFixtures/SPEC007/Evidence/milestone-9/runtime-bank-lifecycle-followup-2026-11-11.md).
It does not change the four failed SPEC-007 executions in the integrated P10
result or close LY-RD-001/002.

## Exact remaining actions and disposition

| Item | Current evidence / prerequisite | Smallest next action | Scope and consequence |
| --- | --- | --- | --- |
| P10 aggregate | Latest completed run remains `run-v8GRC8xq` (55/28). The focused SPEC-014 Dynamic and Static runs now use the pinned Swift 6.4 compiler and both stop at analyzer-owned `SignalAnalyzerView` schema/View errors; current root-test log also contains errors from the dirty checkout and is diagnostic only because that invocation has no complete source manifest. | Resolve the already allocated analyzer migration prerequisite in I4, then run one source-bound complete P10 gate on the resulting authorized input set. | Do not count either focused run as aggregate success, infer a clean-source defect from the unbound root-test log, or transfer shared P10 rows. P10 stays FAILED / UNMET meanwhile. |
| SPEC-007 `LY-RD-001` | Current P02/P05 owner receipts exist for all four profiles. The macOS helpers execute the 286-assertion layout probe; Pi ARMv6 and nRF52840 only cross-compile the probe and pass ABI checks. The required differential is baseline corpus plus both application layouts under all four profiles. | Complete and retain the baseline/application differential for each profile using the current P02 receipts. For embedded behavior that requires execution rather than compile/ABI evidence, obtain explicit connected-target authorization and run the owner matrix on target. | Current receipts establish build route readiness, not embedded runtime behavior; LY-RD-001 stays open. |
| SPEC-007 `LY-RD-002` | The macOS probe exercises reader release, prior-publication preservation, sink begin/stage/publish refusal, excess depth/scope, and candidate reuse. Pi/nRF probe outputs are compile/ABI only. The complete failed begin/lookup/finish and first-excess cleanup/reuse matrix is absent for all four profiles. | Retain the full failure-cleanup matrix under Dynamic and Static. For embedded behavior requiring execution, obtain explicit connected-target authorization, run the same matrix on Pi ARMv6 and nRF52840, and retain each route's result. | No connected hardware execution was performed; no criterion promotion follows from compile/ABI checks. T9.1 remains open. |
| P11 retained owner accounting | The crosswalk above names exact Native Static, Dynamic allocator, Pi, nRF and P08 scoped receipts, but the missing joined fields are not present: private allocator attribution and full route peak; Pi connected provider/target identity plus whole-route stack/fit; nRF connected sustained workload; and criterion-linked stack/IRQ/allocation/ABI joins for applicable routes. | Produce the missing route evidence under the named owner criteria, attach exact image/toolchain/provider identities and resource ledgers, then obtain independent disposition. | Existing scoped receipts remain usable only within their stated bounds. Full P11 remains UNMET; no inference of all-route fit or connected performance. |
| P12 adoption | No-removal/no-cutover is recorded. Owner conformance is not complete and production dependency/cutover inventory plus focused post-removal checks are absent. | After P10/P11 and each applicable criterion pass, enumerate exact retained inputs and dependencies, prepare the cutover/removal diff and rollback evidence, then request human adoption disposition. | Preserve current production inputs and independent controls. No adoption pass or deletion is claimed. |
| Lifecycle / iteration closeout | SPEC-007 remains `implementing`, plan `active`, conformance `collecting`; iteration 3 remains active, with P08 FROZEN / UNMET. | A maintainer must decide the Spec `implemented` transition only after its complete conformance evidence is accepted; the separate human iteration-3 closure decision follows the governing closeout gate. | This packet makes neither decision and does not authorize I4 activation or affected S1–S3 reuse. |

The fresh embedded P02 receipts are now retained and the cross-compiled P05
routes pass. Connected-target execution and connected resource/accounting
evidence were not produced because the task scope excludes hardware action.
Human authorization is needed for that remaining target work. These exact gaps
are the remaining boundary, not a generic request to repeat all historical
campaigns.

## Current closure gates

| Gate | Evidence and disposition | Remaining requirement |
| --- | --- | --- |
| P10 — current hardware-free validation | The latest integrated `scripts/test.sh all-hardware-free` run `run-v8GRC8xq` at revision `3f7558be20907767e9816477fac2b6604d80422e` recorded 55 passes and 28 failures in 83 serialized checks on pinned Swift 6.4.0. `results.tsv` SHA-256 is `1ba48aaadb67bd9c396e04661c55948d332ed37d27b0738f26682fbd450ea0d9`; `metadata.txt` SHA-256 is `d0253fecfd220d5f7663ac533208e270533adb6e92e5dbc0892a112fe10a7381`. See the [P10 receipt](p10-run-usFDdIBT/p10-run.md) and [exact current-run files](p10-run-usFDdIBT/current-run-v8GRC8xq/). The earlier 60/23 `run-b1kjDyaM` is retained as an intermediate run; the original 24/59 and intermediate 56/27 and 60/23 results remain historical. | The integrated run used a dirty worktree without a complete source-file manifest. Twenty failed rows have analyzer/workload prerequisites; two nested SPEC-014 reports used Xcode Swift 6.3.3 and lacked source hashes. The corrected Dynamic and Static SPEC-014 reports use pinned Swift 6.4 and compile Semantic Core without those diagnostics; both remain blocked by analyzer schema/View errors. Four SPEC-007 lifecycle rows remain incomplete; two Pi sandbox/cache rows have separate focused passes without changing the aggregate. SPEC-006 macOS Dynamic/Static rows pass by reusing matching reports, not by a fresh standalone compile. These are failed executions, not independent criterion verdicts. No whole P10 check or shared criterion is transferred or waived. P10 remains **FAILED / UNMET**. |

Compact, hash-bound post-run SPEC-002 Pi, SPEC-014 Pi, and SPEC-005 macOS
Dynamic receipts are retained in
[`post-run-targeted-receipts.tar.gz`](post-run-targeted-receipts.tar.gz),
SHA-256 `36d58dc61057dd2d2e70d05e2faa8f33483af927528f398ac07c8ff729f8bd0b`;
the full binary-bearing reports remain in `.build` and are identified by their
run IDs and report hashes in the P10 receipt.
| P10 — criterion dispositions | [Criterion index](criterion-dispositions.csv) is generated from the nine current owner-plan matrices and contains the 180 P10 owner rows plus nine scoped-ownership rows. The 180 P10 rows are SPEC-001 49, SPEC-002 10, SPEC-006 21, SPEC-007 11, SPEC-010 16, SPEC-011 15, SPEC-012 17, SPEC-013 19, and SPEC-015 22. | All 189 current rows remain explicitly dispositioned: 180 P10 owner rows stay UNMET because the integrated gate failed; nine SO rows retain the separately approved P08 classification and do not imply P10 conformance. The additional SO rows are IN 3, RP 3, and HC 3. Historical owner-plan evidence/status is preserved and is not promoted by aggregate results. |
| P11 — physical/resource accounting | Reuse only the exact scopes below. Four P08 collection receipts have 849 declared input matches and 3,404 declared artifact/hash-size matches in the retained audit; this is not proof of full semantics or P11 conformance. | Full criterion-linked joined storage/stack/IRQ/allocation/ABI accounting and applicable target evidence remain incomplete. No all-route fit or connected-performance pass follows from the selected results. |
| P12 — adoption/removal | **No removal and no cutover.** Preserve generated baselines and independent controls while adoption gates are unmet. SPEC-013 and SPEC-015 conformance reports remain `collecting`. | Complete P10/P11 evidence and criterion-linked conformance before any removal/cutover; document exact retained sources/artifacts and justified no-removal. No deletion was made for this closeout. |
| ME-09 — handoff and decision | This packet consolidates current evidence, boundaries, transfers, failures, and required follow-up. | The current independent review status is recorded in [independent-review.md](independent-review.md) against its named document hashes. Any acceptance is limited to the bounded evidence/status handoff; it does not satisfy P08, P10, P11/P12, or human iteration-3 closure. The explicit human closure decision remains outstanding. |

The 180-row P10 owner matrix is reconciled as the 152 standard acceptance rows
plus 28 `*-RD-*` disposition rows. The nine `*-SO-*` rows are additional
cross-cutting P08 dispositions. The CSV records all 189 current rows, marks the
180-row P10 matrix UNMET, records the nine SO classifications, records P11 as
unmet at the overall-gate level, and records P12 no-removal. Each owner's
existing plan status and planned evidence remain visible. The analyzer disposition
is strictly for analyzer-specific portions; shared criteria remain split and
affected reuse remains blocked where S1–S3 apply. The generator verifies all 189
owner-plan rows and is reproducible with:

```sh
python3 docs/iterations/iteration-003-review/closeout-2026-11-08/build-criterion-disposition-index.py
```

The regenerated CSV has 190 lines including its header. The generator's input
boundary is the nine listed plan files; it does not infer criteria or turn a
historical report into current conformance.

## Retained P11 evidence and limits

| Retained evidence | Exact result retained | Boundary / disposition |
| --- | --- | --- |
| [Native Static assessment](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-native-closure-2026-11-07/native-assessment.md), SHA-256 `0ee99cf9f3f7ef6989900d9054c1ee65a1d8147872c99a05a282990da5d93c43`; [independent review](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-native-closure-2026-11-07/native-assessment-review.md), SHA-256 `2cd4fc6364bee88d4588a6fea3d85e90624cb7af59184f6bc5b918a5464dc930` | Reviewed exact image `8e9cf62c…dcc47`; scoped NoHeap and charged-entry 2,936,768 B vs 8,340,976 B available. | Exact Native Static workload only. No inference for Dynamic, Pi, whole-process memory, arbitrary consumers, or the rejected compiler allocation-effect promise. |
| [Dynamic allocator accounting](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/dynamic-allocator-private-accounting-2026-11-07/README.md), SHA-256 `3624474bc9d27a4025d0f9349ca17d717beed7ae0b1df864a2c80e89edcfe29b` | Retains selected client requested/usable/rounding and process/default-zone/ADMIN/PTR snapshots. | Private allocator bytes and complete route/lifetime/peak remain unmeasured; zone totals are not attributed private bytes; sampler perturbed public totals; timing is deferred. |
| [Pi current collection/image result](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-pi-collection-image-result.md), SHA-256 `7ddfeff83eea2e75975ec5979a5ead72bdabe866ac1ef970bd2708902e2ea5a8` | 409/409 receipt checks and an early ARMv6 hard-float link; retained ELF, stripped image and map identities are in the result. | Cross-compilation only. No target execution, full stack, allocation, or fit. Whole composition certification is transferred under I4-AC-013. |
| [nRF final-fit independent review](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-firmware-final-fit-independent-review.md), SHA-256 `f7163bd188ac99b0ebc442f0476cc452e09e07ac89b5214ffbc12978eb9f183f` | Exact image `0e54fe25…1f02f5`; main/ISR bounds 95,469/6,672 B; RAM 255,612/262,144 B; flash 403,400 B. | Accepted exact-image resource evidence only. No target execution or extracted-host certification. |
| [Pi frozen-session handoff](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/pi-current-stack-analysis-2026-11-07/callback21-freeze-session-handoff.md), SHA-256 `51e147ccc72c1f6d561efc2060c81760b8ab2e33e90c60109f85e8d3dcdbae02`; [independent classification review](../../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/pi-current-stack-analysis-2026-11-07/callback21-freeze-session-handoff-independent-review.md), SHA-256 `e1294ff6c07cea6e2d700fc5d577bcb5cce34ad11db2acfef452d1fccaddc749` | Current retained graph is callback21: 2,987 bodies / 401,948 instructions, 216 machine-guard tables / 5,420 entries, with conditional target domains kept distinct. | P08 remains FROZEN / UNMET. Local/table proofs do not make complete stack/provider/fit claims. Do not resume old-image graph or stack campaigns for this closeout. |

The collection-integrity snapshot [input-audit.json](../p08-freeze-assessment/input-audit.json), SHA-256 `b14f2f8ebbf94e238a54d508a749c713109172e92d53e96124478b32002b3e90`, was captured at review HEAD `ba843084…`, before the docs-only closeout authorization commit `b06791fd`. It checks declared receipt inputs and artifact hashes/sizes; it explicitly does not verify all semantic applicability, full transitive inventories, or SDK installation identity. The authorization commit did not refresh any certification evidence.

### P11 retained-evidence crosswalk

The retained receipts are inputs to the following criteria, not completed
criteria. They cover selected evidence classes only; the criteria remain UNMET
until the required joined evidence and independent dispositions exist.

| Receipt | Relevant owner criteria | What the receipt supports | Still missing |
| --- | --- | --- | --- |
| Native Static reviewed image | `RP-SO-003`, `HC-SO-003`; resource aspects of `HC-015` | Exact reviewed image NoHeap and charged-entry/headroom result | Other profiles, whole-process memory, rejected compiler allocation promise, and connected workload |
| Dynamic allocator report | `RP-SO-003`, `HC-SO-003` | Selected-client request/usable/rounding observations and bounded process/default-zone snapshots | Private allocator bytes, all-route lifetime/peak, unperturbed complete accounting, and fit |
| Pi linked image and callback21 handoff | `RP-SO-003`, `HC-SO-003`; P08 scope also `RP-SO-001/002`, `HC-SO-001/002` | Retained image/ABI identity, finite conditional graph evidence, and explicitly open residuals | Connected target/provider identity, complete stack/IRQ/fit, shared alias/lifetime/reentry premises, and full owner-route coverage |
| nRF exact-image review | `RP-SO-003`, `HC-SO-003`; resource aspects of `HC-015` | Exact image stack/RAM/flash bounds | Connected-target execution and sustained-workload evidence |
| P08 scoped ownership and callback ledgers | `RP-SO-001/002`, `HC-SO-001/002`, plus `RP-SO-003`/`HC-SO-003` for resource portions | Named route-specific findings and unresolved ownership predicates | The 54 remaining live-store alias checks are listed in the five-literal section's four live-store lists; they are not an aggregate safety proof for other callback groups. Borrow, alias, reentry, and provider conditions remain route-specific and unresolved where recorded. |

`HC-RD-003` and `RP-RD-003` remain open disposition rows. The wider P11 gate
also needs the complete criterion-linked resource, stack, IRQ, ABI, allocation,
and applicable connected-target accounting. P12 remains “no cutover/removal”;
that is a safe retained disposition, not completion of the adoption gate. The
criterion-linked owner conformance updates/reports, dependency/cutover review,
and focused post-removal checks remain outstanding. These limits do not alter the existing I4 transfers
or the S1–S3 affected-use restriction.

## Criterion transfer and handoff

The approved [analyzer delivery allocation](../analyzer-delivery-transfer.md)
transfers analyzer P09–P12 to I4 with I4-03/04/07/10 coordination, while
framework/counter P10–P12 stay in I3. The [restricted-use decision](../p08-unmet-safety-closeout-disposition.md)
allows only named S1–S3 to remain unmet at I3 closure; it blocks affected I4
reuse until resolved or replaced and validated. It is not a P10 waiver.

Retain these split dispositions in the next owner plan and conformance updates:

| Evidence class | I3 disposition | I4 destination / use constraint |
| --- | --- | --- |
| Shared ownership, lifetime, callback alias/reentrancy (S1–S3) | Explicitly unmet under the approved closeout rule; no broad safety pass | I4-03/07. Reuse of affected paths stays blocked pending resolution or validated replacement. |
| Current Native Static scoped no-heap/headroom | Retain exact reviewed evidence | Refresh only when changed image/provider/launch/boundaries invalidate its stated scope. |
| Dynamic private allocator attribution and full composition peak | Unmet; retain reporting scope and limits | I4-03/04/07 → I4-AC-013. Do not infer private bytes from rounding or process-zone totals. |
| Pi full-route stack/provider/target/fit | Unmet; freeze existing graph evidence | I4-03/04/07 → I4-AC-013 before affected counter adoption. A linked ARMv6 image is identified; connected-target/provider identity, whole-route stack and usable headroom remain absent. |
| nRF exact-image resource bound | Retain reviewed image result, with no execution claim | Refresh for changed image or extracted host; not a sustained-workload receipt. |
| Legacy analyzer integration, migration, oracles and certification | Transferred and unmet | I4 P09–P12 / I4-03/04/07/10 / I4-AC-012. |
| P12 changes to production inputs | No removal; preserve existing inputs and independent controls | Reconsider only after applicable adoption evidence passes and exact dependencies are enumerated. |

The T1–T5 labels in the P08 assessment remain split as follows: T1 is Pi
whole-route stack/provider/launch/fit; T2 is Dynamic private-allocation and
route-peak accounting; T3 is nRF target execution and changed-host certification.
Those composition-specific obligations transfer to I4-AC-013. T4 is analyzer
integration and certification, transferred to I4 P09–P12 / I4-AC-012. T5 is
the incomplete full P08/SO-09 exit and remains P08 FROZEN / UNMET; it does not
become a transferred pass. The bounded overall freeze review and human closure
decision are separate retained I3 gates.

The compiler's rejected CounterSemanticCodec allocation-effect promise remains
a distinct failed result; it is not converted to PASS by the Native Static
review. The retained Unit failure is linked as [the recorded SwiftPM failure
capture](../../../../.build/contracts/p08-witness45-swiftpm/root-unit.stderr)
(SHA-256 `d838f9f1feb6202a306434518a5e7c48deb8bfe2c1825c8834ca4cf9a79dffa8`),
with its historical disposition in the [checkpoint](../complexity-and-efficiency-checkpoint.md#historical-unit60-assessment--stopped-not-a-new-p08-prerequisite): SwiftPM's root unit build failed in `SignalAnalyzerView` before Interaction tests ran. The retained notes do not preserve the full shell argument vector, so this packet does not claim exact flags. Interaction remains UNEXECUTED. Neither is silently charged to S1–S3.

## Review and closure state

The [overall handoff review](independent-review.md) records the exact document
hashes it reviewed. Its acceptance, if present, is limited to bounded evidence
and status classification; it does not accept P08 or iteration closure. P10
execution, P11/P12 conformance, and human closure remain unmet.

After that review, ME-09 still requires a human disposition. Keep iteration 3
`active`, P08 `FROZEN / UNMET`, conformance reports `collecting`, Specs at their
existing lifecycle statuses, and iteration 4 unactivated until authorized. Do
not claim iteration closure or implementation completion from this handoff.
