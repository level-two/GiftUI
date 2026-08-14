---
id: RFC-002
feature: giftui-mvp-architecture
title: GiftUI MVP Layered Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-14
updated: 2026-08-14
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-001
related_adrs: []
related_specs: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# RFC-002: GiftUI MVP Layered Architecture

## Summary

This RFC proposes that GiftUI own a narrow, backend-independent pipeline from
declarative UI semantics through runtime expansion, proposal-based layout, and
a normalized render plan. Backends consume the render plan and translate it
into target mechanics; display-controller drivers and transports remain below
the backend boundary. A separately resolved capability model describes what a
complete assembled stack can provide after software fallbacks, hardware
facilities, transport limits, and runtime-profile restrictions are combined.

The central boundary is:

```text
declarative view
    -> semantic/runtime graph
    -> resolved layout
    -> backend-neutral render operations
    -> backend
    -> surface or display target
    -> driver
    -> OS, HAL, and hardware
```

GiftUI semantics therefore remain owned by GiftUI. Backends own rendering,
presentation, and input adaptation, but do not interpret `View`, `VStack`,
`Button`, state, identity, or reconciliation. Hardware drivers own controller
and transport mechanics, but do not become GiftUI backends merely because
they can display pixels.

These are candidate architectural choices for review. This draft does not
approve them, define final public APIs, authorize package restructuring, or
authorize implementation.

## Context

