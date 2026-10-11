# RFC-014 P07 progress

## Current stop — associated requirements, 2026-10-11

The prior approved correction is implemented. A newly confirmed exact
Storage/Handler/TargetAccess boundary stops affected integration. Read the
[decision packet](associated-type-constraint.md) and its four compile-only proofs.
It proposes removing exactly three associated requirements from the common
operational protocol, with explicit lost static checks and required concrete
construction proofs. No proposal is applied or approved. Separate Strong review
and human decision remain. Commits: `498720fc`, `2fe8a86e`, `db78cf9c`, and partial
WIP `027bdc11`. P07 incomplete; T9.1/T11.1 open; repair counter **0/2**.

The [independent Strong associated-type review](independent-associated-type-review.md)
confirms the compiler blocker and recommends one explicit SPEC-013 amendment
that relocates the removed generic checks into mandatory concrete construction
proofs. It confirms RFC-014 checked-write precedence over legacy dispatch
realization without waiving finite typed handler semantics. Independent replay
passed all four cases with compiler/input/module-artifact identity checks.
P07 acceptance, full integration and SPEC-015's host boundary remain open.


## Approved resumption assignment — 2026-10-11

After the concrete explanation of the three protocol suppressions and the
separate SPEC-015 boundary, Eugene replied: “Got it. Please proceed then.”
This approves the reviewed narrow SPEC-009/013 correction and resumes P07.
Record the exact amendment and approval in the Specifications and approval
ledger before implementation. The earlier blocker records remain historical.

Sequential Strong assignment: `gpt-6-astra` / `medium`, C3/R3, same P07
footprint and RP-RD-001–004/current owner criteria. Extend the footprint only
to the approved SPEC-009 declaration correction and directly necessary generic
forwarding, with owner-plan/conformance traceability. No new package is added.
All other contract signatures, behavior and limits remain fixed. SPEC-015's
containing host construction/activation is not approved by this correction.

Resume from `dfe15494` and committed slices `2935fb73`/`bbc753e5`, using the
existing exact commands and evidence. Update pinned inputs when source changes
require it; never weaken hash validation. Implement actual Dynamic/Static
coordinators and the finite phase/fault/retirement/offer/retry cleanup exit,
then hand off to a separate Strong exit review. No P08 work. Commit each
coherent step. Remaining implementation choices are internal realization
within the approved contracts; new contract/scope questions return to Eugene.
Consecutive unproductive repair count remains **0/2**, not reset by resumption.

## Step 4 — record approved coordinator correction

The exact SPEC-009/SPEC-013 protocol suppressions are recorded with the human
approval ledger before code changes. SPEC-009 is approved/plan ready with a
narrow T9.1 checkpoint inside P07; both affected reports are collecting and
preserve historical passes without claiming amended conformance. Shared
sequence/context and manifest are reconciled. SPEC-015 is unchanged.
Validation: `scripts/validate-governance.rb`, `git diff --check`.
Repair count remains **0/2**.

## Step 5 — implement the approved scoped forwarding correction

The exact three protocol suppressions are implemented. SPEC-009 is implementing
and its existing owner plan active. Both existing profile execution coordinator
types now retain consuming, lifetime-dependent concrete binding/admission/runner
values with `~Copyable & ~Escapable` generic forwarding. The real model-scope
fixture constructs those actual wrappers and calls submit/run/quiesce. This is
a declaration/forwarding proof, not evidence of a complete production cycle.

The old Static pointer binding adapter was extracted unchanged to its own file;
Dynamic's former pointer binding is represented by a compatibility adapter and
initializer. These retained pre-cutover adapters are not selected by current
scope proofs and are not alternate coordinators or completion evidence. The
current concrete coordinator types are migrated in place. Full old Canvas-backed
binding source is still pending migration; no full-module pass is claimed.

Validation was sequential after `scripts/format-swift.sh`, using the four exact
Step 2 invocations with the same pinned core receipts. `step-5-*.json` records
commands, source hashes, compiler, logs and outputs. Both macOS routes pass 159
value assertions; all four compile actual scoped forwarding and reject copying
or escaping the scoped owner and admission/opportunity conformer. ARMv6/nRF
are cross-compilation plus exact architecture/VFP checks only, not execution.
`RuntimeProfileStorage.swift` had to join the selected core source set after the
new coordinator contract import exposed its required associated type. A scoped
fixture extension required explicit `where Model: ~Copyable`; each diagnostic
narrowed the cause and the next check passed. Unproductive repair count: **0/2**.

