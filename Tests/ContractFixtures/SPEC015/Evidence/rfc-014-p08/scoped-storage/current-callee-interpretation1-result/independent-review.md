# Independent Strong review — P08 current-callee interpretation 1

Reviewed 2026-10-19 at **`9159017a89d12342815d7e80246efb0bb03467a3`**.
Verdict: **PASS for the bounded interpretation and its STOP disposition**.
No blocking factual, contract or scope finding was identified in this packet.
**Complete current-callee and safety PASS remains unestablished;
`strict_cold_eligible` remains false.** This is not P08 acceptance.

## Independent method and frozen identity

Read the [interpretation](README.md), its inspection program and derived
inventories, the independently reviewed collection, retained SIL, complete
serialized indexes/required bodies, object symbol/disassembly captures, current
source, accepted ADR-039/040, SPEC-015 S15.1/S15.2, approval provenance and
iteration/implementation navigation. Independent standard-library parsing,
JSON/gzip inspection, SHA-256 checks and read-only Git blob comparisons produced
the [inspection record](independent-review-inspection.json). The author's
inspection program was read, not executed or imported.

All **61 checked frozen files** equal their exact reviewed-commit blobs: the
seven interpretation inputs/outputs, SIL, complete index, required-body record,
terminal, and all 50 object captures. The SIL retains its recorded SHA-256
`6cc9e7b6cecbeb46dd71b2ac8b6e023182354e7fcc08c814374b9c23303c71ed`.
All 42 actual-host sources match the frozen source manifest. All five preexisting
dirty files match their preservation hashes. This review changed none of those
files or the untracked Python cache.

No compiler, build, test, controller, decoder, demangler, qualifier,
counter/schema-4/P07 driver, fixture/application runtime, strict-cold route,
image, connected operation or source repair ran. The only execution was
standard-library inspection and Git/file operations for this review.

## Decisive ordinary Text edge

The two cited actual-consumer sites, SIL **598700–598701** and
**600950–600951**, reference the exact ordinary `BoundedText.withUTF8` symbol
and apply it to `()` with `[nothrow]` and an `[on_stack]` callback. Its SIL
declaration at **601691** has no basic blocks. Both callback references name
the retained SemanticStandardPayloadCodec closure whose body begins at
**601530**. These are actual optimized consumer observations, not a substitution
of an unrelated generic body.

GiftUI object header **0x77c**, disassembly line **552**, supplies that exact
ABI body. It reserves **0xf0**, requests Error metadata at **0x7cc**, loads the
closure thunk/Error witness and calls retained generic `withUnsafeBytes` at
**0x804**. That generic body is present at **0x874**, line **634**: fixed
**0x40** plus metadata-sized, 16-byte-rounded stack storage, callback `blr x9`
at **0x8c4**, and conditional error value-witness move `blr x8` at **0x8dc**.
The thunk at **0x838** calls its captured callback at **0x858**. The metadata
helper at **0x8fc** has both cache and cold branches, with the cold branch
calling external `swift_getTypeByMangledNameInContext2` at **0x930**.

This is a concrete required attribution gap. An on-stack/nothrow caller does
not erase the ordinary ABI's metadata setup or dynamic storage. Conversely,
the conditional error move is not evidence of a feasible throw or allocation
for this particular callback. The packet correctly claims neither a heap event
nor a complete stack bound, and correctly retains linked-runtime and callback/
witness attribution as missing proof. **U01 alone justifies STOP.**

## Selected Static and ownership observations

- Source **1103–1133** constructs Static geometry plus five Static bank
  descriptors from the session token. Source **1238–1355** retains all fourteen
  enclosing typed loans through the consuming body. SIL **82022** preserves
  the token lifetime on the concrete constructor. The observed shape supports
  E01; it does not independently prove every unsafe origin or exclusion rule.
- Source **2462 onward** retains the original root/semantic/Canvas/control and
  field-buffer scopes around the reservation. The `intoSupplied` union,
  consuming host construction, early returns, and deferred original-host
  retirement remain visible in the cited source/SIL. E02/E03/E10 correctly
  distinguish this source order from complete safety evidence.
- The concrete `InteractionState.resolveCandidate` body at SIL **594958**
  exchanges committed/hit roles, records the presentation revision, then
  resets the candidate/hit/prepared committed bank and clears limits/error/
  phase. `resetAllStorage` at **594354** resets all five banks and clears the
  committed revision. E06's selected-path interpretation is supported.
