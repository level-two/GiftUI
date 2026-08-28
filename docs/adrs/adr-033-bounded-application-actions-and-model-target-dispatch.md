---
id: ADR-033
feature: giftui-mvp-architecture
title: Bounded Application Actions and Model-Target Dispatch
status: accepted
authors:
  - codex
created: 2026-08-27
updated: 2026-08-28
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-011
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-010
  - ADR-011
  - ADR-013
  - ADR-024
  - ADR-025
  - ADR-026
related_specs:
  - SPEC-001
  - SPEC-002
  - SPEC-006
  - SPEC-009
  - SPEC-010
  - SPEC-011
  - SPEC-013
  - SPEC-015
related_future_work:
  - FW-021
related_explorations: []
related_spikes:
  - SPIKE-007
supersedes:
  - ADR-013
superseded_by: []
target_milestone: MVP
---

# ADR-033: Bounded Application Actions and Model-Target Dispatch

> **Accepted successor:** This ADR supersedes ADR-013 in full. The complete
> input-provenance and pointer-sequencing rules are restated here so current
> authority does not depend on combining active and superseded records.

## Status

Accepted.

## Context

The Signal Analyzer needs six Button actions in one portable presentation
across dynamic and static macOS, Raspberry Pi/Linux, and nRF52840 profiles.
ADR-013 established fail-closed presentation provenance, bounded pointer
sequencing, identity-generation capture, and current-state validation, but it
also required every committed action record to retain a callable payload.

SPIKE-007 showed that directly retaining an escaping captured closure keeps an
allocator path in the nRF52840 image. It demonstrated a manually constructed
finite tagged callable, but did not demonstrate any compiler, macro, or source
generation boundary capable of transforming ordinary closure syntax into that
representation. RFC-011 therefore approved a different portable meaning for
Button actions: a bounded typed application-action value dispatched by one
statically known handler to the current observable root model.

The replacement must preserve ADR-013's valid relationship between physical
presentation, pointer capture, current control state, and at-most-once action
admission. It must also compose with ADR-024's atomic observable-model
replacement and ADR-025's synchronous model-owned change reporting without
allowing a press begun against one model to acquire a replacement model as its
target.

## Decision Boundary

This record extracts RFC-011's single decision cluster and supersedes ADR-013
as one complete authority. It owns:

- normalized presentation-coupled input admission and bounded pointer
  sequencing inherited from ADR-013;
- the portable representation and ownership of a Button action;
- binding a committed action to an observable-model registration generation;
- handler placement and synchronous mutation-phase dispatch; and
- cancellation when an action binding or model target changes.

It does not define exact Swift declarations, action-code and generation widths,
table capacities, error types, storage layout, or migration spellings. Those
are Specification concerns. Device sampling and calibration, target-specific
physical-presentation eligibility, multiple action domains, nested model
targets, and public action scoping remain outside this decision.

## Decision

Input normalization MUST be a backend-neutral sibling integration seam feeding
runtime admission, not part of the render backend SPI. Presentation-coupled
events MUST carry the eligible physical-presentation revision against which
they were sampled. The target-local gate and runtime admission MUST each
validate that provenance and MUST drop, never retarget or defer, an event whose
eligibility is stale, unavailable, unknown, or no longer authoritative.

A dropped, malformed, out-of-order, or capacity-refused pointer phase MUST
cancel the affected bounded source sequence. Later phases from that sequence
MUST NOT admit an action. Pointer down MAY capture only the enabled stable
semantic action identity and its committed action generation. It MUST NOT
capture or retain an application-action value, handler, callable, model
reference, target generation, declaration, view, or hit record. Release MUST
revalidate the same identity-generation pair, current hit, and current enabled
state before action admission.

Portable Button declarations MUST carry values from one finite typed
application-action domain. The portable MVP action path MUST NOT retain or
synthesize an arbitrary escaping closure. Its committed bound action record
MUST associate stable semantic identity with:

- a finite non-aliasing action generation;
- current effective enabled state and committed hit geometry/order;
- one bounded application-action value; and
- the opaque registration generation of the observable-model target to which
  that value was bound.

The bound record MUST contain no callable, handler reference, model reference,
application object, existential, backend value, or platform value. The target
generation MUST be used only as runtime-local lifetime provenance; it MUST NOT
be a public identity, persisted value, state payload, or pointer-capture field.

The assembled runtime MUST contain one immutable, statically known action
domain and handler bound to the Signal Analyzer's one structurally owned root
observable-model location. The runtime coordinator is the first owner allowed
to join a successfully derived Interaction candidate with the current
observable-model registration generation. `GiftUIInteraction` and
`GiftUIObservableState` MUST remain focused owners and MUST NOT import each
other to perform this join. Backends, input integrations, drivers, and
diagnostics MUST NOT resolve or invoke application actions.

Installing a changed application-action value, target generation, or other
changed binding at the same semantic identity is action-record replacement and
MUST install a fresh action generation. An implementation MAY preserve the
generation only by preserving the exact formerly committed complete bound
record. It MUST NOT compare closures, handlers, models, or action behavior to
infer equivalence. An aborted or refused candidate MUST leave the formerly
committed bound record and generations unchanged. Generation exhaustion or
ambiguous reuse MUST fail closed and MUST NOT alias a captured or admitted
identity-generation pair.

If the captured action generation no longer matches at release, activation
MUST be cancelled. Replacing or removing the root observable model MUST change
or remove its non-aliasing registration generation; the next successful action
candidate MUST therefore replace the bound action record and advance its
action generation. A press captured against the former model MUST invoke
neither the former nor replacement model. A staged or failed model replacement
that does not commit MUST preserve the former target and bound record.

