# One-candidate adoption assessment

Status: terminal **NO-GO for adoption**; RFC review verdict **not ready**.
Parent: [draft RFC-013](../../rfcs/rfc-013-external-application-and-backend-integration.md).
Candidate: **runtime-emitted records with owner-resolved handles**, defined below.
This is the RFC's runtime candidate appendix and a finite adoption assessment,
not an accepted architecture, Specification or implementation plan.

**Decisive result:** the retained nRF rendering/transfer path needs at least
**508.48 ms for background fills alone**, against the 250 ms frame budget.
The root background alone needs 281.6 ms. The assessment is closed; no successor
study or production migration is initiated. The frozen design below is retained
so the rejection has an exact scope. See the terminal review at the end.

## Authorization, scope and stopping rule

After the previous [inconclusive assessment](feasibility-decision.md), Eugene
challenged whether another proposed review would create an infinite ladder.
The replacement proposal was one complete candidate, frozen requirements, one
budget, and a binary go/no-go decision. Eugene replied on 2026-10-09:

> Okay, let's do this step.

That explicitly authorizes this attempt. It does not retroactively approve the
old candidate or renew SPIKE-067 without limit. The material change is to assess
one entire candidate against **all** required outcomes, stopping on a decisive
failure rather than repeatedly repairing an individual mechanism. The earlier
source review and SPIKE-067 remain closed historical records.

- Start: **2026-10-09 15:11:26 UTC**; hard deadline **16:11:26 UTC**.
- At most **24 underlying experimental build/run invocations**, including
  failed invocations and compiler subprocesses; at most **2 repair attempts**.
- Time includes source/design review, experiments, validation and reporting.
  Source reads, arithmetic, hashing and documentation checks are not experiments.
- No second candidate, automatic successor study, evidence-extension phase or
  new acceptance requirement. A repair may fix a probe or implementation defect;
  it may not change the candidate's architecture or waive a gate.
- Stop experimental work at the first decisive mandatory-gate failure or budget
  exhaustion. Finish the report and commit it. Unrun gates remain unproved.
- **GO:** every frozen mandatory gate below is demonstrated; proceed to the
  existing human architecture/contract approval gates, not production adoption.
- **NO-GO:** any mandatory gate fails or remains unproved at termination. Report
  demonstrated incompatibility separately from missing proof. This rejects
  adoption of this candidate; it does not prove all runtime derivation impossible.

## Summary and context

Replace aggregate expanded declaration storage with runtime-appended bounded
records. Keep state and captures in address-stable owner storage, resolve small
typed handles only inside an active service lease, and retain the current
Semantic → Layout → Canvas → Render → synchronous backend pipeline.
Remove large inline capture values from declaration bodies and callable payloads.
Do not replace the display transport or rendering strategy in this candidate.

The investment is the runtime derivation constraint of accepted PROPOSAL-007
and I3-04, supporting the two reference applications and the future external
consumer. I3-05 and IT-AC-009 are adoption constraints on that design. RFC-013
does not grant blanket authority to redesign performance architecture.

## Requirements and decision boundary

Both Signal Analyzer and the finite counter must derive topology from their
portable declarations on macOS Dynamic, macOS Static, Pi 1 ARMv6 Dynamic and
nRF52840 Embedded Static. Generated font resources and finite typed callable
bindings may remain; generated expanded topology, application-specific
pre-expanded record tables and generated parent/child links may not.

This candidate is one representation/ownership/execution decision cluster.
It preserves the existing module owners and public declarative vocabulary.
Package splitting, public host APIs, display damage/caching strategy, a new
asynchronous executor and hardware changes are outside it. Those choices cannot
be smuggled in as probe repairs if this candidate fails.

## Proposed design and module responsibilities

### Representation and construction

Runtime traversal evaluates each active declaration body once per derivation,
appending compact records to the candidate arena. Each record contains a kind,
structural identity, parent/first-child/next-sibling indices and a typed payload
index. Indices, counts and depth are checked before writes. Text, primitive,
modifier and action payloads live in separately charged bounded pools. An
explicit bounded traversal stack replaces retained nested body aggregates;
transient compiler-generated body values still need emitted-stack proof.

SemanticCore continues to own the read-only semantic boundary. Runtime owns
record construction, identity reconciliation and publication. Layout borrows
the completed candidate through the existing semantic-view contract; it does
not copy a complete tree (ADR-032). The published and candidate arenas are
distinct until publication; no overlap saving is assumed. Failed construction
discards only the candidate and preserves the last published tree.

