---
spec: SPEC-001
feature: signal-analyzer
title: Implementation Design — nRF Static Layout Records
status: draft
authors:
  - codex
created: 2026-09-22
updated: 2026-09-23
implementation_plan: ../implementation-plans/spec-001-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — nRF Static Layout Records

> This note explains a replaceable internal realization of the approved
> contract. It is not authority and does not change any profile byte count,
> layout result, rendering behavior, or connected-target gate.

## Purpose and Boundary

SPEC-001 T6.8 still needs resolved layout and render consumption of the
generated Static semantic table. This note selects a bounded representation
for that join. It does not implement the layout, Canvas plan, render, raster,
or firmware owner and makes no connected-hardware claim.

## Governing Contract

[SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md) requires
one unchanged portable hierarchy and a complete nRF Static presentation.
[SPEC-007](../specs/spec-007-layout.md) owns the layout algorithm and
publication contract; [SPEC-008](../specs/spec-008-rendering.md) owns resolved
text/render consumption; [SPEC-013](../specs/spec-013-runtime-profiles.md) and
[SPEC-015](../specs/spec-015-host-configuration.md) fix the exact Static
profile-store audit and the 98-scope, 128-line, 224-glyph capacities. Accepted
ADR-001, ADR-004, ADR-011, and ADR-028 preserve shared Presentation, ordered
publication, and post-layout Canvas derivation. This is a T6.8 implementation
choice, not a new cross-module contract.

## Current-Code Context

`StaticSignalAnalyzerNRFSemanticRegionStore` publishes a checked generated
version-2 table and lends paired `SemanticLayoutView` and `SemanticRenderView`
readers. A host-only validation workspace accepts the normal, 96-byte ASCII,
wide-printable, and multiline diagnostics; it cannot measure/place or publish
layout. The common `layout` algorithm and `publishLayout` require a workspace
that retains scope measurements and placements, text lines, and glyphs, plus a
resolved-layout sink. The production profile owns exactly 3,136
`layoutCandidateBytes` and 4,704 `renderWorkspaceBytes`; both are attempt-local
and disjoint. Extra global arrays or heap-backed buffers would evade the
approved storage audit.
The target-safe published semantic view now resolves primitive children beneath
modifier chains and exposes the same modifier-scope order as the host layout
projection. A differential fixture checks every normal/diagnostic scope and
edge. The target now decodes all seven layout primitive
shapes with checked payload fields; a differential test compares every
primitive in the published diagnostic table with the generated host view.
The actual layout pass remains open.
The target also decodes the preset's passthrough, padding, fixed-frame, and
flexible-frame modifiers with checked alignment, optional dimensions, and
limits. The differential fixture compares every modifier of every diagnostic
primitive against the host layout projection. Measurement and placement
remain open.
The target text measure rule now consumes published UTF-8 scalars and canonical
glyph advances, stages glyphs before line finalization, handles CR/LF and
width wrapping, and writes the exact compact scope measurement. A host
differential fixture compares its complete scope and render regions with the
common measure engine for every diagnostic text scope, including a 96-LF
diagnostic. The target primitive decoder now checks text byte offsets against
the UTF-8 byte pool capacity, which can exceed the old scalar table capacity.
Container and modifier measurement, placement, and publication remain open.
The target text placer now translates the measured scope, line bounds, line
baselines, and glyph baselines with checked 16-bit storage and derives the
scope/line clips. The differential fixture compares all packed records after
nonzero-origin placement by the common engine for every diagnostic text
scope. Container and modifier placement and resolved publication remain open.
The target workspace now checks complete placed scope, dense line, and
associated glyph records before setting the same one-byte publication marker
as the host sink. Its borrowed view reads those records only while the marker
remains set. A differential fixture compares both complete published regions
with the host in-place sink, including refusal of a missing scope and
invalidation on reset. Full hierarchy layout and publication still remain
open; the firmware startup check publishes only one isolated title scope.

## Proposed Internal Organization

Keep generated Static semantic readers in `SignalAnalyzerTargetHost`. Add a
target-local packed `LayoutWorkspace` and `ResolvedRenderLayoutResultStorage`
over the two caller-owned profile regions, with `UInt16` generated scope IDs.
The profile binding should lend both exact disjoint ranges during one active
opportunity, with no escaping buffer or duplicate owner. The sink validates
and publishes the records already written by the workspace in place; it does
not copy them into another array. A compact render-workspace adapter uses the
unoccupied tail without modifying the retained layout result.
The common Static storage protocol and binding now provide that paired borrow:
it exposes exactly 3,136 layout bytes and 4,704 render-workspace bytes only
during an active attempt, then the existing attempt reset clears both ranges.

