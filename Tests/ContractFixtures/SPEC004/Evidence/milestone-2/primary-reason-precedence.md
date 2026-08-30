# SPEC-004 T2.4 Primary-Reason Precedence Evidence

The resolver owns one fixed-width primary-reason selector whose stage input is
internal and whose output remains the approved bounded unavailable value.

The table-driven corpus verifies:

- all 120 unordered pairs among the exact 16 typed-resolver precedence stages;
- both argument orders for every pair;
- all 55 pairs among the 11 candidate-specific stages in both orders;
- lowest-role duplicate/missing behavior;
- concrete top-level short-circuit interactions;
- reversed primary/alternate declarations;
- shared usage overflow before every capacity result; and
- raster before payload before in-flight capacity.

The two operation-set and two operation-stream positions retain distinct stage
ranks even though each pair maps to the same stable public reason. Raw adapter
malformation and extent-conversion stages remain in the separate T1.3 adapter
corpus and are not presented as typed resolver inputs.

Validated commands on 2026-08-30:

```text
swift test --filter GiftUICapabilitiesTests
scripts/contracts/run-spec-004.sh --profile macos-dynamic
scripts/contracts/run-spec-004.sh --profile macos-static
scripts/contracts/run-spec-004.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-004.sh --profile nrf52840-embedded
```

All commands passed. The normalized semantic corpus records stable 55-pair
candidate and 120-pair all-stage summaries and fails if a row is changed,
omitted, or reordered. Cross-target results are hardware-free evidence only.
