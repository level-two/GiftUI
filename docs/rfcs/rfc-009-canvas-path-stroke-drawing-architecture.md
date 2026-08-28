---
id: RFC-009
feature: canvas-drawing
title: Canvas, Path, and Stroke Drawing Architecture
status: approved
authors:
  - Yauheni Lychkouski
created: 2026-08-25
updated: 2026-08-27
proposal:
  - PROPOSAL-006
related_rfcs:
  - RFC-001
  - RFC-002
  - RFC-004
  - RFC-005
  - RFC-006
related_adrs:
  - ADR-003
  - ADR-004
  - ADR-005
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-009
  - ADR-010
  - ADR-011
  - ADR-014
  - ADR-015
  - ADR-016
  - ADR-017
  - ADR-018
  - ADR-019
  - ADR-020
  - ADR-022
  - ADR-028
  - ADR-029
  - ADR-030
  - ADR-031
related_specs:
  - SPEC-001
  - SPEC-002
  - SPEC-003
  - SPEC-004
  - SPEC-006
  - SPEC-012
  - SPEC-013
  - SPEC-014
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-004
supersedes: []
superseded_by: []
target_milestone: MVP
---

# RFC-009: Canvas, Path, and Stroke Drawing Architecture

## Summary

This RFC proposes the minimal portable custom-drawing architecture required by
the Signal Analyzer: a laid-out `Canvas` invokes a synchronous, non-suspending
drawing closure with a scoped graphics context and the Canvas's resolved local
size; the context and its borrowed workspace cannot escape that invocation;
the closure constructs transient straight-line `Path` values and submits solid
opaque strokes in painter's order; GiftUI snapshots those strokes into bounded
cycle-local drawing workspace and lowers them to backend-neutral ordered render
operations.

Canvas is a semantic leaf and a render producer, not a backend escape hatch.
GiftUI owns closure invocation, checked geometry, path validation, drawing
order, stroke meaning, local-to-surface coordinate resolution, inherited clip
propagation, and pre-handoff failure. Canvas bounds do not add an implicit
clip: drawing may extend outside those bounds until an inherited ancestor clip
applies. A backend receives only validated resolved stroke operations during
ADR-010's synchronous one-shot frame offer. It never receives the client
closure, a mutable `Path`, a semantic view, captured application state, or
analyzer-domain values.

The static profile uses caller-owned fixed-capacity path and drawing-plan
workspace. The dynamic profile may use dynamically sized storage, but both
profiles preserve the same public concepts, operation order, geometry, stroke
semantics, and explicit failure categories. A Canvas plan lives only from its
cycle-stable derivation through that revision's synchronous frame offer; it is
discarded after accepted or refused handoff and is never a retained display
list or replay payload.

The proposed direction is intentionally narrow: straight subpaths created by
`move(to:)` and `addLine(to:)`, opaque RGB stroke shading, line width, and the
round caps and joins required by the analyzer. Fills, curves, images, text in
Canvas, public clipping controls, transforms, alpha, effects, animation, and a
general-purpose graphics state remain outside this RFC.

## Context

[PROPOSAL-006](../proposals/proposal-006-canvas-path-stroke-drawing.md)
is accepted and authorizes this RFC. The feature is required by the established
MVP scope: the portable Signal Analyzer must draw an eleven-line vertical grid,
one horizontal center line, and four data-driven digital traces on macOS
dynamic, macOS static, Raspberry Pi/Linux dynamic, and nRF52840 static stacks.

[SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md) is in
review and provides non-authoritative application-workload evidence without
defining a GiftUI drawing contract. For each channel, its current candidate
presentation begins at the retained
baseline, emits horizontal and vertical line segments for transitions in the
visible range, and extends the final level to the right edge. The maximum
five-second window receives at most 400 aggregate transitions under the
specified 80-transition-per-second input bound. With `t` transitions on one
channel, the candidate construction produces `2t + 1` segments: one horizontal
segment per interval, one vertical segment per transition, and the final
horizontal continuation. Across four channels that is at most 804 trace
segments, plus the grid's 12 segments, before any backend-specific raster work.
SPIKE-004 measured a conservative 820-segment fixture by adding one extra seed
segment per channel; that four-segment margin is feasibility evidence, not
application behavior. Exact production capacities remain downstream
Specification work and must be derived from an approved application contract,
including boundary cases and a configured safety margin. The counts above are
review evidence, not an approved application contract or production capacity.

Accepted architecture already fixes the surrounding boundaries:

- ADR-003 fixes four-channel transition storage, the 80-transition-per-second
  aggregate bound, and retained lower-bound baselines needed to reconstruct
  straight-line waveforms.
- ADR-004 fixes one substantially shared four-channel Signal Analyzer
  presentation, the 1-, 2-, and 5-second windows, and the 80-transition-per-
  second aggregate input bound while leaving Canvas contracts to this feature.
- ADR-005 keeps semantic evaluation and layout above one normalized ordered
  render-operation boundary; backends do not evaluate views or own layout.
- ADR-006 requires profile-equivalent semantics while allowing different
  storage, specialization, and dispatch strategies.
- ADR-007 keeps concrete platform, backend, display, transport, and hardware
  knowledge in target composition and integration.
- ADR-008 keeps portable Presentation on the `GiftUI` import surface and
  requires an acyclic compiler-enforced module graph.
- ADR-009 requires checked integer coordinates, dimensions, and scalar
  arithmetic for MVP layout and Canvas geometry.
- ADR-010 requires one borrowed ordered operation stream consumed exactly once
  during synchronous frame offer; a backend may retain only derived data that
  it owns after acceptance.
- ADR-011 freezes observed state during derivation, publishes only complete
  semantic revisions, and discards partial derived work after pre-publication
  failure without replaying client mutations or actions.
- ADR-014 through ADR-016 require bounded explicit outcomes, layered failure
  disposition, and non-authoritative diagnostics.
- ADR-017 separates immutable semantic capability from mutable runtime health.
- ADR-018 and ADR-019 require fixture-backed typed capability facts contributed
  by their actual owners and resolved by the host during bounded startup.
- ADR-020 requires the composite `rasterPresentation` capability to cover
  straight-line strokes, clipping, extent, one-shot lifetime, raster bounds,
  and downstream storage compatibility.
- ADR-022 provides a sibling precedent: another resolved payload crosses the
  render boundary with complete logical geometry and borrowed one-shot
  lifetime rather than giving a backend semantic authority.