[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
accepts the need to establish GiftUI's MVP architecture before proof-of-concept
migration or substantial framework feature work. The architecture must support
one substantially shared Signal Analyzer presentation across:

- macOS with a dynamic runtime;
- macOS with a static runtime;
- Raspberry Pi 1/Linux with a dynamic runtime and framebuffer/PiScreen output;
- nRF52840/Zephyr with a static runtime and TFT output.

[RFC-001](rfc-001-signal-analyzer-application-architecture.md) and its accepted
ADRs establish the application boundary: portable Signal Analyzer Presentation
may depend on approved GiftUI client contracts, while each target host selects
the runtime, backend, display, input, scheduling, and hardware integrations.
They do not establish GiftUI's internal architecture.

The existing proof of concept already supplies useful evidence:

- `GiftUI` contains portable declarations, geometry, traversal, render
  operations, and shared semantic behavior;
- `GiftUIRuntimeDynamic` and `GiftUIRuntimeStatic` realize different storage
  strategies behind a common portable declaration surface;
- the static runtime emits render operations into a caller-provided sink
  without requiring an allocated display list;
- framebuffer and RGB565 renderers consume backend-independent operations;
- Linux platform targets own framebuffer, input, and OS integration;
- an ILI9341 display target is separate from the RGB565 renderer;
- shared host conformance tests compare dynamic and static runtime behavior.

Those structures and the legacy documents in References are evidence, not
accepted architecture. This RFC may preserve, revise, or retire them only
after review, ADR extraction, and downstream Specifications.

## Requirements

### R1 — Portable declarative semantics

The architecture MUST provide one portable, SwiftUI-inspired client model for
the Signal Analyzer's required composition, layout, rendering, interaction,
state, and drawing surface. Portable view declarations MUST NOT expose a
renderer, operating system, display controller, transport, or hardware type.

### R2 — Semantic ownership

View expansion, structural identity, state lifetime, invalidation,
reconciliation, environment propagation when introduced, lifecycle, and
semantic event dispatch MUST be owned above the backend boundary. A backend
MUST NOT evaluate `body`, interpret container semantics, own application
state, or dispatch client actions directly.

### R3 — Backend-neutral layout

Measurement and placement semantics MUST be backend-independent. MVP layout
MUST support the proposal/measurement model needed by the Signal Analyzer and
MUST NOT require a general-purpose constraint solver.

### R4 — Narrow render boundary

Resolved UI MUST lower to a compact backend-neutral render representation.
The MVP representation MUST cover opaque rectangles, text, the limited
Canvas/path strokes required by the analyzer, clip or damage geometry needed
by supported backends, and hit-region correlation where required. It MUST NOT
expose semantic view or container types to backends.

### R5 — Static and dynamic viability

Portable semantics MUST be shared across dynamic and static runtime profiles.
Profile selection MAY change storage, composition, dispatch, and render-plan
materialization, but MUST NOT create a second semantic UI framework or require
a separate portable Signal Analyzer hierarchy.

### R6 — Explicit bounds and failures

Every static-path storage obligation introduced by the architecture MUST have
a fixed, generated, or caller-supplied bound and deterministic exhaustion
behavior. The architecture MUST permit direct render-operation emission so a
static target is not forced to retain an unbounded render tree or display list.

### R7 — Integration ownership

Platform, backend, display-controller, input-device, OS, RTOS, and HAL
mechanics MUST remain below portable semantics. A platform preset MAY compose
these facilities, but MUST NOT become their architectural owner or a generic
bucket that permits upward dependency leaks.

### R8 — Effective capabilities

The architecture MUST define where facts from runtime profile, renderer,
backend, transport, display, input, and hardware are combined into the
capabilities of an assembled stack. Portable application code MUST NOT use
platform checks to infer those capabilities.

### R9 — Capability and policy separation

Capabilities MUST describe available behavior and relevant constraints.
Runtime policy MUST separately decide whether or how to use an available
behavior within frame, memory, quality, or energy budgets.

### R10 — MVP proportionality

Implementation required by this architecture MUST remain traceable to the
Signal Analyzer or to validation of an MVP stack. Boundaries MAY preserve
future extensibility, but unused backends, effects, solvers, drivers, or a
comprehensive capability catalogue MUST NOT be required for MVP completion.

### R11 — Testable contracts

Each architectural boundary MUST be testable without requiring the complete
runtime-by-backend-by-platform-by-device Cartesian product. Connected-hardware
claims MUST remain distinct from host, simulator, compile, and hardware-free
evidence.

## Constraints

- The supported Linux board is Raspberry Pi 1 using
  `armv6-unknown-linux-gnueabihf`, framebuffer rendering, and PiScreen.
- The supported Nordic target is `nrf52840dk/nrf52840` using Embedded Swift,
  Zephyr, and a TFT display path.
- The nRF52840 path cannot require heap allocation, reflection, unrestricted
  existentials, unbounded collections, desktop concurrency facilities, or
  runtime backend discovery.
- The Signal Analyzer ingests up to 80 transitions per second but presents at
  four frames per second; invalidations may therefore be coalesced.
- MVP rendering is limited to opaque RGB colors, text, backgrounds, and the
  straight-line waveform drawing surface in `docs/MVP_SCOPE.md`.
- Hardware scrolling, readback, shadows, alpha compositing, images, advanced
  paths, and native-widget projection are not MVP implementation requirements.
- Existing source compatibility is desirable but secondary to accepted
  architecture. No public ABI stability is established for the proof of
  concept.
- Logical architectural layers need not map one-to-one to Swift packages.
  Static builds may flatten package boundaries while preserving ownership and
  dependency direction.

## Proposed Design

### 1. Logical layers and dependency direction

The proposed architecture has seven logical responsibility layers plus a
cross-cutting configuration and capability plane:

```text
Application and target host
              |
              v
GiftUI public declarative API
              |
              v
Semantic runtime and state
              |
              v
Proposal-based layout and geometry
              |
              v
Backend-neutral render plan
              |
              v
Backend and raster/native implementation
              |
              v
Display/input driver and transport/OS/HAL
```

Dependencies point toward contracts and portable semantics, never from
portable layers toward concrete integrations. A target host is the composition
root and is allowed to depend on all selected components.

The layer boundaries are architectural ownership boundaries. They do not
require seven public products, seven runtime objects, or a call through seven
protocol existentials. The MVP may retain related responsibilities in one
SwiftPM target when doing so does not permit forbidden dependencies or obscure
the contract under test.

### 2. Public declarative API

`GiftUI` remains the primary application import and owns portable declarations
such as `View`, `ViewBuilder`, fixed composition, `Text`, `Button`, stacks,
`Spacer`, state-facing property wrappers or bindings, modifiers, geometry, and
the narrow Canvas/path/stroke client surface.

The portable surface declares semantic intent. It does not declare frame
buffers, pixel formats, Qt objects, Linux descriptors, SPI transactions,
display windows, or controller registers.

Heap-backed strings, callback conveniences, dynamic collections, and similar
facilities may remain opt-in dynamic conveniences. They extend the same
semantics rather than defining a separate dynamic UI model. Unsupported
portable-profile operations should be absent at compile time or fail through
an explicitly bounded contract; they should not be placeholder implementations
that trap only after deployment.

### 3. Semantic runtime and state

The semantic runtime owns expansion of transient view values into a form on
which identity, state, invalidation, layout, and event routing can operate. The
logical flow is:

```text
transient view declaration
    -> semantic traversal or graph construction
    -> structural identity and state binding
    -> persistent runtime state where the selected profile needs it
    -> invalidation and reconciliation
```

Dynamic and static runtimes may use different representations:

- a dynamic runtime may retain class-, array-, dictionary-, or closure-backed
  structures;
- a static runtime may traverse directly or use index-linked fixed-capacity
  arenas, typed state slots, identified actions, and caller-owned workspaces.

The architectural invariant is observable behavior, not graph representation.
Both profiles preserve the same ordering, state lifetime, layout semantics,
render-operation order, hit testing, action dispatch, and deterministic
failure rules for portable views.

For MVP, complete-root reevaluation is acceptable. Partial subtree
reconciliation, transactions beyond what state consistency needs, animation,
and a retained lifecycle model are extension points, not required
implementations.

### 4. Layout and geometry

Layout is a distinct logical subsystem owned above rendering. It receives
semantic children, a proposed size, environment values relevant to layout,
and bounded cache/storage supplied by the selected runtime. It produces final
placements and hit-test geometry.

The baseline algorithm is proposal-based measurement and placement:

```text
parent proposal
    -> child measurement proposals
    -> measured sizes
    -> final placements
    -> resolved bounds and hit regions
```

MVP layout covers stacks, overlays, spacing, alignment, padding, frames,
spacers, intrinsic text/control sizes, and the fixed Signal Analyzer
hierarchy. A generic constraint solver is a separate optional facility and is
not part of the MVP dependency graph.

Layout geometry remains backend-neutral. Pixel quantization, rotation, stride,
color conversion, controller write windows, and physical transfer regions do
not influence semantic measurement. A backend may clip or damage resolved
geometry but may not recompute GiftUI layout semantics.

### 5. Backend-neutral render plan

After layout, GiftUI lowers semantic content and resolved geometry into a
small vocabulary of render operations. The proposed MVP vocabulary includes
concepts equivalent to:

```text
fill opaque rectangle
draw text run
stroke line path with opaque color and bounded stroke style
push/pop rectangular clip, if required by selected MVP backends
associate resolved hit regions with semantic action identifiers
```

Exact cases, scalar types, ownership, and public visibility belong in a later
Specification. The representation carries what must appear and where; it does
not carry `View`, `VStack`, `Button`, state storage, or platform handles.

The canonical contract is an ordered render-operation sink. This permits two
materialization strategies without changing operation semantics:

- static runtimes emit directly into a bounded backend or caller-provided sink;
- dynamic runtimes may collect the same operations into an array-backed
  display list for replay, inspection, damage calculation, or testing.

For MVP, no separate retained render tree is proposed. A retained render tree
could later be introduced above the same operation vocabulary if measurements
show that reconciliation, damage tracking, or a materially different backend
requires it. Keeping one normalized operation boundary minimizes static RAM,
copying, code size, and dual-representation conformance work.

### 6. Backend SPI and implementations

The backend SPI consumes resolved frame information and ordered render
operations, then presents a frame. It should be decomposed by responsibility
rather than exposed as one protocol containing every future facility.

The MVP needs contracts equivalent to:

- surface size and pixel/coordinate mapping;
- frame begin, operation consumption, and frame end/presentation;
- opaque rectangle, text, and line-stroke support;
- damage or partial-write information only where an MVP backend needs it;
- input adaptation into backend-neutral pointer/touch events.

Capability-specific contracts should be separate additions. A backend that
does not support readback, hardware scrolling, vector paths, alpha layers, or
partial update must not provide meaningless methods or runtime traps for those
facilities.

Initial backend families are:

1. A reusable CPU raster path that converts normalized render operations into
   pixels without knowing Linux or a display controller.
2. A framebuffer backend that targets a `PixelSurface`-like memory contract.
3. A Linux integration that owns framebuffer mapping, stride and format
   discovery, presentation, and event-device adaptation.
4. An embedded display backend that rasterizes bounded rows or regions and
   writes them through a display-target contract.
5. Recording and checking backends used for contract tests.

A Qt backend is a future boundary-validation candidate, not an MVP
implementation requirement. Its first conforming mode should consume GiftUI's
render plan through QPainter or an equivalent rendering surface. Directly
mapping `Button` to `QPushButton` would introduce a second semantic runtime and
requires a separate future RFC.

### 7. Display drivers, input drivers, and HAL

An embedded display backend is not the display-controller driver. The backend
owns the conversion from GiftUI render operations to raster regions and
presentation strategy. A display-target contract owns device-facing concepts
such as dimensions, native pixel format, write windows, pixel transfer, and
optional readback or hardware scrolling.

Concrete ILI9341, ILI9486, ST7789, or other controller modules implement that
display-target contract. Transport implementations separately own SPI, GPIO,
DMA, timing, RTOS, or OS mechanics. The intended dependency flow is:

```text
embedded display backend
    -> display-target contract
    <- concrete controller driver
        -> transport/HAL contract
        <- Zephyr, vendor HAL, or OS transport
```

The same separation applies to input. GiftUI semantic input consists of
backend-neutral events and action routing. Touch-controller calibration,
sampling, GPIO interrupts, evdev records, and mouse events remain in drivers
or platform adapters that lower into those events.

### 8. Configuration and composition

A supported configuration is the combination of:

1. build constraints and runtime profile;
2. selected component implementations and capacities;
3. resolved effective capabilities and runtime policy.

These are related but not interchangeable. Embedded Swift restrictions come
from the build/runtime profile. Display dimensions and controller operations
come from hardware. Transfer limits come from a concrete transport. Software
rasterization may supply behavior absent in hardware. Policy chooses among
available implementations within the target's budgets.

The target host is the composition root. Dynamic hosts may use erased runtime
selection where allowed. Static hosts should prefer generic or generated
composition so unsupported combinations fail during compilation and do not
require runtime discovery. Both strategies assemble the same logical
contracts.

Named platform products, when useful, are convenience presets. For example, a
Raspberry Pi preset may select the dynamic runtime, Linux framebuffer backend,
evdev input, and Pi-specific GPIO adapter. It does not own their semantics and
must not be imported by portable views or GiftUI core modules.

### 9. Capability resolution and runtime policy

Each selected layer contributes typed facts rather than platform booleans:

- runtime profile: allocation, existential, resource-loading, or bounded
  storage restrictions;
- renderer: operations it can realize in software and their resource costs;
- backend: presentation, surface, damage, and acceleration facilities;
- display and input drivers: device geometry, formats, update operations, and
  input facilities;
- transport: transfer granularity, bandwidth, alignment, and concurrency
  constraints.

At composition time, a resolver intersects restrictions and adds valid
software fallbacks to produce immutable effective capabilities. Higher layers
consume only semantic results, for example unavailable, software-realized, or
hardware-accelerated behavior with relevant bounds. They do not inspect
controller identity or `#if os(...)` to reach the same conclusion.

Capability support and realization are distinct. A display with no alpha
hardware could still participate in alpha compositing if a selected rasterizer
provides it in software. That example shapes the boundary but alpha remains
outside MVP implementation scope.

Runtime policy is a separate input. It may select full redraw versus damage,
tile height, update coalescing, or an available acceleration path within
declared memory and frame budgets. Policy cannot claim a capability the stack
does not provide or change GiftUI's portable semantics.

For MVP, the capability catalogue should be limited to facts needed to admit
and validate the four supported configurations. Candidate initial entries are
surface dimensions, opaque RGB/text/stroke support, input availability,
render-plan capacity or streaming support, partial presentation where used,
and profile/storage restrictions required for the static runtime.

### 10. Frame and event flow

The proposed serialized MVP flow is:

```text
platform input adapter
    -> backend-neutral input event
    -> hit test against runtime-owned resolved regions
    -> semantic action dispatch
    -> state mutation and invalidation
    -> coalesced view expansion/reconciliation
    -> proposal-based layout
    -> ordered render-operation emission
    -> backend rasterization/presentation
```

The runtime owns serialization, reentrancy rules, action ordering, and
invalidation. The host owns how its event loop or scheduler invokes that
runtime. Backends and drivers may report failures or input but may not mutate
application state directly.

## Module Responsibilities

| Logical module or family | Responsibility | Dependency impact |
| --- | --- | --- |
| `GiftUI` | Portable declarations, semantic contracts, geometry, render-operation vocabulary, and client-facing API | Imports no concrete runtime, backend, platform, driver, OS, RTOS, or HAL module |
| `GiftUIDynamicConveniences` | Heap-backed strings, closure actions, and other opt-in dynamic syntax | Depends only on portable GiftUI contracts and supported dynamic facilities |
| Semantic runtime family | View expansion, identity, state, invalidation, reconciliation, layout orchestration, hit regions, and action routing | Dynamic and static implementations depend on portable contracts; neither depends on a concrete backend |
| Layout subsystem | Proposal-based measurement, placement, cache contracts, and resolved geometry | Depends on semantic/geometry contracts; imports no renderer or platform implementation |
| Render-core subsystem | Normalized operations, sinks, optional bounded/array storage, resources, and frame metadata | Depends on geometry and portable resource contracts; contains no semantic view types in the backend boundary |
| Backend SPI | Frame lifecycle, operation consumption, surface contracts, and backend capability contribution | Depends on render core; contains no application or semantic-runtime ownership |
| CPU rasterizer | Converts normalized operations into pixels or bounded tiles | Depends on backend/render and pixel-surface contracts, not Linux or a controller |
| Framebuffer backend | Presents raster output to a memory surface | Depends on render/raster and surface contracts, not a specific OS |
| Linux integration | Owns framebuffer mapping, discovery, presentation, evdev, and other Linux mechanics | Depends on backend and OS adapters; never imported by portable GiftUI layers |
| Embedded display backend | Converts operations into bounded raster regions and display-target writes | Depends on render/raster, backend SPI, and display-target contracts |
| Display/input driver family | Implements controller operations, calibration, device input, and typed device capabilities | Depends on device and transport contracts, not semantic GiftUI types |
| Transport/HAL family | Owns SPI, GPIO, timing, DMA, RTOS, and OS mechanics | Lowest integration boundary; imports no GiftUI semantics |
| Target host/preset | Selects runtime, capacities, backend, drivers, policy, and event-loop integration | Composition root may depend on every selected layer but exports no new portable semantics |

These names describe ownership. ADRs and Specifications should decide whether
an ownership boundary needs a distinct target after considering dependency
enforcement, compile time, code size, and maintenance cost.

## Public API Impact

The proposed architecture preserves `import GiftUI` as the portable client
surface. It does not approve exact API spellings. Later Specifications are
expected to define:

- portable `View`, builder, primitive, container, modifier, state, and drawing
  contracts required by the Signal Analyzer;
- the compile-time boundary between portable APIs and dynamic conveniences;
- profile-neutral semantic behavior and deterministic bounded failures;
- which backend/render/device protocols are public, package SPI, or internal;
- how a target host supplies configuration without exposing it to view code.

Existing proof-of-concept declarations may be retained when they conform to
those contracts. Source migration is acceptable where current APIs expose
dynamic representation, conflate logical layers, or cannot express the
Signal Analyzer under both profiles.

No stable public ABI is proposed for MVP. Public source compatibility should
be measured and migration notes supplied for renamed, moved, or restricted
APIs.

## Capabilities Impact

Capabilities become a cross-cutting composition result, not a collection of
backend feature flags and not a platform switch in portable application code.

The capability contract should preserve:

- provenance: which selected layer contributed a fact;
- support level: unavailable, software-realized, hardware-accelerated, or
  another domain-specific state rather than a universal Boolean;
- constraints: axes, formats, bounds, alignment, capacity, or cost where they
  affect correct use;
- deterministic resolution: the same assembled configuration yields the same
  effective capability set;
- absence behavior: an unsupported required MVP capability makes the
  configuration invalid before presentation begins where practical;
- inspectability: supported configurations can report their effective
  capability and policy selections in diagnostics and tests.

Capabilities do not authorize silent semantic degradation. A required opaque
stroke or input behavior must either be provided conformingly or make the
configuration unsupported. Optional quality or acceleration choices may
degrade according to explicit policy when their semantic contract permits it.

## Backend Impact

Backends will consume a normalized render plan instead of the semantic view
graph. This keeps them replaceable and makes recording, framebuffer, Linux,
embedded-display, and future painter-style backends comparable at one
boundary.

Existing proof-of-concept backends should be evaluated as follows:

| Existing area | Proposed disposition |
| --- | --- |
| `GiftUIBackendFramebuffer` | Preserve evidence; separate generic raster behavior from memory-surface presentation where measurements justify the split |
| `GiftUIBackendRGB565` | Preserve bounded tile and retained-rectangle strategies as candidate raster implementations below the normalized operation boundary |
| `GiftUIPlatformLinux` | Preserve Linux ownership of framebuffer and input mechanics; prevent it from becoming the owner of raster or GiftUI semantics |
| `GiftUIPlatformRaspberryPi` | Treat as a convenience composition and Pi-specific integration layer, not a new semantic layer |
| `GiftUIDisplayILI9341` | Treat as a display-controller implementation below an embedded display backend; review its current dependency on RGB565 rendering during specification work |
| `GiftUIInputADS7846` | Preserve as a device/input adapter that lowers samples into backend-neutral events |
| `GiftUISimulatorMac` | Preserve as a host/presenter composition using a conforming backend, not as an owner of GiftUI semantics |

No additional production backend is required solely to prove the abstraction.
The MVP's Linux framebuffer and nRF52840 display paths are materially different
enough to validate it, with the macOS host and recording backends providing
faster development evidence.

## Static / Embedded Impact

The architecture deliberately supports static composition around the same
contracts:

- compile-time selected runtime, render pipeline, backend, and drivers;
- fixed, generated, or caller-owned state, graph, layout, hit-region, render,
  event, and tile storage;
- direct render-operation sinks when retaining a display list is wasteful;
- typed actions and state slots instead of mandatory closures, strings, `Any`,
  reflection, or runtime discovery;
- bounded traversal and documented stack use;
- explicit capacity errors and build-time/resource diagnostics;
- no assumption that `Task`, `MainActor`, desktop timers, Objective-C, or a
  font/resource loader exists.

Logical layers may compile into one firmware image and generic specialization
may erase abstraction overhead. That flattening does not permit dependency or
ownership inversion.

Large fixed-capacity storage should support caller-owned long-lived
workspaces. The legacy stack-ownership proposal shows that embedding multiple
large inline arenas in a call frame can exceed nRF52840 stack limits even when
total RAM appears acceptable. Exact workspace APIs and frame budgets require a
separate approved contract; this RFC establishes only that layer boundaries
must not force copies or stack ownership of large fixed stores.

## Performance

The architecture adds lowering boundaries, but they should be statically
specializable and streamable. The expected MVP hot path is view expansion,
layout, operation emission, text/line rasterization, damage selection, and
display transfer.

Performance validation should report, per supported configuration:

- invalidation-to-frame latency;
- layout and render-operation counts for the fixed Signal Analyzer hierarchy;
- operations, pixels, and bytes processed per presented frame;
- full-redraw and selected partial-update frame time where both exist;
- display-transfer time separately from GiftUI CPU work;
- sustained ingestion at 80 transitions per second while presenting every
  250 milliseconds;
- worst-case stack high-water and any heap/allocation count required by the
  selected profile.

The nRF52840 path should use bounded tiles or retained display writes rather
than require a full 480 x 320 RGB565 framebuffer, which would consume 307,200
bytes before runtime, state, stack, and firmware needs. Existing evidence uses
a maximum 480 x 4 x 2-byte tile, or 3,840 bytes; retaining that bound is a
candidate subject to measurement against the final Signal Analyzer geometry.

No universal frame-time budget is approved here. The Signal Analyzer's
250-millisecond presentation interval supplies the required end-to-end
deadline; downstream Specifications should allocate component budgets after
measurement on each target.

## Memory / Binary Size

Static conformance requires resource accounting by ownership boundary:

- graph/layout nodes and traversal depth;
- state slots and value storage;
- hit regions and event/action queues;
- render-operation buffering, if any;
- raster tile or surface storage;
- text/font resources;
- driver and transport buffers;
- stack frames, total stack high-water, linked RAM, and flash;
- generic-specialization and modifier-chain code size.

The streaming render boundary avoids making an array-backed `DisplayList` a
universal RAM cost. Optional facilities such as a generic constraint solver,
retained render tree, alpha compositor, image decoder, dynamic fonts, and
unused drivers should remain outside the linked static configuration rather
than merely disabled by runtime flags.

Dynamic configurations may allocate for convenience, diagnostics, and
retention, but tests should still measure allocation growth and ensure that a
portable feature does not accidentally require unbounded storage.

## Alternatives

### Alternative A — Backends consume the semantic view/runtime graph

Each backend could inspect GiftUI nodes such as stacks, text, and buttons and
choose native or raster equivalents. This can reduce one lowering step and may
help a native-widget backend exploit platform controls.

It also couples every backend to identity, state, layout, modifiers, and
semantic evolution. Backends would duplicate semantic interpretation, static
and dynamic graph representations would leak across the SPI, and cross-backend
conformance would become much harder. This alternative is preferable only if
GiftUI intentionally delegates semantic ownership to another retained UI
framework, which is not the current MVP goal.

### Alternative B — Retained render tree followed by a display list

GiftUI could always build a backend-neutral retained render tree, diff it, and
then lower changes into a display list. This offers a natural place for render
identity, damage propagation, retained resources, and capable desktop
backends.

It introduces two intermediate representations, storage for both, identity
and diffing rules, more copies or borrows, and two bounded-capacity problems on
the static path. It becomes preferable if measurements demonstrate that
partial reconciliation or a required backend cannot be implemented cleanly
over streamed normalized operations. The proposed MVP starts with one
operation vocabulary and leaves retained rendering as an extension.

### Alternative C — Direct semantic traversal into each concrete backend

The runtime could skip a named render representation and invoke backend
methods while traversing laid-out semantic nodes. This minimizes retained
storage and resembles the current static sink path.

Without a normalized operation contract, however, semantic cases tend to
become backend methods and the boundary drifts toward Alternative A. A typed
ordered render sink preserves direct emission while making the intermediate
vocabulary explicit and independently testable.

### Alternative D — Separate static and dynamic architectures

GiftUI could expose `GiftUI` and `GiftUIStatic` as distinct frameworks with
different view, layout, rendering, and backend models. Each could optimize for
its environment with fewer portability constraints.

This would weaken the MVP's central portability claim, duplicate semantic and
test contracts, and invite behavioral drift. It is preferable only if shared
portable semantics prove impossible for the Signal Analyzer after measured
experiments. The proposed design instead varies storage and composition
vertically beneath one portable API.

### Alternative E — Platform-owned vertical stacks

Large Linux, Qt, or embedded platform modules could own runtime, layout,
rendering, input, display, and hardware integration end to end. This simplifies
initial composition and may mirror deployment packaging.

It also duplicates reusable raster, display, input, and semantic behavior and
makes platform names accidental architecture. The proposed design permits
platform presets but keeps ownership in the narrowest reusable layer.

### Alternative F — General constraint solver as the core layout model

A universal solver could express advanced cross-view relationships and make
some layouts concise. It carries algorithmic, memory, code-size, and bounded
storage costs not justified by the fixed Signal Analyzer hierarchy and does
not naturally match the proposed-size model familiar from SwiftUI.

An optional constraints package could be added later if a concrete feature
requires it. The MVP uses proposal-based layout.

### Alternative G — Boolean capabilities attached only to the backend

A single backend struct containing flags such as `supportsAlpha` or
`supportsScroll` is simple to inspect. It cannot accurately represent
software fallbacks, transport constraints, build-profile restrictions,
non-Boolean limits, or provenance.

It is adequate only for a small closed backend with no layered composition.
The proposed resolver instead combines typed contributions from the assembled
stack and keeps policy separate.

## Rejected Approaches

No approach is formally rejected while this RFC remains a draft. The
alternatives above are candidates for review. Approval should record which
ones were rejected and why before ADR extraction.

## Compatibility

### Source compatibility

Portable view syntax should remain familiar and existing conforming
proof-of-concept views should migrate with limited changes. APIs that expose
dynamic-only representations, backend types, or target mechanics may move or
become unavailable to portable builds. Each downstream Specification should
include source migration examples.

### Behavioral compatibility

Shared semantic suites must preserve observable portable behavior across
runtime profiles: layout, state lifetime, invalidation, render-operation
order, input routing, and capacity failure semantics. Pixel output may differ
by quantization, font rasterization, rotation, or physical format while still
conforming to one render contract.

### Package compatibility

Existing product names are not architectural authority. Package splits and
merges should occur only when they enforce an accepted boundary or remove a
measured cost. Convenience platform products may remain even when ownership is
factored into narrower modules.

### ABI and data compatibility

The MVP does not promise ABI stability or persistent UI data formats. Render
operations and capability values should initially be versioned through source
contracts and conformance tests rather than serialized interchange formats.

## Testing Strategy

### Semantic runtime conformance

Run the same fixed Signal Analyzer and smaller fixtures through dynamic and
static host runtimes. Compare structural identity behavior, state lifetime,
invalidation/coalescing, layout bounds, hit regions, action results, ordered
render operations, and deterministic overflow behavior.

### Layout contracts

Test proposal, intrinsic measurement, min/max/fixed/infinite frame behavior,
spacing, alignment, padding, stacks, overlays, spacers, coordinate arithmetic,
and capacity limits independently of a pixel backend.

### Render-boundary contracts

Replay golden normalized operation sequences through recording,
framebuffer/RGBA, RGB565 tile, and embedded display paths. Check clipping,
quantization, text metrics, line strokes, operation ordering, surface bounds,
and failure propagation.

### Backend, platform, and driver contracts

Test each backend against the render SPI, each platform adapter against its OS
event/presentation contract, and each driver against controller/transport
fixtures. Do not repeat all semantic tests for every driver.

### Capability resolution

Use table-driven composition fixtures to verify contribution precedence,
software fallbacks, impossible required combinations, non-Boolean constraints,
policy separation, deterministic diagnostics, and absence behavior.

### Supported-configuration integration

Validate the Signal Analyzer in progression:

1. macOS dynamic for rapid semantic and pixel triage;
2. macOS static for bounded composition and source invariance;
3. Raspberry Pi 1/Linux dynamic with framebuffer, PiScreen, and real input;
4. nRF52840 static with TFT and connected input/display hardware.

Hardware-free builds, host tests, simulators, and ELF/resource checks do not
substitute for connected-board evidence. Raspberry Pi validation must confirm
`armv6l`; nRF52840 firmware must retain the required hard-float ELF attributes.

### Dependency enforcement

Add package-graph or import-boundary tests that fail when portable layers
import concrete backends, platforms, drivers, OS/RTOS modules, or HALs. Static
builds should also prove that omitted optional facilities are not linked.

## Risks

- **The render vocabulary becomes a lowest-common-denominator API.** Keep it
  semantic enough to express required output, allow typed capability-specific
  extensions, and validate it against both framebuffer and embedded display
  paths before approval.
- **Logical layering causes excessive targets or abstractions.** Require a
  distinct package only when it enforces dependency ownership, enables reuse,
  or removes linked cost; permit static specialization and package flattening.
- **Dynamic and static behavior drifts.** Use shared semantic fixtures and
  compare resolved layout and render operations before backend-specific work.
- **Capability resolution becomes speculative.** Limit the MVP catalogue to
  real stack differences and treat future effects only as boundary examples.
- **Software fallbacks hide unacceptable cost.** Preserve realization and cost
  metadata, then let explicit policy choose within measured budgets.
- **Platform presets regain ownership.** Enforce downward imports and keep
  presets as composition roots with no new portable semantics.
- **Large inline static values move cost onto the stack.** Support
  caller-owned workspaces, inspect critical frames, and require stack
  high-water evidence on connected hardware.
- **A painter or native backend does not fit ordered operations.** Prototype a
  recording/painter adapter before freezing the render SPI; introduce a
  retained layer only with measured need.
- **Whole-root MVP rendering hardens into a permanent limitation.** Keep
  identity and invalidation ownership above rendering so later partial
  reconciliation does not change backend semantics.

## Open Questions

1. Should the RFC commit the MVP to the ordered render-operation sink as its
   only canonical IR, or should a lightweight retained render tree also be
   required now? A prototype comparing static RAM/copies and a painter-style
   adapter is needed before review closes this question.
2. Which logical boundaries require distinct SwiftPM targets in the first
   maintained architecture? A package-graph proposal should compare import
   enforcement and reuse against compile-time and code-size costs.
3. Does capability resolution happen entirely at target composition, or may
   some device facts change after initialization? The answer must distinguish
   immutable build/stack support from runtime device presence and failure.
4. What is the minimum typed MVP capability set? It should be derived from the
   four supported configuration fixtures, not from speculative renderer
   features.
5. Which layer owns text measurement, glyph resources, and rasterization while
   preserving identical layout across backends? Font metrics must be stable
   above the raster backend, but storage and pixel generation may need separate
   contracts.
6. How are errors propagated across semantic runtime, layout, render sink,
   backend, display, and transport boundaries in static and dynamic profiles?
   The policy must preserve deterministic failure without forcing exceptions
   or allocation on Embedded Swift.
7. What bounded geometry and scalar representation satisfies both the Signal
   Analyzer layout/drawing API and pixel-oriented embedded execution? Existing
   integer geometry is evidence, but Canvas arithmetic may require a reviewed
   fixed-point or floating-point contract.
8. Which existing product and source boundaries are adopted, adapted,
   replaced, retired, or temporarily bridged? This disposition should follow
   accepted ADRs and measurements, not be inferred from current names.

## Decision Summary

If this RFC is approved in substantially its proposed form, the following
architecturally significant choices should be extracted into separate ADRs:

1. GiftUI owns semantic UI and proposal-based layout above a backend-neutral
   render boundary; backends do not consume the view/runtime graph.
2. Static and dynamic runtimes are alternative storage and composition
   strategies beneath one portable declarative semantic model.
3. The MVP render boundary uses one normalized ordered operation vocabulary
   with direct streaming and optional retained storage, subject to resolution
   of Open Question 1.
4. Backends, display/input drivers, and transport/HAL integrations have
   separate ownership with strictly downward dependencies.
5. Supported platforms are target-host compositions or presets, not owners of
   cross-cutting GiftUI semantics.
6. Effective capabilities are resolved from typed contributions across the
   assembled stack and remain separate from runtime rendering policy.
7. The core layout model is proposal-based; a general constraint solver is an
   optional future facility rather than an MVP dependency.

Additional ADRs may be required for text ownership, error propagation,
geometry representation, package boundaries, and proof-of-concept module
disposition after the open questions are resolved.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [PROPOSAL-001: GiftUI MVP Baseline Charter](../proposals/proposal-001-giftui-mvp-baseline-charter.md)
- [RFC-001: Signal Analyzer Application Architecture](rfc-001-signal-analyzer-application-architecture.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md)
- [GiftUI Runtime Profile Migration Plan](../GiftUI_Runtime_Profile_Migration_Plan.md)
- [GiftUI Embedded Layer Inventory](../GiftUI_Embedded_Layer_Inventory.md)
- [GiftUI Raspberry Pi Platform](../GiftUI_Raspberry_Pi_Platform.md)
- [GiftUI nRF52840-DK Platform Specification](../GiftUI_nRF52840_DK_Platform_Spec.md)
- [GiftUI KMRTM24024 Stack Ownership Proposal](../GiftUI_KMRTM24024_Stack_Ownership_Proposal.md)
- Maintainer-provided architecture layers and boundaries attached to the RFC
  authoring request on 2026-08-14.
