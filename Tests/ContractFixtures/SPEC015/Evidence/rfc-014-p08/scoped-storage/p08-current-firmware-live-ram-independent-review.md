# P08 current firmware live RAM — independent bounded review

**Whole-RAM rejection confirmed, with one call-site erratum; no numerical change.**
Reviewed `17318a41` and the [live result](p08-current-firmware-live-ram-result.md).
For the frozen current realization, increasing main stack alone cannot satisfy
unchanged RAM 196,608. A source-feasible simultaneous fixed-entry subset is
**56,888**; other retained RAM is **142,972**; their lower bound is
**199,860 > 196,608 by 3,252**, before omitted costs. This is not a complete peak,
an impossible-board claim, or a sufficient larger-stack/RAM proposal.

The maintainer permits a sufficient larger main stack; roughly 30 KB is
illustrative, not a ceiling. The independent issue here is the unchanged total-RAM
contract. SPEC-015 remains implementing and P08/R07/T8.1/full SO acceptance remain
open. No source optimization, new allowance, limit edit, build or hardware action
follows from this review.

## Identity and independent checks

The [original live manifest](linked-firmware-live-ram/manifest.json), archive
187,476 bytes / SHA256 `4c6f0c49bd2e83dde4c3d73a7a47b3c7f8c935ce22b681b28df6a2be1d3aea0a`,
all **28** members and **9** current source snapshots match. The existing ELF
remains `e649c5d26a676140b473e8fa1de5b075a479d8282a7f6d69e0034fb215884c38`.
All **47** charged functions' raw ELF symbol indices/names/types/values/sizes
match. All **19,061** selected instruction records reproduce from the same ELF
and pinned objdump. The reviewed read-only mechanical verifier passes; its
source-feasibility caveat is necessary and preserved.

The separate [review supplement](linked-firmware-live-ram-review/manifest.json)
contains [all 47 custody dispositions](linked-firmware-live-ram-review/verified-custody.json),
each actual entry size and nested site, all SP writes up to that site, explicit
union/tail dispositions and the correction below. Additional relevant semantic
store/traversal/TupleView5/Button source hashes match the preceding firmware
handoff. No provisional whole-graph subtotal is accepted as proof.

## Path feasibility and frame custody

The selected path is the ordinary **`.host(0)`** case with nil reuse/baseline,
early=0 and no candidate fault, through successful normal activation and paced
service. The current source supports these choices. It requires ordinary host
lifecycle, host corpus, wake controls and semantic expansion before teardown.
It is not combined with `.twoHosts`, the preceding scoped corpus or a failure
callback. Source feasibility is a requirement on a valid execution given adequate
stack, not a claim that the currently undersized stack executes this path safely.

Every charged entry retains its fixed reservation at its selected nested call;
the final entry is needed only through its prologue. Conditional epilogues printed
earlier in a function belong to other exits and are not traversed on this success
path. Prepared/root/semantic/withStorage register SP assignments move below the
fixed frame. CounterScreen's entry alignment likewise does not release its fixed
reservation. Further alignment/outgoing areas remain uncharged.

The nontrivial connections are supported as follows:

- Main's successful initialization arm calls the counter entry; its early failure
  pop is a separate exit. Entry's nonnil backing/exact extent guards pass before
  its charged 8-byte push. The exported C entry wrapper tail-forwards without
  adding a frame.
- Custody calls the metadata dispatcher. The host arm restores **36+28=64** bytes
  before its tail branch at `0x1c1d4`; that dispatcher is correctly uncharged.
  Metadata-host passes nil before/transcript and one-host supplies the ordinary
  positive host parameters.
- The original model/semantic callback literals and forwarders connect the
  selected prepared/root/semantic frames. All fourteen original bank loans enclose
  the supplied session body. Their interposed bank lender/callback/forwarder and
  scoped consuming-body frames remain omitted; no invented direct edge supplies
  a cost or feasibility premise. Session calls the live host phase only after
  its constructor and preset factory return; neither returned frame is charged.
- Nil reuse selects ordinary lifecycle. Corpus's **7,584** bytes remain at BL
  `0x1d6c6` into wake controls; wake's **9,360** remain at BL `0x1dd06` into the
  successful coalesced service. These calls are nested. Equal state-change values
  do not remove the semantic expansion: the actual pipeline's candidate step
  explicitly calls `semantic.expand` on this successful opportunity.
