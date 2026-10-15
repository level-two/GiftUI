# RFC-014 bounded implementation sequence — 2026-10-10

Current stack candidate A — **STOP; object rejection after one screen, 2026-10-15**.
The [screen result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-stack-candidate-a-screen-result.md) records 25 passing preparation/module/layout checks,
202 controls not run, and incomplete aggregate coverage. The object still requires
a reachable ≥30,096-byte frame; the required nested path improves 213,120→114,464
bytes but exceeds 27,648. Candidate 1/1 and screen 1/1 consumed; historical 2/2
closed. No further optimization variant, compiler/build/image or resource waiver
follows. [Independent Strong result review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-stack-candidate-a-independent-result-review.md) confirms STOP and fit FAIL; P08 remains open.
The prior five-receiver source blocker was corrected at `9cac6bfa` and
[focused source reassessment passed](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-stack-candidate-a-review-correction-independent-source-review.md). Its original freeze/failure
remains historical evidence, not the current blocker.

Previous remaining P08 boundary — **STOP; FIT FAIL independently confirmed, 2026-10-15**.
The [activity record](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-remaining-completion-activity.md) consumed both corrective cycles (2/2). Four full profile collections and
both registered early image builds pass. The [resource reconciliation](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-remaining-images-resource-result.md)
pins a reachable nRF frame needing at least 30,096 bytes against the unchanged
27,648-byte main-stack ceiling. Complete IRQ/allocator/Dynamic cost proof remains
open. P08/R07/T8.1/HC-RD-003 stay open; I4-07/analyzer, P09–P12, hardware and
timing boundaries remain. No further automatic source repair, new variant or
resource waiver is authorized. [Independent exit review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-remaining-independent-exit-review.md) confirms
the blockage and required maintainer decision. Earlier boundary records below remain historical.

Current P08 collected-suite repair batch — **COMPLETE; independent package review PASS, 2026-10-15**.
The [batch result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-suite-collection-result.md) records the full registered baseline collection,
grouped routine corrections and focused validation. Current native runtimes pass
1,736,158 Static / 1,736,082 Dynamic assertions with zero failures; reuse and
exclusivity controls pass. ARMv6's 22 selected compiler checks pass; Embedded's
full 226-check collection passes. Focused receipts remain partial, not a full
corrected-source matrix pass. Both grouped correction cycles are consumed;
historical budgets, contracts and resource limits are unchanged. P08/fit, images
and acceptance coverage remain open. The following boundary records are historical.

Historical grouped lifetime continuation boundary — **STOP, 2026-10-14**.
Candidate `cab1c415`, source review `2989ca7f`: the complete counter module now
compiles, clearing the prior L01–L03 diagnostic sites. The one registered native
counter invocation exited 1 after **191 accepted scoped compiler checks**; check
192 rejected the intended closure escape, but its diagnostic did not contain the
harness's required `escaping` substring. It reports lifetime-dependent input
`escapes its scope`; the positive twin compiled. This is a diagnostic-classifier
mismatch, not an accepted full matrix or runtime result.
[Independent result and immutable evidence](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-compiler-compatibility2-result.md).
The [frozen allowance](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-compiler-compatibility2-source-freeze.md)
is consumed: candidate 1/1, invocation 1/1, automatic repairs 0. Historical
integrated cycles 2/2 and compatibility 1 remain closed. No classifier edit or
rerun occurred. Remaining compiler controls, native exclusivity, counter runtime,
ten initial profile cells, both images, all nine SO criteria and P08/fit remain
open. Three earlier component passes retain their exact applicability limits.
FW-038 captures validation cost separately; its documentation-only commit did
not change any of the nine frozen source hashes or this running matrix.
Earlier pending/current wording below is historical.

Historical compatibility 1 boundary — **STOP, 2026-10-14**.
Candidate `bbb54fc1`, source review `7002a953`, exact native counter run failed
with ten explicit lifetime/ownership diagnostics in three cause groups. The
earlier graph SILGenCleanup assertion is no longer emitted; compiler acceptance
is still absent. [Result and independent diagnosis](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-compiler-compatibility1-result.md).
New allowance consumed: candidate1/1, invocation1/1, automatic repairs0; historical
cycles2/2 remain closed. Three component passes retain their bounded evidence;
actual counter runtime, remaining profiles/images and fit/P08 remain open.
Earlier pending/current wording below is historical.


Current P08 package boundary — **STOP, 2026-10-14**. Source `8ef34f59`
passed independent source review `72bd3a11`, but the final macOS Dynamic counter
compile failed in Swift 6.4 SILGenCleanup ownership verification for the
`p08CounterGraph` closure. [Package evidence and disposition](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-integrated-package-stop.md).
Three component cells passed (459/5,904/187 assertions); actual counter initial
attempt and both corrective reruns failed before runtime. Both corrective cycles
are consumed (2/2), with ten remaining initial cells and two images unrun.
No automatic source repair, rerun, probe or toolchain change remains authorized.
All nine SO criteria, fit and P08 remain open. The earlier dated checkpoints below
are historical; this boundary supersedes their pending/current action wording.


Current integrated independent SOURCE review — 2026-10-14: [Strong review of `e2d9db9c`](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-integrated-independent-source-review.md) finds **B01 blocking**: current retained-action delivery bypasses the admitted/sealed SPEC-009 mutation path. Original producer guards and full same-inventory/same-address host reconstruction are present; O01 requests targeted application-counter fingerprint coverage. Source readiness fails until correction; no compiler/runtime/fit/conformance result. Broader activity permits a bundled autonomous local correction and independent assessment, with cycles **0/2 consumed**, matrix/images **0 consumed** at review. Historical allowances and the two-unproductive guard persist; no renewed file permission gate.


Current integrated activity — 2026-10-14: Eugene explicitly authorized the
broader P08 implementation/review/validation activity instead of micro-step
approval loops. The [activity record](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-integrated-activity.md) supersedes prior current per-file/
source-only stops for necessary existing-contract P08 work, preserving historical
budgets/evidence. Sequential initial pass plus at most two corrective cycles;
predefined 14-cell profile matrix and two early images, affected reruns only.
No contract/resource/platform relaxation, P09 expansion or hardware operation.
Escalate material decisions/exhausted budget; commit meaningful steps and report
at the P08 boundary. All criteria/fit remain open at entry.

Current derived repeated-host handoff — 2026-10-14:
[Design/source-boundary proposal](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-06-repeated-host-design-handoff.md)
selects fresh logical hosts and private original-producer checks using existing
physical session provenance; exact naked-raw limit is explicit. Independent
Strong [design review PASS](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-06-repeated-host-independent-design-review.md);
ready for a concrete human five-file one-source-pass/zero-followup decision. No source allowance exists. Frozen `369906ab`/review `5ba87bd0`,
correction1/1 consumed, all criteria/fit/P08 and budgets/guard remain unchanged.

Current corrective independent review STOP — 2026-10-14:
[Sol 6.1 High source rereview of `369906ab`](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-06-corrective-independent-review.md)
confirms findings 1–4 corrected as source; finding 5 full-host repeated sessions
remains absent. Physical inventory reuse with fresh logical owners is compatible
with the existing terminal-host contract; root/model resurrection is not a fix.
Runtime-local namespaces and persistent model-owner issuance have different
lifetimes. The next autonomous derived handoff must establish old action/input/
source/admission rejection at reused control addresses and name the smallest
source whitelist before requesting another bounded source allowance. Correction
1/1 consumed; zero automatic follow-up repairs and no compiler/runtime/image
allowance or historical budget/guard reset. All criteria/fit/P08 remain open.

Historical corrective source freeze — 2026-10-14: the commit containing this
header freezes the one authorized correction from `03f3393b`. The
[source receipt](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-06-corrective-source-freeze.md)
records findings 1–4 corrections, checked surplus/prefix borrows, exact labels
and symbolic accounting. Finding 5 actual host reuse remains unresolved for
independent scope/lifecycle classification; no unlisted source, terminal-owner
resurrection or identifier reset. New independent Strong SOURCE review is next,
zero automatic follow-up repairs. No compiler/build/formatter/harness/run;
all criteria/fit, budgets/guard and I4-07/P09–P12 remain open/unchanged.

