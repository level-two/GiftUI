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

Raw records are saved as [Pi](pi-ordered-trace.tsv) (139 lines, SHA-256
`ebe67b25fc8174379ecb2ee0cddf15702958b5bf2c26a7411391945710220d9e`)
and [nRF](nrf-ordered-trace.tsv) (139 lines, SHA-256
`65ad95a95b98c167f7c9e15d707c00ae308cd4c03cffbc5a625026cf68807dd6`).
Both host-native runner commands passed. The standalone comparison command

```sh
scripts/contracts/compare-spec-001-target-actions.rb \
  Tests/ContractFixtures/SPEC001/Evidence/milestone-7/pi-ordered-trace.tsv \
  Tests/ContractFixtures/SPEC001/Evidence/milestone-7/nrf-ordered-trace.tsv
```

passed: 120 ordered Pi workload frames, 127 ordered nRF committed frames,
matching terminal capture revision 2404/count 359, seven matching initial and
action-induced frames, and 12 identical ordered action outcomes after
normalizing the Static state/window codes. The action
sequence includes disabled Start before Stop, disabled Stop after Stop,
disabled Start after restart, and each disabled selected-window control. Clear
follows acquired transitions and empties the capture on both profiles.

The target runs use different production scheduling and raster projections,
so their workload frame numbering and per-frame acquisition batches differ.
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
has 139 ordered workload, initial/action-frame, and pointer-action records
(SHA-256 `00ae0ce81cac24c06f7c43c45e0f4cbc69dd0eea760e8d9e76c1ebadf2f0cc2e`).
The comparison command

```sh
scripts/contracts/compare-spec-001-dynamic-reference.rb \
  Tests/ContractFixtures/SPEC001/Evidence/milestone-7/macos-dynamic-reference-trace.tsv \
  Tests/ContractFixtures/SPEC001/Evidence/milestone-7/pi-ordered-trace.tsv
```

passed all 120 ordered workload frames on fact count, capture revision/count,
model state/window, semantic node count, layout scope count, Drawing
stroke/point count, and render operation count. It also passed seven initial
and action-induced presentation summaries and 12 pointer down/up outcomes,
including disabled controls. The reference uses the same approved source and
Presentation implementation at its own macOS extent, while constructing its
own application, admission, and interaction owners. The recording endpoint
checks accepted render streams; it does not produce canonical raster pixels.

This closes the Dynamic application and presentation-summary comparison
slice. A physical raster-frame reference and an independent macOS Static
full-application reference remain absent. T7.6 remains pending.

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
SHA-256 `65ad95a95b98c167f7c9e15d707c00ae308cd4c03cffbc5a625026cf68807dd6`.
Its 127 frames now retain completed semantic, layout, Drawing, and render
counts for a future independent macOS Static comparison.

## T7.6 Pi initial and action frame summaries (2026-09-27)

The host-native display adapters now retain their accepted RGB565 writes in
recording surfaces and append an FNV-1a 64-bit hash to each committed frame
record. Pi reconstructs its 240×240 logical pixels from submitted payload
regions; the nRF adapter reconstructs 480×320 pixels from one-row ILI9486
writes. The latter surface exists only in the macOS native recorder, not the
firmware. The first hashes are `11815390858494900828` (Pi) and
`17577988481690697083` (nRF). Both complete native runs passed and the
target action comparator still passed 120 Pi workload frames, 127 nRF frames,
seven initial/action frames, and 12 actions. These extent-specific hashes
establish physical write order and frame identity; T7.7 will supply reviewed
pixel references.

The Dynamic presentation owner now retains its latest accepted summary for
read-only observation. The Pi native runner records the idle initial frame and
each of the six action-induced committed frames, including capture/model state,
semantic/layout/Drawing/render counts, and cumulative physical payload,
region, and byte counts. Disabled controls leave the committed revision
unchanged and create no frame record.

The host-native runner passed with 120 workload frames and seven additional
initial/action summaries. The expanded target comparison passed all seven
frames on capture revision/count, model state/window, layout scopes, Drawing
strokes/points, and render operation count. Pi and nRF retain their distinct
semantic counting schemes and physical projections. The ARMv6 cross-build
passed and verified the supported EABI5 hard-float executable without a remote
run. The refreshed [Pi raw trace](pi-ordered-trace.tsv) has SHA-256
`ebe67b25fc8174379ecb2ee0cddf15702958b5bf2c26a7411391945710220d9e`.

## T7.6 macOS Static reference and completed comparisons (2026-09-27)

The focused macOS Static reference uses the approved `macOSStatic` profile's
320×240 logical extent and 39,696-byte fixed profile regions. It constructs
its own deterministic source, repository, Static fact admission, ViewModel,
generated Static semantic table, in-place layout and Drawing workspaces,
render preflight and recording operation sink. Source facts are admitted and
applied at each source opportunity; presentation occurs at the same 250 ms
deadlines as the nRF native loop. The reference generates the schedule from
the source's own delays and does not read the nRF trace to choose facts.

The reference also builds and commits six Static interaction records for each
accepted presentation. Before each scripted enabled action it tests pointer
down/up at the committed hit region; disabled controls must ignore down. The
model action is invoked only after the enabled gesture is admitted. The shared
generated Static hierarchy and fixed-region algorithms are exercised with
the macOS preset and its extent; the nRF target retains its own 480×320 tiled
physical projection.

The focused test passed and produced the [macOS Static trace](macos-static-reference-trace.tsv)
(139 ordered records, SHA-256
`4671d31448ac482f28fed9e520f51e974eb1d9dc339f69d882167f269dcb7b52`).
The comparison commands passed:

```sh
scripts/contracts/compare-spec-001-dynamic-reference.rb \
  Tests/ContractFixtures/SPEC001/Evidence/milestone-7/macos-dynamic-reference-trace.tsv \
  Tests/ContractFixtures/SPEC001/Evidence/milestone-7/pi-ordered-trace.tsv
scripts/contracts/compare-spec-001-static-reference.rb \
  Tests/ContractFixtures/SPEC001/Evidence/milestone-7/macos-static-reference-trace.tsv \
  Tests/ContractFixtures/SPEC001/Evidence/milestone-7/nrf-ordered-trace.tsv
```

The Dynamic comparison covers 120 workload frames, seven initial/action
presentations and 12 pointer outcomes; the Static comparison covers all 127
initial, workload and action presentations and 12 action outcomes. Both check
ordered capture/model state, semantic/layout/Drawing/render summaries and the
presence of a physical target-frame hash. The target-to-target action check
also passes. This completes T7.6 at the host-native evidence boundary.
Reviewed exact pixels, fault injection and profile-driver registration remain
T7.7 through T7.9.

## Validation boundary

After these slices, both host-native rehearsal commands passed, as did the
nRF production-host check, ARMv6 cross build, nRF hard-float target build,
formatter lint, governance tooling, and the registered SPEC-001 macOS Dynamic
driver. The default `scripts/test.sh` run passed its root Swift suite but
finished with 12 failing other-specification checks. Representative failures
include the SPEC-002 owned-source inventory and SPEC-008 package boundary
checks. The detailed local results are under
`.build/test-reports/macos-dynamic/`; they are not T7.6 parity evidence.

The macOS Dynamic and Static executables still call
`HardwareFreePresetRunner.run` for preset/admission checksums. The focused
tests above provide the independent source, admission, presentation and
interaction references used for T7.6. The complete host-native behavior and
ordered comparison gate now passes. Exact pixel references remain T7.7.