Current source code proves only partial feasibility. It has `Int`-based
geometry with some checked arithmetic, RGB color storage used by current opaque
paths, ordered rectangle/text operations, dynamic display lists, direct static
emission, framebuffer realization, and bounded RGB565 tile workspaces. It has
rectangle stroking but no governed client Canvas, arbitrary straight-line Path,
canonical stroke operation, or cross-profile path storage. Legacy framework
documents and current code are evidence, not authority and do not yet conform
to approved SPEC-002 geometry or this proposed drawing contract.

## Scope and Decision Boundary

This RFC owns one independently reviewable client-to-render decision cluster:

- when a Canvas drawing closure executes relative to layout, state freeze,
  semantic publication, and frame offer;
- which owner supplies the closure's resolved local geometry;
- the ownership and lifetime of mutable Path construction and immutable stroke
  snapshots;
- how client-local path geometry becomes validated, ordered, surface-resolved
  stroke intent without exposing semantic values to a backend;
- the portable meaning of the MVP stroke subset;
- the bounded static workspace model and pre-handoff failure boundary; and
- integration with the existing normalized operation, capability, failure,
  and one-shot handoff architecture.

These concerns cannot be approved independently. Closure timing determines
which state and size are valid; path lifetime determines whether stroke
submission can be borrowed and bounded; stroke lowering determines the
backend boundary; and the storage strategy determines whether failure can be
detected before a backend acquires irreversible presentation responsibility.
Splitting those choices would create circular RFCs in which each depends on
the others for basic coherence.

Adjacent concerns remain independently owned:

- RFC-001 and SPEC-001 own analyzer waveform calculation and presentation
  requirements, not GiftUI drawing semantics.
- RFC-002 and its ADRs own the integrating layer graph, render-operation
  boundary, geometry model, and backend isolation; this RFC specializes the
  separately reserved Canvas producer at that boundary.
- RFC-004 owns cycle, publication, one-shot frame lifetime, refusal, and
  rederivation; this RFC does not create another transaction.
- RFC-005 owns shared outcome meaning, containment, policy, and diagnostics;
  this RFC identifies Canvas-specific detection points and affected scopes.
- RFC-006 and SPEC-004 own capability vocabulary and resolution; this RFC
  requires the existing `rasterPresentation` operation set to cover the
  canonical stroke operation. Canvas-plan, Path, and producer-operation
  capacities remain RFC-002 B2 structural-validation inputs; this RFC does not
  add fields to SPEC-004's closed capability vocabulary or add a client-probed
  capability.
- Downstream Specifications own exact Swift declarations, numeric capacities,
  storage layouts, operation fields, raster algorithms, default style values,
  quantization rules consistent with this RFC, and conformance vectors.
  The drawing Specification may approve a bounded capacity/configuration
  mechanism without freezing a Signal Analyzer-specific number; target-host
  configuration and eventual application conformance must apply the later
  approved application bound. This prevents the drawing and application
  Specifications from becoming circular approval prerequisites.

A separate raster-algorithm RFC is not currently justified. Multiple raster
implementations may realize the same normalized stroke semantics beneath the
existing backend boundary. If evidence later shows that an independently
significant raster ownership or payload-lifetime choice cannot fit this
boundary, it must return through lifecycle triage rather than being selected
inside a Specification.

## Requirements

1. Portable Presentation MUST express the Signal Analyzer grid and four
   traces using one Canvas/path/stroke concept across all four MVP profiles.
2. A Canvas drawing closure MUST receive its resolved local size and a
   backend-independent drawing context only after layout has resolved the
   Canvas bounds for the cycle-stable revision.
3. Closure invocation MUST be synchronous, non-suspending, and at most once
   per Canvas occurrence in one derivation attempt; preflight MUST NOT reinvoke
   client code. The Canvas declaration MAY retain its client closure from
   declarative construction until that revision's post-layout invocation,
   because post-layout size is required. It MUST release that closure no later
   than finalization of the owning cycle and MUST NOT retain it in published
   semantic state, presentation-pending intent, or a frame payload, or pass it
   below the render-producer boundary. The scoped graphics context and every
   borrowed Path/workspace view supplied for the invocation MUST NOT escape
   the invocation. None may expose concrete backend, surface, platform,
   display, transport, driver, OS/RTOS, HAL, or hardware identity.
4. The drawing closure MUST observe the same frozen application and
   environment revision as the enclosing semantic derivation. It MUST NOT be
   a mutation, action, reentrant cycle, or asynchronous-work boundary.
5. MVP Path construction MUST be scoped to an active Canvas invocation and
   support a current point, multiple open straight subpaths, `move(to:)`, and
   `addLine(to:)`. A Path MUST NOT persist across Canvas invocations or cycles,
   cross an asynchronous boundary, or own a backend resource. One live mutable
   Path has unique construction ownership; copying or aliasing its mutable
   storage is not admitted. Preconstructed retained paths, curves, and closed-
   fill semantics are not admitted by this RFC.
6. Stroke submission MUST snapshot the submitted Path's geometry. Later
   mutation or destruction of the client Path MUST NOT change an earlier
   submitted stroke.
7. Stroke submission MUST support opaque RGB shading, positive checked integer
   line width, and the round cap and round join semantics required by the
   Signal Analyzer. A line-width shorthand and an explicit stroke-style form
   MUST lower to the same canonical style meaning when their values agree.
8. Canvas closure invocations MUST follow deterministic resolved render order.
   Their stroke calls MUST preserve painter's order relative to one another and
   to surrounding normalized render operations.
9. GiftUI MUST resolve Canvas-local coordinates, inherited clip, and drawing
   order before the operation reaches a concrete backend. A backend MUST NOT
   receive a client closure, mutable Path, semantic node, or application value.
10. A normalized stroke operation MUST carry or synchronously expose every
    validated point, subpath boundary, opaque paint value, canonical style
    value, resolved origin, and resolved clip needed to realize the portable
    stroke without reconstructing semantic or layout decisions.
11. Dynamic and static realizations MUST produce equivalent normalized stroke
    records for the same accepted client input, including order, checked
    geometry, subpaths, style, clip, and failure category.
12. Static realization MUST use finite caller-owned or generated workspace and
    MUST NOT require heap allocation, reflection, `Any`, unrestricted
    existentials, exceptions, tasks, threads, or a full-frame pixel buffer.
