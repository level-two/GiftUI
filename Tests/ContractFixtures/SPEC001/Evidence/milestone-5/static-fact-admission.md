# SPEC-001 Static Fact Admission Evidence

The Dynamic retained endpoint and the Static direct-dispatch endpoint now
delegate to one fixed `1/32/1` admission core. The Static handle contains only
a typed pointer to caller-owned storage, so generated roots retain ownership
of its address and lifetime without an existential registry or retained box.

The normalized transcript admits compact, reserved-failure, and snapshot
facts in physical-store-crossing order. Both profiles return sequences
`1,2,3`, seal the same kinds in that sequence, and yield value-equal facts.
Existing kernel fixtures continue to cover the full 28-fact burst, all 32
physical compact slots, fact 33, producer-category excess, post-seal deferral,
quiescence, discard, and nonwrapping exhaustion.

Reproduce with:

```sh
swift test --filter SignalAnalyzerHostFactAdmissionTests
swift test --filter HostSequencedFactAdmissionTests
```

This completes the Static admission portion of T5.1. The Static root wake,
mutation, and publication join is exercised by the integrated-cycle
transcript.
