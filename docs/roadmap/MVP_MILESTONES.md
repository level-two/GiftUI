# GiftUI MVP Milestones

**Status:** Established MVP delivery ordering

**Authority:** Prioritization only; this roadmap does not approve architecture, feature contracts, or implementation

## Purpose

This roadmap orders the work required by the [GiftUI MVP Scope](../MVP_SCOPE.md). The scope remains authoritative for what belongs in MVP and for MVP exit decisions; this document answers when that work should happen and what architectural subsystem each milestone should prove.

The ordering follows one guiding principle:

> Each milestone should unlock useful client expression while validating an architectural foundation needed by later milestones.

## Lifecycle Gate

The accepted [GiftUI MVP Baseline Charter](../proposals/proposal-001-giftui-mvp-baseline-charter.md) establishes the Proposal-level rationale and expected outcome for the MVP. The MVP Scope incorporates that accepted direction into the authoritative product boundary, and this roadmap orders its delivery. The baseline charter avoids retroactively requiring a separate Proposal for every existing MVP feature area.

Each independently governed feature area must still pass its applicable RFC,
ADR, Specification, and conformance gates from the
[Feature Lifecycle](../engineering/FEATURE_LIFECYCLE.md). The baseline charter
does not infer those approvals, and a milestone may begin implementation only
when its governing Specifications are approved. New work outside the baseline,
or a material change to its problem, users, outcomes, or boundaries, requires
explicit lifecycle review and may require a new Proposal.

## Prioritization Rules

Work within the MVP should be ordered by these rules:

1. Prefer foundational features used throughout the Signal Analyzer over specialized features.
2. Establish composition, modifiers, and layout before adding specialized rendering or controls.
3. Use each client-facing addition to validate its underlying subsystem: view description, modifier behavior, layout, rendering, invalidation, input, or backend isolation.
4. Validate static and constrained configurations progressively instead of postponing portability checks until the complete application exists.
5. Keep low-level custom drawing late enough that it builds on the ordinary declarative pipeline rather than becoming a shortcut around it.
6. Do not pull generally useful SwiftUI-like features into MVP unless the Signal Analyzer or a target-stack validation requires them.
7. Treat the working PoC as evidence and reusable source material, not as implicit approval of its architecture or contracts.
8. Prefer an incremental adopt, adapt, replace, or retire decision for each PoC area over either preserving everything or performing an unexamined rewrite.

## Current PoC Baseline

The repository already contains a partially working stack across these areas:

- view composition and result-builder support;
- basic stacks, geometry, and layout arithmetic;
- text, color, render operations, and render backends;
- button input and hit regions;
- dynamic and static runtimes with state storage;
- framebuffer and RGB565 rendering;
- macOS simulation, Linux, and Raspberry Pi platform integration;
- ILI9341 display and ADS7846 touch support;
- thermostat examples and cross-runtime/backend tests.

This baseline should be preserved as non-authoritative migration input. Existing code, tests, and examples may demonstrate useful behavior or implementation knowledge, but they do not establish the target architecture and must not bypass lifecycle approval.

## Delivery Sequence

### M1 — Architecture Establishment

**Outcome:** The MVP architecture is reviewed and made authoritative through the required lifecycle artifacts before framework migration or major feature implementation proceeds.

**Questions governed here:** Layer and module boundaries; ownership; view, state, layout, rendering, interaction, backend, platform, and hardware responsibilities; static versus dynamic composition; capability placement and propagation; cost and compatibility constraints; and the contracts that later milestones must specify.

**PoC input:** Inventory the current modules, tests, examples, and working target paths as evidence for the RFC. Record strengths, constraints, coupling, and known gaps without treating current structure as the default decision.

**Completion condition:** The relevant Proposal is accepted, the architecture RFC is approved, required ADRs are accepted, and downstream Specifications can be drafted without inventing unresolved architecture.

**Why here:** Client-feature work and migration need a stable destination. Without accepted boundaries, reuse decisions would allow the PoC to define the architecture implicitly.