13. Ordinary invalid geometry, invalid path state, invalid phase or scoped-
    lifetime use, arithmetic overflow, path exhaustion, drawing-plan
    exhaustion, and operation exhaustion MUST produce explicit bounded
    outcomes. They MUST NOT silently wrap, truncate, drop a stroke, substitute
    a style, or publish a partial Canvas result. A backend that passed startup
    validation but cannot realize an admitted canonical style is an invariant
    or configuration failure, not ordinary client-data failure or a permitted
    runtime fallback.
14. A pre-handoff Canvas failure MUST discard the incomplete cycle-local
    drawing plan and follow ADR-011 dirty-rederivation behavior. It MUST occur
    before the frame is offered and MUST NOT replay admitted mutations or
    client actions.
15. A backend MUST consume the complete borrowed normalized stroke payload
    during ADR-010's synchronous offer and MUST NOT retain the operation or its
    borrowed path storage after the call returns.
16. Required normalized straight-line-stroke operation coverage MUST be
    represented inside the existing composite `rasterPresentation` capability.
    RFC-002 B2 structural validation MUST separately prove the selected Canvas,
    Path, drawing-plan, and producer-operation capacities before the first run
    cycle. Portable Canvas code MUST NOT probe concrete implementations or
    silently omit required strokes when either startup gate fails.
17. The feature MUST remain sufficient for the current Signal Analyzer without
    establishing a general-purpose graphics framework.

## Constraints

- The client and normalized geometry scalar is the checked integer model
  established by ADR-009 and specified by SPEC-002.
- Colors are opaque RGB values. Alpha and blend behavior are outside scope.
- All Canvas work occurs inside RFC-004's non-suspending serialized cycle.
- The normalized stroke payload is part of ADR-010's one-shot frame stream,
  not a replayable display list or asynchronous client callback.
- A static runtime must be able to reserve all Canvas, path, operation, raster,
  payload, and downstream capacity before the corresponding irreversible
  presentation effect.
- Startup MUST preserve the accepted two-gate boundary: B2 validates Canvas,
  Path, plan, and producer-operation structure/capacity; SPEC-004 capability
  resolution validates only its closed operation, extent, encoding, raster,
  payload, in-flight, and lifetime vocabulary. Neither gate substitutes for
  the other.
- Concrete backends may use different raster algorithms and storage, but they
  may not change accepted logical geometry, operation order, clip, width,
  cap/join meaning, or opaque color.
- Canvas does not introduce analyzer-domain knowledge into GiftUI and does not
  expose GiftUI internals to the analyzer.
- Exact declarations and capacities must remain implementable by the supported
  Embedded Swift toolchain and `nrf52840dk/nrf52840` configuration.

## Proposed Design

### 1. Canvas is a laid-out semantic leaf

`Canvas` participates in the ordinary declarative hierarchy and layout
proposal process. It has no semantic children and does not expose its drawing
closure to layout. Layout resolves the Canvas bounds using the same frame,
padding, stack, and alignment contracts as other views.

The semantic node preserves the client drawing closure and captured cycle-
stable values only until the revision's post-layout Canvas derivation. This
storage is necessarily longer-lived than the Canvas initializer call; the
architecture therefore constrains invocation, context borrowing, and release
rather than incorrectly describing the stored closure itself as non-escaping.
The semantic node does not contain backend or device identity. A Canvas
contributes no hit region by itself; interaction continues to use separately
declared controls and hit-test semantics.

After layout resolves the Canvas bounds, the render producer invokes the
drawing closure synchronously with:

- a scoped graphics context owned by GiftUI; and
- a local size whose origin is conceptually `(0, 0)` and whose dimensions are
  the checked resolved Canvas dimensions.

Multiple Canvas occurrences are invoked in deterministic resolved render
order. Their plans are inserted at the corresponding position in the enclosing
painter's order; a runtime may not reorder closures merely to group storage or
backend work.

The closure is part of derivation. It is not an event callback. It may read
the same frozen values captured by the enclosing view declaration, but it may
not suspend, retain or escape the context or a workspace borrow, initiate
another cycle, dispatch an action, or mutate observed state through GiftUI.
The runtime releases the invocation closure no later than finalization of the
owning cycle; it never places the closure in committed semantic state,
presentation-pending intent, the Canvas plan, or the frame stream. Exact type-
system enforcement, invalid-phase reporting, and the treatment of arbitrary
external mutation outside GiftUI's observation contract belong to the public-
contract Specification and MUST preserve ADR-011's at-most-once effects.

### 2. Scoped construction and snapshot ownership

The graphics context owns access to one cycle-local drawing workspace. A
mutable Path is a transient client construction value valid only during the
active context invocation and contains ordered subpath boundaries and checked
local points. It may be mutated and submitted more than once within that
invocation, but it cannot be retained for a later Canvas or cycle. A live Path
has unique mutable construction ownership: two client variables cannot alias
the same mutable point/subpath range, and copying a live Path is outside the
MVP contract. The downstream Specification must make that rule unrepresentable
in the supported common language surface; it may not expose shared mutable
aliasing. Representation is otherwise not part of portable semantics:

- a dynamic profile may use uniquely owned expandable storage; and
- a static profile uses fixed-capacity storage leased from, embedded in, or
  generated for the active drawing workspace.

Both representations expose the same accepted operations and failure meaning.
The public Path does not own a backend resource, pixel buffer, platform path,
or indefinitely retained allocation.

Calling `move(to:)` establishes a current point and starts a new open subpath.
Calling `addLine(to:)` appends one straight segment from the current point and
makes the supplied point current. A line addition without a current point is
invalid. Empty and one-point subpaths produce no line segment; the exact
accepted behavior of zero-length segments and endpoint coincidence is a
Specification question constrained by deterministic cross-backend semantics.

When the client calls `stroke`, GiftUI snapshots the Path's then-current
subpaths, paint, and canonical style into the Canvas plan. The snapshot is
immutable. The client may subsequently mutate or reuse its Path without
changing previously submitted strokes. The snapshot step is the ownership
boundary that prevents a backend or later frame phase from borrowing mutable
client storage.

The selected architecture permits an implementation to transfer uniquely
owned storage into the plan or copy into a plan arena, provided the public
snapshot semantics and failure ordering are identical. Static code must not
hide allocation behind copy-on-write or existential storage.

### 3. Cycle-local Canvas plan

