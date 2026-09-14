# SPEC-015 Application Opportunity Integration Evidence

The focused `GiftUIHostConfigurationTests` fixture exercises the T5.1
application boundary through `HostApplicationOpportunityGate`.

- An application opportunity admits exactly one synchronous operation and
  rejects reentrant entry.
- Quiescence prevents later application delivery and cannot interrupt an
  executing opportunity.
- Both the same-thread fixture and the explicitly queued distinct-executor
  fixture construct the deterministic Signal Analyzer source, repository,
  observation use cases, admission adapter, root model, and fixed host fact
  storage.
- Both immediate repository callbacks stop at admission. The root model is
  unchanged until the later sealed mutation application.
- Both execution modes produce identical callback sequences, admitted facts,
  and final model state.

Reproduce with:

```sh
swift test --filter GiftUIHostConfigurationTests
```

This is hardware-free host-execution evidence. Concrete executable ownership,
source transition delivery, action dispatch, and four-preset normalization
remain later T5/T6 work.
