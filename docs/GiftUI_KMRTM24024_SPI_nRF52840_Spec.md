# GiftUI KMRTM24024-SPI nRF52840 Support Specification

**Status:** Proposed implementation specification
**Parent platform:** Nordic nRF52840-DK, `nrf52840dk/nrf52840`
**Swift target:** `armv7em-none-none-eabi` with Zephyr hard-float flags
**Display module:** KMRTM24024-SPI, 2.4-inch TFT, 240 × 320, four-wire SPI
**Expected controller:** ILI9341; provisional until verified on the exact module
**Optional touch:** XPT2046/ADS7846-compatible resistive touch controller
**Runtime profile:** GiftUI portable/static, heap disabled
**Purpose:** Define the requirements, module boundaries, implementation plan,
hardware gates, validation, and optional readback-enabled rendering work for a
separate KMRTM24024-SPI framework and nRF52840 firmware target.

---

## 1. Decision Summary

Support shall be added alongside, not inside, the existing ILI9486 PiScreen
application. The two displays share the static GiftUI runtime and bounded
RGB565 renderer, but their electrical interfaces and controller protocols are
different:

- the existing PiScreen driver writes through an SPI-to-16-bit-parallel bridge;
- the KMRTM24024-SPI is expected to expose the ILI9341's native four-wire,
  8-bit SPI interface;
- the KMRTM module is 240 × 320 rather than 480 × 320;
- display SDO/MISO appears to be exposed on common boards, but this must be
  verified on the exact unit before readback is enabled.

The implementation shall add:

```text
GiftUIDisplayILI9341                  Swift library product and target
Tests/GiftUIDisplayILI9341Tests       host transport/render integration tests
firmware/nrf52840/applications/
  kmrtm24024_spi/                     separate Zephyr firmware application
```

The stable firmware command shall be:

```bash
scripts/nrf52840/build.sh --application kmrtm24024_spi
```

Flashing remains explicit:

```bash
scripts/nrf52840/flash.sh --application kmrtm24024_spi
```

The first usable target is write-only from GiftUI's perspective: initialize
the panel, render the static thermostat through `GiftUIBackendRGB565`, and use
dirty-region writes backed by the LCD's retained GRAM. Display readback is a
separate capability gate and must not block baseline display support.

The pinned Zephyr 4.3.0 tree already contains:

- `ilitek,ili9341` display support;
- the `zephyr,mipi-dbi-spi` four-wire SPI transport;
- RGB565 rectangular `display_write`;
- optional `display_read` when `CONFIG_ILI9XXX_READ=y` and the DBI transport is
  not marked `write-only`.

The baseline shall reuse that driver unless connected-hardware evidence shows
that the module needs a different initialization profile or the driver cannot
meet correctness/resource requirements. GiftUI-specific adaptation remains in
the new framework rather than being added to `GiftUI`, the static runtime, or
the existing ILI9486 application.

---

## 2. Provenance and Assumptions

`KMRTM24024-SPI` is a module marking, not a sufficiently authoritative
controller or schematic identifier. Community reports associate the common
red module with an ILI9341 and frequently an XPT2046-compatible touch
controller, but visually similar 240 × 320 modules also ship with other
controllers and different power circuitry.

The following remain assumptions until Phase 0 closes them:

- the LCD controller is an ILI9341 or a command-compatible device approved by
  an explicit profile;
- the display is wired for four-wire 8-bit SPI;
- LCD SDO is connected from the controller to the module header;
- LCD SDO becomes high-impedance while LCD chip-select is inactive;
- a fitted touch controller, if any, is XPT2046/ADS7846-compatible;
- the LCD and touch data-out pins can safely share nRF52840 MISO;
- the VCC, LED, and logic pins have the electrical behavior expected from the
  exact module revision.

Before power is applied, record:

1. clear photographs of both sides;
2. every silkscreen label and populated controller marking;
3. regulator, level-shifter, LED resistor, and touch-controller population;
4. unpowered continuity between header pins and controller/support circuitry;
5. the intended supply rail and measured resistance to ground;
6. whether the board already works with a known ILI9341 implementation and the
   exact initialization, orientation, and SPI settings used there.

