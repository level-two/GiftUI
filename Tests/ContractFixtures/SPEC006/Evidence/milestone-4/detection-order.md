# SPEC-006 Coincident Failure and Reentrancy Evidence

Task `T4.2` is implemented by `BoundaryCorpus/coincident-failures.tsv`, the
coincident-order cases in `SemanticExpansionAttemptTests`, the body-stop and
modifier/action ordering cases in `SemanticExpansionTraversalTests`, and
`SemanticReentrancyTests`.

The probes combine reentrancy with begin refusal, depth with invalid identity
and storage exhaustion, invalid identity with later reservations, operation
counts with storage, and storage with hook refusal. Event and counter checks
show the first detecting point wins, later hooks do not run, the sticky error
does not change, no partial result publishes, and reset permits a later valid
attempt. Action semantic-node reservation precedes action reservation, while
modifier observations retain increasing scope-local indices.

The reentrancy fixture uses three named synchronous entry sources: callback,
invalidation, and external input. Each shares the active logical workspace,
returns `reentrancyViolation` before beginning its sink, and performs no nested
action or publication. The containing custom-view body is evaluated once and
the outer root completes and publishes normally.
