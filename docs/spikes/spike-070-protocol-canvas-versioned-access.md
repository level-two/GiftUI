---
id: SPIKE-070
feature: external-application-integration
title: Protocol Canvas and Versioned Property Access
status: completed
authors:
  - codex
created: 2026-10-10
updated: 2026-10-10
source:
  - RFC-014
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-069
  - SPIKE-071
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# SPIKE-070: Protocol Canvas and Versioned Property Access

Disposable C-P1/C-P2 evidence for [RFC-014](../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md),
not accepted architecture or production implementation. B0–B4 remain current
blockers. The full C-P3 application ownership/firmware proof is excluded.

## Authorization and baseline

On 2026-10-10 Eugene replied “Please proceed” to the completed detailed design
and proposed 90-minute/48-invocation/two-repair experiment. This launches exactly
that proof. Continue committing each coherent step. Baseline `b3b241ce`, clean
working tree. Prior Spikes stay terminal; no hardware operation is authorized.

## Target Questions

1. Can a small reproducible, checked finite source transformation lower ordinary
   model property reads in body/draw/helpers to explicit current/frozen context
   routes, including typed failure propagation from nonthrowing body source?
2. Can protocol Canvas use actual GiftUI View/primitive traversal and scoped
   GraphicsContext while storing only safe keys/scalars for deferred invocation?
3. Do concrete compiler controls reject context escapes and overlapping mutation
   on all four configurations? What lifetime-feature policy is required?
4. Do native model drivers preserve coherent two-field freezes, unchanged values,
   frame-key validation, drawing order, failure cleanup and next-frame updates?

## Bounds / Stop Conditions

- **90 active minutes from 05:30:54 UTC**, including orientation, generation,
  trials, analysis, repairs, validation and commits; conservative wall deadline
  **07:00:54 UTC** unless actual excluded waiting is explicitly recorded.
- **48 underlying compiler/link/executable invocations; two repair rounds; one
  candidate.** Unexpected failed compiler trials consume budget. Version reads,
  doctors, source-generation checks, hashes and ELF inspection are inventory,
  not target compiler/run trials. Record them separately.
- Stop when any ceiling is reached or a decisive contract/scope incompatibility
  appears. No silent alternative API, general compiler or automatic successor.
- No production edits, SDK installation, flash/deploy, performance campaign,
  external package work or full model-pool/firmware migration. Generated Pi/nRF
  artifacts stay under their established `.build/` target directories.
- Preserve commands, source/compiler hashes, generation manifest, diagnostics,
  logs and ledger. Positive compilation precedes interpretation of negative
  controls. Require intended diagnostics, not just a failing exit status.

## Method

Use a strict finite authoring corpus: one annotated counter schema with two
scalar fields, a View body containing repeated typed Canvas instances, a Canvas
method reading those fields, and one analyzer capture-reader/helper using indexed
owned transition reads. Source transformation must parse/check its supported
forms and reject unknown fields, unchecked helpers or property access outside a
contextual entrypoint. Do not call hard-coded equivalent output a generator.
Publish the accepted grammar/coverage and mutations proving output depends on
source. Unsupported syntax is a build diagnostic, not guessed lowering.

Use maintained GiftUI declarations except the concrete closure-based Canvas;
replace that file only in the disposable compilation unit with the draft protocol
and generated contextual invocation contract. Any body/traversal/context seam
adaptation must be identified. A generated throwing body entrypoint returning
real GiftUI children is not automatically complete Semantic Core integration.
Test leaf witness selection with the actual visitor protocol and a disposable
finite visitor; do not claim actual Layout or a complete observable-owner driver.

The owner copies current fields/404-entry transition backing into distinct frozen
backing before exposing a frame read. Keys carry identity/generation/frame data,
never raw pointers. A nonescapable FrameRead receives explicit owner lifetime;
unsafe host backing construction remains an identified precondition. Use native
execution for both profile flags and object compilation for ARMv6/nRF; these
are not hardware or class-owner-equivalence results.

### Frozen call matrix

| Group | Planned invocations | Gate |
| --- | ---: | --- |
| Lifetime policy controls, native | 2 | Default vs explicit LifetimeDependence, record exact supported spelling/diagnostics |
| Generated corpus + real GiftUI declarations | 4 | One positive compilation per configuration |
| Native execution | 2 | Same deterministic scalar/capture/traversal/lifetime transcript |
| Six compiler-negative cases × four configurations | 24 | Return local context, outer storage, escaping closure, stored field, nested-helper escape, overlapping mutation |
| nRF sectioned object + rooted relocatable link | 2 | Inspect reachable allocator/indirect-call/ABI properties, not whole firmware |
| Reserved repairs/additional targeted controls | Up to 14 | Within the same two-repair/48-call cap; no new question |

