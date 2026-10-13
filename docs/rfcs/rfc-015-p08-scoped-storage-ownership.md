---
id: RFC-015
feature: external-application-integration
title: P08 Scoped Storage Ownership
status: draft
authors:
  - codex
created: 2026-10-13
updated: 2026-10-13
proposal:
  - PROPOSAL-007
related_rfcs:
  - RFC-014
  - RFC-013
related_adrs:
  - ADR-007
  - ADR-008
  - ADR-035
  - ADR-036
  - ADR-038
related_specs:
  - SPEC-011
  - SPEC-013
  - SPEC-015
related_future_work:
  - FW-037
related_explorations: []
related_spikes:
  - SPIKE-075
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# RFC-015: P08 Scoped Storage Ownership

## Summary

**Draft candidate, not an approved amendment or permission to implement.**
The [independent initial review](../iterations/iteration-003-review/rfc-015-initial-review.md)
at `5770d266` found R1–R4. The response below selects draft corrections; it does
not change the immutable review verdict or establish compiler acceptance.
The [revision review](../iterations/iteration-003-review/rfc-015-revision-review.md)
records additional retirement, cleanup, capacity and gate-order corrections
against `b39a4f35`; B1–B4 remain open.
Prepare one narrow P08 direction: stable typed physical owners lend exclusive,
compiler-bounded storage access to a noncopyable, nonescapable geometry and
Interaction carrier chain. Interaction retains authority over its transaction;
physical storage retains complete independently owned identity keys. Moving a
small access value never transfers or relocates its pointee.

The maintainer authorized preparation of precise ownership boundaries enforced
by Swift, with broader implications captured separately. That instruction does
not approve this unseen design, new declarations, ADRs, Specifications, compiler
runs, repairs or resource exceptions. All new Swift compositions below are
uncompiled proposals. This draft is **not ready for architectural approval**
until the blockers in Open Questions are resolved.

## Context

Accepted [PROPOSAL-007](../proposals/proposal-007-external-application-integration.md)
and approved [RFC-014](rfc-014-runtime-derived-records-and-scoped-model-access.md)
cover the finite counter and analyzer runtime migration. Accepted ADR-035/036
require distinct semantic banks, independently owned Interaction keys, stable
backing and bounded scoped access. ADR-038 requires exact construction inputs
and separate operational validation. Implementing SPEC-015 and its active plan
still have P08/R07/T8.1 open; existing feature stages do not advance here.

This is post-MVP work in ITERATION-003 I3-04/I3-05, preserving the closed
ITERATION-001 reference application and four-stack regression contract. It is
not an additional MVP commitment. ITERATION-004 external delivery remains
RFC-013's independent concern.

At source `63e717d1`, four counter routes and the nRF link pass, but the actual
construction closure's 58,648-byte local frame exceeds the unchanged 27,648-byte
main stack before overlap. The [phase result](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r07-firmware-recipe/production-attempt/backing-realization/phase-split/result.md)
is qualified evidence, not a complete stack proof. A later one-IR diagnostic
ended [exit -5 without output](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r07-firmware-recipe/production-attempt/backing-realization/phase-split/ir-capture/independent-review.md);
it supplies no new mechanism or successful repair.

The [construction review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/r07-firmware-recipe/production-attempt/backing-realization/phase-split/construction-candidate-review.md)
identifies two concrete obstacles. Ordinary CounterGeometry and Interaction
storage protocols implicitly require Copyable/Escapable conformers, retained by
value throughout the pipeline. An outer lease does not constrain an extracted
ordinary pointer adapter. Also, the existing 2,412-byte Interaction slot holds
one initialized `CounterStaticKeys?`, including state and five typed banks; it
is not uninitialized space for five replacement owners.

## Scope and Decision Boundary

This RFC owns the inseparable P08 choice of physical backing ownership,
exclusive access, scoped storage contracts, geometry/Interaction lifetime
propagation, and lifecycle of those accesses. Geometry alone cannot justify a
combined construction repair; borrowed Interaction conformers require an
explicit portable contract change. The decision can be rejected without
changing RFC-014's runtime derivation, model access or accepted offer semantics.
Hence a focused successor decision is reviewable separately; RFC-014 remains
approved and unchanged in substance.

Included: the counter's geometry and five Interaction banks, generic contracts
that retain those accesses, host/coordinator handoff, construction/failure/
teardown, and compatibility of existing owned stores. Affected analyzer and
other package callers must be inventoried before adoption. The candidate does
not generalize Layout, Render, Canvas, semantic or model storage protocols
unless a concrete P08 carrier requires a separately identified amendment.

Excluded: universal GiftUI Core storage architecture, frontend IR/ABI, arbitrary
backend/platform abstraction, external package stabilization, simulator,
resource-limit changes, workload reductions and new performance experiments.
These exclusions must not hide a lifetime needed by this candidate.

## Requirements

Candidate requirements below use MUST to describe the proposed contract only.

- P08-SO-001: Every physical initialized object has exactly one backing owner,
  one initialization/deinitialization responsibility and an accounted region.
- P08-SO-002: Every supported safe client path carrying access depends on all
  underlying owners. Types reject copy, lifetime escape and use after consume;
  access control rejects forging/extraction. Overlapping access is excluded by
  structural borrowing where provable and Swift runtime exclusivity otherwise;
  library session/alias rules also exclude reentry and untracked physical aliases.
- P08-SO-003: Interaction owns transaction metadata and complete bounded copied
  keys independently of semantic-bank lifetime. No storage accessor exports a
  mutable bank, owner ticket, pointer or lifetime-erased adapter.
- P08-SO-004: Commit/discard, capacity, exact identity, generation, publication,
  failure precedence and teardown preserve SPEC-011/013/015 behavior.
- P08-SO-005: No claimed syntax proof replaces runtime validation of capacity,
  identity, phase, provenance, initialized state, bounds or callback quiescence.
- P08-SO-006: Actual target resources and complete nested stack remain measured
  acceptance gates under unchanged limits. Smaller source values are not proof.

## Constraints

Use the approved project-local Swift 6.4 configuration and required lifetime
features; no associated type whose value itself must be nonescapable, no newer
language dependency and no unchecked fallback. Existing Scalar/Identity/Result
associated types remain owned Copyable/Escapable values. Static remains bounded
and zero-heap; Dynamic retains equivalent limits and outcomes. Production
hardware, production compilation/linking and repairs are outside this preparation.
The separately authorized SPIKE-075 below permits only its bounded disposable
compiler experiment; it does not reopen those production allowances.

All historical allowances stay closed, including helper 2/2, B03 1/1, GOT 1/1,
prior image/backing-image allowances, phase correction/image and diagnostic
capture 1/1. Preserve the package two-consecutive-unproductive stop rule; this
RFC creates no successor budget and resets no count. No new experiment follows
merely from listing evidence needed below.

## Proposed Design

### Ownership graph and access matrix

```text
host/profile composition -> stable typed physical backing owner
                                 | exclusive activation borrow
                                 v
                        private storage session
                         /                   \
             scoped geometry access     scoped Interaction bank accesses
                         \                   /
                         supplied -> pipeline -> coordinator -> live host
                                      |
                           serialized phase operations

Semantic Core candidate view -> synchronous key copy -> Interaction physical banks
```

Arrows toward backing indicate borrowing, not ownership transfer. Semantic
Core still owns canonical expansion; Layout/Render consume it. Interaction
controls candidate/committed routing. Platform code supplies regions and
quiescence; it does not write live routing banks. Host composition binds these
owners without merging their semantic responsibilities.

| Object | Owns / may move | May borrow / mutate | Forbidden supported access |
| --- | --- | --- | --- |
| Physical backing owner | Typed geometry objects, five distinct typed Interaction banks; destruction inventory | Lends one exclusive activation session after validation | Copy while borrowed, move/rebind/release while session lives, second active session |
| Interaction machine | Phase, counts, revision and key-pool metadata, held once with scoped bank accesses | Exclusive candidate writes; committed reads; infallible role exchange | Owning a second inline copy of the same banks; changing physical destruction inventory |
| Scoped geometry/access adapter | Unique access capability, never physical bytes | Named geometry operations under session lifetime | Copyable/Escapable conformance, pointer/base property, public initializer |
| Supplied/pipeline/coordinator/host | Consumed scoped access and existing model/semantic/control dependencies | Serialized operations; explicitly scoped read views | Extracted escaping workspaces, hidden retained closures, owner release |
| Application/frontend author | Ordinary values, keys/actions and declarations | Supported synchronous operations | Construct storage capabilities or conform a borrowed storage implementation |
| Backend/platform integrator | Its endpoint/transport and supplied region ownership | Validated host composition, stop/drain | Forge framework storage capability or bypass live-bank exclusivity |
| Trusted library bridge | Binding/initialization code and private adapters | Unsafe access only inside actual owning borrows | Treat pointer-descriptor lifetime as pointee proof |

