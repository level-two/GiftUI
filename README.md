# GiftUI

GiftUI is an experimental declarative user-interface framework for embedded
systems, inspired by SwiftUI's source-level model.

This repository contains the operable macOS simulator for PoC A. It includes
generic view expansion, deterministic stack layout, runtime-owned `@State`,
full-root invalidation, button hit testing, backend-independent display lists,
an in-memory RGBA framebuffer, a compiled bitmap font, AppKit presentation,
and the interactive thermostat example.

## Requirements

- macOS 15 or newer
- Xcode 16.3 or newer
- Swift 6 toolchain
- Xcode command-line tools

Check the local setup:

```bash
scripts/check-environment.sh
```

## Build and test

```bash
swift build
swift test
```

Run the simulator demo:

```bash
swift run GiftUIExampleThermostat
```

The demo opens a 720×720 point window that presents a 240×240 logical RGBA
framebuffer at 3× scale with nearest-neighbor interpolation. Click `-` and `+`
to update the runtime-owned target temperature and redraw the complete view
graph.

## Debug in Xcode

No generated `.xcodeproj` is required. Open the package directly:

```bash
open Package.swift
```

Choose the `GiftUIExampleThermostat` scheme and run it with the `My Mac`
destination. Breakpoints can be placed in the example, runtime, framebuffer,
or simulator targets.

## Package layout

```text
Sources/
├── GiftUI/                       # Client-facing, platform-neutral API
├── GiftUIRuntimeDynamic/         # Replaceable dynamic PoC runtime
├── GiftUIBackendFramebuffer/     # Platform-neutral RGBA framebuffer
├── GiftUISimulatorMac/           # AppKit/CoreGraphics presentation shell
└── GiftUIExampleThermostat/      # Runnable client example

Tests/
├── GiftUITests/
├── GiftUIRuntimeDynamicTests/
├── GiftUIBackendFramebufferTests/
└── GiftUIIntegrationTests/
```

Application view declarations import only `GiftUI`. AppKit and CoreGraphics
are isolated to `GiftUISimulatorMac`.

The implementation specifications are in
[`docs/GiftUI_Framework_Spec.md`](docs/GiftUI_Framework_Spec.md) and
[`docs/GiftUI_PoC_A_macOS_Simulator_Spec.md`](docs/GiftUI_PoC_A_macOS_Simulator_Spec.md).

## PoC runtime constraints

The dynamic runtime intentionally uses heap-backed arrays and dictionaries,
escaping button closures, `String`, task-local build context, a full RGBA
framebuffer, and full-root redraws. Those choices are isolated to replaceable
runtime/backend modules; the client-facing view declarations remain independent
of AppKit and framebuffer types.

## Core implementation status

The PoC Core implements variadic result-builder composition, branch-specific
structural state identity, proposal-based measure/place layout, render-operation
display lists, and serialized input dispatch. State writes that occur while a
frame is being emitted leave the application invalid so the next render
delivers the update; multiple writes before that render coalesce into one frame.

Structural identity is intentionally topology-based for PoC A. Reordering or
inserting siblings can therefore move state between paths. Explicit identity
and reconciliation remain future static/runtime work.
