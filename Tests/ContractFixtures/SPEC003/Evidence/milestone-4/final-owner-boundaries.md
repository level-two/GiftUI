# SPEC-003 Final Owner-Boundary Evidence

- Task: `T4.5`
- Evidence categories: package graph, source boundary, compiled host surface
- Date: 2026-09-14

## Exact owner set

The SPEC-003 boundary registry includes every current regular target whose
direct package dependencies contain `GiftUIFailureCore`: diagnostics,
execution correlation, display and backend integration, host configuration,
Signal Analyzer presentation, and all focused owner-adapter boundaries.

`check-spec-003-dependencies.rb` derives the actual regular-target consumer
set from the package dump and requires exact equality with the registered set.
For every registered production consumer it also rejects a failure-module
re-export and rejects `GiftUIFailureDiagnostics` on correctness paths.

## Reproducible checks

```text
swift package --disable-sandbox dump-package | scripts/contracts/check-target-dependencies.rb
swift package --disable-sandbox dump-package | scripts/contracts/check-spec-003-dependencies.rb
scripts/contracts/check-spec-003-execution-correlation.rb
scripts/contracts/check-spec-015-source-boundaries.rb
scripts/contracts/check-spec-015-host-surfaces.sh
```

Results:

- repository exact graph: 81 targets, 282 direct edges, acyclic;
- SPEC-003 registry: 24 active entries, zero reserved entries;
- execution-correlation dependency direction: passed;
- production host source boundary: 22 files, 10 registered imports, 183
  protected owner files, zero ambient lookup;
- compiled host package surface and two negative compile cases: passed.

The standalone SPEC-003 driver continues to compile the positive Core import,
reject higher imports, inspect the emitted Core interface and linked products,
and execute the exact package checks above in every profile. This evidence is
hardware-free and makes no connected-target claim.
