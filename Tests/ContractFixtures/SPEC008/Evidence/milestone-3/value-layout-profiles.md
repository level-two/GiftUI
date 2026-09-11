# SPEC-008 T3.5 Value Layout Profile Evidence

`check-spec-008-value-profiles.sh` compiles the exact bounded rendering values
with the compiler, target, SDK, profile flag, and optimization mode for each of
the four SPEC-008 evidence profiles. LLVM IR supplies constant size, stride,
and alignment values for `Color`, `BoundedText`, `RenderLimits`,
`RenderWorkspaceCapacity`, `RenderWorkspaceVisit`,
`RenderSinkCapacity`, `RenderDamageMode`, `RenderPlanHeader`, `PositionedGlyph`,
`FillRectOperation`, `PositionedGlyphOperationHeader`,
`RenderProductionError`, and `RenderProductionResult`.

The checker enforces exact sizes for `Color` (3), `RenderLimits` (6),
`RenderWorkspaceCapacity` (8), `RenderWorkspaceVisit` (1),
`RenderSinkCapacity` (4), `RenderDamageMode` (1), and
`RenderProductionError` (1), plus the approved upper bounds for all remaining
values. Each report records the compiler path, digest and version, target, and
optimization mode beside its layout table and complete compiler commands.

Reproduce with:

```text
scripts/contracts/check-spec-008-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-008-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-008-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-008-value-profiles.sh --profile nrf52840-embedded
```

The ARMv6 and nRF52840 results are cross-compilation evidence only. They do not
claim connected-hardware execution, deployment, display validation, or
flashing.
