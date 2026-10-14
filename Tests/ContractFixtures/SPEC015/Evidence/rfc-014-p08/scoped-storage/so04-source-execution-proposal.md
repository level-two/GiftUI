# SO-04→06 coherent source package proposal — 2026-10-14

**PROPOSED, NOT AUTHORIZED.** This packet follows the passing
[SO-03 fixture review](so03/fixture-stabilization/independent-review.md), source
`57175025`, result `2adc9e28`, independent review `de51b8a5`. Preparation inspects
clean `de51b8a5` and changes documentation only. It creates no production,
compiler, build, executable, debugger, target or repair allowance.

## Concrete next decision

Authorize **one sequential SO-04→SO-05→SO-06 source implementation pass**,
with a separate source/evidence commit for each step, **zero automatic repairs**,
then a separate independent Strong source review (Sol 6.1 High). No compiler,
build, test executable, debugger, IR capture or image invocation is included.
SO-07's numerical validation allowance and SO-08's image allowance remain pending.
Approval should be recorded in the P08 receipt before source dispatch; this
proposal itself is no evidence of approval.

## Authority, dependency and separability

Accepted [ADR-039](../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md)
and the approved [S11/S13/S15 amendments](../../../../../../docs/iterations/iteration-003-review/rfc-015-contract-acceptance.md)
govern; the [reviewed physical design](../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md)
and [existing source sequence](so02-execution-proposal.md#remaining-source-work-subject-to-the-recorded-allowance-and-so-03-review)
derive their realization. SPEC-011/013/015 stay implementing, plans active.
ITERATION-003 I3-04/I3-05 needs the finite counter and safe four-stack runtime
storage; ITERATION-001's analyzer/stack controls remain compatibility requirements.
Full RFC-015 delivery and the accepted analyzer integration residual stay I4-07/P09.

SO-04 can be committed as a **provisional, uncompiled source checkpoint**. It
cannot be accepted as a usable standalone owner replacement. Current Embedded
storage initializes `CounterStaticKeys?` at offset 24,024 and exposes its
accessors/audit/destructor; selected Static HostProbe still calls
`interaction.take()` and `workspace.withGeometry`, and Dynamic HostProbe calls
both `geometry.take()` and `interaction.take()`. S15.1 requires old-slot
binding/init/take/control/audit/deinit replacement together. Those selected
callers need SO-05's complete scoped carriers and consuming retirement. The
existing plan therefore requires one coherent SO-04→06 source freeze before
whole-host validation. Intermediate checkpoints grant no overlay, acceptance,
buildability or runtime claim; ordinary owned profile/probe storage is separate.

## Bounded files and ordered commits

`RD/` means `Tests/ContractFixtures/SPEC015/RuntimeDerived/`. No source path beyond
this list is included. Record the actual changed paths and old/new symbols in
each receipt; if another path is necessary, stop with its exact reason.

| Step | Source boundary and resulting checkpoint |
| --- | --- |
| SO-04 | New `RD/CounterScopedStorage.swift`; existing `StaticCounterEmbeddedBacking.swift`, `CounterProfileStorage.swift`, `CounterGeometry.swift`, `CounterStaticGeometry.swift`, `CounterStorageMeasurement.swift`, `CounterStorageRegions.swift`. Implement final typed G/B/five-bank storage, checked layout, original acquisition-prefix inventory/reverse destruction, private actual-owner session token, exclusive factory/provenance and pair-capacity checks, owned physical facts. Record every old/new binding/init/access/audit/destructor site. Selected concrete geometry/access/assembly bodies belong in the new trusted file. Numeric layout/C reservation and syntax remain unvalidated. Commit provisional SO-04 source and its ledger. |
| SO-05 | The new trusted file and shared profile/measurement files above, plus `RD/CounterHostOwner.swift`, `CounterDynamicHostOwner.swift`, `CounterPipelineOwner.swift`, `CounterHostProbe.swift`, `CounterDynamicHostProbe.swift`, `CounterCoordinatorProbe.swift`, `CounterGraphProbe.swift`, `CounterRouteEntry.swift`. Transfer exact G/C/R/H and all existing scope dependencies through supplied/pipeline/coordinator/host/retired values; consume the quiesced Optional once; preserve owned-only `returnWorkspaces`; install body cleanup before any early return/activation. Finish the selected old-slot/assembly migration, preserving separate owned coordinator routes. Commit SO-05 and the complete cleanup/transfer table. |
| SO-06 | New `RD/CounterScopedStorageProbe.swift`; existing `RD/CounterFixedStorageProbe.swift`, `CounterHostCorpus.swift` and directly corresponding host/graph probes above. Add deterministic original-address/count/extent/role and destruction transcripts, acquisition-fault prefixes, capacity boundaries, unequal sufficient extents/counts, refusal/discard, repeated sessions, early returns and activation/candidate failures; retain independent action/semantic/pixel/graph/join/wake/admission controls. Commit SO-06 with the exact planned positive/negative labels and source freeze. |

Only mechanical registration and intended-cause/positive-twin generator updates
in `scripts/contracts/check-spec-015-counter.py`,
`check-spec-015-scoped-host.py`, `check-spec-013-runtime-cycle.py`,
`check-spec-011-owned-keys.py`, the three existing `run-spec-011.sh`,
`run-spec-013.sh`, `run-spec-015.sh` drivers and `driver-registry.tsv` are included.
New test files other than the one named above require a new concrete scope.
Runtime coordinator source remains read-only: if its current suppressions or
Optional union require a change, freeze the exact contract-cited finding for
separate scope review rather than adding it automatically. Firmware/CMake/image
recipe changes are reserved for the later measured layout/image handoff.

SO-03 Interaction/bridge implementations and frozen attempt evidence stay pinned.
The provisional owner layout must not copy historical offsets, guess a new C
byte constant, alias Dynamic arrays, retain a second selected owned Keys/geometry,
overlay initialized storage or measure physical banks as adapter sizes. Retain
the existing C reservation only as an explicitly unvalidated input; mismatch
against future target facts stops before any correction/recompile. No actual
layout/fit value is supplied by this source-only package.

## Review boundary, limits and stops

One initial source realization is proposed, not a variant search. Each step
records an inspectable diff, necessity/criterion mapping and known unresolved
compiler/ABI facts before the next dependent source step. Before SO-07, one
independent read-only Strong review inspects the coherent migration, full
dependency unions/private visibility, no-alias/old-slot inventory, every body
return and original-prefix/destruction ledger, all planned negative twins and
the exact driver registration changes. A source blocker freezes the package;
there is no authorized corrective pass. Formatting occurs once at the reviewed
freeze before future compiler validation, as specified by the existing packet.

Stop and escalate any necessary contract/architecture/scope change, forbidden
lifetime or unchecked fallback, unexplained loss of cleanup/owned compatibility,
missing finite test oracle, or need for a source/compiler diagnostic outside this
allowance. Preserve each failure and ask independent review to classify progress;
the two-consecutive-unproductive guard and all historical counters survive step,
agent/model and package names. No new repairs, compiler calls or targets are
authorized by a productive checkpoint.

## Later validation proposal; still unapproved

The [existing exact SO-07 commands and pinned profiles](so02-execution-proposal.md#known-pinned-identities-and-ordered-so-07-proposal)
remain the reviewable future sequence: macOS Dynamic → macOS Static → Pi ARMv6
Dynamic → nRF Embedded Static, with Interaction then runtime owner drivers,
native-only scoped-host compatibility, then the actual counter route. Proposed
maximum remains **14 driver invocations, once per cell, no automatic retry**;
the later source review must refresh actual receipt/input identities and freeze
the finite new labels before any such allowance. No stale core receipt triggers
an implicit rebuild. Target routes compile/inspect; native routes execute their
fixed corpus. SO-03 evidence is reusable only for actually unchanged inputs/cases.

The [SO-08 proposal](so02-execution-proposal.md#so-08-early-images-measurement-and-independent-exit)
then has one Pi image link and one supported nRF invocation, with actual target
layout/C-symbol comparison and complete feasible construction/helper/IRQ stack,
ABI/allocator/RAM/flash ledgers. Those are separate future numerical allowances,
not covered by the current decision. SO-09 remains a separate independent exit.
All nine SO criteria, HC-RD-003/P08/R07/T8.1 and the 58,648-vs-27,648 failure
remain open, as do I4-07/P09–P12, timing and hardware obligations. No new deferred
idea, lifecycle/status change, limit/workload relaxation or historical budget reset.
