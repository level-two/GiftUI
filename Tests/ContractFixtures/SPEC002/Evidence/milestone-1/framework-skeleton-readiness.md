# SPEC-002 Framework Skeleton Readiness

This is the stable transcript for implementation-plan task `T1.6` and the
Milestone 1 exit gate. It was reproduced from the repository root on
2026-08-29 at committed revision
`ed0c43fdd7ea51d09d77fb70e240e6162162188b`.

## Clean checkout

```text
$ git status --porcelain
<no output>

$ git rev-parse HEAD
ed0c43fdd7ea51d09d77fb70e240e6162162188b
```

Ignored `.build/` and `.toolchains/` state is not source state and does not
alter the target or fixture inventories.

## Package and dependency baseline

```text
$ swift package dump-package | scripts/contracts/check-target-dependencies.rb
SPEC-002 dependency check passed: 2 targets, 1 direct edges, acyclic.

$ swift build --product GiftUI
warning: '--product' cannot be used with the automatic product 'GiftUI'; building the default target instead
Build of product 'GiftUI' complete!
```

The exact set is `GiftUI` with no direct target dependency and `GiftUITests ->
GiftUI`. The checker also validates target kinds and performs independent
cycle checks. No other target or product exists.

## Fixture mechanics and standalone driver

```text
$ scripts/contracts/check-fixture-manifest.rb
SPEC-002 fixture manifest check passed: 2 fixtures.

$ scripts/contracts/run-spec-002.sh --profile macos-dynamic
SPEC-002 macos-dynamic contract surface passed
```

The positive `import-giftui` fixture compiled against the freshly emitted
module. The `forbidden-runtime-import` fixture failed with the registered
fixed diagnostic `no such module 'GiftUIRuntimeDynamic'`; an unexpected
success or unrelated failure would have failed the driver. Its metadata
records Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`), target
`arm64-apple-macosx26.0`, macOS SDK 26.5, `-O`, whole-module optimization,
the dynamic profile flag, exact commands, repository revision, and exit 0.

## Root tests and repository gate

```text
$ scripts/test.sh
==> governance
pass: governance
==> driver-registry
pass: driver-registry
==> root-tests
pass: root-tests
==> SPEC-002-macos-dynamic
pass: SPEC-002-macos-dynamic
All macos-dynamic checks passed
```

The root SwiftPM test log records one executed Foundation smoke test with zero
failures. The ordered results contain governance, registry, root tests, and
the SPEC-002 macOS-dynamic driver, each with exit 0.

## Active-tree and retained-environment audit

The active `Package.swift`, `Sources/`, `Tests/GiftUITests/`, operational
scripts, and README contain none of the removed PoC product, application,
runtime, backend, platform, input, display, or compatibility names. The only
root package source and test files are their clean replacements. The exact
dependency checker makes every speculative new target fail closed.

All retained Raspberry Pi and nRF shell entry points pass `bash -n`, and both
doctor help entry points are callable. Their checked-in pins are:

```text
Raspberry Pi target: armv6-unknown-linux-gnueabihf
nRF board:           nrf52840dk/nrf52840
nRF Swift target:    armv7em-none-none-eabi
Zephyr:               4.3.0
Zephyr SDK:           0.17.4
```

The project-local Raspberry Pi Swift 6.3.2 toolchain is not installed, so its
actual compiler/probe evidence remains required by Milestone 5. The nRF
hardware-free SPEC-002 surface passed during `T1.4`, but this skeleton gate
does not promote that result to final cross-profile or connected-hardware
conformance. No deployment, remote access, service restart, or flash occurred.

Milestone 1 is ready. Substantive Foundation implementation may begin without
reintroducing a PoC compatibility surface or a later Specification's target.