### State, captures and callable lifetime

Each model lives in a typed owner slot keyed by structural identity and local
declaration identity. A copied model handle contains an owner token, slot and
generation, never an address of a local initializer temporary. Resolution checks
the owner token, generation and service phase before returning a scoped borrow.
State replacement first validates/registers the new association, then commits;
failure preserves the old association. Removing a published owner retires its
registration and generation. Exhaustion refuses reuse rather than wrapping.

Analyzer live, snapshot/model and admission capture stores remain distinct
404-record stores. A drawing capture is a small slot/revision handle. The owner
freezes its snapshot until all Canvas invocations finish; resolution requires
the active owner and matching revision. The finite counter has one typed model
slot and its own finite action/canvas bindings. Neither application uses an
escaping pointer to a stack-local model as its ownership mechanism.

Pointer-bearing views are internal, synchronously borrowed values. Persistent
handles remain harmless after teardown because they require an independently
live owner to resolve. No global resolver, thread-local state or implicit task
context is introduced. The unresolved design-to-contract issue is how existing
`@State` and value-shaped capture access expose this resolver without changing
observable semantics; this is a mandatory proof obligation, not assumed solved
by naming the handle. Raw-pointer wrappers alone do not prove non-escape.

### Service, publication and teardown

1. Host owns backing before activation and admits compact facts into the
   existing active/sealed bounded admission regions.
2. Runtime applies accepted facts/actions exactly once to the live model,
   freezes a coherent revision, reconciles state and derives candidate records.
3. Shared Layout computes bounds/text; Canvas resolves frozen captures, emits
   the drawing plan and releases callable leases. Render validates the combined
   stream before publication/offer. Drawing records stay live through streaming.
4. Preserve existing semantic/observable publication and interaction transaction
   ordering. Backend consumes the ordered one-shot stream synchronously through
   the current operation-major RGB565 tile endpoint and target transport.
5. Drop all layout/drawing/semantic borrows before resetting attempt scratch.
   Backpressure/refusal and post-acceptance faults retain their existing distinct
   dispositions; accepted facts are not replayed on a frame retry.
6. Teardown quiesces input, ends any active synchronous offer, unregisters models,
   invalidates generations and releases backing last. A failed attempt cannot
   publish partially constructed state or retain a pointer into its scratch.

Existing host scheduling and target transfer configuration are retained. Record
indexing can remove duplicate lookup work; local bounded raster arithmetic may
be optimized only with identical operation and transfer semantics. No performance
improvement is assumed from the smaller representation itself.

## Constraints, public API, capabilities and backends

Preserve ADR-006/007 profile semantics and owner direction; ADR-024/025/026 state
ownership/invalidation/Static restrictions; ADR-032 semantic borrowing;
ADR-033 typed actions; and ADR-010 synchronous one-shot offer semantics.
SPEC-001/006/010/012/013/015 would need reviewed runtime/representation and
capacity amendments before adoption. SPEC-007/008/011/014 remain the layout,
render, surface and backend contracts; this candidate does not waive them.
Any necessary `@State` or capture API change must be explicit in that review.
Portable presentation still imports GiftUI; target selection remains host-owned.

Dynamic uses owner-allocated storage with the same bounded logical identities.
Static/Embedded uses caller-owned fixed regions, no heap, reflection, arbitrary
existentials or unbounded callable storage. The candidate does not use a
compiler feature as a substitute for ownership proof. Actual nRF hard-float
and Pi ARMv6 compositions are required for target claims.

## Memory, performance and binary bounds

The following are **assessment ceilings**, not approved application contracts
or measured consumption. No region may borrow unused bytes from another live
region without a proven lifetime exclusion. Counts include candidate and
published state where both are live.

| Proposed nRF reservation | Analyzer bytes | Counter bytes |
| --- | ---: | ---: |
| Frame arenas, all record/payload/layout/text/Canvas/admission/interaction scratch | 65,536 | 8,192 |
| Typed model/capture owner backing | 24,576 | 2,048 |
| Main stack | 27,648 | 8,192 |
| ISR stack | 2,048 | 2,048 |
| All remaining linked writable memory, guards, alignment, transport and platform state | 8,192 | 8,192 |
| **Total ceiling** | **128,000** | **28,672** |

