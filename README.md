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
    --rotation 0 \
    --touch
```

Touch input is read from `/dev/input/event0` by default and maps evdev absolute
coordinates through the framebuffer's aspect-fit and rotation transform. Use
`--touch-device` for a stable device path; runtime swap/invert options are
available for panels whose Device Tree overlay does not calibrate the axes.

Enable three active-low GPIO buttons with internal pull-ups:

```bash
GiftUIExampleThermostatRaspberryPi \
    --device /dev/fb1 \
    --gpio-buttons
```

The defaults use BCM GPIO 17 for previous, 27 for next, and 22 for activate.
Previous/next move an amber focus border; activate dispatches the focused
GiftUI button. All GPIO lines, polarity, bias, and debounce timing are
configurable through `--help`.

Use `--once` for a one-frame hardware smoke test and `--help` for all options.
The adapter accepts 16-, 24-, or 32-bit framebuffer formats, honors device
stride, converts from GiftUI's RGBA8888 surface, and aspect-fits with
nearest-neighbor scaling. See
[`docs/GiftUI_Raspberry_Pi_Platform.md`](docs/GiftUI_Raspberry_Pi_Platform.md)
for PiScreen setup and runtime details.

Agent workflows are defined in `skills/giftui-pi-toolchain` and
`skills/giftui-pi-build-deploy`.

## Nordic nRF52840-DK development environment

The proposed microcontroller port uses a separately pinned, project-local
Embedded Swift and Zephyr environment. Swift, Zephyr 4.3.0, the Zephyr SDK ARM
toolchain, Nordic modules, and the locked Python environment remain under
`.toolchains/nrf52840/`; firmware and reports remain under
`.build/nrf52840/`. Nothing changes Xcode's selected toolchain or the global
`swift` command.

macOS needs CMake 3.29 or newer, Ninja 1.10 or newer, Devicetree Compiler 1.6
or newer, Git, and Python 3.10 through 3.13. Python 3.12.13 is the pinned
baseline. Machine-specific paths can be configured by copying
`scripts/nrf52840/local.env.example` to the ignored
`scripts/nrf52840/local.env`.

Set up and run the hardware-free C-to-Swift Zephyr probe:

```bash
scripts/nrf52840/setup-toolchain.sh
scripts/nrf52840/doctor.sh --probe
```

Activate paths in an interactive shell only when needed:

```bash
source scripts/nrf52840/env.sh
```

Build a named firmware application:

```bash
scripts/nrf52840/build.sh --application skeleton
```

`build.sh` emits the ELF, HEX, map, resolved Devicetree, section/symbol data,
and size report. Flashing is never a build side effect. A connected board is
changed only through an explicit command:

```bash
scripts/nrf52840/flash.sh --application skeleton
```

The included probe proves Zephyr can call an Embedded Swift function for the
nRF52840 target and exercises the DK's first LED/button when flashed. It is a
toolchain milestone, not the completed thermostat, ILI9486 display, or ADS7846
touch port. Those later phases remain governed by
[`docs/GiftUI_nRF52840_DK_Platform_Spec.md`](docs/GiftUI_nRF52840_DK_Platform_Spec.md).

The `skeleton` application is the first application-shaped Swift firmware.
Swift owns its persistent event loop and calls a narrow Zephyr bridge for time,
UART logging, LED1, and Button 1. LED1 blinks while idle and remains lit while
Button 1 is held. It intentionally stops before the static GiftUI runtime,
RGB565 renderer, ILI9486 display, and ADS7846 touch phases.

Swift 6.3.2 names its bundled ARMv7E-M standard module
`armv7em-none-none-eabi`. Zephyr supplies the Cortex-M4F and
`-mfloat-abi=hard` flags, and the build rejects firmware whose ELF does not
declare the VFP hard-float calling convention.

Agent workflows are defined in `skills/giftui-nrf-toolchain` and
`skills/giftui-nrf-build-flash`.

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
The reviewed, staged implementation path from the current dynamic PoC to
separate portable/static and dynamic profiles is in
[`docs/GiftUI_Runtime_Profile_Migration_Plan.md`](docs/GiftUI_Runtime_Profile_Migration_Plan.md).
The proposed Embedded Swift/Zephyr port for the Nordic nRF52840-DK and an
ILI9486/ADS7846 PiScreen is specified separately in
[`docs/GiftUI_nRF52840_DK_Platform_Spec.md`](docs/GiftUI_nRF52840_DK_Platform_Spec.md).

## PoC runtime constraints

The current PoC intentionally uses heap-backed arrays and dictionaries,
escaping button closures, `String`, task-local build context, a full RGBA
framebuffer, and full-root redraws. The runtime and backend already have useful
module seams, but some dynamic storage still lives in the client-facing
`GiftUI` module. The runtime-profile migration plan inventories that coupling
instead of treating the present module layout as allocation-free readiness.

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