The whole package implementation, including other modules that can name package
protocols and generic initializers, is trusted. Swift does not seal those protocols
against in-package conformances. Storage protocols are not outside-package
conformance extension points. Their conformances, unsafe constructors and generic
factories belong to reviewed trusted library/fixture code. A backend author's safe client
API accepts validated concrete configuration/owners, never an arbitrary conformer
that claims disjointness. Future public integration must preserve this boundary
or obtain its own reviewed contract. The actual P08 storage entry is the
`fileprivate withP08Storage` factory: only the trusted fixture assembly invokes
it; the outside-package client surface exposes no storage factory or adapter.
Any future untrusted in-package caller requires an explicitly restricted entry;
package visibility alone is not that restriction. Arbitrary explicitly unsafe code can violate
memory safety; this RFC makes no promise to prevent that.

### Type enforcement and concrete syntax

Existing, compiled patterns (read from current maintained source; no new compile
performed here):

```swift
// ObservableModelScope.swift: actual owning inout borrows stay in the factory.
package func withObservableModelScope<Model: ~Copyable, Schema, Result>(
    ownership: inout ObservableModelOwnership,
    models: inout MutableSpan<Model?>,
    schema: UInt16, needsCapture: Bool,
    _ body: (borrowing ObservableModelScope<Model, Schema>)
        throws(ObservableStateError) -> Result
) throws(ObservableStateError) -> Result

// ObservableStateRootScope.swift: consumed scoped fields propagate lifetimes.
@_lifetime(copy models, borrow records, borrow reports)
fileprivate init(
    models: consuming ObservableModelScope<Model, Model.Schema>,
    records: borrowing UnsafeMutablePointer<ObservableStateRootStorage<Identity>>,
    reports: borrowing UnsafeMutablePointer<ObservableStateRootReports>
)
@_lifetime(copy self)
package borrowing func borrowedRoot() -> ObservableStateRootScope<Model, Identity>
```

The factory retains the actual storage borrows around invocation. Its private
pointer initializer is safe only through that restricted call path. These
patterns establish neither a P08 generic storage composition nor its stack cost.

**Proposed, uncompiled declaration shapes:** bodies and witness implementations
are deliberately absent. The proposed storage callback is nonthrowing; failures
are owned values and physical initialization is a separate checked stage. Intended interface signatures
and lifetime constraints are fixed below; compiler acceptance and implementation
proof remain approval blocker B1, not assumed implementation details.

```swift
package protocol InteractionCandidateRecordStorage: ~Copyable, ~Escapable {
    associatedtype Identity: Equatable & Sendable

    var count: UInt16 { get }
    var capacity: UInt16 { get }
    mutating func reset()
    borrowing func record(at index: UInt16) -> InteractionCandidateRecord<Identity>?
    mutating func append(_ record: consuming InteractionCandidateRecord<Identity>) -> Bool
    mutating func replace(
        at index: UInt16,
        with record: consuming InteractionCandidateRecord<Identity>
    ) -> Bool
}

package protocol InteractionCommittedRecordStorage: ~Copyable, ~Escapable {
    associatedtype Identity: Equatable & Sendable

    var count: UInt16 { get }
    var capacity: UInt16 { get }
    mutating func reset()
    borrowing func record(at index: UInt16) -> BoundActionRecord<Identity>?
    mutating func append(_ record: consuming BoundActionRecord<Identity>) -> Bool
    mutating func exchangeContents(with other: inout Self)
}

package protocol InteractionHitRegionStorage: ~Copyable, ~Escapable {
    associatedtype Identity: Equatable & Sendable

    var count: UInt16 { get }
    var capacity: UInt16 { get }
    mutating func reset()
    borrowing func region(at index: UInt16) -> InteractionHitRegion<Identity>?
    mutating func append(_ region: consuming InteractionHitRegion<Identity>) -> Bool
    mutating func exchangeContents(with other: inout Self)
}


package protocol InteractionCandidateBuilder: ~Copyable, ~Escapable {
    associatedtype Identity: Equatable & Sendable

    mutating func beginCandidate(limits: InteractionLimits) -> InteractionError?
    mutating func append(
        identity: Identity,
        isEnabled: Bool,
        bounds: Rect,
        clip: Rect,
        paintOrder: UInt16,
        action: BoundedApplicationAction,
        targetGeneration: ObservableTargetGeneration
    ) -> InteractionCandidateAppendResult
    mutating func assignGeneration(
        _ generation: ActionGeneration,
        to identity: Identity
    ) -> InteractionError?
    mutating func finishCandidate() -> InteractionError?
    mutating func resolveCandidate(_ disposition: InteractionCandidateDisposition)
}

package protocol InteractionGestureResolver: ~Copyable, ~Escapable {
    associatedtype Identity: Equatable & Sendable

    borrowing func resolveDown(at point: Point) -> PointerGestureOutcome<Identity>
    borrowing func resolveMove(
        _ captured: CapturedAction<Identity>,
        at point: Point
    ) -> PointerGestureOutcome<Identity>
    borrowing func resolveUp(
        _ captured: CapturedAction<Identity>,
        at point: Point
    ) -> PointerGestureOutcome<Identity>
}

package protocol InteractionCommittedActionView: ~Copyable, ~Escapable {
    associatedtype Identity: Equatable & Sendable

    borrowing func committedRecord(
        for identity: Identity
    ) -> BoundActionRecord<Identity>?
}

protocol CounterGeometry: ~Copyable, ~Escapable {
    borrowing func storageMeasurement() -> CounterGeometryMeasurement
    mutating func layout(_ bank: borrowing SemanticRecordView<CounterPayload>, limits: RuntimeProfileLimits) -> LayoutResult
    mutating func draw(source: inout CounterSource, context: ExecutionContext, limits: RuntimeProfileLimits) -> DrawingPlanResult
    mutating func preflight(_ bank: borrowing SemanticRecordView<CounterPayload>, limits: RuntimeProfileLimits) -> RenderProductionResult
    mutating func produce<S: DrawingOperationSink>(_ bank: borrowing SemanticRecordView<CounterPayload>, header: RenderPlanHeader, sink: inout S, limits: RuntimeProfileLimits) -> RenderProductionResult
    func verifyPlan(canvas: SemanticRecordReference, value: UInt8) -> Int
    func bounds(_ record: SemanticRecordReference) -> Rect?
    func clip(_ record: SemanticRecordReference) -> Rect?
    mutating func resetLayout()
    mutating func resetPlan()
    mutating func resetRender()
    mutating func reset()
}
```

This is a proposal to implement scoped borrowing via concrete finite adapters,
not a blanket addition of suppressions. `P08StorageSession` and every mutable
adapter MUST be `~Copyable, ~Escapable`, have private storage fields and no
client-callable initializer, pointer conversion, `_read`/`_modify` accessor or
raw descriptor. The factory MUST hold actual disjoint typed borrows, call the nonthrowing
body once synchronously and finish cleanup before releasing them. Every adapter
is constructed from one common actual backing-owner session lifetime, not
independently scoped bank lifetimes; see R3 below. It must not
return a scope borrowed merely from local pointer descriptors. Any nested unsafe
callback must enclose all uses. The initializer's lifetime propagation must
include every bank; omitting one is a failed contract test.

`consuming` transfers the unique access capability, not backing. `borrowing`
prevents consuming or mutating that value itself; it does not prevent a method
from mutating pointer/reference-backed data. Reviewed concrete methods and hidden
mutable capabilities enforce semantic read-only access. `mutating`/`inout` grants
exclusive value access, subject to compile-time and runtime enforcement below.
No adapter offers a `borrowed()` method that duplicates mutable authority. Scalar
measurement, Rect and complete identity/action records may return as owned values.
No blanket Sendable or `@unchecked Sendable` conformance is allowed on session,
adapters, state, host or lifetime carriers. No supported API accepts an escaping
or `@Sendable` closure containing them. Synchronous IRQ admission uses its existing
separate handoff; it cannot access these live banks.

### Exact candidate carrier signatures

