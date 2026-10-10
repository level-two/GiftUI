# RFC-014 C: Canvas and versioned-property contract draft

**2026-10-10 — proposed contract for RFC review; not an approved Specification.**
Parent: [RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md).
Direction: [C1–C6](rfc-014-decision-direction.md). Baseline: `d2c4be83`.
Eugene authorized this detailed design step after recording that direction.
No compiler experiment or production change is part of this step.
The [application storage ledger](rfc-014-c-storage-ledger.md) supplies concrete
K=2/F=1 capacities, replacement traces and the proposed five-bank analyzer cost.

The feature remains at RFC stage under accepted PROPOSAL-007. Post-MVP
iteration 3 requires real analyzer/counter traversal on all four configurations.
Accepted ADRs and implemented Specs remain authoritative. “Requires” below
specifies the candidate being reviewed, not a new production requirement.

## Subsequent proof boundary — SPIKE-070 and SPIKE-071

[SPIKE-070](../../spikes/spike-070-protocol-canvas-versioned-access.md) ended
inconclusive after its Embedded assertion failure. The separately authorized
[SPIKE-071](../../spikes/spike-071-canvas-embedded-escape-continuation.md) fixes
that fixture issue and completes four-profile positive compilation, 24 intended
compiler-negative controls and bounded nRF object inspection. Both native runs
pass 21 checks; no allocator relocations remain in the rooted nRF fixture.
See [results and limits](../../../experiments/spike-071-canvas-embedded-escape-continuation/evidence/result.md).

This supports the finite context/Canvas mechanism under the tested experimental
lifetime flags. The root still becomes a throwing descriptor without View
conformance, and Canvas's target draw receives FrameRead. Complete production
binding, current-write/helper coverage, actual State/owner integration, compiler
adoption and full-image resources remain B1/B4 and C-P3 obligations. The numbered
controls below are not all a passed suite: painter order, mid-list failure and
full replacement/materialization/teardown remain unproved.

Earlier “not authorized” statements describe the original design step. Both
subsequent Spikes are now terminal, with no additional experiment allowance.

## Contextual evaluation follow-up

The [production evaluation/binding design](rfc-014-contextual-evaluation.md)
refines §§2–4: the compiled View contract needs contextual witnesses and typed
failure transport; source `body` syntax is a finite-lowering input, not an
unchanged context-free runtime getter. A frame lease pins frozen storage while
short body/draw read borrows end before nested State binding. The design also
covers short-circuit effects, current-write routes, the Drawing access argument
and explicit compiler-policy/authority implications. It is uncompiled draft
design; SPIKE-071 does not validate this larger integration.

## Design commitments in this draft

- Keep one serialized mutation domain. External producers submit immutable
  bounded facts; they never write current or frozen model banks directly.
- Store model data in stable typed owner storage. `@State` associates a model
  with a structural location; proposed `@Published` fields describe versioned
  property storage within that model. These are different identities.
- Use an explicit copy-freeze baseline: current remains the authoritative
  writable bank, and a separate frame bank receives a complete frozen copy.
  Do not swap banks or copy frozen state back after drawing.
- Keep model/data identities in transient View and Canvas values. Resolve
  reads through a runtime-supplied context passed to generated evaluation and
  drawing entrypoints; no stored raw owner pointer, global or task-local lookup.
- Make Canvas a protocol leaf. Stage each concrete value, then invoke its draw
  method after Layout. The frame owns frozen backing; individual canvases do
  not acquire independent historical snapshots.

The main remaining feasibility question is explicit: ordinary `model.property`
syntax has no context parameter in Swift. This draft proposes finite generated
access routes with a hidden context argument, not a property wrapper that
magically finds the runtime. Its production realization remains unbuilt/unproved; SPIKE-070 tests only a finite disposable subset. It is narrower
than arbitrary closure-capture analysis but is still a source-tooling obligation.

## 1. Public authoring surface

The proposed Canvas declaration is:

```swift
public protocol Canvas: View, _GiftUISemanticPrimitivePayload
where Body == Never {
    func draw(
        in bounds: Rect,
        context: inout GraphicsContext
    ) throws(DrawingError)
}
```

The existing public bridge marker is inherited to permit `visitPrimitive(self)`.
The initial proposal supplied `body: Never` to satisfy today's View getter.
The subsequent [contextual evaluation design](rfc-014-contextual-evaluation.md)
replaces that compiled getter requirement: retain the leaf category/Body marker
and generated primitive/draw witnesses, without a fake body getter to make
contextual dispatch work. Normal traversal visits one leaf without evaluating
body or calling draw. Concrete Canvas authors need neither a body nor
user-written traversal. Bounds are local `(0, 0, width, height)` with checked
nonnegative resolved dimensions; parent translation and clip remain framework
responsibilities. This preserves today's local-size semantics without exposing
backend or absolute device coordinates. Synchronous `GraphicsContext.withPath`
closures remain supported; this change removes the retained drawing closure,
not every closure in drawing source.

A proposed model-schema macro, provisionally `@ObservableModel`, recognizes
`@Published` fields, emits finite property identities and current/frozen access
routes, and provides the existing observation attachment/report behavior.
The name does not imply Combine publishers. Portable authoring can retain a
class-shaped model schema; a Static image uses its generated typed model identity
and stores, not an ordinary heap-allocated class. Exact macro/compiler declarations
and the class-to-identity realization require C-P1 evidence below.

A scalar counter example illustrates the complete affected source shape:

```swift
@ObservableModel
final class CounterModel {
    @Published var value: UInt8 = 0
}

@ObservableStateHost
struct CounterScreen: View {
    @State var model: CounterModel

    var body: some View {
        VStack(spacing: 4) {
            Text("Counter")
            Text(counterText(model.value))
            Button("Increment", action: CounterAction.increment)
                .disabled(model.value == 9)
            Button("Reset", action: CounterAction.reset)
                .disabled(model.value == 0)
            CounterCanvas(model: model)
        }
    }
}

struct CounterCanvas: Canvas {
    let model: CounterModel

    func draw(
        in bounds: Rect,
        context: inout GraphicsContext
    ) throws(DrawingError) {
        try counterStroke(
            context: &context, size: bounds.size, value: model.value)
    }
}
```

These are **uncompiled authoring examples**, not drop-in Swift definitions.
`counterText` selects the ten bounded digit strings. `counterStroke` emits no
stroke at zero; otherwise it emits the selected (4,8) → (4+4×value,8), width-one,
round-cap/round-join stroke. Increment/Reset handlers remain the existing typed
interaction concept; host-driven replacement is not a third button. Model
initialization/materialization is specified below, not invented by this example.

The analyzer's two draw sites become `SignalAnalyzerGridCanvas` (no model field)
and `SignalAnalyzerTraceCanvas` (model identity plus channel and range scalars).
The trace method reads the frozen presentation capture through that identity:

```swift
struct SignalAnalyzerTraceCanvas: Canvas {
    let model: SignalAnalyzerViewModel
    let channelID: SignalChannelID
    let visibleRange: Range<Duration>

    func draw(
        in bounds: Rect,
        context: inout GraphicsContext
    ) throws(DrawingError) {
        try drawSignalAnalyzerTrace(
            context: &context, size: bounds.size, channelID: channelID,
            capture: model.presentationCapture, visibleRange: visibleRange)
    }
}
```

Root, waveform, channel and trace declarations pass the same bound model
identity instead of stored 404-record `SignalCapture` values. Header/window/level
reads use the frame revision too. The trace and starting-level helpers accept a
new `SignalPresentationCapture` schema value with frozen metadata and indexed
transition reads. Its lowered stored form is a safe identity, not a pointer.
The draw helper's indexed reads receive the same generated context as draw.

