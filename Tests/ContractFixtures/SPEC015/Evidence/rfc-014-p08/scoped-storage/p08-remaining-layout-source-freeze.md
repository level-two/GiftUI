# P08 remaining layout measurement source freeze — 2026-10-15

This is the initial source pass of the [remaining-completion activity](p08-remaining-completion-activity.md),
authorized by Eugene's “Please proceed with the remaining p08 tasks”. Correction
consumption remains **0/2**; historical allowances stay closed. Parent obtained
independent Strong assessment of the constant-return realization before this
implementation. No contract, workload, capacity, target, compiler or compiler
flag changes. The [current design](../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md)
records the equivalent internal realization; literal section data is not assumed.

`StaticCounterLayoutFacts.swift` supplies 129 Embedded-only measurement roots:
25 original fields × offset/count/size/stride/alignment, plus cursor end, maximum
alignment, rounded slot bytes and required four-slot bytes. Every root uses the
same existing checked layout with the existing supplied slot extent; initializer/
append inlining hints expose that derivation without removing any guard. No
root is called, returned capability, dynamic global or runtime table is added.
The actual counter module includes these roots; scoped diagnostic variants omit
only this measurement source, retaining all **384/202 labels**, positive twins,
native **five exclusivity controls** and **thirteen reuse labels per route**.
The two unused associated-value bindings in `reset()` are removed without changing
its operations or switch coverage.

`p08_layout_facts.py` reads ARM ELF bytes without executing target code. It accepts
only exact exported Thumb roots whose full symbol body initializes r0 from an
immediate, optionally applies movt, then returns. Loads, calls, branches, stack
work, relevant relocations, extra bytes, invalid bounds and missing/duplicate/
unexpected roots fail closed. It independently checks field bounds/disjointness,
round-up/multiplication and actual four-slot spacing alignment. Compiler folding
is **unproven**; an unsupported emitted body is a real measurement failure.

SO07 adds one read-only `so07-layout-facts` check after the existing module/control
work. A failed/omitted extraction blocks the usable target object list. SO08
requires a complete passing counter receipt and verifies its sources/artifacts;
the supported firmware recipe retains exact roots with linker `--undefined`
entries (no compiler flags or RAM pointer table), then reads the final ELF/map.
It requires exact object/ELF fact equality and the unique `counter_backing.0`
symbol, exact `.bss.counter_backing.0` map owner/address/size, C/Swift source extent
agreement, base/section alignment and all four actual slot origins. Full retained
C bytes and surplus remain charged. All actual retained measurement code,
duplicates, padding and metadata still require image/resource attribution.

The [new exact qualification](p08-remaining-layout-applicability.json) pins the
seven unchanged predecessors that did not compile `CounterScopedStorage.swift`.
Their receipt hashes, original inputs and complete argv-derived Swift input sets
were verified. This qualifies only that metadata drift; compiled-source changes,
new instrumentation and driver/helper changes invalidate prior counter coverage.
Old receipts, qualifications and manifests remain unchanged.

Compiler-free checks: **48 Python tests** (29 existing collection + 19 layout),
Python AST, shell syntax, exact accessor inventory/projections, seven predecessor
proofs and whitespace pass. No compiler, runtime, build, image, formatter or
delegation occurred in this source pass. [The manifest](p08-remaining-layout-source-manifest.json)
pins source/helper/qualification identities and the registered next recipes.
Parent next obtains independent source review, then four fresh full collections
and the two existing early images. Numeric materialization, full current coverage,
firmware fit/stack/IRQ attribution, caller-inventory refresh and P08 acceptance
remain open; the 27,648-byte ceiling and historical failure are unchanged.
