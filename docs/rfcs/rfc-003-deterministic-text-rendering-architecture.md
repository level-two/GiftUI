---
id: RFC-003
feature: giftui-mvp-architecture
title: Deterministic Text Rendering Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-15
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-001
  - RFC-002
related_adrs: []
related_specs: []
related_future_work:
  - FW-001
  - FW-002
  - FW-003
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# RFC-003: Deterministic Text Rendering Architecture

## Summary

This RFC proposes that GiftUI own font resolution, canonical font metrics,
MVP shaping, line breaking, measurement, and glyph positioning above the
backend-neutral render-plan boundary. Layout lowers text to positioned glyph
runs. The ordered render-operation sink transports those completed decisions;
backends rasterize and composite glyph images but do not remeasure, reshape,
or silently substitute fonts.

Capable targets may rasterize exact packaged font outlines. Static and
embedded targets may instead use build-time packages containing the same
canonical metrics and exact precompiled bitmap strikes. Both paths refer to
one fingerprinted face identity. This hybrid is intended to preserve identical
text geometry without requiring an outline parser and rasterizer in every
firmware image.

The proposal refines the text question in
[RFC-002](rfc-002-giftui-mvp-layered-architecture.md) while preserving that
RFC's candidate dependency direction:

```text
declarative Text and style
    -> proposal-based layout and canonical text layout
    -> positioned-glyph render operations
    -> backend and raster implementation
    -> surface or display target
```

Font assets are portable resources used through separate metric/shaping and
raster-payload views. They do not move layout into a backend. Positioned runs
are immutable in meaning, but static implementations may place them in bounded
caller-owned workspaces or stream them into the ordered operation sink; this
RFC does not require an allocated display list or retained render tree.

These are candidate architectural choices for review. This draft does not
approve architecture, settle exact public APIs, authorize a font toolchain or
runtime implementation, or make the draft boundaries in RFC-002 authoritative.

## Context

