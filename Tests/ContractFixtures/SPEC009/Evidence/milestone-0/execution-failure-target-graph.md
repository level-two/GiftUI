# SPEC-009 T0.2 Execution and Failure Target Graph Evidence

The package and fail-closed SPEC-002 dependency registry contain the exact
`GiftUIExecution -> GiftUI + GiftUIRenderCore` and
`GiftUIFailureExecution -> GiftUIFailureCore + GiftUIExecution` production
edges. Their focused test targets and every currently compiled fixture-only
owner adapter are registered with their actual direct dependencies.

The SPEC-009 interface audit verifies those declarations, prevents either
production target from becoming a library product, and checks the SPEC-003
through SPEC-005 negative fixtures against the real execution and failure
target names. The migration audit scans the affected boundary fixtures and
contract checkers and rejects any remaining `GiftUIExecutionContract`
placeholder, alias, compatibility shim, or second execution surface.

The exact dependency checker additionally rejects duplicate rows, unknown
edges, package drift, and cycles.
