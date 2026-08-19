---
id: RFC-002
feature: giftui-mvp-architecture
title: GiftUI MVP Layered Architecture
status: review
authors:
  - Yauheni Lychkouski
created: 2026-08-14
updated: 2026-08-19
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-001
  - RFC-003
  - RFC-004
  - RFC-005
  - RFC-006
  - RFC-007
related_adrs: []
related_specs: []
related_future_work:
  - FW-004
  - FW-005
  - FW-009
  - FW-010
  - FW-016
related_explorations: []
related_spikes: []
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
the backend boundary. The separate capability-system lifecycle must fit these
boundaries, but this RFC does not define capability physical ownership,
vocabulary, inputs, results, resolution, propagation, consumption, policy,
absence behavior, diagnostics, or the MVP catalogue.

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

GiftUI semantics therefore remain owned by GiftUI. Backends own rendering and
presentation, while sibling platform/input adapters normalize device events
for runtime admission. Neither interprets `View`, `VStack`, `Button`, state,
identity, or reconciliation. Hardware drivers own controller and transport
mechanics, but do not become GiftUI backends merely because they can display
pixels.

The target integration coordinates presentation eligibility with its sibling
physical-input path. It suppresses or defers input known to target a stale,
unavailable, or not-yet-eligible presentation before that input reaches the
runtime; device health does not become portable GiftUI semantics.

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

Those structures and the legacy documents in References are feasibility
evidence, not architectural input or authority. Existing code and product
names do not select the maintained boundaries. After this architecture passes
its approval gates, the proof of concept will be revised and fitted to the new
boundaries through downstream Specifications and migration work.

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

### R8 — Capability-system boundary

Any capability-system integration selected by the separately governed
capability lifecycle MUST preserve this RFC's dependency direction and MUST NOT
expose concrete backend, platform, driver, OS, RTOS, or hardware identity to
portable application code. RFC-002 does not require every layer to contribute
capability facts and MUST NOT define physical capability ownership, vocabulary,
inputs, results, resolution, propagation, consumption, policy, absence
behavior, diagnostics, or the MVP catalogue.

### R9 — MVP proportionality

Implementation required by this architecture MUST remain traceable to the
Signal Analyzer or to validation of an MVP stack. Boundaries MAY preserve
future extensibility, but unused backends, effects, solvers, drivers, or a
comprehensive capability catalogue MUST NOT be required for MVP completion.

### R10 — Testable contracts

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
- Logical ownership and prohibited imports MUST be enforced by an acyclic
  Swift target/module graph and dependency tests. The MVP distribution MUST
  use one Swift package containing multiple targets; a logical layer MAY use
  one or more targets. A target MUST NOT combine responsibilities when doing
  so introduces a prohibited dependency or makes an ownership boundary
  untestable. Alternative post-MVP package and distribution topologies are
  captured in FW-016.
- The active runtime profile, component graph, and layer implementations are
  immutable for an assembled MVP stack. Runtime device presence and failures
  are operational state handled through the run-cycle and failure contracts,
  not configuration mutation in this RFC.
- MVP layout and Canvas geometry use checked integer coordinates, dimensions,
  and scalar arithmetic. Fractional, floating-point, or fixed-point geometry
  is outside current scope and captured in FW-005.

## Proposed Design

### Swift package, product, target, module, and layer terminology

This RFC uses SwiftPM terms distinctly:

- A **Swift package** is the distribution and manifest boundary described by
  one `Package.swift` file.
- A **product** is a named library or executable that the package exposes to a
  client or host. A product is backed by one or more targets.
- A **target** is a SwiftPM build unit with declared source and target
  dependencies. The MVP package contains multiple library, executable, and
  test targets as needed by its supported platforms and profiles.
- A **module** is the compiler/import namespace produced by a Swift or Clang
  target in the MVP graph. This RFC writes `target/module` when the build-unit
  and import-boundary aspects are both relevant.
- A **logical layer** is an architectural responsibility boundary. It is not a
  package, product, target, or module by definition; its responsibilities may
  be implemented by one or more targets while preserving the required import
  direction.

For MVP distribution, GiftUI uses exactly one Swift package. That package
contains multiple targets and exposes the products needed by portable clients,
runtime profiles, backends, platform integrations, and supported hosts. Exact
product and target names remain downstream Specification work, except that the
portable client module and product remain named `GiftUI`.

### 1. Logical layers and dependency direction

The proposed architecture has seven vertical responsibility layers. The
separate capability-system lifecycle governed by RFC-006 must integrate with
this dependency graph without reversing it, but its physical ownership and
internal structure are outside this RFC:

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

RFC-006 owns whether the capability system uses a dedicated target, which
vocabulary or resolution mechanism it provides, and how results reach approved
consumers. RFC-002 requires only that those choices preserve this import
partial order: a portable or foundational contract must not import a runtime,
backend, platform, driver, OS/RTOS, HAL, or concrete integration merely to
describe an assembled stack, and concrete contributors must not acquire
upward dependencies on their consumers.

Environmental operations needed by an approved feature or runtime contract
must be supplied explicitly by the target host through the narrowest owning
contract. This RFC rejects ambient platform lookup and upward imports, but it
does not establish a universal Service catalogue or require a dedicated
Service package before a concrete consumer justifies one. RFC-007 and FW-009
preserve that postponed generalization.

Logical ownership is enforced at the narrowest dependency boundary that needs
compiler or import-test protection. For the MVP, distinct Swift targets and
modules inside the single GiftUI distribution package provide those
boundaries. A logical layer does not receive a separate package merely because
it is a layer, and the MVP does not split GiftUI into multiple packages.
Static specialization may erase runtime call overhead, but it may not reverse
the source-level import graph or move responsibilities into a target that
requires forbidden imports. FW-016 preserves post-MVP reconsideration when
distribution, versioning, toolchain, dependency, or measured build needs
justify a different topology.

`GiftUI` is the physical portable declaration module and the sole import
required by portable Presentation code, not an umbrella that re-exports
runtime, layout, render, backend, or integration implementations. Optional
dynamic conveniences remain a separate explicit import. `GiftUI` owns the
lowest portable values that must be shared by declarations and their
consumers: checked geometry/scalars, backend-neutral input values, and public
semantic declaration vocabulary. These values may use package-scoped
implementation detail, but they introduce no upward dependency. Hosts import
additional products explicitly.

### 2. Physical contract ownership and module DAG

The following physical ownership makes the cross-layer contracts acyclic.
Names other than the stable client module `GiftUI` are candidate maintained
module names; Specifications may refine a name or split an implementation
family without changing the listed owner or dependency direction.

