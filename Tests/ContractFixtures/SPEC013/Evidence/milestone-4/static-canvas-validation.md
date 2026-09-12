# T4.3 Static Canvas Validation

Date: 2026-09-12

Static construction reuses Runtime Core's ordered startup validator after all
common limit, relation, presence, capacity, and byte-total checks. The Static
table gate requires a nonzero case count within the configured bound, exact
declared count and maximum ID, exactly one coverage entry for every dense ID,
and a present in-range capture size for every case.

The Static staging validator accepts only a nonzero in-range generated ID whose
reported capture byte count exactly matches that case. Zero, out-of-range, and
size mismatch return `RuntimeOwnerFailure.drawing(.invariantViolation)`. The
validator accepts no client-body or Canvas-invocation callback, and an
instrumented generated table records zero invocations during all staging
checks.

SPEC-012 remains the sole owner of generated-source rejection. Its existing
fail-closed generator check covers unsupported capture source and the other
thirteen typed rejection cases; Runtime Static adds no fallback grammar or
runtime box.

Verification commands:

```text
swift test --filter GiftUIRuntimeStaticTests
scripts/contracts/check-spec-012-static-canvas-manifest.rb
scripts/contracts/check-spec-013-static-generated-fixture.rb
scripts/contracts/check-spec-013-harness.rb
```

Result: eight focused Static tests passed under Apple Swift 6.3.3, including
eight independent startup-table faults and all three staging invariant classes.
The SPEC-012 manifest checker reproduced all 14 build-time rejection cases.
