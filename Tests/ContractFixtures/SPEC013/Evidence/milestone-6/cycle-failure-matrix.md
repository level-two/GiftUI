# SPEC-013 T6.3 Cycle Failure Matrix Evidence

Evidence kind: host execution and inspection. No simulator, connected target,
deployment, service restart, or flashing was used.

## Result

The shared complete-pipeline runner executes a 55-cell matrix: the exact
Semantic, Layout, Observable State, Interaction, and Drawing focused-owner
failure values are each injected at all eleven ordered pipeline stages.

Every cell preserves the first failure and its detecting stage, skips later
fallible work, performs the exact acquired cleanup actions once, records one
publication-sensitive disposition, finalizes once, and produces the required
dirty-state and wake result. Prepublication rows discard acquired candidates;
postpublication rows preserve the published revision and abort only candidate
routing. Canvas callable release is asserted whenever that cleanup obligation
was acquired. The separate mutation-state probe proves cleanup cannot replay an
already applied mutation.

## Reproduction

```sh
scripts/format-swift.sh
swift test --filter everyFocusedOwnerFailureAtEveryStageHasExactCleanupAndDisposition
swift test --filter RuntimeCoordinatorCleanupTests
scripts/contracts/check-spec-013-cycle-failures.rb
scripts/contracts/check-spec-013-harness.rb
```