The following interface fragments specify the intended complete constraints and
lifetime inputs for the changed storage transfers. They remain **uncompiled**;
method bodies and existing unchanged operational members are omitted. Suppressing
Self constraints on a protocol permits both owned and scoped conformers: it does
not force conformers to be noncopyable. The concrete mutable access types below
explicitly forbid copying/escaping. Restricted construction and factories prevent
safe clients from substituting arbitrary conformers.

```swift
package struct InteractionState<C, R, H>: ~Copyable, ~Escapable,
    InteractionCandidateBuilder, InteractionCommittedActionView,
    InteractionGestureResolver
where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
      R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
      H: InteractionHitRegionStorage & ~Copyable & ~Escapable,
      C.Identity == R.Identity, C.Identity == H.Identity {
    package typealias Identity = C.Identity
    private var candidateRecords: C
    private var candidateHitRegions: H
    private var candidateCommittedRecords: R
    private var committedRecords: R
    private var committedHitRegions: H
    private enum Phase: UInt8 { case idle, staging, readyForOffer }
    private var limits: InteractionLimits?
    private var phase: Phase = .idle
    private var candidateError: InteractionError?
    private var committedPresentationRevision: PresentationRevision?
    @_lifetime(copy candidateRecords, copy candidateHitRegions,
               copy candidateCommittedRecords, copy committedRecords,
               copy committedHitRegions)
    package init(candidateRecords: consuming C, candidateHitRegions: consuming H,
                 candidateCommittedRecords: consuming R,
                 committedRecords: consuming R, committedHitRegions: consuming H)
}

package struct InteractionOwnedKeyState<C, R, H>: ~Copyable, ~Escapable,
    InteractionCandidateBuilder, InteractionCommittedActionView,
    InteractionGestureResolver
where C: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
      R: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
      H: InteractionHitRegionStorage & ~Copyable & ~Escapable,
      C.Identity == SemanticCompleteIdentity,
      R.Identity == SemanticCompleteIdentity,
      H.Identity == SemanticCompleteIdentity {
    package typealias Identity = SemanticCompleteIdentity
    private var state: InteractionState<C, R, H>
    private let maximumComponentsPerKey: UInt16
    private let maximumComponents: UInt32
    private var configuredComponentsPerKey: UInt16
    private var configuredComponents: UInt32
    private var candidateComponents: UInt32 = 0
    package private(set) var committedComponents: UInt32 = 0
    private var isStaging: Bool = false
    private var failure: InteractionError?
    @_lifetime(copy state)
    package init?(state: consuming InteractionState<C, R, H>,
                  maximumComponentsPerKey: UInt16, maximumComponents: UInt32)
}

protocol CounterCandidateBacking: InteractionCandidateRecordStorage,
    ~Copyable, ~Escapable {
    var retainedIdentitySlots: Int { get }
    var retainedPayloadBytes: Int { get }
}
protocol CounterCommittedBacking: InteractionCommittedRecordStorage,
    ~Copyable, ~Escapable {
    var retainedIdentitySlots: Int { get }
    var retainedPayloadBytes: Int { get }
}
protocol CounterHitBacking: InteractionHitRegionStorage, ~Copyable, ~Escapable {
    var retainedIdentitySlots: Int { get }
    var retainedPayloadBytes: Int { get }
}

// Three concrete, closed finite adapter types; each implements its complete
// protocol above. No adapter has a public/package constructor or pointer getter.
fileprivate struct P08CandidateAccess: ~Copyable, ~Escapable, CounterCandidateBacking
fileprivate struct P08CommittedAccess: ~Copyable, ~Escapable, CounterCommittedBacking
fileprivate struct P08HitAccess: ~Copyable, ~Escapable, CounterHitBacking
// Their Identity is exactly SemanticCompleteIdentity, not a scoped associated type.
fileprivate struct P08GeometryAccess: ~Copyable, ~Escapable, CounterGeometry

fileprivate typealias P08ScopedKeys = InteractionOwnedKeyState<
    P08CandidateAccess, P08CommittedAccess, P08HitAccess
>
fileprivate struct P08StorageSession: ~Copyable, ~Escapable {
    private var geometry: P08GeometryAccess
    private var interaction: P08ScopedKeys
    @_lifetime(copy geometry, copy interaction)
    fileprivate init(geometry: consuming P08GeometryAccess,
                     interaction: consuming P08ScopedKeys)
    // No accessor for either capability; transfer only through this constructor.
    @_lifetime(copy self, copy models, copy root, copy semantic,
               copy values, copy control)
    consuming func intoSupplied(
        models: consuming ObservableModelScope<CounterOwnedModel, CounterModelSchema>,
        root: consuming ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>,
        semantic: consuming SemanticRecordStore<CounterPayload>,
        values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>,
        control: consuming CounterHostControl, audit: RuntimeStorageAudit
    ) -> CounterHostSuppliedStorage<P08GeometryAccess,
           P08CandidateAccess, P08CommittedAccess, P08HitAccess>
}

fileprivate func withP08Storage<Result>(
    backing: inout P08TypedBackingOwner,
    _ body: (consuming P08StorageSession) -> Result
) -> Result
```

`P08TypedBackingOwner` is the unique noncopyable physical-owner aggregate;
geometry and each bank are private initialized fields/regions. It has no API for
constructing a second owner from an address. Its initializer, typed binding and
partial-failure destruction inventory must be supplied for B2. The private adapter
constructors may use the existing borrowed-descriptor lifetime pattern **only**
inside the factory's actual typed storage borrows. The session cannot be created
from client pointers. No signature with an independently borrowed raw descriptor
is a safe-client entry point. The factory's ordinary generic Result deliberately
requires Copyable/Escapable; only owned reports may leave it.

Both supplied and pipeline types use the following identical complete generic
constraint set (their stored geometry and interaction become private):

```swift
struct CounterHostSuppliedStorage<G, C, R, H>: ~Copyable, ~Escapable
where G: CounterGeometry & ~Copyable & ~Escapable,
      C: CounterCandidateBacking & ~Copyable & ~Escapable,
      R: CounterCommittedBacking & ~Copyable & ~Escapable,
      H: CounterHitBacking & ~Copyable & ~Escapable,
      C.Identity == SemanticCompleteIdentity,
      R.Identity == SemanticCompleteIdentity,
      H.Identity == SemanticCompleteIdentity

struct CounterPipelineOwner<G, C, R, H>: ~Copyable, ~Escapable,
    RuntimeCompletePipelineOwner
where G: CounterGeometry & ~Copyable & ~Escapable,
      C: CounterCandidateBacking & ~Copyable & ~Escapable,
      R: CounterCommittedBacking & ~Copyable & ~Escapable,
      H: CounterHitBacking & ~Copyable & ~Escapable,
      C.Identity == SemanticCompleteIdentity,
      R.Identity == SemanticCompleteIdentity,
      H.Identity == SemanticCompleteIdentity

// Member initializer of supplied; same storage-transfer initializer on pipeline
// additionally takes its existing owned limits and endpoint configuration.
@_lifetime(copy models, copy root, copy semantic, copy values, copy scopedControl,
           copy geometry, copy interaction)
fileprivate init(
    models: consuming ObservableModelScope<CounterOwnedModel, CounterModelSchema>,
    root: consuming ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>,
    semantic: consuming SemanticRecordStore<CounterPayload>,
    values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>,
    scopedControl: consuming CounterHostControl, audit: RuntimeStorageAudit,
    geometry: consuming G, interaction: consuming InteractionOwnedKeyState<C, R, H>
)

fileprivate typealias P08Supplied = CounterHostSuppliedStorage<
    P08GeometryAccess, P08CandidateAccess, P08CommittedAccess, P08HitAccess
>
fileprivate typealias P08Pipeline = CounterPipelineOwner<
    P08GeometryAccess, P08CandidateAccess, P08CommittedAccess, P08HitAccess
>
fileprivate typealias P08Coordinator = StaticRuntimeExecutionCoordinator<
    CounterExecutionBinding, CounterAdmission, P08Pipeline
>

// Internal retirement transfer, never a callback Result or owned workspace.
struct CounterRetiredStorage<G, C, R, H>: ~Copyable, ~Escapable
where G: CounterGeometry & ~Copyable & ~Escapable,
      C: CounterCandidateBacking & ~Copyable & ~Escapable,
      R: CounterCommittedBacking & ~Copyable & ~Escapable,
      H: CounterHitBacking & ~Copyable & ~Escapable,
      C.Identity == SemanticCompleteIdentity,
      R.Identity == SemanticCompleteIdentity,
      H.Identity == SemanticCompleteIdentity {
    private var semantic: SemanticRecordStore<CounterPayload>
    private var geometry: G
    private var interaction: InteractionOwnedKeyState<C, R, H>
    @_lifetime(copy semantic, copy geometry, copy interaction)
    init(semantic: consuming SemanticRecordStore<CounterPayload>,
         geometry: consuming G,
         interaction: consuming InteractionOwnedKeyState<C, R, H>)
    @_lifetime(self: copy self)
    mutating func resetAfterQuiescence()
}
fileprivate typealias P08RetiredStorage = CounterRetiredStorage<
    P08GeometryAccess, P08CandidateAccess, P08CommittedAccess, P08HitAccess
>

// Members of supplied and pipeline respectively, with their G/C/R/H constraints.
// Supplied requires that activation has not transferred it to a coordinator;
// pipeline requires completed quiescence and release of registrations/read pins.
@_lifetime(copy self)
consuming func retireInertStorage() -> CounterRetiredStorage<G, C, R, H>
@_lifetime(copy self)
consuming func retireQuiescedStorage() -> CounterRetiredStorage<G, C, R, H>

fileprivate enum P08HostState: ~Copyable, ~Escapable {
    case inert(P08Supplied, Span<UInt8>)
    case active(P08Coordinator, ObservableModelTicket<CounterModelSchema>?, Span<UInt8>)
    case retired(P08RetiredStorage, Span<UInt8>)
    @_lifetime(copy supplied, copy activationSpan)
    init(supplied: consuming P08Supplied, activationSpan: Span<UInt8>)
    @_lifetime(self: copy self)
    mutating func activate(assembly: CounterHostAssembly) -> HostConfigurationError?
    @_lifetime(self: copy self)
    mutating func teardown()
}
```

