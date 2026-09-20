# SPEC-001 T6.7 Dynamic Drawing-Plan Workspace

`DynamicDrawingPlanWorkspace` is the production Dynamic owner for Canvas
construction. It supplies one scoped `GraphicsContext`, reuses the bounded
`DynamicLivePathStorage`, snapshots straight-line strokes into immutable plan
records, translates points to surface coordinates, preserves inherited clips,
and publishes only after all Canvas callables complete. Its arrays reserve the
generated `DrawingLimits`; first excess and malformed path/storage responses
remain fail-closed through the shared Canvas producer.

The portable analyzer now gives the grid Canvas an exact 200 x 100 frame and
each channel trace Canvas an exact 120 x 16 frame. This resolves the previously
observed zero-sized Canvas layouts without introducing backend-specific source.
The five fixed frames add five semantic modifiers and five layout/render
scopes.

Under `GIFTUI_DYNAMIC_PROFILE`, the real diagnostic-present hierarchy,
resolved layout, Canvas callables, workspace, Canvas preflight extension, and
Canvas streaming extension complete as one production join. The diagnostic
scenario records:

- 5 Canvas occurrences and 5 submitted strokes;
- 32 snapshotted points and 16 snapshotted subpaths;
- 5 normalized stroke operations;
- 35 total render operations: 30 ordinary plus 5 Canvas strokes;
- 129 positioned glyphs; and
- maximum clip depth 3.

The diagnostic scenario has no captured transitions, so its 32 points are not
the release workload maximum. The separately approved deterministic release
corpus remains responsible for the 832-point high-water claim. This slice
proves production ownership and integration, not replacement resource
evidence.

The final styled-and-sized diagnostic hierarchy measures 48 semantic nodes,
50 modifiers, semantic depth 34, 126 retained expansion identities, 203
recorded traversal identities, and 98 coherent render/layout scopes at render
and layout depth 13. The normal hierarchy measures 47 semantic nodes, 49
modifiers, and 124 retained identities. These values require deliberate
SPEC-008/SPEC-013/SPEC-015 review before preset regeneration.

This evidence is hardware-free. No deployment, framebuffer access, or
connected-target execution occurred.
