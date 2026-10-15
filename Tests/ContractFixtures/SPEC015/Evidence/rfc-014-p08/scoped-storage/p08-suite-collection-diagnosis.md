# P08 collected-suite diagnosis — 2026-10-15

**Group the ordinary defects below into corrective cycle 2; no contract change is
demonstrated.** Diagnostic input `3c281acd`; setup cycle 1/2 is productive and
cycle 2 remains unconsumed here. The [current activity](p08-suite-collection-activity.md)
authorizes collection/grouped corrections/focused validation without per-error
permission stops. This step changes no maintained source, generates no compiler
variant, runs no compiler/suite/image/hardware operation and delegates no work.
Historical budgets, the two-unproductive guard and all P08/fit obligations remain.

The [manifest](suite-collection-diagnosis/manifest.json) pins four full collection
receipts, every failed check's exact log, primary error locations, positive twin
status and the three inspected native binaries. Complete collection means all
registered checks were dispositioned; blocked checks are not validated.

| Current collected profile | Passed | Failed | Blocked | Disposition |
| --- | ---: | ---: | ---: | --- |
| macOS Dynamic | 402 | 8 | 14 | 384 scoped cases include 192 historical imports; runtime traps; all five exclusivity controls pass |
| macOS Static | 400 | 9 | 15 | 384 fresh scoped cases; runtime and positive exclusivity trap; negative execution blocked |
| ARMv6 | 402 | 7 | 0 | 384 scoped cases reached; compile evidence only, no target execution |
| nRF Embedded | 23 | 1 | 202 | counter module fails; all 202 scoped controls blocked; compile evidence unavailable |

## Native failure: proved reservation stride overlap

The exact Static exclusivity binary was stopped at the image-resolved initializer
failure branch. Its [captured range table](suite-collection-diagnosis/static-resolved-ranges.log)
shows **G4 start 6,171,888,632 / extent 40 / alignment 8 / required 40** and
**C0 start 6,171,888,668 / extent 484 / alignment 4 / required 484**. C0 starts only
36 bytes after G4: their declared ranges overlap by four bytes. Both addresses are
aligned. The earlier alignment hypothesis is not the cause of this failure.

The emitted [validation branch](suite-collection-diagnosis/static-validation-detail.log)
checks extent/alignment/overflow/disjointness and returns **14** at initializer
`+2396`; capacity failure separately returns **15**. The range-failure registers
show current C0, earlier G4 and overlapping ends, proving which check failed.
Source `P08TypedSlot.native.reservationRange` charges `Optional<T>.stride`, while
Swift places the following C0 typed field in G4's trailing stride padding. This is
a false reservation claim, not evidence that Swift's disjoint typed fields alias.

Both [Static](suite-collection-diagnosis/static-counter-direct.log) and
[Dynamic](suite-collection-diagnosis/dynamic-counter-direct.log) counter binaries
trap in `withP08SelectedStatic` at `+920`, inside `p08CounterGraph`, with initializer
return **14**, compared against nil **17**. Their disassembly gives the same G4
and C0 field offsets `0xe50`/`0xe74`, also 36 bytes apart. The Dynamic route reaches
the common Static graph control first; its failure does not establish a separate
Dynamic backing defect. Positive Static exclusivity fails before its intended
exclusive-access exercise, explaining the blocked negative. No new transaction,
root/action lifecycle or mutable producer defect is established by these traps.

**Minimal correction recommendation:** preserve the reviewed full `count*stride`
extents, overlap guard, initialized inventory, retained-byte/audit accounting and
original typed loans. First consider reordering private native reservation field
declarations, leaving named physical IDs, initialization/destruction order and
logical roles unchanged. Moving G4 before G3 could force G4's complete 40-byte
span before an 8-aligned successor; however, this diagnosis proves G3's stride
200, **not its size**, so G3→C0 and all other adjacent pairs still require actual
layout verification. Do not claim that proposed order already works. If a finite
reorder cannot establish full disjoint extents, a small typed native slot wrapper
with an explicitly aligned tail field and checked size/stride/alignment can reserve
the full span; charge all added tag/tail/outer bytes and check both native profiles
and surplus slots. Avoid blanket large padding or changing Embedded raw layout.
Merely substituting `.size` in reservationRange is insufficient: `record()` and
the approved ledger still use stride, and later initialized-range/audit checks
would retain the contradiction.

The [design](../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md)
selects individual typed Optional slots, actual compiler native layout and explicit
padding accounting; it does not fix native declaration order or numeric ABI.
These are routine private realization options under ADR-039. Update the derived
physical explanation and prove actual layout/accounting. Escalation is needed
only if the existing extent, ownership or resource requirements cannot be met,
not to choose a contract-preserving field order or small typed reservation wrapper.

## Six diagnostic classifier defects, repeated in three profiles

All positive twins passed. In Dynamic, the first negative's historical numeric
exit remains unknown/nonzero-class; other listed negatives freshly exit 1. Their
primary errors occur solely in the appended generated probe, not trusted prefix.

