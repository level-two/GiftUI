# P08 current-callee and safety interpretation 1 — 2026-10-19

Disposition: **STOP — required complete current-callee and safety proof remains
incomplete. `strict_cold_eligible` is false.** This is a completed bounded
interpretation with identified open edges, not a completed callee/cost/safety
qualification. The collection itself retains its independent PASS.

Reviewed baseline: `0572d004c1761989aabd3d452e1101a5139d4514`, including the
[collection archive](../current-callee-collection1-result/README.md) and its
[independent review](../current-callee-collection1-result/independent-review.md).
All 42 actual-host source hashes still match the frozen collection source list.
The five preexisting tracked edits match their recorded preservation hashes;
the preexisting Python cache was not changed or staged.

No compiler, build, test, collection controller, decoder, demangler, qualifier,
counter/schema-4/P07 driver, application runtime, strict-cold route, image or
connected operation ran. No maintained source, raw receipt, collection marker,
repair/retry allowance or contract was changed. Only standard-library text,
JSON, hash and compressed-record inspection produced this derived packet.

## Authority and lifecycle

[Accepted ADR-039](../../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md),
[implementing SPEC-015 S15.1/S15.2](../../../../../../../docs/specs/spec-015-host-configuration.md),
the approved/applied scoped-storage packet, and the
[P08 SO-01–09 plan](../../../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md)
govern this interpretation. ADR-040's accepted finite-counter physical-SRAM
exception remains applicable; no historical 27,648-byte counter ceiling is
reinstated. All other ownership, privacy, heap, logical-capacity, corpus and
resource obligations remain binding. The plans remain active and Specs
implementing; P08, R07, T8.1 and all still-unmet SO criteria remain open.

This is ITERATION-003's finite-counter dependency for actual analyzer and
Static/Dynamic stack validation. The closed ITERATION-001 reference application
and constrained embedded stack requirements explain its necessity; closed MVP
gains no work. Full RFC-015 delivery remains ITERATION-004 I4-07, with P09–P12,
hardware, timing and later conformance gates separate. This result introduces
no architectural or contract choice and no optional deferred item.

## Reproducible inspection and exact inventory

Run the read-only input inspection from the repository root:

```text
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-interpretation1-result/inspect.py
```

The [inspection program](inspect.py) imports only the Python standard library,
reads existing SIL/JSON/symbol/disassembly/source bytes, and writes derived
records only beside itself. It never imports or invokes collection, decoder,
qualification or fixture code. Repeating it repeats text inspection, not a
production attempt. The frozen raw outputs remain the primary evidence.

| Derived record | Content and exact boundary |
| --- | --- |
| [Inspection summary](inspection-summary.json) | Input SIL hash, source/preservation joins and counts below; explicit STOP/strict-cold false |
| [SIL inventory](sil-inventory.json.gz) | Exact symbols and source lines for 1,064 nodes, 8,068 function-reference sites, 9,544 apply/try-apply/begin-apply/partial-apply sites, and 8,113 ownership/lifetime/dispatch operations; separate membership for each root |
| [Object inventory](object-inventory.json.gz) | Hashes for all 25 symbol/disassembly pairs; exact root joins and conservative code/data-reference closure containing 4,064 function headers, relocations, direct and indirect branches, and stack instructions |
| [Required-body join](required-body-join.json) | All 92 exact retained targets, serialized identity/kind/blocks, exact SIL joins and explicitly labelled specialization-prefix candidates |
| [Privacy join](privacy-control-join.json) | All 93 original classifiers, actual exits, classified diagnostics and raw-stream hashes from the closed terminal |

The two `.json.gz` files are deterministic gzip-compressed UTF-8 JSON. Inspect
them with standard-library `gzip.decompress` and `json.loads`. Every SIL node has
an `Snnnn` ID and its complete mangled symbol. Edges use those IDs to avoid
repeating very large specialized names. Each retained line number refers to
`../current-callee-collection1-result/raw/actual-host.sil` or the named module's
`-disassembly.stdout`; symbol locations refer to `-symbols.stdout`.

The SIL hash is
`6cc9e7b6cecbeb46dd71b2ac8b6e023182354e7fcc08c814374b9c23303c71ed`
(62,139,693 bytes). Text inspection finds 3,994 function records, of which
3,654 have basic blocks. The 11 retained complete indexes contain 4,796 function
records. Their 92 selected bodies remain uniquely available as independently
reviewed. Availability is not evidence that the actual optimized consumer calls
the unspecialized symbol: none of the 92 selected target symbols is a direct
member of the selected reference closure; 42 have prefix-matching specialization
candidates there, while 11 have exact bodies elsewhere in the SIL. Prefix
matches are candidate joins, not asserted semantic equivalence or exhaustive
inlining attribution.

