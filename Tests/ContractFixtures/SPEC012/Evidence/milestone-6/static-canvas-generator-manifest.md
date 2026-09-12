# SPEC-012 Static Canvas Generator Manifest Evidence

Plan task: `SPEC-012 T6.1`

The checked source-analysis descriptor contains three syntactic Canvas
expressions in canonical order. Lowering assigns IDs `1`, `2`, and `3`, and
the manifest's switch-coverage sequence contains exactly those IDs. The
largest fixture capture record is 12 bytes; this is an artificial contract
fixture value, not a production limit or resource claim.

Four occurrences map to the three expressions. `trace-blue` and `trace-green`
reuse callable ID `2` while retaining distinct capture-record identities and
distinct captured values. The checker reconstructs all field offsets, record
sizes, IDs, switch coverage, and occurrence mappings from the ordered input
and rejects any checked-manifest drift.

Reproduce from the repository root:

```text
scripts/contracts/check-spec-012-static-canvas-manifest.rb
scripts/contracts/check-spec-012-harness.rb
scripts/contracts/run-spec-012.sh --profile macos-static
```

T6.1 establishes only the generator handoff. Generated Swift table dispatch,
negative build-time rejection cases, production storage/limits, destruction,
and resource evidence remain T6.2-T6.5 work through SPEC-013/015 ownership.
