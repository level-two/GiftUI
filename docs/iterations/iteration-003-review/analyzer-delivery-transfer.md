# Approved analyzer delivery transfer — 2026-11-08

## Subsequent P08 freeze amendment

The [2026-11-08 freeze allocation](p08-freeze-and-certification-transfer.md)
supersedes this record's full-P08 and complete counter-certification prerequisites.
Iteration-3 revision 7 retains shared safety, bounded freeze review and applicable
validation; iteration-4 revision 10 owns composition-specific counter certification
and dependent adoption under I4-AC-013. P08 remains FROZEN / UNMET. The analyzer
transfer and its acceptance obligations remain unchanged. Earlier rows below
preserve the prior approved allocation; use the linked amendment for current entry.


## Approval and scope

Eugene explicitly approved this allocation on 2026-11-08:

> Agreed. Update the governing documents to move analyzer-specific P09–P12 work into iteration 4, keeping P08 and framework/counter validation in iteration 3. Preserve the acceptance obligations and adjust iteration-4 entry gates accordingly.

This approves ITERATION-003 revision 6 and ITERATION-004 revision 9. It changes
scheduling and iteration entry/exit dependencies, not accepted architecture,
Specification criteria, budgets, evidence standards or lifecycle status. Neither
iteration is closed or activated by this amendment. Existing failed checks and
consumed execution allowances remain recorded; no pass or retry is inferred.

## Package ownership and sequence

| Package | ITERATION-003 | ITERATION-004 |
| --- | --- | --- |
| P08 | Complete finite counter and required framework paths, all four routes, safety, lifetime, cold/allocation, ABI and complete resource/fit evidence, with independent exit review | Reuse only applicable evidence; I4-07 still owns its existing residuals |
| P09 | No intermediate analyzer host migration required | Entire analyzer migration joins I4-03 reusable GiftUI-owned host adoption; coordinate I4-07 ownership and I4-10 model authoring through their normal approval gates |
| P10 | Framework/counter functional conformance and required hardware-free gate after P08; all 180 owner criteria receive explicit retained/transferred/unmet dispositions | Analyzer integration, application oracles and final changed-path four-profile conformance after P09 |
| P11 | Complete framework/counter physical storage, stack/IRQ, allocation, ABI and applicable target evidence | Final analyzer resource and connected sustained-workload certification on the reusable-host composition |
| P12 | Framework/counter adoption, safe removal of their obsolete inputs, documentation and handoff after their P10/P11 gates | Analyzer production cutover, generated graph/build-dependency removal, replaced host wiring retirement and final owner conformance after analyzer P10/P11 gates |

Package IDs stay stable. P08 → framework/counter P10 → P11 → P12 is the
iteration-3 sequence; P09 is no longer a prerequisite for that branch.
Iteration 4 performs P09 → analyzer P10 → P11 → P12 together with I4-03/04,
coordinated with I4-07/10. Do not implement and certify a disposable intermediate
SignalAnalyzerTargetHost merely to satisfy the old ordering.

Shared regressions, safety defects and evidence needed by adopted framework or
counter paths remain iteration-3 blockers. Transfer only analyzer-specific work;
do not relabel a shared failure as an analyzer residual. The full hardware-free
command remains required; record analyzer-only failures/unexecuted checks with
exact criterion, cause and destination rather than skipping checks or claiming a
full pass. Required framework/counter checks must pass or have an explicit
applicable maintainer exception. Retain analyzer baseline controls and required
build inputs until its replacement passes adoption gates. No new analyzer
feasibility campaign is required by this transfer; any necessary bounded check
must identify the concrete shared-path risk it resolves.

## Acceptance transfer map

Criterion IDs and original requirements/configurations remain unchanged.
At iteration-3 closure distinguish retained results from **transferred, unmet**
analyzer obligations; transfer is not conformance or a technical exception.