Remaining: actual production owner/cycle integration, fault/cleanup differential,
physical audit and quiescence evidence, then separate Strong review. T9.1 and
T11.1 remain open. No SPEC-015 host lifetime change or P08 work was made.

## Step 6 — frame acquisition cleanup and scoped record forwarding

Successful freeze now records resetAttemptStorage before expansion can fail.
The model scope exposes existing checked begin/end-frame operations for staged
runtime ownership; withFrame uses the same operations. SemanticRecordStore lends
a borrowedStore with lifetime dependence on the actual activation. No backing
ownership changes. The existing unit cleanup oracle now includes the acquired
frame lease on expansion failure; historical test receipts are preserved.

After formatting, the Step 2 macOS Static command passes **179 assertions**,
including actual Dynamic and Static model stores: pin a model, release its last
ticket under discovery authority, fail expansion, destroy exactly once, retain
first failure/dirty disposition, finalize once, then repeat on the same backing.
This is an explicitly focused regression; later pipeline stages are unreachable.
The nRF Step 2 command cross-compiles the same corpus and passes ARM/VFP checks.
Both routes reject semantic borrowed-owner copy/escape in addition to prior
negatives. Receipts: `step-6-macos-static.json`, `step-6-nrf52840-embedded.json`.
No full repository or complete-profile-cycle pass is inferred.

Fixture repairs: normalized Int/UInt32 assertion count; LLDB localized an initial
native trap to ticket release in reading phase, corrected to the existing checked
discovery route; Embedded required an explicit GiftUISemanticCore import for the
semantic error enum. Each narrowed the cause or passed a new check. One native
intermediate run overlapped a driver edit and is excluded from committed evidence;
the final two receipts were collected from stable inputs. Repair count **0/2**.

## Step 7 — partial record-workspace integration, stopped at protocol boundary

WIP preservation only; not a complete or behaviorally accepted cycle slice.
The existing Dynamic Layout/Drawing/Render workspace types now use qualified
SemanticRecordReference values. Dynamic Layout's transient dictionary key includes
all owner/bank/revision/ordinal fields. Static Drawing has a thin qualifier adapter
around its existing UInt16 workspace; it rejects mismatched bank qualifications.
The tiny P07 fault presentation includes generated State, text, one Button, one
Canvas and conditional removal. It does not add P08 host/schema/preset work.

After formatting, the macOS Static Step 2 invocation selected/compiled these
current workspaces and generated presentation; existing 179 assertions and six
lifetime negatives passed. Receipt: `step-7-partial-macos-static.json`. These
assertions do NOT exercise the new workspace adapter or the presentation. Their
behavioral integration, audit and cross-target proof remain unvalidated. The
honest WIP commit preserves this work without claiming package completion.

Integration stopped on a newly confirmed exact associated-type boundary in
GiftUIRuntimeProfileCoordinator. The approved three protocol suppressions did
not change its associated requirements. Storage still requires Copyable; the
pinned compiler rejects suppressing Copyable on an associated type. The same
bounded protocol's Handler/TargetAccess requirements still select the legacy
raw-model callback interfaces rather than the approved scoped checked-operation
join. A separate decision/review packet records the minimal compiler evidence,
exact proposed correction and lost static checks. No such amendment is applied.
Repair counter remains **0/2**; T9.1/T11.1 and P07 exit remain open.

## Parent checkpoint — contract escalation, 2026-10-11

P07 is **incomplete and blocked on the scoped coordinator contract decision**.
The parent accepts the bounded independent review at `d7d6cdd1` as confirmation
of the blocker, not as package acceptance. Validated implementation steps are
`2935fb73` and `bbc753e5`; the decision packet is committed at `7bb8dfb2`.
Execution and review used sequential Strong `gpt-6-astra` / `medium` assignments.
No Standard or Economy assignment was needed. Each step is committed.

The user must decide whether to approve the packet's narrow SPEC-009/013
constraint correction before affected integration resumes. SPEC-015's containing
host lifetime remains a separately reviewed boundary. Actual profile cycle/fault
evidence and final Strong package review remain pending; T11.1 remains open.
P01–P06 passed, P08–P12 have not started. Repair counter: **0/2**.

## Launch and Strong implementation assignment — 2026-10-11

