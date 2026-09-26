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

The unprivileged `giftui` account belongs to both `video` and `input`; direct
access checks confirmed that it can read and write `/dev/fb0` and read
`/dev/input/event0`.

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
no service restart. A target-side SHA-256 check reproduced
`d0a4717d9161ab7bc92f709b992d118cb41d1060937196d1a1b11e5180db732c`.
The target report completed with the registered
Raspberry Pi preset values: 240 x 240 logical extent, 16-row RGB565 region,
30,416 profile-storage bytes, six actions, five canvases, 2,400 workload
events, 120 workload frames, and `status=complete`.

This target execution strengthens T6.4's existing cross-build evidence by
proving that the immutable artifact starts and completes on the selected
ARMv6 machine. The executable still only calls `HardwareFreePresetRunner`; it
did not open `/dev/fb0` or `/dev/input/event0`. Consequently this run does not
claim visible PiScreen output, physical control input, presentation cadence,
or completion of T8.1, SPEC-011 T9.3, or SPEC-015's connected PiScreen gate.

## Production PiScreen Run, 2026-09-24

The maintainer authorized both connected hardware campaigns. The target again
reported `armv6l`; the working framebuffer was `fb_ili9486` at 480 x 320,
16-bit RGB565, with ADS7846 at `/dev/input/event0`. The production Dynamic
Canvas build initially failed before framebuffer submission because the Pi
cross-build omitted `GIFTUI_DYNAMIC_PROFILE`. The corrected build passed the
profile gate and produced visible output. The production graphics-console
transition currently requires `sudo -n`: the `giftui` account can access the
framebuffer and input but cannot open `/dev/tty0` in its present permissions.

A subsequent 60-second run used the deployed ARMv6 artifact with SHA-256
`abd6f599689549b53fc82cd212627530111ec2783e7cefabe142b00f87699e37`:

```text
sudo -n timeout --preserve-status -s TERM 60s \
  /home/giftui/giftui/bin/SignalAnalyzerRaspberryPiARMv6 --run-signal-analyzer
status=completed
```

The maintainer's contemporaneous photograph showed only the title/status area
and a mostly blank display, and reported that the UI appeared stuck. This is a
failed visual acceptance observation even though the process exited normally.
No six-control physical input or four-frame/second measurement was collected.
After the run, SSH to `192.168.55.44` timed out, preventing framebuffer
capture and further connected diagnosis. T8.1 remains open; the photo and
process exit must not be represented as a passing connected display test.

The same production endpoint was then captured through a local framebuffer
sink. It reproduced the photographed partial frame. The raster session
reported `capacityExhausted` after its first accepted payload: its contract
allowed 16 regions per payload, while the Pi target's writer continued to
advertise its 320-region construction capacity after a 16-region reservation.
The title's last glyph submitted 21 regions, so the accepted frame drained
without drawing the subtitle, waveform, or controls. The Pi target now applies
the requested byte and region limits to its writer for each reservation. A
focused regression renders the title, subtitle, waveform, and control areas,
checks that no payload exceeds 16 regions, and requires a failure-free raster
session. The corrected ARMv6 artifact has SHA-256
`476bc858700222883dbb73033c364608ade8969b3f5836d4d59f50a5a52a8cdb`;
the SPEC-001 Pi profile gate passed its 251-test host suite and cross-build at
`.build/contract-reports/spec-001/20260925T064115Z-48271/raspberry-pi-armv6/`.
This is local evidence for the fix; the corrected artifact has not yet been
run on the Pi because SSH remains unavailable.

On 2026-09-25 the maintainer confirmed that the Pi address remains
`192.168.55.44` and began checking/rebooting it. Repeated ping from the build
Mac lost both packets, and the latest attempt reported `No route to host`.
No further deployment was attempted; the corrected binary still needs an
`armv6l` check and connected display/input run when SSH returns.
The Mac retained its local `192.168.55.15/24` address and an `en0` route to
`.44`, but ARP for `.44` remained incomplete. This points to target/network
reachability rather than a missing Mac route.

