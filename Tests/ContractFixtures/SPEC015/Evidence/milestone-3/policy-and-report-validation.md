# Policy and report validation

`HostResidualPolicyTableValidation` evaluates all nine finite contexts and
requires exact equality with SPEC-015's allowed set and fixed selection. It
does not call `GiftUIResidualFailurePolicy.disposition`. Focused tests replace
the allowed set and selection independently for every context and require
failure; the exact table passes and a malformed table reaches
`.policy/.incompleteFailurePolicy` only after every earlier stage succeeds.

Combined-invalid fixtures prove text precedes capability, capability precedes
endpoint, endpoint precedes action/model, action/model precedes input/wake,
and input/wake precedes policy. The one-shot guard separately proves every
repeat returns `.graph/.invariantViolation`. Exact success verifies every
assembly-report field: host/profile/audit, capability snapshot/effective value,
five Drawing operations, 35 sink operations, cardinality, three timing values,
28 compact facts, and three refusals.

This is partial T3.6 evidence. The complete poison-accessor ledger, combined
graph/runtime/workload precedence cases, no-partial-borrow proof, and explicit
owner/policy/diagnostic/clock/scheduler side-effect probes remain open and are
not claimed here.

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
