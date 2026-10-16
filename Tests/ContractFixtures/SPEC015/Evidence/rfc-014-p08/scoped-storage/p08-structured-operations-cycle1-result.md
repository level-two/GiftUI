# P08 structured operations correction1 result and final correction proposal

Current result: **all three focused collections PASS; main-stack rejection remains**.
Source `b8a9626a`, independent SOURCE review `3a346b91`; the passing checkpoint is
`449c9712`. The [independent result/approach review](p08-structured-operations-cycle1-independent-result-review.md)
confirms main-stack FAIL and final correction2 APPROACH PASS at `955daa9b`.
Correction1/2 is productive; correction2 is ready for its authorized source pass, not frozen here.
Historical allowances remain closed. No new compiler/runtime/image execution was
performed by this analysis. No contract, source, limit or resource waiver changed.

## Current execution and measurement

The [receipt manifest](structured-operations-cycle1-collections/result.json)
pins exact commands, inputs, compiler and logs in its verified compressed archive.
Its SHA256 is `64a84a7c717ed44e9b34c87e4f74bf470279f17525868ddeb8f92940656a631f`;
archive SHA256 is `3bdeaf91f30135af9df25f55dfea039cdb084ce0404b6f9a87da7c98849a0eb3`.

| Collection | Passed | Omitted | Native assertions/failures |
|---|---:|---:|---:|
| nRF52840 Embedded | 25 | 202 | not executed |
| macOS Dynamic | 42 | 384 | 1,736,244 / 0 |
| macOS Static | 42 | 384 | 1,736,320 / 0 |

Each Native collection includes all13 reuse labels,5 exclusivity and2 projection
controls. All receipts are fresh-focused, focused-passed, collection-incomplete
and aggregate-passed=false. Neither omitted compiler controls nor image fit is
claimed. nRF strict160 roots independently retain active cursor34713/alignment8,
34720×4=138880 backing, metadata15760 and donor tail18960. No retained extent grew.

## Current object rejection proof

