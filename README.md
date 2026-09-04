# GiftUI

GiftUI is a SwiftUI-inspired declarative UI framework for Linux and embedded
Swift targets. Its MVP is validated by one substantially shared low-frequency
digital Signal Analyzer across macOS dynamic/static, Raspberry Pi 1/Linux, and
nRF52840 Embedded Swift configurations.

## Current implementation state

The repository is on the clean MVP baseline governed by
[SPEC-002: Portable Foundation](docs/specs/spec-002-portable-foundation.md),
which is currently implementing. The root Swift package intentionally contains
only:

- the stable `GiftUI` library product and target;
- the `GiftUITests` Foundation test target; and
- SPEC-002 migration and contract evidence.

Portable geometry and normalized pointer declarations are introduced in the
next SPEC-002 milestones. Runtime, layout, rendering, backend, platform, and
host targets return only through their own approved Specifications and ready
implementation plans.

## Build and test

Run from the repository root:

```sh
swift package dump-package
swift build --product GiftUI
scripts/test.sh
```

`scripts/test.sh` is the single repository-level check entry point. With no
argument it runs the fast macOS-dynamic gate, including governance, root unit
tests, Swift formatting, and every registered contract driver. Select another
hardware-free profile explicitly (positionally or with `--profile`), or run
all four while preserving per-profile results:

```sh
scripts/test.sh --profile macos-static
scripts/test.sh --profile raspberry-pi-armv6
scripts/test.sh --profile nrf52840-embedded
scripts/test.sh --profile all-hardware-free
```

The aggregate runner never deploys, contacts a Raspberry Pi, or flashes a
connected nRF board. A missing local cross-toolchain is reported as a failed
profile rather than skipped.

Generated SwiftPM state remains under `.build/`. If a restricted environment
cannot use the user-level compiler cache, point `CLANG_MODULE_CACHE_PATH` and
`SWIFTPM_MODULECACHE_OVERRIDE` at task-specific directories under `/tmp`.

## Signal Analyzer reference application

The current macOS SwiftUI reference application is under
[`demo/SignalAnalyzer/`](demo/SignalAnalyzer/README.md). It preserves the MVP
domain, data, view-model, workload, and presentation evidence while GiftUI's
approved contracts are implemented. It is a separate package and does not
claim that the clean GiftUI root package can run the completed analyzer yet.

## Cross-target environments

Toolchains and SDKs are project-local; do not install them globally or change
Xcode's selected toolchain.

Raspberry Pi 1 / ARMv6 diagnostics:

```sh
scripts/raspberry-pi/doctor.sh
scripts/raspberry-pi/doctor.sh --probe
```

Application builds and deployment require an explicit current product:

```sh
scripts/raspberry-pi/build.sh --product <product>
scripts/raspberry-pi/deploy.sh --product <product>
```

Deployment is allowed only when a remote change was requested, and the script
requires the remote machine to report `armv6l`.

nRF52840 diagnostics and the retained hardware-free probe:

```sh
scripts/nrf52840/doctor.sh
scripts/nrf52840/doctor.sh --probe
scripts/nrf52840/build.sh --application probe
```

Flashing always requires an explicitly named application and an explicit
connected-board request:

```sh
scripts/nrf52840/flash.sh --application <application>
```

See the repository skills under `skills/` for the complete setup, diagnostic,
build, deploy, and flash workflows and their safety constraints.

## Engineering governance

Major features follow the gated Proposal → RFC → ADR → Specification →
Implementation Plan → Conformance lifecycle. Start with:

- [MVP scope](docs/MVP_SCOPE.md)
- [feature lifecycle](docs/engineering/FEATURE_LIFECYCLE.md)
- [AI agent rules](docs/engineering/AI_AGENT_RULES.md)
- [code style](docs/engineering/CODE_STYLE.md)
- [feature manifest](docs/features.yaml)
- [SPEC-002 implementation plan](docs/implementation-plans/spec-002-implementation-plan.md)

Accepted ADRs and approved or implementing Specifications are authoritative.
Draft, proposed, review, superseded, legacy, deferred, and Spike material is
not implementation authority.

## Historical proof of concept

The retired implementation and mixed legacy documents remain recoverable from
the immutable annotated `PoC` tag. Their verified tag object, commit, tree, and
retrieval commands are recorded in the
[proof-of-concept historical baseline](docs/engineering/POC_HISTORICAL_BASELINE.md).
No historical file was copied into an active archive directory.
