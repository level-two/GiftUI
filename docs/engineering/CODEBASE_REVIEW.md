# Codebase Review Process

This process supports bounded cleanup reviews, including
[ITERATION-002](../iterations/iteration-002-cleanup.md). Review records are
derived evidence and recommendations, not architecture, contract amendments,
or implementation authorization. Follow the
[Feature Lifecycle](FEATURE_LIFECYCLE.md),
[Numbered Iteration Scopes](ITERATION_SCOPES.md), and
[AI Agent Rules](AI_AGENT_RULES.md).

## Purpose and baseline

Answer two distinct questions: does implementation satisfy the authoritative
contracts, and are existing design choices still justified by application and
target constraints? Report contract divergence separately from a recommendation
to reconsider accepted architecture. Do not rewrite requirements to match code.

Before reviewing, record the repository revision, relevant working-tree changes,
review boundaries, governing artifacts, supported configurations, existing
evidence, approved exceptions, and known failures or evidence gaps. Preserve
historical results with their original scope. A build, host fixture, or iteration
closure does not establish connected-hardware conformance.

## Review coverage and passes

Inventory maintained framework/application modules, target hosts, build/source
selection, generators, tests, and operational scripts. Record exclusions with
reasons. Use a coverage matrix with area, governing contracts, applicable
configuration, review perspective, reviewed revision, evidence link, and status
(`not reviewed`, `reviewed`, or `blocked` with a reason). A reviewed area may
still have findings or unproved runtime behavior.

| Perspective | Checks |
| --- | --- |
| Dependencies and ownership | Compare actual imports and both SwiftPM and firmware source composition with approved ownership. Check cycles, misplaced responsibilities, portable/platform coupling, fixture dependencies in production, and composition logic in lower layers. |
| Types, abstractions, and mappings | Identify forwarding-only wrappers, duplicated representations/state, repeated conversions, speculative extension mechanisms, and excess intermediate storage. Identify the invariant, ownership, unit, lifetime, or profile constraint each separation protects before proposing removal. |
| Interfaces and encapsulation | Inspect producer and consumer code together. Check unnecessary exposure and coupling to another owner's storage, raw identifiers, lifecycle, state machine, or platform representation. Distinguish public distribution API from compiler-visible integration contracts. |
| Requirements and behavior | Map applicable acceptance criteria to implementation and evidence. Inspect normal and boundary behavior, ordering, limits, errors, and recovery. Distinguish defects, conflicting authority, approved exceptions, and missing evidence. Link criteria rather than redefining them. |
| End-to-end flows | Trace acquisition → model mutation → observation → semantic derivation → layout → drawing/rendering → frame handoff → display; input → action dispatch → mutation; and failure → containment/recovery/cleanup. Check ownership and state transitions across seams. |
| Profiles and resources | Compare equivalent Static/Dynamic behavior and target realizations. Inspect heap allocation, bounded storage, copying, repeated traversal, stack/RAM/flash, overflow/truncation, generation, and compile-time exclusions. Measure costs where necessary rather than inferring them from source size. |
| Tests, tooling, and documentation | Check production-path coverage, stale fixtures/scripts/source lists, reproducible generation, obsolete workarounds, test expectations derived through the same mechanism under test, and evidence freshness. Preserve deliberate dependency/ABI/resource/negative-compilation guards. |

Review module responsibilities locally, with their immediate producers and
consumers, then examine flows across modules. Generic repeated sweeps are not a
substitute for coverage of these different perspectives.

Include lifetime and failure checks: stale identities/registrations/callbacks,
borrowed data escaping its lifetime, partial failure, cancellation/refusal,
capacity exhaustion, duplicate sources of truth, and release of owned resources.
Check generated representations against portable declarations and production
joins against fixture-only substitutes.

## Findings register

Assign stable local finding IDs and record:

