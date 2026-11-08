---
id: RFC-016
feature: observable-reference-state
title: Observable Model Authoring API
status: draft
authors:
  - codex
created: 2026-11-07
updated: 2026-11-08
proposal:
  - PROPOSAL-005
related_rfcs:
  - RFC-008
  - RFC-011
  - RFC-014
  - RFC-015
related_adrs:
  - ADR-024
  - ADR-025
  - ADR-026
  - ADR-027
  - ADR-033
  - ADR-036
  - ADR-038
  - ADR-039
  - ADR-041
related_specs:
  - SPEC-001
  - SPEC-006
  - SPEC-010
  - SPEC-011
  - SPEC-013
  - SPEC-015
related_future_work:
  - FW-017
  - FW-019
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-005
---

# RFC-016: Observable Model Authoring API

## Current iteration allocation — 2026-11-08

Under Eugene's explicit instruction to move I4-10 to the next iteration,
[ITERATION-005](../iterations/iteration-005-authoring-and-storage-assessment.md)
I5-02 / I5-AC-002 receives the unchanged Q1–Q5, OA-01–07 and M0–M6 outcomes.
Use iteration 4's qualified reusable-host counter/analyzer baseline; authoring
migration is counter-first and follows its own RFC/ADR/Spec/ready-plan gates.
RFC-016 remains draft. Iteration 4 has no dependency on this API or migration.

## Summary

Propose a supported `GiftUI` model declaration and mutation authoring surface
that generates observation plumbing and lowers reads/writes through the existing
checked model boundary. Application authors would describe state, pure derived
values and mutation intent without implementing registration or reporting SPI.
Dynamic and Static/Embedded would retain the same authored source and accepted
ownership, admission, invalidation, publication and failure semantics.

This is a **draft**, requested by Eugene on 2026-11-07 after inspection of
`SignalAnalyzerViewModel: _GiftUIObservableReference`. Names and examples below
are candidates, not available APIs or approved contracts. No implementation, conformance closure or RFC approval is authorized by this
draft. The subsequent scheduling instruction below approves iteration inclusion
while retaining the architecture and implementation gates.
The migration sequence is a design-level plan, not a ready Implementation Plan.

## Context

[Accepted PROPOSAL-005](../proposals/proposal-005-observable-reference-state.md)
already covers the public observation concept and equivalent portable behavior.
The feature is in `implementation`; SPEC-010's approved RFC-014 amendment is
implementing. Its amendment controls conflicts with the retained raw-reference
baseline. Existing evidence does not prove this proposed authoring API.

[SignalAnalyzerViewModel](../../Sources/SignalAnalyzerPresentation/SignalAnalyzerPresentationValues.swift)
currently implements `_GiftUIObservableReference`, stores a change sink and
manually attaches, detaches and reports changes. SPEC-010 describes these types
as framework conformance SPI rather than supported client UI. A presentation
model may depend on GiftUI; making its author maintain registration machinery
is the friction addressed here.

ADR-024/025/026 establish structural ownership, coarse synchronous invalidation
and profile equivalence. ADR-027/033 retain admitted facts and bounded action
dispatch. ADR-036 and SPEC-010's amendment require checked scoped reads/writes,
not unrestricted references. ADR-039 preserves scoped actual-owner access and
owned retained consumers; ADR-041 qualifies Native Static construction through
caller-supplied typed backing. These remain constraints, not redesign targets.

The original requirement traces to ITERATION-001's changing Signal Analyzer
capture, status, error and visible-window presentation across four stacks. This
refinement is subsequent authoring work, not a new MVP commitment. ITERATION-004
already records an unresolved analyzer dispatcher/reference integration residual;
ITERATION-005 I5-02 now schedules this RFC and gated migration; iteration 4
resolves its existing-contract residual independently, without waiting for this API.

## Scope and Decision Boundary

The decision cluster is how authored model declarations and mutation methods
become the existing checked, generated model contract. Declaration syntax,
mutation coverage, diagnostics and service separation must be reviewed together:
a pretty declaration without complete write coverage would be unsafe.

A focused RFC under the existing feature is preferable to rewriting approved
RFC-008. This authoring surface can be accepted or rejected while retaining
RFC-008 observation semantics and RFC-014/015 runtime contracts. It introduces no
competing storage owner, read domain, admission queue or host assembly system.
General Swift compilation and general application integration remain outside
this boundary; RFC-013's draft candidates are not authority here.