| Contract family | Physical contract owner | Allowed dependency direction |
| --- | --- | --- |
| Public declarations, checked geometry/scalars, and normalized input values | `GiftUI` portable leaf module | Imports no runtime, layout, render, backend, platform, driver, OS/RTOS, HAL, or concrete capability implementation |
| Structural/action identity, state binding hooks, invalidation, hit maps, and semantic routing | `GiftUISemanticCore` | Depends on `GiftUI`; exposes no backend or integration type |
| Layout proposals, semantic-child adapter, measurement/placement results, and hit geometry | `GiftUILayout` | Depends on `GiftUI`; the runtime adapts semantic children to this consumer-owned contract, so layout does not import a runtime implementation |
| Render operations, resource identities, and one-shot ordered sink contracts | `GiftUIRenderCore` | Depends on `GiftUI`; imports no semantic-runtime, backend, platform, or driver implementation |
| Cycle/frame identity, frame envelope, admission, and synchronous handoff results | focused execution contract governed by RFC-004 | Depends on portable values and `GiftUIRenderCore`; both runtimes and backends depend on it rather than on each other |
| Cross-layer failure facts and composition-policy seam | focused failure contract governed by RFC-005 | Remains below its producers and coordinators; exact target placement follows RFC-005 without importing a concrete runtime or integration |
| Capability-system integration seam | Physical ownership governed by RFC-006 | Any resulting contract placement must preserve the partial order and must not require portable or foundational code to import concrete contributors or higher consumers |
| Runtime execution | `GiftUIRuntimeDynamic` / `GiftUIRuntimeStatic` | Depend on `GiftUI`, semantic, layout, render, execution, failure, and other separately approved cross-feature contracts; import no concrete backend |
| Backend frame consumption and surface contracts | `GiftUIBackend` | Depends on render, execution, failure, and portable geometry contracts; imports no semantic runtime |
| Raster, display-target, driver, and transport contracts | Narrow consumer-owned integration modules | Dependencies continue downward from render/backend to display target, controller, and transport/HAL; no upward semantic imports |
| Target host or preset | Composition root | May depend on all selected modules; exports no new portable semantics |

The critical import partial order is therefore (an arrow means “depends on”):

```text
target host
    |-> runtime profiles
    |       |-> GiftUISemanticCore -> GiftUI
    |       |-> GiftUILayout -------> GiftUI
    |       |-> GiftUIRenderCore ---> GiftUI
    |       |-> execution ----------> GiftUIRenderCore
    |       \-> failure contract
    |-> GiftUIBackend
    |       |-> execution / failure
    |       \-> GiftUIRenderCore ----> GiftUI
    |-> input adapter -> execution + GiftUI
    \-> raster/display -> GiftUIBackend -> driver -> transport/HAL
```

The diagram omits secondary downward imports and the capability-system edges
governed by RFC-006. Any such edges must fit this partial order without causing
a portable or foundational contract to import a concrete contributor or
higher consumer. In particular, runtime profiles may import layout and render
contracts directly, while platform input adapters import only `GiftUI`
normalized event values plus the
execution admission contract. No arrow points from a portable contract toward
a concrete implementation.

### 3. Cross-layer contract matrix

The matrix below makes the proposed boundary obligations reviewable without
selecting final Swift declarations. It is normative at the architectural
level if this RFC is approved: a downstream Specification may refine names,
representations, capacities, and visibility, but may not reverse ownership,
extend lifetime, introduce an unbounded static obligation, or change failure
direction without further architecture review.

The visibility classes used here are:

- **Client API** — imported by portable application Presentation code;
- **Host API** — used by the target composition root, never by portable views;
- **Framework SPI** — shared between GiftUI targets/modules or runtime profiles
  but not intended as ordinary application surface;
- **Integration SPI** — implemented by backends, platforms, drivers, or HALs;
- **Tooling** — build-time or diagnostic consumption only.

Exact access control, target names, and representation remain Specification
work within the physical owners and partial order established above.

#### Contract meaning and authority

