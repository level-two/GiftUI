# SPEC-001 T6.8 nRF52840 TFT/Input Adapter Slice

The selected connected assembly is the `nrf52840dk/nrf52840` with the
480 x 320 ILI9486 PiScreen display bridge and its ADS7846 resistive-touch
controller. This is the concrete assembly whose dimensions match the approved
480 x 320 Static preset and 480 x 4 RGB565 region contract.

The application-local Devicetree overlay fixes the display at 4 MHz and touch
at 2 MHz. It assigns the Arduino-header SPI bus, display chip select/DC/reset,
touch chip select, and active-low PENIRQ. Project-local bindings keep those
requirements explicit rather than depending on an unrelated generic panel.

The first hardware-free T6.8 slice restores the previously proven device
drivers at the current `signal-analyzer-static` firmware boundary. It provides:

- safe-state GPIO and SPI initialization for ILI9486 and ADS7846;
- the PiScreen serial-to-16-bit-parallel command framing;
- bounded RGB565 writes with an exact 480 x 4 / 3,840-byte maximum transfer;
- raw 12-bit touch sampling and active-low pen-state observation; and
- saturating, rate-limited display/input/capacity fault accounting.

The checked firmware retains each public driver entry point even before the
remaining Static host loop consumes it. `main` also validates the compiled
4-row and 3,840-byte values alongside the exact generated preset and storage
total.

## Exact build result

The project-local doctor passed with Swift 6.3.2, Zephyr 4.3.0, Zephyr SDK
0.17.4, target `armv7em-none-none-eabi`, and board
`nrf52840dk/nrf52840`. The command

```text
scripts/nrf52840/build.sh --application signal-analyzer-static --pristine
```

loaded `app.overlay`, compiled the ILI9486 and ADS7846 drivers, and passed the
ELF, hard-float, required-symbol, zero-heap, RAM, and flash gates. The emitted
ELF declares ARMv7E-M and `Tag_ABI_VFP_args: VFP registers`.

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `5217a55b094a3179dfa39e78a9d1b4ffe56933bacd49cef42b8206ccda84d8aa` |
| `zephyr.hex` | `11f6d71eac0f9f1f627858171d38733160490bbb68f53ab5c5a365fb4826b91e` |
| `zephyr.map` | `06b787854eb6574eeb458fed7c5f3937e3b69ea1cfd801f41aa6e7e864199c31` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The load-segment report records 35,192 flash bytes and 176,508 RAM bytes,
within the checked 1,048,576-byte flash and 196,608-byte RAM ceilings. Both
the Zephyr heap and C allocation arena remain zero. The display driver owns
only a bounded scratch segment; it does not introduce a 480 x 320 full-frame
buffer.

This slice is compile/link/inspection evidence only. It does not yet compose
the generated Static host loop, submit analyzer regions, normalize actions, or
measure connected stack high-water behavior. No board was flashed. The
documented physical-board provenance, shield continuity/orientation, and
power checks remain mandatory before the authorized connected campaign can
begin.

## Finite device-validation entry

A separately committed follow-up replaces the firmware's immediate
preset-check exit with a finite target-owned validation entry. After confirming
the exact generated preset, storage total, 4-row tile, and 3,840-byte segment,
it will, when deliberately flashed:

1. initialize ADS7846 and ILI9486 through their safe states;
2. transfer bounded color bars without a full framebuffer;
3. poll PENIRQ and raw samples every 10 ms for ten seconds;
4. print saturating fault counts and main-stack high-water over UART; and
5. return instead of running an unbounded loop.

The exact pristine build passed again. The follow-up artifacts are:

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `762373bed14562ffbc4c9d6421f003ca9543c49be58f3cfe9520912b7b57a0f8` |
| `zephyr.hex` | `3382b495777a3e9161c247bdb5675e7d6595da143761171a0abd7896b03ded58` |
| `zephyr.map` | `95b45a845a34b213bf97e4c2a001b213f51781cbd51d9ec2f62c7666797a29ea` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The load-segment report records 35,988 flash bytes and 176,508 RAM bytes;
hard-float, zero-heap, required-symbol, and ceiling checks pass. This is still
hardware-free evidence: the repository's `doctor.sh --probe` validates the
probe build, not a connected DK. No board was detected or flashed, and no
connected output or stack result is claimed.

## Explicit device cleanup

The next hardware-free slice adds target-owned shutdown entry points for both
controllers. ADS7846 shutdown leaves chip select inactive and PENIRQ as a
pulled-up input. ILI9486 shutdown turns the display and backlight off when
available, asserts reset, leaves data/command and chip select inactive, and
clears its initialized state. Display initialization rolls partial progress
back to that safe state.

The finite validation entry now tracks successful initialization separately
for touch and display. Every later display, input, or normal-completion path
runs reverse-order cleanup, preserves the original operational failure, and
records a cleanup failure without replacing an earlier one. This makes the
previously implicit finite-return behavior an explicit device-lifecycle
contract for the future Static host owner.

