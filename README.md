# GiftUI

GiftUI is a SwiftUI-inspired declarative UI framework for Linux and embedded
Swift targets, with macOS development and validation configurations. It provides
views, layout, text and opaque color rendering, observable state, interaction,
Canvas drawing, and dynamic and static runtime profiles.

For the long-term destination, read the [vision](docs/VISION.md). For the values
guiding design choices, read the [principles](docs/PRINCIPLES.md). This README
covers the current implementation, validation status, and repository workflows.

## Project status

GiftUI is under active development. The Signal Analyzer reference application
exercises a substantially shared UI across macOS dynamic/static, Raspberry Pi
1/Linux, and nRF52840 Embedded Swift configurations. Backend integration and
target-host configuration connect the framework to those environments.

The [MVP iteration](docs/iterations/iteration-001-mvp.md) closed in October 2026
with recorded exceptions. Its [closeout evidence](Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md)
records hardware-free checks and connected-target observations. Full measured
MVP conformance remains outstanding: Pi and nRF timing requirements were not
met, and some connected input, fault/recovery, trace, and sustained-load
validation remained incomplete at closeout.

Subsequent work is tracked in [Runtime Memory and Efficiency](docs/iterations/iteration-003-dev-ux-improvement.md)
and [Backend and Application Integration](docs/iterations/iteration-004-backend-and-application-integration.md).
The [feature manifest](docs/features.yaml) links current lifecycle states and
governing artifacts. Historical closeout results do not establish conformance
of later changes.

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

The package's minimum macOS deployment target is macOS 26.0 for both macOS
profiles. Host development and macOS profile checks require macOS 26 and Xcode
26 or newer. macOS 15 deployment support was dropped by maintainer approval on
2026-11-09. This does not change the Raspberry Pi or nRF52840 targets.

Each invocation keeps reports under `.build/test-reports/<selection>/run-*`.
`latest-<selection>.txt` points atomically to the last finished invocation,
including failures. `metadata.txt`, `results.tsv`, logs and `child-reports.tsv`
retain run status, interrupted checks, newly published child identities and
latest-pointer observations (which can include older reports). Incomplete child
staging directories are retained and listed separately. Invocations and
standalone contract drivers serialize shared build/cache writers through
`.build/validation.lock`; nested checks inherit the lock. The lock file is never
removed, and process exit releases its kernel lock. There is no automatic report
pruning: archive or remove completed runs manually only when no validation is
active. A forcibly killed run retains its files even if its exit trap cannot run.

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

## Contributing and project documentation

Start with the [code style](docs/engineering/CODE_STYLE.md) and
[feature lifecycle](docs/engineering/FEATURE_LIFECYCLE.md). Repository-aware
agents also follow the [AI agent rules](docs/engineering/AI_AGENT_RULES.md).

- [Iteration scopes](docs/iterations/README.md): delivery goals and boundaries.
- [Architecture](docs/architecture/README.md): explanations of accepted decisions.
- [Documentation rules](docs/engineering/DOCUMENTATION_RULES.md): document roles,
  authority, and traceability.

## Historical proof of concept

The retired implementation and mixed legacy documents remain recoverable from
the immutable annotated `PoC` tag. Their verified tag object, commit, tree, and
retrieval commands are recorded in the
[proof-of-concept historical baseline](docs/engineering/POC_HISTORICAL_BASELINE.md).
No historical file was copied into an active archive directory.
