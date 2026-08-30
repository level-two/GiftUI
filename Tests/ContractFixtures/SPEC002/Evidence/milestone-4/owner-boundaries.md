# SPEC-002 Milestone 4 Owner-Boundary Evidence

**Task:** `T4.1`

**Recorded:** 2026-08-30

**Base revision:** `fda06c8ce001181d27c46806bcbaf76a42df60c6`

## Exact target graph

`Tests/ContractFixtures/SPEC002/target-dependencies.yaml` names every current
Swift package target, its target type, and every direct target dependency. The
checked-in graph contains 12 targets and 14 direct edges. The fail-closed graph
checker compared that allow-list with `swift package dump-package` and proved
both graphs acyclic:

```sh
swift package dump-package | scripts/contracts/check-target-dependencies.rb
```

Result: `SPEC-002 dependency check passed: 12 targets, 14 direct edges,
acyclic.`

## Protected owner fixtures and boundaries

The three protected foundational owners have positive import coverage and a
forbidden upward-import fixture in their owning fixture registries:

| Owner | Positive fixture | Forbidden fixture |
| --- | --- | --- |
| `GiftUI` | SPEC-002 `import-giftui` | SPEC-002 `forbidden-runtime-import` |
| `GiftUIFailureCore` | SPEC-003 `import-failure-core` | SPEC-003 `forbidden-giftui-import` |
| `GiftUICapabilities` | SPEC-004 `import-capabilities` | SPEC-004 `forbidden-giftui-import` |

The owner drivers additionally inspect source/interface imports. The SPEC-003
Core boundary check rejects a `GiftUI` import by `GiftUIFailureCore`; the
SPEC-004 boundary check rejects a `GiftUI` import by `GiftUICapabilities` and
rejects a capability reference or re-export from the `GiftUI` public and
package interfaces.

These exact commands passed on macOS with Apple Swift 6.3.3:

```sh
scripts/contracts/run-spec-002.sh --profile macos-dynamic
scripts/contracts/run-spec-003.sh --profile macos-dynamic
scripts/contracts/run-spec-004.sh --profile macos-dynamic
```

The checkout contained unrelated in-progress SPEC-004 T5.1 files when these
commands ran. They are not part of this task or its commit; the package graph,
protected-owner fixture registries, and boundary checkers recorded here were
unchanged by that work.

## Disposition

`T4.1` is complete. The allow-list must be refreshed again through `T4.3` when
later production owner targets land. This evidence does not claim re-export
inspection for every eventual target and does not advance SPEC-002 beyond
`implementing`.
