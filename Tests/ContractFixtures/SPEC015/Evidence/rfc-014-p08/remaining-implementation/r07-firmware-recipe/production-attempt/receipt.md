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

Source realization step: six source files changed (four existing fixtures, one
new fixture, counter_main.c). Existing host implementation remains shared via
CounterSelectedStaticProfileStorage; the existing inline coordinator/native
owner remains available. Embedded field accessors mutate pointed-to storage
without mutating the descriptor; only small semantic/Canvas descriptors are
locally copied for nested scoped spans. No bank payload copies are introduced.
The shared ledger takes an optional separately charged descriptor region;
existing callers supply none. The new physical slot includes original trailing
alignment bytes. Formatter invocation `scripts/format-swift.sh` exited0
(session81006). No compiler, checker or image build has run for this step.

Route freshness clarification during native-static validation: parent explicitly
authorizes exactly one macos-dynamic checker execution after static passes,
because the changed shared graph/entry bytes affect all four original P08
routes. The checker has no native compile-only switch. This is an independent
required route refresh, not a repair or unchanged rerun. Pi and nRF follow
sequentially as cross-compilation only. No checker modification is authorized.

## Sequential validation resume dispatch — 2026-10-13, entryf1c7eccb

Same Sol6.1 High / Strong, source38ba440d; user renewed proceed instruction.
C3/R3, P08/T8.1/R07, HC-RD-003 current-route and image physical-fit criteria.
Read committed backing-realization checkpoint, active plan/context and platform
skills. Native Static/Dynamic already passed and will not be rerun. No source
edit or new repair is dispatched. Historical helper2/2, B031/1, diagnostic1/1
and earlier supported-image1/1 remain closed; two-consecutive-unproductive-
repair guard and independent review stop remain unchanged.

Allowed remaining checks, sequential, once each: existing checker
`python3 scripts/contracts/check-spec-015-counter.py --runtime-build
.build/raspberry-pi/contracts/spec-013-runtime-cycle/tmpvq70p7a0/raspberry-pi-armv6
--profile raspberry-pi-armv6`; then existing checker with
`--runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmp9d1k2h7s/nrf52840-embedded
--profile nrf52840-embedded`. Host build uses its existing default verified
recipe. Record actual fresh output paths and exact failures. After both pass,
one `scripts/nrf52840/build.sh --application signal-analyzer-static
--counter-build <fresh-nrf-output>`, then read-only linked artifact inspection
for actual nested gross stack, ABI/GOT/allocator/RAM/flash against unchanged
limits. Platform doctors are read-only preflight; no probes, variants or setup.
Only receipts/evidence and affected plan/context/progress checkpoint may change.
Any failed validation stops for separate Strong review; no automatic repair,
P09, target execution or hardware. Model-capacity failure is reported without
a substitute model or resetting any guard.

Pi current-source refresh PASS on2026-10-13, session90484, actual checkerexit0,
output `.build/raspberry-pi/contracts/p08-counter-o95xgfoa`, 28/28 checks and
221matching current input hashes. Exact invocation/log/receipt preserved under
backing-realization. No native rerun or source repair. nRF remains uninvoked in
this slice; continue its one reviewed checker only after this committed step.

nRF current-source checker PASS on2026-10-13, session11792, actualexit0, output
`.build/nrf52840/contracts/p08-counter-bpvu3ztk`, 26/26checks and
208matching current input hashes including new backing fixture. Before the one
supported image command, inspect the emitted initializer read-only for constant
layout rejection; no alternate compilation or repair. If it rejects, STOP.

Read-only route initializer inspection confirms construction path, no constant
layout rejection; local route frame17592bytes remains provisional. Exact
section disassembly/hash and inspection commands are preserved. Native/Pi/nRF
source38ba440d receipts now all current. Next exact single supported invocation:
`scripts/nrf52840/build.sh --application signal-analyzer-static --counter-build
.build/nrf52840/contracts/p08-counter-bpvu3ztk`. It has not yet run. Preserve
actual exit and final image; inspect actual linked stack/ABI/GOT/allocator and
RAM/flash, then STOP. No repair follows failed validation.
