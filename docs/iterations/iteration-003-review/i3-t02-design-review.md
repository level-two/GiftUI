# I3-T02 runtime design review and adoption sequence

**Verdict: not ready for RFC approval or production implementation.**
The bounded design package is delivered with named blockers. This is an
executor self-review of [draft RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md),
not independent reviewer approval or target validation. Initial design commit:
`2d0a034d`; the final review commit also contains the corrections below.

The original I3-T02 findings below describe the authoring task. The subsequent
[B1 follow-up](#b1-follow-up--spike-069) adds evidence without approving the RFC
or changing the original task's budget/history.

## Typed access and three-bank policy review — 2026-10-10

**Verdict: not ready for RFC approval; requested design package delivered.**
Author consistency review using the RFC-reviewer checklist; not independent
review, compiler evidence or human RFC approval. Eugene explicitly selected
[three-bank bounded refusal](rfc-014-capture-policy-choice.md). The
[typed access contract](rfc-014-typed-access-contract.md) is the resulting draft
engineering recommendation. No additional maintainer policy choice is pending.
Earlier sections below retain the evidence and decisions at their recorded stage.

| Severity / location | Finding and required resolution |
| --- | --- |
| Resolved design direction / SR-Q3 | Generated application schema requirements and fixed per-conformance domains avoid an app-aware GiftUI core. Scoped facades and explicit checked writes replace the universal scalar-reader candidate. Body remains compiler-derived. The complete contract is now reviewable. |
| Resolved policy / SR-Q4 | Keep source/admission/model at 3 × 404 × 16 = 19,392 transition bytes. Separate model metadata from bank entitlement; preserve independently retained owners and refuse unavailable capacity before commit. No ADR-034 resource amendment is requested. |
| Blocker / B1, access composition | Compile the primary-associated-domain View, same-domain containers, custom children and leaf lifting across actual modules. SPIKE-073 tested a simpler concrete context; it does not prove this generic schema ABI. No nonescapable associated type or newer compiler is assumed. |
| Blocker / B0/B2, transfer and lifetime | Verify the capacity contract's failure matrix on actual ownership routes. An installed empty analyzer still reserves a bank; transfer requires explicit last-owner release. Guard callbacks against invalidating reservations, keep attach seed reads scoped, and preserve SPEC-010 invariant-failure behavior. Descriptor pointees, all host caches, cleanup and generation reuse still require evidence. |
| Blocker / B4, real source behavior | Validate every source-route row, including capture preflight before writes, short-circuit/helper order, initializer effects and failure transport. A mapping is not an implemented frontend. Existing owned Domain capture semantics require an explicit presentation-type migration. |
| Blocker / B2/B3, costs | Lay out model metadata, descriptors, tickets and registration separately from the transition subtotal; measure full supported images and stack paths. Two metadata slots have no measured footprint yet. Dynamic and Static must enforce the same configured outcomes. |

Corrections made during review: expose the same-domain opaque constraint rather
than assume unconstrained `some View` carries it; keep Never out of the universal
Body-domain equality; reject the empty-candidate loophole that would steal a
retained model's bank on its first update; distinguish initial materialization
from replacement; preserve detach-hook invariant failures instead of promising
rollback after commit. These are contract corrections, not new test results.

No non-blocking follow-up was extracted: the missing proofs are current RFC
blockers. Candidate ADR extraction remains contingent on RFC approval, including
the compiled View/access boundary and bounded ownership realization. Do not
create a fourth-bank ADR or reopen the terminated compiler studies.

Package validation: `scripts/format-swift.sh`, `ruby scripts/validate-governance.rb`
and `git diff --check` pass; 164 local links in the affected design documents
resolve. Production Sources, Tests, Package.swift and scripts are unchanged from
`a948e221`. No compiler, runtime or hardware test is claimed for the new contract.

## Stable-read evidence disposition — 2026-10-10

**Verdict: not ready for RFC approval; bounded correction package complete.**
This is an author consistency review, not independent reviewer approval.
[SR-Q1–4 results](rfc-014-stable-read-revision.md#activity-results--2026-10-10)
record the source audit and terminal SPIKE-073 (`3a6b1199`).

| Finding | Disposition |
| --- | --- |
| SR-Q1 / CE-5, model-read lifetime | Existing synchronous ordering and owned drawing-plan interface permit model-data access to end after Canvas invocation/discard. Caller cleanup is required for early failure; no new owner-pool or all-host conformance claim. |
| SR-Q2 / CE-2, Body inference | Fixed concrete borrowed context supports inferred non-Never custom Body in the finite fixture on all four compiler configurations. Both native runs pass 15 checks; eight negative controls reject. Real schema/module integration remains open. |
| SR-Q3 / CE-1/3/4, access contract | Separate snapshot selection disappears. Scoped access, helper transformation or safe owner-bound getters, checked mutation and ownership still need a complete application contract. Existing wrappers do not prove safe borrowed access. |
| SR-Q4 / B0/CE-7, memory | Mandatory F0 removed; conditional K=2 non-sharing cost is four banks, 25,856 bytes. ADR-034 remains three banks. Resolve replacement/retention policy or prove safe allocation before requesting resource approval. |
| B2/B3, full feasibility | No production migration, actual Runtime profile exercise, target link/run or full-image memory/stack proof. Existing blockers remain. |

The experiment stopped within its original ceilings: 15/16 invocations, one/two
repair rounds, approximately 41 seconds. Its diagnostics, snapshots, ABI evidence
and limitations are recorded. Do not rerun a generic escape matrix or expand
frontend grammar merely because other contract details remain unresolved.

## Stable-read correction review — 2026-10-10

Current [SR-1–6 and bounded activities](rfc-014-stable-read-revision.md) supersede
copy-freeze and mandatory frontend Body derivation as the working baseline.
The author review finds no need to amend accepted ADR-011/025: they require
mutation exclusion, not a copied model. B0 remains open for retained-owner storage;
B1/B2 remain open for safe access/ownership. CE-2 now asks whether a non-generic
evaluation requirement permits compiler-derived Body. Existing SPIKE-072 results
are preserved; they do not require retaining its method-generic interface.
No production or RFC approval follows. Evidence dispositions will be recorded
against SR-Q1–4 before this bounded package ends.

## Contextual integration evidence review — SPIKE-072, 2026-10-10

**Verdict: not ready for RFC approval; bounded integration mechanism supported.**
Author consistency review, not independent or human approval.
[SPIKE-072](../../spikes/spike-072-contextual-traversal-integration.md), experiment
commit `9e0d49b3`, supplies seven separately compiled adapted modules plus an
application on four configurations, 111 passing checks on each native profile,
and four intended parent-read/child-discovery rejections. The
[terminal report](../../../experiments/spike-072-contextual-traversal-integration/evidence/result.md)
preserves 60 invocations and the explicit fifth-repair deviation from the initial
four-round estimate. Production sources, compiler policy and authority are unchanged.

| Finding | Updated disposition / required resolution |
| --- | --- |
| CE-1, source/build compatibility | Maintainer provisionally selected finite transformation for this experiment. Mandatory transformation and changed compiled View remain candidate contracts, not adopted source/binary compatibility. |
| CE-2, generic conformance | Root and nested custom hosts now traverse actual SemanticCore across real module boundaries. The successful realization derives concrete Body aliases; automatic generic opaque Body inference is unproved. A universal leaf default inferred Never and failed native checks; constrain leaf defaults and prove all supported Body shapes. |
| CE-3, read versus State discovery | Same-frame scalar child discovery works after parent evaluation returns; simultaneous parent-read/child-binding rejects on all four configurations. Fixture Binding/Session do not replace the production State reconciler, registration rollback, independent ownership, owner generations or C-P3. |
| CE-4, source effects / coverage | Runtime branch identities/counts and poisoned short-circuit reads pass for the finite corpus. The [application inventory](../../../experiments/spike-072-contextual-traversal-integration/application-coverage.md) shows that neither complete application fits the current grammar. Define complete source/type/helper/current-mutation coverage before claiming frontend feasibility. |
| CE-5, Drawing connection | Actual CanvasPlanProducer/CanvasInvocationSource accept a separately borrowed generic read facade across modules. Distinct draw order, mid-list failure, access-to-invalidScope mapping and release checks pass. Resolved layout, recording workspace and occurrence store are fixtures; actual immutable geometry storage/host publication remain unproved. |
| CE-6, compiler / resources | Four supported configurations and separate modules compile with the pinned experimental flags. Native flags use the same scalar owner; Dynamic class equivalence and complete-image heap/stack/indirect-call costs are not proved. No target execution claim. |
| CE-7, physical storage | Unchanged: scalar two-entry backing does not settle independent capture owners or amend ADR-034. Complete C-P3 and exact resource accounting before the five-bank decision. |

The next useful design work is a finite source/type/effect contract and complete
counter/analyzer candidate corpus, including explicit Body derivation, helper
classification and current mutation/report routes. Keep independent owner/frame
storage proof separate. Do not repeat the general escape matrix or hide required
frontend work in FW-035. Candidate ADR extraction remains after RFC approval.

## Contextual evaluation design review — 2026-10-10

**Verdict: not ready for RFC approval; requested design step delivered.** This
is an author consistency review using the RFC-reviewer checklist, not independent
review or human approval. [Design commit `8ba066c3`](rfc-014-contextual-evaluation.md)
replaces the unspecified production seam with an explicit proposed compiled View
contract and sequencing. No compiler or production experiment occurred here.

The main design correction is to distinguish a frame lease from a Swift read
borrow: pin the complete frame, borrow for one body, return owned children, end
the borrow, then bind/traverse children. A long FrameRead stored in the current
ordinary visitor cannot be inferred from SPIKE-071. The proposed visitor instead
receives a separate scoped session, and Drawing receives a separate typed access
argument. The draft also preserves conditional evaluation when lowering typed
reads; unconditional hoisting would change short-circuit behavior.

| Finding | Severity / location | Required resolution |
| --- | --- | --- |
| CE-1: authoring/runtime split changes the View contract | Blocker B1/B4; design §2/§7 | Explicitly review the mandatory finite transformation and contextual compiled witness proposal. It preserves source forms, not untransformed Swift/old-protocol compatibility; direct body/draw bypasses and precompiled old views need diagnostics. An ordinary wrapper/macro addition is not claimed. |
| CE-2: exact contextual generic conformance remains uncompiled | Blocker B1; §2/§3 | Establish concrete Swift read/session lifetime constraints, stable opaque Body type, root and nested custom View conformance through real SemanticCore, and absence of runtime storage imports/existential fallback. SPIKE-071's root descriptor does not settle this. |
| CE-3: State discovery must not overlap read borrows | Blocker B1/B2; §3/§4 | Demonstrate parent borrow ends before child binding; new same-epoch frozen entry is fully reserved/initialized without modifying prior entries. Exercise first-excess failure, failed-candidate cleanup and retained independent ownership. Ending a borrow must not free frame storage. |
| CE-4: expression effects and write coverage need complete inventory | Blocker B4; §5/§6 | Preserve branch/short-circuit order, read count and typed error paths; diagnose unsupported helper/escape routes. Cover both applications' body/draw/current-mutation paths, compound updates and synchronous reports. The finite Spike grammar is insufficient. |
| CE-5: actual post-layout adapter and failure origin mapping | Blocker B1/B4; §5/§6 | Carry access separately through actual CanvasPlanProducer/CanvasInvocationSource; no context field in an escapable source. Specify access vs semantic/binding/drawing outcomes and preserve first failure/cleanup without default getter values. |
| CE-6: compiler adoption and whole-image costs | Blocker B1/B3; §7 | Review pinned LifetimeDependence/Lifetimes policy and fail-closed build coverage on all profiles. Bound recursive Body temporaries, helper specialization and drawing indirect calls in the complete image; the rooted object is not that proof. |
| CE-7: physical storage authority is unchanged | Blocker B0/B2; §4/§8 | The five-bank proposal still conflicts with ADR-034; keep exact ownership/peak storage and the formal amendment decision separate from this traversal refinement. |

The contract map names the relevant ADR-006/024/025/026/028 and
SPEC-006/010/012 amendments; ADR-034 remains binding. No accepted ADR, approved
Spec, iteration scope or production build flag changed. Current requirements
were not moved into Future Work. Existing FW-035 remains outside the finite
Swift design and does not absorb its missing enforcement obligations.

Optional feedback: stabilize helper/entrypoint names after the generic interface
is established. Names are not a blocker; exact ownership and source/build
compatibility are. Candidate ADR extraction remains after RFC approval.
Validation covers source-to-contract comparison, local links, governance and
whitespace; no new compilation, runtime, memory or performance evidence.

## Prior C evidence — SPIKE-071, 2026-10-10

**Verdict: bounded mechanism supported; RFC still not ready for approval.** This
is an author evidence/consistency review, not independent or human approval.
[SPIKE-071](../../spikes/spike-071-canvas-embedded-escape-continuation.md) completes
the earlier missing matrix; [exact results](../../../experiments/spike-071-canvas-embedded-escape-continuation/evidence/result.md)
preserve 40 calls and two repair rounds.

All four configurations compile; both native profiles pass 21 checks. Six
negative cases reject for the intended reason on all four configurations. The
nested-helper test required a correction to remove a borrowed-value consumption
error, followed by four positive forwarding controls and four clean negative
rejections. The original confounded diagnostics remain in evidence. Rooted nRF
inspection finds no allocator relocations, five indirect drawing call sites and
correct Cortex-M4F/VFP attributes. No full-image heap/stack claim follows.

B1/B4 now have a supported finite compiler mechanism; the next design boundary
is production contextual View evaluation/error transport, complete field/helper/
current-write coverage, actual State/owner integration and experimental compiler
policy. Existing root descriptor and draw-signature adaptations are not public
compatibility proof. B0 five-bank storage, B2/C-P3 owner/accounting and B3 costs
remain open. No generic matrix rerun is needed absent a candidate change, and no
further experiment or production migration is automatically authorized.

## Prior C evidence — SPIKE-070, 2026-10-10

**Verdict remains not ready.** This is an author evidence/consistency review,
not independent approval. The separately authorized
[SPIKE-070](../../spikes/spike-070-protocol-canvas-versioned-access.md) is terminal
inconclusive; [exact evidence](../../../experiments/spike-070-protocol-canvas-versioned-access/evidence/result.md)
preserves all 11 invocations and two repairs.

- Finite source-dependent generation and real child View/Canvas traversal work
  in both native profile runs (21 checks each); ARMv6 object compilation passes.
- The root's throwing evaluation descriptor and the Canvas draw FrameRead
  parameter are explicit adaptations. Public View conformance/integration,
  actual State/macro ownership and complete helper coverage remain B1/B4.
- Underscored lifetime attributes need the tested Lifetimes/LifetimeDependence
  feature configuration. This is experimental compiler-policy evidence, not
  automatic adoption of those flags.
- Embedded rejects two assertions through the untyped throwing `&&` autoclosure.
  No repair allowance remains. The source correction is plausible but untested;
  none of the 24 negative controls or nRF reachability checks ran. Do not infer
  C-P2 safety, zero heap, nRF ABI or architecture impossibility from this result.
- Equal repeated Canvas values and a first-Canvas failure do not establish
  discriminating painter order or a mid-list failure case. Those candidate
  controls, full C-P3 ownership, B0 storage and complete B2/B3 costs remain open.

Registration and evidence are committed separately. Governance, snapshot/hash,
local-link and whitespace validation do not replace the missing compiler gates.
No experiment is opened automatically; another run needs explicit bounded
authorization. Historical “not launched” paragraphs below predate SPIKE-070.

## Current review boundary — 2026-10-10

The [maintainer-proposed direction C](rfc-014-decision-direction.md) now leads
further RFC design: protocol Canvas and observable properties backed by current
and frozen versions. Earlier A/B recommendations below are historical. **Verdict
remains not ready:** the later [C contract](rfc-014-c-contract.md) and
[storage ledger](rfc-014-c-storage-ledger.md) now specify candidate binding,
copy-freeze and peak logical roles. Their compiler realization, exact layouts
and target costs remain unproved. SPIKE-069 did not test C.

Review C against ADR-028's closure-specific contract and ADR-024/025/026's model
ownership/phase rules. Keep current mutation serialized; the presence of two
versions alone must not implicitly authorize writes during frozen derivation.
Require coherent multi-property reads and stable reachable backing, safe finite
Canvas dispatch, release on every failure edge and retained-owner accounting.
Do not carry the earlier four-slot arithmetic into C without recomputation.

This follow-up records direction and process only, with governance/link/whitespace
validation. It performs no new experiment and changes no approval status.

## Detailed C contract review — 2026-10-10

**Verdict: not ready for RFC approval; detailed design step delivered.** This is
an author consistency review of the proposed contract/ledger, not independent
review, compiled evidence or approval. Exact operation meanings and first-excess
behavior replace the previous unspecified version-selection/storage questions.
They remain candidate contracts until the lifecycle approvals.

| Severity / location | Finding | Required resolution |
| --- | --- | --- |
| Blocker B1/B4 — C contract §2 | `@Published` syntax has no implicit runtime-context argument in Swift. The design now explicitly requires finite generated current/frozen access routes, including typed error transport from nonthrowing body source. | C-P1 must demonstrate the real source transformation and reject unchecked paths; manually written contextual functions alone do not validate the authoring surface. Stop if it requires a general compiler outside iteration scope. |
| Blocker B1 — C contract §2/§4 | Safe identity keys remove stored raw pointers, but actual read/GraphicsContext/owner borrows must remain confined. Protocol conformance and noncopyable values alone do not establish that. | C-P2 negative controls and actual traversal/staging invocation; resolve supported lifetime policy without importing SPIKE-069's experimental-warning result as approval. |
| Blocker B0/B2 — C storage ledger | K=2/F=1 with independent source/admission requires five non-sharing capture banks: 32,320 transition bytes, +12,928 over ADR-034. Four-bank staging reuse fails the retained-former + installed + frozen case. | Explicit storage decision/ADR-034 amendment or a separately proven sharing realization; complete metadata, ABI/alignment, stack and Dynamic accounting. |
| Blocker B1/B2/B4 — owner ticket and host migration | Separate application ownership, registration and frame leases now have an explicit logical ledger; actual Static ticket lifetime and Dynamic equivalence remain unimplemented. Failure effects cannot mutate during freeze. | C-P3 host sequence including failed attach with independently owned candidate, retained former, first-excess/retry, failure-effect ordering and teardown before caller storage release. |
| Blocker B4 — source/model schema | New model schema, presentation capture projection and Canvas methods require migration beyond changing a type name. Newly materialized State must get a same-epoch frozen copy before its body. | Implementable declarations and finite complete field/helper inventory for analyzer/counter; verify normal initialization, ignored seed, structural-removal and branch-capacity behavior. |
| Unchanged B2/B3 / iteration performance | The ledger counts capture backing, not complete firmware resources. Runtime record codecs/path bounds and full-image costs remain open; 4 MHz performance failure is independent. | Preserve their original evidence gates and distinguish approval evidence from post-Spec implementation conformance; no arithmetic-only feasibility claim. |

### Authority conflict and migration map

| Existing authority | Candidate disposition |
| --- | --- |
| ADR-006 / SPEC-006 runtime structural traversal | Preserve runtime traversal and exact identity; amend Canvas protocol leaf recognition/contextual evaluation seams. Never generate graph topology. |
| ADR-024 / SPEC-010 structural State ownership | Preserve materialization, replacement, removal and external ownership. Add separate property identity, model-value/frame epochs, typed owner tickets and frozen-map outcomes. |
| ADR-025 / ADR-011 serialized invalidation/publication | Preserve coarse synchronous reporting, mutation phases, non-reentrancy and failed-frame dirty state. No current writes while frozen and no concurrent mutation feature. |
| ADR-026 bounded equivalent profiles | Preserve source semantics and zero-heap Static requirements; explicitly review model-schema/context lowering and corresponding Dynamic rules. |
| ADR-028 / SPEC-012 closure-based Canvas | Requires an explicit Canvas representation decision/amendment: protocol values replace stored drawing closures. Preserve scoped context, checked local geometry, order, once-per-attempt and cycle-local plan. |
| ADR-034 / SPEC-001/013/015 capture reservation | Five-bank baseline conflicts with exact three-bank authority. Retention stays five seconds/404 entries; no unilateral constant/budget change. |
| SPEC-003/009/010/013/015 errors and owner composition | Review new capacity/epoch/access outcomes and their adapter mappings, versioned property/failure-effect sequencing and host cache removal. Existing production mappings are not silently reused. |

Non-blocking naming detail: `@ObservableModel`, `@Published` and presentation
projection spelling are provisional, with no Combine compatibility commitment.
The logical access/ownership contract must be reviewed before stabilizing names.
No correctness blocker is hidden in a deferred item; storage alternatives remain
current RFC choices until B0 is resolved.

The proposed next proof is precisely C-P1/C-P2 and has a 90-minute/48-invocation/
two-repair ceiling. It is not launched, and the design request does not reset
any prior Spike budget. Governance, links, arithmetic and whitespace checks pass;
no source examples were compiled and no supported-image feasibility is claimed.

## What this step established

- One runtime decision boundary is now separate from RFC-013's external package,
  API and setup decisions, under accepted PROPOSAL-007 and I3-04. Both RFCs remain
  draft. Existing implemented owner Specifications and accepted ADRs remain
  authoritative; no current Spec was edited to adopt the proposal.
- The draft specifies emitted records, exact cross-revision path identity,
  model/capture access, callback isolation, failure/publication/teardown, and
  explicit simultaneous storage. It preserves the current modules and the
  corrected scheduling/raster/layout behavior from I3-T01.
- The analyzer reservation sketch includes a fourth 6,464-byte snapshot for
  staged replacement, with a conditional total of 120,928 bytes. The counter
  sketch totals 30,368 bytes. Both are unapproved and unvalidated proposals;
  incomplete codec, external model ownership and stack obligations prevent a
  feasibility or memory-improvement claim.
- No build, benchmark, firmware operation or experimental invocation occurred.
  No SPIKE-067/068 budget was reopened. Source review and arithmetic do not
  replace compiler, target, lifetime or connected evidence.

## Review findings and resolution

| Finding | Severity / location | Resolution in final draft |
| --- | --- | --- |
| Fourth capture slot contradicts an accepted architectural decision | Blocker; Capture access / Memory; ADR-034 | Added B0 and explicit ADR-034/RFC-012 references. Either seek a reviewed architecture amendment preserving retention, or demonstrate a safe three-slot replacement design. Specs/limits cannot change first. |
| An all-pairs identity comparison could violate SPEC-006's linear-expansion requirement | Blocker; Runtime records / Performance | Removed as an implementation option. Proposed paired path-trie traversal with a fixed vocabulary fanout; exact counts, bound and implementation evidence remain B2. Record indices are never persistent identity. |
| Registration retirement does not prove the application released its model | Blocker; Model storage / Capture access / Memory | Require both framework and application ownership to end before slot reuse. A live/staged pair and four captures are insufficient if retired models remain externally owned. The actual finite pool bound and failure behavior remain B1/B2. ADR-024 is preserved. |
| A view carrying runtime leases or packed firmware representation into Domain would reverse ownership | Blocker; Capture access | Require a typed application read boundary with target-supplied storage adaptation; no runtime module, firmware offsets or packed record format in Domain/Presentation. Exact declarations remain B1. |
| `borrowing`, a generation token and Void callbacks do not establish non-escape by themselves | Blocker; Non-escape boundary | Explicitly retained as B1. Successful native tests cannot settle it. Exact supported binding/lowering and all framework-owned escape/callback routes need evidence. |
| The reservation sketch is not a complete resource proof | Blocker; Memory / Binary Size | Exact path prefixes, payloads, copied interaction keys, model/control storage, capture size, external model pool and complete stack remain B2/B3. No uncharged headroom or implicit limit increase. |
| Removing generated graph inputs is distinct from removing all code/resource generation | Adoption blocker; Compatibility / B4 | Require producer/consumer inventory and declaration perturbation. Fonts, typed roles and finite syntactic Canvas/model lowering may remain; expanded topology may not. |
| Current nRF 4 MHz transfer exceeds the frame budget independent of graph construction | Iteration performance blocker; Backend / Performance | Preserved. This package selects no SPI speed, framebuffer, damage strategy or requirement waiver and makes no four-FPS claim. |

Non-blocking suggestions: keep the first record codec easy to inspect; avoid
adding indexing beyond the linear identity requirement before a measured need;
reuse current oracles where their assumptions still apply. These are optional
implementation choices, not additional studies or commitments. No new optional
feature was discovered that needs a Future Work record.

## Contract-change map

These are proposed amendment boundaries, not already approved changes.

| Owner | Clauses / criteria affected | Required change or proof |
| --- | --- | --- |
| SPEC-001 | Portable capture/presentation declarations, retention resources; SA-AC-008–015, 021–025, 028–031, 039–040, 045 | Keep owned capture semantics; specify separate frozen read view, replacement storage and portable waveform adaptation. Preserve 404 records/five seconds and source/state/action behavior. |
| SPEC-006 | Structural identity, expansion/work limits; DV-001–011, 013, 015–017 | Preserve exact identity and linear work. Specify any new storage/record contract only if existing SPI cannot represent it; no relocation of semantic authority. |
| SPEC-010 | Public bound State access, registration and lifetime; OS-001–012 | Resolve concrete Static model/context/lowering, non-escape, external owner lifetime and callback isolation without hiding API changes. |
| SPEC-011 | Committed identity/target records; IN-003–013 | Prove identity keys survive bank reuse and refusal; keep target/action generations and one-shot typed dispatch. New key layout may be private; any changed contract needs review. |
| SPEC-012 | Static capture lowering and cycle lifetime; DR-001–005, 007–013 | Review exact scoped reads and owned-key payloads through selected lowering/API changes; prove capture-at-declaration meaning and per-occurrence release; preserve fixed table/source-lowering requirement. |
| SPEC-013 | Exact storage audit, stage sequence, failure/recovery; RP-001–015 | Review proposed record/payload/path/control budgets and lease checks, both profiles, bank swapping and complete byte/stack accounting. |
| SPEC-015 | Host workload/presets, validated ownership, quiescence; HC-001–006, 009–018 | Exact analyzer replacement resources and independently derived counter workload/resource bounds; supported source/build inputs and platform facts. |
| SPEC-007/008/009/014 | Existing layout/render/execution/backend contracts | Regression owners; no amendment selected by this RFC. If implementation exposes a contract conflict, stop that choice and route it explicitly. |

The proposed fourth-slot branch explicitly conflicts with ADR-034, which says
“No fourth buffer or heap fallback is introduced.” Existing authority remains
binding. An ADR-034 successor/amendment is required for that branch; the design
alternative is a three-slot replacement with complete failure/lifetime proof.

Potential ADRs after RFC approval: runtime record identity/publication and scoped
model/capture ownership. No ADR was authored as accepted or inferred from source.
If final API/lifetime decisions conflict with an accepted ADR, amend that
architectural decision explicitly before any dependent Spec approval.

## Conditional implementation order

All rows below are **blocked for production**. The same rows are linked from
the affected per-Spec plans; historical approved tasks retain their dispositions.
This dependency sequence is not a ready plan or a new execution authorization.

| Order | Scope and owner | Prerequisite | Completion evidence |
| --- | --- | --- | --- |
| R0 | Resolve B1 source-enforcement/API direction and B2 ownership/cardinality; use them to select B0 capture-slot architecture, then finish exact declarations/resource proposals | Review of RFC-014 and SPIKE-069 evidence; any further experiment requires an explicit bounded recipe and separate authorization | Concrete binder/read-view contract, lowerable source shape, complete model owner/pool lifecycle, exact codec/count budget for both apps; no proof by annotation |
| R1 | RFC decision → ADR extraction → affected Spec amendments | Resolved approval blockers and explicit human approvals at each gate | Accepted architecture and approved declarations/limits/errors; then ready per-Spec task sections |
| R2 | Runtime record builder, exact identity and independent semantic oracle (SPEC-006/013) | R1 | Both bank and branch-shift tests, linear work bound, bounded failures, no pre-expanded graph inputs |
| R3 | Typed model/context, capture lease and transaction cleanup (SPEC-010/012/013) | R1; join with R2 | Replacement/removal/external-alias cases, callback isolation, actual compiler non-escape/no-heap evidence, exact release trace |
| R4 | Finite counter composition (SPEC-011/012/013/015) | R2/R3, approved counter bounds | All ten values and complete action/Canvas workload; state/identity/pixel parity; separate target compositions |
| R5 | Analyzer read-view adaptation and runtime host migration (SPEC-001/011/015) | R2/R3; reuse R4 integration mechanisms where contracts match | Existing capture/action/failure/pixel oracles, generated graph inventory removed, all four hosts use actual traversal |
| R6 | Complete integrated adoption validation | R4/R5 and exact frozen artifacts | Four-profile owner gate, exclusive byte ledger, full feasible-path stack/IRQ bounds and matched memory evidence; independently authorized connected workload checks |

R2 and R3 may inform each other but neither authorizes bypassing R1. Counter-first
integration reduces application complexity; it does not waive the analyzer or
turn counter success into complete stack/lifetime evidence for the larger app.
Iteration-3 delivery is not complete if the 4 MHz performance gate remains
unresolved; its remedy is an explicit adjacent decision, not an extra R6 repair.

## Next actionable decision

This paragraph records the original I3-T02 recommendation. The subsequent
[SPIKE-069 follow-up](#b1-follow-up--spike-069) refines the next step to the
source-enforcement/API and ownership choices before finalizing slot count.

Resolve **B0**, the concrete architecture direction: permit the proposed fourth
snapshot through an ADR-034 amendment, or retain three slots and require a
proved replacement protocol. In either branch, **B1** still needs the concrete
supported Static binding/capture-read lifetime and **B2** the external-model
ownership bound. These choices are not approved by the instruction to draft
the design. B1 work can proceed without selecting the fourth-slot branch;
the current three-slot contract remains the default until explicitly amended. The draft
identifies the exact existing APIs and escape paths; it does not supply compiler
proof. Before authorizing any prototype, fix its concrete API candidate, complete
source/composition boundary, required negative cases, target compilers and one
numeric invocation/repair/time ceiling. Do not restart the archived aggregate
candidate or launch another general feasibility review. This package requests no
RFC approval while these blockers remain.

## Validation and disposition

### B1 follow-up — SPIKE-069

The separately authorized [SPIKE-069](../../spikes/spike-069-scoped-model-access.md)
completed after this review. **Verdict remains not ready.** Its
[evidence](../../../experiments/spike-069-scoped-model-access/evidence/result.md)
narrows B1 rather than closing it:

- Copyable State escapes through generic results, outer storage from Void
  callbacks and delayed closures on all four configurations. Fixed typed
  access alone does not enforce non-escape. No escaped pointer was dereferenced.
- A concrete nonescapable borrow compiles on all four with experimental
  LifetimeDependence; twenty negative controls reject intended escapes/overlap
  and stored declaration use. The compiler's unsupported-`@lifetime` warning
  remains an adoption issue, not a suppressed diagnostic.
- An owned body compiles with actual GiftUI declarations; direct borrowed-view
  capture in actual Canvas rejects on all four. A bounded delayed-key lifetime
  model passes sixteen cases per native profile and cross-compiles for Pi/nRF.
- R=1 in the model requires five snapshot slots. The actual applications' R
  and enforceable application ownership remain unproved. Four slots alone do
  not resolve B0/B2; observation detachment still cannot destroy owned models.
- The nRF section-GC fixture has no retained allocator relocation. It is not
  a final firmware, supported owner integration, whole-image stack/heap or
  actual application traversal result.

The next design decision is now explicit: preserve source through checked finite
lowering with diagnosed unsupported escapes, or review scoped State/body/Canvas
API changes. Both may use scoped reads and delayed owned snapshot keys internally.
Neither is adopted by the successful fixture. Resolve that choice and the
application ownership bound before finalizing B0's physical slot count.

The conditional R0–R6 migration sequence remains blocked. SPEC-001/010/012
amendments must reflect the selected source/capture semantics, not copy the
prototype. Compiler policy, every generated route, complete storage and full
image/profile evidence remain required. No automatic next experiment is opened.

### Source-design follow-up — 2026-10-09

**Verdict: not ready.** The [source comparison](rfc-014-source-design-options.md)
and [ownership audit](rfc-014-ownership-audit.md) complete the requested next
design step. This is an author consistency review, not an independent reviewer
or human approval. It recommends explicit scoped APIs for further design and
preserves checked finite lowering as an alternative. No compiler or application
experiment was run in this follow-up.

| Severity / location | Finding and required resolution |
| --- | --- |
| Blocker B1/B4 — source comparison, A lowering table | Preserving familiar syntax needs mandatory type-directed enforcement on every supported profile, including cross-file helpers and copied wrappers. Existing macros do not establish it. If A is selected, define its finite source boundary and mandatory build integration without introducing a general compiler or generated graph. |
| Blocker B1 — source comparison, B API table | The proposed scoped marker/builder/snapshot Canvas is not a compiled API. Choose exact nonescapable declarations, generic builder constraints, initializer ownership, transparent identity behavior, error mapping and supported compiler policy. Experimental fixture success does not prove these generic interfaces. |
| Blocker B1/B2 — ownership audit, analyzer owner table | Host, failure and presentation-attempt caches retain model references. A root swap alone is insufficient. Define retarget/release on association commit and failures, including replacement followed by failed derivation. Reclamation must preserve explicit external owners. |
| Blocker B0/B2 — ownership audit, peak ledger | R=0 after cleanup does not establish peak R=0. Prove transient retention and all simultaneously reserved roles before choosing three or four-plus-retained slots. Four still conflicts with ADR-034 even if R=0 is proven. Counter needs its own finite model ledger, not analyzer slots. |
| Blocker B1/B4 — source comparison, staged payload ownership | Copyable keys/capture records cannot implicitly own unique pins. Specify ledger acquisition/release per actual occurrence and every partial-failure edge; no key may resolve freed owner backing. |
| Unchanged blocker B2/B3/B4 — RFC resource and adoption sections | Complete codecs/capacities, actual traversal and four-configuration owner behavior, full-image stack/heap and matched Dynamic costs remain unproved. The 4 MHz performance failure is independent. |

Non-blocking suggestion: finalize public naming only after the logical contract
is stable; candidate names are not package/export decisions. No new deferred
artifact is needed for this naming detail. All correctness and feasibility
questions above remain current blockers rather than future work.

Candidate ADRs remain runtime records/identity and model/snapshot lifetime.
The chosen source restriction or API migration additionally needs an explicit
compatibility decision against ADR-024/026/028 and SPEC-010/012. A four-slot
choice still needs the separate ADR-034 amendment/successor. Neither API
recommendation nor this review changes current authority.

Governance validation, local file links and whitespace checks pass for the
follow-up. Design sketches were not compiled; no additional production tests,
heap/stack measurement, hardware validation or budget extension is claimed.

### Original authoring validation

`scripts/validate-governance.rb` and `git diff --check` pass for this documentation
package. Local links, reciprocal Proposal/RFC/manifest references, resource
arithmetic and all seven conditional per-Spec sections are checked. Production
source and approved Specs are unchanged; the I3-T01 74-check result remains the
last code validation and is not relabeled as validation of RFC-014.

I3-T02 finishes as **design delivered with named approval/adoption blockers**.
Its final time accounting and commits are recorded in the
[current activity plan](memory-efficiency-plan.md#i3-t02--runtime-derivation-design-package).