**Gate:** no controller, supply, backlight, or connector fact used by the
firmware remains inferred only from the `KMRTM24024-SPI` marking.

---

## 3. Goals and Non-Goals

### 3.1 Goals

- Add a distinct, host-testable ILI9341 display framework without regressing
  the existing ILI9486/ADS7846 application.
- Add a distinct nRF52840 firmware target for the KMRTM24024-SPI module.
- Reuse `GiftUI`, `GiftUIRuntimeStatic`, `GiftUIBackendRGB565`,
  `GiftUIBuiltinFont`, and the portable thermostat view unchanged.
- Drive the 240 × 320 panel with bounded RGB565 tiles and no required MCU full
  framebuffer.
- Support 0°, 90°, 180°, and 270° logical orientations, with one connected-
  hardware-validated orientation required for the first milestone.
- Preserve deterministic capacity failures and zero heap allocation.
- Support optional touch by reusing `GiftUIInputADS7846` after the physical
  controller and wiring are verified.
- Detect and report display-controller, SPI, capacity, and optional readback
  failures through bounded fault paths.
- Measure full refresh, dirty update, stack, flash, RAM, and touch latency.
- Investigate and, when hardware proves it viable, expose bounded GRAM
  readback for diagnostics and advanced read-modify-write rendering.

### 3.2 Non-goals for the baseline

- Replacing the existing `ili9486` target.
- Treating all 2.4-inch 240 × 320 SPI modules as interchangeable.
- Requiring a full RGB565 framebuffer in nRF52840 RAM.
- Using `GiftUIRuntimeDynamic`, Foundation, Linux APIs, Objective-C runtime
  features, or unbounded collections in firmware.
- Requiring touch to declare baseline display support complete.
- Adding SD-card support merely because some related modules contain a slot.
- Flashing a connected board as a build or test side effect.
- Promising alpha compositing, screenshots, or GRAM copies before SDO and
  readback correctness are proven on hardware.

---

## 4. Architecture and Module Boundaries

### 4.1 Dependency direction

```text
GiftUIExampleThermostatPortableView
                 │
                 ▼
       GiftUIRuntimeStatic
                 │
                 ▼
       GiftUIBackendRGB565
                 │
                 ▼
       GiftUIDisplayILI9341
                 │
                 ▼
 kmrtm24024_spi Zephyr application
                 │
                 ▼
 Zephyr display + MIPI-DBI + SPI/GPIO
                 │
                 ▼
           KMRTM24024-SPI
```

`GiftUI` must not import ILI9341, Zephyr, SPI, GPIO, or module-specific APIs.
`GiftUIBackendRGB565` remains controller-independent. The new display framework
may depend on `GiftUI` geometry and `GiftUIBackendRGB565`, but must not import
Zephyr so it can be compiled and tested on the host.

### 4.2 Proposed package surface

Add a SwiftPM library product and target:

```swift
.library(name: "GiftUIDisplayILI9341", targets: ["GiftUIDisplayILI9341"])
```

The target should provide statically dispatched, allocation-bounded concepts
equivalent to:

- display geometry and orientation configuration;
- rectangular RGB565 presentation;
- solid-rectangle writing compatible with `RGB565SolidRectWriter`;
- capability reporting for register reads and GRAM reads;
- optional bounded RGB565 rectangular reads;
- transport-neutral error/fault values suitable for Embedded Swift.

Exact API names may change during implementation. The following constraints
may not:

- transport is generic/static or otherwise proven allocation-free; no
  protocol existential is retained in the firmware hot path;
- caller-owned or fixed-capacity buffers are used for all pixel I/O;
- rectangle and byte-count arithmetic is overflow checked;
- read capability is explicit, not inferred from a non-null MISO pin;
- host fakes can capture lifecycle calls, rectangles, bytes, and errors;
- no Zephyr headers or board pin assignments enter the SwiftPM target.

