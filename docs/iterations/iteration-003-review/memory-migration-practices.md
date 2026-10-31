# Memory migration practices for iteration 3

Updated 2026-10-31. Companion to the [mandatory MR-01–08 rules](../iteration-003-dev-ux-improvement.md#mandatory-memory-ruleset)
and [batch workflow](../iteration-003-dev-ux-improvement.md#mandatory-batch-execution-workflow).
These are implementation recipes under existing ADRs/Specifications, not new
contracts or blanket allocation guarantees. Use the matching existing realization
before inventing another one. An incompatible case must be recorded as a batch
exception and qualified separately; do not force it into a superficially similar
example or waive a rule.

## Provenance and how to use this guide

The mined window is the latest 100 commits ending at `169174c9`, from
`41911d2a` through `169174c9` (2026-10-19–29). An inventory found 21 commits
changing source, maintained tools or non-evidence fixtures; the other 79 changed
records/evidence. Selected implementation diffs and their scoped review/result
records ground the recipes below. This is not a claim to have requalified every
historical artifact. Current uncommitted experiments are not accepted exemplars.

Before editing, choose the applicable recipe(s), open the named symbols and
check their current signature against the cited historical commit. Record the
choice in the existing batch receipt's MR mapping. Code blocks are excerpts or
explicitly labelled sketches, not standalone programs. For pinned context use,
for example, `git show d8cc0c18 -- Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterModelProbe.swift`.
A historical scoped PASS proves only the stated boundary; refresh applicability
before using it for changed code, another generic instantiation or another profile.

| Worker encounters | Start with | Mandatory rules |
| --- | --- | --- |
| Optional/enum comparison in an allocation-sensitive path | MP-01 | MR-05/08 |
| Fixed test vectors or backing accidentally expressed as Array | MP-02 | MR-04/07/08 |
| Native Static generic owning-model construction | MP-03 | MR-01/02/04/06 |
| Generic method/initializer opaque across a module boundary | MP-04 | MR-05/08 |
| Type-independent facts fetched through a generic owner | MP-05 | MR-05/07/08 |
| Generic physical workspace/sink pulls runtime metadata into Static entry | MP-06 | MR-01/02/04/05/08 |
| Mutation, candidate transfer, early failure or teardown | MP-07 | MR-01/02/03/06 |
| Variadic or interpolated diagnostics inside the charged Static route | MP-08 | MR-04/05/08 |
| Small probes pass but the actual Static entry still fails | MP-09 | MR-04/05/07 |
| A migration needs equivalence tests and a bounded feedback loop | MP-10 | MR-06/07/08 |

## MP-01 — Match presence or an exact case without asking for equality

**Use when:** only presence or a particular enum case is required. In
`08f063cd`, Interaction move/up stopped requesting an unnecessary generic
Equatable witness. `5badd1fe` applied related case checks across the finite
fixtures, preserving short-circuit order and payload checks.

```swift
// Before: only presence matters here.
guard capturedRecord(captured, contains: point) != nil else {
    return .cancelled
}
// After: same one evaluation and rejection path.
guard case .some = capturedRecord(captured, contains: point) else {
    return .cancelled
}
```

Reuse [InteractionState](../../../Sources/GiftUIInteraction/InteractionState.swift)
`resolveMove`/`resolveUp` checks and [CounterAdmission](../../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterAdmission.swift).
For `Optional<Enum>`, match `.some(.case)` explicitly. For an associated-value
case, preserve every previously compared payload field; `.some` alone cannot
replace value equality. Keep the evaluation order of side-effecting getters and
short-circuit conditions. Do not remove required Equatable conformances.

**Check:** nil/some, unequal payload and wrong-case outcomes, first-error order,
then the actual compiled caller. The [witness45 result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-witness45-result/README.md)
accepted removal of three specific witness origins but retained a metadata
call. Private inlining had moved that boundary rather than resolving it and was
reverted. `5badd1fe` had focused functional success but exceeded its retention
budget; it is not an accepted complete batch or global no-allocation result.

## MP-02 — Give every fixed collection dimension a fixed type

**Use when:** a finite, compile-time table is intended. Typing the loop element
as InlineArray does not make the surrounding literal an InlineArray.
`80c6c6be` replaced two inferred ordinary outer Arrays with one shared table.

```swift
let invalidCapacityCases: InlineArray<5, InlineArray<5, UInt16>> = [
    [1, 2, 2, 2, 2],
    [2, 1, 2, 2, 1],
    [2, 2, 1, 1, 2],
    [2, 2, 2, 1, 2],
    [2, 2, 2, 2, 1],
]
for capacityIndex in 0..<5 {
    let capacities = invalidCapacityCases[capacityIndex]
    // Existing refusal assertions, unchanged.
}
```

Reuse `invalidCapacityCases` in [CounterScopedStorage](../../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterScopedStorage.swift).
Preserve vectors, iteration order and all Static/Dynamic assertions. Do not
rewrite unbounded collections to a guessed capacity. Inspect initialization,
copying and closure captures too: InlineArray is a representation choice, not
an automatic guarantee that every containing function avoids allocation.

**Check:** output equivalence and compiled removal at the actual caller; account
for simultaneous storage and stack. The [capacity33 result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-capacity33-result/README.md)
confirmed removal of two array-storage origins; global allocator imports stayed
17→17. Its logical 50-byte payload was not a measured stack bound.

## MP-03 — Lend caller-owned typed backing through the existing checked scope

**Use when:** Native Static model construction is governed by ADR-041. Reuse
`d8cc0c18`'s construction migration; retain the same scoped model operations.

```swift
var ownership = ObservableModelOwnership(
    identity: try namespace.issue(), captureLimit: 0)!
var backing: InlineArray<2, CounterOwnedModel?> = .init { _ in nil }
var models = backing.mutableSpan
checks += try withObservableModelScope(
    ownership: &ownership, models: &models, schema: 1, needsCapture: false
) { (models) throws(ObservableStateError) in
    try counterScopedModel(models)
}
```

This excerpt assumes the surrounding Counter fixture's throwing context,
namespace and check count. Reuse [CounterModelProbe](../../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterModelProbe.swift)
and the matching [CycleProfileStorage](../../../Tests/ContractFixtures/SPEC013/RuntimeDerived/CycleProfileStorage.swift)
control. Keep backing and ownership alive through all claims, callbacks and
cleanup; do not return a raw descriptor from the lending closure. Preserve the
Embedded owning branch and Dynamic control. The fixture's known-valid force
unwrap is not a recipe for handling arbitrary configuration input.

**Check:** matching model/host prerequisites, populated destruction, foreign-owner
and capacity refusals, retained tickets, repeat activation and escape negatives.
Include initialization and destruction in the charged lifetime. The
[typed-backing review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-typedBacking61-result/final-review.md)
is scoped evidence; provider/live-state/resource and P08 acceptance remained open.

## MP-04 — Expose the finite specialization chain, not just its top method

**Use when:** a demonstrated generic boundary prevents specialization. Commits
`e4c36a94`, `71e28609` and `e55628c2` made the necessary operations and explicit
initializers available to the consumer optimizer. Work through the relevant
constructor, fields and callees as one mechanism group.

```swift
// Excerpt from InteractionStorage.swift after e4c36a94.
@inlinable
package init(identity: Identity, bounds: Rect, paintOrder: UInt16) {
    self.identity = identity
    self.bounds = bounds
    self.paintOrder = paintOrder
}
```

In [InteractionStorage](../../../Sources/GiftUIInteraction/InteractionStorage.swift),
the enclosing generic record and fields needed by this body are
`@usableFromInline`; the explicit initializer exposes work that an opaque
synthesized initializer did not. Follow through
[InteractionOwnedKeyState](../../../Sources/GiftUIInteraction/InteractionOwnedKeyState.swift)
and its concrete consumer. Preserve access restrictions and lifetime annotations.
Add only visibility required by the selected chain; do not mechanically make
all methods public/inlinable or add `@inline(__always)` everywhere.

**Check:** compiled concrete consumer and reached cleanup, all behavior/refusal
controls, exports and code-size/resource effects. These annotations enable
optimization; they neither force successful specialization nor certify zero heap.
A moved metadata call is still unresolved. Apply MP-09 to the actual entry.

## MP-05 — Put type-independent facts on the existing nongeneric owner

**Use when:** a generic accessor returns facts that do not depend on its type
argument. `169174c9` moved the implementation of root capacities to RootControl
while retaining the generic compatibility getter and its export.

```swift
// ObservableStateRootStorage<Identity>: retain the existing facade.
package static var storageCapacities:
    (locations: UInt16, registrations: UInt16, associations: UInt16)
{ ObservableStateRootControl.storageCapacities() }

// ObservableStateRootControl: one implementation of these facts.
package static func storageCapacities() -> (
    locations: UInt16, registrations: UInt16, associations: UInt16
) { (2, 2, 2) }
```

Reuse [ObservableStateRootScope](../../../Sources/GiftUIObservableState/ObservableStateRootScope.swift)
and [OwnerRootQualification](../../../Tests/ContractFixtures/SPEC015/AllocationGate/OwnerRootQualification.swift).
Ordinary and qualified accounting must use the same implementation. For stored
facts, forward the actual field, as `identityForAccounting()` and
`capacityForAccounting()` do; do not replace it with a plausible constant.
Never hoist type-dependent size/alignment or capacities into a false universal
constant. Keep layout and existing compatibility signatures unless separately
authorized to change them.

**Check:** original/generic/concrete results, invalid limits and overflow,
independent field/layout accounting, ordinary exports and imported effect caller.
The [owner/root result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-static-owner-root-qualification1-result/README.md)
accepted that boundary; the full entry still failed on the captured accumulator.

## MP-06 — Supply concrete physical storage while keeping one algorithm

**Use when:** the existing approved composition permits a concrete realization
of shared operations. `17e9da5f` supplied concrete sinks/codecs and canonical
consumer payloads; `04e7cc6e` supplied Counter workspace/traversal storage.

```swift
// Excerpt: only the physical realization is Counter-specific.
struct CounterRecordWorkspace: SemanticExpansionWorkspace {
    typealias Identity = SemanticCompleteIdentity
    var state: SemanticRecordWorkspaceState
    // Other required forwarding operations omitted here.
    mutating func beginExpansion() -> Bool { state.beginExpansion() }
    mutating func discardExpansion() { state.discardExpansion() }
}
```

Reuse `CounterRecordWorkspace` / `CounterSemanticTraversal` in
[CounterSemantic](../../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterSemantic.swift),
forwarding to `SemanticRecordWorkspaceState` / `SemanticExpansionAttempt` and
shared traversal operations. Keep the concrete carrier's existing `~Copyable`,
`~Escapable`, consuming transfers and lifetime dependencies. Do not copy the
semantic traversal state machine into a Counter-only implementation.

For Canvas, reuse [SemanticRecordPayload](../../../Sources/GiftUISemanticCore/SemanticRecordPayload.swift)
(`standard` or `canvas` marker) and the typed attempt-owned pending buffers in
[CanvasSemanticPayload](../../../Sources/GiftUIDrawing/CanvasSemanticPayload.swift).
Keep owner/bank/revision/ordinal joins and staged-value transfer validation;
do not retain captures in the canonical consumer bank or substitute untyped
pointers. This is the existing Canvas realization, not permission to redesign
other public representations.

**Check:** layout/render/interaction consumers, complete output and cleanup,
actual instantiated ownership/callee chain and physical storage deltas. The
[workspace/traversal result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-traversal-realization-result/README.md)
accepted a scoped dependency removal, not global allocation/resource eligibility.

## MP-07 — Preflight before writes; attach cleanup to the owning scope

**Use when:** changing mutation, transfer, partial initialization or retirement.
The retained [ObservableModelMutation](../../../Sources/GiftUIObservableState/ObservableModelMutation.swift)
API is the starting point, not a new API introduced by this commit window:

```swift
borrowing func preflight(_ mutation: Mutation)
    throws(ObservableStateError) -> Prepared
mutating func commit(_ prepared: Prepared) -> Bool
```

Use bounded prepared data and the existing checked mutation route. Keep commit
nonthrowing and preserve no-op reporting semantics; never implement rollback by
copying the entire capture or replaying admitted operations.

For scoped temporary ownership, `17e9da5f`'s
`withCanvasSemanticPayloadCodec` establishes typed buffers, builds the scoped
codec and installs `defer { codec.discardPending() }` before invoking the body.
The transfer separately validates the candidate owner **before** entering
cleanup that may discard it. Follow that ordering: rejection of a foreign
candidate must not destroy someone else's captures. Clear only initialized
entries; return/reset metadata to the specified inert state.

For retirement tests, reuse `d02ecc8b`'s
[RootStoppedActivationFaultControl](../../../Tests/ContractFixtures/SPEC015/RootStoppedActivationFaultControl.swift):
retain an independent ticket across the root callback, inject detach failure and
retired-unregister refusal, and observe sink/model destruction exactly once.
The successful case releases the still-valid independent claim normally; the
stopped case must not release a revoked claim through a retired scope.

**Check:** normal exit, precommit rejection, partial transfer/initialization,
early throw/return, failed activation and retained claims. The
[fault-control result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-u03-fault-control5-result/README.md)
observed destruction before `withRoot` returned; placement inside the internal
report-storage borrow was established separately by source ordering. Do not
claim a stronger runtime observation than the fixture actually makes.

## MP-08 — Use bounded typed diagnostics inside the Static route

**Use when:** diagnostics are part of the charged allocation-sensitive path.
`ebc98c69`, `95bec0b4` and `5f6f0261` replace variadic `print`/generic rendering
with finite overloads, `StaticString` fragments and bounded numeric text.

```swift
// Excerpt from the Native Static diagnostic implementation.
private func counterTraceWrite(_ text: StaticString) {
    text.withUTF8Buffer { bytes in
        for byte in bytes { _ = putchar(Int32(byte)) }
    }
}
```

Reuse `counterTrace` / `counterTraceWrite` in
[CounterPipelineOwner](../../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift).
Preserve labels, separators, type spelling, numeric range, leading zeroes and
newlines; do not silence diagnostics to pass an allocation check. This Darwin
writer is behind its existing Native Static condition, not a portable Embedded
logging backend. Do not introduce `String`, interpolation, variadic `Any` storage
or a captured growable collection in an otherwise bounded replacement.

**Check:** full output comparison with only already-approved address normalization,
integer boundary cases and actual writer/provider applicability. Removing Swift
variadic storage does not prove that `putchar` or its system provider never
allocates; required first-use/provider checks still apply.

## MP-09 — Check defining modules and the complete actual entry

**Use when:** an allocation promise is being qualified. `3f9ba09d` installed the
maintained [Counter allocation gate](../../../scripts/contracts/check-spec-015-counter-allocation.py).
It checks the actual `p08CounterStaticResourceEntryV1`; `dafaaf8d` separated
that complete Static resource workload from the mixed functional workload,
which remains a behavioral control. Do not delete Dynamic checks from the
mixed corpus or move Static setup/cleanup outside the charged entry.

The gate's paired controls deliberately differ:

```swift
// Positive control: source in NoAllocationPositive.swift.
@_noAllocation
@inline(never)
public func noAllocationPositive(_ input: Int) -> Int {
    input &+ 1
}
// Negative control returns a freshly allocated AllocationBox and must fail.
```

Use the existing gate's argument parser and current authenticated build manifest,
not a copied historical command with stale module paths. Its initial
[gate result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-native-static-allocation-gate-result/README.md)
passed the harmless control, rejected the allocating control and refused a stale
Semantic dependency, then rejected the real graph-validation entry. A functioning
gate can correctly report FAIL for the product.

`86a6aaa9`, `10a6b7bf`, `f65e2081` and `169174c9` show the complementary pattern:
compile concrete operations in their defining modules with the existing
qualification flag, then check the imported consumer with the matching module
and object. Keep the ordinary and annotated implementation body identical;
verify ordinary behavior/exports as well. Reuse the finite fixtures under
[AllocationGate](../../../Tests/ContractFixtures/SPEC015/AllocationGate).
Do not add annotations to unproved declarations just to hide an opaque callee,
disable verification, substitute a warmed entry or infer success from fewer
allocator symbols. An allocation diagnostic is a rejected compiler promise,
not a measurement that allocation actually occurred.

**Check:** positive/negative enforcement, exact provider provenance, actual
constructor→operation→failure→cleanup chain, ordinary ABI/behavior and remaining
foreign-provider/cold/resource duties. A leaf PASS never closes the full entry.

## MP-10 — Keep the oracle independent and repair a whole mechanism group

**Use when:** porting tests or collecting failures for a mechanical batch.
Follow the complete comparisons in `08f063cd`, `80c6c6be`, `d8cc0c18` and
`04e7cc6e`: preserve all cases, payload fields, first-error behavior, output
order and the registered address-only normalization. The new implementation
must not compute both the expected and actual result through the same new
policy. Host-only observation scaffolding may allocate (the retirement control
uses a class and Array); label that boundary and do not treat its whole program
as a Static allocation/resource test.

For each batch use this short checklist in the existing receipt:

1. List matching sites, recipe IDs and MR/contract rows; include constructors,
   default arguments, callbacks and destruction, not only the diagnostic line.
2. Reuse applicable evidence; qualify the missing representative mechanism and
   affected target boundary once before migrating equivalent sites.
3. Apply the whole group, compile affected modules, then run focused behavior
   and the integrated entry. Record newly exposed independent blockers together.
4. Repair by cause; do not start another helper-sized approval, controller or
   full matrix for each next diagnostic. Two unproductive corrections trigger
   mechanism reassessment within existing authority and allowance.
5. Run the required package acceptance gate and record focused/full timing,
   applicable reused results and still-open criteria. Stop at the package exit.

The other 79 commits in the window are evidence/process history, not 79 patterns
to reproduce. Keep necessary provenance and failures, but use existing runners,
one current summary and one package receipt. A historical one-shot controller,
provider crawl or receipt chain is not a default prerequisite for a source edit.

## Boundaries workers must keep visible

- These recipes are mandatory starting practices when their conditions match;
  qualification is per mechanism and applicability, not a permanent whitelist.
- A failed metadata-removal attempt, moved opaque call, unexecuted test or
  exceeded execution budget remains a failure/unknown at that boundary.
- Do not copy current uncommitted accumulator/visitor experiments as accepted
  practice. Consult the [current checkpoint](complexity-and-efficiency-checkpoint.md)
  for their disposition and the next authorized package.
- Full lifetime/owner controls, strict cold/zero-heap evidence, target fit and
  existing independent acceptance reviews remain required. No recipe promotes
  P08, substitutes host evidence for hardware, or increases a resource limit.
