# P08 activation-time containing-owner stop — 2026-10-11

**Stopped at 2/2 consecutive unproductive repairs. P08 is incomplete.**
Last validated maintained implementation: `c39733de`; approved lifetime authority:
`4dbdc2e0`. Strong Sol6.1 High, sequential, no delegation. No maintained runtime or
host source changed for this failed join. No further compiler runs or alternative
factoring occurred after guard exhaustion. P07 history is unchanged.

[Independent read-only stop review and finite next authorization option](independent-stop-review.md)
confirm the stop without new compiler runs or production changes.

## Required behavior and attempted implementation

The approved SPEC-015 correction permits a scoped host, but preserves pure
validation and valid-only exposure. The actual coordinator and endpoint must
first be constructed in the first `activate()` step; supplied backing must stay
alive through teardown. A compile-only host accepting a preexisting coordinator
is not production-pattern authority. No new host abstraction, unsafe escape,
compiler change or altered activation ordering is approved.

The attempted local containing owner holds supplied real P07 model/root/semantic/
Canvas scopes and owned geometry/interaction workspaces. Its optional actual
`StaticRuntimeExecutionCoordinator<CycleExecutionBinding,CycleAdmission,
CyclePipelineOwner<...>>` starts empty. `activate()` constructs the actual focused
pipeline (including its endpoint), binding, admission and concrete coordinator.
This is an evidence-only storage-join control; it is not the counter, a validated
host, endpoint/service integration or complete lifecycle implementation.

## Exact bounded controls and results

[Observed source/command/diagnostic record](observed-controls.json) preserves
compiler identity, source hashes, original commands and observed results. The
commands inherit the pinned Swift6.3.2 configuration and actual modules from
`.build/contracts/p08-scoped-host-ie3r3cmc/result.json`. Both approved lifetime
features remain unchanged; no additional compiler controls were introduced.

| Control | Source | Observed disposition |
| --- | --- | --- |
| Initial attempt | [Property-default nil](initial-property-default.swift) | exit1; initial control, not a repair |
| Repair1 | [Explicit initializer nil](repair-1-explicit-nil.swift) | same diagnostic; unproductive1/2 |
| Diagnostic reduction | [No activate method](diagnostic-inert-only.swift) | same diagnostic; narrows failure to inert initialization, no guard reset |
| Repair2 | [Consuming scope transfer](repair-2-consuming-scopes.swift) | same diagnostic; unproductive2/2, stop |

Each reports `lifetime-dependent variable 'self' escapes its scope` at the
containing owner's initializer, with compiler-generated init and self-lifetime
notes. Repair1 changes only where the optional coordinator receives nil. The
reduction removes the whole activation method, demonstrating that its assignment
is not required for this rejection. Repair2 uses the existing consuming-scope
initialization pattern for all four scoped fields; it still rejects.

Sources and diagnostic excerpts are preserved from observed tool output. These
are not newly rerun logs. An earlier missing-import correction preceded the
initial lifetime control and is ordinary fixture setup, not a lifetime repair.
The evidence proves rejection of these exact sources. It does **not** establish
root cause, a compiler bug, impossibility of the approved host contract, or the
failure of every possible lawful internal construction.

A [frozen reproduction script](reproduce.py) is provided for separately authorized
confirmation. It verifies supplied schema-module input/artifact/compiler hashes
and reruns these four unchanged controls, with no repairs. It was **not run**
after guard exhaustion. Under separate confirmation authorization, its command is:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-join-stop/reproduce.py --schema-build .build/contracts/p08-scoped-host-ie3r3cmc
```

## Reviewable next decision

The smallest supported next choice is explicit authorization for a **new bounded
investigation**, after independent read-only confirmation of this packet, to
identify a lawful initialization pattern on the same pinned compiler while
preserving activation-time construction and all existing contract duties. It
must state its finite controls/repair budget and stop conditions before work.
No feasibility promise accompanies that request. Alternatively, leave P08
stopped with its validated commits intact.

No architecture or contract alternative is substantiated by these controls, so no
contract diff or preapproval is proposed. A compiler selection change, new host
abstraction, unsafe lifetime escape or preactivation coordinator construction
would cross current authority and requires its own concrete reviewed decision;
this stop record does not authorize any of them. This is a current correctness
blocker, not deferred optional work.

## Completed and remaining package work

Completed: approved exact lifetime correction; scoped host/controller propagation
with187 lifecycle assertions and ownership negatives; complete schema4 host-module
compilation on both native routes,320 assertions each, six missing-field compiler
controls, fail-closed scalar generator controls and no hierarchy-shape input.
[Execution receipt](../progress.md) links immutable evidence and exact commands.

Remaining P08: lawful activation-time coordinator/endpoint storage join; finite
UInt8 0–9 Increment/Reset/disabled/optional-stroke counter using its own immutable
limits, pools and audited ledger; all nine existing validation stages, exact graph/
report/endpoint audits and valid-only concrete construction; actual cache tickets,
replacement reservations/callback rejection, frozen frame reads, partial activation,
backing-last teardown and stale action/key controls; four registered build routes;
early linked Pi/nRF images with gross RAM/stack/allocator/ABI checks; final source
hash reconciliation and independent Strong exit review. Full analyzer adoption is
P09. No hardware operation, target execution, physical timing, full-image resource
fit or P08 acceptance is claimed. SPEC-015 remains `implementing`, plan `active`,
T8.1/HC-RD-001–004 and P09–P12 open.
