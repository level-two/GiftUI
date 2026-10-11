# P07 construction checkpoint review — 2026-10-11

**Result: FAIL — one required construction fix (C1).** This is the independent
Strong construction review of clean `ac6f2886`, including `dce120da`, `d3b0dc24`,
`129a952e` and `b31ce354`. It is not P07 exit or full Specification conformance.
No implementation or contract was changed. The resumed repair guard remains
**0/2**; review neither consumes a repair attempt nor resets the historical 2/2.

## Authority and scope

Applied the conformance-reviewer skill to the explicitly bounded checkpoint.
SPEC-013 T11.1 and necessary SPEC-009 T9.1 remain implementing, under accepted
ADR-035/036/037, approved RFC-014 amendments and the approved concrete-binding
correction. ITERATION-003 I3-04/05 requires actual analyzer/counter runtime
construction; closed ITERATION-001 supplies stack and analyzer regressions.
The feature manifest and lifecycle/iteration/documentation rules were consulted.
The [explicit consuming-owner authorization](consuming-owner-resumption.md) and
[step-5 progress](progress.md) govern this review. Earlier stops are historical.
No status, manifest, contract, or full conformance-report transition is made.

## C1 — accepted configured limits are not bound into actual execution

**Blocking, both profiles.** The factory can successfully audit a smaller
configured limit, then construct and run owners using the fixture's larger
constants. This violates SPEC-013's immutable configured-limit binding and
no-growth-past-configured-limits requirements (Limits, ownership and storage;
Construction and validation), independent of the later P07 lifecycle cases.

A focused client of the unchanged step-5 modules constructs each actual factory
with `cycleProfileLimits(profile, pathPoints: 1)`. Its audit succeeds and retains
`maximumLivePathPoints == 1`. Nevertheless, `run()` completes the full successful
fixture, whose [Canvas](../../RuntimeDerived/Cycle.swift) lines 9–10 executes
`move` followed by `addLine`, requiring two live points. Results:

```text
Static audited path point limit=1
Static run checks=129 applied mutations=3
Dynamic audited path point limit=1
Dynamic run checks=128 applied mutations=3
```

The source cause is concrete:

- [CycleProfileStorage.swift](../../RuntimeDerived/CycleProfileStorage.swift),
  lines 265–269 and 339–343: incoming limits are retained and audited, while
  focused stores are assembled with constant semantic/model/Interaction bounds.
- [CycleGeometry.swift](../../RuntimeDerived/CycleGeometry.swift), lines 53,
  58–59 and 109–110: the actual Drawing owner and `CanvasPlanProducer.derive`
  use `cycleDrawingLimits`, whose path bound is 202, instead of the audited
  configured Drawing limits.
- The same wiring pattern exists for admission in
  [CycleCoordinatorProbe.swift](../../RuntimeDerived/CycleCoordinatorProbe.swift)
  line 98 and [CyclePipelineOwner.swift](../../RuntimeDerived/CyclePipelineOwner.swift)
  line 133, semantic expansion at lines 174–175 and Interaction at line 223.
  Those are source observations of this one binding defect, not additional
  claims of independently reproduced failures.

**Smallest coherent fix:** retain physical capacities separately, and pass the
validated configured limits into the actual coordinator and focused runtime
operations. Ensure every accepted configurable axis is enforced; do not replace
its audit value with the larger capacity. Add a focused executable control using
a valid smaller limit that the workload actually exceeds (one path point versus
the two-point Canvas), and an adequate-limit success control on both profiles.
An audit-only below/equal/above test cannot establish this relationship. No
architecture or Specification amendment is needed.

## Other construction checks