On the next Pi retry, the production product was rebuilt and passed its ARMv6
hard-float verification. The new deployable artifact is
`.build/raspberry-pi/artifacts/SignalAnalyzerRaspberryPiARMv6`, SHA-256
`ab7cd23d5de29b558a84e1c5877d4df45beb40f591045917b5f0d9ad6e4c8c0c`.
The SPEC-001 Raspberry Pi profile gate passed 251 host tests and published its
cross-build report at
`.build/contract-reports/spec-001/20260925T180656Z-73832/raspberry-pi-armv6/`.
Deployment dry-run verified the intended host-key alias and atomic upload
sequence. A real SSH `uname -m` to `192.168.55.44` timed out; a later ping
again lost both packets. No deployment or connected display run occurred.

## Connected Retry and Frame-Time Diagnosis, 2026-09-25

The Pi returned at `192.168.55.44` and reported `armv6l`. The corrected
production artifact (SHA-256
`ab7cd23d5de29b558a84e1c5877d4df45beb40f591045917b5f0d9ad6e4c8c0c`)
was deployed through `scripts/raspberry-pi/deploy.sh` after the target check.
A 90-second foreground run returned `status=completed`. The maintainer's
photograph showed the title, subtitle, four channel rows, three time rulers,
and all six controls. This confirms that the preceding region-reservation fix
removed the title-only failure, but the maintainer then reported that the
screen draws slowly, clears, and draws again.

The 480 x 320 `fb_ili9486` device has a 960-byte stride and 16-bit pixels.
Framebuffer captures during execution show progressive drawing, including
[a partial frame before the row-skip change](piscreen-partial-20260925.png)
and [a partial frame after it](piscreen-row-skip-live-20260925.png). The left
letterbox still contains text-console remnants. A 120-second run exited
cleanly and used approximately 9.4 MiB RSS, but the process stayed CPU-bound.
This is a failed display-responsiveness observation, not a four-frame/second
pass.

An opt-in monotonic trace measured the first presentation at approximately
11 seconds and subsequent frames at 11-13 seconds. Removing the forced
full-map `MS_SYNC` after each small framebuffer payload did not stop visible
clearing. Framebuffer writes accounted for only about 0.7 seconds of each
roughly 10-second frame; operation-level tracing identified the 12-subpath
grid stroke as the largest cost, approximately 6 seconds. Caching two-point
segment bounds reduced completed frame times to approximately 5-6 seconds.
That implementation introduced unaccounted stroke storage, so it was replaced
with a buffer-free row candidate search. Six connected frame durations from
the replacement were 4,156,867; 4,472,800; 4,818,261; 4,760,076;
5,102,640; and 5,208,801 microseconds. The instrumented run completed
normally after 30 seconds.

The replacement passed the 17 independent SPEC-012 raster golden masks, the
SPEC-001 Raspberry Pi profile gate's 251 tests and ARMv6 cross-build, and the
`signal-analyzer-static` nRF52840 build. The exact deployed ARMv6 artifact
has SHA-256
`11bd18e6db649d2bbe2f0da10db1f70cf6edc512fca2977624e7e52e2aa49f5c`;
`armv6l` and the remote SHA-256 were checked before a 30-second foreground
run returned `status=completed`. No remote service was restarted. A separate
SPEC-012 profile run failed its module-contract owner check for
`StaticSignalAnalyzerNRFEmbeddedRasterSink.swift` versus
`CanvasRenderProducer.swift`; the raster oracle itself passed.

T8.1 remains open. The observed 4-5-second frames miss the required
four-frame/second cadence and responsiveness. Physical six-control input,
event loss/duplication/staleness, recovery, and a conforming 30-second
end-to-end run have not yet been established. The connected evidence must not
be treated as a passing PiScreen gate.

During a subsequent five-minute foreground run, the maintainer tapped the
visible controls and reported no response; the screen continued to clear on
each frame. An independent 15-second read from `/dev/input/event0` captured
10,144 bytes (634 Linux input events), including 64 `BTN_TOUCH` down events,
63 up events, and valid `ABS_X`/`ABS_Y` samples. `evtest` identified the device
as ADS7846 with both axes declared as 0-4095. Thus physical touch reaches the
kernel, but no action response was demonstrated. The slow synchronous frame
blocks input polling for several seconds, and the current raw-to-logical
calibration/interaction routing still requires a connected diagnosis. These
samples do not prove all six actions, ordering, or event loss behavior.

