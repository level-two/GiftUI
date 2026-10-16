# P08 frozen-artifact resource worksheet — 2026-10-16

**Result: final firmware fit is unknown. Obtain the normal current firmware
artifact before another source optimization or stack-budget proposal.** The
contract-object rejection remains valid for its exact object and flags; it does
not establish the stack of the separately recompiled firmware. No source,
compiler, build, link, target execution or hardware operation occurred here.
All historical repair allowances remain closed; P08/SO acceptance remains open.

## Artifact scope and stopping conditions

Source is `51cfc960`, SOURCE review `ee10d2f1`; reviewed starting assessment is
`103c653a`. Object `.build/nrf52840/contracts/p08-counter-9sc79u_m/P08CounterRuntime.o`
has SHA256 `e1ff7e1457e18857f4f562731fe12b10d50f84ed54062270846a8cf9f4056062`.
Its receipt is focused-passed, collection_complete=false/passed=false. There are
23 local objects plus one reused portable `GiftUI.o` in its 24-object list.
There is no current linked firmware ELF/map for this source/recipe.

Bound: inspect at most 100 named function sections, their complete bodies and
direct relocation identities; follow actual Embedded source phases rather than
every generic alternative. Stop at unresolved indirect targets, register-derived
SP changes, missing cross-image helpers/IRQ evidence or differing final codegen.
A broad generic callback expansion identified 274 sections before disassembly
and was stopped. The bounded selection inspected 80 sections, retaining 18,063
instructions and 15 indirect sites. This is **not complete callee/CFG closure**.
The existing entry-frame extractor is explicitly a lower-bound parser; it does
not become an upper-bound analyzer by inspecting complete bodies.

[Inspection manifest](resource-worksheet/manifest.json) pins the 322,396-byte
[packet](resource-worksheet/frozen-object-inspection.tar.xz), SHA256
`dfe0445e8d84a439151e43a11b357f7bbeef4fd86d4c3cea0f79b80af4099fff`.
It contains reproducible extraction, section/symbol-table identities, complete
selected disassembly, every selected SP write/indirect instruction, recipe
comparison and the image-handoff source finding. Earlier immutable result and
review packets are unchanged.

## Applicability correction: contract object versus firmware

The [normal image handoff](../../../../../../scripts/contracts/build-spec-015-counter-image.py)
verifies the collection objects but **does not link them into nRF firmware**.
It reconstructs source lists for 24 owners, including GiftUI; `Counter.cmake`
recompiles all of them with firmware-specific flags and lower-owner imports.

| Common inputs | Material differences |
| --- | --- |
| Pinned Swift 6.4, Embedded/LifetimeDependence/Lifetimes, `-Osize`, whole-module compilation, package giftui, testing, function sections, disabled stack protector, tiled counter, same selected 42 counter source files | Firmware adds `GIFTUI_NRF_EMBEDDED`, `GIFTUI_REFERENCE_BITMAP_ONLY`, `-Xcc -fshort-enums/-fno-pic/-fno-pie`, picolibc includes, Zephyr toolchain C flags and interface defines; module visibility/cache/build graph also differs. |

Those defines are active source distinctions: `RasterStrokeCoverage.swift`
lines 21/48/114 select nRF behavior; `GiftUIReferenceTextResources.swift` lines
84/119/150 select bitmap-only realization. They are absent from the frozen
contract object's target flags. Equal target ABI, counter source and optimization
level therefore do not prove equal imported bodies, specialization, frames or
linked reachability. No current firmware compile-command/object equivalence
record closes that gap. The existing 28,288-byte witness rejects the frozen
contract object against 27,648; **neither final-firmware fit nor final-firmware
failure follows from it alone**. Preserve the STOP as that package's evidence
boundary, not a reason to indefinitely withhold the missing normal image.

## Source-feasible phase account and exact remaining graph gaps

