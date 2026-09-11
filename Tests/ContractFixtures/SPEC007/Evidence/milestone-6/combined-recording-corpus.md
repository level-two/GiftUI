# T6.1-T6.4 Combined Recording and Failure Corpus

The canonical fixture registry now contains reciprocal cases for all nine
acceptance criteria. `LayoutCombinedCorpusTests` executes a single mixed
stack/overlay/spacer/frame/padding/text attempt with the SPEC-005 reference
metrics and asserts the complete begin, scope, line, glyph, and publish order.
Text events immediately follow their primitive scope and preserve exact
instance and glyph identities.

The focused stack and text goldens supply the numeric success corpus. The
counter, semantic-validation, collaboration/publication, geometry, and text
overflow suites form the failure corpus: invalid declarations, malformed
in-range access, invalid Unicode, exact/one-over capacities, reentry before
input, begin/stage/publish refusal, discard/reset behavior, and checked
arithmetic all fail before replacing prior current output.

Reproduce with:

```sh
swift test --filter GiftUILayoutTests
scripts/contracts/check-spec-007-harness.rb
```
