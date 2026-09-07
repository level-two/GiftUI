# SPEC-009 Milestone 1 Execution Value Surface

Plan boundary: `SPEC-009 Milestone 1`

The complete focused `GiftUIExecution` value and protocol surface from T1.1
through T1.5 compiles under the four approved evidence configurations. The
profile check compiles `GiftUI`, `GiftUITextResources`, `GiftUIRenderCore`, and
`GiftUIExecution` as separate modules with the approved dependency direction,
then emits optimized target IR for 31 non-generic and finite-specialization
layout probes. This is host compilation or cross-build/inspection evidence;
it is not simulator or connected-hardware execution.

| Profile | Evidence kind | Value module | Layout rows | Result |
| --- | --- | --- | ---: | --- |
| `macos-dynamic` | host compile + optimized IR | complete | 31 | pass |
| `macos-static` | host compile + optimized IR | complete | 31 | pass |
| `raspberry-pi-armv6` | cross-build + optimized target IR | complete | 31 | pass |
| `nrf52840-embedded` | Embedded Swift cross-build + optimized target IR | complete | 31 | pass |

All four normalized layout reports have SHA-256
`3473779362d20acd54519bdfd62db9c344340d48f59f5a8444429fe4bf2abdc0`.
Notable measured sizes are `ExecutionContext` 22 bytes,
`ExecutionAdmissionOutcome` 26 bytes, `AdmissionSummary` 10 bytes,
`RunCycleFailure<ExecutionFixtureOwnerFailure>` 5 bytes,
`RunCycleSummary` 39 bytes, and
`RunCycleResult<ExecutionFixtureOwnerFailure>` 72 bytes. Every exact width and
ceiling in SPEC-009 passes on every profile.

The focused test target's existing row now names its direct `GiftUI` import in
addition to Execution and Render Core. The remaining incremental T0.2 rows are
otherwise intentionally unchanged. `GiftUIFailureExecution` and the fixture-
only adapter targets have no first
compiling source because their mapping/adapter work belongs to later plan
tasks. Adding empty package targets now would violate T0.2's no-placeholder
rule. `GiftUIExecution` and its fully declared focused test target remain the
only completed T0.2 slice.

Reproduce from the repository root:

```text
scripts/contracts/check-spec-009-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-009-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-009-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-009-value-profiles.sh --profile nrf52840-embedded
```

The registered `scripts/contracts/run-spec-009.sh --profile <profile>` driver
also invokes the same check and retains the module plus normalized layout
report in its content-addressed evidence directory. The fixture corpus,
allocations, coordinator image, and acceptance evidence remain fail-closed for
their later owning milestones.