| ID | Producer -> consumer | Contract payload or operation | Semantic authority and prohibited knowledge |
| --- | --- | --- | --- |
| B1 | Portable application declaration -> semantic runtime | Root `View` declaration, fixed child composition, ordered modifiers, primitive semantic values, and client actions | `GiftUI` physically owns the declaration vocabulary. GiftUI client semantics are authoritative. Declarations expose no runtime profile, backend, platform, driver, OS, RTOS, HAL, or hardware identity. The runtime may evaluate declarations but may not reinterpret target mechanics as client semantics. |
| B2 | Target host -> assembled GiftUI runtime | Selected runtime profile, component implementations, capacities, approved cross-feature configuration inputs, explicit consumer-owned environmental contracts, and product policy | The host is the sole composition root. Portable views and lower components neither discover implementations nor mutate the assembled graph. |
| B3 | Semantic runtime -> layout subsystem | Semantic child access through the `GiftUILayout`-owned adapter contract, structural identity needed for caches, proposed size, layout-relevant environment, intrinsic-measurement requests, and bounded workspace | The runtime owns semantic identity and staged state; `GiftUILayout` owns its input/output contract plus measurement and placement rules. Layout receives no backend, surface, pixel-format, platform, or device knowledge and does not import a runtime implementation. |
| B4 | Layout/text subsystem -> font-resource contracts and glyph workspace | Canonical font identity, metric/shaping view, text input, bounded line/glyph workspace, and positioned glyph results | RFC-003 owns exact text authority. Layout owns text geometry; raster providers and backends may not remeasure, reshape, substitute a face, or change line placement. |
| B5 | Layout and semantic lowering -> render core | Resolved geometry, portable paint/drawing intent, positioned text, ordered opaque rectangle and line operations, clip/damage geometry where required, and stable resource identities | `GiftUIRenderCore` owns normalized operation meaning and transport. It receives no `View`, container, state-storage, reconciliation, hit/action map, platform handle, or concrete backend object. Runtime-owned hit geometry is a parallel revision artifact and never enters the render payload. |
| B6 | Render core/runtime coordinator -> backend SPI | Stable frame identity and provenance, frame offer, ordered render payload, resource references, coordinate/surface facts, and presentation request | RFC-004 owns frame transaction semantics. A backend executes and presents operations; it does not evaluate views, perform GiftUI layout, mutate semantic state, invoke client actions, or request semantic replay. |
| B7 | Backend -> rasterizer or memory-surface contract | Normalized drawing operations, clip/damage region, target pixel mapping, raster resources, and bounded pixel/tile workspace | Rasterization owns conversion to pixels, not GiftUI semantics or OS/device mechanics. Pixel quantization and storage format must not feed back into semantic measurement. |
| B8 | Backend/presentation adapter -> display-target contract | Surface geometry, native format, write region/window, pixel payload, submission identity, and presentation request | The backend owns presentation strategy and post-handoff recovery; the display target owns device-facing submission mechanics. Neither side owns semantic commit or action dispatch. |
| B9 | Display-controller driver -> transport/HAL implementation | Controller commands, address windows, borrowed or transferred byte buffers, timing requirements, GPIO/SPI/DMA operations, and transaction identity | The controller driver owns controller protocol and state. The transport/HAL owns bus, RTOS, interrupt, and vendor mechanics and imports no GiftUI semantic or render-operation types. |
| B10 | Platform/input driver adapter -> semantic runtime admission | `GiftUI`-owned backend-neutral pointer/touch value, logical coordinates, phase, stable source/event identity where required, and bounded ordering metadata | Drivers own sampling, calibration, interrupts, evdev, or mouse records; a sibling input/platform adapter owns normalization and feeds the RFC-004 admission contract only after B16 presentation eligibility permits it. Input does not enter through the render-oriented `GiftUIBackend` SPI. The runtime owns hit testing, disabled-state enforcement, and semantic routing; producers never invoke client actions directly. |
| B11 | Semantic runtime -> portable client action/state boundary | Hit-test result, semantic action identity, ordered handler invocation, state mutation, invalidation, and resulting semantic revision | The runtime owns action ordering, reentrancy, state lifetime, and invalidation. Backends, drivers, environmental adapters, and diagnostics cannot mutate application state or dispatch handlers. The separate observable-state lifecycle must define the public state contract. |
| B12 | Selected components -> separately governed capability-system boundary | Any contribution payload, vocabulary, and resolution input are defined solely by RFC-006 | The integration must not require a contributor to import a higher consumer or unrelated concrete component. RFC-002 does not decide whether contributions, Traits, a resolver, or another mechanism exists. |
| B13 | Separately governed capability-system boundary -> approved consumers | Any result, propagation, policy, or absence behavior is defined solely by RFC-006 | The integration must not expose concrete backend, platform, driver, OS/RTOS, HAL, or hardware identity to portable application code or reverse this RFC's dependency direction. |
| B14 | Framework consumer -> explicit environmental contract | Only the operation required by an approved consumer, such as a host wake request or diagnostic submission | The consumer RFC or Specification owns the operation semantics. The host supplies the implementation; environmental code cannot mutate semantics, admit input directly, or become capability or policy authority. A shared Service abstraction is deferred by FW-009. |
| B15 | Any pre-handoff operational layer -> runtime failure boundary; any layer -> diagnostic support | Typed bounded failure fact, originating boundary/phase, stable cycle/frame/context identities, and optional diagnostic record | RFC-005 owns pre-handoff propagation and optional diagnostic observation. Post-handoff presentation facts remain below Core and cannot change logical-frame disposition. Diagnostics have no control-flow authority. |
| B16 | Presentation integration -> sibling physical-input admission gate | Committed frame provenance, backend-local presentation eligibility/health, and the minimum bounded state needed to suppress or defer input known to target a stale, unavailable, or not-yet-eligible presentation | RFC-004 owns the coherence rule. Target integrations coordinate presentation and physical input without exposing device/transport failure as GiftUI semantics, rolling back committed state, replaying work, or invoking handlers. |

#### Ownership, lifetime, and synchronization

| ID | Ownership and valid lifetime | Invocation and synchronization model |
| --- | --- | --- |
| B1 | Application view values are transient. The runtime owns any derived identity and persistent state separately; it must not retain borrowed declaration storage beyond its declared evaluation lifetime. | Runtime-directed synchronous evaluation inside a sealed cycle. Dynamic conveniences may erase syntax mechanically but may not change observable ordering or permit concurrent semantic mutation. |
| B2 | The host owns selected implementations and long-lived storage. Profile, component graph, capacities, approved cross-feature configuration state, explicitly supplied environmental contracts, and policy are immutable for the assembled runtime lifetime. | Construction and validation complete before the first cycle. Runtime operational state may change only through admitted inputs and outcomes, not graph mutation. |
| B3 | Inputs are borrowed from cycle-stable semantic state. Layout results and hit geometry are owned by staged runtime/frame state for at least the lowering and hit-test lifetimes defined by RFC-004. Cache lifetime is explicit and cannot affect results. | Synchronous, deterministic measurement and placement within a cycle. Layout does not call a concrete backend or accept asynchronous mutation. |
| B4 | Font packages and identities are immutable assembly resources. Text, line, glyph, and shaping workspaces are explicitly borrowed or caller-owned for a declared cycle/frame scope; no implementation may assume heap retention. | Deterministic layout-time resolution and shaping. Raster acquisition may occur later but cannot change positioned geometry. Exact streaming/borrowing rules remain with RFC-003. |
| B5 | Resolved values are cycle-stable. Operations and their borrowed resources are valid only during the synchronous one-shot sink call and cannot be retained or replayed by the backend. The separate runtime-owned hit map outlives every input routed against its committed revision. | Ordered emission after layout. Producers cannot concurrently mutate staged semantics or resources while operations are consumed. Hit-map publication follows RFC-004 but is not operation-sink traffic. |
| B6 | Every first-party MVP backend consumes the one-shot ordered operation stream synchronously during frame offer. Before accepting, it reserves bounded capacity and retains or transfers only backend-owned derived pixel, transfer, or device data. Refusal retains nothing. | Frame offer and logical commit-or-abort are synchronous. Presentation may continue asynchronously below the handoff boundary; its outcomes do not re-enter Core to alter frame disposition or call semantic code. |
| B7 | Backend or caller owns bounded raster scratch, tiles, and surfaces. Borrowed operation/resource data is valid only for the declared draw call; caches have explicit assembly/frame lifetime and cannot change output. | Synchronous operation execution for the MVP path unless a later backend contract explicitly transfers ownership. Raster work cannot race semantic or layout mutation. |
| B8 | Buffer and pixel-payload ownership is explicit per submission: borrowed data must complete synchronously; asynchronous submission requires transferred or independently stable storage for its backend-local lifetime. | Submission may complete synchronously or asynchronously. Downstream completion and failure remain local to presentation recovery, input gating, and optional diagnostics. |
| B9 | Driver owns controller state and transaction metadata. Buffer ownership is borrowed for synchronous transfer or explicitly transferred until completion; interrupt code may retain only declared stable tokens/storage. | Transfers may be synchronous, DMA-driven, interrupt-driven, or polled. Asynchronous effects feed only lower-layer state, presentation/input coordination, or optional diagnostics; they never callback into semantics. |
| B10 | Raw platform records remain below the adapter. Normalized events are copied or moved into a bounded admission queue and then into one sealed cycle batch. Hit regions used for routing belong to a committed semantic/layout revision. | Producers may be asynchronous or interrupt-driven; runtime consumption is serialized at the next admission boundary. Equal-order and coalescing rules must be deterministic. |
| B11 | Runtime owns action maps and state slots for their declared structural lifetime. Client handlers receive only public values/Bindings whose lifetime cannot expose runtime storage unsafely. | Dispatch is serialized within the active cycle. Reentrant external input is queued for a later cycle; disabled actions are suppressed before handler invocation. |
| B12 | Ownership and lifetime of any capability-system input are governed by RFC-006. RFC-002 requires only that the seam not retain a concrete higher-layer consumer or create an upward import. | Invocation and synchronization are governed by RFC-006 and must fit the immutable assembled component graph. |
| B13 | Ownership and lifetime of any capability-system result are governed by RFC-006. | Consumption must not require portable application code to probe concrete contributors or target identity. |
| B14 | The host owns each concrete environmental adapter for the assembled runtime lifetime. Tokens and pending requests have the bounds and lifetime defined by their consumer contract; diagnostic payloads are copied or synchronously consumed. | Calls originate at the boundary defined by the owning consumer. Wakeups and asynchronous completions re-enter through bounded admission rather than arbitrary callbacks. |
| B15 | A cycle owns its bounded pre-handoff failure accumulator until disposition. Diagnostic sinks may consume synchronously or copy bounded records. Backend-local post-handoff health retains only the provenance its local policy needs. | Control-flow failure propagation is synchronous through handoff. Post-handoff diagnostics are best effort and never block correctness or alter committed frame state. |
| B16 | The target presentation/input integration owns bounded local eligibility and health state for the accepted frames it advances. No Core completion queue is required for that state. | Presentation completion may be asynchronous, but the integration locally sequences it with physical input and suppresses or defers input known not to correspond to an eligible presentation. |

