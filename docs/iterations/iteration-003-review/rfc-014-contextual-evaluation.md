# RFC-014: contextual View evaluation and frame access

> **Revised working direction, 2026-10-10:**
> [Stable reads without a mandatory snapshot copy](rfc-014-stable-read-revision.md)
> supersedes this document's separate frozen-bank baseline and its assumption
> that the frontend must derive concrete Body aliases. The remaining text
> preserves the previous candidate and its evidence; it is not the current
> implementation direction. Lifetime, ownership and source-coverage questions
> remain open. No accepted contract changed.


Current evidence: [SPIKE-073](../../spikes/spike-073-fixed-context-body-inference.md)
compiles a fixed-context evaluation requirement with compiler-derived custom Body
on all four configurations. Its miniature protocol is not the module integration
fixture below. The remaining question is the real context/schema/access contract;
manual Body aliases are no longer the preferred baseline.

**2026-10-10 — proposed design, not an approved contract.** Parent:
[RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md).
This delivers Eugene's next-design-step instruction after
[SPIKE-071](../../spikes/spike-071-canvas-embedded-escape-continuation.md).
Baseline `badbfc80`. No experiment, production change or lifecycle approval is
part of this step. The feature remains at RFC under accepted PROPOSAL-007;
post-MVP iteration 3 requires real analyzer/counter derivation on four profiles.

The recommendation is to make **contextual evaluation the runtime View
contract**, while retaining `body` as supported authoring syntax through finite
source lowering. The runtime must bind State, evaluate with a short frozen read
borrow, release that borrow, and only then traverse the returned owned children.
The frame continues to own frozen storage through drawing. This separates
storage lifetime from an individual Swift borrow.

## 1. The actual integration gap

### Subsequent bounded evidence — SPIKE-072

Eugene's “Let's do it” provisionally selected mandatory finite transformation
for the integration experiment, not production adoption.
[SPIKE-072](../../spikes/spike-072-contextual-traversal-integration.md) now compiles
seven adapted modules plus a generated application across four configurations;
both native profiles pass 111 checks. It exercises actual SemanticCore and
CanvasPlanProducer orchestration with fixture binding, storage and resolved layout.
The parent-read/child-discovery conflict rejects on all four configurations.

The concrete Swift realization needs **explicit generated associated Body
types** for this corpus. A universal `View where Body == Never` default caused
Swift to select Never for the custom root and nested view despite their generic
opaque-return methods. Native checks failed; SIL confirmed the wrong witnesses.
The corrected candidate limits default evaluation to an explicit leaf marker and
derives `ConditionalContent<Nested, Nested>` / `HStack<TupleView3<...>>` aliases
from the source AST. No custom view is assigned Never or routed around traversal.
Authored `some View` remains a supported source form; automatic generic opaque
witness inference is not established. Supported body shapes must be derived and
checked by the frontend, which adds to its completeness obligation.

This narrows the integration uncertainty; it does not prove the full source
language, production State wrapper/reconciler, owner tickets, immutable geometry
plan, nominal identity codec, Dynamic ownership or resources. The
[application inventory](../../../experiments/spike-072-contextual-traversal-integration/application-coverage.md)
shows that the tested grammar does not cover either complete application.
The original analysis below describes the pre-experiment gap; its remaining
full-integration obligations still apply.

The current [View/visitor declarations](../../../Sources/GiftUI/DeclarativeView.swift)
require a nonthrowing `body` getter and context-free `_giftUITraverse`.
[ObservableStateHostMacro](../../../Sources/GiftUIMacros/ObservableStateHostMacro.swift)
generates a callback that simply reads `declaration.body`.
[SemanticExpansionTraversal](../../../Sources/GiftUISemanticCore/GiftUISemanticCore.swift)
binds State before that callback, stores an owned evaluated body, and recursively
expands it after binding returns. Its stored visitor is an ordinary value; adding
a nonescapable FrameRead field to it is not established by the Spike.

SPIKE-070/071 instead used a root descriptor without View conformance, a throwing
`evaluate(read:)`, and a disposable visitor. They prove neither an unchanged View
witness nor the real stateful-binding path. The existing body getter cannot
receive the proposed context or return the proposed access failure. A new
property wrapper alone does not fill that contract gap.

