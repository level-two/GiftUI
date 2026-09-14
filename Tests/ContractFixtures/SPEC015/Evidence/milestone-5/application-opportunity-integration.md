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
- Both immediate bootstrap callbacks stop at admission. The root model is
  unchanged until the sealed bootstrap mutation application.
- Dispatching the start action through the application executor synchronously
  emits four capture transitions and the running-state callback. A subsequent
  scheduled source transition is also delivered through the executor. All six
  later facts stop at bounded admission, and all eight callbacks observe the
  unchanged initial model state.
- The six later facts are sealed and applied only after callback return. They
  produce the running state and the exact five-transition capture without
  callback-to-model mutation.
- Both execution modes produce identical callback sequences, admitted facts,
  and final model state.

Reproduce with:

```sh
swift test --filter GiftUIHostConfigurationTests
```

This is hardware-free host-execution evidence. Concrete four-preset ownership
and normalization remain Milestone 6 work.
