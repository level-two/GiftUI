# SO-03 first-trap independent Strong review — 2026-10-14

**PASS diagnostic scope/identities; local Canvas fixture defect proven by source.
SO-03 runtime remains BLOCKED; the exact observed failed condition is unproved.**
Reviewed clean `51b93bcb`, sequential task `p08_so03_trap_review`, inherited
configuration, no subagents. [Dispatch](../../../../progress.md#so-03-first-trap-independent-strong-review-dispatch--2026-10-14)
preceded source/evidence inspection. This review ran no debugger (including
nonlaunch commands), compiler/build/test/probe/executable, retry or source/driver
edit. Only review/evidence/navigation documentation changes follow.

## Authority and necessity

Accepted [ADR-039](../../../../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md),
approved [SPEC-011 S11.1–4](../../../../../../../../../docs/specs/spec-011-interaction.md#s111-scoped-storage-and-state-declarations),
[SPEC-013 S13.1](../../../../../../../../../docs/specs/spec-013-runtime-profiles.md#s131-physical-owner-session-and-coordinator-contract)
and [SPEC-015 S15](../../../../../../../../../docs/specs/spec-015-host-configuration.md#s151-construction-transfers-and-retirement)
remain governing; all three Specifications are implementing, plans active.
ITERATION-003 I3-04/I3-05 requires runtime-derived finite-counter/four-stack
validation, preserving closed ITERATION-001 analyzer controls. Full RFC-015
analyzer integration/owned returns remain mandatory ITERATION-004 I4-07 with
the separate P09 handoff. The design note and execution plans are derived,
not authority for a changed contract or another attempt.

## Evidence verification and inference limits

[Read-only verification](independent-review-verification.json) independently
matches 122 source-freeze inputs, 128 driver inputs, 24 unaffected pins,
130 artifact hashes/sizes and 84 historical files. Compiler/macro/core/reused
artifacts and debugger/xcrun file hashes match. Frozen source remains `ef46dd4b`;
the 2,215,848-byte executable retains SHA-256
`58eaf79ee44ae030de2c51ddfb1c23650337da05dc70f9a930f34b7b0aca8a48`.
All 43 native planned/attempted argv agree in order. The 42 compiler/oracle
passes remain valid for those inputs: 30 zero exits and 12 intended negatives,
including 27 focused cells and link. Sole native execute remains -5, empty
output, no completion count; this diagnostic does not change those results.

The [saved diagnostic](result.md), process receipt and 10,293-byte raw stdout
(stderr empty) agree on the exact reviewed argv, one `process launch`, PID 75302,
six backtrace frames, first-stop PC `0x100084810`, sixteen requested instructions
and one kill/status 9. The cancelled worker request has no execution result or
session ID; the parent's recorded absence of the wrapper's prelaunch marker
supports zero launches for that request. That earlier directory observation is
provenance, not independently reconstructable from today's populated directory.
Parent debugger exit 0 records completed diagnostic commands, not inferior success.
No continue/restart/fallback is present. Diagnostic allowance is 1/1 consumed.

PC/image mapping identifies the specialization of `so03RecordOperations` for
the actual SO03Session C/R/H types. It excludes the initializer-only exchange
traps as the symbol at this stop. Main places prior Interaction/root calls before
this family, but no independent count/transcript was printed. Optimized/inlined
code and the forward window do not establish every preceding assertion's success,
the exact source branch reaching `brk`, or which earlier host operation completed.
The adjacent `__stack_chk_fail` call did not execute in the retained window and
does not establish a stack-canary failure. No compiler/runtime/contract defect
can be selected from this PC alone.

## Source-proven Canvas construction defect

The Canvas half of [InteractionProbe.swift](../../../../../../../../../Tests/ContractFixtures/SPEC011/RuntimeDerived/InteractionProbe.swift:306)
constructs a fresh `Backing<CanvasSemanticPayload<UInt8>>`, begins a candidate,
enters root → declarationRole(1) → declarationRole(2), then calls `bank.store`
at line 314. No helper or loop operation appends a semantic record on this path.

[SemanticRecordBankMetadata](../../../../../../../../../Sources/GiftUISemanticCore/SemanticRuntimeRecords.swift:150)
starts with records=0; beginCandidate clears it and marks expanding.
[enter](../../../../../../../../../Sources/GiftUISemanticCore/SemanticRuntimeRecords.swift:207)
adds only path entries and inherits nearestRecord, initially `.max`; it never
increments records. The separate `appendRecord` operation at line 265 creates
the record and updates nearestRecord/count. Therefore all three paths here
retain nearestRecord `.max` and records remains zero.
[store](../../../../../../../../../Sources/GiftUISemanticCore/SemanticRuntimeRecords.swift:295)
requires nearestRecord < records and the record's path to equal activePath.
That guard must fail with `.invalidIdentity`; fixture line 315 throws it and
the outer catch at line 350 traps, **if this Canvas path is reached**. This
is a proven fixture construction defect independently of PC-to-line mapping.
The ordinary `emit` helper already calls appendRecord for declaration roles;
it is used by the earlier host checks, not by this Canvas construction.

The source proof narrows the diagnosis productively beyond a symbol-only stop.
It does not prove that this was the first observed trap, that hostChecks passed,
or that repairing it will yield runtime success. There is no demonstrated need
to weaken ownership, assertions, limits or the accepted contract.

## Smallest proposed correction and stopped boundary

**Proposed only, NOT AUTHORIZED:** change only
`Tests/ContractFixtures/SPEC011/RuntimeDerived/InteractionProbe.swift`, inserting
this checked operation immediately after the three-component enter loop (current
line 312), before `empty` and `bank.store`:

```swift
if let error = bank.appendRecord(limits: store.limits) { throw error }
```

At that point activePath is declarationRole(2). One record is created at ordinal
0, matching the unchanged `view.reference(at: 0)!` at line 333. Do not append at
both declaration roles: that would require changing the reference and enlarging
this fix. Preserve paths, payload/action, seven checks, all preconditions, existing
host/root/semantic/transaction assertions and every ScopedStorageProbe control.
No production, driver, lifetime annotation or common-session change is proposed.

This **expands beyond correction-2's ScopedStorageProbe-only source allowance**.
It needs new explicit maintainer authority for this exact fixture change and,
if validation is approved, one fresh immutable native driver invocation using
the same pinned recipe/flags/core and unchanged 43-command/27-focused-cell plan,
zero automatic follow-up repairs, then a separate independent Strong review.
Freeze source/plan/identities before the run; stop on the first unexpected result
with raw evidence and no fallback. No further debugger launch is proposed or
needed to justify this local correction. This is a proposal, not an allowance.

Original/correction-1/correction-2 native allowances each remain 1/1 consumed,
0 remaining; fixture corrections 2, automatic repairs 0. Productive correction-2
(29 new compiler passes) and this productive diagnostic narrowing do not reset
any helper/B03/GOT/image/backing/phase/IR/SPIKE-075 budget or establish two
consecutive unproductive repairs. A read-only diagnostic review is not another
source correction. No automatic repair or new run follows from this finding.

All nine SO criteria, physical fit, 58,648 versus 27,648 stack failure,
HC-RD-003/P08/R07/T8.1 and mandatory I4-07/P09–P12 duties remain open;
SO-04–09 remain unapproved. The defect is a required current-path blocker,
not deferred work; no new Future Work/Exploration/Spike, manifest/status or
contract change is needed. Documentation checks and the separate review commit
are recorded in the shared receipt. Stop for parent/maintainer disposition.
