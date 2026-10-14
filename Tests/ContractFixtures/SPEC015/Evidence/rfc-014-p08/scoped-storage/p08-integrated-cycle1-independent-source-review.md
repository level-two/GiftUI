# P08 cycle 1 independent Strong SOURCE review — 2026-10-14

**Source readiness FAIL: C01 retains one concrete numeric-type blocker.**
Independent Sol 6.1 High review of clean `1716673d`, correction diff from
`e2d9db9c`, [freeze](p08-integrated-cycle1-source-freeze.md),
[manifest](p08-integrated-cycle1-source-manifest.json),
[qualification](p08-integrated-cycle1-applicability.json) and
[cause handoff](p08-integrated-cycle1-diagnosis.md). Accepted ADR-039 and approved
S11/S13/S15 plus SPEC-011 execution ordering remain authority. No compiler,
build, probe, driver/runtime, formatter, source fix or subagent in this review.
This is source assessment, not compiler acceptance or full conformance/fit proof.

## Remaining blocker

`CounterScopedStorage.swift:909` declares `renderBytes: UInt64` using
`renderInline + d.g4.pointee.reservedPayloadBytes`. The first operand is UInt64;
`DynamicRenderWorkspace.reservedPayloadBytes` is **Int** at
`Sources/GiftUIRuntimeDynamic/DynamicRenderWorkspace.swift:49–53`. Swift has no
implicit widening conversion for these operands. Splitting the original sizing
expression did not correct this numeric mismatch.

Convert the bounded nonnegative payload byte count explicitly to UInt64 before
adding it to the UInt64 inline charge, preserving the exact existing sum and
arithmetic/resource duties. No compiler/platform/limit change is necessary.
The other new sizing terms use matching UInt64 payload properties. C01 remains
open; no affected counter rerun has happened at this freeze.

## Corrected source dispositions

| Item | Independent disposition; execution remains unproved |
| --- | --- |
| C02 | Corrected source API/lifetime shape at `CounterScopedStorage.swift:1701–1727`: five separate original inline fields are each held by a typed pointer scope, their initialized mutableSpan and nested buffer visitor. Pinned Swift 6.4 InlineArray interface at 13599–13629 ties mutableSpan to the mutating field borrow. No backing copy, owned array or aggregate projection replaces the field scopes; all pointers/spans remain enclosing the body. Compiler lifetime enforcement, address stability, physical exclusivity and helper-frame cost remain evidence duties. |
| C03 | Five local `current = stage.take()!` bindings at 1773,1785,1797,1812,1834 are consumed once into the corresponding switch. Existing complete method lifetime unions, structured holder cleanup, Optional transfers and one stage owner remain. No computed-expression consume survives in these paths. |
| C04 | Both observation conformances at 1445–1459 explicitly preserve G/C/R/H protocol requirements, `~Copyable & ~Escapable` and identity equalities. No scoped access is made Copyable/Escapable. Intended generic acceptance/negative diagnostics remain unexecuted. |
| C05 | `CounterDynamicHostProbe.swift:2` imports the actual P08CounterSchema. Its model/schema signatures and six rejected-outcome assertions are preserved. The prior missing-name root cause is corrected by source; later compiler diagnostics may still appear. |
| B01 | Corrected source execution path at `CounterPipelineOwner.swift:286–307,347–350,355–387` and `CounterScopedStorage.swift:1599–1614`. Original-origin guard precedes gate/controller access. A real admitted down runs through the host with input1/action0 and zero model/dispatch effect. Delivery requires that live capture equal the retained original, then assigns **that original value** into the existing pointer capture; real admitted up seals it. Existing apply transitions to `.mutating`, orders state/completion before dispatch and uses the unchanged bridge. Corpus correlates exact sealed/dispatched capture, phase and cycle to the up summary, input1/action1, exactly one applied/dispatch increment, cleared capture, actual model2 and the independent semantic/pixel oracle. No idle bridge call, context patch, substituted envelope, scoped capability getter, second dirty flag or second pending transaction owner remains. |
| O01 | Corrected at `CounterScopedStorage.swift:1510–1518,1538–1543`: fingerprint includes all five application counters plus owned seal/dispatch/context/count observations. Stale prepare/delivery at 1564–1567 and the original stale input/admission/application batch compare full fingerprint and actual model value before labels. Existing actual admission/application immutable guards remain. |
| Observation instrumentation | Control fields `CounterPipelineOwner.swift:61–69` are owned facts recorded only by actual successful seal/dispatch; actual admission does not read them as pending work. Dispatch instrumentation asserts `.mutating` and matching sealed capture. Fresh reconstructed control asserts empty observations at `CounterScopedStorage.swift:1476`. These fields and extra current-twin summaries/borrow helpers enter existing concrete layout/family24 accounting; target layout/nested stack/IRQ/allocator proof remains open. |

