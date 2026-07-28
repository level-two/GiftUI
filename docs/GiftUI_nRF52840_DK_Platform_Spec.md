# GiftUI Nordic nRF52840-DK Platform Specification

**Status:** Proposed platform and migration specification  
**Board:** Nordic nRF52840-DK, `nrf52840dk/nrf52840`  
**CPU target:** Arm Cortex-M4F / `armv7em-none-none-eabihf`  
**Display:** 3.5-inch PiScreen, ILI9486, 480 × 320, SPI  
**Touch:** ADS7846 resistive touchscreen controller, SPI  
**Execution environment:** Embedded Swift integrated with Zephyr  
**Document purpose:** Define the toolchain, wiring, GiftUI migration, resource
limits, validation sequence, and definition of done for an nRF52840-DK port.

---

## 1. Decision Summary

An nRF52840-DK port is possible, but it is a new microcontroller platform
slice. The existing Raspberry Pi executable cannot be retargeted because it
depends on Linux framebuffer, evdev, `libgpiod`, dynamic loading, processes,
and signals.

The intended result is:

```text
Existing GiftUI view declarations
    ↓
GiftUI static/allocation-bounded runtime
    ↓
bounded RGB565 render sink
    ↓
GiftUI nRF52840 Zephyr platform
    ↓
Zephyr SPI, GPIO, display, and input services
    ↓
ILI9486 LCD + ADS7846 touch controller
```

The view DSL should remain common where Embedded Swift permits it. The runtime,
text storage, action storage, framebuffer strategy, application loop, and
hardware adapters must be replaced or specialized.

The PiScreen can be connected electrically through a wiring adapter. It cannot
be plugged directly into the DK: PiScreen uses a Raspberry Pi 26/40-pin HAT
layout, while the nRF52840-DK exposes an Arduino Uno R3 layout and Nordic GPIO
headers.

---

## 2. Goals and Non-Goals

### 2.1 Goals

- Run the thermostat example as nRF52840 firmware.
- Preserve the `View`, stack layout, `Text`, `Button`, and state-driven redraw
  programming model wherever practical.
- Drive the 480 × 320 ILI9486 through SPI without a full-screen framebuffer.
- Read and calibrate the ADS7846 through the same SPI bus with an independent
  chip-select and interrupt input.
- Keep all storage bounded and make capacity failures deterministic.
- Keep the host simulator and Raspberry Pi targets working without behavioral
  regressions.
- Provide reproducible, project-local toolchain setup and build diagnostics.
- Make memory, flash, stack, and SPI performance visible in build reports.

### 2.2 Non-goals for the first board slice

- Running Linux or emulating `/dev/fb1`, evdev, or `libgpiod`.
- Reusing `GiftUIRuntimeDynamic` on the MCU.
- Holding a 480 × 320 framebuffer in nRF52840 RAM.
- Animations, scrolling, Unicode shaping, multiple touch contacts, or a GPU.
- Bluetooth, Thread, Zigbee, or over-the-air update integration.
- Deploying or flashing hardware as an implicit part of a host build.
- Supporting an unknown PiScreen electrical revision without continuity and
  voltage checks.

---

## 3. Hardware and Resource Baseline

The nRF52840 provides a 64 MHz Cortex-M4F, 1 MiB of internal flash, and 256 KiB
of RAM. The DK includes a J-Link debugger and an Arduino Uno R3-compatible
header. All budgets in this document include Zephyr, Embedded Swift runtime
support, application stacks, drivers, GiftUI storage, and display staging.

### 3.1 Framebuffer consequences

| Representation | Calculation | Storage |
| --- | ---: | ---: |
| Current logical RGBA8888 surface | 240 × 240 × 4 | 230,400 bytes |
| Full PiScreen RGBA8888 surface | 480 × 320 × 4 | 614,400 bytes |
| Full PiScreen RGB565 surface | 480 × 320 × 2 | 307,200 bytes |
| One RGB565 scan line | 480 × 2 | 960 bytes |
| Sixteen RGB565 scan lines | 480 × 16 × 2 | 15,360 bytes |

