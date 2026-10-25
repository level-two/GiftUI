# P08 Native Static typed-backing decision — 2026-10-24

Eugene explicitly answered **“APPROVE TYPED-BACKING DESIGN DIRECTION”** to the
presented question: replace Native Static generic owning-model construction with
caller-supplied typed backing; retain shared generic scoped operations and all
ownership, lifetime, refusal, cleanup, Dynamic-control and strict zero-heap/resource
requirements; migrate construction coverage rather than hide failures.

The instruction also authorized faithful dated ADR/Specification/plan/manifest
transcription and one coherent implementation/conformance package. It does not
approve materially different APIs, storage representations, compiler settings or
resource limits. [ADR-041](../../adrs/adr-041-native-static-typed-model-backing.md)
extracts only this decision. SPEC-013 and SPEC-015 apply it while remaining
`implementing`; no implemented transition or waiver is authorized.

## Exact boundary

Native Static construction supplies stable, initialized, concrete typed model
backing and separate bounded ownership bookkeeping before lending them to the
existing checked scoped factory. Generic model operations and their common
behavioral oracles remain. Construction, refusal, populated-slot destruction,
early errors, repeated activations, callback retirement and backing-last lifetime
are still charged and tested. Dynamic controls and Embedded's existing owner path
remain unchanged; no public API removal/unavailability is introduced.

The accepted production baseline is `e55628c2`. Failed Model53 serialization and
Model54's earlier unapproved replacement are historical, not retroqualified. The
new approval changes the Native construction requirement, not those outcomes.
Remaining provider, layout/error/once, live-state, resource/profile/cold and P08
exit duties are not waived. P09 remains scheduled separately; unit FAILED /
Interaction UNEXECUTED stays explicit without a waiver. No A60/controller restart,
network/install/hardware action or renewed twelve-hour run is authorized.
