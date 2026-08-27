---
id: SPEC-006
feature: giftui-mvp-architecture
title: Declarative View Semantics Specification
status: approved
authors:
  - codex
created: 2026-08-25
updated: 2026-08-27
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-004
  - RFC-010
  - RFC-011
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-008
  - ADR-033
  - ADR-032
related_specs:
  - SPEC-002
  - SPEC-003
  - SPEC-007
  - SPEC-008
  - SPEC-009
  - SPEC-010
  - SPEC-011
  - SPEC-012
related_future_work:
  - FW-017
  - FW-020
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-006: Declarative View Semantics Specification

> **Approval status:** Explicitly reapproved by the maintainer after ADR-033
> superseded ADR-013. This revised action-payload and state-host traversal
> contract is authoritative for implementation.

## Summary

This Specification defines the Rank 0 GiftUI client model and its profile-
neutral structural expansion contract. Portable clients declare transient
`View` values, compose zero through five fixed children with `ViewBuilder`,
factor declarations into custom views, and apply modifier declarations in
source order. A SPEC-010-generated state-host witness may bind direct
observable-state declarations before a custom body runs. The semantic runtime
expands the resulting declarations synchronously into runtime-owned semantic
structure with deterministic structural and action identity.

This contract is deliberately complete before layout: its canonical expansion
transcript observes declaration order, structural paths, branch selection,
custom-body boundaries, modifier order, action identity, exact counts, and
bounded refusal, but no size, placement, hit region, render operation, state
slot, or backend output.

## Scope

This Specification owns:

- the public `View` and `ViewBuilder` declaration model;
- fixed zero-through-five sibling composition, empty, conditional, and
  optional composition;
- custom views and view-returning properties or functions without mandatory
  type erasure;
- the semantic meaning and ordering of modifier chains, while later
  Specifications own concrete modifier vocabularies and payloads;
- the public bounded action-value protocol used by action-bearing declarations;
- runtime-owned structural identity and semantic action-occurrence identity;
- deterministic synchronous expansion of transient declarations;
- one stateful-custom-view traversal operation that permits SPEC-010 to bind a
  mutable transient copy before body evaluation without moving state ownership
  into Semantic Core;
- caller-supplied expansion limits and all-or-nothing failure behavior; and
- a backend-free recording seam and shared dynamic/static conformance corpus.

The contract applies to macOS dynamic, macOS static, Raspberry Pi 1/Linux
dynamic, and nRF52840/Zephyr static configurations.

## Goals

- Provide the Signal Analyzer with one familiar Rank 0 declaration surface in
  every MVP configuration.
- Preserve custom-view boundaries, fixed child order, branch selection,
  modifier order, structural identity, and action identity across profiles.
- Keep declaration values transient and runtime storage profile-specific.
- Make every expansion bound and failure deterministic and independently
  testable without layout or rendering.
- Preserve the `GiftUI` module as the sole portable Presentation import.

## Non-goals

- Define stacks, overlays, spacers, measurement, placement, alignment,
  spacing, padding, frames, or any other layout behavior.
- Define `Text`, `Color`, foreground/background painting, `Button`,
  `disabled`, hit testing, pointer sequencing, or action activation behavior.
- Define state storage, observable-state registration, invalidation,
  reconciliation, or run-cycle publication; SPEC-010 owns all such behavior
  while this contract owns only the pre-body traversal position.
- Define concrete layout, rendering, interaction, state, or drawing modifier
  payloads.
- Support unrestricted dynamic child collections, `ForEach`, `buildArray`,
  runtime plug-in declarations, public type erasure, reflection-based
  traversal, or a public `Binding` abstraction.
- Require a retained semantic graph. Direct bounded traversal and retained
  profile-specific graphs are both conforming.
- Define client-visible identity inspection, explicit view identity, keyed
  collection identity, layout caches, or persistent serialized identities.

## Dependencies

### Lifecycle prerequisites

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
  is accepted.
- [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md) is approved.
- [RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md) is approved.
- [ADR-005](../adrs/adr-005-semantic-layout-render-boundary.md),
  [ADR-006](../adrs/adr-006-shared-semantics-runtime-profiles.md),
  [ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md),
  [ADR-033](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md), and
  [ADR-032](../adrs/adr-032-semantic-core-owned-layout-input.md) are accepted.
- [SPEC-002](spec-002-portable-foundation.md) and
  [SPEC-003](spec-003-failure-outcomes-and-containment.md) are approved.

The MVP Scope requires non-trivial portable Signal Analyzer hierarchies and
reusable custom views in all four configurations. That Rank 0 requirement is
the reason this contract is required now.

### Contract dependencies

- SPEC-002 owns portable values and the package/import partial order. This
  Specification neither redefines geometry nor changes that graph.
- SPEC-003 owns `GiftUIOutcome`, failure facts, containment, disposition,
  health, and diagnostics. This Specification fixes only the semantic-owner
  mappings for its own failures.
- Later LAYOUT, RENDERING, EXECUTION, OBSERVABLE, INTERACTION, and
  RUNTIME-PROFILES Specifications consume this contract and MUST NOT redefine
  its expansion, identity, ordering, or failure semantics.
- EXECUTION and INTERACTION own committed bound action records and generations
  under ADR-033. They consume the stable semantic action identity and borrowed
  typed action value defined here; this Specification does not bind a model
  target, allocate a committed generation, retain a callable or model, or
  dispatch an action.
- The approved SPEC-010 contract owns `_GiftUIObservableStateHost`, its
  declaration visitor, macro-generated witness, binding results, and all state
  failure behavior. This Specification owns the single traversal operation
  that calls that witness before `body`; the coordinated approval of both
  contracts establishes this seam.

## Related ADRs

- **ADR-005 — Semantic, Layout, and Render Boundary:** requires GiftUI, rather
  than a backend, to own declaration expansion and identity. This contract
  ends at semantic structure and exports no layout or render result.
- **ADR-006 — Shared Semantics Across Runtime Profiles:** requires static and
  dynamic implementations to preserve the same observable declaration,
  identity, action, ordering, and failure behavior despite different storage.
- **ADR-008 — Module Dependency Graph and MVP Package Topology:** places the
  public declarations in `GiftUI`, runtime-owned expansion in
  `GiftUISemanticCore`, and prohibits upward or concrete integration imports.