The existing pipeline initializer that accepts a raw control descriptor stays
trusted/file-local and must add `copy geometry, copy interaction` to its existing
`copy models, copy root, copy semantic, copy values, borrow control` lifetime
list. It is not available through the client factory. The scoped-control route
uses the full list above, with existing owned `limits: RuntimeProfileLimits` and
`endpointConfiguration: HostEndpointConfiguration` rather than `audit` on the
pipeline. Owned arguments add no borrowed lifetime.

Static and Dynamic coordinators already declare all retained Binding/Admission/
Opportunity generics with `~Copyable & ~Escapable`, package admission/opportunity
getters with private setters, and an
initializer `@_lifetime(copy binding, copy admission, copy opportunity)` taking
all three `consuming`. Preserve that exact constructor chain; the Dynamic
specialization uses its existing Dynamic binding/admission and the same scoped
bank/geometry rules. The Dynamic supplied/pipeline types receive the same complete
G/C/R/H constraints and consumed lifetime inputs above, parameterized by their
existing Dynamic model/root/semantic/value scopes. No Dynamic pointer-erased
substitution is permitted. Their exact existing scope types stay unchanged.

The live host's private `state` becomes the scoped state above; its existing
consuming supplied initializer retains `@_lifetime(copy supplied, copy activationSpan)`.
Every activation/opportunity/retirement enum rewrite retains
`@_lifetime(self: copy self)`. Internal retirement results carry scopes with their
original dependencies; only the outer factory Result must be owned. The retired case
holds accesses until the activation callback ends even after logical teardown.
`CounterReturnedWorkspaces` remains an owned-only route: explicitly constrain
G/C/R/H to Copyable and Escapable on its declaration and initializer. Also move
the existing pipeline `returnWorkspaces(checks:)` member into an extension with
those same owned constraints; leaving it on the unconstrained scoped pipeline
would still require constructing an inadmissible owned result. The scoped route
returns an owned report/check count instead. `withBacking` is removed from
supported callers and replaced by an owned measurement operation; no callback
exposes the capability types. Compiler rejection of a required declaration is
B1 and cannot be repaired by omitting a dependence.

For active retirement, the host completes the existing stop/drain and
quiescence sequence, including release of the independent cache ticket at its
existing pre-quiescence point, then consumes the
coordinator's `takeQuiescedOpportunity()` Optional. It consumes the resulting
pipeline through `retireQuiescedStorage()` into the retired case. Failed/inert
activation instead consumes supplied storage through `retireInertStorage()`.
These operations transfer semantic/geometry/Interaction values exactly once;
they do not create an alias by borrowing a field from a soon-destroyed carrier.
The remaining model/root/value/control scopes end only after their required
cleanup. `resetAfterQuiescence()` retains the existing semantic reset, geometry
reset and Interaction `resetAllStorage()` order and failure disposition.
Static and Dynamic host retirement need equivalent transfers. Exact Optional
consumption, partial moves and lifetime unions remain B1; no scoped route may
reuse `CounterReturnedWorkspaces`, copy private fields or drop a dependency to
make retirement compile.
The generic retirement carrier and transfer members are internal to the trusted
counter fixture module so its separate host/pipeline files can use them. Concrete
P08 adapters and their constructors remain file-local to the storage assembly.

### Complete carrier obligation

No associated type is introduced for scoped storage. Concrete generic parameters
carry accesses. The following is a finite migration checklist, not proof that
current declarations already work:

| Path | Required candidate change / invariant |
| --- | --- |
| Three Interaction storage protocols | Suppress both Self constraints; keep Identity, record returns and capacity values owned; trusted conformances only |
| Three Interaction operational protocols | Admit noncopyable/nonescapable Self so state can conform; audit consumers that retain these conformers |
| InteractionState / InteractionOwnedKeyState | Both scoped/noncopyable; explicit C/R/H suppressions, equalities, consuming initializers and lifetime dependence on every consumed bank/state |
| CounterCandidateBacking / CounterCommittedBacking / CounterHitBacking | Repeat required Self permissions through inheritance; measurement returns only owned facts |
| CounterGeometry / concrete scoped geometry | Suppress both constraints; constructor restricted to actual typed owner borrow; no raw accessor or independently escaping view |
| CounterHostSuppliedStorage / Dynamic supplied storage | Explicit Geometry and bank generic permissions; private fields; init lifetime includes geometry AND Interaction, plus models/root/semantic/values/control |
| CounterPipelineOwner and both initializer routes | Same complete constraints and lifetime list; private geometry/Interaction; operation-only access; consume onward within session |
| Static/Dynamic coordinator, host state and live host | Audit every generic constraint, conformance, stored optional and move; propagate session plus activation-span dependence through consuming constructors and mutating transitions |
| CounterReturnedWorkspaces / callback results | Owned native route stays separate; scoped Embedded route returns only owned checks/report values, never geometry/Interaction/host through current escaping return type |
| Pipeline returnWorkspaces / supplied and host retirement | Owned-return member is available only with owned G/C/R/H; scoped retirement consumes supplied or quiesced pipeline into CounterRetiredStorage, including the coordinator Optional and every dependency |
| withBacking / all measurement helpers | Return bounded owned measurements; remove adapter exposure from supported surface; any retained internal borrowing callback proves no escaping return/capture |
| Optional/enum/tuple/generic wrappers and closures | Carry same lifetime or reject construction; no erased Any/existential wrapper, collection or stored closure fallback; no new nonescapable associated type |

### Owned-state compatibility choice — R1

Choose conditional Copyable and Escapable conformances for **both** existing
state types; do not introduce a duplicated owned state machine. These are
uncompiled candidate declarations modeled on the existing conditional extensions
in [HostPresetBootstrap.swift](../../Sources/GiftUIHostConfiguration/HostPresetBootstrap.swift).
The maintained single-field pattern is evidence of spelling, not proof of this
five-field/initializer composition.

```swift
extension InteractionState: Copyable
where C: Copyable & ~Escapable, R: Copyable & ~Escapable,
      H: Copyable & ~Escapable {}
extension InteractionState: Escapable
where C: Escapable & ~Copyable, R: Escapable & ~Copyable,
      H: Escapable & ~Copyable {}
extension InteractionOwnedKeyState: Copyable
where C: Copyable & ~Escapable, R: Copyable & ~Escapable,
      H: Copyable & ~Escapable {}
extension InteractionOwnedKeyState: Escapable
where C: Escapable & ~Copyable, R: Escapable & ~Copyable,
      H: Escapable & ~Copyable {}
```

