---
spec: SPEC-015
feature: giftui-mvp-architecture
title: Implementation Design — P08 Checked State Serialization
status: draft
authors: [codex]
created: 2026-10-17
updated: 2026-10-17
implementation_plan: ../implementation-plans/spec-015-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# P08 checked State serialization

Historical readiness correction: `dbbf96a6` incorrectly claimed the repaired runner
files existed and were archived. Read-only inspection found both absent because
the aborted approval also prevented their writes. The linked WIP receipt now
records first actual separate workspace preparation and a distinct two-file
archive; no compiler/test/continuation execution occurred.

Current [final correction WIP](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/checked-state-correction2/README.md):
macro compile/link pass; standalone runner setup failed on unavailable macOS APIs.
The confirmed macOS repair has not executed: escalated command request aborted
by the user. Exact maintained regression/provider gates remain pending, with no
production PASS/FAIL. Initial1/1/corrections2/2 in progress, source unaccepted;
no retry/alternate route or further source variant. P08/R07/T8.1 remain open.

Current [corrective1 STOP](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/checked-state-correction1/README.md):
exact mapper annotation clears schema; first presentation compile reports two
missing generated helper declaration separators. Initial1/1/corrections1/2 consumed;
no retry or later gate. Source unaccepted; P08/R07/T8.1 open. Earlier checkpoints
below retain historical accounting.

[Independent final corrective2 recipe PASS](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-checked-state-correction2-design-review.md)
confirms both separators have one helper-append cause. Within the existing
lowerer/test map, add leading separating newline trivia to every appended helper
and regress actual verbatim lowerer output for Counter and supported multi/nested
State declarations. Require a parser negative control on frozen failed output and
positive actual-output parsing before the fresh provider chain. No generated-text
repair, helper AST/semantics change or new allowance; correction2/2 is final and
has not begun at this review. A failed positive gate freezes the final attempt.

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification. Design only: no source, compiler or runtime result
> is claimed. [Independent Strong design review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-checked-state-serialization-independent-design-review.md)
> passes this design with the structural matching clarification below; execution
> evidence is still required.

## Purpose and Boundary

Current [initial candidate receipt](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/checked-state-candidate1/README.md)
is STOP: macro/lowering/fresh GiftUI pass, generated schema compile fails on the
non-ABI checked DrawingError mapper. Initial1/1 consumed, corrections0/2; no retry,
presentation/private/physical/actual-consumer/runtime result. Independent review
must assess the exact missing dependency before any grouped correction.

Select one checked forwarding candidate over the unaccepted `3ae67711` source
experiment. The [new activity record](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-checked-state-serialization-activity.md)
records the maintainer's renewed bounded direction separately from the exhausted
Native cold pipeline activity. Its historical initial candidate and 2/2 corrections
remain closed. Nothing is restored or adopted implicitly.

The candidate removes the five illegal direct private references identified by
[final independent review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-native-cold-pipeline-correction2-independent-review.md):
four key reads in generated evaluation and one mutable State-declaration visit.
It must also pass the complete strict cold pipeline gates. Solving privacy alone
is insufficient. Static construction, actions and teardown still allocate zero
heap, including first-use metadata and access-enforcement TLS.

## Governing Contract

SPEC-015 remains `implementing`, its [plan](../implementation-plans/spec-015-implementation-plan.md)
active, and P08/R07/T8.1 open. ITERATION-003 I3-04/I3-05 require the finite counter
before analyzer migration; ITERATION-001's common application and macOS Static
stack validation provide the retained reference requirement. Full RFC-015/I4-07,
P09–P12, timing and connected hardware obligations are unchanged.

The governing clauses are:

