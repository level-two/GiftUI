# P08 U01 retained-byte attribution 1 — 2026-10-19

Disposition: **bounded selected-callback/local-helper attribution completed;
U01 remains open for external cold metadata, numeric temporary storage and
linked implementation evidence. Complete current-callee/safety proof remains
STOP; `strict_cold_eligible` remains false.** No feasible heap event is proved
by this attribution, and no cold zero-heap or complete stack PASS is established.

This is exactly the U01-only next slice requested by the
[independent interpretation review](../current-callee-interpretation1-result/independent-review.md)
at **`b1eb9ea2330f0fd2504c5bb2d2bb94854019fe88`**. U02–U05 retain their
prior open dispositions; their broader attribution and safety work did not run.
Independent review of this new packet is next.

## Inputs, method and preservation

The [inspection record](inspection.json) verifies **67 frozen files** against
their exact baseline Git blobs: the prior review's 61 inputs/outputs, its two
independent-review files, two preparation manifests and the two relevant
dependency sources. All **42 actual-host source hashes** and the **five
preexisting dirty-file hashes** match their frozen manifests. The preexisting
Python cache files were hashed without modification or staging. The actual-host
SIL SHA-256 remains
`6cc9e7b6cecbeb46dd71b2ac8b6e023182354e7fcc08c814374b9c23303c71ed`.

Run from the repository root:

```text
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-u01-attribution1-result/inspect.py
```

The [extractor](inspect.py) uses only Python's standard library and read-only
`git show`/`git rev-parse`; it reads retained SIL, JSON indexes, existing object
symbol/disassembly text and baseline source bytes. It writes only the derived
inspection JSON and [numbered exact excerpts](retained-excerpts.txt). It never
imports repository execution code. Its repeat invocation checks the first
recorded cache hashes. No compiler, build, test, controller, decoder, demangler,
qualifier, fixture/application runtime, strict-cold route, image or connected
operation ran. No maintained source, raw receipt, collection marker, repair,
retry or allowance changed.

All SIL line numbers below refer to
[`actual-host.sil`](../current-callee-collection1-result/raw/actual-host.sil).
Object addresses and line numbers refer to the named module's retained
`-disassembly.stdout`, under the same `raw/` directory. Object addresses are
**object-relative**, not linked addresses. The excerpts preserve the raw
one-based line numbers; the inspection JSON retains complete exact symbols.

## Two actual callers and callback provenance

| Stage | Exact retained evidence | Bounded conclusion |
| --- | --- | --- |
| Ordinary Text in traversal | Specialized `SemanticExpansionTraversal.expandFixedChild` begins at SIL 598046. Its admitted `BoundedText` branch captures scalar scratch and count in `%457` at 598698, referencing the closure at 601530; ordinary ABI `%458`/`apply [nothrow] %459<()>()` are 598700–598701. | This actual consumer supplies this exact callback, with `()` result and `[on_stack]` context. The invalid-declaration branch does not call `withUTF8`. |
| Ordinary Text in Canvas payload | Specialized `CanvasSemanticPayloadCodec.primitive` begins at SIL 600887. Its `%45` callback at 600948 captures the same two kinds of scratch; `%46`/`apply [nothrow] %47<()>()` are 600950–600951. | The second actual consumer supplies the same closure symbol and no-throw result specialization. |
| Emitted traversal caller | P08 object 0xa2ab4/0xa2ab8 stores scratch/count pointers at caller `sp+0x700/+0x708`; 0xa2ac4/0xa2ac8 relocations name the **local** closure `.TA.65` at 0xb6928. Context is `sp+0x6f0` (0xa2acc), `x21=0` (0xa2ad8), then the ordinary ABI call at **0xa2adc**, raw line 200635. | `.TA.65` calls local `.TA` via relocation at 0xb6930. It is not an unresolved arbitrary callback. |
| Emitted Canvas caller | P08 0xa3e48 stores scratch/count pointers in its closure context; 0xa3e54/0xa3e58 names local `.TA` at **0xb3700**. Context is `x29-0xb0` (0xa3e5c), `x21=0` (0xa3e68), ordinary ABI call at **0xa3e6c**, raw line 202053. | This call reaches `.TA` directly. |
| Captured callback body | P08 `.TA` at 0xb3700, raw line 222471, loads captured pointers with `ldp x2,x3,[x20,#0x10]`, calls the exact shared decoder symbol at 0xb370c and returns. `.TA.65` at raw 226670 adds a 0x10-byte frame and calls this `.TA`. | The scratch/count provenance agrees with the two SIL `partial_apply` captures. |
| Decoder | SIL **601530–601687** has 20 blocks, scalar byte reads/bit operations, scalar scratch/count writes and loops; zero apply-family instructions, zero `throw` and zero heap-allocation instructions. Six `cond_fail` sites remain. Exact shared object bodies are P08 **0xa429c**, raw 202368, and GiftUISemanticCore **0x21e70**, raw 42293. | Both retained bodies have scalar decoding/checks, normal `ret` and `brk` traps, no calls, no stack adjustment and no write of `x21`. No unknown callback remains within these retained selected bodies. |