Historical corrective source dispatch — 2026-10-14: Eugene approved one bounded
source correction of the five findings at `0e047ee4`, with “Please go ahead”.
Use the [reviewed correction boundary](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-06-independent-source-review.md#criteria-disposition-and-next-bounded-decision),
then freeze/commit and independent Sol 6.1 High review; zero automatic follow-up
repairs. No compiler/build/formatter/runtime/IR/image/target allowance. Earlier
source freezes and budgets remain historical evidence; all criteria/fit stay open.

Current source review STOP — 2026-10-14: independent Sol 6.1 High
[review of `0bb4d9ca`](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-06-independent-source-review.md)
finds five source-readiness blockers in the frozen SO-04→06 package: Embedded
shadow assignment, inert cleanup assertion, surplus slot overlap, incomplete
actual active/retired escape matrix and missing full host/control reuse.
Physical/accounting and compiler/runtime/target/fit proof remain open. SO-04
`fd879ad0`, SO-05 `825603a2`, SO-06 `0bb4d9ca` remain unvalidated source
checkpoints; no corrective pass or compiler/formatter/build/run occurred.
The exact next correction is proposed only; SO-07–09 remain separately gated.
All criteria, lifecycle statuses, historical budgets/guard and I4-07/P09–P12
obligations persist. [Freeze ledger](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so06-source-freeze.md).

Historical resumption — 2026-10-14: Eugene approved the exact reviewed
CounterAdmission.swift conformance-clause addition with “Ok, please then go ahead
with it”. Resume the existing sequential SO-04→06 source pass, per-step commits,
zero automatic repairs and independent Sol 6.1 High source review. Witness bodies
remain unchanged; no compiler/build/executable/debugger/IR/image/target allowance
or historical budget reset. [Scope and approval](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-source-execution-proposal.md).

Independent scope review — 2026-10-14: [Strong review of `97f1fe3b`](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-source-scope-review.md)
confirms the extension-default inference and minimum CounterAdmission.swift
conformance-clause-only addition. No compiler failure demonstrated; no other
predictable unlisted same-boundary extension found. Productive source discovery,
no source realization/repair or allowance reset. Exact maintainer scope decision
is pending; SO-04→06 stay stopped/incomplete and all gates/counters remain intact.

Current source stop — 2026-10-14: inspect authorized `a8471eb3`; the sole
pipeline opportunity conformance in unlisted `CounterAdmission.swift`:13 has
no explicit suppressed G/C/R/H extension constraints. The [frozen source
inference and minimum added-file proposal](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-source-scope-stop.md)
await independent Strong source review. No compiler failure demonstrated;
SO-04→06 incomplete, no source realization or corrective pass, no compiler/
build/executable/debugger/IR/image/formatter/target action. No coherent source
freeze/label registration reached; all historical counters/guard and open
criteria/fit retained. Existing authorization is preserved below; no added
path or renewed allowance is inferred.

Current source authorization — 2026-10-14: Eugene approved the exact
[SO-04→06 source package](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-source-execution-proposal.md)
with “Please go ahead”. One sequential source pass, separate step commits, zero
automatic repairs, then independent Sol 6.1 High source review. No compiler/build/
executable/debugger/IR/image allowance; SO-07–09 remain separately pending.
Historical budgets, all criteria and the stack failure remain unchanged.

Current SO-03 fixture stabilization — 2026-10-14: source `57175025`, result
`2adc9e28`, [independent Strong review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so03/fixture-stabilization/independent-review.md)
at `de51b8a5` passes the bounded package: 43/43 cells, 42 compiler oracles and
native execute, 61 scoped/owned assertions with zero failures. SPEC015 measurement
callers remain source-inspected only. Repair/native allowances each 1/1 consumed,
automatic repairs 0; earlier counters/guard stay closed. The concrete next
[SO-04→06 source package](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-source-execution-proposal.md)
is proposed/unapproved: sequential provisional commits, zero compiler/build/run
or automatic repair, then independent Strong source review. SO-07–09 require
separate allowances. All criteria/fit/HC-RD-003/P08/R07/T8.1 and I4-07/P09–P12
remain open; Specs implementing/plans active.

Historical independent trap review — 2026-10-14: [Strong review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so03/correction-2/trap-diagnostic/independent-review.md)
passes diagnostic scope/identities and proves a local Canvas fixture defect:
InteractionProbe.swift stores an action without appendRecord; records stays 0,
so store must fail invalidIdentity if reached. Exact observed PC-to-condition
mapping and host-check completion remain unproved. Proposed only, NOT AUTHORIZED:
one checked appendRecord after the enter loop, preserving reference ordinal 0,
then one fresh native driver/zero automatic repairs and independent review.
This expands beyond prior ScopedStorageProbe-only correction scope and requires
new specific authority. No debugger/compiler/run/source action in review.
122/128/24/130/84 identities and all 43 native argv match; 42 compiler oracles
persist. Diagnostic and three native allowances each 1/1 consumed, corrections 2,
automatic repairs 0; productive narrowing grants no reset or further authority.
All nine criteria/fit/58,648-vs-27,648/HC-RD-003/P08/R07/T8.1 and I4-07/P09–P12
remain open; Specs implementing/plans active, SO-04–09 unapproved. STOP for
maintainer disposition of the exact proposal.

Historical frozen-executable diagnostic — 2026-10-14: [First-trap result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so03/correction-2/trap-diagnostic/result.md)
locates the first stop at EXC_BREAKPOINT `0x100084810`, specialized
`so03RecordOperations(_:) + 260`, with actual SO03Session storage types. Exact
failed condition/root cause remains inconclusive from optimized symbols/window.
One authorized launch/PID 75302, six-frame backtrace/PC/images/16 instructions,
then kill/status 9; debugger exit 0 is not runtime acceptance. Stalled worker
permission request was cancelled before execution; parent ran exact reviewed argv
once after confirming no launch marker/logs. No continue/restart/fallback/source/
compiler/probe/repair. All 122/128/24/130/84 identities match pre/post; frozen
source `ef46dd4b` and binary unchanged. Diagnostic 1/1 consumed, 0 remaining;
three native allowances each 1/1, corrections 2, automatic repairs 0, historical
budgets/guard preserved. STOP for separate independent Strong read-only review
before any repair proposal. All nine criteria, physical fit/58,648-vs-27,648,
HC-RD-003/P08/R07/T8.1 and mandatory I4-07/P09–P12 remain open; Specs
implementing/plans active, SO-04–09 unapproved. No further run/compiler/source
or instrumentation authority remains.

Historical independent helper review — 2026-10-14: [Strong review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so03/correction-2/independent-review.md)
passes exact helper scope/frozen evidence and all 42 native compiler oracles
(30 zero exits, 12 intended negative rejections; 27 focused cells and link).
SO-03 runtime remains blocked: sole execute -5, empty output, no established
cause/location or demonstrated contract defect. 122/128/24/130 identities,
84 historical files and all 43 argv/oracles match; source `ef46dd4b` stays frozen.
Correction 2 is productive: 29 new compiler/oracle passes over the preceding 13;
no new unproductive increment is justified; historical guard/counters stay closed.
All three native allowances remain 1/1 consumed, 0 remaining; corrections 2,
automatic follow-up repairs 0. Proposed only, NOT AUTHORIZED: one debugger launch
of the existing pinned executable, first-stop backtrace/PC/image evidence, no
compile/rebuild/source repair/relaunch, then independent Strong review. No
further source/compiler/run authority remains. All nine criteria, fit, P08/R07/
T8.1/HC-RD-003 and I4-07/P09–P12 remain open; Specs implementing/plans active,
SO-04–09 unapproved. [Frozen native outcome](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so03/correction-2/result.md).

Historical independent correction review — 2026-10-13: [Strong source/result review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so03/correction-1/independent-review.md)
classifies the failure as a local initializer-call lifetime error, no demonstrated
contract defect. Five temporary mutableSpan accesses end before the line-532 state
read. Common-session factory source follows the reviewed actual-owner/token/private
descriptor pattern, but its acceptance is unproved. Exact 122/128/24/80 hashes and
43 planned/14 attempted argv match; 13 pass/1 fail, 27 focused/link/execute unreached.
One correction narrowed the cause productively; zero automatic follow-up repairs,
no historical counter reset. Both native allowances stay 1/1 consumed, 0 remaining.
Smallest proposal: same-five-consuming-input helper checks actual so03Union Optional
and returns owned count within the call; preserve all 27 labels/independent omitted
inputs. One correction/one fresh native driver/zero further repairs plus independent
review is proposed, NOT AUTHORIZED. No source/compiler action follows. All nine
criteria/fit/P08/R07/T8.1/HC-RD-003 and mandatory I4-07/P09–P12 stay open; Specs
implementing, plans active, SO-04–09 unapproved.

Historical SO-03 correction outcome — 2026-10-13: unvalidated fixture source
`8d996626`, clean native entry`16499074`; single authorized rerun FAILED at
OwnedKeyProbe line532 initializer-only precondition use. Actual14compiler cells
13pass/1fail;27focusedprobes/link/execute unreached. [Frozen result and independent
review handoff](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so03/correction-1/result.md).
Newallowance1/1consumed,0remaining; correction1,automaticfollowuprepairs0; no source
edit after failure. Original1/1 and all historical counters stay closed. Stop for
sequential independent Strong read-only review/classification; no next compiler or
repair/SO-04+/suite/target/hardware authority. Allcriteria/fit/P08/R07/T8.1 and
mandatory I4-07/P09–P12 stay open; Specsimplementing/plansactive.

Historical SO-03 checkpoint — 2026-10-13: source `4c7e8bc2` is frozen after the
single native driver failed at the scoped fixture exchange. Actual14compiler
cells13pass/1fail;27focusedprobes/link/execute were not reached. Allowance1/1
consumed,0remaining; automaticrepairs0.
[Exact result and independent review handoff](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so03/result.md).
The [independent Strong review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so03/independent-review.md)
identifies a new local fixture realization defect, no demonstrated contract
defect. Passing checks/narrowed cause are productive; zero repairs attempted,
no historical counter reset. Proposed one fixture correction/one fresh native
driver with zero automatic follow-up repairs remains NOT AUTHORIZED. All
criteria/fit/P08/R07 stay open; SO-04–09 remain proposed/unapproved.

**Prior applicability checkpoint — 2026-10-13.**
SO-01 inventory and SO-02 design/correction review are recorded. Eugene accepted
the [narrow baseline integration disposition](rfc-015-delivery-allocation.md#accepted-pre-existing-integration-gap-disposition--2026-10-13)
and [SO-03 packet](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so02-execution-proposal.md):
preserve the two legacy analyzer factories unchanged, validate real shared owned
dispatcher/all six operation consumers, and require actual analyzer model/root/
target/factory reconciliation and owned-return evidence in ITERATION-004 I4-07
with the existing P09 integration handoff. IN-SO-003/full RFC stays unmet.
Independent readiness verification precedes source dispatch; SO-03 has one native
driver invocation, zero automatic repairs and independent result review.
SO-04–09 allowances remain proposed/unapproved. [Exact receipt](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/progress.md#so-03-applicability-and-allowance-documentation-dispatch--2026-10-13).
Specs stay implementing, plans active; all nine SO criteria, HC-RD-003 and
P08/R07/T8.1 remain open. Historical budgets, guard and 58,648/27,648 failure persist.

## RFC-015 ordered P08 ownership tasks — 2026-10-13

This is an insertion within P08/R07, preserving P01–P12 and every historical
checkpoint. The [delivery allocation](rfc-015-delivery-allocation.md) assigns full
RFC delivery to ITERATION-004 I4-07. SO-01 classifies each change/criterion subcase
by actual P08 dependency or failing gate; every adopted-path safety/fit obligation
stays in P08. No optional uniform analyzer migration is added. SO-09 transfers
exact residual rows, source identities and reusable evidence, even an explicit
empty residual list; partial coverage never closes a full criterion.

Each task consumes the preceding task's recorded result, preserving exact source and
contract identities. A failed check freezes the receipt and invokes the existing
escalation/stop guard; no unchecked workaround or unbounded repair loop is planned.
Validation tasks additionally require the separate allowance under Execution disposition.

| Task / dependencies | Owner, allowed modules/files and work | Required evidence / criteria |
| --- | --- | --- |
| **SO-01 Contract, necessity and caller inventory**; approved/applied amendments | All three owners: inventory six protocols, both states, every direct/transitive/generated/test consumer and actual Static/Dynamic counter route. Confirm operation-only bridge dispatch and owned analyzer/dispatcher/workspace dispositions; preserve old route/oracles. | One caller-to-disposition table with actual symbols, per-change P08 necessity and explicit I4-07 residual, no hidden retained scoped consumer; trace old/new criterion IDs and compiler/feature identities. IN-SO-003; HC-SO-003; B3/B4. |
| **SO-02 Physical design note before source edits**; SO-01 | SPEC-013/015: prepare docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md using checklist below. Review actual StaticCounterEmbeddedBacking.swift, CounterGeometry.swift, CounterStaticGeometry.swift, CounterStorageMeasurement.swift, CounterHostAssembly.swift and Static/Dynamic host/pipeline initialization and teardown. | Concrete reviewed physical/cleanup plan, no guessed fit; named old/new binding/init/deinit/audit sites and all return paths. RP-SO-001/002; HC-SO-002; B2. |
| **SO-03 Interaction and operation consumers**; SO-02 | SPEC-011: InteractionStorage/Values/State/OwnedKeyState/ExecutionGestureAdapter; RuntimeCore RecordInteraction/Canvas bridges, CandidateTransaction/Coordinator/Resolution/Dispatcher. Apply exactly six headers, full state constraints/unions, conditional conformances, owned measurement and selected consumer bounds. Owned Static/StaticSix/Dynamic aliases and analyzer consumers remain owned. | Focused owned/scoped state and failable Optional positive/negative pairs, same-state-machine compatibility and caller inventory update; no seventh protocol. IN-SO-001/003; B1/B3. |
| **SO-04 Typed physical owner and exclusive factory**; SO-03 | SPEC-013/015: finite RuntimeDerived storage assembly/backing and geometry files identified by SO-02. Replace old Optional slot as one migration; typed final-region initialization, prefix inventory, common session/provenance, pair capacity validation and owned measurement. | Fault-at-each-initialization-address and pair-capacity tests; physical ledger including unequal sufficient extents; no old live overlay. RP-SO-001; IN-SO-002/003; HC-SO-002; B2. |
| **SO-05 Complete carriers and retirement**; SO-04 | SPEC-013/015: CounterHostOwner/CounterDynamicHostOwner/CounterPipelineOwner/CounterDynamicHostProbe/CounterStorageMeasurement and actual Dynamic pipeline/supplied symbols from SO-01; Static/DynamicRuntimeExecutionCoordinator only for required preserved constraints. Consume capabilities through host, Optional quiesced extraction and scoped retirement; confine owned returnWorkspaces extension. Install body cleanup before activation. | Direct and generic positive/negative carriers including every bank, geometry, model/root/semantic/value/control and activation span independently; inert/failure/active transitions. IN-SO-001; RP-SO-002/003; HC-SO-001/002; B1/B2. |
| **SO-06 Transaction and lifecycle corpus**; SO-05 | All three owners: directly corresponding Interaction/runtime/SPEC015 unit and contract fixtures, existing control/oracle helpers. Exercise role/count swaps, refusal, capacity/identity/generation boundaries, semantic reuse, early returns and repeated sessions. | Address/count/role/destruction transcripts; both profiles agree; all physical lifecycle paths and old action/semantic/pixel controls preserved. IN-SO-002/003; RP-SO-001/002; HC-SO-002; B2/B3. |
| **SO-07 Pinned four-profile boundary validation**; SO-06 | Owner drivers scripts/contracts/run-spec-011.sh, run-spec-013.sh and run-spec-015.sh, registered finite counter routes and directly related negative generators. Use approved project-local Swift 6.4 and feature flags; format maintained Swift before repository gate. Run authorized focused matrix then required registered gates once at the frozen source. | macOS Dynamic/Static, Pi ARMv6 Dynamic and nRF Embedded Static receipts, positive twin of each negative, exact failure cause and static/runtime-exclusivity classification, source/compiler/input hashes. IN-SO-001/003; RP-SO-003; HC-SO-001/003; B1/B3. |
| **SO-08 R07 early images and complete construction-stack check**; SO-07 | SPEC-013/015: existing Raspberry Pi and nRF build routes/recipes only, through their toolchain/build skills. Link current finite-counter early artifacts; inspect ABI, allocation reachability, linked sections and actual enclosing construction plus nested helper stack/feasible IRQ overlap. | Current ELF/map and immutable ledger, Static zero heap and matched Dynamic costs, unchanged target ceilings including 27,648 main stack; no source-size or link-only fit claim. RP-SO-003; HC-SO-003; HC-RD-003; B2/B3. |
| **SO-09 Independent P08 exit**; SO-08 | All owners: freeze criterion matrix, caller/physical ledgers, command/results and open gates in P08 receipt; separate read-only Strong review. | Accept only complete applicable P08/B1–B3 evidence; transfer remaining full-scope rows to I4-07 without marking them met; maintain open P10–P12 obligations and actual timing/hardware dispositions. P08/R07/T8.1 remain open on any missing/failing evidence. HC-SO-003 and P08-applicable coverage of all nine SO criteria; B4. |

SO-07's protocol-owner evidence is bounded to changed contracts and compatibility;
it does not reopen baseline implementation or claim full analyzer migration. P09–P12
remain the existing separate sequential packages, not work authorized by this handoff.

The [pre-code physical design-note checklist](rfc-015-p08-handoff.md#pre-code-physical-design-note-checklist)
and [execution disposition and preserved budgets](rfc-015-p08-handoff.md#execution-disposition-and-preserved-budgets)
are adopted as the design/review and execution constraints. SO-02 must cover every
checklist item and receive separate Strong review before source work. Its
owner-plan metadata links now exist. SO-03–09 require ordered
prerequisites and a separate recorded source/command/profile/attempt/repair allowance;
SO-03 alone now has the separate recorded allowance above. Strong ownership/lifetime/resource routing and independent
Strong P08 exit remain as specified below, without a new model selection.

| Criteria | Owner/checkpoint | Ordered task/evidence mapping | Disposition |
| --- | --- | --- | --- |
| IN-SO-001 | SPEC-011 T12.1 | SO-03/05/07, declarations/state unions/owned Optional and copy/escape pairs | unmet |
| IN-SO-002 | SPEC-011 T12.1 | SO-04/06, pair/exchange/capacity and existing transactional controls | unmet |
| IN-SO-003 | SPEC-011 T12.1 | SO-01/03/04/06/07, caller/owned compatibility/client negatives/measurement | unmet |
| RP-SO-001 | SPEC-013 T11.1 | SO-02/04/06, physical inventory/prefix unwind/capacities | unmet |
| RP-SO-002 | SPEC-013 T11.1 | SO-02/05/06, cleanup/repeat-session/Optional/exclusivity | unmet |
| RP-SO-003 | SPEC-013 T11.1 | SO-05/07/08, four carriers/linked ABI/complete stack/resources | unmet |
| HC-SO-001 | SPEC-015 T8.1 | SO-05/07, complete carrier chain/independent negative matrix | unmet |
| HC-SO-002 | SPEC-015 T8.1 | SO-02/04/05/06, binding/control/audit/destruction/cleanup and old controls | unmet |
| HC-SO-003 | SPEC-015 T8.1 | SO-01/07/08/09, actual routes/images/resource inventory/independent exit | unmet |

SO-09 reconciles P08-applicable portions of all nine rows and the unchanged
four-counter-route/R07 early-image/gross-resource/T8.1 gates. Final P10–P12 and
hardware/timing dispositions remain separate; P09 cannot start from document
readiness or partial SO evidence.

**Historical P08 checkpoint — one optimized-IR capture failed, 2026-10-13.**
Unchangedsource63e717d1; ed985668 prescribed one frozen firmware owner capture.
[Exact failure](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r07-firmware-recipe/production-attempt/backing-realization/phase-split/ir-capture/result.md) records actualexit-5, emptylogs, no isolatedIR/module
output and482matching frozeninputs; only3outputaction/path argv substitutions.
Capture1/1 consumed; no retry/causeclaim/source/build/link or design selected.
Prior four current routes/link pass and58648-byte nested stack failure persist.
STOP for independent read-only review/package boundary; no guardreset or human
contract gate inferred. SPEC015 implementing/planactive/P08/T8.1 open;
P09–P12/hardware untouched.

**Historical P08 checkpoint — phase-split routes/link PASS; construction stack FAIL, 2026-10-13.**
Source63e717d1 changes exactly reviewed fixture/helper and Static-negative seam.
NativeStatic/Dynamic1,349,555/1,349,501zero, Pi28/28, nRF26/26 pass; five seam
counts1 and exact lifetime oracles retained. [Bounded linked result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r07-firmware-recipe/production-attempt/backing-realization/phase-split/result.md)
records supportedexit0, ARMv7E-M/VFP, flash299332/RAM152320, heap0/GOT20/noRAMcopy/
no relocs. Actual enclosing construction closure0x17a48 reserves58648local bytes,
exceeding unchanged27648by31000; actual helpercalls and root attribution retained.
Smaller helpers do not pass nestedstack. STOP for independentStrong result and
packageguard disposition. Current onecorrection/image consumed; all historical
closed allowances and two-consecutive-unproductive rule preserved, no reset or
renewed budget. SPEC015 implementing/planactive/P08/T8.1 open; P09–P12/hardware
untouched, no target execution/current-source Pi image/fullP11peak claim.

**Historical P08 checkpoint — phase-split test seam pending review, 2026-10-13.**
Independent678e5880 permits the candidate inout helper split. [Pre-edit finding](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r07-firmware-recipe/production-attempt/backing-realization/phase-split/seam-finding.md)
identifies necessary Static escape-generator maintenance outside its one-file
handoff. No source/check/build ran; source38ba440d four-route/link passes and
72208-byte nested stack failure remain current. Separate Strong review next;
no human contract gate, guard reset, P09 or hardware action.

**Historical P08 checkpoint — current routes/link PASS; nested gross-stack FAIL, 2026-10-13.**
Source38ba440d has current nativeStatic/Dynamic1,349,555/1,349,501 zero failures,
Pi28/28 and nRF26/26 compile routes. [Exact bounded result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r07-firmware-recipe/production-attempt/backing-realization/result.md) records the
single supported nRF build actualexit0, ARMv7E-M/VFP, flash298932/RAM152320,
heap0, caller BSS120704 and20-byte GOT inside ROM/no RAM copy/no relocations.
Linked roots shrink, but actual selected nested host control closure0x17bd0
reserves72208local bytes, exceeding unchanged27648 by44560 alone. STOP for
separate Strong review; no automatic source repair or further build. No full
P11 peak audit, target execution, hardware or current-source Pi image claim.
Historical helper2/2+B031/1/diagnostic1/1/earlier image1/1 stay closed; current
backing image1/1 consumed and two-consecutive-unproductive guard preserved.
SPEC015 implementing/plan active/T8.1/HC-RD-003/P08 open; P09–P12 pending.

**Historical P08 checkpoint — backing source committed; native routes PASS; capacity interruption, 2026-10-12.**
Reviewed backing design `19d07b6e` and source `38ba440d` preserve the existing
counter workload. Current native Static/Dynamic pass 1,349,555/1,349,501 assertions
with zero failures. [Exact checkpoint](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r07-firmware-recipe/production-attempt/backing-realization/result.md) records the completed evidence and
remaining sequential Pi/nRF routes, supported image, resource/stack checks and
independent review. Selected Sol 6.1 High workers returned repeated capacity
errors; no substitute model, new compiler attempt or repair followed. The
Embedded backing implementation is not yet target-validated. Previous image
stack failures remain historical, not current-source measurements. All closed
allowances remain closed; SPEC-015 implementing/plan active/P08/T8.1 remain open.
P09–P12 are pending; no hardware action or package pass is claimed.

**Historical P08 checkpoint — supported nRF image links; gross-stack FAIL, 2026-10-12.**
Reviewed sourcee5620a35 uses existing Zephyr RODATA hook; [single supported build](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r07-firmware-recipe/production-attempt/result.md)
passes actual exit0, final ELF/HEX/map/ARMv7EM/VFP/zeroheap/linked RAM31616 and
flash297604. GOT20bytes lie inside accounted ROM, no RAM copy/remaining relocs.
Actual selected root calls graph32344byte then host121216byte local frames;
both exceed unchanged mainstack27648. STOP for separate Strong review; no
follow-on repair or limit/workload/runtime/compiler/source relaxation. Four R06
routes and qualified Pi early image remain; R07/P08 exit incomplete.
Initial supported-build1/1 and diagnostic1/1 consumed; historicalhelper2/2+B031/1
closed. SPEC015 implementing/planactive/T8.1/HC-RD-003/P08 open, P09–P12 pending.
No hardware action or target stack-fit claim.

**Historical P08 checkpoint — one R07 GOT-placement diagnostic PASS; independent review next, 2026-10-12.**
Independent433599e3 prescribed one isolated link, now [actual exit0](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r07-firmware-recipe/got-placement/result.md)
with the sole GOT script-block change and three argv operand substitutions.
All346frozen inputs match;20GOTbytes retain two runtime entries, actual
RasterFillCoverage intersection survives. Diagnostic pre0 ELF/map only; no
production correction or final Zephyr/image-fit acceptance. One-link budget1/1
consumed, STOP for separate Strong review. Four current R06 routes pass; Pi early
image remains separately qualified. Final supported nRF image/ABI/zeroheap/
RAM/flash/gross-stack and independent P08 exit remain open. Historicalhelper2/2+
B031/1 closed; no compiler/source/config/runtime/limit change or hardware action.
SPEC015 implementing/planactive/T8.1/P08 open; P09–P12 pending.

**Historical P08 checkpoint — R07 residual nRF link diagnosis stopped for independent review, 2026-10-12.**
Four current R06 counter routes pass; Pi early image linked with its qualified
ARMv6/VFP/resource result. Corrected nRF firmware recipe attempt2 compiles24owners
but prelink exits1. [Frozen sequential diagnosis](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r07-firmware-recipe/diagnosis/result.md)
records four isolated link diagnostics, all exit1/no ELF; orphan reporting mode
alone does not explain the failure, exact cause unresolved. No compiler/source/
recipe/config repair in this continuation. Further variants stopped by parent
pending separate Strong review. Final nRF ABI/zeroheap/RAM/flash/gross-stack and
independent P08 exit remain open. Historicalhelper2/2+B031/1 closed; zero production
repairs this continuation. SPEC015 implementing/planactive/T8.1/P08 open;
P09–P12 pending, no hardware action or target/image-fit claim.

**Historical P08 checkpoint — four current counter routes PASS; early images next, 2026-10-12.**
Source1497f0ae actual nativeStatic/Dynamic PASS1,349,555/1,349,501 zero24/24;
Pi ARMv6 PASS28/28 and nRF Static PASS26/26 compile-only. All4current source input
sets match. [Exact current-route result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r06-current-routes/result.md).
R07 early linked images/map/ABI/RAM/stack/allocator and independent P08 exit remain
open; no target execution/image-fit claim. Historical helper2/2+B031/1 closed;
SPEC015 implementing/plan active/P08/T8.1 open, P09–P12 pending.

**Historical P08 checkpoint — corrected nRF counter route PASS; other current routes next, 2026-10-12.**
Independent7f6ef917 authorizes bounded contract-owner import realization. Corrected
Embedded Static route PASS26/26;207 current inputs match. [Exact correction,
failures and remaining route obligations](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r06-import-correction/result.md).
Native/Pi earlier receipts remain historical after shared source changes; fresh
current-source routes and R07 linked images/resource/ABI remain open. No target
execution/image-fit claim. R01–R05 accepted; historical helper2/2/B031/1 closed.
P08/T8.1 open, SPEC015 implementing/plan active, P09–P12 pending.

**Historical P08 checkpoint — R06 route WIP stopped for authority/scope review, 2026-10-12.**
R01–R05 native are independently accepted at0f7290ce; tiled endpoint source at
c49fc9b0 passes1,353,625/0,24/24. Current selected nativeStatic/Dynamic routes pass
1,349,555/1,349,501 assertions, zero failures24/24; Pi ARMv6 current Dynamic route
cross-compiles28/28. nRF fails fresh HostConfiguration compilation on130 missing
per-file direct-import diagnostics in5files, before counter model. [Exact frozen
route checkpoint and dependency authority packet](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r06-profile-routes/result.md).
No import/dependency repair or image work pending separate Strong review; no target
execution/image fit claim. Historical helper2/2/B031/1 closed. P08/T8.1 open,
SPEC015 implementing/plan active, P09–P12 pending.

**Historical P08 checkpoint — R05 native PASS; separate review next, 2026-10-12.**
[Finite actual construction-origin result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r05-factory-origin-controls/result.md) passes2,697,625 assertions/zero
failures24/24. All13 legal-edge omissions and3 concrete hidden/bound-input cases
reject at graph stage before eight later projections; canonical selections drive
actual endpoint/text, root/admission and full-report scheduler constructors.
R01–R04 native results are independently accepted at7254e752; R05 result review
remains pending. Actual nested geometry/backing-last proof stays qualified; no
standalone stale-geometry claim. Historical helper2/2/B031/1 remain closed.
No targets started. Registered routes/Embedded/early images and independent P08
exit remain open; SPEC015 implementing/plan active/P08/T8.1 open, P09–P12 pending.

**Historical P08 checkpoint — R01–R04 native results; R05 finding for review, 2026-10-12.**
Latest native source `1f3a7ea0` passes2,697,541 assertions/zero failures24/24:
actual native binding/wake/refusal/supersession and seven-stage activation controls,
with both scoped-host escape negatives. Raw geometry expiry evidence remains
explicitly qualified. [R05 finding and exact review handoff](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r05-factory-origin-findings/finding.md) records required
factory-origin/callback omissions before later projections; proposed finite inert
descriptor is unimplemented pending sequential Strong review. No new contract or
user approval gate is inferred. Independent native review remains pending; no
target build. Historical helper2/2/B031/1 closed; P08/T8.1 open, P09–P12 pending.

**Historical P08 checkpoint — R02 native PASS, 2026-10-12.**
[Reviewed lexical continuation](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r02-binding-controls/continuation-result.md) passes1,349,199 assertions/zero failures
and23/23 checks, including actual Static/Dynamic binding rejection and own34/35
operational controls. Independent result review remains pending. The preceding
pause was conservative; its two corrections narrowed distinct causes, and the
first owner-capture correction now passes. Historical helper2/2 and B031/1
remain closed. R03–R05 and P08/T8.1 remain open; P09–P12 pending. No target
build or analyzer applicability claim follows from this finite-counter result.

**Historical P08 checkpoint — conservative R02 pause, 2026-10-12.**
R02's initial invocation and two bounded corrections all stop at counter-model
compilation. The current WIP is unvalidated; its new actual-probe test closure
captures a lifetime-dependent owner, which the pinned compiler rejects. Parent
confirmed no further repair, rearrangement or compilation before independent
read-only Strong review. [Exact checkpoint and options](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r02-binding-controls/result.md).
Last validated native source remains R01 `d2df7dcc`:1,349,005 assertions/zero
failures,23/23 checks. B03 independent acceptance remains its bounded historical
result. R03–R05 were not started. Historical2/2 and B031/1 remain closed; the R02
stop does not reset either. Counter34/35 and analyzer20/2/6,28/32/33/category
applicability stays as reviewed; analyzer evidence remains mandatory P09/P10/P11.
SPEC-015 implementing/plan active/T8.1 and P08 open; P09–P12 pending.

**Historical P08 checkpoint — B03 independently accepted; remaining P08 open, 2026-10-12.**
B01 inventory/review and B02 bounded helper/mask realization are complete. The
single B03 native invocation at source `102382d7` passes1,348,673 reported
assertions/zero failures and23/23 checks; independent Strong result review at
`5475f547` accepts that bounded result. [Review and remaining-work handoff](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/option-b/b03/independent-review.md).
The current user authorizes remaining P08 execution; R01 adds actual rejected-
admission wake/timestamp invariance and multiple-fact/category deadline controls.
Only new controls justify fresh source-specific validation; no unchanged B03
rerun or same-helper repair is authorized. Historical2/2 remains closed; B03's
1/1 attempt is permanently consumed. All other operational/origin gaps, four
registered application routes, actual Embedded endpoint, early linked target
images/resource/ABI and final independent P08 exit remain open. SPEC-015 stays
implementing, its plan active and T8.1/P08 open; P09–P12 pending.

**Historical P08 checkpoint — Option B documents approved; implementation separate,
not started, 2026-10-12.** Eugene selected Option B and instructed that its
required documents be treated as approved, then explicitly said not to proceed
with its implementation in this activity. [Exact approval and limit](rfc-014-spec-approval.md#option-b-construction-graph-amendment--2026-10-12).
Accepted [ADR-038](../../adrs/adr-038-construction-graph-and-operational-contracts.md)
and the amended SPEC-015 graph/operational contract resolve the decision needed
at the prior checkpoint. They do not validate the existing masks or replace
construction, backing, activation or runtime proofs.

Last validated source remains `48a987cd` (1,348,627 assertions / 23 controls);
`cfaa57af` preserves unvalidated graph WIP. Historical **2/2** stays closed;
the later native allowance stays **0/1, unconsumed**. No source edit, compiler
invocation or target build occurred for this documentation activity. SPEC-015
remains implementing, its plan active and T8.1/P08 open. P09–P12 remain pending.
The separate implementation activity starts at the bounded B01→B02→B03 sequence
below, then the remaining existing P08 gates. No step runs automatically from
this documentation approval. Earlier stops/approvals below are preserved as
history; their decision-required language predates the approved Option B delta.


**Historical P08 checkpoint — graph-boundary decision required, 2026-10-12:**
The user explicitly approved the previously proposed bounded continuation at clean
`87b6a0bf`: dependency trace first, two projection-helper replacements, then one
native gate attempt with no automatic repair. [Trace checkpoint](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/step-7g-graph-stop/bounded-continuation-trace.md)
`fca0a3a9` and sequential independent Strong review found that the current actual
admission11→canonicalWake16 notification is a forbidden upward dependency under
the exact direct graph contract. Backing indirection cannot erase it. Affected
source edits and compilation stopped before the gate; new allowance **0/1** is
unused and prior **2/2** remains closed. Last validated source is `48a987cd`,
1,348,627 assertions and23 controls. The graph WIP in `cfaa57af` stays unvalidated.

[Decision packet](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/step-7g-graph-stop/graph-boundary-decision.md)
recommends moving notification forwarding to enumerated enclosing host boundaries
using existing outcomes, preserving the approved contract. This exceeds the
currently authorized two-helper edit scope and requires explicit approval; the
alternative is a reviewed Specification amendment to construction-only graph
semantics. Neither is implemented or approved. No compiler or target build ran.
SPEC-015 remains implementing, plan active and T8.1/P08 incomplete; graph,
four routes, early linked images and independent exit review remain open.

**Historical P08 checkpoint — unvalidated graph slice stopped, 2026-10-12:**
Last validated source is `48a987cd`: actual canonical wake integration and
[step7f controls](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/step-7f-wake-controls/result.md)
pass 1,348,627 assertions and 23 controls. The subsequent exact construction graph
and activation projection edits are preserved as an **unvalidated WIP checkpoint**.
Two pinned Swift 6.4 `counter-model` compiles stopped in SILGen at
`CounterHostState.constructedRuntimeProjectionIsValid` with the same
`can't set insertion point to a null instruction` assertion. The local resumed
same-blocker guard is **2/2**; no third compile or repair is authorized under this
allowance. [Frozen stop evidence](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/step-7g-graph-stop/stop.md)
was committed in `b3950465`; the following source checkpoint preserves the exact
failed WIP for independent read-only review. This stop does not reopen the closed
activation audit or establish an upstream contract blocker.

[Independent stop review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/step-7g-graph-stop/independent-review.md)
upholds the stop at clean `cfaa57af`, verifies both frozen failures, and requires
an exact dependency trace before considering a different projection shape.
Its proposed one-attempt continuation is untested and requires fresh explicit
authorization; no further compiler work is authorized by the review.
Graph validation, four registered routes, early linked target-image evidence and
independent P08 exit review remain open. SPEC-015 stays implementing, its plan
active and T8.1 incomplete. No graph validation or P08 pass is claimed. This
checkpoint supersedes the continuation direction in the historical activation
checkpoint below; its approval and completed evidence remain unchanged.

**Historical P08 checkpoint — activation blocker resolved, 2026-10-12:**
The [approved Swift 6.4 correction](rfc-014-spec-approval.md#swift-64-compiler-baseline-correction--2026-10-12)
`267616c9` is applied and the actual generic-host activation join is verified.
[Independent final audit](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-integration/baseline-final-review.md)
`0555805f` passes the maintained join, fresh macro/core/runtime and Foundation
four-profile regressions, matched resource pairs, ABI and isolated native timing.
Both native P08 component gates pass368 assertions and37 checks, including all
four precise ownership negatives. No contract or resource ceiling was relaxed.

The compiler lifetime-containment and activation-time construction blocker is
closed. Continue P08's finite counter/application integration and four-route
application/early-image acceptance under the existing sequence. Synthetic
component reports and application-stage trace adapters do not satisfy full
validator/application evidence. T8.1, complete P08 and P10–P12 remain open;
SPEC-015 stays implementing and its plan active. [Current evidence](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/progress.md)
preserves historical failures, guards and closed budgets.

**Historical P08 stop checkpoint, superseded only by later explicitly bounded work:**
Approved correction `4dbdc2e0`, host propagation `6eda65d0` and schema4 slice
`c39733de` are committed. Both native complete HostConfiguration component gates
pass320 assertions plus ownership/missing-field/generator controls. The attempted
inert owner for an activation-time actual coordinator rejects on the pinned
compiler after two unproductive repairs; [exact stop packet](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-join-stop/stop.md).
Guard **2/2**; no further affected implementation or compiler alternatives are
authorized without a new bounded decision. This does not prove a compiler bug
or justify changing the approved contract. SPEC-015 implementing/plan active;
P08 incomplete, counter/four routes/early images and independent exit review open.
Original approval packet/probes/review and earlier checkpoints remain historical.
[Receipt](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/progress.md).
Evidence-only investigation was separately approved and authorized in `0bc51d70`.
Independent accounting review `c05e6d35` permitted predeclared B under that same
allowance. Its positive failed:3/6 fresh invocations on2/2 layouts, no passing
controls or negatives; conservative candidate guard2/2, productionguard2/2
unchanged. [Finite result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-join-investigation/result.md)
has completed [independent final review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-join-investigation/final-review.md).
Its closed allowance grants no further compiler work or production integration;
later bounded scopes are recorded above. Unused calls are not authority.
P09–P12 remain pending.

**Current P07 checkpoint — finite package exit passed, 2026-10-11:**
The explicitly [resumed consuming-owner implementation](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/consuming-owner-resumption.md)
includes audited construction and lifecycle steps 1–6, followed by R1 (`0741894a`)
and R2 (`ad671ea6`) repairs. The original [independent FAIL](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/independent-exit-review.md)
remains preserved. Fresh [repaired four-route evidence](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/repair-final-evidence.md)
uses clean `ad671ea6`; each native route passes 5904 assertions and twelve
compiler negatives across 26 actual Static/Dynamic case pairs. Cross routes pass
selected-module compilation and CPU/VFP checks; no target execution is claimed.
Independent Strong [repair exit review](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/independent-repair-exit-review.md) passes the finite P07 exit at `329570ab`, resolving R1/R2. Full owner conformance remains separate.
Resumed consecutive unproductive repairs: **0/2**. Historical 2/2 stop preserved.
T9.1/T11.1 and P10–P12 remain open. P08 implementation has begun under the current checkpoint.

The bench and stop records below describe earlier boundaries; their statements
that continuation is unauthorized are superseded only by the resumption above.

> **Focused bench complete (2026-10-11):** [candidate 2 passes](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/focused-bench/result.md)
> on Swift 6.3.2: consuming ownership with audit access while coordinator-owned;
> 535 native assertions and one positive / three negative ownership controls.
> Commits `230f2fe8` and `3997da73`; 7/12 diagnostics and both candidates used.
> Candidate 1 still fails. Production source remains at `c234058e`; the complete
> 26-field audit and P07 exit remain unproved. No further bench or production
> repair is authorized by this completed bounded continuation.

> **2026-10-11 explicit continuation:** Eugene authorized only the sequential
> [focused workaround bench](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/focused-bench/authorization.md)
> for options 1 and 2 on Swift 6.3.2. The original 2/2 stop below remains
> historical; production integration and P08 remain stopped. The new bounded
> bench allowance must not be interpreted as an unlimited P07 restart.

**P01–P07 passed; P08 reviewed R02 continuation, last native PASS R01 d2df7dcc; P09–P12 pending.** This is the shared
sequencing index for nine owner Implementation Plans, not another contract or
investigation. It derives only the [approved Spec amendments](rfc-014-spec-approval.md)
at `3c260bbc`, their subsequent explicit amendments, and accepted ADR-035/036/037/038. ITERATION-003 I3-04/05 supplies the
analyzer/counter and four-configuration delivery scope; the closed MVP supplies
regression semantics. ITERATION-004 external delivery remains separate.

For a new or resumed assignment, use the [task context guide](rfc-014-task-context.md)
to reach the relevant contract, source, tests and current evidence without
reconstructing the investigation history. Package boundaries and model routing
remain in this sequence.

P07's [progress receipt](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/progress.md)
records actual audited construction and enforced configured limits, complete
Static/Dynamic logical transcripts, terminal recovery, actual pointer admission
and checked dispatch, discarded-removal preservation, malformed Drawing rollback
and latest-revision supersession. SPEC-009 T9.1 participates within P07; SPEC-015
host work remains P08. Historical constraint decisions and stop evidence below
are provenance, not the current execution checkpoint.

Historical stop before explicit consuming-owner resumption: [audited-construction repair record](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/audited-construction-stop/stop.md),
committed at `e132dfe5`. Maintained source is restored to validated `c234058e`
(531 native assertions and ten compiler negatives); the failed in-place-lend
patch, exact command, diagnostics and intermediate evidence are preserved.
Actual audited factory/common-coordinator conformance and the remaining package
exit are incomplete. No further affected repair, context switch or alternative
factoring is authorized without the maintainer decision required by the guard.

The prior correction is implemented. The new [associated-type decision packet](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/associated-type-constraint.md)
records the remaining Storage/Handler/TargetAccess boundary, bounded compiler
proof, concrete proposed operational-protocol correction and lost static checks.
The [exact reviewed correction is approved](rfc-014-spec-approval.md#concrete-coordinator-binding-amendment--2026-10-11). Validated slices and honest partial WIP are preserved.
The [independent Strong review](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/independent-associated-type-review.md)
at `8d9f76c9` confirms the blocker and recommends the exact correction with
mandatory concrete binding proofs. Those proofs accompany resumed integration;
separate Strong package exit review remains required.

## Fixed deliverable and scope rules

Deliver one runtime-derived implementation for the existing analyzer and finite
counter: fixed-domain access, stable bounded ownership, exact semantic records,
protocol Canvas, schema-4 host validation and complete conformance/resource
dispositions. Keep existing application behavior, three capture banks, logical
limits, owner dependencies and backend semantics. The counter is the existing
UInt8 0–9 / Increment / Reset / disabled predicates / optional stroke corpus from
the [source inventory](../../../experiments/spike-072-contextual-traversal-integration/application-coverage.md),
not a new application feature project.

The baseline is **12 work packages, P01–P12**, below. Owner task IDs are accounting
checkpoints within those packages; they are not nine additional workstreams.
Each package gets implementation commits, focused evidence and a finite exit.
Do not start a successor before its named dependencies pass. Mark affected Specs
`implementing` and owner plans `active` only when their implementation starts.

- Every edit must name a package and approved criterion. A local repair needed
  for that exit stays in that package; it does not become a new study.
- No new application, target, general Swift frontend, arbitrary cross-domain
  composition, package split/external API, scheduler, renderer, transport, display
  clock, visual redesign, fine-grained observation, lock framework or extra bank.
- No speculative optimization, unrelated cleanup, framework generalization or
  compiler upgrade. Keep the supported source inventory finite. Existing pure
  helpers need no new model generic parameter unless their approved access needs it.
- Optional discoveries get the smallest Future Work record with source/revisit
  trigger; they do not enter P01–P12. Required correctness/resource failures cannot
  be deferred. Record their failing criterion and keep the package incomplete.
- Changing the deliverable, footprint to add another subsystem, accepted bound,
  public behavior or architecture requires a concrete maintainer decision before
  affected work continues. Adding/replacing packages requires an explicit plan
  revision with old/new scope and reason, not an automatically appended backlog.
- Stop a package when its exit passes. Do not keep polishing or broaden tests
  without a changed path or unresolved failure. Run the broad gate at integration;
  later reruns need a code change or a specific unresolved concern.
- After two consecutive repair attempts on the same blocker with no new passing
  check or narrowed cause, stop that affected package and report the failing case,
  attempted fixes and smallest options. Do not restart its allowance under a new
  task name, toolchain or Spike. Independent already-scoped work may continue only
  if its prerequisites hold. This is a progress guard, not permission to weaken tests.

No elapsed-time or feasibility promise is inferred from task count. The bound is
the named delivery surface, fixed package list, finite acceptance evidence and
failure stop rules. A checkpoint report records completed/remaining package IDs,
criterion failures and any proposed scope change after every package.

## P02 direction correction — 2026-10-10

Eugene requested removal of the separate lowering module and migration ifdefs.
P02 therefore amends the existing GiftUI declaration files in place and locates
finite source lowering in the existing GiftUIMacros target. No new target or
parallel declaration implementation is introduced. Historical comparisons use
the pinned P01 baseline revision and receipts. Downstream consumer migration
remains in P03–P09; P10 is the integrated build/conformance gate. P12 still owns
removal of superseded generated topology and final production adoption, and does
not require a second compiled View ABI to be maintained until that point.

## Current repository and permitted footprints

The pre-P02 baseline had context-free `View.body` in
`Sources/GiftUI/DeclarativeView.swift`, retained Canvas closures in
`Sources/GiftUI/Canvas.swift`, existing ObservableState transaction/reconciler
owners, Dynamic/Static model and semantic stores, and RuntimeCore's complete
pipeline/cleanup. P02 has since replaced the declaration ABI in place with
typed domain/read contracts; consumers migrate in P03–P09. Use current source
and package receipts for implementation state, not this baseline description.
Reuse the existing owners and their failure tests.

`scripts/contracts/generate-spec-001-nrf-topology.py`, Canvas-table generation and
`generate-spec-015-workload.rb` still serve generated production inputs. Replace
only the expanded-graph/capture assumptions this migration changes. Keep font and
bounded resource generation. The finite counter has experimental/source inventory
evidence, not an already implemented host; create its bounded repository test
composition as production-contract validation, never claim an external package.

Footprints below include matching unit tests, `Tests/ContractFixtures/SPECxxx`,
contract-driver registration and narrowly required Package.swift wiring. New files
inside these existing owner boundaries are permitted. Importing application
schemas into GiftUI, moving owners between modules or changing unrelated backend
algorithms is not. An integration edit in an unchanged owner must preserve its
contract and be traceable to a failing migration check.

## Option B resumption sequence — separate activity

This is a finite continuation inside P08/T8.1, derived from accepted ADR-038 and
SPEC-015 HC-003, HC-011, HC-014, HC-018 and HC-RD-001–004; SPEC-009's wake contract
remains unchanged. B01 inventory/review, B02 realization and the single B03
attempt/result review are now complete; remaining P08 stays open. Historical
documentation-only activity limits below remain provenance, not the current
execution boundary. Each subsequent implementation assignment must record its
entry revision, exact allowed files, reviewed inventory, dependency/artifact
identities and its applicable bounded validation allowance before edits.
The old 2/2 guard and all closed investigation budgets remain closed. B03 is
1/1 consumed and its command below is historical, not an available rerun.

| Step / dependency | Bounded work and required output | Checkpoint and stop |
| --- | --- | --- |
| **P08-B01**; approved Option B documents | Reconcile the actual eighteen-role factory/owner trace with direct construction inputs, activation wiring and operation-only calls. Identify every mandatory borrowed/retained input, bound construction callback, backing and derived configuration origin. Distinguish the finite counter's actual executor gate from its aggregate; shared Mutation vocabulary from live target access; use-case start and normalized submit operational arguments from construction inputs. Audit admission→canonical wake, binding identity, scheduler, deadlines, phase and backing-last teardown separately. | Commit the inventory and exact proposed masks/projection changes for separate Strong review before source edits. Do not declare current masks valid. A required upward construction edge, hidden origin, ambiguous lifetime or new ownership choice stops for upstream resolution. No compiler invocation. |
| **P08-B02**; B01 reviewed | Replace only the two failed whole-coordinator projection helper shapes and directly corresponding activation call sites using the existing approved controlPointer projections. Reconcile direct construction masks and directly corresponding graph controls with B01's actual inputs; eliminate physical-placement-only edges, retain every required configuration/backing origin. Preserve initializer root/model association, cache lifetime, actual application/endpoint checks and all operational wake proofs. | Commit the bounded source/test diff with its applicability and evidence gaps. No public protocol redesign, automatic Option A forwarding, new wake accumulator, retained requester adapter, unsafe conformance, allocator/capacity/compiler change or unrelated refactor. No feasibility claim before B03. |
| **P08-B03**; B02 complete, reviewed inputs available | Format maintained Swift, then invoke the existing native counter gate **once**, using the verified pinned Swift 6.4 runtime dependency receipt below. Capture exact source/compiler/module identities, command, assertions/controls, diagnostics and outcome. | **No automatic repair or rerun**, whether pass or fail. Freeze evidence, commit the outcome and stop for separate Strong result review. Success establishes only the bounded native slice; failure preserves the exact blocker for maintainer disposition. Never reset the old 2/2 guard or enlarge the one-attempt allowance. |
| **Remaining P08**; B03 passes and independent result review accepts | Continue existing registered macOS Dynamic/Static, Pi ARMv6 and nRF Embedded application routes; actual counter action/text/stroke and host lifetime/activation/failure coverage; early linked Pi/nRF images with RAM/stack/allocator/ABI evidence. | Record source/artifact-specific results and limitations; separate Strong P08 exit review must pass before P09. A native graph pass or cross-build is not complete host/application/hardware conformance. |
| **P09→P10→P11→P12**; preceding existing gates | Analyzer migration → integrated functional conformance → complete resource/workload evidence → production cutover/closeout, within each unchanged package footprint below. | Execute sequentially as separately assigned bounded packages, report and commit each package boundary, retain existing repair/escalation and connected-work approvals. Request implemented transitions separately after conformance; no auto-run during this activity. |

The predeclared single native invocation, for the later assigned B03 only, is:

```sh
python3 scripts/contracts/check-spec-015-counter.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static
```

Its exact dependency receipt must still match before use. Missing/stale inputs
are a handoff blocker, not permission to rebuild a dependency graph, switch a
compiler or spend an extra invocation. Existing native controls must separately
cover queued-only admission notification, every accepted fact behind nonfact
wake, canonical three-reason coalescing and one outstanding bit, cycle-time
notifications surviving the take, refusal/backpressure/supersession/no replay,
terminal rejection and backing validity. Record any missing required coverage
before B02; do not hide an operational or lifetime gap behind a graph pass.

The packet's old Option A forwarding inventory remains historical reasoning;
Option B does not require producer-by-producer forwarding. No helper replacement
or graph implementation has been performed by this documentation update.

## Ordered work packages

| Package / dependency | Implementation boundary and concrete output | Exit evidence; stop when complete |
| --- | --- | --- |
| **P01 — Compiler and baseline**; none | SPEC-002 driver, shared contract-driver forwarding and `.toolchains` selection. Add `--compiler-baseline rfc-014`, keep historical reproduction, record source/recipe hashes and the finite route inventory. Register required invocation in the explicit top-level runner. | Four compiler identity/feature/ABI selections; unknown/missing feature rejection; fresh Foundation PF-006/007 size/allocation/link results. Inventory and baseline are pinned once; no general tooling cleanup. |
| **P02 — Typed declarations and finite lowering**; P01 | GiftUI View/builder/read/key contracts, GiftUIMacros and the application schema/source lowering build step. Implement only inventory syntax/effects, inferred Body, same-domain composition, typed failures and source-located rejection. | Separate core/schema/presentation/host modules compile; arity 0–5, helpers/short-circuit/order and ordinary stateless/custom dispatch; negative wrong-domain/escape/unsupported-effect cases on four configurations. No frontend feature outside the corpus. |
| **P03 — Stable owners and State**; P02 | GiftUIObservableState and Dynamic/Static model, registration, target-access stores; host-owned identity issuance. Implement tickets/pins/checked writes, nested State discovery and three-bank final-ticket transfer/refusal. | Real owner/reconciler callbacks test first install/ignored seeds, retained owners, empty entitlement, second-populated refusal, attach/detach/report faults, stale identities and every pre/postcommit path. Measure actual metadata/ticket/pin layouts now; stop on unsafe backing or an incompatible bound. |
| **P04 — Runtime records and exact identity**; P02, P03 | GiftUISemanticCore and profile semantic storage/codecs. Emit records/path/payload pools from actual traversal, paired exact trie matching, disjoint candidate/published banks. | Declaration perturbation changes topology without graph generation; exact trace/modifier/state identity, fixed-fanout work counts, every first-excess pool case and reader-aware bank reuse. Measure prefix/payload maxima against approved logical limits before integration. |
| **P05 — Layout and committed action keys**; P04 | SemanticCore Layout adapter, narrow Layout/Render consumer joins, GiftUIInteraction candidate/committed storage and host target bridge. Copy complete keys; retain accepted-offer routing semantics. | Layout/oracle equality, scope/depth limits, no model access in Layout, independent keys across multiple bank reuses/refused offers, stale target/release cancellation and atomic key-pool failure. No new layout/raster algorithm. |
| **P06 — Protocol Canvas**; P03, P04 | GiftUI Canvas, GiftUIDrawing invocation/plan adapters and profile staged-value storage; finite witness lowering. Replace escaping Canvas closures while retaining scoped withPath, geometry and raster contracts. | Zero/multiple/repeated occurrences, inferred ordinary bodies, exact model choice, checked local bounds/order, escape controls and exactly-once cleanup including rejection before acquisition. Independent geometry/pixel controls stay unchanged. |
| **P07 — Complete runtime cycle**; P05, P06 | RuntimeCore limits/audit/pipeline/cleanup and both concrete coordinators. Integrate read/discovery/mutation phases, model retirement, candidate semantics, owned geometry, accepted-offer Interaction commit and refusal retry. | Actual Dynamic/Static differential fault transcripts, first/partial failure, no mutation replay, last-read versus registration retirement, quiescence and all early-exit cleanup. No shared mock bridge presented as runtime integration. |
| **P08 — Schema-4 hosts and finite counter**; P07 | GiftUIHostConfiguration, workload generator/validator and finite repository counter fixture plus four host/profile build routes. Implement explicit pool/model/ticket/pin limits, owner caches and audited layout validation. | Schema-3 rejection, missing/mismatched field/witness and below/equal/above limits; complete counter route/action/text/stroke corpus through actual runtimes on four builds. Link early target images and check gross RAM/stack/allocator problems before analyzer migration. |
| **P09 — Analyzer migration**; P08 | SignalAnalyzerPresentation/Domain adapters, SignalAnalyzerTargetHost, Pi/native owners and nRF firmware assembly. Explicit capture selection, protocol Canvas and checked compound mutations; preserve Domain-owned capture semantics and source/admission roles. | Entire route inventory accounted for, real host owner replacement tests, 404/405 and horizon/baseline/Clear/revision boundaries, full diagnostics, action and waveform/pixel oracles. Produce linkable analyzer artifacts with no graph-input dependency in the candidate build. Consume the mandatory unresolved legacy analyzer model/root/target/factory and actual owned-return evidence handoff under the accepted P08 applicability disposition; coordinate its full conformance closure with ITERATION-004 I4-07. |
| **P10 — Integrated functional conformance**; P09 | Existing nine owner contract suites, RuntimeConformance and application/preset harnesses; cross-profile adapters and driver registry only as required by changed contracts. | All 180 owner criteria receive a migration disposition: functional/import/negative/error/pixel evidence here; resource/connected parts explicitly pending P11. Run relevant four-profile drivers and one full hardware-free gate. Never regenerate expected pixels merely to match a changed output. |
| **P11 — Complete resource and workload evidence**; P10 | Actual linked artifacts, map/stack/allocator inspection and existing workload runners; implementation repairs only within the package owning the failure. | Complete live-storage/stack/IRQ ledger, ABI and linked Static zero heap, matched Dynamic costs, preserved three banks and target limits. Record measured 30s acquisition/frame results where authorized. Hardware-free proof and connected evidence are separate; unmet timing/hardware criteria block full adoption, not authorize transport redesign. |
| **P12 — Production cutover and closeout**; P10/P11 migration gates pass or explicit applicable maintainer disposition | Remove superseded expanded topology/closure production build inputs; preserve independent baseline controls and resource generation. Update nine conformance reports, author/build guidance and task dispositions. | Production uses only runtime derivation; final build-dependency scan plus focused post-removal checks. Every criterion cites final artifact/evidence or explicit exception. Request implemented transition separately. If adoption is blocked, record the exact residual gate, keep the baseline route and leave cutover incomplete; no automatic follow-on phase. |

Default execution is sequential in the listed order. P05 and P06 have independent
owner surfaces after their dependencies, but this plan does not authorize new
parallel agents. All shared interfaces are fixed by the approved Specs.

## Complexity, risk and model routing

Added 2026-10-10 at Eugene's request to reserve the strongest model for complex
or consequential work and reduce cost on routine execution. These are planning
estimates for the existing packages, not measured model performance, new work
packages or changes to acceptance criteria. P01/P02 ratings are retrospective;
their completed work does not need rerunning. P03's remaining work uses this
routing from its next safe handoff.

Rate the actual assignment on two independent axes. File count, diff size and
test duration do not determine either rating.

| Level | Complexity (C): reasoning required | Risk (R): consequence of a wrong result |
| --- | --- | --- |
| 1 | Mechanical execution with exact inputs, an established pattern and an objective check | Local, readily detected and reversible; no behavioral or acceptance decision |
| 2 | Bounded implementation across known interfaces; several interacting cases | Behavior or integration regression within an established owner; targeted evidence can establish correctness |
| 3 | Cross-owner invariants, unfamiliar compiler behavior, lifetime/transaction reasoning or whole-image resource proof | Memory safety, stale identity, atomic publication, data loss, resource guarantees or adoption/conformance decisions |

Use three model tiers, mapped to concrete available model IDs and reasoning
settings at execution time. **Economy** is the least expensive model already
adequate for mechanical tasks; **Standard** handles bounded implementation;
**Strong** is the most capable reasoning model available for difficult or
consequential decisions. Price and model names are deliberately not frozen here.
If a cheaper tier has not demonstrated adequacy, start one tier higher.

| Assignment rating | Minimum implementation tier | Review before accepting its result |
| --- | --- | --- |
| C1 / R1 | Economy | Objective checks and normal package review; no separate Strong review for clerical output |
| C2 / R1 | Standard | Normal package review and focused checks |
| C1–2 / R2 | Standard | Strong review of changed behavior and criterion evidence |
| C3 or R3 | Strong | Explicit Strong review of invariants, failure paths and evidence, separate from the implementation pass |

A review pass can use the same implementing agent with the relevant context;
these tiers do not authorize spawning agents or require duplicate implementation.
Model review never substitutes for tests or human lifecycle decisions. Missing
authority or an ambiguous contract is an upstream blocker, not a reason to ask a
larger model to invent a resolution.

### Package ratings and lower-cost assignments

The core rating applies if a package is assigned as a whole. The bounded slices
below allow cheaper execution after their inputs and expected results are fixed.
Their parent dependencies, exit evidence and repair limits remain in force.

| Package | Core C / R | Core tier | Reason for rating | Lower-cost slice and prerequisite |
| --- | --- | --- | --- | --- |
| P01 | C2 / R2 | Standard | Compiler selection, ABI forwarding and baseline provenance affect every later result | Economy C1/R1: execute fixed identity commands and collect hashes; unexpected compiler/ABI results return to the core owner. Already complete. |
| P02 | C3 / R3 | Strong | Domain inference, source transformation and escape rejection define the typed safety boundary | Standard C2/R2: add cases from a reviewed syntax/diagnostic matrix without changing lowering or expected semantics. Already complete. |
| P03 | C3 / R3 | Strong | Backing lifetime, pins, registration retirement and three-bank transfer/refusal must agree on every failure path | Economy C1/R1: run fixed owner tests and collect layout sizes after Strong supplies the cases; Strong interprets lifetime and bound results. |
| P04 | C3 / R3 | Strong | Exact identity, bank reuse and bounded reconciliation couple semantics to storage | Standard C2/R2: implement enumerated first-excess fixtures after Strong fixes pool rules and independent expected outcomes. |
| P05 | C2 / R3 | Strong | Small consumer joins can misroute committed actions after bank reuse or refused offers | Standard C2/R2: adapt Layout fixtures to the fixed borrowed-view interface; committed-key ownership and retirement stay Strong. |
| P06 | C3 / R3 | Strong | Deferred Canvas values, scoped reads, staged storage and exactly-once cleanup cross lifetime boundaries | Standard C2/R2: add reviewed occurrence/order fixtures against unchanged geometry and pixel controls; ownership and escape handling stay Strong. |
| P07 | C3 / R3 | Strong | The complete cycle coordinates mutation, publication, offer acceptance, retirement and fault cleanup | Economy C1/R1: execute fixed differential transcripts and index results; Strong diagnoses mismatches and assesses cleanup. |
| P08 | C3 / R3 | Strong | Owner caches, backing layout and audited resource limits accompany otherwise bounded host wiring | Standard C2/R2: implement schema validation and finite counter wiring against fixed contracts. Economy C1/R1: transcribe reviewed schema fixtures and collect four-route build reports. |
| P09 | C3 / R3 | Strong | Real host replacement and compound capture mutation must preserve application semantics and admission | Standard C2/R2: migrate inventoried presentation call sites after one reviewed pattern and API are fixed; capture ownership and mutation remain Strong. |
| P10 | C3 / R3 | Strong | Applicability of evidence across 180 criteria determines whether integration actually conforms | Economy C1/R1: run named suites and populate raw command/result links. Strong owns criterion dispositions, oracle differences and exception identification. |
| P11 | C3 / R3 | Strong | Complete overlapping storage, stack/IRQ, zero-heap and sustained-workload proof require whole-system reasoning | Economy C1/R1: extract exact artifact/map values and run fixed, authorized measurements. Strong reconciles the ledger and decides what the evidence establishes. |
| P12 | C2 / R3 | Strong | Production cutover removes the fallback and depends on valid adoption dispositions | Economy C1/R1: update links and execute dependency scans from a reviewed cutover list. Strong owns removals, gate assessment and final conformance review. |

P08's Standard slice covers only fixed-contract schema/counter wiring; if the
assignment includes its owner-cache or resource-layout work, route that combined
assignment to Strong. Likewise, a lower-cost slice inherits the core rating
unless its boundary actually excludes the listed critical decisions. A passing
test does not by itself justify downgrading lifetime or resource-proof work.

### Dispatch, escalation and handoff

Before each assignment, record a short entry in the existing package receipt:

```text
Package / slice; governing criterion IDs; dependencies satisfied
Allowed files and output; fixed inputs / pattern / independent expected results
Context: exact contract headings, source symbols, test exemplars and receipt
Settled decisions; remaining implementation choice (or explicitly none)
C / R and reason; tier -> actual model ID / reasoning setting
Required commands and reviewer tier; remaining package repair allowance
Result / evidence links; unresolved issues; handoff or escalation reason
```

Switch models between bounded slices or at a recorded failure handoff, with the
current diff, source revision, uncommitted work, commands/results and remaining
work preserved. Do not restart the package or repeat passed checks solely because
the model changed. These annotations support manual selection or a future
dispatcher; editing this plan does not implement automatic model switching.

Escalate Economy to Standard when work requires behavioral interpretation or a
repair beyond the prescribed pattern. Escalate directly to Strong on unsafe
access, lifetime/identity uncertainty, transaction or failure-order changes,
cross-profile disagreement, unexpected resource growth, oracle changes or
unclear acceptance evidence. Escalate after the first failed repair that produces
no new passing check or narrower cause; preserve the existing two-attempt package
stop rule. Switching models never resets that counter or a closed work budget.

Strong may return a precisely bounded mechanical slice to a cheaper tier once
its inputs, invariants and checks are settled. Keep critical review with Strong;
do not downgrade a task merely because it took longer or used more tokens.
Record actual model usage, repair counts and review rework in the same receipt
when available; do not invent cost estimates or promise savings. Reassess the
tier mapping using that evidence at package checkpoints, without creating a
benchmark project or expanding P01–P12.

## Owner plan and criterion mapping

Every criterion appears once in its owner plan's acceptance matrix. Historical
task references preserve evidence provenance; a new current owner checkpoint
adds fresh migration obligations. Existing checked tasks are not reopened as
unbounded cleanup. The new checkpoints intentionally remain pending until both
their implementation and P10/P11/P12 evidence obligations have dispositions.

| Owner plan / current checkpoint | Implementation packages | Verification and primary new criteria |
| --- | --- | --- |
| [SPEC-001 T13.1](../../implementation-plans/spec-001-implementation-plan.md) | P09 | P10–12; SA-RD-001–004 and 45 baseline criteria. |
| [SPEC-002 T7.1](../../implementation-plans/spec-002-implementation-plan.md) | P01 | P10–12; refresh PF-006/007 and retain all ten Foundation criteria. |
| [SPEC-006 T10.1](../../implementation-plans/spec-006-implementation-plan.md) | P02, P04 | P10–12; DV-RD-001–004 and 17 baseline criteria. |
| [SPEC-007 T9.1](../../implementation-plans/spec-007-implementation-plan.md) | P05 | P10–12; LY-RD-001–002 and nine baseline criteria. |
| [SPEC-010 T10.1](../../implementation-plans/spec-010-implementation-plan.md) | P03 | P10–12; OS-RD-001–004 and 12 baseline criteria. |
| [SPEC-011 T12.1](../../implementation-plans/spec-011-implementation-plan.md) | P05 | P10–12; IN-RD-001–002 and 13 baseline criteria. |
| [SPEC-012 T10.1](../../implementation-plans/spec-012-implementation-plan.md) | P06 | P10–12; DR-RD-001–004 and 13 baseline criteria. |
| [SPEC-013 T11.1](../../implementation-plans/spec-013-implementation-plan.md) | P07 | P10–12; RP-RD-001–004 and 15 baseline criteria. |
| [SPEC-015 T8.1](../../implementation-plans/spec-015-implementation-plan.md) | P08 | P10–12; HC-RD-001–004 and 18 baseline criteria. |

No previous fixture completion proves a new RD criterion. Unchanged requirements
may reuse an oracle or exact unchanged-artifact evidence only with an explicit
applicability argument; changed binaries need fresh relevant measurements. This
preserves every criterion without reimplementing the whole MVP.

## Design notes and evidence protocol

At most three focused notes are planned, inside implementation packages:

1. P02: SPEC-006 finite source lowering and typed failure flow.
2. P03: SPEC-010 owner/pointee lifetime and replacement transaction, including
   Canvas pins, registration retirement and teardown.
3. P04: SPEC-006 record/path/payload representation and bounded reconciliation.

These explain replaceable realizations, not alternative architectures or separate
investigations. No new note is a delivery task merely because another class exists.
Their byte/lifetime claims feed the single P11 ledger rather than another study.

Each package receipt records input/output commits, changed files, exact checks,
compiler/profile/artifact identities, pass/fail counts, criterion links, resource
deltas and remaining blockers. Use existing owner evidence locations and link
receipts from the owner plans/conformance reports; don't duplicate logs. Generated
reports remain under `.build/`; Pi artifacts under `.build/raspberry-pi/`, nRF
under `.build/nrf52840/`, toolchains under `.toolchains/`.

Run `scripts/format-swift.sh` before repository validation. Use the existing owner
`scripts/contracts/run-spec-NNN.sh --profile <profile>` drivers for
`macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, `nrf52840-embedded`; propagate
the approved migration compiler selection without weakening historical checks.
P10's broad gate is `scripts/test.sh all-hardware-free`. Reuse its exact artifacts
for P11 where possible. Any new required focused check must be explicitly
registered with the top-level runner, not silently discovered or skipped.

### Focused testing campaigns — maintainer instruction, 2026-10-15

Eugene requested retaining the existing sequential test infrastructure, excluding
untested two-worker execution, and using shorter focused campaigns when they
provide equivalent validation for the change. This is an execution policy under
the existing iteration scope, not a reduction of acceptance criteria or a reset
of any bounded activity's run/repair allowance.

- Before a campaign, record changed inputs, affected contracts/owners, transitive
  consumers, test families and profiles, plus why omitted checks remain covered.
  Use existing focused selection and verified resume/reuse mechanisms where
  applicable; do not introduce parallel workers or parallel batch delegation.
- Run the smallest complete affected families and prerequisites. Preserve positive
  twins, negative diagnostic classification, required compiler passes and actual
  runtime integration checks. A family selection must not omit another affected
  family merely to shorten a run.
- Reuse earlier results only where their source, dependency, compiler, flag,
  profile and artifact identities remain applicable under the existing verifier
  or an explicitly reviewed applicability qualification. Focused checks plus
  valid retained evidence may cover the same obligations as a full rerun; a
  focused pass alone must never be reported as a complete suite pass.
- If impact or evidence applicability cannot be established, broaden the campaign
  to the relevant subsystem/profile or full suite. Shared ownership, runtime,
  compiler/configuration and storage-layout changes require early affected
  ARMv6/Embedded checks; do not defer target feasibility to final validation.
- After a coherent change batch, run affected subsystem integration checks.
  Preserve full required package/iteration gates at their defined boundaries,
  including P10's broad gate and final source/artifact coverage. Any subsequent
  change invalidates affected evidence and requires the corresponding refresh.
- Each receipt names what ran, what was reused and why, what remains unvalidated,
  and whether the result is focused or complete. No automatic retry, new repair
  allowance, required-check waiver or performance claim follows from this policy.

Pi builds target `armv6-unknown-linux-gnueabihf`; nRF builds target
`nrf52840dk/nrf52840` with `armv7em-none-none-eabi` and verified VFP ABI. Follow the
repository platform skills. No setup installs globally. Deployment/service restart
and flashing require explicit connected-work authorization; Pi must report
`armv6l` before deployment. P11 first prepares the exact artifacts/commands and
bounded measurement cases, then requests only the missing device authorization.

## Known blockers and completion boundary

There is no remaining architecture approval blocker to P01. Complete lowering,
unsafe bridge correctness, prefix/payload capacity and whole-image fit are
implementation obligations, not already proven results. Detect them at P02–04
and P08/09 as well as final P11; stop the affected package if the contract cannot
be met. An internal bounded fix stays in scope; an extra bank, changed identity,
public semantic change or higher approved bound returns for a decision.

The known 4 MHz display lower bound and missing connected measurements remain
explicit. This plan does not authorize solving them by changing clocks, transport
or requirements. P11 may finish an honest evidence/disposition packet while an
acceptance gate remains unmet; that does not pass the gate or make P12 executable.
Do not wait indefinitely, label a hardware-free result full conformance, or launch
another experiment to avoid reporting the remaining decision.

Planning is complete when owner matrices cover all criteria and P01–P12 have
dependencies/footprints/exits. Implementation is complete only when the approved
contract's adoption gates pass (or receive explicit applicable dispositions),
cutover succeeds and all owner reports are ready for human review. Neither plan
completion nor approval marks any Spec implemented or closes the iteration.

## Completion record

P01 implemented in `bb61d4ef`, with the ARMv6 output-root correction in
`b77d85f7`; all four migration Foundation drivers, the
historical macOS control and all 17 compiler controls pass. The
[P01 receipt](../../../Tests/ContractFixtures/SPEC002/Evidence/rfc-014-p01/result.md)
pins source/recipe/route/compiler/artifact identities, deltas and the single
successful CMake repair. SPEC-002 is implementing and its plan active; T7.1
remains open through P10–P12.

P02's direction correction is committed in `117f49cf`; its declaration exit and
focused suite are implemented in `53de09c6`. All four final profile drivers pass
at that commit: both native profiles execute 120 assertions; ARMv6 and Embedded
compile the separate modules and verify target CPU/VFP object attributes. The
[P02 receipt](../../../Tests/ContractFixtures/SPEC006/Evidence/rfc-014-p02/result.md)
preserves exact inputs, commands, diagnostics and artifact identities. SPEC-006
is implementing and its plan active; T10.1 remains open through P04/P10–P12.
Shared inventory routes retain their named ownership, runtime, action, Canvas
and complete-application integration obligations. The whole-tree migration and
resource/connected evidence are not inferred from this declaration exit.

P03 passed its finite package exit at `15b47e2a` after separate Strong review
of the explicitly approved scoped visitor correction and root-entry repair;
P04–P07 subsequently passed as recorded below and in the current checkpoint; P08–P12 remain pending. There is no
remaining P02 exit failure, new package, scope expansion or architecture change.

Planning was prepared without implementation or experiment execution. Optional work remains in the existing deferred track; no new optional
deliverable was added. That historical checkpoint stopped at the requested P06
boundary; the current P07 exit is recorded above and below.

P04's scoped traversal, runtime records, exact paired paths, bounded payloads and
reader-aware profile banks are implemented in `36834e01`, `7e6fdcd6`,
`c75d3105` and `7be2c837`. All four final registered owner routes pass against
clean source `7be2c837`. Separate Strong review at `037607c7` found no blocking
finding and matched 646 evidence hash/size entries. The
[final P04 exit](../../../Tests/ContractFixtures/SPEC006/Evidence/rfc-014-p04/progress.md#final-p04-package-exit--2026-10-11)
records native/cross-build limits, measured component bounds and remaining
integration/resource gates. T10.1 remains open through P10–P12. No contract,
scope or capacity change was needed; consecutive unproductive repairs remain
0 of 2. No P05 work was started.

P05 subsequently implemented borrowed Layout/Render views, complete owned
Interaction keys and checked target dispatch in `a7c9c6b1`, `f86dfbde` and
`fec8a27c`. All eight owner/profile routes pass on clean source `fec8a27c`.
Independent Strong review `42b5f639` found no blockers and verified all receipts
and 500 artifacts. The [final P05 exit](../../../Tests/ContractFixtures/SPEC011/Evidence/rfc-014-p05/progress.md#final-p05-package-exit--2026-10-11)
records native/cross-build scope, physical key/capture costs, the unverified
optional dependency check and later integration/resource gates. T9.1/T12.1
remain open. No contract/scope change or exception was needed; consecutive
unproductive repairs remain 0 of 2. No P06 work was started.

P06 subsequently implemented protocol Canvas, finite witness lowering, scoped
exact-model invocation, bounded staged values and marker-only semantic transfer.
The scoped-source constraint amendment was explicitly approved in `e6f10f67`.
Independent review `72438931` found P06-R1: lazy model binding allowed client
drawing before rejection. Repair `431293f9` prebinds all captured keys; separate
Strong review `59c80b52` passes the finite exit and independently reproduces the
corrected outcome. Four refreshed owner routes pass: each native profile executes
4,042 assertions and 13 negative controls; ARMv6/nRF provide compilation, ABI,
layout and 13 negative controls, without target execution. The
[final P06 exit](../../../Tests/ContractFixtures/SPEC012/Evidence/rfc-014-p06/progress.md#final-p06-package-exit--2026-10-11)
records exact provenance, unchanged geometry/pixel controls, complete reserved
payload growth and remaining integration/resource obligations. SPEC-012 T10.1
stays open through P10–P12. Consecutive unproductive repairs remain 0 of 2;
no P07 work was started.


P07 subsequently passed its finite package exit after the original review found
R1/R2 at `c1500b86`. Repairs `0741894a` and `ad671ea6` correct exact failure
frame/intent and actual idle/deferred opportunity quiescence. Independent Strong
[rereview](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/independent-repair-exit-review.md) at `329570ab`
resolves both findings, rehashes all four fresh routes, and independently executes
both native binaries: 5904 assertions/zero failures, twelve negatives and 26
complete actual-profile pairs each. Cross routes provide selected-module CPU/VFP
and twelve negatives only. Selected audited backing is Static 68,503 / Dynamic
166,240 bytes; whole-image/resource obligations remain later gates. T9.1/T11.1
and P10–P12 remain open; no Spec transition or P08 start is implied. The resumed
guard remains 0/2 and historical 2/2 stop/original FAIL are preserved.

Planning validation: all nine approved Spec statuses and ready plan templates
checked; every one of 180 criteria appears exactly once in its owner matrix;
P01–P12 are the only packages; owner drivers and local links exist. Governance,
authority graph, task-evidence validation and `git diff --check` pass. This checks
planning integrity only; subsequent P01/P02 evidence is recorded above, and
remaining implementation/conformance evidence stays pending.

### P03 historical safety stop — 2026-10-10

Resolved by the explicitly approved scoped visitor amendment recorded below.
The following checkpoint preserves the earlier evidence and authority boundary.

The direct scoped owner/root increments are committed and have selected-component
evidence. A raw-pointer lexical visitor prototype was rejected and removed: the
public generic host witness can copy its visitor into an escaping closure.
[Reproduction and bounded options](../../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/lexical-visitor-blocker.md)
record successful native compilation and the exact compiler/source identities.
Separate Strong review rejects literal two-pass enumeration under OS-010; no
compliant alternative has been demonstrated. Review verification of the bounded
generation-precedence repair precedes the human contract decision. No SPI
amendment, sealed-conformance assumption or capacity change is authorized.
No P03 exit or downstream package start is recorded. Consecutive unproductive
repair count remains 0 of 2; the stop is a safety/authority question.

### P03 scoped ownership exit review — 2026-10-10

The user explicitly approved the precise visitor lifetime correction recorded in
[the approval record](rfc-014-spec-approval.md#scoped-visitor-constraint-amendment--2026-10-10)
and committed as `567b59fb`. The remaining P03 implementation now supplies a
noncopyable/nonescapable actual-root binder, generated nested exact-once traversal,
matching candidate-ticket transfer, checked generation-based profile target access,
and retaining-sink terminal teardown. Copy/escape controls exercise both public
visitor protocols on all four pinned configurations. The [step-9 progress record](../../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/progress.md)
contains final source/compiler/target receipts, actual metadata/ticket/pin layouts,
commands, fault state transitions and explicit limits. Separate Strong review
passed the finite P03 exit after the step-10 repair; no downstream work or
implemented transition is claimed. Consecutive unproductive repair count remains
0 of 2.

The review initially stopped when the Strong agent hit the account usage
limit. Its provisional root-entry-during-frame cleanup finding was subsequently
confirmed by a safe separate-review reproduction and repaired locally in step 10. The [exact resumption point](../../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/progress.md#exit-review-interruption-and-exact-resumption-point)
preserves the historical suspected path and evidence limits. Step 10 adds the
pre-borrow phase guard and all-phase entry/exit regression. Separate bounded
verification at `15b47e2a` reran the original reproduction with zero attachments,
verified final receipt hashes, and found no remaining blocker. The
[final P03 package exit](../../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/progress.md#final-p03-package-exit)
records 645 assertions per native profile, all four compile/negative routes and
the remaining integration/resource evidence boundaries. P03 has passed; owner
T10.1 remains open through P10–P12.

## Deferred and Follow-up Work

[FW-036](../../future-work/fw-036-swift-compiler-upgrade-assessment.md) records the
compiler-upgrade assessment explicitly scheduled for ITERATION-004 I4-05 by
Eugene on 2026-10-11. P07 retains Swift 6.3.2 and all current exit obligations.