P07 is authorized by the user's request to execute it sequentially and commit
each step. Starting revision: `57720ddf`; working tree was clean. P05 and P06
passed their separate Strong reviews; P06's final receipt is
`Tests/ContractFixtures/SPEC012/Evidence/rfc-014-p06/progress.md`.

- Package: P07 complete runtime cycle; owner SPEC-013 T11.1. Governing criteria:
  RP-RD-001–004 and applicable RP-001–015 regression obligations. P07 provides
  the finite integration exit; full resource/application dispositions remain
  P08–P12 and T11.1 remains open.
- Authority/context: SPEC-013 **RFC-014 runtime amendment**, **Shared pipeline
  failure and mutation seam**, **Run-cycle coordination**, and accepted
  ADR-035/036/037; current owner checkpoint and acceptance matrix in
  `docs/implementation-plans/spec-013-implementation-plan.md`; shared sequence
  and task context guide under `docs/iterations/iteration-003-review/`.
- Allowed output: RuntimeCore limits/audit/pipeline/cleanup, concrete Dynamic
  and Static coordinators, their directly corresponding fixtures/tests/driver
  registration and narrowly necessary build wiring; current owner records and
  focused design notes. No P08 or successor implementation.
- Entry symbols: `RuntimeCompletePipeline`, `RuntimeCoordinatorCleanup`,
  `DynamicRuntimeExecutionCoordinator`, `StaticRuntimeExecutionCoordinator`;
  exemplar `Tests/GiftUIRuntimeCoreTests/RuntimeCompletePipelineTests.swift`.
- Independent expected behavior: actual profile owners produce equal logical
  transcripts; preserve first failure and admitted mutation without replay;
  semantic publication survives refusal, Interaction commits only on accepted
  offer; reads end at last use independently of registrations; every acquired
  resource releases once on early exits and quiescent teardown.
- Settled: P03 ownership, P04 record banks, P05 owned action keys and P06 protocol
  Canvas are approved and passed component dependencies, not proof of P07.
  Remaining implementation choices: inspect existing joins and choose internal
  coordination within those contracts; do not invent a contract or scope change.
- Rating C3/R3: cross-owner lifetime, mutation/publication and cleanup invariants.
  Strong implementation: `gpt-6-astra` / `medium`. Separate Strong exit review
  follows implementation. Standard mapping is `gpt-6-sol` / `medium`; Economy
  mapping is `gpt-6-luna` / `medium`, only for a separately fixed bounded packet.
- Validation: run `scripts/format-swift.sh` before focused validation; establish
  exact SPEC-013 migration driver invocations using pinned P01/P02 build receipts,
  preserving the historical gate. Record concrete commands/artifacts here before
  cheaper collection. Run `scripts/validate-governance.rb` and `git diff --check`
  for record changes. P10 retains the full hardware-free integration gate.
- Execution is sequential. Commit each coherent step with evidence/disposition.
  Consecutive unproductive repair count: **0 of 2**. Stop after two attempts on
  one blocker without a new passing check or narrowed cause. Model changes do
  not reset this allowance. Contract/scope decisions return to the user.

Result: implementation pending. Package exit review pending.

## Step 1 — begin authorized implementation

SPEC-013 is now implementing and its owner plan active. T11.1 remains open.
The current need is ITERATION-003 I3-04 / IT-AC-006 actual runtime derivation
across four configurations, retaining ITERATION-001 analyzer/stack semantics.
The accepted ADR-035/036/037 and approved runtime amendment provide authority.
Existing profile bindings still reference the former Canvas surface; historical
gates remain unchanged while the explicit migration route will select the
current owners. No complete-module or resource pass is inferred from P03–P06.

Validation: `scripts/validate-governance.rb`; `git diff --check`.
Repair count: 0 of 2.

## Step 2 — required limits and disjoint audit values

Added mandatory RuntimeRecordLimits and RuntimeModelLimits to the runtime input,
validated limit and capacity surfaces. There are no fallback defaults for omitted
fields. Candidate and published record capacities validate independently; model
slots/tickets/pins and capture entitlement validate before activation. Added all
ten RFC-014 byte fields to the checked 26-field sum, without reclassifying old
host estimates as actual allocations. Physical count/stride/alignment and
complete owner integration remain open.

