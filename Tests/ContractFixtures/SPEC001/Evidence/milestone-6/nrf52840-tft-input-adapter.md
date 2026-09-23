# SPEC-001 T6.8 nRF52840 TFT/Input Adapter Slice

## Fixed typed model-location precursor

`StaticSignalAnalyzerNRFModelLocation.swift` now provides a firmware-lifetime
typed value location, with a copyable pointer-plus-generation handle. Its host
fixture passed all six exact action routes, one shared location, dirty-window
updates, and retirement/reactivation invalidation. The same source is included
in the Embedded Swift whole-module build. Firmware startup calls the retained
`giftui_signal_analyzer_model_location_valid` entry; the hardware-free checked
build passed VFP hard-float, zero-heap, required-symbol, RAM, and flash gates
at 184,128 RAM bytes and 35,756 flash bytes. The image still enters diagnostic
device validation after this check. Capture publication, direct model/use-case
integration, and the generated Static root remain to be linked; this entry
does not establish connected-target behavior.
The next checked slice gates handle dispatch by an explicit mutation
opportunity. Host assertions cover out-of-phase delivery, nested begin,
unmatched end, and unchanged state after rejection. Target startup exercises
the same phase boundary before diagnostic validation. The checked image still
uses 184,128 RAM and 35,756 flash bytes and passes the same build gates.
The SPEC-015 generator now emits an nRF model descriptor from its existing
hierarchy digest. `--check` passed; the host fixture matched structural
identity, declaration ordinal, and all four capacities against the generated
host preset. The firmware compiles that descriptor and validates its fields
before diagnostic startup. The checked image passes the hard-float,
zero-heap, required-symbol, RAM, and flash gates at 184,192 RAM and 35,796
flash bytes. The generated root and repository are still not linked.
The registered `scripts/contracts/run-spec-001.sh --profile
nrf52840-embedded` driver also passed after this change: 225 host tests, the
touch/input/storage/clock/scheduler/lifecycle C fixtures, and the SPEC-015
nRF cross-build. Its immutable SPEC-001 report is
`.build/contract-reports/spec-001/20260923T113743Z-91221/nrf52840-embedded/`.
The fixed model location now has a typed direct change-report registration:
one slot and generation, accepted reports coalescing into one dirty bit,
out-of-phase refusal, and stale-token refusal after retirement. The host
fixture and retained firmware startup entry exercise those outcomes. The
hardware-free target build passes hard-float, zero-heap, symbol, RAM, and
flash gates at 184,192 RAM and 36,020 flash bytes. The registration is an
endpoint precursor; it does not yet attach the portable model or run the
production application.
Firmware CMake now runs the SPEC-015 generator's `--check` mode before Swift
source assembly and tracks the generator plus workload and hierarchy inputs
for reconfiguration. The hardware-free nRF build passed with that configure
gate and unchanged 184,192 RAM / 36,020 flash use.

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
| `zephyr.elf` | `373c02769f556b4c24937752a60c185756cc68eb57fc8a64f73090f3cc28d541` |
| `zephyr.hex` | `13a426114a9677f1d782ab5999ea750cd38de73949ee4071f324dabe10a03822` |
| `zephyr.map` | `53188f8d99cdb8d2944f2f8bbdc9af96cd57653352aa77175bbcc1ccccbbeb87` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The load segments use 34,384 flash bytes and 175,552 RAM bytes. This evidence
proves the serialized drain mechanism; the following host-only interaction
evidence is deliberately separate from this firmware result. Calibration,
connected shield behavior, and flashing remain open. No board was flashed.

## Address-stable firmware input lifetime

`StaticSignalAnalyzerNRFFirmwareInputStorage` now owns the Embedded Swift input
ABI in one fixed global value. It permits one source initialization, refuses
presentation installation or admission before that initialization, and
mutates the retained coordinator directly for every later bridge call. The
firmware no longer copies an optional coordinator value out of global storage
and assigns it back after presentation, admission, or quiescence.

`StaticSignalAnalyzerNRFApplicationInputOwner` now embeds this exact storage
rather than a separate `StaticSignalAnalyzerNRFInputABI`. Its application
opportunity delegates to the storage's serialized drain and adds only the
scoped interaction/root handler. Firmware admission and the later application
join therefore cannot diverge into two coordinator states.

The shared storage is noncopyable. The
`nrf-firmware-input-storage-copy` compiler-negative fixture attempts an
explicit copy from a consuming argument and must receive Swift's noncopyable
copy diagnostic. `check-spec-001-nrf-input-storage-ownership.sh` builds the
production target-host module, checks that diagnostic, and runs as part of the
nRF SPEC-001 profile. The exact Embedded Swift build accepts the same
noncopyable type as its fixed global without changing the artifact digests or
resource totals above.

`staticNRFFirmwareInputStorageOwnsOneInPlaceLifetime` proves pre-initialization
refusal, duplicate-initialization refusal, a stable caller-owned address across
admission, retained pending state, the shared serialized drain, and unavailable
rejection after quiescence. Existing application-owner tests prove action
dispatch and capture cleanup through the same storage path.
The exact ARMv7E-M build above compiles this same storage into the firmware and
retains all six C entry points while passing VFP hard-float, zero-heap,
no-full-framebuffer, RAM, and flash gates. This establishes only the firmware
input lifetime. The generated observable root, interaction storage, rendering,
and endpoint application aggregate remains outside the firmware whole-module
source. Calibration, connected shield behavior, and flashing remain open. No
board was flashed.

## Static production assembly validation

`StaticSignalAnalyzerNRFAssembly` now performs the inert production validation
that must precede nRF device and application-owner construction. It consumes
the generated `nrf52840Static` preset and its fixed storage audit, rejects a
projection other than 480 x 320 with one 480 x 4 RGB565 region, and resolves
the exact 3,840-byte synchronous-borrow capability and endpoint contract. The
validator also checks the complete component graph, reference text resources,
six-action/one-root application domain, normalized input and wake boundary,
`1/32/1` cardinality, generated pacing policy, and residual policy. Its report
records the 35-operation sink minimum and 28-fact service-window maximum.