#### Failure, bounds, visibility, and conformance evidence

| ID | Failure and static-bound obligation | Intended visibility | Minimum independent evidence |
| --- | --- | --- | --- |
| B1 | Unsupported portable-profile operations are absent at compile time or return an explicit bounded failure; declaration expansion and state/action capacity exhaustion are deterministic. | Client API plus framework SPI for evaluation | Compile the same portable Signal Analyzer hierarchy for dynamic and static profiles; compare expansion order, identity, state lifetime, action results, and overflow fixtures. |
| B2 | Invalid component combinations, missing required approved contracts, or insufficient capacities prevent runtime start with bounded validation output. | Host API | Assembly fixtures for all four MVP configurations, plus negative fixtures proving prohibited or under-capacity graphs fail before cycles begin. |
| B3 | Layout returns complete geometry or a structured failure; it never exposes partial geometry as complete. Bounds cover traversal depth, nodes, proposals, caches, hit regions, coordinates, and arithmetic overflow. | Framework SPI | Backend-free layout fixtures for all MVP containers/modifiers and Signal Analyzer geometry, including identical cross-profile results and every capacity edge. |
| B4 | Unsupported input, package mismatch, workspace exhaustion, malformed resources, and numeric overflow follow RFC-003/RFC-005; no fallback may silently change geometry. | Client API for text request; framework/tooling contracts for packages and layout | Golden canonical text geometry, package integrity, dynamic/static workspace exhaustion, and exact-face raster-provider conformance. |
| B5 | Operation or resource exhaustion fails explicitly; an ordered stream is never silently truncated. Bounds cover operation payload, clip depth, paths/segments, resources, and identifiers. Hit-map capacity is a B3/B11 runtime obligation, not render storage. | Framework SPI | Golden one-shot operation sequences, recording-sink validation, malformed-resource tests, deterministic overflow at every sink boundary, and instrumentation proving no backend retains borrowed operations or resources. |
| B6 | Complete accepted handoff commits the logical frame; preparation failure or handoff refusal aborts it. Post-handoff presentation failure never changes that disposition, rolls back semantic state, or causes semantic replay. Backend-owned downstream slots and presentation data are bounded. | Integration SPI | Recording/checking backend contract suite, all-or-nothing offer fixtures, backpressure/refusal tests, post-handoff fault injection, and derived-presentation-data lifetime instrumentation. |
| B7 | Unsupported operations, invalid resources, clipping/coordinate overflow, tile/surface exhaustion, and pixel conversion failures are explicit frame-attempt outcomes. Scratch, cache, tile, and surface storage are bounded on static targets. | Integration SPI | The same golden operations through recording, host pixel-surface, framebuffer, and RGB565 tile implementations, with bounds and guard-region checks. |
| B8 | Invalid geometry/format, insufficient reserved capacity, or synchronous submission refusal prevents handoff acceptance. Disconnection, partial presentation, and downstream failure after acceptance remain bounded local health/recovery conditions. | Integration SPI | Fake display-target fault injection plus Raspberry Pi and nRF52840 connected-display evidence for all-or-nothing handoff and local post-handoff behavior. |
| B9 | Bus/controller timeout, invalid state, short transfer, and device failure update bounded backend-local health/recovery and may emit optional diagnostics; they do not reopen the frame transaction. Command, transfer, DMA, and interrupt queues are bounded. | Integration SPI | Controller fixtures over fake transports, transfer-boundary fault injection, input-gating checks, ELF/resource checks, and connected-device evidence without claiming semantics from hardware-free tests. |
| B10 | Malformed samples, coordinate overflow, queue exhaustion, and unsupported event forms have deterministic drop/failure/diagnostic behavior. Event queues, batch size, source count, and identifiers are bounded. | Integration SPI feeding framework SPI | Adapter fixtures for mouse/host, evdev, and embedded touch; ordering, calibration, overflow, disabled-hit, and revision-correlation tests independent of a pixel backend. |
| B11 | Missing/stale action identity, disabled action, handler failure, state-slot exhaustion, and reentrant input have explicit behavior; action/state slots and queued invalidations are bounded. | Client API plus framework SPI | Cross-profile fixtures for identity change, state preservation/removal, disabled controls, ordered actions, reentrancy, coalescing, and deterministic exhaustion. |
| B12 | Failure, bounds, visibility, and evidence for capability-system inputs are governed by RFC-006. | Visibility governed by RFC-006 | Dependency tests prove that supplying any approved input does not add an upward or concrete cross-component import. |
| B13 | Failure, bounds, visibility, and evidence for capability-system results are governed by RFC-006. | Visibility governed by RFC-006 | Dependency tests prove that consuming any approved result does not expose concrete target identity to portable application code or reverse the module partial order. |
| B14 | Every approved environmental contract defines bounded failures, lifetime, and re-entry behavior; correctness never depends on diagnostic delivery. | Host API and the owning consumer SPI | Consumer-specific deterministic fakes and target adapters; no common Clock/Scheduler/Sink catalogue is required by this RFC. |
| B15 | Every non-local failure is classified and propagated; context or diagnostic exhaustion cannot replace the primary failure. Record width, context depth, secondary failures, and sink capacity are bounded. | Framework/integration SPI; Tooling for symbolization | Phase-by-phase fault injection across semantic, layout, render, backend, display, and transport boundaries, with and without a diagnostic sink. |
| B16 | Input known to target a stale, unavailable, or not-yet-eligible presentation is not admitted as current GiftUI input. Local eligibility state and deferred-input capacity are bounded with deterministic overflow behavior. | Integration SPI below framework admission | Presentation/input fixtures covering delayed completion, failure, recovery, rapid accepted frames, stale physical events, gating saturation, and targets that cannot claim interactive coherence. |

