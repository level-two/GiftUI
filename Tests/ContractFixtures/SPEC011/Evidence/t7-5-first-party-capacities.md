# SPEC-011 T7.5 First-Party Capacities

Date: 2026-09-14

All four generated Signal Analyzer presets carry first-party capacities of six
semantic action occurrences, six Interaction actions, six hit regions, six
Execution semantic actions, six committed actions, and one active normalized
input source. These are host-owned generated values, not Interaction defaults.
Startup validation requires each manifest count to equal its owning limit and
rejects malformed cardinality before normal execution.

The portable application corpus covers acquisition states idle, running,
stopped, and failed with exact Start/Stop enabled state. It separately covers
the one-, two-, and five-second windows and proves exactly the currently
selected window control is disabled.

```sh
source scripts/lib/swiftpm.sh
giftui_swiftpm --package-path "$PWD" --cache-root "$PWD/.build/codex-cache" \
  --disable-sandbox -- test --filter HostWorkloadStartupValidationTests
giftui_swiftpm --package-path "$PWD" --cache-root "$PWD/.build/codex-cache" \
  --disable-sandbox -- test --filter SignalAnalyzerViewHierarchyTests
```
