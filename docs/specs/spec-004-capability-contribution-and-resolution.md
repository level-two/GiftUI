---
id: SPEC-004
feature: capability-system
title: Capability Contribution and Resolution
status: draft
authors:
  - codex
created: 2026-08-22
updated: 2026-08-22
proposal:
  - PROPOSAL-004
related_rfcs:
  - RFC-002
  - RFC-005
  - RFC-006
related_adrs:
  - ADR-017
  - ADR-018
  - ADR-019
  - ADR-020
related_specs:
  - SPEC-002
  - SPEC-003
related_future_work:
  - FW-006
  - FW-007
  - FW-008
  - FW-014
  - FW-015
  - FW-018
related_explorations: []
related_spikes:
  - SPIKE-001
  - SPIKE-002
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-004: Capability Contribution and Resolution

## Summary

This Specification defines the Wave 1 contract for typed capability
contributions, deterministic bounded host resolution, immutable effective
results, and the single MVP `rasterPresentation` capability family. It owns
capability contribution and resolution vocabulary. It references portable
value semantics owned by SPEC-002 and failure, outcome, and containment
vocabulary owned by SPEC-003; it does not redefine either set of concepts or
import their modules into the capability foundation.

The contract has an independent acceptance seam: normalized fixtures invoke a
pure resolver without a runtime or backend implementation, compare results
across every contribution order, exercise absence and incompatibility, and
prove that the static path performs no heap allocation.

## Scope

This Specification covers:

- the foundational `GiftUICapabilities` module and its import boundary;
- typed, contributor-owned inputs gathered by a target host;
- required and optional capability requirements and explicit absence
  behavior;
- deterministic initialization-time resolution into an immutable snapshot or
  stable validation failure;
- the exact MVP catalogue boundary of one family, `rasterPresentation`;
- the semantic fields and compatibility checks required by that family;
- equivalent normalized results for dynamic and static profiles; and
- hardware-free fixture, dependency, bounded-resource, and zero-allocation
  evidence.

The contract applies to the macOS dynamic, macOS static, Raspberry Pi 1/Linux
dynamic with PiScreen, and nRF52840 static with TFT MVP configurations. It
specifies capability semantics and their host-facing seams, not the concrete
backend, display, runtime, or board integrations that supply those seams.

## Goals

- Give every capability input, result, constraint, and absence case one
  unambiguous owner and meaning.
- Resolve the same effective result from the same normalized inputs regardless
  of contribution, discovery, or iteration order.
- Reject missing or incompatible required presentation behavior before the
  first run cycle.
- Keep the static contribution, resolution, result-construction, storage, and
  access path allocator-independent and explicitly bounded.
- Allow materially different full-surface and tiled realizations to satisfy
  one `rasterPresentation` semantic promise without exposing target identity.
- Keep operational health and failure disposition outside mutable capability
  state.

## Non-goals

- A general Trait system, string-keyed registry, open heterogeneous catalogue,
  universal capability lattice, plugin discovery mechanism, or service
  locator.
- Capability families other than `rasterPresentation` for MVP.
- Treating runtime profile, selected components, ordinary display
  configuration, input presence, observable state, backpressure, or device
  health as capability families.
- Defining portable geometry, scalar, encoding-storage, or other cross-module
  value semantics owned by SPEC-002.
- Defining cross-layer outcome, containment, failure-disposition, or
  diagnostic semantics owned by SPEC-003.
- Defining render operations, frame handoff, rasterization, display transfer,
  target-host assembly, or runtime startup beyond their capability-facing
  input and result seams.
- Live mutation, renegotiation, or replacement of a capability snapshot after
  runtime construction; live surface reconfiguration remains FW-018.
- A replayable or retained GiftUI operation-stream lifetime.
- A stable serialized snapshot, binary ABI, public portable-view query API, or
  concrete target/backend/device identifiers in capability values.

## Dependencies

- PROPOSAL-004 is accepted, RFC-006 is approved, and ADR-017 through ADR-020
  are accepted.
- SPEC-002 owns portable values and import rules. Because ADR-019 forbids
  `GiftUICapabilities` from importing `GiftUI`, component-local adapters map
  SPEC-002-owned concrete values into the closed capability-specific
  vocabulary. The mapping must preserve their approved meaning and bounds
  without making capability records a competing public geometry contract.