The evidence column identifies the smallest contract fixture for each boundary;
it does not replace the supported-configuration progression or connected-board
evidence required by the Testing Strategy.

### 4. Public declarative API

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

### 5. Semantic runtime and state

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

### 6. Layout and geometry

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
hierarchy. Its geometry uses checked integer coordinates, dimensions, and
scalar arithmetic, including the MVP Canvas line operations. A generic
constraint solver is a separate optional facility and is not part of the MVP
dependency graph.

Layout geometry remains backend-neutral. Pixel quantization, rotation, stride,
color conversion, controller write windows, and physical transfer regions do
not influence semantic measurement. A backend may clip or damage resolved
geometry but may not recompute GiftUI layout semantics.

### 7. Backend-neutral render plan

After layout, GiftUI lowers semantic content and resolved geometry into a
small vocabulary of render operations. The proposed MVP vocabulary includes
concepts equivalent to:

```text
fill opaque rectangle
draw text run
stroke line path with opaque color and bounded stroke style
push/pop rectangular clip, if required by selected MVP backends
```

Exact cases, integer widths, ownership, and public visibility belong in a
later Specification. The representation carries what must appear and where;
it does not carry `View`, `VStack`, `Button`, state storage, or platform
handles.

The MVP canonical IR is an ordered render-operation sink. This permits two
materialization strategies without changing operation semantics:

- static runtimes emit directly into a bounded backend or caller-provided sink;
- dynamic runtimes may collect the same operations into an array-backed
  display list for replay, inspection, damage calculation, or testing.

No retained render tree is required for MVP. The operation vocabulary and its
producer/consumer boundary MUST nevertheless remain independent of direct
stream lifetime: frontend and layout code lower resolved content through the
same render-plan contract, while a future retained representation may become
an alternative internal producer of the ordered operations. Inserting that
producer MUST NOT require a new declarative, semantic-runtime, or layout
contract. Resource identities and operation meaning therefore cannot depend
on a particular backend object or on the array-versus-stream storage choice.
Keeping one canonical operation IR now minimizes static RAM, copying, code
size, and dual-representation conformance work. The retained-tree possibility
and its revisit triggers are captured in
[FW-004](../future-work/fw-004-retained-render-tree.md).

### 8. Backend SPI and implementations

The backend SPI consumes resolved frame information and ordered render
operations, then presents a frame. It should be decomposed by responsibility
rather than exposed as one protocol containing every future facility.

The MVP needs contracts equivalent to:

- surface size and pixel/coordinate mapping;
- frame begin, operation consumption, and frame end/presentation;
- opaque rectangle, text, and line-stroke support;
- damage or partial-write information only where an MVP backend needs it.

Input normalization is the sibling B10 integration seam rather than a method
on the render-oriented backend SPI. A combined platform preset may assemble
both, but that convenience does not merge their ownership.

Optional backend contracts are defined only when their governing feature and
capability lifecycles require them. A backend is not forced to provide
meaningless methods or runtime traps for facilities outside its contract.

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

### 9. Display drivers, input drivers, and HAL

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

### 10. Configuration and composition

A supported configuration is the combination of:

1. build constraints and runtime profile;
2. selected component implementations and capacities; and
3. the immutable dependency graph connecting those components.

The selected profile, implementations, capacities, and dependency graph do not
change after the MVP stack is assembled. Runtime device presence, disconnects,
and failures are operational state below RFC-004's accepted handoff and may
produce optional RFC-005 diagnostics; they do not mutate the assembled
architecture or Core's committed frame. What those facts mean as capabilities
belongs to the separate capability-system lifecycle.

The target host is the composition root. Dynamic hosts may use erased runtime
selection where allowed. Static hosts should prefer generic or generated
composition so unsupported combinations fail during compilation and do not
require runtime discovery. Both strategies assemble the same logical
contracts.

Named platform products, when useful, are convenience presets. For example, a
Raspberry Pi preset may select the dynamic runtime, Linux framebuffer backend,
evdev input, and Pi-specific GPIO adapter. It does not own their semantics and
must not be imported by portable views or GiftUI core modules.

### 11. Capability-system seam

Capability-system definition is outside this RFC.
[RFC-006](rfc-006-capability-system-architecture.md) owns physical contract
placement, vocabulary, contribution and resolution mechanisms, propagation,
consumption, absence behavior, policy relationship, diagnostics, and the MVP
catalogue. RFC-002 neither selects a capability target nor requires Traits, a
resolver, an effective snapshot, or a client projection.

This RFC supplies only the layering constraints that work must respect:

- capability work must not move semantic ownership into backends or drivers;
- portable code must not depend on concrete target identity;
- any participating module must remain within the approved partial order
  without importing a higher consumer or unrelated concrete integration;
- portable application code must not acquire concrete target identity through
  the capability seam; and
- capability mechanisms selected by RFC-006 must fit both the immutable,
  statically composed MVP stack and the shared portable client model.

No statement in this RFC about a component, format, operation, capacity, or
runtime profile should be interpreted as defining a capability type or
resolution rule.

### 12. Frame and event flow

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

[RFC-004](rfc-004-run-cycle-and-frame-transaction.md) focuses this flow into a
sealed run-cycle and frame-transaction model. Every first-party MVP backend
consumes the ordered operation stream once during synchronous frame offer; an
asynchronous presentation path may retain only backend-owned derived data.
This preserves the render-operation boundary without imposing a retained
display list or replay storage on any MVP profile.

