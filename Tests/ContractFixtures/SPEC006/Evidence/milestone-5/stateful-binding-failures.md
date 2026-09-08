# SPEC-006 T5.3 Stateful Binding Failure Evidence

The combined stateful expansion fixture injects every one of SPEC-010's twelve
`ObservableStateError` cases. Alternating declaration ordinal zero and one
proves both first-wrapper and later-wrapper failure after an earlier successful
binding. Every result is exactly `.bindingFailure(error)`; no
`SemanticExpansionError` is created or substituted.

For every case, the generated stateful body's poison observation remains
absent, the semantic sink records zero body-evaluation stages, committed and
staged transcripts are empty, publication count is zero, and discard count is
exactly one. The semantic workspace returns to idle and is reusable after the
owner failure.

This matrix covers capacity, generation, ownership, compatibility, stale
attachment, contained/safety-not-proven phase, reentrancy, and invariant
failures at the SPEC-006 binding seam. Mandatory observable-state cleanup and
policy behavior beyond candidate discard remain owned by later SPEC-010 tasks;
Semantic Core neither interprets nor reranks those values.

The registered audit fixes the twelve-case set, early/late injection, body and
publication suppression, atomic discard/reset observations, and the distinct
owner-failure branch. Milestone 5's stateful subset is complete.
