# Scoped connected attempt — 2026-10-05

**T11.7 is blocked, not passed.** No new exception is created. This packet
preserves the attempt separately from the passing hardware-free integration.
[Raw copied-file identities](raw-identities.json) identify the retained logs.

The identified Pi reported `armv6l`, hostname `giftui-pi`, framebuffer `/dev/fb0`
and touch `/dev/input/event0`. Local artifact SHA-256 is
`a3b7b345e9dd99ab08c24e60885ef7b845855bb48cef64da597a86f8a3fbdbcf`.
`scripts/raspberry-pi/deploy.sh --product SignalAnalyzerRaspberryPiARMv6 --no-build --resume`
verified the local ARMv6 ELF and remote architecture, then its rsync transfer
stalled. A read-only SSH check timed out; the local transfer was terminated
(exit 143). The subsequent read-only retry succeeded: the deployed executable
remained 10,371,236 bytes; the `.incoming` upload was 5,767,168 bytes, below the
10,364,356-byte current artifact. No atomic replacement, application run or
service restart completed. The incoming file is retained for resumption.

One J-Link, serial `683833660`, identified nRF52840/Cortex-M4 at 3.3V.
`scripts/nrf52840/flash.sh --application signal-analyzer-static --no-build`
completed successfully. ELF SHA-256:
`9ef60d653678dce21ec389dbf4977aca0fe40291a2847958ba42b3d190681da6`;
HEX SHA-256:
`7089c07e6b35ea7557adae63b03aa5eac353112aa9db3055e0b0888750962cc1`.
The bounded Start script used a temporary software breakpoint at `service`.
Both 55-second attempts timed out before any software action was admitted.
The nonhalting recovery collector observed ready revision 1 and zero custom
fault counters; DHCSR `00030003` shows the target halted, so its `go` did not
prove continued execution. The later [fault inspection](fatal-inspect.log)
shows a UsageFault path at `service`, CFSR 0, HFSR `80000000`, DFSR 1.
This is consistent with the detached software breakpoint left by the timed-out
debugger. The inference is a debugger-induced breakpoint fault, not evidence of
a production startup defect. No Start/Stop/window pass is claimed.
The final observed board state is the Zephyr fatal loop; successful restoration
has not been established. Future bounded scripts must use a hardware breakpoint
and guaranteed breakpoint cleanup, not detach with a flash software breakpoint.

Automatic approval review rejected the recovery flash because explicit
connected-board authorization was not established. It also rejected the resumed
Pi deployment because explicit remote-change authorization was not established.
The proposed hardware recovery/checks and remote deployment/checks are pending
human authorization; no indirect workaround is used. Repository standing-device
language in the derived plan is insufficient to override those rejections.

No physical touches, independent pixels, whole-stack high-water, source/capture
lifecycle or 80-event/s wall-time result is established by this attempt.
Production retains the approved 30s/2,404-record contract. T11.8 depends on
completed T11.7 or a specific approved exception and therefore remains blocked.
