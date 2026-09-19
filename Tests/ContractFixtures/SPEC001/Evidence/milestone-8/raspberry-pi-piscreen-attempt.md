# Raspberry Pi / PiScreen Connected Campaign Attempt

**Recorded:** 2026-09-19

The maintainer separately authorized connected Raspberry Pi work and selected
`giftui@giftui-pi.local`. Local mDNS was unavailable, so the target was reached
at `192.168.55.44` with `HostKeyAlias=giftui-pi.local`; its ED25519 key matched
the saved hostname key before any deployment. The machine reported `armv6l`,
Raspberry Pi Model B Rev 2, and Raspbian Bookworm.

The project-local Swift 6.3.2 ARMv6 doctor passed. SPEC-003's dedicated
connected corpus was deployed, executed, and removed successfully, completing
its separately owned T6.2 evidence without a service restart.

The PiScreen campaign gates could not execute conformingly:

- `/dev/fb0` was absent;
- DRM `card0-HDMI-A-1` reported `disconnected` with no mode;
- the writeback connector had no display mode;
- the ADS7846 touchscreen was present as `/dev/input/event0`; and
- the exact T6.4 product still invokes `HardwareFreePresetRunner` and has no
  production PiScreen framebuffer/DRM presentation and input adapter to drive
  the required 30-second six-control scenario.

Deploying that product would only reproduce its hardware-free normalized
transcript and could not prove visible output, presentation-coupled routing,
physical input, cadence, or recovery. It was therefore not deployed, and no
service was restarted.

This attempt leaves SPEC-001 T8.1, the Raspberry Pi portion of SPEC-011 T9.3,
and SPEC-015's connected PiScreen gate blocked. A conforming retry requires a
connected 240 x 240 display interface exposed to the unprivileged `giftui`
user and the approved production PiScreen display/input integration in the
exact T6.4 artifact. Cross-build or SPEC-003 latency evidence cannot substitute
for those observations.

## Framebuffer Remediation

**Recorded:** 2026-09-20

The follow-up connected-hardware request authorized diagnosis and repair. The
PiScreen device-tree overlay was already correct: `spi0.0` was bound to
`fb_ili9486`, but the display appeared as `/dev/fb1`. The boot log showed why:
Raspberry Pi 1 firmware created an early 720 x 480 `simple-framebuffer` for its
default composite-TV output. That transient device consumed framebuffer index
zero and disappeared after KMS initialization, leaving the working SPI display
at index one.

The repair preserved
`/boot/firmware/config.txt.giftui-before-fb0-20260920` with SHA-256
`9fca766706959aa07d7f002db60513cf27932db658697ec6394dd6752f941ba1`,
then added the documented `enable_tvout=0` setting to disable the unused
composite framebuffer. The resulting configuration SHA-256 was
`d6b74980968463800d5d27bf17c5a7caaac0e340fe96770e375c4c6d7253b4b6`.
After one required reboot, the target again reported `armv6l` and exposed:

- `/dev/fb0`, owned by `root:video` with mode `0660`;
- `fb_ili9486`, 480 x 320, 16 bits per pixel, at SPI 16 MHz; and
- ADS7846 touchscreen input at `/dev/input/event0`.

The firmware `simple-framebuffer` no longer appeared in the boot log. This
closes the target-configuration portion of the original blocker. It does not
by itself close SPEC-001 T8.1: the exact T6.4 artifact must still supply the
approved 240 x 240 logical presentation and input integration before visible
output or six-control evidence can be claimed.

## Exact T6.4 Artifact Execution

After the repair, the repository Pi doctor passed with project-local Swift
6.3.2 and the exact `armv6-unknown-linux-gnueabihf` SDK. The command

```text
scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6
```

produced a stripped ARM EABI5 hard-float executable with build ID
`8dc7afc03f5910a1946e8a259187030db4297528` and SHA-256
`d0a4717d9161ab7bc92f709b992d118cb41d1060937196d1a1b11e5180db732c`.
The repository deployment workflow rechecked `armv6l`, atomically installed
that artifact at `giftui/bin/SignalAnalyzerRaspberryPiARMv6`, and ran it with
no service restart. The target report completed with the registered
Raspberry Pi preset values: 240 x 240 logical extent, 16-row RGB565 region,
30,416 profile-storage bytes, six actions, five canvases, 2,400 workload
events, 120 workload frames, and `status=complete`.

This target execution strengthens T6.4's existing cross-build evidence by
proving that the immutable artifact starts and completes on the selected
ARMv6 machine. The executable still only calls `HardwareFreePresetRunner`; it
did not open `/dev/fb0` or `/dev/input/event0`. Consequently this run does not
claim visible PiScreen output, physical control input, presentation cadence,
or completion of T8.1, SPEC-011 T9.3, or SPEC-015's connected PiScreen gate.