Each successfully derived Canvas produces a finite ordered plan of immutable
stroke snapshots. The plan is cycle-local derived work, not semantic state and
not a general retained render tree. Its lifetime is:

```text
state freeze and layout
    -> synchronous Canvas closure
    -> validated immutable stroke snapshots
    -> complete semantic revision / prepared frame
    -> one synchronous frame offer
    -> release after accepted or refused disposition
```

If the frame is refused, Core may retain only RFC-004's constant-space intent
that the latest published revision still needs presentation. It must discard
the Canvas plan and rederive it during a later separately paced opportunity;
it must not retain or replay the refused payload.

The plan exists because client drawing must finish and capacity failure must be
known before a backend may begin irreversible output. It also separates
client-closure execution from backend consumption. The plan is scoped only to
custom drawing payload; this RFC does not require ordinary views or complete
frames to materialize a universal display list.

### 4. Canonical stroke meaning

The canonical MVP stroke is an ordered set of open straight subpaths plus:

- a positive checked integer line width;
- an opaque RGB paint value;
- a supported endpoint cap value including `round`;
- a supported segment join value including `round`;
- a resolved surface origin for the Canvas local coordinate space; and
- the resolved clip inherited from the render pipeline.

Stroke geometry is defined in logical checked integer coordinates. Width,
cap, and join are logical semantics, not hints. A backend may quantize to its
pixel format only according to the downstream conformance contract and must
not replace round caps or joins with another style merely because its native
API lacks them.

No new public clipping operation is introduced. Canvas bounds do not
contribute an implicit clip. Drawing may extend outside those bounds until the
clip inherited from an ancestor in the existing render/layout pipeline applies.
The downstream Specification must encode this behavior and provide
cross-backend vectors for points on and outside each Canvas edge, both with and
without an intersecting inherited clip.

### 5. Lowering to the normalized operation stream

After a Canvas plan is complete, the render producer visits its stroke
snapshots in painter's order at the Canvas's position in the enclosing render
order. Each snapshot lowers to one normalized straight-line-stroke operation
or an equivalent bounded sequence whose grouping preserves canonical cap and
join semantics.

The normalized operation may synchronously expose a borrowed point/subpath
view instead of embedding a fixed maximum array in every operation value. That
view is valid only for the containing append/visit during ADR-010's offer. The
consumer must finish validation and raster derivation before returning and may
retain only backend-owned pixels, spans, tile work, or transfer data after
accepted handoff.

Splitting one path into independent segment operations is not conforming when
doing so changes join or endpoint behavior. Likewise, a backend cannot infer
subpath boundaries from duplicate points. The normalized payload must carry
the boundaries required for exact meaning.

### 6. Capacity and failure sequencing

The target host supplies or selects bounded capacities during construction.
Before the first cycle, RFC-002 B2 structural validation proves that the
selected Canvas/Path producer has sufficient point, subpath, stroke-record,
plan, and normalized-operation capacity for the approved configured workload.
Separately, SPEC-004 capability resolution proves that the render producer,
backend, surface/display, encoding, raster and derived-payload bounds, one-shot
lifetime, and host policy agree on the existing `rasterPresentation` semantic
path. A target that fails either gate does not start; the portable application
does not receive an optional feature flag and does not omit waveforms.

Within a cycle, Canvas construction uses checked operations in this order:

1. validate each local geometry and style value;
2. reserve or validate Path construction capacity;
3. snapshot a submitted stroke into drawing-plan capacity;
4. resolve local geometry and inherited clip using checked arithmetic;
5. validate normalized-operation capacity and payload bounds; and
6. expose the complete borrowed operation during frame offer.

A failure in steps 1 through 5 occurs before frame offer. The detecting layer
invalidates partial local work, reports a SPEC-003-compatible bounded outcome,
and marks the derived Canvas/frame scope incomplete. The runtime discards the
whole incomplete derived plan and retains dirtiness as required by ADR-011.
The downstream drawing Specification must map invalid values, arithmetic
overflow, capacity exhaustion, invalid phase/lifetime use, reentrancy, and
unexpected post-validation semantic mismatch into SPEC-003's closed condition,
origin, affected-scope, and containment vocabulary. Target policy may quiesce
a required facility after repeated or structural failure, but may not publish
partial drawing, narrow an unproven affected scope, reinterpret failure as
success, or choose an unadvertised fallback.

Failure after accepted handoff is backend operational state under ADR-010 and
ADR-017. Optional diagnostics may project either phase but cannot alter the
typed outcome or frame disposition.

### 7. Static and dynamic profiles

The two profiles may differ beneath the common semantics:

| Concern | Dynamic candidate | Static candidate | Required invariant |
| --- | --- | --- | --- |
| Path construction | uniquely owned growable buffer | fixed-capacity workspace range or generated inline storage | same points, subpaths, validation, and failure category for admitted workloads |
| Stroke snapshot | move or copy into cycle plan | seal or copy into caller-owned plan arena | later Path mutation cannot affect an earlier stroke |
| Plan records | array-like cycle storage | fixed record table plus point/subpath arenas | identical painter's order and payload meaning |
| Lowering | iterate borrowed records | index/range iteration without existential allocation | same normalized operation fixtures |
| Failure | explicit allocation/capacity outcome | explicit deterministic exhaustion | no silent drop, truncation, trap for ordinary exhaustion, or partial publication |

Profile equivalence does not require equal internal capacities or byte layout.
Every supported target must declare and validate enough capacity for the
approved downstream Signal Analyzer workload. Until SPEC-001 is approved, its
current 816-segment logical case and SPIKE-004's conservative 820-segment
fixture remain feasibility evidence rather than a normative production bound.
Shared boundary fixtures must fail in the same semantic category when
configured to the same artificial limits.

## Module Responsibilities

