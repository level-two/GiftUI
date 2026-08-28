---
id: RFC-011
feature: giftui-mvp-architecture
title: Bounded Application Actions and Model-Target Dispatch
status: approved
authors:
  - codex
created: 2026-08-27
updated: 2026-08-27
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-004
  - RFC-008
related_adrs:
  - ADR-006
  - ADR-008
  - ADR-011
  - ADR-013
  - ADR-024
  - ADR-025
  - ADR-026
  - ADR-033
related_specs:
  - SPEC-001
  - SPEC-006
  - SPEC-009
  - SPEC-010
  - SPEC-011
  - SPEC-013
related_future_work:
  - FW-021
related_explorations: []
related_spikes:
  - SPIKE-007
supersedes: []
superseded_by: []
target_milestone: MVP
---

# RFC-011: Bounded Application Actions and Model-Target Dispatch

> **Approval status:** Approved by explicit maintainer authorization. This RFC
> establishes design consensus but does not itself change ADR-013, authorize
> implementation, or make SPEC-011 authoritative. Accepted ADR-033 extracts
> the agreed decision; revised dependent Specifications require their own
> approval gates.

## Summary

GiftUI's portable `Button` should carry a finite typed application-action value
rather than an escaping closure. A target-composed, statically known action
handler should apply that value to the currently installed observable model
only during SPEC-009's mutation phase. Interaction records and pointer captures
should contain no closure or model reference.

The runtime coordinator should bind each committed action value to the exact
generation of its target observable-model registration. Replacing the model
must change that binding, install a new action generation, and cancel a press
captured against the former model. Dynamic profiles may offer closure syntax as
an optional convenience, but portable Signal Analyzer source and the static
profile must not depend on closure retention or closure-to-tag synthesis.

## Context

