# SPEC-010 T2.3 Presentation-Fact Admission Evidence

`PresentationFactAdmissionAdapter` is the exact typed package façade over
SPEC-009 admission: one immutable `Sendable` fact enters and one unchanged
`ExecutionAdmissionOutcome` returns. The declaration owns no queue, capacity,
sequence namespace, alternate result, model, callable, task, platform object,
or mutation operation.

The focused fixture uses a six-byte value containing only fixed-width producer,
sequence, and payload fields. It forwards exactly once through
`ExecutionAdmissionSink.submit(stateChange:)` and preserves `.queued`,
`.capacityRefused`, `.unavailable`, `.invalidValue`, and `.invalidProvenance`
without reinterpretation. Every refusal retains no second copy and invokes no
direct model-mutation fallback.

The source audit fixes the single associated type and method signature, checks
unique ownership in `GiftUIObservableState`, rejects dynamic/reference payload
facilities and prohibited owners, and verifies the complete finite fixture
field set. Application executor entry and a concrete approved application fact
remain downstream responsibilities.