An opt-in app trace then showed decoded contacts at logical `(73,186)` and
`(72,186)`, inside the host-tested Start action bounds `(61,176)` through
`(96,196)`. The first input batches queued some events but dispatched zero
actions; later batches repeatedly reported `queuedCount: 0` and rejected all
contacts. The Pi touch decoder emits a new Down only after the preceding
physical Up, but the ingress had not passed that completion proof to
`HostNormalizedInputGate`. Once a press crossed a multi-second redraw, the
gate could remain in its cancelled state and reject subsequent taps with no
resynchronization proof. Commit `18311a99` forwards the decoder's proof for
Down events, with a focused recovery test; the SPEC-001 Pi profile gate then
passed 252 host tests and ARMv6 cross-build. Commit `501cbf02` clears the
framebuffer at startup to remove stale console text from the letterbox.

The connected 75-second run of the touch-fix build reported clean completion
and frame durations increasing from about 4.2 to 6.3 seconds. No contacts
arrived during that run, so physical action dispatch remains unverified. The
four-frame/second requirement remains failed. The later bounded-arithmetic
stroke optimization passed all 17 SPEC-012 golden masks, the independent
raster oracle, and both ARMv6 and nRF52840 cross-builds; its connected timing
is pending at this point in the record.

The bounded-arithmetic optimization produced connected frame durations of
4,090,260 through 5,546,760 microseconds over a completed 45-second run.
The subsequent exact two-point stroke fast path produced 4,111,653 through
5,618,600 microseconds over another completed 45-second run. Neither change
materially improved the Pi cadence, so they were reverted in `2541741a` and
`f4e3bfa4`. The latter run was on the `armv6l` Pi; no contacts were observed.

The touch trace also showed many identical-position Move samples between a
Down and Up, sufficient to consume the six-event input queue before the Up
is admitted. Commit `bddacaaa` suppresses only unchanged-position Move
samples at the physical decoder; a changed position still emits Move and an
Up still emits the last active point. The focused Pi tests, the 252-test
SPEC-001 Pi profile gate, ARMv6 cross-build, and nRF52840 static build passed.
Connected physical action dispatch and a conforming cadence are still open.

The final source state, with both ineffective raster fast paths reverted and
the stationary-touch suppression retained, passed the 252-test SPEC-001 Pi
profile gate and ARMv6 cross-build. Its deploy artifact has SHA-256
`52ee1d9129822cae302f8076d383e045bab1adfa35701b96851d04c632e32df9`.
The final upload to `192.168.55.44` failed when the Pi host dropped off the
network (`Host is down`); three subsequent pings were lost. The preceding
deployed executable remains the last verified connected version. A partial
`.incoming` file may be present and must be hash-checked if resumed. The
final touch build had not yet received a connected run at that point.

The Pi briefly returned and again reported `armv6l`; the partial upload was
522,240 bytes. A resumable upload of the same artifact was attempted, but the
Pi stopped responding to ping and SSH during transfer. The stalled client
was stopped, preserving the partial `.incoming` file. The final artifact is
still local and T8.1 remains open pending stable Pi connectivity and physical
control testing.

The final artifact was ultimately resumed at 16 KiB/s through the explicit
IPv4 address with the saved `giftui-pi.local` host-key alias. The remote
SHA-256 matched
`52ee1d9129822cae302f8076d383e045bab1adfa35701b96851d04c632e32df9`.
A 90-second foreground run on `armv6l` returned `status=completed`. The
recorded frame durations grew from 4,124,011 to 6,722,685 microseconds, so
the four-frame/second gate still fails. The app decoded several Down/Up
contacts and ingress queued them without the previous permanent rejection,
but the opportunity summaries reported zero dispatched actions. Down points
included logical `(83,175)` and `(112,171)`, above the host-tested Start and
Stop hit bounds at y=176-196. The maintainer confirmed these were the Start
and Stop taps, followed by two more Stop taps. The connected trace therefore
supports a vertical calibration correction. This run is not evidence of
six-control success.