`StaticSignalAnalyzerNRFAssemblyTests` proves that the production validator
returns the immutable Static nRF report and that its storage audit, effective
presentation, cardinality, Drawing limit, sink limit, and fact bound equal the
generated preset contract. This is host execution of the production assembly
validator, not an Embedded Swift link or connected-target run. The validator
is not yet part of the firmware whole-module source, so the firmware hashes and
resource totals above remain unchanged. No board was flashed.

## Static application storage join

`StaticSignalAnalyzerNRFApplicationStorage` is the caller-owned, noncopyable
aggregate for the next composition boundary. It can be constructed only from
the exact `StaticSignalAnalyzerNRFAssembly` report and uses the generated root
descriptor to create the `UInt32` observable root. The same inert construction
creates fixed candidate and committed interaction stores at the generated
six-action/six-hit-region limit and one
`StaticSignalAnalyzerNRFApplicationInputOwner`. It does not bind a model,
activate input, open a device, or retain a pointer to movable storage.

`StaticSignalAnalyzerNRFAssemblyTests` proves exact-report acceptance, rejection
of a valid report from another target, successful use of the generated limit,
and rejection of a seven-action/seven-region candidate. This remains host
mechanism evidence; the aggregate is not yet linked into the firmware
whole-module source or an address-stable firmware lifetime. Firmware hashes
and resource totals therefore remain unchanged. No board was flashed.

`withAddressStableOwner` now spans the complete host-side application lifetime
over the aggregate's disjoint root, interaction, and input fields. The scoped
owner accepts the host's one concrete repository, constructs the exact Start,
Stop, and Clear use cases plus `SignalAnalyzerViewModel`, and materializes that
model in the generated root at target generation zero. The use cases retain the
repository after the caller's reference ends, while the direct change-report
route exists only while the aggregate field addresses are valid. The existing
input opportunity dispatches the committed one-second action. Scope exit
quiesces input and publishes structural absence, which detaches the model
change sink, removes the model, and releases the repository before the borrowed
field pointers expire.
`staticNRFAddressStableOwnerBindsDispatchesAndDetachesRoot` proves the retained
repository lifetime, exact-once Start/Stop/Clear delegation, action mutation,
dirty report, detached root, repository release, removed model, and empty input
storage. The firmware lifetime join remains open, so this is still host
mechanism evidence and does not change the firmware resource record.

The same address-stable aggregate now owns
`StaticSignalAnalyzerHostFactAdmissionStorage`. Root binding constructs the
capture/state admission adapter from the identical repository retained by the
model, while `installRepositoryObservation` is the separate activation step.
That step admits the repository's two current values under the generated
bootstrap bound and leaves the model unchanged. The host fixture seals and
drains sequence 1 as a snapshot and sequence 2 as a compact acquisition-state
fact, proving callback termination and deferral. Scope exit stops both
observations exactly once before fact disposal and root removal. This remains
host mechanism evidence: the aggregate and observation adapter are not yet in
the firmware whole-module source, firmware hashes and resource totals remain
unchanged, and no board was flashed.

`applyRepositoryFactsAtOpportunity` now owns the next Static mutation
boundary. It seals the admitted bootstrap batch, applies the snapshot and
acquisition-state facts through the bound model while the observable root is
in its mutation phase, and restores the idle phase afterward. The fixture
proves the callback leaves the model idle, the later opportunity applies two
facts and changes the model to running, the root becomes dirty, and a repeated
opportunity applies zero facts without replay. This is still host mechanism
evidence and does not alter the firmware hashes or resource record.

The scoped owner now exposes one combined post-presentation application
opportunity. It seals and applies the prior fact batch before opening the
admission store's bounded `.action` producer around the complete input drain.
The host fixture commits Start, Stop, and Clear hit regions, drains the
generated six-event maximum, and proves each use case delegates exactly once.
That opportunity reports zero prior facts and three dispatched actions. All
three synchronous repository callbacks are admitted while the model remains at
its pre-action acquisition state and capture revision; the following combined
opportunity applies exactly those three facts in sequence and drains zero
input, ending stopped at capture revision one. Bootstrap facts retain their
explicit pre-presentation application step because input is not yet eligible.
This proves same-thread callbacks cannot reenter Static observable mutation or
join the batch that caused them. The result remains host mechanism evidence;
no firmware source, resource record, or connected hardware was changed.

## Static interaction and observable mutation

`StaticSignalAnalyzerNRFApplicationInputOwner` is the production typed owner of
the serialized ring and interaction session. It retains
`PointerActionCapture<UInt32>` and exact source/sequence/successor-ordinal
provenance as fixed value state across application opportunities. Each
`runOpportunity` creates a scoped `StaticSignalAnalyzerNRFInteractionHandler`
that borrows the generated `StaticInteractionState<UInt32>` and observable root
only for that synchronous drain, so no unsafe pointer to movable caller-owned
storage survives an opportunity. All three use the generated root descriptor's
exact `UInt32` structural identity (`1_410_692_621`); the input boundary neither
narrows it nor creates a parallel identity. Physical-presentation replacement
is installed in admission and dispatch together and cancels any capture;
quiescence closes both halves. Dispatch occurs while the root is `.mutating`
and retains both action-generation and observable-target-generation guards.

`StaticSignalAnalyzerNRFInteractionHandlerTests` proves that a down and up
drained through separately constructed scoped handlers select the one-second
window and dirty the root, a stale observable target generation cancels without
mutation, physical-presentation replacement cancels an in-flight capture, and
owner quiescence closes admission, clears storage, cancels capture, and rejects
later opportunities. The established coordinator tests continue to prove total
drain accounting.

This is host mechanism evidence for the production owner. The owner is not
yet part of the Embedded Swift whole-module source because its committed
interaction state and observable root must be supplied by the remaining full
Static presentation composition. Consequently, the firmware hashes and
resource totals above are not attributed to this handler. No board was flashed.

## Generated profile storage reconciliation

