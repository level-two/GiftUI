# P08 layout correction 1 diagnosis — 2026-10-15

The actual fresh focused run failed in `.build/nrf52840/contracts/p08-counter-up8gwovn`:
**24 preparation/module passes, 202 not-run scoped controls, one layout failure**.
The [immutable packet](remaining-layout-cycle1-failure/manifest.json) preserves
the exact receipt, wrapper, commands and logs; all 129 C roots, six C-local and
six Swift-local helpers, 129 Swift counterparts and their bytes/relocations;
and complete selected-section disassembly. Original large files are losslessly
compressed with original/decompressed hashes. The actual compiler, object and
every receipt artifact hash were verified. No source, compiler, rerun, probe,
target execution, build or image operation occurred in this diagnosis.

Counter receipt SHA-256:
`38915aa85e7e45181b0e200eaf064f809a99e1973b668e211b1c38fff12b3e6c`.
Object SHA-256:
`09d518c80de8336a25a31bf02ed4fd2f0ebb5c719bf2966d4faf1dfc3e59799d`;
size **2,804,204 bytes**. These are failing partial evidence, not a full suite
or passing numeric-layout receipt.

## Complete observed obstacles

All **129 exact global defined C roots remain present**. The exact-one local
helper whitelist fails because this compilation instead emits six local
functions: `giftui_p08_layout_{g2_size,g3_count,c0_size,g2_alignment,h0_size,control_size}Tm`.
Six analogous mangled Swift-local helpers accompany the 129 Swift counterparts.
No extra exported measurement root, missing required root or registration failure
was found. Local compiler function names depend on merging, so another finite
name-by-name whitelist would repeat the defect.

Every exported root was inspected independently of inventory classification.
**Zero** satisfies the unchanged strict complete-function decoder:

| Actual C root shape | Count | Exact behavior |
| --- | ---: | --- |
| 30-byte body | 63 | Push r4/lr; subtract 752 from SP; call outlined initialization helpers and InlineArray repeating initializer; move an immediate to r0; restore SP; pop r4/pc. |
| 32-byte body | 32 | Same template, with a wide immediate. |
| Four-byte `fff7febf` body | 34 | Single direct `b.w`, with one `R_ARM_THM_JUMP24` relocation at offset zero, to another measured root or local helper. |

All six C-local helper bodies have the same 30/32-byte initialization template.
The 34 tail wrappers resolve through **at most two** direct tail edges to that
template. There are no observed tail cycles or conditional wrappers. The 95
non-wrapper roots retain **760 bytes** before callees (752 locals + 8 saved
register bytes), not a pure return. `OUTLINED_FUNCTION_92` calls memory clearing;
`OUTLINED_FUNCTION_93` prepares the nil element; the remaining call constructs
`InlineArray<25, CounterEmbeddedRegion?>.init(repeating: nil)`. These are surviving
collection-initialization effects of constructing `CounterEmbeddedLayout` just
to observe a scalar. Calls, relocations, stack and memory effects cannot be
accepted by dropping a prefix/suffix or widening the current return decoder.

**Correction 1 was productive:** the unconditional trap-only bodies disappeared
after the reservation correction. Successful-layout scalar arithmetic folded;
the unused array initialization and function merging remain. This is progress,
not a measurement pass, fit claim or budget reset. **1/2 cycles remains consumed**;
only the final grouped corrective cycle remains under the existing guard.

## Diagnostic literals, not accepted function proofs

The packet's `diagnostic-immediate-literals.json` records the actual immediate
instruction at offset `+22` of each 30/32-byte body and exact tail-wrapper path.
For encoding analysis only, it supplies a synthetic decoder terminator to the
isolated immediate. **The original functions all remain rejected**: their prior
calls may have effects/fail, and no SO07 driver pass is manufactured. Independent
checked arithmetic over these diagnostic values produces this consistent ledger:

