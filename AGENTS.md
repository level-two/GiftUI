# GiftUI Agent Contract

## Repository workflow

- Run commands from the repository root.
- Keep the downloaded macOS compiler and cross-compilation SDK under
  `.toolchains/`.
- Keep generated Raspberry Pi builds and deployable artifacts under
  `.build/raspberry-pi/`.
- Do not run the Swift.org installer, install the ARMv6 SDK under `/opt`, or
  mutate Xcode/global Swift selection.

## Engineering governance

Before major feature design or implementation:

1. Read `docs/engineering/FEATURE_LIFECYCLE.md` and
   `docs/engineering/AI_AGENT_RULES.md`.
2. Read `docs/MVP_SCOPE.md` and identify the reference-application or stack
   validation requirement that makes the work necessary now.
3. Inspect `docs/features.yaml` and determine the feature's lifecycle stage.
4. Locate authoritative accepted ADRs and approved Specifications.
5. Treat draft, proposed, review, legacy, rejected, deprecated, and superseded
   documents as non-authoritative.

Do not infer human approval or change accepted architecture implicitly.
Preserve lifecycle traceability and update `docs/features.yaml` plus affected
cross-references when creating or superseding artifacts. Use the role-specific
skills under `.agents/skills/` for triage, authoring, review, implementation
planning, implementation design, execution, and conformance; detailed process
rules belong there and under `docs/engineering/`.

During any lifecycle or implementation work, capture valuable out-of-scope
ideas and intentionally postponed decisions through the repository's Future
Work, Exploration, and Spike track. Use
`.agents/skills/deferred-work-curator/SKILL.md`; do not expand MVP scope or
treat deferred artifacts and Spike code as authority.

## Raspberry Pi skills

- Use `skills/giftui-pi-toolchain/SKILL.md` for toolchain setup, environment
  activation, diagnostics, and the ARMv6 probe.
- Use `skills/giftui-pi-build-deploy/SKILL.md` for Raspberry Pi builds and
  deployment.

## nRF52840 skills

- Use `skills/giftui-nrf-toolchain/SKILL.md` for Embedded Swift/Zephyr setup,
  activation, diagnostics, and the hardware-free board probe.
- Use `skills/giftui-nrf-build-flash/SKILL.md` for nRF52840 firmware builds,
  artifact inspection, and explicit J-Link flashing.

## Stable commands

- `scripts/raspberry-pi/setup-toolchain.sh`
- `scripts/raspberry-pi/doctor.sh`
- `scripts/raspberry-pi/doctor.sh --probe`
- `scripts/raspberry-pi/build.sh --product <product>`
- `scripts/raspberry-pi/deploy.sh --product <product>`
- `scripts/nrf52840/setup-toolchain.sh`
- `scripts/nrf52840/doctor.sh`
- `scripts/nrf52840/doctor.sh --probe`
- `scripts/nrf52840/build.sh --application <application>`
- `scripts/nrf52840/flash.sh --application <application>`

## Safety

- The supported board target is Raspberry Pi 1:
  `armv6-unknown-linux-gnueabihf`.
- Do not substitute an ARMv7 or AArch64 SDK.
- Do not deploy or restart a remote service unless the user requested a remote
  change.
- Before deploying, require the remote machine to report `armv6l`.
- The supported Nordic board is `nrf52840dk/nrf52840`. Swift uses its bundled
  `armv7em-none-none-eabi` module with Zephyr's Cortex-M4F hard-float flags;
  require ELF verification of the VFP calling convention.
- Keep nRF52840 toolchains under `.toolchains/nrf52840/` and generated firmware
  under `.build/nrf52840/`.
- Never flash an nRF52840-DK unless the user requested a connected-board
  change.
