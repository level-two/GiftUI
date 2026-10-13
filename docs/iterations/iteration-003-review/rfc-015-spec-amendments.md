# RFC-015 exact Specification amendment packet — 2026-10-13

**Proposed; non-authoritative.** RFC-015 is approved at `ec29db3c`;
[ADR-039](../../adrs/adr-039-scoped-storage-ownership.md) is proposed. No live
Specification changes in this packet. Accept ADR-039 before approving the exact
sections S11, S13 and S15 below; apply approved text verbatim at the named anchors.
Their criteria supplement existing criteria without closing any checkbox or
changing current implementing status. B1–B4 remain downstream obligations.

## Source inventory and application instructions

- Approved [RFC-015](../../rfcs/rfc-015-p08-scoped-storage-ownership.md): six protocol
  headers, exact carriers, conditional conformances, R2 consumers, R3/R4 initialization,
  retirement and B1–B4. [Approval record](rfc-015-readiness-and-approval.md).
- Accepted ADR-007/008/035/036/038: composition/import direction, independent keys,
  stable backing/model pins and exact construction inputs; no supersession selected.
- Implementing [SPEC-011](../../specs/spec-011-interaction.md), RFC-014 runtime
  amendment, Types / APIs, candidate behavior and State / Lifecycle; existing IN-RD-001/002.
- Implementing [SPEC-013](../../specs/spec-013-runtime-profiles.md), RFC-014 runtime
  amendment including both approved coordinator corrections; RP-RD-001–004.
- Implementing [SPEC-015](../../specs/spec-015-host-configuration.md), RFC-014 runtime
  amendment, Owners/resource ledger, State / Lifecycle; HC-RD-001–004.
- Current source: GiftUIInteraction storage/values/state/owned-key state;
  GiftUIRuntimeCore Interaction bridges/transaction/coordinator/resolution/dispatcher;
  Static/Dynamic Interaction storage and execution coordinators;
  SPEC015 RuntimeDerived Counter geometry/pipeline/host/storage measurement and
  Dynamic counterparts; SignalAnalyzerTargetHost consumers listed in S11.3.
- Owner plans SPEC-011 T12.1, SPEC-013 T11.1, SPEC-015 T8.1 and shared RFC-014
  P08/R07 remain open. Prior finite passes remain evidence only for their exact source.

When applying, add ADR-039 to each affected Spec's related_adrs and Related ADRs;
link this packet and the accepted ADR from each inserted section. Keep all prior
accepted ADR links. Section S11 replaces only the six protocol declaration
headers/owned-state implicit constraints where those conflict; unchanged methods
and existing semantic contracts remain normative. S13 and S15 add the specified
constraints to their existing runtime amendments. No unrelated declaration changes
are approved by these instructions. All text under S11/S13/S15, including criteria,
is the concrete proposed contract; implementation names are internal, not public API.

## S11 — insert before SPEC-011 RFC-014 amendment's IN-RD-001

### S11.1 Scoped storage and state declarations

The following six package protocols MUST permit noncopyable and nonescapable Self.
Replace their declaration headers with these exact headers, preserving every
existing requirement and owned Identity/record/result type:

```swift
package protocol InteractionCandidateRecordStorage: ~Copyable, ~Escapable
package protocol InteractionCommittedRecordStorage: ~Copyable, ~Escapable
package protocol InteractionHitRegionStorage: ~Copyable, ~Escapable
package protocol InteractionCandidateBuilder: ~Copyable, ~Escapable
package protocol InteractionGestureResolver: ~Copyable, ~Escapable
package protocol InteractionCommittedActionView: ~Copyable, ~Escapable
```

In these header fragments the existing braces/body follow unchanged. Storage
count/capacity remain UInt16; reset/append/replace/exchange remain mutating,
record/region reads remain borrowing and return owned optional records. Builder
begin/append/assignGeneration/finish/resolve remain mutating with their existing
owned errors/results. Gesture and committed reads remain borrowing with owned
results. No nonescapable associated type and no seventh protocol relaxation is added.

Replace implicit owned constraints of the two state declarations with the following
exact constraints (generic parameter spelling may be expanded without semantic change):

