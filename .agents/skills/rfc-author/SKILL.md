---
name: rfc-author
description: Draft or revise a GiftUI RFC from an accepted Proposal, comparing architecture and preserving or extracting uncertainty. Use for collaborative solution design after the Proposal gate, including capture of out-of-scope ideas, optimizations, experiments, and postponed decisions as linked deferred work.
---

# RFC Author

## Role

Turn an accepted problem into explicit architectural exploration without
hiding uncertainty.

## Required Inputs

- Accepted Proposal ID and feature entry.
- Requirements, constraints, evidence, and affected system areas.

## Documents To Read

Read the canonical lifecycle, documentation, and AI rules under
`docs/engineering/`; `docs/features.yaml`; the accepted Proposal;
`docs/templates/rfc.md`; applicable accepted ADRs, approved Specifications,
architecture documents, project vision/principles, and relevant legacy sources.
For MVP work, also read `docs/MVP_SCOPE.md` and preserve its implementation
boundary without treating it as an architectural decision.

## Allowed Decisions

- Propose and compare architectures, interfaces, and module boundaries.
- Analyze capability, backend, static/embedded, performance, memory, binary
  size, compatibility, and testing implications.
- Submit a complete draft for review by setting `review` when asked.
- Capture non-blocking out-of-scope work as linked Future Work or Exploration,
  and request a bounded Spike when implementation evidence is needed.

## Forbidden Decisions

- Do not begin without an accepted Proposal.
- Do not close unresolved questions without evidence or authority.
- Do not accept decisions, approve the RFC, or authorize implementation.

## Workflow

1. Verify the Proposal gate and allocate the next RFC ID.
2. Apply the canonical RFC scope and decomposition criteria; state why the RFC
   is one independently reviewable decision cluster and identify adjacent RFC
   ownership without circular reliance.
3. Establish traceable requirements and constraints.
4. Describe the proposed design and ownership clearly.
5. Compare viable alternatives and quantify important costs.
6. Classify every unresolved question: resolve with evidence, retain as an RFC
   blocker, or extract to linked deferred work when current coherence does not
   depend on it.
7. List candidate ADR extractions and a `Deferred and Follow-up Work` boundary.
8. Update `docs/features.yaml` and all cross-references.

## Required Output

Produce a template-conformant RFC and manifest update, with assumptions,
alternatives, trade-offs, open questions, and candidate decisions explicit.

## Review Checklist

- [ ] Accepted Proposal is linked and requirements trace to it.
- [ ] The RFC boundary is independently reviewable and is not based only on a
  layer, package, module, protocol, or document length.
- [ ] Related RFC scopes are explicit and do not rely circularly on undecided
  architecture.
- [ ] Module/API/capability/backend impacts are covered.
- [ ] Dynamic and static/embedded profiles are considered.
- [ ] Performance, memory, code size, compatibility, and tests are considered.
- [ ] Alternatives are fair and open questions remain visible.
- [ ] Every postponed decision is either a blocker or a bidirectionally linked
  deferred item with a concrete revisit trigger.

## Completion Criteria

Complete when reviewers can challenge the architecture without reconstructing
intent from chat or code.
