# SPEC-006 T6.5 Complexity Evidence

The instrumentation derives ten counters from the canonical modifier-custom
and action-modified transcripts: visitor dispatch, path and identity
validation, counter reservation, workspace and sink reservation, body
evaluation, semantic stage, modifier stage, and action stage.

Geometric admitted scales `1, 2, 4, 8, 16` retain an exact constant per-unit
ratio for every counter. Five capacity-failure rows increase the inactive
rejected subtree from 1 through 16 units while attempted work remains fixed at
the third event and published work remains zero. No traversal, retry, cleanup,
or retained storage scales with rejected work.
