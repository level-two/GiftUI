---
id: SPEC-006
feature: giftui-mvp-architecture
title: Declarative View Semantics Specification
status: draft
authors:
  - codex
created: 2026-08-25
updated: 2026-08-25
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-004
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-008
  - ADR-013
related_specs:
  - SPEC-002
  - SPEC-003
related_future_work:
  - FW-017
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-006: Declarative View Semantics Specification

## Summary

This Specification defines the Rank 0 GiftUI client model and its profile-
neutral structural expansion contract. Portable clients declare transient
`View` values, compose zero through five fixed children with `ViewBuilder`,
factor declarations into custom views, and apply modifier declarations in
source order. The semantic runtime expands those declarations synchronously
into runtime-owned semantic structure with deterministic structural and action
identity.

This contract is deliberately complete before layout: its recording fixtures
observe declaration order, structural paths, branch selection, custom-body
boundaries, modifier order, action identity, and bounded refusal, but no size,
placement, hit region, render operation, state slot, or backend output.

## Scope

This Specification owns:

- the public `View` and `ViewBuilder` declaration model;
- fixed zero-through-five sibling composition, empty, conditional, and
  optional composition;
- custom views and view-returning properties or functions without mandatory
  type erasure;
- the semantic meaning and ordering of modifier chains, while later
  Specifications own concrete modifier vocabularies and payloads;
- runtime-owned structural identity and semantic action-occurrence identity;
- deterministic synchronous expansion of transient declarations;
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
  reconciliation, run-cycle publication, or frame handoff.
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
  [ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md), and
  [ADR-013](../adrs/adr-013-provenance-validated-input-admission.md) are
  accepted.
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
- EXECUTION and INTERACTION own committed action records and generations under
  ADR-013. They consume the stable semantic action identity defined here as
  one component of the captured identity-generation pair; this Specification
  does not allocate generations or retain callable payloads.

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
- **ADR-013 — Provenance-Validated Presentation-Coupled Input:** requires
  pointer capture to pair this Specification's stable semantic action identity
  with a downstream committed action generation, without retaining a callable
  payload, and requires exact pair revalidation before activation.

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

**Structural path**
: The exact ordered sequence of root, custom-body, fixed-child, conditional-
  branch, optional-presence, and declaration-role components by which an
  expanded semantic occurrence is reached.

**Structural identity**
: Runtime-owned identity determined by structural path and declaration role.
  Its equality is normative; its stored representation is profile-specific.

**Semantic action identity**
: The package-SPI runtime identity of one action-bearing occurrence, derived
  from that occurrence's structural identity and action-bearing role. It does
  not contain the downstream committed action generation and does not retain a
  public action payload.

**Modifier order**
: The source-call order of a modifier chain. In `base.a().b()`, `a` precedes
  `b`. Lowering may not reorder, merge, or discard modifiers unless the
  concrete modifier's approved contract explicitly proves equivalence.

**Expansion attempt**
: One synchronous, bounded evaluation of a root declaration into staged
  semantic structure or a recording sink.

## Public Contract

Portable Presentation MUST need only `import GiftUI`. A custom declaration
MUST be expressible as a value conforming to `View` with an opaque
`body: some View`. The declaration surface MUST be identical in static and
dynamic configurations.

Clients MUST NOT be required or permitted to implement a public traversal
method, manufacture structural identity, name a runtime profile, retain a
semantic node, or import layout, render, runtime, backend, platform, driver,
OS/RTOS, HAL, or hardware modules.

View-returning properties and functions MAY return `some View` and MAY use
`@ViewBuilder`. They MUST expand with the same rules as an equivalent inline
declaration. Custom views, builder groups, conditional wrappers, optional
wrappers, and modifier wrappers MUST require no client-visible type erasure.

The maintained Rank 0 surface supports at most five direct expressions in one
builder block. A client MAY compose more content by nesting fixed groups or
custom views. `buildArray` and unrestricted runtime child iteration MUST be
absent from the portable API.

## Module Contract

`GiftUI` MUST own the public declarations and package-only declaration hooks.
It MUST import no semantic-runtime implementation and MUST expose no runtime,
layout, render, backend, platform, or hardware type through this API.

`GiftUISemanticCore` MUST own expansion, structural paths, structural/action-
occurrence identity, staged semantic structure, and the recording conformance
seam. It MAY depend on `GiftUI`. It MUST NOT import `GiftUIFailureCore`,
`GiftUIFailureExecution`, a layout, render, runtime-profile implementation,
backend, platform, driver, OS/RTOS, HAL, hardware, or optional diagnostic
implementation.

`GiftUISemanticCore` MUST expose only the closed local expansion result and
error vocabulary below. The first runtime/owner adapter that imports both
`GiftUISemanticCore` and `GiftUIFailureCore` MUST map a local error to the
normative SPEC-003 fact in `Error Handling`. Neither failure module may import
`GiftUI` or `GiftUISemanticCore` to perform that mapping.