- **ADR-033 — Bounded Application Actions and Model-Target Dispatch:** requires
  pointer capture to pair this Specification's stable semantic action identity
  with a downstream committed action generation, without retaining an action
  value, callable, handler, or model, and requires exact pair revalidation
  before activation.
- **ADR-032 — Semantic-Core-Owned Borrowed Layout Input:** permits
  `GiftUILayout` to import Semantic Core's narrow read-only layout-facing view
  while leaving expansion, identity, ordering, and semantic-result ownership
  in `GiftUISemanticCore`. SPEC-007 owns the exact view declarations.

## Terminology

**Declaration value**
: A transient value conforming to `View`. It describes intent and is not a
  runtime node, persistent identity, state owner, or backend object.

**Custom view**
: A client-defined `View` whose `Body` describes its content. A custom view is
  expanded through its `body`; clients do not implement framework traversal.

**Fixed group**
: A compile-time generic composition of zero through five ordered children.
  It is structural syntax and does not itself become a semantic node.

**Framework primitive**
: A GiftUI-owned declaration whose semantic meaning is supplied through the
  underscored framework traversal surface instead of by evaluating `body`.
  Its `Body` is `Never`.

**Structural occurrence**
: A custom or framework declaration reached at one structural path. A custom
  occurrence can own identity and modifiers without itself adding a semantic
  node; a framework occurrence adds one semantic node unless its wrapper rule
  explicitly says otherwise.

**Semantic occurrence**
: A framework declaration occurrence that stages one semantic node. Empty,
  fixed-group, conditional, optional, and modifier wrappers are structural
  syntax and are not semantic occurrences.

**Structural path**
: The exact ordered sequence of root, custom-body, fixed-child, conditional-
  branch, optional-presence, and declaration-role components by which an
  expanded semantic occurrence is reached.

**Structural identity**
: Runtime-owned identity determined by structural path and declaration role.
  Its equality is normative; its stored representation is profile-specific.

**Modifier scope**
: The exact structural occurrence or structural wrapper path to which one
  modifier application is attached. A modifier scope may describe a custom
  view or group and therefore need not itself be a semantic node.

**Semantic action identity**
: The package-SPI runtime identity of one action-bearing occurrence, derived
  from that occurrence's structural identity and action-bearing role. It does
  not contain the downstream committed action generation or the bounded
  application-action value carried by the occurrence.

**Modifier order**
: The source-call order of a modifier chain. In `base.a().b()`, `a` precedes
  `b`. Lowering may not reorder, merge, or discard modifiers unless the
  concrete modifier's approved contract explicitly proves equivalence.

**Expansion attempt**
: One synchronous, bounded evaluation of a root declaration into staged
  semantic structure or a recording sink.

**Canonical expansion transcript**
: The profile-independent ordered fixture record of structural-path entry,
  body evaluation, semantic occurrence, modifier application, and action
  occurrence events. It compares role and path equality, not profile-private
  identity bytes.

## Public Contract

Portable Presentation MUST need only `import GiftUI`. A custom declaration
MUST be expressible as a value conforming to `View` with an opaque
`body: some View`. The declaration surface MUST be identical in static and
dynamic configurations.

Clients MUST NOT be required to implement or call a traversal method,
manufacture structural identity, name a runtime profile, retain a semantic
node, or import layout, render, runtime, backend, platform, driver, OS/RTOS,
HAL, or hardware modules. The underscored traversal surface is public only so
external `View` conformances can receive its default witness; direct use or
override by application code is unsupported and non-conforming.

View-returning properties and functions MAY return `some View` and MAY use
`@ViewBuilder`. They MUST expand with the same rules as an equivalent inline
declaration. Custom views, builder groups, conditional wrappers, optional
wrappers, and modifier wrappers MUST require no client-visible type erasure.

The maintained Rank 0 surface supports at most five direct expressions in one
builder block. A client MAY compose more content by nesting fixed groups or
custom views. `buildArray` and unrestricted runtime child iteration MUST be
absent from the portable API.

`GiftUIAction` is the portable, finite action-value boundary needed by semantic
payload traversal. Conforming cases MUST have no associated value, and every
valid action code is its `UInt16` raw value. The concrete conforming type is the
action domain; GiftUI exposes no public numeric domain identifier. Raw values
are not public ABI, persistence, or a wire format. Later control and
Interaction contracts own action-bearing syntax, target binding, and dispatch.

## Module Contract

`GiftUI` MUST own the public declarations and the underscored framework
traversal surface. Swift protocol requirements cannot have `package` access,
and an SPI-hidden default witness is unavailable to an ordinary external
conformance. The traversal requirement, its visitor/payload types, and its
default witness therefore MUST be public underscored declarations. They are
not supported client API and carry no source-compatibility promise. `GiftUI`
MUST import no semantic-runtime implementation and MUST expose no runtime,
layout, render, backend, platform, or hardware type through this surface.

`GiftUISemanticCore` MUST own expansion, structural paths, structural/action-
occurrence identity, staged semantic structure, and the recording conformance
seam. It MAY depend on `GiftUI`. It MUST NOT import `GiftUIFailureCore`,
`GiftUIFailureExecution`, a layout, render, runtime-profile implementation,
backend, platform, driver, OS/RTOS, HAL, hardware, or optional diagnostic
implementation.

`GiftUISemanticCore` MUST expose only the closed local expansion result, the
error vocabulary below, and ADR-032's package-scoped read-only layout-facing
view over a complete successful result. That view MUST NOT add another
expansion result, identity relation, ordering rule, mutable semantic operation,
or retained layout-owned representation; SPEC-007 defines its exact borrowed
surface. The first runtime/owner adapter that imports both
`GiftUISemanticCore` and `GiftUIFailureCore` MUST map a local error to the
normative SPEC-003 fact in `Error Handling`. Neither failure module may import
`GiftUI` or `GiftUISemanticCore` to perform that mapping.

Dynamic and static runtime implementations MAY depend on
`GiftUISemanticCore`; it MUST NOT depend on either implementation. Within the
package, only `GiftUISemanticCore`, `GiftUI` declaration implementations, and
checked-in conformance fixtures MAY reference the underscored traversal names.
Concrete declarations introduced by later Specifications MUST enter expansion
through that one surface; they MUST NOT add another `View` requirement or
create a second expansion engine.

A dynamic convenience MAY adapt callback-backed or erased syntax in a
separately imported module, but it MUST lower to the same fixed declaration
and expansion semantics. The underscored traversal surface is a framework
dispatch mechanism, not a compatibility promise or a plug-in interface.

