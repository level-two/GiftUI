# T4.4 Overlay and Padding Evidence

`ZStack` now gives every flattened child the same proposal, derives its ideal
size from the independent maximum child axes, caps its own bounds, and places
children in source order using the two alignment axes. It passes the inherited
logical clip unchanged.

Padding resolves edge-set and explicit-inset forms with checked inset sums,
floors present child proposals at zero, expands the child ideal size, caps the
padding scope to its parent proposal, and translates the child by leading/top
without adding a clip. Chained modifier tests prove outer-to-inner publication
and unmerged source-call ordering.

Reproduce with:

```sh
swift test --filter LayoutStackTests
```
