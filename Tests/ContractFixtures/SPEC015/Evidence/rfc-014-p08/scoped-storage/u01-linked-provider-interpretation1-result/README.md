# P08 U01 linked/provider interpretation 1 — 2026-10-19

Disposition: **selected linked Text bodies/branches and system install-name
bindings resolved; external implementation/cold-cost/numeric-size proof remains
STOP.** Static records bind the Error runtime entry/ErrorWS to
**`/usr/lib/swift/libswiftCore.dylib`**, and memcpy/canary leaves to
**`/usr/lib/libSystem.B.dylib`**. They do **not** select the pinned toolchain
core. **B remains inapplicable and unexecuted; `strict_cold_eligible=false`.**

This completes exactly the U01-only retained-byte handoff in the
[independent A-only result review](../u01-residual-static1-a-only-result1/independent-review.md)
at **`a298d71c526423d2376c416d2ad896b66c127a20`**. It preserves that archive's
capture-only PASS and STOP. Independent review of this interpretation is next.
No U02–U05 investigation, new evidence acquisition or contract/scope choice occurred.

## Method and frozen identities

[inspection.json](inspection.json) and the [numbered exact excerpts](retained-excerpts.txt)
are derived by [inspect.py](inspect.py), using only standard-library text/JSON/hex,
hashes and read-only Git. Run from the repository root:

```text
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/u01-linked-provider-interpretation1-result/inspect.py
```

All **32 archived files** equal their baseline Git blobs; all **28 source-packet
members** match manifest byte counts/hashes. All **180** frozen direct context
files, including the **42 source hashes**, five preexisting dirty files and
preexisting cache hashes/membership, remain intact. No decoder, controller,
compiler, build, test, runtime, acquisition, qualifier, demangler, image,
connected action or source repair ran. No captured output or marker changed.

The actual ordinary counter still has **6,602,168 bytes**, SHA-256
`12d51381b0a776a3a05c60aa3f97b732a0490434435194d6eda0e29ef0d89242`.
Its frozen receipt SHA-256 is
`6850a3f150938e2a755f2260c94c42d7f103b0110639599a27925ba377b8ecb8`;
link command **405** and historical invocation **406** are zero based.
All **25** link objects still equal the original collection's object-capture
set and hashes. These retained executable bytes, rather than an unrelated
probe or candidate image, supply the linked observations below.

All line numbers below refer to the three archived A `.stdout` files in
[`u01-residual-static1-a-only-result1`](../u01-residual-static1-a-only-result1/README.md).
Addresses are the image's **preferred unslid virtual addresses**, not observed
process addresses. The image is ARM64, EXECUTE, TWOLEVEL and PIE. Its UUID is
**`3DEE5FE5-1F72-3C9A-8A36-4F30A2CE9ADF`**, metadata lines **472–474**.
LC_BUILD_VERSION reports MACOS/minos **26.0**, SDK **26.0** and linker
**1267.0** (476–484). The retained compiler argv separately names the
MacOSX26.5 SDK path; neither fact supplies a runtime version/UUID.

## Exact loader/import/fixup interpretation

The complete **22 load commands** have **no `LC_RPATH`**. The five dependency
ordinals, in load order, are:

| Ordinal / load command | Install name | Kind |
| --- | --- | --- |
| 1 / 14, line 493 | `/usr/lib/libSystem.B.dylib` | Strong |
| 2 / 15, line 500 | `/usr/lib/libobjc.A.dylib` | Strong |
| 3 / 16, line 507 | `/usr/lib/swift/libswiftCore.dylib` | Strong |
| 4 / 17, line 514 | `/usr/lib/swift/libswift_Builtin_float.dylib` | Weak |
| 5 / 18, line 521 | `/usr/lib/swift/libswift_DarwinFoundation2.dylib` | Strong |

LC_LOAD_DYLINKER names `/usr/lib/dyld`. All selected imports below are strong
(`weak_import=0`) in the captured chained-import records. Their two-level
ordinal joins, indirect-symbol entries and GOT fixups agree:

| Selected symbol | Chained import / ordinal | GOT fixup | Code stub |
| --- | --- | --- | --- |
| `_swift_getTypeByMangledNameInContext2` | **125 / 3**, metadata 12593–12596 | **0x10025c928**, bind line 1266 | **0x1001d8794**, indirect entry 642 |
| `_$ss5ErrorWS` | **68 / 3**, 12365–12368 | **0x10025c760**, bind 1209 | Data witness; no call stub asserted |
| `_memcpy` | **8 / 1**, 12125–12128 | **0x10025c580**, bind 1149 | **0x1001d85f0**, entry 607 |
| `___stack_chk_guard` | **2 / 1**, 12101–12104 | **0x10025c550**, bind 1143 | Data guard; no call stub asserted |
| `___stack_chk_fail` | **1 / 1**, 12097–12100 | **0x10025c548**, bind 1142 | **0x1001d859c**, entry 600 |

