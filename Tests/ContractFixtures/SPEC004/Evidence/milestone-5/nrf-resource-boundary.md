# SPEC-004 nRF Resource Boundary Evidence

**Tasks:** T5.3 and T5.4 (complete)

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
| Linked flash | 25,732 B | 30,500 B | +4,768 B | total <= 1 MiB; capability <= 8 KiB | pass |
| Device flash warning | — | 30,500 B | 30,500 B | review above 896 KiB | pass |
| Named capability storage | — | — | 202 B | <= 512 B | pass |
| Default display staging | — | — | 3,840 B | <= 16 KiB | pass |
| Initialization work | — | — | 44 operations | <= 96 | pass |
| Conservative resolver stack | — | — | 80 B | <= 256 B | pass |

The stack checker starts at the retained resolver measurement entry (or the
public production resolver when it remains as a final-image symbol), derives
each reachable frame from ARM disassembly, follows direct call targets through
the linked symbol table, rejects reachable dynamic adjustments, unresolved
indirect calls, and cycles, and sums the maximum acyclic live-frame path.

The first candidate exposed a 360-byte resolver frame and 540-byte path. An
attempted internal `borrowing` annotation produced identical codegen and was
not retained. The conforming implementation instead separates input
validation/canonicalization from sequential candidate evaluation, so both
large candidate outcomes are never live in one frame. The public API,
workspace reset, deterministic preference and reason precedence, normalized
results, zero allocation, and 44-operation maximum remain unchanged.

## Reproduction

```text
scripts/nrf52840/doctor.sh --probe
scripts/contracts/run-spec-004.sh --profile nrf52840-embedded
```

Both commands pass. The driver performs two pristine rebuilds from the same
fixed baseline and candidate build paths. The baseline ELF hash is
`c3e798a5340891d63d4e9b8a3f1727ab4089bd730fcfe2bff379883b6b8f4212`
in both builds; the candidate ELF hash is
`24f21d8a3c0eac988f2a0b4891a37bc48f0a71aab5bce6dea900e3768b53841f`
in both builds. Normalized metrics and the seven-node reachable resolver call
graph are byte-identical across builds. Generated ELFs, maps, load segments,
symbol tables, disassembly, hashes, and the TSV summary remain under
`.build/contract-reports/spec-004/nrf52840-embedded/` and are not committed.
The driver records complete compiler/linker commands, source and tool hashes,
ELF/map/section/symbol/disassembly inputs, and the resolved call graph. No
reachable indirect call, dynamic stack adjustment, recursion, or unresolved
body remains.
