# SPEC-001 T6.7 Dynamic Render Projection Blocker

The first production render-preflight attempt joined the real diagnostic-
present semantic result, the real 53-scope resolved layout, canonical text
metrics, `DynamicRenderWorkspace`, and `RenderProducer`.

The exact generated preset fails closed before rendering because the current
`DynamicSemanticHostStorage` exposes all 81 retained semantic structural
identities as `SemanticRenderView.semanticScopeCount`, while the approved
SPEC-015 workload admits 62 render-semantic scopes. An informative run with
128 semantic/layout visit slots and traversal depth 64 then fails with
`RenderProductionError.invariantViolation`: the current render child
projection traverses layout primitives rather than all identities claimed by
the render view. Increasing workspace capacity therefore does not resolve the
problem.

The production portable hierarchy now applies the foreground, background,
padding, and frame surface represented by SPEC-008. Its independently checked
diagnostic maximum is 121 retained semantic/render identities, 93 layout
scopes, and layout depth 13, including exactly 21 foreground scopes and 9
background scopes. See `portable-surface-measurement.md`. These measurements
exceed the currently approved SPEC-008/SPEC-015 render-workspace values of 62
semantic scopes, 53 layout scopes, and traversal depth 6.

The checked regressions assert both the new measured surface and the exact
preset's fail-closed semantic-capacity result. T6.7 render work must construct
a coherent render-only projection, then measure the final operation and clip
high-water values. The measured semantic/layout changes require deliberate
SPEC-008/SPEC-013/SPEC-015 amendment and reapproval rather than silent
headroom.

This evidence is hardware-free. No deployment, framebuffer access, or
connected-target execution occurred.
