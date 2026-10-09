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

Production now includes the I3-T01 corrections on the iteration-2 baseline.
[The completed package](i3-t01-result.md) records commits, all 74 hardware-free
checks, resource costs and remaining gates. Existing accepted ADRs and implemented
Specifications remain authority; the generated production graph is retained.

**Current disposition: I3-T01 passed within its hardware-free boundary.**
**I3-T02 is delivered with named blockers** in [draft RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md)
and its [design review](i3-t02-design-review.md). The next unresolved decision
is the three-versus-four capture-slot decision under ADR-034 (B0), alongside
the exact Static binding/capture lifetime and external-model ownership bound
(B1/B2), before runtime implementation. No experiment is automatically launched.
The [findings summary](preparation-findings.md) and stopped studies remain
historical inputs; this result does not reopen their budgets or experiments.

| Work | Current readiness / missing prerequisite |
| --- | --- |
| I3-T01 correction package | Complete within the hardware-free boundary; [result and residual gates](i3-t01-result.md). |
| I3-T02 runtime design, I3-04 / ME-05 | Delivered with named blockers: [RFC-014 review and contract map](i3-t02-design-review.md). |
| ME-06 runtime implementation | Blocked on the resulting architecture/contract gates and complete resource/lifetime evidence; no ready migration plan yet. |
| ME-08 integrated validation | Waits for the adopted implementations and exact artifact identities; connected evidence remains separately authorized. |
| ME-09 closure/handoff | Waits for the criterion dispositions and maintainer decision; no automatic iteration-4 extraction. |

## I3-T02 — Runtime derivation design package

**Status:** delivered with named approval/adoption blockers. **Kind:** RFC design and adoption routing, not a renewed
feasibility experiment or authorized production migration.

On 2026-10-09, after the next-task explanation distinguished design from blocked
implementation, Eugene instructed: “Let’s proceed then.” This authorizes this
bounded design continuation. The standing request is to commit each step.
Baseline: `710fbd24`; the I3-T01 source/test evidence identifies `7d618db7`.

Use one **60-active-minute ceiling**, including orientation, source review,
authoring, self-review, governance validation and commits. Launch accounting at
19:18 UTC charges eight minutes of preceding orientation. No builds, runtime
experiments, new Spike, hardware operation or budget renewal is selected.
A missing proof ends in a named blocker and exact required evidence, not an
automatic experimental continuation. This is an executor-selected ceiling.

| Step | Deliverable | Exit |
| --- | --- | --- |
| I3-T02.1 | Scope and authority routing | Complete: `769ea2de`; separate runtime ownership from external package/API delivery. |
| I3-T02.2 | [Draft RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md) | Complete: `2d0a034d`; concrete ownership and conditional resource model, corrected during final review. |
| I3-T02.3 | [Review and conditional implementation sequence](i3-t02-design-review.md) | Complete with B0–B4 unresolved; seven per-Spec conditional sections remain blocked. |

Runtime representation, state access and capture lifetime form one coherent
review boundary: each controls what a copied declaration can retain through
post-layout Canvas execution. They can be evaluated without choosing the
iteration-4 package partition or public host API. Route them to a focused RFC;
RFC-013 retains external integration and historical candidate evidence.
Preserve the 4 MHz performance failure independently of representation design.
A new RFC number does not reopen SPIKE-067/068 or adopt their candidates.

Final charged upper bound: **25/60 active minutes**, including initial
orientation and final reporting/commit time rounded up conservatively; zero experimental invocations,
zero hardware operations and zero excluded waiting. Documentation governance,
links, budget arithmetic and diff checks pass. This design task is closed;
compiler feasibility, safe complete resources and iteration performance remain
unproved. No allowance renews automatically.

The design must preserve the accepted Semantic Core, Layout, Runtime,
Observable State, Drawing and Interaction owners. Existing-contract private
choices may later become implementation notes; changes to declarations,
resource limits or lifetime obligations require the affected Spec review.
No approved Specification or ADR is changed by this package.