**Scope trace:** [Architecture Scope](../MVP_SCOPE.md#architecture-scope), [Backend Scope](../MVP_SCOPE.md#backend-scope), and [Static and Dynamic Configuration Scope](../MVP_SCOPE.md#static-and-dynamic-configuration-scope).

### M2 — Capability and Foundation Infrastructure

**Outcome:** The minimum approved infrastructure needed to host later client features exists across the MVP profiles, including the architectural place and propagation path for capabilities.

**Architecture proof:** The accepted boundaries can support backend selection, platform integration, static and dynamic configurations, capability differences, and testable cross-layer contracts without requiring platform-specific decisions in portable application code.

**Scope discipline:** Implement only the capability and infrastructure mechanisms required by the Signal Analyzer or by validation of the four MVP configurations. This milestone establishes extensible rails, not a speculative capability catalogue.

**Completion condition:** Approved Specifications define the infrastructure contracts; their required host, static-profile, backend, and hardware-free platform checks pass; and later feature milestones have supported integration points.

**Why here:** The client surface should grow on the intended runtime, backend, capability, and validation rails rather than creating another temporary parallel stack.

**Scope trace:** [Capability System Scope](../MVP_SCOPE.md#capability-system-scope), [Backend Scope](../MVP_SCOPE.md#backend-scope), and [Static and Dynamic Configuration Scope](../MVP_SCOPE.md#static-and-dynamic-configuration-scope).

### M3 — PoC Disposition and Migration

**Outcome:** The existing PoC is deliberately revised and migrated onto the accepted architecture and foundational infrastructure before substantial new client-surface expansion.

**Migration method:** Classify each affected PoC area as:

- **adopt** — it already conforms to the approved contract;
- **adapt** — useful code can be retained behind revised boundaries or APIs;
- **replace** — behavior remains necessary but the implementation conflicts with the approved design;
- **retire** — the code is obsolete, duplicated, or outside MVP scope;
- **defer** — useful post-MVP work that should not burden the migration.

**Evidence to preserve:** Reuse relevant tests, examples, target probes, and observed behavior as regression evidence. Add characterization tests before changing behavior that is useful but not yet specified. Do not preserve accidental PoC behavior merely because a test currently encodes it.

**Completion condition:** Every in-scope PoC module has a recorded disposition; reusable portions operate through the approved contracts; obsolete parallel paths are identified for removal; and the migrated baseline passes its applicable host and hardware-free checks. Connected-hardware claims remain open until actually validated.

**Why here:** This creates one coherent foundation for subsequent work, captures the value already present in the repository, and avoids maintaining old and new rails longer than necessary.

**Scope trace:** The migration is justified by the need to preserve a common application model across the [MVP Outcome](../MVP_SCOPE.md#mvp-outcome) and by the anti-leakage requirements in [Architecture Scope](../MVP_SCOPE.md#architecture-scope).

### M4 — Declarative Composition Foundation

**Client unlock:** The Rank 0 surface: `View`, opaque `body`, fixed result-builder composition, reusable custom views, view-returning helpers, and modifier chaining.

**Architecture proof:** GiftUI can preserve a declarative view description through composition and ordered transformations without requiring type erasure in ordinary client code.

**Why here:** Every later layout, rendering, state, and input feature depends on a stable composition model. Modifier chaining is included here because layout and rendering modifiers must share a coherent transformation pipeline.

**Scope trace:** [Rank 0 — Declarative View Model](../MVP_SCOPE.md#rank-0--declarative-view-model).

### M5 — Layout Language

**Client unlock:** The Rank 1 layout surface: vertical, horizontal, and overlay stacks; flexible space; spacing; alignment; padding; and fixed, constrained, or expanding frames.

**Architecture proof:** Layout negotiation can flow through nested containers and modifiers without backend-specific positioning in application code.

**Why here:** This is the highest-leverage expansion of client expressiveness. It enables complete screen structure before GiftUI accumulates specialized widgets or drawing APIs.

**Scope trace:** [Rank 1 — Layout](../MVP_SCOPE.md#rank-1--layout).

### M6 — Composed Rendering

**Client unlock:** Text, opaque RGB color, foreground styling, and rectangular backgrounds applied through the established composition and layout systems.

**Architecture proof:** Resolved layout can become backend-independent rendering data, and rendering modifiers can participate in the same ordered pipeline as layout modifiers.

**Why here:** The Signal Analyzer needs a usable visual vocabulary, but the MVP does not need speculative shapes, effects, alpha compositing, or a general styling system.

**Scope trace:** Rendering entries in [Rank 2 — Rendering, Interaction, and State](../MVP_SCOPE.md#rank-2--rendering-interaction-and-state).

### M7 — Observable State and Input

**Client unlock:** Observable reference state presented through `@State`, followed by `Button` actions and disabled interaction state.

**Architecture proof:** State changes invalidate dependent view descriptions, recomputation reaches layout and rendering, and backend input dispatch reaches application actions while respecting disabled state.

**Why here:** State propagation should be demonstrated before controls become more complex. The scoped Button surface then proves the complete one-way update and event loop without introducing binding ownership or richer controls that the MVP does not require.

**Scope trace:** State and interaction entries in [Rank 2 — Rendering, Interaction, and State](../MVP_SCOPE.md#rank-2--rendering-interaction-and-state) and the [State and Data Boundary](../MVP_SCOPE.md#state-and-data-boundary).

### M8 — Core Signal Analyzer Vertical Slice

**Client unlock:** A substantially shared Signal Analyzer presentation using the complete Rank 0–2 surface, with a placeholder waveform surface.

**Architecture proof:** Composition, modifiers, layout, rendering, state, and input work together as an application rather than as isolated framework demonstrations.

**Validation order:**

1. macOS dynamic for rapid integration and debugging;
2. macOS static to expose static-composition restrictions early;
3. Raspberry Pi/Linux dynamic to validate framebuffer and platform boundaries;
4. nRF52840 static to validate constrained embedded viability.

**Why here:** A cross-stack vertical slice exposes abstraction leaks before the custom-drawing contract adds backend complexity.

**Scope trace:** [MVP Outcome](../MVP_SCOPE.md#mvp-outcome), [Backend Scope](../MVP_SCOPE.md#backend-scope), and [Static and Dynamic Configuration Scope](../MVP_SCOPE.md#static-and-dynamic-configuration-scope).

### M9 — Analyzer Drawing Surface

**Client unlock:** The minimal `Canvas`, graphics context, path, stroke style, solid shading, and geometry operations needed to draw the time grid and four digital traces.

**Architecture proof:** A deliberately narrow low-level drawing escape hatch can cross the backend contract without bypassing GiftUI layout, capability handling, or platform isolation.

**Why here:** Custom drawing is essential to the reference application but less broadly foundational than composition, layout, rendering, state, and input. Implementing it after the core vertical slice prevents it from becoming the architecture around which ordinary views are designed.

**Scope trace:** [Waveform Drawing Scope](../MVP_SCOPE.md#waveform-drawing-scope).

### M10 — Complete Signal Analyzer and MVP Validation

**Client unlock:** The complete Signal Analyzer with its real time grid and digital traces on every target configuration.

**Architecture proof:** The common client model, backend boundaries, capability model, and static/dynamic composition remain viable across desktop, Linux/framebuffer, and constrained embedded environments.

**Validation order:**

1. macOS dynamic;
2. macOS static;
3. Raspberry Pi/Linux dynamic with framebuffer rendering and PiScreen;
4. nRF52840 static with a TFT display.

**Completion gate:** Every criterion in [MVP Exit Criteria](../MVP_SCOPE.md#mvp-exit-criteria) must have real execution evidence. Builds, host tests, and simulators do not substitute for required connected-hardware validation.

## Deferred Client Priorities

The source ideas also identify valuable features that are not required by the current MVP scope. Their suggested order after MVP is:

1. bindings and externally owned observable state;
2. conditional and dynamic hierarchy with stable identity;
3. additional visual primitives and styling;
4. bidirectional controls;
5. richer shape and path operations;
6. scrolling as an early capability-intensive feature;
7. higher-level collections and controls.

This list is directional context, not an established post-MVP feature roadmap. Features such as `Binding`, `@ObservedObject`, `@StateObject`, `ForEach`, `Toggle`, `Slider`, `Shape`, `ScrollView`, and `List` require their own lifecycle artifacts and an explicit scope or milestone decision before implementation.