Domain `SignalCapture` remains an owned, Equatable/Sendable snapshot. Acquisition
and fact application explicitly copy its values into current presentation storage
or apply accepted bounded mutations there. There is no implicit reinterpretation
of Domain values as borrowed capture views. Existing captureless grid geometry,
trace geometry, channel labels and six analyzer actions stay unchanged.

## 2. Exact access contract and generated boundary

The owner supplies these logical identifiers; they are not memory addresses:

| Value | Components / role |
| --- | --- |
| Model identity | owner-incarnation ID, typed pool slot, allocation generation |
| Property identity | finite schema-local field ordinal; independent of View path |
| State association | complete structural identity + State declaration ordinal → model identity |
| Observation target | registration generation; changes on replacement/detachment, independently of model allocation |
| Frozen model reference | model identity + frame epoch; stored only in frame-bound declarations/payloads |
| Read context | a live owner borrow, frame epoch and typed frozen-bank map; never stored in the graph or a Canvas field |
| Mutation context | a live owner borrow plus mutation capability; separate model, report and coordinator-result regions |

Never wrap allocation, owner-incarnation, registration or frame generations.
Exhaustion is a bounded failure before reuse, not aliasing with an old key.
The assembled owner is passed first; compare its incarnation with the key before
looking up the slot. A stale integer key cannot cause dereference of dead backing.
No global mapping from owner IDs to pointers is introduced.

The required internal operation signatures are expressed below in contract
notation; they are not a claim about final Swift generic syntax:

```text
readCurrent<T>(MutationContext, ModelID<T>, PropertyID<T,V>) -> V or AccessFailure
writeCurrent<T>(MutationContext, ModelID<T>, PropertyID<T,V>, V) -> WriteOutcome
readFrozen<T>(FrameReadContext, FrozenModelID<T>, PropertyID<T,V>) -> V or AccessFailure
readFrozenElement<T>(FrameReadContext, FrozenModelID<T>, PropertyID<T,C>, index)
    -> owned element / absent / AccessFailure
```

Scalar reads return owned values. Large presentation collections use explicit
indexed operations that return one owned element; their entire contents never
become an inline Canvas field or body temporary by implicit getter copying.
An owned Domain snapshot export, when requested by a supported host operation,
is an explicit bounded copy with separately charged output lifetime.

Finite access lowering performs the following exact jobs:

1. Before evaluating a state host, bind its State association and convert its
   model references to `(ModelID, frameEpoch)` for that frame. Repeated aliases
   retain the same model identity and epoch, not a new owner or registration.
2. Rewrite known schema property reads in body, draw and their finite typed
   helper graph to `readFrozen`/`readFrozenElement` with an explicit generated
   context parameter. Mutation handlers use current routes. A model reference
   does not switch banks by reading an owner-wide mutable “current phase” flag.
3. Thread the context through computed accessors and the analyzer's capture
   helpers. A helper that uses model properties must have a generated contextual
   entrypoint; separately compiled unchecked getters, arbitrary existential
   calls and unknown generic access paths fail the supported build. Pure helpers
   operating only on owned scalar values need no transformation.
4. Propagate internal access failure out of the generated evaluation attempt,
   without fabricating a getter result. Public nonthrowing `body` syntax must
   not force a zero/default return, ignored error latch or trap on ordinary
   capacity/staleness failure. In draw, map the failure to typed DrawingError.
   The exact compiler transformation of this failure path is part of C-P1.
5. Reject unlowered production property-access and Canvas entrypoints before
   linking. Apply the same semantic rules to Dynamic and Static. No raw Dynamic
   build may bypass required context selection and serve as a parity oracle.

The public GraphicsContext remains a drawing capability, not a model resolver.
The generated invocation adapter receives two separate arguments: frozen-model
read access and the scoped graphics context. Drawing/Core supplies its existing
invocation seam; target composition supplies the concrete typed model adapter.

