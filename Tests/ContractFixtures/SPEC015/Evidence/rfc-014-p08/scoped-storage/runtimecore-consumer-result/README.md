# Actual consumer — required callee specialization gate FAIL

**Fresh SIL collection PASS; bounded actual-consumer gate FAIL.** Source22eea103
is unchanged. The single prepared42-source SIL emission exited0; all573 frozen
inputs/recipe/output hashes verify. [Collection receipt](collection-result.json),
[full fresh SIL/log archive](evidence.tar.gz), [member hashes](manifest.json),
[bounded slices](evidence/) and [receipt](receipt.json) preserve reproducible evidence.
The unrelated old SIL remains unqualified and untouched. No new compiler, decoder,
application, source edit or automatic repair occurred during interpretation.

The concrete scoped Static operation is
`CounterPipelineOwner<P08GeometryAccess,P08CandidateAccess,P08CommittedAccess,P08HitAccess>.runOpportunity`:

1. Actual specialized Static `CounterHostState.attachRoot` calls it at SIL78629–30;
   the ordinary opportunity path also calls it at79560–61. This is an actual
   activation/operation boundary, not an invented generic probe.
2. At SIL6644–45 it references/applies generic `RuntimeCompletePipeline.run`.
   The callee at109438–42 has only an effect summary and **zero basic blocks**.
3. The fresh RuntimeCore physical index independently identifies that exact symbol:
   FunctionID611, bit1118229, serializedKind0, zero basic blocks, inline strategy2.
   [Full physical record](missing-callee-physical.json) retains index/raw prefix proof.
4. The hash-matched actual host object agrees: concrete caller starts0x1828 and
   branches at0x198c (+0x164), with ARM64_RELOC_BRANCH26 to the same generic symbol.
   [Exact combined evidence](blocker.json) and bounded object/SIL slices preserve it.

This fails required callee/body availability and complete concrete specialization.
It is **not a measured allocation failure, heap count, missing-everywhere claim or
contract impossibility**. The operation's result is formed before counterTrace
(reference6655/apply6656); this particular missing-body edge is independent of
that later observation call. Metadata/TLS/context allocation and quiet-observer
attribution are otherwise unqualified, not inferred from allocator symbol presence.
The fresh25 compile PASS,22 selected privacy PASS and six selected body-availability
PASS remain valid; this is an additional required callee beyond those six roots.

## Next read-only review boundary

`RuntimeCompletePipeline.run` already has source `@inlinable` and
`@inline(__always)`. Re-adding them is not a correction. Its enclosing package
nominal/protocol/signature formal scope and compiler serialization eligibility
need exact review. [Finite transitive inventory](next-bounded-inventory.json)
starts at this proven boundary: three generic private helpers
finishOfferWithoutCommit/fail/cleanup, ordinary cleanupStage, their direct cleanup
oracle/tracker/OptionSet boundary, and16 existing owner requirements with exact
CounterPipelineOwner stage/callee implementations. Inventory all of these and
required result/enum payload/witness/constructor dependencies together before any
future candidate; this avoids one-symbol fixes. Ordinary nongeneric ABI callees
need not have their implementation serialized. No blanket field/nominal sweep,
source edit map, new allowance or new execution is granted by this evidence.
Preserve checked construction, restricted source access, complete failure/cleanup
order, original State references,14 loans/Optional lifetime unions and strict costs.

[All42 origin dispositions](origin42-status.json) remain explicitly unqualified
for full private-callee/continuation/destruction coverage after this early material
gate failure. State structural-borrow/no temporary/copy/context allocation and
actual binder/action/domain/visitor paths are not certified by this packet.
Full14-loan/Optional/lifetime/provenance/exclusivity/failure-cleanup safety and
strict host-first cold/reuse remain blocked; no broader safety or runtime followed.
Key-failure Error-witness first-use resource costs remain unresolved. Source
candidate/combined overlay/P08/R07/T8.1 remain unaccepted. The sole witness
candidate permits no automatic source repairs; every exhausted budget and
protected external five/pycache stays unchanged. Independent boundary review next.
