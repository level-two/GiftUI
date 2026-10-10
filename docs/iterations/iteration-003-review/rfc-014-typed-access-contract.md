# RFC-014: typed access and model ownership contract

**2026-10-10 — proposed RFC contract, not an approved Specification.** Parent:
[RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md).
This develops SR-Q3 under Eugene's instruction to resolve the remaining issues
and ask only for explicit decisions. The maintainer selected the independent
[three-bank capacity policy](rfc-014-capture-policy-choice.md).
Accepted ADR-011/024/025/026/034 and existing Specs remain unchanged.

## Decision at the design boundary

Use **typed read domains fixed by each compiled View conformance**, with short
borrowed read facades and separately authorized writes. Keep model fields in
stable owned storage. Keep authored `var body: some View`, model-property syntax,
and protocol Canvas. Swift infers Body; generated code supplies access binding,
context type arguments and checked mutation routes. No per-read snapshot
selection or frontend reconstruction of Body types is required.

The domain is a compile-time type describing the application's access operations;
it is not a runtime service locator or an application-wide mutable singleton.
The same generated portable presentation is specialized by a Dynamic or Static
bridge supplied by the host. GiftUI's generic core does not import either app's
schema, and portable presentation does not import a runtime or platform module.

This is a proposed realization within the existing RFC boundary. It resolves
which contract to develop, not every compiler/integration/resource proof. The
specific cross-module realization below has not yet been compiled; SPIKE-073
only proves the simpler concrete-context inference mechanism.

## Type and module boundary

The following is **schematic internal Swift**, not new author-facing syntax or
an already compiled public API:

```swift
protocol ReadDomain {
    associatedtype Slot  // An ordinary owned storage descriptor type.
}

struct FrameRead<Domain: ReadDomain>: ~Escapable {
    // Lifetime-dependent read-only access to typed owner descriptors.
    // Construction belongs to the trusted owner bridge, not to application views.
    private let slots: Span<Domain.Slot>
}

protocol View<Domain> {
    associatedtype Domain: ReadDomain
    associatedtype Body: View
    func evaluate(read: borrowing FrameRead<Domain>)
        throws(AccessFailure) -> Body
}

// Generated custom view. The method itself introduces no generic parameters.
struct AnalyzerRoot<D: AnalyzerReadDomain>: View {
    typealias Domain = D
    let model: ModelKey<AnalyzerSchema>
    func evaluate(read: borrowing FrameRead<D>)
        throws(AccessFailure) -> some View<D> { /* original body, scoped access */ }
}
```

Domain and Slot are ordinary associated types. The nonescapable type is the
concrete generic `FrameRead<Domain>`, not an associated type whose Escapable
conformance must be suppressed. This avoids depending on Swift 6.4's
[SE-0503](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0503-suppressed-associated-types.md).
It still needs the separately reviewed lifetime/compiler policy already exposed
by SPIKE-071–073. A new toolchain is not silently selected.

| Layer | Owns | Dependencies / exclusions |
| --- | --- | --- |
| GiftUI portable core | Generic View/builder/access types, typed key shape, common access failures, lifecycle-neutral read-scope interface | No analyzer/counter schema, Runtime import, `Any` registry or target record ABI |
| Generated application schema surface | AnalyzerSchema/CounterSchema markers; field types; typed read-domain requirements and read facades; pure derived getters | GiftUI plus application Domain/value modules; no runtime storage allocation, scheduler or hardware import |
| Generated portable Presentation | Context-parameterized view conformances, scoped body/draw/helpers and owned child payloads | GiftUI, application schema and existing value modules; no concrete profile implementation |
| Host/profile bridge | Concrete domain witness, address-stable typed slots, buffer decoding, owner/generation checks, phase-controlled read construction, writes/reporting and replacement | May depend on schema surface and the selected runtime/backend storage; the dependency points toward portable contracts |

The schema surface is a generated build input associated with the application,
not a hand-maintained universal GiftUI module containing all possible models.
The transformed presentation imports it; authored imports need no Runtime module.
Exact external package visibility belongs to iteration 4; this design must first
work across the current separate modules, not rely on a monolithic compilation.

A domain may implement multiple finite model schemas. Its Slot representation
and direct witnesses are known at assembly, so a counter-only domain has no
analyzer capture storage. A finite typed enum or separate typed regions can
represent heterogeneous slots; their size and projection costs must be measured.
No unbounded existential map or unchecked field-ID-to-pointer cast is authorized.

For example, the generated `AnalyzerReadDomain: ReadDomain` requirements name
specific operations: binding an `AnalyzerSchema` key, obtaining AcquisitionState
or VisibleTimeWindow, and loading a SignalTransition at a checked capture index.
Each bridge implements those operations with static typed dispatch over its Slot
representation. A concrete `AnalyzerRead<D>` facade stores a lifetime-dependent
read view and a validated projection; its ordinary property getters forward to
D's corresponding operation. It does not require an associated `Read` type whose
Escapable constraint is suppressed. Low-level projection construction and slot
access are restricted to the generated schema/bridge interface; application
getters cannot fabricate a projection or obtain a descriptor's pointer.