The framework adapts GiftUI rendering to an already configured display
transport. Zephyr owns the baseline ILI9341 register sequence and address-window
commands. The framework must not maintain a second competing initialization
table.

### 4.3 Firmware target responsibilities

`firmware/nrf52840/applications/kmrtm24024_spi/` owns:

- `CMakeLists.txt`, `prj.conf`, and the DK overlay;
- Zephyr device lookup and the C/Swift bridge;
- SPI, GPIO, reset, sleep, uptime, and bounded logging;
- optional touch-controller initialization and sampling;
- the application loop and hardware fault policy;
- the module-specific, hardware-validated initialization overrides;
- connected-hardware diagnostics and validation output.

It shall not copy the ILI9486 bridge encoding. Native ILI9341 command and pixel
bytes are sent as 8-bit SPI transfers.

### 4.4 Zephyr driver decision

Use the pinned Zephyr `ilitek,ili9341` driver and `zephyr,mipi-dbi-spi` transport
for the baseline. Before accepting this decision, verify on the exact module:

- reset and initialization complete reliably after cold power-on;
- controller register values and color/gamma settings are correct;
- RGB565 byte order and RGB/BGR selection match GiftUI colors;
- all required orientations map the full 240 × 320 address space;
- `display_write` accepts the bounded tile pitch used by GiftUI;
- the driver and selected Kconfig remain heap-free;
- the linked image stays inside repository flash/RAM limits.

If only initialization differs, override the documented Devicetree register
properties for the KMRTM profile. Add a project-local controller driver only
if the Zephyr driver cannot satisfy a measured requirement. Never patch the
generated checkout under `.toolchains/nrf52840/`.

The current Zephyr display API exposes `display_read`, but read support is
compile-time optional. A later optimized batch-reader may be project-local if
the upstream pixel-at-a-time conversion path is too slow; it must remain
behind the same capability contract.

---

## 5. Hardware Interface

### 5.1 Expected module signals

The common 14-pin module layout is listed only as a continuity checklist:

| Position | Common label | Expected role | Required for baseline |
| ---: | --- | --- | --- |
| 1 | `VCC` | Module power | Yes; voltage must be verified |
| 2 | `GND` | Common ground | Yes |
| 3 | `CS` | LCD chip-select, active low | Yes |
| 4 | `RESET` | LCD reset, active low | Yes |
| 5 | `DC/RS` | LCD command/data select | Yes |
| 6 | `SDI(MOSI)` | LCD data input | Yes |
| 7 | `SCK` | LCD serial clock | Yes |
| 8 | `LED` | Backlight supply/enable | Yes; circuit must be verified |
| 9 | `SDO(MISO)` | LCD data output | Optional readback |
| 10 | `T_CLK` | Touch clock | Optional touch |
| 11 | `T_CS` | Touch chip-select | Optional touch |
| 12 | `T_DIN` | Touch data input | Optional touch |
| 13 | `T_DO` | Touch data output | Optional touch |
| 14 | `T_IRQ` | Touch interrupt, normally active low | Optional touch |

The actual silkscreen and continuity record supersede this table.

### 5.2 Proposed nRF52840-DK mapping

Reuse the proven Arduino SPI routing and control-pin pattern from the existing
PiScreen application while keeping a distinct overlay:

| Function | DK Arduino pin | nRF52840 GPIO | Notes |
| --- | --- | --- | --- |
| SPI MOSI | D11 | P1.13 | LCD SDI; optionally touch T_DIN |
| SPI MISO | D12 | P1.14 | LCD SDO and/or touch T_DO after tri-state test |
| SPI SCLK | D13 | P1.15 | LCD SCK; optionally touch T_CLK |
| LCD CS | D10 | P1.12 | Active low |
| LCD D/C | D9 | P1.11 | Command/data |
| LCD reset | D8 | P1.10 | Active low |
| Touch CS | D7 | P1.08 | Optional, active low |
| Touch IRQ | D6 | P1.07 | Optional input/pull-up |
| Backlight control | D5 | P1.06 | Only after load and polarity verification |

