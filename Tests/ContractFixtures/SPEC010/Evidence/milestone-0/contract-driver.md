# SPEC-010 Contract Driver

Plan task: `T0.3`

Date: 2026-09-05

The registered driver exposes exactly:

- `scripts/contracts/run-spec-010.sh --profile macos-dynamic`
- `scripts/contracts/run-spec-010.sh --profile macos-static`
- `scripts/contracts/run-spec-010.sh --profile raspberry-pi-armv6`
- `scripts/contracts/run-spec-010.sh --profile nrf52840-embedded`

Each command validates SPEC-010's checked-in schemas, hashes every declared
input, records repository revision/dirty state, compiler identity, target,
optimization, full command transcript, and current portable `GiftUI` module.
The ARMv6 and nRF modes use repository-local pinned toolchains and report-local
compiler caches; they perform hardware-free cross-builds only.

The two macOS profiles also reproduce the approved borrowing-property source
blocker. Every profile sets `public_contract_compile=blocked`, lists exactly
OS-001 through OS-012 as `missing`, and fixes `evidence_complete=false`.
Passing the harness means that prerequisites and failure reporting are
reproducible; it does not mean the observable-state contract conforms.

Metadata fixes remote access, deployment, service restart, simulator
execution, connected-target execution, and flashing to `false`. No command
creates a macro target, observable-state owner, runtime profile, application
model, remote change, or connected-hardware claim.
