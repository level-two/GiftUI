# SPEC-004 Final Hardware-Free Matrix

Date: 2026-09-19

Reviewed revision: `383d1e72b398fedb0ffb85313526ccbcee8cf8e9`

The complete registered matrix was executed first:

```sh
scripts/test.sh all-hardware-free
```

That run completed every registered row. It identified an ambiguous SPEC-004
ARMv6 module lookup that counted the target module and a host-side
`Modules-tool` cache copy. The corrected driver requires the exact
`armv6-unknown-linux-gnueabihf/release/Modules/GiftUICapabilities.swiftmodule`
artifact. After the correction was committed, all four exact SPEC-004 commands
passed from a clean worktree:

```sh
scripts/contracts/run-spec-004.sh --profile macos-dynamic
scripts/contracts/run-spec-004.sh --profile macos-static
scripts/contracts/run-spec-004.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-004.sh --profile nrf52840-embedded
```

Every profile published immutable run ID
`383d1e72b398fedb0ffb85313526ccbcee8cf8e9-b55dbb156cbf7dac`.

| Profile | Result | Evidence classification |
| --- | --- | --- |
| macOS dynamic | pass | arm64 host compile and execution |
| macOS static | pass | arm64 host compile and execution |
| Raspberry Pi ARMv6 | pass | hardware-free EABI5 hard-float cross-build and inspection |
| nRF52840 Embedded | pass | hardware-free ARMv7E-M/VFP hard-float cross-build, link, and inspection |

The top-level aggregate remains nonzero because SPEC-011 deliberately fails
closed while its T7-T9 profile/conformance work is pending, and SPEC-007's nRF
driver currently has a downstream direct-compilation defect. Those rows are
reported as repository-wide observations; they are not substituted for the
four exact passing SPEC-004 results and do not create connected-hardware
evidence. No remote access, deployment, service restart, simulator, or flashing
occurred.
