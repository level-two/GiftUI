# SPEC-004 Conjunctive Startup-Gate Evidence

- Task: `T4.4`
- Evidence category: macOS host execution over the four generated profile
  compositions
- Date: 2026-09-14

## Production gate

`CheckedMVPHostConfigurationValidator` enters RFC-002 B2 component-graph
validation first and SPEC-004 capability resolution at its own later stage.
Either failure returns a stage-specific invalid result with no
`HostAssemblyReport`. `HostPresetBootstrap` constructs and audits live owners
only from a complete valid report, so neither gate can substitute for the
other and no partial snapshot reaches a runtime owner.

The success report stores exactly one `CapabilitySnapshot`. Its
`rasterPresentation` equals the report's immutable effective presentation and
the validated inert endpoint projection. The validator is single-use; a
second validation attempt fails at the graph stage without resolving again.
Snapshot reads are direct stored-value access, covered by the existing 10,000
read/zero-resolver-invocation evidence.

## Reproducible checks

```text
scripts/format-swift.sh
swift test --filter HostPresetBootstrapTests
swift test --filter HostValidatorCapabilityTests
```

The bootstrap suite passed seven tests. Its new independent-negative fixture
proved both combinations:

- valid B2 plus missing capability contributor fails at `.capability` and
  performs zero construction/audit calls;
- missing B2 residual-policy role plus otherwise valid capabilities fails at
  `.graph` and performs zero construction/audit calls.

The valid control validates once, constructs and audits once, stores equal
snapshot/effective/endpoint values, and remains inactive until explicit
activation. The five capability-validator tests also passed, including all 24
contributor permutations and the no-second-resolution guard.

This is host execution evidence. The same generated four-profile projections
are covered by the SPEC-015 hardware-free matrix; it makes no connected-target
claim.
