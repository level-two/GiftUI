# P08-B01 independent Strong review — 2026-10-12

**PASS for the B01 inventory and bounded B02 handoff.** Reviewed commit
`372362b5e662a15d2a2e669a9e4b6ecba830dd1f`; entry diff was only the parent-authored
independent-review dispatch in `../../progress.md`, included in this review
commit. Separate Strong `gpt-6.1-sol`, high, C3/R3; no delegation, source edits,
compiler/version/macro/executable invocation, formatter, build, counter gate or
dependency regeneration. This is an inventory/proposed-change review, not a
native feasibility result or P08 conformance review.

## Authority and review boundary

Read root AGENTS, lifecycle-reviewer and deferred-work-curator instructions,
FEATURE_LIFECYCLE, AI_AGENT_RULES, DOCUMENTATION_RULES,
IMPLEMENTATION_DOCUMENTATION, ITERATION_SCOPES, VISION/PRINCIPLES, iteration001
and003, manifest, shared RFC-014 task guide/plan, SPEC-015 owner checkpoint and
Option B approval/review. Accepted ADR-007/008/036/038 and implementing
SPEC-009/015 govern. The feature remains in implementation; SPEC-015 is
`implementing`, its plan `active`, T8.1/P08 open. The approved construction
amendment and current separate implementation dispatch supply authority; the
earlier documentation-only activity and operation-inclusive trace are history.

MVP trace is the shared interactive observable/text/Canvas reference application
across desktop, Pi and Embedded stacks. This work belongs to post-MVP
ITERATION-003 I3-04/05, preserving counter/analyzer semantics and bounded
ownership while replacing generated graphs. Neither iteration scope nor this
review supplies new architecture or an implemented transition.

The review independently inspected actual selected constructors, composition
and teardown in CounterProfileStorage, CounterHostAssembly, CounterApplication,
CounterModel, CounterAdmission, CounterPipelineOwner, both scoped host owners
and probes, CounterNativeRaster, CounterWakeIntegration and CounterGraphProbe;
also the maintained normalized-input gate, scheduled controller, report
construction and graph validator. Source identities are the unchanged
[29-file manifest](b01-source-identities.json). The
[B01 inventory](b01-inventory.md) is accurate for both actual native compositions.

## Independent mask disposition

The exact proposed role-ordered vector passes review:

```text
role:  0 1 2 3 4 5  6 7 8 9 10 11 12 13 14 15 16 17
mask:  0 0 0 0 0 0 63 0 0 0  0  1  0  0  1  0 61  0
```

- Roles0–5: profile inputs are explicit host identities, scalar bounds and
  typed backing; text views/package and literal capability contributions have
  no peer constructor inputs. Their zeros do not remove backing duties.
- Endpoint6=63: actual adapter/target/surface require control backing0; the
  native endpoint stores text views1 and effective/configuration origins2–5.
  The constructed projection checks remain required at the actual constructor.
- Executor7 is the parameterless HostApplicationOpportunityGate; source8,
  repository9 and useCases10 are default scalar owners. Their zeros are correct.
  CounterApplicationOwners retains control0 as an enclosing composition input;
  B01 explicitly traces it. Its synchronous start/deliver calls retain no peer
  callbacks and cannot turn the aggregate into executor7.
- Admission11=1: constructor limits, context, queued-fact storage and initial
  committed revision originate in profile0. Its queued-only wake call is an
  operation; no retained wake adapter establishes an upward constructor edge.
- ActionDomain12=0 and handler13=0: CounterAction is compiled vocabulary.
  CounterHandler is an enum with only static `operation`, no owner instance or
  retained target. Dispatch supplies action type, operation and independently
  constructed root access at call time. Its action parameter and Mutation result
  do not create constructor dependencies on12 or14 under ADR-038.
- Root14=1: supplied exact root/model/schema backing comes from0. Initializer
  association checks, first-root retain and independent ticket release remain.
- Normalized15=0: HostNormalizedInputGate.init requires literal source0 and
  default sequence seed only. Residence inside CounterControl is co-location;
  admission11 is supplied only to submit. Physical installation is operational.
- Wake16=61: CounterWake is scalar, but the actual host binding constructs and
  retains HostScheduledOpportunityController with the **entire** assembly report.
  Its storageAudit originates in0; effectivePresentation/capabilitySnapshot
  preserve contribution origins2–5. Text validation leaves no text package/view
  field in that report, so no edge1. Pacing/cardinality/workload are explicit host
  constants. Calling the report inert cannot erase these real copied origins.
