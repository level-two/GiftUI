# SPEC-009 T6.3 Render and Offer Mapping Evidence

The adapter maps all six directly representable render-production errors with
their exact SPEC-008 condition, origin, scope, and containment. `sinkRefused`
is accepted only through the render-producer non-retryable-refusal route, kept
distinct from endpoint refusal.

Only invalid-envelope and contract-violation frame-offer failures map. The
coordinator-impossible insufficient-capacity and producer-failed forms return
no fact, preventing replacement of a retained producer error. All offer-time
mappings require mandatory abort and unavailable/quiescence effects first.
