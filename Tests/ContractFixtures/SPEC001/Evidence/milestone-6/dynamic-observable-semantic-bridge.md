# SPEC-001 T6.7 Dynamic Observable/Semantic Bridge

`DynamicObservableStateReconciler` now adapts the production Dynamic observable
root to the generic semantic state-binding contract. It delegates candidate
begin, encounter, and finish to `DynamicObservableRootAdapter`, and installs a
replacement route that returns later `State` replacements to that same root.

The semantic visitor is generic over every observable declaration type, while
one Dynamic root intentionally owns one concrete model type. The bridge first
checks exact metatype equality and rejects any unexpected model with
`invariantViolation`; only the proven-equal `State` representation is rebound
to call the typed root API.

The focused command

```text
swift test --filter DynamicObservableStateReconcilerTests
```

passes an initial materialization/publish cycle, a preserved second cycle, and
the mismatched-model rejection case. This bridge is the state-binding
prerequisite for expanding the real `SignalAnalyzerView`; it does not itself
complete the target host.
