# GiftUI

GiftUI is an experimental declarative user-interface framework for embedded
systems, inspired by SwiftUI's source-level model.

This repository currently contains the macOS simulator scaffold for PoC A. It
establishes the distributable SwiftPM package, backend boundaries, in-memory
RGBA framebuffer, AppKit presentation shell, thermostat example, and initial
tests. Layout traversal, bitmap-font rendering, external `@State` binding, and
input dispatch are subsequent PoC milestones.

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

The current demo opens a 720×720 point window that presents a 240×240 logical
RGBA framebuffer at 3× scale with nearest-neighbor interpolation. The visible
frame is a simulator scaffold; thermostat text, layout, state-driven redraw,
and button interaction will be implemented in later milestones.

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

The implementation specification is in
[`docs/GiftUI_PoC_A_macOS_Simulator_Spec.md`](docs/GiftUI_PoC_A_macOS_Simulator_Spec.md).