| Module boundary | Proposed responsibility |
| --- | --- |
| GiftUI / host-only tooling | Canvas/property authoring declarations, primitive witnesses, safe identity/access interface shapes and finite source transformation; no concrete Runtime storage import |
| Application Presentation/schema | Typed model/property descriptors and contextual body/draw/helper entrypoints; no backend or Runtime dependency |
| Observable State | Structural association, registration, model-value revisions and local access failures |
| Runtime/target composition | Concrete typed banks, frame/mutation capabilities, owner lifetime and application-specific adapters; pass these explicitly to generated entrypoints |
| Drawing/Layout/Render | Existing geometry, ordering and owned plan contracts; no application model or owner resolver in a backend |

Exact generic access-interface declarations and compiler-visible target boundaries
are part of C-P1. A hidden dependency from GiftUI/Drawing into Runtime or an
existential model registry is not an acceptable implementation shortcut.

This is a finite model/schema/callable binding proposal, not a general Swift
compiler. The emitted traversal still evaluates actual source branches at
runtime. If the two real applications cannot fit that finite boundary, record
that failure before growing the tooling scope or introducing a different API.
The protocol alone does not remove this risk.

Escaping a **key value** is memory-safe by itself: it cannot read data without a
live matching context. A retained frame key used in another frame rejects its
epoch; it never silently resolves the newest model. The actual context must be
nonescapable or mechanically confined to generated synchronous calls. Copyable
closures storing a raw context pointer are specifically excluded by SPIKE-069.
GraphicsContext, Path and internal owner/read borrows remain invocation-scoped;
no protocol conformance by itself proves that confinement.

## 3. Mutation, freeze and initialization

| Phase | Current bank | Frozen bank | Permitted observations / transition |
| --- | --- | --- | --- |
| Construct/idle | Initializers or existing committed model values | Invalid; no retained frame revision | Construct inert typed seeds/owners; no body/draw |
| Mutating | Reads and checked writes allowed; report dirtiness synchronously | Invalid and unborrowed | Apply sealed facts/actions, perform replacement, consume first mutation failure |
| Preparing freeze | No user writes; coordinator has exclusive access | Copy all participating fields and nested backing into staging | Reserve complete bounded frame capacity first; no application callback sees partial copies |
| Deriving/layout/drawing | Stable; neither direct application nor external-producer writes allowed | Immutable, tagged with frame epoch | Body/helper/draw reads use only matching frozen map; source facts may enter separate admission |
| Finalizing | Still no interleaved mutation | Release staged values/read scopes on success or failure, then invalidate frame map | Publish/discard through existing owner order; no frame borrow survives teardown |
| Next mutation | Reuse current as last mutated value, including failed-frame changes | Invalid/free | Never replay mutation or copy old frozen values back |

Freeze is an atomic visibility boundary, not necessarily an atomic machine
copy instruction. The single serialized owner copies fields in finite order,
then marks the complete map ready. A failure before readiness discards partial
frozen data, leaves current unchanged and dirty, and never invokes body/draw.
Even unchanged fields are copied in the baseline, avoiding stale-bank values.
Nested mutable backing must be copied or independently proven immutable for the
whole freeze. Copying only a class/array pointer is not a deep-freeze proof.

At a newly encountered State location, an inert typed initializer seed may be
materialized during traversal as required by ADR-024. This is initialization,
not arbitrary application mutation during freeze. Reserve its model/registration
and frozen slot before its body, attach as a staged association, and initialize
both versions from that one seed under the same frame epoch. Existing current
values cannot change meanwhile. A known association ignores the new seed without
allocating another live model. Fact/action dispatch and observation startup are
forbidden during initializer materialization.

If the candidate later fails, discard its newly created associations and frame
versions, releasing only models with no independent application owner. Preserve
the previously published live set. New bindings still consume declared capacity;
initialization is not a bypass around the freeze's model bound. Changes in
structural paths may temporarily need old and new model slots until publication.
The selected applications' stable single root is not a proof for arbitrary trees.