The generated nRF Static audit is 36,368 bytes after the approved semantic,
layout, and render-capacity amendments. The firmware's retained C reservation
and Swift preset self-check still used the earlier 28,016-byte value even
though the host-native report described the amended total. This slice replaces
that stale reservation, updates the complete named application-storage check
to 155,600 bytes, and adds exact ELF symbol-size gates for the profile,
115,392-byte capture, and 3,840-byte raster-staging stores. SPEC-015 report
generation now reads all three values from `readelf` output rather than
printing constants.

A pristine hardware-free build passed ARMv7E-M, VFP hard-float, zero-heap,
forbidden-symbol, exact-size, RAM, and flash checks. The inspected symbols are
36,368, 115,392, and 3,840 bytes respectively. Linked totals are 183,872 bytes
RAM and 34,384 bytes flash, within the approved 196,608-byte RAM and 1 MiB
flash ceilings.

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `2ce8059e501e4903016339df28829c587f847c2c06b1275cf01b5a8591b27cc7` |
| `zephyr.hex` | `9d3d4e238edd790f4c9fca5a9d4ed28b389ecbd89f63ecf73876791d3d53f4f9` |
| `zephyr.map` | `fe4e06099b9f3585fdebf79c05053582a7336614126825bb03920feffd0f5fe0` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

This is cross-build and inspection evidence only. No board was flashed.

## Generated Static profile-region owner

`StaticSignalAnalyzerNRFProfileRegions` now maps one exact, nonoverlapping range
for every generated profile-storage family over a caller-owned 36,368-byte
buffer. Its field-by-field `RuntimeStorageByteCounts` equals the nRF preset
exactly, and any other supplied capacity is rejected. The representation adds
no dynamic storage or discretionary headroom to the approved audit and can map
the already retained firmware storage symbol without copying it onto the
embedded stack.
The exact map clears its caller-owned storage on successful construction so
retained publication never interprets uninitialized bytes as a prior revision.

The reset fixture fills the complete owner with a nonzero byte pattern. An
attempt reset clears the eight registry-defined attempt-local regions and
leaves exactly 8,144 retained bytes; complete reset then clears those retained
regions too. The first attempted inline aggregate representation was rejected
after its synthesized initializer required roughly 342 KB of temporary stack
in a focused host fixture. The caller-supplied map preserves the approved
storage contract without introducing that embedded-stack hazard. This remains
host mechanism evidence; the remaining firmware join must construct the map
over the retained symbol with semantic, layout, Drawing, render, and endpoint
owners. No board was flashed.

## Static runtime-profile binding join

`StaticSignalAnalyzerNRFProfileBinding.make` now requires the exact validated
nRF assembly report, generated Static root identity and limits, exact caller-
owned region map, and one concrete generated metadata/callable-table value.
It returns Runtime Static's common noncopyable binding rather than duplicating
opportunity or storage lifecycle in the target host.

The join independently derives the concrete table's greatest declared capture
record and requires exact equality with the generated workload's two callable
cases and 32-byte maximum. An otherwise structurally valid two-case table with
a 31-byte greatest record rejects before profile construction, so preset
headroom cannot conceal stale or incomplete generated source.

`StaticSignalAnalyzerNRFRuntimeStorage` now joins that binding with the
application storage under the same exact assembly report. Its noncopyable
address-stable scope lends both owners simultaneously and quiesces application
and profile state before their locations or caller-owned profile buffer expire.
The host fixture proves construction, one balanced profile opportunity, common
scope teardown, and rejection of another target's report. It continues to use
the production generated metadata and Canvas table.

The production metadata envelope now derives its single observable slot from
the generated root descriptor, specializes all six `SignalAnalyzerAction`
codes, and declares dense coverage for callable IDs one and two. Construction
requires the exact nRF assembly report and runs the independent Static Canvas
host validator over the supplied generated table. The runtime-storage fixture
now consumes this production envelope and the checked generated callable table.

## Generated Static Canvas table

`StaticSignalAnalyzerNRFCanvasTable.generated.swift` lowers the portable grid
and trace expressions to dense callable IDs one and two. The grid record is
empty. The trace record is exactly 32 bytes and contains only an address-stable
model handle, a standard channel value, and millisecond-exact visible-range
bounds. Invocation dispatches directly to the existing grid and trace drawing
helpers; no Canvas closure or dynamic callable collection is retained.

`nrf-static-canvas-manifest.yaml` records the exact two-case layout, offsets,
switch coverage, and five portable source occurrences. The dedicated contract
checker rejects source drift, non-dense coverage, an incorrect greatest record,
closure fallback, or dynamic storage. Focused host tests prove the exact layout,
grid and trace invocation, typed model borrowing, and invalid ID/capture
rejection. Runtime-storage tests now pass this generated table through the
production metadata factory. This is production target-host source compiled by
the host package; it is not yet linked into the Embedded Swift firmware image.

`StaticSignalAnalyzerNRFPresentationInputs.generated.swift` adds the next
generation boundary. It records the checked 47-node normal and 48-node
diagnostic semantic variants, their exact body/modifier/action/depth and
structural/traversal high-water values, and the five Canvas occurrences. One
synchronous stable-model borrow supplies the current visible range to the grid
plus four trace captures. The stage reserves the exact semantic candidate and
Canvas logical limits once in an active Static profile opportunity; a repeated
reservation rejects without staging more work. Host tests cover both variants,
all five dense occurrence identities, capture sizes, scoped model access, and
attempt teardown. This does not yet claim semantic primitive, layout, render,
endpoint, firmware, or connected-hardware evidence.

Runtime Static now lends a generated region through the common profile binding
only while that region's registered lifetime is active. The nRF fixture proves
attempt-local semantic storage rejects before begin and after finish, is reset
at finish, retained semantic storage remains available before quiescence, and
all access rejects after teardown. This is the bounded workspace seam for the
next semantic/layout/render implementation; it does not itself claim those
stages are complete.

