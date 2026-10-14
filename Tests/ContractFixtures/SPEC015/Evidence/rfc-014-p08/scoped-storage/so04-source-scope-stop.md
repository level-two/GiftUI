# SO-04 source inspection checkpoint — conformance scope finding, 2026-10-14

**FROZEN FOR INDEPENDENT SOURCE REVIEW.** Input is clean
`a8471eb3846c5a262951c20fdfb449a1f4659398`, which records Eugene's
“Please go ahead” authorization for the exact
[SO-04→06 source packet](so04-source-execution-proposal.md). This checkpoint
contains documentation and read-only source inspection only. No initial source
realization, corrective pass, compiler/build/test executable/debugger/IR/image,
formatter, target or hardware invocation occurred. It is not a compiler failure
receipt, SO-04 completion, coherent source freeze, buildability claim or fit claim.

The [independent Strong review](so04-source-scope-review.md) at `97f1fe3b`
confirms this source inference and the minimum known clause-only scope addition;
maintainer scope authorization remains pending. No compiler failure was demonstrated.

## Exact source-backed finding

The selected pipeline must accept scoped geometry and all five Interaction
banks under [SPEC-015 S15.1](../../../../../../docs/specs/spec-015-host-configuration.md#s151-construction-transfers-and-retirement).
The approved base constraint set suppresses both implicit ownership requirements
on each G/C/R/H parameter. The current
[CounterPipelineOwner declaration](../../../RuntimeDerived/CounterPipelineOwner.swift)
at lines 115–116 is in the approved SO-05 edit boundary; its four parameters are
currently owned and must receive that complete set.

However, the only conformance supplying the coordinator opportunity witnesses
is [CounterAdmission.swift](../../../RuntimeDerived/CounterAdmission.swift),
line 13:

```swift
extension CounterPipelineOwner: ExecutionOpportunityRunner, RuntimeOpportunityQuiescence {
```

This generic extension does not explicitly suppress `Copyable` or `Escapable`
on `Geometry`, `Candidate`, `Committed` and `Hits`. The source-level inference
is that its default owned generic requirements do not make those conformances
available for the proposed scoped instantiation. Base suppression alone does
not express the complete suppressed generic extension boundary. Independent
review must confirm this inference; the pinned compiler has not been invoked.

Both actual selected routes need these exact witnesses:

| Route | Actual source use | Coordinator requirement |
| --- | --- | --- |
| Static | `CounterHostOwner.swift`: pipeline construction line 164; coordinator construction line 166; aliases lines 32–37 | `StaticRuntimeExecutionCoordinator.swift` line 20 requires `Opportunity: ExecutionOpportunityRunner & RuntimeOpportunityQuiescence & ~Copyable & ~Escapable` |
| Dynamic | `CounterDynamicHostOwner.swift`: pipeline construction line 105; coordinator construction line 107; aliases lines 14–19 | `DynamicRuntimeExecutionCoordinator.swift` line 18 requires the same complete Opportunity constraints |

[Static coordinator source](../../../../../../Sources/GiftUIRuntimeStatic/StaticRuntimeExecutionCoordinator.swift)
and [Dynamic coordinator source](../../../../../../Sources/GiftUIRuntimeDynamic/DynamicRuntimeExecutionCoordinator.swift)
already contain the required suppressions and the consuming lifetime-dependent
Optional extraction. They are read-only and no change to them is proposed.
Their profile conformance extensions also explicitly retain suppressed generic
requirements, at Static lines 93–98 and Dynamic lines 91–96.

`CounterAdmission.swift` is absent from the packet's bounded source list.
The packet explicitly says: “if another path is necessary, stop with its exact
reason.” Editing that extension, moving/deleting its conformance or adding a
different opportunity wrapper would exceed or circumvent the approved boundary.
None was attempted. SO-04 cannot progress to the coherent SO-05/06 migration
under an unresolved necessary SO-05 scope prerequisite.

## Same-boundary inventory and smallest proposed decision

Read-only `rg` inventory over the maintained RuntimeDerived directory found
exactly two `extension CounterPipelineOwner` declarations:

| Site | Disposition |
| --- | --- |
| `CounterAdmission.swift`:13 | The sole `ExecutionOpportunityRunner`/`RuntimeOpportunityQuiescence` conformance; outside the approved list; minimum known added-file requirement. |
| `CounterHostOwner.swift`:91 | Scoped-control pipeline initializer extension; already inside SO-05's file boundary. Its generic suppressions, lifetime union and private-field initialization must be realized there or in the already authorized pipeline file. |

No other `CounterPipelineOwner` conformance/extension was found in that directory.
`CounterWakeIntegration.swift`:79 extends the nongeneric `CounterHostControl`;
it is not the same suppressed-G/C/R/H boundary and requires no change for this
specific finding. Owned coordinator callers and measurement aliases occur in
already listed `CounterCoordinatorProbe.swift`/`CounterProfileStorage.swift`.
This inventory establishes the known boundary, not acceptance of unimplemented
access bodies, carrier rewrites, cleanup, source generators or compiler syntax.

If independent review confirms the inference, the smallest proposed scope
amendment is to add only
`Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterAdmission.swift`, restricted
to the conformance extension's generic constraint clause:

```swift
extension CounterPipelineOwner: ExecutionOpportunityRunner, RuntimeOpportunityQuiescence
where Geometry: ~Copyable & ~Escapable,
      Candidate: ~Copyable & ~Escapable,
      Committed: ~Copyable & ~Escapable,
      Hits: ~Copyable & ~Escapable {
```

This is an unapplied reviewable proposal, not source authority or validated
syntax. Existing base protocol/equality requirements remain inherited; existing
witness method bodies, admission/control/wake logic and workload remain exact.
No witness-method edit is presently identified as necessary. Their usability
with the eventual scoped realization remains a later source/compiler obligation;
any newly identified body defect must receive its own exact stop disposition.

## Checkpoint disposition and preserved limits

SO-04/05/06 remain incomplete; neither new Swift file exists, and all original
binding/init/access/audit/destructor sites remain unchanged. No driver/generator
registration or planned positive/negative label was realized or claimed. The
next handoff is independent Strong **source finding review**, rather than the
coherent migrated-source acceptance review described in the packet.

The source package is stopped under its explicit scope rule, with zero automatic
repairs. This checkpoint grants no fresh attempt or validation allowance. All
historical counters and the two-consecutive-unproductive guard remain intact;
independent review must classify the stop without resetting them. SPEC-011/013/015
remain implementing, plans active; all nine SO criteria, HC-RD-003/P08/R07/T8.1,
the 58,648-vs-27,648 failure, I4-07/P09–P12 and timing/hardware obligations stay
open. No contract, architecture, capacity, workload, C reservation or limit changes.

Documentation checks are recorded in the P08 receipt after this checkpoint.
