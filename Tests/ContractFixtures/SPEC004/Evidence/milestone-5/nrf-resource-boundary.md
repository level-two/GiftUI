# SPEC-004 nRF Resource Boundary Evidence

**Task:** T5.3 (open; stack ceiling failed)

**Evidence class:** hardware-free cross-build and final-image inspection

**Target:** `nrf52840dk/nrf52840`, `armv7em-none-none-eabi`, Cortex-M4F hard-float

**Toolchain:** Swift 6.3.2, Zephyr 4.3.0, Zephyr SDK 0.17.4

The SPEC-004 driver builds a matched baseline/candidate pair with whole-module
`-Osize`, Embedded Swift, function sections, the same Zephyr configuration,
heap disabled, and no remote access, deployment, or flashing. The baseline
contains the retained C/Swift entry and display staging but does not compile or
link `GiftUICapabilities`. The candidate concatenates the exact checked-in
production source and the observable resource probe into one generated WMO
input, avoiding duplicate Swift module-hash objects without changing source
meaning.

## Measured preliminary pair

| Metric | Baseline | Candidate | Delta/value | Contract bound | Result |
| --- | ---: | ---: | ---: | ---: | --- |
| Linked RAM | 9,856 B | 10,108 B | +252 B | total <= 192 KiB; capability <= 768 B | pass |
| Linked flash | 25,732 B | 30,596 B | +4,864 B | total <= 1 MiB; capability <= 8 KiB | pass |
| Device flash warning | — | 30,596 B | 30,596 B | review above 896 KiB | pass |
| Named capability storage | — | — | 202 B | <= 512 B | pass |
| Default display staging | — | — | 3,840 B | <= 16 KiB | pass |
| Initialization work | — | — | 44 operations | <= 96 | pass |
| Conservative resolver stack | — | — | **540 B** | **<= 256 B** | **fail** |

The stack checker starts at the final-image production
`RasterPresentationResolver.resolve` symbol, derives each reachable frame from
ARM disassembly, follows direct call targets through the linked symbol table,
rejects reachable dynamic adjustments, unresolved indirect calls, and cycles,
and sums the maximum acyclic live-frame path. The resolver's own final-image
frame is already 360 bytes (nine saved registers plus 324 bytes of local
stack), so the contract cannot pass through a measurement interpretation.
Reachable callees raise the conservative bound to 540 bytes.

An attempted internal `borrowing` annotation on helper inputs compiled and
passed focused tests but produced the same 360-byte resolver frame and 540-byte
path, so it was not retained. T5.3 remains unchecked. The implementation must
reduce production stack usage while preserving the approved API and semantics,
or SPEC-004 must return to review; the plan cannot grant an exception.

## Reproduction

```text
scripts/nrf52840/doctor.sh --probe
scripts/contracts/run-spec-004.sh --profile nrf52840-embedded
```

The second command currently fails closed with
`resolver stack 540 exceeds 256`. Generated ELFs, maps, load segments, symbol
tables, disassembly, hashes, and the TSV summary remain under
`.build/contract-reports/spec-004/nrf52840-embedded/` and are not committed.
T5.4 still requires two pristine repeatable pairs and its complete evidence;
this preliminary pair does not claim T5.4.