A pristine hardware-free build retains `ads7846_shutdown` and
`ili9486_shutdown` and again passes ARMv7E-M, VFP hard-float, zero-heap,
required-symbol, RAM, and flash gates:

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `f6fe865c298c3b52bdeda9c4dcb0d6361ed196d663f6dc8bfb7cb9ea71a2ec47` |
| `zephyr.hex` | `dfbcda4af14bb61866cc61bf1f3e4ca9fe99da87da975833bb76d1c0ea4fc2fe` |
| `zephyr.map` | `1b2b5f186403558049d3610400351cff42a7f1893fa7ce54dcf45e15d8666288` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The inspected load segments use 32,168 flash bytes and 175,296 RAM bytes.
No full framebuffer or heap entry point is present. No board was flashed.

## Target-local touch normalization

The ADS7846 boundary now includes an allocation-free normalizer configured by
explicit raw horizontal/vertical ranges, logical extent, axis swap, and axis
inversion. It maps accepted samples into bounded logical coordinates and emits
the same numeric down/move/up phases as GiftUI's portable pointer contract.
Leaving the calibrated range closes an active contact at its last valid point;
an input transport failure can reset local contact state without synthesizing
an action-producing up event. Source, sequence, ordinal, and physical-
presentation provenance remain owned by the future Static host admission
adapter, not by this device decoder.

`check-spec-001-nrf-touch-input.sh` compiles the exact firmware source as C99
with warnings treated as errors. Its fixture covers invalid calibration,
fail-closed reinitialization, minimum/midpoint/maximum mapping, swapped and
inverted axes, ordered down/move/up emission, out-of-range closure, and
transport reset. The check is also part of the SPEC-001 nRF profile driver.

The pristine firmware retains the initializer, update, and reset entry points
and passes ARMv7E-M, VFP hard-float, zero-heap, symbol, RAM, and flash gates.
The inspected artifacts are:

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `269d09fa033546d0e1332785edc1727fc1452ba1451cc0f0ff34eb55fcaa63cb` |
| `zephyr.hex` | `cb528626b32dd8343f88b9c1c4de384e586ff01ced990287fae906526a3243bf` |
| `zephyr.map` | `28145b1e6dd81fac8325a4a99beda5d3448ab3f63350154c1eb673adc5906a37` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The load segments use 32,456 flash bytes and 175,296 RAM bytes. Physical
calibration values and orientation are deliberately not claimed by this
hardware-free fixture and remain connected-target evidence.

## Static normalized-input admission

`StaticSignalAnalyzerNRFInputCoordinator` is the first application-host side
of the touch boundary. It reuses the common normalized input gate to assign the
configured source, committed physical-presentation revision, pointer sequence,
and ordinal. Pending events occupy a six-entry inline tuple ring, exactly
matching the generated nRF preset's maximum input-event bound; no dynamic
collection is present in the owner.

`swift test --filter StaticSignalAnalyzerNRFInputCoordinatorTests` proves that
input is ineligible before a physical presentation, down/move/up receives
exact provenance and drains in order, the first event beyond six cancels its
sequence, cleared fixed storage can be reused without reusing the refused
sequence, stale presentation input is dropped, and quiescence clears pending
input and closes admission. This fixture alone is host mechanism evidence; the
separate Embedded Swift handoff evidence follows below. Opportunity-time action
drain and connected shield behavior remain open.

## Embedded Swift contact handoff

The production firmware now whole-module compiles the exact shared `GiftUI`
input values, `GiftUIExecution` sequence allocator and admission values,
`HostNormalizedInputGate`, `StaticSignalAnalyzerNRFInputCoordinator`, and
`StaticSignalAnalyzerNRFInputABI`. CMake tracks every source as a configure
dependency before producing the single Embedded Swift composition source.

The retained C bridge forwards a normalized phase and logical point plus the
observed physical-presentation revision and explicit resynchronization proof.
It cannot supply source, sequence, or ordinal values. Swift validates the ABI
values, assigns provenance through the shared gate, and packs the exact
disposition and rejection without collapsing their vocabulary. The finite
entry constructs the owner before device initialization, installs revision
zero only after the color-bar transfer succeeds, and quiesces the owner on
every cleanup path.

`swift test --filter StaticSignalAnalyzerNRFInputABI` covers valid typed
handoff, malformed C values, exact provenance, and packed rejection values.
`check-spec-001-nrf-static-input-bridge.sh` compiles the production C bridge
with warnings as errors and proves exact forwarding plus invalid-call
rejection. The pristine firmware retains all six C/Swift bridge entry points
and passes ARMv7E-M, VFP hard-float, zero-heap, symbol, RAM, and flash gates:

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `dd10ab24725f38631dc8042a0f6215936695c907dc4a67ffbfe3c4f73e92727c` |
| `zephyr.hex` | `cc4dd1622f6c996540a9abb6af883dd54f9f5623fedbcba08878186189f888ca` |
| `zephyr.map` | `4cfdd8280b27aa23afc075e37ab01520695b585fa41e485c7e950e9326d25395` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The load segments use 34,656 flash bytes and 175,552 RAM bytes. No heap entry
point or full framebuffer is present. Physical calibration values, the real
poll-loop submission call site, opportunity-time action drain, and connected
shield behavior remain open. No board was flashed.