The base declarations retain all protocol/Identity equalities above. State's
five C/R/H fields are the only lifetime-bearing fields. Its Phase, optional
InteractionLimits, optional InteractionError and optional PresentationRevision
are ordinary owned Copyable/Escapable values. OwnedKeyState's state field is
conditionally owned under the same constraints; all UInt16/UInt32 counters,
Bool staging flag and optional InteractionError are owned. No session, pointer,
closure or extra lease field is silently added to either generic state. All
stored fields are listed in the candidate declarations above.

The consuming state initializer and its five-input lifetime union are unchanged;
when all five inputs are owned Escapable values that union must impose no scoped
result restriction. The failable OwnedKeyState initializer consumes state and
inherits its dependence; its Optional result must be conditionally escapable
when state is owned and remain scoped otherwise. B1 must prove both cases and
copy semantics, not only type aliases. CounterReturnedWorkspaces explicitly
requires G/C/R/H: Copyable & Escapable, hence its stored state uses these
conditional conformances. Its constructor remains consuming for geometry/state.
No concrete scoped adapter satisfies either owned constraint. If the compiler
cannot express these exact conformances or initialization/result rules, **R1
remains an approval blocker under B1**; no separate owned duplication or lifetime
erasure is preauthorized.

### Direct consumer dispositions — R2

This adopts the bounded inventory from the immutable initial review; it is not
an exhaustive generated/test/transitive compiler audit. Paths below are under
`Sources/<Module>/`. Operation-only functions borrow/inout existing state and
return owned values; each named generic parameter explicitly adds both
`~Copyable & ~Escapable`, preserving its existing protocol and Identity equalities.

| Module / files | Chosen candidate disposition |
| --- | --- |
| GiftUIInteraction: InteractionStorage.swift, InteractionValues.swift, InteractionState.swift, InteractionOwnedKeyState.swift | Six scoped-admitting protocols and the conditional state route above. Both withBacking callbacks are replaced by owned measurements; migrate measurement callers |
| GiftUIInteraction: ExecutionGestureAdapter.swift | down/move/up use `Resolver: InteractionGestureResolver & ~Copyable & ~Escapable`; resolver is borrowed, gesture returns remain owned |
| GiftUIRuntimeCore: RuntimeRecordInteractionBridge.swift | append/appendProjected add explicit Candidate/Committed/Hits scoped permissions; dispatch adds `Records: InteractionCommittedActionView & ~Copyable & ~Escapable` to its borrowed operation parameter; all Model/RootIdentity/Action/role constraints and owned returns remain |
| GiftUIRuntimeCore: RuntimeRecordCanvasInteractionBridge.swift | append adds the same Candidate/Committed/Hits permissions and existing complete-identity equalities; no retained scoped callback |
| GiftUIRuntimeCore: RuntimeInteractionCandidateTransaction.swift | build adds `Interaction: InteractionCandidateBuilder & ~Copyable & ~Escapable`; preserves existing inout argument and owned result |
| GiftUIRuntimeCore: RuntimeInteractionCandidateCoordinator.swift | build and discardCandidates receive that same Interaction constraint; other owned occurrence/observable/generation constraints stay unchanged |
| GiftUIRuntimeCore: RuntimeInteractionCandidateResolution.swift | resolve receives that same Interaction constraint; generation allocator/owned outcomes remain unchanged |
| GiftUIRuntimeCore: RuntimeInteractionDispatcher.swift | **Owned-only.** Retained Records explicitly require InteractionCommittedActionView & Copyable & Escapable; Handler and TargetAccess remain their existing owned Copyable/Escapable conformers and Model equality. Ordinary stored fields/non-consuming initializer and InteractionDispatcher conformance remain; no seventh operational protocol relaxation |
| GiftUIRuntimeStatic / GiftUIRuntimeDynamic: StaticInteractionStorage.swift, DynamicInteractionStorage.swift | Existing owned banks and Static/StaticSix/Dynamic state aliases use R1 conditional conformances; same limits/allocations accounting |
| GiftUIRuntimeStatic / GiftUIRuntimeDynamic: StaticRuntimeExecutionCoordinator.swift, DynamicRuntimeExecutionCoordinator.swift | Preserve scoped constructor union and explicit constraints. admission/opportunity are package getters with private setters, not wholly private; scoped getter/consume results cannot escape. Include consuming `takeQuiescedOpportunity() -> Opportunity?` with `@_lifetime(copy self)` in Optional/retirement proof |
| SignalAnalyzerTargetHost: DynamicSignalAnalyzerActionDispatcher.swift, StaticSignalAnalyzerActionDispatcher.swift, StaticSignalAnalyzerNRFEmbeddedInteractionOwner.swift | **Owned-only** generic operational consumers/conformer; add explicit Copyable/Escapable bounds if needed after protocol relaxation. No borrowed analyzer architecture selected |
| SignalAnalyzerTargetHost: DynamicSignalAnalyzerPresentationPipeline.swift, StaticSignalAnalyzerNRFApplicationStorage.swift, StaticSignalAnalyzerNRFPresentationCommitter.swift, StaticSignalAnalyzerNRFInteractionHandler.swift, StaticSignalAnalyzerNRFApplicationInputOwner.swift, StaticSignalAnalyzerNRFInteractionCandidateProducer.swift | **Owned-only** aliases, pointer and inout paths retain existing storage semantics through R1; withInteraction<Result> remains owned-state/non-escaping callback and ordinary owned Result. Validate pointer lifetime and no scoped adapter substitution |

The counter uses operation-only RuntimeRecordInteractionBridge.dispatch with
borrowed scoped Records, not the storing RuntimeInteractionDispatcher. If the
actual counter audit finds it must retain a scoped Records dispatcher, stop for
an explicit new decision on that carrier/conformance; do not expand this draft
by relaxing InteractionDispatcher. Other tests/generated clients remain B3 audit
obligations, not assumed compatibility.

The proposed initializers use the existing `@_lifetime(copy ...)` pattern for
consumed scoped values: explicitly include `copy geometry, copy interaction`
alongside all existing dependencies. Scope-valued read results use
`@_lifetime(copy self)` only when immutable access is safe and the concrete
result cannot expose mutable authority. The scalar owned return paths require
no artificial dependence. Swift's acceptance of each new composition remains
B1; if a required host/coordinator constraint cannot express it, stop upstream
rather than erase lifetime at that boundary.

### Initialization, moves, failure and teardown

1. Before client exposure, validate capacities, region alignment, disjointness,
   identities and schema. Initialize each typed physical bank exactly once in
   its final stable region and record initialized objects independently of roles.
   Construct geometry's typed physical objects likewise. The owner cannot move
   initialized pointees after granting access.
2. Acquire the exclusive session. Construct one state machine with five access
   values, then move the scoped geometry/state through supplied, pipeline,
   coordinator and host. No copied large owner crosses these constructors.
   All existing construction graph backing inputs remain explicit under ADR-038.
3. Initialize before activation; on partial failure, unwind only successfully
   initialized/acquired values, in reverse acquisition order. End scoped users
   before destroying physical backing. The storage callback is nonthrowing and
   returns only owned reports/failures; no Optional.take path may leave an
   untracked initialized bank.
4. During activation, exclusive backing access persists. Frame semantic/model
   borrows and frame pins remain independent obligations from SPEC-013/015;
   storage session is not a model pin. End candidate semantic borrows at their
   own last use, not by reusing committed Interaction key storage.
5. On shutdown/failure, stop admission and producers, drain synchronous/IRQ
   callbacks, resolve any begun candidate once, release frame/read pins and
   registrations under existing rules, make callbacks unavailable, end host/
   coordinator/access lifetimes, then deinitialize physical objects once.
   Teardown methods alone do not release the Swift borrow; scope completion does.

### Common session, exclusivity and checked initialization — R3/R4

Choose one immutable private `P08SessionLifetime: ~Escapable` token per exclusive
actual backing-owner borrow. It may be copied only as immutable lifetime/
provenance evidence, never mutable authority. Every concrete geometry/C/R/H
adapter constructor has `@_lifetime(copy sessionLifetime)` and takes that common
token as `borrowing P08SessionLifetime`; its private bank descriptor is selected
by the same trusted factory. The token must depend on the actual owner's typed
borrow enclosing the whole callback, not merely a borrowed pointer local. Exact
token construction and compiler propagation are B1/B2 obligations, not proven
syntax. No independently created adapter enters the state initializer through
the concrete client entry. Only that factory constructs the complete five-access
state; it checks distinct physical bank identities and stores same-session
provenance in each concrete adapter.