The archived historical ordinary invocation has no DYLD/Malloc/Swift override;
the frozen collector inherits that sanitized environment. The decoder's separate
LLVM `DYLD_LIBRARY_PATH` affects only A's inspection tools. There is no captured
counter rpath, import ordinal or historical override directing these imports to
the pinned development toolchain core. Its matching Swift version and frozen
payload bytes therefore cannot qualify the selected system import.

This resolves **static install-name selection**, not the historical loaded
system image UUID, cache identity, reexport implementation or interposition
behavior. The relevant system standalone paths were absent in the authenticated
inventory; the current cache map names those images but contains no selected
implementation bytes or historical loaded-image proof. No system cache was
decoded, copied or extracted here.

ErrorWS remains a data witness passed in x6 and unused by the selected retained
generic. Its system binding is not a value-witness call: the inactive error
transfer target still comes from the populated metadata's separate table slot.

## Actual linked Text chain

| Link | Exact retained evidence |
| --- | --- |
| Traversal caller | SIL 598700–598701's original P08 object call 0xa2adc joins linked **0x1001b87d4**, body line **470389**. Its callback address is formed by `0x1001cc000+0x2b0`; context is `sp+0x6f0`, error state `x21=0`. |
| Canvas caller | SIL 600950–600951's P08 0xa3e6c joins linked **0x1001b9b64**, body **471646**. Its callback address is `0x1001c9000+0xcc`; context is `x29-0xb0`, `x21=0`. |
| Ordinary ABI | Both direct calls reach **0x100001648**, body **619**, exact `BoundedText.withUTF8` symbol. Fixed frame 0xf0; 96-byte copy at **0x100001684** goes to the memcpy stub above. Metadata cell address is `0x10028c000+0x200`; **0x100001698** calls helper **0x100000e5c**. |
| ABI thunk/generic | The ABI forms thunk **0x100001704** in `x1`, then **0x1000016d0** calls the single linked generic **0x100001740**, body **683**. Generic **0x100001790 `blr x9`** invokes that thunk; thunk **0x100001724 `blr x10`** invokes the originally captured callback. |
| Traversal local thunk | **0x1001cc2b0** (`.TA.65`), body **491268**, calls **0x1001c90cc** at 0x1001cc2b8. |
| Canvas/local callback thunk | Both paths use P08's **0x1001c90cc** (`.TA`), body **487891**; it loads capture pointers with `ldp x2,x3,[x20,#0x10]`, then calls the canonical decoder **0x100106574** at **0x1001c90d8**. |
| Canonical decoder | **0x100106574**, body **282984**, is the exact shared SIL 601530 symbol. It has **48 instructions**, scalar decoding/stores/checks, normal `ret` and terminating `brk`; no calls, stack reference or x21/w21 reference. |
| Separate same-named thunk | **0x100106634**, body **283033**, is another local `.TA` with the identical name. It also calls decoder 0x100106574, but is **not** the callback pointer captured by either selected P08 caller. |
| Local outlined helpers | ABI **0x100001674** calls GiftUI's guard-save helper **0x10000d790**, body **14154**; **0x1000016e0** calls guard-compare helper **0x10000d508**, body **13960**. Both load guard GOT **0x10025c550**; mismatch reaches fail stub via **0x100001700**. Other modules' same-numbered helpers are not substituted. |

Duplicate local names make symbolic branch rendering alone ambiguous. The
inspection uses **only the already archived `--full-contents` hex** to read the
selected 32-bit little-endian BL words and compute
`target = instruction_address + sign_extend(imm26)*4`. The opcode is checked as
BL; raw word, signed immediate, target and original hex/text line numbers are
recorded for every selected join. This is finite arithmetic on retained bytes,
not a decoder invocation or new disassembly collection. For example,
0x1001cc2b8's word **0x97fff385** resolves to **0x1001c90cc**, while
0x1001c90d8's **0x97fcf527** resolves to **0x100106574**.

Address-normalized retained instruction comparison shows the canonical decoder
matches **GiftUISemanticCore object 0x21e70** (its loop uses `x8`) and differs
from **P08 object 0xa429c** (`x9`). Both had the same semantic symbol; the linked
body is now concrete. The generic 0x100001740 matches both retained generic
definitions (GiftUI 0x874 and ReferenceTextResources 0xaf24). There is no retained
link map establishing which indistinguishable generic object copy won; its
actual linked address/body and call target are nevertheless resolved. No
object-origin claim is inferred solely from link order or duplicate names.

## Selected error feasibility and remaining numeric bound