## Types / APIs

### Rank 0 declarations

The following public source contract is normative:

```swift
public protocol GiftUIAction: RawRepresentable, Equatable, Sendable
where RawValue == UInt16 {}

public protocol View {
    associatedtype Body: View

    @ViewBuilder
    var body: Body { get }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    )
}

extension Never: View {
    public typealias Body = Never
    public var body: Never { get }
}

@resultBuilder
public enum ViewBuilder {
    public static func buildBlock() -> EmptyView
    public static func buildBlock<Content: View>(_ content: Content) -> Content
    public static func buildBlock<A: View, B: View>(_ a: A, _ b: B) -> TupleView<A, B>
    public static func buildBlock<A: View, B: View, C: View>(
        _ a: A, _ b: B, _ c: C
    ) -> TupleView3<A, B, C>
    public static func buildBlock<A: View, B: View, C: View, D: View>(
        _ a: A, _ b: B, _ c: C, _ d: D
    ) -> TupleView4<A, B, C, D>
    public static func buildBlock<
        A: View, B: View, C: View, D: View, E: View
    >(
        _ a: A, _ b: B, _ c: C, _ d: D, _ e: E
    ) -> TupleView5<A, B, C, D, E>
    public static func buildEither<A: View, B: View>(
        first: A
    ) -> ConditionalContent<A, B>
    public static func buildEither<A: View, B: View>(
        second: B
    ) -> ConditionalContent<A, B>
    public static func buildOptional<Content: View>(
        _ content: Content?
    ) -> OptionalContent<Content>
}
```

The traversal requirement is part of the protocol witness table only because
Swift requires a public protocol requirement to share the protocol's access.
Its name, visitor/payload types, and every visitor operation MUST remain
underscored. The public default implementation MUST call `visitCustomView`
with the declaration and one nonescaping body accessor; therefore an ordinary
external conformance supplies only `Body` and `body`. A declaration annotated
with SPEC-010's `@ObservableStateHost` receives a generated witness that calls
`visitStatefulCustomView`; the client still does not hand-author or call the
traversal method.

The builder wrapper source shape is also normative:

```swift
public struct EmptyView: View {
    public typealias Body = Never
    package init()
    public var body: Never { get }
}

public struct TupleView<A: View, B: View>: View {
    public typealias Body = Never
    package init(_ a: A, _ b: B)
    public var body: Never { get }
}

public struct TupleView3<A: View, B: View, C: View>: View {
    public typealias Body = Never
    package init(_ a: A, _ b: B, _ c: C)
    public var body: Never { get }
}

public struct TupleView4<A: View, B: View, C: View, D: View>: View {
    public typealias Body = Never
    package init(_ a: A, _ b: B, _ c: C, _ d: D)
    public var body: Never { get }
}

public struct TupleView5<
    A: View, B: View, C: View, D: View, E: View
>: View {
    public typealias Body = Never
    package init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E)
    public var body: Never { get }
}

public struct ConditionalContent<First: View, Second: View>: View {
    public typealias Body = Never
    package init(first: First)
    package init(second: Second)
    public var body: Never { get }
}

public struct OptionalContent<Content: View>: View {
    public typealias Body = Never
    package init(_ content: Content?)
    public var body: Never { get }
}
```

Stored children and branch storage MUST be package implementation detail.
`EmptyView` and the wrapper construction initializers are intentionally not
ordinary client API; clients obtain wrappers through `ViewBuilder`. No wrapper
may publish a child tuple, branch-storage enum, or optional payload. Every
wrapper MUST be usable without allocation, reflection, an existential, or
runtime discovery.

`Never` conformance exists only to satisfy `Body: View`. Reading any
framework primitive or wrapper `body`, or attempting to traverse `Never`, is
an invariant violation. Normal expansion MUST dispatch the underscored
framework override and MUST NOT evaluate `Never`. Client custom views inherit
the custom-body default and MUST NOT substitute a primitive override.

### Underscored declaration traversal

The underscored traversal source shape is normative. Method bodies and payload
fields are owned by the declaration contracts that use it.

```swift
public protocol _GiftUISemanticPrimitivePayload {}

public protocol _GiftUISemanticActionPayload {
    associatedtype Action: GiftUIAction
    var _giftUIAction: Action { get }
}

public protocol _GiftUISemanticModifierPayload {}

public protocol _GiftUISemanticTraversalVisitor {
    mutating func visitCustomView<Declaration: View>(
        _ declaration: borrowing Declaration,
        body: () -> Declaration.Body
    )
    mutating func visitStatefulCustomView<
        Declaration: View & _GiftUIObservableStateHost
    >(
        _ declaration: borrowing Declaration,
        body: (borrowing Declaration) -> Declaration.Body
    )
    mutating func visitEmpty()
    mutating func visitFixed<A: View, B: View>(
        _ a: borrowing A, _ b: borrowing B
    )
    mutating func visitFixed<A: View, B: View, C: View>(
        _ a: borrowing A, _ b: borrowing B, _ c: borrowing C
    )
    mutating func visitFixed<A: View, B: View, C: View, D: View>(
        _ a: borrowing A, _ b: borrowing B, _ c: borrowing C,
        _ d: borrowing D
    )
    mutating func visitFixed<
        A: View, B: View, C: View, D: View, E: View
    >(
        _ a: borrowing A, _ b: borrowing B, _ c: borrowing C,
        _ d: borrowing D, _ e: borrowing E
    )
    mutating func visitConditionalFirst<First: View, Second: View>(
        _ content: borrowing First, second: Second.Type
    )
    mutating func visitConditionalSecond<First: View, Second: View>(
        first: First.Type, _ content: borrowing Second
    )
    mutating func visitOptionalAbsent<Content: View>(_: Content.Type)
    mutating func visitOptionalPresent<Content: View>(
        _ content: borrowing Content
    )
    mutating func visitPrimitive<Payload: _GiftUISemanticPrimitivePayload>(
        _ payload: borrowing Payload
    )
    mutating func visitActionPrimitive<Payload: _GiftUISemanticActionPayload>(
        _ payload: borrowing Payload
    )
    mutating func visitModifier<
        Content: View, Payload: _GiftUISemanticModifierPayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    )
}
```

