# GiftUI MVP Scope

**Status:** Established MVP product scope

**Authority:** Maintainer-provided boundary for MVP prioritization and exit decisions

**Baseline charter:** [PROPOSAL-001: GiftUI MVP Baseline Charter](proposals/proposal-001-giftui-mvp-baseline-charter.md)

## Purpose

The GiftUI MVP validates that GiftUI can be used to build a meaningful interactive application across desktop, Linux, and constrained embedded environments while preserving a common SwiftUI-inspired client model.

The MVP is defined by a representative application: a **low-frequency digital signal analyzer**.

The Signal Analyzer is the primary constraint on MVP feature, architecture, backend, and capability work. Functionality that is not required by the analyzer or by validation of the target stack configurations is normally outside MVP scope.

## MVP Outcome

The MVP outcome is a working Signal Analyzer implemented with GiftUI and running on the following stack configurations:

| Platform | Configuration | Role |
|---|---|---|
| macOS | Dynamic | Primary development, debugging, and rapid iteration environment |
| macOS | Static | Early validation of static-build constraints |
| Linux / Raspberry Pi | Dynamic, framebuffer, PiScreen | Validation of Linux operation, framebuffer rendering, and real display hardware |
| Embedded / nRF52840 | Static, TFT display | Validation of constrained embedded execution |

The validation progression is:

**macOS dynamic → macOS static → Raspberry Pi / Linux → nRF52840 / Embedded**

The same portable Signal Analyzer presentation should be used across these configurations.

Platform-specific hosting and bootstrap code is explicitly allowed at the application boundary. For the reference application, `SignalAnalyzerApp/SignalAnalyzerApp.swift` is considered platform-specific hosting code and is outside the portable GiftUI view scope.

Platform-, backend-, and hardware-specific implementation details must otherwise remain behind GiftUI abstractions.

---

## Reference Application

The Signal Analyzer defines what "enough GiftUI" means for MVP.

It must exercise GiftUI as an application framework rather than as a collection of isolated demonstrations.

The portable presentation requires:

- composition of non-trivial view hierarchies;
- reusable custom views;
- vertical, horizontal, and overlay layout;
- flexible and constrained sizing;
- spacing, alignment, and padding;
- text presentation;
- opaque foreground and background colors;
- interactive controls;
- disabled interaction state;
- observable state-driven updates;
- data-driven waveform visualization.

The application-level presentation should remain substantially shared across all target configurations.

---

## GiftUI Feature Scope

The following feature surface defines the GiftUI functionality required by the Signal Analyzer.

The ranking represents implementation dependency and priority rather than optionality.

Ranks **0–2 form the core required GiftUI client surface**.

Waveform drawing is also required to complete the full Signal Analyzer demo and therefore the overall MVP outcome.

### Rank 0 — Declarative View Model

| Required feature | Required behavior | Signal Analyzer use |
|---|---|---|
| `View` and `body: some View` | Declare a view as a value with an opaque body type | All analyzer view types |
| Result-builder child composition | Compose a fixed number of child views | Screen, header, controls, ruler, and channel rows |
| Custom views and view-returning properties/functions | Split a hierarchy into reusable components without type erasure | Analyzer, waveform panel, channel row, header, status, and controls |
| Modifier chaining | Apply ordered layout and rendering transformations to views and containers | All analyzer components |

Rank 0 establishes the fundamental GiftUI client programming model.

---

### Rank 1 — Layout

| Required feature | Required behavior | Signal Analyzer use |
|---|---|---|
| `VStack`, `HStack`, `ZStack` | Lay out children vertically, horizontally, and back-to-front | Screen structure, header, controls, waveform panel, ruler, and channel rows |
| `Spacer` | Consume flexible space along a stack's main axis | Header, controls, and time ruler |
| Stack spacing | Support zero and explicit point spacing | Screen sections, labels, status, controls, and channel rows |
| Stack alignment | Support leading and center alignment | Header and channel labels |
| `padding` | Support uniform, horizontal, and vertical insets | Screen, status, controls, ruler, and channel rows |
| `frame` | Support fixed, minimum, maximum, infinite, and aligned dimensions | Minimum analyzer size, expanding channel rows, fixed labels, and button widths |

Rank 1 establishes the layout functionality necessary to describe the analyzer without backend-specific positioning.

---

### Rank 2 — Rendering, Interaction, and State

| Required feature | Required behavior | Signal Analyzer use |
|---|---|---|
| `Text` | Render static strings and strings derived from application state | Titles, channel names, levels, time values, status, errors, and buttons |
| Opaque RGB `Color` | Render solid foregrounds and backgrounds without alpha compositing | Screen and panel backgrounds, accents, status, grid, and secondary text |
| `foregroundStyle` | Apply a solid color to text and other foreground-rendered content | Labels, status, controls, and channel accents |
| Rectangular `background` | Paint an opaque color behind a view using its resolved layout bounds | Status, controls, ruler, channel rows, and waveform panel |
| `Button` | Render text content and dispatch an action | Start, Stop, Clear, and visible-window selection |
| `disabled` | Prevent input according to current application state | Acquisition actions and selected time-window button |
| `@State` with observable reference state | Preserve the view model and invalidate dependent view descriptions when it changes | Capture data, acquisition status, errors, and visible window |