The current object uses section/symbol identities, not objdump's nearest label.
The successful C entry thunk 9972 tail-branches to 9976; 9976 pushes 8 bytes at
+8 and BLs corpus 4340 at +12. Route wrapper 9980 is an alternative tail wrapper,
not another enclosing frame. Corpus 4340 reserves 64; host corpus 4332 reserves
64; custody 4246 reserves 112 and calls case dispatcher 4250 at +388. Dispatcher
reserves 64 through its two-host BL +188→4269; its other leaf tail branches
restore that frame first. Custody preparation and destruction are sequential
around the selected operation, not additional simultaneous preparation frames.

| Feasible phase | Concrete current-object path and accounting disposition |
| --- | --- |
| Physical construction / fault prefixes | Custody 4246→prepare 4184, then case 4250→graph 4265 / fault 4261 / invalid 4257 or selected host. Owner/control constructors and prefix destruction are separate maxima. `p08InitializeOuterControl` 3882 has 6,936 entry bytes; prepare 4184 has 56. Their complete descendants are not closed. |
| Required host cold construction | Two-host 4269→one-host 4281→prepared 4029→model lender 210→4037→semantic lender 10411→4044→owner.withStorage 3433→original bank loans→4048→session 3994→constructor 3983→factory 3990. The archived 28,288 witness includes only selected reservations; actual entry/custody, callback forwarders and further original loans add real costs. Cold helper 4316, plan installer 4301 and join checker have returned before factory; later live/reuse phases are not summed here. |
| Live / current action / stale rejection | Session 3994 calls host phase 3967 at +474 after constructor returns. Phase→reuse 3863→stale helper 3823 or current helpers 3831/3847/3851/3855, sequentially. Stale helper separately captures baseline, runs sensitivity 3740→matches 3728→matchesAdmission 3716, then checks old origins. Entry reservations are respectively 5,960 / 1,528 / 560 / 1,816 / 16 / 2,328 / 2,512; these are not a complete path bound. Current action/operator descendants, pipeline phases and backend callbacks remain open. |
| Activation, candidate failure, refusal and ordinary lifecycle | Phase 3967 branches to `counterRunHostLifecycle` 3971 (2,296 entry bytes), activation or candidate-failure operations under the same original scope. Refusal and success are alternatives, never simultaneous sums. The complete runtime/render/endpoint and writer descendants are not closed. |
| Logical teardown / metadata cleanup | Session defer invokes original-host teardown before access scopes end; afterward bank loans unwind, custody invokes destroyMetadata 4216 and releases donor objects in reverse. Inert early 1/2/3, active cleanup, constructor failure, namespace trap and metadata-prefix failure have distinct maxima. Factory destructors 12002/12008/12014 are leaf `bx lr` bodies in this object; that does not close the rest of teardown. |
| Exchange corpus | Scoped corpus 4336→custody→exchange 4273 (18,304 entry bytes)→withStorage 3433. It retains its own observations and role transcript; it is a separate required phase, not part of the host cold sum. Its deeper typed-loan/role/exercise/cleanup graph is unclosed. |

The first four original byte loans have exact current targets: 3433 REL32+1056
installs 11852; 3437 REL32+308 installs 11856; 3441 REL32+292 installs 11860;
3445 REL32+300 installs 11864. The repeated byte lender 3176 reserves 32, invokes
BLX r4 at +106 and restores only afterward. Forwarders 11852/11856/11860/11864
reserve 552/536/520/496 and BL bodies 3437/3441/3445/3449 at
+576/+554/+534/+506; these are nested original loans, not alternatives.

Model lender 210's BLX r0+200 uses the callback installed by 4029 REL32+588:
12084→12088→4037, with 24/224 entry bytes and actual BL12088+244 (the preserved
prior erratum). Semantic callback 12375 is installed by 4037 REL32+540 and calls
4044 at +174; scoped callback 12379 is installed by 4044 REL32+308 and calls
4048 at +188. Both reserve 176. These identities do not resolve every internal
branch of semantic lender 10411, whose BLX r3 sites +836/+1006 remain to classify.

