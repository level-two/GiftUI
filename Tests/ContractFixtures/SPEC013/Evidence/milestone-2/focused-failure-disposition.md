# T2.4 Focused Failure and Disposition

Date: 2026-09-12

`RuntimeFocusedFailureState` retains the first exact `RuntimeOwnerFailure` and
its immutable SPEC-009 `ExecutionContext`. Later focused failures cannot
replace either value. Cleanup observations are separate and monotonic:
contained cleanup remains contained, while safety-not-proven cleanup can only
widen the final containment.

The sibling failure adapter maps the correlated focused value using the owning
SPEC-006, SPEC-007, SPEC-010, SPEC-011, or SPEC-012 condition/origin/scope
meaning. It returns the original correlation beside the mapped SPEC-003 fact.
A safety-not-proven cleanup widens containment without replacing condition,
origin, scope, focused value, or execution context.

Focused tests construct a total SPEC-003 residual-policy input from the mapped
fact and retained context. Repeating the mapping across diagnostic variants
produces the identical typed result because the adapter accepts no diagnostic
input.

Verification command:

```text
swift test --filter 'RuntimeFocusedFailureStateTests|GiftUIRuntimeFailureAdapterTests'
```

Result: nine focused tests passed, including first-failure preservation,
secondary-cleanup widening, all five owner cases through correlation,
representative owner facts, residual-policy input, diagnostics independence,
and the two-byte carrier ceiling.