Neither full-screen representation is acceptable. The first implementation
shall use an RGB565 scan-line or tile buffer. A 480 × 16 tile is the preferred
starting point; the height must remain configurable after linker-map and stack
measurements.

### 3.2 Initial resource requirements

- Linked RAM usage must not exceed 192 KiB, leaving at least 64 KiB for measured
  stack headroom, interrupts, and growth.
- Display staging must not exceed 16 KiB by default.
- All GiftUI queues, arenas, text buffers, state slots, and hit regions must
  have compile-time or initialization-time capacities.
- Firmware must fit in internal flash and the build must report flash and RAM
  totals. A warning threshold of 896 KiB flash should reserve upgrade room.
- No full framebuffer may be allocated accidentally, even when dimensions or
  orientation change.
- Heap use after initialization is prohibited for the first production-shaped
  slice. An early bring-up may temporarily enable a bounded heap, but this must
  be reported and removed before the static-runtime milestone is accepted.

---

## 4. Toolchain Configuration

### 4.1 Toolchain model

The nRF52840 target shall use Embedded Swift integrated with Zephyr. Zephyr
owns startup, the linker script, vector table, scheduler/timing facilities,
device configuration, and flashing. Swift compiles the GiftUI and application
sources to objects that are linked into the Zephyr firmware.

The board identifier is:

```text
nrf52840dk/nrf52840
```

The Swift code-generation target is expected to be:

```text
armv7em-none-none-eabihf
```

The target triple, float ABI, CPU, and Zephyr compiler flags must be taken from
the configured Zephyr build rather than duplicated as unverified constants in
multiple scripts.

### 4.2 Isolation from existing toolchains

- Do not change Xcode's selected toolchain or the global `swift` command.
- Do not modify the pinned Raspberry Pi Swift 6.3.2 compiler or ARMv6 SDK.
- Keep nRF52840 downloads and generated SDK/toolchain state under:

  ```text
  .toolchains/nrf52840/
  ```

- Keep generated firmware and reports under:

  ```text
  .build/nrf52840/
  ```

- Keep Zephyr, Zephyr SDK, Embedded Swift, CMake, Ninja, Python environment,
  and J-Link version pins in one tracked configuration file.
- Machine-local paths must live in an ignored local environment file.

### 4.3 Proposed repository interface

The implementation milestone should add:

```text
scripts/nrf52840/toolchain.env
scripts/nrf52840/local.env.example
scripts/nrf52840/setup-toolchain.sh
scripts/nrf52840/env.sh
scripts/nrf52840/doctor.sh
scripts/nrf52840/build.sh
scripts/nrf52840/flash.sh
```

Stable commands should become:

```bash
scripts/nrf52840/setup-toolchain.sh
scripts/nrf52840/doctor.sh
scripts/nrf52840/doctor.sh --probe
scripts/nrf52840/build.sh --application thermostat
scripts/nrf52840/flash.sh --application thermostat
```

`setup-toolchain.sh` may download and unpack pinned dependencies only inside
`.toolchains/nrf52840/`. `doctor.sh --probe` must build a minimal firmware that
calls Swift from the Zephyr application, then inspect its ELF target, sections,
and symbols. It must not require a connected board.

`flash.sh` is a hardware-changing operation and must never run from `build.sh`.
It must identify the generated artifact explicitly and use the DK's J-Link
runner. A future debug command may start a J-Link debug server, but it must not
be a prerequisite for normal builds.

### 4.4 Version and reproducibility requirements

- Pin a known-compatible Embedded Swift development toolchain rather than
  following a moving snapshot URL.
