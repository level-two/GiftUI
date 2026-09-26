# SPEC-001 T7.5 host loop rehearsal seam

Evidence kind: `host-native-fixture`. These runs were on macOS on 2026-09-26;
they do not establish connected Pi or nRF execution, application behavior
parity, or a reviewed pixel reference.

## Source and substituted boundaries

The Pi runner enters the production `DynamicSignalAnalyzerPiAssembly`,
`DynamicSignalAnalyzerPiLifecycleOwner`, `MVPHostActivationController`,
`PiScreenDisplayTarget`, and endpoint path used by the Linux process loop.
Its executable mode is in the same `SignalAnalyzerRaspberryPiARMv6` product.
Only the monotonic clock, physical input (no contacts in this startup case),
and framebuffer sink are deterministic. The recording sink accepts each
borrowed RGB565 payload and counts its regions and bytes. The owner performs
the seven production activation steps, including observation, initial
presentation, and Start dispatch. A forwarding recorder observes the seven
calls in order and the shared controller's eight teardown calls in reverse
ownership order while forwarding every call to the production owner. The
runner checks the active owner and eligible input before teardown, then
quiescent source, input, and assembly-report state afterward.

The nRF runner compiles the firmware's exact `main.c`, `production_host.c`,
`static_host_lifecycle.c`, scheduler, touch pipeline, input bridge, touch
normalizer, and fixed `storage.c` with the same amalgamated production Swift
source as the target build. Its `main.c` validation runs before device
initialization. Native adapters replace Zephyr clock/wait, ADS7846 samples,
and the ILI9486 transport. The clock advances deterministic deadlines; input
ends the bounded run after one service. The display adapter accepts synchronous
one-row RGB565 writes from the production 480 x 4 tile path. The runner checks
that application teardown retired the model before display shutdown and that
display shutdown precedes touch shutdown. It uses the exact 39,696-byte
profile, 115,392-byte capture, 3,840-byte tile, and 240-byte coverage regions;
no target framebuffer is added.

The unchanged production sources were inventoried at revision
`7f65ce0d38b4879103c755ff95c12a3b9b5b304c`:

| Production source | SHA-256 |
|---|---|
| `DynamicSignalAnalyzerPiLifecycleOwner.swift` | `c0eae701e8f747d325fcbfb7e0026d95ff577b758f280a239a39c3ceb0cf5c5f` |
| `LinuxSignalAnalyzerPiProcessLoop.swift` | `b52a20af5dda856ace051ecdbd24beb3779d9e862b53fd0e0a9057fb9ba44140` |
| nRF `main.c` | `0790525e5352a4be9ad7e29ab73698d36b66a1fed148781e32d9969889a65c73` |
| nRF `production_host.c` | `6853866169763d8dce88cc454e13de9ba2ca901249ece37544743c36792b99e6` |
| nRF `StaticPreset.swift` | `4d434a1a42b385c7d9187c7b0c0af0682b37d8f684bb666a884fce3b0323222d` |
| nRF `StaticInputABI.swift` | `27520259e747b9804d4313beec94ebbe376aa5c1066978ddbaa80231edc98fd8` |
| nRF generated amalgamation after the checked firmware build | `1f30b5dcc883d98e9a3c6eb22f10168b5e106e77226a31e405fc38d0aa8bf368` |

## Commands and results

From the repository root:

```sh
scripts/contracts/check-spec-001-pi-host-native-rehearsal.sh
scripts/contracts/check-spec-001-nrf-host-native-rehearsal.sh
```

Both passed. Pi reported 268 accepted payloads, 2,640 regions, and 226,960
RGB565 bytes across its first complete physical frame. nRF reported 2,460
synchronous tile writes and 403,122 RGB565 bytes across its first complete
physical frame. The nRF run ended with the fixture's deliberate input-stop
sentinel after its first service, and checked the expected reverse teardown.
The built Pi and nRF native binary SHA-256 values were respectively
`b344295fe4af4a864b2797365b1fdec82f731e2414c82603b31449e21c843731`
and `e7bd1fbeef9e5b4fdbc3bdd5dd7ad1065ca0f132b50a80f3de3a271ab93df790`.

The compatibility builds also passed after the runner changes:
`scripts/raspberry-pi/doctor.sh` and
`scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6`
produced a verified ARMv6 EABI5 hard-float executable (SHA-256
`5e63709869c737e673e0dc8e5f9ddf04ccd3cc72c91cd11d97103fb6d21f2f7f`).
`scripts/nrf52840/doctor.sh` and
`scripts/nrf52840/build.sh --application signal-analyzer-static` produced
an ARMv7E-M hard-float ELF (SHA-256
`1cbfa64cef84695497aab982ba05d0fcbaa3dbd3ac86e5de970accb4a2544381`)
with 196,480 RAM and 241,436 flash bytes. The nRF native runner passed again
after that build regenerated the amalgamated Swift source.