If LCD SDO and touch T_DO do not both become high-impedance when deselected,
do not tie them directly together. Resolve that with separate SPI routing,
verified series isolation, or a buffer before enabling both devices.

### 5.3 Electrical safety

- nRF52840 GPIO uses 3.3 V signaling and is not 5 V tolerant.
- Do not infer safe logic levels from an onboard VCC regulator.
- Do not drive the LED load directly from a GPIO unless measured current and
  the exact board circuit prove that the pin is only a logic-level enable.
- Keep LCD and touch chip-selects inactive during reset and early boot.
- Disconnect power before changing wiring.
- Do not connect the display until the module-side rail and polarity are
  recorded.
- Start at a conservative SPI frequency and raise it only through the
  validation ladder.

---

## 6. Display and Transport Requirements

### 6.1 Baseline controller behavior

The accepted driver must support:

- hardware reset with datasheet-compliant delays;
- software reset, sleep-out, normal mode, and display-on sequencing;
- 240 × 320 address windows using `CASET` and `PASET`;
- RGB565 memory writes using `RAMWR`;
- explicit RGB/BGR and orientation control through `MADCTL`;
- explicit pixel format through `COLMOD`;
- rectangular writes with checked `x`, `y`, width, height, pitch, and size;
- display blanking/backlight policy that avoids a bright random frame at boot;
- bounded error propagation from GPIO, SPI, controller, and capacity failures.

Controller detection should read ID/status registers when SDO is available and
record the observed response. A successful write-only color-bar test is still
required because clone ID responses are not by themselves proof of behavior.

### 6.2 SPI configuration

- Use SPI mode 0 unless hardware validation identifies a different mode.
- Begin display bring-up at 4 MHz.
- The ILI9341 specification gives a 100 ns minimum write clock cycle and a
  150 ns minimum read clock cycle. Treat 10 MHz write and approximately
  6.67 MHz read as controller-side ceilings unless the exact controller's
  authoritative data allows otherwise.
- A faster nRF52840 SPIM capability does not override the panel limit.
- Increase the display clock through 4 MHz, 8 MHz, and at most the accepted
  controller limit, running corruption and power-cycle tests at each step.
- Touch begins at no more than 2 MHz and uses its own chip-select/configuration.
- Keep command, dummy clocks, and response inside one correctly held-CS read
  transaction.
- Break long display writes into bounded segments when needed for EasyDMA,
  touch latency, or watchdog service.
- Render and SPI transfer must not occur in GPIO interrupt context.

### 6.3 Geometry and byte order

The physical surface is portrait 240 × 320. Logical landscape is 320 × 240.
The implementation must have one source of truth for rotation so that software
rotation in `RGB565RendererConfiguration` is not accidentally combined with a
second controller rotation.

For each supported orientation, test:

- four uniquely colored corners;
- odd-width and odd-height rectangles;
- the final row and column;
- RGB, white, black, and mid-gray canonical RGB565 values;
- dirty rectangles crossing the renderer's tile boundary;
- text and hit-test alignment.

### 6.4 Performance requirements

- Report full-frame payload and end-to-end render time at every accepted
  display clock.
- At 4, 8, and 10 MHz, a 153,600-byte RGB565 payload has theoretical minimum
  wire times of about 307.2, 153.6, and 122.9 ms respectively; measured time
  will be higher due to commands, segmentation, scheduling, and rasterization.
- Preserve the parent platform target of at most 150 ms from an accepted input
  event to a visible dirty thermostat update.
- Report median, 95th-percentile, and maximum dirty-update latency.
- Read-modify-write features must publish their maximum supported region size
  and worst-case latency. They must not stall touch or watchdog service.
- The application must sleep or block while idle rather than spin.

---

## 7. Memory and Resource Budgets

### 7.1 Pixel storage

| Representation | Calculation | Storage |
| --- | ---: | ---: |
| Full RGBA8888 framebuffer | 240 × 320 × 4 | 307,200 bytes |
| Full RGB565 framebuffer | 240 × 320 × 2 | 153,600 bytes |
| Four-row RGB565 tile | 240 × 4 × 2 | 1,920 bytes |
| Four-row RGB666 read scratch | 240 × 4 × 3 | 2,880 bytes |
| RGB565 + RGB666 four-row pair | 1,920 + 2,880 | 4,800 bytes |

