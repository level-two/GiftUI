# Host failure adapter and startup policy routing

`HostFailureAdapter` preserves every SPEC-015 configuration payload long
enough to select its exact SPEC-003 fact. Host-owned failures use the required
condition, host-composition origin, runtime scope, and containment. All seven
SPEC-013 validation errors, all nine SPEC-005 errors, and all fourteen
SPEC-004 unavailability families retain their focused mappings.

`FixedMVPHostResidualPolicyTable` is total over all nine host contexts and
shares the same canonical row function used during validation. The concrete
policy returns each fixed selection. Focused tests construct a valid policy
input for every row and verify the exact selection.

Startup routing constructs no policy input for success, a defective policy
table, or an ordinary failure whose projections have not yet been discarded.
After discard, it constructs exactly one `startupValidation` input with the
mapped failure, `quiesceAffectedScope`, ordinal zero, and limit one. This is
partial T4.2 evidence; operational mandatory-effect ordering, no-policy rows,
diagnostic fault injection, and fatal-hook bypass remain with T5.3/T5.5.

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
