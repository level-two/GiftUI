# Final corrective2 design — concrete ABI dependency completion

**Independent design PASS; source/compiler unexecuted.** The
[review](../p08-grouped-module-closure-corrective2-independent-design-review.md)
passes the 21 ABI annotations plus the previously approved default completion below. Initial1/1 and
corrective1/2 are consumed. This is the last permitted corrective cycle; it starts
at its first source edit, not this read-only amendment. [Corrective1 result](../grouped-module-closure-corrective1-result/README.md)
retains lower+15 PASS, Layout FAIL36, nine blocked owners and all302 frozen inputs.
The source remains `b46a8239`. [Exact map](candidate-map.json): **21 declarations
in13 files**, four arithmetic ABI entries, one directly used property and sixteen
signature nominals. The separate one-site default completion below makes the
total boundary **22 edits in14 files**. There are no new serialized bodies,
access/body changes, no-op edits or flag changes; the sole parameter-default change
completes an already approved initializer guard. This extends only the previously reviewed
six-root/caller dependency mechanism, not the144-nominal lexical inventory.

## Diagnosed arithmetic and direct blocked-owner dependencies

- Add only `@usableFromInline` to package `GeometryArithmetic` and its existing
  `add`/`subtract`/`multiply` methods in GiftUI.swift. All18 failing LayoutEngine
  expressions (15 add,2 subtract,1 multiply) require the enum and called method,
  accounting for all36 errors. These nongeneric checked arithmetic helpers remain
  ordinary ABI-callable methods, with overflow checks and Optional results intact.
  No `@inlinable` or opacity guarantee is selected: actual physical/callee codegen
  must still inspect any compiler-selected serialization and ordinary call.
- The serialized checked `SignalAnalyzerPresetHostInstance.init` assigns
  `self.assemblyReport`. Add only `@usableFromInline` to that existing package let.
  Its `HostAssemblyReport` type and accessed `kind` getter are already qualified.
- Already qualified `SignalAnalyzerPresetLiveOwner` gives its existing
  `runOpportunity` requirement ABI formal scope. Its result requires `RunCycleResult`
  and concrete `RuntimeOwnerFailure`. `RunCycleResult` cases require
  `RunCycleSummary`, `ExecutionOperational`, `RunCycleFailure`; the latter's cases
  require `ExecutionError`, `RenderProductionError`, `FrameOfferFailure` and
  `FrameRefusalOrigin`. These are nominal-only ABI edits. No RunCycleSummary field
  or constructor is accessed by these roots; none is added to the allowlist.
- Already qualified macOS activation-failure enums give their cases ABI formal
  scope. Their payloads require `RuntimeOwnerFailure` (shared above),
  `RasterBackendError`, `DisplayTargetError`, `HostConfigurationError` and
  `HostWakePacingError`. HostConfigurationError's cases require `HostComponentRole`,
  `RuntimeProfileValidationError` and `TextResourceValidationError`.
  `RasterPresentationUnavailable` is already public. RuntimeOwnerFailure's five
  payloads are already qualified (`SemanticExpansionError`, `LayoutError`,
  `ObservableStateError`, `InteractionError`, `DrawingProductionError`). No payload
  field/value/case change or additional failure type follows.

[Matched compiler rule and hashes](compiler-access-rule.json) pin the same
Swift6.4 release commit used previously: Decl.cpp5180–5223 makes an ABI enum's
cases and an ABI protocol's requirements usable from inline; TypeCheckAccess.cpp
151–159 and1933–1952 check those declarations and associated-value types. This is
an exact signature closure, not an assumption that nominal qualification promotes
all members. In particular, ordinary nonfrozen struct fields are excluded unless
directly referenced by the selected serialized body. The fresh compile remains
the material legality gate; this inspection does not predict a PASS.

## Previously approved constructor-default completion

The [one-site amendment](constructor-default-amendment.json) restores only
`value: Payload? = nil` in the existing internal CanvasStagedEntry initializer.
Frozen `b89c4fac` has an optional mutable value property and no custom entry
initializer. Swift's [documented optional initialization and memberwise rules](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/initialization/)
establish the original nil default; [SE-0242](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0242-default-values-memberwise.md)
records default memberwise synthesis implemented in Swift5.1. Corrective1 preserved
invoked=false but omitted this explicitly approved value default. Restore it in
this same final cycle, retaining access, ownership, assignments and all lifetime
tokens. No new constructor or public capability is introduced; no other default
or signature change is included. Original map/freeze snapshots remain unchanged.

