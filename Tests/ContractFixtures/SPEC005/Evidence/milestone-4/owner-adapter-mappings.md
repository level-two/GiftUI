# SPEC-005 T4.1 Owner-Adapter Mapping Evidence

T4.1 adds a package-internal test fixture that imports exactly
`GiftUITextResources` and `GiftUIFailureCore`. It does not import diagnostics,
layout, rendering, runtime, backend, platform, or host modules.

The focused suite proves all nine local validation errors map exactly:

- schema, count, metrics, mapping, and raster-record errors become
  `.invalidValue/.hostComposition/.runtime/.contained`;
- identity, incompatible-view, and integrity errors become
  `.invalidIdentity/.hostComposition/.runtime/.contained`; and
- capacity becomes
  `.capacityExhausted/.hostComposition/.runtime/.contained`.

It also proves the exact layout/render invariant facts, preserves the
SPEC-002 arithmetic fact as
`.arithmeticOverflow/.foundation/.operation/.contained`, and maps required
render-realization loss to
`.requiredFacilityUnavailable/.rendering/.runtime/.contained`.

## Reproduction

```text
swift test --filter GiftUITextResourceOwnerAdapterTests
scripts/contracts/check-spec-005-owner-adapters.rb
scripts/contracts/run-spec-005.sh --profile macos-dynamic
```

The diagnostics test records every mapped fact into the configured diagnostic
buffer and re-evaluates all mappings unchanged. Package graph and source scans
also prove the contract leaf still imports no failure or diagnostic vocabulary.
This is test-only host evidence and creates no production layout, render, or
host API.