The generated semantic-region store now gives the exact 3,024-byte candidate
and published regions a checked fixed prefix: a 32-byte header, five 8-byte
Canvas occurrence descriptors, six dense `UInt16` action codes, and a trailing
FNV-1a integrity word. The integrity word covers the entire region, excluding
its own four bytes. Candidate staging reserves the generated normal or
diagnostic semantic high-water values
and writes directly into attempt-local storage. Publication validates that
candidate, writes the retained region with a nonzero semantic revision, and
cannot be repeated through the same generated input scope. The remaining 2,936
bytes are zeroed and reserved for the generated primitive/modifier/text records
that complete the Static layout view. Host tests prove normal and diagnostic
publication, exact root/count/Canvas/action data, corruption rejection,
strictly increasing retained semantic revisions, candidate clearing at attempt
finish, published retention between attempts, and published invalidation at
quiescence. This slice does not yet claim the primitive table or layout/render
pipeline is complete.

Publication now borrows the attempt-local candidate and retained published
regions together through the common Static profile owner. Once candidate
integrity and revision ordering pass, it copies the exact 3,024 candidate
bytes into the published region in place, then changes only state, revision,
and checksum. A test corrupts an otherwise unused tail byte and proves
publication rejects it; after repair, the published payload matches the
candidate byte-for-byte except for state, revision, and checksum. A stale
revision attempt leaves the prior retained bytes unchanged. This avoids
regenerating semantic data from a second model read and
avoids a full-region stack temporary; the remaining topology writer must keep
all future candidate records within the same integrity boundary.

The Dynamic semantic oracle now asserts 96 scopes/117 text scalars for normal
and 98 scopes/129 text scalars for diagnostic. The generated packed-record
codec fixes the remaining region layout at 98 24-byte scope slots, 139
four-byte Unicode scalar slots, six two-byte action-to-scope slots, and 16
reserved bytes. Focused host tests prove exact region fit, last-slot
round-trips, and rejection of out-of-range relations, invalid scalars, and
short buffers without mutation. This is the legacy version-1 scalar table;
the generated hierarchy now fills and validates a separate version-2 UTF-8
table, but production publication remains prefix-only and is not yet a
semantic layout view.
The packed table now also has a non-mutating topology validator. A three-scope
fixture proves linked root/children plus all six action targets; corruption
fixtures reject duplicate identity, parent cycles, orphan or duplicate links,
wrong parents, surrogate scalar values, and targets outside the used scope
count. The production candidate does not yet call this validator because its
generated version-2 table is not yet staged through the region owner.
The host Dynamic semantic oracle now projects each real portable render tree
into that codec: the normal variant fills 96 scopes and 117 text scalars, the
diagnostic variant 98 scopes and 129 text scalars. Both round-trip every scope,
map all six actual action identities, and pass the linked-tree validator.
This is capacity/topology evidence, not generated firmware semantics: the
fixture's version-1 scalar form alone did not encode the remaining
per-kind modifier/layout/render payloads.
Its source-path-derived IDs are unique in each variant; exact assertions show
that the six controls and five Canvas occurrences retain the same IDs when
the diagnostic branch adds two scopes. Modifier IDs use the owning source
path and local modifier index, not a variant-sensitive global ordinal. These
IDs are still host-oracle derivation evidence, not a generated firmware table.
The exact three-word modifier payload codec now round-trips every actual
normal and diagnostic layout modifier together with its render scope. Both
hierarchies use only passthrough style, padding, fixed frame, and one bounded
flexible-frame shape; negative tests reject padding-insets, a flexible frame
requiring four scalar words, and layout/render mismatches. Disabled-action
flags are now generated and host-checked; the production table reader is
still open, so this host evidence does not claim a published semantic result.
The primitive codec now round-trips every actual stack, spacer, proxy, text,
and Canvas scope in both portable hierarchies. Text scopes retain exact scalar
pool ranges and all five Canvas scopes retain their generated occurrence IDs;
negative tests reject missing or out-of-range associations and mismatched
render scopes. The modifier codec now also carries the disabled-action bit,
obtained from the exact Dynamic modifier record rather than inferred from
final action state. The host oracle follows each packed action's ancestor
chain and proves its effective enabled state matches all six Dynamic actions
in both variants. The generated version-2 table writer is now host-checked,
but its production reader remains open, so these codecs do not yet make the
published prefix a usable semantic result.
The table codec now uses the 16 reserved bytes for a versioned completion
footer. It writes the footer only after whole-table validation; a checked
summary rejects an unsealed prefix, corrupt footer, or malformed linked scope.
The real normal and diagnostic oracle projections both seal and reread their
exact scope/scalar counts. The enclosing region checksum and publication
lifetime are still separate and must be integrated with the generated writer.
Whole-table validation now rejects malformed primitive/modifier payloads and
text-pool gaps or excess in addition to broken links. The positive real-tree
projections still seal under those stricter checks.
The complete-table acceptance path now also rejects repeated action-scope
ordinals; the production six-action mapping must identify six distinct scopes.
It also requires one and only one record for each of the five generated Canvas
occurrence IDs. The real-tree host projections satisfy this check; duplicate
Canvas occurrence corruption is rejected.
The real-tree oracle now pins complete source topology fingerprints for normal
and diagnostic variants, covering every stable scope ID, tree link, and kind.
This catches structural source drift before a generated Static writer is
accepted; it is not a publication integrity checksum or an embedded run.
The generated-result acceptance path rejects the synthetic complete-table
fixture even though its checksums, counts, and generic topology are valid.
The original bounded-text encoder converts UTF-8 into the legacy scalar
region and remains tested for overflow. A new byte-pool encoder uses the same
556 bytes without changing the 3,024-byte region: it preserves exact Unicode
bytes, preflights overflow, and has strict allocation-free UTF-8 validation.
The generated topology writer now emits all 96 normal or 98 diagnostic
root-first scope shapes from ROM into the borrowed fixed region. Host oracle
tests compare every emitted stable ID, relation, and kind with the real
portable hierarchy. Subsequent generated stages now fill every primitive,
modifier, action, Canvas, and UTF-8 text payload in that same region.
The topology writer now also installs the exact six action ordinals and five
Canvas occurrence payloads. The oracle checks each association in both real
variants; a missing shape or repeated binding is rejected before publication.
The writer also fills thirteen invariant nonzero stack/spacer payloads.
Every non-text primitive payload now matches the real-tree oracle in both
variants; text and modifier payloads have separate generated stages.
The generated input mapping now returns all 20 normal and 21 diagnostic text
values from the live model, with exact host-oracle comparison. A maximum
96-byte admitted diagnostic proves the current four-byte scalar pool cannot
represent every required message: replacing the measured 12-scalar error in
the 129-scalar diagnostic tree needs 214 slots, but the pool holds 139. Text
therefore cannot use the legacy scalar schema. The version-2 byte schema
packs all 21 generated text values with that maximal diagnostic into 214
bytes, validates each range, and seals the generated table in host tests.
The generated table now stages in the attempt-local production region with
the refreshed whole-region checksum, variant count, topology fingerprint,
distinct action targets, and exact Canvas occurrences. Host tests stage the
117-byte normal and 214-byte maximal-diagnostic candidates across separate
opportunities. The prefix-only publish path rejects this staging input;
the matching version-2 path now publishes the exact complete table after
validation. A stale revision and a checksum-corrupt candidate each leave the
previous published result unchanged. The layout/render reader and full
presentation transaction remain open.
A borrowed version-2 render view now decodes every stable scope identity,
render scope, and child relationship from the checked table without allocation.
The normal and diagnostic host oracle compares all of those queries with the
portable Dynamic render projection. The region owner now lends this reader
synchronously from validated candidate or published storage. Host tests
reject candidate access after attempt finish and published access after
quiescence. This is not an embedded run.
A version-2 layout view now unwraps render modifier chains, returns the
portable primitive/child/modifier ordering, and decodes UTF-8 text scalars
without a second text buffer. The host oracle checks all of these queries in
normal and diagnostic variants, plus the 96-byte diagnostic boundary. Scoped
production lending now rejects access after candidate attempt finish or
published quiescence. A paired scoped borrow provides both readers over the
same validated bytes, with host checks at candidate, published, and invalid
lifetimes. The full layout/render transaction remains open.
The common semantic-layout validator accepts the normal generated nRF view
under the exact preset. A maximal 96-byte ASCII diagnostic is preserved in
the semantic table but needs 214 scalar/glyph slots, so validation returns
`capacityExhausted` at the former approved 139-slot limit. The maintainer
approved a 224-slot replacement on 2026-09-21; this transcript is the
pre-amendment regression, not successful amended layout or connected-target
evidence.
The amended hardware-free host test now counts 117 scalars in the normal tree
and 214 in the maximal diagnostic tree, then passes both through the common
semantic-layout validator using the generated 224-slot nRF preset. It does
not yet prove resolved layout publication or connected display behavior.
The follow-up fixture also stages exact 96-byte wide-printable `W` and
multiline LF diagnostics through separate generated Static candidate and
publication opportunities. Both retain the 214-byte semantic payload and pass
the common validator with the amended 224-scalar/128-line preset; previous
published state remains intact until each candidate is committed. The Dynamic
Pi full-pipeline fixture measured 27 and 117 resolved lines respectively, but
the Static test remains validation-only and does not claim resolved layout.
Independently, the generated writer now fills fifteen invariant padding/frame
modifier records. Both real-tree variants match every packed flag, edge,
alignment, and dimension. It also fills twenty-five fixed passthrough styles,
with exact color/scope oracle comparison. The final ten passthrough records
now derive status/channel colors and disabled-control flags from the borrowed
model. Both real-tree variants match every modifier record, and running plus
selected-window changes update the generated payloads. The byte-pool schema
removes the measured scalar-capacity obstacle, but production publication and
layout/render reading are still open.
The enclosing semantic-region owner now has a separate complete-candidate
staging and publication path. A host fixture populates a synthetic 96-scope
table directly in the borrowed candidate region, seals it, refreshes the
whole-region checksum, rejects corruption before retained publication, then
publishes exact bytes with revision and lifetime checks. This proves the
storage transaction only; the synthetic chain is not the portable analyzer
hierarchy and does not satisfy the production generated-staging obligation.

