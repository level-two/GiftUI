# Matched Native allocation diagnostic protocol

This separate diagnostic adapts SPEC-013's allocation interposer. It changes no
application/framework source or retained compiler receipt. It observes public
allocation APIs; **it does not establish zero heap, total process heap, complete
temporary-storage cost, complete stack bound, or resource fit**.

From the repository root, the sequential mechanical command is:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-allocation-diagnostic/measure.py --output .build/contracts/p08-native-allocation-matched-20261017 --run
```

The output directory must be new. Omit `--run` for preparation/validation only.
Do not rerun compiler suites. The script validates the retained receipts'201
current input hashes/profile, pinned compiler hash and exactly25 distinct object
inputs, removes only generated `Main.swift`, substitutes `Driver.o`, changes the
module-cache/output destinations and adds the observer library/rpath. It records
both link argument arrays, objects/hashes, C instrumentation/compiler identities,
Mach-O section/symbol/library inventories and all generated artifact hashes. A
fresh diagnostic link is required; never overwrite either retained `counter`.
Original partial receipt status and runtime/host noncompiled qualifications stay
unchanged; source freshness alone does not make those receipts complete.

`Driver.c` calls the existing C export with NULL, first cold through cleanup and
then immediately reuses the same finite route through cleanup. This export runs
`p08CounterRoute`, not every additional model/semantic test in retained Main.
Record its actual return count per profile; require nonzero and cold=reuse. Do
not substitute retained Main's larger assertion counts or require equal counts
across profiles. The script runs three fresh processes/profile in alternating
Dynamic/Static order. Fixture trace output is unchanged and redirected to raw
stdout. No reports or attribution work occur between the two windows.

## Accounting and controls

The observer wraps malloc/calloc/realloc/free, valloc/aligned_alloc/posix_memalign,
zone malloc/calloc/realloc/free/valloc/memalign/batch, and their SDK typed variants.
Only an outermost public API event on the owner thread enters the ledger; nested
hooks are counted separately. TLS is initialized before measurement. Foreign
thread events invalidate the run. Fixed pointer/group tables have explicit
saturation flags. Cold retained records remain present in reuse; report its
baseline, new allocation counts/totals, absolute live and peaks. The `frees` field
counts tracked records retired, including successful realloc replacement. Unknown frees
refer to pre-window/unobserved allocations and remain visible, never subtracted.

Standalone validation executes in a separate process, so known allocations do
not warm the matched workload. It checks23 positive route families (including
realloc and batch counts), retained cold→reuse release, and foreign-thread
rejection. The negative direct-zone control is expected to allocate/free113bytes
while yielding zero public events. That is a **coverage failure of the method**,
not an allocator or profile failure. Keep it in every packet. Any positive
control failure, foreign event, saturation, or unexpected entry count stops
interpretation. Frame truncation/unknown symbols require attribution qualification.

`requested` includes any Swift header/control already inside the allocation.
`malloc_size` is rounded usable client storage; reserved-minus-requested is
usable-size rounding, **not** allocator arena/VM/metadata bookkeeping. Peak values
are simultaneous client-live records at observed API boundaries. Realloc's
internal old/new overlap and allocator arenas are not measured. Per-group peaks
are not simultaneous across groups and must not be summed as an actual peak.
Observer BSS arrays, additional observer/C call frames, initialized TLS and
reporting storage are diagnostic costs; the output gives array sizes and a
minimum globals charge, while the library's section inventory supplies its full
linked charge. Nothing from the observer is charged as profile-owned payload.

Per-allocation groups preserve cohort, public route, requested/reserved totals,
live extents and up to24 frame-chain return PCs. Capture is nonallocating; ARM64
frame pointers must remain aligned, monotonic and within the recorded pthread
stack. Return PCs have authentication stripped. Tail calls/omitted frames may
hide callers even without truncation. `dladdr` runs after both windows and records
image/base/offset/symbol; use preserved `nm -n` and Mach-O VM addresses to resolve
private main-image symbols, then pinned Swift demangling. Do not infer ownership
from an unresolved stack or subtract the whole Static run from Dynamic.

## Required attribution and coverage follow-up

After mechanical runs, a bounded Strong analysis must:

1. Classify actual allocation groups against the pinned source functions: common
   counter graph/oracle, fixture `counterTrace`/Swift print, selected Static or
   Dynamic host/storage, and unresolved. Dynamic also calls common Static
   scoped-storage fixtures. Runtime generic metadata or boxing reached by the
   selected Static path cannot be excused merely by calling it library work.
   Account payload capacity×stride and source/runtime header/control separately;
   keep temporary live peaks and retained metadata distinct.
2. Use the **actual loaded runtime UUID/path** (`IMAGE` records), not the compiler's
   bundled dylib by assumption. Audit the rooted Swift allocation/metadata/error/
   coroutine routes, zone dispatch tables and raw VM paths. In particular both
   ordinary runtime objects import `swift_coroFrameAlloc`; import presence is not
   reachability, and a coroutine/temp cache or stack allocation can bypass malloc.
   Resolve ABI and call targets from that actual runtime before adding an event
   hook; record logical temporary lifetime separately without double-counting
   its eventual public heap backing. Do not guess a C prototype.
3. Follow every rooted allocation edge to a validated public hook or supply
   separate evidence for direct zone callbacks, mmap/mach VM, allocator internal
   reserve/metadata and temporary slabs/caches. The negative control proves this
   cannot be omitted. Concrete follow-up is actual-runtime disassembly/rooted
   call-site audit, with address breakpoints on identified direct callbacks/VM
   entries if static resolution is insufficient. Do not classify all imported
   allocators as reached. If these edges cannot be closed, preserve observed
   totals as qualified partial evidence and name the exact unresolved family.

Native records RLIMIT_STACK, actual pthread stack extent, inherited signal mask,
signal dispositions/alternate stack, loaded-image UUIDs and linked sections.
These are assumptions/inventory, not a stack bound. Complete feasible phases,
outer driver, callbacks/recursion, Swift/stdio/allocator callees, outgoing argument
and temporary/copy homes remain required. OS IRQ executes on a kernel stack;
user signal reentrancy needs its own explicit premise. No Cortex-M stack/IRQ
numbers transfer. The observer changes stack use, so measured observer paths
cannot simply replace the ordinary-image stack proof.

For Pi, use preserved current ELF `c1c6682e` and its exact ARMv6 map/objects plus
source phase/lifetime reasoning. Static Swift still leaves Linux dynamic loader,
libc/libm/libstdc++/libatomic/libgcc callees; qualify their identities/frames and
callback/temporary/allocator/VM paths. SDK or symbol presence alone is not a
complete bound. Actual deployment process stack/physical-memory assumptions are
not established by hardware-free linking. This protocol does not execute Pi or
alter its supported build route.
