# RFC-014 Specification approval — 2026-10-10

Eugene instructed: “Please, thread specs as approved, and derive the implementation
plan. But please make sure that this plan and its work will be precisely scoped.
I mean that we do not get into the same trap as we did before with infinitely
growing scope, and commit everything.”

In the context of the immediately preceding presentation of commit `9b2ff666`,
this explicitly approves the coordinated amendments to SPEC-001, SPEC-002,
SPEC-006, SPEC-007, SPEC-010, SPEC-011, SPEC-012, SPEC-013 and SPEC-015. Their
[review and exact amendment map](rfc-014-spec-amendment-review.md) identifies the
contract sections, precedence over baseline realization, 28 new RD criteria and
refreshed Foundation measurements. All nine statuses are now `approved`.

Accepted ADR-035/036/037 govern; ADR-037 supersedes ADR-028. The prior implemented
baseline at `53740a73` and its evidence remain historical. This approval does not
mark the changed contracts implemented, satisfy missing measurements, waive
performance requirements or close ITERATION-003.

The instruction requires a bounded plan: finite deliverables, declared exclusions,
dependencies, objective stop conditions and explicit handling of discoveries.
No new investigation, platform, application, transport redesign, external package
delivery, remote deployment or board flashing is authorized by this planning
request. Required implementation/conformance work must remain visible rather than
being deferred merely to obtain a completion label.

## Scoped visitor constraint amendment — 2026-10-10

After the P03 safety review recorded in `3e82e2a9`, Eugene replied
“Makes sense. Please proceed” to the precise proposal below. This explicitly
approves this narrow coordinated SPEC-006/SPEC-010 contract delta and continued
P03 implementation. It does not mark either Specification implemented.

- SPEC-010's declaration visitor protocol supports `~Copyable, ~Escapable`;
  the host witness accepts `Visitor: _GiftUIObservableStateDeclarationVisitor &
  ~Copyable & ~Escapable` by inout.
- SPEC-006's semantic visitor protocol supports `~Copyable, ~Escapable`;
  `View._giftUITraverse` accepts `Visitor: _GiftUISemanticTraversalVisitor &
  ~Copyable & ~Escapable`, retaining `Visitor.Domain == Domain`.
- Generated witnesses, fixed containers, modifiers and forwarding preserve these
  constraints. Generic suppressions permit scoped conformers; they do not require
  every concrete visitor to be noncopyable or nonescapable. Ordinary View values
  and authored syntax remain unchanged.
- The backing-dependent binder is concretely noncopyable and nonescapable, with
  its lifetime tied to actual borrowed root/model storage. It must not rely on a
  convention that public witnesses are generated or synchronous.
- All four pinned configurations require copy/escape rejection controls and
  positive generated/nested exact-once, bind-before-body and failure-suppression
  evidence. Existing capacities, identity, replacement and publication semantics
  remain fixed.

This makes ADR-036's scoped access enforceable at both public generic forwarding
boundaries without introducing another runtime, alternate traversal or a new RFC.
The [historical blocker](../../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/lexical-visitor-blocker.md)
is preserved as evidence and resolved by this approved amendment; implementation
and package-exit evidence are still required.

## Scoped Canvas source constraint amendment — 2026-10-11

Eugene replied “Approved. Please proceed” to the concrete P06 proposal committed
as `67331c11`. This explicitly approves the narrow SPEC-012 amendment described
in the [constraint packet](../../../Tests/ContractFixtures/SPEC012/Evidence/rfc-014-p06/scoped-source-constraint.md)
and continued P06 implementation:

- `CanvasInvocationSource` permits `~Copyable, ~Escapable` conformers.
- `CanvasPlanProducer.derive` permits `Source: CanvasInvocationSource &
  ~Copyable & ~Escapable`; private validation/failure helpers and directly
  necessary adapters forward those suppressions.
- The lifetime-bearing adapter is noncopyable/nonescapable and tied to actual
  borrowed P03 owner and staged-value storage. Existing owned conformers remain
  permitted; the suppressions do not require all sources to borrow.
- All lookup/invoke/release method signatures, associated types, bounds,
  failure ordering and early-rejection caller cleanup duties remain unchanged.
- P06 must still prove positive and noncopy/escape controls, exact-selected-model
  reads, normal/throwing/early cleanup, witness coverage and order across the four
  pinned configurations. Geometry/pixel controls and resource accounting remain.

This realizes accepted ADR-036/037; no architecture change, relaxed acceptance
criterion, capacity increase, package expansion or implemented transition is
approved. The original compiler proof remains historical evidence. SPEC-012
stays implementing and P06 remains open until its implementation and review pass.

## Scoped coordinator constraint amendment — 2026-10-11

After the [P07 independent Strong blocker review](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/independent-blocker-review.md)
and the concrete explanation of the three protocol suppressions, Eugene replied:
“Got it. Please proceed then.” This explicitly approves and reapproves the narrow
SPEC-009/SPEC-013 correction and resumes the existing P07 package:

- `ExecutionAdmissionSink: ~Copyable, ~Escapable`.
- `ExecutionOpportunityRunner: ~Copyable, ~Escapable`.
- `GiftUIRuntimeProfileCoordinator: ~Copyable, ~Escapable,
  ExecutionAdmissionSink, ExecutionOpportunityRunner`.
