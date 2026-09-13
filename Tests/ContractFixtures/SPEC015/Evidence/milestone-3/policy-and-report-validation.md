# Policy and report validation

`HostResidualPolicyTableValidation` evaluates all nine finite contexts and
requires exact equality with SPEC-015's allowed set and fixed selection. It
does not call `GiftUIResidualFailurePolicy.disposition`. Focused tests replace
the allowed set and selection independently for every context and require
failure; the exact table passes and a malformed table reaches
`.policy/.incompleteFailurePolicy` only after every earlier stage succeeds.

The production validator now carries a bounded nine-bit access ledger with no
dynamic storage. A fixture fails at each stage and proves that the ledger is
the exact prefix ending at the first failure; every later stage remains a
poisoned, unread bit. Out-of-order entry fails without ledger mutation. The
one-shot guard proves every repeat returns `.graph/.invariantViolation`
without changing completed access evidence. Exact success verifies every
assembly-report field: host/profile/audit, capability snapshot/effective value,
five Drawing operations, 35 sink operations, cardinality, three timing values,
28 compact facts, and three refusals.

The validation-purity scan freezes the nine `enter` calls in raw-value order
and rejects policy-decision, owner-lifecycle, diagnostic, clock, or scheduler
references in the concrete validator. Its generic policy input exposes only
immutable table accessors, and its inputs contain descriptors rather than live
owners, so failure cannot expose a partial instance or borrow. The ledger's
`sideEffectCount` remains zero for every failure and success fixture.

Reproduction:

```sh
scripts/format-swift.sh
scripts/contracts/check-spec-015-validation-purity.sh
source scripts/lib/swiftpm.sh
giftui_swiftpm \
    --package-path "$PWD" \
    --scratch-path "$PWD/.build" \
    --cache-root "$PWD/.build/swiftpm-cache" \
    --disable-sandbox \
    -- test --filter GiftUIHostConfigurationTests
```