The shared Static observable-model handle now accepts a typed-throwing scoped
borrow. This lets the generated trace case invoke the existing
`throws(DrawingError)` helper against the address-stable model without copying
or retaining its capture state; a focused runtime test proves the exact typed
failure exits the borrow unchanged.

The host fixture uses the generated two-case table to exercise this join. It
proves the retained audit equals the generated preset,
opportunity begin activates attempt storage, opportunity finish clears exactly
28,224 attempt bytes, and quiescence clears the remaining 8,144 retained bytes
and tears the binding down. Another target's valid assembly report rejects
before construction. The generated semantic staging, render presentation, and
firmware linkage remain open. No board was flashed.

The generated Static semantic candidate now completes common layout validation,
measurement, placement, and in-place publication over the exact 3,136-byte
layout and 4,704-byte render regions. The host fixture covers the normal tree
and 96-byte ASCII, wide-printable, and multiline diagnostic trees. The profile
borrow rejects outside an active opportunity and clears all three attempt-local
regions at finish. This is hardware-free layout evidence; render lowering,
physical display, firmware linkage, and connected-target evidence remain open.

The Static Drawing join now has an allocation-free live-path store over the
exact 3,280-byte attempt-local path region. Host tests prove scoped move/line
construction, two subpaths, signed coordinates, the first-excess 203rd-point
boundary, and complete reset. The 13,536-byte plan, five-Canvas derivation,
render production, and firmware linkage remain open.

The Static Drawing-plan codec now fixes checked regions for five Canvas slots,
five stroke headers, 832 translated points, and sixteen subpaths inside the
existing 13,536-byte profile family. Host tests round-trip the final slot of
each family, including a signed extreme point, and reject duplicate zero-point
writes, wrong region length, invalid stroke enums, and reserved-byte
corruption. The following owner fixture adds publication evidence; Canvas
derivation remains open.