Computed properties use the facade's other typed reads; they are not target
storage operations. Thus `visibleRange` stays application semantics, while the
bridge only loads its typed inputs. An operation returning a service reference
or unmanaged mutable object is outside this read contract, even if its source
looks like an ordinary getter.

## Composition and inferred Body

All model-reading children in an assembled tree use the same concrete access
domain, possibly constrained only to the schema operations that they need.
Generated custom views carry D as a type argument, not as a stored read context.
The compiler infers each custom Body for that specialized conformance.

Composed custom views require their Body to use that domain. The schematic
protocol uses Domain as a primary associated type so the generated opaque result
can state `some View<D>` without naming the concrete Body. Domain-parameterized
core containers compose children with that same domain. Existing stateless
primitive values are lifted using a typed leaf wrapper containing only the
original owned declaration value. A stateless custom component remains a custom
view with a generated domain parameter; it is not wrapped as an opaque leaf. Domain type arguments at constructor/builder sites are
part of lowering. No view may erase the domain merely to satisfy composition.
A custom child is still traversed as a custom View, never recategorized as a
primitive to bypass its body.

Do not impose `Body.Domain == Domain` on the universal View protocol: Never is
the common leaf Body and has no meaningful read domain. Put same-domain
constraints on composed custom/container paths; keep explicit leaf dispatch
separate. Canvas remains a leaf with `Body == Never` and a draw witness receiving
the same domain's fresh scoped read. No broad Never default applies to custom
views. Cross-domain trees need an explicit composition design; the selected two
applications each have one assembled domain.

## Identity, binding and read facades

Keep four identities distinct: model schema, owner/runtime instance, allocated
model slot/generation, and structural State association/registration generation.
A copied `ModelKey<Schema>` owns no data and cannot dereference storage on its own.
The concrete frame owner retains every participating model until all frame reads
and staged Canvas payloads are released. Registration retirement is not ownership
release; reusing a slot requires a fresh checked allocation generation.

Before a read facade is created, the owner validates phase, owner identity,
schema, slot occupancy and allocation generation. A facade is nonescapable and
lifetime-dependent on FrameRead. Field access then uses schema-specific typed
operations. Readable stored scalars return owned values; nested model aggregates
return further scoped facades. Property access cannot expose the Slot descriptor,
raw address, writable reference, service object or owning ticket.

The bridge may need confined unsafe code to construct a Span or decode a packed
record. It must prove backing ownership, initialization, alignment, bounds and
lifetime at that boundary. A borrow of a descriptor containing a pointer does
not automatically prove the pointer's pointee lifetime; the frame owner and
closed mutation routes must establish it. Do not claim memory safety from a
phase bit or Span spelling alone.

The generated local binding has this schematic intent:

```text
read.analyzer(modelKey) -> borrowed AnalyzerRead<D>
AnalyzerRead.state.acquisitionState -> owned AcquisitionState
AnalyzerRead.state.visibleWindow -> owned VisibleTimeWindow
AnalyzerRead.state.errorMessage -> owned bounded diagnostic or nil
AnalyzerRead.visibleRange -> owned Range<Duration>
AnalyzerRead.state.capture -> borrowed CaptureRead<D>
CaptureRead.transition(at:) -> owned SignalTransition or bounds failure
```

Known valid scalar getters need no per-property owner lookup after binding.
Indexed capture access still checks the index. Bind failures map to typed body
access failure before using the facade; draw maps them to the established typed
Drawing failure path. No ordinary getter traps on capacity, wrong owner or stale
key. Diagnostic code and failure precedence require Spec review.

## Passing data to children and Canvas

Small values (window, ranges, diagnostics, action codes) remain ordinary owned
values. Model identity stays in typed keys. A large capture passed to a child
uses an owned presentation selection containing owner/model/allocation identity
and bounded metadata, never a borrowed facade or full 404-record copy.

Resolve that selection under the current frame owner before indexed reads.
The owner excludes mutation for the whole derivation, so the selection does not
need an independent historical snapshot bank. It must never mean “whatever model
is currently installed” across replacement. Staged values cannot survive their
attempt; persistent application ownership uses a separate owning ticket.

The existing owned Domain `SignalCapture` contract remains intact. The earlier C
proposal's explicit presentation-capture type migration remains required; a
borrowed selection must not be silently substituted for an independently owned
Domain value. Exporting a full owned Domain capture is an explicit boundary with
accounted destination capacity, outside body/draw evaluation.

## Actual source-route coverage

This is the contract mapping for the existing
[application inventory](../../../experiments/spike-072-contextual-traversal-integration/application-coverage.md),
not a claim that a generator already supports these forms.

