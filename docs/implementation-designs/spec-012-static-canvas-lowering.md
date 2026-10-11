---
spec: SPEC-012
feature: canvas-drawing
title: Implementation Design — Static Canvas Lowering
status: current
authors:
  - codex
created: 2026-09-12
updated: 2026-10-11
implementation_plan: ../implementation-plans/spec-012-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-007
  - SPIKE-008
supersedes: null
superseded_by: null
---

# Implementation Design — Static Canvas Lowering

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## RFC-014 P06 current realization — 2026-10-11

The approved runtime amendment replaces the historical closure/capture realization
below. GiftUI now defines the fixed-domain Canvas protocol and supplies only its
Never leaf defaults. FiniteSourceLowering identifies authored Canvas declarations,
checks one synchronous typed draw witness, and emits `_giftUIDraw` with a borrowed
FrameRead. Ordinary custom views retain their inferred bodies. The existing
scoped two-parameter withPath form remains supported.

Generated schema facades have a drawing-specific checked initializer and indexed
accessor. They translate only the five closed access failures into the approved
DrawingError cases, avoiding erased error transport through Embedded Swift.
Each generated draw witness first checks all captured typed model keys, in
sorted property-name order, through those checked initializers. Each temporary
facade is discarded immediately. This unconditional prologue precedes all
authored statements, including withPath and branches that do not read model
fields; keyless Canvas witnesses receive no prologue. Table case/payload and
producer identity/order validation still precede this binding. The existing
member-access lowering can revalidate during a field read within the same scope.
The private Canvas bridge constructs a checked zero-origin Rect from Layout Size.
No escaping Canvas closure initializer remains in GiftUI.

The approved scoped-source correction now permits the lexical adapter. Optional
finite-lowering output emits a separate host table, concrete typed union, dense
nonzero per-type IDs and an exhaustive switch, using actual MemoryLayout stride
for each payload case. No runtime occurrence topology is generated.

Both profiles lend initialized bounded typed slots through CanvasStagedValues.
Static takes caller-owned MutableSpan backing; Dynamic allocates one configured
array before its lending callback. A slot retains identity/witness, optional
owned value and an invoked bit; release clears its value once. The lender's defer
cleans any caller-owned early-rejection suffix. The noncopyable/nonescapable
ObservableCanvasInvocationSource has explicit lifetime dependence on both actual
P03 model scope and slot scope. Each invoke opens a fresh model read, passes it
to exactly one validated table case and ends it before release. DrawingError is
transported as a closed optional result across the access-error callback.

Candidate expansion stores concrete Canvas values in the existing bounded generic
payload pool tagged pendingCanvas. Before any consumer borrow or publication,
CanvasSemanticTransfer moves each occurrence into the staged store and replaces
the semantic payload with an empty Canvas marker. A failed transfer discards its
staged prefix and candidate while preserving the published bank. Semantic Core
only provides the pending-payload transfer operation and fences; Drawing owns the
concrete codec. No additional bank or field is introduced. The generic payload
union can enlarge every reserved payload slot; target measurements must report
the full two-bank cost, not merely the count of live Canvas values.

Four-profile selected evidence is now in the
[shared progress record](../../Tests/ContractFixtures/SPEC012/Evidence/rfc-014-p06/progress.md),
with finite P06 PASS after [independent repair review](../../Tests/ContractFixtures/SPEC012/Evidence/rfc-014-p06/repair-exit-review.md).
Actual Counter semantic payload slots grow32→36
bytes on all measured targets (+784 bytes for196 reserved slots); Analyzer
slots grow32→40 on64-bit native (+1,568 bytes),32→36 on32-bit targets (+784).
The source descriptor is64 bytes native/32 target. Five Analyzer staged slots
plus metadata are244 bytes native/184 target. The single P11 ledger must include
these costs with full overlapping host/stack/linked evidence; component IR's
absence of direct allocator calls is not a transitive zero-heap conclusion.
The sections below describe the historical baseline, not the current protocol
representation or permission to retain a closure fallback.

## Historical baseline realization

## Purpose and Boundary

This note records the source-generation boundary that turns statically known
Canvas expressions into stable nonzero callable IDs, fixed-layout captures,
and complete finite dispatch. It exists because capture packing, repeated
occurrence ownership, dispatch, and destruction span generator and runtime
owners and are not safely reconstructable from one generated switch.

The note does not select production application expressions, capacities,
observable handles, runtime-profile storage, host assembly, or raster behavior.
SPEC-013 owns production generated storage and dispatch integration; SPEC-015
owns production limits and host lifetime proof.

## Governing Contract

The realization follows SPEC-012's `Public Contract`, `Module Contract`,
`Types / APIs`, `Behavior`, `Resource Contract`, and DR-001, DR-010, DR-011,
and DR-012. It guides plan tasks T6.1-T6.5.

ADR-028 fixes callable timing and release, ADR-029 fixes scoped Path ownership,
ADR-030 fixes the normalized stroke meaning reached by dispatch, and ADR-031
requires fail-closed bounds before a cycle begins.

## Current-Code Context

`GiftUI` exposes the single closure-shaped Canvas source API and its narrow
non-returning invocation bridge. `GiftUIDrawing` owns
`StaticCanvasCallableTable` and `StaticCanvasLimits`. T6.1 adds a checked
profile-neutral generator fixture. T6.2 supplies its generated capture records,
greatest-case storage, and complete direct-dispatch table without installing a
production static Canvas representation. SPEC-013 remains the owner of that
profile seam.