## Module Responsibilities

| Logical module or family | Responsibility | Dependency impact |
| --- | --- | --- |
| `GiftUI` | Portable declarations, checked geometry/scalars, normalized input values, and sole import required by portable Presentation | Portable leaf module; imports no runtime, layout, render, backend, platform, driver, OS/RTOS, HAL, or concrete capability implementation and does not re-export those implementations |
| `GiftUIDynamicConveniences` | Heap-backed strings, closure actions, and other opt-in dynamic syntax | Depends only on portable GiftUI contracts and supported dynamic facilities |
| `GiftUISemanticCore` | Portable semantic traversal, identity, state, invalidation, reconciliation, hit-region, and action-routing contracts | Depends on the public declaration/geometry layer; imports no concrete runtime, layout implementation, renderer, or integration |
| `GiftUILayout` | Proposal-based measurement, placement, semantic-child adapter, cache contracts, resolved geometry, and hit geometry | Depends on `GiftUI`; owns the B3 consumer contract and imports no runtime implementation, render, backend, or platform integration |
| `GiftUIRenderCore` | Normalized operations, one-shot ordered sinks, bounded producer workspace, resources, and frame metadata | Depends on resolved geometry and portable resource contracts; exposes no semantic view types to backends |
| RFC-004 execution contract module | Cycle/frame identities, admission, frame envelope, and synchronous handoff results | Depends on portable/render contracts; both runtimes and backends depend on it without depending on each other |
| RFC-005 failure contract module | Cross-layer failure facts and composition-policy seam | Sits below producers and coordinators; imports no concrete runtime, backend, platform, or driver implementation |
| `GiftUIRuntimeDynamic` / `GiftUIRuntimeStatic` | Profile-specific semantic storage and execution | Each coordinates semantic, layout, render, execution, failure, and other separately approved cross-feature contracts; neither imports a concrete backend |
| `GiftUIBackend` | Frame acceptance, operation consumption, presentation, and surface contracts | Depends on render/execution/failure and portable geometry contracts; contains no application or semantic-runtime ownership and does not own input normalization |
| `GiftUIRaster` | Converts normalized operations into pixels or bounded tiles | Depends on backend/render and pixel-surface contracts, not Linux or a controller |
| Framebuffer backend targets | Present raster output to memory-surface contracts | Depend on render/raster and surface contracts, not a specific OS |
| Platform input adapter targets | Normalize mouse, evdev, or touch-driver records into `GiftUI` input values, apply target-local B16 presentation eligibility, and feed RFC-004 admission | Sibling of render backends; depend on portable input/execution contracts and target-local coordination, never semantic-runtime implementations |
| Linux integration targets | Own framebuffer mapping, discovery, presentation, evdev adaptation, and other Linux mechanics | Compose backend and sibling input contracts with OS adapters; never imported by portable GiftUI layers |
| Embedded display backend targets | Convert operations into bounded raster regions and display-target writes | Depend on render/raster, backend SPI, and display-target contracts |
| Display/input driver targets | Implement controller operations, calibration, and device input | Depend on device and transport contracts, not semantic GiftUI types |
| Transport/HAL targets | Own SPI, GPIO, timing, DMA, RTOS, and OS mechanics | Lowest integration boundary; import no GiftUI semantics |
| Target host/preset targets | Select the immutable runtime, capacities, backend, drivers, and event-loop integration | Composition roots may depend on every selected layer but export no new portable semantics |

Except for the stable client module `GiftUI`, the names above are candidate
maintained names. Downstream Specifications may refine names and target
grouping, or split an implementation family, while preserving the contract
owner, import partial order, and independently testable boundaries. A single
SwiftPM distribution package contains these MVP targets.

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

Existing proof-of-concept declarations and implementations will be evaluated
against those contracts and revised, moved, or replaced as needed. Current
names and source placement create no compatibility presumption and do not
influence the new dependency graph.

No stable public ABI is proposed for MVP. Public source compatibility should
be measured and migration notes supplied for renamed, moved, or restricted
APIs.

## Capabilities Impact

Capability-system definition is not part of this RFC. This architecture only
requires RFC-006's selected integration to preserve the module partial order,
avoid upward or concrete cross-component imports, and keep target identity out
of portable application code. Physical ownership, vocabulary, inputs, results,
resolution, propagation, consumption, catalogue, policy, and absence behavior
belong to RFC-006. Delegated environmental operations remain with their
approved consumer contracts. RFC-007 preserves a
possible shared foundation but is paused through FW-009. Until RFC-006 passes
its gates, RFC-002 must not be read as Capability authority.

## Backend Impact

Backends will consume a normalized render plan instead of the semantic view
graph. This keeps them replaceable and makes recording, framebuffer, Linux,
embedded-display, and future painter-style backends comparable at one
boundary.

Existing proof-of-concept backend, platform, display, input, and simulator code
must be fitted to the approved target boundaries rather than used to derive
them. Downstream migration work will move, split, adapt, or replace that code;
proof-of-concept product names carry no ownership or compatibility authority.

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

The distinct module targets may link into one firmware image and generic
specialization may erase abstraction overhead. Link-time flattening does not
permit dependency inversion or source-level ownership leaks.

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

The module graph may increase module metadata, generic specialization, build
graph, and cross-module optimization costs. Keeping the targets in one SwiftPM
distribution package avoids a manifest per layer while retaining compiler-
checked imports. Release and embedded builds must measure the remaining costs
and enable whole-module and link-time optimization where supported. A measured
cost may justify refining a boundary through a new RFC/ADR; it does not
authorize silently moving responsibilities across an ownership boundary.

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

### Alternative G — One package with one undifferentiated target

GiftUI could distribute one product backed by one target containing portable
declarations, runtimes, layout, rendering, backends, platforms, and device
integrations. This would minimize manifest structure and explicit target
dependencies.

It would also erase compiler-enforced import boundaries inside the package,
permit platform or backend dependencies to leak into portable code, and make
the proposed ownership graph difficult to test. It is preferable only if the
MVP abandons those ownership boundaries, which would contradict this RFC's
core direction.

### Alternative H — Multiple independently distributed Swift packages

GiftUI could place logical families in separate Swift packages, each with its
own manifest, products, targets, dependency graph, and potentially independent
release lifecycle. This can strengthen distribution isolation, permit
independent versioning, or accommodate different toolchain and dependency
requirements.