Generator rejection/perturbation controls and runtime stale/foreign key, frozen
write and body-error cases do not each add a compiler invocation; their inputs
and results must still be preserved. A policy-control rejection is an expected
observation; a repair is a change in response to an unexpected failed trial.

## Reproduction

Code/evidence will reside under `experiments/spike-070-protocol-canvas-versioned-access/`.
Use its bounded runner from the repository root. Pin project-local Swift 6.3.2,
ARMv6 SDK destination and Cortex-M4F hard-float flags from tracked target setup.
Both target doctors passed before experimental work; save their outputs with
the input inventory. No change to compiler/SDK pins or global selection.

## Results

**Terminal: inconclusive.** [Exact results and limits](../../experiments/spike-070-protocol-canvas-versioned-access/evidence/result.md),
[ledger](../../experiments/spike-070-protocol-canvas-versioned-access/evidence/ledger.json)
and [source/reproduction boundary](../../experiments/spike-070-protocol-canvas-versioned-access/README.md)
are committed in `c0abc624`; registration was `14ea4e18`.

- A strict finite source transformer rejects seven unsupported-use samples and
  changes output for three source perturbations. Perturbed outputs were not
  compiled; this is not complete Swift or a production macro implementation.
- Both native profiles compile with actual GiftUI declarations except the
  replaced Canvas file and pass 21 fixture checks each. ARMv6 object compilation
  succeeds with ARMv6/VFP attributes; no target execution occurred.
- `@_lifetime` needs experimental Lifetimes as well as the tested
  LifetimeDependence configuration. The default and Dependence-only controls
  reject. Experimental policy is not adopted by this evidence.
- After two fixture repairs, nRF compilation rejects `any Error` introduced at
  two throwing `&&` assertions. The likely assertion correction is untested;
  this does not refute C. The repair ceiling requires a terminal report.
- **11/48 invocations, 2/2 repairs**, stopped before the 90-minute deadline;
  no excluded waiting. All 24 compiler-negative controls and both nRF
  reachability invocations remain unrun. There is no C-P2 non-escape/heap proof.

The root is lowered to a throwing descriptor entrypoint without View conformance;
Canvas's generated draw signature gains FrameRead. Actual child traversal and
GraphicsContext run through a disposable visitor/recorder. Those adaptations
are explicit, not proof of unchanged public source contracts or actual Layout.
No production files, accepted ADRs, Specifications or hardware changed.

## Limitations

The finite corpus is deliberately smaller than the complete applications. No
source checker completeness, native Dynamic class-owner parity, actual State
reconciliation, full graph/Layout execution, physical five-bank feasibility,
whole-image heap/stack or 4 MHz performance result follows from this proof.
Experimental lifetime requirements remain an adoption issue even if tests pass.

## Disposition

Completed with an **inconclusive** result and no automatic successor. Feed the
narrow positive evidence and exact remaining gaps into RFC-014. Keep B1/B4 open:
production contextual View evaluation/error transport, complete finite getter/
helper coverage, compiler adoption policy, Embedded positives, escape controls
and target resources remain unproved. B0/B2/C-P3 storage/ownership and B3 costs
also remain open.

Revisit only after explicit maintainer authorization of a separately bounded
follow-up. Its first experimental step would correct the identified assertions,
then require Embedded positive compilation before interpreting the remaining
negative matrix and resource inspection. No alternative API or budget is
silently launched. RFC/ADR/Spec gates still precede production migration.

## References

- [C contract and proof controls](../iterations/iteration-003-review/rfc-014-c-contract.md)
- [C storage ledger](../iterations/iteration-003-review/rfc-014-c-storage-ledger.md)
- [Current plan](../iterations/iteration-003-review/memory-efficiency-plan.md)

## Separately authorized continuation

After this terminal report Eugene authorized [SPIKE-071](spike-071-canvas-embedded-escape-continuation.md)
for the assertion correction and remaining Embedded/escape/resource checks.
SPIKE-071 completed with four-profile positives, 24 valid negative controls and
bounded nRF object evidence. This original result, experiment files and budget
remain closed and unchanged; the successor evidence is separate.