- Pin a supported Zephyr revision after the first successful C/Swift probe.
- Record the Zephyr SDK and Python dependency lock versions.
- Record checksums for downloaded archives.
- Print the complete resolved version set during `doctor.sh`.
- Produce `zephyr.elf`, `zephyr.hex`, `zephyr.map`, size output, and the
  resolved Devicetree under `.build/nrf52840/`.
- Run host-side GiftUI tests with the existing Swift toolchain independently of
  the firmware build.

---

## 5. Hardware Wiring

### 5.1 Electrical rules

- Disconnect all power before changing wiring.
- Use a common ground between the DK and PiScreen.
- nRF52840 GPIO is 3.3 V logic and is not 5 V tolerant. No signal presented to
  an nRF52840 GPIO may exceed `VDD + 0.3 V`.
- Do not infer the PiScreen power rail from the connector shape. Confirm the
  exact board marking, schematic, or continuity path before applying power.
- Do not connect both 3.3 V and 5 V PiScreen power inputs.
- Do not drive the LCD backlight current directly from an nRF52840 GPIO. Use
  the PiScreen's existing enable/transistor input, or add a suitable transistor
  stage if the board exposes the LED load directly.
- Check that LCD and touch MISO are high-impedance while their chip-selects are
  inactive before sharing the bus.

### 5.2 PiScreen-side signals

The known ILI9486/ADS7846 PiScreen arrangement normally uses Raspberry Pi SPI0
with the LCD on chip-select 0 and touch on chip-select 1. The following pins
match the common PiScreen overlay and are the hardware baseline to verify with
continuity testing:

| Function | Raspberry Pi physical pin | BCM signal | Notes |
| --- | ---: | --- | --- |
| SPI MOSI | 19 | GPIO10 / MOSI | Shared by LCD and touch |
| SPI MISO | 21 | GPIO9 / MISO | Required by ADS7846 |
| SPI SCLK | 23 | GPIO11 / SCLK | Shared by LCD and touch |
| LCD CS | 24 | GPIO8 / CE0 | Active low |
| Touch CS | 26 | GPIO7 / CE1 | Active low |
| LCD D/C | 18 | GPIO24 | Command/data select |
| LCD reset | 22 | GPIO25 | Normally active low |
| Touch IRQ / PENIRQ | 11 | GPIO17 | Active-low interrupt |
| Backlight enable | 15 | GPIO22 | Polarity must be verified |
| Ground | 6, 9, 14, 20, or 25 | GND | Connect at least one solid ground |
| Panel power | revision-dependent | 3.3 V or 5 V | Verify before connection |

This table is not authorization to power an unidentified clone. Controller
identity alone does not guarantee identical power or backlight circuitry.

### 5.3 Proposed nRF52840-DK signal assignment

Use the DK's Arduino SPI3 routing for the shared bus. The proposed control pins
are adjacent Arduino digital pins and avoid the DK's built-in buttons, LEDs,
QSPI flash, NFC pins, and default debug connection.

| PiScreen function | DK Arduino pin | nRF52840 GPIO | Configuration |
| --- | --- | --- | --- |
| SPI MOSI | D11 | P1.13 | SPI3 MOSI |
| SPI MISO | D12 | P1.14 | SPI3 MISO |
| SPI SCLK | D13 | P1.15 | SPI3 SCK |
| LCD CS | D10 | P1.12 | GPIO chip-select, active low |
| LCD D/C | D9 | P1.11 | GPIO output |
| LCD reset | D8 | P1.10 | GPIO output, active low |
| Touch CS | D7 | P1.08 | GPIO chip-select, active low |
| Touch IRQ | D6 | P1.07 | GPIO input, pull-up, falling edge |
| Backlight enable | D5 | P1.06 | GPIO/PWM control after polarity check |
| Ground | GND | GND | Common ground |
| Panel power | 3.3 V, 5 V, or external | Not a GPIO | Select only after board verification |

This is a proposed adapter mapping, not an instruction to line up Raspberry Pi
and Arduino header positions. The adapter shall connect by signal name.