The three explicit roots are `p08CounterHost(write:backing:)` (SIL 400836),
`p08CounterScopedStorage(backing:write:)` (417207), and
`p08CounterRoute(write:backing:)` (562306). All join exact symbols in the matching
P08CounterRuntime object. Their SIL reference closures contain respectively
912/1,035/1,063 nodes and 269/281/282 bodyless nodes. The union has 282 bodyless
nodes: 272 have defined matching object symbols; none gains a serialized body
from the 11 indexes. The remaining ten are external Swift/runtime/printing or
library operations, listed by exact symbol and first parent in the inventory.

These are **conservative reference closures**, not feasible execution graphs.
They include address-taken callbacks, Dynamic descriptor alternatives and
observation/transcript code. They do not infer targets of indirect calls, reject
branches using invented invariants, or turn symbol existence into an executed
heap event. The union retains 106 indirect SIL call sites, including 37 witness
sites. The host root alone retains 29 witness sites plus 69 callback/argument
sites. The object closure retains 852 indirect branches and 1,892 external
branch sites to 56 exact symbols without an exact retained disassembly header.
These counts measure remaining attribution work, not 852 feasible unknown calls
or 56 demonstrated defects. Code-address relocations are included as potential
callback targets; metadata/data relocations remain data observations.

`OUTLINED_FUNCTION_n` names are resolved within their own object. Cross-object
definitions are retained separately; duplicate Swift generic definitions do not
select a linked winner. A symbol alias without an exact disassembly header,
runtime-invoked metadata/value witness, or unrecorded linker choice remains an
explicit limit. The program performs no numeric whole-stack or allocator proof.

## Actual adopted paths and edge dispositions

The following source/SIL/object joins are the semantic interpretation layered on
the complete mechanical inventory. `SIL` denotes the raw actual-host SIL;
`P08 object` and `GiftUI object` denote their captured disassembly text.

