# RFC-012 retention review — 2026-10-05

Verdict: **ready for human approval consideration**. This review is not approval.
The [amendment](../../rfcs/rfc-012-five-second-capture-retention-amendment.md)
is one bounded retention decision under accepted PROPOSAL-002 and preserves
RFC-001's historical reasoning. ADR-003 remains accepted and authoritative.

No unresolved technical RFC blocker found. The density review clarified that
10 Hz/channel is the stress envelope, while the production source keeps its
distinct deterministic patterns and seeded schedule. Review checked ownership/dependency
direction, Dynamic/Static compatibility, inclusive cutoff and 404 boundary
rationale, distinct scalar baselines, equal-time/capacity/out-of-order behavior,
Clear/publication/borrow/revision semantics, and all three physical stores.
The 96,000-byte arithmetic agrees with Step 14's isolated measured candidate;
production-linked totals, raster parity and physical timing are expressly unproven.
The 30s/80-event/s workload and delivered count remain unchanged. No backend
capability, alternate buffer, heap, stack or profile negotiation is added.

Non-blocking implementation risks are visible in the RFC: complete-capture
behavior changes for older-history consumers; all region/ABI/fixture expectations
must be audited together; research measurements cannot substitute for production
or physical evidence. Alternatives include retaining the existing history; the
recommendation does not claim that alternative has been human-rejected.

Candidate ADR: successor to ADR-003 covering 5s inclusive transition retention,
404 minimum records plus separate baselines, unchanged density/eviction semantics.
Extract only after explicit approval of RFC-012, then obtain ADR acceptance and
exact SPEC-001/015 (and affected SPEC-013 resource) approval. Existing FW-027/032
performance and FW-031/033 connected follow-ups stay outside the decision; none
conceals a prerequisite for a coherent retention policy.

RET-01 authoring/review is prepared. Its approval gate is pending. RET-02–04 and
production retention tasks remain held by the ordered workflow in the
[coordination plan](implementation-plan.md). No artifact status or contract was
promoted based on iteration approval or this review.

## Subsequent human disposition — 2026-10-05

[Explicit approval](retention-approval.md) approved RFC-012 and its faithful delivery chain. ADR-034 and the coordinated Specs are authoritative; earlier approval-pending statements above preserve the pre-approval review history.
