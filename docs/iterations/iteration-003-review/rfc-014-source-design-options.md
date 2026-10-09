# RFC-014 source-design options

**2026-10-09 — proposed alternatives, neither selected nor approved.** This is
supporting design analysis for [RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md)
B1/B4, under accepted PROPOSAL-007 and iteration-3 runtime derivation scope.
The [ownership audit](rfc-014-ownership-audit.md) informs B1/B2 independently.
SPIKE-069 is complete; this document runs or authorizes no experiment.

## Recommendation and decision

Prefer **B, explicit scoped reads and snapshot-aware Canvas**, for the next
contract-design pass. It makes the lifetime boundary inspectable in portable
application source and confines hidden transformations to finite binding and
callable lowering. It requires accepting a visible State/Canvas API migration.
This is an author recommendation, not a conclusion proved by SPIKE-069.

Choose **A, checked source-compatible lowering**, if preserving `@State`, direct
model-property reads and ordinary Canvas syntax is worth owning a mandatory
semantic checker/transformer on every supported profile. A is not disproved:
the experiment disproved callback-only restrictions, not checked lowering.
Neither choice proves whole-application feasibility or resolves compiler policy.

The immediate human choice is which source contract to develop, not whether to
approve RFC-014, add a capture buffer or launch an experiment. Exact declarations,
owner capacities and enforcement still need design/review after that direction.

## Reading the examples

A/B below label source-design alternatives, not SPIKE-069's pointer/borrow fixtures.
All code below is **uncompiled proposed application source**. Names such as
`PresentationCapture`, `CaptureSelection`, `CaptureRead`, `ScopedState`,
`WithModel` and `SnapshotCanvas` are candidate names, not existing APIs. Ellipses
are avoided inside the examples; omitted application members are identified in
prose. These are focused replacements for the affected bodies/helpers, not
complete applications or new accepted Specification declarations.

Both candidates retain runtime body evaluation and real semantic traversal.
Finite generated model routes, callable cases and checked helper specializations
are allowed; neither may emit an application topology or replay an expected tree.
Both retain typed Button actions, synchronous model-owned invalidation,
structural State identity, mutation-before-derivation and post-layout Canvas.
Both keep Domain `SignalCapture` as an owned value with its existing semantics.
Neither puts a Runtime import, physical snapshot offset or resolver singleton
in portable Presentation/Domain source.

## A — checked source-compatible lowering

### Analyzer source

The following replaces the root body. Its existing `@State private var
viewModel: SignalAnalyzerViewModel`, initializer and `View` conformance remain.
`presentationCapture` is a new explicit presentation projection, not a change to
the lifetime or meaning of `viewModel.state.capture: SignalCapture`.

```swift
package var body: some View {
    VStack(spacing: 0) {
        SignalAnalyzerHeaderView(
            acquisitionState: viewModel.state.acquisitionState,
            errorMessage: viewModel.state.errorMessage, layout: layout)
        SignalAnalyzerWaveformView(
            capture: viewModel.presentationCapture,
            visibleRange: viewModel.visibleRange,
            selectedWindow: viewModel.state.visibleWindow,
            layout: layout)
    }
    .foregroundStyle(.white)
    .padding(2)
    .background(.black)
}
```

Waveform, channel and trace declarations change their stored `capture` type and
initializer parameter from `SignalCapture` to `PresentationCapture`. This is a
small copyable selection token with no raw-pointer getter outside checked
source. Existing channel-level reads such as `capture.currentLevel(for:)` are
recognized operations whose lowering supplies a live scoped read. The trace
helper keeps ordinary Canvas syntax:

```swift
package func makeSignalAnalyzerTraceCanvas(
    channelID: SignalChannelID,
    capture: PresentationCapture,
    visibleRange: Range<Duration>
) -> some View {
    Canvas { (context, size) throws(DrawingError) in
        try drawSignalAnalyzerTrace(
            context: &context, size: size, channelID: channelID,
            capture: capture, visibleRange: visibleRange)
    }
}
```

`drawSignalAnalyzerTrace` and its starting-level helper become checked capture
consumers. Their source parameter is `PresentationCapture`; generated internal
variants receive a scoped `CaptureRead`. Indexed transition reads produce owned
transition values. A loop may not materialize a borrowed collection into a
stored declaration or capture a read iterator in another escaping closure.
The existing captureless grid Canvas needs only ordinary finite callable lowering.