The source join is `SemanticStandardPayload.swift` **68–108**, especially
`text.withUTF8` at **78**: decode admitted, validated UTF-8 into an existing
`InlineArray<96, UInt32>` plus count. `BoundedText.swift` **107–115** supplies
bytes from its private inline storage and bounded count. These unchanged
dependency sources equal the frozen baseline blobs; actual compiled behavior
above is independently visible in the retained SIL/object captures.

The exact ordinary ABI still has zero serialized blocks: GiftUI index function
399 and GiftUISemanticCore index function 704, kind 0; SIL declaration 601691
also has no blocks. Its ordinary body is supplied by the retained GiftUI object,
not by substituting an unrelated serialized generic body.

## Ordinary ABI, generic body and module-local helpers

GiftUI **0x77c**, raw line **552**, reserves **0xf0 (240) bytes**. Registers
retain the original callback function (`x24`), callback context (`x23`), result
metadata (`x22`), result destination (`x25`) and original `BoundedText` pointer
(`x20`). The selected callers initialize `x21=0`; 0x794/0x800 preserve/restore
that incoming error state across setup.

1. **0x7a8 → GiftUI `_OUTLINED_FUNCTION_72` at 0xc904**, raw 18681:
   loads `___stack_chk_guard` and stores it at `[x29-0x38]`. It has no frame,
   allocator or indirect call. Its object-local identity matters: another
   object's helper 72 is not this function.
2. **0x7b8 → `_memcpy`**, with destination `sp+0x10`, source original storage,
   count **0x60 (96)**. The library implementation/cost is absent from these
   object captures. The bounded copy is inside the fixed 0xf0 frame.
3. **0x7bc/0x7c0** store result metadata, callback, context and original self
   in the stack capture. **0x7cc** calls the retained metadata helper for
   `_$ss5Error_pMD`; **0x7d4/0x7d8** names GiftUI thunk **0x838**;
   **0x7e8** loads external `_$ss5ErrorWS` into `x6`.
4. **0x804** calls exact generic `withUnsafeBytes` at GiftUI **0x874**, raw
   **634**. It passes the copied storage as `x0`, thunk as `x1`, stack context
   `sp+0x70` as `x2`, private storage metadata as `x3`, returned Error metadata
   as `x4`, result metadata as `x5`, ErrorWS as `x6`, outer error destination
   `sp+8` as `x7`, and the original result destination as `x8`.
5. Generic **0x8c4 `blr x9`** therefore calls the supplied GiftUI thunk
   **0x838**. The thunk reserves **0x20 (32)** bytes; **0x848** loads the
   original function/context from capture `+0x18/+0x20`; **0x84c/0x850** loads
   original self/count; **0x858 `blr x10`** calls the selected P08 callback
   above with copied byte base and original count. `UnsafeBufferPointer`'s
   element is `UInt8`; the original count is loaded as `UInt16`.
6. **0x814 → GiftUI `_OUTLINED_FUNCTION_40` at 0xc67c**, raw 18434:
   reloads `___stack_chk_guard`, compares it with saved `x8` and returns flags.
   It has no frame or further call. 0x818 branches on mismatch to external
   `___stack_chk_fail` at **0x834**. This is a stack-canary failure edge,
   not a Swift throw or error value-witness call. U03's outstanding memory
   safety proof is not replaced by assuming canary failure impossible.