### 5.4 Shared SPI bus requirements

- LCD and touch must have independent chip-select GPIOs.
- Both chip-selects must be inactive during reset and boot until their drivers
  initialize.
- The LCD starts with a conservative SPI clock. Increase it only after repeated
  full-screen and dirty-rectangle tests pass.
- The ADS7846 starts at no more than 2 MHz unless its exact data sheet and board
  layout validate a different value.
- Changing between LCD and touch transactions must also change the SPI
  frequency and any required mode safely.
- No display transaction may monopolize the bus long enough to lose a touch
  press. Large regions must be split into bounded transfers if needed.
- DMA is optional for bring-up and recommended only after a synchronous driver
  is correct and memory ownership is explicit.

### 5.5 ILI9486 display requirements

The platform must provide or integrate an ILI9486 driver that supports:

- hardware reset and a revision-appropriate initialization sequence;
- sleep-out and display-on sequencing with required delays;
- 480 × 320 address windows;
- RGB565 pixel input, including verified byte order;
- memory write commands for rectangular regions;
- 0°, 90°, 180°, and 270° orientation, or one documented fixed orientation for
  the first milestone;
- RGB/BGR selection and MADCTL validation;
- bounded transfers from scan-line or tile storage;
- backlight enable only after successful controller initialization.

ILI9486 support must be confirmed against the pinned Zephyr revision. If that
revision has no usable ILI9486 binding/driver, add a project-local Zephyr
display driver or a narrowly scoped ILI9xxx profile. Do not pretend the device
is an ILI9341 merely because some commands overlap.

### 5.6 ADS7846 touch requirements

The touch adapter must support:

- active-low PENIRQ wake-up;
- SPI coordinate and pressure sampling;
- bounded oversampling/median or trimmed filtering;
- press and release detection without busy waiting;
- raw range calibration;
- X/Y swap, inversion, and display-rotation mapping;
- rejection of samples outside calibrated ranges;
- conversion into GiftUI pointer down, move, and up events.

Zephyr includes an XPT2046 input driver in recent revisions. ADS7846 reuse must
be validated against the actual wire protocol and configuration; it is not an
assumption. If compatibility tests fail or the binding cannot express the
required ADS7846 behavior, implement a project-local ADS7846 input driver.

Initial calibration defaults may use raw 0...4095 ranges, swapped axes, an
X-plate resistance near 100 ohms, and a pressure ceiling near 255 only as
bring-up values. Production values must be measured on this screen and stored
in the board configuration.

---

## 6. GiftUI Stack Migration Guide

### 6.1 Module boundaries

The port should add these conceptual modules without changing the Linux and
macOS dependency direction:

```text
GiftUI                              shared declarative API and geometry
GiftUIRuntimeStatic                 bounded state/layout/action runtime
GiftUIBackendRGB565                 scan-line/tile rasterization
GiftUIPlatformZephyr                scheduler, time, GPIO, SPI/input bridges
GiftUIPlatformNRF52840              board defaults and hardware configuration
GiftUIExampleThermostatNRF52840     firmware entry point
```

The exact CMake/Swift module packaging may differ from SwiftPM target names,
but dependency direction must remain the same. `GiftUI` must not import Zephyr,
Nordic, ILI9486, or ADS7846 APIs.

### 6.2 Profile selection and application portability

This firmware selects the portable/static GiftUI profile at compile time. It
must not expose dynamic-only overloads and then trap when they are used.

The framework-level portability contract is defined in
[`GiftUI_Framework_Spec.md`](GiftUI_Framework_Spec.md), section 3.3. For this
board it means:

- core layout, state/invalidation semantics, rendering order, and hit testing
  remain invariant;
- storage and execution implementations are nRF52840-specific and bounded;
- a view source remains unchanged only if it uses portable-profile APIs;
- escaping closure callbacks and unbounded `String` interpolation are not
  assumed portable merely because they work in the macOS and Linux products;