The explicit registered migration route is now:
`run-spec-013.sh --profile <profile> --compiler-baseline rfc-014 --giftui-build <core>`;
its default historical route is unchanged. Formatting preceded validation.
Both native profiles pass **159 assertions** for invalid, absent, below/equal/
above capacity and every audit field's contribution/overflow; ARMv6 and nRF
compile the same oracle and pass exact architecture/VFP object checks. Cross
compilation is not execution. Both platform doctors passed without target access.
The four `step-2-*.json` receipts contain exact commands, pinned compiler,
core receipt, source hashes and artifacts. Exact invocations:

```sh
scripts/contracts/run-spec-013.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/dd5d4849463055f2-hwlll28l/macos-static
scripts/contracts/run-spec-013.sh --profile macos-dynamic --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/189dda86d331e15d-wpk82ft7/macos-dynamic
scripts/contracts/run-spec-013.sh --profile raspberry-pi-armv6 --compiler-baseline rfc-014 --giftui-build .build/raspberry-pi/contracts/spec-006-rfc-014/189dda86d331e15d-w03qxe3s/raspberry-pi-armv6
scripts/contracts/run-spec-013.sh --profile nrf52840-embedded --compiler-baseline rfc-014 --giftui-build .build/nrf52840/contracts/spec-006-rfc-014/189dda86d331e15d-xnmh_sbd/nrf52840-embedded
```

The first native invocation rejected obsolete core `f28bb03491f0640c-ot0b940_`
on a changed FiniteSourceLowering hash. Selecting the final P06 receipt above
resolved this input mismatch without changing validation. No failed compile or
behavior repair occurred. Consecutive unproductive repair count remains **0/2**.

This slice does not migrate legacy profile bindings or P08/P09 host/application
initializers. Required new arguments intentionally have no schema-3 defaults;
the migration driver currently proves the values/audit slice only. Full P07
cycle, focused review and T11.1 remain open.

## Step 3 — lexical complete-pipeline owner

The internal RuntimeCompletePipelineOwner now permits nonescapable concrete
owners; its runner/helpers and both existing profile forwarding constraints
propagate that permission. The actual P03 ObservableModelScope-backed compile
probe now conforms, while owner copy and escape negatives reject. The runner
order, failure carriers, publication/disposition values and cleanup table are
unchanged. SPEC-013's Shared pipeline failure and mutation seam prescribes
the associated failure/result shapes, not an Escapable owner inheritance
clause. This internal correction realizes ADR-036's approved scoped ownership
and does not amend the contract.

After `scripts/format-swift.sh`, the same registered macOS Static and nRF
commands from step 2 pass: native 159 assertions plus two expected compiler
negatives; nRF compiles the concrete scoped owner and both negatives and
verifies Cortex-M4F/VFP ABI. Exact receipts are `step-3-macos-static.json` and
`step-3-nrf52840-embedded.json`. These are scoped forwarding evidence, not
actual complete coordinator execution; old profile bindings remain unmigrated.
Governance and whitespace checks pass. Repair count: **0/2**.

A different constraint issue exists on the explicitly specified Execution
protocols inherited by concrete coordinators. That issue is tracked separately;
this internal repair does not authorize changing those contracts.

## Concrete coordinator contract boundary — 2026-10-11

The [exact constraint report](scoped-coordinator-constraint.md) demonstrates
that the real model-scope-backed coordinator cannot conform to SPEC-009's
explicit Copyable/Escapable admission/opportunity protocols. Evidence-only
shadows isolate both constraints and the narrowly proposed suppressions compile.
SPEC-009, SPEC-015 and the concrete coordinator interfaces are unchanged.
The internal runner repair is committed separately at `bbc753e5`; it supplies
no approval for the explicit contract correction.

Affected P07 integration is stopped for the parent/maintainer decision, with
all diffs, commands, source/artifact identities and limits preserved. No new
ownership workaround, further package or P08 work is authorized by this finding.
P07 and T11.1 remain open; separate Strong review has not run.
Consecutive unproductive repair count: **0 of 2**.

## Independent Strong blocker review — 2026-10-11

The [bounded independent review](independent-blocker-review.md) confirms the
exact contract blocker at `7bb8dfb2`. Independent replay verified the pinned
compiler, source and artifact hashes and reproduced current/CopyableOnly
rejections plus proposed-shadow success. It recommends the narrow SPEC-009/013
constraint correction for explicit human approval, preserving the SPEC-015
construction/activation decision boundary before P08 relies on a scoped host.
This is not the completed-package exit review: P07 remains incomplete, T11.1
open, P08 unstarted and the unproductive repair count **0/2**. No production or
normative contract change was made. Governance and whitespace checks pass.
