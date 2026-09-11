# T4.2 Proxy and Stack Evidence

The generic `LayoutEngine` now consumes the validated, preordered semantic
workspace in two phases. It measures `.proxy`, `VStack`, and `HStack`
bottom-up, stores one measurement per exact scope identity, places each scope
top-down, and hands the complete workspace to atomic publication.

The focused corpus covers empty and five-child stacks, absent axes, a
main-axis proposal smaller than the base extent, exact interior-only gaps,
overflowing child placement, inherited root clips, source ordering, and proxy
co-location with its single flattened child.

Reproduce with:

```sh
swift test --filter LayoutStackTests
swift test --filter GiftUILayoutTests
```