## Requirements

These are proposed review requirements; accepted constraints remain authoritative.

- OA-01: Portable model/view source imports GiftUI and application Domain as
  needed, with no handwritten underscored observation symbols or runtime imports.
- OA-02: One supported declaration produces equivalent authored reads and
  admitted mutations on macOS Dynamic/Static, Pi 1 ARMv6 Dynamic and nRF52840
  Embedded Static. Unsupported source fails explicitly on the common surface.
- OA-03: Preserve structural State identity, ignored repeated seeds, replacement,
  removal, bounded ownership, generation validation and deterministic refusal.
- OA-04: Every admitted observable change reports synchronously before its
  mutation returns; proven no-ops may omit reports. Preserve owner-level
  coalescing, freeze, publication and no replay after derivation failure.
- OA-05: Generated accesses obey actual backing lifetime, exclusive mutation,
  preflight/commit and service exclusion; annotations cannot bypass admission.
- OA-06: Unsupported aliases, escapes, unchecked writes and unbounded constructs
  receive source-located diagnostics, without fallback to raw references.
- OA-07: Demonstrate finite costs and equivalent failure/lifecycle behavior;
  authoring convenience adds no implicit heap fallback or capture bank.

## Constraints

No property dependency graph, Apple Observation, Combine, task-local resolution,
reflection, `Any` registry, arbitrary unchecked `inout` callback or dynamic-only
escape hatch. No new scheduler, actor, lock, snapshot history or observer list.
Existing capacity and resource budgets remain controlling. Authored reference
identity does not imply an allocated class on Embedded Static.

## Proposed Design

### Declaration and ownership

Candidate markers `@ObservableModel` and `@ModelMutation` identify inputs to
GiftUI's finite source-generation/lowering pipeline. A marker need not itself be
a sufficient standalone Swift macro expansion. Exact build integration and
supported grammar remain approval blockers below.

```swift
import GiftUI
import SignalAnalyzerDomain

@ObservableModel
final class SignalAnalyzerViewModel {
    private(set) var state = SignalAnalyzerViewState()

    var visibleRange: Range<Duration> {
        let window = state.visibleWindow.duration
        let end = max(window, state.capture.duration)
        return max(.zero, end - window)..<end
    }

    @ModelMutation
    func visibleDurationChanged(_ window: VisibleTimeWindow) {
        guard state.visibleWindow != window else { return }
        state.visibleWindow = window
    }
}
```

This is an abbreviated authoring example, not a replacement implementation.
Stored model data is observable by default; pure computed properties derive from
that data. The initial supported subset would exclude inheritance and arbitrary
mutable reference fields. Domain aggregates require known typed lowering; they
are not automatically safe merely because the outer property is declared `var`.
No arbitrary `@ObservationIgnored` escape hatch is proposed for mutable services.

Generated output would contain the typed schema, inert seed, storage bridge,
scoped scalar/nested/indexed reads, checked mutation operations and registration
witnesses. Services are absent from seeds/read facades. Separate host bindings
retain use-case access. Storage initialization does not start acquisition.

`@State private var viewModel: SignalAnalyzerViewModel`, ordinary reads such as
`viewModel.state.acquisitionState`, and `@ObservableStateHost` remain the authored
view shape. Lowering supplies schema/domain parameters and checked accesses.
Initial seeds, candidate ownership transfer and preserved State binding retain
the approved semantics; an ordinary-looking initializer cannot secretly create
another independently populated capture bank.

### Mutation and reporting

`@ModelMutation` denotes a supported synchronous entry point, not unrestricted
permission to call a method from any executor. Action dispatch and admitted
presentation facts resolve the existing target and enter the checked mutation
route. Calls outside that route are rejected; the final Specification must
identify which invalid uses are compile-time versus bounded runtime failures.

Generated operations validate phase, owner/schema/generation, capacity and
fallible domain preconditions before writes. Compound capture updates retain
preflight followed by non-failing commit. Reporting occurs after the model-data
borrow ends and before the operation returns, using disjoint registration/dirty
bookkeeping. A changed flag may be derived from supported committed writes;
whole-model comparison and full-capture rollback copies are not the default.

