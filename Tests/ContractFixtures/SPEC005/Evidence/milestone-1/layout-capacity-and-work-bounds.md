# T1.5 Layout, Capacity, Work, and Allocation Evidence

Task `T1.5` closes Milestone 1 with target-compiler layout reports, independent
capacity boundaries, bounded-work counters, and allocation interposition.

Each of the four pinned profiles compiles the production declarations and the
checked-in layout probe together under optimization, emits LLVM IR, and
extracts constant size, stride, and alignment for 16 normative values. All
profiles report the same values. Exact identities retain 32-, 2-, and 1-byte
widths; `FontInstanceID` is 34 bytes; `FontLineMetrics` is 12;
`GlyphMetrics` is 20; and every descriptor or raster record is at most 80.
The fail-closed target-layout checker rejects nonconstant results, ceiling
violations, invalid stride, or non-power-of-two alignment.

Focused runtime fixtures independently exercise zero, one, maximum, and
maximum plus one for the one-instance, 256-glyph, 256-mapping, two-realization,
16,384-manifest-byte, and 65,536-payload-byte ceilings. A zero-byte payload
with a zero-byte glyph record forms an exact empty partition. Zero remains
within capacity so Milestone 2 can preserve its distinct `.invalidCount`
precedence where the contract requires a nonzero count.

Counter-instrumented views record these maximum lookup and traversal results:

| Path | Maximum observed work |
| --- | ---: |
| scalar mapping | 256 record comparisons |
| metric lookup | 1 table visit |
| raster-record lookup | 1 table visit |
| payload borrow | 1 body invocation |
| canonical manifest | every declared mapping, metric, realization, and record exactly once |

No cache, speculative index, or collection was added to production. Optimized
macOS dynamic and static probes warm the runtime, reset malloc/calloc/realloc
interposition, then repeatedly exercise maximum mapping lookup, metric and
record access, empty and nonempty payload borrowing, canonical byte emission,
and SHA-256. Both reports contain `allocation_count=0` and the identical
checksum `856487783`. ARMv6 and nRF52840 compile the same collection-free paths
and layout probe; their hardware-free evidence makes no runtime-allocation,
deployment, flashing, or connected-target claim.
