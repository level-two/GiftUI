# SPEC-004 Milestone 0 Harness Readiness

Plan task: `T0.5`

Date: 2026-08-30

Clean revision: `66921422be8f97aad2de47f3b03fb6b0045a0630`

## Clean-revision precondition

`git status --porcelain=v1` produced no output before the focused tests,
standalone driver, and top-level gate ran. The SPEC-004 driver independently
recorded `repository_dirty=false`, the same revision, and `exit_code=0`.

## Harness results

| Check | Result |
| --- | --- |
| Governance validation | passed: 6 features, 65 lifecycle artifacts, 9 repository skills |
| Driver registry | passed: 3 explicitly registered drivers |
| Exact package graph | passed: 9 targets, 7 direct edges, acyclic |
| SPEC-004 target boundary | passed: 2 active targets, 14 forbidden imports |
| Ordered compile fixtures | passed: 15 fixtures |
| Capability compiled boundary | passed source/interface imports, dependency scan, product links, and `GiftUI` non-re-export |
| Portable presentation scan | passed: 4 source files, zero capability or concrete-identity branches |
| Focused capability unit tests | passed: 1 test, 0 failures |
| Complete root tests | passed: 70 tests, 0 failures |
| Standalone SPEC-004 macOS dynamic command | passed |
| No-argument `scripts/test.sh` | passed every registered macOS-dynamic check |

The synthetic unknown-edge, cycle, and `deviceID` source cases each failed
with their expected diagnostic, proving those gates do not report success by
omission.

## Exact commands

```text
git status --porcelain=v1
git rev-parse HEAD
swift test --filter GiftUICapabilitiesTests
scripts/contracts/run-spec-004.sh --profile macos-dynamic
scripts/test.sh
```

The standalone driver report records Apple Swift 6.3.3 build
`swiftlang-6.3.3.1.3`, target `arm64-apple-macosx26.0`, SDK 26.5, release `-O`
with WMO, complete commands, compiler/input/image hashes, and deterministic
report roots.

## Disposition

SPEC-004 Milestone 0 is complete. The harness is ready for `T1.1` closed-
vocabulary declarations without importing Foundation, failure, runtime,
backend, platform, driver, host, or connected-hardware owners. This host
readiness record claims no ARMv6/nRF runtime behavior or connected-target
evidence.