The analyzer record sublimit is 128 scopes × 32 bytes × two arenas = 8,192
bytes within its frame reservation; counter uses 32 × 32 × two = 2,048 bytes.
Analyzer depth is at most 32, counter 16; payload pools must fit the frame totals.
Analyzer retains 224 glyph/scalar, 128 text-line and 404-record capture bounds;
counter is limited to 32 glyphs/scalars/lines, one model and two action bindings.
Overflow must be deterministic and preserve live state. These proposed limits
need fixture and emitted-image validation; they are not findings of feasibility.

Both nRF images must also fit the existing 196,608-byte application RAM and
1,048,576-byte flash ceilings with zero heap. Whole feasible-path main/IRQ stack,
callbacks and recursion must fit the reservations including construction and
teardown. A single small local frame or observed high-water value is insufficient.

Across all four profiles, report paired baseline/candidate owned bytes, stack,
allocations and peak process memory under identical work. Dynamic must not
regress measured baseline peak memory; a numerical limit cannot be invented
from source alone. Smaller nRF use than the archived 169,984-byte candidate is
not a claim of improvement over the 95,104-byte generated production image.

## Frozen testing and adoption gates

| Gate | Required result | Decisive rejection condition |
| --- | --- | --- |
| G1 — representation and semantics | Both apps, all four profiles: actual runtime topology; matching identity/state/actions/layout/pixels, failure and teardown oracles; no generated graph input | Structural contradiction, semantic mismatch or missing proof |
| G2 — memory and lifetime | Exact supported artifacts; exclusive storage accounting, complete stack/callback/IRQ bounds, zero-heap Static and stale/escape/alias/capacity controls within the above ceilings | Unsafe bound, unresolved ownership or missing supported-image proof |
| G3 — sustained performance | Analyzer: existing SPEC-001 workload, at least 30 s at 80 events/s and four-FPS target cadence, correct ordered capture and required latency; three independent paired baseline/candidate runs per target with instrumented/control accounting | An unavoidable cost already exceeds 250 ms; any workload failure; or required paired evidence missing |

Check inexpensive necessary conditions first. A native geometry or recording
probe can refute a preserved transfer strategy; it cannot establish target
timing, stack, ABI, heap safety or complete candidate implementation. A failed
analyzer gate rejects the combined candidate without manufacturing a counter
pass. Connected operations still require explicit target-operation authorization.

## Alternatives, risks and open questions

The archived aggregate candidate has useful partial behavior evidence but
unresolved copy/lifetime/stack closure; it is not resumed here. Generated topology
is the production control but cannot satisfy runtime derivation. A full-surface
buffer, changed damage strategy, higher transport rate or asynchronous scheduling
would be a materially different candidate, with its own memory/semantic/hardware
implications. None is silently substituted to rescue this attempt.

Primary risks are resolver compatibility, compiler body temporaries, whole-path
stack closure and the retained rendering/transport cost. These remain adoption
blockers until demonstrated, not new preparation tasks. A successful micro-probe
would answer only its named question, never all three gates.

## Deferred work and decision summary

Existing [FW-027](../../future-work/fw-027-pi-performance-investigation-resumption.md)
and [FW-032](../../future-work/fw-032-nrf-performance-improvement.md) retain
performance provenance. The assessment may identify a necessary different
decision, but creates no automatic work item, follow-up experiment or milestone.
Results of [SPIKE-068](../../spikes/spike-068-candidate-transfer-bound.md) feed this
record. The terminal review and gate dispositions follow below.

Potential ADR extraction if supported: runtime record ownership/publication and
owner-resolved State/capture lifetime. No ADR is accepted by this assessment.

## References

- [Approved iteration scope](../iteration-003-dev-ux-improvement.md)
- [Coordination plan](memory-efficiency-plan.md)
- [Baseline and historical source analysis](feasibility-decision.md)
- [Accepted investment](../../proposals/proposal-007-external-application-integration.md)

## Terminal review — 2026-10-09

**Verdict: not ready. Adoption decision: NO-GO.** Reject this complete candidate
as a solution to iteration 3 while it preserves the present rendering/transfer
strategy. This is stronger than a missing benchmark: its mandatory wire work
already violates the frame budget even if all computation were instantaneous.
It does not establish that runtime records or typed owner handles are impossible.

### B1 — decisive performance blocker