This preserves familiar framework syntax, **not byte-for-byte analyzer source**:
the presentation projection, stored capture types and drawing helper contracts
change. Domain publication, admission and acquisition still own `SignalCapture`.
No implicit conversion from an owned Domain capture to a borrowed view is allowed.

### Counter source

The proposed complete counter's state host retains `@State private var model:
CounterModel`. Its body reads one bounded integer before constructing owned
children. `counterText` selects one of ten predeclared bounded strings;
`counterStroke` implements the already selected scalar drawing workload.

```swift
var body: some View {
    let value = model.value
    return VStack(spacing: 4) {
        Text("Counter")
        Text(counterText(value))
        Button("Increment", action: CounterAction.increment)
            .disabled(value == 9)
        Button("Reset", action: CounterAction.reset)
            .disabled(value == 0)
        Canvas { (context, size) throws(DrawingError) in
            try counterStroke(context: &context, size: size, value: value)
        }
    }
}
```

Canvas captures the owned integer, not `model`. The action handler still gets
the current typed model through Interaction. Host-driven root replacement
remains a separate mutation operation with exact replacement results.

### Required checked lowering

| Source construct | Required realization and rejection boundary |
| --- | --- |
| `@State` field and direct property reads | Bind by exact structural location before body; lower reads through explicit typed owner context. Check copied wrappers, aliases and helper calls, not merely callback return types. Reject uses whose owner lifetime cannot be established. |
| Presentation capture stored in child declarations | Store only a typed owner/slot/allocation-generation/snapshot identity token and copied metadata. No raw address or 404-record value. Freeze covers token production through staging; no data lookup through an expired owner. |
| Capture read in a helper | Type-directed recognition of a finite helper call graph; generated scoped parameter passed explicitly through each supported call. Reject unknown, separately compiled unchecked, existential, generic-container or escaping uses unless covered by the checked contract. No text substitution or name-only matching. |
| Canvas capture | Capture selection and scalar arguments at declaration. Stage a separately tracked pin under each actual occurrence; the generated callable resolves that same selection and supplies a fresh borrow. Never substitute the current root's capture at invocation. |
| Body/Canvas closures and returned values | Allow independently owned scalars/declarations and safe opaque tokens. Reject a model borrow, borrowed iterator or pointer returned/stored in an escaping container or closure, including storage from a Void callback. |
| Mutation and report routes | Permit mutation only in its phase. Keep model, registration/report and result storage disjoint; preserve the first replacement failure. Reads/Canvas cannot invoke mutation through an alias. |
| Profile assembly | Apply the semantic acceptance rules to Dynamic too. A raw Dynamic build that bypasses the checker is not the supported implementation. Static lowers closures to finite payloads/cases and rejects unlowered fallback before linking. |

A needs a concrete integration plan for type resolution, cross-file helper
coverage, diagnostics, source maps and mandatory build enforcement. The existing
State macro and Canvas lowering requirements do not already provide this proof.
The finite vocabulary must cover both actual applications without growing into
the general application compiler excluded by iteration 3. If it cannot, A needs
a narrowed source contract or a scope decision; silently supporting arbitrary
Swift is not an option.

## B — explicit scoped State reads and snapshot-aware Canvas

### Analyzer source

Use an explicit declaration marker `ScopedState<SignalAnalyzerViewModel>` in
place of `@State var viewModel`. The candidate marker represents initializer
selection and the structural State association, not a dereferenceable model.
The state-host binding witness would recognize this marker before body
traversal. Its exact initialization/ownership-transfer declarations remain to be
designed against the ownership audit; it must not embed a full capture copy.

The root body uses a new view-building primitive. `WithModel` delays its builder
until runtime traversal reaches this bound state host; it passes a nonescapable,
read-only model view. The builder returns an ordinary owned child declaration.

```swift
private let model: ScopedState<SignalAnalyzerViewModel>

