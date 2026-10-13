# SO-02 independent Strong design review — 2026-10-13

Reviewed `35f4759c`, sequential independent Strong task `p08_so02_review`,
with only the pre-review dispatch dirty. **BLOCKED for the execution proposal
as written; physical design is suitable for bounded source realization after
the two documentation corrections below.** This review grants no production
allowance and proves neither Swift acceptance nor fit. No compiler, test/build,
source edit, experiment, hardware action or subagent ran.

## Authority and bounded finding

Authority is accepted [ADR-039](../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md)
and live [S11.1–4](../../../../../../docs/specs/spec-011-interaction.md#s111-scoped-storage-and-state-declarations),
[S13.1–2](../../../../../../docs/specs/spec-013-runtime-profiles.md#s131-physical-owner-session-and-coordinator-contract),
[S15.1–2](../../../../../../docs/specs/spec-015-host-configuration.md#s151-construction-transfers-and-retirement),
applied at `59d98712`. The [handoff checklist](../../../../../../docs/iterations/iteration-003-review/rfc-015-p08-handoff.md#pre-code-physical-design-note-checklist),
[delivery allocation](../../../../../../docs/iterations/iteration-003-review/rfc-015-delivery-allocation.md)
and [SO-01](so01-inventory.md) govern necessity and evidence. SPEC-011/013/015
remain implementing, owner plans active. ITERATION-003 I3-04/I3-05 requires the
finite runtime-derived counter/four-stack validation while preserving the closed
ITERATION-001 controls; full RFC-015 reconciliation/conformance remains I4-07.
No architecture or Spec correction is identified. No new deferred item arises.

## Concrete blockers and smallest corrections

**B1 — layout evidence precedes no authorized producing step.**
[Design lines 291–295](../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md)
requires the first authorized current-target numeric layout transcript before
SO-04 acceptance. [Proposal lines 89–95](so02-execution-proposal.md) says SO-04
selects/finalizes that numeric layout, but permits no compiler probing before
SO-07; its listed SO-03 command does not compile the counter layout. No current
replacement numeric transcript is identified. A source checkpoint can select
the checked MemoryLayout-derived algorithm and prefix ledger, but cannot be
reported as validated numeric acceptance before the actual target evidence.

Smallest correction: explicitly distinguish SO-04's unvalidated source checkpoint
from final SO-04 acceptance; state the exact already-proposed SO-07/08 output
that supplies target offsets/count/stride/alignment and verifies the C reservation
constant. Keep numeric layout and SO-04 validation open until that evidence.
If an earlier compiler capture or constant correction/rerun is needed, stop and
propose its exact separate allowance rather than inventing numeric values or
silently consuming a probe. This correction needs no new experiment or contract.

**B2 — finite commands do not explicitly close changed-consumer coverage.**
[Proposal lines 14–28](so02-execution-proposal.md) changes six RuntimeCore
consumers plus necessary owned analyzer factory constraints. Current
`scripts/contracts/check-spec-011-owned-keys.py:77` compiles only
RuntimeRecordInteractionBridge and RuntimeInteractionCandidateResolution from
that module. It omits RuntimeRecordCanvasInteractionBridge,
RuntimeInteractionCandidateTransaction, RuntimeInteractionCandidateCoordinator
and RuntimeInteractionDispatcher. The proposed SO-07 runtime driver at
`scripts/contracts/check-spec-013-runtime-cycle.py:77–79` adds the Canvas bridge
but still omits the latter three. The counter driver replays that selected
recipe (`check-spec-015-counter.py:91–102`); the scoped-host driver builds only
its named lower host modules (`check-spec-015-scoped-host.py:49–54`). None names
the actual Dynamic/StaticSignalAnalyzerActionDispatcher factories. Merely
registering new state lifetime pairs or disclosing wider validation at SO-09
does not show these changed declarations retain their owned contracts.

Smallest correction: explicitly require changed source-input registration and
focused positive/scoped-operation or owned-retained compatibility cases for
all six changed RuntimeCore consumers; assign the actual analyzer factory
compatibility checks an exact finite command/input route and budget before
source dispatch. The same existing driver invocations may carry those cases
if the proposal names the registration, prerequisites and finite labels;
otherwise propose a separate narrowly bounded compatibility invocation.
Do not infer a broad repository/P10 run or defer required changed-caller
compatibility to I4-07. Freeze labels/source hashes before the one invocation,
as already required by the proposal. This is command coverage, not a demand
for an additional production migration or a known source compile failure.

## Physical design assessment

The [design](../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md)
covers the checklist at source level, with the following acceptance boundaries:

- **Actual owner and typed disjoint borrowing:** the owner's inout access
  encloses every actual T/UInt8-region borrow; the immutable token is a reborrow
  of that owner, never a pointer variable. Owner descriptor fields are separated
  from reserved pointees, descriptor snapshots precede token creation, and
  owner mutation waits until all dependent carriers die. Restricted concrete
  construction, no raw getter/arbitrary-conformer entry, no alias/reentry and
  per-target exclusivity requirements preserve S11/S13. Annotation acceptance
  and full direct/generic negative matrices are unproved, not design passes.
- **Native storage stability:** individually pinned typed Optional slots and a
  closed owned-result callback avoid assuming an ordinary returned aggregate
  stays put. The actual payload projection must still prove final-object
  identity/address throughout initialization, sessions and destruction. A
  materialized payload copy/writeback cannot count as the final typed borrow;
  measuring its temporary stack cost alone would not cure that ownership defect.
  The note already rejects temporary bank copies and requires compiler/source
  proof or an exact diagnostic stop. Dynamic payloads must remain unique with
  no exported COW alias. Optional tags, surplus capacity and temporaries count.
- **Embedded migration:** the checked region algorithm, 14-entry Static and
  nine-entry Dynamic inventory, outer prefix, byte initialization, typed
  acquisitions and reverse unwind give an explicit final-object plan. The old
  workspace/CounterStaticKeys Optional binding/init/access/take/audit/destructor
  and control placement are one replacement; old stride equality is removed.
  Actual `StaticCounterEmbeddedBacking.swift:20–162` confirms those old sites.
  Numeric target layout and the reservation/C constant remain B1 evidence.
- **Exchange/count ownership:** five real banks retain their own counts;
  complete typed descriptors change roles while original physical IDs own
  destruction. No selected access uses owned payload exchangeContents.
  Equal immutable logical pair capacities are checked before acquisition;
  unequal sufficient retained extents stay charged. Serialized accepted R/H
  exchange/revision, refusal/discard, complete semantic keys and independent
  action/generation outcomes remain unchanged. Address/count/role transcripts
  with unequal counts and original-ID destruction are still required.
- **Cleanup/retirement:** one structured holder precedes every body return,
  distinguishes session/supplied/live/retired, and does not duplicate Interaction
  phase state or candidate resolution. Both profiles retain the full unions,
  activation span, pre-quiescence cache release, stop/drain/pins/registrations,
  once-consumed coordinator Optional and pipeline retirement, then semantic→
  geometry→Interaction reset. Existing source at CounterHostOwner:227–261 and
  CounterDynamicHostOwner:168–202 confirms the extraction/reset sites being
  replaced. Terminal empty reset and later retired empty reset are distinguished
  from once-only teardown/destruction. Every activation/candidate/failure/normal
  path, repeat session and backing-last check remains required evidence.
- **Measurement and compatibility:** original physical inventory and mutable
  role maps have separate ledgers; all 26 families, control/state, descriptors,
  native padding, constructor/writeback/carrier costs and Dynamic overhead are
  charged without adapter subtraction or duplicate selected owned geometry/Keys.
  The four maintained withBacking callers are the two Counter and two Cycle
  measurement/region files; the design repairs them with owned facts while
  retaining owned analyzers/dispatchers/Cycle and owned-only workspace returns.
  Compiler and compatibility coverage remains required, including B2.
- **Limits and execution:** ordered four-profile commands, native-only component
  restriction, actual fresh recipe paths, two early images, failure freezes and
  separate diagnosis/repair stops are explicit. Complete feasible construction,
  caller/helper/closure/IRQ stack and allocation/ABI/RAM/flash proof is mandatory;
  link success and small handles cannot replace it. All proposed maxima remain
  proposals, including the one native SO-03 invocation, up to 14 SO-07 driver
  cells and two image invocations. No automatic repair or historical budget reset.

## Disposition and checks

Correct B1/B2 documentation, then obtain bounded independent verification of
those corrections before presenting the concrete production allowance. No
source or compiler work follows from this review. All nine SO criteria,
HC-RD-003 and P08/R07/T8.1 remain unmet/open; P09–P12/hardware/timing gates
remain separate. The 58,648/27,648 failure, historical consumed allowances,
SPIKE-075's closed seven experiments and cumulative unproductive guard persist.

Documentation checks and review commit are recorded in the P08 receipt.
