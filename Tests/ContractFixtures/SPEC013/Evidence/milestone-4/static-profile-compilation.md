# T4.6 Static Profile Compilation and Link

Date: 2026-09-12

The same production `GiftUIRuntimeStatic` sources and focused-owner module graph
compile for macOS Static and nRF52840 Embedded Swift. The macOS gate links the
complete SwiftPM test image with `GIFTUI_STATIC_PROFILE`. The nRF gate compiles
every production owner module with Embedded Swift, `-Osize`, whole-module
optimization, and the Cortex-M4F hard-float flags, then links a Zephyr image for
`nrf52840dk/nrf52840` without flashing or connected-hardware access.

The nRF compile exposed and corrected one transitive-import dependency in
`RuntimeStorageRegistry`: Embedded Swift requires direct imports for the
focused-owner value fields read by that file. The module contract permits those
existing Runtime Core edges and continues to reject Dynamic, backend, host,
platform, driver, and failure-adapter imports from Runtime Static.

Both optimized targets report the same exact value sizes:

| Value | macOS arm64 bytes | nRF ARMv7E-M bytes |
| --- | ---: | ---: |
| `RuntimeProfileLimits` | 87 | 87 |
| `RuntimeStorageAudit` | 160 | 160 |
| `StaticStructuralIdentity` | 4 | 4 |
| fixture `StaticCanvasOccurrence` | 17 | 17 |

The linked nRF ELF retains `giftui_spec013_static_profile_probe` and reports
ARMv7E-M, VFPv4-D16, and VFP-register arguments. The link fixture supplies the
same `posix_memalign` compatibility bridge used by earlier nRF evidence. T4.5's
later path-scoped SIL and call-symbol inspection distinguishes that platform
support from the specialized Runtime Static binding path and proves the latter
does not reference it.

Verification commands:

```text
scripts/contracts/check-spec-013-static-profiles.sh --profile macos-static
scripts/contracts/check-spec-013-static-profiles.sh --profile nrf52840-embedded
scripts/contracts/check-spec-013-module-contract.sh
scripts/contracts/check-spec-013-harness.rb
```

Result: both compile/link profiles passed with Apple Swift 6.3.3 on macOS and
the pinned project-local Apple Swift 6.3.2 nRF toolchain. No simulator,
deployment, connected-board execution, or flash was performed.