## Data and Control Flow

The semantic candidate is validated, then the common `layout` measure/place
and publication operation writes the two regions. A successful sink seal
exposes an immutable `ResolvedRenderLayoutView` until the attempt ends. The
five generated Canvas captures derive against that view, followed by combined
render preflight and interaction. An error discards the in-place candidate;
it cannot alter the prior published semantic revision or enable input.

## Algorithms and Data Structures

The 3,136-byte layout region has 98 fixed 32-byte scope slots. Each slot
stores its generated two-byte stable identity; the identities are not scope
ordinals and lookup must search the occupied prefix. Each slot must retain
ideal/resolved measurements while placement runs; it also retains
placed bounds and clip. Candidate packing uses checked signed or unsigned
16-bit geometry where the exact 480 x 320 hierarchy and 96-byte text bound
prove representability. Decoding reconstructs full `GeometryScalar` values.
The first checked scope codec now stores stable identity, ideal/resolved
sizes, placed origin, and clip inside one slot and rejects signed-16-bit
overflow, duplicate placement, wrong region size, and corrupt reserved bytes.
The target-safe workspace now owns both exact disjoint profile slices during
an active layout attempt. It appends unique scope identities, replaces staged
measurements, places scopes, and uses the 26-byte depth stack in the render
scratch tail. A host differential fixture compares both complete regions
after each operation, including reset and reuse. The target workspace now
also appends and replaces text lines and glyph baselines in the same region,
with dense per-scope indexes and canonical glyph bounds. Glyphs can precede
their line records as required by the common text measurement pass; baseline
replacement requires the line record.
The differential fixture compares both complete regions after these text
operations too. Publication and the actual measure/place traversal remain
open.
The corresponding target-safe codec now compiles into the nRF image, and a
host differential fixture compares its entire 3,136-byte region against this
host codec for a checked measurement and placement. Firmware startup uses the
actual profile slice for a root-scope probe; complete layout is still open.
The target codec now also replaces a staged measurement before placement,
matching the common workspace's modifier update step and refusing updates
after placement. The host byte comparison covers that replacement.
The production adapter must still prove every field's range under the real
hierarchy; an unrepresentable value fails closed, never wraps or clamps.

The 4,704-byte render-workspace region is partitioned by checked offsets:

| Content | Maximum | Bytes each | Total |
| --- | ---: | ---: | ---: |
| Text lines | 128 | 16 | 2,048 |
| Positioned glyphs | 224 | 10 | 2,240 |
| Remaining metadata and render traversal scratch | — | — | 416 |

A line record stores scope ID, line index, compact bounds, and baseline.
Before placement its clip is the common zero rectangle; afterward the clip is
reconstructed from the placed text scope and line bounds. A glyph record
stores scope ID, line index, glyph ID, and baseline. Its per-scope glyph index
is derived from stable record order, its instance is the one checked reference
font, and its clip comes from its line. The append/store methods must verify
these derivations rather than silently discard supplied fields. `publishLayout`
then checks line/glyph order and replays them into an in-place validating sink.
The fixed 16-byte line and 10-byte glyph codecs now prove their byte ranges,
checked geometry, last-slot access, and untouched scratch tail in host tests;
the corresponding target-safe codec now cross-builds and a differential
fixture compares its entire workspace with the host codec after line/glyph
staging and glyph-baseline replacement. Firmware startup uses the actual
profile slice for one line and glyph, without claiming layout publication.
The target now also compiles a compact, allocation-free projection of the
canonical reference font's 96 scalar mappings, 102 glyph metrics, replacement
glyph, and line metrics. A generator checks it against the adopted reference
catalogue at firmware configure time; a host differential test compares every
mapping and metric. The firmware line/glyph probe obtains its glyph ID from
this projection. Layout measurement and rasterization have not yet consumed it.
The fixed-region workspace now verifies the reference font, derives text clips
from placed scope and line bounds, derives glyph indexes from record order, and
stores its 13-entry scope stack in the reserved scratch tail. Focused host tests
cover placement, text replacement, duplicate rejection, and complete reset.
The in-place resolved-layout storage now checks every staged scope, line, and
glyph against those same packed records. It sets a one-byte publication marker
in the scratch tail only after complete summary and root verification. The
common `publishLayout` cleanup then clears the depth stack and counters while
preserving the published records for the rest of the active opportunity.
Acquiring another layout clears both regions and invalidates the former view.
Focused host tests prove publication, field queries, reuse invalidation, and
refusal without partial publication. The common Static profile now lends the
semantic candidate and both disjoint layout regions in one attempt-scoped
borrow. A host fixture runs the generated normal hierarchy and the 96-byte
ASCII, wide-printable, and multiline diagnostic hierarchies through the common
validation, measurement, placement, and in-place publication path. The
workspace admits glyphs before their line records are finalized, matching the
common measure order; it derives line and glyph clips after placement. The
same package source is not yet linked into the embedded firmware pipeline.

