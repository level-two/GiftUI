# T4.3 Flexible Spacer Evidence

Stack measurement recognizes flexibility only for unmodified children after
transparent structural flattening. It includes every `minLength` in the base
extent, preserves minimums when the main proposal is absent or too small, and
distributes positive extra space by quotient plus one-unit source-order
remainders. The assigned spacer cross extent is the stack's resolved cross
extent.

Standalone spacers and any spacer carrying a modifier measure as ordinary
zero-size content. Focused tests also prove that a capped parent never
compresses spacer minimums or assigns negative space.

Reproduce with:

```sh
swift test --filter LayoutStackTests
```
