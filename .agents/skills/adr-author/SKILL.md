---
name: adr-author
description: Extract one architecturally significant GiftUI decision from an approved RFC into a proposed ADR with rationale, consequences, and rejected alternatives. Use after RFC approval when decisions need durable authoritative records.
---

# ADR Author

## Role

Extract an agreed decision; do not create a new one.

## Required Inputs

- Approved RFC and accepted Proposal.
- The specific decision and evidence that the RFC reached agreement.

## Documents To Read

Read the lifecycle/documentation rules, `docs/features.yaml`,
`docs/templates/adr.md`, the accepted Proposal, approved RFC, related ADRs,
project principles, and affected architecture documents.
For MVP decisions, read `docs/MVP_SCOPE.md` to verify product-boundary
alignment without deriving the decision from scope alone.

## Allowed Decisions

- Choose a narrow record boundary and faithfully summarize established
  context, decision, rationale, consequences, and rejected alternatives.
- Keep the ADR `proposed` pending explicit acceptance.

## Forbidden Decisions

- Do not introduce, broaden, improve, or reinterpret the RFC decision.
- Do not extract from an unapproved RFC unless another explicit authority is
  documented.
- Do not mark the ADR accepted.

## Workflow

1. Verify RFC approval and locate exact decision evidence.
2. If consensus is incomplete, report the gap and stop extraction.
3. Allocate the next ADR ID and copy the template.
4. Record one normative decision and balanced consequences.
5. Keep consequences required by the decision in the ADR; capture only
   optional future extensions or investigations as linked deferred work.
6. Link source artifacts and update the feature manifest and RFC relationships.

## Required Output

Produce a `proposed` ADR and traceability updates, or a concise report that
consensus is insufficient and RFC work must resume.

## Review Checklist

- [ ] The source RFC is approved.
- [ ] The ADR contains exactly one supported decision.
- [ ] Rationale and rejected alternatives match the RFC.
- [ ] Consequences include costs and follow-up work.
- [ ] Deferred items do not hide a consequence required to apply the decision.
- [ ] Status remains proposed without explicit human acceptance.

## Completion Criteria

Complete when the decision can be accepted or rejected independently without
losing its RFC provenance.