## 2. Proposed source and runtime contracts

Keep the C author's familiar declaration forms: `struct Screen: View`,
`var body: some View`, `@State`, schema property reads and Canvas's
`draw(in:context:)`. The supported build transforms contextual bodies/helpers
into explicit entrypoints. This is **source-form preservation through a required
build step**, not a claim that the same untransformed declaration conforms to
today's Swift View protocol. It is not just adding a macro to the current binary
interface, and no existing macro is assumed to rewrite arbitrary body code.

The proposed compiled View SPI replaces the mandatory context-free body getter
with category/traversal and contextual body-evaluation witnesses. Keep a concrete
associated Body shape for custom views; Canvas/primitive categories are leaves.
A generated custom type must itself conform to that compiled contract, including
when it is the root or nested in an ordinary container. No detached root-only
adapter, fake primitive classification, `Body = Never` substitution for a custom
view, default-valued body, or trapping compatibility getter satisfies this design.

The following is **contract notation, not tested Swift generic syntax**:

```text
expand(declaration, inout semanticTraversal, inout evaluationSession)
    -> success | semanticFailure | bindingFailure | accessFailure

bindState(declaration, structuralIdentity, inout evaluationSession)
    -> owned BoundDeclaration | BindingFailure

evaluateBody(boundDeclaration, borrowing FrozenReads)
    -> owned Declaration.Body | AccessFailure

invokeDraw(owned CanvasValue, borrowing FrozenReads,
           inout GraphicsContext, checkedLocalBounds)
    -> success | DrawingError
```

`EvaluationSession` is a synchronous, exclusive borrow of the target's concrete
binding/owner regions, not a heap session or an ID-to-pointer registry.
`FrozenReads` is a shorter nonescapable read facade. Access descriptors and
protocol shapes belong at the GiftUI/application-schema boundary; target
composition implements them using its concrete owner. Presentation and
SemanticCore must not import a runtime, physical bank layout or application host.

The declaration's Body type/category cannot depend on the runtime context's
value or the selected physical storage backend. Finite generated witnesses may
specialize a concrete typed access adapter; no existential model registry,
reflection or runtime compiler is introduced. The exact Swift constraints for
context lifetime, opaque Body inference and nested generic containers are a
named remaining compiler-realization obligation, not supplied by the notation.

All participating portable declarations use the same contextual contract on
Dynamic and Static. Pure bodies can ignore the read facade but still use the
same entrypoint and traversal. A raw Dynamic `body` path is not a parity oracle.
Direct authored `.body` evaluation or model-reading `.draw` calls outside the
supported evaluation/invocation entrypoints are build diagnostics, not a way to
obtain an implicit frame. Construction of owned declaration values remains
separate from their evaluation. An external precompiled view with only the old
body witness is incompatible with
this candidate unless separately given a reviewed adapter; automatic mixed-mode
compatibility is not included. RFC-013 owns later package/product delivery.

The module placement is part of this proposal, independent of physical layout:

| Owner | Declarations / responsibility |
| --- | --- |
| GiftUI | Compiled View/category/evaluation SPI, portable read-access interface and local typed access failures; no SemanticCore or Runtime import |
| Application schema/Presentation output | Finite model/property descriptors and body/draw/helper witnesses; depends on the GiftUI surface, not target storage |
| SemanticCore | Structural traversal and finite expansion-outcome union, generic over binding/access adapters; no concrete application model |
| Observable State | Association/registration rules, model-value revisions and binding outcomes |
| Runtime and target composition | Concrete model banks, frame lease and session, factories for short read facades, mutation/reporting adapters |
| Drawing | Pass the separate typed access argument through invocation; retain geometry/ordering/error ownership without resolving model IDs itself |

## 3. Thread the session; do not retain it in a visitor

Change the traversal SPI to pass the evaluation session explicitly along each
recursive visit. The semantic traversal value retains only graph workspace,
sink, path bookkeeping and owned failure/identity values. Its methods receive
the separate session by scoped argument; they do not store it, a read facade,
an escaping resolver closure or a raw owner pointer for later evaluation.

