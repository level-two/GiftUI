# P08 graph boundary — decision packet and approved Option B disposition

**Current disposition — 2026-10-12:** Eugene selected Option B and approved its
required documents, then explicitly reserved implementation for a separate
activity. See the appended approval disposition below. The original conflict,
Option A recommendation and then-unapproved alternatives are retained as
historical decision reasoning. No source edit or compiler invocation followed
this documentation approval; existing graph conformance is not asserted.


2026-10-12. Current source remains the unvalidated graph checkpoint `cfaa57af`;
last validated source is `48a987cd`, with 1,348,627 assertions and23 controls.
The user approved only the previously proposed dependency trace, replacement of
two projection helpers/call sites, and one native gate attempt. Entry87b6a0bf was
clean. Trace recorded in `fca0a3a9`; sequential independent Strong review found the
current conflict below. No source edit, compiler probe or target build occurred.
New gate allowance **0/1**; the earlier **2/2** stop remains closed and unchanged.

## Exact conflict and authority

SPEC-015 `docs/specs/spec-015-host-configuration.md:791–800` requires exact
compiler-visible direct dependency records and rejects upward dependencies.
Role factAdmission=11 and wakeRequester=16 are fixed at lines520/525. Under the
accepted trace, typed operational dependencies count: useCaseSet10→source8 and
repository9 through `CounterFactUseCases.start`, and normalizedInput15→admission11
through the actual gate submit operation. Restricting the graph to retained
constructor fields would weaken that criterion.

`Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterAdmission.swift:149–156`
has all three actual submit overloads call
`control.pointee.emitCounterWake(.admittedWork, acceptedFact:true)` on `.queued`.
`CounterWakeIntegration.swift:21–40` implements that method by accumulating the
canonical wake and recording the fact/reasons into the scheduler. That is actual
role16 behavior. Therefore the current realization has forbidden11→16. Shared
backing via profile0 does not remove this dependency. The canonical wake behavior
itself passed step7f; that does not validate its graph boundary.

Executor7 is the actual `HostApplicationOpportunityGate`, not its enclosing
aggregate; use-case dependencies8/9 are required. Handler13→actionDomain12 remains
valid: `CounterOwnedModel.Mutation` is shared value vocabulary and the handler
has no root registration, key or target. SPEC-015 line1119 names model, handler
and target separately; actual dispatcher supplies handler and target separately
in `CounterPipelineOwner.swift:305`. These reviewed distinctions do not resolve
admission11→wake16.

## Option A — relocate notification forwarding to host composition (recommended)

Keep the exact direct graph contract. Make finite CounterAdmission perform only
its existing wake-free admission policy, synchronization and return of the exact
ExecutionAdmissionOutcome. The enclosing host composition consumes each result
and emits the existing canonical admittedWork notification **only on queued**,
synchronously before producer delivery returns. No public protocol, approved
algorithm, capacity, compiler flag or unsafe conformance needs to change.

This is source-feasible by inspection because all submit overloads already return
ExecutionAdmissionOutcome, both actual coordinators return it unchanged, and
HostNormalizedInputGate returns `.queued(event)` exactly after successful
admission. This remains uncompiled and unapproved; no feasibility pass is claimed.
It exceeds the currently authorized two-helper replacement scope and needs a
new explicit bounded allowance and independent review of complete caller coverage.

Exact boundary inventory from repository source, not an exhaustive future-client
promise (all files under Tests/ContractFixtures/SPEC015/RuntimeDerived):

| Boundary / file | Existing result and proposed host forwarding point |
| --- | --- |
| CounterHostOwner.swift:188; CounterDynamicHostOwner.swift:139, `state.admit` | Actual coordinator current-value bootstrap returns outcome; after submit borrow ends, inspect queued and emit before returning to activation. Preserve Bool caller result. |
| CounterApplication.swift:89–92, source→repository delivery closure | Actual admission returns outcome; emit once on queued before callback returns. Preserve application callback counters, serialized gate and no retained closure/control adapter. |
| CounterHostCorpus.swift:101,111–112, physical input | Inspect each actual gate disposition immediately after each call; emit once for each queued down/up, including distinct accepted-fact deadline accounting. Rejected malformed/source/stale input emits nothing. Do not postpone down notification until after up. |
| CounterPipelineOwner.swift:225–226, finite injected late completion | Boundary injection is host fixture composition; consume outcome, forward after the short admission call and before returning. Preserve deferred next-seal behavior, no synchronous runtime or application mutation entry. |
| CounterWakeIntegration.swift:119,136,154,168,184, integration producer facts | Each direct accepted submit must explicitly forward at the surrounding fixture producer boundary. Preserve supplied clock, earliest fact deadline, one requester transition and three refusal controls. |
| CounterCoordinatorProbe.swift:45–61, direct coordinator corpus | Each actual successful state/completion submission forwards; refused/invalid/unavailable results do not. This covers all0–9, physical34-slot queue and terminal rejection. |
| CounterHostProbe.swift:65–69; CounterDynamicHostProbe.swift:60–64, stopped producer/input controls | Results are unavailable/source-quiesced; assert no canonical notification or runtime entry. Preserve these negative sites rather than treating them as successful forwarding paths. |