- ILI9486, ADS7846, Zephyr, and board APIs remain below the view declaration.

The current thermostat source uses closure-backed buttons and interpolated
`String`. The migration must therefore choose and verify one of these paths:

1. replace those uses with typed actions and bounded text, then use the same
   portable thermostat source in dynamic and static configurations; or
2. prove that the selected Embedded Swift compiler lowers the existing closure
   and text forms into bounded, allocation-free storage, then admit those exact
   forms into the portable profile with generated-code and allocation tests.

Path 1 is the required baseline. Path 2 is an optional ergonomic optimization;
it must not delay a correct static port.

No `#if` or runtime `if available` branch may be added to `ThermostatView` for
Zephyr, ILI9486, ADS7846, or static storage. Compile-time conditions belong in
the profile facade, runtime implementation, platform entry point, or hardware
adapter. Runtime checks are appropriate only for physical state such as a
missing/unresponsive touch controller.

### 6.3 Current-to-target migration map

| Current implementation | Why it cannot be used unchanged | Required replacement |
| --- | --- | --- |
| `DynamicStateStore` dictionary of `Any` | Runtime type metadata and unbounded allocation | Generated or typed fixed-capacity state layout |
| `ViewNode` reference tree with child arrays | Heap use and unbounded node count | Index-based nodes in a fixed arena, or direct traversal |
| Button closures in dictionaries | Escaping closure and dictionary storage | Typed application action IDs/enums |
| `String` and interpolation everywhere | Unbounded allocation and formatting | Static strings plus bounded UTF-8/integer formatting |
| `DisplayList` array | Grows dynamically | Direct render sink or fixed operation buffer |
| `HitTestMap` array and action dictionary | Grows dynamically | Fixed hit-region table paired with typed actions |
| `BuiltinFont8x12` string dictionary | Runtime dictionary and per-glyph arrays | Compile-time scalar lookup table in flash |
| RGBA8888 `MemoryFramebufferSurface` | 230,400 bytes even at 240 × 240 | RGB565 tile/scan-line surface |
| Linux framebuffer presenter | Requires `/dev/fb*`, `mmap`, and `ioctl` | ILI9486 rectangular SPI writer |
| evdev input | Requires Linux input devices | ADS7846 Zephyr input adapter |
| `libgpiod` navigation buttons | Requires Linux shared library and file descriptors | Zephyr GPIO callbacks/events |
| Linux poll/signal loop | Requires process/OS facilities | Zephyr event loop and timer |

### 6.4 Embedded Swift compatibility pass

Before designing static storage around code that does not compile, create an
Embedded Swift compile-only target for the shared `GiftUI` sources. Classify
every diagnostic into:

1. language feature unavailable in Embedded Swift;
2. supported language feature with unacceptable allocation;
3. standard-library API unavailable for the selected target;
4. module/build-system incompatibility;
5. platform code that belongs outside core.

Known work includes removal or specialization of weak references, `Any` state,
existential state storage, class-backed `@State`, dynamically allocated node
trees, dictionaries, and string-keyed font lookup.

The compatibility pass must produce a tracked inventory. It must not weaken
the macOS/Linux implementation simply to silence embedded diagnostics; use
profile-specific storage and implementations where appropriate.

### 6.5 Static state and invalidation

The thermostat milestone needs one `Int` state value but the runtime design
must not hard-code temperature semantics.

Preferred progression:

1. Prove state invalidation with an application-specific typed state struct.
2. Add fixed typed slots or generated state layout keyed by structural identity.
3. Adapt `@State` to bind to a static location without `Any`, reflection, or a
   heap-allocated location object.
4. Make missing slots, type/layout mismatches, and exhaustion deterministic
   build or runtime errors.

No static-runtime state write may silently fall back to local property-wrapper
storage after the view has been bound.

### 6.6 Static view expansion and layout

