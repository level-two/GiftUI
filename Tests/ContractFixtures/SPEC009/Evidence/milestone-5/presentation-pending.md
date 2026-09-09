# SPEC-009 T5.5 Presentation-Pending Evidence

The recording coordinator retains one `PresentationPendingIntent` containing
only the latest semantic revision and its retryable-refusal count. Backpressure
preserves a same-revision count and starts a newer revision at zero; retryable
refusal starts at one and checked-increments without sharing the backpressure
outcome.

A newer revision replaces the complete older intent and records `superseded`.
Repeated recovery requests coalesce behind one `presentationPending` wake until
the host supplies and the coordinator acknowledges a separately paced idle
opportunity. Clearing is revision-scoped so completion of an older attempt
cannot discard a newer intent.

The source audit rejects dynamic collections and retained roots, graphs,
frames, streams, operations, actions, models, or borrows.