```swift
package struct InteractionState<C, R, H>: ~Copyable, ~Escapable,
    InteractionCandidateBuilder, InteractionCommittedActionView, InteractionGestureResolver
where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
      R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
      H: InteractionHitRegionStorage & ~Copyable & ~Escapable,
      C.Identity == R.Identity, C.Identity == H.Identity

package struct InteractionOwnedKeyState<C, R, H>: ~Copyable, ~Escapable,
    InteractionCandidateBuilder, InteractionCommittedActionView, InteractionGestureResolver
where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
      R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
      H: InteractionHitRegionStorage & ~Copyable & ~Escapable,
      C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity,
      H.Identity == SemanticCompleteIdentity
```

InteractionState retains exactly five lifetime-bearing stored values: candidateRecords C,
candidateHitRegions H, candidateCommittedRecords R, committedRecords R and
committedHitRegions H. Its other fields remain owned Phase, optional limits,
optional candidate error and optional presentation revision. Its consuming initializer
MUST depend on all five arguments:

```swift
@_lifetime(copy candidateRecords, copy candidateHitRegions,
           copy candidateCommittedRecords, copy committedRecords, copy committedHitRegions)
package init(candidateRecords: consuming C, candidateHitRegions: consuming H,
             candidateCommittedRecords: consuming R, committedRecords: consuming R,
             committedHitRegions: consuming H)
```

InteractionOwnedKeyState retains state plus its existing owned UInt16/UInt32 counters,
Bool staging flag and optional error; no additional lease, closure or pointer field.
Its existing failable initializer becomes:

```swift
@_lifetime(copy state)
package init?(state: consuming InteractionState<C, R, H>,
              maximumComponentsPerKey: UInt16, maximumComponents: UInt32)

extension InteractionState: Copyable
where C: Copyable & ~Escapable, R: Copyable & ~Escapable, H: Copyable & ~Escapable {}
extension InteractionState: Escapable
where C: Escapable & ~Copyable, R: Escapable & ~Copyable, H: Escapable & ~Copyable {}
extension InteractionOwnedKeyState: Copyable
where C: Copyable & ~Escapable, R: Copyable & ~Escapable, H: Copyable & ~Escapable {}
extension InteractionOwnedKeyState: Escapable
where C: Escapable & ~Copyable, R: Escapable & ~Copyable, H: Escapable & ~Copyable {}
```

All original protocol/Identity equalities continue to apply to these extensions.
Owned inputs MUST retain owned return/copy semantics including the failable Optional;
scoped inputs MUST retain every dependence. A second owned state machine or lifetime
erasure is forbidden. Both withBacking callbacks MUST be removed from supported
callers and replaced with owned bounded measurement operations; no callback exports
a storage capability. Measurements MUST describe physical retained banks, never
substitute adapter MemoryLayout for bank bytes.

### S11.2 Access and transaction semantics

Only reviewed trusted package/fixture code may conform these protocols. They are
not outside-package extension points; package visibility does not seal conformances.
Safe client entry points MUST use validated concrete owners/configuration, never an
arbitrary conformer claiming disjointness. Access constructors and physical fields
MUST be restricted; no pointer/base/bank getter, descriptor conversion, `_read`/
`_modify`, duplicating borrowed mutable capability or lifetime-erased adapter is exposed.

The finite P08 accesses MUST be ~Copyable and ~Escapable and share the common
actual-owner session specified in S13. Interaction controls phase, counts, revision
and bounded complete copied keys once. Storage never substitutes semantic indices,
hashes or borrowed path references for complete keys. Exact identity, generations,
capacity-first-excess behavior, failure precedence and accepted-offer rules remain.

Initialization MUST validate distinct bank identities, common provenance, and equal
immutable logical capacity within each prepared/committed R and candidate/committed H
pair, sufficient for the configured action/hit limits. C also covers the action limit.
Unequal retained physical extents are valid when each covers the shared logical capacity;
unequal logical pair capacities or undersized extents fail before session acquisition.
Do not clamp workload limits. This finite rule does not alter owned-store constructors.

After existing finishCandidate preflight, accepted offer exchanges both complete R/H
role descriptors (address plus bank-local count/extent metadata) and revision without
allocation, bank copy, fallible work or observer/reentry exposure between them. Logical
capacity and session lifetime/provenance remain invariant. Physical destruction stays
with original initialized objects. Reset targets former committed banks. Refusal/discard
exchanges nothing, resets candidate/prepared storage and preserves committed routing.

### S11.3 Consumer compatibility

Operation-only generic parameters MUST explicitly admit both suppressions while
preserving existing identity/model/role constraints and owned results:

