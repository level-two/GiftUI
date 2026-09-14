# SPEC-011 T7.4 Signal Analyzer Dispatch

Date: 2026-09-14

`SignalAnalyzerAction` is the total six-code set `0...5`. The single immutable
`SignalAnalyzerActionHandler` switch maps Start, Stop, Clear, and the 1/2/5-
second selections to the one root `SignalAnalyzerViewModel`. Dynamic and
Static host adapters each construct that same handler and route through
`RuntimeInteractionDispatcher`; neither stores a model or introduces a
closure/default/profile-specific action path.

The 31 Presentation tests pass the total switch, observable reporting,
selected-window behavior, and root ownership. The 7 host dispatch tests run
all six codes through both profile adapters, reject invalid codes 6 and 65535,
cancel stale action/target generations, and compare replacement interleavings.

```sh
source scripts/lib/swiftpm.sh
giftui_swiftpm --package-path "$PWD" --cache-root "$PWD/.build/codex-cache" \
  --disable-sandbox -- test --filter SignalAnalyzerPresentationTests
giftui_swiftpm --package-path "$PWD" --cache-root "$PWD/.build/codex-cache" \
  --disable-sandbox -- test --filter SignalAnalyzerHostActionDispatchTests
```
