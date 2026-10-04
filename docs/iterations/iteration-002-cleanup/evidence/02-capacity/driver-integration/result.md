# Capacity owner-driver integration — 2026-10-05

SPEC-011 T10.2 maintained fixture/driver integration is implemented; final profiles remain pending. Register each of the five unequal stores across recording/Dynamic/Static compositions and the missing-generation precedence case in candidates.yaml. The owner driver explicitly selects both real-store tests with its existing profile differential corpus. Six Swift Testing tests (including two five-case unequal-store tests and the three-case partial-failure differential) pass.

Combined attempt `run-KacCl0NG` exposed a pre-existing fixed harness inventory ending at milestone 9. Its retained SPEC-011 Dynamic staging log reports `task evidence keys differ`; this is a tooling failure, not an interaction behavior failure. The strict expected inventory now includes all three approved milestone-10 tasks (52 total). A fixture replacing T10.3 with T10.4 still refuses. No task/criterion check was weakened. The partial aggregate was stopped for correction; it is not a final gate pass.

Reproduce `ruby scripts/contracts/check-spec-011-harness.rb`; `swift test --disable-sandbox --scratch-path .build --filter 'ProfileDifferentialTests|UnequalInteractionStoreCapacity'`; fresh `scripts/test.sh all-hardware-free`.
