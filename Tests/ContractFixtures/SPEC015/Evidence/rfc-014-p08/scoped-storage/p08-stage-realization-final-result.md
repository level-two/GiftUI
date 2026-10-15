# P08 typed-stage final result — stack fit rejected

**STOP: correction 2/2 compiles/extracts layout; stack fit FAILS.** Source
[Independent source review](p08-stage-realization-cycle2-independent-source-review.md)
passed `f7e56cf0` before screen revision `0faf6c76`.
The registered screen exits 0 in about 52 seconds: 25 preparation/module/layout
checks pass, 202 controls are not run. Fresh/focused success is true; complete
collection and aggregate pass are false. No current full collection, runtime,
image or complete resource result follows. Both cycles are closed; no automatic
third variant. [Independent exit review](p08-stage-realization-independent-exit-review.md)
confirms the result and package STOP. Older evidence stays immutable.

[Compact result](stage-realization-cycle2-screen/result.json),
[original receipts](stage-realization-cycle2-screen/screen-receipts.tar.xz) and
[frame/relocation packet](stage-realization-cycle2-screen/frames-and-calls.json.xz)
pin actual commands/flags, source/compiler/tools and 34 full bounded disassemblies.
Actual object `.build/nrf52840/contracts/p08-counter-l9u4imor/P08CounterRuntime.o`
SHA-256 `917e93305c4b2c9f46bf83fb92df407bb141955a73cf53379f26ce14fcc0f904`;
build receipt `cdead491a37a2f5bc7f7f1de005df78894c1d4b0e34d855fd65a918c1ae02465`;
wrapper `e93f474ddd30a149c58cdc1797c03f230c2468df1ec94ff58f5d3cf520d9ad09`.
Layout `a1d58b1d708b73c02d59c45ad4e684ce05d7acede90a5bdc90f5657ff2a96def`
still gives cursor 31,993, alignment 8, four 32,000-byte slots / 128,000 retained.
Stderr is empty. This analysis uses existing symbol decoding/disassembly only:
no source/compiler/build/runtime/image variant. Packet size is 141,112 bytes.

## Required live lower bounds

ET_REL owner sections qualify offsets. Exact symbols and relocation targets use
their actual linked symbol-table indices. Frames count saved registers plus SP
subtractions. All listed edges are BL / R_ARM_THM_CALL, with caller restoration
after return. Enclosing callbacks, deeper callees, alignment and IRQ add costs.

| Function | Owner section | Frame lower bound |
| --- | ---: | ---: |
| lexical construction | 3839 | 26,072 |
| inout host operations / reuse ordering | 3831 / 3734 | 4,216 / 5,360 |
| old-origin checks / stale action rejection | 3694 / 3646 | 8,032 / 19,272 |
| borrowing prepare operation | 3623 | 3,912 |
| current action router / up leaf | 3718 / 3714 | 5,296 / 11,528 |
| actual host wrapper / state opportunity | 3638 / 7168 | 144 / 7,896 |
| actual preset factory | 3850 | 8,728 |
| terminal / teardown controller / state reset | 3730 / 9198 / 7184 | 344 / 24 / 7,832 |

The second host receives the original nonnull transcript, early 0/no fault, and
enters actual stale-action preparation. Its required path is
**26,072 + 4,216 + 5,360 + 8,032 + 19,272 + 3,912 = 66,864 > 27,648**.
Edges: section3839+0x6ca→3831; 3831+0x1e→3734; 3734+0x58→3694;
3694+0x17c→3646; 3646+0x2a→3623. The prepare frame is allocated even though
original-producer validation rejects the stale action. No exclusive branches sum.

Separate required paths also fail:

- Current up through actual host/state opportunity: 26,072 + 4,216 + 5,360 +
  5,296 + 11,528 + 144 + 7,896 = **60,512**. Reuse+0x7e→router; router+0x48→up;
  up+0x62→wrapper; wrapper+0x2a→state. The positive twin has active host, valid
  report and activation step seven.
- Valid construction, lexical+0x614→preset factory: **26,072 + 8,728 = 34,800**.
- First active terminal teardown/reset: 26,072 + 4,216 + 5,360 + 344 + 24 +
  7,832 = **43,848**. Reuse+0xa4→terminal; terminal+0x18→controller;
  controller+0x82→reset. Later idempotent lexical defer is not added.

These are source-feasible lower bounds, not target execution, global maxima or
complete upper bounds. Prior 75,224 and final 60,512 current-action subpaths have
different private boundaries; subtraction is not a whole-workload saving. Root
remains 128; down/up leaves are 10,480/11,528. Any oversized required path rejects fit.

## Remaining cause and decision

Lexical construction reserves 26,072: fusion did not coalesce all consumed-value
homes. At +0x518 copy length 3,889 precedes memcpy8 +0x526 and a state-related
operation. At +0x61c length 4,808 precedes memcpy8 +0x624 and typed-host Optional
tag/projection handling. Exact generated symbols/bodies are retained. These are
static transfers, not exhaustive frame partitions or semantic authority copies.
Borrowed model/prepare/deliver helpers still reserve 3,896 local bytes (frames
3,904/3,912/3,912). Legal owned assertion results do not eliminate physical state
temporaries. No heap, new owner or backing change was used.

A 30 KiB usable stack cannot cover even the 34,800-byte construction path. Holding
**historical** non-main RAM 132,032 and main guard 64 fixed, usable 66,864 requires
at least **198,960**, already 2,352 beyond 196,608 before omitted costs. This is
conditional arithmetic, not a new image RAM measurement; historical zero-margin
usable room 64,512 is not a current fit fact. Modest budget-only increase is unsupported.

Next needs a separately authorized structural/compiler realization investigation
at existing limits, or deliberate contract/resource review. No new attribute or
source candidate is selected. Failure does **not** prove the contract unimplementable.
SPEC-015 S15.2's mandated state payloads/lifetime unions cannot silently become
heap boxing, raw projections, another backing owner or weaker checks. Any proposed
change needs its actual upstream decision. Mandatory resource correctness is not
deferrable optional optimization.

P08/R07/T8.1/HC-RD-003 remain blocked/open. Current complete coverage, image handoff,
nested/IRQ/allocator/Dynamic and physical cleanup/resource proof remain unproved.
I4-07/analyzer, P09–P12 and hardware/timing stay separate. Read-only hash/decompression,
arithmetic, links, governance and whitespace checks pass. Pycache remains untouched.