- Directly necessary generic callers/forwarding preserve these permissions.
  Existing copyable/escapable conformers remain permitted. Associated types,
  method signatures, bounded failures, stage order, admission, publication,
  accepted-offer commit, cleanup, quiescence and all limits remain unchanged.
- The concrete scoped coordinator must remain tied to actual borrowed owner
  storage; copying an unmanaged descriptor is not an alternative lifetime proof.
  Positive and copy/escape negative checks apply on the four pinned routes,
  followed by actual profile cycle/fault/cleanup evidence and separate review.

This realizes accepted ADR-036. The [historical decision packet](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/scoped-coordinator-constraint.md)
and its compiler evidence remain unchanged. SPEC-009's previously implemented
baseline is preserved at `0ff7756a`; it does not prove amended conformance.
SPEC-009 returns to approved for this correction; SPEC-013 remains implementing.
The narrow SPEC-009 owner checkpoint belongs inside P07, not a new package.
SPEC-015's containing host construction/activation lifetime is a separately
reviewed boundary and receives no blanket approval here. P08 is not started,
and no implemented transition, waived criterion or enlarged scope is approved.


## Concrete coordinator binding amendment — 2026-10-11

After the [independent associated-type review](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/independent-associated-type-review.md)
and the proposed relocation with mandatory construction proofs were explained,
Eugene replied: “Nice, please proceed either way proposed solution.” This approves
and reapproves the exact SPEC-013 correction: remove only Storage, Handler and
TargetAccess and their Model equality from GiftUIRuntimeProfileCoordinator;
retain Endpoint/Sink and every operational/inherited requirement.

Concrete construction MUST bind actual storage and validated audit, common
Model/Schema and one immutable finite action domain with a statically known
handler mapping to that Model.Mutation. Mismatch compiler negatives and runtime
provenance/lifecycle evidence are mandatory. This relocates guarantees; it does
not drop them. The previous associated-types-unchanged restriction is superseded
only for these removals. Existing RFC-014 precedence already resolves checked
writes versus baseline raw callbacks; no separate SPEC-011 approval gate or new
action API is introduced. SPEC-015, P08, compiler upgrades and owner/module
moves are outside this decision. SPEC-013 remains implementing, its plan active,
report collecting, T11.1 open through P10–P12. P07 requires separate Strong exit
review. Historical blocker evidence stays intact.


## Scoped host lifetime amendment — 2026-10-11

After the [independent Strong review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/independent-blocker-review.md)
of packet `2579e980` and its exact [proposed diff](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/proposed-spec-015.diff),
Eugene replied: “Approved, please proceed”. This explicitly approves that precise
SPEC-015 correction and resumes the existing P08 package:

- `MVPHostInstance: ~Copyable, ~Escapable`, with every associated type, lifecycle
  method, argument/result and failure unchanged. Existing escapable conformers
  remain permitted.
- A returned scope-bearing host retains compiler-checked dependence on supplied
  backing or consumed scoped coordinator, remains inside every backing activation,
  and cannot escape an activation callback or survive backing release.
- Pure ordered validation still precedes live-owner construction and instance
  exposure. Runtime coordinator and endpoint construction remain the first
  `activate()` step; the compile-only preexisting-coordinator proof is not
  production-pattern authority. Exact graph/report/endpoint audits, first-error
  handling, partial construction, lifecycle and backing-last teardown remain.
- Internal finite concrete construction/return constraints may be propagated to
  realize that approved boundary. The source-only associated factory is not fixed
  by a spelling edit; pinned Swift 6.3.2, no associated-type feature upgrade, no
  unchecked escape and no new host abstraction remain requirements.
- P08 must provide actual four-route host ownership/copy/escape/consume/closed-
  backing negatives, activation/teardown and counter/schema/resource evidence,
  then separate Strong exit review. T8.1 and later P10–P12 duties remain open.

This is consistent with accepted ADR-036 and changes no architecture, capacity,
pacing, role graph, policy, hardware authorization or package scope. The original
blocker packet, probes and review are preserved as historical decision evidence.
SPEC-015 remains approved until implementation begins; P08 guard remains **0/2**.
No P08 acceptance, implemented transition or P09 authorization is implied.

## Swift 6.4 compiler-baseline correction — 2026-10-12

Eugene selected “Approve the correction and continue (recommended)” in response
to the explicit request to replace Swift 6.3.2 with Swift 6.4 (the official 6.4.0
package and matching ARMv6 SDK), apply the reviewed correction, and finish P08
host integration and regression checks. This approves the exact
[compiler-baseline correction](rfc-014-compiler-baseline-correction.md) at
`593175c3`, supported by independent minimal review `80161faa` and fresh actual
activation feasibility review `156f3fb4`.

The new migration baseline supersedes only the earlier version-specific 6.3.2
restriction, including that restriction in the scoped-host amendment above.
Apply the coordinated compiler/SDK pins, Specification applicability notes and
drivers, then perform fresh validation and maintained P08 integration. All
public semantics, ownership and callback containment, target triples, ABI,
resource ceilings, existing feature flags and hardware authorization remain
unchanged. No new associated-type feature dependency is approved.

This is an approved configuration correction under the existing architecture,
not a declaration of conformance. Historical 6.3.2 receipts remain historical;
they cannot establish fresh 6.4 binary or resource results. Every earlier closed
investigation ledger remains closed. The resumed implementation uses bounded
assignments, the existing repair guard and independent review. No P08 exit,
implemented transition or hardware action is approved by this correction.