[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
accepts architecture work needed to keep the Signal Analyzer's portable
presentation shared across macOS dynamic, macOS static, Raspberry Pi/Linux
dynamic, and nRF52840 static configurations. Text is a Rank 2 MVP requirement:
the analyzer needs titles, channel labels, values, status, errors, and button
labels on every target.

RFC-002 proposes that GiftUI own proposal-based layout above a compact,
backend-neutral ordered render plan. Its Open Question 5 asks which layer owns
text measurement, glyph resources, and rasterization while keeping layout
stable across backends. This RFC answers that focused question without
creating a parallel render architecture:

- canonical text measurement and placement belong to the layout subsystem;
- completed positioned glyph runs are text's render-plan payload;
- font-resource contracts provide stable identity and separate metric/shaping
  data from raster payloads;
- a raster capability produces exact-identity glyph images; and
- the backend executes ordered operations and presents pixels.

RFC-002 remains `draft` and non-authoritative. Approval of either RFC must
reconcile shared terminology, geometry, capability, error, and render-plan
questions with the other; this RFC cannot approve RFC-002 by reference.

The proof of concept supplies useful evidence, not authority. Both dynamic and
static layout currently measure text as `glyphCount * 8` by `12`, while
`RenderOperation.text` carries raw `TextRun` content to a backend. The
framebuffer and RGB565 backends then select glyph bitmaps from
`GiftUIBuiltinFont`. This proves that a small allocation-free bitmap font and
ordered text operation can work across the existing targets. It also exposes
the architectural gap: layout and rasterization separately assume matching
cell metrics without a fingerprinted font identity or a contract preventing a
backend from choosing different glyph geometry.

The maintainer-provided text architecture attached to this RFC request is the
primary design source. It is adapted here to GiftUI's lifecycle template, MVP
scope, proposed ordered sink, bounded static storage, and existing module
vocabulary.

## Requirements

### R1 — One canonical geometry authority

For identical text, style, constraints, font packages, and policy, all
supported configurations MUST produce the same resolved face sequence, glyph
IDs, advances, offsets, line breaks, baselines, and logical bounds. Layout
MUST read geometry only from canonical packaged metrics and shaping data.

### R2 — Layout above rasterization

Font resolution, normalization, fallback, MVP shaping, line breaking,
measurement, and glyph positioning MUST be owned by GiftUI's layout side of
the render-plan boundary. A backend, raster provider, platform text API, cache,
or display device MUST NOT change those decisions.

### R3 — Positioned-glyph render boundary

Normal GiftUI `Text` MUST lower to backend-neutral positioned glyph-run
operations. The canonical render operation MUST preserve exact font-instance
identity, glyph IDs, clusters where required, logical positions, and opaque
paint without requiring the backend to interpret raw text.

### R4 — Exact font identity

Every layout and raster request MUST refer to an immutable, fingerprinted font
face and instance. Missing faces, mismatched packages, unsupported strikes,
and absent glyph coverage MUST produce deterministic diagnostics or failures;
they MUST NOT trigger ambient system-font substitution.

### R5 — Shared layout, selectable raster realization

The same layout contract MUST support an outline-backed raster provider and a
precompiled-bitmap provider. Raster realization MAY change coverage, hinting,
gamma, cache placement, or pixel format, but MUST NOT change canonical pen
positions, advances, baselines, line breaks, or bounds.

### R6 — Static and embedded viability

The nRF52840 configuration MUST NOT require runtime font discovery, heap
allocation, an outline parser, or an outline rasterizer. Text, glyph-run,
package, cache, and compiler-generated storage obligations MUST be fixed,
generated, or caller-supplied and MUST have deterministic exhaustion behavior.

### R7 — Streamable ordered operations

The architecture MUST permit positioned glyph runs to be emitted directly
through RFC-002's candidate ordered render-operation sink. Immutability of a
run's meaning MUST NOT imply a mandatory array-backed command buffer, retained
display list, or second render tree.

### R8 — MVP proportionality and extension boundary

The MVP implementation MUST cover the text used by the Signal Analyzer and
the four target-stack validations. Its contracts SHOULD leave shaping and
raster extension points, but full complex-script shaping, bidirectional and
vertical layout, text editing, runtime font discovery, and advanced glyph
representations MUST NOT become MVP implementation dependencies.

### R9 — Testable separation

Canonical text layout MUST be testable without a pixel backend, and each
raster provider and backend MUST be testable without re-running text layout.
Tests MUST distinguish geometric conformance from backend-specific visual
quality.

## Constraints

- The MVP must render the Signal Analyzer's text through substantially shared
  portable presentation on all four configurations in `docs/MVP_SCOPE.md`.
- MVP rendering uses opaque RGB color. Alpha, color glyphs, subpixel blending,
  and general compositing are not required by this RFC.
- RFC-002 proposes proposal-based layout, a normalized ordered operation sink,
  and distinct backend, raster, platform, driver, and HAL ownership. This RFC
  must remain compatible with that candidate direction while it is under
  review.
- RFC-002 selects checked integer geometry for MVP layout and Canvas. This RFC
  may propose a text-internal fixed-point representation, but it must define a
  deterministic conversion to the shared integer layout contract and cannot
  silently change repository-wide geometry. RFC-005 separately owns the
  cross-layer error model.
- The static path cannot assume heap-backed `String`, arrays, dictionaries,
  reflection, unrestricted existentials, runtime resource loading, or desktop
  concurrency facilities.
- Font redistribution, subsetting, and bitmap derivation must comply with the
  selected font's license.
- No proof-of-concept API, package name, bitmap, metric, or behavior is
  authoritative merely because it currently works.
- Pixel-identical antialiasing across materially different raster providers is
  not required. Canonical geometry is the cross-backend invariant.

## Proposed Design

### 1. Responsibility and dependency structure

Text follows RFC-002's proposed layers and gives the font resource two narrow
views rather than making it a new vertical owner:

```text
GiftUI public declarative API
  Text content, semantic FontRequest, TextStyle
                    |
                    v
Proposal-based layout and geometry
  FontResolver -> TextShaper -> TextLineLayout
                    |
                    | PositionedText / positioned glyph runs
                    v
Backend-neutral render plan and ordered sink
  draw positioned glyph run + opaque paint + resolved clip
                    |
                    v
Backend and raster implementation
  operation execution, glyph image cache, clipping, blending
          |                         |
          | exact GlyphRequest      | pixels
          v                         v
Glyph raster provider        surface or display target
  outline or bitmap

Font package resource
  identity + canonical metrics/shaping + optional raster payloads
          |                         |
          +--> layout view          +--> raster-payload view
```

Dependencies point toward portable contracts and down the render pipeline.
Layout may query the metric/shaping view of a font package but MUST NOT import
a raster provider, backend, platform text service, display driver, OS, RTOS,
or HAL. A raster provider may query the exact payload associated with the font
identity in a render operation but MUST NOT call layout. The backend may cache
the returned image but MUST NOT replace the identity or feed image dimensions
back into measurement.

RFC-002 requires distinct Swift packages for its top-level layout, render-core,
backend/raster, and integration layers. This RFC does not merge those layers.
Whether text-internal boxes inside one of those layers require additional
packages remains an RFC-003 question. A small static build may specialize the
separate packages into one firmware image, provided source dependencies and
focused tests preserve the contracts and prevent raster data from becoming
layout data.

### 2. Semantic input and text storage

The client-facing `Text` declaration supplies semantic content and style. A
conceptual input is:

```text
TextSpec {
  content
  fontRequest
  textStyle
  paragraphStyle
  languageHint
}

TextLayout.layout(TextSpec, ProposedSize, workspace) -> PositionedText
```

Names and exact visibility remain Specification work. `content` may be a
static string, generated/resource-backed text, bounded formatted text, or an
opt-in dynamic string. Those storage forms MUST converge on the same sequence
of supported Unicode scalar values and the same text-layout behavior. The
dynamic convenience path must not create a second shaping or measurement
model.

`FontRequest` expresses semantic family alias, weight, style, stretch, and
logical size. It carries no platform font handle, raster mode, display scale,
or device pixel size. The MVP may expose only the subset justified by the
reference font and Signal Analyzer while retaining an extensible internal
identity.

### 3. Font resolution, identity, and package views

Before shaping, a resolver converts semantic intent into an explicit ordered
face chain:

```text
FontCatalog.resolve(FontRequest) -> ResolvedFontChain
FontCatalog.metrics(FontFaceId) -> CanonicalFontMetricsView
FontPayloadCatalog.payload(FontFaceId) -> FontRasterPayload
```

A usable face has a stable `FontFaceId` and content fingerprint. The identity
records or derives from:

- package namespace and face name;
- package schema version;
- source-font fingerprint;
- canonical-metrics compiler version; and
- shaping-data version where independently versioned.

The metric/shaping view contains the supported character map, global and
per-glyph metrics, canonical bounds, kerning, MVP substitution data, and
fallback metadata. The raster-payload view contains either exact outlines or
exact bitmap strikes and image metadata. Both views MUST prove they come from
the same package identity and source fingerprint.

Application aliases may change between releases. A resolved `FontFaceId`
always identifies one exact package revision for the lifetime of a layout and
its render operations. Tests and serialized diagnostic fixtures record the
resolved identity, not merely a family name.

Font packages are application or target resources, not ambient platform
dependencies. A capable backend may use a platform raster API only if it loads
the exact packaged outline and validates identity; asking that API to locate a
similar system font is non-conforming.

### 4. Shaping, line layout, and measurement

Conceptual internal contracts are:

```text
TextShaper.shape(TextSlice, ResolvedFontChain, options, workspace)
    -> ShapedRun sequence

TextLineBreaker.break(ShapedRun sequence, ProposedSize, paragraphStyle)
    -> LineBreak sequence

TextPositioner.position(ShapedRun sequence, LineBreak sequence, workspace)
    -> PositionedText
```

Shaping maps supported input text and resolved faces to glyph IDs, clusters,
advances, and offsets. Line breaking consumes shaped runs; it does not remap
text. Positioning assigns line membership, origins, baselines, logical bounds,
and any required canonical ink bounds.

Measurement MUST return bounds from this same shaping and positioning path. A
separate fast measurement implementation is conforming only if it is proven
to be an exact optimization of the canonical result for its admitted input;
it cannot use backend or platform metrics.

The proposed MVP shaping envelope is:

- UTF-8 decoded under one explicit malformed-input policy;
- packaged character mapping;
- left-to-right horizontal Latin runs required by the Signal Analyzer;
- substitutions and kerning required by the selected reference font;
- explicit newlines, spaces, tabs, and deterministic empty-line behavior;
- one explicit fallback chain and replacement-glyph policy; and
- single-line plus width-constrained layout where the reference application
  needs it.

Exact normalization, substitution, whitespace, wrapping, and unsupported
input policies remain approval blockers below. The architecture fixes their
ownership above the backend even before those policies are selected.

### 5. Canonical geometry

This RFC proposes signed 26.6 fixed-point logical pixels for glyph advances,
offsets, baselines, and positions. Conversion from font units would use
integer arithmetic with round-to-nearest and ties away from zero. Intermediate
accumulation would remain in canonical logical units; device conversion would
occur only during rasterization or drawing.

The text rules are:

1. measurement reads only canonical package metrics;
2. logical font size affects canonical metrics, while device scale affects
   raster selection or generation only;
3. line ascent, descent, and gap come from canonical face data rather than a
   platform's recommended line height;
4. advances and placement use unhinted metrics;
5. fallback is explicit and completed before a run is emitted;
6. logical bounds derive from advances and line metrics;
7. canonical ink bounds, if required for MVP, derive from packaged glyph
   bounds rather than raster pixels; and
8. cache state, atlas placement, bitmap dimensions, hinting, antialiasing, and
   transfer geometry cannot invalidate layout.

RFC-002 fixes the shared MVP layout and Canvas geometry as checked integers.
Approval of this RFC must confirm that 26.6 is sufficient for text-internal
geometry and define deterministic measurement, bounds, and raster conversion
at that integer boundary. This draft does not create an unrelated public text
coordinate universe by fiat.

### 6. Positioned text and the render-plan operation

Conceptual values are:

```text
FontInstanceId = FontFaceId + logical size + approved variation/synthesis flags

PositionedGlyph {
  fontInstanceId
  glyphId
  cluster
  x, y
  xAdvance, yAdvance
  flags
}

PositionedGlyphRun {
  fontInstanceId
  glyphs
  baseline
  logicalBounds
  inkBounds, if required
}
```

The backend-neutral render plan gains an operation conceptually equivalent to:

```text
drawPositionedGlyphRun(run, opaquePaint, resolvedClip)
```

The operation preserves canonical logical positions and exact font identity.
It contains no backend font handle, glyph image, atlas coordinate, surface
pointer, platform object, or authoritative raw string. Transforms, opacity,
and richer clip forms are outside the MVP unless separately established by
the render architecture.

`PositionedGlyphRun` is immutable semantically: once emitted, its glyph
selection and geometry cannot change. Its physical storage may be:

- fixed inline storage with an explicit maximum;
- caller-owned arena or scratch space valid for the sink call;
- generated static storage;
- a borrowed slice into a bounded text-layout workspace; or
- an array-backed immutable value in a dynamic convenience layer.

The ordered sink may consume one run at a time. A backend that needs replay may
copy operations into storage it owns, subject to its declared capacity. No
supported static configuration is forced to retain all positioned text or all
render operations for a frame.

### 7. Raster-provider contract

After receiving a positioned run, the backend requests an image for each exact
glyph instance:

```text
GlyphRasterRequest {
  fontInstanceId
  glyphId
  deviceScale
  renderMode
  transformClass
}

GlyphImageProvider.acquire(GlyphRasterRequest) -> GlyphImage

GlyphImage {
  format
  width, height, stride
  originX, originY
  pixel payload or backend resource
}
```

The request and result names are illustrative. `originX` and `originY` place
coverage relative to the canonical glyph origin. They are raster metadata,
not corrected bearings, and MUST NOT feed back into advances, baselines,
bounds, or wrapping.

An outline provider may generate monochrome or grayscale coverage and may
apply hinting when hinting changes pixels only. A bitmap provider selects an
exact packaged strike for the face, logical size, device scale, and render
mode. The MVP does not silently scale a nearby strike. Unsupported transforms,
formats, or strikes produce a deterministic capability/resource result.

A platform-native text facility may be used internally to rasterize one exact
glyph from the validated packaged face. It may not lay out a string, choose
fallback, report authoritative advances, or reposition glyphs.

### 8. Backend responsibilities

For text, a conforming backend:

- consumes positioned-glyph operations in sink order;
- validates that required font/raster resources are available;
- acquires exact-identity glyph images from the selected raster provider;
- positions image origins relative to canonical glyph origins;
- clips and composites coverage using the supplied opaque paint;
- caches glyph images or atlas entries without changing geometry; and
- reports unsupported formats, transforms, capacity, or missing assets
  deterministically through the repository-wide error boundary.

The backend MUST NOT call text layout, reinterpret clusters, perform fallback,
replace a face or logical size, apply a platform line height, or advance a pen
from raster image widths. A compatibility adapter may lower legacy raw-string
requests through canonical layout into positioned runs during migration; there
is no conforming adapter in the opposite direction for normal `Text`.

### 9. Build-time font compiler and packaging flow

Static bitmap packages are generated outside the target runtime:

```text
source font + manifest + text corpus or ranges
                    |
                    v
       validate license and fingerprint
                    |
                    v
      subset cmap, glyphs, and shaping data
                    |
                    v
       emit canonical metric tables
                    |
                    v
 rasterize requested sizes/scales/render modes
                    |
                    v
 pack, checksum, and generate build integration
                    |
                    v
     versioned font package + inspection report
```

The manifest declares faces, logical sizes, device scales, code-point ranges
or corpus inputs, fallback faces, raster modes, compression, and missing-glyph
policy. The compiler computes transitive glyph dependencies introduced by the
selected substitutions and ligatures before subsetting.

Each image record includes its glyph ID, strike identity, dimensions,
stride/format, canonical origin offset, and payload location. Canonical metrics
are emitted once in the same form consumed by shared layout. The compiler
fails when requested coverage cannot be satisfied, identities conflict, or a
strike does not reproduce the canonical glyph mapping.

Identical compiler version, source fonts, manifest, and options SHOULD produce
byte-identical packages. An inspection report lists included characters and
glyphs, unresolved input, package size by section, and source fingerprints.
The package filename and binary schema are Specification concerns; `.guifont`
is a candidate convention, not an approved format in this RFC.

### 10. MVP realization

The proposed first conformance set is:

- one packaged, non-variable reference face or minimal explicit fallback
  chain covering all Signal Analyzer text;
- one shared canonical metric, shaping, line-layout, and positioning path;
- left-to-right horizontal Latin behavior sufficient for the application;
- one outline-backed provider for a capable reference backend;
- one monochrome or grayscale exact-strike provider for the embedded path;
- a build-time package generator driven by explicit ranges or corpus;
- bounded positioned-run and glyph-image storage for static execution;
- deterministic missing-resource and unsupported-input behavior; and
- cross-profile golden geometry plus per-backend visual fixtures.

Only functionality exercised by the Signal Analyzer or required to validate
the four target stacks is an MVP implementation obligation. The architecture
may admit additional sizes, faces, fallback entries, or wrapping behavior, but
their implementation requires a concrete current-scope use.

## Module Responsibilities

| Logical module or family | Responsibility | Dependency impact |
| --- | --- | --- |
| `GiftUI` public declarations | `Text`, semantic content and style requests, portable text-storage contracts | Imports no font rasterizer, backend, platform text API, OS, RTOS, or HAL |
| Layout subsystem | Resolution, normalization, shaping, canonical metrics, line layout, measurement, glyph positioning | Depends on portable font metric/shaping contracts; imports no raster or backend implementation |
| Font resource contracts | Stable identity, package lookup, canonical metric/shaping view, exact raster-payload view, integrity checks | Shared portable contract with separately restricted views; owns no line placement or compositing |
| Render-core subsystem | Positioned-glyph operation, bounded/borrowed storage contracts, ordered sink transport | Depends on geometry and font identity; carries no raw-text interpretation or backend handles |
| Glyph raster provider | Exact-face outline or bitmap decoding and glyph-image acquisition | Depends on render/font-payload contracts; cannot depend upward on layout |
| Backend family | Operation execution, glyph cache/atlas, coverage blending, clipping, surface submission | Depends on render and raster contracts; cannot measure, shape, or substitute text |
| Font compiler tooling | Validation, subsetting, canonical table extraction, strike generation, reproducible packaging and reports | Build-time only; its version and output identity are inputs to runtime packages |
| Target host/preset | Selects packages, provider, capacities, backend, and policy; validates the assembled configuration | Composition root may depend on selected implementations but exports no new portable text semantics |

These responsibilities must preserve RFC-002's distinct package boundaries
between public API, layout, render core, raster/backend, and integration.
Additional text-internal package placement and public/package/internal
visibility remain in RFC-003 review.

## Public API Impact

The portable API continues to expose `Text` and familiar style concepts, not
glyph or backend mechanics. Downstream Specifications are expected to define:

- static, bounded, resource-backed, and dynamic text storage admitted by each
  profile;
- the MVP `FontRequest`, `TextStyle`, and paragraph options;
- whether explicit measurement is public or only participates in layout;
- deterministic error and replacement-glyph policy;
- which font-resource, positioned-run, sink, and raster-provider contracts are
  public, package SPI, generated interfaces, or internal; and
- migration from current `TextRun` and raw-string backend entry points.

Exact type spellings shown in this RFC are illustrative. No stable ABI or
serialized public font format is promised for MVP.

## Capabilities Impact

Text introduces support and constraint facts that the separately governed
capability-system lifecycle may need to represent:

- available face/package identities and coverage fingerprints;
- supported logical sizes, device scales, render modes, and exact strikes;
- outline or bitmap realization and its relevant costs;
- maximum scalar, glyph, run, line, workspace, and cache capacities;
- supported shaping/normalization envelope; and
- package/resource availability at composition or initialization.

These facts describe support and constraints. Policy separately chooses among
available raster modes, cache sizes, or development replacement behavior. A
required Signal Analyzer face or strike that is absent makes the assembled
configuration invalid before presentation where practical; capability
resolution does not authorize a visually similar fallback.

PROPOSAL-004 and its future RFC own the representation, resolution phase,
policy relationship, and minimum MVP catalogue. RFC-002 supplies only the
module and dependency seams. This RFC requires the eventual capability model
to preserve exact identity, bounded absence behavior, and the distinction
between semantic conformance and raster quality, but it does not define that
model.

## Backend Impact

Existing backends currently consume `TextRun` and choose glyphs directly from
`GiftUIBuiltinFont`. Migration would replace that semantic raw-text operation
with positioned glyph runs and move exact glyph lookup behind the raster
provider contract.

The existing fixed 8-by-12 cell font remains useful evidence and could become
the first exact bitmap package if its identity, coverage, metrics, licensing,
and compiler/source provenance satisfy review. It is not automatically the
canonical font. The framebuffer and RGB565 implementations remain evidence
for clipped, allocation-free glyph drawing and cross-format golden tests.

Capable backends may choose different raster providers without changing
layout. A backend that delegates entire strings to Core Text, Pango, Qt, or a
similar platform layout service is non-conforming for normal GiftUI `Text`,
even if its screenshots appear acceptable.

## Static / Embedded Impact

Static conformance uses compile-time selected packages, provider, capacities,
and policy. It may use generated scalar-to-glyph tables, fixed-capacity run
workspaces, direct ordered-sink emission, and exact bitmap payloads compiled
into firmware. No dynamic package registry or outline rasterizer is required.

Resource accounting must include:

- source or decoded text capacity;
- shaped glyph and line-break workspace capacity;
- positioned glyph-run storage or maximum streamed run size;
- canonical metric, cmap, kerning, substitution, and fallback tables;
- bitmap strike payloads and indexes;
- glyph/tile/cache scratch memory;
- traversal stack and stack high-water; and
- linked code and flash cost of each included provider and compiler-generated
  table.

Large stores should be generated static data or caller-owned long-lived
workspaces, not large inline call-frame values. Capacity exhaustion, missing
coverage, and unsupported strikes must be deterministic. Omitted outline,
dynamic-loading, advanced-shaping, and unused raster facilities must not be
linked into the nRF52840 configuration merely behind runtime flags.

The current 3,840-byte RGB565 tile bound is relevant evidence for compositing
scratch space, not a complete text memory budget. Font-package flash, shaping
workspace, and stack limits remain explicit review questions.

## Performance

Canonical layout adds resolution, shaping, line layout, and positioning before
operation emission. Expected hot paths are character decoding, cmap lookup,
kerning/substitution lookup, fixed-point accumulation, glyph-image lookup,
coverage blending, and display transfer.

Validation should report per supported configuration:

- cold and warm text-layout time for representative and maximum admitted
  Signal Analyzer strings;
- glyphs and runs processed per frame;
- glyph cache hit/miss behavior where a cache exists;
- raster and blending time separately from layout and display transfer;
- package initialization or validation time;
- whether text work fits within the Signal Analyzer's 250-millisecond frame
  interval while ingestion continues; and
- worst-case stack high-water and heap/allocation counts for the selected
  profile.

Layout caches MAY reuse results when all semantic inputs, constraints, and
package identities match. Cache state MUST NOT change output. The first
implementation should prefer bounded tables and simple deterministic lookup
over speculative shaping or atlas optimization.

No component-level time budget is approved here. Numerical budgets must be
measured and allocated before implementation sign-off.

## Memory / Binary Size

The hybrid design trades generated flash for lower embedded runtime cost. An
outline provider adds parser/rasterizer code and source outlines; a bitmap
provider adds strike payloads for every admitted face, size, scale, and mode.
Subsetting reduces flash but increases the need for complete corpus/range
declarations and deterministic missing-coverage diagnostics.

Dynamic targets may allocate layout results and caches for convenience, but
portable semantics cannot require unbounded growth. Static targets need
declared maxima for input scalars, glyph expansion, runs, lines, fallback
faces, package tables, and cached images. Compiler inspection reports and
linked-image measurements should make those costs visible before deployment.

Advanced shaping engines, color glyphs, runtime font loading, resampling,
signed-distance fields, and general shared atlases remain outside the linked
MVP static image unless separately justified.

## Alternatives

### Alternative A — Backend-owned measurement and string drawing

Each backend could pass a string and style to its platform text stack. This is
the smallest initial abstraction and often gives native typography quality.
It also permits different font lookup, shaping versions, metrics, rounding,
and line breaking to alter intrinsic sizes and downstream layout. It is
preferable only when native layout equivalence matters more than GiftUI's
cross-backend geometry, contrary to the portable Signal Analyzer requirement.

### Alternative B — One complete font and raster stack on every target

GiftUI could package one shaping and outline raster library everywhere. This
offers the strongest opportunity for both geometric and pixel consistency and
reduces provider variation. It imposes outline parsing, code, data, scratch,
and raster costs on nRF52840. It becomes preferable if measured firmware costs
fit the target budgets or future scripts cannot be served by exact strikes.

### Alternative C — Precompiled bitmap fonts on every target

All configurations could use the same exact bitmap strikes. This simplifies
conformance and could make pixel output identical for matching formats. It
limits sizes and transforms, can multiply package size, and needlessly
restricts capable targets. It remains useful for deterministic kiosk-like
configurations, but is not proposed as the universal realization.

### Alternative D — Canonical metrics with backend-selected similar fonts

Layout could use packaged metrics while a backend draws a platform font with a
matching family name. This reduces packaging work. Glyph IDs, contours,
bearings, origins, and coverage may no longer describe the same face, so
clipping and visual placement can diverge even when advances are copied. Exact
identity is therefore proposed instead.

### Alternative E — Character-cell advances only

The current 8-by-12 proof-of-concept model is small, deterministic, and enough
for a restricted display. Making character cells the architecture would block
proportional metrics, kerning, substitutions, fallback, and reliable ink
bounds. A fixed-cell package may conform as a special case of positioned
glyphs, but it should not define the general boundary.

### Alternative F — Raw text plus canonical font identity in the render plan

The render plan could carry the exact string and face, leaving shaping to a
shared backend helper. This preserves identity but places measurement and
drawing on opposite sides of the boundary, invites duplicate shaping, and
makes a backend dependency necessary for intrinsic layout. Completed
positioned runs better preserve RFC-002's rule that layout is resolved before
render operations.

## Rejected Approaches

No approach is formally rejected while this RFC remains a draft. The
alternatives above remain review candidates. Approval should record the
rejected approaches and rationale before ADR extraction.

## Compatibility

### Source compatibility

Portable `Text` declarations should remain familiar. Font/style additions can
use defaults so existing simple labels migrate with limited source changes.
Dynamic-only initializers may remain in an opt-in convenience module, while
static and bounded text retain the same layout semantics.

### Behavioral compatibility

Existing 8-by-12 measurement and pixels may change when the canonical package
is introduced. Such changes are migrations from proof-of-concept behavior,
not compatibility regressions against approved architecture. During migration,
tests should compare old and new output, classify intended differences, and
freeze the accepted canonical geometry.

### Package and backend compatibility

Current raw `TextRun` render operations and `RenderBackend.drawText` cannot
remain the canonical backend boundary. Temporary adapters may support staged
migration, but first-party backends must eventually consume positioned glyph
runs. Existing package names do not decide final ownership.

### Data, schema, and ABI compatibility

The MVP has no stable font-package schema, render-operation ABI, or serialized
layout format. Packages and golden fixtures should carry explicit schema,
compiler, source, metrics, and shaping versions so an upgrade either preserves
output or intentionally invalidates and regenerates fixtures.

## Testing Strategy

### Canonical layout conformance

Run identical text fixtures through dynamic and static host profiles and,
where the language/runtime permits, target builds. Compare resolved identities,
glyph IDs, clusters, advances, offsets, line breaks, baselines, logical bounds,
and required ink bounds exactly. Changing device scale, raster mode, cache
state, or provider must not change logical measurement or wrapping.

### Render-boundary conformance

Recording sinks compare positioned-glyph operation order and payloads across
profiles. Borrowed or streamed static storage must remain valid for the
documented sink lifetime, and capacity tests must exercise maximum glyph/run
counts and deterministic overflow without heap fallback.

### Raster-provider conformance

For every referenced glyph, outline and bitmap providers validate exact face
identity and return images whose origins align to the canonical glyph origin.
Tests vary hinting, cache/atlas placement, bitmap dimensions, and supported
raster modes while proving that none feed back into layout.

### Compiler and package conformance

Pinned inputs should produce byte-identical packages and inspection reports.
Coverage tests include all Signal Analyzer strings and generated numeric
values, transitive substitution dependencies, fallback, replacement glyphs,
whitespace, empty lines, wrapping thresholds, negative bearings, and maximum
admitted lengths. Corrupt packages, fingerprint mismatch, unsupported strikes,
and absent glyphs exercise deterministic errors.

### Backend and integration evidence

Each first-party backend renders common positioned runs through its selected
provider. Pixel goldens are per backend/provider combination; cross-provider
pixel identity is not required. Visual tests confirm legibility, baselines,
clipping, and opaque color on macOS, framebuffer/RGB565 paths, and connected
MVP displays.

Supported-configuration validation follows macOS dynamic, macOS static,
Raspberry Pi 1/Linux, then nRF52840. Host tests, cross-builds, simulators, and
ELF/resource checks do not substitute for connected-board evidence.

### Dependency enforcement

Import or package-graph tests prevent layout from importing backend/platform
font APIs and prevent backends from invoking text layout. Static link checks
confirm that omitted outline, dynamic-loading, and advanced-shaping facilities
are absent from firmware.

## Risks

- **The MVP text scope becomes a typography platform.** Restrict required
  coverage and policy to concrete Signal Analyzer strings and stack
  validation; keep richer semantics in linked deferred work.
- **The font package and compiler cost more than the application justifies.**
  Start with one face and minimal tables, measure package sections, and permit
  a generated fixed-cell package as a conforming first realization.
- **Exact geometry still drifts through arithmetic.** Pin conversion and
  rounding fixtures, coordinate the scalar choice with RFC-002, and compare
  serialized canonical results before rasterization.
- **A platform raster API subtly changes face or glyph interpretation.**
  Require exact packaged outlines and fingerprints, glyph-level calls, and
  provider conformance against the bitmap reference.
- **Static storage overflows on real content.** Generate capacities from the
  admitted corpus where possible, expose maxima in diagnostics, and test the
  longest numeric/error strings and worst glyph expansion.
- **Bitmap strikes consume excessive flash.** Measure by face/size/scale/mode,
  subset exact coverage, and keep compression choice visible as an open
  policy rather than hiding cost in a generic resource layer.
- **Positioned runs accidentally force retention.** Make sink lifetime and
  borrowing explicit and test direct static emission without a display list.
- **RFC-002 and RFC-003 settle shared boundaries differently.** Keep reciprocal
  links and approval blockers for the render plan, integer conversion,
  capability-system seam, errors, and package ownership until review
  reconciles them.

## Open Questions

The following questions block RFC approval or the coherence of a downstream
Specification; they are not deferred:

1. Which redistributable reference face and license permit source packaging,
   subsetting, and bitmap derivatives for every MVP target?
2. What exact Signal Analyzer corpus/ranges, Latin substitutions, normalization,
   malformed-input, whitespace, tab, fallback, replacement, and line-breaking
   policies define MVP conformance?
3. Does unsupported input fail strictly in production, render a visible
   replacement, or use an application-selected policy? How is that result
   expressed through the cross-layer error architecture in RFC-005?
4. What maximum scalars, glyph expansion, runs, lines, package flash, shaping
   workspace, glyph scratch/cache RAM, stack high-water, startup time, and
   per-frame time must each MVP profile admit?
5. Is signed 26.6 fixed-point sufficient for text-internal geometry and all
   admitted line lengths, or must storage be wider? Which deterministic
   rounding and bounds rules convert it to RFC-002's checked integer layout
   and Canvas geometry?
6. Are canonical ink bounds required for all MVP text, or may a layout request
   omit their computation and storage when only logical bounds are consumed?
7. Which bitmap formats and compression, if any, are required by the first
   embedded provider, and can they meet measured flash and decode budgets?
8. How do package schema, compiler, metrics, and shaping upgrades preserve or
   deliberately version identities and golden layout?
9. Does the first outline provider use a bundled raster library or an exact-face
   validated platform API, and what conformance evidence is sufficient for the
   latter?
10. Beyond RFC-002's required package-per-layer boundaries, which
    text-internal contracts require additional Swift packages or targets, and
    which may remain within their owning layer package without weakening
    dependency enforcement or increasing static code size?

## Deferred and Follow-up Work

- [FW-001](../future-work/fw-001-international-and-rich-text-layout.md)
  captures full complex-script shaping, bidirectional and vertical layout,
  variable-font axes, color glyphs, and related locale-aware segmentation.
  These do not contribute to the MVP Signal Analyzer; revisit when an accepted
  application requirement needs one of those semantics.
- [FW-002](../future-work/fw-002-text-interaction-and-accessibility-geometry.md)
  captures hit testing, selection, carets, editing, and accessibility geometry.
  The current RFC renders presentation text only; revisit when an accepted
  interactive-text or accessibility feature needs geometry derived from
  canonical clusters.
- [FW-003](../future-work/fw-003-advanced-font-delivery-and-glyph-rasterization.md)
  captures runtime font registration, transformed strike resampling, distance
  fields, compressed atlases, and shared incremental caches. Revisit when a
  concrete target requires runtime fonts, arbitrary transforms, or measured
  cache/raster costs exceed the simple MVP realization.

These captures do not add requirements, roadmap work, or implementation
authority to the MVP.

## Decision Summary

If this RFC is approved after its blockers are resolved, the following
architecturally significant choices are candidates for ADR extraction:

1. GiftUI layout owns font resolution, canonical metrics, MVP shaping, line
   layout, measurement, and glyph positioning above the render-plan boundary.
2. Normal GiftUI text crosses the ordered render boundary as completed
   positioned glyph runs, not authoritative raw-string operations.
3. Font resources provide one fingerprinted identity with separate
   metric/shaping and raster-payload views shared by layout and rasterization.
4. Raster providers own exact-glyph pixel acquisition, while backends own
   operation execution, caching, clipping, compositing, and presentation;
   neither may change canonical geometry.
5. Capable targets may use exact packaged outlines, while static/embedded
   targets may use exact precompiled bitmap strikes under the same layout
   contract.
6. Static positioned-run and font-resource storage is bounded, generated, or
   caller-owned and may stream through the ordered sink without a mandatory
   retained display list.
7. Silent font substitution and renderer feedback into layout are prohibited;
   missing or incompatible resources have deterministic failure behavior.

The text-internal scalar/rounding choice, exact MVP shaping and fallback
policy, package versioning, and error behavior must be resolved before the
corresponding ADRs and Specifications can be authoritative.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [PROPOSAL-001: GiftUI MVP Baseline Charter](../proposals/proposal-001-giftui-mvp-baseline-charter.md)
- [PROPOSAL-004: GiftUI Capability System](../proposals/proposal-004-capability-system.md)
- [RFC-001: Signal Analyzer Application Architecture](rfc-001-signal-analyzer-application-architecture.md)
- [RFC-002: GiftUI MVP Layered Architecture](rfc-002-giftui-mvp-layered-architecture.md) — draft, non-authoritative architectural context
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
- [GiftUI Embedded Layer Inventory](../GiftUI_Embedded_Layer_Inventory.md) — implementation evidence only
- [`RenderOperation`](../../Sources/GiftUI/Rendering/RenderOperation.swift),
  [`RenderBackend`](../../Sources/GiftUI/Rendering/RenderBackend.swift), and
  current dynamic/static layout implementations — proof-of-concept evidence
- [`GiftUIBuiltinFont`](../../Sources/GiftUIBuiltinFont/BuiltinFont8x12.swift),
  framebuffer, and RGB565 text rasterizers — proof-of-concept evidence
- Maintainer-provided “Deterministic Text Rendering Architecture” draft
  attached to the RFC authoring request on 2026-08-15.
