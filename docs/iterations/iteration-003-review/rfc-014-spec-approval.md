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
