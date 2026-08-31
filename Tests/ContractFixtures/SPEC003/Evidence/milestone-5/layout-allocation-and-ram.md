# SPEC-003 Milestone 5 Layout, Allocation, and Owned-RAM Evidence

**Task:** `T5.3`

**Recorded:** 2026-08-31

Each pinned profile compiler emits optimized target LLVM IR from the exact
production sources plus the Core and diagnostics layout probes. The checker
requires constant size, stride, and alignment results for all 23 concrete
Core/diagnostics values and fails the exact 2-byte condition identifier and
the 4-, 8-, 20-, and 24-byte maxima.

The contract defaults and named owned-state totals are:

| Profile | Buffer records | Named owned state | Limit |
| --- | ---: | ---: | ---: |
| macOS dynamic | 64 | 1,578 B | 2,048 B |
| macOS static | 16 | 426 B | 512 B |
| Raspberry Pi ARMv6 | 16 | 426 B | 512 B |
| nRF52840 Embedded | 8 | 234 B | 320 B |

The named total is exactly one `GiftUIOperationalHealth`, one
`GiftUIDiagnosticDeliveryCounters`, and one
`GiftUIFixedDiagnosticBuffer`. The target reports preserve every component's
layout and reject a wrong default capacity or an over-limit sum. Final-image
writable-section deltas, including equalized runtime/test support, remain the
separate matched-image proof required by `T5.4`.

Both optimized macOS profiles execute 100 warmups and 10,000 measured
iterations through construction, containment normalization, propagation,
health update/query, generic policy dispatch, and diagnostic selection. Their
identical result is:

```text
allocation_count=0
maximum_counted_steps=37
maximum_normalization_counted_steps=5
maximum_diagnostic_selection_counted_steps=8
checksum=1338630
```

This proves the zero-allocation static path, the 64-step correctness bound,
and both 8-step local bounds. ARMv6 and nRF results are optimized compiler/IR
evidence only; they perform no connected-target execution, deployment, service
restart, or flashing.
