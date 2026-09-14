# Two-phase preset construction

`HostPresetBootstrap` consumes one inert validator and invokes `validate()`
exactly once. Invalid validation returns only the original staged validation
result: the live-owner factory is never called and no instance or borrow is
exposed.

After `.valid(report)`, the bootstrap constructs exactly one candidate instance
and audits it before exposure. The audit must reproduce the complete immutable
assembly report, the exact inert endpoint and effective presentation, and one
of each retained owner: runtime, endpoint, resource package, capability
snapshot, root model target, action handler, application executor, wake
integration, and residual policy table. Any mismatch synchronously tears down
the candidate and returns no instance.

`SignalAnalyzerHostPresetConstruction` exposes four distinct entry points for
macOS Dynamic, macOS Static, Raspberry Pi Dynamic, and nRF52840 Static. Each
requires the validated report to name its exact preset before the live factory
can run. A mismatched report returns `.profileMismatch` with no construction,
audit, instance, or borrow.

Focused tests cover all four successful entry points, exact-once validation,
invalid and mismatched reports, all nine owner cardinality defects, report and
endpoint mismatch, and teardown of every rejected live candidate. The seam
imports only focused value owners; executable roots supply their approved live
factory without moving application or platform ownership into
`GiftUIHostConfiguration`.

Reproduction:

```sh
scripts/format-swift.sh
source scripts/lib/swiftpm.sh
giftui_swiftpm \
    --package-path "$PWD" \
    --scratch-path "$PWD/.build" \
    --cache-root "$PWD/.build/swiftpm-cache" \
    --disable-sandbox \
    -- test --filter GiftUIHostConfigurationTests
```
