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

Two-file source step ready: helper extraction preserves59original assertion/
guard lines and original phase order; same owner/host are passed inout with
original scopes. Source-text Static generator checks all five exact full-line
seams once (owned projection, method, declaration, lifecycle call, post-scope
return). Copy/Dynamic generation and every exact diagnostic tuple unchanged.
Recorded in phase-split/source-invariants.json. No compiler/check/build yet.

Phase-split nativeStatic PASS source63e717d1, actualexit0,1349555zero failures,
24/24checks;194inputs still match and five generatorseamcounts1. Formatter0.
Fresh `.build/contracts/p08-counter-qo3vbsn0`; exact logs/negative/identities
preserved underphase-split. Selected-model capacity interrupted after command
completed; resumed same Sol6.1High from recorded result without rerun/model
substitution/source change/guard reset. Remaining Dynamic/Pi/nRF each once,
then supportedimage only on passes. No failure/repair occurred.

Current Dynamic route PASS source63e717d1, actualexit0,1349501zero failures,
24/24 and194matching inputs, allfive Staticseamcounts1. Exact fresh output
`.build/contracts/p08-counter-e00kvr4q`; no repair or unchangedrerun. Pi is next
sequentially, then nRF and supportedimage only after passes.

Current Pi ARMv6 route PASS source63e717d1, actualexit0,28/28 checks and221
matching inputs, allfive Staticseamcounts1. Exact fresh output
`.build/raspberry-pi/contracts/p08-counter-kwh6apf1`; compilation only, no target
execution/current-source Pi image claim. No repair. nRF is next sequentially.

Current nRF route PASS source63e717d1, actualexit0,26/26 checks and208matching
inputs, allfive Staticseamcounts1. Fresh `.build/nrf52840/contracts/p08-counter-yhrdgas4`,
compile-only/no target execution. All4current source routes now pass. Next exact
single supported invocation is `scripts/nrf52840/build.sh --application
signal-analyzer-static --counter-build .build/nrf52840/contracts/p08-counter-yhrdgas4`.
No repair/source change/variant; preserve linked outcome and actual nestedstack
including alignment/applicable IRQ overlap, then STOP for independent review.

## Phase-split linked result — source63e717d1, 2026-10-13

All4current routes pass with unchangedexactdiagnosticoracles/five seamcounts1.
One supported imageactualexit0, session75382; finalARMv7E-M/VFP, flash299332/
RAM152320, heap0, main27648/ISR2048, unchanged120704callerBSS. GOT20bytes
0x48e7c–0x48e90 insideaccountedROM, no RAMcopy/remainingrelocs; priorallocator
qualificationretained. Exactimages/364buildobjectidentities/reports preserved.

Actual nested semantic/construction closure0x17a48 still saves32 and subtracts
58368+248 =58648local bytes, exceeding27648by31000 before any overlap. Actual
helpercalls:0x17d68/0x1806c→rejection0x182bc (4768local),0x17dcc/0x180d4→
lifecycle0x187d0 (8392local). Fullregisteredroot/callback/helperbody attribution
preserved. Smallerhelpers do not establish fit. No fullP11peak investigation
needed after decisive localfailure. No auto repair/new build/sourcevariant.
STOP for separateStrongresult andpackageguard disposition; singlecorrection
andimageallowancesconsumed, no renewedbudget/guardreset. P08open/nohardware.

## One optimized-IR evidence capture dispatch — entryed985668

Sol6.1High/Strong, unchangedsource63e717d1; C3/R3/P08/T8.1/HC-RD-003 remaining
construction-transfer attribution only. ed985668 accepts narrowed priorgates
and states packageguard is not exhausted/reset; phase correction/image budget
closed. This dispatch is one unchanged-source compiler output capture, zero
source edits/builds/links/retries/semantic variants or nextimplementation.

Exact firmware P08CounterRuntime command (148argv/39sources) matches preserved
compile_commands bytes. Invocation array/diff/outputmaps/frozeninput hashes are
in phase-split/ir-capture. Only three argv tokens change: -c→-emit-ir, isolated
output-file-map operand, isolated emit-module-path operand. Per-source object
outputs become llvm-ir .ll outputs; every ancillary output redirects to isolated
.build/nrf52840/contracts capture root. Official swift-driver FileType source
confirms llvm-ir key (linked in receipt); no help/compiler probe was invoked.
All other argv/cwd, target/compiler pins/Osize/WMO/parallel/lifetime/features/
macro/Cflags/import/cache paths remain identical. Frozen current sources/import
modules/compiler/frontend/macro/Cheaders/targetstdlib/pins/config/finalimage
and364existingfirmware object identities verified before capture.

