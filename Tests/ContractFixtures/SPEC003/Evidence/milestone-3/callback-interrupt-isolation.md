# SPEC-003 Milestone 3 Callback/Interrupt Isolation Evidence

Plan task: `T3.4`

Date: 2026-08-29

## Fixture boundary

The callback and interrupt sinks each retain one test-only
`DiagnosticAttackSurface`. Its authoritative fields are private to the
fixture; sinks can reach only three guarded attempt seams:

- semantic mutation;
- client-action invocation; and
- re-entry into the earlier outcome stage.

The fixture commits the outcome and advances to diagnostic delivery before
the sink is invoked. Every attempt after that transition is recorded as
rejected without changing the semantic value, action count, or forward-only
stage.

## Reproducible check

```text
$ swift test --filter \
    GiftUIFailureDiagnosticsTests/testCallbackAndInterruptSinksCannotGainSemanticAuthority
pass
exit 0
```

For each delivery context, the assertions require:

- one accepted optional diagnostic observation;
- three attempted and rejected authority violations;
- zero semantic mutations;
- zero client-action invocations;
- exactly one original outcome-stage entry;
- the stage remaining diagnostic; and
- a complete correctness snapshot equal to the pre-delivery baseline.

The repository fast gate and all four diagnostic-buffer capacity builds are
run before the task commit.