Location: candidate Service step 4 and its retained operation/transport strategy.
[SPIKE-068](../../spikes/spike-068-candidate-transfer-bound.md), committed in
`0afc0b96`, rehearsed current generated nRF semantics, common Layout and shared
Render on the host. The normal running screen resolves to **320 × 220** root
bounds and emits **nine background fills totaling 127,120 clipped pixels**.
Canvas strokes and glyph pixel costs were omitted, making the count conservative.

The target transport encodes two RGB565 bytes per pixel, and
[`app.overlay`](../../../firmware/nrf52840/applications/signal-analyzer-static/app.overlay)
sets the display SPI limit to 4,000,000 bits/s. The current operation-major
endpoint transmits each operation before the next, including overlapping fills.
The driver sends those bytes directly; it has no rectangle-fill offload or
retained-pixel comparison. Therefore:

`127120 × 2 × 8 / 4000000 = 0.50848 seconds per frame, for fills alone`.

Even removing every overlapping fill leaves the root background's
`320 × 220 × 2 × 8 / 4000000 = 0.2816 seconds`. Both exceed 250 ms.
The nine fills alone imply an optimistic upper bound of about **1.97 FPS**.
Doubling the bus rate hypothetically would still take 254.24 ms for those fills,
before commands, waveforms, glyphs or CPU time; no bus change was tested or made.

This argument depends on the explicitly preserved layout/operation/transfer
semantics. A new damage policy, operation coalescing or transport may change it;
those would change the frozen candidate and cannot be counted as probe repairs.
Faster semantic traversal, smaller captures, direct record lookup or stack-frame
repairs cannot remove these wire bytes. More profiling of this candidate is not
needed to establish this rejection.

Required resolution **before reconsidering adoption**, not an automatically
scheduled task: explicitly select a materially different rendering/transfer
strategy capable of fitting the existing requirement, or explicitly change the
requirement/target commitment through its approval gates. Memory improvement
alone does not resolve B1. This report selects neither alternative.

### B2 — safety and compatibility remain unproved

Location: State/capture resolver integration, complete construction/service/
teardown stack, and supported compositions. No complete runtime-derived image
was built. Owner-handle compatibility and non-escape, state replacement/failure
semantics, callback/IRQ closure and exact resource ceilings remain unproved.
The native fixture is a combined source control with imports removed, not
separate-owner firmware. It supplies geometry only, not stack, heap, ABI or
target timing evidence. These are blockers to adoption, not new follow-up tasks.

| Frozen gate | Terminal disposition |
| --- | --- |
| G1 — both applications/all profiles/runtime derivation and semantic parity | **Unproved**; no runtime-derived replacement was implemented. |
| G2 — safe complete storage/lifetimes/stack and resource ceilings | **Unproved**; no supported candidate artifact or whole-path proof. |
| G3 — sustained acquisition and four-FPS presentation | **Failed necessary condition** on nRF; no paired workload pass claimed. |

An analyzer failure rejects the combined candidate. Counter, macOS and Pi
implementation/measurement were not continued after the decisive failure.
The rejection does not reclassify their missing evidence as measured failures.
Existing MVP exceptions and implemented feature statuses remain historical
authority, and no iteration criterion is marked met by this assessment.

### Execution, validation and stop

- Candidate/gates frozen before compilation in **`7d4e8f59`**.
- Experiments stopped at **15:24:23 UTC**, 12 minutes 57 seconds after launch.
- Terminal report and verification completed at **15:28:54 UTC**, 17 minutes
  28 seconds after launch, within the 60-minute ceiling.
- Two explicit compiler-driver invocations and one native execution; one probe
  repair. The first build omitted the composition enum and a rectangle unwrap;
  its failure is retained and is not classified as a candidate defect.
- Compiler/linker subprocesses were not individually traced. The entire
  24-invocation allowance is conservatively charged closed; no exact child count
  or unused experiment allowance is claimed. One of two repairs was used.
- Retained source/recipe hashes verified against the working tree, rectangle
  areas and byte/time arithmetic checked, and raw logs preserved in the
  [evidence directory](../../../experiments/spike-068-candidate-transfer-bound/evidence/decision.json).
- Governance and whitespace validation passed. Production sources, authoritative
  ADRs/Specs and hardware were not changed. No production test pass is claimed
  from this disposable probe.

This is the final assessment, not “inconclusive, therefore do another study.”
No new evidence request, replacement candidate, ADR extraction, implementation
plan, connected action or preparation phase follows automatically. The existing
iteration remains active with its delivery gates unmet; closing this assessment
does not close or abandon the iteration.