- Residual17=0: literal finite policy selection has no peer constructor input.

No omitted actual required upward construction edge, hidden required callback
origin, ambiguous supplied backing origin or new ownership choice was found.
This approves the proposed classification; the current table remains unvalidated
and still needs the B02 changes and B03 attempt.

## Two projection replacements

Both proposed replacements are within the approved bounded realization. At
activation step7 the existing state.controlPointer exposes the already-selected
pipeline control. The finite boolean checks hasRoot, committedRecords==2,
admissionController, wake and scheduler. finalizePipeline copies hasRoot from
the actual rootIdentity after the synchronous startup cycles; no intervening
root retirement occurs before step7. Direct/scoped pipeline and execution-binding
initializers independently enforce root.belongs(to:models). attachRoot retains
the exact model ticket; quiesce releases it before coordinator/root shutdown.

Removing the two whole-coordinator borrowing helpers therefore removes duplicate
reads without removing the association/lifetime checks. Keep actual application
and native endpoint projections at this same boundary. The proposed change does
not require a new pointer getter, unsafe conformance or Optional cache inspection.
Compiler feasibility remains unproved until B03; this review ran no compiler.

## Coverage gaps and progression

The inventory correctly records current obligations, rather than passes:
rejected-admission wake/timestamp invariance; multiple fact categories behind a
nonfact wake; actual foreign binding/control/report rejection; production burst
and category boundaries; actual nonretryable refusal/supersession; every actual
activation failure stage and backing expiry; required-origin/callback-indirection
rejection before later projection. Existing structural graph negatives cannot
reject omission of a legal lower edge, and positive mask comparison alone cannot
claim that requirement. Actual Embedded endpoint and linked target coverage also
remain open.

These gaps **do not block bounded B02/B03**. The shared plan explicitly requires
recording missing coverage before B02, gives B02 a bounded helper/mask/control
footprint with evidence gaps, and limits B03 success to the native slice. No
source finding demonstrates an unsatisfiable contract or requires an upstream
choice now. The gaps remain mandatory remaining-P08 work and block a complete
HC-003/011/014 or P08 exit claim until evidenced. They are not optional Future
Work; FW-009/035 remain unchanged. No new approval requirement is introduced.

Before expanding beyond B02's four files, record a concrete remaining-P08 slice
for those controls. If an actual required upward edge, ambiguous lifetime or new
ownership/public-contract choice appears, stop the affected work and route it
upstream. This handoff does not authorize a generic validator/API redesign.

## Read-only identity verification and exact handoff

Independently rehashed all29 source-manifest entries and all491 file comparisons
in [the dependency record](b01-dependency-identities.json): zero missing/stale
entries. The492nd comparison is host/runtime compiler-receipt equality, separately
confirmed from the actual receipts. Reproduced the current driver's exact
preflight by reads/hashes, including484 runtime/host input/artifact comparisons,
compiler, core module/object and macro identity; reciprocal runtime/core/host
receipt hashes match. All four explicit rebuild-exception current hashes match
the inventory and remain excluded historical mismatches, not passing source
identities. Swift6.4 target/flags are recorded-receipt data; no version command ran.

B02 may now change only CounterHostOwner.swift, CounterDynamicHostOwner.swift,
CounterHostAssembly.swift and CounterGraphProbe.swift as proposed: remove the
two helpers, use the existing finite control projections, adopt the reviewed
vector, preserve structural negatives and identify exact endpoint/report origins.
Commit its diff and applicability/gaps. Preserve association, cache lifetime,
application/endpoint checks and operational wake behavior. No feasibility claim.

B03 follows only with those reviewed inputs: format, recheck pinned identities,
then the one predeclared counter-driver invocation. Missing/stale dependencies
require handoff; no refresh/rebuild or compiler switch is granted. Pass or fail,
freeze/commit and stop for separate Strong result review; no automatic repair or
rerun. Historical2/2 remains closed; B03 remains0/1 unused after this review.
Remaining P08 four routes, early linked images, resources/ABI, final independent
exit review and P09–P12 remain open. No manifest or authority change is needed.

Review validation: read-only inspection and hashing plus `git diff --check`.
Only this review and the existing progress dispatch/result are committed.