- Category, affected modules, exact code locations, and reviewed revision.
- Governing requirement/invariant, or the rationale being questioned.
- Observed behavior or complexity, concrete consequence, supporting evidence,
  counterevidence, confidence, and unresolved questions.
- Smallest plausible correction, expected benefit, risks, affected profiles,
  lifecycle route, and validation needed.
- Priority, disposition, responsible owner/task where selected, and links to
  verification or deferred records.

Classify findings as confirmed defects/contract divergence, supported
simplification opportunities, architectural concerns, investigation hypotheses,
or preferences without demonstrated benefit. Missing evidence is not by itself
proof of a defect. Treat conflicting authoritative documents as an explicit
blocker for the affected choice, not an invitation to choose authority silently.

For suspected excess types or mappings, ask what protection the separation
provides, what becomes simpler after removal, and what would be lost. Counts of
types, modules, adapters, lines, or conditionals identify hotspots; they are not
standalone success criteria. A proposed simplification needs a concrete benefit
and preservation evidence for relevant contracts and resources.

## Reconciliation and selection

Merge duplicate findings and group symptoms by root cause. Check whether the
issue was already fixed, deliberately constrained, or covered by a recorded
exception. Prioritize correctness and ownership problems, then supported
contract-preserving simplifications; separate upstream decisions and uncertain
opportunities. A severe finding outside a cleanup commitment still needs visible
triage, not silent inclusion or deferral of a current blocker.

Record a disposition for each finding: selected, needs investigation/upstream
decision, deferred, rejected with evidence, or duplicate with a canonical link.
Before scope approval, selected work needs bounded outcomes, affected profiles,
validation requirements, and lifecycle routing. Resolve uncertainty that
invalidates a promised replacement, or select an investigation whose output is
evidence and a recommendation. Agree resource/cost thresholds before evaluating
feasibility. Do not assume that investigation must recommend removal.

Local maintenance can follow the lightweight path. Public/cross-module contract,
ownership, dependency-boundary, profile, backend-coupling, and material resource
changes follow the lifecycle. Use feature triage for routing, lifecycle review
for authority/traceability, conformance review for acceptance-criterion evidence,
and RFC/Spec review for proposed changes. Valuable unselected work uses the
deferred-work-curator skill with provenance, reciprocal links, and concrete
revisit triggers; a register entry alone is not durable deferred capture.

## Agent review task

Use bounded tasks with a named area and perspective. For example:

> Review [area] for [perspective] against [accepted ADRs and approved
> Specifications]. Inspect producers, consumers, and production build paths.
> Do not edit implementation. Report evidence-backed findings with exact
> locations, consequences, counterevidence, the smallest plausible correction,
> lifecycle routing, and validation needs. Record coverage and unresolved
> questions. Separate preferences from demonstrated problems.

Reconcile reports before selecting work. Use a fresh review of selected changes
to check the original findings and regressions. Additional passes should have a
new perspective, changed code, or an unresolved question to investigate.

## Remediation, verification, and completion

Implement selected work only after its required gates. Keep each change focused
on one finding or coherent root cause; separate mechanical and semantic edits.
Use focused checks during development, format maintained Swift before repository
gates, and run appropriate profile gates at integration milestones. The existing
`scripts/test.sh all-hardware-free` gate covers hardware-free profiles; connected
validation remains separate and requires its normal authorization. Add tests
when they demonstrate meaningful behavior or prevent a specific regression,
rather than merely mirroring private structure.

Record before/after constrained-resource costs where affected. Link verification
to findings and governing conformance evidence. Existing exceptions retain their
scope; new failures require explicit dispositions rather than reuse of an old
exception by assumption.

The audit is complete when planned coverage is reviewed or explicitly blocked,
findings are reconciled, and coverage/evidence gaps and dispositions are visible.
Cleanup completion additionally requires verification of selected outcomes and
appropriate exception/deferred records under the iteration closure rules.
Repeated passes ceasing to find suggestions are not a completion criterion.
