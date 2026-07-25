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

## Raspberry Pi 1 cross-compilation

The project pins both the official Swift.org 6.3.2 macOS compiler and an ARMv6
SDK for Raspberry Pi OS Bookworm. They are downloaded and unpacked into the
ignored `.toolchains/` directory, without modifying `/opt`, Xcode, or the
global Swift installation. Allow roughly 8 GB of free disk space for the
cached packages and unpacked tools.

Set up and verify the toolchain:

```bash
scripts/raspberry-pi/setup-toolchain.sh
scripts/raspberry-pi/doctor.sh --probe
```

Cross-build a Raspberry Pi executable product:

```bash
scripts/raspberry-pi/build.sh \
    --product GiftUIExampleThermostatRaspberryPi
```

Configure machine-local deployment defaults:

```bash
cp scripts/raspberry-pi/local.env.example \
    scripts/raspberry-pi/local.env
```

Then deploy atomically over SSH:

```bash
scripts/raspberry-pi/deploy.sh \
    --product GiftUIExampleThermostatRaspberryPi
```

The Raspberry Pi executable uses the kernel-managed framebuffer path, which is
the preferred first integration for the 3.5-inch PiScreen: the OS driver owns
SPI and panel initialization, and GiftUI writes frames through `/dev/fb1`.
The device path, logical dimensions, and rotation are runtime options:

```bash
GiftUIExampleThermostatRaspberryPi \
    --display fbdev \
    --device /dev/fb1 \
    --width 240 \
    --height 240 \
    --rotation 0
```

Use `--once` for a one-frame hardware smoke test and `--help` for all options.
The adapter accepts 16-, 24-, or 32-bit framebuffer formats, honors device
stride, converts from GiftUI's RGBA8888 surface, and aspect-fits with
nearest-neighbor scaling. See
[`docs/GiftUI_Raspberry_Pi_Platform.md`](docs/GiftUI_Raspberry_Pi_Platform.md)
for PiScreen setup and runtime details.

Agent workflows are defined in `skills/giftui-pi-toolchain` and
`skills/giftui-pi-build-deploy`.

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
├── GiftUIPlatformLinux/           # Linux loop and framebuffer presentation
├── GiftUIPlatformRaspberryPi/     # Raspberry Pi defaults/configuration
├── GiftUIExampleThermostatView/   # Shared platform-neutral client view
├── GiftUIExampleThermostat/       # Runnable macOS client
└── GiftUIExampleThermostatRaspberryPi/ # Runnable Raspberry Pi client

Tests/
├── GiftUITests/
├── GiftUIRuntimeDynamicTests/
├── GiftUIBackendFramebufferTests/
├── GiftUIIntegrationTests/
├── GiftUIPlatformLinuxTests/
└── GiftUIPlatformRaspberryPiTests/
```

Application view declarations import only `GiftUI`. AppKit and CoreGraphics
are isolated to `GiftUISimulatorMac`; Linux framebuffer and Raspberry Pi
configuration code are isolated to their platform modules.

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
structural state identity, proposal-based measure/place layout, checked layout
arithmetic, render-operation sinks, frame-consistent interaction snapshots, and
serialized input dispatch. Dynamic runtimes can retain operations in a
`DisplayList`; allocation-bounded runtimes can provide a custom
`RenderOperationSink` and report capacity exhaustion without changing view
declarations.

Hit testing is resolved by Core against the interaction snapshot built for the
presented frame. Later, deeper regions win when controls overlap. State writes
that occur while a frame is being emitted leave the application invalid so the
next render delivers the update; multiple writes before that render coalesce
into one frame.

Structural identity is intentionally topology-based for PoC A. Reordering or
inserting siblings can therefore move state between paths. Explicit identity
and reconciliation remain future static/runtime work. Fixed state arenas and
typed, non-closure actions likewise belong to the future static runtime rather
than the completed dynamic PoC Core.
