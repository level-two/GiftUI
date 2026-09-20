# SPEC-001 T6.7 Dynamic Render Capacity Blocker

The production render-preflight join now combines the real diagnostic-present
semantic result, the real 98-scope resolved layout, canonical text metrics,
`DynamicRenderWorkspace`, and `RenderProducer`.

`DynamicSemanticHostStorage` now publishes a distinct coherent render view
rather than exposing its retained expansion identities directly. The render
view contains every primitive, action proxy, and modifier layout scope exactly
once, maps every render identity to itself in the resolved layout, and forms a
single rooted tree. Its final diagnostic maximum is exactly 98 render scopes
at traversal depth 13, equal to the 98 resolved-layout scopes.

With separately labeled measurement capacities, ordinary preflight and
streaming succeed with 30 operations, 129 positioned glyphs, and maximum clip
depth 3. The production Dynamic drawing-plan workspace then derives all five
Canvas strokes; Canvas-aware preflight and streaming succeed with 35 total
operations. See `dynamic-drawing-plan-workspace.md`.

The production portable hierarchy applies the foreground, background, padding,
and frame surface represented by SPEC-008. Its independently checked expansion
maximum is 126 retained semantic identities; its render-only projection and
layout each contain 98 scopes at depth 13, including exactly 21 foreground
scopes and 9 background scopes. See `portable-surface-measurement.md`. These
measurements are the approved SPEC-008/SPEC-015 render-workspace values.

The checked regressions assert the measured surface, complete render-tree
coverage, successful production render streaming, and exact generated-preset
admission. The maintainer approved the SPEC-008/SPEC-013/SPEC-015 amendment on
2026-09-20; the workload generator now emits the measured structural values
and checked profile byte totals. The capacity blocker is resolved with no
silent headroom. T6.7 continues with the live host-owner composition.

This evidence is hardware-free. No deployment, framebuffer access, or
connected-target execution occurred.