The rehearsal establishes the executable production seam for T7.6. The
scripted actions, workload and semantic comparison, reviewed pixels, faults,
and registered profile gate remain T7.6 through T7.9.

## T7.6 Pi behavior slice

The Pi native runner now drives 2,400 production deterministic-source
deliveries through repository observation, fact admission, mutation, semantic
derivation, layout, Drawing, and framebuffer submission. Its substituted clock
spaces 20 deliveries in each 250-millisecond logical window and services 120
windows. The source's prescribed transition timestamps remain unchanged; this
is an ingress-rate stress rehearsal, not a claim that the natural source emits
80 transitions per second. The first window applies 25 facts because the
startup Start action leaves four baseline transitions and a running-state fact
pending; subsequent windows apply 20.

After the workload, the runner taps committed hit regions for Stop, Start,
Clear, and each 1/2/5-second window. It checks action dispatch, the next
applied state and committed revision, an empty capture after Clear, and zero
dispatch for disabled Start and selected-window controls. The full run passed
with 2,400 deliveries, 120 paced workload opportunities, and all six enabled
actions. The recording sink observed 35,651 synchronous payloads, 341,864
regions, and 28,897,180 RGB565 bytes across startup, workload, and actions.

This is Pi `host-native-fixture` evidence. The nRF behavior runner and ordered
comparison against a macOS reference remain open, so T7.6 remains pending.

## T7.6 nRF pacing correction and first physical action

The production nRF service loop now retains a 250-millisecond presentation
deadline after the initial frame. Dirty source/model state waits for that
deadline, and the scheduler includes it among its next wake candidates. The
production-host unit check covers an 80-millisecond source delivery with no
early frame, the frame at 250 milliseconds, and a later rejected display
submission. The native runner sends a raw ADS7846 down/up contact to the
committed Start hit region. It verifies revision 1 throughout the pre-deadline
period and observes revision 2 after the deadline, with 4,999 synchronous tile
writes and 807,666 bytes across the two complete frames.

The checks passed with
`scripts/contracts/check-spec-001-nrf-production-host.sh` and
`scripts/contracts/check-spec-001-nrf-host-native-rehearsal.sh`. The target
doctor and `scripts/nrf52840/build.sh --application signal-analyzer-static`
passed for `nrf52840dk/nrf52840`; the ARMv7E-M hard-float ELF used 196,480 RAM
and 241,564 flash bytes. This establishes pacing and one physical Start action,
not the full nRF T7.6 workload/action matrix.

## T7.6 nRF acquisition and physical action slice

The extended native runner now completes 2,400 scheduled production-source
transitions and 120 committed workload frames. Its clock adapter scales the
source's 201,770-millisecond 2,400-transition schedule into just under 30
logical seconds, then stops scheduling further source transitions at capture
revision 2,404. The production repository, fact application, semantic/layout/
Drawing pipeline, 480×320 tiled raster transport, pacing, and C touch path
remain active. It checks Stop, restart, Clear, and each window through raw
down/up samples at the committed hit region, plus zero dispatch for disabled
Start and selected-window controls. The complete run passed with 328,822 tile
writes and 51,427,778 RGB565 bytes across startup, workload, and actions.

This run found and resolved a source tie defect. Two transitions can have the
same prescribed timestamp; the former nRF delay bridge returned “no source”
for the resulting zero delay. The bridge now preserves zero, and the C host
drains at most eight due transitions in one service call. The focused
production-host test checks the simultaneous case. After the fix, the target
build passed with 196,480 RAM and 241,532 flash bytes. The native execution
remains `host-native-fixture` evidence, not connected-target evidence.

Ordered semantic, action, Drawing, and frame traces against the applicable
macOS reference remain to complete T7.6.

## T7.6 ordered target trace slice (2026-09-27)

The two native runners now emit ordered records from their production host
opportunities. The Pi records every workload frame's fact count, capture
revision/count, model state, semantic and layout counts, Drawing stroke/point
counts, and render operation count. The nRF recorder observes each committed
presentation revision after the production tiled frame, including capture and
model state plus cumulative tile writes/bytes. Both runners record the same
post-workload enabled and disabled pointer sequence. These are observation
records; they do not drive the host loops.

Raw records are saved as [Pi](pi-ordered-trace.tsv) (132 lines, SHA-256
`62ff76e6c47e357c4f520f48c45166504bba99c9a0b033e2da7a24a547a1d9c8`)
and [nRF](nrf-ordered-trace.tsv) (139 lines, SHA-256
`d5f1fee4f126f52a4090e621ba7b436801494a545c8dd72affb61cb08bd7ee8b`).
Both host-native runner commands passed. The standalone comparison command

