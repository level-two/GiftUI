# SPEC-004 Construction Instrumentation

The optimized macOS allocation probe constructs the complete typed capability
input family, fills all four role-addressed slots, records a duplicate, and
constructs each usable resolver-workspace capacity in a repeated measured
loop. A malloc/calloc/realloc interposer is reset after warmup and read before
printing so reporting allocations are outside the measured interval.

The same probe records size, stride, and alignment for every normative
SPEC-004 record ceiling. `check-spec-004-layout.rb` rejects missing, duplicate,
malformed, or over-ceiling rows. Cross-built profiles retain compile and image
evidence; the executable allocation observation is a macOS host claim only.