The current ILI9486 firmware report records 29,308 linked RAM bytes. Adding a
full 153,600-byte RGB565 buffer to a similarly sized image would reach about
182,908 bytes, leaving only 13,700 bytes below the repository's 192 KiB linked
RAM ceiling. It is therefore not the default and is not required for this
target even though it may fit in a narrowly configured image.

The baseline uses the existing maximum four-row bounded RGB565 renderer. The
KMRTM target should normally allocate only 1,920 pixel bytes for a full-width
tile. Optional readback may add bounded RGB666 scratch but total display
staging must remain at or below 16 KiB by default.

### 7.2 Firmware limits

- Keep linked RAM at or below 192 KiB and report actual use.
- Keep flash at or below 1 MiB with the existing 896 KiB warning threshold.
- Preserve at least 25% measured main-stack high-water margin.
- Keep `CONFIG_HEAP_MEM_POOL_SIZE=0` and
  `CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0`.
- Reject heap allocation entry points in the final ELF as the existing
  `ili9486` build does.
- Keep all generated state under `.build/nrf52840/kmrtm24024_spi/`.
- Keep all toolchains under `.toolchains/nrf52840/`.

---

## 8. Rendering Strategy and Planned Improvements

### 8.1 Baseline: retained GRAM without reads

The LCD's internal GRAM already acts as retained display storage. Readback is
not needed to preserve untouched pixels:

1. the initial frame is rendered through `RGB565TileRenderer`;
2. subsequent layouts are compared with `StaticLayout.changedRenderBounds`;
3. changed solid/text regions are sent through `RGB565RetainedRenderer`;
4. the controller retains all pixels outside the written address windows.

This directly reuses the current static stack and should be the first
performance path accepted on hardware.

### 8.2 What readable GRAM provides

An ILI9341 contains internal display RAM and defines `RAMRD`/`RAMRD_CONT`.
That storage is readable over SPI when the physical SDO path exists, but it is
not memory-mapped into the nRF52840 and does not provide a CPU framebuffer
pointer.

Readback can enable:

- on-device screenshot or region-dump diagnostics;
- write-then-read integrity tests and pixel checksums;
- bounded alpha blending over pixels whose source scene is not otherwise
  available to the renderer;
- antialiased glyph, icon, mask, and sprite composition through small
  read-modify-write tiles;
- recovery checks after SPI errors or display sleep/wake cycles.

Readback is not automatically faster. ILI9341 GRAM returns 18-bit RGB data as
three bytes per pixel after dummy clocks, while the normal GiftUI path writes
two RGB565 bytes per pixel. Read timing is also slower than write timing. Full-
screen read-modify-write should therefore be rejected from interactive frame
paths unless measurements prove a specific use case.

### 8.3 Readback capability gate

Enable the read capability only after all of these pass:

1. verify controller identity and module SDO continuity;
2. prove SDO electrical levels and inactive-chip-select high impedance;
3. read stable status/ID registers across 100 resets;
4. write canonical RGB565 patterns and read them back;
5. account for the dummy byte and RGB666-to-RGB565 conversion;
6. verify first/last pixel, row transitions, window bounds, and rotations;
7. test shared MISO with touch selected and deselected;
8. measure per-pixel and batched-region throughput;
9. inject SPI errors and prove bounded recovery;
10. record the accepted read clock.

The first validation may use Zephyr's existing `display_read`. The pinned
driver converts GRAM data to RGB565 but currently performs one converted pixel
read at a time. If this is too slow for composition, add a project-local
batched row/tile path that reads `3 × pixelCount` bytes into bounded scratch
and converts the tile locally. Keep the Zephyr checkout unmodified and retain
the same public capability/error semantics.

### 8.4 Advanced rendering phases

The following improvements are ordered by value and independence from
readback:

1. **Write-only bitmap/mask blits.** Extend the RGB565 backend with bounded,
   clipped monochrome or RGB565 bitmap operations. Opaque images need no
   readback.
2. **Coverage/alpha over a known scene.** Rerasterize all intersecting retained
   GiftUI operations into the current tile, then blend there. Prefer this when
   the scene description is available because it avoids SPI reads.
3. **Read-modify-write tile compositor.** For unknown/external backgrounds,
   read only the dirty tile, blend a fixed-capacity coverage mask or source,
   and write the same tile back.
4. **Antialiased fonts and icons.** Add coverage-mask rasterization and golden
   tests to both framebuffer and RGB565 backends before exposing a portable
   view API.
5. **Diagnostic capture.** Provide an explicit, non-interactive command that
   reads bounded chunks and streams a screenshot/checksum through a selected
   diagnostic transport without allocating a full frame.
6. **Vertical scrolling.** Evaluate the ILI9341 vertical-scroll commands for
   full-width scrolling surfaces. This is controller acceleration and does not
   require GRAM readback; arbitrary rectangular moves still require redraw or
   read/write copying.
7. **Optional full RGB565 framebuffer profile.** Consider only after map and
   stack reports prove sufficient margin for the final application. It must be
   a compile-time opt-in profile, never a silent allocation by this target.

New view-level features such as `Image`, opacity, or rounded/antialiased shapes
belong in portable GiftUI APIs and must have matching host/static semantics.
They must not be exposed as KMRTM-only view types.

---

## 9. Optional Touch Support

Touch is conditional on the exact module population. If present and verified
as XPT2046/ADS7846-compatible:

- reuse `GiftUIInputADS7846` for samples, calibration, filtering, orientation,
  and GiftUI input events;
- reuse the existing five-point calibration and typed-action dispatch model;
- keep a distinct Devicetree child and chip-select;
- share SCK/MOSI/MISO only after electrical arbitration passes;
- poll or signal work from `T_IRQ`, but never perform SPI inside the GPIO ISR;
- split large display transfers if measured touch latency requires it;
- preserve display operation if touch initialization fails.

Baseline display acceptance may use DK buttons and does not depend on touch.
Touch acceptance requires 100 correctly classified presses on every test
control, including edge presses, with no stuck state or display corruption.

---

## 10. Implementation Plan and Gates

### Phase 0 — Exact hardware identification

1. Complete the provenance record from section 2.
2. Confirm controller and optional touch identities.
3. Confirm VCC, logic, LED, reset, and SPI electrical behavior.
4. Confirm the 14-pin layout or replace it with the actual mapping.
5. Verify MISO tri-state behavior for every populated SPI device.

**Gate:** reviewed wiring/electrical record with no unresolved powered signal.

### Phase 1 — Separate framework and host tests

1. Add `GiftUIDisplayILI9341` to `Package.swift`.
2. Define an allocation-bounded, statically dispatched transport contract.
3. Add checked rectangle and RGB565 presentation adapters.
4. Add a fake transport that records lifecycle calls, rectangles, data, and
   failures.
5. Test bounds, clipping, byte order, orientation, solid fills, unsupported
   capabilities, invalid sizes, and fault propagation.
6. Compile the target in Embedded Swift mode through the firmware CMake flow.

**Gate:** host tests pass and the framework compiles for Embedded Swift without
Foundation, Zephyr imports, heap entry points, or unbounded pixel storage.

### Phase 2 — Hardware-free nRF firmware target

1. Add `firmware/nrf52840/applications/kmrtm24024_spi/`.
2. Add an overlay using the proposed DK mapping and pinned Zephyr
   `ilitek,ili9341`/MIPI-DBI driver.
3. Add Kconfig for RGB565, display writes, heap prohibition, reports, and the
   existing 24 KiB initial main-stack candidate.
4. Link `GiftUI`, static runtime, RGB565 backend, built-in font, portable
   thermostat, and the new display framework as distinct Swift modules.
5. Extend `scripts/nrf52840/build.sh` artifact checks for the new application,
   preferably through application-owned metadata rather than another growing
   chain of hard-coded branches.