For MVP it adds manifest, dependency-resolution, release, integration, and
cross-package testing overhead without an accepted distribution requirement.
It becomes preferable when an independently consumed component, incompatible
toolchain boundary, dependency cycle, release/versioning requirement, or
measured build problem cannot be handled cleanly by multiple targets in the
single package. FW-016 preserves that reassessment.

## Rejected Approaches

For the proposed MVP direction, Alternatives A and C are rejected because
backends must consume the ordered render-operation IR rather than semantic
views. Alternative B is rejected as an MVP requirement because a retained
tree adds a second representation and bounded-storage problem; it remains
preserved as FW-004. Alternative D is rejected because static and dynamic
profiles share one portable semantic model. Alternative E is rejected because
platform modules are compositions rather than semantic owners. Alternative F
is rejected because the Signal Analyzer does not justify a general solver.

Alternative G is rejected because one undifferentiated target/module would
erase the compiler-enforced import boundaries required by the maintained MVP
architecture. Alternative H is not selected for MVP: GiftUI is distributed as
one Swift package whose multiple targets/modules enforce the dependency graph.
Multiple packages are not rejected permanently; FW-016 preserves the
post-MVP decision and its evidence triggers.

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

### Package and module compatibility

Existing product names other than `GiftUI` are not architectural authority.
Migration will split, move, adapt, or replace current code so the target/module
graph enforces the approved partial order. The MVP uses one SwiftPM
distribution package with multiple targets and the products needed to expose
approved client, host, and integration modules. Portable application code
continues to depend only on and import `GiftUI`.

### ABI and data compatibility

The MVP does not promise ABI stability or persistent UI data formats. Render
operations should initially be versioned through source contracts and
conformance tests rather than serialized interchange formats.

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

### Supported-configuration integration

Validate the Signal Analyzer in progression:

1. macOS dynamic for rapid semantic and pixel triage;
2. macOS static for bounded composition and source invariance;
3. Raspberry Pi 1/Linux dynamic with framebuffer, PiScreen, and real input;
4. nRF52840 static with TFT and connected input/display hardware.

Hardware-free builds, host tests, simulators, and ELF/resource checks do not
substitute for connected-board evidence. Raspberry Pi validation must confirm
`armv6l`; nRF52840 firmware must retain the required hard-float ELF attributes.

Implementation and conformance work must collect bounded aggregate evidence
for B3-B16 on the nRF52840 configuration, including identity and queue
representation, workspace ownership, stack high-water, and linked RAM/flash.
Specifications set exact widths and capacity values. This evidence is not an
RFC approval blocker; if it demonstrates that the proposed ownership,
lifetime, or dependency boundaries are infeasible, affected implementation
must stop and return the conflict to RFC/ADR review rather than weakening the
boundary in a Specification or in code.

### Dependency enforcement

Add target-graph and import-boundary tests that fail on an upward import, on a
target grouping that makes a prohibited import possible, and when portable
layers import concrete backends, platforms, drivers, OS/RTOS modules, or HALs.
Static builds should also prove that omitted optional facilities are not
linked.

## Risks

- **The render vocabulary becomes a lowest-common-denominator API.** Keep it
  semantic enough to express required output and validate it against both
  framebuffer and embedded display paths before approval.
- **Module boundaries increase build or binary cost.** Measure incremental
  builds, release code size, metadata, and cross-module specialization; use
  one distribution package and link-time optimization without reversing the
  target import graph.
- **Dynamic and static behavior drifts.** Use shared semantic fixtures and
  compare resolved layout and render operations before backend-specific work.
- **The separate capability RFC conflicts with these boundaries.** Treat
  RFC-002's dependency direction and non-inversion rules as constraints on
  RFC-006. Reconcile RFC-006 before it advances if its proposed integration
  violates them; do not embed capability semantics in RFC-002.
- **Platform presets regain ownership.** Enforce downward imports and keep
  presets as composition roots with no new portable semantics.
- **Large inline static values move cost onto the stack.** Support
  caller-owned workspaces, inspect critical frames, and require stack
  high-water evidence on connected hardware.
- **A painter or native backend does not fit ordered operations.** Revisit
  FW-004 when a concrete backend or measurement meets its trigger; the MVP
  does not add a retained layer speculatively.
- **Whole-root MVP rendering hardens into a permanent limitation.** Keep
  identity and invalidation ownership above rendering so later partial
  reconciliation does not change backend semantics.

## RFC Decomposition Assessment

The matrix has been reviewed using the repository's independently reviewable
decision-cluster criteria. It does not justify another RFC merely for a layer
or interface:

| Matrix scope | Governing artifact | Why no additional RFC is needed |
| --- | --- | --- |
| B1-B3, B5, and B7-B10 | RFC-002 | Declarative-to-layout lowering, normalized rendering, backend/display separation, and sibling input admission are the core dependency-direction decision. Splitting them would make each draft depend on the others to remain coherent. |
| B4 | RFC-003 | Text geometry and exact resource identity have independent alternatives and evidence, so the existing focused RFC remains justified. |
| B6 and B16 | RFC-004 | Cycle ordering, synchronous handoff, frame lifetime, logical commit, and lower presentation/input coherence form one independent execution decision cluster. |
| B15 and the failure aspects of all rows | RFC-005 | Explicit outcomes, policy ownership, and diagnostic independence are independently reviewable across every layer. |
| B12-B13 | RFC-006 under PROPOSAL-004 | Capability physical ownership, vocabulary, inputs, results, resolution, propagation, consumption, policy, and absence behavior have a separate accepted problem, alternatives, and evolution path. RFC-002 retains only dependency-direction and non-inversion constraints. |
| B14 | Consumer RFC or Specification; RFC-007/FW-009 preserve generalization | No common Service foundation is justified until multiple approved consumers demonstrate shared semantics or a dependency problem. |
| B11 public observable state | Separate feature lifecycle required by MVP Scope | RFC-002 fixes runtime ownership and the publication seam but cannot select the public state architecture. |
| Canvas public drawing semantics used by B5 | Separate feature lifecycle required by MVP Scope | RFC-002 fixes the render-layer placement of resolved drawing intent; the public Canvas/Path contract requires its own accepted Proposal before an RFC. |

Declarative composition, layout, the non-text render vocabulary, backend SPI,
display/driver separation, and pointer/touch admission now have sufficient
architectural ownership here for later Specifications to define exact APIs,
types, capacities, algorithms, and conformance cases without selecting a new
architecture. If review later exposes a credible alternative that can be
approved independently, the decomposition may be revisited; document length
or module count alone is not such evidence.

## Open Questions

RFC-002 has no remaining open question about whether to create another layer
RFC. The following list records the coordinated status; both items are
resolved in the coordinated drafts:

1. **Operation ownership and the logical commit boundary are resolved in the
   coordinated drafts:** RFC-004 now requires every
   first-party MVP backend to consume the ordered operation stream once during
   synchronous frame offer without retaining or replaying it. Complete accepted
   handoff commits the logical frame and routing; later presentation and device
   health remain in the target integration, which coordinates them with
   physical input. Replayable operation storage and post-handoff recovery are
   outside MVP scope and preserved by
   [FW-010](../future-work/fw-010-backend-transport-submission-retry.md).
2. **Failure placement is resolved in the coordinated drafts:** RFC-005 places
   dependency-free failure facts in `GiftUIFailureCore` and execution
   correlation in `GiftUIFailureExecution`, which depends only on the core and
   RFC-004's execution contract. Capability-system placement and mechanisms are
   not resolved by RFC-002; RFC-006 owns them subject only to B12-B13's
   dependency-direction and non-inversion constraints. This separation
   preserves B12-B16 without making RFC-002 a source of capability authority.

RFC-003 reports no remaining architectural open questions. Its licensed
reference-resource and bounded static text evidence remain downstream
Specification prerequisites rather than RFC-002 blockers. Observable state
and Canvas remain missing separate feature lifecycles; that blocks
Specifications and implementation for those public features, but it does not
require their architecture to be folded into or resolved by RFC-002.

## Deferred and Follow-up Work

- [FW-004](../future-work/fw-004-retained-render-tree.md) preserves exploration
  of a retained render tree. MVP uses only the ordered render-operation IR;
  the IR must allow a future retained producer without changing frontend or
  layout contracts.
- [FW-005](../future-work/fw-005-alternative-geometry-scalars.md) preserves
  possible fractional, fixed-point, or floating-point geometry work. MVP uses
  checked integers.
- [RFC-003](rfc-003-deterministic-text-rendering-architecture.md) owns text
  geometry, font resources, positioned glyph operations, and glyph
  rasterization. RFC-002 retains only the rule that GiftUI owns text geometry
  above target rasterization.
- [RFC-004](rfc-004-run-cycle-and-frame-transaction.md) owns run-cycle, commit,
  frame, and presentation-transaction semantics.
- [RFC-005](rfc-005-failure-diagnostics-propagation.md) owns error and
  diagnostic propagation across the layers.
- [RFC-006](rfc-006-capability-system-architecture.md) owns the capability
  physical ownership, vocabulary, contribution and resolution mechanisms,
  propagation, consumption, policy relationship, diagnostics, absence
  behavior, and MVP catalogue. RFC-002 supplies only the dependency-direction
  and non-inversion constraints that its integration must preserve.
- [RFC-007](rfc-007-delegated-services-architecture.md) preserves the paused
  shared delegated-Service design. Current consumer-specific environmental
  contracts remain with RFC-004, RFC-005, or later approved feature work.
- [FW-009](../future-work/fw-009-shared-delegated-service-foundation.md)
  records the concrete triggers for reconsidering a shared Service package and
  catalogue without adding it to MVP scope.
- [FW-010](../future-work/fw-010-backend-transport-submission-retry.md)
  preserves replayable operation or backend-derived payload storage and post-
  handoff recovery policy as post-MVP work. Revisit only when a supported
  backend demonstrates a measured downstream availability or presentation/
  input-coherence requirement that bounded local handling cannot satisfy.
- [FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md)
  preserves reconsideration of the one-package MVP distribution. Revisit when
  independent consumption or versioning, incompatible toolchains, dependency
  constraints, or measured build and release costs demonstrate that several
  packages or another topology would be preferable.
- Existing proof-of-concept code will be revised and fitted into the accepted
  module graph through later ADRs, Specifications, and migration planning. It
  is not an input to the target architecture.

## Decision Summary

If this RFC is approved in substantially its proposed form, the following
architecturally significant choices should be extracted into separate ADRs:

1. GiftUI owns semantic UI and proposal-based layout above a backend-neutral
   render boundary; backends do not consume the view/runtime graph.
2. Static and dynamic runtimes are alternative storage and composition
   strategies beneath one portable declarative semantic model.
3. The MVP render boundary uses one normalized ordered operation vocabulary
   consumed once through synchronous streaming; no backend retains or replays
   the operation stream, and no retained render tree or replay storage is
   required. The boundary permits a future retained producer without changing
   frontend or layout contracts.
4. Backends, display/input drivers, and transport/HAL integrations have
   separate ownership with strictly downward dependencies.
5. Supported platforms are target-host compositions or presets, not owners of
   cross-cutting GiftUI semantics.
6. Logical ownership is enforced by the acyclic target/module import graph and
   dependency tests. The MVP is distributed as one Swift package containing
   multiple targets and products; `GiftUI` remains the portable declaration
   module and product rather than an upward-importing umbrella facade.
7. The active MVP profile and component graph are immutable after stack
   assembly; runtime presence and failure are operational state.
8. The core layout and Canvas geometry use checked integer scalars; a general
   constraint solver is an
   optional future facility rather than an MVP dependency.
9. Existing proof-of-concept code conforms to or migrates toward the new
   boundaries and does not determine them.
10. Backend-neutral input normalization is a sibling integration seam feeding
    runtime admission, not part of the render backend SPI; runtime-owned hit
    maps remain parallel to render payloads.

Text ownership, run-cycle semantics, error propagation, and the capability
system remain governed by their focused lifecycle artifacts rather than ADRs
extracted from this RFC. A shared delegated-Service foundation is not an
active MVP decision and remains deferred through RFC-007 and FW-009.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [PROPOSAL-001: GiftUI MVP Baseline Charter](../proposals/proposal-001-giftui-mvp-baseline-charter.md)
- [PROPOSAL-004: GiftUI Capability System](../proposals/proposal-004-capability-system.md)
- [RFC-001: Signal Analyzer Application Architecture](rfc-001-signal-analyzer-application-architecture.md)
- [RFC-003: Deterministic Text Rendering Architecture](rfc-003-deterministic-text-rendering-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](rfc-005-failure-diagnostics-propagation.md)
- [RFC-006: GiftUI Capability System Architecture](rfc-006-capability-system-architecture.md)
- [RFC-007: GiftUI Delegated Services Architecture](rfc-007-delegated-services-architecture.md)
- [FW-004: Retained Render Tree](../future-work/fw-004-retained-render-tree.md)
- [FW-005: Alternative Geometry Scalar Representations](../future-work/fw-005-alternative-geometry-scalars.md)
- [FW-016: Post-MVP Package and Distribution Topology](../future-work/fw-016-post-mvp-package-distribution-topology.md)
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