The actual selected linked thunks and canonical decoder preserve incoming zero
x21 on normal return. This retains the independently reviewed no-throw result:
thunk **0x100001728** and generic **0x100001794** take their zero branches;
the generic's conditional value-transfer **0x1000017a8 `blr x8`** is not executed
on that normal-return chain. Traps terminate execution and do not return a Swift
error. Trap/canary infeasibility and complete safety are not proved here.

Unconditional Error metadata setup remains. Helper **0x100000e5c**, body **97**,
tests the cache word's sign bit, returns a cached pointer on its fast branch,
or calls the selected system Swift stub at **0x100000e90**, then stores the
returned pointer. The linked generic still reads
**`S=*(*(M-8)+0x40)`** at **0x100001760/764** and reserves
**`D=(S+15)&~15`** at **0x10000176c–778**, before dispatch or the error test.

The single linked `_$ss5Error_pMD` cache cell is **0x10028c200** (symbols line
**34452**). Captured file bytes at body **671167** give
**`0xfffffff9fff68a50`**, sign bit 1: the helper's cold-form descriptor.
Its signed low 32 bits are **-619,952**, pointing to **0x1001f4c50**;
its signed high 32 bits are **-7**, giving a **seven-byte symbolic mangled name**
`02df7a06005f70` (body **634250**). This is name encoding, **not a seven-byte
Error value, populated metadata pointer, size-slot value or stack bound**.
The file image does not observe whether prior runtime work warms this shared
cache before the selected Text call. The required uncached runtime path remains
unqualified; selected no-throw behavior does not erase it.

## R01–R04 disposition and next bounded handoff

| Residual | Resolved here | Still required |
| --- | --- | --- |
| **R01 — OPEN** | Exact linked cold-call stub/GOT/import ordinal and absolute system Swift install name. | Applicable system Swift implementation bytes/UUID/cache identity and feasible cold metadata/transitive allocator/ownership/stack evidence. No heap event or cold zero-heap PASS is established. |
| **R02 — OPEN** | Exact linked unconditional reservation formula and cold-form mangled-name cache descriptor; selected conditional error transfer excluded. | Applicable populated metadata or exact version-matched runtime layout/constructor proof for numeric S/D. The file cache descriptor does not supply it. |
| **R03 — PARTIAL RESOLVED** | Selected local linked definitions, duplicate-thunk addresses, direct call targets, complete load/rpath records and static system provider ordinals. Pinned toolchain core is not selected. | Historical actual loaded system image/cache identity and matching implementation bytes. The current map/version and toolchain payload do not close this gap. |
| **R04 — OPEN COST** | memcpy/fail stub addresses, guard GOT and ordinal-1 libSystem bindings; selected local guard helpers understood. | Exact libSystem reexport/dispatch/resolver implementation, selected memcpy costs, guard/failure disposition and complete adopted safety proof. Names/stubs alone do not supply them. |

First independently review this interpretation, especially duplicate-name branch
arithmetic, exact absolute provider bindings and cache/name-size distinction.
Then prepare **one separately bounded system-provider evidence request** for
the selected `/usr/lib/swift/libswiftCore.dylib` and libSystem/C leaves: identify
applicable historical image/cache UUID/build evidence, exact existing bytes or
the genuinely missing inputs, and proposed commands/acquisition limits, raw
receipts, independent review and stop conditions **before execution**. Current
cache ranges are leads for preparation only. No cache extraction, runtime probe,
B retargeting, new decoder/controller or acquisition is prepared/executed by
this result. The existing B toolchain-core commands cannot be released by this
system install-name result. U02–U05 remain separately bounded open work.

No actual contract/scope decision arose; any proposed warm-up, heap/ownership/
privacy/bound/scope relaxation goes upstream for the requested Astra Medium
decision. [Accepted ADR-039](../../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md),
[ADR-040](../../../../../../../docs/adrs/adr-040-counter-physical-sram-budget.md)
and [implementing SPEC-015 S15.1/S15.2](../../../../../../../docs/specs/spec-015-host-configuration.md)
remain authoritative, including ADR-040's finite-counter SRAM exception. This is active
ITERATION-003's necessary counter dependency for analyzer/constrained-stack
validation; closed ITERATION-001 gains no work. Full RFC-015 remains ITERATION-004
I4-07; these current proof dependencies are not deferred requirements.

Both permanent attempts remain **1/1 consumed**, repairs **0**, retries **0**:
original collection marker **[16777234,29640436]**, A-only marker
**[16777234,29650609]**. Neither identity changed. Complete callee **and** safety
PASS still precede a current strict-cold manifest with its existing host-first
baseline, silent/observed/ordinary windows, workload/baseline counts and zero-heap
enforcement. **P08/R07/T8.1, remaining SO, strict-cold/zero-heap, four-profile,
ABI/resources, independent exit and later conformance gates remain open.**
