# SPEC-012 T9.3 Resource Evidence

Date: 2026-09-14

All four pinned compilers reproduce the same seven value layouts: 18-byte
`DrawingLimits` within a 20-byte bound, exact 4-byte `StaticCanvasLimits` and
`SubpathRange`, exact 10-byte `DrawingPlanSummary`, 40-byte
`StraightLineStrokeHeader`, exact 1-byte `DrawingProductionError`, and
11-byte `DrawingPlanResult` within a 12-byte bound.

Focused Drawing instrumentation keeps generated capture size, callable
lifetime, live Path point/subpath high-water, immutable plan
stroke/point/subpath high-water, combined render traversal/workspace counts,
and linear construction/snapshot work distinct. SPEC-013's four-profile run
`f76656e188855f67d5c72170c29167a55f8d6c90-31230e742780694f` supplies separate
production Canvas callable, path workspace, drawing plan, render workspace,
stack-stage, heap/allocation, linked-image, and workload-timing measurements.

SPEC-014's four-profile run
`64f28244cdc154dd98ca1786ced9a80ce1df7d6f-7b601523b1450ef0` records
post-acceptance raster storage separately. Raspberry Pi observes 7,680-byte
tile, payload, in-flight, and bounded stack storage with 15 tile visits and
zero optimized allocation references. nRF observes 3,840 bytes for each
corresponding bound, 80 tile visits, zero heap-allocation instructions, and
linked section/RAM/flash deltas. Full-surface storage stays zero for these
tiled configurations. Each report retains its command transcript, symbols,
link maps, section deltas, stack, allocation, resource high-water, and timing.

The pristine macOS and ARMv6 collectors use isolated scratch directories plus
the repository's already-resolved dependency cache. Evidence regeneration is
therefore hardware-free and no longer depends on network availability.