At each custom-view occurrence:

1. Enter the existing custom-body structural path. Preserve existing work/count
   checks and category validation; a generated adapter adds no path component.
2. For a state host, encounter all State declarations in lexical ordinal order.
   Resolve the existing association or materialize an admitted seed, reserve its
   frozen entry and finish binding before application body evaluation. Plain
   custom views still validate any inherited model keys against this frame.
3. Record the bounded body-evaluation event after binding succeeds. Construct
   one short `FrozenReads` borrow from the session's owner and call the generated
   body entrypoint exactly once. Neither session mutation nor recursive child
   traversal occurs inside this read scope.
4. Return an owned Body value containing only owned scalars/ordinary declaration
   values and validated model keys. No borrowed view, span, raw model pointer or
   resolver closure may be stored in that value. Large capture projection values
   remain identity-bearing selections with indexed owned reads.
5. End the read borrow before expanding any returned child. Recursively pass the
   session to child visits, then leave the custom-body path. Release temporary
   Body/declaration values on every success/failure edge.

This preserves the current useful ordering—bind, evaluate, then recurse—while
replacing the context-free callback. Semantic expansion still interprets actual
runtime branch/optional/tuple/container declarations. Generated finite type,
field and callable IDs are permitted; generated occurrence paths, expanded graph
records or expected branch topology are not.

Source-to-generated declaration mapping preserves one nominal category and the
same source structural transitions. It must not make generated adapter wrappers
observable in identity, work counts or Button/model targeting. The corresponding
semantic oracle must be independent of those generated IDs and graph records.
No application model lookup may be based on the host's latest root route.

## 4. Frozen lifetime and newly materialized State

| Interval | What stays live | What can change |
| --- | --- | --- |
| Before initial freeze | Current models and structural associations | Serialized admitted mutations and replacement |
| Entire derivation frame | Frame lease, epoch, existing frozen model entries and any staged Canvas keys | No mutation of existing current/frozen values; bounded discovery of previously unmaterialized State only |
| One body/helper call | Short FrozenReads borrow plus owned declaration input | Read-only; no binding or child traversal |
| Between body calls | Frame lease, owned children, no active read facade | Reserve/bind a new State entry; seed its current and frozen values before its body |
| Layout | Frame lease and graph-owned scalar/geometry facts | Layout workspace only; no application body/draw calls or new State discovery |
| One Canvas invocation | Frame lease, occurrence value, short FrozenReads and GraphicsContext borrows | Drawing workspace only |
| Finalization | Pending occurrence cleanup, then frame lease release | Frozen storage reusable only after all readers and staged occurrences end |

A frame lease pins lifetime; it is not one immutable Swift borrow held over the
whole recursive traversal. With no active facade, the coordinator may add a
newly materialized model's complete frozen entry to the bounded same-epoch map.
It cannot rewrite an already frozen value, move backing invalidly, lazily copy an
existing model on first read, or reopen application mutation. The parent's owned
keys remain valid because earlier entries and generations are stable.

Known State locations ignore fresh seeds without constructing another live
owner. A new location reserves current/model/registration/frozen capacity before
exposing its body. It initializes both versions from the one inert seed and
publishes no partially copied entry. Failure discards the candidate's newly
created associations while preserving independently owned models and the prior
published live set. No external observation startup or action dispatch occurs.

New child State can exceed K=2/F=1 even when the application normally has one
root model. Report bounded refusal at that child before evaluating its body;
do not borrow the old frozen slot or assume the parent's read borrow ending
also frees its frame storage. The [C storage ledger](rfc-014-c-storage-ledger.md)
is unchanged. This design solves the proposed sequencing, not the five-bank
physical approval or C-P3 ownership proof.

## 5. Typed errors and expression lowering

A generated body returns one typed access failure immediately. The semantic
attempt carries a finite tagged outcome preserving semantic, binding and access
origins; no `any Error` box, swallowed getter failure or zero/default value is
needed. The failed candidate stops before later children, Layout, Canvas or
frame offer. Existing published semantic state remains intact; mutations already
applied before freeze remain applied and dirty. Cleanup cannot overwrite the
first causal failure.

