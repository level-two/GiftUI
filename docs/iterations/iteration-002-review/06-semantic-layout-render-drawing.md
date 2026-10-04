# Step 06 — Semantic, Text, Layout, Drawing, and Render Owners

Source baseline: `6cf31f26`. Governing contracts: SPEC-005/006/007/008/012,
ADR-005/009/021/023/028/029/030/031/032.
This is a responsibility, interface, and failure-path source review. The
consolidated hardware-free gate supplies behavioral/profile evidence separately.

| Owner | Inspected source seams | Assessment |
| --- | --- | --- |
| GiftUISemanticCore | Expansion attempt/traversal, stateful binding, recording sink, SemanticLayoutView/RenderView | Owns declaration expansion/structural identity and exposes narrow consumer projections. Bounded depth/path/identity/event counters and first-failure handling discard/reset acquired workspace/sink. Binding failures stay distinct from semantic failures. |
| GiftUITextResources | Metrics/raster contracts, validation, payload borrow, resource digest | Canonical metrics and packaged raster bytes share exact resource identity. Payload callbacks validate dimensions/counts and contents without handing Layout concrete raster ownership. Raw buffer lifetime remains provider/caller responsibility. |
| GiftUIReferenceTextResources | Catalogue-backed metrics/raster views, reference and Pi compact packages, generated manifests | Concrete immutable resource owner. Payload-subset compile guards preserve catalogue identity while omitting unavailable bytes; generated resources are not the analyzer hierarchy candidate. |
| GiftUILayout | Layout entry, semantic validation, Engine text/stack/modifier paths, publication, resolved render projection | Validates before measure/place, resets workspace on failure, stages sink output and discards incomplete publication. SemanticCore owns layout input (ADR-032); Layout owns placement and canonical glyph positions. |
| GiftUIRenderCore | Render/drawing operation values, sink contracts and recording sink | Backend-neutral normalized operation grammar and bounded sink surface. Does not own semantic traversal or physical presentation. |
| GiftUIRenderLowering | Preflight, Producer, Streaming, extension contracts | Traverses narrow semantic/resolved-layout views; validates snapshot versions, counts, sink capacity and shape before streaming. Post-begin failures discard, successful finish verifies actual versus preflight counts. |
| GiftUIDrawing | CanvasPlanProducer, LivePathBuilder, StrokeSnapshotProducer, CanvasRenderProducer and callable-table contracts | Canvas executes after Layout, snapshots paths into a bounded cycle plan, releases each callable on success/failure, and contributes strokes through render extensions without moving the lower traversal into Drawing. |

## Lifetime and failure observations

`GraphicsContext`/`Path` are noncopyable scope wrappers over explicit backing
storage. LivePathBuilder rejects inactive use and preflights point/subpath
demand; StrokeSnapshotProducer validates ranges and checked aggregate demands
before writing a plan. The path is temporary, the plan owns a snapshot, and the
render operation borrows plan data during synchronous submission. These are
three different lifetimes, not three interchangeable copies of one model.
Compiler borrow-negative tests and runtime stale-scope tests matter alongside
the wrappers; noncopyability alone does not validate arbitrary raw memory.

CanvasPlanProducer validates occurrence identity/order before invocation and
releases remaining identities on failure, avoiding duplicate release for a
malformed repeated identity. The enclosing runtime also owns rollback after a
failed derivation. Retiring the callable table merely because the Dynamic
declaration retains a closure would remove the Static realization's bound.

Layout's preflight checks configured workspace limits; publication stages
scope/line/glyph records before exposing a result and discards on an inconsistent
write. Render preflight and streaming compare semantic/layout versions and exact
operation/glyph counts. Sink refusal before beginning differs from an invariant
failure after accepted begin. Collapsing these mappings can change containment
and retry behavior.

## Simplification decisions

No additional confirmed defect was established in these inspected joins.
Recording sinks and storage wrappers are useful test/projection seams; forwarding
methods alone are insufficient evidence for a breaking removal. Native and
packed workspaces realize the same algorithm with different storage/resource
costs. CBR-003 remains the concrete duplicate-algorithm candidate, in startup
probes, not in the current common production Layout join.

`Canvas.swift` has three Dynamic-profile guards separating retained closure
execution from Static callable specialization. Removing them needs an alternative
Static representation with the same heap/bounds guarantee; it is not a cosmetic
source-selection edit. Reference font guards select bitmap/outline availability
and reject contradictory configuration. Retain their guarantees when considering
file-level source selection. Step 09 records the complete guard classification.

The review covers owner contracts, acquisition/publication/rollback joins, and
representative internal algorithms. It does not claim every possible malformed
provider or every branch of the large LayoutEngine was manually proved; registered
corpora/negative tests and their profile results remain necessary evidence.