| Existing route | Proposed read/write contract |
| --- | --- |
| Root `viewModel.state.*` and `visibleRange` | Bind AnalyzerRead once; preserve source evaluation order; derive range from the same unchanged capture metadata and window. |
| Header/controls, error optional/default text, selected-window predicates | Copy bounded values; normal Swift optional/switch/boolean evaluation and compiler-derived body types. |
| Waveform/channel children | Pass capture selection, owned range/channel/window/layout values. No 404-record body temporary. |
| `currentLevel`, `startingLevel`, `tracePointCount`, trace drawing loops | Scoped CaptureRead argument; bounded indexed reads, baseline handling and original short-circuit/filter order. Return owned scalars/geometry. |
| Grid drawing, duration formatting, geometry helpers | Keep pure owned inputs and existing synchronous closures; no model context when none is read. |
| Counter digit, disabled predicates, optional stroke | CounterRead returns UInt8; owned text/predicates; Canvas resolves the same model key for deferred reads. |
| Start/Stop/Clear | Invoke existing host-owned services only during the authorized action/mutation route; do not put service references in read facades or copied Canvas. |
| `visibleDurationChanged`, acquisition/failure updates | Exclusive typed write scope; validate phase and identities before changes; preserve equality/no-op and coarse dirty reporting. |
| Capture snapshot/mutation replay | Validate revision and all fallible input/capacity conditions before writing; update metadata and records coherently, then report once or according to the existing method contract. |
| Attach/detach, replacement, stale input | Preserve independent owner/registration generations, attach-time report rejection, old-association preservation on failure and committed replacement after later frame failure. |

Lowering preserves helper call order and short-circuit behavior. It introduces
context only along model-reading paths. A helper returning a view still uses
Swift opaque-result inference; a helper returning owned geometry does not acquire
an unnecessary model generic parameter. Unsupported escaping model aliases,
unknown mutating helper effects and unmanaged nested references are diagnosed by
the supported build, not routed through an unchecked fallback.

## Mutation and failure contract

A read facade has no setter. Generated @Published-like mutation routes use an
exclusive typed write scope obtained only during admitted mutation. Validate the
owner, generation, phase and required backing first. Model storage and
registration/dirty bookkeeping are separate so reporting does not take a second
exclusive borrow of a still-borrowed model region.

Do not expose an arbitrary user closure over `inout` model storage and call that
phase enforcement. The supported mutator set is generated/checked; it prevents
reference aliases and reports changes synchronously before returning. Detached
application owners retain their data, but their writes must use the same owning
store's serialized authority; observer detachment grants no concurrent-write right.

For a fallible capture operation, preflight capacity/revision/representation
checks before touching bytes. Do not implement rollback by copying the complete
model onto the stack. If an existing Domain algorithm cannot be expressed as a
preflight followed by non-failing commit within current capacities, that method
is an explicit implementation/contract blocker, not permission to silently change
its failure semantics. Service side effects already applied are never replayed
or undone merely because later derivation fails.

Ordinary schema initialization creates an inert seed; no service startup or
registration occurs during body evaluation. New State materialization reserves
storage and registration before evaluation. A preserved location ignores fresh
initializer seeds. Parent read borrows end before child discovery mutates owner
bookkeeping. Shutdown drains reads and releases staged values before reclaiming
backing. Application tickets may not outlive caller-supplied storage.

## Ownership versus capture capacity

The access contract does not assume one large buffer per model metadata slot.
An empty capture may have zero populated records; model metadata and identity
still have independent lifetime and finite capacity. An occupied capture bank
has one tracked owner or an explicitly specified immutable-sharing policy; this
design selects no COW/sharing shortcut.

[The selected capacity policy](rfc-014-capture-policy-choice.md) reserves one
model-capture bank, separate from source and admission. Two model metadata
records do not imply two populated captures. Reserve backing before construction
or replacement; reads only validate already-reserved backing, never allocate it.
An installed empty analyzer reserves its capture entitlement too. No retained
former model is destroyed to make room, and source/admission bytes are not loaned
to a replacement. Both profiles expose the same configured capacity refusals.
Counter metadata/scalars are accounted independently of analyzer buffers.

## Review gates and disposition

The design answer to SR-Q3 is schema-specific typed read domains plus scoped
facades and checked writes. No further public syntax choice is needed to develop
it. The unresolved engineering gates are explicit:

1. Compile the domain-parameterized View/container/facade contract across actual
   module boundaries under pinned compilers; verify inferred Body and that the
   portable side imports no Runtime module. SPIKE-073 is not that proof.
2. Cover the real source routes above, including compound mutation preflight,
   initializer/replacement effects and typed failures. No complete frontend claim.
3. Prove owner ticket/slot/borrow lifetime and cleanup, especially descriptor
   pointees and nested State discovery, on both profiles.
4. Measure exact metadata/descriptor/dispatch and whole-image costs; apply the
   selected capture-capacity policy through normal RFC/ADR/Spec review.

This contract removes the schema-unaware universal scalar reader from the
recommended production design. It does not introduce a new experiment, upgrade
the toolchain, approve the RFC, or authorize production implementation. The
storage decision was the only maintainer choice requested in this package and
has been answered. Engineering validation must not be relabeled as an additional
product choice.
