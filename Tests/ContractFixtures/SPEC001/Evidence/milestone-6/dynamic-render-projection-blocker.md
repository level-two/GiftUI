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
measurements exceed the currently approved SPEC-008/SPEC-015 render-workspace
values of 62 semantic scopes, 53 layout scopes, and traversal depth 6.

The checked regressions assert the measured surface, complete render-tree
coverage, successful production render streaming, and the exact preset's
fail-closed semantic-capacity result. The coherent projection blocker is
resolved, including Canvas-plan integration. T6.7 remains blocked on
deliberate SPEC-008/SPEC-013/SPEC-015 amendment and reapproval plus the live
host-owner composition; no silent headroom was added.

This evidence is hardware-free. No deployment, framebuffer access, or
connected-target execution occurred.
