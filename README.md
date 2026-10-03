# GiftUI

GiftUI is a SwiftUI-inspired declarative UI framework for Linux and embedded
Swift targets. Its MVP is validated by one substantially shared low-frequency
digital Signal Analyzer across macOS dynamic/static, Raspberry Pi 1/Linux, and
nRF52840 Embedded Swift configurations.

## Current implementation state

All fifteen MVP Specifications are implemented under the recorded maintainer
approvals. The framework includes declarative views, layout, text and opaque
color rendering, observable state, interaction, Canvas drawing, runtime
profiles, backend integration, and target-host configuration. The
[Specification portfolio](docs/roadmap/MVP_SPECIFICATION_PORTFOLIO.md) links
the governing contracts and their current lifecycle states.

The [iteration closeout](Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md)
records 72 passing hardware-free checks across all four profiles, reviewed
pixel references, and connected target observations. SPEC-001, SPEC-011, and
SPEC-015 close with explicit maintainer-approved exceptions: Pi and nRF
cadence fails, and complete connected input, fault/recovery, trace, and
sustained-load evidence remains incomplete. This closes the current iteration;
full measured MVP conformance remains outstanding. Its numbered scope is
[ITERATION-001: GiftUI MVP](docs/iterations/iteration-001-mvp.md).

Follow-up is preserved in [Pi performance](docs/future-work/fw-027-pi-performance-investigation-resumption.md),
[macOS pointer validation](docs/future-work/fw-031-macos-connected-pointer-validation-resumption.md),
[nRF performance](docs/future-work/fw-032-nrf-performance-improvement.md), and
[connected validation](docs/future-work/fw-033-connected-validation-follow-up.md).

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

The GiftUI application shares its domain, data, and presentation under
`Sources/SignalAnalyzerDomain`, `Sources/SignalAnalyzerData`, and
`Sources/SignalAnalyzerPresentation`. The root package provides
`SignalAnalyzerMacOSDynamic`, `SignalAnalyzerMacOSStatic`,
`SignalAnalyzerRaspberryPiARMv6`, and the `SignalAnalyzerNRF52840HostOracle`
validation executable. The nRF production application is
`firmware/nrf52840/applications/signal-analyzer-static`.

The separate [macOS SwiftUI reference](demo/SignalAnalyzer/README.md) remains
comparison evidence. Application acceptance and its closeout exceptions are
recorded in [SPEC-001 conformance](docs/conformance/spec-001-conformance.md).

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
- [numbered iteration scopes](docs/iterations/README.md)
- [feature lifecycle](docs/engineering/FEATURE_LIFECYCLE.md)
- [AI agent rules](docs/engineering/AI_AGENT_RULES.md)
- [code style](docs/engineering/CODE_STYLE.md)
- [feature manifest](docs/features.yaml)
- [SPEC-002 implementation plan](docs/implementation-plans/spec-002-implementation-plan.md)

Accepted ADRs and approved, implementing, or implemented Specifications are authoritative.
Draft, proposed, review, superseded, legacy, deferred, and Spike material is
not implementation authority.

## Historical proof of concept

The retired implementation and mixed legacy documents remain recoverable from
the immutable annotated `PoC` tag. Their verified tag object, commit, tree, and
retrieval commands are recorded in the
[proof-of-concept historical baseline](docs/engineering/POC_HISTORICAL_BASELINE.md).
No historical file was copied into an active archive directory.
