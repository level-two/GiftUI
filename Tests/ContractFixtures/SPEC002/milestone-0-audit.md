# SPEC-002 Milestone 0 Audit

This record is the final evidence for implementation-plan task `T0.8` and the
Milestone 0 exit gate.

## Clean package

- `swift package dump-package` reports exactly `GiftUI` and `GiftUITests`.
- `swift build --product GiftUI` succeeds.
- `swift test` executes the clean Foundation module smoke test successfully.
- `Package.swift`, `Sources/`, and the root test target contain no removed PoC
  module, product, application, compatibility, input-event, or arithmetic
  declaration.

## Retired paths and links

- The confirmed removal list still contains exactly 175 sorted paths with
  SHA-256 `181af546c12a4fcf861bd76511494fcef841974c6c41f79d0e6d3cacd83b1922`.
- 173 paths are absent; the stable module file and root test file were recreated
  from the clean contract and contain no old implementation.
- Every retired mixed legacy document is absent from `docs/` and recoverable
  from immutable tag `PoC` through
  `docs/engineering/POC_HISTORICAL_BASELINE.md`.
- No active Markdown link targets a retired local document.
- Removed implementation names remain only where governed migration,
  disposition, or historical evidence must identify what was removed; no
  active package, source, operational default, or README instruction uses one.

## Governance and environment

- `scripts/validate-governance.rb` passes.
- `git diff --check` passes.
- All retained shell scripts pass `bash -n`.
- The nRF doctor and hardware-free probe pass for `nrf52840dk/nrf52840` with
  Swift's `armv7em-none-none-eabi` module. The probe produced ELF, HEX, map,
  DTS, and report artifacts under `.build/nrf52840/probe/`; its measured
  footprint was 26,292 bytes of flash and 6,016 bytes of RAM.
- The Raspberry Pi doctor fails closed before compilation because the ignored
  project-local Swift 6.3.2 host toolchain is not installed. Its retained
  scripts still name only `armv6-unknown-linux-gnueabihf` and keep generated
  artifacts under `.build/raspberry-pi/`. Installing the toolchain and running
  the actual probe remains Milestone 5 work.
- No deployment, remote access, service restart, connected-board action, or
  flash was performed.

Milestone 0 proves a buildable clean host baseline and structural retention of
the cross-target probe workflows. Actual cross-profile compiler/probe evidence
remains scheduled for Milestone 5 and does not become connected-hardware
evidence.
