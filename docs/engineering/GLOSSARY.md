# Engineering Governance Glossary

**Accepted**
: Human-authorized status for a Proposal or ADR. An accepted Proposal permits
  design exploration; an accepted ADR is authoritative architecture.

**ADR (Architecture Decision Record)**
: A concise record of one architecturally significant decision, its rationale,
  consequences, and rejected alternatives.

**Approval gate**
: A lifecycle boundary that requires explicit human authorization unless that
  authority has been explicitly delegated.

**Approved**
: Human-authorized status for an RFC or Specification. An approved RFC can
  produce ADRs; an approved Specification authorizes major implementation.

**Architecture documentation**
: A current explanation derived from accepted ADRs. It explains architecture
  but does not create decisions.

**Artifact**
: A Proposal, RFC, ADR, Specification, architecture document, roadmap entry,
  implementation plan, or conformance record stored in the repository.

**Authoritative**
: Normative for downstream work. Project vision/principles, established
  product scope, accepted ADRs, and approved Specifications are authoritative
  at their respective levels.

**Capability**
: An explicit representation of behavior or resources available from a
  runtime profile, platform, backend, or device. Capabilities must not be
  inferred from unrelated implementation details.

**Conformance review**
: Evidence-based comparison of implementation behavior with an approved
  Specification's acceptance criteria.

**Decision**
: An architectural choice made authoritative by an accepted ADR. Candidate
  designs and implemented accidents are not decisions in this lifecycle.

**Deprecated**
: ADR status indicating that use is discouraged while history and any
  remaining applicability are preserved.

**Dynamic profile**
: A GiftUI execution profile that can use facilities such as heap allocation,
  dynamically sized collections, runtime type information, or escaping
  closures.

**Exploration**
: A non-authoritative investigation of uncertain questions, hypotheses, or
  candidate directions. It produces findings and a disposition but need not
  reach or authorize a decision.

**Feature**
: A stable, manifest-keyed engineering concern that can be tracked through one
  or more lifecycle branches.

**Feature manifest**
: `docs/features.yaml`, the machine-readable navigation index for feature
  state, artifacts, dependencies, and milestones. It is not a design contract.

**Future Work**
: A cheap, durable capture of one idea, opportunity, unanswered question, or
  intentionally postponed decision, including provenance and a concrete
  revisit trigger. It is not a roadmap commitment.

**Implementation contract**
: An approved Specification defining what implementation and tests must
  satisfy.

**Implemented**
: Specification status granted after conformance review and explicit human
  authorization. It is stronger than “code exists.”

**Legacy source**
: A pre-governance or mixed document retained as provenance. Its content is
  not assigned a modern approval state by inference.

**Lifecycle stage**
: The current gated position of a feature or branch: Proposal, RFC, ADR,
  Specification, implementation, or conformance/completion.

**Major feature work**
: Work that creates durable public, cross-module, ownership, capability,
  backend, runtime-profile, performance, resource, or compatibility choices.

**MVP scope**
: The established product boundary in `docs/MVP_SCOPE.md`. It governs what is
  necessary for the MVP and how MVP completion is judged, but does not select
  architecture or replace lifecycle approvals.

**Normative**
: Contractual language defining required behavior, normally expressed with
  `MUST`, `MUST NOT`, `SHOULD`, or `MAY`.

**Proposal**
: The “why” artifact: problem, users, value, goals, constraints, scope, and
  success criteria without detailed architecture.

**Promotion**
: A traceability action by which another artifact takes ownership of deferred
  work. Promotion does not itself approve a Proposal or RFC, accept an ADR,
  authorize implementation, or reuse the deferred artifact's ID.

**Revisit trigger**
: A concrete event, dependency, measurement threshold, milestone need, or new
  evidence that causes deferred work to be re-evaluated. “Later” is not a
  revisit trigger.

**RFC (Request for Comments)**
: The “how” artifact: collaborative architectural design, alternatives,
  trade-offs, costs, and unresolved questions for an accepted Proposal.

**Specification**
: The “what” artifact: precise, testable behavior and interfaces derived from
  accepted architectural decisions.

**Static profile**
: A GiftUI execution profile designed for bounded or forbidden allocation and
  constrained runtime features, including Embedded Swift targets.

**Spike**
: A bounded, disposable implementation, prototype, benchmark, or experiment
  used to answer named questions and produce reproducible evidence. Its code
  and conclusions are non-authoritative.

**Superseded**
: Status indicating that a newer artifact replaces current authority. Both
  predecessor and successor remain linked and historical content remains.

**Traceability**
: Explicit, navigable relationships among feature entries, lifecycle
  artifacts, legacy sources, implementation, tests, and conformance evidence.