- `P08CandidateAccess.reset` at SIL **76149** and object **0x196a8** has separate
  Static clearing and Dynamic reset branches. The inspected constructor fixes
  the Static descriptor origin. The Dynamic alternative at **0x1970c** cannot
  establish a feasible Static COW allocation by mere reference membership.
- The merged reset helper at **0x12344** passes an initializer through `blr x8`
  and performs bounded copies/clearing. Optional helpers at P08 **0xf8b8**,
  **0xb37fc**, and GiftUIObservableState **0xb7c** use stores and tail `bzero`.
  Their suffixes alone imply no allocation or aggregate cost. E08 stays within
  that observed boundary.
- The loaded C callback at SIL **3992** is real. Privacy/lifetime compiler
  controls do not establish its complete target provenance, reentry exclusion,
  quiescence, or every Optional/retirement path. U03 remains a required safety
  gap; no new concrete escape defect is demonstrated by this review.

## Inventory and coverage claims

Independent reconstruction matches **3,994** SIL records, **3,654** with blocks,
root reference sets **912/1,035/1,063** with **269/281/282** bodyless entries,
union **1,064**, **8,068** references and **9,544** apply-family sites. Every
recorded reference and apply-family tuple matches its raw SIL line. The **106**
indirect entries include closure construction; they are not 106 demonstrated
unknown executed calls.

The independently reconstructed object-reference set matches **4,064** headers
out of **24,152** captured headers, **852** indirect branch sites, and **1,892**
external branch relocations to **56** exact symbols without an exact retained
header. Module-local outlined symbols remain module-local; duplicate generic
definitions retain separate identities. Data relocations, address-taken code,
Dynamic alternatives and observer/transcript code are included. These counts
are a reference inventory, not feasible-call counts, linked winner selection,
whole-program completeness, a heap-event count, or a stack sum.

All **92** required-body joins agree with their complete indexes and positive
body/kind records across **11** indexes/**4,796** serialized functions. **Zero**
exact required symbols belong directly to this reference union; **42** have
prefix candidate joins. Prefix similarity does not prove semantic equivalence
or that an actual consumer uses that unspecialized body. The packet explicitly
preserves that limit.

The **93** privacy joins agree with the closed terminal's original recorded
classifications: **32** exit-zero and **61** negative controls. This review does
not turn those records into a fresh safety matrix or rerun their classifiers.
The prior independent collection review retains its separate integrity PASS.
U04/U05 correctly leave diagnostic-window attribution, complete lifetime matrix,
four-profile, allocator, ABI/image and resource obligations open.

## Smallest next bounded attribution and authority

Start with **U01 only**, against these same bytes: join the two actual caller
closures to SIL **601530**, the GiftUI thunk **0x838**, the retained generic
body **0x874**, and the module-local outlined helpers reached by **0x77c**.
Record exact target/provenance, selected no-throw/error-branch feasibility, and
what the retained Error metadata can establish about aligned temporary storage.
Finish with an explicit residual list for the cold external runtime/linked
implementation evidence that these captures cannot supply. This is the first
slice of the packet's broader U01–U03 attribution recommendation, not permission
to launch all external-symbol or safety work as an unbounded campaign.

Then bound U02's actual Static feasibility and U03's original
origin/return/retirement evidence joins separately. Any genuinely unavailable
runtime/library or fresh safety evidence needs a concrete preparation request
with its own review and allowance before execution. A contract/scope/ownership/
privacy/bound decision goes upstream; no such change is justified here.

Accepted ADR-039 and implementing SPEC-015 remain authoritative, with ADR-040's
finite-counter physical-SRAM exception preserved. No historical counter ceiling
is reinstated, no criterion is closed, and no new ADR/Spec amendment is needed
for this evidence-only disposition. This is the necessary finite-counter
dependency in active ITERATION-003, traceable to the analyzer and constrained
stack validation; closed ITERATION-001 gains no commitment. Full RFC-015 remains
ITERATION-004 I4-07. No optional deferred item was discovered; these proof gaps
remain current blockers.

Collection **1/1 consumed**, repairs **0**, retries **0**, and marker
**[16777234, 29640436]** remain unchanged. This review grants no execution,
repair, retry or successor allowance. Required complete callee **and** safety
PASS must precede preparation of a current strict-cold manifest. Its host-first,
silent/observed/ordinary windows, workload/baseline counts and zero-heap
enforcement remain binding. **P08/R07/T8.1, unmet SO criteria, strict-cold,
zero-heap, four-profile, ABI/resources, independent exit and later conformance
gates stay open.**
