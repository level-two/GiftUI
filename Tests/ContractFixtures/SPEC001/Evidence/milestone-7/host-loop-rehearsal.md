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