- SPEC-003 owns the bounded failure/outcome and containment vocabulary through
  which a host reports resolution failure. SPEC-004 owns the capability-domain
  reason carried by that vocabulary, not the enclosing outcome semantics.
- RFC-002 B2 structural validation and this Specification's capability
  resolution are distinct, conjunctive startup gates. Neither substitutes for
  the other.
- ADR-010 owns the synchronous one-shot operation handoff and borrowed-stream
  lifetime that `rasterPresentation` checks for compatibility.
- The four MVP configurations and the Signal Analyzer render vocabulary in
  `docs/MVP_SCOPE.md` bound the catalogue and fixture set.
- SPIKE-001 and SPIKE-002 are feasibility evidence only. They do not define
  production types, storage layouts, or budgets.

## Related ADRs

- ADR-017 requires separate structural-selection, immutable semantic
  capability, explicit policy/configuration, and mutable operational-state
  planes. This Specification therefore freezes the effective snapshot before
  the first run cycle and excludes runtime health mutation.
- ADR-018 requires fixture-justified, typed, domain-specific requirements,
  owned contributions, quantitative constraints, and explicit absence
  behavior. This Specification therefore admits no second MVP family and no
  target-identity or Boolean-bag shortcut.
- ADR-019 places capability vocabulary and pure resolution in the foundational
  `GiftUICapabilities` module and requires deterministic, bounded,
  allocator-independent static resolution at the target-host composition
  point.
- ADR-020 defines the single composite `rasterPresentation` family, its four
  contributor boundaries, compatibility dimensions, semantic promise, and
  stable unavailable result. This Specification elaborates only those
  accepted fields and checks.

## Terminology

- **Capability family:** A fixture-justified typed domain whose requirement,
  contributions, resolution rule, effective result, and unavailability
  reasons are owned by `GiftUICapabilities`.
- **Requirement:** The semantic behavior and quantitative bounds that an
  assembled stack must provide. A requirement declares whether absence is
  required or optional and the behavior for optional absence.
- **Contribution:** An immutable typed record containing only facts owned by
  one contributor boundary. A contribution never asserts end-to-end support.
- **Contributor role:** One of render producer, raster/backend adapter,
  surface/display adapter, or target-host resource policy for
  `rasterPresentation`.
- **Policy:** Explicit host input that selects only among otherwise conforming
  realizations. Policy cannot create support or weaken a requirement.
- **Resolution:** A pure, deterministic intersection and validation of a
  requirement, typed contributions, structural facts needed by the family,
  and policy.
- **Effective result:** The immutable capability-level realization properties
  and bounds produced by successful resolution. It contains no concrete
  target, backend, driver, or device identity.
- **Unavailable reason:** A stable capability-domain explanation that no
  conforming result exists. Its enclosing failure/outcome representation is
  owned by SPEC-003.
- **Capability snapshot:** The immutable collection of effective results for
  one assembled runtime. For MVP it contains at most the one admitted family.
- **Operational state:** Mutable health, backpressure, disconnection, or
  runtime failure after configuration. It is not a contribution and cannot
  mutate a snapshot.

Concrete portable extents and checked quantities have the semantics and
visibility established by SPEC-002. Where the closed capability vocabulary
needs the corresponding fact, a local adapter validates and maps that value
into a capability-specific bounded record; `GiftUICapabilities` does not
import or re-export the SPEC-002 type.

## Public Contract

Portable application and Presentation code MUST NOT need to import
`GiftUICapabilities`, branch on a target/backend/device identity, or query a
global capability registry to express the Signal Analyzer. `GiftUI` MUST NOT
re-export `GiftUICapabilities`.

A configuration that declares `rasterPresentation` required is eligible to
start only when resolution returns an effective result satisfying the entire
requirement. Optional absence, if used by a later approved host contract, MUST
remain explicit and MUST NOT be presented as support. The same normalized
inputs and policy MUST expose equivalent semantic results and absence reasons
in static and dynamic profiles.

