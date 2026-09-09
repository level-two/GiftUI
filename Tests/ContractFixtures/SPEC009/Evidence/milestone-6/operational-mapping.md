# SPEC-009 T6.4 Operational Mapping Evidence

All five primary operational results map to their exact SPEC-003 kind, origin,
and smallest scope while preserving context, the complete event set, attempt
ordinal, and attempt limit. The adapter independently recomputes primary
precedence and rejects mismatches, malformed attempt bounds, or mapping before
mandatory abort, dirty, unavailable, cancellation, and quiescence effects.

The residual input preserves correlation and accepts every non-retry target.
Paced retry is available only for backpressure or retryable refusal below the
limit; an exhausted ordinal and unrelated operational facts reject it.