The current semantic outcome already distinguishes binding and semantic errors.
The proposed access arm and its local code/origin mapping require SPEC-006/010
and SPEC-003/009/013 amendments. They are not existing enum cases. A body read
failure must not be misreported as a successful empty view, drawing failure or
capacity exhaustion merely because an adapter lacks the correct case.

Inside draw, contextual access failures map to `DrawingError.invalidScope` as
in the C contract; application drawing failures keep their DrawingError. A bad
index in an optional indexed-read operation preserves its documented absent
result; an invalid model/frame is an error, not an absent element. Mapping is
performed before crossing an existing typed GraphicsContext/Path callback.
No side-channel getter latch supplies a fabricated success value.

SPIKE-071 demonstrates why source lowering must preserve typed effects through
expressions. For an authored short-circuit expression:

```text
model.enabled && check(model.value)
```

read `enabled` first; if false, do not read `value` or call `check`. If true,
read `value`, then call `check` and propagate its declared typed outcome.
Do not hoist all reads unconditionally ahead of the branch. The same rule applies
to `||`, conditional expressions, optional/default expressions and builder
branches: preserve evaluation count, source order and conditional effects.
A typed temporary avoids an untyped throwing autoclosure only when introduced
at the original execution point. SPIKE-071's two unconditional test assertions
are not proof that arbitrary expression hoisting is valid.

A finite effect inventory classifies each reachable helper as pure/owned,
frozen-read, current-mutation or drawing. Generate contextual variants only for
known frozen-read/current-mutation/drawing routes. Reject recursion, unknown
existential dispatch, unreviewed generic getter routes, stored read contexts and
unsupported escaping closures before building a supported image. Keep existing
synchronous `withPath` closures under their typed drawing contract. Preserve
branch/runtime traversal; do not expand the accepted grammar silently.

## 6. Mutation and post-layout invocation

Mutation uses a separate exclusive capability. State assignment requests the
existing atomic association replacement operation; published-property assignment
requests a checked current-bank write. Preflight phase, identity, capacity and
revision availability before altering a property. A changed write synchronously
reports coarse model dirtiness before returning. Repeated/no-op writes follow
the established equality rule; no property-read dependency graph is added.

For compound updates, read the needed current values into owned temporaries,
end their read borrows, then perform a bounded write. No unconstrained `_modify`
yield or raw mutable projection crosses a helper boundary. Generated setters
must propagate typed refusal rather than permit a host callback to ignore it.
Earlier successful writes are not rolled back/replayed if a later operation
fails. Only an explicitly contracted batch can promise all-or-nothing behavior.

Body/draw entrypoints have no mutation capability. Frame-phase guards remain a
runtime backstop, not permission to use a mutable owner alias while FrozenReads
is live. Reports, model storage and coordinator outcome regions need disjoint
borrows so reporting does not reborrow an already exclusively borrowed aggregate.
Actual field/helper/action coverage in both applications remains B4/C-P3.

The current [CanvasInvocationSource](../../../Sources/GiftUIDrawing/CanvasInvocationSource.swift)
receives GraphicsContext and Size through
[CanvasPlanProducer](../../../Sources/GiftUIDrawing/CanvasPlanProducer.swift).
Extend that source/producer seam with a separately passed scoped typed access
adapter; do not solve it by storing FrozenReads inside today's escapable source.
Drawing stays generic over the access interface and knows no model schema or
runtime bank. The target resolves its concrete finite Canvas value, borrows the
same frame's reads and invokes the generated draw witness with checked local
bounds. GraphicsContext remains solely a drawing capability.

The occurrence source retains owned keys/scalars only, with one value per
occurrence. Invocation follows resolved painter order and occurs at most once
per attempt. On success release the invoked value; on failure release the failing
and all pending values without reinvocation. End read/graphics borrows before
releasing the frame lease. A complete immutable plan owns copied geometry and
never keeps the access adapter, model selection or application callable.

## 7. Alternatives, compiler policy and costs