The zero-child and one-child builder results lower as `EmptyView` and the
child itself, respectively. Each visitor operation receives borrowed or
nonescaping values and MUST NOT require `Any`, an existential payload,
reflection, a string key, a closure retained past the call, or a runtime
registry. Metatype arguments select an inactive generic branch only; expansion
MUST NOT instantiate, evaluate, retain, address-compare, or emit an event for
that branch.

`GiftUI` MUST supply the ordinary custom-view default. A declaration without
direct observable state calls `visitCustomView`. SPEC-010's
`@ObservableStateHost` macro MUST synthesize the only supported client override
and call `visitStatefulCustomView`; direct handwritten overrides remain
unsupported. The stateful operation makes one mutable transient copy, invokes
the generated declaration witness through the SPEC-010 state-binding
decorator, and evaluates the supplied body accessor only if every binding
succeeds. Binding failure evaluates no body and is returned by the combined
runtime coordinator as the exact SPEC-010 error rather than a semantic-
expansion error. Semantic Core neither stores nor interprets a state value,
attachment, registration, dirty bit, or target generation.

Each wrapper above MUST override
the requirement and call exactly its matching visitor operation. Each later
concrete primitive or modifier contract MUST define its typed payload and its
single matching override through this SPI. An action-bearing primitive MUST
use the action-bearing operation exactly once; it MUST NOT separately use the
non-action primitive operation for the same occurrence. These rules are the
closed dispatch contract; adding a later declaration category requires a
reviewed revision of this Specification rather than an unregistered hook. The
stateful-custom-view operation is a custom-body boundary, not a semantic
occurrence or new node category.

### Expansion limits and summary

`GiftUISemanticCore` MUST expose the following package SPI. These values are
immutable after an expansion attempt begins.

```swift
package struct SemanticExpansionLimits: Equatable, Sendable {
    package let maximumDepth: UInt16
    package let maximumSemanticNodes: UInt16
    package let maximumBodyEvaluations: UInt16
    package let maximumModifierApplications: UInt16
    package let maximumActionOccurrences: UInt16

    package init?(
        maximumDepth: UInt16,
        maximumSemanticNodes: UInt16,
        maximumBodyEvaluations: UInt16,
        maximumModifierApplications: UInt16,
        maximumActionOccurrences: UInt16
    )
}

package struct SemanticExpansionSummary: Equatable, Sendable {
    package let semanticNodeCount: UInt16
    package let bodyEvaluationCount: UInt16
    package let modifierApplicationCount: UInt16
    package let actionOccurrenceCount: UInt16
    package let maximumObservedDepth: UInt16
}

package enum SemanticExpansionError: UInt8, Equatable, Sendable {
    case capacityExhausted = 0
    case invalidIdentity = 1
    case reentrancyViolation = 2
    case invariantViolation = 3
}

package enum SemanticExpansionResult: Equatable, Sendable {
    case success(SemanticExpansionSummary)
    case failure(SemanticExpansionError)
}
```

`maximumDepth`, `maximumSemanticNodes`, and `maximumBodyEvaluations` MUST be
nonzero. Modifier and action limits MAY be zero. Initialization returns `nil`
for an invalid limit set and produces no partial value. Production values are
selected by the later RUNTIME-PROFILES/HOST-CONFIGURATION contracts; this
Specification's independent fixtures MUST inject small values and exercise
every edge.

The fields and counts have these exact meanings:

- `maximumDepth` bounds the number of simultaneously active structural-path
  components. The root component has depth one. A custom-body, fixed-child,
  selected conditional-branch, optional-presence, or declaration-role
  component increases depth by one while active. Modifier applications do not
  increase depth.
- `maximumSemanticNodes` bounds framework semantic occurrences. Empty, group,
  conditional, optional, modifier, and custom-view wrappers do not increment
  it.
- `maximumBodyEvaluations` bounds custom-view `body` evaluations. Builder and
  framework wrapper traversal and framework primitive dispatch do not
  increment it.
- `maximumModifierApplications` bounds individual typed modifier payloads,
  including repeated modifiers of the same kind.
- `maximumActionOccurrences` bounds action-bearing semantic occurrences. Each
  is also one semantic node, so an action reservation never replaces the node
  reservation.
- `maximumObservedDepth` is the greatest permitted depth actually entered on
  a successful attempt, including the root-position and endpoint-role
  components. It is two for an `EmptyView` root and never zero on success.

Counts reserve the next unit before the corresponding body evaluation,
semantic-node stage, modifier stage, or action stage. A count equal to its
limit is permitted; the next reservation fails before the operation occurs.
Path depth is checked before entering the next component. Counters MUST NOT
include inactive branches, absent optionals, rejected reservations, or work
after the first failure.

The expansion entry point MUST be the sole generic package operation over
`Root: View`, a profile-owned `SemanticExpansionWorkspace`, and a
`SemanticExpansionSink`. It accepts the root by nonescaping borrow, immutable
limits, and `inout` caller-owned workspace and sink, and returns
`SemanticExpansionResult`. Both protocols are package SPI owned by
`GiftUISemanticCore`; their exact associated identity and storage types MAY be
profile-specific, but they MUST provide these operations:

1. report all finite path, identity, staging, and sink capacities before the
   attempt;
2. reject begin while the same workspace is active;
3. stage a structural occurrence, semantic occurrence, modifier application,
   and action occurrence without publishing it;
4. publish the staged result exactly once on success;
5. discard the complete staged result on failure; and
6. reset to an idle, reusable state without retaining the borrowed root or
   payloads.

A sink refusal caused by any reported finite capacity maps locally to
`.capacityExhausted`. A sink or workspace that reports sufficient capacity and
then cannot honor it maps to `.invariantViolation`; it MUST NOT be reclassified
as ordinary backpressure. The local result MUST add no allocation and MUST not
contain a SPEC-003 fact, operational outcome, disposition, health, or
diagnostic value.

### Canonical recording seam

The package recording sink MUST expose a canonical transcript for contract
fixtures. Each transcript event contains an exact structural path plus one of
these closed event kinds:

```text
enterStructuralOccurrence(declarationRole)
evaluateCustomBody(declarationRole)
stageSemanticOccurrence(declarationRole)
applyModifier(modifierRole, zeroBasedChainIndex)
associateAction(actionRole)
```

