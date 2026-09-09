# SPEC-006 T6.2 Semantic Profile Evidence

Every standalone profile validates the same ordered declaration, transcript,
identity, summary, bounds, failure-order, framework-failure, owner-mapping,
and state-host artifacts. The generated semantic report records the canonical
corpus digest, total counters, transcript and relation counts, and maximum
observed depth. Its normalized content contains no profile-private values.

Rank 0 variants independently vary symbolic backend, platform, and capability
facts for empty, conditional, modifier, action, and state-host representative
cases. Each variant is required to remain canonically equal: those later-layer
facts cannot alter builder shape, branch selection, expansion order, modifier
or action ordering, identity relations, summaries, failures, or transcripts.