No property-level dependency graph is introduced. A changed current property
reports coarse model dirtiness before mutation returns; no-op omission requires
proven equality. Compound field/collection changes use finite checked mutation
operations; do not expose raw mutable storage or unconstrained `_modify` yields.
Each successful changed property operation advances a bounded model-value
revision and reports dirtiness; reserve the revision before changing data and
refuse exhaustion without wrapping. This revision is distinct from allocation,
registration and frame generations. It adds a proposed model-value-generation
exhaustion outcome to the Spec error mapping. The frame records the revision
whose complete values it copied. Dirty clearing follows existing
semantic publication rules, not Canvas success or physical display acceptance.

## 4. Canvas staging and release

Each actual occurrence stores exact structural identity, concrete Canvas type
ID, bounded typed value and frame epoch. Repeated instances of one conformer
have separate occurrence records, although code/type IDs are shared. Static
uses a finite union/table whose capacity is the largest case plus bookkeeping;
it must not allocate existential boxes. Dynamic uses its corresponding bounded
owner and the same occurrence/lifetime semantics.

Before staging succeeds, validate every generated model field against the live
frame map and its ownership association. Later invocation validates occurrence
identity, frame epoch and layout bounds before calling application code. Resolve
the exact bound ModelID, never the host's current-root route. No Canvas acquires
ownership of an application model simply by copying its identity.

A frame lease pins all backing needed by its readers. Zero Canvas still requires
body/layout lifetime coverage; multiple Canvas values share that frame lease.
Release each staged value after invocation or discard and destroy all remaining
values on failure. Only after the final frame reader ends can frozen storage be
reused. A draw failure releases the failing and all not-yet-invoked values; no
previous successful Canvas is reinvoked to repair or preflight the attempt.
Drawing plans own copied geometry and never contain model keys or read contexts.

## 5. Replacement, removal and errors

Replacement occurs only during mutation, with no live frozen readers. Reserve
candidate current storage and registration first; attach, then commit the new
association and retire the former registration. Retarget status/acquisition/
failure routes at that association commit, even if later graph/draw work fails.
Application ownership of the old model survives detachment until explicitly
released. Registration staleness does not invalidate such an owner's allocation.

Publish removal only with the complete semantic revision. Discarded candidates
do not remove previously published state. Teardown cancels/drains admission and
frame work, releases all staged values/borrows, detaches registration, and releases
backing only after its actual owners end. A host may not destroy caller-supplied
Static storage while an owning ticket still requires it; the owning-scope API
must enforce that obligation. Safe keys alone do not solve owning-ticket lifetime.

| Condition | Proposed bounded outcome / required behavior |
| --- | --- |
| No model slot during application-owned construction | Proposed `modelStorageCapacityExhausted`; no live identity/ticket published |
| No model slot for replacement | Existing `replacementStagingCapacityExhausted`; preserve old association and first failure |
| Initial association / registration full | Existing location/association/registration capacity outcomes at the matching owner; skip affected body |
| Frozen model/property backing full | Proposed `frozenStorageCapacityExhausted` in the observable owner; abort before the affected body, release frame staging, keep current dirty |
| Frame epoch exhausted | Proposed `frameGenerationExhausted`; refuse new freeze without reuse |
| Foreign/stale model or frame key | Proposed contextual `staleModelAccess` or `staleFrameAccess`; abort evaluation; Canvas mapping is `.invalidScope` |
| Write while frozen | Reject before the write as contained invalid phase; no frozen/current change. A detected uncontained write is safety-not-proven, never ordinary successful invalidation |
| Drawing failure | Existing typed DrawingError mapping; discard incomplete drawing attempt and release frame values |
| Later derivation failure after replacement | Keep new model association and dirty state; no rollback/replay |
| Source admission full | Existing admission outcome; never mutate current directly as fallback |
| Unsupported reference, unchecked getter or unbounded Canvas payload | Build-time diagnostic; no runtime allocation fallback |

New error names are draft contract additions, not enum cases already present.
SPEC-010 must assign stable local codes and SPEC-003/009/013 adapters must define
origin/disposition mapping before implementation. Access failure transport is a
mandatory positive/negative compiler control, not permission to trap getters.

