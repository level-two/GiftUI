# SPEC-012 Drawing Limits and Fixture Storage Evidence

Plan task: `SPEC-012 T3.1`

`DrawingLimits` rejects every nonpositive field independently and rejects a
normalized-operation limit below the plan-stroke limit. Equality at that
relation is admitted. `StaticCanvasLimits` rejects either zero field and admits
the minimum positive pair.

The optimized layout probe passes on macOS dynamic/static, Raspberry Pi ARMv6,
and nRF52840 Embedded Swift. `DrawingLimits` is 20 bytes and
`StaticCanvasLimits` is exactly 4 bytes on every compiler.

Focused fixture storage establishes two bounded identity representations for
later workspace tests: a capacity-checked dynamic buffer and a four-slot inline
static buffer. Both admit a count equal to capacity, reject the first excess
without mutation, preserve order, and return `nil` at the count boundary.

Reproduce from the repository root:

```text
swift test --filter DrawingValueTests
scripts/contracts/check-spec-012-value-profiles.sh --profile <profile>
```