Capability declarations are immutable for the lifetime of the assembled
runtime. A changed component graph, required extent, orientation, semantic
requirement, or capability declaration requires construction and validation
of a new runtime. Backpressure, refusal, disconnection, and post-handoff
failure use SPEC-003-owned outcome/failure vocabulary and MUST NOT alter the
snapshot.

## Module Contract

`GiftUICapabilities` exclusively owns:

- capability requirement, contribution, policy-input, effective-result,
  snapshot, and unavailability-reason vocabulary;
- pure family-specific resolution rules; and
- the `rasterPresentation` catalogue entry.

`GiftUICapabilities` MUST NOT import `GiftUI`, semantic, layout, render,
execution, failure, runtime, backend, platform, driver, OS/RTOS, HAL, or
concrete integration modules. Component-local adapters, not the foundational
module, MUST translate SPEC-002-owned values into the closed capability-
specific representation while preserving their meaning. Its pure resolver
returns a capability-domain effective-or-unavailable result; the target host
maps that result into SPEC-003-owned outcome vocabulary outside the
foundational module rather than recreating or importing failure concepts.

Contributor adapters MAY depend on their own component contract and
`GiftUICapabilities`; a component contract may expose SPEC-002-owned values
where its already-approved import direction permits that dependency. Each
adapter translates local facts into the closed capability vocabulary without
placing concrete types or identities in the contribution. Contributors MUST
NOT import a higher consumer or another concrete contributor merely to form a
contribution.

The target host is the composition root. It gathers typed inputs, supplies
policy, owns resolver workspace and snapshot storage, invokes resolution once
during bounded initialization, and passes the immutable effective result only
to approved consumers. Validation tooling may format or symbolize results but
has no resolution or semantic authority.

SPEC-004 MUST NOT duplicate portable-value definitions from SPEC-002 or the
failure/outcome and containment definitions from SPEC-003. Changes at either
shared boundary require reciprocal review of all three Wave 1 Specifications.

## Types / APIs

The following are normative semantic type seams. Concrete Swift spelling,
generic parameters, access-control declarations, and storage layout remain
open until SPEC-002 and SPEC-003 stabilize their referenced semantics and
host-side mappings; a draft MUST NOT invent a competing public value or
failure contract.

### Family-neutral seams

- A typed capability requirement carries its family identity, required versus
  optional status, and family-specific semantic and quantitative requirements.
- A contribution carries exactly one contributor role and only that role's
  family-specific facts.
- Explicit host policy carries resource limits and preferences among
  conforming paths; it cannot downgrade a requirement.
- Resolution consumes immutable requirement, contributions, policy, and
  caller-owned workspace and returns a capability-domain result containing
  exactly one of:
  - an immutable effective family result; or
  - a stable capability-domain unavailable reason.
- At the host boundary, an adapter maps an unavailable result into the
  enclosing outcome vocabulary owned by SPEC-003 without changing the typed
  reason, containment, or outcome semantics.
- A capability snapshot stores at most one effective result for each admitted
  family and permits read-only access without invoking resolution.

### `rasterPresentation` requirement

The requirement contains closed capability-specific values mapped from
SPEC-002-owned portable values where applicable:

- required normalized operation coverage for opaque rectangles, positioned
  text, straight-line strokes, clipping, and damage semantics;
- required logical surface extent;
- required conformance to ADR-010's synchronous borrowed one-shot stream;
- canonical pixel-encoding compatibility requirement;
- acceptable downstream submission-lifetime forms;
- maximum permitted raster workspace, payload storage, and in-flight storage;
  and
- required or optional absence behavior.

### Contributor records

- The render-producer contribution contains the required operation-set
  identity and one-shot stream conformance, and contains no pixel format,
  device identity, or presentation policy.
- The raster/backend contribution contains operation coverage, common-stream
  consumption support, producible canonical pixel encodings, produced-buffer
  lifetime forms, supported extent bounds, and required raster/payload
  workspace.
- The surface/display contribution contains logical extent, accepted canonical
  pixel encodings, bounded region/row constraints, accepted submission
  lifetime and handoff forms, and bounded in-flight requirements.
- The host resource-policy input contains allowed storage and in-flight bounds
  plus deterministic preference among otherwise conforming paths; it contains
  no fabricated support fact.

