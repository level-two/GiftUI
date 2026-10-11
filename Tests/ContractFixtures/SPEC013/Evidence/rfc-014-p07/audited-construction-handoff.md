# P07 audited-construction context handoff

This is a sequential Strong context handoff, not a blocker escalation, contract
amendment, exit review, acceptance or new package. Stop point: 2026-10-11, after
3478c788. Consecutive unproductive repair allowance remains **0/2**. No process
is running. No agent delegation or remote/board action occurred.

## Completed immediately before handoff

- cd29fae0 recorded the bounded actual Dynamic backing design before code.
- 3478c788 implements complete-reference-qualified constant-time ordinal layout
  lookup, retained resolved-layout banks, aggregate Drawing pools, and retained
  live-path backing. It includes step-18-macos-static.json: **531 assertions,
  ten negative compilations**, both actual profile cycles.
- The same fresh gate compiled the 34-line common-coordinator extension now
  preserved with this handoff. It does **not** instantiate audited conformance:
  CycleExecutionBinding does not yet conform to RuntimeAuditedExecutionProfileBinding.
  These source extensions are incomplete scaffolding, not audit evidence.

The existing coordinator types remain DynamicRuntimeExecutionCoordinator and
StaticRuntimeExecutionCoordinator. The pending internal binding protocol carries
Endpoint and retained storageAudit only; it changes no normative declaration.
A real factory must establish profile/limits/owner agreement before using it.
Do not claim the conditional conformance establishes those relationships alone.

## Exact actual backing locations

Sources/GiftUIRuntimeDynamic:

- DynamicObservableRootAdapter owns DynamicObservableModelStorage and
  DynamicObservableModelRegistration (the latter aliases ObservableStateRootStorage).
- DynamicObservableModelStorage owns ObservableModelOwnership and InlineArray<2,
  Model?>; four claim descriptors and two pins are inside the ownership ledger.
- DynamicSemanticRecordStorage owns two-bank metadata and typed arrays of records,
  paths, payloads and scalars. Actual Array capacities are not exposed yet.
- DynamicCanvasCallableStorage owns metadata and a typed Array of staged entries.
- DynamicLayoutHostStorage owns DynamicLayoutWorkspace and
  DynamicResolvedLayoutStorage arrays. Both now expose reservedPayloadBytes;
  the index constructor requires maximumSemanticRecords (126 in the fixture).
- DynamicDrawingPlanWorkspace exposes planReservedPayloadBytes and
  livePathReservedPayloadBytes. DynamicLivePathStorage exposes reservedPayloadBytes.
  These are retained payload extents only; owning value metadata is separate.
- DynamicRenderWorkspace owns semantic/layout visit arrays and foreground array;
  actual retained-capacity accessor is not present yet.
- DynamicInteractionStorage owns candidate records, committed records and hit
  regions as preallocated Arrays. Actual capacity accessors are not present yet.

Static counterparts:

- StaticObservableRootAdapter/StaticObservableModelStorage own actual inline
  model, ledger, registration and association storage.
- StaticSemanticRecordStorage owns control metadata and borrows typed initialized
  arrays supplied by the fixture, not the old raw-region recipe.
- StaticCanvasValueStorage borrows typed initialized staged entries.
- StaticSixInteractionCandidateStorage, StaticSixInteractionCommittedStorage and
  StaticSixInteractionHitStorage own six inline optional records each.
- SignalAnalyzerTargetHost StaticSignalAnalyzerNRFLayoutWorkspace,
  StaticSignalAnalyzerNRFResolvedLayoutStorage, StaticSignalAnalyzerNRFRenderWorkspace,
  StaticSignalAnalyzerNRFDrawingWorkspace and related plan/live-path storage use
  supplied raw regions. These are the actual finite target stores.

Shared source:

- ObservableModelOwnership.Record contains a pinned Bool per model; do not count
  the whole ledger as model metadata and then add guessed duplicate pin storage.
- ObservableStateRootStorage separates registration records, report routes and
  offered claims. Its exact field partition needs truthful accounting.
- InteractionOwnedKeyState wraps InteractionState; complete inline identities
  live in candidate/committed/hit records. Separate identity audit fields must
  subtract those bytes from record totals, never count keys twice.
- RuntimeProfileStorage, RuntimeProfileValidation, RuntimeStorageCapacities and
  RuntimeStorageByteCounts are the existing storage/audit seams. Checked totals
  belong to Runtime Core. Existing DynamicProfileStorage/StaticProfileStorage
  raw-region recipes are historical controls, not this actual backing.

## Present fixture assembly and ownership problem

All paths below are under Tests/ContractFixtures/SPEC013/RuntimeDerived.

CycleSemanticProbe.giftuiP07CycleSemantic constructs actual root adapters, then
withSemantic constructs actual semantic storage. Static Backing contains 252
records, 756 paths, 196 optional payloads, 448 scalars (two banks of
126/378/98/224). The helper runs separate State/semantic/Canvas tests before
cyclePipelineProbe. This existing helper is valid functional evidence, but is
not an audited RuntimeProfileStorage construction.

CyclePipelineProbe.withPipelineValues constructs staged Canvas capacity **1**;
cycleDrawingLimits allows **5**. Correct the complete-cycle assembly to capacity
5 before claiming capacity agreement (the isolated one-Canvas helper may remain
capacity 1 under its own limits). Static complete-cycle regions currently are
3136 layout, 4704 shared text/render overlay, 3280 path and 13536 plan bytes.
The overlay must be charged once to its owning lifetime with explicit evidence.
StaticCycleGeometry also owns an InlineArray<126, SemanticRecordReference?> and
workspace value metadata. DynamicCycleGeometry owns the actual value workspaces.

