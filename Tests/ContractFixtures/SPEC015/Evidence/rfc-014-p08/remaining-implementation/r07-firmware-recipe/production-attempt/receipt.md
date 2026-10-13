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

## Bounded backing validation result — 2026-10-13

Source38ba440d unchanged. All4current routes pass; native passes were preserved,
not rerun. One supported firmware command, session91357, actualexit0. Linked
ARMv7E-M/VFP, flash298932/RAM152320, heap0, exact120704-byte caller BSS,20-byte
GOT inside accounted ROM/no RAM copy/no relocations are preserved in adjacent
backing-realization. Existing allocation-thunk/refusal-stub qualification stays.

Gross-stack FAIL: selected nested runCounterHost control closure0x17bd0 saves
32 and subtracts71680+496 =72208bytes, exceeding27648 by44560 alone. Actual
root/selected-symbol/direct caller attribution and full relevant disassembly
are preserved. Graph2248 and host3968+alignment improve, but do not establish
fit. No full peak/IRQ/P11 audit is needed after this decisive local failure.
Compiler cause unresolved; STOP for separate Strong review. No automatic repair,
additional build, source/runtime/workload/limit relaxation or hardware action.
All closed historical guards and current two-consecutive-unproductive rule are
preserved. Current backing image invocation1/1 consumed; P08 remains open.

## Phase-split pre-edit dispatch and test-seam finding — entry678e5880

Sol6.1 High / Strong; C3/R3, HC-RD-003/P08/T8.1/R07. Read exact independent
backing-result review. Mapped two @inline(never) private helpers: rejection
phase takes inout owner, borrowed canonical/foreign model/root scopes, both
control pointers, immutable audit/report/snapshots and returns only Int18; full
lifecycle phase takes inout same selected host, same pointer/report/failure
selector/join count and returns only Int. Owner consumption into preset factory,
all enclosing backing/activation lifetimes, proposal/assertion order, profiles/
IDs/slots and teardown stay unchanged. CounterHostProbe.swift is the only
authorized source file. No source edit/build/check/repair has run.

Pre-edit unchanged-checker seam analysis identifies necessary additional test
maintenance: Static negative generator lines133–142 textually inject escape
inside old in-method lifecycle block. Required top-level helper move removes
the needle (pure-text ValueError); retaining indentation mis-scopes escaped.
Exact old/new proposed seam, hashes, argument/lifetime map and finite tests are
in backing-realization/phase-split/seam-finding.md and seam-analysis.json.
Additional needed file is check-spec-015-counter.py for the exact Static
escape-injection call seam, preserving existing independent lifetime/provenance
oracle. No generator change is made. STOP for separate Strong review before
widening file handoff; this is ordinary test-maintenance scope disposition, not
a claimed product/contract decision or human approval requirement. Guards and
all unconsumed current allowances are preserved; prior image remains failed.

## Amended phase-split implementation dispatch — entryd402ee6a

Same Sol6.1 High / Strong. Authority678e5880 amended by phase-split/seam-review.md
atd402ee6a; C3/R3, HC-RD-003/P08/T8.1/R07. Exactly two source files allowed:
RuntimeDerived/CounterHostProbe.swift and scripts/contracts/check-spec-015-counter.py.
The prior seam finding consumed no source/check/build allowance. One mapped
correction, formatter, one fresh nativeStatic gate then one Dynamic/Pi/nRF route
refresh each sequentially, and one supported nRF image only after passes. Stop
first failure or linked result for independent review; zero automatic repair.
Historical closed allowances and package two-consecutive-unproductive rule stay.

Phase map is unchanged from the recorded seam-finding: construct supplied/owner
once within original model/semantic/Canvas/geometry/control/activation borrows;
inout owner rejection helper preserves all six proposals/assertions/snapshots
and returns Int18, ending its borrow before original factory consumes owner.
Same selected host then goes inout to the complete lifecycle helper, preserving
activation, failures, paced calls/corpus, repeated activation, teardown and all
stopped-input/admission assertions. Both private @inline(never) helpers precede
p08CounterHost, neither returns an owner/host/large aggregate. No new BSS/heap,
raw nonescapable storage, lifetime shortening, scope/ID/order/capacity change.

Checker Static negative matches exactly one complete40-space-indented actual
counterRunHostLifecycle call line in original control closure. Replace it with
the same activate/escaped-consume/return1 body. Failclosed exact full-line counts
for method rename, escaped declaration insertion, post-scope use seam and owned
projection; record counts. Keep copy/Dynamic negatives, Embedded absence and
exact Static diagnostic/provenance tuple unchanged. No legacy/fake fallback.

Exact gate recipes reuse existing verified runtime builds: macos-static
.build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static; macos-dynamic
.build/contracts/spec-013-runtime-cycle/tmp_63jv4xj/macos-dynamic; Pi
.build/raspberry-pi/contracts/spec-013-runtime-cycle/tmpvq70p7a0/raspberry-pi-armv6;
nRF .build/nrf52840/contracts/spec-013-runtime-cycle/tmp9d1k2h7s/nrf52840-embedded.
Fresh checker outputs/invocations/logs/hashes retained under phase-split. Final
image uses fresh nRF receipt via existing supported build. Actual nested helper/
construction/enclosing/initializer/corpus/click frames including alignment and
applicable IRQ overlap must fit27648; smaller locals alone are insufficient.
RAM196608/flash1048576/heap0 and all prior qualifications stay. No P09/hardware.
