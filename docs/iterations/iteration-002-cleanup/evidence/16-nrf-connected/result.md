# Authorized nRF five-second connected regression — 2026-10-05

Eugene's [explicit deployment approval](../../retention-approval.md) resolved the
previous authorization blocker. Identified J-Link 683833660/nRF52840-DK;
ARMv7E-M/VFP ELF SHA-256
`9822838bccedb57f2819e6d3e8b0e796c15f9e8357d5880bced3bb4cb2b68f2f`,
HEX `293c4f604cb26bee2251f68c4a0ae51cb6376fe35d8356f68933a1cc82b7bf97`.
Stable no-build flashing completed. Hardware-assisted temporary breakpoints at
`service` avoid the previous detached software-breakpoint fault; every script
removed breakpoints, resumed and detached successfully within its 55s bound.

Startup publishes revision 1/idle/count0 with default two-second window. Normal
software input down/up admission returned 255/255 with pending count2 for each
of Start, Stop, select1, select2, select5. After Start, revision5/running/count7
was observed; after Stop, revision6/stopped/count8. Window publications advance
through revisions7/8/9 with enabled-action geometry proving 1/2/5s selections.
The eight packed live records include four initial lows at time0 and the expected
deterministic prefix. Retained baseline remains all-low in this partial capture;
nonzero baseline/eviction coverage is independently tested hardware-free.
The 19,392-byte three-slot region is observed in the real C production context.
Custom driver fault counters and CFSR/HFSR remain zero throughout. DFSR2 records
the requested debugger halt, not a production CPU fault.

Input quiesce/retirement reported revision0/pending0 and zero faults. The same
verified firmware was flashed again to restore a default idle application.
Final service inspection: revision1, idle0, count0, two-second window. Nonhalting
SWD samples confirm zero custom/CPU faults and DHCSR without the halted bit.
Unused capture bytes may contain startup-probe records; logical count0 controls
the empty capture, and no zeroization contract is implied. Final device is
running the approved image with acquisition idle and no debugger session left.

These are connected CPU/firmware and software-input observations. No physical
touch, independent pixel review, exhaustive stack high-water or sustained
80-event/s wall-time pass is claimed. Debugger timestamps are not a cadence
measurement; existing timing/physical exceptions retain their exact provenance.
[Matched resources](paired-resources.json): flash274,272 →274,144 (−128),
RAM191,104 →95,104 (−96,000), configured main stack27,648 unchanged, disabled
heaps and VFP checks pass. [Raw scripts/log identities](raw-identities.json).

The nRF portion of T12.4/T11.7 is complete; Pi remains unavailable by mDNS.
No full connected task or iteration closure is inferred until its Pi portion
succeeds or a specific scope exception is explicitly approved.