| Logical owner | Responsibility | Dependency impact |
| --- | --- | --- |
| `GiftUI` portable declaration surface | Canvas declaration, scoped graphics-context concept, Path construction concept, stroke-style and opaque-shading concepts | Remains the sole import for portable Presentation; imports no runtime, renderer, backend, platform, or hardware implementation |
| Portable foundation | Checked point, size, rectangle, scalar, and opaque color meanings | Reused by drawing without acquiring Canvas, backend, or capability policy |
| Declarative semantic runtime | Preserve Canvas declaration identity and cycle-stable captured values; treat Canvas as a semantic leaf | Does not invoke concrete raster or backend code |
| Layout | Resolve Canvas bounds through ordinary proposals and placement | Does not inspect the drawing closure or path contents |
| Render producer / Canvas lowering owner | Invoke the closure after layout, own bounded construction and plan workspace, validate and snapshot paths, resolve origin/clip, preserve order, and emit normalized strokes | Imports portable declarations, foundation, and approved failure/render contracts; imports no concrete backend |
| Frame/presentation coordinator | Include drawing operations in the one-shot offer and apply existing commit/refusal rules | Does not retain the Canvas plan after disposition or execute client code |
| Capability system | Validate SPEC-004 straight-line-stroke operation coverage plus compatible extent, raster/payload/in-flight, encoding, and lifetime facts before cycles begin | Does not add Canvas-plan fields or expose concrete implementation identity to Canvas code |
| Backend/raster integration | Consume validated normalized strokes synchronously and realize canonical semantics using target-selected raster/storage mechanics | Does not import or evaluate Canvas declarations, Path mutation, semantic views, or analyzer state |
| Target host | Assemble capacities, policy, producer, backend, surface, and diagnostics; require both B2 structural validation and SPEC-004 capability resolution before runtime start | Remains the only concrete composition root |

This RFC does not require a new independently distributed package. A
Specification may place focused drawing-lowering contracts in an internal
target if that preserves ADR-008's approved acyclic graph; the existence or
name of that target is not itself an RFC decision.

## Public API Impact

The portable `GiftUI` surface gains concepts equivalent to:

- a `Canvas` view initialized with a synchronous drawing closure;
- a scoped graphics context capable of stroking a Path;
- a resolved local `Size` passed to the closure;
- a mutable straight-line Path with `move(to:)` and `addLine(to:)`;
- opaque solid shading;
- a line-width shorthand; and
- a `StrokeStyle` subset containing line width plus the required round cap and
  join choices.

These are semantic concepts, not exact declarations. A downstream
Specification must define generic constraints, closure type, mutability,
visibility, construction and failure surface, default values, equality or
sendability where relevant, and unavailable operations. It must preserve one
substantially shared Signal Analyzer source shape across profiles and must not
expose profile capacity parameters, backend handles, unsafe borrowed pointers,
or platform types to ordinary client code. It must also make the active-Canvas
scope and unique construction ownership of mutable Path storage explicit:
copying, aliasing, retained, preconstructed, cross-cycle, and asynchronously
transferred Paths are outside the MVP contract.

This RFC does not promise SwiftUI source compatibility. Familiar naming and
call shape are desirable only where they preserve bounded explicit behavior.

## Capabilities Impact

Canvas does not create a new optional public Capability family or extend
SPEC-004's closed field set. The existing `rasterPresentation` family continues
to mean that the complete Signal Analyzer presentation path is available. Its
approved facts already cover:

- the straight-line-stroke operation bit and one-shot operation-stream
  lifetime;
- checked logical extent and clipping operation coverage;
- raster workspace and downstream retained-data bounds; and
- compatible canonical pixel encoding and submission lifetime.

Claiming the straight-line-stroke operation bit means the producer/backend path
implements the complete admitted canonical payload and style semantics,
including opaque RGB paint, once those semantics are accepted and specified;
style variants do not become new capability fields. Maximum points, subpaths,
strokes, Canvas-plan bytes, and producer-operation capacity are structural B2
inputs, not
`rasterPresentation` fields. The exact capability contribution fields and
absence reasons remain owned by approved SPEC-004 or an approved successor.
Runtime path exhaustion, backend backpressure, device loss, and transport
failure are operational outcomes or health, not mutable Capabilities.

## Backend Impact

Every first-party MVP backend must add conformance for the canonical normalized
straight-line-stroke operation. A backend may use a native line primitive,
scan conversion, tile-local rasterization, or another bounded algorithm, but
it must match the shared logical and pixel conformance vectors for order,
width, endpoints, joins, color, and clipping.

A full-surface framebuffer backend may raster directly into its surface during
accepted offer. A tiled RGB565 backend may visit affected tiles or produce
bounded backend-owned spans/transfer data, provided it consumes the borrowed
path payload synchronously and reserves all post-offer capacity before
acceptance. Neither backend may retain the Path snapshot or ask Core to replay
it after offer.

Unsupported native cap/join features are implementation details, not an
absence of portable semantics. The backend must realize the canonical result
in software or fail composite capability resolution before runtime.

## Static / Embedded Impact

- Path and Canvas-plan storage is finite, caller-owned or generated, and
  independent of heap allocation.
- The static plan uses bounded record, point, and subpath storage. Exact
  packing, widths, and alignment are Specification work supported by
  SPIKE-004 evidence.
- The Canvas closure is stored only as part of the semantic declaration until
  its synchronous invocation; static representation may specialize or generate
  that storage without heap allocation. The scoped context and workspace
  borrows do not escape, and no task, executor hop, post-cycle or frame-payload
  closure retention, or Objective-C runtime is required.
- SPIKE-004 proves the bounded plan/storage shape and Swift-to-static-fixture
  link path, but its nRF52840 plan arena and operations are implemented in C;
  it does not prove the final Swift Canvas closure, scoped Path ownership, or
  public declaration shape. The drawing Specification must compile and inspect
  those exact Swift declarations with the supported Embedded Swift toolchain
  before its approval gate can close.
- Checked local-to-surface translation must report overflow before operation
  exposure.
- The nRF52840 realization must measure linked flash, global/static RAM,
  cycle-workspace RAM, maximum stack, per-point and per-stroke cost, operation
  count, and raster workspace separately.
- Host-only compilation is not connected-hardware validation. This RFC's
  feasibility gate may use hardware-free Embedded Swift compile/link evidence;
  final conformance still requires the MVP's connected nRF52840/TFT evidence.
- No complete frame pixel buffer or replayable render list is required by this
  architecture. Backend-owned tile or transfer buffers remain governed by the
  existing presentation contracts.

## Performance

Path construction, snapshotting, lowering, and backend consumption should be
linear in the number of accepted points and strokes. No operation should scan
the complete capture history after Presentation has already selected visible
transitions. The canonical producer should require constant work per point,
subpath boundary, and stroke record, excluding backend raster coverage
proportional to affected pixels or tiles.

