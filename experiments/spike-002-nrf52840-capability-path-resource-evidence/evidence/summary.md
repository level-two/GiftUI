# SPIKE-002 Evidence Summary

## Reproduction identity

- Revision: `8a166978382d6a52e2f13779902887b430c04514`; the worktree was
  dirty with the uncommitted SPIKE-002 experiment and its documentation feed
  when measured.
- Host: macOS 26.3 arm64.
- Swift: Apple Swift 6.3.2; target `armv7em-none-none-eabi`.
- Zephyr 4.3.0 (`3568e1b6d5cdd51a6b964a2a1d6d29200fea2056`),
  Zephyr SDK 0.17.4, west 1.5.0, CMake 4.4.2, Ninja 1.13.2.
- Board: `nrf52840dk/nrf52840`.
- Compile/link: Embedded Swift, `-Osize`, Cortex-M4F hard-float,
  function sections, and linker garbage collection.
- Baseline ELF SHA-256:
  `ed3a4f3dfe70607caf792209046f2efae3ffb3212116ba71ecb374bce54f4359`.
- Candidate ELF SHA-256:
  `91584a9e84ea73c7645152665e53aac83d08dc5442ac36eaa36083134be188f4`.
- Two pristine builds produced identical ELF hashes and normalized metrics.

## Resource result

| Metric | Baseline | Candidate | Increment | Limit / interpretation |
| --- | ---: | ---: | ---: | --- |
| Linked RAM bytes (ELF `LOAD`) | 8,060 | 8,188 | 128 | 196,608 total |
| Linked flash bytes (ELF `LOAD` file sizes) | 25,816 | 26,920 | 1,104 | 1,048,576 total; 917,504 warning |
| `bss` bytes | 1,025 | 1,105 | 80 | Informational |
| `datas` bytes | 44 | 44 | 0 | Informational |
| `text` bytes | 22,452 | 23,544 | 1,092 | Informational |
| `rodata` bytes | 2,384 | 2,384 | 0 | Informational |
| Capability fixed storage bytes | 0 | 80 | 80 | Snapshot 32 + validation 16 + trace 32 |
| Worst-case resolver stack bytes | 0 | 72 | 72 | Finite disassembly bound |
| Complete driver stack bytes | control only | 472 | n/a | Main + driver + failure resolver chain |
| Success initialization operations | 0 | 14 | 14 | All fixed-width counter categories |
| Worst negative initialization operations | 0 | 14 | 14 | Resource-bound failure |
| Steady-state resolver invocations | 0 | 0 | 0 | Required zero |
| Heap allocator entry points | 0 | 0 | 0 | Required zero |
| Display staging bytes | 0 | 3,840 | 3,840 | At most 16,384 |

The 128-byte RAM delta exceeds the 80 bytes of named capability storage by 48
bytes because the linker moved `noinit` alignment/padding. The delta is kept
whole; no attempt was made to subtract threshold effects.

## Stack method

The bound comes from conservative ARM disassembly of every resolver branch.
The resolver saves nine 32-bit registers and reserves 28 bytes (64 bytes). A
failure may call the validation-result helper, which saves two registers (8
bytes), yielding 72 bytes. The resolver contains no recursion or indirect
call. The complete driver saves nine registers and reserves 356 bytes (392
bytes); main adds 8 bytes, so main + driver + resolver + failure helper is at
most 472 bytes. The generated `disassembly.txt` is retained under
`.build/nrf52840/spike-002-candidate/reports/spike-002/` by `run.sh`.

## Initialization work and path coverage

The columns below are contributions visited, compatibility comparisons,
checked operations, validation records, and resolver invocations. They come
from executing the exact candidate Swift source in the host harness.

| Path | Visited | Compared | Checked | Records | Invocations | Stable result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Available | 4 | 3 | 5 | 1 | 1 | 480×320 RGB565, 3,840-byte staging |
| Malformed input | 4 | 0 | 1 | 1 | 1 | reason 1 |
| Duplicate owner | 4 | 0 | 1 | 1 | 1 | reason 2 |
| Incompatible encoding | 4 | 2 | 1 | 1 | 1 | reason 3 |
| Incompatible lifetime | 4 | 3 | 1 | 1 | 1 | reason 4 |
| Unsatisfied resource bounds | 4 | 3 | 5 | 1 | 1 | reason 5 |
| Positive control | 4 | 3 | 5 | 1 | 1 | available |

The available trace is `0x1f`: construction, initialization-time resolution,
validation construction, immutable snapshot storage, and steady-state access
were all reached. The steady-state accessor reads the stored snapshot and has
no resolver call. The target entry invokes all paths from a volatile seed and
stores trace/counter values in retained fixed symbols, preventing dead-code
elimination.

## Zero-heap and family exclusion checks

Both final configurations contain `CONFIG_HEAP_MEM_POOL_SIZE=0` and
`CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0`. Neither final ELF exports a code
entry for `malloc`, `calloc`, `realloc`, `aligned_alloc`, `k_malloc`,
`k_calloc`, or `k_realloc`. The complete capability path uses stack values and
the named static snapshot, validation, and trace records; all appear in the
candidate symbol/map reports.

The candidate symbol report was checked for
`dynamic.*registry`, `framebuffer`, `appkit`, `backend.*desktop`, and unrelated
`capability.*(text|input)` patterns. None is retained. Only the experiment's
single raster-presentation family is present.

## Interpretation and limitation

The bounded representation satisfies SPIKE-002's linked-image feasibility
criteria and every established RFC-006 target limit. This proves feasibility
for one representation, not the final API, layouts, diagnostic vocabulary, or
independent resolver/snapshot budget. The target image was not executed and no
board was flashed; operation counts are host execution of the exact pure
candidate source, while target observability and bounds come from ELF/map and
disassembly evidence.
