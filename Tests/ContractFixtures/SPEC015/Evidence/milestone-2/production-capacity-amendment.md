# SPEC-008 / SPEC-013 / SPEC-015 Production-Capacity Amendment

**Approved for implementation** — the maintainer explicitly approved the
completed production hierarchy measurements on 2026-09-20.

The diagnostic-present Signal Analyzer measures 48 semantic nodes, 14 body
evaluations, 50 modifier applications, 6 action occurrences, semantic depth
34, 126 retained semantic identities, 98 coherent render scopes, 98 resolved
layout scopes, and render/layout depth 13. Its ordinary render stream contains
30 operations, 129 positioned glyphs, 21 lines, and clip depth 3. The release
ceilings remain 35 combined operations, 139 glyphs, 21 lines, clip depth 4,
and the existing 832-point Canvas plan.

The canonical workload descriptor now carries the measured semantic and
structural values. Regeneration produced one provenance digest,
`4404d7f0672dcbbd3246ee65b4c898146346d758f46f358feaa2b39d0e5261ef`,
for all four manifests and the Swift presets.

The exact profile projections are:

| Profile | Semantic candidate | Semantic published | Layout candidate | Render workspace | Checked total |
| --- | ---: | ---: | ---: | ---: | ---: |
| Dynamic | 4,032 B | 4,032 B | 3,920 B | 6,272 B | 41,376 B |
| Static | 3,024 B | 3,024 B | 3,136 B | 4,704 B | 36,368 B |

The resource-instrumentation gate compiled its bounded 24-field snapshot and
allocation interposer. The generated-workload, SPEC-008, SPEC-013, and
SPEC-015 harness checks passed. The Dynamic production integration test passed
with the exact generated semantic, layout, render-workspace, render, sink, and
Drawing limits, including Canvas-aware streaming. This is hardware-free
evidence and makes no connected-target claim.