| Edge | Actual path and exact evidence | Disposition |
| --- | --- | --- |
| E01 — physical owner to session | CounterScopedStorage.swift 1238–1355 nests b0–b3, g0–g4 and c0/h0/r0/r1/h1 typed loans around `p08ConstructStaticStorageSession` and its consuming body. Constructor at source 1103 / SIL 82022 creates `.static` geometry and all five `.static` bank descriptors from one borrowed session token. | Source shape, concrete constructor and lifetime-bearing calls resolved. Whole 14-loan safety/cost proof is not implied. |
| E02 — original outer lenders | Source 2462 `withP08SelectedStatic` encloses root/semantic/canvas/control and five span/buffer callbacks inside the reservation. SIL 400014–400832 (`p08RunPreparedStaticHost` and nested closures) retains the foreign scope, model/root, semantic, Canvas, session and owned result flow. | Original loans remain enclosing; extracted raw pointer descriptors alone do not replace these duties. |
| E03 — supplied to host | Source 2495 `P08StorageSession.intoSupplied` preserves the complete consuming union; source 2600 onward constructs/finishes the original Static host. SIL 389787 construction, 391862 owner initializer, 391994 session phase and 385320 host phase carry the concrete P08 access types. | Actual host route resolved at concrete type level. Per-return cleanup, every independent origin and Optional lifetime still require complete safety evidence. |
| E04 — activated cycle | Host activation/checked joins lead through Static coordinator and `RuntimeCompletePipeline` stage specializations to semantic expansion, layout, Canvas drawing, render preflight/production, offer resolution and retirement. Concrete references, ordinary ABI leaves and witness/closure sites are retained with exact source lines in the two inventories. | No generic-only surrogate was used. Ordinary ABI, callback and cold/runtime leaves still prevent a complete cost/safety PASS. |
| E05 — ordinary Text | SIL 598700/598701 in specialized `SemanticExpansionTraversal.expandFixedChild` and 600950/600951 in specialized `CanvasSemanticPayloadCodec.primitive` call ordinary `BoundedText.withUTF8<()>()`. Both use a no-throw application with an on-stack callback; declaration at SIL 601691 has zero blocks. GiftUI object 0x77c, text line 552, supplies its actual ABI implementation. | ABI identity resolved; cold metadata and indirect/value-witness costs remain U01 below. Ordinary admitted Text makes this a required path. |
| E06 — candidate resolution | Concrete P08 `InteractionState.resolveCandidate` at SIL 594958 has direct committed/hit exchange references at 595001/595006, then candidate/hit/prepared-record resets at 595020/595025/595030. Successful commit records the presentation revision; reset clears candidate limits/error/phase. Invalid phase branches return. `resetAllStorage` at 594354 resets all five banks and clears the committed revision too. | Selected transactional/reset paths resolved; no new E/F metadata blocker is inferred at these sites. |
| E07 — descriptor alternatives | P08CandidateAccess.reset at SIL 76149 switches `.static` to bounded Optional clearing and `.dynamic` to a Dynamic storage reset. Actual P08 object 0x196a8, line 32157, confirms the static count loop, concrete Optional initializer and fixed copies; 0x1970c is its Dynamic alternative. Source 1103 and immutable descriptors establish the selected Static origin. Committed/hit access methods retain analogous explicit switches and exchange checks. | Dynamic COW/Array allocation code is not attributed to the feasible Static descriptor path. The scoped-storage control root also intentionally exercises Dynamic alternatives; its counts do not qualify a Dynamic profile. |
| E08 — merged reset/init helpers | P08 object's `StaticTwoInteractionCandidateStorage...Tg5Tm` at 0x12344 (22991) accepts a concrete initializer function pointer and uses a count-bounded loop with outlined copy helpers. `.WOi0_` functions must be inspected individually: Optional SemanticCompleteIdentity at 0xf8b8, Optional P08StorageSession at 0xb37fc (222562), and Optional ownership in GiftUIObservableState at 0xb7c (1129) use scalar/vector stores and/or tail `bzero`. | These selected bodies are retained and understood as initialization/clear/copy work. `Tm`/`WOi0_` suffixes alone imply neither allocation nor free work. No aggregate stack/copy-cost result follows. |
| E09 — observation/dispatch | `_GiftUIObservableChangeSink.reportChange` has a loaded C callback at SIL 3992. Model attachment/ticket/association checks and runtime action bridge enter the concrete counter operation. Some closures are specialized/on-stack; other callback arguments remain indirect. | Exact dispatch sites retained. The C function-pointer target/provenance and complete lifetime/quiescence proof remain U03. |
| E10 — retirement/backing last | Source 2619 installs `defer { host?.p08FinishOriginalStaticHost() }`; source 2477/2480 encloses final vacancy check and reservation finish. `p08CompleteBody` checks quiescence and retires producer origin; `withStorage` ends token/pointee loans before `requireEmpty` and returning to idle. Reconstruction deinitializes/reinitializes typed root/semantic/canvas/control only between retired hosts. | Required source order is present. The retained two-host/early-return controls contribute behavior evidence, not complete unsafe-bridge or all-profile proof. |

The main Static host source is a finite nine-scenario loop plus a two-host reuse
sequence. Namespace-exhaustion throws exist in its SIL, but a fresh namespace
issuing this bounded number of IDs cannot reach exhaustion under the inspected
source invariants. Those root error boxes are not demonstrated feasible
allocations. Failure cases inside admitted semantic/model operations still need
their own cause and feasibility classification; global `allocate` effects do not
classify them.

## Required unresolved edges and safety limits

