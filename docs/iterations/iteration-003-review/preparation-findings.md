# Reusable iteration-3 preparation findings

This is a selective handoff from [the archived preparation](preparation-archive.md),
not an implementation plan or evidence that the complete design is feasible.
Production remains the iteration-2 closeout. RFC-013 remains draft; no new ADR or
Specification was approved by the studies. Do not copy experiment code into
production without its normal design, contract and implementation review.

| Finding worth retaining | Evidence and practical limit |
| --- | --- |
| Existing raster, endpoint, display and validation owners are reusable | [Backend inventory](../../explorations/exp-002/backend-foundation-inventory-2026-10-05.md). Investigate access and construction before introducing replacement modules. |
| A portable external declaration compiles, but current host/display access is insufficient | [SPIKE-014](../../spikes/spike-014-external-consumer-access-baseline.md). This is an access baseline, not a complete external application or a setup-improvement denominator. |
| Native external-host integration and ordinary error queries have positive controls | [Archived completion evidence map](https://github.com/level-two/GiftUI/blob/af5e9559ebf71446dbee4c3b1fcb2aae65a8f769/docs/iterations/iteration-003-review/rfc-013-completion-plan.md). Reuse exact cases when their inputs match; API inventories do not approve a public API or package partition. |
| Runtime derivation can join real application roots, state, actions, layout and recording frames in experimental compositions | [Integrated study](https://github.com/level-two/GiftUI/blob/af5e9559ebf71446dbee4c3b1fcb2aae65a8f769/docs/spikes/spike-067-integrated-runtime-host.md). These results do not establish full supported composition, production migration or every profile/source case. |
| Large value copies and construction/service overlap can dominate Embedded stack use | [Final result](https://github.com/level-two/GiftUI/blob/af5e9559ebf71446dbee4c3b1fcb2aae65a8f769/experiments/spike-067-integrated-runtime-host/armv6-results-0065.md). A specific 20,096-byte getter was removed experimentally. Earlier local and linked stack failures remain valid for their original images; the improvement is not a complete safe stack bound. |
| The integrated Dynamic recording consumer genuinely cross-linked for ARMv6 | [Packet 65 and inspection](https://github.com/level-two/GiftUI/blob/af5e9559ebf71446dbee4c3b1fcb2aae65a8f769/experiments/spike-067-integrated-runtime-host/armv6-results-0065.md). The original packet failed in post-link inspection; a separate inspection verified the ELF. Neither target execution nor framebuffer/PiScreen delivery was proved. |
| Existing target phase evidence already identifies performance work | [Pi measurements](../iteration-002-review/30-pi-aggregate-phase-comparison.md), [nRF measurements](../iteration-002-review/26-connected-nrf-phases-and-failure.md). Refresh only inputs or measurements needed for the next decision; these are not final runtime-derived production results. |

## Unresolved questions that matter now

1. Can the complete runtime-derived application fit reviewed storage and stack
   budgets, including construction, callbacks/IRQ, recursion and simultaneous
   backing lifetimes? Zero heap and a successful link do not prove this.
2. Are State/capture access, aliasing, escape, publication and teardown safe on
   the actual supported compositions rather than only serialized fixtures?
3. Which measured costs prevent the existing sustained acquisition/frame
   requirements, and which bounded remedies can improve them without changing
   semantics, workloads or budgets?
4. Which architecture/contract amendments are necessary before adoption?
   Final external API, package, activation and setup questions belong to
   iteration 4 after the runtime and cost constraints stabilize.

These remain current feasibility or approval gates, not optional Future Work.
SPIKE-067 ended at **744/768 invocations and 30/30 corrections**. Its allowance
is exhausted. This cleanup does not restart it. A new ID cannot reset the same
question or budget. Retrieve its recipes and failures only when they bear on a
named decision; do not rerun every predecessor to reconstruct the chronology.

## What to keep out of the active plan

Per-attempt compiler logs, binary snapshots, public-symbol inventories, failed
harness repairs and repeated reconciliation tables remain in the archive.
Useful experimental oracles may be adopted only after identifying their exact
assumptions and reviewing them against the affected approved contracts.

FW-034's practical lesson is to freeze compiler inputs before a run. It does not
justify a new evidence framework. [FW-035](../../future-work/fw-035-generated-view-graph-for-interchangeable-frontends.md)
retains the separate future generated-frontend question; it is not a fallback
that satisfies the current runtime-derivation commitment.