## Selected error branch and value-witness targets

On normal return from either inspected callback chain, the incoming zero Swift
error state is preserved: neither P08 callback thunk nor either retained
decoder body writes `x21`. This agrees with both actual SIL `[nothrow]` calls
and the callback's absence of throwing/calling instructions. Callback traps
terminate execution; they do not return a nonzero Swift error.

Consequently, for these two selected emitted paths on normal callback return:

- GiftUI thunk **0x85c** takes its zero branch to **0x868**; the nonzero-only
  error store **0x860** and sentinel write **0x864** are not executed.
- Generic **0x8c8** takes its zero branch to **0x8e4**. The Error value-transfer
  sequence **0x8cc–0x8e0**, including indirect **0x8dc `blr x8`**, is not
  executed. The outer **0x808** likewise skips the error load at **0x80c**.

The generic's conditional target is exactly the code pointer loaded from
**`*(*(M-8)+0x20)`**, where `M` is the returned Error metadata. Its arguments
would be outer destination `x0`, aligned temporary source `x1`, and `M` in `x2`.
The captures identify this error-value transfer slot, but do not contain its
populated pointer or exact runtime code symbol. No cost of that inactive
transfer is charged to these selected normal-return bodies, and no unconditional
allocation follows from its mere existence. This conclusion does not classify
other callers or an arbitrary throwing closure.

**ErrorWS is a separate external data witness symbol.** It is loaded into `x6`,
but the retained generic body does not use `x6`. The conditional value-transfer
target comes from the metadata's value-witness table, not from ErrorWS. No
ErrorWS dispatch, retain, release or value-result witness call is present on
this selected local callback path; the `()` result needs no such observed call.
This is an emitted-body observation, not a complete runtime ABI qualification.

## Metadata cache/cold split and aligned temporary storage

The helper at GiftUI **0x8fc**, raw **670**, reserves **0x20 (32)** bytes and
loads the metadata-cache word. **0x910** tests its sign bit:

- Cache branch: **0x914–0x91c** restores registers and returns the cached word.
- Cold branch: **0x920–0x92c** reconstructs the name address/length and null
  context arguments; **0x930** calls external
  **`swift_getTypeByMangledNameInContext2`**; **0x934** writes its returned
  metadata to the cache, then rejoins the epilogue.

There is no retained proof that the first admitted Text call sees a populated
cache. The cold branch remains required for qualification; the normal callback
does not remove setup that precedes its invocation. Symbol `_$ss5Error_pMD` is
defined data (GiftUI symbols line **2070**, object address **0xf970**), while
ErrorWS and the cold runtime entry are undefined symbols at lines **59/89**.
Symbol addresses/relocations do not expose the populated runtime metadata.

The generic body always reserves **0x40 (64)** fixed bytes, then computes:

```text
M = Error metadata returned at 0x7cc, passed as x4
V = *(M - 8)                     // 0x894
S = *(V + 0x40)                  // 0x898: size slot read
D = (S + 15) & ~15               // 0x8a0 / 0x8a4
sp = prior_sp - D                // 0x8a8 / 0x8ac
```

This gives the emitted 16-byte-rounded reservation formula. It is stack space,
not an allocator call. The reservation occurs **before** callback **0x8c4**
and before error test **0x8c8**, so excluding the error transfer does not remove
it. Separately, **0x8b0/0x8b4** reads the private byte-storage size for the raw
buffer end; this does not supply `S` for Error. Neither `()` result size, the
96-byte storage nor the ErrorWS symbol supplies the missing Error size.

These captures have no populated `M`/`V` bytes or size-slot value. They establish
no numeric `S`, numeric `D` or upper bound for this metadata-dependent temporary.
No assumed existential size is substituted. The fixed frames are recorded in
the JSON, with the metadata helper in a separate earlier phase; they are not
summed into a whole-stack bound. Caller frames, external calls, cold runtime
nesting and linked selection remain necessary.

## Linked implementation boundary and concrete residuals

