# P08 remaining layout measurement — independent Strong source review

**PASS for the recorded validation, with materialization and fit unproved.**
Independent Sol 6.1 High assessment of clean `7b43e199`, the
[source freeze](p08-remaining-layout-source-freeze.md),
[manifest](p08-remaining-layout-source-manifest.json),
[qualification](p08-remaining-layout-applicability.json) and
[current activity](p08-remaining-completion-activity.md), under accepted ADR-039
and approved S11/S13/S15. No source blocker or new contract decision is found.

| Boundary | Source assessment |
| --- | --- |
| Actual derivation | All 129 Embedded-only C roots project the expected 25 original region indices/components and four summaries from the existing checked CounterEmbeddedLayout, with exact UInt32 conversion. Initializer/append inlining hints preserve every guard and add no alternate layout. No root executes or creates retained capability/global state. Folding, compile acceptance and changed inlining resource costs require actual artifacts. |
| Strict extraction | ELF32 little-endian ARM object/executable checks, exact unique root inventory, Thumb normalization, symbol/section bounds and executable permissions precede decoding. Only a complete immediate r0 initialization, optional movt and final bx lr is accepted; unsupported instructions, extra bytes and relevant relocations reject. The decoder handles the finite permitted immediate forms without evaluating arbitrary target code. Object/ELF values and validated layouts must agree. A real unsupported body remains a failed measurement, not permission to loosen the decoder. |
| Physical/C proof | Extracted facts independently satisfy checked sequential alignment, field extents, disjoint bounds, round-up and four-slot multiplication. Required slot bytes may be smaller than the supplied 30,176-byte stride; full 120,704 retained C bytes and surplus remain explicit. Source constants, unique counter_backing.0 object, exact map owner/address/size, writable allocated section, base/section alignment and stride divisibility establish all four actual slot origins. Actual retained code, duplicate bodies, linker padding/metadata and complete stack/IRQ costs remain image-ledger duties. |
| Drivers/retention | Actual P08CounterRuntime includes the measurement source; repeated scoped variants omit only its capability-free roots, preserving the trusted storage code, all positive twins and 384/202 scoped labels. Native runtime, five exclusivity checks and thirteen reuse observations per route are unchanged. SO07 extraction requires successful current module preparation and gates the usable target object list. SO08 additionally requires complete passing receipts, exact inputs/artifacts and pinned SO07 object facts; explicit linker undefined roots retain the expected symbols without a RAM pointer table. The existing supported firmware route performs final extraction. |
| Freshness/hygiene | All thirteen manifest hashes and seven exact unchanged predecessor receipts/input-list counts/digests/source exclusions pass. Neither new accessor source nor changed Embedded layout source belongs to those component inventories. Only the explicitly qualified noncompiled CounterScopedStorage metadata drift is admitted; actual counter inputs/helper changes require fresh coverage. Removing two unused enum associated-value bindings preserves reset operations and switch coverage. No old counter receipt is promoted to current acceptance. |

Independently ran **48 compiler-free tests** (19 layout and 29 collection), Python
AST, shell syntax and whitespace checks: all pass. Tests cover immediate forms,
malformed/effectful bodies, ELF bounds/permissions/duplicates/relocations,
object/ELF disagreement, exact accessor projections, arithmetic, full retained
surplus and C symbol/alignment/slot-origin failures. These checks establish
extractor/source readiness only. No compiler, build, runtime, image, debugger,
hardware operation, formatter or subagent was invoked in this review.

A single explicitly recorded existing nRF driver invocation with
`--fresh-focused --select-family so07-layout-facts` is a sound first validation:
fresh preparation/current module executes its registered extraction while all
202 scoped controls record not-run. Its partial flags cannot establish full
acceptance or feed an image. Preserve failure and use the activity's grouped
correction boundary if materialization fails; if successful, proceed to the four
fresh complete registered collections. There is no cross-profile build dependency
requiring native before nRF because their exact component recipes already exist.
The new full Embedded collection has **227 total checks**: 24 preparation,
202 scoped and one layout extraction; the approved scoped corpus is unchanged.

Current remaining-completion activity stays at **0/2 corrective cycles** after
this initial source review; historical budgets remain closed and the two-unproductive
guard persists. SO07 full current coverage, SO08 numeric layout/C reports and
both images, full resources/stack/IRQ, caller refresh and independent SO09 exit
remain pending. All nine criteria, P08/R07/T8.1/HC-RD-003 and fit remain open,
including the historical 58,648-byte failure against the unchanged 27,648-byte
ceiling. No implementation or lifecycle transition is claimed.