- Service's `.began` TBB arm reaches `0x28e32` and the host call `0x28e36` while
  retaining 544 bytes. The body-evaluation union's `.body` arm reaches `0x7090`
  and declaration call `0x70be` while retaining 1,368 bytes; failure arms are not
  added. Raw TBB tables are `02190915` and `02573546`, respectively.
- The finite authored path is CounterScreen → background modifier → VStack →
  TupleView5 → third child `.disabled` Increment Button → Text label. Earlier
  sibling Text visits have returned; their frames are not added. Disabled affects
  semantic value, not whether the label is traversed. Successful primitive/action
  helpers at `0x3a38a` / `0x3a45c` restore their **256-byte** frames before tail
  forwarding at `0x3a43e` / `0x3a52c`; both correctly charge zero.
- Text BL `0x6be4` enters merged declaration-role function `0x3982e`; its
  **1,072-byte entry** is sufficient. Its representative CounterScreen symbol name
  does not introduce recursive CounterScreen traversal. The ledger's further
  outlined/equality chain is unnecessary to this endpoint and is not counted.

These independently reviewed custody groups reproduce the report:

| Group | Entries | Fixed bytes |
| --- | ---: | ---: |
| Main/entry/corpus/ordinary host/custody/metadata-host/one-host | 7 | 456 |
| Prepared/original model and semantic callbacks/withStorage | 10 | 9,592 |
| Session/host phase/lifecycle/host corpus/wake | 5 | 26,728 |
| Service/pipeline/finite semantic traversal/declaration-role entry | 25 | 20,112 |
| **Simultaneous subset** | **47** | **56,888** |

## Exact erratum to the immutable packet

`required-live-fixed-subset.json` names helper `0x5996c`'s callback at
**`0x59b3a`**. That is its nil-span-start arm. The current valid source supplies
nonnil semantic buffers, including the 128-scalar span. The source-specific arm
instead calls **`BLX r3` at `0x59a64`**: the start load/compare at
`0x59978` / `0x59996` and BEQ `0x599a4` retain the nonnil fallthrough; LDRD
`0x59a38` reloads the supplied callback from `[sp,#508]`. It is the same
`0x519b5` Thumb callback resolved from literal `0x1aab4` plus ADD-PC `0x1aa26`.

Both arms retain the identical **448-byte** entry frame. The corrected site
therefore changes **no frame, count, sum, RAM result or conclusion**. The original
archive is unchanged; the supplement records the exact replacement site and
source premise. This is a corrected proof reference, not a waived finding.

## RAM accounting and decision

Independent ELF reads confirm disjoint RAM PT_LOAD sizes **804+169,816=170,620**;
their extent includes a four-byte gap. Main's whole symbol is **27,712**, with
27,648 payload and **64 guard**. ISR's whole symbol is **2,112**, with 2,048
payload and **64 guard**. Both symbols lie inside linked RAM and do not overlap.
Replacing only main's payload leaves all other bytes and both guards charged:

`170,620 − 27,648 = 142,972; 142,972 + 56,888 = 199,860 > 196,608`.

Only **53,636** payload bytes remain before rounding, already below the required
fixed subset. No stack reservation is added twice. Four backing slots retain
138,880 bytes and donor metadata is not charged again. Omitted lenders, dynamic
SP areas, deeper callees, startup/IRQ/FPU and allocation closure can increase the
requirement; they cannot rescue this frozen representation under 196,608.

A sufficient main-stack selection alone is therefore unavailable under the
current total-RAM contract. A distinct decision is needed: retain 196,608 with an
explicitly bounded representation/co-residency change, or review a larger total-RAM
contract. This evidence proves neither a smaller replacement nor a sufficient
new numerical limit. Complete conservative phase/startup/IRQ/FPU/allocation
accounting and normal guarded final-image validation remain necessary after that
decision, alongside remaining four-route/Pi/Dynamic/P08 exit and I4-07/P09–P12,
hardware and timing obligations.

Review actions were source/evidence reads, raw ELF/objdump inspection and the
read-only mechanical ledger verifier. No source/build/link/test campaign, hardware,
limit change or optimization ran. Governance, whitespace, supplementary hashes
and affected-link checks pass; existing pycache is preserved.
