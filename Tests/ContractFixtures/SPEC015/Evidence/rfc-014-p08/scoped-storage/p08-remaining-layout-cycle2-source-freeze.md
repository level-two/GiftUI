# P08 final layout correction 2 source freeze — 2026-10-15

This consumes **cycle 2/2** of the existing
[remaining activity](p08-remaining-completion-activity.md), following independent
Strong approach assessment. Both [earlier](p08-remaining-layout-initial-diagnosis.md)
[failure packets](p08-remaining-layout-cycle1-diagnosis.md) remain immutable.
No third automatic source candidate or compiler variant follows another
materialization failure. Historical allowances remain closed.

One `counterVisitEmbeddedLayout` traversal now owns the original 25 typed
MemoryLayout queries, counts/order, R1 surplus, append overflow/bounds guards
and final checked round-up/four-slot multiplication. Runtime construction alone
creates and stores the original InlineArray. Measurement visitors select copied
scalar metadata synchronously without creating that collection; they expose no
capability, escaping closure, global initializer or alternative ABI layout.
The original query/count sequence was compared exactly with the predecessor.
The 32000-byte slot / 128000-byte full four-slot reservation remains unchanged.
Runtime locals, visitor/traversal work and any materialization copies still need
actual target resource attribution; no stack improvement or fit is inferred.

Exactly 129 global defined roots remain mandatory. Up to **258** nonroot local
functions under the measurement prefix may be separately recorded with symbol
table/index, Thumb/executable bounds and bytes; names confer no authority.
Unknown exported, weak, undefined/data, duplicate, missing or malformed roots
still reject. Each queried root needs its own complete proof independently of
helper classification.

The immediate-return **leaf grammar is unchanged**. Only up to **two entire
four-byte unconditional Thumb B.W tail hops** may precede it, preserving LR:

- Object: exact canonical unresolved branch/addend (-4), sole body relocation at
  zero, `R_ARM_THM_JUMP24` in REL, resolving the actual `sh_link` symbol table and
  `r_info` index to a defined Thumb function; names alone do not resolve edges.
- Firmware: signed displacement with PC = instruction address + 4, checked
  destination arithmetic and a unique defined Thumb function start; no residual
  or overlapping relocation. Reject interior targets and ambiguous aliases.
- Every function consumes its full bytes in executable bounds. Reject third
  hops, cycles, calls, conditional/indirect branches, loads, stack effects,
  initialization templates, invalid symbols/addends/relocations and extra bytes.
  Record each body, edge, relocation identity and terminal leaf independently
  in object and ELF reports, and charge actual retained code/helper metadata.

**69 compiler-free tests** pass: 29 collector and 40 layout/proof tests. They
cover zero/one/two hops versus three, signed offsets/PC, actual linked auxiliary
symbol tables and indices, addends/types/overlaps, cycles, aliases/interior/
undefined targets, calls, bad leaves and all saved failed initialization templates.
Python AST, source identities, exact unchanged leaf AST, seven qualification
proofs, local links and whitespace checks pass. No compiler, build, target
runtime, image, formatter or agent was invoked in this correction.

`CounterScopedStorage.swift` and its
[exact metadata qualification](p08-remaining-layout-applicability.json) are
unchanged and pinned again. Changed backing/accessor/extractor inputs require
fresh preparation; old counter/image coverage is not reused. All **384/202**
scoped controls, native **five** exclusivity controls and **thirteen** reuse
labels per route remain registered. [The new manifest](p08-remaining-layout-cycle2-source-manifest.json)
pins files, proof limits, preserved failures and the same registered focused
command. Parent obtains independent Strong source review, then performs the
final focused nRF materialization invocation. Full collections/images remain
held. Actual proof success, final C-symbol comparison, complete stack/IRQ/
RAM/flash fit, caller inventory and P08 acceptance remain open.