The concrete `exchangeContents(with:)` witnesses are called only by the private
state-held prepared/committed R pair and candidate/committed H pair. They require
same-session provenance, distinct banks and compatible validated capacities;
checks precede ready-for-offer, so commit stays non-failing. Every adapter keeps
the common owner/session lifetime unchanged when its role pointer exchanges.
Physical addresses may change roles but cannot acquire a longer independent
lifetime. Cross-session exchange is unavailable through the client entry and is
a trusted implementation invariant, checked before commit; the generic protocol
alone does not prove it. Moves and retired host cases preserve that same token
dependence. B1 must prove exchanged adapters cannot escape the common owner even
through generic/Optional paths.

For this concrete P08 candidate, compatible means **equal immutable logical
capacity within each exchanged pair**, each covering the configured action or
hit limit. Candidate records must also cover the action limit. Unequal physical
reservations are permitted only when both cover that same logical capacity;
their full retained bytes remain accounted. Initialization rejects unequal
pairwise logical capacities or an undersized reservation before any session.
It never clamps a configured workload limit. This rule applies to the new P08
adapters; it does not silently restrict existing owned bank constructors.
Equal logical pair capacities keep the validated capacity stable when roles
change, as SPEC-013 requires. Allowing logical capacities to move with unequal
banks would need a different audit contract; copying bank contents would add
work at commit. Neither alternative is selected for this finite candidate.

An exchange moves the complete role descriptor, including the bank address and
any bank-local count/extent metadata held in the adapter. Moving only a pointer
while leaving its count behind would misinterpret the newly selected bank.
Logical capacity and common-session provenance remain invariant. No allocation,
bank copy, revalidation failure or recoverable return is introduced between
accepted offer and the two exchanges/revision update. The session excludes
observers/reentry throughout that operation; this is serialized publication,
not a claim of a hardware-atomic multiword swap. Refusal/discard performs no
exchange. The existing finishCandidate preflight and failure precedence remain
required even after successful storage initialization.

The checked physical initialization stage is separate from withP08Storage:

```swift
// Nonthrowing candidate signature; failure is an ordinary owned value.
fileprivate func initializeP08Backing(
    _ backing: inout P08TypedBackingOwner
) -> P08BackingInitializationFailure?
// Existing fixed callback signature is deliberately nonthrowing:
fileprivate func withP08Storage<Result>(
    backing: inout P08TypedBackingOwner,
    _ body: (consuming P08StorageSession) -> Result
) -> Result
```

The physical owner's private initial state has final reserved regions but no
initialized objects or live access. initializeP08Backing validates all capacities,
alignment and disjointness before initialization. It records each successful
typed geometry/bank initialization in a private fixed-capacity inventory. That
inventory and the owner's lifecycle flag are physical bookkeeping; Interaction's
phase/revision/key-pool control is held once in the scoped state. Existing host
control is supplied separately through its own lifetime input, not initialized
a second time as part of this inventory.
On failure it destroys precisely that initialized prefix in reverse order,
clears the inventory and returns an owned failure; no session exists yet.
Success leaves the complete validated initialized inventory and no live borrow.
withP08Storage requires that successful state, acquires the exclusive session
without fallible initialization, and invokes its body once. Callback operations
report failure through ordinary owned result/report values (the generic Result
cannot carry scoped payloads). Library cleanup resolves begun candidates and
ends accesses before releasing the borrow on every normal/owned-failure return,
with responsibilities assigned below.
No throwing-body cleanup promise, scoped error payload, trap recovery guarantee
or new exception mechanism is made. Exact inventory and field map remain B2.

The consuming callback owns the transferred session/host. The outer factory
cannot subsequently call methods on that consumed state. Therefore the closed
trusted assembly body must install structured cleanup around the live host
before activation and before any owned-failure early return. That cleanup owns
stop/drain, candidate resolution, pins/registrations, retirement and reset;
the storage factory owns only the enclosing physical borrow and its completion.
Dropping a noncopyable value does not itself prove semantic teardown. Audit each
body/early-return path; do not claim a compiler negative test proves cleanup.
Failure before host construction releases only the scopes actually acquired.

| Physical owner state | Permitted next action and cleanup owner |
| --- | --- |
| Reserved, no initialized objects | Checked initializer validates and initializes; failure unwinds its recorded prefix and returns to reserved |
| Initialized and idle | Factory may lend one session; repeated initialization is invalid and must not overwrite live objects |
| Session active | Trusted assembly body owns logical cleanup; owner cannot reinitialize, destroy or lend again |
| Body finished, all access scopes ended | Factory returns to initialized/idle only after quiescence and complete reset; physical bank objects remain initialized |
| Initialized/idle, final release | Physical owner destroys its inventory once in reverse initialization order, then releases regions |

A subsequent session is a fresh host activation, never continuation of the old
Interaction transaction. Previous committed records, counts, revision, gesture
capture and phase metadata cannot survive into a fresh state machine. Complete
reset occurs after quiescence while the retiring host still holds its accesses;
canonical initial role assignment is safe only after all five banks are empty.
Host/model generation issuance continues to obey existing stale-action rules;
resetting banks does not authorize reusing an old generation or callback.
If cleanup cannot establish these conditions, reuse/release is forbidden and the
existing invariant-failure disposition applies; no factory success or recovery
from a trap is claimed. B2 must show these transitions for both profiles.

Compile-time lifetime/copy checks and access control cover only the structural
API boundary. Swift may diagnose overlapping inout statically or use runtime
exclusivity enforcement; B1 must identify which for every negative and pinned
host/Embedded configuration. Trusted code also rejects reentrant activation and
preserves exclusive session state before invoking callbacks. Dynamic owners
must not expose shared mutable reference aliases or COW-buffer descriptors while
scoped access is active; any owned copy must be independent before entering the
exclusive factory. Physical disjointness, retained reference aliases, callback
quiescence and same-session bank provenance require runtime validation plus
trusted implementation review/B2 evidence. Absence of Sendable proves none of
those physical properties. No unchecked or disabled-exclusivity fallback is
permitted if target settings cannot enforce the selected rules.

### Replacing the live Interaction slot and commit semantics

There is no permission to reinterpret the live `CounterStaticKeys?` slot.
Adoption requires replacing its initializer, binding, state/control placement,
access construction, audit and deinitializer together. The new region inventory
must prove five disjoint initialized physical banks (candidate records, prepared
committed records, candidate hits, committed records, committed hits), one state
machine/control owner, alignment/padding and geometry region lifetimes. No old
optional keys owner or `interaction.take()` flow may coexist over the same bytes.
The old 2,412-byte size is evidence, not an approved new layout budget or proof
that the replacement fits. This exact realization is B2.

Commit may exchange the two R role handles and the two H role handles only
within the same exclusive common-owner session under R3, never across independently
borrowed handles or sessions. It MUST NOT transfer the physical destruction
responsibility or alias banks. `exchangeContents(with:)` must preserve the
existing logical exchange meaning, capacities and distinct initialized objects.
After finish preflight, accepted offer commits both role pairs and presentation
revision without fallible work or observer-visible half commit. Candidate reset
then targets the former committed banks. Refusal/discard resets only candidate/
prepared storage; prior committed routing remains valid. The physical owner
always destroys by its original initialization inventory, never by current role
handle order. All role exchanges preserve dependence on all five original banks.

## Module Responsibilities

| Module / owner | Responsibility | Dependency impact |
| --- | --- | --- |
| GiftUIInteraction | Transaction algorithm, complete key/record meaning, scoped storage/operation contracts | No host/platform import; callers must explicitly preserve access lifetimes |
| Runtime Static/Dynamic | Coordinate phases, storage audit and scoped carrier constraints | Preserve lower Interaction contracts and equal profile outcomes |
| Host composition / P08 fixture | Typed region ownership, restricted factories, exact binding and cleanup | Inputs visible in construction graph; platform lifetime stays outside Interaction |
| Semantic Core / Layout / Render | Existing semantic ownership and consumers | No alternate graph or new storage architecture selected |
| GiftUI / Presentation schema | Existing declaration and model facade contracts | No physical storage or platform exposure |

## Public API Impact

No public API is changed by this draft. Proposed package protocols and concrete
carriers have source/constraint effects across modules. Existing owned stores
remain viable storage implementations; their use must not force borrowed paths
back to Copyable/Escapable. A separate owned convenience path may remain only if
it cannot accept or extract scoped access values. The exact conditional Copyable/Escapable route selected under R1 requires B1
evidence; its compiler acceptance is not assumed.
External authors receive concrete safe operations, not the trusted conformance
surface. Public exposure later belongs to RFC-013 and its own approval.

## Capabilities Impact

