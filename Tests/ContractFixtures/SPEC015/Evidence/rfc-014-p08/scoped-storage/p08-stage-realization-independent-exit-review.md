# P08 typed-stage package — independent exit review

**STOP / resource fit FAIL independently confirmed; P08 NOT COMPLETE.** Review
of `76530e4a` and the [final result](p08-stage-realization-final-result.md) finds
no material discrepancy. Source `f7e56cf0` passed independent source review and the
actual nRF module/layout screen compiles, but this resource rejection closes the
activity at **2/2**, with no third automatic variant or limit change.

Independently verified the actual ET_REL/ARM object SHA-256
`917e93305c4b2c9f46bf83fb92df407bb141955a73cf53379f26ce14fcc0f904`,
actual receipt/layout/wrapper identities, compressed frame/receipt packets and
all 34 saved disassembly hashes. Packet size is 141,112 bytes. A separate ELF32
read and read-only regeneration verify 14 path prologues/section disassemblies
and 13 distinct actual BL relocation edges through their real SHT_REL sh_info,
sh_link and symbol-table indices. No unresolved zero offset is a global address.

Decisive stale preparation path: **26,072 + 4,216 + 5,360 + 8,032 + 19,272 +
3,912 = 66,864 > 27,648**. Exact edges are 3839:0x6ca→3831,
3831:0x1e→3734, 3734:0x58→3694, 3694:0x17c→3646 and 3646:0x2a→3623.
Raw code retains each caller frame through the BL and uses the result afterward.
The second real host has the original nonnull transcript and early zero/no fault;
it must perform stale prepare. The borrowing prepare frame is reserved before
producer rejection. This is a required source-feasible path, not target execution.

Other independently checked prologues/edges/arithmetic establish separate bounds:
current up **60,512**, valid construction **34,800**, first active terminal/reset
**43,848**. All exceed 27,648. Mutually exclusive branches and later idempotent
teardown are not added together. These are lower bounds, not global maxima or
complete stack upper bounds; outer/deeper/IRQ/alignment costs remain omitted.
Different historical subpath boundaries do not establish whole-workload savings.

Verified lexical immediate/call samples 3,889 at 0x518→memcpy8 at 0x526 and
4,808 at 0x61c→memcpy8 at 0x624. Residual state forwarding and typed-host Optional
materialization are physical compiler costs, not proof of duplicated semantic
ownership, heap allocation or a complete frame partition. Required state and
ownership remain unchanged; no passing fit follows from lawful owned observations.

The current receipt is **25 pass / 202 not run**; fresh/focused success true,
complete collection/aggregate pass false. Layout remains cursor 31,993, alignment
8 and 32,000×4 = 128,000 retained. Final source hash is unchanged. Earlier full
profile/runtime/image passes remain valid historical evidence for their sources;
they do not supply current coverage. No new runtime or image exists for this source.

Holding historical other RAM 132,032 and guard 64 fixed gives
**132,032 + 64 + 66,864 = 198,960**, exceeding 196,608 by **2,352** before omitted
costs. This is conditional arithmetic, not a new linked-image RAM fact or a stack
maximum. It does not support a modest budget-only remedy or raising any ceiling.

Stop further costly tests/images on this candidate. The next package decision
should be a bounded resource-realization/ownership-contract assessment before
another implementation: identify which mandated state payload/lifetime and typed
host construction/projection costs this compiler can realize within existing
limits, and distinguish avoidable private orchestration from obligations that
would need an upstream change. Another blind annotation package is unsupported.
Failure here does not prove the contract unimplementable or that it must change.
Any proposed ownership, representation, workload, capacity, toolchain or resource
amendment needs its precise authority and explicit decision; none is selected here.

No source/compiler/build/test/runtime/image/hardware work or allowance reset was
performed by this review. Historical budgets stay closed. P08/R07/T8.1/HC-RD-003,
all nine SO criteria and complete current coverage, cleanup/resource, allocator,
IRQ/Dynamic and final acceptance duties remain open; later packages and hardware/
timing retain their separate dispositions.
