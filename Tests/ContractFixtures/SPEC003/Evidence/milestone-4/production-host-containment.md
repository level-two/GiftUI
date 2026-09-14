# SPEC-003 Production Host Containment Evidence

- Task: `T4.4`
- Evidence category: macOS host execution
- Owner boundary: `GiftUIHostConfiguration`
- Date: 2026-09-14

## Production sequence

`HostResidualFailureRouting` requires an `MVPHostInvariantFailureOwner` for
every residual-policy route. A defective table, a request missing mandatory
coordinator effects, an invalid policy input, or an unlisted policy result
executes this fixed fail-closed sequence:

1. prevent another normal run cycle;
2. construct the exact `.invariantViolation` / `.hostComposition` / `.runtime`
   / `.safetyNotProven` fact;
3. transition runtime operational health to `quiesced` with that fact;
4. propagate the same fact through the owner failure seam; and
5. invoke the configured fatal hook, when available.

The route does not call residual policy again. With no configured fatal hook,
steps 1 through 4 remain mandatory and unchanged.

## Reproducible checks

```text
scripts/format-swift.sh
swift test --filter HostResidualFailureRoutingTests
swift test --filter GiftUIHostConfigurationTests
```

The focused suite passed 6 tests, including all nine missing-effect branches,
all nine valid policy routes, defective-table and unlisted-selection controls,
and diagnostic success/failure equivalence. Each fail-closed control asserted
the exact ordered event transcript and rejected three later normal-cycle
attempts.

The complete `GiftUIHostConfigurationTests` suite passed 139 tests. This is
host execution evidence; it makes no connected-target claim.