Repeated writes may produce coalesced coarse reports. Exact report count is not
a client guarantee. A conservative report is allowed when no-op proof is absent.
An early return before a write need not report. If an admitted sequence partly
changes state before a later operation fails, the existing first-failure and
actual-partial-work contract remains, with reports for committed changes and no
replay of effects. A method annotation promises neither general transactional
rollback nor automatic safe lowering of arbitrary throwing Swift code.

### Services, actions and admitted facts

Start/Stop/Clear remain application intents; their use cases remain host-owned
services reached through the accepted action/executor path. Capture/status facts
still enter the presentation admission owner and mutate the model only when
admitted. Neither the marker nor a generated setter may move repository sinks
onto the ViewModel or let external producers mutate sealed frame data.

The service-free example above is deliberately insufficient to close this RFC.
Before approval, expand an actual Start intent, its error-state update and an
admitted capture fact through the proposed surface. Show the service binding,
checked access, report timing, owned dispatcher return/copy behavior and failure
transport. Preserve ADR-039's distinction between scoped operation access and
owned retained dispatchers. Do not store a scoped read/mutation facade in either.

### Boundary visible to authors

The author supplies domain state, pure derivation and application behavior. The
framework/generator supplies attach/detach, sink ownership, stale attachment
protection, dirty reporting, scoped access and profile storage bridges. Generated
cross-module SPI may remain public for compiler visibility; that does not make
it a supported handwritten extension API. Do not mechanically reduce access
levels until generated and external-consumer needs are established.

## Module Responsibilities

| Owner | Responsibility | Dependency impact |
| --- | --- | --- |
| GiftUI | Supported markers and authored State/View surface | No runtime or application schema dependency |
| Host build tooling | Validate finite syntax; generate typed schema, witnesses and source mapping | Tooling stays out of deployed images |
| Application-generated schema surface | Field types, pure reads and finite operations | Preserve ADR-036 schema/import direction |
| GiftUIObservableState | Shared registration, ownership and checked operation machinery | Reuse existing owners, no observer subsystem |
| Runtime Dynamic / Static and host bridge | Concrete backing and admitted execution | Same bounds and outcomes; profile-specific realization |
| Application Presentation / Domain | Data, intent and domain rules | No sink or registration implementation |

## Public API Impact

Candidate additions are `@ObservableModel` and `@ModelMutation`; exact signatures,
annotation roles and generated names await grammar/build review. No new manual
`invalidate`, attach/detach or general mutation-closure API is proposed. Existing
`@State` and `@ObservableStateHost` authoring is preserved. Initializer/service
binding source compatibility must be resolved before approval, not hidden behind
a promise that the complete current class compiles unchanged.

## Capabilities Impact

No new runtime capability or negotiation. Supported model forms are build-time
constraints shared across profiles. Missing required compiler/lowering features
fail the build; static capacity exhaustion retains explicit bounded outcomes.

## Backend Impact

No renderer/display/input/platform interface changes. Backends continue to
consume complete published output. Observation never renders immediately or
turns backend refusal into replay of application effects.

## Static / Embedded Impact

Generate concrete typed operations and use existing bounded storage/registration.
Dynamic may retain objects internally; Embedded uses stable fixed/caller-supplied
backing. Native Static construction continues to follow ADR-041. Nonowning keys
remain distinct from owning tickets, registrations and frame pins. Copying a key
neither extends lifetime nor forks model state. No generated pointer may outlive
its actual owner; numeric generations alone do not establish memory safety.

## Performance

Expected reporting remains constant bounded owner-dirty work, with existing
validation on checked operations. Instrumentation must not introduce a per-field
observer registry or whole-state comparisons. Measure mutation/report latency,
complete-root derivation, build time and generated specialization growth against
an identified adopted baseline; no performance improvement is asserted yet.

## Memory / Binary Size

The intended additional runtime observer-list capacity is zero. This is a design
target, not measured evidence. Record actual generated metadata, code size,
stack high-water/bounds, RAM and allocation behavior, including initialization,
replacement, failure and cleanup. Charge all simultaneous live storage and host
libraries under existing profile rules. Existing resource exceptions are not
transferable to another model or target. No budget is raised by this RFC.

## Alternatives