| Check | Bounded result and evidence |
| --- | --- |
| Actual RuntimeProfileStorage and common coordinator | Pass for default composition: typed factories own the measured stores; the lexical path supplies their audit to the common conformance. C1 blocks claiming the same guarantee for every accepted custom configuration. |
| Owner/schema/domain/mutation join | Default composition binds concrete model/root scopes and finite CycleAction/CycleHandler checked writes. Foreign actual model owner rejects before client stages; four type mismatch negatives are present and pass in the receipt. Remaining stale-target/exactly-once lifecycle coverage stays with P07. |
| All 26 physical byte families | Pass at the native backing-audit boundary: independently summed every descriptor and field; Static 50 regions / 67,662 bytes, Dynamic 75 / 165,401 bytes. Each descriptor satisfies nonnegative count, size/stride/alignment and charged-extent bounds. Source partitions account for matching scratch, model/pins/root, semantic metadata/padding, identity-bearing Interaction records, admission, controller, result and factory/coordinator residuals. |
| Dynamic rounding and exclusions | Retained Array capacities include whole-element tails; bank zero uses the configured physical prefix and bank one the remaining retained elements. Recording endpoint/sink and fault/transcript fields are excluded while CycleRuntimeControl is included. Allocator headers and class-object inter-field alignment remain separately identified later costs. These totals are not full heap/image/stack measurements. |
| Consuming transfer and COW risk | Geometry/Interaction leave their factory transfer slots with `Optional.take`, enter the consuming owner, and return only after coordinator quiescence. Audits borrow backing and do not retain an observer Array. No retained second mutable owner was found in this path. Extent equality is not allocator/address-identity evidence or a claim of zero Dynamic allocation. |
| Static descriptor lifetime | Returned raw workspace descriptors are reset and destroyed inside all four nested raw-buffer callbacks. UInt8 backing uses byte codecs with alignment 1; typed descriptor values have separately reported alignment. No escaped raw descriptor was found. |
| Attempt reset | Active-owner reset checks preserve the published semantic reference, live root identity, committed Interaction routing and late pending fact while clearing candidate/Canvas work. Factory reset methods operate at the preuse/postquiescent boundary, after scoped semantic/root/Canvas teardown. |
| Whole reset | Preuse and postquiescent reset/re-audit controls pass, preserving retained extents while clearing Interaction and admission storage. Consuming returned-owner escape/use-after-consume negatives remain enforced. |
| Capacity/profile rejection | Existing eight-axis below/equal/above audit checks and wrong-profile/foreign-owner controls reject before client stages. Their passing capacity comparisons do not cover the operational enforcement defect C1. |

## Reproducibility and validation

The [step-5 receipt](resumption-step-5-macos-static.json) records 685 assertions,
zero failures and twelve expected compiler negatives. Independently verified all
165 input hashes, 142 artifact hashes, compiler hash and core-receipt hash against
the current files. The receipt truthfully identifies a dirty `dce120da` build;
its input hashes match reviewed `ac6f2886`, so commit-label differences do not
invalidate the evidence. The fresh directory is
`.build/contracts/spec-013-runtime-cycle/tmpjj61jlwe/macos-static`.
The [descriptor copy](construction-storage-regions.json) exactly matches the
receipt's storage reports, and independently checked sums match all 26 fields.
No broad gate rerun was needed. The supplemental probe compiled and linked only
against those verified unchanged modules with the receipt's pinned command,
then executed locally with exit 0. It does not represent a fresh module build.

To reproduce C1, save the following as `/tmp/p07-construction-review/LimitProbe.swift`:

```swift
import GiftUIObservableState
import GiftUISemanticCore
import GiftUIRuntimeCore
@testable import RuntimeCycleProbe
@main struct LimitProbe {
 static func main() throws {
  var m = ObservableModelOwnerNamespace()
  var s = SemanticRecordOwnerNamespace()
  var storage = StaticCycleProfileStorage(modelOwner: try m.issue(), semanticOwner: try s.issue(), limits: cycleProfileLimits(.static, pathPoints: 1))
  guard case .valid(let audit) = storage.audit() else { fatalError("unexpected audit rejection") }
  print("Static audited path point limit=\(audit.limits.drawing.maximumLivePathPoints)")
  print("Static run checks=\(storage.run()) applied mutations=\(storage.control.applied)")
  var dynamic = DynamicCycleProfileStorage(modelOwner: try m.issue(), semanticOwner: try s.issue(), limits: cycleProfileLimits(.dynamic, pathPoints: 1))
  guard case .valid(let dynamicAudit) = dynamic.audit() else { fatalError("unexpected Dynamic audit rejection") }
  print("Dynamic audited path point limit=\(dynamicAudit.limits.drawing.maximumLivePathPoints)")
  print("Dynamic run checks=\(dynamic.run()) applied mutations=\(dynamic.control.applied)")
 }
}
```

Reuse the receipt's link command while changing only the client source and
executable output:

```python
import json, pathlib, shlex, subprocess
receipt = json.loads(pathlib.Path(
    "Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/"
    "resumption-step-5-macos-static.json").read_text())
command = next(shlex.split(c) for c in receipt["commands"]
               if " -o " in c and c.endswith("/runtime-cycle"))
command = ["/tmp/p07-construction-review/LimitProbe.swift"
           if p.endswith("/Main.swift") else p for p in command]
command[-1] = "/tmp/p07-construction-review/limit-probe"
subprocess.run(command, check=True)
subprocess.run([command[-1]], check=True)
```

An initial reviewer-only probe used a zero state-fact limit, which is invalid by
ExecutionLimits construction and trapped; it supplied no finding. Replacing it
with the valid one-point Drawing configuration above isolated the actual defect.
No maintained code was modified by either probe and neither was a repair attempt.

## Remaining boundary

