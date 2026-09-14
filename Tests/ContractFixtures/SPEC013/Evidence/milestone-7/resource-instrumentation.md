# SPEC-013 T7.2 Resource Instrumentation Evidence

Evidence kind: host compilation and source inspection. No simulator,
connected target, deployment, service restart, or flashing was used.

## Result

The profile-neutral snapshot contains bounded counters for all seven required
stack stages, heap allocation and peak bytes, dynamic allocator bookkeeping,
four separately excluded owner byte groups, generated Canvas code and greatest
capture, five linked-image values, and both timing workloads. Saturating
addition is reported explicitly rather than wrapping.

The macOS interposer uses a fixed 4,096-entry pointer registry without
allocating instrumentation storage. It measures allocation calls, live
reserved-byte high water, and reserved-minus-requested bookkeeping high water,
and reports registry saturation. Dedicated probes expose checked nanosecond
timing through `ContinuousClock` and optimized-IR `MemoryLayout` entry points
for the five Runtime Core contract aggregates. The method registry fixes twelve
measurement mechanisms and their truthful execution scopes.

T7.3 still owns optimized symbol/SIL/linked-image scans and the nRF/Raspberry
Pi target proofs. T7.4 still owns two pristine collections per profile. No
numeric profile result is claimed merely because the instrumentation compiles.
