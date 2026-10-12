# R07 production GOT source step

Entry93d15431, reviewed handoff got-placement/independent-review.md.
Counter.cmake adds the existing Zephyr RODATA hook; adjacent counter_got.ld
is exactly the prescribed ALIGN4/boundary/four-pattern snippet plus explanation.
No normal-analyzer recipe or generated Zephyr script is edited.

Required formatter PASS exit0, no maintained Swift changes. All346frozen inputs
match except the explicitly edited Counter.cmake; the new snippet hash is added.
Exact two-file source patch and current hashes are adjacent. This is the source
step only: no production validation invocation yet, no image/resource pass.

One supported build remains authorized, with normal CMake stages; record actual
outcome, then STOP for independent result review. Diagnostic1/1 and historical
helper2/2+B031/1 remain closed; no source/flags/runtime/config/workload/limit
relaxation, automatic repair, target execution or hardware.

## Reviewed backing realization dispatch — entry71c833a9

Executor Sol6.1 High / Strong; P08/T8.1/R07, C3/R3, HC-RD-003 physical
backing and linked-image gross-fit criteria. Review authority is adjacent
`independent-review.md`; no human contract decision is inferred. This is a new
local storage realization only. Historical helper2/2+B031/1, diagnostic1/1 and
initial supported-build1/1 remain closed. One correction/source step, then
one finite affected native validation, fresh required route receipts and one
supported nRF image validation; no automatic follow-on repair.

Concrete layout: preserve the existing inline profile for existing coordinator
and native callers. The selected Embedded graph/host share their existing
behavior through a selected profile alias; the new profile contains typed field
pointers into explicit caller-owned slots, not another corpus or runtime owner.
C main supplies four static slots of30176bytes aligned8 (120704bytes total),
exactly the existing ARM profile stride. Layout checks must assert every typed
stride and final cursor before access. The existing final-image initializer
0x10ee4/semantic initializer0x3c1aa establishes these target extents; no new
compiler/linker diagnostic ran for this design.

| Field, in slot order | Offset | Bytes/stride | Alignment |
|---|---:|---:|---:|
| RuntimeProfileLimits |0|116|4|
| StaticObservableRootAdapter |116|812|4|
| StaticSemanticRecordStorage |928|116|4|
| records128 x SemanticRuntimeRecord |1044|2560 (20each)|2|
| paths384 x SemanticPathEntry |3604|8448 (22each)|2|
| payloads256 x CounterPayload? |12052|9216 (36each)|4|
| scalars128 x UInt32 |21268|512 (4each)|4|
| StaticCanvasValueStorage |21780|4|2|
| Canvas entry1 |21784|28|4|
| workspace scopes1024/text1056/path20/plan112 |21812|2212|1|
| CounterStaticKeys? |24024|2412|4|
| alignment gap |26436|4|—|
| CounterControl, including tile800/coverage50 |26440|3728|8|
| used Bool |30168|1|1|
| tail alignment |30169|7|—|

Bind each field to its exact type, initialize fields individually in that order,
and initialize semantic elements one by one to existing defaults (including
nonzero absent sentinels and nil payloads). Never construct the original full
profile or semantic aggregate as an initializer temporary. Other individual
field initializers retain their existing values; their stack scratch and live
callees remain part of final gross-fit review. Deinitialize in reverse order
after all nested borrows/host teardown. Include slot padding and descriptor
metadata in the physical ledger once, without changing capacities or limits.

Lifetime/slot map: graph uses slot0 and destroys its descriptor and typed fields
at function return. Only then does host initialize complete0, partial1 and
nonRetryable2, preserving identity issue order and all three simultaneous live
intervals. Each step2...7 initializes failed3 with fresh monotonic identities;
its original run/teardown completes before deinit and next iteration reuse.
The three saved profiles run in original order after the failure loop. Their
slots end after final borrows and teardown at host return. The existing foreign
root/control stay independent inline locals and concurrently live through each
rejection scope; no foreign alias/reuse or omitted negative. Caller backing is
passed explicitly from C to private entry, graph and host; no ambient lookup.
C main owns the sole invocation; no backing is shared between concurrent calls.

Allowed source files only: CounterProfileStorage.swift, CounterGraphProbe.swift,
CounterHostProbe.swift, CounterRouteEntry.swift, CounterStorageRegions.swift,
CounterStorageMeasurement.swift, optional new StaticCounterEmbeddedBacking.swift
(all under RuntimeDerived), and firmware src/counter_main.c for explicit backing
ABI only. No portable owner, checker, image builder, recipe/GOT/flags/runtime,
capacity, workload, source-order, assertion, hardware or contract relaxation.

Finite checks after source commit: scripts/format-swift.sh; one
`python3 scripts/contracts/check-spec-015-counter.py --runtime-build
.build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static --profile
macos-static` affected native check; existing checker refreshes for macos-dynamic,
raspberry-pi-armv6 and nrf52840-embedded from their existing verified runtime/host
recipes (their exact argv/output paths recorded at dispatch). Fresh nRF receipt
then `scripts/nrf52840/build.sh --application signal-analyzer-static
--counter-build <fresh-nrf-output>`. Preserve exact failures. Inspect linked
ABI/GOT/relocations/allocator qualification, total RAM/flash and actual nested
entry/graph/host/initialization/corpus/click stack chain. Any check/scope failure
stops for independent Strong review; P09–P12 and hardware remain untouched.
