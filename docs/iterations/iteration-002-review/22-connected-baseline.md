# Step 22 — Connected production baseline

The maintainer superseded the earlier hardware deferral with authorization for
measurements and experiments after hardware-free completion. Both targets were
identified and the measured artifacts matched the preserved baseline. This is
bounded connected evidence, not iteration scope approval or universal conformance.

| Target / workload | Fresh result | Interpretation |
| --- | --- | --- |
| Pi 1 / idle full-frame application, 45s | 31 frames; 0.717 observed fps; 1.272–1.513s frame cost, median 1.369s; sampled peak RSS 9,748KiB | Reproduces FW-027's performance gap before the 80-event/s acceptance workload. |
| nRF / software Start then nonhalting SWD, 600 samples over 66.84s | Running state, capture9/drawing40 at halted snapshot; first nine capture records match deterministic source; steady publication gaps 21.190/21.200/21.625s | Reproduces FW-032; sparse capture/publication does not establish sustained admission or four fps. |
| nRF / verified reset, painted startup and idle | 19,480 bytes of observed changed extent in a 27,648-byte sentinel range; 8,168-byte untouched prefix; idle revision1 | Matches historical painted startup extent. A workload observation, not a whole-control-flow stack bound or permission to reduce reservation. |

## Identity and method

Pi SSH `giftui@giftui-pi.local` reported `armv6l`. Its existing binary matched
local SHA-256 `acf57db5625eb1d2802210aaa6e30128749277d81ad26a3f313b79f8448d8d7e`,
so no deployment was needed. PiScreen inspection reported 480×320, 16bpp,
960-byte stride and `/dev/input/event0`. A bounded sudo application process used
`GIFTUI_PI_TRACE=1`; SIGINT timeout wrapper exited124 while application teardown
reported `status=completed`. No remote service restart or physical contact occurred.

J-Link serial683833660 identified Cortex-M4 and 3.3V. Production firmware
SHA-256 `c6d0f12c8585cad3f3949fb596e13fa7328989239a31a1f6e428afadb541ed5c`
was explicitly flashed through the repository J-Link runner. ARMv7E-M/VFP,
zero-heap baseline checks remained valid. SWD observations used host timestamps
and 100ms requested sleeps; probe overhead is included.

Ready software Start used the committed hit point and revision1. Both Down/Up
returned255 (pending), with pending count2; subsequent acquisition was observed.
A software Stop admitted at revision6 while the CPU was halted mid-frame also
returned pending, but a later snapshot at revision13 remained running/capture16.
**A stopped outcome was not established.** Freshness/replacement during that
mid-frame injection is a hypothesis, not a proven code defect or physical-input
result. Do not mark Start/Stop/Clear connected acceptance passed.

Sampled driver counters and CFSR/HFSR stayed zero. Debug-halt DFSR flags are
recorded separately and are not application hard faults. The nine-record prefix
checks only initial source records, not lossless 80-event/s admission for30s.

## Stack measurement integrity

An initial paint attempt lacked a verified pre-start halt and was excluded.
A later GDB attachment initialized CPU registers, invalidating its apparent
startup/acquisition measurements. Those raw attempts remain labeled excluded.
The corrected attachment explicitly uses `-nohalt -noir -noreset`, then halts
through GDB and resumes at detach. These options follow
[SEGGER's documented register/attach behavior](https://kb.segger.com/J-Link_GDB_Server).

The independent valid production stack run resets/halts with Commander, verifies
PC0x2473c/SP0x2002ea40 and DHCSR0x00030003, writes0xAA only to
`0x20027e80..<0x2002ea80`, verifies halt again, and runs. No debugger function
calls occur before its stack capture. The64-byte MPU reservation is excluded
using the actual stack symbol/configuration. Capture shows ready idle revision1,
PC in the application delay loop and CFSR/HFSR0. `z_main_thread.stack_info` is
zero in this single-thread build; it supplies no extra range proof.

The observed changed extent includes startup checks and idle presentation. It
does not cover all paths, active acquisition, failed publications or the hierarchy
candidates. Static Step20 proof barriers remain; observed sentinel data cannot
replace a conservative whole-program bound.

## Preserved evidence and disposition

[Measurements, artifact identities and per-file hashes](evidence/22-connected-baseline.json)
and [raw archive including excluded attempts](evidence/22-connected-logs.tar.gz)
preserve the campaign. Collector scripts and
[summary reproduction](summarize-connected-baseline.py) are committed beside it.
Generated logs/builds remain under the platform `.build/` trees.

FW-027/032 remain open performance work. FW-033 still requires physical contact,
complete normal/diagnostic rendering, failure/recovery and sustained workload
coverage. The current research can now proceed to bounded hierarchy candidate
measurements. No production cleanup, contract amendment or exception closure
is selected by this result.
