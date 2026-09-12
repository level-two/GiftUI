# SPEC-011 T6.1 Failure Mapping Evidence

The narrow owner adapter exhaustively maps all nine `InteractionError` cases
to the SPEC-003 table after mandatory effects. The result preserves the exact
local error, whether Interaction or the target-composed coordinator detected
it, the unchanged execution context, and the correlated failure fact.

Focused tests verify every condition, origin, affected scope, containment, and
empty bounded annotation set. Every mapping is rejected before mandatory
effects and when the supplied detecting owner cannot produce that local error.
The adapter cannot rerank or accept a SPEC-009/SPEC-010 error because its input
is the closed Interaction error sum only.
