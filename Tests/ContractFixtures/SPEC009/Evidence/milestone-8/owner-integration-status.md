# SPEC-009 T8.2/T8.3 Owner Integration Status

The SPEC-010 boundary is integrated exactly: Observable State owns a
generic `PresentationFactAdmissionAdapter`, imports only Execution, forwards
one complete typed fact, and returns the exact admission outcome without a
fallback or second queue.

The SPEC-011 boundary is integrated through `GiftUIInteraction`'s
`ExecutionGestureAdapter` and `InteractionState`. The audit fixes the exact
target dependencies and verifies that pointer capture and resolution do not
acquire Observable State, runtime, backend, or dispatch ownership.

The SPEC-014 boundary is integrated through `GiftUIBackendIntegration`'s
`OneShotRasterBackendEndpoint`. It imports only the approved capability,
display, Execution, failure, raster, render, surface, and text-resource owners;
conforms through `RasterBackendEndpoint` to the synchronous frame endpoint;
and proves pre-body reservation, exact refusal mapping, invalid-envelope
rejection, and at-most-once body entry. The source audit rejects runtime,
Interaction, Observable State, action-target, and host-policy ownership.

T8.3 is complete. T8.2 remains blocked because the present Dynamic and Static
profile bindings expose active-pipeline entry points but do not yet conform to
SPEC-013's production `ExecutionAdmissionSink` and
`ExecutionOpportunityRunner` coordinator surface. The recording coordinator
is not treated as a production substitute. `integration-owner-status.tsv`
records that exact gate and the checker fails closed if any owner disposition
or approved dependency set drifts.