One invocation next, stop mismatch/failure withoutretry. Analyze only selected
semantic/construction closure allocations/lifetimes/state→owner→optional/fullhost
transfers, correlating7284/7807/8155linkedcopies. Distinguish named allocations
from backend-only spills; no fullcompiler/P11 study. Record table and one exact
fixture constructionflowdesign or precise unresolvedattribution, then STOP for
independentStrongdesign disposition. Main27648/heap0/RAM196608/flash1048576,
all historicalclosedguards and package rule preserved; nohardware/P09–P12.

## One IR capture result — d2200978 dispatch, unchangedsource63e717d1

Actualcompilerexit-5; emptystdout/stderr; isolateddirectory contains only
precreatedoutputmap, zeroIR/moduleoutput. Exactargv3outputtokenchanges/cwd/maps/
start/exit/log/hashmetadata retained underphase-split/ir-capture. Fullrecorder
toolwall0.436902583s includespre/posthashes; subprocessdurationnotinstrumented.
All482frozeninputs stillmatch;364firmwareobjects verifiedbefore. No causeclaim,
retry, alternatecapture, compilerstudy/source/build/link or nextimplementation.

Capture1/1consumed; existing58648stackfailurepersists. MissingIR preventsnamed
alloca/ownership/lifetime table or evidence-supported avoidabletransferdesign;
allocation-attribution.md distinguishes priorlinkedcopies from unavailableIR.
STOP independentread-onlyreview/packageboundary, no renewedbudget/guardreset.
No humancontractgate inferred; alllimits/history/P08open/noP09/hardware preserved.

## Design-only candidate — unchangedsource63e717d1, entry77b72644

Sol6.1 High / Strong; original P08 authority, SPEC015 bounded caller-owned
Static backing contract. This is a reviewable candidate, NOT implementation
readiness, compiler feasibility or image fit. No source/compiler/test/build/
link/capture ran. Parent ended further reading to preserve this finite boundary.
All consumed allowances and the package guard stay unchanged. Independent
disposition of the following concrete plan is required before implementation.

### One mechanism: transfer descriptors, retain ordinary bulk at caller

Select one combined ordinary-workspace realization, not another optional-switch
or helper experiment. Preserve the current supplied→owner→existing optional
preset factory→mutable host construction and both reviewed phase helpers.
Remove the five inline interaction bank payloads and the ordinary geometry
value from those aggregate transfers; replace them with small typed adapters.
Retain every actual logical bank, geometry value and scope once at its caller.
This reduces nominal payload carried by every inert/active/retired state, owner
and host value. It does not claim that any particular7284/7807/8155-byte memcpy
or backend temporary disappears, or assign all58648bytes to these fields.

1. Embedded profile initializes five ORIGINAL typed bank objects directly in
   its already reserved interaction interval, instead of constructing one
   inline CounterStaticKeys? there. Types are original CounterStaticCandidate,
   CounterStaticHits, CounterStaticCommitted, CounterStaticCommitted,
   CounterStaticHits, each capacity2. There is no second copy/bank or new BSS.
2. Three private fixture protocol adapters each hold a typed pointer to one
   such original bank. They forward capacity/count/record/region/append/replace/
   reset exactly to that bank. Committed/hit exchangeContents exchanges the
   original pointed-to bank contents through their existing method, never
   swaps lifetime ownership or silently aliases the two physical banks.
3. CounterHostKeys is InteractionOwnedKeyState over these adapters. Its existing
   phase, limits, failure, identity-component and presentation metadata remain
   owned inline in the transferred value; only its five record banks become
   descriptors. Keep old CounterStaticKeys and native/coordinator realizations
   available. Embedded-selected host aliases use the new adapter types.
4. Inside the existing workspace.withGeometry closure, keep exactly one
   `var bulkGeometry = consume geometry` as an ordinary typed caller local.
   Borrow it with withUnsafeMutablePointer for the whole original control/
   activation/host lifetime. A CounterGeometry-conforming private proxy forwards
   every operation to that same StaticCounterGeometry value. Its references64,
   layout/render/drawing metadata and raw workspace descriptors remain there;
   the existing scopes1024/text1056/path20/plan112 bytes remain in their original
   profile slot. No raw storage contains a scoped host, owner or semantic scope.
5. A separate explicit ~Copyable/~Escapable bulk lease retains the geometry
   pointer borrow and a bank-span borrow tied to the selected profile. The
   ordinary proxy/adapters satisfy existing Copyable/Escapable generic protocol
   requirements; the lease is stored only in scoped supplied/state ownership.
   It cannot be discarded while an active or retired state retains adapters.