| File under Sources | Parameter / operation |
| --- | --- |
| GiftUIInteraction/ExecutionGestureAdapter.swift | Resolver: InteractionGestureResolver & ~Copyable & ~Escapable for down/move/up; borrowed resolver |
| GiftUIRuntimeCore/RuntimeRecordInteractionBridge.swift | Candidate/Committed/Hits storage permissions in append/appendProjected; borrowed Records: InteractionCommittedActionView & ~Copyable & ~Escapable in dispatch |
| GiftUIRuntimeCore/RuntimeRecordCanvasInteractionBridge.swift | Candidate/Committed/Hits storage permissions in append |
| GiftUIRuntimeCore/RuntimeInteractionCandidateTransaction.swift | Interaction: InteractionCandidateBuilder & ~Copyable & ~Escapable in inout build |
| GiftUIRuntimeCore/RuntimeInteractionCandidateCoordinator.swift | Same Interaction bound in build/discardCandidates |
| GiftUIRuntimeCore/RuntimeInteractionCandidateResolution.swift | Same Interaction bound in resolve |

RuntimeInteractionDispatcher's retained Records MUST explicitly require
InteractionCommittedActionView & Copyable & Escapable; Handler/TargetAccess,
non-consuming initializer and InteractionDispatcher conformance remain owned.
Counter dispatch uses the operation-only bridge. A retained scoped dispatcher need
is an upstream decision; InteractionDispatcher MUST NOT be relaxed here.
Static/StaticSix/Dynamic banks and aliases retain owned semantics through conditional
state conformances. Analyzer Dynamic/Static action dispatchers and
StaticSignalAnalyzerNRFEmbeddedInteractionOwner stay owned. Analyzer presentation
pipeline, NRF application storage/committer/handler/input owner/candidate producer
and withInteraction callbacks stay owned, with ordinary owned Result and existing
pointer lifetime duties. Inventory all transitive/generated/test callers before
adoption; no newly required scoped retained consumer is authorized by this table.

### S11.4 Additional acceptance criteria

- [ ] **IN-SO-001:** All six declarations, both five-input/state initializer unions,
  conditional owned copy/escape and failable Optional cases pass the pinned four-profile
  positive/negative matrix; scoped state copy/escape is rejected for the intended reason.
- [ ] **IN-SO-002:** Same-session paired exchange tests record addresses/counts before
  and after repeated unequal-count swaps; equal logical/unequal sufficient physical
  extents succeed; unequal logical/undersized pairs fail before session. Accepted offers
  have both exchanges/revision, refusal/discard have none, keys survive semantic reuse
  and first-excess/identity/generation/stale-action transcripts retain existing outcomes.
- [ ] **IN-SO-003:** Complete caller inventory shows each S11.3 disposition and preserves
  owned analyzer/native returns; supported client negatives reject construction,
  extraction and arbitrary conformer entry. Measurement tests reconcile owned facts
  to every physical bank before/after role changes without adapter-size substitution.

## S13 — insert before SPEC-013 runtime Amendment acceptance criteria

### S13.1 Physical owner, session and coordinator contract

A unique noncopyable P08TypedBackingOwner MUST reserve final typed geometry and
five disjoint bank regions, with private fixed-capacity initialized-object inventory
and lifecycle flag. Interaction transaction metadata exists once in scoped state;
physical bookkeeping and separately supplied host control MUST NOT duplicate it.
An immutable private P08SessionLifetime: ~Escapable token MUST depend on the actual
owner's typed exclusive borrow enclosing the callback. Each concrete geometry/C/R/H
access constructor has `@_lifetime(copy sessionLifetime)` and a borrowing token input.
The token may be copied only as immutable lifetime/provenance evidence. All accesses
retain this common lifetime through moves/exchanges/retirement, never only a pointer
local's lifetime. Trusted construction validates same-session provenance and distinct
banks before ready-for-offer; no cross-session exchange is client-callable.

```swift
fileprivate func initializeP08Backing(
    _ backing: inout P08TypedBackingOwner
) -> P08BackingInitializationFailure?
fileprivate func withP08Storage<Result>(
    backing: inout P08TypedBackingOwner,
    _ body: (consuming P08StorageSession) -> Result
) -> Result
```

These are nonthrowing internal operations; initialization failures and Result are
ordinary owned values. Checked initialization validates all capacities, identities,
schema, alignment and disjointness before initializing. It records successful objects
and unwinds precisely that prefix in reverse on failure, clearing the inventory.
No session exists on failure. Success leaves initialized/idle storage. A second
initialization cannot overwrite it. Factory activation is exclusive, invokes body once
synchronously, and performs no fallible physical initialization. No scoped Result,
throwing callback cleanup, scoped error or trap recovery is promised.

