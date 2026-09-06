# SPEC-009 Contract Driver

Plan task: T0.3

Date: 2026-09-06

The registered driver exposes exactly:

- scripts/contracts/run-spec-009.sh --profile macos-dynamic
- scripts/contracts/run-spec-009.sh --profile macos-static
- scripts/contracts/run-spec-009.sh --profile raspberry-pi-armv6
- scripts/contracts/run-spec-009.sh --profile nrf52840-embedded

Each command validates the frozen SPEC-009 fixture schemas and migration
inventory, hashes every declared input, and records repository revision and
dirty state, the pinned SPEC-002 compiler, SDK and target identity, the profile
optimization, and the exact command transcript. Raspberry Pi and nRF modes
run only repository-local toolchain diagnostics. No profile builds or
executes an execution target because `GiftUIExecution` and its required
`GiftUIRenderCore` dependency have not landed.

Every report lists EX-001 through EX-014 as missing and records the execution
target, production dependency checks, and target inspection as blocked.
Fixture cases, value layouts, allocation evidence, and acceptance evidence
remain missing; therefore evidence_complete=false. Passing this harness proves
that the current prerequisites and omissions are reproducible, not that any
execution behavior conforms.

Metadata fixes remote access, deployment, service restart, simulator
execution, connected-target execution, and flashing to false. The driver does
not create an execution, runtime-profile, endpoint, backend, platform, or
hardware implementation.