| Candidate | Benefit | Limitation / suitable use |
| --- | --- | --- |
| Generated declaration + checked lowering (preferred) | Removes plumbing and covers reads/writes under existing architecture | Requires a precise finite grammar, diagnostics and end-to-end evidence |
| Public registrar/helper on handwritten models | Smaller local migration; explicit signaling | Leaves write coverage and lifetime/admission responsibility with authors; insufficient as the portable default |
| Generate only attach/detach witnesses | Removes registration boilerplate | Manual reports and unchecked aliases remain; possible implementation step, not OA-01–06 completion |
| Explicit public state schema and operation enum | Clear finite embedded contract; less source transformation | Changes authored ergonomics; credible fallback if marker lowering cannot meet evidence gates |
| Keep current SPI authoring | No immediate migration cost | Continues observed abstraction leakage and author-maintained correctness obligations |

## Rejected Approaches

No new candidate has been rejected by review. Existing ADRs already exclude
Apple Observation as the common contract, explicit runtime invalidation as client
coordination, unchecked reference escape and arbitrary unchecked `inout` access.
Renaming the protocol alone does not satisfy this RFC's requirements.

## Compatibility

Preserve observable behavior, domain data meaning, action/fact order and profile
outcomes. Handwritten source migration is expected; binary compatibility is not
claimed for generated implementation symbols. Establish current public consumer
usage before selecting a deprecation period. During migration, legacy and generated
implementations may coexist in separate fixtures, but never own duplicate active
registrations for the same model/location. No fallback through the old unchecked
route may circumvent approved scoped access.

### Conditional migration plan

| Step | Work and affected contracts | Exit evidence |
| --- | --- | --- |
| M0 | Freeze adopted source/compiler/profile baseline; inventory handwritten observation, generated bridges and analyzer factory residuals | Exact symbol/source inventory and separate existing-failure list; no claimed baseline pass from stale evidence |
| M1 | Resolve Q1–Q5; review RFC; extract any new authoring-boundary ADR; amend SPEC-010 and affected SPEC-006/001/011/013/015 contracts | Explicit human approvals before implementation; current semantics remain controlling |
| M2 | Derive a ready Implementation Plan mapping OA requirements to approved Spec criteria; implement finite declaration/lowering and diagnostics | Counter positive/negative source fixtures and deterministic generated output |
| M3 | Migrate counter through existing dynamic/static owners | Four-profile ownership, mutation, failure and resource evidence |
| M4 | Migrate analyzer data/derived reads, then window intent, admitted capture/status facts and Start/Stop/Clear service integration | Nested/indexed reads, bounded capture preflight/commit, action ordering, errors and actual factory owned/scoped controls |
| M5 | Remove handwritten sink/attachment/report code from migrated Presentation; audit handwritten/generated source separation and consumer build path | No handwritten observation SPI in migrated models/views; generated code uses approved bridges only |
| M6 | Compare profiles and resource totals; review conformance and migration documentation; remove obsolete compatibility fixtures only after evidence adoption | Criterion-by-criterion report and explicit human completion transition |

These steps neither restart P08 campaigns nor consume their historical allowances.
Open P09/P10–P12 and iteration-4 residuals retain their own authority and evidence.
The derived plan must reconcile overlap rather than duplicate or declare those
obligations complete. No connected deployment/flashing is part of this draft.

## Testing Strategy

- OA-01/02/06: compile the same authored counter/analyzer subset on the four
  governed configurations; assert source-located rejection for escaping facades,
  mutable reference aliases, unchecked `inout`, unsupported nested mutation and
  service access from read facades. Inspect deterministic generated output and
  build dependency closure; do not equate a parsed marker with working lowering.
- OA-03: preserved initializers, replacement/refusal, removal, duplicate attach,
  stale keys/attachments, exhausted generations/capacities, detached owned models
  and correct release order. Include actual owned dispatcher return/copy tests
  and scoped-storage rejection controls.
- OA-04/05: changed/no-op/early-return paths, nested writes, compound capture
  preflight failure, committed changes before later failure, synchronous report
  timing, freeze rejection, coalescing and failed-derivation reattempt without
  replaying use cases or facts. Use independent semantic traces across profiles.
- OA-07: measured RAM/stack/code/allocation and bounded metadata; inspect ARMv6
  and Cortex-M4F artifacts under existing target rules. Hardware observations,
  where required by eventual acceptance criteria, remain distinct from builds.
- Audit handwritten Presentation for prohibited observation symbols while
  allowing documented generated SPI. Pair this structural check with semantic
  evidence; symbol absence alone cannot establish safety.

## Risks