Underlying maintained `StaticRuntimeExecutionCoordinator.swift:41–59` and
`DynamicRuntimeExecutionCoordinator.swift:39–57` simply synchronize and return
admission outcomes; they need no notification API change. The maintained
HostNormalizedInputGate internals also need no change. No forwarding belongs
inside CounterAdmission, CounterQueuedFacts or their wake-free controller.
A small fixture-local outcome inspection may be used only at host composition,
without a new runtime owner or adapter that becomes role11 and recreates11→16.

A newly approved bounded implementation must also correct the graph masks for
useCase10→8|9 and normalized15→11, remove unjustified physical-placement edges,
and replace the two unvalidated whole-coordinator helpers using already approved
controlPointer projection. The exact18-role trace and all operational paths need
review after relocation; the current table is not accepted just because masks
validate. Preserve root/model initializer association, cache lifetime, actual
application/endpoint checks, physical storage and all existing negative controls.

Required validation in that future bounded slice: every queued fact separately
recordsAcceptedFact at the supplied clock even behind an existing nonfact wake;
canonical three-reason coalescing emits one requester transition; callback during
cycle survives to the next paced opportunity; refused/invalid/stopped producers
emit none; real dirty/backpressure/refusal recovery retains exact no-replay and
three-refusal terminal policy. No extra accumulator, retained requester, polling,
synchronous runtime entry or public contract change. Existing native gate may
exercise these after scope approval; no new run is authorized by this packet.

## Option B — amend graph semantics after contract review

Propose a precise SPEC-015 amendment defining records as factory/construction-only
dependencies, with operational notification edges validated separately. This
requires Specification review and explicit human approval before normative edits
or dependent implementation. It affects the treatment of useCase.start and
normalizedInput.submit too; retaining their operational edges while selectively
omitting admission notification would be inconsistent. It is broader than local
fixture relocation and would need an updated exact graph test/acceptance trace.
No such amendment is drafted or approved here.

## Decision and stop boundary

Recommend **A** if the maintainer authorizes the enumerated host-boundary relocation
and one reviewed native gate attempt. It preserves the existing direct graph
contract and uses already returned finite outcomes; it introduces no new public
requirement. B is available if the maintainer wants different normative graph
semantics. Neither option is implied by prior approval of only projection helpers.

Affected implementation is stopped for the user decision. No compiler allowance
has been spent; old guard2/2 is not reset. Four registered routes, early linked
ARMv6/nRF image resource/ABI evidence and P08 exit remain open. SPEC-015 stays
implementing, plan active, T8.1 incomplete. No graph/P08 pass or target claim.


## Approved Option B disposition — 2026-10-12

The [exact maintainer instructions](../../../../../../../docs/iterations/iteration-003-review/rfc-014-spec-approval.md#option-b-construction-graph-amendment--2026-10-12)
approve Option B's documents while explicitly prohibiting implementation during
this activity. [ADR-038](../../../../../../../docs/adrs/adr-038-construction-graph-and-operational-contracts.md)
is accepted; the coordinated RFC-014 and SPEC-015 amendments and reciprocal
SPEC-009 clarification are approved. Authority commit `61f968b1` passed
repository governance and diff checks. This is not compiler or conformance proof.

The fixed eighteen-role graph now describes exact direct factory/construction
dependencies. Mandatory borrowed/retained inputs, backing, required construction
callbacks and derived configuration origins remain fully traced; actual required
construction edges cannot be omitted through pointer, callback or shared backing
indirection. Ordering/cycle/lower-edge constraints remain. Any actual upward
construction dependency still stops for upstream resolution.

Constructor inputs, activation wiring and runtime operation arguments are
classified separately and consistently. Use-case start/source/repository and
normalized submit/admission arguments are not automatically construction edges.
The finite counter's executor is its actual serialization gate, not its enclosing aggregate;
Mutation vocabulary does not establish a live root target owner. Backing-origin
and lifetime evidence is still required for all these distinctions. Existing
counter masks are not approved merely because this new contract was approved.

Runtime admission may retain automatic canonical notification through the typed
consumer-owned wake contract; the host binds it to platform scheduling once.
Option A per-producer forwarding is not selected. Separate validation must prove
binding/runtime identity, one canonical reason set/outstanding bit, every queued
fact's clock/deadline, canonical coalescing, cycle-time notification, no reentry,
refusal/backpressure/no replay, quiescence and backing-last teardown. Graph shape
is not a substitute for any of that evidence. Module imports remain unchanged
under ADR-007/008; no public protocol, service framework, frontend/IR, unsafe
conformance, allocator, capacity, compiler or hardware change is selected.
FW-035/FW-009 remain captured and do not enlarge current scope.

The [separate implementation sequence](../../../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md#option-b-resumption-sequence--separate-activity)
is B01 actual construction/operation/lifetime inventory and review → B02 only the
two failed helper shapes/direct activation sites with audited construction masks
and corresponding controls → B03 exactly one predeclared native invocation, no
automatic repair/rerun, then freeze and independent review. Only a reviewed pass
leads to the remaining registered four routes, early linked images and independent
P08 exit; P09–P12 follow their existing gates. Nothing runs in this activity.

Historical 2/2 remains closed. Latest 0/1 remains unconsumed, not reset. Last
validated source remains `48a987cd`; `cfaa57af` remains unvalidated graph WIP.
SPEC-015 implementing / plan active / T8.1 and P08 open; no graph or P08 pass.