| Field | Offset | Count | Size | Stride | Alignment |
| --- | ---: | ---: | ---: | ---: | ---: |
| limits | 0 | 1 | 115 | 116 | 4 |
| root | 116 | 1 | 810 | 812 | 4 |
| semantic | 928 | 1 | 116 | 116 | 4 |
| semanticRecords | 1044 | 128 | 20 | 20 | 2 |
| semanticPaths | 3604 | 384 | 22 | 22 | 2 |
| semanticPayloads | 12052 | 256 | 33 | 36 | 4 |
| semanticScalars | 21268 | 128 | 4 | 4 | 4 |
| values | 21780 | 1 | 4 | 4 | 2 |
| canvasEntry | 21784 | 1 | 28 | 28 | 4 |
| b0 | 21812 | 1024 | 1 | 1 | 1 |
| b1 | 22836 | 1056 | 1 | 1 | 1 |
| b2 | 23892 | 20 | 1 | 1 | 1 |
| b3 | 23912 | 112 | 1 | 1 | 1 |
| g0 | 24024 | 1 | 70 | 72 | 4 |
| g1 | 24096 | 1 | 98 | 100 | 4 |
| g2 | 24196 | 1 | 1024 | 1024 | 4 |
| g3 | 25220 | 1 | 167 | 168 | 4 |
| g4 | 25388 | 1 | 26 | 28 | 4 |
| c0 | 25416 | 1 | 484 | 484 | 4 |
| h0 | 25900 | 1 | 460 | 460 | 4 |
| r0 | 26360 | 1 | 484 | 484 | 4 |
| r1 | 26844 | 1 | 484 | 484 | 4 |
| h1 | 27328 | 1 | 460 | 460 | 4 |
| control | 27792 | 1 | 4200 | 4200 | 8 |
| used | 31992 | 1 | 1 | 1 | 1 |

Cursor **31993**, maximum alignment **8**, rounded slot **32000**, required
four-slot total **128000**. Current Swift/C source reservation is also
`4 * 32000`, source alignment 8, with zero derived surplus and all four supplied
origins spaced on alignment 8. **No current firmware C symbol/map comparison
exists**; source consistency is not linked-artifact evidence. Full retained
code/metadata, RAM/flash and feasible construction/body/helper/IRQ stack bounds
remain unknown, and the existing resource ceilings are unchanged.

## Proposed final grouped correction for independent assessment

1. Factor the existing typed 25-region enumeration and checked scalar cursor/
   round-up algorithm into **one** private traversal with a synchronous
   nonescaping metadata visitor. Runtime construction sends its checked copied
   regions into the existing array; measurement selects its scalar through a
   trivial lexical visitor **without constructing that array**. Keep every
   MemoryLayout query, count, region order, guard, overflow and runtime stored
   region unchanged. No copied scoped capability, runtime global, guessed ABI,
   second region list, allocator or new compiler flag is introduced. This
   removes the actually observed unused initialization from measurement rather
   than accepting it as a constant-return proof.
2. Require the exact 129 global defined function roots and separately record
   bounded, defined **STB_LOCAL function** symbols under the measurement prefix,
   validating their section/Thumb/bounds. They confer no fact authority. Reject
   any extra exported/weak/undefined/data root, duplicate or missing root; a local
   name cannot mask a bad required root. Compiler-generated local names are not
   a normative inventory.
3. For independent design assessment, support only the **observed direct-tail
   semantic shape** in addition to the unchanged immediate-return leaf grammar:
   at most two whole four-byte unconditional Thumb `b.w` hops, no cycles, each
   resolving to a unique defined Thumb function start in executable bounds.
   In an object, require the canonical unresolved branch bytes, exactly one
   `R_ARM_THM_JUMP24` relocation at zero with its canonical start addend, and an
   exact unambiguous target symbol. In the final ELF, decode the complete direct
   PC-relative branch and require its destination to be a unique function start;
   reject residual/ambiguous relocation, overflow, middle-of-body targets or
   unresolved symbols. The terminal leaf must pass the existing strict decoder
   and reject all relevant relocations. Record every hop, raw byte, target and
   leaf. BL, indirect/conditional branches, arbitrary callees, loads, stack,
   memory effects, unknown instructions, extra bytes and initialization bodies
   remain forbidden. Add finite object/ELF positive and mutation tests.

The third item is a proposed equivalent proof of a constant-return function
graph, **not a claim that current code qualifies** and not authorization to
broaden instruction acceptance merely to pass. Independent Strong assessment
must approve the semantic proof before source implementation. If the final
candidate still emits effects or exceeds these bounds, preserve the actual
failure and stop at the two-cycle boundary; no automatic third candidate, source
variant or changed ownership/resource contract follows. All full collections
and images remain held; historical packets and budgets stay immutable.
