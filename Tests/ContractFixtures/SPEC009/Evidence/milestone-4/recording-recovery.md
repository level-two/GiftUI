# SPEC-009 Recording Recovery Evidence

`RecordingDerivationRecovery` is an internal bounded failure seam for the five
pre-publication derivation boundaries: semantic expansion, layout, action-table
staging, routing, and immutable render-input validation. Each injected failure
records and then clears the complete accumulated partial-result set while the
previous published semantic and presentation revisions remain authoritative.

When the cycle has applied observable effects, every boundary returns a
failure summary with a dirty semantic disposition and no logical frame. The
shared wake accumulator requests exactly one coalesced `semanticDirty` wake.
Recovery cannot begin while that wake remains outstanding, so it is necessarily
a later idle opportunity rather than recursion from the failing cycle.

The recovery opportunity publishes from current state without incrementing or
replaying the already-applied effect count. A pre-publication failure before
any dirty work exists instead reports an unchanged disposition and requests no
dirty wake, matching the exhaustive terminal-state matrix.

Reproduce the focused evidence with:

```sh
swift test --filter RecordingDerivationRecoveryTests
scripts/contracts/check-spec-009-recording-recovery.rb
scripts/contracts/run-spec-009.sh --profile macos-dynamic
scripts/contracts/run-spec-009.sh --profile macos-static
```
