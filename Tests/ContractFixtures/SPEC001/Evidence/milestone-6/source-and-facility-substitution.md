# SPEC-001 Milestone 6 — Source and Required-Facility Substitution

`DeterministicSignalDataSourceTests.sourceSubstitution` replaces the
deterministic mock with an independent `SignalDataSource` fixture at the
existing `DefaultSignalAcquisitionRepository` initializer. The repository,
Domain use cases, Presentation admission adapter, ViewModel, and portable
`SignalAnalyzerView` require no source-specific branch or edit. The fixture
transition reaches the same capture publication contract through that shared
owner chain.

`HostResidualPolicyTableValidationTests.validationAccessLedgerStopsAtEveryFirstFailure`
independently faults graph, runtime-profile storage, text resources, workload,
capability contributions, endpoint/payload bounds, action/model routing,
input/wake routing, and residual policy. Every fault returns at its owning
validation stage, records zero side effects, and proves no later facility was
read. A reduced or target-specific analyzer therefore cannot be published
after any required facility is absent or inconsistent.

Reproduce the focused evidence with:

```sh
swift test --disable-sandbox --filter sourceSubstitution
swift test --disable-sandbox --filter validationAccessLedgerStopsAtEveryFirstFailure
```

The four-preset comparison in
`Tests/ContractFixtures/SPEC015/Evidence/milestone-6/four-preset-comparison.md`
then verifies that source independence and fail-closed configuration do not
create target-specific semantic variants.