Exact symbol inventory across the **25 captured objects** finds two definitions
of the generic: GiftUI **0x874** and GiftUIReferenceTextResources **0xaf24**,
raw **21405**. The latter has the same fixed frame, size-rounding sequence,
callback dispatch and conditional transfer shape. The decoder likewise has
separate P08 **0xa429c** and GiftUISemanticCore **0x21e70** definitions with the
same selected scalar/no-throw behavior. These compatible retained bodies
strengthen local attribution; duplicate definitions do not select a linked
winner or exclude interposition/a different linked provider.

| Residual | Exact missing evidence | Current effect |
| --- | --- | --- |
| R01 — cold Error metadata | Actual selected runtime/library identity and body/transitive callees for `swift_getTypeByMangledNameInContext2` when resolving this Error existential, including cold initialization, allocation/ownership and nested stack behavior. No exact captured header exists for this runtime symbol. | Required cold cost/zero-heap proof remains open; no heap event has been demonstrated. |
| R02 — Error temporary bound | Same-runtime populated Error metadata/value-witness layout or an exact version-matched retained ABI definition establishing the `+0x40` size and reservation bound. If its conditional transfer is later needed for another caller, supply the exact `+0x20` target too. | The selected transfer is excluded, but the unconditional aligned stack reservation remains unbounded numerically by this packet. |
| R03 — linked identities | Exact linked artifact/dependency/symbol-binding evidence connecting these caller bodies to the retained ordinary ABI, generic and decoder definitions, and the actual ErrorWS/metadata provider. | Object-relative definitions do not constitute linked/cold-runtime qualification. |
| R04 — external byte copy/canary leaves | Exact selected library implementation/cost for `_memcpy`; stack-guard data and canary failure target disposition under the adopted safety proof. | A complete selected call/cost/safety result cannot be claimed from local prologues alone. |

## Next bounded handoff and unchanged gates

First independently review this U01 attribution against the baseline and exact
excerpts, especially callback capture offsets, no-throw/error feasibility,
module-local helper joins and the missing metadata bound. Then prepare **one
separate U01 runtime/linked evidence request**, scoped to R01–R04: inventory
whether an already frozen exact linked artifact and matching runtime/library
bytes exist; identify exact hashes, target/loader/version applicability and
which static data/body/binding records could answer each row. Preparation must
state any genuinely unavailable inputs and any proposed acquisition/inspection
commands, budgets, review and stop conditions before execution. This result
does not execute or authorize that acquisition or a new decoder/runtime route.
U02 Static-feasibility attribution and U03 original origin/return/retirement
joins remain separately bounded subsequent work, not an automatic expansion
of this slice.

No actual contract/scope choice arose here. If cold evidence subsequently
requires a warm-up exception, heap/ownership/privacy/bound relaxation or scope
change, stop that choice and route the concrete decision upstream for the
maintainer-requested Astra Medium decision. This packet makes none of those
changes and does not claim the current contract impossible.

[Accepted ADR-039](../../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md),
[accepted ADR-040](../../../../../../../docs/adrs/adr-040-counter-physical-sram-budget.md),
[implementing SPEC-015 S15.1/S15.2](../../../../../../../docs/specs/spec-015-host-configuration.md)
and the active SO plan remain authoritative. ADR-040's finite-counter SRAM
exception remains applicable; no historical 27,648-byte ceiling is reinstated.
This is ITERATION-003's necessary finite-counter dependency for analyzer and
constrained stack validation, traceable to the closed ITERATION-001 reference
application; it adds no MVP work. Full RFC-015 delivery remains ITERATION-004
I4-07. No optional deferred item was discovered; R01–R04 remain current proof
gaps, not deferred requirements.

Collection **1/1 consumed**, repairs **0**, retries **0**, and marker
**[16777234, 29640436]** remain unchanged. Required complete callee **and**
safety PASS must precede preparation of a new current strict-cold manifest for
the existing `native-cold-static-candidate/run.py --prepared` route. Its exact
host-first baseline, silent/observed/ordinary windows, workload/baseline counts
and zero-heap enforcement remain binding. **P08/R07/T8.1, remaining SO criteria,
strict-cold/zero-heap, four-profile, ABI/resources, independent exit and later
conformance gates stay open.**
