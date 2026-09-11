# Complete Failure Corpus Evidence

Implementation-plan task `T6.3` is complete. The producer now executes every
direct semantic and layout malformed-view family through the production entry
point, including missing values, duplicate identities, invalid arity, text
children, missing mappings, declared-count disagreement, bounds/clip/line/
glyph absence, and line/glyph index disagreement. Every row returns the exact
local invariant failure before `begin`, never discards, and resets once.

A second matrix independently drives operation, positioned-glyph, clip-depth,
workspace render, layout-scope, text-line, and sink-glyph one-over failures.
The existing focused rows supply semantic-scope, traversal-depth, sink-
operation, ordinal visit-set, workspace acquisition, resource compatibility,
begin and every post-begin refusal, pre/post-begin snapshot change, reentry,
reuse, and exact preflight-only visit counts.

The registered audit joins those rows with the seven-value owner mapping,
constructible precedence matrix, direct arithmetic mapping, all three
defensive checked-intersection sites, atomic recording preservation, and exact
begin/discard/reset behavior.

Run:

```sh
scripts/contracts/check-spec-008-failure-corpus.rb
scripts/contracts/check-spec-008-failure-precedence.rb
swift test --filter everyDirectSemanticAndLayoutMismatchFailsBeforeBegin
swift test --filter everyIndependentRenderAndStructuralCapacityFailsOneOverBeforeBegin
```
