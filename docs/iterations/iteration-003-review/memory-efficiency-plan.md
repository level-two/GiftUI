# Iteration 3 activity plan

This is the single current coordination plan for
[approved iteration-3 revision 4](../iteration-003-dev-ux-improvement.md), with
external delivery in [iteration 4](../iteration-004-backend-and-application-integration.md).
It replaces the archived preparation/completion checklists under the
[2026-10-09 cleanup authorization](preparation-archive.md). It is not a ready
Specification Implementation Plan and does not approve a design.

## Start here

Production is the iteration-2 closeout, commit `2d036748`. Existing ADRs,
implemented Specifications, tests and target recipes are unchanged. Read the
[findings summary](preparation-findings.md), then identify the exact unresolved
choice the next work will change. Retrieve archived source/evidence only for
that choice. No blanket replay of SPIKE-015–067 is required.

The immediate output is **one feasibility decision packet**: can a complete
runtime-derived analyzer and finite counter satisfy reviewed memory/lifetime
bounds, and which measured costs should be addressed first? A negative or
inconclusive result is useful if it identifies the exact constraint and the
scope/design decision needed. It is not permission for an automatic follow-up.

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

ME-02/03 may share a frozen baseline. Work sharing an owner must use one
coordinated sequence. Do not create a new plan for each compiler or fixture repair.

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

Before an experiment, record the choice, discriminating observation, exact inputs,
smallest adequate method and cumulative command/correction limit. Budget use is
cumulative for the question; renaming a Spike or checkpoint does not reset it.
SPIKE-067 is already stopped at 744/768 invocations and 30/30 corrections.
Continuing that question requires an explicit recorded reassessment before any
compilation, not a new numbered study that bypasses its stop.

At a failed invariant, unsafe bound or exhausted limit, produce a disposition:
select a supported remedy, request a specific upstream design/scope decision,
or leave the gate unmet. Do not automatically append another preparation cycle.
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

All activities remain planned. This cleanup performs no experiment, production
migration, hardware operation or conformance transition.