6. Require the expected Swift entry, display framework, static runtime, RGB565
   backend, ARMv7E-M attributes, VFP calling convention, and zero heap.

**Gate:** `scripts/nrf52840/build.sh --application kmrtm24024_spi` emits the
ELF, HEX, map, Devicetree, and reports under the correct build directory with
all architecture/resource checks passing. No board is required or flashed.

### Phase 3 — Connected write-only display bring-up

1. Verify unpowered wiring and safe chip-select/reset state.
2. Flash only through the explicit application flash command.
3. Validate reset, controller readiness, blanking/backlight, and UART faults.
4. Render color bars, corner markers, checkerboards, odd rectangles, text, and
   repeated full-screen fills at 4 MHz.
5. Validate RGB/BGR, byte order, orientation, final row/column, and cold boots.
6. Raise write frequency only through the validation ladder.

**Gate:** 100 cold/warm resets and repeated patterns show no corruption,
out-of-range writes, fault loops, or manual-start dependency.

### Phase 4 — Static GiftUI integration

1. Render the thermostat initial frame with the four-row tile backend.
2. Use changed-layout bounds and retained GRAM dirty writes for updates.
3. Verify layout and pixels against the host static reference at 240 × 320 and
   320 × 240 as applicable.
4. Drive actions with DK buttons; add touch only if Phase 0 approved it.
5. Record full-frame time, dirty-update time, RAM, flash, and stack high-water.

**Gate:** static thermostat state changes produce correct bounded dirty updates
with no full framebuffer, heap use, or regression to the ILI9486 target.

### Phase 5 — Optional GRAM readback

1. Enable MIPI-DBI reads and `CONFIG_ILI9XXX_READ` in a measurement branch of
   the target configuration.
2. Run the readback capability gate from section 8.3.
3. Measure the upstream one-pixel conversion path.
4. If justified, implement and test a bounded batched tile reader outside the
   pinned Zephyr checkout.
5. Expose read capability to the new framework only after connected tests pass.

**Gate:** write/read pattern equivalence passes for all tested windows and
orientations; unsupported or failed reads report an error without affecting
the write-only renderer.

### Phase 6 — Rendering improvements

1. Add opaque bitmap/mask blits and cross-backend golden tests.
2. Add scene-rerasterized coverage blending.
3. Add read-modify-write tile blending only for backgrounds not reconstructible
   from the retained scene.
4. Evaluate antialiased text/icons, vertical scroll, and diagnostic capture.
5. Keep each feature behind measured memory/latency budgets and portable API
   conformance tests.

**Gate:** each accepted feature matches the framebuffer reference, stays within
the staging/RAM/stack limits, clips safely, and meets its recorded latency.

### Phase 7 — Endurance and documentation

1. Run touch/display arbitration if touch is enabled.
2. Run extended dirty-update, sleep/wake, and power-cycle tests.
3. Capture accepted SPI clocks, timing, current, memory, stack, and faults.
4. Add a KMRTM bring-up/validation record that distinguishes measured facts
   from untested fields.
5. Replace the README's planning link with verified build/use instructions
   only after the stable build command works.

**Gate:** all definition-of-done requirements are measured on the identified
hardware and recorded without replacing missing results with assumptions.

---

## 11. Verification Matrix

| Area | Host/hardware-free evidence | Connected-hardware evidence |
| --- | --- | --- |
| Framework isolation | SwiftPM dependency and import tests | N/A |
| Embedded compatibility | Embedded Swift module build | Swift entry runs |
| Geometry/clipping | Unit and golden tests | Corner/edge patterns |
| RGB565 byte order | Captured fake-transport bytes | Canonical colors |
| Bounded storage | Capacity tests and ELF/map checks | Stack high-water |
| Initialization | Pinned-driver review and transport lifecycle tests | 100 power/reset cycles |
| SPI errors | Injected transport failures | Disconnect/error recovery |
| Dirty rendering | Static/full-reference equivalence | Untouched pixels persist |
| Readback | RGB666 conversion and dummy-byte tests | Write/read equivalence |
| Touch | Existing ADS7846 host tests | Press/arbitration tests |
| Regression | Existing host suites and `ili9486` build | Existing hardware unchanged |

