# T8.1 Repository and Compiler-Surface Gate

The macOS dynamic top-level repository gate passed at revision
`8e65bb85bd089d41226ba949344b73249435384f`. It covered governance,
governance-tooling tests, Swift formatter lint, the contract-driver registry,
all 388 Swift tests, the diagnostic-buffer probe, and every registered
macOS-dynamic driver from SPEC-002 through SPEC-010. The registry resolves
SPEC-008 to `scripts/contracts/run-spec-008.sh` for all four profiles.

The SPEC-008 declaration and value-layout profile checks also passed directly
for macOS static, Raspberry Pi ARMv6, and nRF52840 Embedded. Each declaration
run accepted/rejected the same 17 public and negative compile fixtures. Each
layout run proved all 13 bounded values, including exact
`RenderWorkspaceCapacity` size 8. The macOS dynamic report recorded the
following representative optimized layouts:

| Value | Size | Requirement |
| --- | ---: | ---: |
| `Color` | 3 | exact 3 |
| `RenderLimits` | 6 | exact 6 |
| `RenderWorkspaceCapacity` | 8 | exact 8 |
| `RenderWorkspaceVisit` | 1 | exact 1 |
| `RenderSinkCapacity` | 4 | exact 4 |
| `RenderDamageMode` | 1 | exact 1 |
| `RenderProductionError` | 1 | exact 1 |
| `BoundedText` | 98 | maximum 100 |
| `RenderPlanHeader` | 38 | maximum 40 |
| `PositionedGlyph` | 12 | maximum 12 |
| `FillRectOperation` | 35 | maximum 36 |
| `PositionedGlyphOperationHeader` | 58 | maximum 60 |
| `RenderProductionResult` | 39 | maximum 44 |

Reproduce with:

```console
scripts/test.sh --profile macos-dynamic
scripts/contracts/check-spec-008-declaration-profiles.sh --profile macos-static
scripts/contracts/check-spec-008-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-008-declaration-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-008-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-008-declaration-profiles.sh --profile nrf52840-embedded
scripts/contracts/check-spec-008-value-profiles.sh --profile nrf52840-embedded
```

The cross-compilation results are compiler evidence only. They do not claim
execution on Raspberry Pi or nRF52840 hardware.