The current Signal Analyzer review workload is small in stroke count but not
in segment count. Under SPEC-001's current candidate drawing behavior and the
accepted 80-transition-per-second/five-second bound, the representative maximum
is:

| Item | Representative count |
| --- | ---: |
| Grid strokes | 12 one-segment paths, or an equivalent smaller stroke grouping |
| Visible transitions | 400 aggregate |
| Logical trace segments | 804 across four channels |
| Logical total segments | 816 |
| SPIKE-004 conservative fixture | 820, including one extra seed segment per channel |

Specifications must derive production bounds from approved application and
execution contracts rather than treating this evidence table as the final
capacity. The drawing contract may define the bounded mechanism before the
application number is approved; first-party host configuration and conformance
must later apply the approved bound without revising this architecture.
Performance evidence must record closure invocation, construction, snapshot,
lowering, and raster time independently on representative dynamic, Pi, and
embedded configurations. It must also demonstrate that drawing remains within
the target frame cadence without requiring a frame for every acquisition fact.

## Memory / Binary Size

The principal RAM costs are:

- current mutable Path points and subpath markers;
- sealed stroke records and their immutable point/subpath payloads;
- normalized operation iteration state;
- backend raster/tile workspace; and
- any backend-owned post-acceptance pixel or transfer data.

The architecture permits unique-storage transfer or arena sealing to avoid a
second point copy, but it does not require that optimization. A conforming
implementation must report both peak simultaneous storage and steady
cycle-workspace storage. It must not hide duplicate point buffers, allocator
metadata, or large inline values on the stack.

The static build must compare a drawing-enabled Signal Analyzer fixture with a
matched placeholder-waveform baseline and report flash, RAM, and stack deltas.
It must inspect linked symbols for allocator, reflection, task, thread,
exception, and unavailable runtime dependencies. Binary-size regressions must
be attributed to public declarations, path planning, normalized payload,
raster support, or test-only instrumentation where possible.

## Alternatives

### A. Cycle-local immutable Canvas plan (proposed direction)

Run the closure after layout, snapshot strokes into bounded derived workspace,
then expose only normalized immutable payload during frame offer.

This cleanly separates client execution from backend consumption, detects
ordinary capacity failure before irreversible output, permits shared recording
fixtures, and gives static profiles an explicit workspace. Its cost is
cycle-local point/stroke storage and potentially one copy from a mutable Path
into a sealed snapshot.

[SPIKE-004](../spikes/spike-004-canvas-path-plan-feasibility.md) demonstrates
viable nRF52840 RAM, stack, flash, and operation costs for both measured plan
implementations using its conservative 820-segment fixture, while direct
emission fails the required no-partial-output boundary after late sink
exhaustion. This RFC therefore proceeds with the cycle-local immutable Canvas
plan as its proposed direction.

Selecting this architecture does not select copy-to-plan or unique-range
sealing as a production storage layout. Both preserve the required snapshot
and failure semantics; their exact representation remains downstream
Specification and implementation work. SPIKE-004's lower measured RAM cost for
unique-range sealing is useful evidence, not architectural authority.

### B. Execute the client closure while a backend consumes the frame stream

Core could invoke the Canvas closure during ADR-010 offer and emit segments
directly to the backend, minimizing Core path-plan storage.

This can be attractive for extremely constrained streams, but it couples
client code execution to backend transaction timing, makes ordinary path or
operation exhaustion difficult to discover before irreversible output, and
risks exposing partial Canvas output. Preflighting by invoking the closure a
second time would make invocation count observable unless the API imposed a
stronger purity model than other GiftUI declarations.

SPIKE-004 confirms the resource advantage but also demonstrates that direct
emission can expose partial output after late sink exhaustion. It is therefore
not part of the proposed direction.

### C. Retain a complete frame display list

A complete retained list simplifies replay and lets every operation be
validated before offer. It also imposes universal operation storage, resource
lifetime, copy, and replay semantics already rejected for MVP by ADR-005 and
ADR-010. Canvas does not justify reopening that system-wide decision.

### D. Give the backend the Canvas closure or mutable Path

A backend-native Canvas could minimize translation and use platform graphics
APIs directly. It would make backends evaluate client behavior, acquire
semantic and application lifetimes, reproduce checked geometry and stroke
meaning, and diverge between static and dynamic profiles. It conflicts with
ADR-005 and the accepted Proposal.

### E. Expose only immediate `move` / `line` context commands

An immediate context could avoid a Path type and stream each segment as it is
declared. It does not meet the accepted MVP Path surface, makes stroke style a
per-segment concern, loses explicit subpath ownership, and makes round joins or
reusing one path for another stroke harder to define.

### F. Tessellate or rasterize strokes in Core

Core could convert lines to polygons, spans, masks, or pixels before the
backend boundary. That would make Core own pixel quantization and raster
format, increase transient data volume, duplicate tile/full-surface strategy,
and weaken backend independence. It may be suitable only if later evidence
establishes a new independently reviewed raster boundary.

### G. Adopt a general-purpose Path and graphics-state model now

A richer model would make curves, fills, transforms, images, alpha, and effects
easier to add later. None is required by the Signal Analyzer, and each adds
operation vocabulary, storage, failure, backend, and conformance obligations.
Future extensibility is preserved through the path/operation boundary without
implementing those features speculatively.

### H. Admit copyable or retained standalone Path values

A standalone copyable Path would permit preconstruction, caching, cross-Canvas
reuse, and familiar value-copy patterns. It would also require copy/alias
semantics, storage ownership outside the active Canvas workspace, capacity and
failure behavior for every copy, and cross-cycle lifetime rules that the Signal
Analyzer does not use. The proposed MVP instead keeps one uniquely owned
mutable construction handle inside the active Canvas invocation. Standalone
Paths require a new Proposal if a concrete later use case justifies them.

## Rejected Approaches

Alternative B is rejected from the proposed direction because SPIKE-004 shows
that it cannot preserve the required no-partial-output boundary after late sink
exhaustion without retained pre-recording or observable closure reinvocation.
Alternatives C through H conflict with accepted architecture, exceed the
accepted MVP scope, or add an unused lifetime and cost model, so they remain
outside the approved direction. RFC approval rejects these approaches for this
decision cluster; authoritative architecture still requires accepted ADRs.

## Compatibility

There is no approved public GiftUI Canvas API to preserve, so this RFC creates
no promised source or ABI migration. Current and legacy rectangle-stroke APIs,
dynamic display lists, and proof-of-concept renderer methods are
non-authoritative and may require migration.