The B01 mechanism preserves original producer and capture identity, performs all
ordinary current sequence/revision/gesture/bridge checks, and rejects stale origin
before any current effect. It is productive correction of the actual ordering
defect, not merely a different oracle. No additional bounded source blocker was
found beyond C01.

## Receipt qualification and checks

The driver qualification at `check-spec-015-counter.py:33–56` is restricted to
CounterScopedStorage.swift, exact original receipt path/hash, original and corrected
source hashes and the pinned complete recorded Swift-path list hash. The source
must be absent from that list. All other input/artifact/compiler/macro and recipe
verification remains; the historical r06 fallback is unchanged. New counter
receipts explicitly record qualification use and `original_manifest_current=False`.
The driver directly consumes the pinned SPEC-013 and scoped-host receipts; the
SPEC-011 entry records the separately reusable successful component evidence.
No predecessor receipt was rewritten and no unknown mismatch is waived.

Read-only verification confirms the nine source hashes, qualification hash and
all three pinned receipt hashes; in each receipt CounterScopedStorage.swift is
the **only** current input mismatch and is absent from recorded Swift paths.
Their component execution inputs remain unchanged. Exact recorded path counts
are **112/173/53**, matching qualification/driver. The freeze prose's 110/171/52
counts are inaccurate; correct that prose in the next record without rewriting
this frozen qualification. The list conservatively includes every `.swift` argv
token, including generated/output paths, rather than only input arguments.
Driver AST parses without invocation; 26 route labels remain unique/unchanged,
384/202 compiler labels and five Native exclusivity controls remain registered.
Whitespace and this review's local link checks pass.

## Progress and next bounded action

Classify cycle 1 as **productive source progress and cause narrowing**: C02–C05,
B01 and O01 have concrete source corrections; C01 is narrowed to an exact
UInt64/Int mismatch. This is not a measured compiler-success classification or
a second consecutive unproductive correction. Current cycle **1/2 consumed**;
initial cells **4 consumed, 3 passed/1 failed**, corrective counter rerun **0**,
images **0**. Parent owns subsequent execution, cycle and cumulative guard records.

Readiness for a qualifying rerun requires correcting C01 and independently
assessing the resulting freeze. Parent has indicated it may instead use cycle
1's single already-budgeted affected counter rerun **diagnostically** on this
frozen source, recording that sequencing before invocation. The original compiler
reported several independent frontend errors in one invocation, so useful
additional typechecking diagnostics are possible. The known C01 failure can
still suppress later ownership/code-generation and runtime checks; no such
coverage is promised. Such a run is not source-readiness approval or closure of
C01, and adds no probe/variant/cell/allowance. Preserve its exact failure before
any cycle 2 source work; do not rerun unchanged successful dependency cells solely
for their noncompiled applicability hash.

All nine SO criteria, HC-RD-003/P08/R07/T8.1, actual fit, the historical 58,648-byte
failure and unchanged 27,648-byte main-stack ceiling remain open. I4-07/P09–12,
hardware/timing and lifecycle transitions stay separate. No new optional deferred
idea or upstream contract decision was found; C01 is current required correctness.
Only this review document changes in the separate review commit; parent maintains
subsequent navigation and execution records.
