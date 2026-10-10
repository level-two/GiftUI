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