No capability identifiers, negotiation or absence behavior changes. Missing or
invalid backing fails existing startup validation before activation; there is no
heap/profile fallback. Storage access is authority, not a capability advertisement.

## Backend Impact

Endpoint, raster, payload, in-flight, transport and input ownership remain as
specified. A backend may consume synchronous governed render views; it cannot
retain geometry or Interaction access. Platform region provision and callback
quiescence are explicit inputs, not hidden global service state. This RFC does
not create a backend-neutral storage framework.

## Static / Embedded Impact

Finite concrete adapters avoid nonescapable associated-type dependence. Typed
backing remains preactivated, bounded and zero-heap. Stable storage can be BSS
or an adequately scoped typed owner, but final binding/lifetime and constructor
stack cost require evidence. Owned native/Dynamic stores must satisfy equal
logical limits; their retained allocation and allocator overhead stay accounted.
Neither a simulator nor a host compile establishes nRF behavior.

## Performance

Expected benefit is fewer large construction transfers. There is no measured
improvement for this candidate. Additional handle loads, exclusivity checks,
specialization and role exchange may have costs. Existing service/frame pacing
and transport obligations remain. Actual complete nested stack, caller/callee
alignment and IRQ overlap are required; no local helper frame or type size is a
substitute. Existing 4 MHz failure remains separately qualified.

## Memory / Binary Size

Count physical banks once under their backing owner; separately count handles,
state/control, initialization inventory, padding, dynamic allocations, static
initialization and stack temporaries. Role changes do not change physical owner.
No new capture bank, larger RAM/stack/flash ceiling, reduced identity/corpus limit
or unaccounted rollback copy is proposed. Changed specialization/dispatch text
must be measured from the actual target image. Fit remains unproved.

The existing `counterMeasureInteraction` derives inline bytes from
`MemoryLayout<C/R/H>` and obtains retained storage through `withBacking`.
Substituting small adapter layouts into that formula would omit their physical
banks. The candidate instead takes physical extents from the backing owner's
validated owned inventory and logical counts/capacities from owned state
measurements. The fixture combines those facts without exporting bank access or
making GiftUIInteraction depend on counter/profile measurement types. It counts
key bytes within physical records once, and handles/control separately. B2 must
reconcile this result to actual retained regions across role exchanges; a small
adapter size is never a physical-bank measurement.

## Alternatives

| Direction | Strength | Cost / reason not selected as this draft's candidate |
| --- | --- | --- |
| Local fixture fix, keep existing owned Interaction generics | Smallest contract impact; may solve geometry transfer within current authority | Interaction's inline owners and construction copies remain; no evidence it resolves actual frame. Still a valid alternative if a concrete design proves fit; broader change is not demonstrated necessary |
| Stable retained owner + ordinary small escaping handle | Natural Dynamic representation if handle really retains an accounted owner | Ordinary pointer plus outer lease is insufficient; Static retention/reclamation needs bounded tickets and no heap. Different lifetime architecture and cost; not established by current evidence |
| Stable typed owner + scoped exclusive handles (candidate) | Keeps physical ownership fixed and Swift access bounded through host lifetime | Requires explicit cross-module generic contract change, complete carrier proof and slot replacement |
| Scoped borrow per phase | Shorter access intervals, may simplify phase-level APIs | State/control and committed routing persist between phases; repeated borrowing still needs one persistent owner and cannot export mutable adapters. Could be preferable after exact integration evidence |
| In-place construction | May avoid temporary physical-owner transfer, complements scoped access | Does not alone constrain pointer escape or generic storage constraints; typed partial initialization and actual compiler stack still need proof |

The candidate combines stable ownership, scoped access and final-region typed
initialization. It does not claim in-place syntax forces optimization or that a
portable amendment is the only possible P08 repair.

## Rejected Approaches

The independent review rejects adoption of the previous combined construction
candidate, not all pointer implementations. This draft excludes lifetime-erased
escaping pointer adapters; a separately stored outer lease without complete
carrier dependence; blanket suppressions without restricted construction/use;
rebinding five banks over a live Optional owner; copying keys as semantic-bank
indices; new heap/capture/stack limits; and an untested public generic conformance
surface treated as a safety guarantee. No other alternative has been reviewed
and rejected by this draft.

## Compatibility

Preserve exact source-route behavior, failure precedence, identity/action meaning,
publication/offer rules, target/compiler/ABI constraints and teardown. P08 generic
source signatures may change only after approval. Inventory all package call
sites and owned convenience routes; external package stability is not yet claimed.
No ABI or serialized representation promise is made here. Any conflict with
accepted ADRs or other approved Specs remains an approval blocker, not implied
permission from iteration inclusion.

## Testing Strategy

On 2026-10-13 the maintainer authorized minimum sequential feasibility experiments
with preserved repair limits and commits at each step. The separately bounded
[SPIKE-075](../spikes/spike-075-p08-state-feasibility.md) tests the state contract
first; it does not authorize the full matrix below or production repairs. Before
adoption, B1 needs an explicitly bounded validation authorization for exact new
syntax on the four required profiles and cross-module client boundaries. Test
both optimized and relevant diagnostics configurations under pinned flags;
assert semantic failure causes rather than arbitrary diagnostics. Required pairs:

| Positive | Negative and required reason |
| --- | --- |
| Construct/run/teardown one scoped host inside real owning borrow | Return host, geometry, Interaction state or adapter beyond any owner: lifetime escape |
| Consume each access through full supplied/pipeline/coordinator/host chain | Copy capability or use original after consume: noncopyable/use-after-consume |
| Move inside nested scope; return owned reports/records | Wrap in Optional/tuple/generic/closure and return or store externally: same lifetime escape, never wrapper erasure |
| Read committed owned record while legally borrowed | Extract pointer/base/bank, call private init, forge arbitrary storage conformance through client factory: inaccessible API / no supported generic entry |
| One exclusive activation, mutation through named methods | Second activation, owner mutation/rebinding/release or overlapping inout while first live: exclusivity/lifetime violation |
| Synchronous nonescaping work, no capture transfer | Escaping closure, task/Sendable transfer or async suspension with access: unsupported API/non-Sendable/lifetime violation |
| End scopes before backing destruction; owned native workspaces still return | Pass scoped access through CounterReturnedWorkspaces or stored Optional.take return: incompatible constraints or lifetime escape |
| Consume quiesced coordinator Optional into scoped retirement inside the owning callback; retire inert supplied storage after activation failure | Return the internal carrier beyond semantic/storage lifetime or the retired host beyond activation-span lifetime; call owned-only returnWorkspaces with scoped G/C/R/H: lifetime/constraint rejection |
| Copy complete owned identity into distinct banks | Retain semantic key reference instead: semantic/runtime conformance rejection, not claimed syntax proof |

For closure/Optional negatives, include both direct and generic helper routes and
ensure the rejection is not an unrelated missing conformance. Include a minimal
positive twin of every negative. A compiler accepting one required escape fails
the design; no unchecked wrapper repair or compiler bug claim is automatic.

After architecture/Spec approval and separate implementation authorization, test
partial initialization at each acquisition point, activation failure, owned-failure
callback cleanup, repeated sessions, teardown/quiescence, unequal owner
identity and capacities, repeated swaps, refusal/discard, first-excess pools,
identity/generation exhaustion, stale actions, semantic-bank reuse and exact
once destruction by physical address. Record role/address mapping before and
after exchange; verify no duplicate owner or adapter survives. Existing independent
semantic/action/pixel controls and actual image/stack/zero-heap evidence remain
required. These are future evidence obligations, not a new allowance.

Include body early returns before host construction, after activation failure,
during a failed candidate and after successful commit. Verify cleanup ownership
and exactly-once resolution, then run a fresh session on the same initialized
banks: no stale routing, old count or revision may reappear. Test unequal logical
pair capacities as initialization failures, and unequal physical extents with
equal sufficient logical capacities as valid constructions. Repeated exchanges
with different record counts must preserve address/count correspondence, stable
logical capacity and the original physical destruction/measurement inventory.

## Risks

Generic lifetime composition may fail under the pinned compiler; changes to
operational conformances may propagate further than intended. In that event
stop and return the concrete incompatibility for disposition. Internal unsafe
bridging still needs review of actual pointee lifetimes, aliasing and initialization.
A successful syntax matrix proves only supported API exclusions, not trusted
implementation correctness or physical resource fit. Construction may still
exceed stack after transfer removal. Partial failure, swapped roles and callbacks
can violate teardown unless audited by physical owner and actual phase.

