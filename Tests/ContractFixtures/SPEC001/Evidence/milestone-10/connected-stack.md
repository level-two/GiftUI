# T10.6 — Connected application stack validation

2026-10-02. Explicit user-authorized flash and debugger-driven measurement on
nRF52840-DK, J-Link probe 683833660, 3.30 V, SWD 4 MHz. The named final image
was built, checked and flashed through the repository scripts.

- ELF SHA-256: `669ce2770fefe731e838c290038593590baf3cf96e86203f0ceb971c5cb82588`.
- HEX SHA-256: `4032ad705ef6317fb3a07f1a1ab2acc5a19955bd96072571f39914e5249b2f77`.
- ARMv7E-M, Cortex-M4F VFP register calling convention; heap-disabled image
  and no linked allocation entry points pass the build checks.
- FLASH **275,504 / 1,048,576**; RAM **191,104 / 196,608** bytes. Relative to
  the initial production join, flash decreases 9,384 and RAM decreases 4,096
  bytes. No ceiling or main-stack capacity changes.
- Main-stack buffer `0x20027E80`, capacity **27,648** bytes. Measured high-water
  **19,480** bytes, untouched low prefix **8,168** bytes (29.5%).
- Final halted CPU: NoException; CFSR/HFSR zero and all five driver fault
  counters zero. Raw stack length is exactly 27,648 bytes.

## Realization and meaningful checks

The first joined firmware overflowed its main stack before production. Large
32-slot Interaction value copies and inlined startup validation/stages combined
into oversized call frames. The six-action preset now selects runtime-owned
six-slot candidate, committed and hit stores using the same generic canonical
InteractionState algorithms. The existing general 32-slot stores remain intact.
Stage boundaries and two startup validator stages remain out of line; every
prior startup assertion remains. Canvas derivation still calls its canonical
producer. No parallel interaction algorithm, heap fallback or reduced UI appears.

A regression commits six records, overflows a later seven-record candidate,
and proves the previous revision and routing survive unchanged. The current
1,158-test root suite passes (the two expensive reference corpora were already
run by the complete registered gate). The real firmware-native corpus preserves
818 ordered frames and 12 actions and all production fault/recovery probes.
Actual firmware compiler negative imports and the nRF Static owner/storage/
allocation profile checks pass. Source hashes, configuration, ABI, symbols,
commands and raw logs accompany the measurement.

## Measurement method and scope

This single-thread Zephyr configuration does not initialize the main stack to
an AA sentinel despite CONFIG_INIT_STACKS=y. A debugger breakpoint at main
verifies its range. J-Link loadbin then **implicitly resets and halts** the MCU
and paints 27,640 bytes from the low stack address before resuming boot,
leaving the top eight bytes intact. This is deliberately a pre-boot paint,
not a claim that loadbin preserves a paused execution state. The read script
uses J-Link's hexadecimal length `0x6C00`; the earlier decimal-looking length
was invalid and its dump is excluded. Count the unchanged low AA prefix of
the exact 27,648-byte dump to reproduce the high-water figure.

After startup and idle, GDB admits normalized down/up Start events through the
production input ABI using committed hit bounds. The production C service
loop consumes both; revision advances from 1 to 11, acquisition is running,
capture count is 14 and drawing point count is 50. Sampling was interrupted
before the planned 3,500 service stops; finalization observes capture count
16 and zero queued events. The subsequent Stop attempt did not prove a stopped
state and is not counted as successful action evidence. Diagnostic functions
are existing read-only exports retained against link GC; input still goes
through normal admission, gesture handling and paced opportunities.

The watermark covers startup validation, idle, this acquisition/rendering and
debugger call frames. It is a measured case, not an exhaustive worst-case bound
or a 30-second 80-Hz/cadence proof. Physical touch, reviewed pixels, connected
display acceptance and frame-cost/timing criteria remain separately gated.
The production common join's stack-fit prerequisite is satisfied for this
recorded run; SPEC-001 is not transitioned to implemented.

`connected-stack-validation.tar.gz` preserves the exact raw stack, sentinel,
command scripts, hashes and validation logs. No unrelated source edits are
included in this step.