package var body: some View {
    let layout = layout
    return WithModel(model) { read in
        VStack(spacing: 0) {
            SignalAnalyzerHeaderView(
                acquisitionState: read.acquisitionState,
                errorMessage: read.errorMessage, layout: layout)
            SignalAnalyzerWaveformView(
                capture: read.captureSelection(),
                visibleRange: read.visibleRange,
                selectedWindow: read.visibleWindow,
                layout: layout)
        }
        .foregroundStyle(.white)
        .padding(2)
        .background(.black)
    }
}
```

`read` is not today's `SignalAnalyzerViewModel` class or a copyable pointer
facade. It has no mutation API. `captureSelection()` returns a copyable opaque
`CaptureSelection` and owned metadata, not `CaptureRead`. Waveform/channel/trace
store that selection. Channel-level baseline/current-level metadata needed by
body should be copied from this same snapshot selection during the root read;
otherwise a separate explicit scoped read is required. A nested child cannot
call a hidden raw-pointer getter on its stored selection.

The trace helper changes to an explicit snapshot-aware Canvas:

```swift
package func makeSignalAnalyzerTraceCanvas(
    channelID: SignalChannelID,
    capture: CaptureSelection,
    visibleRange: Range<Duration>
) -> some View {
    SnapshotCanvas(snapshot: capture) {
        (context, size, read) throws(DrawingError) in
        try drawSignalAnalyzerTrace(
            context: &context, size: size, channelID: channelID,
            capture: read, visibleRange: visibleRange)
    }
}
```

The drawing helper and starting-level helper accept `borrowing CaptureRead`,
whose type itself must enforce non-escape. `borrowing` on an ordinary copyable
pointer struct would not suffice. The callback receives that read only at
post-layout invocation. It can copy transition values into the drawing plan,
but cannot store `read` in a View, field or delayed closure. The callback's own
retained captures are the owned channel/range values; the selection is a
separate framework payload. Ordinary scalar/captureless Canvas remains available.

### Counter source

The same explicit scope works for the counter; there is no analyzer-specific
capture projection or snapshot Canvas:

```swift
private let model: ScopedState<CounterModel>

