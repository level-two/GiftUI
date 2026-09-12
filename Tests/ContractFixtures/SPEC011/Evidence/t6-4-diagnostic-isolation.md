# SPEC-011 T6.4 Diagnostic Isolation Evidence

The focused matrix runs diagnostics omitted, selected and accepted, dropped,
saturated, and failed. Every row preserves an identical correctness snapshot:
the exact mapped local/correlated failure, mandatory containment state,
residual bounds, zero handler invocations, and zero fallback, retarget,
partial-publication, or alias counts.

The diagnostic sink deliberately attempts all four prohibited effects during
its callback. The authority rejects every attempt after diagnostic delivery
begins, and a freshly reconstructed correctness snapshot remains value-equal
to the baseline. Omitted diagnostics construct no record.

Failure Diagnostics is linked only into the focused test target. Neither
`GiftUIInteraction` nor `GiftUIInteractionFailureAdapterFixture` imports or
depends on it, so diagnostic availability cannot become a correctness path.