| Original criterion | Iteration-3 retained obligation | Mandatory iteration-4 destination |
| --- | --- | --- |
| IT-AC-004 | Framework/counter semantics, identity, state/actions, pixels, failures and resources; shared regression coverage | Analyzer equivalent coverage under I4-AC-004 / P09–P11 |
| IT-AC-005 | Exact evidence, limits, split dispositions and handoff documentation | Analyzer migration/removal and final evidence under I4-AC-005 / P12 |
| IT-AC-006 | Counter runtime derivation with no generated expanded graph | Analyzer runtime derivation and removal of generated topology/build dependencies under I4-AC-004/005 / P09/P12 |
| IT-AC-007 | Complete framework/counter cost accounting and findings | Analyzer live-memory, copy/stack, traversal and phase measurements under I4-AC-012 / P11 |
| IT-AC-008 | Safe bounded actual framework/counter compositions on all four routes | Analyzer exact-image safety, lifetime, stack/IRQ, heap, RAM/flash and ABI proof under I4-AC-012 / P11 |
| IT-AC-009 | Transfer entire analyzer sustained-workload obligation; retain existing evidence and failures | I4-AC-012 / P11: at least 30 continuous seconds, 80 events/s, four-FPS target cadence, no loss/reordering/duplicates/stale facts/capacity rejection, original latency/coalescing/frame/state requirements |
| IT-AC-010 | ME-09 framework/counter owner/API/budget handoff, exact source/artifacts and explicit analyzer unknowns | Resolve analyzer storage/transfer/performance constraints before final adoption under I4-AC-004/012 |

I3-04/I3-05 and ME-05–09 follow the same application split. All nine owner
plans and conformance reports keep their original criteria; shared criteria may
remain partially satisfied across iterations. No Specification becomes implemented
until its full obligations pass or receive explicit applicable exceptions.

## Iteration-4 entry and adoption gates

1. Accept an explicit human iteration-3 delivery/closure decision covering P08
   and retained framework/counter P10–P12 results, with exact evidence identities,
   budgets, failures, unknowns and this analyzer residual map. P08 PASS alone is
   insufficient. An unmet retained obligation needs a separate applicable exception.
2. Analyzer runtime derivation, final resource/workload certification and graph
   cutover are iteration-4 delivery gates, **not entry prerequisites**. Missing
   transferred analyzer evidence alone does not require an entry exception.
3. Obtain normal RFC/ADR/Specification approvals and ready plans before dependent
   reusable-host, model-authoring or ownership implementation. RFC-013/RFC-016
   drafts remain non-authoritative. This transfer selects no host API.
4. Validate the final supported and recording compositions on all four governed
   configurations. Connected Pi/nRF evidence and authorization requirements,
   independent oracles, zero-heap proof and per-application budgets are unchanged.
   Refresh invalidated evidence; no counter result proves analyzer fit or cadence.
5. Retire analyzer production graph inputs and bespoke wiring only after its
   functional/resource/workload adoption gates pass or have explicit applicable
   dispositions. Final I4 closure accounts for every transferred criterion.

This is committed delivery rescheduling, not optional Future Work. Existing
FW-027/032 and the I4-07 residual allocation retain their links and obligations;
no new speculative work or deferred artifact is introduced.


## Counter-first realization — 2026-11-08

The subsequent maintainer instruction makes P08 implementation and qualified
proof the extraction baseline: [RFC-013 sequence and evidence rules](../../rfcs/rfc-013-external-application-and-backend-integration.md#counter-first-migration-and-p08-reuse--2026-11-08),
[iteration-4 execution and receipt requirements](../iteration-004-backend-and-application-integration.md#counter-first-extraction-and-evidence-handoff).
After this transfer's entry/contract gates, extract the reusable host from the
counter's qualified mechanisms, validate the external counter, then adopt the
same host in Signal Analyzer. Preserve independent oracles; explicitly qualify
reuse and refresh invalidated evidence. No added P08 generalization, assumed
completion, altered acceptance obligation or changed scope revision follows.
