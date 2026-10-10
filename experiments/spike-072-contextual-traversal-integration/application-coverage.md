# Application source coverage — SPIKE-072

**The tested finite transformer does not cover either complete application.**
This is a source inventory at the recorded revision, not proof of a complete
transitive effect analysis. [Input hashes and symbol/route locations](evidence/application-inventory.json)
make the observations reproducible. No application source was migrated.

## What the experiment covers

Two scalar fields; two State hosts; one root `if` with `>` and `&&`; a known
read helper; one three-child HStack; model-key/scalar Canvas captures; checked
scalar drawing reads. The emitter preserves short-circuit execution with
conditional statements. Generated concrete Body aliases follow the source AST;
no occurrence identities or expanded graph records are generated. Six negative
source samples reject unsupported syntax/helper/property/initializer forms.

The model ABI is deliberately fixed to two UInt32 fields with 0/7 defaults.
The runtime's seed parameter is a fixture binding input, not proof of general
Swift initializer or macro semantics. All bodies/helpers must fit the finite
parser; no general Swift parsing, type checking or effect analysis is claimed.
Ordinary compiler type checking still validates emitted Swift. Unsupported source
must fail the supported build rather than fall through to a raw body getter.

## Counter

Sources: the finite counter requirement and candidate example in
[RFC-014 C contract](../../docs/iterations/iteration-003-review/rfc-014-c-contract.md#1-public-authoring-surface),
and [SPIKE-014's earlier portable counter](../spike-014-external-consumer-access/PortableCounter.swift).
The latter accepts owned text/disabled values; it is not an existing complete
versioned observable counter implementation. Do not invent a production counter
model or host as coverage evidence.

| Route | Effect / migration requirement | SPIKE-072 status |
| --- | --- | --- |
| State model initialization; `model.value` | Bind by structural identity/ordinal, UInt8 0–9 schema, frozen read | UInt32 scalar/key mechanism tested; UInt8 schema and real State owner missing |
| `counterText(value)`; `Text` | Pure bounded digit selection; Text builder output | Not in this grammar; SPIKE-071's different fixture does not make this build cover it |
| Increment/Reset Buttons and `.disabled(value == 9/0)` | Frozen predicate; owned typed action payload and modifiers | Equality, Buttons, modifiers and their Body shape inference not lowered here |
| CounterCanvas → `counterStroke` | Frozen read followed by owned scalar geometry; skip zero | Generic scoped draw path tested; specified zero/nonzero geometry helper not migrated |
| Increment / Reset handlers | Current read, checked bounded write, no-op rule, synchronous coarse report | Not generated or executed; handwritten frozen-phase rejection is not a setter proof |
| Host replacement / retained former owner | Independent owner, registration, frame lifetime and first-excess refusal | C-P3 remains open; two scalar entry slots are not owner tickets |

## Analyzer frozen reads and helpers

The current model stores `SignalAnalyzerViewState` and `captureRevision` in
`SignalAnalyzerPresentationValues.swift`. It has no production `@Published`
implementation. Replacing that storage remains a candidate contract change.

| Source route | Required frozen/owned boundary | Missing from the tested grammar |
| --- | --- | --- |
| `SignalAnalyzerView.body`: `viewModel.state.acquisitionState`, `.errorMessage`, `.capture`, `.visibleWindow`, `viewModel.visibleRange` | Read one coherent version; copy small values; retain capture identity rather than copy all transitions | Nested aggregate property paths, enum/optional/diagnostic types, Range/Duration, computed getter effects |
| `visibleRange`: visible-window duration plus capture duration | Both inputs from the same frozen model; owned range result | Transitive computed reads; min/max/duration arithmetic |
| `SignalAnalyzerHeaderView`, `SignalAnalyzerControlState` | Pure owned acquisition/window inputs; enum switches and ternary selections | Plain custom-view body lowering, local lets, switches, ternary expressions, modifiers and actions |
| Error text `errorMessage?.boundedText ?? ...` | Preserve optional/default evaluation and conversion errors | Optional chaining/default expressions; bounded text helper handling |
| `SignalAnalyzerWaveformView` → channel children | Pass channel/range scalars plus capture identity | Complete nested view builder graph and concrete Body type derivation |
| `SignalCapture.currentLevel(for:)` | Frozen baseline plus bounded indexed transition reads | Collection iteration, channel filtering and helper effect propagation |
| `SignalAnalyzerRulerLabels` → formattedSeconds → TimelineFormatting.seconds / withUTF8 | Pure owned range arithmetic and bounded formatting | Overflow branches, tuple storage, synchronous byte callback coverage |
| `makeSignalAnalyzerGridCanvas` / `drawSignalAnalyzerGrid` | Pure geometry inside scoped GraphicsContext | Protocol-Canvas migration of old closure factory; bounded loop and path operations |
| `makeSignalAnalyzerTraceCanvas` / `drawSignalAnalyzerTrace` | Frozen capture identity + owned channel/range; read transition records at draw time | Safe indexed capture API, channel/time filtered loops, effect forwarding through withPath |
| WaveformGeometry.startingLevel / tracePointCount | Baseline and transition reads share the same frozen capture | Bounded iteration and `&&` filters with multiple conditional indexed reads |
| WaveformGeometry.x/y/milliseconds | Pure owned scalar arithmetic, branches, enum switch and overflow rules | Pure-helper whitelist and complete type/effect inventory |

The domain's owned `SignalCapture`, capture publication/replay and acquisition
interfaces retain their current meaning. This experiment does not authorize
turning a domain value into a borrowed capture or changing publication lifetime.

## Analyzer current mutation and reporting

| Current route | Obligation before frontend coverage can be claimed |
| --- | --- |
| `startTapped` | Clear diagnostic and report before acquisition; route each failure into owned diagnostic/current mutation. Existing untyped/existential error catches are not automatically acceptable in Embedded generated code. |
| `stopTapped`, `clearTapped` | Keep use-case side effects outside frozen body/draw; later admitted facts update model in the mutation phase. |
| `visibleDurationChanged` | Current equality check, checked write and synchronous report; specify no-op behavior. |
| `apply`: snapshot/mutation capture facts | Replay/validate captureRevision and capture together; capacity preflight and batch meaning must be explicit. Existing `previousState = state` whole-state copy is not evidence of a bounded versioned realization. |
| `apply`: acquisition-state / operational-failure facts | Ordered multi-property update of state/diagnostic; preserve change detection and coarse report. |
| attach/detach/reportChange | Checked lifetime/generation, synchronous reporting; disjoint storage/coordinator borrows and report refusal handling. No publisher/latch shortcut. |
| State replacement / owner failure adapters | Preserve independent ownership, failed candidate cleanup, committed registration, dirty state and failure-effect ordering. |

The source inventory also includes StaticSignalAnalyzerNRFModelLocation and
ModelCaptureState: activation/retirement, mutation phase, diagnostic/acquisition
setters, capture snapshot/mutation, visible-range/current-level helpers and dirty
reporting. These handwritten paths use target storage/generation rules and, in
some setters, rollback after report refusal. They cannot be treated as generated
current setters or silently substituted for the proposed preflight/batch semantics.
DynamicSignalAnalyzerPiInitialPresentationOwner is recorded as the composition
boundary, not recursively audited in full by this inventory.

## Disposition

B4 stays open with concrete missing source families. The next frontend design
work can define the finite supported source/effect grammar and a complete pair
of candidate application sources; do not grow a general compiler by trial and
error or claim completeness from these small scalar fixtures. C-P3 ownership and
five-bank accounting remain separate. Required gaps stay in RFC-014, not FW-035.