The new public concepts must coexist with existing `View`, checked geometry,
opaque Color, layout, and modifier declarations without adding another import
to portable Presentation. Existing ordinary views and backends that do not
claim the complete MVP `rasterPresentation` capability need not gain Canvas
behavior silently; first-party MVP configurations must implement the complete
approved operation set before claiming conformance.

Operation encoding is an internal contract unless a later Specification says
otherwise. It should permit additive future operation cases without changing
the meaning or lifetime of the MVP straight-line-stroke payload. Adding curves,
fills, alpha, or retained paths is not a compatible extension by implication;
each still requires lifecycle authority.

## Testing Strategy

### Public semantic fixtures

- Verify Canvas receives the checked resolved local size after layout.
- Verify the stored client closure is invoked synchronously exactly once for a
  successful derivation, is released no later than cycle finalization, is not
  retained in published semantic state or presentation-pending intent, and is
  ordered within cycle-stable derivation.
- Verify the scoped graphics context, Path/workspace views, and all borrowed
  resources cannot be retained beyond the invocation.
- Record straight paths with multiple subpaths, empty subpaths, boundary
  points, repeated points, and invalid `addLine` ordering.
- Prove a live mutable Path cannot be copied or aliased into shared mutable
  storage and cannot be retained beyond the active Canvas invocation.
- Verify a stroke snapshots its Path and later mutation does not alter the
  earlier record.
- Verify line-width shorthand and equivalent StrokeStyle produce identical
  canonical records.
- Verify multiple strokes and surrounding ordinary views preserve painter's
  order.
- Verify sibling Canvas occurrences invoke their closures and insert their
  plans in deterministic resolved render order in both profiles.

### Cross-profile normalized-operation fixtures

- Run the same portable Canvas source through dynamic and static producers and
  compare exact normalized points, subpath boundaries, surface origin, clip,
  color, style, and order.
- Inject identical artificial limits for path points, subpaths, stroke records,
  and operations and compare explicit failure categories and affected scope.
- Verify checked overflow and invalid geometry never wrap or publish a partial
  plan.
- Verify failed derivation retains dirtiness and does not replay mutations or
  actions on the next opportunity.

### Backend and raster fixtures

- Use shared golden vectors for horizontal, vertical, corner, zero-length,
  boundary, odd/even width, round-cap, round-join, Canvas-edge, inherited-clip
  edge, and overlapping painter-order cases.
- Verify that geometry outside Canvas bounds remains visible when no inherited
  ancestor clip excludes it, and is clipped only where the inherited clip
  applies.
- Compare framebuffer and RGB565/tiled realization under canonical pixel
  tolerances defined by the drawing Specification.
- Verify a backend consumes every borrowed point before returning from offer
  and retains no Canvas-plan address or borrowed resource afterward.
- Verify unsupported style, extent, lifetime, or workspace combinations fail
  the owning startup gate instead of failing as a hidden runtime fallback:
  a producer/backend lacking the complete canonical style semantics must not
  advertise SPEC-004's straight-line-stroke operation bit; operation, extent,
  lifetime, and approved raster bounds fail capability resolution, while
  Canvas/Path/plan/producer-operation capacity fails B2 structural validation.

### Application and platform evidence

- Render the SPEC-001 grid and all four trace patterns from deterministic
  capture fixtures, including lower-bound baseline reconstruction and the
  five-second maximum visible window.
- Validate macOS dynamic and static source equivalence before Raspberry Pi and
  embedded integration.
- Record Raspberry Pi framebuffer output and PiScreen connected evidence.
- Record nRF52840/TFT connected output plus flash, RAM, workspace, and stack
  evidence. Host builds and screenshots do not substitute for connected
  hardware at final conformance.

### Dependency and negative fixtures

- Fail builds if portable Canvas declarations import a concrete backend,
  platform, driver, OS/RTOS, HAL, or hardware module.
- Fail builds if a backend imports semantic Canvas or analyzer modules.
- Prove omitted optional diagnostics do not change drawing outcomes.
- Prove the embedded closure and Path dependency closure links no allocator,
  reflection, task, thread, or exception runtime.
- Compile the exact public Canvas closure and uniquely owned scoped Path source
  shape with the supported Embedded Swift toolchain; C plan-arena evidence or
  a Swift entry point that delegates storage operations to C is insufficient.
- Prove B2 structural-validation failures and SPEC-004 capability failures are
  independent, conjunctive startup gates with no duplicated Canvas capacity
  fields in the capability snapshot.

## Risks

- **The cycle-local plan consumes too much nRF52840 RAM.** SPIKE-004 resolves
  feasibility for the bounded analyzer workload. Production Specifications
  must still derive capacities from approved workload bounds and preserve the
  measured resource headroom.
- **Snapshot copying doubles peak path storage.** Permit unique transfer or
  arena sealing beneath identical snapshot semantics and measure peak
  simultaneous storage rather than only final plan size.
- **Backend rasterization drifts.** Define canonical golden vectors and keep
  width, cap, join, order, and clip in the normalized operation meaning.
- **A client closure performs side effects or retains scoped state.** Specify
  Canvas as derivation, reject GiftUI mutation, reentrant use, and escaped
  context/workspace borrows where enforceable, release the stored closure by
  cycle finalization, and never use closure reinvocation as an implicit
  preflight mechanism.
- **The final Swift API links runtime support absent from Embedded Swift.**
  SPIKE-004 validates plan storage but not the exact Swift closure or Path type.
  Make the downstream Specification's approval seam compile and inspect the
  final source shape for allocation, reflection, task, exception, and other
  unavailable runtime dependencies.
- **Capacity differs across profiles.** Require every supported target to fit
  the approved downstream analyzer workload and compare semantics at identical
  artificial limits; expose no target identity or silent feature reduction.
- **Nested borrowed payloads complicate the backend SPI.** Keep the borrow
  synchronous and scoped to one operation visit, and require retention tests
  at the boundary.
- **Canvas expands into a general graphics framework.** Keep the operation and
  test catalogue limited to the accepted straight-line opaque-stroke scope.
- **Canvas-edge behavior drifts between backends.** Encode the selected
  non-clipping semantics in the drawing Specification and test geometry beyond
  every Canvas edge with and without an inherited ancestor clip.

## Open Questions