## Fixed preparation questions and output

This section preserves the closed ME-01–04 phase's original brief.

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

## I3-T01 — Correct scheduling and reduce raster/layout costs

**Status:** complete; passed within the stated hardware-free validation boundary.
[Integrated result](i3-t01-result.md) records all three corrections and remaining iteration gates.
**Kind:** one bounded production implementation task, not an experiment.
**Scope mapping:** I3-05 and its internal host/backend corrections; ME-05
readiness, ME-07 implementation and the affected portion of ME-08 validation.
This task contributes to IT-AC-004/005/007/008/009; it does not independently
satisfy those iteration-wide criteria.

On 2026-10-09, after the implementation-versus-experiment explanation, Eugene
requested recording the proposed package as a task in iteration 3. This is a
decomposition of the existing approved scope, not a new scope commitment,
architecture decision, or acceptance-criterion amendment.

The [32 MHz review](candidate-go-no-go.md#32-mhz-architectural-reassessment)
supplies the findings. Retain the existing owner boundaries and approved
contracts. Applicable contracts include SPEC-001/015 for source admission and
host service, SPEC-007 for layout, SPEC-008/012/014 for rendering and raster
consumption, and SPEC-013 for profile/resource obligations. Existing features
remain implemented; this task record does not change their lifecycle status.

| Subtask | Fixed implementation outcome |
| --- | --- |
| I3-T01.1 — Source scheduling | Preserve source deadlines and admit overdue events in bounded, ordered batches. Preserve timestamps, generation boundaries, Start/Stop/Clear behavior, capacity and failure handling. |
| I3-T01.2 — Embedded raster | Implement a bounded, allocation-free fast path for the analyzer's orthogonal waveforms, preserving pixel coverage, painter order and synchronous borrowed-view lifetime. |
| I3-T01.3 — Layout lookup | Replace repeated linear workspace searches with bounded indexing while preserving identities, layout results and approved storage limits. |

These are subtasks of one package, not independently renewable investigations.
Implement and commit coherent changes in this order, then assess the integrated
result. At launch, update the affected existing per-Spec implementation plans
with exact source/test boundaries, contract mappings and validation commands;
record any technically necessary internal design in their focused design notes.
That work belongs to this task and its budget. This coordination entry alone is
not a ready per-Spec plan or authority for a new algorithmic contract.

### Implementation-plan ownership and launch details

The linked per-Spec plans retain their earlier task history. Their historical
`ready` or `completed` status does not establish I3-T01 execution readiness.
The following links assign responsibilities within this one task, not seven
new tasks or independent budgets:

| Plan | I3-T01 responsibility |
| --- | --- |
| [SPEC-001](../../implementation-plans/spec-001-implementation-plan.md#iteration-3-correction-task--2026-10-09) | Application scheduling, target-specific host/workspace changes, workload and integrated application evidence; coordinate the shared task report. |
| [SPEC-015](../../implementation-plans/spec-015-implementation-plan.md#iteration-3-correction-task--2026-10-09) | Host source deadlines, wake/pacing and bounded admission joins with SPEC-001. |
| [SPEC-007](../../implementation-plans/spec-007-implementation-plan.md#iteration-3-correction-task--2026-10-09) | Layout identity, output equivalence and bounded workspace checks for indexing. |
| [SPEC-014](../../implementation-plans/spec-014-implementation-plan.md#iteration-3-correction-task--2026-10-09) | Bounded stroke raster implementation, coverage storage and synchronous tiled consumption. |
| [SPEC-008](../../implementation-plans/spec-008-implementation-plan.md#iteration-3-correction-task--2026-10-09) | Render/painter/clip/failure regression obligations; no Render contract amendment is selected. |
| [SPEC-012](../../implementation-plans/spec-012-implementation-plan.md#iteration-3-correction-task--2026-10-09) | Stroke coverage and borrowed-path lifetime regression obligations; no drawing contract amendment is selected. |
| [SPEC-013](../../implementation-plans/spec-013-implementation-plan.md#iteration-3-correction-task--2026-10-09) | Profile equivalence and complete accounting of changed storage, allocations and stack costs. |

At launch, the executor must freeze the exact affected files, selected internal
algorithms, criterion-to-check mapping and commands in those plans before the
dependent code changes. The per-Spec launch entries now freeze these details; the three
subtask descriptions are outcomes, not fully specified algorithms. Reuse
existing contract checks and add targeted regressions where needed, with no
separate approval loop for ordinary derived planning. A required contract or
architecture change still follows its normal gate.

### Working assumptions and evidence boundaries

- Keep the accepted core owner boundaries as the working basis. The source
  review found no unavoidable contradiction; it did not prove that local
  corrections will achieve four FPS or eliminate every later design change.
- I3-T01 starts from maintained production with its existing generated graph.
  Improve reusable host/raster/layout owners without adopting archived runtime
  experiments. Graph removal and both applications' runtime derivation remain
  I3-04; revalidate these corrections on that later integrated representation.
- The scheduler correction concerns deterministic source deadlines and ordered
  bounded catch-up. It is not a promise to recover arbitrary unbuffered physical
  GPIO edges or to tolerate unlimited backlog. The default deterministic source
  is not the required 80-events/s stress workload; validation must distinguish
  them and preserve the existing admission capacities.
- The 32 MHz rate is an analytical assumption for the nRF display only. The
  production overlay remains at 4 MHz. I3-T01 does not silently change that
  setting; an actual clock change and device verification must be explicitly
  recorded before any 32 MHz target claim. Pi/macOS costs are unaffected by
  the assumption. The known 65.276 ms fill/command wire floor is not a full
  frame timing prediction.
- The iteration still covers both applications and four configurations.
  I3-T01's Pi/nRF scheduling and Embedded raster/layout focus is narrower;
  cross-profile regressions remain required, and it does not promise to remove
  every Pi bottleneck or establish counter safety. Account for index/coverage
  storage and preserve approved limits; faster code is not automatically
  lower-memory code. Candidate reservations are not approved application budgets.

### How this task informs subsequent work

I3-T01 delivers corrected production code and bounded validation results that
give the remaining iteration work concrete context: which costs were reduced,
which constraints remain, and whether further design changes are necessary.
Its final report must map those findings to the existing activities below and
recommend their direction within the unchanged iteration goals. This mapping
is part of the same task and budget, not a separate investigation.

| Subsequent work | Relationship to I3-T01 |
| --- | --- |
| ME-05/06 runtime-derived graph design and implementation (I3-04) | Use the corrected code, resource results and remaining constraints when selecting the realization. Ownership/lifetime design can proceed independently; I3-T01 neither proves its safety nor supplies missing architecture/contract approval. |
| ME-08 integrated validation | Requires the completed implementations together. Revalidate the exact integrated artifacts; I3-T01's local results do not establish runtime-derived or connected-hardware conformance. |
| ME-09 closure and handoff | Uses integrated validation and explicit dispositions of remaining criteria; I3-T01 completion alone does not enable iteration closure. |

No additional general preparation phase precedes I3-T01: the launch planning
described above belongs inside it. The unresolved runtime design remains a
separate current obligation. Findings steer existing work; they do not
automatically expand scope, create successor tasks or reopen stopped studies.

### Bound and completion decision

Use one ceiling of **eight active hours** for planning, implementation, builds,
tests, repairs and the final report across all three subtasks. Record cumulative
usage in this entry when execution begins and after each work session. Exclude
waiting for maintainer input or unavailable hardware and report it separately.
The budget does not reset at a subtask, commit or session boundary.
This is an executor-selected work ceiling, not a delivery-time guarantee or a
claim that the maintainer approved that particular number. Execution launched on 2026-10-09 at 16:43 UTC, with 15 minutes charged for
launch orientation/source inspection before that timestamp. Cumulative charged usage is at most 140/480 minutes; see the
[final accounting](i3-t01-result.md#budget). The allowance is closed.
The eight-hour limit covers I3-T01 only, not the whole iteration. Subsequent
work still needs a concrete bounded execution plan; this record does not
promise a total iteration duration or authorize an indefinite continuation.

Finish with one integrated report that records each subtask's disposition,
commits, correctness checks, resource results, performance evidence and its
limits. Run focused regression checks and the applicable repository/profile
and target build checks; format maintained Swift before the repository test
gate. Preserve the existing 80 events/s for 30 seconds, four-FPS, semantic/pixel
correctness and bounded-memory requirements. A speedup or host build alone is
not a pass for those target requirements.

Close this bounded task as **passed within the stated validation boundary** or
**ended with named failures or unmet checks**. Budget exhaustion requires the
latter report; it is not success. Do not mark incomplete subtasks successful.
Missing connected evidence remains an explicit ME-08 gate and does not keep
this local implementation task open indefinitely. The assumed 32 MHz rate is
not a verified display capability; flashing and deployment require explicit
authorization.

An architecture/contract conflict stops the affected implementation and is
reported against its governing artifact. New findings do not add subtasks,
experiments or automatic successors. Any extension needs an explicit maintainer
decision on the reported result and additional bounded work.

Runtime-derived graph migration and its unresolved ownership/lifetime proof
remain separate current iteration obligations under I3-04 and ME-05/06; this
task neither adopts that candidate nor defers those obligations. FW-027/FW-032
remain the performance provenance, and FW-024/025/026 remain outside this task.
Task closure does not close iteration 3 or establish iteration-4 readiness.

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

The following experimental rules governed the closed preparation phase.
I3-T01 uses its own implementation bound above; neither allowance renews the
other or reopens SPIKE-067/068.

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

## Historical actions at the preparation amendment

This table records permissions when revision 5 was first adopted. Its phase
launch and experiment rows are no longer open: the recorded phases have ended.
Use the current readiness table and I3-T01 task above for the next action.

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

### Explicitly authorized one-candidate assessment

After the above terminal report, Eugene authorized the presented replacement:
one complete candidate, fixed safety/semantics/performance requirements, one
time/invocation/repair budget, and **GO or NO-GO** with no automatic successor.
The [candidate assessment](candidate-go-no-go.md) records the exact instruction,
design, numeric working limits, mandatory gates and terminal result. Any failed
or unproved mandatory gate means no-go for adoption; a demonstrated failure
ends experiments early. This specific attempt overrides the three-way reporting
rule above without rewriting that historical outcome. Later production and
iteration closure gates remain unchanged. New findings are report findings,
not automatically additional ME activities or evidence tasks.

**Terminal update:** the one-candidate assessment ended **NO-GO**. SPIKE-068
establishes a 508.48 ms nRF background-fill wire lower bound against 250 ms;
G1/G2 remain unproved. ME-05 adoption readiness is not established. Preparation
is stopped. A different rendering/transfer strategy or a changed requirement is
a maintainer decision, not a new automatically opened ME step. The same candidate
must not be reopened merely to gather more profiling or stack evidence.

Eugene then explicitly authorized the
[32 MHz architectural reassessment](candidate-go-no-go.md#32-mhz-architectural-reassessment).
It changes the analytical bus assumption and asks for unavoidable architectural
blockers. It is a single bounded source/contract review, not an automatic
continuation or a hardware change. Preserve the 4 MHz verdict and all adoption
gates while recording the new review separately in the same packet.

The 32 MHz review is complete: no further unavoidable architectural contradiction
was found. Retained source-deadline rebasing needs correction, current CPU costs
need bounded implementation improvements, and complete safety/performance remain
unproved. The recommendation is to retain the core architecture and address
these implementation/design obligations. This does not establish ME-05 readiness
or open another preparation phase.