## Open Questions

The independent initial review remains **not ready**. Response mapping:

| Finding | Draft correction | Evidence still missing |
| --- | --- | --- |
| R1 | Conditional Copyable/Escapable state route, full stored-field and initializer constraints | Actual compiler acceptance, owned-return/copy and scoped-negative pairs under B1 |
| R2 | Direct consumer table; scoped operation-only parameters, owned-only storing dispatcher/analyzer | Complete transitive/generated/client audit and cross-module B1 evidence; any counter need for retained scoped dispatcher is a new decision |
| R3 | One common actual-owner session lifetime on all concrete adapters; restricted paired exchange | Token/constructor/exchange propagation and physical provenance under B1/B2 |
| R4 | Nonthrowing callback with owned failures; separate checked physical init and prefix cleanup | Exact initializer/inventory/teardown realization and fault-path proof under B2 |
| V1 (revision review) | Scoped consuming retirement carrier and owned-only returnWorkspaces member | Full inert/active/Optional/reset lifetime proof under B1 |
| V2 (revision review) | Explicit trusted-body cleanup and physical-owner/session state transitions | Early-return, repeated-session and partial-failure proof under B2 |
| V3 (revision review) | Equal logical pair capacities, complete descriptor exchange and physical-owner measurement | Unequal-reservation, repeated-swap and ledger reconciliation under B2 |
| V4 (revision review) | RFC approval precedes ADR acceptance and Spec amendments | Human selection/evidence disposition remains B4 |

These are candidate choices, not approved decisions or a claim that the review's
findings have been independently closed. All remaining questions below are
**approval blockers**, not deferred decisions:

- **B1 — Expressible complete API:** Implement the specified interface fragments and
  cross-module positive/negative pairs for every carrier listed above under
  approved Swift 6.4. In particular prove protocol Self suppressions, state
  conformance, consumed generic lifetime union, Optional moves, existing
  coordinator constraints and exclusive factory closure behavior, R1 conditional
  owned conformances, R2 intermediate consumers, R3 common-session exchange and
  the scoped retirement/owned-return separation above.
  Distinguish static/access-control failures from runtime exclusivity checks. This needs
  separately authorized bounded evidence; existing patterns alone are insufficient.
- **B2 — Exact physical realization:** Provide the five-bank typed initialization,
  control-owner, final geometry storage and destruction inventory replacing the
  initialized old slot. Prove disjointness, partial failure and swap semantics;
  name every changed binding/initializer/deinitializer/audit site. Include the
  cleanup owner for each return path, repeat-session reset and the physical-bank
  measurement replacing the old adapter-size formula. No raw offset
  layout or exact byte promise is adopted here.
- **B3 — Narrow necessity and migration:** Independent review must compare the
  candidate with an ownership-preserving fixture-only design and identify the
  actual cross-module caller inventory. Evidence does not yet prove that the
  portable contract change is necessary or sufficient for P08 stack fit.
- **B4 — Authority and validation disposition:** Maintainer chooses whether to
  pursue this candidate after independent review, including a bounded way to
  resolve B1/B2 under closed budgets. Resolve the evidence and migration blockers
  before requesting RFC approval. After human RFC approval, extract a proposed
  additive ownership ADR (or explicit supersession if review finds a conflict),
  obtain its acceptance, then obtain approval of exact Spec amendments and prepare
  ready plans before implementation. ADR acceptance is not a prerequisite for approving
  its source RFC. No architectural acceptance is inferred from preparing this RFC.

## Deferred and Follow-up Work

[SPIKE-075](../spikes/spike-075-p08-state-feasibility.md) owns the first minimum
state-expressibility experiment under the new authorization. Its first run passed
the shadow declarations and positive client on macOS Dynamic, then stopped on a
copy-test helper that inadvertently required Escapable as well as Copyable.
Strong exit review classifies this as inconclusive fixture evidence, not a
falsified RFC contract. Escape negatives and other profiles remain unrun; the
zero-repair package has ended. Its evidence feeds B1; it neither defers a blocker
nor approves this RFC. Complete carrier feasibility
still needs evidence if that first gate passes. Detailed implementation migration,
physical layout and complete linked resource/stack acceptance remain downstream
conformance work; RFC approval needs a viable ownership/cleanup plan and enough
compiler evidence to establish the selected architecture, not completed production
conformance. Historical experiment budgets remain closed.

[FW-037](../future-work/fw-037-core-wide-storage-ownership-generalization.md)
captures evaluation of this separation for frontend/backend/platform-independent
GiftUI Core and simulator integration. The maintainer scheduled this assessment
in [ITERATION-004](../iterations/iteration-004-backend-and-application-integration.md)
revision 3, I4-06 / I4-AC-007. It will assess a concrete second consumer and
record any missing P08 evidence; scheduling does not adopt this draft.
Existing FW-022, FW-035 and EXP-002 retain simulator, generated-frontends and
integration-shape questions. None is required to settle P08. B1–B4 cannot be
moved there to make this RFC appear complete.

## Decision Summary

Candidate ADR extraction after RFC approval: one focused additive P08 storage
ownership decision distinguishing physical owner, transaction owner and scoped
access, restricting trusted construction, and requiring a complete type-carrier
chain. Preserve ADR-035's complete key ownership, ADR-036's stable backing/model
pins and ADR-038's construction/operation distinction. A conflict requires explicit
reviewed supersession rather than silent reinterpretation.

Exact proposed downstream impact, **not applied**:

| Artifact | Proposed change | Existing obligation retained |
| --- | --- | --- |
| SPEC-011 Types/APIs and lifecycle | Explicit scoped/noncopyable Self on three storage and three operation protocols; scoped state/owned-key carrier constraints, restricted construction/access, exact role exchange | Complete independently owned keys, accepted-offer commit, refusal/discard, exact identities/generations and bounded infallible resolution |
| SPEC-013 storage / coordinator contracts | Carrier constraints through actual Static/Dynamic coordinator and retirement uses; typed physical-owner accounting, capacity invariants and assigned session cleanup | Equal bounds/outcomes, zero-heap Static, phase/pin/publication order and complete resource ledger |
| SPEC-015 host construction/lifetime and HC-RD-002/003 evidence | Supplied/host geometry+Interaction dependence, no scoped returned-workspace path, physical slot/init/deinit inventory, full negative matrix | Validation before activation, exact construction inputs, no stale dispatch, backing last and unchanged target limits |
| P08 plan/design/evidence | Only after approved contracts: map tasks to adopted declarations and explicit separately authorized validation | P08/R07/T8.1 remain open; P09–P12 and hardware unaffected; historical budgets/stop guards remain closed |

Other Specs/ADRs may be named by B3's concrete caller audit; none is silently
amended now. New work outside the accepted problem requires its own scope gate.

## References

- [SPEC-011](../specs/spec-011-interaction.md), runtime amendment, Types/APIs,
  candidate/generation behavior and State/Lifecycle.
- [SPEC-013](../specs/spec-013-runtime-profiles.md), runtime amendment ownership,
  cycle order and scoped coordinator corrections.
- [SPEC-015](../specs/spec-015-host-configuration.md), schema-4 owners, scoped host
  lifetime, construction/operation contracts and HC-RD-002/003.
- [ADR-035](../adrs/adr-035-runtime-derived-records-and-exact-identity.md),
  [ADR-036](../adrs/adr-036-scoped-model-access-and-bounded-ownership.md),
  [ADR-038](../adrs/adr-038-construction-graph-and-operational-contracts.md).
- [Current model scope factory](../../Sources/GiftUIObservableState/ObservableModelScope.swift),
  [root scope](../../Sources/GiftUIObservableState/ObservableStateRootScope.swift),
  [Interaction storage](../../Sources/GiftUIInteraction/InteractionStorage.swift),
  [Interaction state](../../Sources/GiftUIInteraction/InteractionState.swift),
  [owned key state](../../Sources/GiftUIInteraction/InteractionOwnedKeyState.swift).
- [Counter geometry](../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterGeometry.swift),
  [pipeline](../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift),
  [host](../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterHostOwner.swift),
  [returned workspaces](../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterStorageMeasurement.swift).
- [Approved iteration scope](../iterations/iteration-003-dev-ux-improvement.md),
  [RFC-014 implementation plan](../iterations/iteration-003-review/rfc-014-implementation-plan.md),
  [baseline compiler approval](../iterations/iteration-003-review/rfc-014-spec-approval.md#swift-64-compiler-baseline-correction--2026-10-12).