```sh
scripts/contracts/compare-spec-001-target-actions.rb \
  Tests/ContractFixtures/SPEC001/Evidence/milestone-7/pi-ordered-trace.tsv \
  Tests/ContractFixtures/SPEC001/Evidence/milestone-7/nrf-ordered-trace.tsv
```

passed: 120 ordered Pi workload frames, 127 ordered nRF committed frames,
matching terminal capture revision 2404/count 359, and 12 identical ordered
action outcomes after normalizing the Static state/window codes. The action
sequence includes disabled Start before Stop, disabled Stop after Stop,
disabled Start after restart, and each disabled selected-window control. Clear
follows acquired transitions and empties the capture on both profiles.

The target runs use different production scheduling and raster projections,
so their frame counts and per-frame acquisition batches differ. The Pi record
does not yet include its initial or post-workload presentation summaries.
The macOS Dynamic and Static executables still do not run full application
reference loops. The target-to-target action comparison is an incremental
check, not the required ordered comparison against independent macOS reference
traces. T7.6 remains pending.

## T7.6 macOS Dynamic workload presentation reference (2026-09-27)

The focused macOS Dynamic test constructs a fresh deterministic source,
repository, observation adapter, sequenced fact admission, ViewModel, and
production Dynamic semantic/layout/Drawing/render pipeline at the approved
320×240 macOS extent. It derives and accepts an idle candidate, applies the two
bootstrap facts in the startup opportunity, starts the source, then delivers
20 scheduled transitions before each of 120 application/presentation
opportunities. It records completed outcomes through a synchronous recording
render endpoint. This calculation does not read the Pi trace to choose facts
or expected values.

The focused test passed. Its [raw reference trace](macos-dynamic-reference-trace.tsv)
has 120 ordered records (SHA-256
`1e1ea4cc126abf52fce05da63ad1312c6d9fc40a7489b9f801ab622d03f6c67b`).
The comparison command

```sh
scripts/contracts/compare-spec-001-dynamic-reference.rb \
  Tests/ContractFixtures/SPEC001/Evidence/milestone-7/macos-dynamic-reference-trace.tsv \
  Tests/ContractFixtures/SPEC001/Evidence/milestone-7/pi-ordered-trace.tsv
```

passed all 120 ordered frames on fact count, capture revision/count, model
state/window, semantic node count, layout scope count, Drawing stroke/point
count, and render operation count. The reference uses the same approved source
and Presentation implementation at its own macOS extent, while constructing
its own application and admission owners. The recording endpoint checks
accepted render streams; it does not produce canonical raster pixels.

This closes the Dynamic workload presentation comparison slice only. The
macOS Dynamic reference still lacks physical pointer action and raster-frame
traces, and an independent macOS Static full-application reference remains
absent. T7.6 remains pending.

## T7.6 completed nRF presentation counts (2026-09-27)

The production Static presentation transaction now publishes five read-only
counts only after its physical frame and interaction candidate commit:
semantic scopes, layout scopes, Drawing strokes and points, and render
operations. Teardown and validation reset the observations. The host-native
recorder asserts each count and includes them in all 127 committed-frame
records. No count controls an application transition or a render decision.

The native run and target build passed. The checked `nrf52840dk/nrf52840`
ELF retained ARMv7E-M hard-float verification and used 196,544 RAM and
241,644 flash bytes. The refreshed [nRF raw trace](nrf-ordered-trace.tsv) has
SHA-256 `d5f1fee4f126f52a4090e621ba7b436801494a545c8dd72affb61cb08bd7ee8b`.
Its 127 frames now retain completed semantic, layout, Drawing, and render
counts for a future independent macOS Static comparison.

## Validation boundary

After these slices, both host-native rehearsal commands passed, as did the
nRF production-host check, ARMv6 cross build, nRF hard-float target build,
formatter lint, governance tooling, and the registered SPEC-001 macOS Dynamic
driver. The default `scripts/test.sh` run passed its root Swift suite but
finished with 12 failing other-specification checks. Representative failures
include the SPEC-002 owned-source inventory and SPEC-008 package boundary
checks. The detailed local results are under
`.build/test-reports/macos-dynamic/`; they are not T7.6 parity evidence.

The macOS Dynamic and Static executables call `HardwareFreePresetRunner.run`
and report preset/admission checksums. The new focused Dynamic reference above
adds an ordered workload presentation calculation but does not turn either
executable into a full application loop. Remaining action, raster, and Static
reference comparisons must pass before T7.6 can be completed.