Replace `ViewNode` allocation with one of:

- a fixed arena of compact nodes referenced by integer indices; or
- direct generic traversal that measures, places, and emits without retaining
  a complete dynamic tree.

The fixed arena is the preferred first migration because it retains the
current measure/place behavior and is easier to compare against host golden
tests. Its capacity, maximum child count, and traversal depth must be explicit.

The thermostat firmware must fail deterministically if a view exceeds those
capacities. Recursion depth and task/interrupt stack measurements are required.

### 6.7 Typed actions and interaction snapshot

For the first firmware, use a typed action model such as:

```swift
enum ThermostatAction: UInt8 {
    case decrement
    case increment
}
```

Each bounded hit region stores an action ID. The application dispatches that
ID against its mutable state. This replaces closure capture and the dynamic
action dictionary while preserving the observable `Button` behavior.

Longer term, result-builder overloads or generated adapters may allow the
existing closure-shaped declaration to lower into typed static actions. Until
that is proven, source compatibility is a goal rather than an unsupported
claim.

### 6.8 Bounded text and font data

The static text profile must provide:

- zero-allocation static labels;
- bounded integer formatting for the temperature value;
- explicit UTF-8 capacity and truncation/overflow behavior;
- a font lookup table stored in flash and indexed by scalar/code point;
- the glyphs required by `Target`, digits, minus, plus, and degree sign.

The dynamic `Text(String)` API may remain for host targets. The static target
may introduce a bounded text value internally or publicly if the Embedded
Swift compiler cannot specialize the existing path safely.

### 6.9 RGB565 tile renderer

The renderer shall:

1. lay out in logical coordinates;
2. intersect each render operation with the current physical tile;
3. rasterize directly into RGB565 storage;
4. set the ILI9486 address window for the dirty tile/rectangle;
5. transfer the buffer over SPI;
6. reuse the same bounded storage for the next tile.

Color conversion and byte order must be unit tested. Clipping must prevent all
buffer overrun when operations partially overlap a tile.

The first correct implementation may redraw every tile. The next optimization
should track dirty rectangles from invalidation and update only affected
regions. A thermostat button press should not require a full-screen transfer
after dirty-region support is accepted.

### 6.10 Zephyr application loop

The firmware loop must be event driven:

- initialize display, touch, and optional button inputs;
- perform the initial layout/render;
- sleep while no event or invalidation is pending;
- translate touch samples into GiftUI pointer events;
- mutate state and coalesce invalidations;
- render the next consistent frame;
- avoid rendering or SPI work in GPIO interrupt context.

Touch IRQ handlers should signal a work item or queue. Rendering belongs in one
serialized application context so state, the interaction snapshot, and the
presented pixels remain consistent.

---

## 7. Migration Plan and Acceptance Gates

### Phase 0 — Hardware provenance and baseline

1. Record the PiScreen vendor/revision and photograph both sides.
2. Verify ILI9486 and ADS7846 identity from the working Raspberry Pi overlay or
   hardware documentation.
3. Record the working Pi SPI clocks, orientation, RGB/BGR mode, initialization,
   touch ranges, axis transforms, pressure limits, and backlight polarity.
4. Verify every PiScreen connector signal with continuity or schematic data.
5. Measure the panel current and logic-high voltages.

**Gate:** A reviewed wiring sheet exists; no power or signal pin remains an
assumption.

### Phase 1 — Toolchain and board probe

1. Pin Embedded Swift, Zephyr, Zephyr SDK, CMake, Ninja, Python, and J-Link.
2. Add project-local setup and doctor scripts.
3. Build a Zephyr firmware containing a Swift function.
4. Validate Cortex-M4F target, hard-float behavior, ELF sections, map output,
   UART logging, and a DK LED/button interaction.
5. Flash only through the explicit flash command.

**Gate:** `doctor.sh --probe` succeeds without hardware and the probe runs when
flashed to the DK.