[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
authorizes architecture needed to deliver one substantially shared Signal
Analyzer presentation across macOS dynamic, macOS static, Raspberry Pi/Linux,
and nRF52840 static configurations.

RFC-002 places `Button` in the portable `GiftUI` declaration surface, allows
static runtimes to use identified actions, and keeps heap-backed callback
conveniences optional. RFC-004 and ADR-013 require bounded, presentation-coupled
input, identity-generation capture, current-state release validation, and
at-most-once mutation-phase action application. RFC-008 and ADR-024 through
ADR-026 give the Signal Analyzer one structurally owned observable root model
with profile-equivalent replacement and registration generations.

ADR-013 currently describes a callable payload in every committed action
record. Draft SPEC-011 consequently proposes retaining arbitrary escaping
closures dynamically and synthesizing finite tagged callables statically.
[SPIKE-007](../spikes/spike-007-static-action-storage-feasibility.md) shows that
persisting a captured closure retains an allocator path on nRF52840, while a
manually constructed tagged callable is bounded. The Spike does not show how
ordinary `Button(action: { ... })` source can be converted into that tagged
callable without a new source-generation or compiler architecture.

The architectural issue is therefore the portable meaning and ownership of an
application action, not merely a missing lowering protocol in SPEC-011.

## Scope and Decision Boundary

This RFC owns one independently reviewable decision cluster:

- the portable representation of a Button action;
- the application action-domain and handler boundary;
- binding an action to a live observable-model target;
- replacement and pointer-capture behavior when that target changes; and
- the dynamic/static representation boundary for action dispatch.

These concerns must be reviewed together because choosing an opaque closure,
stable token, or typed action value changes persistent storage, model lifetime,
replacement generations, dispatch ownership, and portable source semantics at
the same boundary.

RFC-002 continues to own the integrating module graph. RFC-004 continues to own
admission, phase ordering, capture state, action-generation allocation, and
frame commit. RFC-008 continues to own observable-model storage, registration,
replacement, and invalidation. This RFC defines the action/model binding passed
between those owners without moving their existing responsibilities.

Multiple independently scoped action domains, nested model targets, reusable
feature routing, environment dispatch, and public binding abstractions are not
required by the one-root-model Signal Analyzer and are preserved in
[FW-021](../future-work/fw-021-scoped-action-domains.md).

## Requirements

- Portable Signal Analyzer source MUST use the same finite application-action
  declarations in every MVP profile.
- A committed interaction record and a pointer capture MUST contain no closure,
  model reference, application object, existential, or backend value.
- The static action path MUST allocate zero heap bytes and MUST NOT require
  reflection, runtime type discovery, or opaque closure-to-tag synthesis.
- Action dispatch MUST occur exactly once, synchronously, in SPEC-009's
  `.mutating` phase and in its admitted semantic-action order.
- The handler MUST receive the current validated model target; it MUST NOT
  retain or invoke an initializer-time model after runtime replacement.
- Replacing or removing the target model MUST cancel a captured action rather
  than apply it to the replacement or a stale model.
- Dynamic and static realizations MUST produce equivalent action, cancellation,
  failure, model-change, and publication transcripts at equal limits.
- Backends, input integrations, drivers, and diagnostics MUST NOT resolve or
  invoke application actions.

## Constraints

- The MVP Signal Analyzer has exactly one structurally owned root observable
  ViewModel and six finite actions: Start, Stop, Clear, and three visible-window
  selections.
- The public model remains SwiftUI-inspired but does not promise SwiftUI source
  compatibility.
- SPEC-009 owns the runtime-wide finite `ActionGeneration` namespace and its
  fail-closed exhaustion behavior.
- Observable state replacement must retain ADR-024 through ADR-026 ownership,
  attachment, and profile-equivalence semantics.
- The runtime component graph and selected handler are immutable after assembly.
- Exact action-code width, target-generation declaration, limit values, public
  spellings, and local error types belong to downstream Specifications.

## Proposed Design

### Portable action values

Portable application code declares one finite action domain. The architectural
shape is a typed, bounded, `Sendable` value that can be normalized without
allocation into a fixed-width action code. For the Signal Analyzer, an
illustrative source shape is:

```swift
enum SignalAnalyzerAction: UInt16, GiftUIAction {
    case start
    case stop
    case clear
    case selectOneSecond
    case selectTwoSeconds
    case selectFiveSeconds
}

Button("Start", action: SignalAnalyzerAction.start)
Button("2 s", action: SignalAnalyzerAction.selectTwoSeconds)
```

The exact `GiftUIAction` and `Button` declarations remain Specification work.
The architecture requires the declaration to carry an action value rather than
a callable. A qualified enum case is the required feasible source form.
Unqualified `.start` syntax may be provided only when ordinary Swift contextual
typing supports it; this RFC does not require an action-scope type system solely
to shorten that spelling.

The MVP action domain is finite and has no arbitrary associated payload. A
later application that requires bounded action payloads must justify and
specify their representation through its own lifecycle.

### Assembled action handler

The target composition supplies one statically known action handler and binds
it to the Signal Analyzer's root observable state location. Its architectural
shape is equivalent to:

```swift
protocol GiftUIActionHandler {
    associatedtype Action: GiftUIAction
    associatedtype Model: _GiftUIObservableReference

    mutating func handle(
        _ action: Action,
        model: borrowing Model
    )
}
```

The handler type and action domain are immutable for the assembled runtime
lifetime. A static profile specializes dispatch into a total switch over the
finite action domain. A dynamic profile may use different bounded storage or
dispatch mechanics but must preserve the same action meaning and ordering.

The handler does not own, retain, register, or replace the observable model.
The runtime coordinator borrows the current installed model from the
Observable State owner only for the synchronous dispatch call. The handler may
invoke the model's Start, Stop, Clear, or visible-window intent. Any model
change must synchronously use the model-owned change-report seam before the
handler returns.

An action-triggered repository callback still terminates at SPEC-010's bounded
fact-admission adapter and can affect the model only in a later cycle. It cannot
reenter the active action mutation.

### Bound action record

The runtime coordinator is the first owner that knows both a successful
Interaction candidate and the current observable-model registration. It binds
the action value to that registration without making `GiftUIInteraction`
import `GiftUIObservableState`.

Architecturally, the committed record contains:

```text
semantic action identity
action generation
effective enabled state
hit geometry and painter order
bounded application-action value
opaque target-registration generation
```

The opaque target generation proves which installed model the action was
derived to address. It is not a model reference, state value, attachment
capability, public identifier, persisted value, or pointer-capture field.

The action generation may be preserved only by preserving the exact formerly
committed bound record. A changed action value, changed target generation,
changed binding, or newly substituted record is replacement and requires a
fresh SPEC-009 action generation. Frame refusal preserves the formerly
committed bound record and generations unchanged.

### Model replacement and removal

Model replacement is fail-closed for an active press:

1. A down captures only semantic identity and action generation.
2. Replacing the root model installs a new non-aliasing observable registration
   generation under the Observable State contract.
3. The next candidate binds the same action value to the new target generation,
   treats the bound record as replacement, and reserves a fresh action
   generation.
4. Release against the former action generation fails validation and invokes
   neither the former nor replacement model.

Published model removal similarly removes the bound action target. A staged or
failed replacement that does not commit preserves the former target and action
record. Immediately before invocation, the coordinator revalidates semantic
identity, action generation, enabled state, and target generation. Any mismatch
cancels activation.

This rule intentionally rejects applying an old press to whichever model is
current at release. The conservative cancellation preserves the user's action
target across observable-model lifetime changes.

### Dispatch flow

```text
Button action value
    -> semantic identity and enabled-state lowering
    -> layout bounds, clip, and painter order
    -> bind current target-registration generation
    -> stage bound action record
    -> accepted frame atomically commits record and hit map
    -> down captures identity-generation only
    -> valid release admits one semantic action
    -> mutation phase revalidates action and target generations
    -> typed handler borrows current model and applies the action once
    -> model change report dirties the owning state location
```

No declaration closure, handler reference, or model reference enters the hit
map or pointer state.

### Optional dynamic closure conveniences

`GiftUIDynamicConveniences` may separately offer callback-oriented syntax for
applications that deliberately opt into dynamic facilities. Such syntax is
not the portable Signal Analyzer contract, does not define static semantics,
and must adapt through a bounded dynamic action domain rather than changing
Interaction, Execution, or model-target validation. Whether existing dynamic
callback initializers remain source-compatible is downstream Specification and
migration work.

## Module Responsibilities

| Module or owner | Responsibility | Dependency impact |
| --- | --- | --- |
| `GiftUI` | Portable finite action value and Button declarations | Remains the portable leaf; imports no runtime, state, backend, or application model |
| `GiftUISemanticCore` | Structural/action identity and typed action payload traversal | Depends only on portable declarations; invokes no action |
| `GiftUIInteraction` | Enabled state, bound-record staging input, hit routing, current action lookup, and action-local errors | May import semantic, layout, and execution contracts; imports no observable-state implementation or application model |
| `GiftUIObservableState` | Current model location, registration generation, replacement, removal, and change reporting | Does not import Interaction or invoke handlers |
| Runtime coordinator | Joins successful semantic/layout/interaction candidates with the current model-target generation and commits them with the frame | Profile owner may import both focused contracts; owns no application behavior |
| Action-handler adapter | Decodes the finite action value and applies it to a borrowed current model | Target-composed above focused owners; statically known for the runtime lifetime |
| `GiftUIExecution` | Phase ordering, action-generation allocation, capture, admission, and at-most-once mutation | Does not import Interaction, Observable State, or an application handler |

## Public API Impact

Portable `Button` source changes from an escaping callback to a finite typed
action value. The guaranteed source form uses a qualified application action:

```swift
Button("Clear", action: SignalAnalyzerAction.clear)
```

Views continue to read the observable model for presentation and disabled
state, but buttons do not capture that model. Model intent wiring moves to the
one assembled handler. This is less callback-oriented than SwiftUI but keeps
the portable application source explicit, bounded, and common to every MVP
profile.

The existing proof-of-concept `ActionID` surface and dynamic callback extension
have no compatibility authority. A downstream Specification must state their
retention, migration, or removal explicitly.

## Capabilities Impact

This design adds no Capability. The action domain and handler are required
components of an interactive Signal Analyzer runtime, not runtime-probed
facilities. Missing or incompatible action/model bindings fail host assembly or
the pre-publication candidate according to downstream contracts; portable view
code does not branch on their presence.

## Backend Impact

None. Backends continue to receive only normalized render operations and frame
provenance. Input integrations continue to normalize and stamp physical events
without seeing action values, model targets, handlers, hit maps, or callables.

## Static / Embedded Impact

Static action records retain fixed-width values and generations only. The
handler, model accessor, decoding, and total action switch are statically known
and may specialize into direct calls. The path requires no allocator, closure
box, reflection, existential registry, task, actor, Objective-C runtime, or
platform callback.

The static profile already requires generated address-stable root-model storage
and registration dispatch under the observable-state lifecycle. The same
immutable profile descriptor may identify the action domain, handler type, and
root target location. This RFC adds no runtime source scanning or closure
capture analysis.

Hardware-free nRF52840 evidence must verify the fixed storage, direct dispatch,
forbidden-symbol absence, Cortex-M4F hard-float ABI, flash/RAM deltas, and stack
bound. It does not replace connected-board interaction evidence required at the
implemented transition.

## Performance

Candidate construction remains linear in action occurrences. Action-code
decoding, target-generation comparison, and total-switch dispatch are constant
time for the six-case Signal Analyzer domain. Hit testing and pointer
sequencing retain their separately specified bounds.

Action dispatch adds no queue and performs no model lookup by reflection or
string. Dynamic and static conformance fixtures must record action-derivation,
target-binding, and dispatch timing and demonstrate that the handler does not
alter the Signal Analyzer's 250-millisecond presentation target.

## Memory / Binary Size

Each committed record adds one bounded action value and one opaque target
generation to the identity, action generation, enabled state, and geometry
already required by Interaction. Exact widths and packing are Specification
work and must be measured rather than inferred from this RFC.

The static path uses fixed record, hit-region, and source capacities and zero
heap allocation. The finite action switch adds bounded code size proportional
to the configured Signal Analyzer action cases. A dynamic convenience registry,
if retained, is outside the portable static image and must remain independently
bounded.

## Alternatives

### Portable escaping closures plus generated callable unions

This preserves SwiftUI-like callback syntax. It requires a compiler, macro, or
source-generation boundary that discovers captures, emits a finite callable
union, reports unsupported captures, and keeps dynamic and generated behavior
equivalent. SPIKE-007 proves only the manually generated representation, not
that transformation. This option would be appropriate only if GiftUI chooses
such build tooling as a first-class architecture and accepts its complexity.

### Stable untyped `ActionID` and handler registry

This is close to the proof of concept and is easy to store. It places collision,
registration, missing-handler, and payload rules on clients and weakens source
typing. A typed finite action value can normalize to a bounded code internally
without exposing an unstructured identifier as the preferred application API.

### Restricted function pointer plus bounded context

A thin function and explicitly bounded context can avoid an ordinary closure
box. It exposes representation constraints in client syntax, complicates
heterogeneous storage, and still requires ownership and lifetime rules for the
context. It is a viable systems API but is less appropriate for the familiar
portable presentation surface.

### Handler retains the initializer-time model

This is simple to assemble but can invoke a stale model after `@State`
replacement or keep a published-removed model alive. It duplicates lifetime
ownership outside the observable state location.

### Resolve the current model at release without target-generation cancellation

This applies an old press to a replacement model when the action code and
structural identity remain unchanged. It reduces cancellation but weakens the
identity-generation safety guarantee and changes the target of an interaction
after down. The proposed design instead treats model replacement as action
replacement and cancels.

### Permit heap-backed closures on embedded targets

This minimizes API change but conflicts with zero-heap static operation and
current evidence shows an allocator-failure trap rather than a bounded local
failure. It would require changing embedded resource and failure architecture,
not merely relaxing one implementation choice.

## Rejected Approaches

The proposed direction rejects retaining or synthesizing arbitrary closures in
the portable MVP action path, retaining the model in each Button or action
record, and applying a captured press to a replacement model. These approaches
do not satisfy the selected bounded ownership and fail-closed target semantics.

Optional dynamic callback conveniences are not rejected for dynamic-only
applications; they are excluded from portable MVP authority.

## Compatibility

Portable proof-of-concept code using `Button(action: ActionID)` or a retained
closure requires migration to a finite application action value. Signal
Analyzer intent methods and visible behavior remain unchanged. Target assembly
adds the statically known handler and target binding; platform input and backend
code remain unchanged.

No action value, target generation, action generation, or raw code is public
ABI, persisted data, or a wire format. Reordering or renumbering a private
action enum between builds does not require data migration.

## Testing Strategy

Shared recording, dynamic, and static fixtures must cover:

- compilation of the qualified finite-action Button source in every profile;
- exact normalization and total decoding of all six Signal Analyzer actions;
- rejection of unknown, malformed, or wrong-domain action values;
- one handler invocation in SPEC-009 semantic-action order;
- disabled, removed, stale-generation, moved-out, and replacement cancellation;
- model replacement after down and before release, proving that neither model
  receives the action;
- model replacement after action admission but before dispatch, proving final
  target-generation revalidation and no invocation;
- failed or refused model replacement preserving the former target and record;
- frame refusal preserving the formerly committed action and target generations;
- model removal invalidating the target and retaining no model through capture;
- action-driven model reporting, dirty coalescing, and complete publication;
- action-triggered repository delivery entering only a later admission;
- equal dynamic/static action and cancellation transcripts at equal limits;
- zero static heap allocation and absence of closure, reflection, existential,
  task, backend, platform, and allocator dependencies; and
- nRF52840 and ARMv6 compile/link, ABI, stack, flash, and RAM evidence.

No connected hardware is required to approve this architecture. Connected
input/display evidence remains an implementation-conformance gate.

## Risks

- **Reduced SwiftUI familiarity.** Qualified action values are more explicit
  than closure callbacks. Dynamic conveniences may preserve callback ergonomics
  where allocation is intentionally available.
- **Action/model coupling leaks into focused modules.** Keep the binding in the
  runtime coordinator and action-handler adapter; Interaction and Observable
  State must not import each other.
- **Model replacement races are implemented inconsistently.** Require the
  target generation in the complete bound-record equality and revalidate it
  immediately before dispatch.
- **A generic action-domain system expands beyond MVP.** Limit the approved
  contract to one finite Signal Analyzer domain and one root model target;
  preserve broader scoping in FW-021.
- **Action codes become accidental persistence.** Specify that they are
  runtime/build-local values and test semantic tokens rather than raw storage
  outside the exact layout tests.

## Open Questions

No open architectural question remains. Exact public declarations,
fixed widths, capacities, error values, and migration spellings remain
downstream Specification work.

## Deferred and Follow-up Work

- [FW-021](../future-work/fw-021-scoped-action-domains.md) preserves nested or
  multiple action domains and model targets. It remains outside MVP because the
  Signal Analyzer has exactly one root observable model and one finite action
  domain. Revisit when an accepted application requires independently
  replaceable nested targets or a maintained reusable view library requires
  scoped action routing.

## Decision Summary

This approved RFC produces one focused ADR that:

1. replaces ADR-013's committed callable payload with a bounded application
   action value bound to an opaque observable-model target generation;
2. places the statically known handler and current-model borrow at the assembled
   runtime coordinator boundary rather than in Button, Interaction, or a
   backend;
3. requires model replacement or removal to replace the bound action record,
   advance its action generation, and cancel an existing press; and
4. confines arbitrary closure syntax to optional dynamic conveniences outside
   the portable MVP action contract.

The ADR must state precisely which clauses of ADR-013 it supersedes while
preserving that ADR's provenance, sequencing, capture, and current-state
validation decisions.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002: GiftUI MVP Layered Architecture](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-008: Observable Reference State Architecture](rfc-008-observable-reference-state-architecture.md)
- [ADR-013: Provenance-Validated Presentation-Coupled Input](../adrs/adr-013-provenance-validated-input-admission.md)
- [SPEC-001: Signal Analyzer Reference Application](../specs/spec-001-signal-analyzer-reference-application.md)
- [SPEC-009: Execution Cycle and Frame Handoff Contract](../specs/spec-009-execution-cycle-and-frame-handoff.md)
- [SPEC-010: Observable Reference State Contract](../specs/spec-010-observable-reference-state.md)
- [SPEC-011: Button Interaction and Activation Contract](../specs/spec-011-interaction.md)
- [SPIKE-007: Static Action Storage Feasibility](../spikes/spike-007-static-action-storage-feasibility.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