### Exact proposed source set; no portable or recipe change

- New RuntimeDerived/StaticCounterHostBorrowedWorkspaces.swift: three bank
  adapters, CounterGeometry proxy, scoped bulk lease, selected host aliases.
  Existing StaticCounter source glob already includes this naming family.
- RuntimeDerived/StaticCounterEmbeddedBacking.swift: initialize/deinitialize
  five original bank objects within the existing2412-byte slot; own the small
  CounterHostKeys? descriptor and expose only a profile-borrowed bank span.
- RuntimeDerived/CounterHostOwner.swift: selected CounterHostPipeline aliases;
  supplied interaction/geometry types; retain the lease through every state
  transition; extend lifetime dependencies without dropping existing ones.
- RuntimeDerived/CounterHostProbe.swift: typed geometry caller local/pointer
  scope and explicit lease construction; otherwise same owner construction,
  snapshots, rejection helper, existing factory unwrap and lifecycle helper.
- RuntimeDerived/CounterProfileStorage.swift, CounterStorageMeasurement.swift
  and CounterStorageRegions.swift: actual selected backing/descriptor accounting.

CounterPipelineOwner.swift's existing generic Geometry/Candidate/Committed/Hits
interfaces and algorithm are planned unchanged. No portable Sources, factory,
checker, image builder, compiler/flag/GOT, counter_main.c, C BSS reservation,
workload/capacity/limit or new diagnostic package change. Any further required
file or generic-interface change is UNKNOWN/outside this proposed set and must
return to review before implementation. No opportunistic wider refactor.

### Typed bank layout and physical accounting

Existing per-profile slot is30176bytes, four slots total120704BSS, aligned8.
Re-use ONLY interaction interval [24024,26436), length2412, alignment4.
Let C/H/R be exact target MemoryLayout strides of the original three bank types.
Place candidate at24024; candidateHits at24024+C; preparedCommitted at24024+C+H;
committed at24024+C+H+R; committedHits at24024+C+H+2R; end24024+C+2H+2R.
These are exact typed expressions, not invented numeric extents. Required
pre-access checks: each type alignment≤4, each cursor aligned, pairwise disjoint,
C+2H+2R≤2412; residual interval is padding charged once. The old owned-key type
contains these same five types plus state/control metadata, providing the
source-level fit rationale. Literal per-bank target strides/this re-layout's
measured extent remain UNKNOWN until independently accepted layout evidence;
no guessed value may become an unsafe load/bind or a relaxed bound.

Initialize each original bank separately with its existing capacity2 initializer
and nil slots/count0. Initialize the small owned-key descriptor with existing
maximumComponentsPerKey24/maximumComponents48 and the same state defaults.
Never initialize the old whole inline key aggregate in that interval as well.
No extra bank or allocation is reserved. At profile end, first destroy the
returned/remaining small descriptor after all borrows; deinitialize the five
typed banks in reverse order. Slot3 is reused only after original failure host
teardown and profile deinit; graph0 ends before complete0 initialization.

Geometry is one existing ordinary value relocated into an explicit caller
local, not new bank capacity. Its nominal size and any initializer/move scratch
are part of stack evidence. The proxy pointer is additional small metadata.
Audit candidate/prepared/committed identities, optional record arrays, each
original bank header, owned-key metadata, descriptors and residual padding once
under their true family. Pointer-wrapper MemoryLayout must never replace the
backing's physical byte charge. Existing Dynamic/inline ledger paths remain.
Same limits/capacities must accept the true new ledger; otherwise stop.

### Ownership, lifetimes, exclusivity and retained versus removed states

The proposed bulk lease constructor depends on BOTH borrowed geometry pointer
and copied profile-bound bank span. Supplied initializer retains all existing
model/root/semantic/Canvas/control dependencies and additionally copies the
lease lifetime. Owner init remains consuming supplied plus activationSpan.
CounterHostState inert retains supplied/lease; active retains coordinator, root
cache, activationSpan AND lease; retired retains semantic/geometry proxy/key
descriptors/activationSpan AND lease. Every consume-self switch restores that
same lease along with the original state, including rejection/failure arms.
No lease or original scope may be shortened on activation, quiesce or retirement.