Each admitted application action MUST execute at most once, synchronously, in
SPEC-009's serialized mutation phase and in admitted semantic-action order.
Immediately before dispatch, the runtime coordinator MUST revalidate semantic
identity, action generation, enabled state, and target generation. Any mismatch
MUST cancel dispatch. On success, the coordinator MUST borrow the currently
installed model for that exact target generation and call the statically known
handler. The handler MUST NOT own, retain, register, replace, or escape the
model. Any observable mutation MUST synchronously use ADR-025's model-owned
change-report seam before the handler returns.

Core MUST own the committed hit map and bounded pointer sequencing separately
from render payloads. The common MVP path MUST NOT retain historical hit maps
or a deferred-input queue.

Static realization MUST store and dispatch only bounded typed values and
generations and MUST require no heap allocation, reflection, runtime type
discovery, arbitrary existential registry, or opaque closure-to-tag synthesis.
Dynamic realization MAY use different bounded mechanics while preserving the
same portable action, ordering, replacement, cancellation, failure, model
change, and publication transcripts. Optional callback syntax MAY exist in a
dynamic-only convenience surface, but MUST NOT define or alter the portable
MVP action contract.

## Rationale

Finite action values make the portable representation explicit in ordinary
Swift source and give static profiles a demonstrated fixed-storage route
without requiring unproven closure transformation infrastructure. Keeping the
handler at target composition preserves one portable Button meaning while
allowing static specialization and dynamic implementation freedom.

Binding the value to the current model registration generation preserves the
user's action target across model lifetime changes. Treating replacement as a
new action generation retains ADR-013's conservative identity-generation
safety: an old press cannot invoke obsolete behavior or acquire a newly
installed model. Final target revalidation also closes the interval between
release admission and mutation-phase dispatch.

The coordinator join preserves focused module ownership. Interaction can own
hit testing and gesture state without observing models, Observable State can
own model lifetime without knowing application actions, and backends remain
unable to invoke application behavior.

## Consequences

### Positive

- One finite typed Button action surface is portable across all MVP profiles.
- Committed records and pointer captures retain no closure or model reference.
- Static action storage and dispatch are finite, allocation-free, and
  specialization-friendly.
- An in-flight press cannot move from a former model to its replacement.
- Existing presentation provenance, bounded sequencing, current-state checks,
  at-most-once mutation, and backend isolation remain intact.

### Negative

- Portable Button syntax is less callback-oriented than SwiftUI and may require
  a qualified action enum case.
- Target assembly must supply one concrete action domain, handler, and root
  observable-model binding.
- Every complete bound-record comparison and storage contract must include an
  opaque target generation.
- Conservative model or action replacement can cancel a press even when the
  application regards old and new behavior as equivalent.
- Dynamic callback conveniences cannot be assumed by portable applications.

### Follow-up

- Keep ADR-013 preserved as superseded history and use ADR-033 for current
  architecture summaries and authoritative Specification relationships.
- Review and explicitly approve revised SPEC-011's bounded action,
  target-binding, replacement, dispatch, failure, and test contracts after its
  prerequisite Specifications are authoritative.
- Complete renewed review and approval of SPEC-006 and SPEC-009 after their
  callable-payload clauses were replaced with ADR-033 semantics.
- Complete review of the updated SPEC-001 and SPEC-010 action/model integration
  contracts through their normal approval gates.
- Measure static fixed storage, stack, flash, RAM, direct dispatch, and
  forbidden-symbol absence on nRF52840 and ARMv6; connected interaction
  evidence remains an implementation-conformance gate.

## Deferred and Follow-up Work

- [FW-021](../future-work/fw-021-scoped-action-domains.md) preserves multiple
  or nested action domains, independently replaced model targets, child action
  transformation, and reusable feature routing. None is required by the
  Signal Analyzer's single root model and finite action domain.

## Rejected Alternatives

### Portable escaping closures plus generated callable unions

Rejected because the required compiler, macro, or source-generation boundary
has not been established. SPIKE-007 proved only a manually constructed tagged
representation and showed that direct captured-closure retention keeps an
allocator path on nRF52840.

### Stable untyped action identifiers and a runtime handler registry

Rejected because collision, registration, missing-handler, and payload rules
would move into client code and weaken compile-time action-domain checking.

### Restricted function pointers with bounded context

Rejected for the portable declarative surface because they expose storage and
lifetime mechanics to clients and complicate heterogeneous representation.

### Retain the initializer-time model in the handler or action record

Rejected because it duplicates observable-state lifetime ownership and may
invoke or keep alive a model after replacement or published removal.

### Resolve whichever model is current at release or dispatch

Rejected because a press begun against one model could silently acquire a
replacement model as its target.

### Capture the action value, callable, or model on pointer down

Rejected because pointer capture would extend obsolete action or model
lifetime and bypass committed current-state revalidation.

### Resolve only stable semantic identity on release

Rejected because replacement at the same identity could give an existing press
new behavior that was not committed when the press began.

### Retain historical hit maps or defer stale input

Rejected for the common MVP path because it adds multi-revision storage and can
reinterpret an old coordinate or action against a different presentation.

## References

- [RFC-011: Bounded Application Actions and Model-Target Dispatch](../rfcs/rfc-011-bounded-application-actions.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [ADR-013: Provenance-Validated Presentation-Coupled Input](adr-013-provenance-validated-input-admission.md)
- [ADR-024: Structurally Owned Observable Reference State](adr-024-structurally-owned-observable-reference-state.md)
- [ADR-025: Coarse Model-Owned Observable Invalidation](adr-025-coarse-model-owned-observable-invalidation.md)
- [ADR-026: Profile-Equivalent Bounded Observable State Realization](adr-026-profile-equivalent-bounded-observable-state.md)
- [SPIKE-007: Static Action Storage Feasibility](../spikes/spike-007-static-action-storage-feasibility.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