- Marker syntax could imply arbitrary Swift support. Publish a finite grammar
  and diagnostics before advertising the API.
- Nested setters can conceal large copies or aliasing. Require explicit aggregate
  lowering and capture preflight/commit evidence, not generic `didSet` synthesis.
- Service-backed methods can blur action execution and model mutation. Preserve
  admitted ordering and prove the complete service/error/fact path.
- Specialization can increase binary size or stack. Measure linked target costs;
  source simplification is not a resource proof.
- Migration can conceal existing integration failures. Baseline them separately
  and require actual factory evidence rather than a substitute fixture alone.

## Open Questions

All questions below are **approval blockers**, not deferred work.

- Q1 — What exact declaration/mutation grammar is supported, and which existing
  lowering stage owns each transformation? Provide source-to-generated counter,
  nested analyzer and unsupported-source examples, including diagnostic locations.
- Q2 — How are service bindings and intent methods authored without services in
  seeds/read facades? Review complete Start/error and capture-fact expansions,
  initializer compatibility and actual owned dispatcher integration.
- Q3 — How are nested writes, helper calls, early returns, throwing operations
  and partial admitted work instrumented? Provide report/borrow-order traces and
  a bounded preflight representation for capture writes.
- Q4 — Are these true Swift macros, generation markers, or a combined tool
  surface? Demonstrate compatibility with the approved compiler configuration
  and a consumer build without hand-maintained generated files. Any needed
  bounded feasibility experiment requires its own explicit scope/evidence record.
- Q5 — What migration/deprecation boundary and measured resource criteria apply?
  Inventory consumers and select existing controlling budgets/fixtures; do not
  infer a new iteration allocation or generalize a target-specific exception.

## Deferred and Follow-up Work

- [FW-017](../future-work/fw-017-public-binding-abstraction.md) remains the owner
  of public binding projections. This RFC adds no `$model.field` two-way binding;
  revisit under that item's concrete public projection requirement.
- [FW-019](../future-work/fw-019-fine-grained-observable-dependency-tracking.md)
  remains the owner of property tracking/selective reevaluation. Field-write
  instrumentation here does not promote it; revisit only on its performance or
  accepted larger-hierarchy triggers.

No new deferred decision is needed: source lowering, service authoring and
mutation coverage are necessary to this design and remain blockers above.

## Decision Summary

Candidate for extraction after approval: a supported generated model-authoring
boundary with exhaustive checked mutation coverage and diagnostics, keeping
registration SPI out of handwritten application code. Exact syntax and mechanical
migration belong in subsequent Specification amendments. ADR-024/025/026/027/036
and applicable ADR-039/041 ownership rules remain unchanged. If review finds that
this candidate requires different semantics, return that choice for an explicit
architecture amendment rather than presenting it as implementation detail.

## References

- [RFC-008](rfc-008-observable-reference-state-architecture.md)
- [RFC-014](rfc-014-runtime-derived-records-and-scoped-model-access.md)
- [RFC-015](rfc-015-p08-scoped-storage-ownership.md)
- [SPEC-010](../specs/spec-010-observable-reference-state.md), approved amendment
- [ADR-036](../adrs/adr-036-scoped-model-access-and-bounded-ownership.md)
- [ADR-039](../adrs/adr-039-scoped-storage-ownership.md)
- [ADR-041](../adrs/adr-041-native-static-typed-model-backing.md)
- [ITERATION-001](../iterations/iteration-001-mvp.md)
- [ITERATION-004](../iterations/iteration-004-backend-and-application-integration.md), analyzer integration residual
- [GiftUI authored/compiled State](../../Sources/GiftUI/ObservableState.swift)
- [Internal storage bridge](../../Sources/GiftUIObservableState/ObservableStateModel.swift)
- [Checked mutation contract](../../Sources/GiftUIObservableState/ObservableModelMutation.swift)

## Historical Iteration Allocation — 2026-11-07

After the draft was presented, Eugene instructed: “please add work on this rfc
and changes into the next iteration and commit”. ITERATION-004 revision 7
therefore includes I4-10 and I4-AC-011: resolve Q1–Q5, review the API, obtain
required ADR/Specification approvals, and deliver the conditional M0–M6 migration
with four-profile evidence. This is scope approval, not RFC approval or immediate
implementation authorization. Existing iteration entry gates, resource limits,
P08 allowances and analyzer integration residuals remain unchanged.
