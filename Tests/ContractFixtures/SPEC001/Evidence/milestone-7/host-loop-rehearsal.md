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