The fixed Static Drawing-plan owner now snapshots five focused strokes into
the audited region and seals one directly readable `DrawingPlanView`. Host
tests compare translated points, headers, and subpaths, reject an incomplete
five-Canvas plan, reject a corrupt subpath before publication, and prove reset.
The common generated Canvas invocation and firmware render path remain open.

The Static Drawing workspace now executes five scoped `GraphicsContext`
invocations over the same path and plan regions. Host tests confirm exact
stroke/point publication and path-region cleanup after every context. An
invalid `addLine` before `move` fails with the typed Drawing error and leaves
no sealed plan. The generated Canvas source is not yet connected.

The generated Static Canvas source now maps all five packed semantic Canvas
identities to the callable table inside one active five-region profile borrow.
The common `CanvasPlanProducer` derives all five strokes over the resolved
layout for the normal tree and valid 96-byte `A`, `W`, LF, and four mixed
`W`/LF diagnostics.
`swift test --filter staticNRF` passes 74 host tests, and the SPEC-013 macOS
Static profile check links the production target. The common render preflight
accepts all eight normal and diagnostic cases under the approved 150-operation
nRF ceiling. The 96-byte `A` and `W` cases produce 37 and 38 operations with
214 positioned glyphs each; four mixed shapes each produce 39 operations with
123, 128, 133, and 143 glyphs. The approved SPEC-001/SPEC-008/SPEC-015
amendment derives 145 ordinary and 150 combined slots from the bounded
hierarchy. No connected board run or flash is claimed.

The same eight host cases now stream through the common Canvas render producer
and a counting Drawing operation sink at approved production capacity. All
publish their expected headers and five strokes with matching operation and
glyph counts. This verifies operation production, not the production raster
endpoint or connected firmware loop.

The Static nRF raster endpoint factory now constructs the common one-shot
operation-major RGB565 session from the exact validated host assembly and
caller-owned 3,840-byte raster region plus 240-byte coverage bitmap. The
assembly's raster work limits admit the approved worst-case 150 operations
across 80 tile rows: 12,000 tile visits and 23,040,000 theoretical pixel-run
submissions. A host fixture checks exact capacity admission, successful
endpoint construction, and rejection of a short coverage region. The full
application producer is not yet offered through this endpoint, and the
connected firmware loop remains open.
An additional host offer sends one touched RGB565 pixel through the real
operation-major session and verifies one 2-byte synchronous payload followed
by frame completion.
The generated hierarchy fixture now offers all eight normal and diagnostic
Canvas streams through that production endpoint. Each offer is accepted and
submits nonempty synchronous RGB565 payloads. It uses the validated 480 x 320
physical surface for the render header; layout's content root is 480 x 224.
The fixture now calls the production Static nRF render-offer helper, which
retains exact surface selection and producer-failure mapping for the live
owner. This remains hardware-free endpoint evidence, not connected display
evidence.
The same production helper now performs render preflight using the validated
physical surface and generated render/sink limits. The eight-case fixture
calls it before every offer and checks the returned headers and operation
counts; the live transaction and firmware link remain open.

The Static nRF display target now borrows the same 3,840-byte region as the
raster tile and packs touched runs toward its front before synchronous
submission. Host tests verify two separated source pixels survive successive
in-place submissions, reject invalid reservations and transport refusal, and
run all eight generated hierarchies through this one-slot target. The focused
generated hierarchy test passes with all eight raster offers enabled; its
previous condition exercised only the first offer, so that earlier eight-offer
claim lacked endpoint evidence.
The production endpoint factory now constructs the tile store and display
writer from one caller-supplied raster region, and the same eight-case fixture
uses this factory entry.
The transport-failure fixture now proves both first-payload and later-payload
failure handling. A failed synchronous driver call may already have sent a
prefix, so both preserve accepted responsibility, record `displayFailure`,
drain to an idle session, and leave target health unavailable with one failure
count. The unavailable target refuses another frame pending reconstruction.
The platform transport value now matches the six-argument ILI9486 C write
entry with a noncapturing C function pointer. A host test verifies the final
pixel in the 480 x 320 extent, one-row geometry, exact byte count, malformed
run refusal, and nonzero C status mapping. This is C ABI shape evidence on
macOS; the full Static Swift host is not yet linked in firmware.

The firmware now reserves a separately named 240-byte touched-pixel bitmap
beside its existing 3,840-byte raster slot. The entry self-check counts
155,840 named application-storage bytes, and the build gate checks the new
symbol's exact linked size. A hardware-free `signal-analyzer-static` build
passed ARMv7E-M, VFP hard-float, zero-heap, forbidden-symbol, exact-size,
RAM, and flash gates. The inspected totals are 184,128 RAM bytes and 34,400
flash bytes. The built Swift entry still contains the preset/input diagnostic
source set; this build does not establish linked application-host execution.
The full SPEC-015 `nrf52840-embedded` runner was attempted but stopped in its
shared host-test phase at the Dynamic Pi Drawing pipeline's existing
`invariantViolation`, before that runner's cross-build/report phase. The
direct nRF build and its inspection remain the evidence for this storage
change.

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `5335f20e5df7f4936e7fce5e4e97a6276c3c977119a4bcb49ea55c321ba91b02` |
| `zephyr.hex` | `1dacee1dd137eddcefdc8e2a4cc85e1052b92274912aa48b86d3a03c980cff7e` |
| `zephyr.map` | `88bcefea8ed680f4edf0747f9198c6e626b0720a44eb9d43fa015633d6434cbe` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The generated Static action reader now resolves six occurrence identities,
action codes, paint order, bounds, clips, and inherited disable modifiers
directly from the borrowed semantic candidate and published layout. Eight
hierarchy fixtures check the exact mapping and initial Start/Stop enabled
state. Candidate construction and committed interaction publication remain
open in the application owner. The focused production candidate builder now
stages all six records in `StaticInteractionState`, assigns six generations,
commits them after a simulated accepted offer, then proves that an unchanged
rebuild preserves those generations before discard. The address-stable
application owner now holds the generation allocator and delegates candidate
build and offer resolution to these production helpers. A host fixture proves
that an unbound root is refused, a retryably refused offer leaves no committed
actions, and a later accepted offer commits all six records. The application
owner now installs the physical input revision in the same offer-resolution
call only after interaction commit. The eight-case host fixture verifies that
input remains ineligible after refusal and becomes eligible after acceptance.
An accepted result presented before candidate construction is discarded by
the Static owner; the fixture verifies it leaves input ineligible.
The same owner path now accepts a replacement presentation, rejects an old
revision's input, and admits a resynchronized down event for the replacement.
The connected owner must still use this at the physical offer boundary.