Observable reference-state invalidation is an explicit MVP requirement because
the Signal Analyzer receives changing capture and acquisition state. Its
architecture and public contract are not established by this scope document;
they require a separate feature lifecycle beginning with a Proposal before
implementation is authorized.

The MVP intentionally limits rendering to **opaque RGB colors**. Alpha compositing, gradients, shadows, and richer styling are not required unless a later concrete MVP requirement introduces them.

---

## Waveform Drawing Scope

The completed Signal Analyzer requires a minimal custom-drawing API.

This is part of the **full MVP completion criteria**, because the reference application must ultimately display its captured signals.

Only the drawing functionality required by the analyzer is in scope.

| Required feature | Required behavior |
|---|---|
| `Canvas` | Provide a drawing closure with a graphics context and resolved view size |
| `GraphicsContext.stroke` | Stroke a path with a solid color and either a line width or stroke style |
| `Path` | Create a mutable path using `move(to:)` and `addLine(to:)` |
| `StrokeStyle` | Configure line width, round caps, and round joins |
| Solid color shading | Use an opaque RGB color as a stroke source |
| Drawing geometry | Provide points, sizes, and scalar arithmetic in canvas coordinate space |

Canvas, path, and stroke support are explicit MVP requirements because the
Signal Analyzer must draw its time grid and digital traces. Their separately
governed lifecycle has an accepted
[PROPOSAL-006](proposals/proposal-006-canvas-path-stroke-drawing.md), approved
[RFC-009](rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md), and
accepted [ADR-028](adrs/adr-028-post-layout-canvas-derivation-and-cycle-local-plan.md),
[ADR-029](adrs/adr-029-scoped-transient-path-snapshot-semantics.md),
[ADR-030](adrs/adr-030-canonical-normalized-straight-line-stroke-operation.md),
and [ADR-031](adrs/adr-031-bounded-canvas-failure-and-startup-gate-integration.md).
Those ADRs establish the Canvas architecture; exact public declarations and
implementation contracts still require an approved drawing Specification
before implementation is authorized.

The canvas needs to support only the analyzer's immediate requirements:

- drawing the time grid;
- drawing four data-driven digital traces.

No general-purpose drawing framework is required for MVP.

In particular, the MVP does not require arbitrary fills, curves, images, text drawing inside a canvas, clipping, transforms, gradients, alpha compositing, or advanced path operations unless they become necessary for the reference application.

---

## Architecture Scope

**Lifecycle authorization:** [PROPOSAL-003: GiftUI MVP Architecture Establishment](proposals/proposal-003-giftui-mvp-architecture-establishment.md)

The MVP must:

> Establish the layer boundaries and backend abstractions necessary for the MVP; the capability system must fit those boundaries, but only capabilities actually needed by MVP functionality have to be implemented.

The architecture must establish sufficient separation between:

- client-facing declarative UI;
- view/state representation and update propagation;
- layout;
- drawing and rendering representation;
- interaction and event dispatch;
- backend-independent framework functionality;
- backend contracts;
- platform integration;
- hardware-specific implementation.

The architecture should support future GiftUI growth, but implementation complexity must remain justified by MVP requirements.

Future extensibility should primarily influence **boundaries and contracts**, not cause speculative implementation.

---

## Capability System Scope

The MVP must establish the architectural place and propagation model for capabilities.

Capabilities may originate from differences in:

- static versus dynamic configuration;
- platform;
- backend;
- runtime environment;
- display hardware.

The capability model must fit cleanly across the architectural layers established during the MVP.

However, the MVP does **not** require a comprehensive capability catalogue.

Only capabilities exercised by the Signal Analyzer and its target configurations need to be implemented.

Potential future differences—such as hardware scrolling, shadows, alpha compositing, richer graphics, or backend-specific acceleration—may influence the capability architecture but do not require MVP implementation unless the analyzer depends on them.

The MVP should demonstrate that a capability difference can be represented without leaking platform- or backend-specific decisions into portable application code.

---

## Backend Scope

The MVP requires only the backend functionality necessary to execute the Signal Analyzer on the target configurations.

Required validation environments are:

### macOS

Used as the primary implementation and triage environment.

Both dynamic and static configurations must be exercised so that static-build restrictions are discovered before reaching embedded hardware.

### Raspberry Pi / Linux

The analyzer must run dynamically on Raspberry Pi using the Linux stack and framebuffer rendering, with PiScreen as the physical display target.

