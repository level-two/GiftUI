---
spec: SPEC-006
feature: giftui-mvp-architecture
title: Implementation Design — Runtime Record Banks
status: current
authors:
  - codex
created: 2026-10-11
updated: 2026-10-27
implementation_plan: ../implementation-plans/spec-006-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Runtime Record Banks

This is a replaceable internal realization, not architectural or contract
approval. It implements [SPEC-006's runtime amendment](../specs/spec-006-declarative-view-semantics.md#rfc-014-runtime-amendment),
DV-RD-002–004 and owner T10.1 within RFC-014 P04. [ADR-035](../adrs/adr-035-runtime-derived-records-and-exact-identity.md)
owns the two-bank/exact-path decision; [ADR-036](../adrs/adr-036-scoped-model-access-and-bounded-ownership.md)
owns model reads and [SPEC-013](../specs/spec-013-runtime-profiles.md#limits-ownership-and-storage)
owns configured physical bounds. P05 owns the Layout projection and committed
Interaction keys; P06 owns Canvas codecs; P07 owns coordinated publication;
P08/P09 own application vocabulary/workload adoption. This note authorizes none
of those successors.

## One traversal and its scoped body join

`GiftUISemanticCore.swift` retains the existing structural/counting traversal.
`SemanticStatefulBinding` is now a noncopyable/nonescapable-capable body bridge.
`ObservableSemanticBodyBinding` borrows the existing model and State root scopes;
it binds direct State declarations before the count reservation/body callback.
An owned body returns only after its read ends. The visitor then traverses it,
allowing child discovery without retaining a parent read. The visitor stops on
any semantic, State binding or access failure. Access failures remain typed and
separate for the coordinator; Semantic Core imports only GiftUI.

The bridge is consumed into the noncopyable/nonescapable visitor for one call.
Its lifetime depends on real model/root borrows. No old unscoped body adapter or
second expansion engine remains. Historical callers are migrated by their
ordered packages; the selected-file P04 driver is not a whole-module pass.

## Representation

`SemanticRuntimeRecords.swift` defines ordered records, prefix entries, complete
keys, pool limits and the append/match primitives. A record's ordinal is its
position in its own bank. It holds parent/first-child/last-child/next-sibling
links, exact path index, kind, canonical payload index and text range. Modifier
records additionally store source-order chain index. `UInt16.max` is a sentinel,
never an initialized position. All parent/child topology arises during traversal.

Each path entry stores its parent, bounded child links/count, component/depth,
nearest semantic record, and one matched-published-path scratch field. Components
contain kind, child/branch ordinal, finite concrete role and modifier
discriminator. The traversal maintains a complete path value as temporary
workspace state. Only declaration entries emit records; intermediate custom,
child, branch and optional boundaries remain exact path entries.

`SemanticCompleteIdentity` owns its complete components and no bank address or
index. Its current physical extent is the approved analyzer depth of 34; the
record-limit initializer rejects a larger requested extent rather than clamping
it or increasing the workload bound. Equality compares count and every component.
This key is available for State and independent Interaction-owned copies. Its
size and recursive copies must be counted in complete stack/storage audits;
compact path banks do not make those costs zero.

`SemanticRecordReference` is a checked bank/ordinal reference, not semantic
identity. It also carries store owner and bank revision. Host assembly issues
store identities from a noncopyable namespace retained through reassembly.
View access rejects another store/bank/revision. Exact cross-bank equality uses
complete paths; equal indices alone have no meaning.

## Canonical consumer pool amendment — 2026-10-26

The selected Astra P08 realization replaces the former generic combined payload
pool with one nongeneric `SemanticRecordPayload` vocabulary: `.standard` wraps
`SemanticStandardPayload`, and `.canvas` is a marker without a capture. Both
semantic banks use optional canonical payload slots. `SemanticRecordStore`, its
bank buffers, writer and borrowed view, and `SemanticRecordLayoutView` and
`SemanticRecordRenderView` are nongeneric. There is no parallel consumer graph
or retained generic copy of the canonical bank. The two-bank topology, exact
identity, configured capacities and failure contracts remain unchanged.

Concrete Canvas captures remain in separate typed pending storage at the
existing attempt owner. `CanvasPendingMetadata` tracks the initialized count
and store owner, bank and revision. Parallel initialized buffers hold
`Table.CaptureStorage?` values and canonical payload ordinals. Their dense
pending index is independent of the canonical payload ordinal: ordinary values
and modifiers can occupy intervening canonical slots. Pending capacity follows
the semantic-node bound: 48 in the component/Cycle presets and 24 in Counter,
rather than the later
Canvas occurrence or staged-value capacity. This bounds reserved storage; it
does not add a generic pending consumer facade.

`withCanvasSemanticPayloadCodec` checks inactive metadata and backing extents,
then borrows the metadata and both typed buffers for its scoped callback. The
borrowed `CanvasSemanticPayloadCodec<Roles, Table>` instance is passed to
expansion and retained only within that loan by any scoped pipeline owner.
Its preparation checks the semantic-node capacity. This lender precedes
expansion at the existing semantic attempt scope. It does not construct
`CanvasStagedValues`: that later lender, including Table validation and capacity
refusal, stays at its existing point. Moving it earlier would change observable
failure precedence and is excluded from this realization.

Canvas recording preflights the canonical payload and byte bounds before
reserving a pending slot and committing the canonical marker. The first pending
capture establishes the store/bank/revision association; later captures must
match it. Transfer validates that association and reader state before touching
captures, then checks each dense entry's canonical ordinal against the pending
record. Successful entries become consumer-readable Canvas primitives while
retaining only the marker. Candidate borrowing and publication reject any
remaining pending Canvas records.

`discardCandidate(using:)` preserves the candidate/phase and association checks
before releasing the typed side pool. Transfer rejects a foreign codec without
destroying either candidate or its captures. A failure during an associated
transfer discards staged values and uses the same codec for candidate cleanup;
expansion failure releases its pending captures and candidate before returning.
The checked lender also clears pending storage on scope exit. These are
complementary cleanup boundaries, not permission to clear an unrelated attempt.
Bank readers still defer retirement and reuse until their last borrow ends.

This amendment records the 26 October source direction within the approved
contracts. The supplied-owner amendment below supersedes its generic codec
construction detail. Historical P04 evidence remains evidence for its recorded
snapshot. The original canonical-pool candidate required a compiled gate:
generic codec specialization and the actual construction, copying, transfer
and destruction of typed captures remain unproved costs. A nongeneric consumer
name, small descriptor, lifetime annotation or inlining spelling establishes
neither allocation freedom nor stack or physical-budget fit. The compiled gate
must preserve negative lifetime causes, association and failure precedence,
immediate cleanup and destructor coverage, and qualify the actual emitted
capture and codec paths before any such resource claim.

## Supplied concrete Sink and Codec amendment — 2026-10-27

The canonical consumer pool remains unchanged. The actual supplied Sink and
Codec types are now concrete profile types, rather than aliases or wrappers
around generic owned carriers. Semantic Core owns the nongeneric, nonescapable
`SemanticRecordSinkState`: its private bank descriptors, counters, bounds,
writer construction, validation and publication implement the existing shared
algorithm. Each finite concrete sink holds that state and its concrete codec;
its protocol witnesses forward to Core and the typed payload operations.
The shared traversal and its six staging/publication/reset obligations remain
the sole expansion engine.

`SemanticRecordPayloadCodec` supplies its associated concrete Sink through a
typed factory. The Drawing `CanvasSemanticPayloadCodec` protocol supplies a
concrete codec factory to the existing checked lender. Canvas codecs store the
existing metadata pointer, typed capture and ordinal buffer descriptors and
capacity directly. Neither factory constructs a generic owned intermediary,
retained closure, existential or registration table. Both actual backing and
non-escapable codec loans constrain the resulting sink. Empty Escapable
standard-only fixture codecs have no borrowed state of their own, so their
concrete sinks retain the backing-state dependency alone.

The checked lender still owns the three backing loans and scope-exit cleanup.
Inside its synchronous payload and transfer callbacks, individual descriptor
values are copied while those loans remain live; captures and metadata are not
snapshotted. Canonical preflight precedes all reservation reads and mutations.
Transfer validates the candidate before acquiring cleanup authority, stages
before clearing a capture, and discards staged values before matching pending
cleanup on failure. Reader retirement, partial initialization and populated
teardown retain their existing ordering and charges.

This adds finite adapter maintenance and package-visible construction/state
operations with private bookkeeping, rather than a second semantic algorithm.
It does not change public contracts, invocation signatures, payload capacities
or physical-storage accounting. The compiled evidence supports removal of the
standalone generic Sink/Codec ownership and cleanup dependency, including the
direct owner/capture lifecycle. The baseline already required a generic
Traversal visitor operation; its changed Workspace/Sink key remains separately
unqualified for allocation safety. No whole-traversal, cold, stack, resource or
overall P08 conformance follows from this scoped result. The complete current functional
validation and final artifact applicability have passed independent review for
this scoped package; see the [scoped result](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-p08-finalization-result/allocation/canonical-supplied-sink-full2-validation.json)
and [independent review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-p08-finalization-result/allocation/canonical-supplied-sink-full2-review.md).

## Bounded matching and failure

Append validates component algebra, initialized earlier parents, duplicate
children, depth, prefix capacity and child fanout before mutation. Each entered
prefix is unique within its parent. Structural append reserves its independent
record capacity. A codec reserves a complete canonical payload slot, all text scalar
slots and their byte charge before storing anything. Byte charge uses actual
`MemoryLayout<SemanticRecordPayload?>.stride` plus scalar bytes. A pending Canvas
also charges `MemoryLayout<Table.CaptureStorage?>.stride` and
`MemoryLayout<UInt16>.stride` for its typed capture and ordinal. Physical
backing/audit must separately count every reserved pending slot and ordinal,
including unused capacity, pending metadata, enclosing padding and alignment,
as well as both canonical banks. Logical occupancy charges do not replace this
reserved-storage accounting or authorize a larger configured byte limit.

Count limits retain the existing detection rules. Independently bounded payload
failures are reported through `SemanticExpansionSink.stagingFailure`; count-only
sinks have no such pool and retain invariant failure for an unexplained refusal.
Unknown finite roles are invalid identity. Unknown codecs are invariant failure,
with no generic/existential fallback. Any expansion failure clears the complete
candidate and preserves the published bank.

Reconciliation visits candidate prefixes in append order. A candidate's parent
has already been matched. The algorithm scans only that published parent's
children and compares complete component fields; unmatched parents terminate
the descendant match. Root mismatch likewise prevents descendant matches.
With configured fanout K this performs at most N × K component comparisons.
The per-entry match index is bounded scratch, not persistent State/action
identity. No all-pairs record scan, hash match or path-prefix shortcut is used.

## Banks, readers and profile ownership

`withSemanticRecordStore` nests borrows of five actual initialized typed backing
regions (metadata, records, paths, optional canonical payload slots, scalars). It
partitions each data region into disjoint banks. The private scope initializer's
pointer-descriptor annotations are not the ownership proof: the enclosing
backing borrows and Escapable callback result establish that proof. Readers are
nonescapable and lent only inside that lifetime. Teardown clears all initialized
payloads after the final callback/reader has ended.

A bank moves idle → expanding → candidate → published. Previous publication
becomes retired; it returns to idle only after its last reader ends. A complete
candidate may be borrowed before publication only after pending Canvas transfer
has completed. A failed expansion never publishes.
Publishing performs paired matching then changes semantic bank roles. The
coordinator still must prepare and atomically join the other candidate products;
this primitive does not commit accepted-offer action routing.

While an old published reader survives a swap, that bank cannot be reused.
With both banks occupied, a new attempt refuses at capacity. Candidate discard
also respects live candidate readers. Reference revisions never wrap into reuse.
Copied complete keys remain independent of any bank retirement.

Static assembly supplies typed initialized spans before activation through
`StaticSemanticRecordStorage`. Dynamic owns configured typed arrays
through `DynamicSemanticRecordStorage`, auditing their actual retained extents
and enforcing the same pool rules. Neither adapter invents topology. The old
application host storage/callers remain migration inputs until their ordered
adoption/removal gates; they are not a second new traversal implementation.

## Payload vocabulary and evidence boundaries

`SemanticStandardPayloadCodec` provides shared static operations for finite
scalar/layout/style/action values.
Text decodes admitted bounded UTF-8 into bounded scalar scratch before one pool
preflight/copy. Invalid authored text preserves the existing invalid-scalar
sentinel for its owning consumer. The codec never stores a declaration, model,
handler or closure. No owned generic standard-codec instance is constructed;
unsupported Canvas payloads are refused. The finite Canvas codec uses the same canonical writer seam and the
separate typed pending storage described in the dated amendment.

Concrete role inventories are finite type codecs. They must assign distinct
stable roles, including opaque framework wrapper types reached through inferred
Body/type witnesses; occurrence-order role allocation is excluded. Full
application vocabulary/workload validation remains P08/P09. Payload changes do
not affect a type's role/discriminator.

The [P04 progress receipt](../../Tests/ContractFixtures/SPEC006/Evidence/rfc-014-p04/progress.md)
records each step's source/artifact identity and explicit limits. The historical final implementation packet covered
the actual scoped join, bank primitives, declaration emission/profile differential,
four-profile compilation/layouts and borrowed-view escape rejection. Separate Strong
review passed the finite P04 exit for that snapshot; those receipts do not qualify
the current canonical-pool candidate. Object sizes alone do not prove allocation freedom, physical
budget fit, full feasible-path stack or target execution. P10–P12 retain the
owner's complete criterion/resource/adoption dispositions.

No optional deferred work or new architecture was introduced. A missing current
capacity/lifetime contract would stop P04 and return to its owning Spec.

## P04 component resource envelope

A record is emitted for each entered declaration role. Its path adds that role
and at most two incoming boundaries: conditional/optional adds a branch/presence
plus fixed child; root, custom body and ordinary children need one. Structural
declarations that introduce boundaries themselves also emit a role. Thus the
selected visitor needs at most three entries per structural occurrence;
the independently configured 378-entry pool covers 126 × 3. This is not permission to raise the approved
record/depth/fanout limits. Finite supported roles are checked explicitly.
Payload slots need at most semantic nodes plus modifiers: 48 + 50 = 98, since
action is included in semantic nodes. Text retains its separate 224-scalar
bound. The component/Cycle pending capture and ordinal buffers each reserve 48 slots
at the attempt owner, independently of later staged Canvas backing. Their
complete retained extent, metadata and padding must be charged once alongside
the later staged storage, without hiding it in canonical slot deltas or counting
it again as enclosing-owner padding. Unknown payload vocabulary refuses rather
than adding hidden storage.

The actual-declaration fixture observes peaks 5 records / 11 prefixes / 3 payloads /
2 scalars / depth 9; maximum fixed fanout is separately exercised at five.
These component probes are not the actual counter/analyzer applications.
P08/P09 must measure their vocabulary/workload peaks before host integration;
P11 must include physical reserved banks, headers, independent committed keys,
206-byte complete-key temporaries/recursive copies and 384-byte scalar decode
scratch in target storage and feasible-path stack totals. Compiler layout
receipts distinguish each target; object size is not a resource proof.

The configured Cycle payload cap remains **7168 bytes**, and Counter remains
**4096 bytes**. These original numeric limits do not change when a former
layout-derived expression changes meaning. Canonical and pending charges use
the new physical representation; descriptors and refusal tests are not retuned
to make an over-limit candidate pass.