### Effective result and unavailable reasons

The effective result contains the satisfied semantic coverage, resolved
logical extent, selected canonical pixel encoding, compatible submission
lifetime, capability-level realization kind (bounded full surface or bounded
tiled presentation), and all selected raster, payload, and in-flight bounds.
It MUST NOT contain concrete contributor identities.

The closed unavailable-reason vocabulary MUST distinguish at least:

- missing or duplicate contributor role;
- malformed or out-of-range contribution;
- required operation-set or one-shot-stream incompatibility;
- unsupported or overflowing logical extent;
- no common canonical pixel encoding;
- incompatible downstream submission lifetime;
- insufficient raster, payload, in-flight, or resolver-workspace capacity; and
- policy with no conforming realization.

Exact case spelling and payload width remain an open contract detail, but
implementations and tests MUST preserve these distinctions. Diagnostic text is
non-authoritative and cannot replace the typed reason.

## Behavior

The resolver MUST be pure with respect to runtime and contributor state. For
equal normalized requirements, contributions, policy, and declared capacities,
it MUST return an equal effective result or equal unavailable reason.

Resolution MUST:

1. validate that every required contributor role is present exactly once and
   every input value is well formed, with extent and capacity mappings
   preserving SPEC-002 checked-value meaning;
2. validate operation coverage and the ADR-010 one-shot-stream contract;
3. validate the required logical extent against raster and surface limits;
4. compute a non-empty intersection of canonical pixel encodings;
5. prove producer storage and downstream submission-lifetime compatibility
   within the in-flight bound;
6. validate raster workspace, payload, in-flight, and resolver-workspace
   capacities against host policy;
7. apply deterministic policy only to the remaining conforming realizations;
   and
8. construct one immutable effective result or one stable unavailable reason.

The output MUST be independent of input ordering. Implementations MAY
canonicalize inputs or use role-addressed storage, but ordering cannot be a
tie-breaker. A duplicate, missing, malformed, or exhausted input MUST fail
deterministically and MUST NOT be ignored, partially accepted, or replaced by
the last observed value.

Lack of a common pixel encoding and incompatible submission lifetime MUST each
produce their own stable unavailable reason. Neither may be hidden as
effective-result metadata. All first-party tiled fixtures MUST consume the
borrowed GiftUI operation stream once and MUST NOT retain or replay it after
the synchronous offer returns; only backend-owned derived pixel, tile,
transfer, or device data may remain.

Resolution MUST occur during host composition or bounded initialization, never
during portable view evaluation, per-frame processing, or per-pixel work.
Snapshot access MUST NOT rerun the resolver.

## State / Lifecycle

For one assembled runtime, capability state follows this lifecycle:

1. The host selects an immutable component graph and initializes the selected
   components sufficiently to obtain owned facts.
2. The host constructs the requirement, four role-specific inputs, policy,
   fixed capacities, caller-owned resolver workspace, and result storage.
3. RFC-002 B2 structural validation and capability resolution both complete
   before the first run cycle. Their order may be host-defined, but runtime
   start requires both successes and neither result substitutes for the other.
4. Successful resolution freezes the effective snapshot. Failed resolution
   leaves no partially usable snapshot and prevents runtime start for a
   required family.
5. Approved consumers receive read-only effective values for the runtime
   lifetime.
6. Teardown releases host-owned storage only after all approved consumers are
   torn down. No consumer may outlive or mutate the snapshot.

Re-resolving into an active snapshot, changing contributor facts in place, or
using operational state to rewrite an effective value is illegal. A material
change requires teardown and construction of a new runtime. The exact host
assembly API and startup sequencing across all features belong to the later
HOST-CONFIGURATION Specification.

## Capability Requirements

The MVP catalogue MUST contain exactly `rasterPresentation`; adding a second
family or field requires a separately accepted fixture-backed architectural
change when it is not already entailed by ADR-017 through ADR-020.

Every field MUST map to at least one assertion in a Signal Analyzer or one of
the four supported-configuration fixtures. A field without such evidence MUST
be removed from the MVP catalogue or routed through deferred work.

