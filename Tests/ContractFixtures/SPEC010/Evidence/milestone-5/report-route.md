# SPEC-010 Report Route Evidence

`ObservableStateReportRoute` combines the existing bounded registration
lifecycle with one dirty bit and one semantic-wake bit. Its route remains
inactive while the noncopyable sink is transferred into the model and becomes
active only after the model returns the exact reserved attachment. An
attachment-time report poisons verification instead of activating the route.

During mutation, the first exact live report marks the owner dirty before
requesting `semanticDirty` and returns the paired sink/package outcomes
`dirtied` and `.success(.dirtied)`. Repeated reports return `coalesced`, allocate
no event record, and issue no additional wake. The exhaustive mapping fixture
covers all seven public sink outcomes and their exact `ObservableStateResult`.

The mutation helper borrows the installed sink only for the synchronous call:
a changed mutation reports before returning its outcome, while a proven no-op
returns without invoking the route. The registration lifecycle itself stores
only its bounded attachment and inactive/attaching/active/retired/shutdown
validation state—no sink, callable route, or report history.

Reproduce the focused evidence with:

```sh
swift test --filter ObservableStateReportRouteTests
scripts/contracts/check-spec-010-report-route.rb
scripts/contracts/run-spec-010.sh --profile macos-dynamic
scripts/contracts/run-spec-010.sh --profile macos-static
```