Canonical paths use the component algebra `root`, `customBody`,
`fixedChild(0...4)`, `conditionalBranch(0|1)`, `optionalPresence`, and
`declarationRole`. Fixture declaration, modifier, and action roles are
source-declared symbolic tokens local to the checked-in corpus. Tests compare
token equality and component sequences; they MUST NOT compare strings,
metatype addresses, hashes, object identity, or profile-private raw identity
bytes. Production identities MAY use another bounded representation but MUST
produce the same transcript and equality relation.

Optional absence produces only its wrapper's structural-entry event; it emits
no presence-child event. Structural wrappers emit no semantic event.
`evaluateCustomBody` is recorded immediately before the one body access.
Modifier chain indices start at zero for each modifier scope.
`associateAction` follows the semantic occurrence at the same path and
precedes that occurrence's modifiers. The published successful transcript's
body, semantic, modifier, and action event counts plus its greatest path depth
MUST equal `SemanticExpansionSummary`; structural-entry events are not a
separate summary counter. A discarded attempt is not a current semantic
result, although a test-only attempted-event probe MAY verify the detecting
point.

`SemanticExpansionLimits` and `SemanticExpansionSummary` MUST each occupy no
more than 10 bytes, `SemanticExpansionError` exactly 1 byte, and
`SemanticExpansionResult` no more than 12 bytes on every supported compiler.
Workspace, sink, and identity storage budgets remain profile-owned and MUST be
reported by the later RUNTIME-PROFILES contract rather than inferred here.

### Modifier declaration seam

This Specification defines no public concrete modifier. Every concrete
modifier introduced by a later approved Specification MUST use the one
underscored modifier operation in `_GiftUISemanticTraversalVisitor`. The seam MUST
carry its typed payload without `Any`, reflection, strings, or a global
runtime registry and MUST associate the modifier with its exact modifier scope
while preserving all content structural identities.

A public modifier method MUST return a value conforming to `View` and append
exactly one modifier application to the source-order chain. A later contract
MAY expose the concrete wrapper type or return `some View`; neither choice may
change the ordering or identity rules here.

## Behavior

### Expansion order

An expansion attempt MUST be synchronous, depth-first, and left-to-right.
For identical declarations, limits, and admitted external state, its trace
and result MUST be deterministic.

1. Enter the root-position component and the root declaration-role component.
2. For an ordinary custom view, record its structural occurrence, enter its
   custom-body component, reserve one body evaluation, record
   `evaluateCustomBody`, evaluate `body` exactly once, then expand the returned
   value. For a stateful custom view, perform the same steps but first let the
   SPEC-010 decorator bind every generated direct state declaration on one
   mutable transient copy. Binding emits no semantic node or body count. The
   body accessor receives that bound copy and runs exactly once only after all
   bindings succeed; failure records no `evaluateCustomBody` event.
3. For a fixed group, expand present children in increasing zero-based source
   index. The group itself emits no semantic node.
4. For conditional content, enter branch `0` for `first` or branch `1` for
   `second`, then expand its sole child at child index `0`. The inactive branch
   is not evaluated.
5. For optional content, absence emits no semantic node, body evaluation,
   modifier, or action. Presence enters the optional-presence component and
   expands its sole child at child index `0`.
6. For a framework declaration, record its structural occurrence, validate
   unique structural identity, reserve and stage one semantic occurrence,
   associate one action occurrence when action-bearing, and then expand any
   declared fixed semantic children in source order.
7. Apply modifiers for one modifier scope in increasing zero-based source-call
   index after the modified content has been structurally identified and
   before a later consumer observes the completed scope.

An expansion implementation MUST NOT evaluate an inactive branch, reorder
siblings, invoke a custom body more than once, traverse layout/render output,
or permit asynchronous or concurrent semantic mutation during the attempt.

### Structural identity

Structural identity equality MUST follow these rules:

- roots with the same concrete declaration role begin at the same root;
- each custom declaration role and body boundary, fixed-child index,
  conditional branch, optional-presence boundary, and framework declaration
  role contributes to the exact structural path;
- equal identities require equal complete paths and equal endpoint roles;
- different sibling indices or conditional branches MUST never compare equal;
- group wrappers and modifiers MUST NOT create a semantic node or replace any
  descendant structural identity; their exact paths still distinguish group
  children and modifier scopes;
- changing modifier payload MUST NOT by itself replace the underlying
  occurrence identity;
- removing an optional occurrence removes its identity; restoring the same
  occurrence at the same structural path restores the same structural
  identity relation; and
- a path prefix MUST NOT compare equal to a complete descendant path.

No hash collision may produce identity equality. A profile MAY store paths,
interned indices, generated typed positions, or another bounded
representation, but equality and the recording trace MUST match these rules.
Raw identity representation MUST NOT be client API, serialized, persisted
across assembled-runtime lifetimes, or used to expose runtime-profile choice.

### Action identity

An action-bearing declaration introduced by a later approved contract MUST
request one package-SPI semantic action identity at its structural occurrence.
Two action-bearing occurrences at different structural paths MUST have
distinct identities even when their later interaction payloads compare equal.
Equivalent re-expansions in both profiles MUST preserve the same identity
relation.

Expansion MUST borrow the payload's typed `GiftUIAction` value and stage it
with the action occurrence in the complete semantic result for synchronous
downstream candidate construction. It MUST NOT invoke the action, decode it
through a handler, bind it to a model target, or retain a callable, handler, or
model reference. Capture, replacement, committed lifetime, target binding, and
dispatch belong to INTERACTION and EXECUTION under ADR-033. This Specification
neither makes an expansion-time identity dispatchable nor allocates, advances,
captures, or compares a committed action generation. A backend or declaration
visitor MUST NOT call client behavior.

The identity defined here is the stable identity component of ADR-033's
captured identity-generation pair. Downstream committed-action lowering MUST
treat a changed bounded action value, changed target generation, or other
changed binding at the same identity as replacement and install a new
generation. Preserving, replacing, releasing, and dispatching the bound record
remain downstream obligations and MUST NOT cause a second semantic identity or
expansion engine here.

### Modifier order

Modifier applications are ordered and non-commutative by default. For
`base.a().b().c()`, the semantic chain for that scope is exactly
`[(a, 0), (b, 1), (c, 2)]`. A custom view's outer modifiers follow the complete
modifier events produced inside its body. A modifier applied to a fixed group
is attached to the group scope after every present child has expanded.
Sibling modifier chains do not interleave.

