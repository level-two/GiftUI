# nRF52840 240×320 connected attempt

Date: 2026-09-27

The maintainer verified the physical wiring against the project's nRF52840-DK
Arduino-header pin map and explicitly requested a connected physical test.
The checked-out source revision was
`6bd56094b4a8058f0228e05c4ef3f6c8a4dda9d6`, with a clean working tree.

From the repository root, `scripts/nrf52840/doctor.sh` passed. The
`signal-analyzer-static` application was rebuilt with
`scripts/nrf52840/build.sh --application signal-analyzer-static`; its generated
Devicetree includes the direct-SPI display and shared SPI touch nodes. The
linked ELF reports ARMv7E-M, VFPv4-D16, and VFP-register arguments. The build
uses 194,240 bytes RAM and 241,460 bytes flash, below the approved 196,608-byte
RAM and 1 MiB flash ceilings.

The artifact identities are:

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `0f797c55dc4f6ae268722217caa51dfdb3688b5ad9bd5aca78143448915642c9` |
| `zephyr.hex` | `a2c2e90bbf96d308f45d67c18c55086a9f5dbfc65bb756ef6172d45c8a436c1c` |

`scripts/nrf52840/flash.sh --application signal-analyzer-static --no-build`
completed through the J-Link runner. J-Link identified the same connected
probe as the earlier campaign, serial `683833660`, with target voltage 3.300 V.
The target was reset and resumed through J-Link. The USB serial port
`/dev/cu.usbmodem0006838336601` opened at 115200 baud, but two 50-second
captures yielded no bytes. The production `main` path does not call the
`device_validation.c` logging function; serial silence is not a device result.

Debugger snapshots more than 30 seconds after reset found the Cortex-M4 in
`giftui_static_host_wait_until` under the production scheduler. The display
driver's `display_initialized` byte was 1, all five `giftui_fault_count`
storage entries were zero, and the ARM configurable/hard fault status registers
were zero. This supports successful initialization and sustained scheduler
execution. SPI API success does not establish visible pixel output or a
correct controller profile.

The maintainer subsequently supplied a photograph. It shows that the TFT
receives and displays the Signal Analyzer image, but in portrait orientation
with horizontally reversed text and an unpainted white band. The later
[320×240 landscape candidate](nrf52840-320x240-landscape-candidate.md) addresses
those observations in firmware. Its physical result, controller
identity/readback, six controls, touch calibration, cadence, and connected
stack high-water remain unverified. `T8.2` and connected conformance remain
blocked pending that evidence.
