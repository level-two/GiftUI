# Remaining P08 R02 finding — independent Strong review

2026-10-12. Reviewed `f978aa81f1a89cca8a4197045e0214001e8cff55`, separate
Strong gpt-6.1-sol/high, C3/R3, sequential/no delegation. Entry diff was only
the parent-authored review dispatch in `../../progress.md`, included here.

**Disposition: a bounded local checked join is available; no new ownership,
public API, architecture or human approval gate is needed. Counter/analyzer
capacity applicability is already settled by SPEC-015.** R02 is not implemented
or validated by this review. Historical2/2 and B031/1 remain closed.

Applied lifecycle-reviewer instructions and the prior B01/B03 orientation.
Accepted ADR-038 and implementing SPEC-015/009 remain authority. Feature stage
is implementation; SPEC-015 plan active/T8.1 and P08 open. ITERATION-003 I3-04/05
is post-MVP runtime counter/analyzer delivery preserving the reference's shared
interactive state/text/Canvas and supported stack semantics. No lifecycle status,
manifest or contract change is required for the implementation choices below.

## Existing trusted anchor and insertion point

The finding correctly identifies the missing rejection: both binding
initializers check root.belongs(to:models), but do not independently associate
their separately supplied control/audit. Neither a raw owner UInt32 nor an equal
audit/report identifies a live control allocation.

The existing trusted source is the actual profile factory's lexical composition:

- CounterHostProbe.runCounterHost first obtains audit() from its actual Static
  profile, then its valid CounterHostAssembly. The root.withLifetime and nested
  semantic/Canvas/workspace scopes plus withUnsafeMutablePointer(to:&control)
  furnish actual model/root/control backing. These exact values are retained in
  inert CounterHostSuppliedStorage; the already validated immutable assembly is
  retained in CounterHostOwner.
- CounterDynamicHostProbe.runCounterDynamicHost performs the corresponding
  Dynamic composition. Its CounterDynamicHostSuppliedStorage retains the actual
  model/root/control/audit and consumed geometry/Interaction. The selected kind
  and profile are fixed by this concrete host route, not by a candidate report.

These existing retained inputs are the expected side of the check. Proposed
binding inputs are its candidate side. Keep them independently named: a helper
that builds both sides from an arbitrary candidate, or an equality of two copied
candidate descriptors, is circular. An expected input originates in the lexical
profile/supplied state/validated assembly above, never in the injected candidate.

**Insert the checked join in each state.activate inert branch before the first
CounterHostPipeline / CounterDynamicHostPipeline constructor.** Their initializer
already calls initializeCounterWake and constructs the endpoint. Checking only
the later binding initializer would therefore be too late for the required
no-side-effect foreign-input negative. Binding and admission construction follow
only after the join succeeds. Do not borrow or inspect a whole active coordinator.

One shared finite routine at this existing composition boundary may borrow the
expected supplied scopes and proposed binding scopes transiently and compare:

1. Candidate models.sharesOwner(with: expected supplied models); candidate root
   belongs to both candidate and expected models. This checks actual ownership
   and model backing/schema, rather than numeric namespace identity. Retain the
   existing initializer checks too. Root's initializer is fileprivate and the
   selected route obtains it from the actual adapter lifetime; do not claim a
   new general root-address introspection API.
2. Candidate control pointer equals the expected supplied controlPointer, before
   either pointer is dereferenced for notification, endpoint or admission work.
3. Candidate audit equals supplied.audit; audit.profile and audit.limits.profile
   equal the selected concrete Static/Dynamic profile. Also require expected
   assembly.report.profile/kind/storageAudit to agree with that selected profile,
   host kind and supplied audit.
4. Candidate report equals the already validated assembly.report in full, rather
   than comparing a few pacing fields or re-running validation. Audit/report
   equality is configuration consistency; the model/control checks provide the
   separate live identity association.

Actual successful host construction must use the same checked candidate inputs
after success, with no substitution before pipeline/binding/admission creation.
All later application/admission/wake aliases must derive from that checked
control, as the current actual path already does. No retained second anchor,
new owner, namespace, adapter or wake accumulator is necessary. Transient
borrowed arguments and existing copied audit/report do not change ownership.

## Existing finite failures and independent controls

The existing HostConfigurationError and MacOSStatic/DynamicHostActivationFailure
sums already provide the needed finite route. Return a local
HostConfigurationError? from the checked join and propagate a rejection from
constructRuntimeAndEndpoint as `.failure(.configuration(error), progress:.init())`.
Keep state inert, constructions==0 and activationStep==0; increment/advance only
after success. The activation controller then has no runtimeConstructed progress
to quiesce. Do not force-unwrap a failed binding or replace rejection with a trap.

