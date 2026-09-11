# T5.1 Scalar Decoding and Resource Evidence

Canonical text measurement borrows the validated metrics view throughout the
synchronous attempt and retrieves exactly its sole instance at index zero.
It walks Semantic Core scalar indices in source order, preserves CR, LF, and
CRLF semantics, maps supported scalars and exact replacement glyphs, and
retrieves every glyph metric from that same instance.

The measurement pass resets the validation probe's preliminary text counters
and reserves the proposal-dependent final scalar, line, and positioned-glyph
totals against the global limits. Relative line and glyph records stay in the
caller-owned workspace until top-down placement and atomic publication.

Reproduce with:

```sh
swift test --filter LayoutTextTests
```
