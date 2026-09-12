# SPEC-011 T0.2 Target Boundary Evidence

`GiftUIInteraction` depends on exactly `GiftUI`, `GiftUISemanticCore`,
`GiftUILayout`, and `GiftUIExecution`. The narrow
`GiftUIInteractionFailureAdapterFixture` depends on exactly Interaction,
Failure Core, and Failure Execution, and its focused test target names only
those owners plus Execution for a concrete context fixture.

The registered boundary check rejects reverse edges, re-exports, Observable
State/runtime/backend/platform/driver dependencies, reflection, unrestricted
existentials, task/async use, dynamic collections, and allocator facilities in
Interaction. The repository exact-graph check covers package/registry drift,
unknown or duplicate edges, and cycles.