No architecture question remained open at approval. SPIKE-004
resolves bounded plan-storage feasibility but not the final Swift public API,
which is an explicit downstream Specification gate. The cycle-local plan and
non-clipping Canvas-bounds behavior are approved RFC choices extracted into the
accepted ADRs below and are now authoritative architecture.

The following exact contract details are intentionally owned by the downstream
drawing Specification rather than left as RFC questions:

- **Exact public failure surface:** which construction or stroke operations
  return typed outcomes, and which invalid state is accumulated until
  submission. The contract must preserve this RFC's explicit pre-offer,
  no-partial-plan semantics and one common source shape.
- **Degenerate geometry and raster vectors:** exact zero-length segment,
  coincident endpoint, default cap/join, and odd/even line-width behavior under
  one deterministic cross-backend meaning.

## Deferred and Follow-up Work

- [SPIKE-004](../spikes/spike-004-canvas-path-plan-feasibility.md) completed the
  bounded static-feasibility comparison. Its results are evidence for the
  cycle-local plan and do not select production code, capacities, or
  architecture.

Richer fills, curves, images, Canvas text, public clipping controls,
transforms, effects, retained rendering, and animation remain outside the
accepted Proposal. They are not silently added to MVP scope by this RFC. No
separate Future Work item is created because the repository currently has no
concrete requirement or revisit trigger beyond those already recorded as
non-goals and deferred client priorities.

## Decision Summary

This RFC's significant choices are extracted into separate accepted ADRs:

1. **[ADR-028: Post-Layout Canvas Derivation and Cycle-Local Plan](../adrs/adr-028-post-layout-canvas-derivation-and-cycle-local-plan.md):** Canvas is a laid-out
   semantic leaf whose stored client closure is synchronously invoked during
   cycle-stable post-layout derivation; its scoped context and workspace borrows
   cannot escape, and the bounded cycle-local immutable plan is released after
   one frame offer.
2. **[ADR-029: Scoped Transient Path Snapshot Semantics](../adrs/adr-029-scoped-transient-path-snapshot-semantics.md):** mutable straight-line Paths use
   unique scoped construction ownership with profile-specific bounded storage
   beneath one client meaning, and every stroke snapshots ordered subpaths so
   later mutation cannot affect submitted intent.
3. **[ADR-030: Canonical Normalized Straight-Line Stroke Operation](../adrs/adr-030-canonical-normalized-straight-line-stroke-operation.md):** GiftUI resolves
   checked local geometry, paint, style, order, origin, and clip above the
   backend boundary; backends synchronously consume borrowed immutable payload
   and own only derived post-acceptance data.
4. **[ADR-031: Bounded Canvas Failure and Startup-Gate Integration](../adrs/adr-031-bounded-canvas-failure-and-startup-gate-integration.md):** construction and
   plan failures abort incomplete derivation before offer; B2 owns Canvas,
   Path, plan, and producer-operation capacities, while the immutable composite
   `rasterPresentation` capability owns operation, extent, encoding, raster,
   payload, in-flight, and lifetime compatibility.

ADR-028 through ADR-031 were accepted on 2026-08-25 and are authoritative
architecture. Exact declarations and implementation contracts remain subject
to an approved downstream drawing Specification.

## References

- [PROPOSAL-006: Canvas, Path, and Stroke Drawing](../proposals/proposal-006-canvas-path-stroke-drawing.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [RFC-001: Signal Analyzer Application Architecture](rfc-001-signal-analyzer-application-architecture.md)
- [RFC-002: GiftUI MVP Layered Architecture](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](rfc-005-failure-diagnostics-propagation.md)
- [RFC-006: GiftUI Capability System Architecture](rfc-006-capability-system-architecture.md)
- [ADR-003: Transition-Based Bounded Capture](../adrs/adr-003-transition-based-bounded-capture.md)
- [ADR-004: Portable Fixed Signal Analyzer Presentation](../adrs/adr-004-portable-fixed-signal-analyzer-presentation.md)
- [ADR-005: Semantic, Layout, and Render Boundary](../adrs/adr-005-semantic-layout-render-boundary.md)
- [ADR-006: Shared Semantics Across Runtime Profiles](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-007: Integration Ownership and Host Composition](../adrs/adr-007-integration-ownership-and-host-composition.md)
- [ADR-008: Module Dependency Graph and MVP Package Topology](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [ADR-009: Checked Integer Geometry for MVP](../adrs/adr-009-checked-integer-geometry.md)
- [ADR-010: Synchronous One-Shot Frame Handoff](../adrs/adr-010-synchronous-one-shot-frame-handoff.md)
- [ADR-011: Serialized Run Cycle and Semantic Publication](../adrs/adr-011-serialized-run-cycle-and-publication.md)
- [ADR-014: Bounded Cross-Layer Outcome Meaning](../adrs/adr-014-bounded-cross-layer-outcomes.md)
- [ADR-015: Layered Failure Disposition Ownership](../adrs/adr-015-layered-failure-disposition.md)
- [ADR-016: Non-Authoritative Diagnostic Projection](../adrs/adr-016-non-authoritative-diagnostics.md)
- [ADR-017: Capability and Operational-State Decision Planes](../adrs/adr-017-capability-and-operational-state-planes.md)
- [ADR-018: Fixture-Driven Typed Capability Model](../adrs/adr-018-fixture-driven-typed-capabilities.md)
- [ADR-019: Bounded Target-Host Capability Resolution](../adrs/adr-019-bounded-host-capability-resolution.md)
- [ADR-020: Composite Raster Presentation Capability](../adrs/adr-020-raster-presentation-capability.md)
- [ADR-022: Positioned-Glyph Render Operation](../adrs/adr-022-positioned-glyph-render-operation.md)
- [SPEC-001: Signal Analyzer Reference Application Contract](../specs/spec-001-signal-analyzer-reference-application.md)
- [SPEC-002: Portable Foundation Specification](../specs/spec-002-portable-foundation.md)
- [SPEC-003: Failure Outcomes and Containment Specification](../specs/spec-003-failure-outcomes-and-containment.md)
- [SPEC-004: Capability Contribution and Resolution Specification](../specs/spec-004-capability-contribution-and-resolution.md)
- [SPEC-006: Declarative View Semantics Specification](../specs/spec-006-declarative-view-semantics.md)
- [SPIKE-004: Canvas Path Plan Feasibility](../spikes/spike-004-canvas-path-plan-feasibility.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md)