Use deterministic existing cases: wrong selected kind/profile -> profileMismatch;
foreign model/root association -> invalidModelTarget; inconsistent same-profile
audit -> invalidWorkload; foreign control or unequal otherwise-profile-correct
candidate report -> invalidWakeIntegration. These are host-owned supplied-input
checks with the Spec's existing contained invalidValue mapping (lines1311–1321),
not a new failure category or a collapsed focused-owner error. After activation,
the existing scheduler's report mismatch retains its exact
`.rejected(.assemblyReportMismatch, pacing:nil)` result before pacing mutation.

Negatives must exercise this same guarded actual construction route, with
independently live foreign inputs; an unrelated test-only predicate is
insufficient. Both actual native profiles need: accepted exact join, foreign
control, foreign coherent model/root pair, crossed root/model, opposite-profile
audit, same-profile differing audit and differing report. A foreign coherent
pair from a separate namespace with the same raw owner number is useful proof
that actual backing comparison is exercised. Confirm no change to either
control's wake/reasons/outstanding, host requests, accepted-fact count/time,
admission queue, endpoint/application constructions or finalized/applied counts.
Pointer equality checks and rejection must precede control dereference.

Also exercise unequal report on the actual installed scheduler, without moving
the accepted clock forward first; prove rejection leaves pending work serviceable
with the original report. Existing begin compares reports before pacing.schedule,
so no scheduler/API redesign is needed. Preserve all existing lifetime
annotations, valid composition activation and teardown checks. This review
selects the bounded mechanism; compiler realization remains untested.

## Counter capacity applicability

SPEC-015 lines228–233 distinguish scalar counter model limits; lines279–284
explicitly preserve its existing finite corpus and own immutable scalar workload
without analyzer storage claims. Lines893–935 describe first-party **Signal
Analyzer** production pacing and category semantics:20 transitions,2 current-value
bootstrap facts and6 action-induced publications,28 conforming production facts,
32 compact slots and physical fact33 rejection. The counter does not acquire
four channels or those callback categories by sharing conservative pacing values.

CounterWorkload's actual state capacity34, input/action capacity2 and completion
capacity1, CounterAdmissionBacking's34 scalar slots and CounterCoordinatorProbe's
34 accepted/35 rejected states are therefore the correct counter-specific
storage boundary. Preserve them. They cannot be relabeled compact32/33 or
analyzer20/2/6 evidence. Existing snapshot/compact/reserved cardinality fields and
pacing reservations remain unchanged; do not invent category tags or silently
resize the counter to force a production claim.

For R02, test/reuse with explicit applicability the real counter34/35 queue
boundary, finite scalar source/repository/use-case callback behavior and existing
HostApplicationStartupValidation projection negatives. Label the last controls
as declared projection checks, not proof of actual analyzer producers. Test
actual accepted callbacks and rejected reentry/stopped delivery against these
finite counter owners; do not claim their standalone scalar service method
enforces a per-window four-channel category policy it does not implement.

Analyzer28/32/33/category obligations remain mandatory on the existing analyzer
producer/admission migration and functional-conformance paths (P09/P10 with
P11 resource/workload evidence). This corrects B01/R02 evidence applicability;
it neither relaxes HC-011 nor postpones required counter identity proof. No
human decision, new counter feature or capacity amendment is needed.

## Handoff and evidence limits

The parent's existing R02–R05 assignment authorizes the corresponding fixture
composition/test work. Before edits, record exact symbols/cases and footprint:
both supplied/state/constructRuntimeAndEndpoint paths and their actual probes;
binding initializers only if the shared checked route needs their finite input
validation, plus counter application/assembly controls only as bounded above.
No maintained generic API change is selected. No new retained layout should be
introduced; retain actual resource accounting for any changed fixture metadata.

If implementation cannot retain the trusted expected/candidate distinction
without escaping scopes, adding a retained owner or changing a generic contract,
stop that concrete choice and report it. No such need is established by the
current source, so speculative upstream approval is unnecessary now. R03–R05,
four routes, linked images/resources/ABI, independent P08 exit and P09 remain
outside this review's implementation boundary.

Read-only verification: all17 input-manifest hashes match current source;
inspected exact supplied/state/profile factories, both binding initializers,
scope comparison, report/scheduler/activation error routes, workload/admission
and relevant SPEC-015 clauses. `git diff --check` on authored review/progress
passes. No source/compiler/test/build/dependency changes or allowance use.
