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

The production portable hierarchy also does not yet apply the foreground and
background modifiers represented by the approved SPEC-008 62-scope/30-
operation Signal Analyzer fixture. Consequently, the final production render
scope, operation, clip-depth, and layout counts cannot be inferred by simply
substituting 81 for 62.

The checked regression asserts the measured `81 > 62` mismatch next to the
successful exact semantic/layout join. T6.7 render work must first realize the
approved complete visible screen surface and construct a coherent render-only
projection, then measure it against SPEC-008/SPEC-015. If those production
measurements differ from the approved workload, the Specifications require
deliberate amendment and reapproval rather than silent headroom.

This evidence is hardware-free. No deployment, framebuffer access, or
connected-target execution occurred.
