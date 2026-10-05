# Retention contract review — 2026-10-05

Verdict: ready under explicit maintainer approval of the concrete RFC-012 policy
and faithful delivery chain. The review does not independently approve a Spec;
[human provenance](retention-approval.md) supplies authorization.

SPEC-001 now specifies five-second inclusive cutoff, 404 transition bounds,
separate baselines and unchanged ordering/eviction/replay/publication/Clear/
revision semantics. SPEC-015/013 consume coordinated three-slot accounting and
preserve host ownership, ABI/alignment, stacks, heaps and unrelated regions.
The 30s/80-event/s delivery remains 2,404; retained counts use schedule-specific
oracles, including synchronized 404 at cutoff 25s. Current production patterns
are unchanged. Required level/path/pixel, boundary/capacity/reuse and resource
checks are measurable; experiments remain evidence, not authority.

No unresolved architecture choice or approval blocker found. Existing timing
and physical exceptions are preserved, and new connected checks must record
actual outcomes. Upstream ADR-034 faithfully supersedes ADR-003, and current
Spec authority references move to the accepted successor. No literal replacement
of delivered counts or historical evidence is authorized.
