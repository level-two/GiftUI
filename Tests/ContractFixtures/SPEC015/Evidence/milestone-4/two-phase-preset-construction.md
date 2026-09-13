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

Focused tests cover invalid and valid construction ledgers, all nine owner
cardinality defects, report mismatch, endpoint mismatch, and teardown of every
rejected candidate. Owner/report mismatches preserve the host invariant route;
endpoint mismatches preserve the SPEC-014 construction-invariant route.

This is partial T4.1 evidence. The seam imports only focused value owners; the
four concrete target roots still need to supply their approved live-owner
factories and first-party construction functions without moving application or
platform ownership into `GiftUIHostConfiguration`.

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