## 6. Decision and evidence disposition

This draft settles the candidate's version selection, copy direction, invocation,
initialization, replacement and failure semantics. It does not prove the source
mechanism, exact ABI or resource feasibility. Required focused proof questions:

- **C-P1:** Can finite model-schema/getter/helper lowering realize the above
  source and typed failure paths on all four configurations without a global
  resolver, escaping context or unbounded machinery? Include actual body and
  protocol Canvas witness selection, not only an isolated method declaration.
- **C-P2:** Can the owner, scoped contexts and finite typed Canvas payloads compile
  with supported lifetime policy, zero forbidden Static allocation and correct
  exclusivity? Negative controls include returned/stored context, nested-helper
  escape, stale frame key, wrong owner, getter outside context and frozen write.
- **C-P3:** Can both application owner sequences fit the declared model/frozen
  capacities and preserve replacement/retention/failure equivalence? Prove peak
  storage and full supported-image costs separately from arithmetic.

No proof run is authorized here. SPIKE-069's pointer counterexamples remain
applicable warnings; its positive borrow fixture does not validate this source
contract. A future bounded proof must use these exact interfaces and cases;
if context injection exceeds finite binding scope, report the incompatibility
rather than silently turning C into A or substituting explicit read APIs.

## 7. Contract controls for the next proof

These are required future observations, not tests executed by this design task.

| Control | Required observation |
| --- | --- |
| Two fields changed before freeze | Body and draw see the same final pair and model-value revision, even when property read order differs |
| Next frame with only one field changed | The other field retains its latest value; no stale-bank swap or copy-back |
| Current write attempted during body/draw | Rejected before any write; incoming source event is admitted separately and appears only after its later mutation phase |
| Saved frame key used in the next frame or another owner | Bounded stale/foreign-context failure before access; no lookup of the newest model |
| Generated getter/helper without a context | Build diagnostic; no unlowered fallback, global lookup or nominal default-valued getter |
| Access failure inside nonthrowing body source | Generated attempt propagates exact failure, discards candidate and never draws/offers incomplete output |
| Multiple instances of the same Canvas conformer | Distinct occurrence values and order; one shared frozen model version; no body evaluation or draw during Layout |
| New State encountered after initial freeze | Both versions initialized from one seed before its body; a known State ignores replacement seeds; failed candidate preserves published associations |
| Retained former model and another replacement request | Installed and former stay valid; first-excess reservation fails without overwrite; release permits fresh-generation reuse |
| Failure after replacement / halfway through Canvas list | New association remains; dirty survives; all pending payloads/context borrows released once; no mutation replay |
| Teardown with stale key vs owning ticket | A key alone cannot access freed storage; an owning ticket prevents premature destruction of its backing |

First proposed experiment: C-P1/C-P2 source/context feasibility only, with the
counter model, one analyzer capture-reader/helper and concrete protocol Canvas
staging/invocation under a disposable adapter. Include actual GiftUI declaration
sources where compatible and identify every draft replacement. Manual generated
code alone can test calling/lifetime feasibility but cannot prove source lowering;
that claim needs a reproducible finite transformation and unsupported-use checks.

Proposed ceiling: **90 active minutes, 48 compiler/link/executable invocations,
two repair rounds, one candidate**, all hardware-free on macOS Dynamic/Static,
Pi ARMv6 Dynamic and nRF Embedded Static. Freeze the positive/negative call matrix
and exact compiler versions before execution. Source/property context coverage,
typed failure propagation and negative escape controls are mandatory; no broad
performance campaign or production migration is included. Stop on an unavoidable
contract/scope contradiction or the first exhausted limit and report supported,
incompatible or inconclusive. No automatic successor or renewed budget.

This is a reviewable proposed recipe, not launch authorization or a new Spike
record. If authorized, register the bounded Spike under RFC-014 before writing
or running experimental code. Keep C-P3 application/complete-image proof distinct;
a successful small compiler probe cannot close B0/B2/B3/B4.
