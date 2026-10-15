# P08 finite inline-literal proof — initial tooling source freeze

Under the [new activity](p08-layout-sizing-validation-activity.md), this is the
initial tooling pass, corrections 0/2. Prior allowances remain closed. Independent
source review PASS at `556a6a7a`: [review](p08-layout-literal-tool-independent-source-review.md). No updated extraction of the actual object, compiler,
build, runtime or image invocation occurred during implementation.

The extractor adds one finite leaf, separate from the unchanged immediate-return
decoder: exactly eight bytes, `00 48 70 47` followed by an owned little-endian
UInt32. Thumb16 `LDR r0,[PC,#0]` at offset 0 reads offset 4 because the actual
normalized function start is four-byte aligned; offset 2 is exactly `BX LR`.
No other load, register, offset, return sequence or body extent qualifies. The
section must preserve power-of-two alignment of at least four bytes. Checked
address arithmetic bounds the complete word. ET_REL addresses are qualified by
their owning section; ET_EXEC addresses are absolute.

Existing ELF function validation still establishes unique nonoverlapping Thumb
function bounds and allocated executable, nonwritable storage. Instructions and
word all belong to that eight-byte function. Existing relocation inspection
rejects every relocation overlapping instructions or word. The existing maximum
two-hop proof resolves each actual symbol-table/index and uses the **leaf's**
address/alignment, never the root PC. Proof metadata records the leaf kind and
literal location separately from tail edges. There is no target execution,
arbitrary dereference, external pool, mutable input, new target code or cost.

Tests exercise the exact observed `00487047801e0200` body and UInt32 boundaries,
object/firmware zero/one/two-hop proofs, actual auxiliary-table targets and leaf PC.
Negatives cover different registers/opcodes/load offsets/returns, truncation,
padding/extra code, word/section misalignment, address overflow, instruction/word
relocations, writable/nonexecutable storage, Thumb state, bounds, aliases, invalid
relocation table and incoherent target index. All **50 layout tests pass**,
including eight new methods; Python AST and whitespace checks pass. Existing
immediate/tail/region/C-reservation tests remain. No Swift code changed.

[Manifest](layout-literal-tool-source/manifest.json) and
[patch](layout-literal-tool-source/source.patch) pin all three tooling/test files.
Extractor SHA-256:
`360a0d74b950260b381b8e5daaea3dd6026ece455f555686f300e6bfcbeb9dc8`.
Patch SHA-256:
`f5947ff7d5909a01a02b9235c8d7221cd524faa7ac8c6d48114db8e1ab9e3eb3`.
Seven unchanged component receipt hashes were rechecked; none records these
changed tooling files as inputs. Their exact candidate exclusion qualification
stays unchanged. A fresh counter receipt must record the new extractor hash;
no historical counter receipt or failed extraction is upgraded.

After independent source PASS, prepare a fresh output directory and execute this
read-only command on the same hash-pinned object (not run in this source step):

```sh
python3 -B scripts/contracts/p08_layout_facts.py object --input .build/nrf52840/contracts/p08-counter-ap7tbjem/P08CounterRuntime.o --output .build/contracts/p08-layout-literal-proof/so07-layout-facts.json --decoded-output .build/contracts/p08-layout-literal-proof/so07-layout-facts-decoded.json --compiler-sha256 79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69
```

Expected: retain strictly decoded numeric facts, then fail unchanged old 32,000
reservation validation. Raw facts stay diagnostic/unvalidated/accepted=false;
accepted layout output remains absent. This is not passing collection/resource
evidence. Exact measured Swift/C sizing and qualification/source review follow
separately. Stack baseline 27,648 and required lower bound 34,560 are unchanged;
complete main/IRQ/current linked-memory proof remains outstanding.
