# SPEC-003 Milestone 3 Diagnostic Buffer Evidence

Plan task: `T3.2`

Date: 2026-08-29

## Implemented boundary

`GiftUIFailureDiagnostics` is an optional downstream target importing only
`GiftUIFailureCore`. No correctness-bearing target imports it. Its generated
`GiftUIFixedDiagnosticBuffer` stores records inline, preserves admitted order,
drops new records after saturation, and saturates its `UInt32` dropped-record
counter. The capacity-zero branch contains no record fields.

The developer build uses the macOS dynamic default of 64 records. Explicit
compile-time selections provide the approved 0, 8, 16, and 64 record layouts;
conflicting selections fail compilation.

## Reproducible checks

```text
$ ruby scripts/contracts/generate-spec-003-diagnostic-buffer.rb --check
exit 0

$ scripts/contracts/check-spec-003-diagnostic-buffer.sh
SPEC-003 diagnostic buffer branches passed: 0, 8, 16, and 64 records.
exit 0
```

The branch check runs the focused buffer suite once per capacity. Each run
admits through `GiftUIDiagnosticSink.consume`, reads every admitted record in
order, attempts one additional admission, compares the retained values before
and after the drop, and forces the optional loss counter through saturation.
It separately compiles a conflicting 8/16 selection and requires the exact
fail-closed diagnostic.

The root Swift package suite also passed with 61 tests and zero failures before
this record was written.