The generic pipeline still owns its ordinary proxy and key metadata, borrowing
no raw scoped owner. Its model/root/semantic/Canvas/control dependencies remain
unchanged. The containing scoped host state retains the additional bulk lease.
Returned quiesced opportunity is used only inside the current state transition;
its proxy/keys are transferred to retired state while retaining the same lease.
Geometry reset and key reset occur at the same teardown step through the same
physical values. Only after repeated teardown/stopped-input checks and host
destruction does the geometry-pointer scope end; only after root/semantic/Canvas
borrows end can profile bank destruction/reuse occur.

At each source ownership transition there is one logical mutable owner of the
interaction metadata and banks. Inert negative proposals borrow/inspect them;
no mutation occurs through another retained bank adapter. Activation consumes
supplied; factory consumes owner; phase helpers take inout same owner/host.
Operations on candidate/prepared/committed banks address pairwise disjoint
objects, and exchange checks cannot accept same-pointer operands. Immutable
returned records remain value copies as today. No raw host placement, ambient
lookup, extra global lease, aliased scratch role or deinitialization shortcut.

RETAIN: supplied, owner, optional factory result, mutable host, full coordinator
state, model ticket, semantic/Canvas/root scopes, activation span, all rejection/
failure/producer/corpus/teardown state and original operation order.
REMOVE FROM TRANSFERRED AGGREGATES: repeated inline five-bank payload and
ordinary StaticCounterGeometry fields only; replace with descriptor plus lease.
Do not remove the existing factory validation or assume optional unwrap elides.

### Unchanged factory/oracle and explicit UNKNOWN semantic constraints

Existing macOS/nRF preset factory and nil/failure behavior stay exactly intact.
CounterHostOwner construction/binding validation, full assembly report and
caller identity selection stay intact. The actual counterRunHostLifecycle call
keeps its exact checker seam; escaped declaration/use and host-copy/Dynamic
negatives are unchanged. Static must still fail with ALL exact current tuple
entries: escaped lifetime diagnostic, activationBacking, root.withLifetime,
semantic.withLifetime, canvas.withLifetime, withUnsafeMutablePointer. The new
lease adds dependency; it cannot replace those established provenance sources.

UNKNOWN, semantic review required before readiness: whether existing generic
bank protocol contracts or any relevant interaction operation require an
independent mutable value copy rather than the proposed single-owner pointer
adapter. The private construction/consume/inout discipline is the proposed
proof; it must be checked against those contracts, not assumed from Copyable.
If independent copies are required, this adapter plan is NOT valid as written;
do not silently weaken semantics or implement a COW heap/supplementary bank.

UNKNOWN, language/lifetime review: exact lease storage/annotations and every
consume-self branch must keep new geometry/profile dependencies while satisfying
existing nonescapable generic constraints and inout exclusivity. Ordinary
protocol adapters cannot themselves claim to be ~Escapable if their current
protocols require Escapable; the separate lease/container is essential.
Native/Dynamic selected realization stays inline; conditional aliases/lease
plumbing must not accidentally change their types or behavior. The exact
minimal native plumbing is UNKNOWN and must be resolved by independent design
review within the named fixture set, not a compiler trial.

These are proof obligations, distinct from empirical stack fit. If semantic
review rejects the copy or lease argument, this candidate cannot be implemented
under the present design. The precise options are revise only this fixture
ownership plan with a demonstrated legal borrow, or return a concrete changed
ownership/contract choice through existing governance. No such change is
asserted necessary or approved now, and no broader compiler investigation is
automatically opened by this design.

### Later validation boundary; no allowance granted here

If independently accepted, the proposal must receive exact finite implementation
dispatch before edits/checks. Required evidence: real target typed bank layout/
alignment/accounting; unchanged native Static/Dynamic assertion counts and all
exact negatives; fresh Pi/nRF current-source receipts; supported image with
unchanged ABI/GOT/heap/RAM/flash and actual feasible nested construction/helper/
initializer/corpus/click stack including alignment/applicable IRQ overlap≤27648.
Native gates must meaningfully exercise adapter semantics as independently
reviewed; native inline-only passes alone cannot prove Embedded adapters. How
to provide that focused native parity check without altering the corpus is
UNKNOWN test-maintenance detail, not permission to weaken existing gates.

Nominal payload reduction is a source mechanism; actual layout, emitted copies,
initializer scratch and whole nested fit remain UNPROVED validation obligations.
Do not equate smaller types/locals with accepted image fit. No implementation
readiness or promised fit is claimed. This design-only section is the entire
new artifact; no standalone note, compiler/test/build/source attempt, diagnostic
renewal, new bank/BSS/heap/workload/bound or hardware/P09 action occurred.
STOP for independent disposition; P08/R07/T8.1 remain incomplete.