var body: some View {
    WithModel(model) { read in
        let value = read.value
        return VStack(spacing: 4) {
            Text("Counter")
            Text(counterText(value))
            Button("Increment", action: CounterAction.increment)
                .disabled(value == 9)
            Button("Reset", action: CounterAction.reset)
                .disabled(value == 0)
            Canvas { (context, size) throws(DrawingError) in
                try counterStroke(context: &context, size: size, value: value)
            }
        }
    }
}
```

`counterStroke` emits no stroke for 0; otherwise it draws from (4, 8) to
(4 + 4 × value, 8), width 1, round cap/join. Both source options use the same
finite strings, geometry and actions. Neither uses a different model update or
pixel oracle to make its implementation easier.

### Required API and lowering rules

| Candidate surface | Required meaning / unresolved contract |
| --- | --- |
| `ScopedState<Model>` | A structural declaration marker with no model-returning `wrappedValue`. Specify initializer materialization, ignored subsequent initializers, key copyability, binding failure and exact ownership transfer. Reusing today's escaping State binder unchanged would defeat this design. |
| `WithModel(state, builder)` | A supported traversal primitive with one scoped read per actual evaluation. Returned children are owned and cannot retain the borrow. Specify transparent identity behavior so adding this access scope does not accidentally change state/action paths. Framework resolves the marker, validates capacity/generation and acquires the scope before calling the builder. |
| Model read schema | Typed read-only owned fields and explicit snapshot selection. Define compiler-supported nonescapable declarations and generic builder constraints. The concrete Spike borrow does not prove this generic builder/API is expressible on every target. |
| `CaptureSelection` | A safe opaque identity plus immutable metadata; copying it does not acquire backing ownership. Runtime staging validates it and acquires a counted pin while the source freeze is live. It offers no standalone dereference API. Foreign/stale keys cause a bounded staging failure before invocation, not pointer access or an ordinary getter trap. |
| `SnapshotCanvas(snapshot:, draw:)` | Adds a fresh scoped `CaptureRead` callback parameter, preserving GraphicsContext/Size and typed DrawingError. Static payload owns selection/scalars, callable ID and explicit pin bookkeeping; Dynamic wrapper uses identical logical selection/release points. Exact error mapping belongs in SPEC-010/012 amendments. |
| Callable lowering | Still required for Static: finite WithModel builder/model cases, ordinary Canvas cases and snapshot Canvas cases. Reject reference/borrow captures and all unlowered fallbacks. No automatic zero-heap claim from explicit syntax. |
| Action/replacement access | Retain typed handlers and synchronous reports. Host replacement uses the explicit result-returning owner operation during mutation; State-body callbacks do not return a mutable model or invoke replacement. |

A staged payload can remain Copyable as required by today's Static capture
storage protocol only if copying its data does not duplicate the pin's ownership.
The phase ledger owns each acquisition/release, not a destructor on a copied key.
Every actual Canvas occurrence owns a ledger entry, even when syntactic callable
IDs or selections match. Staging failure, invocation failure, discard and shutdown
must each release exactly the entries they acquired. This obligation applies to A
as well; neither gets RAII ownership merely by calling the key “owned”.

B has a larger visible migration but a narrower implicit transformation: the
source explicitly identifies the read scope and snapshot callback. It still
needs compiler proof for nonescapable read types, ownership proof for backing,
and complete finite callable coverage. Unsupported experimental lifetime
features cannot be hidden behind the new names.

## Comparison and compatibility cost

| Question | A: checked lowering | B: explicit scopes |
| --- | --- | --- |
| What application authors see | Familiar `@State`, direct reads and ordinary Canvas; a new presentation capture type | Explicit state marker, read builder and snapshot Canvas; scalar Canvas unchanged |
| Where model escape is rejected | Mandatory semantic analysis plus generated scoped routes, on every profile | Compiler-enforced read types at explicit boundaries plus finite capture checks; candidate generic API not yet proved |
| Analyzer migration | New projection/types; checked helpers; host ownership repair | New state marker/body scope/projection/types; borrowed helpers; snapshot Canvas; same host ownership repair |
| Counter migration | Implement missing model/host with State and scalar captures | Implement missing model/host with scoped marker and scalar captures |
| Tooling cost | Type-directed cross-file model/capture rewriting and diagnostics | Explicit primitive/builder/Canvas lowering and diagnostics; no inferred borrow across arbitrary helpers |
| Compatibility risk | “Unchanged syntax” can hide new restrictions on previously accepted Swift | Clearly visible API changes; adding a wrapper must preserve intended structural identity |
| Compiler risk | Generated borrow declarations plus checker completeness | Non-escape/generic API expressibility plus ordinary finite lowering |
| Resource claim | Small keys are proposed; checker output, stack, heap and peak storage unmeasured | Same; explicit scopes alone do not establish smaller stack or feasible firmware |

Both must preserve ADR-024 replacement and external ownership, ADR-025 reporting,
ADR-026 profile equivalence and ADR-028 invocation timing. B changes the accepted
State and Canvas source surfaces and therefore needs an explicit compatibility
ADR/amendment assessment, not only edited examples in a Specification. A also
needs that assessment if its accepted source subset adds portable restrictions.
SPEC-001/010/012 define the affected application, State and Canvas contracts;
SPEC-006 covers traversal/identity; SPEC-013/015 cover resource/host obligations.
RFC-013 retains external package/export decisions; these names choose no package
partition. ADR-034's capture count is a separate unresolved architecture choice.

## Review and evidence boundary

Before either candidate can be approved, settle:

1. Exact portable declarations, typed read fields, scope/identity behavior,
   complete analyzer helper migration and counter model/host ownership.
2. Compiler policy for lifetime features and supported diagnostic behavior;
   SPIKE-069's unsupported-`@lifetime` warning remains unresolved.
3. Every model/state/capture escape route, including copied State, outer storage
   from Void callbacks, nested helpers, generic returns, container storage,
   cross-module functions and delayed closures. For B, prove rejection of
   `SnapshotCanvas` closing over the outer `read` instead of using its fresh one.
4. Actual traversal-to-Layout-to-Canvas cleanup, repeated occurrences, zero
   Canvas, replacement attach/derivation failure, stale selection and shutdown.
   Compare the same Dynamic and Static observable results, not two flag builds
   of a shared lifetime simulator.
5. The ownership ledger and peak retained bound from the audit, complete payload
   codecs/capacities and final four-profile resource evidence. The independent
   4 MHz performance failure remains unchanged.

No further general feasibility study is recommended before selecting the source
direction. If a language/tooling feasibility question then needs experimental
evidence, propose one bounded Spike tied to the chosen exact API and its reject
cases. Record its question, inputs and invocation/repair/time limits and obtain
specific authorization; unused SPIKE-069 budget cannot fund it. A successful API
probe would still not authorize production migration or approve RFC-014.