| Choice | Assessment |
| --- | --- |
| Contextual compiled View witnesses with finite authoring lowering | Recommended draft: explicit ownership/error path, keeps familiar authoring forms, but requires a mandatory transformer and a breaking runtime SPI change. Exact Swift integration remains to be demonstrated. |
| Keep the old getter and store a resolver/FrameRead in every bound declaration or visitor | Not supported by the evidence; ordinary View/visitor storage cannot simply retain a nonescapable borrow. Unsafe pointer erasure repeats SPIKE-069's gap. |
| Global/task-local or phase-sensitive getter selection | Conflicts with C's explicit owner/frame binding and the Static contract. It can silently read the wrong owner or revision. |
| Default/trap body witness plus a special root evaluator | Reject as the production contract: nested generic dispatch could reach the wrong witness, ordinary failures are not represented, and the Spike root exception remains. |
| Public explicit `body(in:)` and explicit read operations | Viable alternative with visible source migration and potentially less transformation; it revises the chosen authoring direction and must be reviewed explicitly, not introduced as a hidden fallback. |

Recommend reviewing adoption of the **pinned Swift 6.3.2 configuration tested
with LifetimeDependence and Lifetimes** for this candidate on all four profiles.
The experiments do not show that each flag is independently necessary or that
future Swift releases preserve the same rules. No production compiler flags
change here. Supported-build metadata must identify compiler hash/version,
feature flags, transformer/schema version and generated-source hashes. Reject a
missing capability, stale generated route or incompatible module before linking;
never substitute unchecked pointer-based access on one profile. Compiler upgrades
must revalidate the affected contract matrix before changing supported policy.

Costs remain explicit: an owned returned body during recursive traversal,
short access facade/session values, typed outcome storage, generated helper and
witness specialization, validation at entrypoints and copy-freeze work. Releasing
a borrow does not reduce reserved capture bytes. No text/RAM/stack or speed
improvement is inferred from source design. Recursion still needs an integrated
maximum-depth/feasible-path stack bound; indirect drawing calls are not zero cost.

## 8. Authority and completion boundary

| Authority | Proposed amendment or preserved obligation |
| --- | --- |
| ADR-006 / SPEC-006 | Preserve equivalent structural semantics, runtime branches and bounded work; explicitly revise View/traversal/evaluation SPI and access-error transport. |
| ADR-024 / SPEC-010 | Preserve pre-body binding, identity, initializer/removal/replacement semantics; specify separate frame lease, short read facade and new-entry initialization. |
| ADR-025 / ADR-011 | Preserve serialized mutation, coarse synchronous invalidation, no rollback/replay and complete publication. |
| ADR-026 | Preserve portable import direction, profile semantics and bounded zero-heap Static realization; review required frontend/compiler policy. |
| ADR-028 / SPEC-012 | Amend stored-closure representation to protocol values and scoped access delivery; preserve post-layout order, invocation lifetime and cycle-local plan. |
| ADR-034 / SPEC-001/013/015 | Three-bank authority remains binding; the proposed five-bank ledger still requires its separate architectural decision and complete accounting. |

This step makes the proposed runtime contract, sequencing and compatibility
cost reviewable. It does not claim those amendments are approved or implemented.
Current blockers remain in RFC-014, not Future Work. No new non-blocking idea
requires a deferred artifact; interchangeable frontends and generated graph representations remain outside this design under existing
[FW-035](../../future-work/fw-035-generated-view-graph-for-interchangeable-frontends.md).
That item does not own or excuse any missing required Swift source lowering;
those gaps stay B1/B4 in this RFC.

Before B1/B4 can close, demonstrate a root **and nested custom State host**
conforming to the proposed compiled View contract through actual SemanticCore,
without a root-only adapter; typed failure through branch/short-circuit/helper
paths; no long read borrow across new-State binding; contextual invocation through
actual Drawing; and equivalent source coverage on all four profiles. The paired
identity/work/publication oracle must remain independent. Full C-P3 owner/storage
and B2/B3 image evidence are separate. These are named integration obligations,
not a newly launched Spike or a renewed generic escape-test budget.