The Static nRF runtime aggregate now owns `HostWakePacingController` alongside
its application and profile owners. A host fixture injects a frame origin of
zero and checks the generated 250,000-microsecond boundary, accepted fact wake,
and quiescence after the address-stable scope. This establishes policy wiring,
not a connected monotonic clock or firmware scheduler.
The production application-stage service now uses that exact controller to
enforce the frame boundary, run one application opportunity, and finish pacing
even when the unbound-root fixture returns `factAdmissionUnavailable`. The
fixture verifies a second wake can be serviced at the next boundary. The
presentation transaction is not yet inside this service.

The linked nRF clock seam converts `k_uptime_get()` to checked 64-bit
microseconds. Its C99 fake-kernel fixture passes null-output, 250 ms,
negative-uptime, and multiplication-overflow cases. The finite firmware entry
now uses this seam for display-transfer timing; the direct hardware-free
build verifies the retained clock symbol and existing ABI, zero-heap,
no-full-framebuffer, exact-storage, RAM, and flash gates. The inspected totals
are 184,128 RAM bytes and 34,496 flash bytes. This is still the finite
diagnostic firmware, not the full application loop.

| Artifact after clock seam | SHA-256 |
| --- | --- |
| `zephyr.elf` | `1265dfada38daa1ab2a0bfc7d8143390256289d48090f45630122df3b9777a9e` |
| `zephyr.hex` | `bb06a5be01ddd599904502801bf1044124acfadd635fe427a96b02f547dd41bf` |
| `zephyr.map` | `0c90cbb5f015de845ded45e40eb3c63204ab0156b2e46cc7ca7e8637ffc79ec1` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The generated eight-hierarchy host fixture now invokes the production Static
nRF layout pass with the exact proposal, reference metrics, and generated
limits. It still verifies the published fixed-region layout records before
Canvas derivation. This is host-only layout integration until the full owner
and firmware are linked.
The same fixture now invokes a production Static Canvas pass that binds the
generated Drawing limits and deriving context to the five fixed-region
invocations, with a success check for complete callable release. All eight
hierarchies still derive five strokes before render preflight.
The physical endpoint fixture now invokes a production handoff that builds
six interaction records after preflight, streams the accepted raster offer,
then commits the presentation and enables input in the same scoped owner.
Each of the eight cases verifies the committed actions and a queued input
event after accepted display handoff. Firmware ownership is still pending.
The same eight-case fixture first supplies a deliberately narrower physical
surface header. The handoff returns `contractViolation` before any display
payload, discards staged actions, and leaves input ineligible. A subsequent
offer with the preflighted header succeeds through that same owner and endpoint.

A production preparation entry now borrows the semantic, layout, render,
path, and Drawing-plan regions for one complete synchronous candidate. It
performs fixed-region layout, Canvas derivation, preflight, and lends the
checked views to the physical handoff callback before the borrow ends. A
focused host fixture rejects unstaged semantic input and accepts a staged
normal hierarchy through display and interaction commit. Semantic publication
now uses the generated checked stage-and-publish entry before preparation,
and the focused fixture verifies its retained revision before physical
handoff. Firmware ownership remains separate work.

The focused preparation fixture now derives generated inputs from the
application owner's bound model. A scoped noncopyable committer lends only
the disjoint interaction, action-generation, and input fields while that
model is borrowed. The accepted physical offer commits six actions and makes
input eligible before the callback ends.

The production presentation transaction now composes generated semantic
publication, five-region preparation, and physical handoff while that model
borrow remains active. The focused host fixture verifies the unbound-root
outcome before binding and an accepted physical offer after binding; the
firmware pacing and recovery join remains open.

The paced full-cycle entry now holds the pacing opportunity and Static profile
attempt through fact application and the physical offer. The initial cycle
has an empty input drain until its first accepted frame installs input
eligibility. The focused host fixture observes two bootstrap facts, six
committed actions, a nonempty display payload, and idle profile/pacing state
after the accepted offer. Firmware identity allocation and recovery remain
open; this is host fixture evidence.

The same host fixture now reserves two consecutive identity bundles from the
Static nRF value owner. Semantic revision zero is excluded as the packed
table's unpublished sentinel. Between opportunities the one-slot endpoint
replaces its value envelope validator while idle, rejects the prior
provenance before raster work, and accepts the second physical offer using
the same tile, coverage, transport, profile, and application owners. Firmware
endpoint lifetime and recovery still need implementation.
The production runtime aggregate now retains that identity cursor alongside
its application, profile, and pacing owners. A host fixture reserves inside
the address-stable owner scope and confirms the next cycle and semantic
revision remain monotonic after the scope quiesces.
The presentation composition now joins that aggregate with the one-slot
endpoint and health controller under one scoped borrow. It rejects overlapping
or misaligned profile, raster, and coverage regions before entering the body;
a hardware-free host fixture verifies the successful join and both rejection
paths. This
remains host-side construction evidence until the firmware links and invokes
the composition.

The Static display target now treats any failed synchronous transport call as
a potentially partial transfer. It reports failure after acceptance, records
one `requiredFacilityUnavailable` health fact, drains the reservation, and
refuses another frame from the same target. Host fixtures cover failure on
the first and later payloads. Firmware health consumption and reconstruction
remain open.