Expansion MUST preserve an otherwise unknown modifier as a typed application
for its owning later consumer. It MUST NOT sort by modifier kind, collapse
duplicates, move a modifier across a custom-view or child boundary, or infer
layout/render meaning.

### Atomicity

All semantic output is staged. Success publishes one complete expansion
summary and makes the staged result available to its next consumer. A failure
publishes no staged semantic tree, transcript, identity map, action map, or
modifier chain as current. Caller-owned scratch may retain unspecified bytes
after failure but MUST be reset before reuse and MUST NOT be observable as
committed semantic state.

## State / Lifecycle

Declaration values are borrowed only for their synchronous evaluation. The
framework MUST NOT retain a borrowed root, custom-body result, builder child,
modifier payload, or closure beyond the declared expansion lifetime unless a
later owning contract explicitly transfers or copies it.

Structural and semantic action identities belong to runtime-owned staged or
committed semantic structure, never to the transient declaration value. This
Specification defines their equality and expansion lifetime; OBSERVABLE and
EXECUTION own state-slot lifetime, invalidation, publication, reconciliation,
and revision lifetime. Pointer capture MUST NOT extend a declaration, action
value, callable, handler, or model lifetime through this identity; ADR-033's
downstream capture stores the identity-generation pair only.

An attempt moves only forward:

```text
idle -> expanding -> staged-complete -> returned-success
                  \-> discarded -> returned-local-failure
```

Reentrant expansion through the same semantic workspace is illegal. External
input, invalidation, or callbacks that arise during expansion MUST enter their
later bounded admission seam and MUST NOT recursively expand the root.

## Capability Requirements

This Specification declares no Capability or Trait and performs no capability
resolution. Rank 0 declaration availability and semantics MUST NOT vary with
backend, platform, driver, OS/RTOS, HAL, hardware identity, or
`rasterPresentation` results.

If a later concrete declaration requires a capability, its owning
Specification MUST preserve this expansion and identity contract and define
absence behavior through SPEC-004. Capability absence MUST NOT silently alter
builder shape, branch choice, modifier order, or action identity.

## Backend Requirements

No backend participates in declaration expansion. A backend MUST NOT reference
the underscored declaration traversal surface, evaluate `body`, inspect custom
views, reinterpret modifiers, assign identity, retain declarations, or invoke
actions. Recording semantic fixtures MUST run without layout, render core, a
backend, a platform adapter, or connected hardware.

## Error Handling

`GiftUISemanticCore` MUST detect each condition and return the exact local
`SemanticExpansionError` below. It MUST NOT construct, import, or return a
SPEC-003 outcome or failure fact. The first runtime/owner adapter that imports
both contracts MUST map the local error through SPEC-003 exactly as follows:

| Condition | Local error | `condition` | `origin` | `affectedScope` | `containment` |
| --- | --- | --- | --- | --- | --- |
| Any declared depth, node, body-evaluation, modifier, action, or caller-owned workspace capacity is exhausted before completion | `.capacityExhausted` | `.capacityExhausted` | `.semantic` | `.activeCycle` | `.contained` |
| A structural path or semantic/action identity cannot be represented uniquely or an identity alias is detected | `.invalidIdentity` | `.invalidIdentity` | `.semantic` | `.activeCycle` | `.contained` |
| Expansion re-enters the active semantic workspace | `.reentrancyViolation` | `.reentrancyViolation` | `.semantic` | `.activeCycle` | `.contained` |
| Framework-owned declaration traversal violates the sealed declaration protocol and safe continuation cannot be proven | `.invariantViolation` | `.invariantViolation` | `.semantic` | `.activeCycle` | `.safetyNotProven` |

Detection order is normative when more than one condition is possible at one
step: reject same-workspace reentrancy at entry; check and reserve the next
path depth; validate the resulting path and identity representation; reserve
the operation-specific declared count; reserve workspace/sink storage; then
call the declaration hook or body.
For an action-bearing primitive, semantic-node reservation precedes action
reservation. For a modifier scope, reservations follow increasing chain index.
The first failed check returns its local error. A framework hook that invokes
the wrong visitor category, invokes more than one primitive category, reports
sufficient storage that it cannot honor, or reaches `Never.body` returns
`.invariantViolation` when safe detection is possible; an unavoidable client
trap is outside GiftUI's recoverable outcome contract.

Invalid `SemanticExpansionLimits` construction returns local `nil`. The first
host/runtime owner adapter that reports it cross-layer MUST map it to
`.invalidValue`, `.semantic`, `.runtime`, `.contained` before the first cycle
starts. `GiftUISemanticCore` performs neither mapping.

Every local failure MUST stop traversal at the detecting point, discard all
staged semantic output, preserve the local error unchanged through the owner
adapter, and perform no action. After mapping, optional annotation or
diagnostic saturation MUST NOT replace the primary fact. Capacity exhaustion
MUST NOT truncate a tree and report success, overwrite earlier staged entries,
retry recursively, or fall back to an allocating/dynamic representation.

Unsupported dynamic-only syntax MUST be absent at compile time in the
portable profile. It MUST NOT compile as a placeholder that traps only on an
embedded target.

## Performance Requirements

- Expansion work MUST be linear in the number of evaluated custom bodies,
  semantic occurrences, modifiers, and action occurrences before success or
  the first failure.
- The static path MUST expand every required declaration with zero heap
  allocations, no reflection, no `Any`, no unrestricted existential storage,
  no runtime registry, no Objective-C, and no `Task` or `MainActor`.
- Expansion stack depth MUST be bounded by `maximumDepth`; recursion or an
  indirect call cycle that can exceed that bound is non-conforming.
- Limits and counters MUST use fixed-width storage and MUST detect increment
  overflow as capacity exhaustion before wrapping.
- A failed attempt MUST retain no correctness-bearing storage proportional to
  the rejected declaration after it returns.

The implementation MUST provide a checked-in
`scripts/contracts/run-spec-006.sh` driver with these commands:

```text
scripts/contracts/run-spec-006.sh --profile macos-dynamic
scripts/contracts/run-spec-006.sh --profile macos-static
scripts/contracts/run-spec-006.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-006.sh --profile nrf52840-embedded
```

The driver MUST use the compiler/target/optimization identities fixed by
SPEC-002 for the corresponding profile, record the repository revision and
complete commands, compile the shared declaration corpus, report allocation
counts, every owned value's size/stride/alignment, every summary counter,
maximum observed expansion depth, and underscored traversal references. It
MUST inspect the nRF52840 ELF for the required hard-float calling convention.
ARMv6 and nRF52840 invocations are cross-build/inspection seams and require no
connected hardware.