This stage validates:

- Linux execution;
- framebuffer rendering;
- real display geometry;
- input/event integration required by the analyzer;
- backend abstraction boundaries outside the macOS environment.

### nRF52840 / Embedded

The analyzer must run as a static embedded configuration on nRF52840 with a TFT display.

This stage validates:

- Embedded Swift constraints;
- static composition;
- constrained resources;
- hardware display integration;
- absence of accidental dependencies on desktop/runtime facilities unavailable in the embedded environment.

Additional speculative backends are outside MVP scope.

---

## Static and Dynamic Configuration Scope

Support for both static and dynamic configurations is an explicit MVP concern.

The architecture and client programming model must not accidentally depend on facilities available only in dynamic or desktop environments.

The MVP validates:

- dynamic configuration on macOS;
- static configuration on macOS;
- dynamic configuration on Raspberry Pi/Linux;
- static configuration on nRF52840.

Static versus dynamic differences may affect internal composition, backend selection, capability resolution, or implementation mechanisms.

They should not require fundamentally different portable Signal Analyzer view code.

---

## State and Data Boundary

GiftUI is responsible for presenting and reacting to application state.

The Signal Analyzer application may obtain changing signal data through its own domain and data layers.

The MVP requires GiftUI to correctly react to observable reference state exposed to the presentation layer.

That observation mechanism is a separately governed MVP feature. The scope
requires the outcome but does not select an observation architecture or make
the macOS investigation's Observation framework an embedded dependency.

The design of signal acquisition, hardware sampling, persistence, repositories, and other analyzer-specific domain/data mechanisms is outside the GiftUI feature scope except where they expose requirements on the UI framework.

GiftUI therefore needs to consume changing state correctly; it does not need to define the application's data acquisition architecture.

---

## Explicit Non-Goals

The MVP does not attempt to:

- reproduce the complete SwiftUI API;
- achieve SwiftUI source compatibility;
- implement features merely because SwiftUI provides them;
- support an arbitrary number of future backends;
- implement speculative capabilities;
- provide a general-purpose graphics framework;
- provide general alpha compositing;
- implement gradients, shadows, effects, or advanced styling not required by the analyzer;
- provide unrestricted dynamic child collections unless the analyzer requires them;
- provide arbitrary path construction beyond the required waveform operations;
- optimize every rendering path beyond what is necessary for viable operation;
- solve future framework requirements before concrete use cases require them;
- make platform-specific application hosting code portable.

Long-term GiftUI features should be deferred when they do not materially contribute to the Signal Analyzer or validation of the MVP architecture.

---

## Scope Rule

Every significant feature, abstraction, capability, or infrastructure addition proposed for MVP should answer:

> **What Signal Analyzer requirement or target-stack validation makes this necessary now?**

If there is no concrete answer, the implementation should normally be considered post-MVP.

A future requirement may justify shaping an abstraction so that it remains extensible, but it should not normally justify implementing unused functionality.

Prioritized delivery sequencing is maintained in the [MVP Milestones](roadmap/MVP_MILESTONES.md) roadmap.

---

## MVP Exit Criteria

The GiftUI MVP is complete when:

1. **The Signal Analyzer is a coherent working application**, not a collection of framework demonstrations.

2. **All Rank 0–2 features are implemented and validated** on the target configurations where they are required.

3. **The waveform drawing surface is implemented sufficiently to render the analyzer's time grid and four digital traces.**

4. **The complete application runs on:**
   - macOS dynamic;
   - macOS static;
   - Raspberry Pi/Linux dynamic with framebuffer rendering and PiScreen;
   - nRF52840 static with a TFT display.

5. **Portable presentation code is substantially shared** across all configurations.

6. Platform-specific code is confined to legitimate hosting, backend, platform, or hardware integration boundaries rather than leaking into the portable view hierarchy.

7. **Layer boundaries are explicit** and sufficient to support the implemented MVP functionality.

8. **Backend abstractions are proven by multiple materially different implementations**, including desktop/Linux and constrained embedded rendering environments.

9. **The capability model has an established architectural role** and is exercised by real MVP requirements where platform or backend differences require it.

10. **Static and dynamic configurations are validated through actual builds and execution**, rather than solely through architectural assumptions.

11. The resulting framework is sufficiently coherent that the Signal Analyzer can reasonably be described as an application built **with GiftUI**, rather than custom platform applications connected through a superficial common façade.

---

## Definition of Success

The MVP succeeds if it demonstrates the central GiftUI hypothesis:

> **A meaningful interactive application can be expressed through a familiar SwiftUI-inspired declarative model and run across desktop, Linux/framebuffer, and constrained embedded environments without abandoning a common application-level programming model or architectural foundation.**

The Signal Analyzer is the proof of that hypothesis.

Everything not required to establish that proof belongs to subsequent GiftUI development.