The remaining g0/g1/g2/g3/g4/c0/h0/r0/r1/h1 source loans must all remain open
through the consuming body. Their specialized bodies contain alternative native,
padded and Embedded paths. Sections 3449/3453/3457/3461 round SP down with BFC;
3457/3461 additionally assign register-derived SP repeatedly and allocate 120-byte
outgoing areas. A single prologue count cannot bound them. Unclosed indirects are
3457+8992, 3461+3372, 3465+1318/+2388, 3469+758 and 3473+278. Session constructor
3421 has five BLX r5 sites +380/+456/+542/+624/+706 requiring concrete value-witness
target resolution; it returns before the host body and must not be added as an
enclosing live frame. Selected undefined helpers are `__aeabi_memcpy{,4,8}`,
`__aeabi_memmove{4,8}` and `__aeabi_memclr4`; final library selection/veneers and
their stack paths require the actual linked recipe. No missing edge is zero.

## RAM, IRQ and allocation worksheet

Current reserved backing is 138,880, including the donor's 16,584 metadata bytes;
do not add donor metadata again. The source custody proves sequential case
execution, one ordinary active slot plus donor, or two active slots plus donor
for unequal exchange; complete typed capacity and adversarial co-residency remain
required. This is not a proof that changing the four-slot reservation is sufficient
or that its current stride maps unchanged to fresh firmware.

Historical image evidence alone reports RAM 159,744, backing 128,000, flash
396,660, main stack 27,648, ISR stack 2,048, MPU stack guard, hard-float/FPU enabled,
no multithreading and disabled heaps. These are historical configurations, not a
current image. Do not add the backing delta to derive current whole RAM or assume
current IRQ behavior. Required current evidence is RAM-mapped PT_LOAD totals and
section/owner inventories (including stack reservations), final map/config, main
and IRQ feasible paths, exception entry/return and FPU/nesting behavior. Check
main-stack bound separately; do not double-count its reservation in PT_LOAD RAM.
Rooted final linked allocator reachability, including indirect targets, is needed
for Static zero heap. Eighty selected functions and disabled heap configuration
do not prove it. No safe numerical replacement stack size can be proposed yet.

## Concrete next measurement, preserving normal guards

The image helper requires `collection_complete=true`, `passed=true`, every check
passed and exact current input/artifact/compiler hashes. The current focused
receipt cannot qualify. Full current nRF collection is now a prerequisite for
**final-codegen resource measurement**, not a claimed acceptance rerun on a
known-failing final image. No partial-receipt or diagnostic scratch-link bypass.

One narrow tooling correction must precede it: the helper imports `ALL_SYMBOLS`
but line 117 evaluates `layout_symbols=list(SYMBOLS)`, with no such binding.
Source/AST evidence is in the packet; the handoff was not executed. Use the
complete imported `ALL_SYMBOLS` registry (129 layout +31 metadata =160) for that
record. Preserve every current receipt/hash check, CMake roots and strict decoder.
Review this tooling-only fix; run existing `test_p08_layout*.py` regressions and
the guarded nRF handoff against the ensuing complete receipt, requiring the same
160 roots in handoff/facts/final image. A focused receipt must still be rejected.

Then run sequentially, retaining exact output paths and receipts:

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded --host-build .build/contracts/p08-scoped-host-hzs5q7za --collect-failures
scripts/nrf52840/doctor.sh
scripts/nrf52840/build.sh --application signal-analyzer-static --counter-build <new-complete-counter-build>
```

The first command must complete all 227 registered checks (25 focused passes plus
202 prior omissions), with current compiler/dependency/source qualifications.
Do not resume from or promote the focused receipt. Existing prerequisite receipt
paths are candidates subject to the driver's hash checks, not silently freshened
inputs. Preserve prior image evidence before the normal pristine build replaces
its output directory. Any new compiler or guard failure is frozen and reviewed;
this worksheet authorizes no repair loop. No deploy, flashing or target run.

Read the emitted current ELF/map/config/compile commands and actual firmware
objects. Reconcile exact flags, full 160-root layout, linked RAM/flash/ABI and
allocator roots; derive feasible phase/callback/SP/IRQ bounds from those objects.
If a complete bound still cannot be obtained, report the exact unresolved target
or measurement requirement. Only then choose a compatible concrete source remedy
or prepare a measured resource amendment for the maintainer. This is the smallest
next artifact package that can change the decision; further contract-object
helper tuning would precede the required evidence.
