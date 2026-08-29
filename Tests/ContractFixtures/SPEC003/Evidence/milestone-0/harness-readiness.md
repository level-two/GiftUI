# SPEC-003 Milestone 0 Harness Readiness

## Evidence Identity

- Repository revision: `63fc738e949293874838c3c63acd0371a7002d28`
- Working tree before and after execution: clean
- Host: arm64 macOS
- Compiler: Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`)
- Compiler SHA-256:
  `2ed38571e92c0283091838c1649e27650ad9c99950288e883c7b2dc6c4ce89fb`
- Target: `arm64-apple-macosx26.0`
- SDK: macOS 26.5
- Profile: `macos-dynamic`
- Optimization: `-O -whole-module-optimization`

This is hardware-free host evidence. It makes no Raspberry Pi, nRF52840,
connected-target, deployment, service-restart, or flashing claim.

## Commands and Results

The following commands ran from the repository root at the clean revision:

```sh
git status --porcelain
scripts/contracts/run-spec-003.sh --profile macos-dynamic
scripts/test.sh
git rev-parse HEAD
git status --porcelain
```

Both status commands produced no output. The standalone driver exited zero and
recorded `repository_dirty=false`, the revision above, complete commands,
checked-in input hashes, compiler path/hash/version, candidate module/library
hashes, and `exit_code=0` under
`.build/contract-reports/spec-003/macos-dynamic/`.

The no-argument aggregate exited zero with these explicit results:

| Gate | Exit |
| --- | ---: |
| Governance validation | 0 |
| Driver registry validation | 0 |
| Root Swift tests | 0 |
| SPEC-002 macOS dynamic driver | 0 |
| SPEC-003 macOS dynamic driver | 0 |

The root suite compiled `GiftUI`, `GiftUIFailureCore`, and their focused test
targets and executed 17 tests with zero failures: 16 Foundation tests and the
failure-core leaf import test.

## Boundary Results

The standalone SPEC-003 log recorded:

```text
SPEC-003 fixture manifest check passed: 4 fixtures.
SPEC-002 dependency check passed: 4 targets, 2 direct edges, acyclic.
SPEC-003 dependency check passed: 2 active and 1 reserved targets.
SPEC-003 Core boundary check passed: no re-export, upward import, or forbidden product link.
```

The ordered compile-fixture results were:

| Fixture | Expected result | Observed result |
| --- | --- | --- |
| `import-failure-core` | compile | compiled |
| `forbidden-giftui-import` | reject | rejected with `no such module 'GiftUI'` |
| `forbidden-execution-import` | reject | rejected with `no such module 'GiftUIFailureExecution'` |
| `forbidden-diagnostics-import` | reject | rejected with `no such module 'GiftUIFailureDiagnostics'` |

The dependency-checker regression inputs also rejected an unknown owner and an
`OwnerA -> OwnerB -> OwnerA` cycle. The future `GiftUIFailureExecution` target
remained absent and reserved behind SPEC-009.

## Milestone Disposition

Milestone 0 is ready for semantic implementation. The checked-in package has
an empty importable `GiftUIFailureCore` leaf, an exact acyclic graph, a focused
test target, an ordered fixture contract, and a registered standalone
four-profile driver. Cross-profile resource and semantic conformance remain
later plan work and are not claimed by this transcript.
