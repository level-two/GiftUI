# SPEC-009 Admission Value Evidence

Plan task: `SPEC-009 T1.4`

`GiftUIExecution` owns the exact admission kind/result/outcome values, typed
admission and opportunity protocols, bounded admission summary, borrowed
action view, and generic captured action. The admission protocols retain their
owner payloads as associated types, so there is no existential payload or
profile-private entry point.

Focused tests prove every raw case and layout ceiling, equality and sendability,
each count limit at equality and one over, the disabled-completion rule, and
the semantic-action-to-pointer count invariant. A SPEC-006-shaped fixture
identity passes through the action view and `CapturedAction` unchanged beside
the runtime-wide `ActionGeneration`; the source audit fixes those as the
captured value's only two fields.

The opportunity protocol's exact result type is part of T1.5. Its declaration
and transitive finite result values land in this buildable commit; T1.5 remains
open until their complete invariants, specializations, layouts, and evidence
are implemented.

Reproduce from the repository root:

```text
swift test --filter AdmissionValueTests
scripts/contracts/check-spec-009-admission-values.rb
swift package dump-package | scripts/contracts/check-target-dependencies.rb
```
