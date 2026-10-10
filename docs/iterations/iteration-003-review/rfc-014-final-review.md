# RFC-014 final architecture and lifecycle review

**2026-10-10 — review closed; RFC-014 approved under the maintainer's conditional
finalization instruction.** No unresolved architectural decision or RFC-blocking finding
remains after the corrections below. This is an author review using the
RFC-reviewer and lifecycle-reviewer checklists, not an independent review or
production conformance report.

Parent: [RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md).
Review baseline: `e2839fb3`. Evidence: terminal
[SPIKE-074](../../spikes/spike-074-final-access-ownership.md) / `41e43c0f`.
No new experiment, compiler trial, production implementation or hardware action
is part of this review.

## Authorization and scope

Eugene instructed:

> Let's then review RFC and finalize it, if there are no gaps or issues. If you find some, please fix them, as long as no decision should be made explicitly, and then close.

This is conditional authorization to finish and close RFC-014 after review and
non-decision corrections, not blanket approval to choose a different design.
It is not inferred from earlier “proceed” messages or passing experiments.
The review must stop for a new architectural/product choice; none was necessary.
The explicit three-bank selection and the previously selected typed access /
protocol Canvas / runtime-record direction remain intact.

The [documentation approval rule](../../engineering/DOCUMENTATION_RULES.md#approval-authority)
permits explicit human delegation. Apply the instruction only to this RFC's
finalization. It does not accept downstream ADRs, approve changed Specs, begin
production migration, close ITERATION-003 or certify implementation feasibility.
RFCs have no `closed` status: successful closure of this review is recorded as
`approved`, with this provenance, after the final checks.

## Findings and corrections

| ID / severity | Finding at the review baseline | Correction / disposition |
| --- | --- | --- |
| FR-1 / blocker, fixed | Current design text still prescribed copy-freeze, four/five banks and historical source alternatives despite later precedence banners. | Rewrote RFC-014 as one selected design. Prior text remains in Git at `e2839fb3`; earlier source/ledger/Spike documents are explicitly historical. No new storage policy. |
| FR-2 / blocker, fixed | The public/module/decision sections still implied an ADR-034 amendment and left the internal read interface undecided. | Integrated fixed typed domains, compiler-derived Body, scoped facades, separate mutation authority and three-bank refusal into the main RFC. No fourth-bank amendment; an explicit Canvas decision against ADR-028 remains required downstream. |
| FR-3 / ambiguity, fixed | A blanket freeze/owner guard could be read as prohibiting new State discovery, or as permission to mutate existing models between parent and child reads. | Separated short read borrows from persistent frame ownership/mutation exclusion. New inert materialization and metadata/registration staging have discovery authority; existing model mutation/replacement does not. |
| FR-4 / ambiguity, fixed | Compiler support was repeatedly described as “open” without distinguishing the tested dependency from final build integration. | Recorded the tested project-local Swift 6.3.2 lifetime-feature configuration as the initial implementation dependency. No upgrade, public annotation, global compiler change or unchecked fallback. Pin/build/diagnostic integration belongs to the Spec. |
| FR-5 / blocker, fixed | The RFC carried an obsolete conditional 120,928-byte estimate, conflicting capture totals and premature feasibility language. | Replaced it with the selected three-bank reservation and exact scoped fixture observations. Kept all missing pool/stack/image/allocator costs explicit and mandatory in IH-6. |
| FR-6 / ambiguity, fixed | Historical “next Spike” and before-approval full-migration work remained mixed with terminal results. | Closed investigation language; routed IH-1–6 through ADR/Spec/implementation gates. No new research allowance; concrete implementation contradictions still return for decision. |
| FR-7 / lifecycle, fixed | RFC, manifest, Proposal routing and handoff would disagree after closure unless updated together. | Update current status/navigation and finalization provenance atomically; preserve prior evidence and historical review verdicts. |

All corrections realize already selected decisions or repair their presentation.
Exact public spelling, failure-code values, codecs, physical offsets and generator
implementation remain legitimate Spec/implementation work, not unresolved choices
between architectures.

## Authority and boundary audit

| Source | Result |
| --- | --- |
| Accepted PROPOSAL-007 and runtime scope amendment | RFC boundary traces to iteration-3 I3-04/05 and analyzer/counter stack validation. External delivery stays with RFC-013 / iteration 4. No new MVP commitment. |
| ADR-006 / ADR-008 | Same portable semantics and acyclic owner dependencies preserved. Application schema is an application build surface; generic GiftUI imports no application model. No new package topology selected. |
| ADR-011 / ADR-025 | Serialized mutation exclusion, coarse reports, complete publication and no replay preserved. No mandatory snapshot copy or property dependency graph added. |
| ADR-024 / ADR-026 | Structural State, first materialization, ignored repeated seeds, atomic replacement, retained application owners and bounded profile-equivalent refusal preserved. All owner/pointee and generation details remain mandatory implementation checks. |
| ADR-028 | Protocol Canvas deliberately changes retained-closure representation. Downstream ADR extraction must explicitly address that wording while preserving post-layout order, scoped context and immutable cycle-local plan. This is not an implicit amendment. |
| ADR-032 / ADR-033 | Semantic Core retains layout-input ownership; Interaction/action targets retain exact committed identities and generations independent of bank ordinals. |
| ADR-034 | Three capture banks, horizon, baselines, admission and workload remain unchanged; unavailable replacement capacity refuses. No storage amendment required. |
| SPEC-001/006/007/010/011/012/013/015 | Affected contract map is explicit in the RFC. Existing implemented Specs are still production authority. Review/approve their changes before implementation relies on new declarations or limits. |
| Deferred track | SPIKE-069–074 remain terminal evidence. No orphaned new item or hidden active correctness deferral. General/external work remains outside scope; in-scope acceptance work stays in IH-1–6. |

## Evidence versus remaining acceptance

SPIKE-074 establishes the finite module/inference and guarded transaction
mechanisms: six separately compiled layers on four configurations, 47 checks in
each native selection, eight intended lifetime rejections, measured target
metadata and three-bank backing. It does not run the real runtime profiles,
implement the complete lowerer, prove all host owners or execute/link firmware.
Object allocator references remain; zero heap and complete image/stack fit remain
unproved. Closing the RFC does not waive these failures-to-establish-conformance.

The [implementation handoff](rfc-014-implementation-handoff.md) keeps IH-2–6 as
mandatory source integration, ownership, record migration, conformance and cost
obligations. A violated accepted bound or changed portable semantics requires a
new decision; it cannot be cured by silently increasing a limit. The independent
4 MHz iteration performance issue is preserved outside RFC-014's scope.

## Finalization record

**Condition satisfied; finalization applied.** The corrected RFC was committed
for review as `8de55124`. All review findings above are resolved without a new
architectural/product choice. RFC-014 is now `approved` under Eugene's exact
conditional instruction in this record. This records delegated finalization;
it does not claim that Eugene independently read the edited text or that an
independent reviewer approved it.

Validation passes: `scripts/format-swift.sh`, governance validation, RFC template
section coverage and `git diff --check`. The 48 recorded trial logs and final
SPIKE-074 source hashes remain intact; no new compiler experiment was run.
Current local cross-references are checked as part of finalization. Production
Sources, Tests, Package.swift, scripts, accepted ADRs and implemented Specs remain
unchanged from `e2839fb3`.

At finalization, the next steps were extraction of the three proposed ADRs,
acceptance and affected Specification approval before implementation. The feature
remained at RFC stage until downstream artifacts existed; RFC-013 stayed draft.
No new investigation, iteration closure or production adoption is authorized.

## Downstream extraction — 2026-10-10

Eugene subsequently requested: “Yes, please extract the ADRs.”
Proposed [ADR-035](../../adrs/adr-035-runtime-derived-records-and-exact-identity.md),
[ADR-036](../../adrs/adr-036-scoped-model-access-and-bounded-ownership.md) and
[ADR-037](../../adrs/adr-037-protocol-canvas-and-scoped-post-layout-drawing.md)
now record the three decisions. The manifest is at `decision`; the next gates
are ADR acceptance and affected Specification approval, as tracked in the
[implementation handoff](rfc-014-implementation-handoff.md). ADR-028 remains
accepted pending the explicit supersession described in proposed ADR-037.
