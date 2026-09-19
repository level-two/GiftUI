# SPEC-013 T8.2 Downstream Integration

The production join remains layered through approved contracts:

- Runtime Core owns the profile-neutral pipeline and contains no backend,
  host, concrete-profile, policy, platform, or hardware selection;
- Host Configuration consumes Runtime Core and Backend Integration contracts
  without importing either concrete runtime profile; and
- the platform-specific Signal Analyzer host assembly selects Dynamic or
  Static profile owners and supplies generated numeric capacities and policy.

The audit and focused integration tests are reproduced with:

```text
ruby scripts/contracts/check-spec-013-downstream-integration.rb
swift test --disable-sandbox --filter RuntimeCompletePipelineTests
swift test --disable-sandbox --filter SignalAnalyzerIntegratedCycleTests
swift test --disable-sandbox --filter HostEndpointStartupValidationTests
swift test --disable-sandbox --filter GeneratedSignalAnalyzerPresetTests
```

The 2026-09-19 run passed and exercised accepted and retryable-refusal paths
through equal Dynamic and Static Signal Analyzer transcripts. It is host-side
integration evidence, not connected-target execution.
