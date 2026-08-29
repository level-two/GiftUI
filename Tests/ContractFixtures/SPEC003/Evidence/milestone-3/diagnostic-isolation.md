# SPEC-003 Milestone 3 Diagnostic-Isolation Evidence

Plan task: `T3.3`

Date: 2026-08-29

## Implemented boundary

`GiftUIDiagnosticProjector` is a generic downstream adapter. It applies the
core `GiftUIDiagnosticSelection` before invoking the supplied record builder,
then passes a selected record to a statically composed sink. The sink result is
reduced only into four optional saturating `UInt32` counters. The projector has
no input or output that can replace an outcome, mutate health, alter a
coordinator input, rewrite residual-policy input, or select a policy result.

## Configuration matrix

The focused test matrix covers:

- omitted diagnostics through the correctness-only baseline;
- enabled delivery and accepted counting;
- source filtering with zero record constructions and zero sink calls;
- sink filtering after one selected construction;
- explicit dropped and failed sink results;
- repeated accepted counting;
- first-party buffer saturation and drop-new accounting; and
- saturation of every optional delivery counter.

After every configuration, the fixture reconstructs and compares one
normalized snapshot containing the outcome, operational health, coordinator
fact, residual failure, residual context, allowed dispositions, attempt
ordinal and limit, and policy result. Every snapshot equals the omitted-
diagnostics baseline.

## Reproducible checks

```text
$ swift test --filter GiftUIFailureDiagnosticsTests
Executed 5 tests, with 0 failures
exit 0
```

The repository fast gate and the four-capacity diagnostic-buffer matrix are
run before the task commit so the same isolation suite also compiles and passes
with 0, 8, 16, and 64 record branches.
