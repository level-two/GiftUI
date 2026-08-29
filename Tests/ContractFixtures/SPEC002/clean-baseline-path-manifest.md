# SPEC-002 Clean-Baseline Path Manifest

This is the implementation-plan `T0.3` keep/rewrite/remove manifest. It is a
review record only; it does not execute or authorize the clean cut.

The manifest was prepared from the active index on 2026-08-29 after commits
`08548bf` and `150edba`. Any added, missing, renamed, or multiply classified
path stops `T0.4`/`T0.5` until this record is refreshed and confirmed.

## Disposition rules

1. `remove` applies only to the 175 exact newline-delimited paths in
   [`clean-baseline-remove-paths.txt`](clean-baseline-remove-paths.txt). The
   file is sorted, contains no duplicate path, and has SHA-256
   `181af546c12a4fcf861bd76511494fcef841974c6c41f79d0e6d3cacd83b1922`.
2. `rewrite` applies only to the exact paths in the next section. A rewrite
   path remains present but must lose the stated PoC coupling or active legacy
   link before the cut.
3. `keep` applies to every other tracked active path. No path in the remove or
   rewrite set can inherit `keep`.
4. Untracked generated state, `.toolchains/`, and `.build/` are outside the
   tracked clean-cut manifest and must remain ignored and unmodified by the
   cut.

The exact removal set consists of 106 `Sources/` files, 18 old `Tests/` files,
17 `ili9486` firmware files, 14 `kmrtm24024_spi` firmware files, 7 `skeleton`
firmware files, 11 legacy `docs/GiftUI_*.md` files, the tracked PoC SwiftPM
workspace file, and `scripts/nrf52840/compile-layer.sh`.

## Exact rewrite set

| Path | Required rewrite before removal |
| --- | --- |
| `Package.swift` | replace the PoC graph with the atomic minimal SPEC-002 package in `T0.7` |
| `README.md` | replace PoC products, commands, tree, and legacy links with the MVP baseline and historical pointer |
| `scripts/check-environment.sh` | remove “PoC A” framing while preserving the host diagnostic |
| `scripts/raspberry-pi/build.sh` | require an explicit current product unless running the retained probe |
| `scripts/raspberry-pi/deploy.sh` | require an explicit product or artifact; retain the `armv6l` safety gate |
| `scripts/raspberry-pi/toolchain.env` | remove the Thermostat product default while preserving exact Swift/SDK pins |
| `scripts/raspberry-pi/local.env.example` | remove the Thermostat example product |
| `skills/giftui-pi-build-deploy/SKILL.md` | remove the Thermostat hardware example; keep explicit-product and remote-change rules |
| `skills/giftui-nrf-build-flash/SKILL.md` | remove the historical Thermostat wording; keep explicit connected-board authorization |
| `docs/engineering/DOCUMENT_INVENTORY.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/proposals/proposal-002-signal-analyzer-reference-application.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/proposals/proposal-003-giftui-mvp-architecture-establishment.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/proposals/proposal-004-capability-system.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/rfcs/rfc-001-signal-analyzer-application-architecture.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/rfcs/rfc-002-giftui-mvp-layered-architecture.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/rfcs/rfc-003-deterministic-text-rendering-architecture.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/rfcs/rfc-004-run-cycle-and-frame-transaction.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/rfcs/rfc-005-failure-diagnostics-propagation.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/rfcs/rfc-006-capability-system-architecture.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/rfcs/rfc-008-observable-reference-state-architecture.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/specs/spec-002-portable-foundation.md` | replace the legacy proof-of-concept reference with the historical-baseline pointer |
| `docs/specs/spec-003-failure-outcomes-and-containment.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/specs/spec-006-declarative-view-semantics.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/specs/spec-007-layout.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/specs/spec-008-rendering.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/specs/spec-009-execution-cycle-and-frame-handoff.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/spikes/spike-002-nrf52840-capability-path-resource-evidence.md` | replace active legacy-document links with the historical-baseline pointer |
| `docs/spikes/spike-003-portable-observable-reference-state-feasibility.md` | replace active legacy-document links with the historical-baseline pointer |

