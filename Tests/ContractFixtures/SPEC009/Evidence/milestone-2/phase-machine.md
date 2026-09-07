# SPEC-009 Phase Machine Evidence

Plan task: `SPEC-009 T2.3`

`ExecutionPhaseMachine` is a finite package-scoped guard over the seven exact
phases and `ExecutionContext`. It owns no semantic, layout, rendering,
admission, runtime-profile, backend, host, or hardware behavior.

Focused tests evaluate all 49 ordered phase pairs and accept only the twelve
forward, skip, failure-finalization, and finalizing-to-idle edges fixed by
SPEC-009. Repeated, backward, skipped-invalid, and idle-invalid transitions
return `.invalidPhase` without changing context. Nested entry returns
`.reentrancyViolation`, preserves the active cycle and phase, and consumes no
new cycle identity. Idle cycle-ID exhaustion returns `.identityExhausted`
while preserving `cycle == nil` and `.idle`.

Publication and candidate recording are phase checked. Exact cycle, semantic,
candidate, and detecting phase correlation persists through finalization;
return to idle clears only cycle/candidate correlation and retains the latest
complete semantic revision. The source has no suspension point or prohibited
owner import.

Reproduce from the repository root:

```text
swift test --filter ExecutionPhaseMachineTests
scripts/contracts/check-spec-009-phase-machine.rb
```
