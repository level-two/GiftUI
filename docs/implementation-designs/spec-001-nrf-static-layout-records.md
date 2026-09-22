---
spec: SPEC-001
feature: signal-analyzer
title: Implementation Design — nRF Static Layout Records
status: draft
authors:
  - codex
created: 2026-09-22
updated: 2026-09-22
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
font, clip, and glyph-index derivation still belongs to the future workspace.

The remaining 416 bytes can hold two 98-scope visit sets and a bounded
13-depth foreground stack for render preflight. Exact offsets and record
encodings remain provisional until compile-time size, overflow, and full-
pipeline tests prove the partition. No part of a live layout result may be
overwritten by render traversal.

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
