# Normalized input and action evidence

`HostNormalizedInputGate` is the one-source target-local boundary. It stamps
only events tied to the current accepted physical presentation, consumes a
runtime-visible sequence only when submitting a down, uses ordinal zero and
checked successors, and requires explicit completion proof before a replacement
down. Unknown, unavailable, malformed, stale, out-of-order, exhausted, and
runtime-refused input is dropped or cancelled without retargeting.

Focused tests prove exact bound success and first-excess
`capacityRefused` cancellation, maximum sequence use without wrap, and exact
runtime rejection preservation. Existing production dispatcher fixtures cover
the six immutable Signal Analyzer actions, action/target generation and
enabled-state revalidation, weak current-model borrowing, replacement races,
and non-retention of former models or handlers.