The paced host fixture now runs two accepted frames and then forces a failed
synchronous write on a third frame. That frame retains accepted disposition
and drains, while target health reports one unavailable failure. The shared
endpoint-health controller returns the required backend failure fact and
effects, makes input ineligible, and requires fresh construction before the
paced opportunity ends. Firmware residual-policy routing and reconstruction
remain open.
The same fixture then requests another wake and proves the paced entry refuses
that cycle with `terminalUnavailability` before consuming the wake, beginning
profile storage, or submitting another display payload.
The fixture also sends that completed backend-health transition through the
production Static nRF residual adapter and shared host router. The fixed
approved table selects `quiesceAffectedScope` after the required effects;
the invariant and fatal hooks are not invoked. Firmware ownership of those
hooks and reconstruction remains open.

The four firmware storage regions now have an explicit address-stable C
handoff for the production owner. Each region is 8-byte aligned, and a
hardware-free fixture checks the exact 36,368/115,392/3,840/240-byte sizes,
pairwise disjointness, stable access, and the 155,840-byte total. The ELF gate
requires the handoff symbol. These are storage-boundary checks; the current
firmware entry still runs the finite device validation and does not consume
the regions through the complete Static host.
The checked hardware-free build passes ARMv7E-M hard-float, zero-heap,
required-symbol, RAM, and flash gates at 184,128 RAM bytes and 34,576 flash
bytes. No board was flashed.
The target now compiles the same four-region validator used by scoped host
composition. Startup rejects any wrong 36,368/115,392/3,840/240-byte extent,
misaligned region, overlap, or address overflow before device initialization.
The host fixture checks a valid map, a short profile region, and capture
overlap. The checked image retains the Swift map entry and passes ABI,
zero-heap, symbol, RAM, and flash gates at 184,128 RAM and 35,660 flash bytes.
This does not establish the generated zero-heap ViewModel location or a
production firmware host loop; those remain open.
The registered `scripts/contracts/run-spec-001.sh --profile nrf52840-embedded`
run completed with 224 host tests and the target HAL fixtures passing. It
published its nRF cross-build report under
`.build/contract-reports/spec-001/20260923T104958Z-85857/nrf52840-embedded/`.
This is cross-build and host-fixture evidence; physical TFT/input execution
remains uncollected.

The finite validation loop now uses an absolute monotonic deadline waiter in
at most 1 ms slices instead of one 10 ms busy wait. Its optional watchdog
callback runs before every wait slice; a build-time guard requires a real
callback if watchdog support is enabled. The C99 fixture checks due-now,
exact deadline, maximum slice, watchdog/clock errors, and clock regression.
The checked hardware-free build retains the waiter and passes ABI,
zero-heap, symbol, RAM, and flash gates at 184,128 RAM bytes and 34,812 flash
bytes. The production Static pacing loop and active watchdog remain open.

A retained C lifecycle entry now accepts device and application callbacks. A
hardware-free fixture verifies side-effect-free validation before device
setup, partial initialization cleanup, teardown after attempted activation,
touch/clock/application/deadline failures, two paced service opportunities,
and reverse-order cleanup with original-error precedence. The entry is not
yet called by firmware `main`; the production Swift application callback set
and physical calibration remain open. The checked hardware-free image retains
the lifecycle symbol and passes the ABI, zero-heap, required-symbol, RAM, and
flash gates at 184,128 RAM bytes and 35,100 flash bytes. No board was flashed.
The application callback table now carries one required opaque owner context
through validation, activation, service, and teardown. The hardware-free
fixture rejects a missing context and checks that every callback receives the
same address, removing the need for a global Swift owner pointer at the
future firmware join.
The checked image remains within the ABI, zero-heap, symbol, RAM, and flash
gates at 184,128 RAM bytes and 35,132 flash bytes.

A target-owned Swift capture record now has a measured 24-byte host stride and
round-trips the portable channel, level, and `Duration` values. A noncopyable
borrower splits the existing 115,392-byte region into live and snapshot slots
of 2,404 records each, with checked boundaries and alignment. The portable
`SignalTransition` has a measured 32-byte stride on macOS; the compact record
is therefore necessary to use the reserved firmware bytes without two Swift
arrays. These are host tests of a target representation, not evidence that the
full acquisition repository is linked into the firmware.
The scoped Static presentation composition now borrows that capture region
with the profile, raster, and coverage regions. Its host fixture writes and
reads a compact live transition through the joined owner and rejects overlap
between capture and profile before entering the application body.

The target capture history now inserts and trims within the compact live slot,
keeps the lower-bound channel baselines, clears with epoch rebasing, and rejects
revision exhaustion. A hardware-free differential run compares each mutation
publication, revision, duration, lower bound, baseline, and retained record
against the portable store over 2,450 transitions plus out-of-history input
and clear. A separate host fixture proves the second slot's copied records
and metadata survive live mutation and clear. These establish host policy
equivalence and bounded storage behavior only; application snapshot delivery
and production firmware linkage are still open.
The scoped presentation composition now lends that live history alongside its
record region and the other target owners. Its host fixture admits and reads
one transition within the shared lifetime; this is still host-native evidence.

The shared compact record and region borrower now compile in the Embedded
Swift firmware. `main` calls a Swift layout entry before device setup and
rejects any target size/stride other than 24 bytes or a two-slot total other
than 115,392 bytes. The checked build retains that entry and passes ARMv7E-M
VFP hard-float, zero-heap, required-symbol, RAM, and flash gates. Its exact
artifacts are under `.build/nrf52840/signal-analyzer-static/`: `zephyr/zephyr.elf`,
`zephyr/zephyr.hex`, `zephyr/zephyr.map`, `zephyr/zephyr.dts`, and `reports/`.
The inspected image uses 184,128 RAM bytes and 35,164 flash bytes. It still
runs diagnostic device validation rather than the production Static host.
The next checked image also passes the actual C-retained capture pointer into
the shared Swift region borrower at startup. The entry refuses null,
incorrect extent, and misalignment before device initialization. Its symbol
is required by the ELF gate; the image uses 184,128 RAM and 35,228 flash
bytes. No board was flashed.
