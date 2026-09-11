# T8.2 Four-Profile Rendering Evidence

The four exact SPEC-008 commands passed against repository revision
`c98c420834f90820d655316ac470fad86d1d375b` with input-set digest
`4c33a13788ae2679549f0eef58103eb633374351a106f070cf02e28c6fec5695` and
shared run ID
`c98c420834f90820d655316ac470fad86d1d375b-4c33a13788ae2679`:

```console
scripts/contracts/run-spec-008.sh --profile macos-dynamic
scripts/contracts/run-spec-008.sh --profile macos-static
scripts/contracts/run-spec-008.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-008.sh --profile nrf52840-embedded
```

The reports recorded `repository_dirty=true` because this T8.2 evidence
instrumentation and note were the uncommitted task under test. Each profile
report includes the complete nested command transcript, declared-input SHA-256
inventory, compiler executable digest, SDK and target identity, 17 declaration
fixture results, and 13 optimized value-layout rows.

| Profile | Compiler and target | Optimization | Execution disposition |
| --- | --- | --- | --- |
| macOS dynamic | Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`), `arm64-apple-macosx26.0`, macOS 26.5 SDK | `-O -whole-module-optimization`, `GIFTUI_DYNAMIC_PROFILE` | host execution |
| macOS static | Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`), `arm64-apple-macosx26.0`, macOS 26.5 SDK | `-O -whole-module-optimization`, `GIFTUI_STATIC_PROFILE` | host execution |
| Raspberry Pi | Swift 6.3.2, `armv6-unknown-linux-gnueabihf`, pinned Bookworm ARMv6 SDK/destination | `-O -whole-module-optimization` | cross-build and inspection only |
| nRF52840 | Swift 6.3.2, `armv7em-none-none-eabi`, Zephyr SDK 0.17.4, Zephyr `3568e1b6d5cdd51a6b964a2a1d6d29200fea2056` | `-Osize -whole-module-optimization`, hard float | cross-build and inspection only |

All profiles recorded the same Signal Analyzer declaration and observation:

| Metric | Declared | Observed |
| --- | ---: | ---: |
| operations | 64 | 30 |
| positioned glyphs | 512 | 139 |
| clip depth | 16 | 4 |
| semantic scopes | 128 | 62 |
| layout scopes | 128 | 32 |
| traversal depth | 32 | 6 |
| text lines | 64 | 21 |
| foreground depth | 32 | 5 |

The logical caller-owned workspace was 109 of 352 bytes: 62 of 128 semantic
visit bytes, 32 of 128 layout visit bytes, and 15 of 96 foreground bytes. The
foreground capacity is exactly 32 three-byte `Color` slots. The maximum
recursive call-stack high-water was six frames, measured independently of the
caller-owned foreground stack. The concrete one-slot production workspace
probe occupied 22 bytes with stride 22 and alignment 2 on every compiler.

The optimized production entry allocated zero heap objects after warmup in
both macOS profiles. Optimized target SIL contained zero allocation
instructions for ARMv6 and nRF52840. The nine `ContinuousClock` samples in
nanoseconds were:

- macOS dynamic: 2500, 1125, 959, 916, 958, 917, 917, 875, 917
- macOS static: 2750, 1083, 1083, 1042, 1000, 958, 1000, 1000, 1041

Cross-target reports record zero required timing samples and
`cross-build-not-executed`; they make no connected-target performance claim.

| Profile | Code delta | Read-only delta | Initialized delta | Zero-initialized delta |
| --- | ---: | ---: | ---: | ---: |
| macOS dynamic | 201004 | 60095 | 4888 | 17408 |
| macOS static | 201004 | 60095 | 4888 | 17408 |
| Raspberry Pi ARMv6 | 254528 | 58066 | 9412 | 10292 |
| nRF52840 | 240 | 112 | 0 | 0 |

Each profile report contains the baseline and render image, linker-emitted
maps, defined-symbol inventory, section-delta table, finite-workspace report,
and allocation report. The nRF ELF additionally records ARMv7E-M,
VFPv4-D16, and `Tag_ABI_VFP_args: VFP registers`, proving the Cortex-M4F
hard-float calling convention.

The per-report acceptance disposition is fail-closed: RD-001 through RD-006
and RD-009 through RD-010 pass; RD-007 and RD-008 remain active until the
cross-profile comparisons and nRF inspection are independently closed by T8.3
and T8.4; RD-011 remains active through the T8.5 conformance handoff. No remote
access, deployment, service restart, simulator execution, connected-target
execution, or flashing occurred.