| Family / failed labels | Actual primary errors | Narrow correction |
| --- | --- | --- |
| `so06-erasure-closure`: static/dynamic × generic × active-host/retired-optional negatives (four labels) | line 2520: `'input' is borrowed and cannot be consumed`; `lifetime-dependent variable 'input' escapes its scope` | Structured finite alternatives for these two exact messages, generated filename, first probe line; rerun the complete family including all direct/generic positive twins |
| `so06-closure-erasure-negative` | line 2519: `lifetime-dependent variable 'input' escapes its scope` | Same finite lifetime-escape message at this probe; rerun its positive twin |
| `so06-task-negative` | line 2519: sending-closure data-race diagnostic, lifetime-dependent input escape, missing reinitialization of consumed closure capture | Recognize all three exact primary message forms at this probe, requiring the lifetime-escape cause; rerun its positive twin |

The current tuple expectations `escaping`/`Escapable` do not match these actual
headers. Do not accept arbitrary compile failure or only the Task concurrency
diagnostic. Use the existing strict structured parser, preserving crash,
unexpected-primary, wrong-site and trusted-prefix rejection. Derive probe bounds
from the generated trusted-source boundary, not permanently hard-coded 2519/2520.
The packet retains all actual messages/columns and positive status details.
The current structured `any_of` accepts each recognized primary independently;
it does not require a particular alternative to occur. Task's lifetime-specific
cause therefore needs an explicit required-primary condition in the corrected
classification; merely listing its three alternatives is insufficient proof.

## Async fixture is ineffective; no contract hole demonstrated

`so06-async-negative` freshly exits **0** on Dynamic, Static and ARMv6. Its only
difference from the positive is an `async` modifier on an uncalled function with
a consuming scoped parameter; the body resets the session immediately, has no
`await`, and demonstrates no transfer from an actual reservation callback.
Acceptance therefore fails the test oracle, but proves neither lifetime erasure
nor a legal escape from the synchronous owner session.

ADR-039 requires the nonthrowing consuming body and enclosing typed borrow;
SPEC-015 S15.1 forbids async transfer that erases its lifetime union. The real
`withP08Storage` body is synchronous `(consuming P08StorageSession) -> Result`.
The minimal paired repair should put a synchronous helper invocation inside that
actual callback for the positive, and attempt `await` of an async consuming helper
from the same callback for the negative. Classify the resulting synchronous-scope
versus async-call/closure rejection from its actual log; do not invent expected
text in advance or claim the compiler forbids every standalone async declaration
with a scoped parameter. Existing Task capture already rejects an actual attempted
escaping transfer. Actual continuation/escape beyond the typed borrow would be a
contract blocker; none is shown by this no-await declaration. No new compiler
variant was run here; collect the repaired pair with the other cycle-2 fixes.

## Embedded module import and warnings

The nRF counter module's six errors all identify `CounterHostProbe.swift`, lines
24/65 (three associated Identity equalities each), and explicitly require the
missing `GiftUIInteraction` import. Add that direct import; do not add
`@export(interface)` or change conformances. The 202 blocked cases must then run;
their behavior is currently unknown. Four confusable constructor trailing-closure
warnings and the unmutated `extracted` local are ordinary source cleanup candidates
within the same grouped correction, preserving lifetime/move semantics.

## Focused validation boundary

Matcher-only driver changes can use exact schema-2 predecessor reuse with the
complete `so06-erasure-closure` and `so06-closure-erasure` families; Task's
complete `so06-task` family must additionally satisfy its required-primary cause.
The repaired async pair belongs to `so06-async`. Native physical-layout source and
Embedded import changes alter compiled inputs: existing `--resume-from` must
continue rejecting that drift. Neither legacy imports nor unchanged old controls
can silently become current-source aggregate coverage.

To honor the requested focused work, rebuild the affected prerequisites/module
and run fresh selected positive/negative families, native counter/runtime and
exclusivity groups, plus the previously blocked Embedded cases using the existing
pinned recipes/flags. Report explicitly partial current-source coverage if other
families are not rerun. Complete current-source aggregate conformance still needs
all required coverage or a separately reviewed exact applicability proof; do not
weaken cache checks or relabel the focused subset as a full suite. Component
receipts remain usable only for inputs/compilations whose exact applicability is
preserved; a newly changed input they actually compiled needs fresh evidence.
Any remaining routine compiler/import/runtime errors should be collected within
the coherent cycle-2 work, not converted into micro-approval barriers.

## Diagnostic execution accounting

Seven completed direct LLDB invocations are recorded with exact commands/results
in [direct-invocations.json](suite-collection-diagnosis/direct-invocations.json):
three offline disassemblies and four existing-binary launches (one unresolved
breakpoint run, one resolved memory inspection, two counter trap traces).
No expression JIT, target function call, compiler probe or process-memory write
was used. Debugger exit 0 is not an application pass. Parent's existing return/
prefix logs are retained unchanged and hashed separately in the manifest.

The earlier composite redirected escalation stalled and was aborted after 877.2s
without nested results. Its three script/invocation records remain **planned,
execution unconfirmed**, not successful diagnostics. The completed direct calls
supersede them. No background job/session was returned. The source repair budget
is unchanged by this diagnosis; P08, nine SO criteria, target images and resource
fit remain open, including the historical 58,648/27,648-byte stack failure.