Object `.build/nrf52840/contracts/p08-counter-jwt7w60j/P08CounterRuntime.o`, SHA256
`8a230085aee82575696182f93ecc8f540ee9bcf21ffab2e094f640b318e7a61b`.
The [analysis manifest](structured-operations-cycle1-analysis-manifest.json) pins
all selected prologues, symbol-table/index-resolved relocations, exact extraction
commands/scripts and selected full bodies in
[the compressed packet](structured-operations-cycle1-analysis.tar.xz), SHA256
`0fcfef40ed21dc991573a77db9db1fb33ea57184748cda1595bfcf75e00f7dd3`.
`required-path.json` inside it identifies every symbol and stack instruction.
Entry arithmetic includes push/stmdb/preindexed str and sub/sub.w/**subw**.
These are fixed entry lower bounds, not whole-program upper bounds.

The required reuse/sensitivity path has these simultaneously retained frames:

| Original operation (ELF section index) | Bytes |
|---|---:|
| two-host operation4273 → one-host4304 | 4632 + 4064 |
| original model lender210 → root body4041 | 520 + 1104 |
| original semantic lender10391 → body4048 → scoped body4052 | 520 + 1056 + 336 |
| original owner.withStorage3441 → live session4002 → host3979 | 3056 + 3824 + 1528 |
| reuse3875 → stale origins3835 → sensitivity3752 | 560 + 1816 + 16 |
| full fingerprint3740 → runtime field3704 → slot baseline3708 | 2328 + 8 + 2920 |
| endpoint suffix7461 → actual recording match6781 | 656 + 200 |
| **Selected live lower bound** | **29144** |

This is1496 above main27648 **before** outer factory/corpus/custody/dispatch,
callback thunks, remaining original bank-loan callback frames, deeper equality
callees, alignment and IRQ. Omitted frames are additional, never assumed zero.
No alternative Native/Embedded callback bodies are summed. Source invokes these
checks during a live required host; comparison-success paths reach each next
guard. Call relocations identify actual functions, not name-only matches.

In particular owner.withStorage3441 calls the original b0.withBorrow3176 at
offset0x112. Its continuation requires empty storage and restores lifecycle idle;
the source body returns only after all nested original typed loans end. It is not
a tail-eliminated ancestor. Two-host4273 calls outlined15743, whose8-offset tail
edge enters one-host4304 without removing4273. The two-host continuation performs
inventory/retirement/reconstruction/release operations. These source continuations
and BL/tail edges are preserved in full selected disassemblies. The semantic
lender10391 is32 saved bytes +488 local bytes, independently checked from its raw
prologue. The source callback chain is the same model→semantic→canvas→storage
chain; no foreign-root alternative is substituted.

| Changed observation/caller | Initial | Correction1 |
|---|---:|---:|
| one-host frame | 8336 | 4064 |
| reuse frame | 2688 | 560 |
| stale-origin frame | 6072 | 1816 |
| reconstruct view frame | 15088 | 24 |
| selected live path excluding owner.withStorage | 36744 | 26088 |

The prior selected path omitted owner.withStorage; adding its actual3056 yields
29144. The source guard changes reduced demonstrated homes. Runtime-slot2920 did
**not** shrink after actual-target-health separation; no unproved claim that it
copies an entire backend or Control is made.

Cold construction has a separate source-feasible **30880** subset: sections4273,
4304,210,4041,10391,4048,4052,3441,4002,3987,3998. This includes the constructor8408
and factory3360, excludes the subsequent live host (construction returns first),
and still omits surrounding callbacks/ancestors. The earlier27824 figure excluded
withStorage3056; it is not the complete bound. Reconstruction has22688 in
4273→4308→3918→3894→3501, before other ancestors: original Control constructor10120
and its6936 caller do not overlap a live host. No total-RAM impossibility or fit
upper bound follows from these selected subsets. Full202/image remains held.

## Proposed final grouped correction2 — source review before execution

This is a concrete final within-contract candidate, **not** an applied source
change or guarantee of compiler fit. Target two fixtures:
`RuntimeDerived/CounterScopedStorage.swift` and `CounterPipelineOwner.swift`, plus
their existing tests, immutable qualification/driver pins and freeze. No core type,
protocol, lifetime contract, owner inventory, donor layout or resource limit changes.

1. **Finish two-host cleanup after live execution in a concrete cold operation.**
   Move the entire post-second-host empty→same14-entry inventory→retired→end
   retained observations→release→hosts2→destruction verification→three labels
   sequence out of `p08RunMetadataTwoHosts` into a finite helper taking the actual
   `inout P08TypedBackingOwner`, actual `inout InlineArray<14,P08InitializedEntry?>`,
   and original outer/control/transcript facts. Return only owned check counts.
   The first-host checks, reconstruction and second-host order remain unchanged.
   No owner value is copied. Cold cleanup and destructor frames remain charged
   after host calls, but their aggregate homes need not be coallocated in the
  4632-byte live parent. Require their full cold path to fit too.

2. **Separate session construction from the live fourteen-loan callback extent.**
   In `P08TypedBackingOwner.withStorage`, retain all original14 Static/9 Dynamic
   typed loan nesting, original address predicates and entry lookup/capacity/role
   order. Create the existing `P08SessionLifetime.lend(owner:self,…)` in the same
   innermost callback. Call a concrete cold Static/Dynamic construction helper,
   then directly invoke the existing body with its returned session *inside that
   callback*. Its signature is `@_lifetime(copy token)` returning the existing
   `P08StorageSession`, taking `borrowing P08SessionLifetime`, the original typed
   field pointers/buffers, five original initialized-entry facts, capacities,
   transcript and owned identity/serial. Explicit argument types are the existing
   descriptor field types, not a new erased container or arbitrary callback.
   It creates the same geometry and five access lenders, InteractionState and
   P08ScopedKeys and returns the same session using existing lifetime-copy
   constructors. No capability outlives the original owner or any original field
   loan; no mutable whole-owner loan is added across reentry. All fourteen loans
   remain open during `body`; requireEmpty/lifecycle-idle stays after they end.
   The helper's construction frame returns before the active host call. A caller
   return buffer/session home can still exist and must be measured, not assumed
   elided. Source review must validate the exact union of original token/field
   lifetimes. If unavailable under existing types, report the exact constraint;
   no raw span, copy-array, unsafe lifetime or unchecked conformance fallback.
   Current emitted withStorage variant callback homes include2784/3152/4400/2712/
  2136 bytes. Their alternatives are **not** added to the bound, but prove why
   fixing only a1496-byte subset deficit cannot establish the complete path.

3. **End full backend/key operand homes between comparisons.**
   `CounterRuntimeSlotBaseline.matches` currently places backend observation and
   four complete optional identity equalities in one2920-byte caller. Introduce
   finite actual-inout baseline operations for backend and each complete identity,
   returning owned Booleans; the caller retains the original first-failure order.
   Each operation uses the exact original full equality, including all identity
   components, and the same actual current field. Backend equality remains every
   actual backend field. No snapshot refresh, hash, truncation or fabricated zero.
   Preserve captured/phase/owner/serial/presence checks, then root/action/candidate
   root/candidate action, then endpoint prefix→actual-target health→suffix. All
  64 accepted recordings and independent lastFrame stay checked. No whole Control
   or endpoint loan may span backend/health callback reentry. Existing actual
   health operation and ended endpoint loans remain. Complete equality operands
   remain charged in their leaf; compiler output decides whether caller homes
   really disappear. This is a finite operand-lifetime change, not attributes
   applied speculatively to unrelated operations.

Preserve all48/2266 selections, prefix custody, surplus map, eight cleanup hooks,
backing-last, one Optional host, early1/2/3/4 ordering, activation/model/root loans,
one frozen baseline and all original exact comparisons. Every new borrowing helper
uses owned predicate values outside assert/short-circuit autoclosures; model reads
retain their existing conditional skip. Preserve explicit ~Copyable/~Escapable
generic permissions. No extra retained object, allocation or donor role is added.

The final freeze must include source/field/order/case parity, unchanged160 roots,
component recipe exclusion proof and exact fresh commands. After independent
SOURCE PASS, collect the same nRF focused module/layout and both Native focused
runtime/exclusivity/projection commands independently. Analyze **all still-live
ancestors plus actual bank-loan callbacks**, construction and release/destruction
paths, not just whether the selected29144 falls below27648. Existing admission/
scheduler/initializer peaks and indirect/deeper calls remain measured obligations.
Only if full current paths are viable proceed to current nRF202 and image/IRQ/
linked-memory evidence. Main27648 and RAM196608 both remain mandatory. Final
correction2 consumes the last cycle; no third automatic source variant is created.

Documentary verification: archive members were checked against their individual
SHA256 values; all three current receipt/object hashes matched. Governance passes
(204 authority nodes/2036 edges;7 features/76 lifecycle artifacts/9 skills), and
`git diff --check` passes. No source test or compiler invocation was added here.