Dynamic and static runtime implementations MAY depend on
`GiftUISemanticCore`; it MUST NOT depend on either implementation. Concrete
declarations introduced by later Specifications MUST enter expansion through
package SPI owned jointly by their declaration module and
`GiftUISemanticCore`; they MUST NOT add public traversal requirements to
`View` or create a second expansion engine.

Declaration traversal SPI MUST be package-scoped. A dynamic convenience MAY
adapt callback-backed or erased syntax in a separately imported module, but
it MUST lower to the same fixed declaration and expansion semantics.

## Types / APIs

### Rank 0 declarations

The following public source contract is normative:

```swift
public protocol View {
    associatedtype Body: View

    @ViewBuilder
    var body: Body { get }
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

`EmptyView`, `TupleView`, `TupleView3`, `TupleView4`, `TupleView5`,
`ConditionalContent`, and `OptionalContent` MUST be public value types so
builder-generated public opaque results are representable. Their stored
children, branch storage, and construction initializers MUST be package SPI;
clients construct them through `ViewBuilder`. Each wrapper MUST be usable
without allocation, reflection, an existential, or runtime discovery.

Framework primitive declarations use `Body == Never` through package SPI.
Evaluating `body` on such a declaration is an invariant violation; normal
expansion MUST dispatch its package primitive hook and MUST NOT evaluate
`Never`. Client custom views MUST NOT declare themselves framework primitives.

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

The expansion entry point MUST be generic over `Root: View`, accept caller-
owned limits and workspace/sink storage, and return
`SemanticExpansionResult`. The local result MUST add no allocation and MUST
not contain a SPEC-003 fact, operational outcome, disposition, health, or
diagnostic value. Exact workspace representation is profile-owned, but it
MUST report its finite capacity before traversal and MUST NOT make declaration
semantics depend on storage strategy.

### Modifier declaration seam

This Specification defines no public concrete modifier. Every concrete
modifier introduced by a later approved Specification MUST use the one
package modifier-declaration seam in `GiftUI`. The seam MUST carry its typed
payload without `Any`, reflection, strings, or a global runtime registry and
MUST associate the modifier with its content while preserving the content's
structural identity.

A public modifier method MUST return a value conforming to `View` and append
exactly one modifier application to the source-order chain. A later contract
MAY expose the concrete wrapper type or return `some View`; neither choice may
change the ordering or identity rules here.

## Behavior

### Expansion order

An expansion attempt MUST be synchronous, depth-first, and left-to-right.
For identical declarations, limits, and admitted external state, its trace
and result MUST be deterministic.

1. Start at the root structural component.
2. For a custom view, enter its custom-body component, evaluate `body` exactly
   once for that occurrence in the attempt, then expand the returned value.
3. For a fixed group, expand present children in increasing zero-based source
   index. The group itself emits no semantic node.
4. For conditional content, enter branch `0` for `first` or branch `1` for
   `second`, then expand its sole child at child index `0`. The inactive branch
   is not evaluated.
5. For optional content, absence emits no semantic node, body evaluation,
   modifier, or action. Presence enters the optional-presence component and
   expands its sole child at child index `0`.
6. For a framework declaration, stage one semantic occurrence and then expand
   any declared fixed semantic children in their source order.
7. Apply modifiers associated with an occurrence in source-call order after
   the modified content has been structurally identified and before a later
   consumer observes the completed occurrence.

An expansion implementation MUST NOT evaluate an inactive branch, reorder
siblings, invoke a custom body more than once, traverse layout/render output,
or permit asynchronous or concurrent semantic mutation during the attempt.

### Structural identity

Structural identity equality MUST follow these rules:

- roots with the same concrete declaration role begin at the same root;
- each custom-body boundary, fixed-child index, conditional branch, optional-
  presence boundary, and framework declaration role contributes to the exact
  structural path;
- equal identities require equal complete paths and equal endpoint roles;
- different sibling indices or conditional branches MUST never compare equal;
- group wrappers and modifiers MUST NOT create semantic-node identity;
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

Expansion MUST NOT invoke an action. Client action payload, capture,
replacement, committed lifetime, and activation belong to INTERACTION and
EXECUTION under ADR-013. This Specification neither makes an expansion-time
identity dispatchable nor allocates, advances, captures, or compares a
committed action generation. A backend or declaration visitor MUST NOT call
client behavior.

The identity defined here is the stable identity component of ADR-013's
captured identity-generation pair. Downstream committed-action lowering MUST
treat installation of a newly derived callable payload at the same identity as
replacement and install a new generation. Preserving, replacing, releasing,
and activating that payload remain downstream obligations and MUST NOT cause a
second semantic identity or expansion engine here.

### Modifier order

Modifier applications are ordered and non-commutative by default. For
`base.a().b().c()`, the semantic chain is exactly `[a, b, c]`. A custom view's
outer modifiers follow the complete modifier chain produced inside its body.
Sibling modifier chains do not interleave.

Expansion MUST preserve an otherwise unknown modifier as a typed application
for its owning later consumer. It MUST NOT sort by modifier kind, collapse
duplicates, move a modifier across a custom-view or child boundary, or infer
layout/render meaning.

### Atomicity

All semantic output is staged. Success publishes one complete expansion
summary and makes the staged result available to its next consumer. An
operational or failure result publishes no staged semantic tree, identity
map, action map, or modifier chain as current. Caller-owned scratch may retain
unspecified bytes after failure but MUST be reset before reuse and MUST NOT be
observable as committed semantic state.

## State / Lifecycle

Declaration values are borrowed only for their synchronous evaluation. The
framework MUST NOT retain a borrowed root, custom-body result, builder child,
modifier payload, or closure beyond the declared expansion lifetime unless a
later owning contract explicitly transfers or copies it.

Structural and semantic action identities belong to runtime-owned staged or
committed semantic structure, never to the transient declaration value. This
Specification defines their equality and expansion lifetime; OBSERVABLE and
EXECUTION own state-slot lifetime, invalidation, publication, reconciliation,
and revision lifetime. Pointer capture MUST NOT extend a declaration or
callable payload lifetime through this identity; ADR-013's downstream capture
stores the identity-generation pair only.

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

No backend participates in declaration expansion. A backend MUST NOT import
the declaration traversal SPI, evaluate `body`, inspect custom views,
reinterpret modifiers, assign identity, retain declarations, or invoke
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
counts and maximum observed expansion depth, and inspect the nRF52840 ELF for
the required hard-float calling convention. ARMv6 and nRF52840 invocations
are cross-build/inspection seams and require no connected hardware.

This draft deliberately sets no standalone latency, linked-code, or total
semantic-workspace ceiling. Production node/action/workspace capacities and
aggregate runtime budgets belong to RUNTIME-PROFILES and HOST-CONFIGURATION.
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
  `ViewVisitor` and document any source adjustment. Existing tuple names and
  five-child builder evidence may be retained only when they satisfy this
  contract. Public client-action representation remains INTERACTION work.

## Testing Requirements

### Declaration and compile fixtures

- Compile custom views with `body: some View`, nested custom views, and
  view-returning properties/functions, with and without `@ViewBuilder`.
- Compile builder blocks of arity zero through five and reject a direct
  six-expression block unless the client explicitly nests composition.
- Compile both branches and optional presence/absence without evaluating the
  inactive declaration.
- Prove that `buildArray`, unrestricted dynamic collections, public traversal
  hooks, and runtime/backend types are absent from the portable surface.

### Recording semantic fixtures

- Record exact depth-first, left-to-right traces for nested custom views,
  every fixed arity, both conditional branches, present/absent optional
  content, empty content, and nested combinations.
- Compare canonical structural-identity equality across repeated expansion,
  branch changes, optional removal/restoration, sibling insertion within a
  different branch, endpoint-role changes, and prefix/descendant paths.
- Prove action-bearing declarations at different occurrences have distinct
  package-SPI semantic action identities and equivalent re-expansions preserve
  their identity relation across profiles. Prove expansion itself neither
  creates an action generation nor retains or invokes a callable payload.
- Record modifier chains of length zero, one, repeated same-kind, and mixed
  kinds; prove exact source order, custom-view nesting order, and no sibling
  interleaving without asserting concrete layout or render meaning.
- Prove each active custom body is evaluated exactly once and each inactive
  body zero times per attempt.

### Bounds and failure fixtures

- Exercise exactly-at-limit success and one-over-limit failure independently
  for depth, semantic nodes, body evaluations, modifier applications, action
  occurrences, and caller-owned workspace.
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
- Prove `GiftUI` imports no `GiftUISemanticCore` implementation and
  `GiftUISemanticCore` imports `GiftUI` but neither `GiftUIFailureCore` nor
  `GiftUIFailureExecution`; prove the runtime owner adapter is the first
  target allowed to import both semantic Core and failure Core.
- Prove a backend, platform, driver, and portable client cannot import package
  traversal SPI.
- Produce all four contract-driver reports; connected-board execution is
  downstream conformance evidence, not this independent approval seam.

## Acceptance Criteria

- [ ] **DV-001:** The exact Rank 0 `View`, `ViewBuilder`, and fixed-wrapper
  public source contract compiles for all four MVP configurations
  with only `import GiftUI` in portable Presentation.
- [ ] **DV-002:** Builder fixtures accept direct arities zero through five,
  conditionals, and optionals; direct six-expression and dynamic-array
  composition are absent unless explicitly nested into the supported surface.
- [ ] **DV-003:** Custom bodies and view-returning properties/functions expand
  synchronously, once per active occurrence, never for inactive branches, and
  with the exact depth-first left-to-right trace.
- [ ] **DV-004:** Repeated, branch-changing, and optional-removal/restoration
  fixtures satisfy every structural-identity equality and inequality rule,
  with no collision or client-visible raw representation.
- [ ] **DV-005:** Modifier fixtures preserve exact source-call and nesting
  order, do not create semantic-node identity, and assert no layout or render
  behavior.
- [ ] **DV-006:** Action-bearing declarations at different structural
  occurrences have distinct package-SPI semantic action identities;
  equivalent re-expansions preserve their identity relation, and expansion
  allocates no committed action generation, retains no callable payload for
  pointer capture, and invokes no action.
- [ ] **DV-007:** Every expansion/workspace capacity succeeds exactly at its
  limit and fails one over with `.capacityExhausted`, no truncation, partial
  publication, overwrite, allocation fallback, or action invocation; the
  first runtime-owner adapter maps that local error to the exact SPEC-003 fact.
- [ ] **DV-008:** Identity alias, reentrancy, invalid limits, and sealed-
  protocol violations produce the exact local error or `nil` specified here,
  and the first runtime-owner adapter maps each to the exact SPEC-003 fact;
  diagnostics cannot change any correctness-relevant result.
- [ ] **DV-009:** Dynamic and static implementations produce equal canonical
  traces, identity relations, modifier order, action associations, summaries,
  and failure facts for the complete shared corpus.
- [ ] **DV-010:** Static conformance records zero heap allocations, bounded
  depth, fixed-width nonwrapping counters, and the required
  nRF52840 hard-float ELF attributes through the four exact driver commands.
- [ ] **DV-011:** Dependency tests prove `GiftUI` remains a portable leaf with
  no semantic-runtime implementation import, Semantic Core imports no failure
  module, only the runtime owner adapter imports both semantic and failure
  contracts, and all remaining imports follow the approved partial order.
- [ ] **DV-012:** Review finds no layout, render, state/invalidation,
  activation/input, capability, backend, frame, or host policy defined by this
  Specification.

## Implementation Notes

This section is non-authoritative guidance. The proof of concept already has
`View`, `ViewBuilder`, fixed tuple wrappers, conditional/optional wrappers, a
visitor, and dynamic/static traversal tests. Those are useful fixture inputs.
The maintained implementation should hide traversal behind package SPI and
replace string structural paths with bounded profile-appropriate
representations while comparing canonical identity relations rather than raw
bytes.

A recording semantic sink should be implemented before retained runtime
storage. It can then serve as the common oracle for both runtime profiles and
for later layout adapters.

## Open Issues

No accepted-architecture blocker remains in this draft. Human review should
confirm one contract-level choice before this Specification advances to
`review`:

1. whether five direct builder expressions remain sufficient for the final
   portable Signal Analyzer hierarchy, or whether a larger fixed arity is
   required.

The former action lifetime and replacement issue is resolved by RFC-004 and
ADR-013: pointer down captures the stable semantic identity together with the
committed action generation and no callable payload; replacement installs a
new generation; release activates only after the exact current pair, hit, and
enabled state match. EXECUTION and INTERACTION must specify the finite
representation and ownership details without redefining the identity contract
here. Keyed/dynamic child identity, client-visible identity, or public custom-
modifier architecture still requires lifecycle triage rather than expansion
of this contract.

## Deferred and Follow-up Work

- [FW-017](../future-work/fw-017-public-binding-abstraction.md) preserves a
  public two-way binding abstraction. It is not required by Rank 0.
- Unrestricted dynamic collections, keyed collection identity, public type
  erasure, public custom modifiers, and client-visible explicit view identity
  are outside the MVP contract. They require lifecycle triage if a concrete
  use case makes them necessary; this draft does not silently commit them.
- Concrete layout, rendering, interaction, observable-state, and drawing
  modifier vocabularies remain with their owning downstream Specifications.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [ADR-005: Semantic, Layout, and Render Boundary](../adrs/adr-005-semantic-layout-render-boundary.md)
- [ADR-006: Shared Semantics Across Runtime Profiles](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-008: Module Dependency Graph and MVP Package Topology](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [ADR-013: Provenance-Validated Presentation-Coupled Input](../adrs/adr-013-provenance-validated-input-admission.md)
- [SPEC-002: Portable Foundation](spec-002-portable-foundation.md)
- [SPEC-003: Failure Outcomes and Containment](spec-003-failure-outcomes-and-containment.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
- `Sources/GiftUI/View/`, `Sources/GiftUI/Composition/`, and current runtime
  conformance tests —
  proof-of-concept evidence only
