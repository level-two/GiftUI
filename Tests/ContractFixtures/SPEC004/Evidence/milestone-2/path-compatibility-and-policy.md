# SPEC-004 T2.2 Path Compatibility and Policy Evidence

The production capability leaf now contains one internal bounded candidate
evaluator layered over T2.1 arithmetic. It enumerates only the two declared
encodings and three declared submission lifetimes and retains no input or
operation stream.

Focused tests prove:

- the validation-only incompatible operation-stream fact has raw value `2`,
  cannot construct a requirement, and maps producer/candidate rejection to
  `.operationStreamMismatch`;
- operation-set, operation-stream, encoding, lifetime, handoff, arithmetic,
  capacity, and policy failures remain distinct;
- synchronous borrow permits only synchronous handoff, while synchronous copy
  and ownership transfer each permit synchronous or queued handoff;
- lifetime and handoff selection use raw-value order;
- preferred encoding wins only when its complete path conforms, otherwise a
  conforming allowed encoding is selected;
- disallowed realization or encoding returns
  `.policyHasNoConformingRealization` only after technical conformance; and
- preferred realization comparison is independent of candidate declaration
  order.

Validated commands on 2026-08-30:

```text
swift test --filter GiftUICapabilitiesTests
scripts/contracts/run-spec-004.sh --profile macos-dynamic
scripts/contracts/run-spec-004.sh --profile macos-static
scripts/contracts/run-spec-004.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-004.sh --profile nrf52840-embedded
```

All commands passed. Both macOS allocation probes report zero allocations
while exercising the compatibility evaluator. ARMv6 and nRF52840 results are
hardware-free compile evidence; this record claims no connected-hardware
execution, deployment, or flashing. The public resolver remains assigned to
T2.3 and is not claimed here.
