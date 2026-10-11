# RFC-014 bounded implementation sequence — 2026-10-10

**P01–P06 passed; P07 resumed under the approved concrete-binding correction;
P08–P12 pending.** This is the shared
sequencing index for nine owner Implementation Plans, not another contract or
investigation. It derives only the [approved Spec amendments](rfc-014-spec-approval.md)
at `3c260bbc` and accepted ADR-035/036/037. ITERATION-003 I3-04/05 supplies the
analyzer/counter and four-configuration delivery scope; the closed MVP supplies
regression semantics. ITERATION-004 external delivery remains separate.

For a new or resumed assignment, use the [task context guide](rfc-014-task-context.md)
to reach the relevant contract, source, tests and current evidence without
reconstructing the investigation history. Package boundaries and model routing
remain in this sequence.

P07's [progress receipt](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/progress.md)
records committed limits/audit and internal scoped-runner steps. The
[independent Strong review](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/independent-blocker-review.md)
at `d7d6cdd1` confirms the explicit SPEC-009/013 coordinator constraints conflict
with the selected scoped owner realization. The
[concrete decision packet](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/scoped-coordinator-constraint.md)
is historical; the [narrow correction is now approved](rfc-014-spec-approval.md#scoped-coordinator-constraint-amendment--2026-10-11). SPEC-009 T9.1 is a directly necessary P07 checkpoint, not another package. Complete profile integration
and package exit remain open; SPEC-015 host lifetime remains a separately
reviewed boundary. Consecutive unproductive repairs: **0/2**. No successor work
has started.

The prior correction is implemented. The new [associated-type decision packet](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/associated-type-constraint.md)
records the remaining Storage/Handler/TargetAccess boundary, bounded compiler
proof, concrete proposed operational-protocol correction and lost static checks.
The [exact reviewed correction is approved](rfc-014-spec-approval.md#concrete-coordinator-binding-amendment--2026-10-11). Validated slices and honest partial WIP are preserved.
The [independent Strong review](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/independent-associated-type-review.md)
at `8d9f76c9` confirms the blocker and recommends the exact correction with
mandatory concrete binding proofs. Those proofs accompany resumed integration;
separate Strong package exit review remains required.

## Fixed deliverable and scope rules

Deliver one runtime-derived implementation for the existing analyzer and finite
counter: fixed-domain access, stable bounded ownership, exact semantic records,
protocol Canvas, schema-4 host validation and complete conformance/resource
dispositions. Keep existing application behavior, three capture banks, logical
limits, owner dependencies and backend semantics. The counter is the existing
UInt8 0–9 / Increment / Reset / disabled predicates / optional stroke corpus from
the [source inventory](../../../experiments/spike-072-contextual-traversal-integration/application-coverage.md),
not a new application feature project.

The baseline is **12 work packages, P01–P12**, below. Owner task IDs are accounting
checkpoints within those packages; they are not nine additional workstreams.
Each package gets implementation commits, focused evidence and a finite exit.
Do not start a successor before its named dependencies pass. Mark affected Specs
`implementing` and owner plans `active` only when their implementation starts.

- Every edit must name a package and approved criterion. A local repair needed
  for that exit stays in that package; it does not become a new study.
- No new application, target, general Swift frontend, arbitrary cross-domain
  composition, package split/external API, scheduler, renderer, transport, display
  clock, visual redesign, fine-grained observation, lock framework or extra bank.
- No speculative optimization, unrelated cleanup, framework generalization or
  compiler upgrade. Keep the supported source inventory finite. Existing pure
  helpers need no new model generic parameter unless their approved access needs it.
- Optional discoveries get the smallest Future Work record with source/revisit
  trigger; they do not enter P01–P12. Required correctness/resource failures cannot
  be deferred. Record their failing criterion and keep the package incomplete.
- Changing the deliverable, footprint to add another subsystem, accepted bound,
  public behavior or architecture requires a concrete maintainer decision before
  affected work continues. Adding/replacing packages requires an explicit plan
  revision with old/new scope and reason, not an automatically appended backlog.
- Stop a package when its exit passes. Do not keep polishing or broaden tests
  without a changed path or unresolved failure. Run the broad gate at integration;
  later reruns need a code change or a specific unresolved concern.
- After two consecutive repair attempts on the same blocker with no new passing
  check or narrowed cause, stop that affected package and report the failing case,
  attempted fixes and smallest options. Do not restart its allowance under a new
  task name, toolchain or Spike. Independent already-scoped work may continue only
  if its prerequisites hold. This is a progress guard, not permission to weaken tests.

No elapsed-time or feasibility promise is inferred from task count. The bound is
the named delivery surface, fixed package list, finite acceptance evidence and
failure stop rules. A checkpoint report records completed/remaining package IDs,
criterion failures and any proposed scope change after every package.

## P02 direction correction — 2026-10-10

Eugene requested removal of the separate lowering module and migration ifdefs.
P02 therefore amends the existing GiftUI declaration files in place and locates
finite source lowering in the existing GiftUIMacros target. No new target or
parallel declaration implementation is introduced. Historical comparisons use
the pinned P01 baseline revision and receipts. Downstream consumer migration
remains in P03–P09; P10 is the integrated build/conformance gate. P12 still owns
removal of superseded generated topology and final production adoption, and does
not require a second compiled View ABI to be maintained until that point.

## Current repository and permitted footprints

The pre-P02 baseline had context-free `View.body` in
`Sources/GiftUI/DeclarativeView.swift`, retained Canvas closures in
`Sources/GiftUI/Canvas.swift`, existing ObservableState transaction/reconciler
owners, Dynamic/Static model and semantic stores, and RuntimeCore's complete
pipeline/cleanup. P02 has since replaced the declaration ABI in place with
typed domain/read contracts; consumers migrate in P03–P09. Use current source
and package receipts for implementation state, not this baseline description.
Reuse the existing owners and their failure tests.

`scripts/contracts/generate-spec-001-nrf-topology.py`, Canvas-table generation and
`generate-spec-015-workload.rb` still serve generated production inputs. Replace
only the expanded-graph/capture assumptions this migration changes. Keep font and
bounded resource generation. The finite counter has experimental/source inventory
evidence, not an already implemented host; create its bounded repository test
composition as production-contract validation, never claim an external package.

Footprints below include matching unit tests, `Tests/ContractFixtures/SPECxxx`,
contract-driver registration and narrowly required Package.swift wiring. New files
inside these existing owner boundaries are permitted. Importing application
schemas into GiftUI, moving owners between modules or changing unrelated backend
algorithms is not. An integration edit in an unchanged owner must preserve its
contract and be traceable to a failing migration check.

## Ordered work packages

| Package / dependency | Implementation boundary and concrete output | Exit evidence; stop when complete |
| --- | --- | --- |
| **P01 — Compiler and baseline**; none | SPEC-002 driver, shared contract-driver forwarding and `.toolchains` selection. Add `--compiler-baseline rfc-014`, keep historical reproduction, record source/recipe hashes and the finite route inventory. Register required invocation in the explicit top-level runner. | Four compiler identity/feature/ABI selections; unknown/missing feature rejection; fresh Foundation PF-006/007 size/allocation/link results. Inventory and baseline are pinned once; no general tooling cleanup. |
| **P02 — Typed declarations and finite lowering**; P01 | GiftUI View/builder/read/key contracts, GiftUIMacros and the application schema/source lowering build step. Implement only inventory syntax/effects, inferred Body, same-domain composition, typed failures and source-located rejection. | Separate core/schema/presentation/host modules compile; arity 0–5, helpers/short-circuit/order and ordinary stateless/custom dispatch; negative wrong-domain/escape/unsupported-effect cases on four configurations. No frontend feature outside the corpus. |
| **P03 — Stable owners and State**; P02 | GiftUIObservableState and Dynamic/Static model, registration, target-access stores; host-owned identity issuance. Implement tickets/pins/checked writes, nested State discovery and three-bank final-ticket transfer/refusal. | Real owner/reconciler callbacks test first install/ignored seeds, retained owners, empty entitlement, second-populated refusal, attach/detach/report faults, stale identities and every pre/postcommit path. Measure actual metadata/ticket/pin layouts now; stop on unsafe backing or an incompatible bound. |
| **P04 — Runtime records and exact identity**; P02, P03 | GiftUISemanticCore and profile semantic storage/codecs. Emit records/path/payload pools from actual traversal, paired exact trie matching, disjoint candidate/published banks. | Declaration perturbation changes topology without graph generation; exact trace/modifier/state identity, fixed-fanout work counts, every first-excess pool case and reader-aware bank reuse. Measure prefix/payload maxima against approved logical limits before integration. |
| **P05 — Layout and committed action keys**; P04 | SemanticCore Layout adapter, narrow Layout/Render consumer joins, GiftUIInteraction candidate/committed storage and host target bridge. Copy complete keys; retain accepted-offer routing semantics. | Layout/oracle equality, scope/depth limits, no model access in Layout, independent keys across multiple bank reuses/refused offers, stale target/release cancellation and atomic key-pool failure. No new layout/raster algorithm. |
| **P06 — Protocol Canvas**; P03, P04 | GiftUI Canvas, GiftUIDrawing invocation/plan adapters and profile staged-value storage; finite witness lowering. Replace escaping Canvas closures while retaining scoped withPath, geometry and raster contracts. | Zero/multiple/repeated occurrences, inferred ordinary bodies, exact model choice, checked local bounds/order, escape controls and exactly-once cleanup including rejection before acquisition. Independent geometry/pixel controls stay unchanged. |
| **P07 — Complete runtime cycle**; P05, P06 | RuntimeCore limits/audit/pipeline/cleanup and both concrete coordinators. Integrate read/discovery/mutation phases, model retirement, candidate semantics, owned geometry, accepted-offer Interaction commit and refusal retry. | Actual Dynamic/Static differential fault transcripts, first/partial failure, no mutation replay, last-read versus registration retirement, quiescence and all early-exit cleanup. No shared mock bridge presented as runtime integration. |
| **P08 — Schema-4 hosts and finite counter**; P07 | GiftUIHostConfiguration, workload generator/validator and finite repository counter fixture plus four host/profile build routes. Implement explicit pool/model/ticket/pin limits, owner caches and audited layout validation. | Schema-3 rejection, missing/mismatched field/witness and below/equal/above limits; complete counter route/action/text/stroke corpus through actual runtimes on four builds. Link early target images and check gross RAM/stack/allocator problems before analyzer migration. |
| **P09 — Analyzer migration**; P08 | SignalAnalyzerPresentation/Domain adapters, SignalAnalyzerTargetHost, Pi/native owners and nRF firmware assembly. Explicit capture selection, protocol Canvas and checked compound mutations; preserve Domain-owned capture semantics and source/admission roles. | Entire route inventory accounted for, real host owner replacement tests, 404/405 and horizon/baseline/Clear/revision boundaries, full diagnostics, action and waveform/pixel oracles. Produce linkable analyzer artifacts with no graph-input dependency in the candidate build. |
| **P10 — Integrated functional conformance**; P09 | Existing nine owner contract suites, RuntimeConformance and application/preset harnesses; cross-profile adapters and driver registry only as required by changed contracts. | All 180 owner criteria receive a migration disposition: functional/import/negative/error/pixel evidence here; resource/connected parts explicitly pending P11. Run relevant four-profile drivers and one full hardware-free gate. Never regenerate expected pixels merely to match a changed output. |
| **P11 — Complete resource and workload evidence**; P10 | Actual linked artifacts, map/stack/allocator inspection and existing workload runners; implementation repairs only within the package owning the failure. | Complete live-storage/stack/IRQ ledger, ABI and linked Static zero heap, matched Dynamic costs, preserved three banks and target limits. Record measured 30s acquisition/frame results where authorized. Hardware-free proof and connected evidence are separate; unmet timing/hardware criteria block full adoption, not authorize transport redesign. |
| **P12 — Production cutover and closeout**; P10/P11 migration gates pass or explicit applicable maintainer disposition | Remove superseded expanded topology/closure production build inputs; preserve independent baseline controls and resource generation. Update nine conformance reports, author/build guidance and task dispositions. | Production uses only runtime derivation; final build-dependency scan plus focused post-removal checks. Every criterion cites final artifact/evidence or explicit exception. Request implemented transition separately. If adoption is blocked, record the exact residual gate, keep the baseline route and leave cutover incomplete; no automatic follow-on phase. |

Default execution is sequential in the listed order. P05 and P06 have independent
owner surfaces after their dependencies, but this plan does not authorize new
parallel agents. All shared interfaces are fixed by the approved Specs.

## Complexity, risk and model routing

Added 2026-10-10 at Eugene's request to reserve the strongest model for complex
or consequential work and reduce cost on routine execution. These are planning
estimates for the existing packages, not measured model performance, new work
packages or changes to acceptance criteria. P01/P02 ratings are retrospective;
their completed work does not need rerunning. P03's remaining work uses this
routing from its next safe handoff.

Rate the actual assignment on two independent axes. File count, diff size and
test duration do not determine either rating.

| Level | Complexity (C): reasoning required | Risk (R): consequence of a wrong result |
| --- | --- | --- |
| 1 | Mechanical execution with exact inputs, an established pattern and an objective check | Local, readily detected and reversible; no behavioral or acceptance decision |
| 2 | Bounded implementation across known interfaces; several interacting cases | Behavior or integration regression within an established owner; targeted evidence can establish correctness |
| 3 | Cross-owner invariants, unfamiliar compiler behavior, lifetime/transaction reasoning or whole-image resource proof | Memory safety, stale identity, atomic publication, data loss, resource guarantees or adoption/conformance decisions |

Use three model tiers, mapped to concrete available model IDs and reasoning
settings at execution time. **Economy** is the least expensive model already
adequate for mechanical tasks; **Standard** handles bounded implementation;
**Strong** is the most capable reasoning model available for difficult or
consequential decisions. Price and model names are deliberately not frozen here.
If a cheaper tier has not demonstrated adequacy, start one tier higher.

| Assignment rating | Minimum implementation tier | Review before accepting its result |
| --- | --- | --- |
| C1 / R1 | Economy | Objective checks and normal package review; no separate Strong review for clerical output |
| C2 / R1 | Standard | Normal package review and focused checks |
| C1–2 / R2 | Standard | Strong review of changed behavior and criterion evidence |
| C3 or R3 | Strong | Explicit Strong review of invariants, failure paths and evidence, separate from the implementation pass |

A review pass can use the same implementing agent with the relevant context;
these tiers do not authorize spawning agents or require duplicate implementation.
Model review never substitutes for tests or human lifecycle decisions. Missing
authority or an ambiguous contract is an upstream blocker, not a reason to ask a
larger model to invent a resolution.

### Package ratings and lower-cost assignments

The core rating applies if a package is assigned as a whole. The bounded slices
below allow cheaper execution after their inputs and expected results are fixed.
Their parent dependencies, exit evidence and repair limits remain in force.

| Package | Core C / R | Core tier | Reason for rating | Lower-cost slice and prerequisite |
| --- | --- | --- | --- | --- |
| P01 | C2 / R2 | Standard | Compiler selection, ABI forwarding and baseline provenance affect every later result | Economy C1/R1: execute fixed identity commands and collect hashes; unexpected compiler/ABI results return to the core owner. Already complete. |
| P02 | C3 / R3 | Strong | Domain inference, source transformation and escape rejection define the typed safety boundary | Standard C2/R2: add cases from a reviewed syntax/diagnostic matrix without changing lowering or expected semantics. Already complete. |
| P03 | C3 / R3 | Strong | Backing lifetime, pins, registration retirement and three-bank transfer/refusal must agree on every failure path | Economy C1/R1: run fixed owner tests and collect layout sizes after Strong supplies the cases; Strong interprets lifetime and bound results. |
| P04 | C3 / R3 | Strong | Exact identity, bank reuse and bounded reconciliation couple semantics to storage | Standard C2/R2: implement enumerated first-excess fixtures after Strong fixes pool rules and independent expected outcomes. |
| P05 | C2 / R3 | Strong | Small consumer joins can misroute committed actions after bank reuse or refused offers | Standard C2/R2: adapt Layout fixtures to the fixed borrowed-view interface; committed-key ownership and retirement stay Strong. |
| P06 | C3 / R3 | Strong | Deferred Canvas values, scoped reads, staged storage and exactly-once cleanup cross lifetime boundaries | Standard C2/R2: add reviewed occurrence/order fixtures against unchanged geometry and pixel controls; ownership and escape handling stay Strong. |
| P07 | C3 / R3 | Strong | The complete cycle coordinates mutation, publication, offer acceptance, retirement and fault cleanup | Economy C1/R1: execute fixed differential transcripts and index results; Strong diagnoses mismatches and assesses cleanup. |
| P08 | C3 / R3 | Strong | Owner caches, backing layout and audited resource limits accompany otherwise bounded host wiring | Standard C2/R2: implement schema validation and finite counter wiring against fixed contracts. Economy C1/R1: transcribe reviewed schema fixtures and collect four-route build reports. |
| P09 | C3 / R3 | Strong | Real host replacement and compound capture mutation must preserve application semantics and admission | Standard C2/R2: migrate inventoried presentation call sites after one reviewed pattern and API are fixed; capture ownership and mutation remain Strong. |
| P10 | C3 / R3 | Strong | Applicability of evidence across 180 criteria determines whether integration actually conforms | Economy C1/R1: run named suites and populate raw command/result links. Strong owns criterion dispositions, oracle differences and exception identification. |
| P11 | C3 / R3 | Strong | Complete overlapping storage, stack/IRQ, zero-heap and sustained-workload proof require whole-system reasoning | Economy C1/R1: extract exact artifact/map values and run fixed, authorized measurements. Strong reconciles the ledger and decides what the evidence establishes. |
| P12 | C2 / R3 | Strong | Production cutover removes the fallback and depends on valid adoption dispositions | Economy C1/R1: update links and execute dependency scans from a reviewed cutover list. Strong owns removals, gate assessment and final conformance review. |

P08's Standard slice covers only fixed-contract schema/counter wiring; if the
assignment includes its owner-cache or resource-layout work, route that combined
assignment to Strong. Likewise, a lower-cost slice inherits the core rating
unless its boundary actually excludes the listed critical decisions. A passing
test does not by itself justify downgrading lifetime or resource-proof work.

### Dispatch, escalation and handoff

Before each assignment, record a short entry in the existing package receipt:

```text
Package / slice; governing criterion IDs; dependencies satisfied
Allowed files and output; fixed inputs / pattern / independent expected results
Context: exact contract headings, source symbols, test exemplars and receipt
Settled decisions; remaining implementation choice (or explicitly none)
C / R and reason; tier -> actual model ID / reasoning setting
Required commands and reviewer tier; remaining package repair allowance
Result / evidence links; unresolved issues; handoff or escalation reason
```

Switch models between bounded slices or at a recorded failure handoff, with the
current diff, source revision, uncommitted work, commands/results and remaining
work preserved. Do not restart the package or repeat passed checks solely because
the model changed. These annotations support manual selection or a future
dispatcher; editing this plan does not implement automatic model switching.

Escalate Economy to Standard when work requires behavioral interpretation or a
repair beyond the prescribed pattern. Escalate directly to Strong on unsafe
access, lifetime/identity uncertainty, transaction or failure-order changes,
cross-profile disagreement, unexpected resource growth, oracle changes or
unclear acceptance evidence. Escalate after the first failed repair that produces
no new passing check or narrower cause; preserve the existing two-attempt package
stop rule. Switching models never resets that counter or a closed work budget.

Strong may return a precisely bounded mechanical slice to a cheaper tier once
its inputs, invariants and checks are settled. Keep critical review with Strong;
do not downgrade a task merely because it took longer or used more tokens.
Record actual model usage, repair counts and review rework in the same receipt
when available; do not invent cost estimates or promise savings. Reassess the
tier mapping using that evidence at package checkpoints, without creating a
benchmark project or expanding P01–P12.

## Owner plan and criterion mapping

Every criterion appears once in its owner plan's acceptance matrix. Historical
task references preserve evidence provenance; a new current owner checkpoint
adds fresh migration obligations. Existing checked tasks are not reopened as
unbounded cleanup. The new checkpoints intentionally remain pending until both
their implementation and P10/P11/P12 evidence obligations have dispositions.

| Owner plan / current checkpoint | Implementation packages | Verification and primary new criteria |
| --- | --- | --- |
| [SPEC-001 T13.1](../../implementation-plans/spec-001-implementation-plan.md) | P09 | P10–12; SA-RD-001–004 and 45 baseline criteria. |
| [SPEC-002 T7.1](../../implementation-plans/spec-002-implementation-plan.md) | P01 | P10–12; refresh PF-006/007 and retain all ten Foundation criteria. |
| [SPEC-006 T10.1](../../implementation-plans/spec-006-implementation-plan.md) | P02, P04 | P10–12; DV-RD-001–004 and 17 baseline criteria. |
| [SPEC-007 T9.1](../../implementation-plans/spec-007-implementation-plan.md) | P05 | P10–12; LY-RD-001–002 and nine baseline criteria. |
| [SPEC-010 T10.1](../../implementation-plans/spec-010-implementation-plan.md) | P03 | P10–12; OS-RD-001–004 and 12 baseline criteria. |
| [SPEC-011 T12.1](../../implementation-plans/spec-011-implementation-plan.md) | P05 | P10–12; IN-RD-001–002 and 13 baseline criteria. |
| [SPEC-012 T10.1](../../implementation-plans/spec-012-implementation-plan.md) | P06 | P10–12; DR-RD-001–004 and 13 baseline criteria. |
| [SPEC-013 T11.1](../../implementation-plans/spec-013-implementation-plan.md) | P07 | P10–12; RP-RD-001–004 and 15 baseline criteria. |
| [SPEC-015 T8.1](../../implementation-plans/spec-015-implementation-plan.md) | P08 | P10–12; HC-RD-001–004 and 18 baseline criteria. |

No previous fixture completion proves a new RD criterion. Unchanged requirements
may reuse an oracle or exact unchanged-artifact evidence only with an explicit
applicability argument; changed binaries need fresh relevant measurements. This
preserves every criterion without reimplementing the whole MVP.

## Design notes and evidence protocol

At most three focused notes are planned, inside implementation packages:

1. P02: SPEC-006 finite source lowering and typed failure flow.
2. P03: SPEC-010 owner/pointee lifetime and replacement transaction, including
   Canvas pins, registration retirement and teardown.
3. P04: SPEC-006 record/path/payload representation and bounded reconciliation.

These explain replaceable realizations, not alternative architectures or separate
investigations. No new note is a delivery task merely because another class exists.
Their byte/lifetime claims feed the single P11 ledger rather than another study.

Each package receipt records input/output commits, changed files, exact checks,
compiler/profile/artifact identities, pass/fail counts, criterion links, resource
deltas and remaining blockers. Use existing owner evidence locations and link
receipts from the owner plans/conformance reports; don't duplicate logs. Generated
reports remain under `.build/`; Pi artifacts under `.build/raspberry-pi/`, nRF
under `.build/nrf52840/`, toolchains under `.toolchains/`.

Run `scripts/format-swift.sh` before repository validation. Use the existing owner
`scripts/contracts/run-spec-NNN.sh --profile <profile>` drivers for
`macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, `nrf52840-embedded`; propagate
the approved migration compiler selection without weakening historical checks.
P10's broad gate is `scripts/test.sh all-hardware-free`. Reuse its exact artifacts
for P11 where possible. Any new required focused check must be explicitly
registered with the top-level runner, not silently discovered or skipped.

Pi builds target `armv6-unknown-linux-gnueabihf`; nRF builds target
`nrf52840dk/nrf52840` with `armv7em-none-none-eabi` and verified VFP ABI. Follow the
repository platform skills. No setup installs globally. Deployment/service restart
and flashing require explicit connected-work authorization; Pi must report
`armv6l` before deployment. P11 first prepares the exact artifacts/commands and
bounded measurement cases, then requests only the missing device authorization.

## Known blockers and completion boundary

There is no remaining architecture approval blocker to P01. Complete lowering,
unsafe bridge correctness, prefix/payload capacity and whole-image fit are
implementation obligations, not already proven results. Detect them at P02–04
and P08/09 as well as final P11; stop the affected package if the contract cannot
be met. An internal bounded fix stays in scope; an extra bank, changed identity,
public semantic change or higher approved bound returns for a decision.

The known 4 MHz display lower bound and missing connected measurements remain
explicit. This plan does not authorize solving them by changing clocks, transport
or requirements. P11 may finish an honest evidence/disposition packet while an
acceptance gate remains unmet; that does not pass the gate or make P12 executable.
Do not wait indefinitely, label a hardware-free result full conformance, or launch
another experiment to avoid reporting the remaining decision.

Planning is complete when owner matrices cover all criteria and P01–P12 have
dependencies/footprints/exits. Implementation is complete only when the approved
contract's adoption gates pass (or receive explicit applicable dispositions),
cutover succeeds and all owner reports are ready for human review. Neither plan
completion nor approval marks any Spec implemented or closes the iteration.

## Completion record

P01 implemented in `bb61d4ef`, with the ARMv6 output-root correction in
`b77d85f7`; all four migration Foundation drivers, the
historical macOS control and all 17 compiler controls pass. The
[P01 receipt](../../../Tests/ContractFixtures/SPEC002/Evidence/rfc-014-p01/result.md)
pins source/recipe/route/compiler/artifact identities, deltas and the single
successful CMake repair. SPEC-002 is implementing and its plan active; T7.1
remains open through P10–P12.

P02's direction correction is committed in `117f49cf`; its declaration exit and
focused suite are implemented in `53de09c6`. All four final profile drivers pass
at that commit: both native profiles execute 120 assertions; ARMv6 and Embedded
compile the separate modules and verify target CPU/VFP object attributes. The
[P02 receipt](../../../Tests/ContractFixtures/SPEC006/Evidence/rfc-014-p02/result.md)
preserves exact inputs, commands, diagnostics and artifact identities. SPEC-006
is implementing and its plan active; T10.1 remains open through P04/P10–P12.
Shared inventory routes retain their named ownership, runtime, action, Canvas
and complete-application integration obligations. The whole-tree migration and
resource/connected evidence are not inferred from this declaration exit.

P03 passed its finite package exit at `15b47e2a` after separate Strong review
of the explicitly approved scoped visitor correction and root-entry repair;
P04–P06 subsequently passed as recorded below; P07–P12 remain pending. There is no
remaining P02 exit failure, new package, scope expansion or architecture change.

Planning was prepared without implementation or experiment execution. Optional work remains in the existing deferred track; no new optional
deliverable was added. The next package is P07 within the existing bounded sequence;
the current execution stopped at the requested P06 package boundary.

P04's scoped traversal, runtime records, exact paired paths, bounded payloads and
reader-aware profile banks are implemented in `36834e01`, `7e6fdcd6`,
`c75d3105` and `7be2c837`. All four final registered owner routes pass against
clean source `7be2c837`. Separate Strong review at `037607c7` found no blocking
finding and matched 646 evidence hash/size entries. The
[final P04 exit](../../../Tests/ContractFixtures/SPEC006/Evidence/rfc-014-p04/progress.md#final-p04-package-exit--2026-10-11)
records native/cross-build limits, measured component bounds and remaining
integration/resource gates. T10.1 remains open through P10–P12. No contract,
scope or capacity change was needed; consecutive unproductive repairs remain
0 of 2. No P05 work was started.

P05 subsequently implemented borrowed Layout/Render views, complete owned
Interaction keys and checked target dispatch in `a7c9c6b1`, `f86dfbde` and
`fec8a27c`. All eight owner/profile routes pass on clean source `fec8a27c`.
Independent Strong review `42b5f639` found no blockers and verified all receipts
and 500 artifacts. The [final P05 exit](../../../Tests/ContractFixtures/SPEC011/Evidence/rfc-014-p05/progress.md#final-p05-package-exit--2026-10-11)
records native/cross-build scope, physical key/capture costs, the unverified
optional dependency check and later integration/resource gates. T9.1/T12.1
remain open. No contract/scope change or exception was needed; consecutive
unproductive repairs remain 0 of 2. No P06 work was started.

P06 subsequently implemented protocol Canvas, finite witness lowering, scoped
exact-model invocation, bounded staged values and marker-only semantic transfer.
The scoped-source constraint amendment was explicitly approved in `e6f10f67`.
Independent review `72438931` found P06-R1: lazy model binding allowed client
drawing before rejection. Repair `431293f9` prebinds all captured keys; separate
Strong review `59c80b52` passes the finite exit and independently reproduces the
corrected outcome. Four refreshed owner routes pass: each native profile executes
4,042 assertions and 13 negative controls; ARMv6/nRF provide compilation, ABI,
layout and 13 negative controls, without target execution. The
[final P06 exit](../../../Tests/ContractFixtures/SPEC012/Evidence/rfc-014-p06/progress.md#final-p06-package-exit--2026-10-11)
records exact provenance, unchanged geometry/pixel controls, complete reserved
payload growth and remaining integration/resource obligations. SPEC-012 T10.1
stays open through P10–P12. Consecutive unproductive repairs remain 0 of 2;
no P07 work was started.


Planning validation: all nine approved Spec statuses and ready plan templates
checked; every one of 180 criteria appears exactly once in its owner matrix;
P01–P12 are the only packages; owner drivers and local links exist. Governance,
authority graph, task-evidence validation and `git diff --check` pass. This checks
planning integrity only; subsequent P01/P02 evidence is recorded above, and
remaining implementation/conformance evidence stays pending.

### P03 historical safety stop — 2026-10-10

Resolved by the explicitly approved scoped visitor amendment recorded below.
The following checkpoint preserves the earlier evidence and authority boundary.

The direct scoped owner/root increments are committed and have selected-component
evidence. A raw-pointer lexical visitor prototype was rejected and removed: the
public generic host witness can copy its visitor into an escaping closure.
[Reproduction and bounded options](../../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/lexical-visitor-blocker.md)
record successful native compilation and the exact compiler/source identities.
Separate Strong review rejects literal two-pass enumeration under OS-010; no
compliant alternative has been demonstrated. Review verification of the bounded
generation-precedence repair precedes the human contract decision. No SPI
amendment, sealed-conformance assumption or capacity change is authorized.
No P03 exit or downstream package start is recorded. Consecutive unproductive
repair count remains 0 of 2; the stop is a safety/authority question.

### P03 scoped ownership exit review — 2026-10-10

The user explicitly approved the precise visitor lifetime correction recorded in
[the approval record](rfc-014-spec-approval.md#scoped-visitor-constraint-amendment--2026-10-10)
and committed as `567b59fb`. The remaining P03 implementation now supplies a
noncopyable/nonescapable actual-root binder, generated nested exact-once traversal,
matching candidate-ticket transfer, checked generation-based profile target access,
and retaining-sink terminal teardown. Copy/escape controls exercise both public
visitor protocols on all four pinned configurations. The [step-9 progress record](../../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/progress.md)
contains final source/compiler/target receipts, actual metadata/ticket/pin layouts,
commands, fault state transitions and explicit limits. Separate Strong review
passed the finite P03 exit after the step-10 repair; no downstream work or
implemented transition is claimed. Consecutive unproductive repair count remains
0 of 2.

The review initially stopped when the Strong agent hit the account usage
limit. Its provisional root-entry-during-frame cleanup finding was subsequently
confirmed by a safe separate-review reproduction and repaired locally in step 10. The [exact resumption point](../../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/progress.md#exit-review-interruption-and-exact-resumption-point)
preserves the historical suspected path and evidence limits. Step 10 adds the
pre-borrow phase guard and all-phase entry/exit regression. Separate bounded
verification at `15b47e2a` reran the original reproduction with zero attachments,
verified final receipt hashes, and found no remaining blocker. The
[final P03 package exit](../../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/progress.md#final-p03-package-exit)
records 645 assertions per native profile, all four compile/negative routes and
the remaining integration/resource evidence boundaries. P03 has passed; owner
T10.1 remains open through P10–P12.
