# RFC-014 P07 progress

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