## Blocked-entry inspection and excluded edits

The map records all28 originally selected serialized entries in the blocked
Drawing/RuntimeCore/HostConfiguration owners; CanvasStagedEntry's new equivalent
initializer was also inspected. Direct body dependencies were checked as groups:

| Selected body group | Required direct entries and current disposition |
| --- | --- |
| Canvas lender/metadata/entry/scope constructors and count/identity/stage/invoke/release/discard | CanvasValueTable + StaticCanvasCallableTable requirements, StaticCanvasLimits accessed fields, metadata count/releases, entry identity/witness/value/invoked and scope state/entries/capacity are already qualified. Standard pointer/Span/Optional operations and assignments stay unchanged. Only the approved entry value=nil default completion above is added. |
| CanvasPlanProducer derive/validateOccurrences/fail | Existing qualified CanvasInvocationSource, ResolvedRenderLayoutView, DrawingPlanConstructionWorkspace/Workspace requirements, ExecutionContext cycle/candidateFrame/phase, DrawingLimits.maximumCanvasOccurrences, result/error cases and ordinary productionError helper supply the direct boundary. No edit. |
| ObservableCanvasInvocationSource.invokeCanvas | Existing qualified stored models/values/table, ObservableModelScope.withRead, CanvasStagedValues.invoke and DrawingError(accessFailure:) supply the boundary; domain/slot/read and original State realization are unchanged. No edit. |
| RuntimeRecordInteractionBridge.dispatch | Existing qualified CapturedAction identity/generation, BoundActionRecord identity/generation/isEnabled/action/targetGeneration, BoundedApplicationAction.code, GiftUIAction protocol, target currentGeneration/mutate and dispatch/error result cases supply the direct boundary. No edit. |
| Host progress/controller activate/teardown/record/contain | Existing qualified owner protocols/requirements, lifecycle/progress/result types and named fields/helpers supply the direct body boundary. Default progress constructor already serialized. No edit. |
| Host instance checked constructor/activate/teardown and two macOS factories | assemblyReport property and exact signature closure above are the only newly selected entries. Existing controller constructors and fields, owner/controller/invariantFailure, kind validation, Optional factories and consume/lifetime paths stay unchanged. |

The one current warning for `LayoutEngine.failure`'s internal setter is preserved
as a warning under the pinned policy, not claimed as an error or repaired by
package setter widening. The analogous eight named restricted setter properties
across Layout/Canvas/controller/instance retain their current access. No future
language-mode policy change is authorized. Runtime whole-directory legacy files,
Pi/nRF factories, unrelated getters, counters, field types and checked constructors
remain outside this amendment. All302 source/tool/recipe/protected hashes verify
in [read-only freeze](source-freeze.json); no compiler or source mutation occurred.

## Implementation and gates after independent PASS

Apply exactly21 added `@usableFromInline` lines plus the one frozen entry-default
completion; every other declaration/access/signature/body/default/lifetime token
remains identical. Format only14 allowlisted files,
audit token deltas and unchanged constructor/protected hashes, then freeze source
and a new isolated command receipt before execution. Changing GiftUI invalidates
the entire registered DAG: freshly rebuild all25 owners sequentially using the
same pinned argv/environment and canonical8 Static/13 Dynamic inputs. Collect all
independently runnable failures, block dependents without stale modules, never
edit/retry mid-sweep. Reuse only exact unchanged accepted macro identity and verify
fresh generated bytes. After any material failure, freeze; no automatic third
correction or successor activity.

Complete compile PASS precedes the existing applicable normal-import privacy
positive/isolated negative controls and lifetime/14-loan/Optional/failure/cleanup
controls, then physical six bodies/all42 origins/callee/concrete CounterPipelineOwner
SIL/object specialization and observer attribution. Only complete safety/codegen
PASS permits unchanged strict host-first cold/reuse. No source visibility, API,
unchecked constructor, pointer getter, authored `_model`, provenance, loan, owner,
algorithm, resource baseline/window, enforcement or compiler-policy change is
allowed. The precise normative privacy exceptions/authority and test requirements
remain those in the [reviewed corrective1 design](../grouped-module-closure-corrective1-design/README.md#authority-and-forbidden-boundary).
Metadata/observer attribution and key-failure first-use costs remain unresolved.
P08/R07/T8.1 and the combined candidate remain unaccepted.
