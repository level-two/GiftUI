# GiftUI MVP Scope

**Status:** Established MVP product scope

**Authority:** Maintainer-provided boundary for MVP prioritization and exit decisions

## Purpose

The GiftUI MVP validates that GiftUI can be used to build a real interactive application across desktop, Linux, and constrained embedded environments while preserving a common SwiftUI-inspired client model.

The MVP is defined by a representative application: a **low-frequency signal analyzer**.

The analyzer is not merely a demo. A working implementation of this application across the target stack configurations is the primary MVP outcome and the main constraint on feature, architecture, and infrastructure work.

## MVP Outcome

The MVP is complete when the low-frequency signal analyzer can be implemented with GiftUI and run on the following stack configurations:

| Platform | Configuration | Role |
|---|---|---|
| macOS | Dynamic | Primary development and rapid iteration environment |
| macOS | Static | Early validation of static-build constraints |
| Linux / Raspberry Pi | Dynamic, framebuffer, PiScreen | Validation of Linux, framebuffer rendering, and real display hardware |
| Embedded / nRF52840 | Static, TFT display | Validation of constrained embedded operation |

The same application-level UI model should be preserved across these configurations. Platform- and backend-specific implementation details should remain behind GiftUI abstractions.

The macOS configurations exist primarily to make implementation, testing, debugging, and architectural validation fast. Raspberry Pi introduces the real Linux/framebuffer environment. nRF52840 validates that the resulting architecture remains viable under embedded and static-runtime constraints.

## Reference Application

The low-frequency signal analyzer defines the practical feature requirements of the MVP.

GiftUI must provide enough functionality to implement the analyzer as a useful interactive application rather than as a collection of isolated framework demonstrations.

The reference application should exercise the framework in areas such as:

- composition of non-trivial UI hierarchies;
- dynamic layout;
- presentation of changing application state;
- user interaction and controls;
- graphical presentation required by the analyzer;
- state-driven UI updates;
- operation on displays with significantly different platform and hardware characteristics.

Detailed analyzer functionality belongs to its own application requirements or feature specifications. This document intentionally does not convert those requirements into a GiftUI API checklist.

## Client-Facing Scope

The MVP includes the subset of the GiftUI client API required to implement the reference application cleanly.

Features should be introduced because they support the analyzer or establish a necessary foundation for functionality that the analyzer requires.

SwiftUI similarity is valuable where it improves familiarity and usability, but source compatibility with SwiftUI is not an MVP requirement.

The MVP does not require broad API coverage. A small coherent API capable of implementing the complete reference application is preferable to a large collection of partially implemented SwiftUI-like features.

## Architecture Scope

The MVP must:

> Establish the layer boundaries and backend abstractions necessary for the MVP; the capability system must fit those boundaries, but only capabilities actually needed by MVP functionality have to be implemented.

The architecture should establish sufficient separation between:

- client-facing declarative UI;
- view/state representation;
- layout;
- rendering;
- interaction and event handling;
- backend-independent framework functionality;
- backend/platform integration;
- hardware-specific implementation.

These boundaries should allow the same client application to operate across the MVP stack configurations without embedding backend-specific decisions into application code.

The architecture should leave room for GiftUI to grow beyond the MVP, but implementation complexity must be justified by current MVP requirements.

## Capability System Scope

The MVP must establish the architectural place and propagation model for capabilities.

Capabilities should allow differences caused by platform, backend, build configuration, runtime environment, or hardware to be represented explicitly.

However, the MVP does **not** require a comprehensive catalogue of future GiftUI capabilities.

Only capabilities required by the reference application and its target stack configurations need to be implemented.

The capability mechanism should nevertheless demonstrate that unsupported or differently implemented functionality can be represented without compromising layer boundaries or requiring platform-specific application code.

## Backend Scope

The MVP requires the backends necessary to run the reference application on the defined validation configurations.

Backend work should be limited to functionality needed by the analyzer and to architectural mechanisms necessary to keep those implementations properly isolated.

The MVP does not require implementation of additional speculative backends.

The validation progression is:

**macOS → Raspberry Pi / Linux → nRF52840 / Embedded**

Each stage should validate assumptions before additional platform constraints are introduced.

## Static and Dynamic Configuration Scope

Support for both static and dynamic configurations is an explicit part of the MVP.

The MVP should demonstrate that the architecture and client programming model do not accidentally depend on facilities available only in richer dynamic environments.

macOS provides an early environment for exercising both configurations before static constraints are encountered on embedded hardware.

The final embedded validation must demonstrate that the relevant GiftUI stack can operate as a static configuration on the nRF52840 target.

## Out of Scope

The MVP does not attempt to:

- reproduce the full SwiftUI API;
- achieve SwiftUI source compatibility;
- implement features solely because SwiftUI provides them;
- support every possible GiftUI backend;
- implement speculative capabilities not exercised by the MVP;
- solve future framework requirements before they become necessary;
- provide production completeness for every supported platform;
- optimize every backend or rendering path beyond what is necessary to demonstrate viable operation.

Features valuable to the long-term GiftUI vision may be deliberately deferred when they are not required to complete the reference application.

## Scope Rule

Every significant MVP feature or architectural addition should be answerable by the question:

> **What requirement of the reference application or MVP stack validation makes this necessary now?**

If there is no concrete answer, the work should normally be considered post-MVP.

Architectural decisions may account for foreseeable evolution, but future requirements should influence boundaries and extensibility rather than cause speculative implementation.

## MVP Exit Criteria

GiftUI reaches MVP when:

1. The low-frequency signal analyzer is implemented as a coherent, useful GiftUI application.

2. The application runs on:
   - macOS with the dynamic configuration;
   - macOS with the static configuration;
   - Raspberry Pi/Linux using the dynamic configuration, framebuffer rendering, and PiScreen;
   - nRF52840 using the static embedded configuration and a TFT display.

3. The application-level GiftUI code remains substantially shared across these configurations, with platform and hardware differences isolated behind framework and backend abstractions.

4. The architecture has clear layer boundaries sufficient to support the implemented functionality and target configurations.

5. Backend abstractions allow the required rendering and interaction implementations to vary without leaking backend-specific concerns into client code.

6. The capability system has an established architectural model and is exercised by the capabilities genuinely required by the MVP stacks.

7. Both static and dynamic configurations are demonstrated through real execution rather than only architectural or compile-time assumptions.

8. The resulting framework provides enough coherent functionality that the analyzer can be treated as an application built **with GiftUI**, rather than as custom platform code connected by a thin GiftUI façade.

## Definition of Success

The MVP succeeds if it demonstrates that the central GiftUI hypothesis is viable:

> **A meaningful interactive application can be expressed through a familiar SwiftUI-inspired model and run across desktop, Linux/framebuffer, and constrained embedded environments without abandoning a common architecture or application-level programming model.**

Everything beyond what is necessary to prove that hypothesis belongs to subsequent GiftUI development.