- [SPEC-006 compiled View and traversal](../specs/spec-006-declarative-view-semantics.md#compiled-view-and-traversal):
  fixed domains, inferred Body, source lowering, both visitor suppressions and
  Domain equality; no graph expansion or hand-authored traversal replacement.
- [SPEC-010 scoped visitor and model contract](../specs/spec-010-observable-reference-state.md#scoped-declaration-visitor):
  lexical enumeration, original `inout State<Schema>` visitation, complete binding
  before evaluation, checked keys/facades and read/mutation exclusion.
- [SPEC-013 S13.1–2](../specs/spec-013-runtime-profiles.md#s131-physical-owner-session-and-coordinator-contract),
  [SPEC-015 S15.1–2](../specs/spec-015-host-configuration.md#s151-construction-transfers-and-retirement)
  and [performance requirements](../specs/spec-015-host-configuration.md#performance-requirements):
  actual-owner borrows, provenance, fourteen loans, Optional lifetime union,
  checked failure/cleanup and strict resource evidence.
- Accepted [ADR-036](../adrs/adr-036-scoped-model-access-and-bounded-ownership.md),
  [ADR-039](../adrs/adr-039-scoped-storage-ownership.md) and the narrow counter
  physical-RAM [ADR-040](../adrs/adr-040-counter-physical-sram-budget.md) exception.
  ADR-040 supplies no heap, ownership or privacy exception.

## Current-Code Context

`FiniteSourceLowering.Lowerer` turns private authored `@State` into private
`@State<CounterModelSchema>` while introducing the phantom domain parameter D.
`ObservableStateHostMacro` generates the visitor and semantic traversal.
`State._giftUIKey()` checks the bound case; the generated facade then performs
the established read/owner/schema/occupied/generation checks. Binding uses
`ScopedObservableDeclarationVisitor.visit`, which guards first failure and schema
identity before the existing checked root encounter.

`withBoundDeclaration` intentionally copies the ordinary View declaration into
its existing transient and binds that transient. This design adds no declaration
or State copy: the visitor must modify the actual original wrapper **inside that
existing transient**, not a getter result or a second wrapper. The bound transient
must be the declaration evaluated afterward.

The [physical serialization evidence](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-pipeline-serialization-result/README.md)
proves the old missing bodies and explains why enclosing ABI usability is needed.
Its archived official Swift 6.4.0 `DeclContext.cpp`, `Decl.cpp`, `TypeCheckAttr.cpp`
and `CrossModuleOptimization.cpp` are evidence about eligibility, not proof of
future specialization. `@usableFromInline` does not permit private backing to be
named in an `@inlinable` body. The private projection bodies below deliberately
remain non-inlinable. No package-CMO flag, serialize-all mode or runtime change is
selected.

## Proposed Internal Organization

The finite lowerer emits a pair of **internal ABI-usable** helpers for each known
State declaration, in its owning presentation nominal. For the actual counter,
the intended generated shape is:

```swift
// Existing declaration, private wrapper, concrete schema and inert seed remain.
@State<CounterModelSchema>(seed: CounterModelSchemaSeed(value: 0))
private var model: _GiftUIModelKey<CounterModelSchema>?

@usableFromInline
internal var _giftUIStateStorage_model: State<CounterModelSchema> {
    _read { yield _model }
    _modify { yield &_model }
}

@usableFromInline
internal borrowing func _giftUIStateKey_model()
    throws(_GiftUIAccessFailure) -> _GiftUIModelKey<CounterModelSchema>
{
    try _model._giftUIKey()
}
```

These are spelling examples to implement under the pinned compiler, not compiled
source. Neither helper is `@inlinable`, `@_transparent` or an always-emitted body.
The yielding accessor has no setter, temporary, stored alias, callback, pointer,
allocation or registration of its own. `_modify` yields the actual field address
under Swift's ordinary exclusive self borrow; `_read` yields a borrow. The key
helper returns only the existing inert nonowning key. It does not construct a
read facade, owner, scope, ticket or unchecked capability.

The lowerer, rather than the attached macro, emits these new names. Preserve the
public macro's exact declared-names list and both public protocols. For the
finite lowered shape, the member macro recognizes the matching concrete State /
Key schema and exact helper pair and emits:

```swift
visitor.visit(&self._giftUIStateStorage_model, declarationOrdinal: 0)
```

The helper pair must be matched deterministically against that declaration;
reject incomplete/mismatched reserved generated members in finite lowering.
Do not infer trust from an arbitrary authored helper name. Unlowered macro inputs
retain their existing direct-field route and constraints; do not force ABI
helpers onto unrelated declarations. Existing private ordinary macro fixtures
must continue to compile. No arbitrary-name addition to `@ObservableStateHost`
or application-name special case is needed.

**Independent review clarification — route selection.** Before adding helpers,
the lowerer rejects authored members colliding with either reserved generated
name, including overloads and escaped spellings of the same identifier. Inventory
and validation stay local to each owning nominal and each lexical State; a nested
or sibling member cannot satisfy another declaration's pair. The member macro
selects this route only after validating the complete finite shape and exactly
one matching pair: instance internal ABI-usable members, the identical concrete
schema, only `_read { yield _model }` / `_modify { yield &_model }` on the storage
projection, and the nongeneric borrowing typed-throwing key helper whose sole
operation is `try _model._giftUIKey()`. Match parsed structure and the original
field identifier, not source substrings or name prefixes. A setter, extra effects,
different field, replacement wrapper, wrong schema, overload, missing member or
malformed reserved pair is a diagnostic, never a fallback to an unsafe route.
No cross-expansion state or generated-origin authentication is assumed: syntax
cannot prove emission history; the complete validated shape establishes the
selected operation, and the lowerer rejects input collisions before emission.
Unlowered declarations without reserved members retain the existing direct route.
Positive multiple/nested declarations and negative lookalike, swapped-field,
wrong-schema, duplicate/overloaded, incomplete and getter/setter tests are required.

The three existing read-rewrite sites (`DeclReferenceExpr`, `self.member`, and
`modelPath` root) call `try self._giftUIStateKey_model()` at the exact original
read position. Four counter key reads remain four reads in their original order.
Do not hoist, cache, substitute `wrappedValue`, suppress errors or add a fallback.
Serialized evaluation/traversal and declaration visitation reference only the
helpers, never `_model` directly. Canvas still receives only its existing key.

## Algorithms and Data Structures

The opaque boundary is intentionally **not generic in Visitor, Schema, Result or
callback type**. Its State and key types name the concrete schema from the finite
inventory. No opaque `withState<Visitor>` wrapper or opaque body-producing wrapper
is introduced. Those shapes would preserve the generic metadata problem.

The enclosing `CounterScreen<D>` remains generic in phantom D. Its backing shape
is independent of D; the selected D is the existing nongeneric `CounterDomain`,
whose read-slot behavior stays in the actual consumer. A projection needs only
that statically known field layout. The owning module can specialize the checked
State key operation for the fixed schema. The serialized caller can specialize
`visit<CounterModelSchema>` with its actual scoped binder after the yielding
projection; no visitor metadata crosses the opaque projection function.

This is a reason to screen the candidate, **not a claim that Swift will erase
all metadata**. The early gate must reject a generic Self metadata instantiation,
context allocation, metadata/conformance lookup or dynamic exclusivity TLS on
this selected route. An unused generic D argument alone is not a failure if it
uses already static nongeneric metadata and proves no allocating lookup. Inspect
the callee and its continuation/destruction too, not only the caller's signature.
The generic protocol remains valid for all other conformers.

Opaque is a serialization boundary, not a promise of `@inline(never)` or a new
optimization policy. Accept an optimizer-incorporated checked operation only when
its owning definition and the actual selected caller/coroutine path prove the same
field yield, checks and complete resource cost. Otherwise retain and inspect its
call, continuation and cleanup; an absent call alone is not evidence of zero cost.

In `GiftUI/ObservableState.swift`, expose only required implementation details to
serialized checked operations: `State.Storage` and `storage` become internal
`@usableFromInline` implementation members; `_GiftUIBoundState` and its existing
fields/initializer receive ABI usability as required. Keep existing source access
for package declarations and do not make a constructor public. Serialize existing
`State.init(seed:)`, `init(candidate:)`, `_giftUIKey`, `_giftUIInitial`,
`_giftUIBinding` and `_giftUIBind` bodies so fixed-schema seed/bound operations can
specialize in their owning callers. Preserve the exact initial/bound enum cases,
checks, discardable bind result and one-case storage. This changes neither the
public State contract nor authored `_model` access. No unchecked initializer,
unsafe field offset, erased callback or raw mutable projection is added.

This is implementation ABI usability, not an added supported cross-module API:
`Storage`, `storage` and every newly usable member remain `internal` or retain
their existing `package` source access exactly as specified above. No storage or
unchecked constructor becomes public/package merely to make serialization work.
Check negative clients without `@testable`/SPI imports both in another module of
the same package and outside it; same-module implementation access is not a client
capability. Do not add `@frozen`, expose storage through a public signature, or
change State's representation/initialization rules as an incidental annotation fix.

## Data and Control Flow

1. Construct the existing declaration with its original inert seed. No prewarm.
2. Root discovery copies the View only at its existing transient-copy site and
   creates the original lifetime-dependent noncopyable/nonescapable binder.
3. Lexical visitation borrows that transient exclusively. The computed `_modify`
   performs `begin_apply`/yield/end of the original State field, and the existing
   visitor receives precisely that inout. No get/set writeback or `alloc_box`
   substitutes for the yield. End the yield before subsequent State discovery.
4. Existing binder failure/schema guards precede encounter. Preserve location,
   ordinal, registration generation, owner/key checks, seed handling, pin/claim
   accounting and first-failure ordering. A binding failure suppresses evaluation.
5. Evaluation obtains a key through the fixed-schema helper, then constructs the
   same checked facade with the same borrowed FrameRead and exact lifetime copy.
   End body reads before child discovery; frame ownership and mutation exclusion
   cover Layout and final Canvas use exactly as before.
6. Actions remain admitted/sealed checked mutations through the original resolver
   and dispatch path. The helper cannot write model bytes or bypass that route.

## Lifecycle and State

The new helpers own no backing and create no persistent access. The fourteen
original simultaneous typed loans, their actual parent-field borrows, private
provenance, capacity checks, Optional host destination and full lifetime union
must remain exact. A helper annotation cannot replace any one of them.

All yielding accesses end before the parent mutable borrow is used again. Retain
compiler overlap rejection or required runtime exclusivity when static proof is
unavailable; an allocating enforcement route is a strict feasibility failure,
not permission to disable it. No alias may reenter the declaration while its
wrapper is yielded. Preserve initialization's reverse successful-prefix unwind,
all session returns, quiescence, consuming retirement and physical backing-last
release. Old/new sessions cannot overlap initialized owners over the same bytes.

## Runtime Profiles and Platforms

The early feasibility target is the actual macOS Static host with approved Swift
6.4, `-Osize`, lifetime features, SDK/package policy and exact frozen workloads.
No fake domain, concrete model moved into presentation, provider/consumer merge,
manual graph, reduced host or warm process substitutes for it. Keeping a phantom
D projection opaque avoids introducing a new dependency from presentation to the
consumer's owned model/root types.

Shared emitter/State changes subsequently require matched Dynamic positive
controls, ARMv6 and Embedded compilation/lifetime controls and affected images.
An internal helper's ABI visibility grants no Swift source access across modules,
even to same-package clients. Recheck that boundary explicitly.

## Resource and Failure Behavior

No byte reduction or fit claim is made. Yield continuation/context, helper frames,
code size and seed/bound enum operations enter the physical/stack/heap ledgers.
Preserve exact payload bytes/IDs/digests, capacities, observables, failure order
and corpus counts. The original [complete pipeline design](spec-015-p08-native-cold-pipeline.md)
still governs its unfinished 42-origin corrections, including Layout visibility;
this note only supplies the new State boundary. Old object/runtime/image receipts
do not qualify changed owners or adopt the failed overlay.

## Test and Diagnostic Seams

Execution must follow the [activity's staged gates](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-checked-state-serialization-activity.md#ordered-gates).
The smallest representative first gate is the **actual freshly lowered counter
schema/presentation**, both new helpers, serialized evaluate/traverse/visitor and
an imported client using the actual binder/schema/domain. It is not the full
contract collection and not a generic toy helper.

Private `_model` access, helper access from a separate same-package module,
unchecked facade/scope construction, copying/escaping the real binder, overlapping
wrapper access and escaped yielded access need positive/negative twins. Inspect
SIL/object identity proving the original field is yielded without a temporary;
exercise new and preserved bindings, ignored seed, wrong-schema and first-failure
paths, then actual action/refusal and teardown/reconstruction. Preserve existing
runtime-exclusivity controls wherever static proof is absent. The actual fresh
host-first cold/reuse and ordinary screens retain their exact counts, windows,
baseline pairing, hooks and complete stacks.

## Candidate File and Function Allowlist

| File | Permitted operations |
| --- | --- |
| `Sources/GiftUIMacros/FiniteSourceLowering.swift` | `Lowerer.visit(StructDeclSyntax)` emits only the fixed-schema helper pair; State discovery/reserved-name validation; three existing read-root rewrites; directly referenced generated facade/Canvas initializer, getter, field and schema/seed ABI/serialization dependencies already named by corrective2. No authored source rewrite outside the finite supported inventory. |
| `Sources/GiftUIMacros/ObservableStateHostMacro.swift` | `expansion(providingMembersOf:)`, declaration inventory and shape-validation helpers select the matching generated projection in the existing lexical visitor; preserve traversal semantics, both suppressions, access and ordinary input behavior. |
| `Sources/GiftUI/ObservableState.swift` | Only State/Storage/storage, existing bound/initial value dependencies and the six existing initializer/read/bind operations listed above. Public macro/protocol signatures and declaration-name list stay exact. |
| `Sources/GiftUI/DrawingSurface.swift` | Independently reviewed corrective1 dependency: add `@inlinable` to the existing `package DrawingError.init(accessFailure:)` only. Preserve its exact five-case mapping and package access; no new mapping, enum case, constructor, drawing operation, `@frozen` or always-inline annotation. `@inlinable` supplies the required ABI usability and checked body serialization. |
| `Tests/GiftUIMacrosTests/ObservableStateHostMacroTests.swift` | Positive/negative generation checks for finite/private/multiple/nested State and deterministic ordinals; preserve existing tests. |
| `scripts/contracts/check-spec-015-counter.py` | Factor/select the bounded preparation, privacy/lifetime, actual consumer/codegen and existing cold screens with explicit stage receipts; do not alter assertions, counts, default registration or diagnostic classes. |
| `scripts/contracts/p08-checked-state-screen.py` (new, if separation is clearer) | Orchestrate those exact existing recipes and physical decoder; archive source/tool/module/callee/command hashes and stages. No alternative workload, hidden retries or generated source repair loop. |

After the early State gates pass, only the previously reviewed complete-pipeline
file/function allowlist and exact corrective2 dependency amendment may be finished.
Before the first source edit freeze their combined inventory by exact file/function,
not an open-ended annotation sweep. A new necessary file or serialization dependency
requires a documented independent design amendment within the same allowance;
file count alone does not require architecture approval. Algorithms, ownership or
cross-module/public contracts do. Keep authored `Counter.swift` and schema semantics
unchanged; never move `CounterDomain`/owned model into presentation to force a clone.

The five external modified files and `scripts/contracts/__pycache__/` are excluded.
No restoration, connected action, deployment or global toolchain change is included.

[Independent candidate1/dependency review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-checked-state-correction1-design-review.md)
confirms the first schema failure and adds only the exact mapper row above to
the frozen inventory. Its body depends solely on existing public enums/cases;
the adjacent emitted facade dependencies are already usable or named in the
existing scope. Corrective1 remains unstarted at this review, corrections0/2.
After this one grouped correction, rebuild fresh GiftUI/schema/presentation and
complete the provider/privacy gate before physical-body/consumer or cold work.

## Rejected Implementation Alternatives

- Direct private field references in serialized witnesses: the actual compiler
  already rejects them; ABI-usable enclosing nominals alone do not solve this.
- Opaque generic callback/visitor wrappers: hide the original problem behind a
  new generic metadata boundary and do not provide the selected concrete seam.
- Widening authored `_model` to package/public, duplicating State/key storage,
  copying a wrapper for inout visitation, raw pointers/offsets or getter/setter
  writeback: violate privacy, original-wrapper semantics or checked ownership.
- Serializing the private yielding body itself: recreates private-reference
  rejection; keep that field projection in its owning implementation.
- Moving consumer model/root/domain into presentation: changes dependency/ownership
  boundaries and is not selected. If the opaque fixed-schema seam fails, report
  its exact residual before proposing such a change through the proper gate.

## Open Implementation Questions

Does the pinned compiler lower this fixed-schema yielding projection and key helper
without rooted allocation/TLS, while specializing the actual binder and complete
host pipeline? This is required current evidence, not deferrable Future Work.
The early gate answers it or stops. No general impossibility or need for a heap
exception has been established. An actual need to change privacy, ownership,
public/cross-module semantics, required lifetime enforcement, zero heap or compiler
policy must stop for the applicable ADR/Specification review.

## Code and Evidence Links

Initial unaccepted realization is frozen in the linked receipt. Inputs: final failure `3ae67711`, final independent review
`9a544f7e`, corrective2 design `e4191d09`, physical serialization `24590caf`.
The activity record will link each source freeze, physical-body/callee receipt,
safety/cold result and independent disposition. Existing frozen evidence remains
immutable. No new deferred item: all uncertainty above blocks current correctness.