The remaining 416 bytes now hold render scratch starting 32 bytes into the
tail: two 98-byte visit sets and a 13-entry RGB foreground stack of 39 bytes.
The first 32 bytes preserve the layout depth stack and publication marker.
The Static render workspace refuses an incorrect region or structural limit,
detects repeated/out-of-range visits, and clears only its scratch on reset.
Host tests prove the packed layout records and publication marker survive a
render traversal. The full render preflight and production transaction remain
open.

## Lifecycle and Resource Behavior

Both regions are cleared by the existing attempt reset and remain unavailable
outside an active opportunity. Layout acquisition and sink publication use
independent explicit states; repeated acquisition, duplicate scopes, missing
lines, non-dense glyph indexes, and any slot excess reject without exposing a
partial view. Render traversal resets only its 416-byte scratch tail. The
implementation must measure stack high-water and recheck the pristine
ARMv7E-M VFP, zero-heap, no-full-framebuffer, RAM, flash, and forbidden-symbol
gates. The 36,368-byte named profile total does not change.

## Test and Diagnostic Seams

First test the packed record codec and exact region boundaries, including
negative and largest valid geometry, exhaustion, duplicate/stale access, and
attempt reset. Then compare the common Static layout result with the Dynamic
oracle for normal, printable 96-byte, and 96-LF diagnostic models: scope
placements, 27/117 measured line cases, glyphs, clips, and failure precedence.
Finally use the production resolved view in Canvas and render preflight host
fixtures before cross-building the unchanged firmware target. Host execution
and cross-builds do not substitute for T8.2 connected TFT/input evidence.

## Rejected Implementation Alternatives

- Heap arrays or untracked static globals would bypass the exact profile
  audit and zero-allocation claim.
- Copying layout records into another sink would require a second unbudgeted
  result store.
- Reusing the 416-byte scratch tail for any retained line or glyph would
  invalidate the view during render preflight.

## Open Implementation Questions

The codec's compact geometry range and exact 416-byte traversal partition
must be proved against the common algorithm and every approved diagnostic
shape. If either cannot be proved, T6.8 pauses for SPEC-013/SPEC-015 contract
review rather than adding unaccounted storage. Physical shield and connected
stack evidence remain the separate T8.2 gate.

## Code and Evidence Links

- [Target adapter to shared layout](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCommonLayoutPass.swift)
- [Target packed workspace adapter](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCommonLayoutWorkspace.swift)
- [Native execution check](../../scripts/contracts/check-spec-001-nrf-full-layout-native.sh)
- [Generated semantic region](../../Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFSemanticRegion.generated.swift)
- [Static profile regions](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFProfileRegions.swift)
- [Common layout](../../Sources/GiftUILayout/Layout.swift)
- [Common layout publication](../../Sources/GiftUILayout/LayoutPublication.swift)
- [Current Static validation fixture](../../Tests/GiftUIHostConfigurationTests/StaticSignalAnalyzerNRFPresentationInputsTests.swift)
- [Checked scope codec](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFLayoutScopeCodec.swift)
- [Scope codec tests](../../Tests/GiftUIHostConfigurationTests/StaticSignalAnalyzerNRFLayoutScopeCodecTests.swift)
- [Checked line/glyph codec](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFLayoutTextCodec.swift)
- [Line/glyph codec tests](../../Tests/GiftUIHostConfigurationTests/StaticSignalAnalyzerNRFLayoutTextCodecTests.swift)
- [Static profile lifetime binding](../../Sources/GiftUIRuntimeStatic/StaticProfileStorage.swift)
- [Paired-region lifetime test](../../Tests/GiftUIHostConfigurationTests/StaticSignalAnalyzerNRFProfileBindingTests.swift)