Repair C1 and obtain bounded re-review before claiming this construction
checkpoint passed. Lifecycle/differential transcripts, malformed Drawing rollback,
four final fresh routes, traceability and independent Strong P07 exit review
remain explicitly pending. Their absence is not an additional finding in this
construction review. Full RP-RD-001–004/RP-002, full resources and Specification
transition remain open. No connected hardware, compiler upgrade, P08 or later
package action occurred. No new out-of-scope idea or deferred artifact was needed.


## C1 bounded re-review — 2026-10-11

**Current construction checkpoint: PASS at `c39fa0fd`; C1 resolved.** The initial
FAIL above remains the historical result for `ac6f2886`. This re-review covers
C1 and the changed construction, lifetime and backing-accounting surfaces only.
There is no remaining construction blocker identified in this bounded review.
P07 exit and full Specification conformance remain pending. The shared repair
guard remains **0/2**; this review does not reset it.

The [correction record](construction-c1-correction.md) is supported by source
inspection, not just the original probe's changed outcome:

- `CyclePipelineOwner` retains `audit.limits`; concrete coordinator assembly
  checks equality and gives admission the same ExecutionLimits. Sealing,
  semantic expansion, Layout, Interaction, Drawing and Render use the retained
  configured fields rather than the old fixture operation constants.
- The semantic factories pass configured record/path/depth/fanout/payload-byte
  budgets separately from physical capacity. `withSemanticRecordStore` slices
  its two disjoint banks using the original physical counts, then lends a store
  with configured limits. Smaller accepted limits cannot move the second bank
  into the first bank's retained extent.
- Model adapters bind configured model/claim/pin bounds into the ownership
  ledger; their audit reports the actual fixed two-model/four-claim/two-pin
  backing. Oversized requested bounds remain rejected by the factory audit
  before activation. Observable root limits reach location, registration and
  association checks. Canvas occurrence bounds and Static table/capture bounds,
  and Interaction per-key/per-bank budgets, reach their actual focused owners.
- Both Drawing implementations separate physical capacity from configured
  live-path/plan limits. Point, subpath and plan writes check configured bounds;
  fixed Static byte offsets still use physical capacity. Line width remains an
  operational bound rather than an allocation dimension.
- The Render adapter exposes the configured structural capacity while borrowing
  the actual workspace after physical coverage validation. Preflight/production
  receive configured Render/sink limits, and preflight checks the ordinary
  operation budget separately from normalized strokes. Its raw pointer is
  constructed and consumed in one callback returning only RenderProductionResult;
  it is not retained in an owner or returned descriptor.

The consuming geometry/Interaction transfer, nested Static raw-buffer callbacks,
semantic/root/Canvas lifetime teardown, and postquiescent reset boundary remain
intact. The failure branch releases candidate state, consumes the coordinator
only after quiescence, and returns the same owned workspaces. No new retained
observer bank, second mutable owner, lifetime suppression, or escaping pointer
was found in the changed construction path.

Independently re-linked and executed the exact original LimitProbe from this
report against the unchanged fresh step-6 modules. Both now audit a one-point
configuration and return after failure with zero mutations:

```text
Static audited path point limit=1
Static run checks=11 applied mutations=0
Dynamic audited path point limit=1
Dynamic run checks=10 applied mutations=0
```

The maintained regression additionally checks the exact
`focusedOwner(drawing(capacityExhausted))` failure at Canvas invocation, zero
streams/commits and cleanup/quiescence. Adequate two-point live-path and plan
configurations run the full successful fixture with three mutations. The
[21-configuration-per-profile matrix](construction-c1-configured-limits.txt)
executes semantic, Layout, Render and identity-capacity failures and adequate
model/observable/Interaction/admission configurations. Source review confirms
remaining scalar fields are forwarded to the focused algorithms; this is not a
claim that every scalar combination has independent executable coverage.

Verified all **165 input hashes**, **142 artifact hashes**, compiler hash and
core-receipt hash in [step 6](resumption-step-6-macos-static.json). Its fresh
native directory is
`.build/contracts/spec-013-runtime-cycle/tmpl44e4dw4/macos-static`;
it records **2,752 assertions, zero failures and 12 compiler negatives**.
The [new descriptor report](construction-c1-storage-regions.json) exactly matches
the receipt. Independently checked descriptor extent bounds and all 26 field
sums: **Static 50 regions / 67,814 bytes; Dynamic 75 / 165,551 bytes**. Added
configured-limit metadata is included through the actual root/Interaction/
Drawing/coordinator layouts and residual partitions. Physical buffers and
whole-element tail ownership remain separate. These are native backing totals,
not allocator, full heap, stack, image or hardware measurements.

No broad gate was rerun and no implementation was edited during this review.
Governance validation and `git diff --check` pass. The original outstanding
lifecycle/transcript, Drawing rollback, four-route and independent P07 exit
obligations remain unchanged; no status or manifest transition is authorized
by this checkpoint result.