### Phase 2 — Embedded-compatible GiftUI core

1. Add the compile-only Embedded Swift target.
2. Inventory unsupported and allocating constructs.
3. Isolate dynamic-only implementations behind module/profile boundaries.
4. Keep existing host tests green.

**Gate:** The agreed shared core subset compiles for Embedded Swift without
linking Linux or Apple frameworks.

### Phase 3 — Static thermostat runtime on the host

1. Implement bounded state, node, action, hit-region, text, and render storage.
2. Convert the thermostat to portable typed actions and bounded text unless
   allocation-free lowering of its existing syntax has already been proven.
3. Run the same portable thermostat source with static and dynamic storage in
   host conformance tests.
4. Add explicit capacity-exhaustion and dynamic-API rejection tests.
5. Compare layout, pixels, touch dispatch, and state changes with the dynamic
   runtime.

**Gate:** The same portable thermostat source passes deterministic static and
dynamic host tests; the static build rejects dynamic-only APIs at compile time;
heap use is disabled or instrumented as zero after initialization.

### Phase 4 — RGB565 backend on the host

**Status:** Complete on the host. The renderer also passes the Embedded Swift
module-compilation gate; hardware transport integration remains Phase 5.

1. Implement scan-line/tile rasterization.
2. Add RGBA-to-RGB565 equivalence/golden tests where applicable.
3. Test clipping, rotation, byte order, and odd rectangle dimensions.
4. Assert the maximum display allocation.

**Gate:** A 480 × 320 frame renders using at most the configured tile buffer;
no full framebuffer allocation is possible.

### Phase 5 — ILI9486 display bring-up

**Status:** Hardware-free firmware implementation complete; connected-board
validation pending. See
[`GiftUI_ILI9486_Bring_Up_Record.md`](GiftUI_ILI9486_Bring_Up_Record.md).

1. Build the wiring adapter and verify unpowered continuity.
2. Bring up reset, backlight control, and an ILI9486 color-bar test in C/Zephyr.
3. Validate RGB565, orientation, address windows, and conservative SPI speed.
4. Integrate the Swift RGB565 backend.
5. Measure full-screen and dirty-region transfer times.

**Gate:** Repeated test patterns and the static thermostat render without
corruption, watchdog resets, or out-of-bounds writes.

### Phase 6 — ADS7846 touch bring-up

1. Validate PENIRQ and shared-bus arbitration independently of GiftUI.
2. Capture raw corner/center samples and derive calibration.
3. Add filtering, pressure threshold, orientation mapping, and release events.
4. Feed events through GiftUI hit testing and typed action dispatch.

**Gate:** At least 100 presses on each thermostat control are correctly
classified, including presses near control edges, with no stuck-touch state.

### Phase 7 — Optimization and hardening

1. Add dirty-region rendering.
2. Tune tile height and SPI transfer segmentation from measurements.
3. Measure stack high-water marks and worst-case event latency.
4. Disable accidental heap fallback.
5. Add fault logging for capacity, SPI, and controller errors.
6. Run long-duration touch/render and power-cycle tests.

**Gate:** All resource, latency, reliability, and safety requirements in this
specification pass and are captured in a hardware validation report.

---

## 8. Requirements and Definition of Done

### 8.1 Functional requirements

- The firmware declares and builds against the portable/static GiftUI profile.
- The same thermostat behavior displays `Target`, a value, and decrement and
  increment controls.
- The portable thermostat view source also runs under the dynamic host runtime
  without platform or profile conditionals in the view declaration.
- Pressing the touch regions changes state exactly once per completed tap.
- The displayed value reflects the updated state on the next render.
- Layout and hit testing agree for every supported orientation.
- Display, touch, and the four DK buttons may coexist; using DK buttons as a
  fallback navigation source is recommended for diagnostics.

### 8.2 Determinism and safety requirements

