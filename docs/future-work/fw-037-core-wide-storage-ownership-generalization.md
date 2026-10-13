---
id: FW-037
feature: giftui-mvp-architecture
title: Core-wide Storage Ownership Generalization
status: captured
authors:
  - codex
created: 2026-10-13
updated: 2026-10-13
source:
  - RFC-015
  - ADR-039
related_future_work:
  - FW-022
  - FW-035
related_explorations:
  - EXP-002
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-004
---

# FW-037: Core-wide Storage Ownership Generalization

## Observation / Opportunity

P08 exposed a distinction between physical backing ownership, state-machine
ownership and scoped access. [Approved RFC-015](../rfcs/rfc-015-p08-scoped-storage-ownership.md)
selects a focused geometry/Interaction direction. A future frontend-, backend-
and platform-independent GiftUI Core might benefit from a consistent version of
this distinction across owner boundaries, using Swift to exclude unsupported
safe-client escapes and aliases while preserving explicit trusted implementation
and runtime checks. That benefit and a common representation remain hypotheses.

## Ownership and Transfer Model to Assess

For each boundary, identify who owns the resource, who may borrow or mutate it,
what ownership or access can transfer, when responsibility changes, and who
cleans up after success, refusal or failure, including cancellation and shutdown.
Use the same questions for frontend, backend, platform and PC simulator
compositions:

- **Ownership:** name the physical backing owner, semantic/state-machine owner
  and party responsible for eventual release; these need not be the same owner.
- **Borrowing and mutation:** identify permitted access, exclusivity and lifetime
  limits while ownership stays with the lender.
- **Transfer:** identify sender, recipient and the exact value or responsibility
  transferred. Moving a scoped access capability does not transfer its backing
  ownership or extend its lifetime. Transfer of presentation responsibility is
  also distinct from transfer of payload storage ownership.
- **Acceptance and cleanup:** identify the transfer point, what the sender may
  still access, and whether rejection returns the resource, retains it with the
  sender or destroys it. Account for post-acceptance failure and final release.

Keep these semantics separate from their Swift enforcement and physical storage
realization. Assess `borrowing`, `inout`/`mutating`, `consuming`/`consume`, concrete
`~Copyable` access or owner types, lifetime constraints and restricted construction.
`consuming` alone does not establish unique resource ownership; reference or
pointer aliases and copyable values need separate treatment. Distinguish compiler
checks from runtime validation and trusted implementation obligations.

This is an assessment model, not a new Core contract. Compare existing
[SPEC-013 borrowing rules](../specs/spec-013-runtime-profiles.md#storage-ownership-and-borrowing),
[SPEC-014 acceptance and payload transfer rules](../specs/spec-014-backend-integration.md)
and [RFC-015 scoped access](../rfcs/rfc-015-p08-scoped-storage-ownership.md).
Determine which rules merit shared Core architecture and which remain specific
to their subsystem; approved Specifications retain authority for current behavior.

## Why Deferred

P08 needs a coherent finite carrier and physical slot design, not a universal
Core redesign. RFC-015 now has bounded native compiler evidence and architectural
approval; its downstream contracts, complete integration and resource proof
remain outstanding. FW-022 already owns simulator investment/fidelity; FW-035 owns
generated graphs for interchangeable frontends; EXP-002 compares integration
shapes. None captures the separate question of whether storage/access ownership
should generalize across them. This item adds only that narrow observation.

## Potential Value

- Reduce accidental ownership coupling when a second frontend, backend or
  simulated platform composes production owners with different backing lifetimes.
- Reuse explicit ownership and lifetime evidence without making one target's
  pointer layout, region allocator or Swift adapter the universal Core contract.

## Current Non-goals

- No new P08 requirement, associated-type scheme, universal owner protocol,
  frontend IR/ABI, allocator, simulator implementation or language-independent Core.
- No deferral of RFC-015's complete lifetime propagation, safe-client boundary,
  disjoint initialization, swap/destruction or exact existing-consumer obligations.
- The scheduled assessment does not approve architecture, implementation or
  experiments, compiler changes or reopened repair allowances.

## Revisit Triggers

- Start of ITERATION-004 I4-06, alongside package/access and host integration
  review; inventory gaps even if the P08 evidence below is not yet complete.

- An adopted P08 ownership contract has complete compiler and physical-lifecycle
  evidence, and a concrete second frontend/backend/platform consumer demonstrates
  different backing/access needs or repeated incompatible adapter code.
- A separately prioritized FW-022 simulator or RFC-013 external integration
  encounters a reproducible ownership boundary that cannot compose the existing
  production owners without duplicating state or erasing lifetime guarantees.

## Disposition

Captured and scheduled as an assessment in
[ITERATION-004](../iterations/iteration-004-backend-and-application-integration.md)
revision 3, I4-06 / I4-AC-007. On 2026-10-13, Eugene explicitly requested:
“Add the produced future work item to the next iteration scope.” In context,
the produced item is FW-037. This authorizes the assessment scope addition,
not a Core-wide architecture or simulator implementation.

On 2026-10-13, Eugene requested and authorized recording the ownership-and-transfer
model above and referencing it from I4-06 and its acceptance criterion. This
clarifies the scheduled assessment without adopting new ownership contracts.

Evaluate concrete ownership boundaries through Exploration (reuse EXP-002 when
its scope fits), including a second consumer and PC simulator composition.
Record evidence gaps and recommend generalization, retaining local contracts,
or deferral. Then use normal Proposal/RFC/ADR/Spec gates for any adoption.
RFC-015's full implementation and acceptance obligations are now scheduled in
ITERATION-004 revision 4, I4-07; P08 retains necessary changes and their complete
proof under the [delivery allocation](../iterations/iteration-003-review/rfc-015-delivery-allocation.md).
I4-06 remains the separate generalization assessment. Status stays captured:
scheduling does not itself promote this item to an Exploration or Proposal.

## References

- [RFC-015](../rfcs/rfc-015-p08-scoped-storage-ownership.md), source and downstream obligations.
- [FW-022](fw-022-contract-accurate-embedded-target-simulator.md), simulator ownership and fidelity.
- [FW-035](fw-035-generated-view-graph-for-interchangeable-frontends.md), frontend graph opportunity.
- [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md), integration alternatives.
