# Iteration 3 activity plan

This is the single current coordination plan for
[approved iteration-3 revision 5](../iteration-003-dev-ux-improvement.md), with
external delivery in [iteration 4](../iteration-004-backend-and-application-integration.md).
It replaces the archived preparation/completion checklists under the
[2026-10-09 cleanup authorization](preparation-archive.md). It is not a ready
Specification Implementation Plan and does not approve a design.
The [revision-5 authorization](efficiency-sequencing-approval.md#bounded-preparation-amendment--2026-10-09)
makes ME-01–04 one bounded phase; their IDs retain traceability, not separate
budgets or permission to grow independent investigations.

## Start here

Production is the iteration-2 closeout, commit `2d036748`. Existing ADRs,
implemented Specifications, tests and target recipes are unchanged. Read the
[findings summary](preparation-findings.md), then identify the exact unresolved
choice the next work will change. Retrieve archived source/evidence only for
that choice. No blanket replay of SPIKE-015–067 is required.

The immediate output is **one feasibility decision packet**: can a complete
runtime-derived analyzer and finite counter satisfy reviewed memory/lifetime
and sustained-performance requirements, which architectural changes are needed,
and which measured costs should be addressed first? A negative or
inconclusive result is useful if it identifies the exact constraint and the
scope/design decision needed. It is not permission for an automatic follow-up.

## Fixed preparation questions and output

Answer these three questions for the complete supported compositions:

1. Can runtime derivation, ownership, representations and lifetimes fit the
   application budgets safely, including simultaneous storage and full stack paths?
2. Which measured costs prevent the sustained acquisition/frame requirements,
   and are they consequences of architecture or local implementation defects?
3. What is the smallest supported remedy, what evidence supports it, and which
   existing contracts or upstream decisions govern adoption?

Evaluate the whole construction/service/retirement model before spending the
budget on isolated getter, compiler or fixture repairs. Neither a wholesale
redesign nor incremental optimization is presumed sufficient. Experimental
success and sunk effort do not favor a candidate without complete evidence.

Keep one decision packet containing the baseline/gap table, budget and usage,
memory/lifetime account, ranked costs, at most two remedies per selected
bottleneck, and a recommendation with authority mapping and residual obligations.
Supporting raw evidence may be linked; do not create a new coordination plan
for each attempt. Select the bottlenecks at launch; adding another consumes the
same budget and cannot silently displace evidence required by the fixed questions.

## Work sequence

| Retained activity IDs | Work and concrete exit |
| --- | --- |
| ME-01 | Freeze maintained source, toolchain, workload and artifact identities; map only the contracts relevant to the next decision and distinguish production from experimental evidence. Exit with a compact baseline and gap table. |
| ME-02 / ME-03 | Reconcile live representations, copies, scratch/backing and full feasible-path stack lifetimes; measure dominant frame and acquisition costs against identical workloads. Exit with accountable bytes, phase/operation counts and ranked bottlenecks. |
| ME-04 | Compare at most two remedies per selected bottleneck within an explicit cumulative study budget. Exit with one recommendation, rejected alternatives and residual obligations, or a named incompatibility requiring a decision. |
| ME-05 | Classify existing-contract changes versus architecture/contract amendments; obtain required approvals, numeric budgets and ready per-Spec plans before major implementation. |
| ME-06 / ME-07 | Implement approved runtime/storage and measured execution changes in coherent, attributable steps. Preserve semantics and retire production graph generation only with replacement coverage. |
| ME-08 | Validate exact integrated production artifacts and disposition every current scope criterion, including the required connected sustained-workload evidence. |
| ME-09 | Record stable owner/lifetime/API constraints, remaining obligations and iteration-4 handoff; request human iteration disposition. |

ME-01–04 share a frozen baseline, budget and terminal decision. Work sharing an
owner must use one coordinated sequence. ME-05 is the adoption approval step;
ME-06 onward is implementation and conformance, not an extension of preparation.

## Measurement requirements

- Account for declarations, semantic candidate/publication, identities,
  State/model/capture leases, layout, interaction, Canvas, raster/workspace,
  payloads, queues and platform/IRQ storage. Count overlapping live memory once
  per actual region; include construction and failure/retirement paths.
- Full stack bounds include reachable direct/indirect calls, recursion,
  callbacks/IRQ, compiler temporaries and ABI effects. An observed high-water
  mark or a sum of unrelated maxima is not a proof.
- Compare identical source declarations, geometry, resources, flags and inputs.
  Distinguish cold, unchanged, small-change and waveform frames, exact capacities
  and first-excess failures. Record phase times, traversals/lookups, copies,
  pixel/transfer counts, queue occupancy and event age as relevant to the claim.
- Use three independent runs per accepted connected baseline/candidate, at least
  30 seconds each at the governing 80 events/s and four-FPS target cadence.
  Report distributions, maximum latency, event/frame counts and instrumentation
  overhead with an uninstrumented control. Preserve loss/order/state/pixel checks.
- The matrix remains macOS Dynamic/Static, actual Pi 1 ARMv6 Dynamic and nRF52840
  Embedded Static. Build/link evidence cannot replace required device execution.
  Use repository toolchains/skills; connected actions require authorization.
- Trace budgets to the exact application/composition. Do not expand ceilings,
  weaken workloads or reuse old MVP exceptions to declare a new criterion met.

## Stop and decide

At launch, record numeric ceilings for active elapsed time, experimental command
invocations and correction attempts in the same decision packet. Count analysis,
build/run time and repairs against elapsed time; exclude waiting for a human or
unavailable device and report that waiting separately. Count underlying build/run
invocations even when batched in a wrapper. Record usage after each work session.
The earliest exhausted ceiling ends preparation. No unbounded or per-step-reset
allowance is permitted. The executor may set conservative limits for otherwise
authorized work without another permission request; setting limits does not
renew an exhausted study or authorize hardware operations.

Before each experiment, record its discriminating observation, exact inputs and
smallest adequate method. Budget use is cumulative across ME-01–04, questions,
candidates, repairs and experiment IDs. Historical same-question usage remains
visible. SPIKE-067 is already stopped at 744/768 invocations and 30/30 corrections.
Before any new compilation on that question, record why the previous approach
stopped, what materially changed, why the new observation can decide the issue,
and the proposed additional bounded allowance. Obtain explicit maintainer
continuation authorization; this documentation amendment grants no such restart.

Disposition every new finding immediately: address it within the remaining
budget if necessary for the fixed questions; capture it through the deferred
track if outside current correctness/scope; or report it as a blocker. A required
safety or feasibility question cannot be hidden in Future Work. Discoveries do
not automatically add milestones, alternatives or preparation phases.

At a failed invariant or unsafe bound, stop the affected candidate and record
the failure; use an already-budgeted alternative only if it addresses that
failure. At budget exhaustion, or earlier when the evidence decides the issue,
publish exactly one terminal disposition:

- **Supported recommendation:** identify the feasible approach and route it to
  ME-05. A recommendation is not architecture or implementation approval.
- **Incompatible approach:** identify the demonstrated constraint and the
  specific architecture/scope decision needed. Keep affected criteria unmet.
- **Inconclusive:** identify the missing evidence and why the bounded study
  could not obtain it. Do not claim either feasibility or impossibility.

Do not automatically append another preparation cycle. An extension or reopened
question requires a terminal report and explicit maintainer authorization of
the changed question/method and additional budget. Meeting preparation's exit
condition does not waive ME-08 evidence or close the iteration.

Commit coherent findings or changes; ordinary failed attempts stay in the
study evidence rather than each creating a separate scope/reconciliation commit.
Freeze inputs before compilation; keep large raw artifacts outside the active
source tree with stable hashes and durable retrieval when they must be retained.

## Handoff and authority

IT-AC-004–010 remain required; IT-AC-001–003 are transferred and IT-AC-005 is
split as specified in the approved scopes. Iteration-4 extraction waits for
runtime derivation, compatibility, safe memory and sustained performance gates,
or a specifically accepted exception. Design/inventory preparation may precede
that handoff, but final public API and package extraction do not.

[Accepted PROPOSAL-007](../../proposals/proposal-007-external-application-integration.md)
and [draft RFC-013](../../rfcs/rfc-013-external-application-and-backend-integration.md)
retain their distinct authority. Independent performance redesign needs the
applicable investment and RFC/ADR/Spec gates. FW-027/FW-032 supply selected
performance provenance; FW-031/FW-033 retain unrelated connected follow-up;
FW-035 retains the future generated-frontend question.

## Actions open after this amendment

| Action | Current permission / prerequisite |
| --- | --- |
| Launch the bounded phase: declare numeric limits, freeze identities and map gaps | Open; read-only inventory and budget declaration need no new approval. |
| Review existing code, accepted contracts and archived evidence; account for costs and compare architectural candidates | Open within the phase budget; candidates remain non-authoritative. |
| Run new hardware-free evidence work | Open only within a recorded budget and the normal Exploration/Spike rules; first distinguish a new question from a continuation of SPIKE-067. |
| Reopen the exhausted runtime experiment | Reassessment and explicit bounded continuation authorization required before compilation. |
| Draft upstream changes | Proposal drafting is open; RFC design requires an accepted Proposal covering the decision. Use RFC-013 for its coherent runtime boundary or separate independently reviewable performance decisions through the normal lifecycle. |
| Adopt major runtime/storage/performance changes | ME-05: applicable approved RFC, accepted ADRs, approved Specifications and ready implementation plans. Existing-contract maintenance remains eligible for the lightweight path. |
| Deploy/flash for connected measurements | Explicit authorization for the operation plus the repository target skills and checks. |

Execution is recorded in the single [feasibility decision packet](feasibility-decision.md).
ME-01 baseline inventory is complete; ME-02/03 record partial source/historical
evidence; ME-04 has a terminal **inconclusive** disposition. The bounded phase
has ended without establishing complete feasibility. ME-05 readiness and later
implementation remain open. Further preparation is not an automatic continuation;
use the packet's exact blockers and next-decision boundary. No production
migration or conformance transition follows from this assessment.
