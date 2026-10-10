# RFC-014 bounded implementation sequence — 2026-10-10

**P01 passed; P02 in progress.** This is the shared
sequencing index for nine owner Implementation Plans, not another contract or
investigation. It derives only the [approved Spec amendments](rfc-014-spec-approval.md)
at `3c260bbc` and accepted ADR-035/036/037. ITERATION-003 I3-04/05 supplies the
analyzer/counter and four-configuration delivery scope; the closed MVP supplies
regression semantics. ITERATION-004 external delivery remains separate.

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

Inspected baseline source still has context-free `View.body` in
`Sources/GiftUI/DeclarativeView.swift`, retained Canvas closures in
`Sources/GiftUI/Canvas.swift`, existing ObservableState transaction/reconciler
owners, Dynamic/Static model and semantic stores, and RuntimeCore's complete
pipeline/cleanup. Reuse these owners and their failure tests.

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
remains open through P10–P12. P02–P12 remain pending with no scope change,
P01 blocker or new package. P02 is the next dependency-complete package.

Planning was prepared without implementation or experiment execution. Optional work remains in the existing deferred track; no new optional
deliverable was added. Next action is P02 within the existing bounded sequence.


Planning validation: all nine approved Spec statuses and ready plan templates
checked; every one of 180 criteria appears exactly once in its owner matrix;
P01–P12 are the only packages; owner drivers and local links exist. Governance,
authority graph, task-evidence validation and `git diff --check` pass. This checks
planning integrity only; all implementation/conformance evidence remains pending.