The macOS dynamic and static fixtures MUST resolve the same semantic coverage,
although their conforming realization and storage mechanisms may differ. The
Raspberry Pi fixture MUST support the 240 x 240 PiScreen case through a bounded
RGB565 tiled realization compatible with its Linux framebuffer path. The
nRF52840 fixture MUST support the 480 x 320 TFT path using no full framebuffer,
with a tile no larger than 480 x 4 x 2 bytes (3,840 bytes) and compatible
synchronous borrowed submission. A full-surface RGBA realization for the
nRF52840 fixture MUST resolve unavailable.

Missing required behavior prevents runtime start. Optional absence, where an
approved consumer permits it, remains an explicit absence and cannot silently
select a semantically weaker path.

## Backend Requirements

No concrete backend is required to run the pure resolver conformance suite.
Backend, render-producer, and surface/display implementations MUST expose
their facts through local adapters that construct only their owned
contribution records. They MUST NOT probe another concrete component or claim
end-to-end support.

All first-party MVP raster paths, including RGB565 tiled paths, MUST accept the
same ADR-010 synchronous borrowed one-shot operation stream. Before the offer
returns, a backend MUST synchronously consume the stream and complete or
reserve all backend-owned derived work. After return it may retain only its
own derived data and the operational state governed outside this
Specification.

Platform and connected-hardware checks are later conformance evidence. They
MUST NOT replace normalized host fixtures, dependency tests, or static
resource/zero-allocation tests for this contract.

## Error Handling

Capability incompatibility is a deterministic initialization validation
failure, not mutable runtime health. SPEC-004 owns the closed capability-domain
unavailable reason. Outside `GiftUICapabilities`, the target-host adapter maps
that reason into the enclosing bounded outcome; SPEC-003 owns that outcome,
propagation, containment, policy-disposition, and diagnostic behavior.

Resolution MUST fail closed for missing, duplicate, malformed, out-of-range,
incompatible, or capacity-exhausted input. It MUST NOT trap, allocate an
unbounded recovery structure, select a weakened realization, expose a partial
snapshot, or depend on diagnostic delivery.

When several incompatibilities exist, the resolver MUST choose one stable
primary reason by a documented family-specific validation precedence that is
independent of contribution order. Additional observations may be projected
only through SPEC-003-owned bounded secondary/diagnostic mechanisms and MUST
NOT replace or change the primary reason. The precise precedence is an open
draft detail required before review.

Runtime refusal, backpressure, disconnection, transport error, and post-handoff
device failure are operational outcomes. They MUST follow SPEC-003 and their
own governing contracts without mutating the capability snapshot.

## Performance Requirements

- Resolution MUST execute once during bounded initialization and MUST NOT run
  in view evaluation, per-frame, or per-pixel paths.
- Resolver work MUST have a statically derivable finite upper bound from the
  closed family, four contributor roles, encoding/lifetime alternatives, and
  caller-declared capacities. Tests MUST report the measured operation count
  for success and worst negative paths.
- Steady-state effective-result access MUST be bounded direct lookup and MUST
  invoke the resolver zero times.
- On the static path, contribution construction, resolution,
  validation-result construction, snapshot storage, and steady-state access
  MUST perform zero heap allocations.
- nRF52840 evidence MUST report incremental linked RAM, worst-case resolver
  stack, linked flash, initialization work, named capability storage, and
  default display staging separately. Total linked RAM MUST remain at or below
  192 KiB, default display staging at or below 16 KiB, and firmware within the
  1 MiB device flash; crossing the 896 KiB warning threshold requires explicit
  review evidence.
- Exact production record widths and capability-specific incremental resource
  budgets remain open before review. SPIKE-002's 128-byte linked-RAM,
  1,104-byte flash, 80-byte named-storage, 72-byte conservative stack, and
  14-operation measurements are feasibility baselines, not normative maxima.

## Compatibility

- Static and dynamic profiles MAY use distinct storage and specialization but
  MUST produce equivalent normalized semantic results, absence behavior, and
  stable reasons.
- Portable Signal Analyzer declarations MUST remain source-compatible and
  substantially shared across all four configurations; they gain no
  target/backend/device branches from this contract.