exercisePipeline takes consuming geometry/Interaction arguments but currently
uses `copy geometry` and `copy interaction` inside the control-pointer closure.
This leaves extra owned values and can cause Dynamic Array copy-on-write.
Eliminate that duplicate ownership before claiming exact audit equality. Do not
silently exclude an extra live copy from the audit.

CyclePipelineOwner owns real focused scopes, geometry, Interaction state, phase,
identities, endpoint, retry and other counters. It is moved into the **existing**
concrete execution coordinator by cycleConcreteCoordinator. CycleExecutionBinding
contains model/root borrows and control; it performs actual root.shutdown.

## Selected internal direction, remaining local choice

Build a bounded concrete RuntimeProfileStorage factory around the **actual typed
backings**, validate its real capacities/extents before client traversal, then
lend the same backing lifetimes to CyclePipelineOwner and retain that validated
audit in CycleExecutionBinding. Keep the existing concrete coordinator path.
Revalidate actual retained extents after cycles/reset/teardown. Prove wrong
profile/limits/owner mismatch rejection. Neither an audit-only value wrapper nor
an unused raw-region owner satisfies this join.

The exact local factory factoring is not written or compiler-proven yet. Prefer
one finite Static and one finite Dynamic assembly over a general generic storage
framework. For geometry/Interaction, choose between a truly consuming transfer
with explicit returned ownership or a narrow scoped in-place lend while the
factory retains backing. Current raw copying is not acceptable. If using an
in-place lend, keep its pointer/borrow entirely within the existing enclosing
lifetime callback, preserve nonescape constraints, and do not invent a registry
or new ownership mechanism. Do not move a parent value after lending its fields.

The pinned compiler permits MemoryLayout of ~Copyable/~Escapable values. Use
actual Array capacities and concrete value layouts. Class reference stride is
not class payload size. Account real class-held typed fields or a measured
concrete backing value; never guess Dictionary/object bytes. Alignment and
allocator bookkeeping are separately reported costs under the amendment, not
permission to omit owned payload. This handoff selects no unproved byte total.

## Bounded remaining P07 requirements

1. Actual storage construction/audit equality and provenance; common coordinator
   conformance instantiated by both actual profiles; static table audit without
   client invocation; capacity below/equal/above and truthful field ownership.
2. Explicit Static/Dynamic logical transcript comparison. Current tests perform
   matching assertions separately; CycleRenderSink counts events but does not
   retain the complete normalized payload transcript.
3. Actual late admission/sealed-batch behavior, stale target cancellation,
   nested entry, partial acquisition cleanup and terminal lifecycle cases.
   CyclePipelineOwner's adapter retryCount uses unchecked `+= 1` and has no finite
   retry-budget proof. SingleSourceExecutionAdmissionController currently retains
   its initial context; no updated late-admission context evidence exists.
4. Nonretryable pipeline disposition is tested, but the fixture later resets flags
   and continues. Prove genuine terminal coordinator quiescence/Interaction
   teardown, unavailable admission and no replay, without that reset shortcut.
5. Explicit malformed-storage append rollback proof for the new Drawing pools.
   First-excess/reuse/capacity preservation is already covered; the rollback code
   exists, but direct malformed-path fault proof is still pending.
6. Four **fresh final** migration route receipts, retained historical controls,
   appropriate governance/source formatting, traceability updates and separate
   Strong P07 exit review. Do not start P08 or self-accept P07. T9.1/T11.1 and
   later complete-image/resource/application gates remain open.

## Reproducible receipts and commands

Format before validation: `scripts/format-swift.sh`.

Latest passing native command:

```
scripts/contracts/run-spec-013.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/dd5d4849463055f2-hwlll28l/macos-static
```

Output: .build/contracts/spec-013-runtime-cycle/tmpb0yehscy/macos-static/result.json,
archived step-18-macos-static.json. Governance and git diff --check also pass.

Other existing core receipt routes (reuse pinned inputs, collect fresh P07 result):

- macos-dynamic: .build/contracts/spec-006-rfc-014/189dda86d331e15d-wpk82ft7/macos-dynamic
- raspberry-pi-armv6: .build/raspberry-pi/contracts/spec-006-rfc-014/189dda86d331e15d-w03qxe3s/raspberry-pi-armv6
- nrf52840-embedded: .build/nrf52840/contracts/spec-006-rfc-014/189dda86d331e15d-xnmh_sbd/nrf52840-embedded

Latest Embedded P07 receipt predates the storage repair:
.build/nrf52840/contracts/spec-013-runtime-cycle/tmpicumkbeo/nrf52840-embedded/result.json,
archived step-17-nrf52840-embedded.json. Object/ABI only, not hardware/full-image.

Fresh driver scripts/contracts/check-spec-013-runtime-cycle.py records source
hashes, compiler identity, commands and negative outputs. Its `step` report label
is still stale (`frame-acquisition-cleanup`) and should be corrected before final
receipt collection. It must not replace or weaken the historical default gates.

Failed storage-repair evidence remains on disk: tmp9awi6b24 first optimized run
hit invalidScope (LivePathBuilder.reset deactivates; fixed by recreating builder
metadata over retained backing); tmpza72cv2o then found fixture initializer access
and untyped catch errors (fixed with @testable and typed do). tmp9awi6b24 was also
used for local debug replay and is not an immutable accepted receipt. Fresh
optimized tmpb0yehscy is the accepted slice receipt. No repeated unproductive
repair occurred; carry **0/2** into the next context.
