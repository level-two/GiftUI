# Independent P07 exit review — 2026-10-11

**Finite P07 exit: FAIL.** P07-R1 and P07-R2 below are reproduced implementation
defects inside the existing package. They require local repair and refreshed
affected evidence, not a contract amendment, waiver or extra package. P08 must
not start. No Specification or owner task is marked complete by this review.

## Frozen boundary and authority

Reviewed clean implementation/evidence commit:
`c1500b868cfb01dae89f447c5f366925810fe0b0`, including recovery implementation
`af796ed8e3321da9800cfe732c268265adef10ae`. Separate sequential Strong review,
Sol 6.1 High, C3/R3; no implementation edits or additional agents.

Frozen contract SHA-256:

- SPEC-009: `60c9d9d2b5446ff15c12d66827c36eed5fa476fb2ce3bec598c49bc857ece845`.
- SPEC-013: `2f6ddecc67b000ec6da8047be5875e793c5cd00813d30c5c1b444e6168cbde79`.

The approved SPEC-009/013 coordinator amendments, accepted ADR-035/036/037,
[explicit resumption](consuming-owner-resumption.md), and
[bounded P07 plan](../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md#ordered-work-packages)
govern. Both Specifications remain `implementing`; T9.1/T11.1 remain open.
ITERATION-003 I3-04/05 requires runtime derivation and efficiency for the analyzer,
finite counter and four configurations. The closed MVP supplies existing analyzer
behavior and target-stack regression requirements, not amended conformance.

The package-only read-only `RuntimeCompletePipelineOwner.presentationIntentState`
observation is a permitted implementation of SPEC-009's existing prior-intent
outcome table. It adds no authored action, public host, retry-policy or lifecycle
contract. Its addition is not itself a blocker. Correct prior-intent preservation
does not excuse the separate post-publication defect below.

## P07-R1 — incorrect post-publication failure dispositions

**Blocker.** In
[RuntimeCompletePipeline.swift](../../../../../Sources/GiftUIRuntimeCore/RuntimeCompletePipeline.swift),
lines 412–417, `fail` derives both frame and intent state solely from whether a
publication exists. Every post-publication failure becomes `.aborted` /
`.unavailable`, including an ordinary capacity failure before candidate allocation.

[SPEC-009's exhaustive outcome matrix](../../../../../docs/specs/spec-009-execution-cycle-and-frame-handoff.md#state--lifecycle),
lines 1233–1235, requires ordinary post-publication render/offer failure to be
`.aborted` / `.satisfied`, unless residual policy separately marks the facility
unavailable. A failure before candidate allocation requires `.notProduced` /
`.satisfied`. Required-facility loss and nonretryable refusal retain their distinct
unavailable outcomes. No policy/facility loss occurs in the reproduced cases.
This fails the P07 phase/failure/disposition exit, RP-RD-002 and the applicable
RP-004/005/007/009 and EX-001/003/010 duties.

Exact existing reproduction, from the repository root:

```sh
.build/contracts/spec-013-runtime-cycle/tmpt5trq269/macos-static/runtime-cycle
```

The independently executed, hash-verified final binary still prints
`P07 values assertions=3917 failures=0`. Its first actual-profile transcript
contains both of these failures, identically in Static and Dynamic:

| Injected stage / exact failure | Actual frame / intent | Required frame / intent |
| --- | --- | --- |
| `candidateAllocation` / `execution(capacityExhausted)` | `aborted` / `unavailable` | `notProduced` / `satisfied` |
| `offerAndProduction` / `execution(capacityExhausted)` | `aborted` / `unavailable` | `aborted` / `satisfied` |

Both preserve semantic revision 2 with `changed: false`. The candidate-stage
fault occurs before `candidates.reserve()`. Inspect `result failed` entries in
case zero of [final-logical-transcripts.json](final-logical-transcripts.json) to
reproduce without executing the binary. The stage-fault loop in
[CyclePipelineProbe.swift](../../RuntimeDerived/CyclePipelineProbe.swift),
lines 126–138, checks stage/error, finalization and cleanup but omits these exact
frame/intent expectations. Equality consequently accepts the same wrong result
in both profiles.

Smallest repair: compute failure disposition from the actual failure and candidate
allocation state/stage under the unchanged outcome table. Preserve prior intent
before publication, satisfied ordinary failures afterward, and required terminal
unavailable cases. Assert the exact frame/intent fields for the actual-profile
fault rows, including genuine candidate-ID and offer failure paths, and verify
stored recovery intent is cleared consistently. Do not fix the oracle to retain
the present unavailable result.

## P07-R2 — idle concrete quiescence leaves capture and routing alive

**Blocker.** Both concrete `quiesce()` methods delegate only to the binding:

- [DynamicRuntimeExecutionCoordinator.swift](../../../../../Sources/GiftUIRuntimeDynamic/DynamicRuntimeExecutionCoordinator.swift), lines 71–73.
- [StaticRuntimeExecutionCoordinator.swift](../../../../../Sources/GiftUIRuntimeStatic/StaticRuntimeExecutionCoordinator.swift), lines 73–75.

The actual finite
[CycleExecutionBinding.quiesce](../../RuntimeDerived/CycleCoordinatorProbe.swift),
lines 91–96, stops admission, clears its queues and shuts down the root. It does
not cancel `control.runtime.pointer.capture` or release the consumed opportunity's
committed Interaction state. The existing terminal tests instead call the owner's
`terminatePresentation`, which performs broader cleanup before later quiesce calls;
they therefore do not establish idle coordinator quiescence.

[SPEC-013 storage/reset/quiescence](../../../../../docs/specs/spec-013-runtime-profiles.md#storage-ownership-and-borrowing),
lines 797–805, explicitly requires idle quiescence to cancel pointer sources and
release queued and committed routing before returning. This is an existing P07
quiescence/cleanup obligation under RP-RD-002 and RP-004/007/008/009, not P08 host
integration or a complete-image requirement.

Independent actual-owner reproduction is preserved under
`.build/contracts/spec-013-runtime-cycle/independent-exit-review-c1500b86/`:

- `CycleCoordinatorProbe.swift`: temporary review-only fixture,
  SHA-256 `c3d99a733cf0ca7101bf7b4a82e2bf93dd69c53ca7d625538520227fd6ff3176`.
- `compile-command.txt`, `link-command.txt`, `compile.log`, `link.log`,
  `execute.log`: exact commands and results against the verified final modules.
- `idle-quiesce`: SHA-256
  `428a977a57dac1ae27de2c036c3c19780dc42e3a7a11a2fad3a84bb642b677b7`.

Run the saved commands with Python `subprocess.run(shlex.split(command), check=True)`
from the repository root, then execute `idle-quiesce`. Compile, link and final
execution exit zero. The temporary fixture changes only review orchestration:
replace `exerciseConcreteLifecycle` with a healthy opportunity, a real admitted
pointer down at the committed revision (source 0, successor sequence 1, ordinal 0),
another opportunity, and `coordinator.quiesce()`. Observe the actual pointer capture
before/after and `coordinator.opportunity.interaction.committedRecordCount`
immediately afterward, before the caller's existing manual reset. Its entry calls
the existing Static and Dynamic factories with issued owner identities. Production
sources, focused algorithms and earlier lifecycle checks remain unchanged.

```text
P07REVIEW profile static
P07REVIEW before quiesce captured=true
P07REVIEW after quiesce quiescent=true captured=true
P07REVIEW committed records after quiesce=1
P07REVIEW profile dynamic
P07REVIEW before quiesce captured=true
P07REVIEW after quiesce quiescent=true captured=true
P07REVIEW committed records after quiesce=1
```

An initial review-fixture attempt used sequence 10 and correctly failed input
successor admission. Changing only that test sequence to 1 produced the successful
reproduction above; this was not a production repair or guard reset.

Smallest required behavior repair: route idle quiescence through cleanup of the
same actual opportunity-owned Interaction/recovery and shared pointer state,
finish root retirement, and return only after those duties complete. Preserve
consuming ownership and its lifetime dependency; caller reset after ownership
return cannot substitute for quiesce. Add permanent actual-profile controls for
healthy idle quiescence with a live capture/committed route and pending recovery,
idempotence, and rejection of later admission/opportunity. This review does not
choose a new protocol or ownership design; escalate only if implementation cannot
realize the already approved contract locally.

## Verified evidence and finite disposition

Independently rehashed every final receipt input, compiler/core receipt and
retained artifact: Static 165 inputs/143 artifacts; Dynamic 165/143; ARMv6 165/120;
nRF 152/115. All four driver checks report passing and each has twelve intended
compiler negatives. The native binary independently reproduced all 23 complete
Static/Dynamic transcript pairs exactly, including the preserved failure rows.
Native route storage reports also equal each other. These checks establish
freshness and reproducibility; they do not override R1/R2.

| P07 duty | Review disposition |
| --- | --- |
| Actual scoped construction and Model/Schema/action/mutation binding | Supported within the finite composition; real factories, foreign-owner rejection, eight ownership and four mismatch negatives, immutable audit/limits and configured-limit execution inspected. |
| 26 audit fields and retained backing | Supported within the finite composition: measured owners, count/size/stride/alignment partitions, checked sums, exclusive key/metadata/geometry partitions and retained backing after ownership return. Static 68,502 / Dynamic 166,239 bytes. No whole-image, allocator-overhead or stack claim. |
| Actual complete cycles and differential values | Reproduced; actual focused owners and concrete coordinators, not a profile flag on a common mock. Equal values do not establish correct R1 dispositions. |
| Read/registration retirement, bank reuse, accepted routing, no replay | Existing finite controls inspected and reproduced: early frame lease, discarded removal, stale target, model commit/report/dispatch counts, refusal and later rederivation. No additional blocker identified in this bounded review. |
| Latest-only recovery and prior-intent fix | Supported for its explicit finite cases: newer refusal/backpressure counters, superseded events, accepted clearing, wake counts and no replay; prepublication prior states preserved. R1 requires the ordinary failure counterparts. |
| Cleanup and quiescence | Failure acquisition/cleanup and terminal-refusal controls reproduced; ordinary failure disposition fails R1 and healthy idle quiescence fails R2. |
| Four pinned routes | Fresh selected modules/negatives and target CPU/VFP artifact evidence verified. ARMv6/nRF are cross-compilation only. |

Complete application/host migration, broad P10 hardware-free regression, P11
linked Static zero heap/full stack/RAM/flash and matched Dynamic allocation/cost,
loaded acquisition/frame/timing and connected evidence, and P12 cutover/conformance
remain open. Their absence is not an extra P07 blocker. This review performs no
full gate, deployment, restart, flash, lifecycle transition or exception approval.

The resumed consecutive-unproductive-repair count remains **0/2**; review findings
are not repair attempts. Preserve the historical exhausted **2/2** stop. Repair
R1/R2 sequentially within the existing guard, collect fresh affected four-route
evidence, and obtain a separate bounded re-review before a P07 pass. No new
optional discovery was promoted or hidden in deferred work.