- `GiftUICapabilities` is not re-exported by `GiftUI`, and no concrete
  contributor type crosses into portable Presentation.
- No serialized capability format, stable ABI, plugin protocol, or migration
  guarantee for legacy proof-of-concept flags is established.
- Existing flags and concrete-type probes are migration evidence only. They
  MUST be classified and replaced at approved boundaries rather than treated
  as compatibility authority.
- Any later change to operation-stream or submission-lifetime meaning requires
  reconciliation with its governing ADRs and this Specification before use.

## Testing Requirements

The contract suite MUST include:

- pure resolver fixtures for macOS dynamic, macOS static, Raspberry Pi
  1/Linux with PiScreen, and nRF52840 with TFT;
- every permutation of the four contributor-role inputs for each positive and
  representative negative fixture, proving equal results independent of
  order;
- missing, duplicate, malformed, out-of-range, optional-absence, required-
  absence, and resolver-workspace exhaustion cases;
- independent negative/control pairs for operation-set mismatch, one-shot
  incompatibility, extent overflow, no common pixel encoding, incompatible
  submission lifetime, insufficient raster/payload storage, and in-flight
  bound violation;
- policy permutations proving policy chooses only among conforming results and
  cannot manufacture support;
- cross-profile comparison of normalized static and dynamic results;
- dependency-graph tests proving the `GiftUICapabilities` import boundary,
  `GiftUI` non-re-export, and absence of concrete identity in portable code;
- static allocation instrumentation or an allocator-free linked fixture that
  fails any allocation attempt across the complete capability-system path;
- steady-state tests proving snapshot access performs no resolver invocation;
- bounded resource evidence reporting linked RAM, named storage, stack, flash,
  initialization work, and staging independently; and
- one-shot tiled-stream tests proving exact-once synchronous consumption and
  no retained or replayed operation stream after offer return.

Host, cross-build, simulator, and connected-hardware evidence MUST be labeled
separately. A successful build or simulator test is not connected-board
evidence.

## Acceptance Criteria

- [ ] The document and manifest identify SPEC-004 as a `draft` for
  `capability-system`, link PROPOSAL-004, RFC-006, ADR-017 through ADR-020, and
  reciprocally relate SPEC-002 and SPEC-003.
- [ ] A dependency test proves `GiftUICapabilities` imports none of the
  prohibited higher or concrete modules, `GiftUI` does not re-export it, and a
  portable Signal Analyzer presentation contains zero target/backend/device
  identity checks.
- [ ] The implemented MVP catalogue contains exactly one family named
  `rasterPresentation`, and every field maps to at least one named assertion
  in the four normalized fixtures.
- [ ] All 24 permutations of the four contributor roles produce byte-for-byte
  or value-equal effective results for each positive fixture and the same
  stable primary unavailable reason for each representative negative fixture.
- [ ] Missing, duplicate, malformed, optional-absence, required-absence, and
  workspace-exhaustion fixtures complete without traps, partial snapshots, or
  order-dependent results.
- [ ] No-common-encoding and incompatible-submission-lifetime negative/control
  pairs resolve independently to distinct stable unavailable reasons.
- [ ] The macOS dynamic and static fixtures expose equal semantic coverage;
  the Raspberry Pi 240 x 240 fixture resolves to a bounded RGB565 tiled path;
  the nRF52840 480 x 320 fixture resolves with a tile no larger than 3,840
  bytes; and nRF52840 full-surface RGBA resolves unavailable.
- [ ] Allocation instrumentation reports zero heap allocations for the static
  path from contribution construction through resolution, validation-result
  construction, snapshot storage, and repeated steady-state access.
- [ ] Repeated steady-state snapshot access invokes the resolver zero times,
  and measured success and worst-negative initialization work remain within
  the statically documented operation bound.
- [ ] nRF52840 resource evidence reports incremental and total linked RAM,
  worst-case resolver stack, linked flash, named capability storage, and
  display staging; totals satisfy 192 KiB linked RAM, 16 KiB default staging,
  and 1 MiB flash limits, with explicit review if flash exceeds 896 KiB.
- [ ] Every first-party tiled fixture consumes the borrowed operation stream
  exactly once synchronously and retains or replays zero GiftUI operations
  after the offer returns.