The trusted consuming body MUST install structured logical cleanup before activation
and every possible owned-failure return. It owns stop/drain, candidate resolution,
pins/registrations, retirement and reset; the factory owns enclosing physical borrowing.
Failure before host construction releases only acquired scopes. Body completion returns
storage to initialized/idle only after quiescence, complete reset and access scope end.
Fresh sessions cannot retain old counts/records/revision/phase/gesture capture; initial
role assignment is restored only with all banks empty. Generations still obey stale-action
rules. Failed cleanup forbids reuse/release under existing invariant-failure disposition.
Final idle release destroys original inventory once in reverse and releases regions last.

Static/Dynamic coordinators retain explicit ~Copyable & ~Escapable Binding/Admission/
Opportunity parameters, package admission/opportunity getters with private setters,
consuming constructor and `@_lifetime(copy binding, copy admission, copy opportunity)`.
`takeQuiescedOpportunity() -> Opportunity?` retains `@_lifetime(copy self)`; consuming
its Optional must retain every storage/model/semantic/control dependence. Dynamic
uses its existing concrete scope types; pointer erasure is forbidden. Storage sessions
do not replace model frame/read pins or alter existing phase/publication order.

Structural borrowing excludes overlapping access where provable; Swift runtime
exclusivity is required otherwise and its enforcement must be recorded per configuration.
Trusted session state also excludes reentry, physical aliases and callbacks accessing
banks. Dynamic shared mutable/COW aliases cannot exist during access; any owned copy
is independent before activation. No unchecked Sendable or disabled-exclusivity fallback.

### S13.2 Accounting and criteria

The ledger MUST identify every physical geometry/bank object, control, descriptor,
provenance and inventory field with owner/count/stride/alignment/padding/lifetime and
actual linked section or stack path. Role exchange cannot alter retained bytes or
physical destruction attribution. Include construction/body-return temporaries,
all nested helper frames and feasible IRQ overlap, Static zero heap and bounded Dynamic
allocation/overhead; no missing path is zero. Preserve all existing target limits,
three model transition banks, source/admission storage and timing obligations.

- [ ] **RP-SO-001:** Physical inventory reconciles each initialized address and complete
  retained bytes before/after swaps. Fault injection at each typed acquisition proves
  reverse successful-prefix destruction exactly once, no live Optional overlay and no
  duplicate control/bank owner; below/equal/above capacities follow S11.2.
- [ ] **RP-SO-002:** Both profiles exercise early returns before host, failed activation,
  failed candidate, commit, refusal, quiescence and a fresh session. Ordered transcripts
  prove once-only candidate resolution/cleanup, reset and no stale session state; physical
  release occurs after every scoped user and callback. Actual coordinator Optional moves
  and runtime/static exclusivity cases have positive twins and classified evidence.
- [ ] **RP-SO-003:** All four pinned configurations cover the whole carrier matrix;
  actual linked images/complete feasible stack/IRQ ledgers prove unchanged resource/ABI
  limits and Static zero heap, with matched Dynamic costs. Unmeasured fit stays unmet.

## S15 — insert before SPEC-015 runtime Amendment acceptance criteria

### S15.1 Construction, transfers and retirement

CounterGeometry and CounterCandidateBacking/CounterCommittedBacking/CounterHitBacking
MUST explicitly admit ~Copyable and ~Escapable Self, retaining all existing owned
measurement/operation results. Concrete P08GeometryAccess/P08CandidateAccess/
P08CommittedAccess/P08HitAccess MUST be fileprivate, ~Copyable and ~Escapable with
private fields/constructors and SemanticCompleteIdentity for each bank's Identity.
P08StorageSession holds private geometry and scoped keys; its consuming constructor
has `@_lifetime(copy geometry, copy interaction)`. No capability accessor is exposed.

Supplied storage and pipeline, both profiles, and CounterRetiredStorage use this
complete generic constraint set, preserving their existing concrete scope types:

```swift
where G: CounterGeometry & ~Copyable & ~Escapable,
      C: CounterCandidateBacking & ~Copyable & ~Escapable,
      R: CounterCommittedBacking & ~Copyable & ~Escapable,
      H: CounterHitBacking & ~Copyable & ~Escapable,
      C.Identity == SemanticCompleteIdentity, R.Identity == SemanticCompleteIdentity,
      H.Identity == SemanticCompleteIdentity
```