The rewrite set and remove set are disjoint. These rewrites do not change
accepted decisions or approved contract text; they repair historical
references or remove obsolete operational defaults.

## Preserved environment audit

Every retained environment script or fixture below was inspected for old
GiftUI module imports, product names, source lists, firmware applications, and
architecture assumptions. The retained paths contain none of the searched PoC
names. Paths in the rewrite table are excluded until their rewrites pass the
same audit.

| Retained exact paths | Purpose and retention proof |
| --- | --- |
| `scripts/raspberry-pi/common.sh`, `env.sh`, `doctor.sh`, `setup-toolchain.sh` | project-local pin loading, environment activation, diagnostics, checksum-verified setup, ARMv6/Bookworm validation; no framework source or product list |
| `scripts/raspberry-pi/probe/Package.swift`, `scripts/raspberry-pi/probe/Sources/GiftUIToolchainProbe/main.swift` | hardware-free compiler/SDK probe only; no GiftUI import or application behavior |
| `scripts/nrf52840/common.sh`, `env.sh`, `doctor.sh`, `setup-toolchain.sh` | project-local Zephyr/SDK/Swift setup and diagnostics; no removed framework source list |
| `scripts/nrf52840/toolchain.env`, `requirements.lock`, `west.yml`, `local.env.example` | exact version/checksum/workspace pins and machine-local override template; default application is the retained hardware-free `probe` |
| `scripts/nrf52840/build.sh` | generic explicitly selectable application build plus ELF, VFP, heap, size, and artifact inspection; its only default is the retained environment probe |
| `scripts/nrf52840/flash.sh` | generic flash mechanics; already requires an explicit application and is never invoked by setup, doctor, build, or tests |
| `firmware/nrf52840/applications/probe/CMakeLists.txt`, `build-checks.conf`, `prj.conf`, `src/Probe.swift`, `src/main.c`, `src/stubs.c` | hardware-free Swift-to-Zephyr board/toolchain probe with no GiftUI implementation import |
| `skills/giftui-pi-toolchain/SKILL.md`, `skills/giftui-pi-toolchain/agents/openai.yaml` | repository-local ARMv6 toolchain workflow and safety rules |
| `skills/giftui-nrf-toolchain/SKILL.md`, `skills/giftui-nrf-toolchain/agents/openai.yaml` | repository-local nRF toolchain workflow and no-flash safety rules |
| `skills/giftui-pi-build-deploy/agents/openai.yaml`, `skills/giftui-nrf-build-flash/agents/openai.yaml` | generic skill metadata without old product or module assumptions |
| `scripts/validate-governance.rb` | current lifecycle/schema/link validation; added after the PoC tag and independent of removed implementation |

The audit search covered `PoC`, `Thermostat`, `ili9486`, `kmrtm24024`,
`skeleton`, `GiftUIExample`, `GiftUIRuntime`, `GiftUIBackend`,
`GiftUIPlatform`, `GiftUIInput`, and `GiftUIDisplay`. A match in a retained
environment path requires reclassification or an explained false positive.

## Preserved current work

All governed lifecycle artifacts, `docs/features.yaml`, engineering rules,
templates, roadmap, `.agents/`, post-tag `demo/SignalAnalyzer/`, governed
Spikes and `experiments/`, repository skills not listed for rewrite, `AGENTS.md`,
`LICENSE`, `.gitignore`, the SPEC-002 evidence directory, and the retained
environment paths above are `keep`. They are current authority, current
process infrastructure, post-PoC MVP application work, governed evidence, or
reusable environment capability. They are not removal candidates.

## Required verification before the cut

Before `T0.5`, compare the current tracked removal set byte-for-byte with
`clean-baseline-remove-paths.txt`, verify every rewrite is complete, verify no
remove path is absent or newly added, and verify every remaining active legacy
link targets the historical-baseline pointer rather than a removed local file.
The maintainer must confirm the exact removal list after `T0.4` adds ownership
and link-repair evidence.