This Specification deliberately sets no standalone latency, linked-code, or
total semantic-workspace ceiling. Production node/action/workspace capacities
and aggregate runtime budgets belong to RUNTIME-PROFILES and HOST-CONFIGURATION.
Any measured inability to implement the exact semantics within those later
bounds is an upstream contract conflict, not permission to weaken this Spec.

## Compatibility

- The same custom-view source and Rank 0 declaration surface MUST compile for
  all four MVP configurations.
- Static and dynamic profiles MUST produce equivalent canonical expansion
  traces, structural-identity relations, modifier order, action occurrence
  identities, summaries, and failures for the shared corpus.
- `import GiftUI` remains the sole portable Presentation import.
- This Specification establishes no public ABI, serialized identity format,
  persistent semantic-tree format, or compatibility for proof-of-concept
  public traversal hooks.
- Migration MUST remove the requirement for clients to implement `_visit` or
  `ViewVisitor`, restrict public wrapper storage and construction to the
  access fixed here, and document every source adjustment. Existing tuple
  names and five-child builder evidence may be retained only when they satisfy
  this contract. This Specification owns only the bounded `GiftUIAction` value
  protocol; public action-bearing controls and dispatch remain INTERACTION
  work.

## Testing Requirements

### Declaration and compile fixtures

- Compile a no-associated-value `UInt16` action enum conforming to
  `GiftUIAction`; reject a different raw-value width and treat associated-value
  action shapes as non-conforming during framework review/generation.
- Compile custom views with `body: some View`, nested custom views, and
  view-returning properties/functions, with and without `@ViewBuilder`.
- Compile builder blocks of arity zero through five and reject a direct
  six-expression block unless the client explicitly nests composition.
- Compile both branches and optional presence/absence without evaluating the
  inactive declaration.
- Prove `Never` satisfies `Body: View`, every framework wrapper dispatches its
  matching underscored visitor operation without reading `body`, and custom
  views receive the one default custom-body implementation.
- Compile an `@ObservableStateHost` view through the exact SPEC-010 macro
  expansion and prove its generated traversal witness calls
  `visitStatefulCustomView`, while an ordinary custom view continues to call
  `visitCustomView` without a handwritten witness.
- Prove that `buildArray`, unrestricted dynamic collections, supported client
  traversal API, wrapper storage/initializers, and runtime/backend types are
  absent from the normal portable surface. Prove an external custom `View`
  conformance compiles without declaring `_giftUITraverse`.

### Recording semantic fixtures

- Record exact depth-first, left-to-right traces for nested custom views,
  every fixed arity, both conditional branches, present/absent optional
  content, empty content, and nested combinations.
- Compare the complete canonical transcript event-by-event and prove its four
  counted event classes and greatest path depth equal the returned summary.
- Compare canonical structural-identity equality across repeated expansion,
  branch changes, optional removal/restoration, sibling insertion within a
  different branch, endpoint-role changes, and prefix/descendant paths.
- Prove action-bearing declarations at different occurrences have distinct
  package-SPI semantic action identities and equivalent re-expansions preserve
  their identity relation across profiles. Prove expansion itself neither
  creates an action generation, binds a target generation, or retains or
  invokes a callable, handler, or model.
- Record modifier chains of length zero, one, repeated same-kind, and mixed
  kinds; prove exact source order, custom-view nesting order, and no sibling
  interleaving without asserting concrete layout or render meaning.
- Prove each active custom body is evaluated exactly once and each inactive
  body zero times per attempt.
- With the SPEC-010 decorator, prove direct state declarations are visited in
  lexical ordinal order before the stateful body event, the body accessor
  receives the bound transient copy, and any binding failure produces no body
  event or partial semantic transcript.

### Bounds and failure fixtures

- Exercise exactly-at-limit success and one-over-limit failure independently
  for depth, semantic nodes, body evaluations, modifier applications, action
  occurrences, and caller-owned workspace.
- Exercise simultaneous candidate failures and prove the mandated detection
  order, including a sink/workspace capacity refusal versus a falsely reported
  sufficient capacity.
- Prove each condition first returns the exact closed local error, stops
  traversal, publishes no partial semantic result, invokes no action, and
  allows clean workspace reuse by a later valid attempt.
- In a separate runtime-owner-adapter fixture, prove each local error and
  invalid-limits `nil` maps to the exact SPEC-003 fact row above while
  `GiftUISemanticCore` itself imports no failure module.
- Force identity alias detection, reentrant expansion, and a sealed-protocol
  invariant violation in framework-only fixtures.
- Prove diagnostics disabled, enabled, saturated, dropped, or failing do not
  change the local expansion result, trace, counts, or adapter-mapped primary
  failure fact.

### Profile and dependency fixtures

- Run the same source corpus and compare canonical results through dynamic and
  static implementations without comparing profile-private raw identity
  bytes.
- Prove static expansion makes zero heap allocations and links no dynamic
  convenience module.
- Prove the limits, summary, local error, and local result values meet their
  exact memory-layout bounds on every contract-driver compiler.
- Prove `GiftUI` imports no `GiftUISemanticCore` implementation and
  `GiftUISemanticCore` imports `GiftUI` but neither `GiftUIFailureCore` nor
  `GiftUIFailureExecution`; prove the runtime owner adapter is the first
  target allowed to import both semantic Core and failure Core.
- Prove package source references the underscored traversal surface only from
  GiftUI declaration implementations, Semantic Core, and named conformance
  fixtures; backend, platform, driver, and portable client sources MUST NOT
  reference or override it.
- Check in a migration inventory covering every proof-of-concept `_visit`,
  `ViewVisitor`, public wrapper initializer/storage member, string path, and
  runtime-specific traversal entry affected by this contract.
- Produce all four contract-driver reports; connected-board execution is
  downstream conformance evidence, not this independent approval seam.

## Acceptance Criteria

- [ ] **DV-001:** The exact `GiftUIAction`, Rank 0 `View`, `ViewBuilder`, and
  fixed-wrapper public source contract compiles for all four MVP configurations
  with only `import GiftUI` in portable Presentation; `Never` satisfies the
  recursive `Body: View` constraint without being evaluated.