Required host suites include existing GiftUI, static runtime, RGB565 backend,
input, integration, Linux, and Raspberry Pi tests plus the new ILI9341 tests.

---

## 12. Definition of Done

Baseline KMRTM24024-SPI static-stack support is complete when:

- the exact hardware record confirms controller, power, and wiring;
- `GiftUIDisplayILI9341` exists as a separate library/target with host tests;
- `kmrtm24024_spi` exists as a separate nRF52840 firmware application;
- the stable build emits and validates all required artifacts;
- the firmware is ARMv7E-M hard-float and contains no heap allocation path;
- RGB565 initialization, full frame, dirty regions, orientation, and recovery
  pass on the exact module;
- the static thermostat renders and updates with bounded memory;
- measured RAM is at most 192 KiB and stack has at least 25% high-water margin;
- full refresh and dirty-update latency are recorded;
- build/test never flashes hardware implicitly;
- the existing ILI9486 application and host targets remain green.

Readable-GRAM enhancements are complete separately when:

- SDO and controller read behavior pass the capability gate;
- bounded RGB666 read scratch converts correctly to RGB565;
- readback failures fall back to or preserve the write-only path;
- at least one justified diagnostic or rendering feature uses the capability;
- measured latency demonstrates that the chosen region sizes are suitable;
- no feature silently allocates a full framebuffer.

Successful compilation alone is not KMRTM24024-SPI board support, and a
working write-only panel alone is not evidence that GRAM readback is safe.

---

## 13. Open Decisions

- Exact KMRTM24024-SPI revision, controller markings, and schematic.
- Whether LCD SDO and optional touch T_DO safely share MISO.
- Module VCC and LED/backlight circuit behavior.
- Exact KMRTM initialization/gamma values versus Zephyr defaults.
- First accepted orientation and whether rotation is owned by the controller
  or the RGB565 software mapping.
- Accepted write/read SPI frequencies after signal-integrity tests.
- Whether baseline touch is fitted and XPT2046/ADS7846-compatible.
- Whether Zephyr's existing `display_read` is sufficient for diagnostics.
- Whether a project-local batched GRAM reader earns its code and scratch cost.
- Which advanced primitive is first: bitmap/mask, coverage text/icons, or
  diagnostic capture.
- Whether a high-memory full RGB565 framebuffer profile has a justified use
  case after final firmware resource measurements.

---

## 14. References

- [`GiftUI_nRF52840_DK_Platform_Spec.md`](GiftUI_nRF52840_DK_Platform_Spec.md)
- [`GiftUI_Embedded_Layer_Inventory.md`](GiftUI_Embedded_Layer_Inventory.md)
- [`GiftUI_ILI9486_Bring_Up_Record.md`](GiftUI_ILI9486_Bring_Up_Record.md)
- [ILI9341 controller specification](https://cdn-shop.adafruit.com/datasheets/ILI9341.pdf)
- [Nordic nRF52840 product specification](https://docs.nordicsemi.com/r/bundle/ps_nrf52840/page/keyfeatures_html5.html)
- Pinned Zephyr sources:
  `.toolchains/nrf52840/workspace/zephyr/drivers/display/display_ili9341.c`,
  `display_ili9xxx.c`, and `drivers/mipi_dbi/mipi_dbi_spi.c`
- Pinned Zephyr bindings:
  `dts/bindings/display/ilitek,ili9341.yaml` and
  `dts/bindings/mipi-dbi/zephyr,mipi-dbi-spi.yaml`
- [Community KMRTM24024-SPI controller/electrical discussion](https://forum.arduino.cc/t/ili9341-tft-arduino-mega-adafruit-ili9341-no-output-but-with-due-m0-fine/536440/17)

The community reference is discovery evidence only. Hardware acceptance must
come from the exact board, controller data, and measured behavior.
