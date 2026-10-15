# P08 finite inline-literal tooling — independent source review

**SOURCE PASS at `556a6a7a`.** The bounded
[tooling freeze](p08-layout-literal-tool-source-freeze.md) implements the approved
finite proof. No source blocker is found; actual-object rereading is pending.
Tooling corrections remain 0/2; all prior repair allowances remain closed.

The only new accepted leaf is exactly eight bytes: `00 48 70 47` plus one owned
little-endian UInt32. LDR r0,[PC,#0] therefore returns that word and BX LR returns
before the word. The normalized actual leaf address must be four-byte aligned;
its owning section must retain power-of-two alignment of at least four. This
preserves ET_REL placement alignment and proves the absolute ET_EXEC PC target.
Checked UInt32 address arithmetic covers the whole literal. This proves every
possible inline word value, not merely the observed numeric value.

Existing function validation still requires allocated executable nonwritable
storage, Thumb state, complete in-section function bounds and no overlapping
function aliases. The complete instruction/word extent is checked for relocations
before decoding. External pools, mutable data and arbitrary loads cannot satisfy
this proof. Other registers, offsets, return instructions, padding, truncation,
stack operations and trailing instructions remain rejected. Existing immediate
and zero-to-two whole-body tail grammars are unchanged. Tail resolution retains
actual symbol-table/index or unique firmware target proof, then checks the leaf's
PC/alignment rather than the root's. Proof metadata records the literal separately.

The eight new synthetic test methods cover object and firmware direct/tail cases,
UInt32 boundaries, auxiliary symbol tables, alignment, address overflow, ownership,
relocations, aliases, malformed extents/opcodes and return sequences. Existing
fixture defaults remain unchanged. The author's **50 compiler-free layout tests
PASS** are recorded, not rerun here. Independent file/patch hashes, per-file exact
diff blocks, three Python ASTs and unchanged qualification pin verify. No Swift,
C reservation, compiler flag or target code changes. A fresh counter receipt must
record the new extractor hash; no historical failed receipt is upgraded.

Proceed with one read of the same hash-pinned object using the exact command
below, in a fresh output directory. This review did not decode that actual object,
run tests, compiler, build, runtime or image. Expected old 32,000-byte reservation
failure must remain a failure: decoded facts accepted=false and accepted output
absent. Review exact measured Swift/C sizing separately before rebuilding. The
27,648-byte stack baseline and prior 34,560-byte lower bound are unchanged; P08
and complete main/IRQ/current-image fit remain open.

```sh
python3 -B scripts/contracts/p08_layout_facts.py object --input .build/nrf52840/contracts/p08-counter-ap7tbjem/P08CounterRuntime.o --output .build/contracts/p08-layout-literal-proof/so07-layout-facts.json --decoded-output .build/contracts/p08-layout-literal-proof/so07-layout-facts-decoded.json --compiler-sha256 79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69
```
