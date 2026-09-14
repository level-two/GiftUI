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

T8.2 and T8.3 are complete. `DynamicRuntimeExecutionCoordinator` and
`StaticRuntimeExecutionCoordinator` borrow address-stable profile bindings and
delegate only to injected focused admission and opportunity owners through
SPEC-009's two common protocols. They add no second queue, cycle algorithm,
state/action storage, endpoint, or host policy. Both façades reject admission
and opportunity entry after profile quiescence with the current execution
context and exact required-facility failure.

The cross-profile differential fixture submits state-change and completion
facts and runs the opportunity solely through generic
`ExecutionAdmissionSink` and `ExecutionOpportunityRunner` functions. Dynamic
and Static outcomes, retained owner counts, and focused failure values match
field-for-field before and after quiescence. `integration-owner-status.tsv`
records all four integrations, and the checker fails closed if a disposition,
source seam, or approved dependency set drifts.