## Integrated Static touch pipeline

The production C boundary now composes the exact raw-sample normalizer and the
retained Swift admission bridge behind an injected immutable calibration and
observed presentation revision. It forwards only normalized phase and logical
coordinates. The first down and each down after an observed release carry the
physical-sequence completion proof; moves and ups never do.

Transport reset, malformed normalization, or a negative ABI result clears the
local contact and enters an awaiting-release state. Continued PENIRQ contact
is suppressed in that state. Only a later observed release restores permission
to submit a new down with resynchronization proof, so a read failure cannot be
silently converted into proof that the former physical sequence ended.

`check-spec-001-nrf-static-touch-pipeline.sh` compiles the exact normalizer,
C/Swift bridge, and production pipeline as C99 with warnings as errors. Its
fixture proves midpoint and edge mapping, down/move/up forwarding, presentation
revision preservation, proof placement, transport-reset suppression,
release-proven recovery, invalid calibration, and fail-closed bridge refusal.

The pristine firmware retains the pipeline initialize, update, and reset
entries and passes ARMv7E-M, VFP hard-float, zero-heap, symbol, RAM, and flash
gates:

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `2d7a9953ad9c27e47c15a5c664423330fdc1d82b019693f6313088c2319aafb5` |
| `zephyr.hex` | `a96b2659c759f27f7e0014e48dca748894ea9cc9eaaa41667f56a31a79fea0e4` |
| `zephyr.map` | `a92d1892bd82e0a0c4dbd6ad1928d2abb80d3e3f18bb5baef284bf0d04d815b8` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The load segments use 34,816 flash bytes and 175,552 RAM bytes. This remains
hardware-free mechanism evidence. The historical connected-board record
requires measured five-point calibration and explicitly forbids substituting
typical ADS7846 ranges, so the finite polling loop does not activate this
pipeline yet. Opportunity-time action drain and connected shield behavior also
remain open. No board was flashed.

## Serialized Static input opportunity

The Static nRF coordinator now owns `HostApplicationOpportunityGate`, matching
the established Dynamic host serialization boundary. The six-entry ring has no
package-level removal operation: its events can leave storage only during
`runOpportunity`, where a total handler classifies each event as consumed,
dispatched, or cancelled/rejected. The returned bounded summary records all
three counts, and quiescence rejects later opportunities while clearing input.

The coordinator and ABI fixtures cover ordered provenance-preserving drain,
empty opportunities, exact classification counts, post-drain storage state,
and unavailable rejection after quiescence. The firmware whole-module source
now includes the exact shared application-opportunity gate; it does not export
a C dequeue operation that could bypass the future interaction owner.

The pristine firmware passes ARMv7E-M, VFP hard-float, zero-heap, symbol, RAM,
and flash gates:

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `b2669171c6d13c12a5763c87ed163eac5648cb88e256a2828045fef2799429d0` |
| `zephyr.hex` | `9aca73a42117d4cc607a736af3b83a2a2d71c1a6b0c19e9fdd3884f68d852d51` |
| `zephyr.map` | `d66578d92b20cf5eef0628f2a130d7382cd3c5c12c5a6b2fa8e2145a163adf51` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The load segments use 35,296 flash bytes and 175,552 RAM bytes. This evidence
proves the serialized drain mechanism; the following host-only interaction
evidence is deliberately separate from this firmware result. Calibration,
connected shield behavior, and flashing remain open. No board was flashed.

## Static interaction and observable mutation

`StaticSignalAnalyzerNRFInteractionHandler` is the production typed consumer
for the serialized ring. It retains `PointerActionCapture<UInt16>` across
application opportunities, requires the installed physical-presentation
revision and exact source/sequence/successor-ordinal provenance, resolves
against committed `StaticInteractionState<UInt16>`, and dispatches through
`StaticSignalAnalyzerActionDispatcher` while the Static observable root is in
its `.mutating` phase. Dispatch therefore retains both action-generation and
observable-target-generation guards.

`StaticSignalAnalyzerNRFInteractionHandlerTests` proves that a down and up
drained in separate serialized opportunities select the one-second window and
dirty the root, a stale observable target generation cancels without mutation,
and queued input remains stored when the handler has not installed the matching
physical presentation. The established coordinator tests continue to prove
total drain accounting and opportunity rejection after quiescence.

This is host mechanism evidence for the production owner. The handler is not
yet part of the Embedded Swift whole-module source because its committed
interaction state and observable root must be supplied by the remaining full
Static presentation composition. Consequently, the firmware hashes and
resource totals above are not attributed to this handler. No board was flashed.