- [ ] **DV-002:** Builder fixtures accept direct arities zero through five,
  conditionals, and optionals; direct six-expression and dynamic-array
  composition are absent unless explicitly nested into the supported surface.
- [ ] **DV-003:** Custom bodies and view-returning properties/functions expand
  synchronously, once per active occurrence, never for inactive branches, and
  with the exact depth-first left-to-right canonical transcript and summary.
- [ ] **DV-004:** Repeated, branch-changing, and optional-removal/restoration
  fixtures satisfy every structural-identity equality and inequality rule,
  with no collision or client-visible raw representation.
- [ ] **DV-005:** Modifier fixtures preserve exact source-call and nesting
  order, do not create semantic-node identity, and assert no layout or render
  behavior.
- [ ] **DV-006:** Action-bearing declarations at different structural
  occurrences have distinct package-SPI semantic action identities;
  equivalent re-expansions preserve their identity relation, and expansion
  allocates no committed action generation, binds no model target, retains no
  action value/callable/handler/model for pointer capture, and invokes no
  action.
- [ ] **DV-007:** Every expansion/workspace capacity succeeds exactly at its
  limit and fails one over with `.capacityExhausted`, no truncation, partial
  publication, overwrite, allocation fallback, or action invocation; the
  mandated detection order is stable when conditions coincide, and the first
  runtime-owner adapter maps that local error to the exact SPEC-003 fact.
- [ ] **DV-008:** Identity alias, reentrancy, invalid limits, and sealed-
  protocol violations produce the exact local error or `nil` specified here,
  and the first runtime-owner adapter maps each to the exact SPEC-003 fact;
  diagnostics cannot change any correctness-relevant result.
- [ ] **DV-009:** Dynamic and static implementations produce equal canonical
  traces, identity relations, modifier order, action associations, summaries,
  and failure facts for the complete shared corpus.
- [ ] **DV-010:** Static conformance records zero heap allocations, bounded
  depth, fixed-width nonwrapping counters, every owned value's required memory
  layout, and the nRF52840 hard-float ELF attributes through the four exact
  driver commands.
- [ ] **DV-011:** Dependency tests prove `GiftUI` remains a portable leaf with
  no semantic-runtime implementation import, only Semantic Core and named
  fixtures plus GiftUI declaration implementations reference the underscored
  traversal surface, Semantic Core imports no failure module, only the runtime
  owner adapter imports both semantic and failure contracts, and all remaining
  imports follow the approved partial order.
- [ ] **DV-012:** Review finds no layout, render, state/invalidation,
  activation/input, capability, backend, frame, or host policy defined by this
  Specification.
- [ ] **DV-013:** Migration evidence inventories and resolves every public
  proof-of-concept traversal hook, wrapper initializer/storage exposure,
  string structural path, and dynamic/static traversal entry without adding a
  compatibility shim that creates a second expansion engine.
- [ ] **DV-014:** `FW-017` and `FW-020` remain optional, post-MVP captures with
  reciprocal links and concrete revisit triggers; no required product behavior
  or implementation criterion depends on pursuing either item.
- [ ] **DV-015:** Stateful custom-view fixtures call the generated SPEC-010
  declaration witness before body evaluation, preserve ordinary expansion
  counts and identity on success, and emit no body event or partial semantic
  result when state binding fails.

## Implementation Notes

This section is non-authoritative guidance. The proof of concept already has
`View`, `ViewBuilder`, fixed tuple wrappers, conditional/optional wrappers, a
visitor, and dynamic/static traversal tests. Those are useful fixture inputs.
The maintained implementation should confine the underscored traversal
surface to its allowed framework owners and replace string structural paths
with bounded profile-appropriate representations while comparing canonical
identity relations rather than raw bytes.

A recording semantic sink should be implemented before retained runtime
storage. It can then serve as the common oracle for both runtime profiles and
for later layout adapters.

## Open Issues

No open issue remains. The contract-level builder-arity choice
is resolved in favor of five direct expressions. The maintained Rank 0
surface therefore remains fixed at arities zero through five; clients compose
larger hierarchies by nesting fixed groups or custom views.

Action lifetime and replacement are governed by RFC-011 and ADR-033: pointer
down captures the stable semantic identity together with the committed action
generation and no action value, target generation, callable, handler, or model;
changing the bounded action or model-target binding installs a new generation;
release activates only after the exact current pair, hit, and enabled state
match. EXECUTION and INTERACTION specify finite representation, target
revalidation, and dispatch without redefining the identity contract here.
[FW-020](../future-work/fw-020-declarative-extensibility.md) preserves
the separately gated post-MVP declarative-extensibility cluster.

## Deferred and Follow-up Work

- [FW-017](../future-work/fw-017-public-binding-abstraction.md) preserves a
  public two-way binding abstraction. It is not required by Rank 0.
- [FW-020](../future-work/fw-020-declarative-extensibility.md) preserves
  unrestricted dynamic collections, keyed collection identity, public type
  erasure, public custom modifiers, and client-visible explicit view identity.
  None is required by the Signal Analyzer or this contract.
- Concrete layout, rendering, interaction, observable-state, and drawing
  modifier vocabularies remain with their owning downstream Specifications.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [ADR-005: Semantic, Layout, and Render Boundary](../adrs/adr-005-semantic-layout-render-boundary.md)
- [ADR-006: Shared Semantics Across Runtime Profiles](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-008: Module Dependency Graph and MVP Package Topology](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [RFC-011: Bounded Application Actions and Model-Target Dispatch](../rfcs/rfc-011-bounded-application-actions.md)
- [ADR-033: Bounded Application Actions and Model-Target Dispatch](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md)
- [ADR-032: Semantic-Core-Owned Borrowed Layout Input](../adrs/adr-032-semantic-core-owned-layout-input.md)
- [SPEC-002: Portable Foundation](spec-002-portable-foundation.md)
- [SPEC-003: Failure Outcomes and Containment](spec-003-failure-outcomes-and-containment.md)
- [SPEC-010: Observable Reference State Contract](spec-010-observable-reference-state.md)
- [FW-017: Public Binding Abstraction](../future-work/fw-017-public-binding-abstraction.md)
- [FW-020: Declarative Extensibility](../future-work/fw-020-declarative-extensibility.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
- `Sources/GiftUI/View/`, `Sources/GiftUI/Composition/`, and current runtime
  conformance tests —
  proof-of-concept evidence only