Their base declarations are ~Copyable, ~Escapable; pipeline retains
RuntimeCompletePipelineOwner. Supplied/pipeline geometry and Interaction fields
become private. Consuming storage-transfer initializers MUST add
`copy geometry, copy interaction` to their existing `copy models, copy root,
copy semantic, copy values, copy scopedControl` union. The trusted raw-control route
instead preserves `borrow control` and adds the same two dependencies. Supplied
retains audit; pipeline retains owned limits/endpointConfiguration. Session.intoSupplied
consumes model/root/semantic/values/control and has `@_lifetime(copy self, copy models,
copy root, copy semantic, copy values, copy control)` with its existing owned audit.
No mandatory backing/origin is omitted from ADR-038's construction graph.

CounterRetiredStorage privately holds semantic, geometry and Interaction;
its consuming initializer has `@_lifetime(copy semantic, copy geometry, copy interaction)`.
Its `mutating resetAfterQuiescence()` retains `@_lifetime(self: copy self)`.
Supplied's consuming `retireInertStorage()` and pipeline's consuming
`retireQuiescedStorage()` each return that scoped carrier with `@_lifetime(copy self)`.
Inert retirement requires no transfer to coordinator; active retirement requires
stop/drain/quiescence and release of pins/registrations, including the cache ticket
at its existing pre-quiescence point, then consumption of takeQuiescedOpportunity's
Optional and its pipeline exactly once. Model/root/value/control cleanup still completes.

Live host/state preserve consuming supplied plus activationSpan initialization with
`@_lifetime(copy supplied, copy activationSpan)`. State has inert(supplied, span),
active(coordinator, optional model ticket, span), retired(retired storage, span) cases;
every activation/opportunity/retirement rewrite retains `@_lifetime(self: copy self)`.
Retired accesses stay scoped through the activation callback even after teardown.
Reset retains semantic reset, geometry reset then Interaction resetAllStorage order.
Static and Dynamic retirement transfer equivalently; borrowing fields from a dying
carrier, copying private fields or dropping an input dependence is forbidden.

CounterReturnedWorkspaces declaration/initializer explicitly require all G/C/R/H
Copyable & Escapable in addition to existing protocol/equality constraints.
Pipeline.returnWorkspaces(checks:) is available only in an extension with those
same owned constraints. Scoped routes return owned report/check counts, never workspaces.
Optional/enum/tuple/generic/closure wrappers MUST retain the union or reject access;
no Any/existential/collection/escaping closure/task/async transfer may erase it.

Replace the old initialized CounterStaticKeys? slot, its binding/init/take/control/
audit/deinit sites together. Five typed banks and final geometry objects have disjoint
validated regions and one physical inventory; the old owner cannot coexist over those
bytes. The historical 2,412 bytes is no replacement layout promise. Physical design
must specify actual offsets/fit/realization before source work; this amendment adopts
no raw offsets and claims neither syntax acceptance nor optimization.

### S15.2 Additional acceptance criteria

- [ ] **HC-SO-001:** Four-profile actual supplied→pipeline→coordinator→host→retirement
  chains accept moves and owned reports; paired negatives reject copy/use-after-consume,
  escape beyond each owner independently, activation-span escape, direct/generic Optional/
  tuple/closure erasure, owned-only workspace return, construction/extraction, escaping/
  Sendable/task transfer and overlapping access for the intended classified cause.
- [ ] **HC-SO-002:** Exact old/new slot, binding, initializer, control, audit and destructor
  inventory plus fault-at-step/early-return/repeat-session transcripts establish S13/S15
  lifetime and backing-last duties for both profiles. Host validation remains before
  activation, preserves first error and rejects mismatched provenance/capacity without
  client/service effects. Independent action/semantic/pixel controls remain unchanged.
- [ ] **HC-SO-003:** Complete current-source caller/route inventory, four registered
  counter routes and early linked Pi/nRF artifacts include ABI, allocator and feasible
  nested-stack/RAM/flash evidence. A smaller source value or passing link cannot close
  HC-RD-003; the prior 58,648-byte frame/27,648-byte ceiling remains failed until replaced
  by measured passing evidence. P08/R07/T8.1 acceptance requires independent exit review;
  P09–P12, hardware and existing unmet timing dispositions remain separate.