- [ ] Fault-injection tests prove runtime backpressure, refusal,
  disconnection, and post-handoff failure leave the effective snapshot
  unchanged and are expressed only through SPEC-003-owned outcome/failure
  seams.
- [ ] Structural-validation-negative fixtures fail RFC-002 B2 independently
  of capability resolution, and capability-negative fixtures fail resolution
  independently of an otherwise valid B2 graph; runtime start occurs only
  when both gates succeed.

## Implementation Notes

This section is non-authoritative. A role-addressed fixed record or canonical
sort can make order independence straightforward. Reuse the normalized inputs
from SPIKE-001 and the measurement harness shape from SPIKE-002, but do not
copy their disposable layouts into production by implication.

Keep capability-domain records compact and move human-readable names and
expanded reports to host tooling where possible. Representation reduction is
the first remedy if measurements are too costly, provided all normative
semantics and normalized results remain unchanged.

## Open Issues

- Stabilize the host-side mapping from SPEC-002 checked extents, capacities,
  and other portable values into the closed capability representation. The
  mapping must preserve meaning without adding a `GiftUICapabilities ->
  GiftUI` import or exposing a competing public geometry type.
- Stabilize the exact SPEC-003 outcome carrier used for initialization
  validation and operational failures; SPEC-004 must supply only its typed
  capability-domain reason.
- Choose exact Swift names, access levels, generic/static representation, and
  record layouts for the semantic seams listed above without introducing a
  new architectural choice.
- Define the complete typed unavailable-reason cases, bounded payloads, and
  deterministic primary-reason precedence required before review.
- Set production contribution counts, alternate-value capacities, resolver
  workspace size, record widths, and capability-specific incremental RAM,
  stack, flash, and initialization-work budgets using implementation evidence.
- Identify the later HOST-CONFIGURATION contract that will own the concrete
  conjunction and sequencing of B2 structural validation and capability
  resolution.

If any issue requires a new capability family, mutable snapshot, new
operation-payload lifetime, target-local resolution, upward import, or changed
failure ownership, SPEC-004 must pause and route that choice through RFC/ADR
review.

## Deferred and Follow-up Work

- [FW-006](../future-work/fw-006-generated-target-configuration.md) preserves
  generated target composition.
- [FW-007](../future-work/fw-007-cost-aware-capability-planning.md) preserves a
  generalized measured realization planner.
- [FW-008](../future-work/fw-008-generalized-component-traits.md) preserves a
  general Trait subsystem.
- [FW-014](../future-work/fw-014-replayable-operation-delivery.md) preserves a
  possible future replayable operation contract.
- [FW-015](../future-work/fw-015-capability-resolver-input-minimization.md)
  preserves later input reduction under explicit compatibility evidence.
- [FW-018](../future-work/fw-018-live-surface-reconfiguration.md) preserves
  live extent/orientation reconfiguration and snapshot replacement.

None of these items changes MVP scope, this contract, or its acceptance
criteria.

## References

- [PROPOSAL-004: GiftUI Capability System](../proposals/proposal-004-capability-system.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [ADR-017: Capability and Operational-State Decision Planes](../adrs/adr-017-capability-and-operational-state-planes.md)
- [ADR-018: Fixture-Driven Typed Capability Model](../adrs/adr-018-fixture-driven-typed-capabilities.md)
- [ADR-019: Bounded Target-Host Capability Resolution](../adrs/adr-019-bounded-host-capability-resolution.md)
- [ADR-020: Composite Raster Presentation Capability](../adrs/adr-020-raster-presentation-capability.md)
- [SPEC-002: Portable Foundation Specification](spec-002-portable-foundation.md)
- [SPEC-003: Failure Outcomes and Containment](spec-003-failure-outcomes-and-containment.md)
- [GiftUI MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [SPIKE-001: Tiled One-Shot Stream and Capability Compatibility Fixtures](../spikes/spike-001-tiled-one-shot-capability-fixtures.md)
- [SPIKE-002: nRF52840 Capability Path Resource Evidence](../spikes/spike-002-nrf52840-capability-path-resource-evidence.md)