| Open edge | Reproducible evidence and exact missing proof | Effect |
| --- | --- | --- |
| U01 — Text cold metadata/callback/value witness | GiftUI `BoundedText.withUTF8` 0x77c reserves 0xf0; at 0x7cc calls `__swift_instantiateConcreteTypeFromMangledName` for Error metadata, loads ErrorWS and a closure thunk, then at 0x804 calls generic `withUnsafeBytes`. That generic body **is retained** at 0x874 (line 634): fixed 0x40 plus runtime-aligned Error-value storage, callback `blr x9` at 0x8c4 and conditional error value-witness move `blr x8` at 0x8dc. The closure thunk at 0x838 invokes its captured callback via `blr x10`. Instantiation helper at 0x8fc has cached and cold branches; cold calls external `swift_getTypeByMangledNameInContext2` at 0x930. | Concrete local bodies resolved. Full cold runtime cost, dynamic storage bound, selected callback/witness chain and linked implementation attribution are unproved. No heap event or whole-stack number is asserted. Blocks required complete-callee PASS. |
| U02 — residual ordinary ABI/metadata/witness closure | The inventory enumerates every bodyless symbol, object relocation and 56 external branch symbols, including once/metadata/associated-type/conformance access, enum and Optional helpers, Equatable dispatch, access checking, memory functions and runtime ownership. Host SIL retains InputSourceID/PointerSequenceID/NormalizedPointerEvent Equatable sites, four text mapScalar witness sites and one opaque disabled-Button traversal witness. SIL 605427 exposes the text mapScalar witness target; 605435–605439 are external Equatable tables. | A named witness table or object definition can resolve identity without proving its complete cost. Remaining targets, cold initialization, feasible branches and temporal nesting have not been exhaustively discharged. Union external symbols include Dynamic and observer operations, so they are not all Static blockers. |
| U03 — callback/unsafe ownership and lifetime | Loaded C callback SIL 3992, closure argument calls in nested owner loans/root scopes, publication/reader bridges, dispatch callbacks and consumed Optional host/coordinator retirement must preserve validated origin, exclusivity, association generation, quiescence and backing-last order. Compile lifetime markers and private access classifiers do not prove every unsafe bridge or reentry path. | No new escaping/copying defect is established here. Complete adopted-chain safety remains unproved; privacy PASS cannot waive it. |
| U04 — observer/transcript attribution | CounterPipelineOwner.swift 765 prints `counterTrace` on non-Embedded. CounterScopedStorage.swift 1685 interpolates and prints reuse labels. SIL 339712 and 401453–401973 retain Any-array/String/print construction; additional assertion failure diagnostics and host/wake/frame transcripts occur in the inventories. Dynamic alternatives retain genuine Array/COW code. | Ordinary capture cannot qualify a silent/observed diagnostic variant. Observer costs must be attributed from exact windows/variants; neither counting every allocation-looking instruction nor excluding all transcript/runtime cost establishes zero heap. |
| U05 — complete safety matrix and target resources | The retained counter426 result qualifies 384 paired scoped checks, supplemental/reuse controls and the native fatal-access result for macOS Static. This collection adds 93 privacy classifications only. It creates no fresh four-profile chain, target ABI/image, complete stack/RAM/flash or allocation observation. | HC-SO-001/002/003, RP-SO and IN-SO rows retain their existing unmet dispositions. No complete safety/physical-fit/current-image or P08 acceptance result follows. |

The 93 classifiers contribute **32 positive exit-zero controls and 61 negative
controls with the expected error(s)**. They cover wrapper/helper/state-storage
privacy, checked lenders, host controller, pipeline helpers/constructors,
resolver internals, observable key/binding/control/phase access, callback ticket
and root helpers, Canvas writer/reference construction, semantic C borrow/return
escape, and E/F getter/setter/internal-field boundaries. They support the exact
tested access and return restrictions at the frozen imports. They are not the
independent geometry/five-bank/model/root/semantic/value/control/activation-span
copy/Optional/escape/exclusivity matrix and do not execute cleanup or callback
quiescence. No positive twin, diagnostic or required count was weakened here.

## Disposition and next bounded step

Collection integrity and the selected source/compiled identity, constructor,
Static descriptor, reset/role and helper observations above **PASS within their
stated boundaries**. Required **complete current-callee and safety PASS is not
established**. U01 alone supplies a concrete required unresolved cold edge;
U02–U05 prevent promoting the other observations into full conformance.
`current_callee_review` is stopped/incomplete and `strict_cold_eligible` remains
false. This is an evidence insufficiency result, not a proof that ADR-039 or the
strict contract is impossible, or a permission to change it.

The next bounded step is independent review of this interpretation, then
compiler-free attribution of U01–U03 against these **same retained bytes**:
resolve exact callback/value-witness and local outlined-helper targets, classify
the 56 external symbol groups by actual Static feasibility, and join the existing
safety corpus to each original lifetime/return/retirement obligation. Record any
runtime/library or fresh safety evidence that genuinely cannot be supplied from
retained inputs as a concrete separately bounded preparation request. No new
execution, source repair, alternate compiler route or automatic collection
successor is granted here. A contract/scope/ownership/privacy/bound decision must
go upstream for the maintainer's requested Astra Medium decision; this packet
does not make one.

Only a separately established required current-callee **and** safety PASS can
release preparation of a new current strict-cold manifest for the existing
`native-cold-static-candidate/run.py --prepared` route. Preserve its exact
host-first baseline, silent, observed and ordinary windows, workload counts,
baselines and zero-heap enforcement. The historical prepared manifest/counts
are not silently applicable to current source. The existing runner itself calls
its allocation result unclassified until attribution; a successful diagnostic
run would not alone satisfy all allocator gates.

Collection allowance remains **1/1 consumed**, zero automatic source/tooling
repairs and zero retries, marker `[16777234, 29640436]` unchanged. All historical
allowances and stopped receipts remain closed. P08/R07/T8.1, all still-unmet SO,
strict-cold, zero-heap, ABI/resource, four-profile, independent exit and later
conformance obligations remain open.
