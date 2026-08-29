# Correctness-Path Instrumentation

The optimized macOS allocation probe compiles the production Core source with
testing visibility, warms generic metadata and runtime support, resets a
Darwin interposer that counts `malloc`, `calloc`, and `realloc`, and executes
10,000 construction, normalization, propagation, health, query, and generic
policy-dispatch iterations with diagnostics absent. It fails on any measured
allocation.

The Swift probe also counts the explicit contract-level branch, comparison,
increment, and store stages in the same path and fails above 64. This count
does not hide compiler/runtime calls: the ordinary driver still records and
audits the production Core undefined-symbol surface and records the probe's
full undefined-symbol surface. The probe executable intentionally retains
printing and failure-reporting allocation symbols after the measurement read;
their presence is visible in that report and their calls cannot affect the
captured count. Milestone 5 must still resolve the optimized final-image
disassembly and complete call graph before conformance.
