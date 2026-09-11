# Canonical Rendering Corpus Evidence

Implementation-plan task `T6.1` is complete. The canonical
`fixtures.yaml` manifest contains five field-by-field successful rendering
cases covering nested foreground/background scopes, sibling restoration,
source-order/ZStack painter order, exact RGB values, unchanged nested clips,
partial and off-surface clips, zero-area omission, both damage modes,
unclipped fill bounds, exact nominal text identities, occurrence-wide glyph
indices, baselines, non-empty groups, and empty-line omission.

The fixture field registry now includes the dense semantic/layout ordinal,
snapshot-version, and traversal-depth fields required by the approved
Specification. The harness verifies complete token/reference reciprocity.
The canonical-corpus audit additionally checks identity coverage, rectangle
shape, zero-origin surfaces, balanced recording/workspace lifecycles, exact
header totals, the two damage modes, the required geometry/text/style
distinctions, and the five corresponding executable Swift goldens.

Run:

```sh
scripts/contracts/check-spec-008-harness.rb
scripts/contracts/check-spec-008-canonical-corpus.rb
swift test --filter GiftUIRenderLoweringTests
```