- Every runtime capacity is documented and tested at its boundary.
- No SPI, allocation, logging, or rendering occurs in GPIO interrupt context.
- Buffer sizes and address-window arithmetic are overflow checked.
- Both SPI chip-selects have safe inactive boot states.
- A touch-controller failure cannot prevent display updates indefinitely.
- A display-controller failure produces a bounded error path rather than an
  infinite retry loop.
- No flashing happens as a side effect of building or testing.

### 8.3 Performance requirements

- Report measured full-screen refresh time at the accepted SPI clock.
- Report median and worst-case touch-to-visible-update latency.
- The initial performance target is a visible response within 150 ms for a
  dirty thermostat control update.
- Touch sampling must remain responsive during large display transfers.
- The application must sleep or block on events while idle rather than spin.

### 8.4 Verification requirements

- Existing macOS, core, dynamic-runtime, framebuffer, Linux, and Raspberry Pi
  tests remain green.
- Contract tests demonstrate equal portable semantics under both runtimes.
- Compile-fail tests demonstrate that dynamic-only conveniences are absent from
  the static API surface.
- Static runtime and RGB565 backend have host-side unit and integration tests.
- The firmware build checks ELF architecture and emits a map/size report.
- Hardware validation records display controller ID/provenance, wiring,
  calibration, SPI clocks, orientation, memory use, stack margin, and latency.
- Power-cycle testing starts with both chip-selects inactive and reaches a
  correct initial frame without manual intervention.

The nRF52840-DK platform is complete only when all acceptance gates pass on the
specified ILI9486/ADS7846 PiScreen hardware. Successful compilation alone is
not board support.

---

## 9. Open Decisions

- Exact PiScreen revision, power input, and backlight circuit.
- Pinned Embedded Swift and Zephyr revisions after the compatibility probe.
- Reuse versus project-local implementation of the ILI9486 Zephyr driver.
- Reuse of the Zephyr XPT2046 driver versus a dedicated ADS7846 driver.
- Fixed arena versus direct generic traversal after Embedded Swift diagnostics.
- Public bounded-text API versus a static-runtime internal representation.
- Required display orientations for the first board milestone.
- Whether DMA improves latency enough to justify its ownership complexity.

These decisions must be closed with measurements or source/hardware evidence,
not by relying on controller-family similarity.

---

## 10. References

- [Introduction to Embedded Swift](https://docs.swift.org/embedded/documentation/embedded/introduction/)
- [Embedded Swift with Zephyr](https://docs.swift.org/embedded/documentation/embedded/integratewithzephyr/)
- [Embedded Swift restrictions](https://docs.swift.org/compiler/documentation/diagnostics/embedded-restrictions/)
- [Nordic nRF52840-DK](https://www.nordicsemi.com/Software-and-Tools/Development-Kits/nRF52840-DK)
- [Zephyr nRF52840-DK board documentation](https://docs.zephyrproject.org/latest/boards/nordic/nrf52840dk/doc/index.html)
- [Zephyr nRF52840-DK board Devicetree](https://github.com/zephyrproject-rtos/zephyr/blob/main/boards/nordic/nrf52840dk/nrf52840dk_nrf52840.dts)
- [Zephyr display API sample](https://docs.zephyrproject.org/latest/samples/drivers/display/README.html)
- [Zephyr input subsystem](https://docs.zephyrproject.org/latest/services/input/index.html)
- [Zephyr XPT2046 binding](https://docs.zephyrproject.org/latest/build/dts/api/bindings/input/xptek%2Cxpt2046.html)
- [Community ILI9486/ADS7846 PiScreen overlay used as a pinout baseline](https://gist.github.com/alexryndin/4fc940ae344751d7f34a2394d24b51ca)
- [`GiftUI_Framework_Spec.md`](GiftUI_Framework_Spec.md)
- [`GiftUI_Raspberry_Pi_Platform.md`](GiftUI_Raspberry_Pi_Platform.md)