## Proposed Internal Organization

Source analysis produces one ordered descriptor. Each expression record has a
stable source key and the exact ordered fields read by its closure. Each
runtime occurrence refers to that expression and owns a distinct capture-record
key plus exact field values.

The lowering step assigns dense IDs `1...N` in descriptor order. It computes
each capture record using checked size/alignment facts, emits one callable case
per expression, and emits occurrence records referencing the assigned ID.
The checked manifest is the review seam between source analysis and Swift
emission. T6.2's checked generated test source consumes it; that fixture is
evidence, not normative source authority.

## Data and Control Flow

```text
static source analysis
  -> ordered expression/capture descriptor
  -> checked ID and layout manifest
  -> generated capture records + union + complete switch
  -> profile-owned semantic payload
  -> synchronous Canvas invocation
  -> immediate capture destruction
```

Repeated occurrences share only the expression ID and switch case. They never
share the capture-record key or storage. The closure's `context` and `size`
parameters are invocation inputs, not captures.

## Algorithms and Data Structures

IDs are the one-based position in canonical expression order and therefore
cannot be zero. Source keys and anchors are unique. Record layout preserves
field order, aligns each field offset, and rounds record size to the greatest
field alignment. The capture union uses the maximum record size and alignment,
never the sum. Empty capture records have zero payload bytes and alignment one.

The manifest lists callable cases and switch coverage separately so validation
can reject missing, duplicate, or stray cases before code generation. It also
lists occurrence-to-expression mappings and capture-record identities so reuse
of a record by repeated occurrences is observable.

## Lifecycle and State

The descriptor and manifest are build inputs. A generated occurrence capture
is initialized during static semantic staging, borrowed by exactly one
invocation, and destroyed immediately afterward or during mandatory cycle
finalization. An ID or capture becomes invalid when its owning occurrence is
released; no generated record enters published semantic or frame storage.

## Runtime Profiles and Platforms

Only static profiles consume the generated table and inline records. Dynamic
profiles retain the approved bounded closure wrapper under SPEC-013. Both
reach the same `CanvasInvocationSource` behavior and scoped drawing machinery.
The generator and manifest checker run on the host; emitted Swift must later
compile under both the macOS static and nRF52840 Embedded Swift compilers.

## Resource and Failure Behavior

All counts are checked before conversion to `UInt16`. Capture sizes and aligned
offsets use checked arithmetic. Generation fails before linking for zero or
excess IDs, incomplete coverage, unsupported captures, over-limit records, or
an unlowered closure. There is no closure-retaining fallback. Production limit
comparison and the address-stable observable-model handle are implemented by
the Static runtime owner. Cross-profile allocator/symbol evidence remains T6.5
work.

## Test and Diagnostic Seams

The fixture has three expressions and four occurrences. Two occurrences reuse
one callable ID while owning different capture records and values. The checker
reconstructs the full manifest from the descriptor, verifies source anchors,
field layouts, nonzero complete generated switch coverage, whole-storage borrow,
and absence of a closure fallback. Host tests compile the generated conformance,
compare its exact four-stroke transcript, verify greatest-case rather than
summed storage, and poison captures after normal and throwing invocation. The
generator gate runs a checked fourteen-case rejection corpus before accepting
the generated source. Later tasks add cross-profile resource inspection without
making diagnostics control runtime behavior.

## Rejected Implementation Alternatives

- Hash-derived IDs are rejected because collision handling and tool-version
  stability add no value to a finite canonical input order.
- One ID per runtime occurrence is rejected because identity belongs to the
  syntactic expression; occurrence state belongs in distinct capture records.
- Summed capture storage is rejected because the contract requires a tagged
  maximum-sized union.
- A default switch case invoking a retained closure is rejected because
  coverage must be complete and production static images admit no fallback.

## Open Implementation Questions

No Milestone 6 implementation question remains. The exact production
source-analysis front end and emitted private type names remain replaceable
SPEC-013 integration details. T6.5 still owns the cross-profile resource
evidence on both pinned compilers. The completed differential fixture now
compares Dynamic closure storage with Static generated occurrence storage for
success, typed failure, immediate release, plan counts, cleanup, and combined
render-operation accounting; the SPEC-013 profile reports supply the shared
allocator, symbol, section, ABI, RAM, flash, and target inspection evidence.

## Code and Evidence Links

- [Static Canvas source descriptor](../../Tests/ContractFixtures/SPEC012/static-canvas-input.yaml)
- [Checked static Canvas manifest](../../Tests/ContractFixtures/SPEC012/static-canvas-manifest.yaml)
- [Static Canvas manifest checker](../../scripts/contracts/check-spec-012-static-canvas-manifest.rb)
- [Generated callable table fixture](../../Tests/GiftUIDrawingTests/GeneratedStaticCanvasCallableTable.swift)
- [Static callable evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-6/static-canvas-callable-table.md)
- [Generation rejection evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-6/static-canvas-generation-rejections.md)
- [Static host-handle evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-6/static-canvas-host-handle.md)
- [Profile storage equivalence evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-6/profile-canvas-storage-equivalence.md)
- [T6.2 Specification blocker](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-6/static-canvas-callable-table-specification-blocker.md)
- [SPEC-012 contract fixtures](../../Tests/ContractFixtures/SPEC012/README.md)
