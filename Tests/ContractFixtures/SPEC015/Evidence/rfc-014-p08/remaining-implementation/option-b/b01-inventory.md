# P08-B01 — actual construction, activation and operation inventory

2026-10-12. Entry source `b3052c6bad5ee630afd3869dbfbdb39ea3265773`.
Strong `gpt-6.1-sol`, high; sequential execution, no delegation. The only entry
diff was the parent-authored B01 dispatch in `../../progress.md`; it is included
in this step's commit. Implementation-executor applies. B01 changes evidence
only: no source edits, compiler/version/macro/executable invocation, build,
formatter or repository gate. Historical repair **2/2 remains closed**; B03's
native allowance remains **0/1, unused**.

## Authority and applicability

Read root AGENTS, implementation-executor, FEATURE_LIFECYCLE, AI_AGENT_RULES,
DOCUMENTATION_RULES, IMPLEMENTATION_DOCUMENTATION, ITERATION_SCOPES, CODE_STYLE,
VISION, PRINCIPLES, iteration scopes 001 and 003, feature manifest, the shared
RFC-014 plan/task context and SPEC-015 owner checkpoint. The feature is in
implementation; SPEC-015 is `implementing`, its plan `active`, T8.1/P08 open.
Accepted ADR-007/008/036/038 and implementing SPEC-009/015 govern this trace.
The approved RFC-014 construction amendment and current user dispatch authorize
this separate implementation activity, superseding only the earlier activity's
documentation-only limit. They do not reset an attempt ledger.

MVP's reference requirement is the shared interactive, observable, text/Canvas
application across desktop, Pi and Embedded stacks. Current work is the
post-MVP ITERATION-003 I3-04/05 delivery, specifically IT-AC-004/006/008:
the isolated finite counter is permitted, but must preserve owner direction,
semantics and bounded lifetime/resource evidence on the actual compositions.
This step establishes inventory, not that delivery or any acceptance criterion.

Exact controlling clauses are SPEC-015 `HostComponentGraphView` construction
contract (lines 810–846), `Activation`, `Opportunity and pacing`, required tests
and HC-003/011/014/018; SPEC-009 `Wake requests and pending presentation`; and
ADR-038 `Decision`. The historical operation-inclusive trace under
`../step-7g-graph-stop/bounded-continuation-trace.md` is evidence of the former
interpretation, not authority for the following classification.

Unless prefixed `Sources/`, source names below are relative to
`Tests/ContractFixtures/SPEC015/RuntimeDerived/`. Exact inspected source hashes
are in [b01-source-identities.json](b01-source-identities.json).

## Actual eighteen selected roles — both native profile compositions

Masks below are proposed B02 masks, derived from the named input trace. They
are not a validation of the existing table. A zero mask means no input from
another fixed role; it does not waive backing, activation or operation duties.
All masks are UInt32 and each set bit denotes its role raw value.

| Role | Actual selected constructor/factory and mandatory input origins | Activation / operation / backing disposition | Proposed mask |
| --- | --- | --- | --- |
| 0 runtimeProfile | `StaticCounterProfileStorage.init(modelOwner:semanticOwner:limits:)` / `DynamicCounterProfileStorage.init(...)`, CounterProfileStorage.swift:255–410. Explicit host-issued owner identities, scalar limits/schema/constants, typed root/model, semantic, Canvas, geometry, Interaction and control backing. | Supplied before validation; `audit()` describes backing, including endpoint/coordinator type sizes, without constructing a live endpoint/coordinator. Static arrays and Dynamic retained extents are accounted separately. Host-issued namespace identities and limits are host inputs, not hidden peer-role owners. | `0x00000` (0) |
| 1 textResourcePackage | `GiftUIReferenceTextResources.targetPackage`, `GiftUIReferenceTextMetricsView()` / `GiftUIReferenceTextRasterView()`. Immutable compiled package and views; no peer input. | Pure validation selects realization0; native endpoint stores the two views and native raster operations use the same package. Package storage is immutable compiled storage, outliving both hosts. | `0x00000` (0) |
| 2 renderProducerContribution | CounterHostAssembly.validate, `.renderProducer(operations:operationStream:)`, line51. Literal five-operation set and one-shot stream contract. | Inert contribution; used by resolution, endpoint configuration and report. No live pipeline constructor here. | `0x00000` (0) |
| 3 rasterBackendContribution | Same function, `.rasterBackend(primary:realization, alternate:nil)`, line52. Literal full-surface realization, extent/encoding/alignment/byte bounds. | Inert contribution; derived configuration retains this origin even when copied through an effective value/report. | `0x00000` (0) |
| 4 surfaceDisplayContribution | Same function, `.surfaceDisplay(...)`, line53. Literal extent/encoding/synchronous lifetime/handoff, region/in-flight limits. | Inert contribution; native target gets the derived endpoint configuration. This role is the contribution, not the later native display target. | `0x00000` (0) |
| 5 hostResourcePolicyContribution | Same function, `.hostResourcePolicy(...)`, line54. Literal byte ceilings and allowed/preferred realizations/encoding. | Inert contribution; configuration/report origins persist through resolution. | `0x00000` (0) |
| 6 rasterEndpoint | `CounterEndpoint.init(configuration:control:)`, CounterNativeRaster.swift:212; calls `CounterNativeRasterAdapter.init` at146 and `CounterNativeEndpoint.init` at232. Required control pointer0 supplies actual surface/payload/health backing; stored text views1; exact effective/descriptor/payload/display configuration derives from contributions2–5. | Constructed only in state.activate, after valid assembly. Actual startup projection checks descriptor/capacity/health identity against assembly; no replacement is proposed. Native adapter/target/surface retain control aliases only inside the supplied lexical scope. Embedded placeholder is a separate evidence gap, below. | `0x0003f` (63): 0,1,2,3,4,5 |
| 7 applicationExecutor | `CounterApplicationOwners.gate = HostApplicationOpportunityGate()`, CounterApplication.swift:59. No peer constructor input. | This gate is the actual sole serialization state: `begin/complete/quiesce` surrounds `startSource`. The enclosing `CounterApplicationOwners.init(control:)` is a host composition aggregate, not executor7; it also contains roles8–10 and host observation/delivery state. Its control0 pointer is recorded in the composition/lifetime trace, not falsely assigned to the parameterless gate. | `0x00000` (0) |
| 8 signalSource | `CounterFactSource()` default scalar initialization, CounterApplication.swift:8. No peer input or retained callback. | `start(deliver:)`, `service(value:deliver:)`, `stop()` take synchronous UInt8→Bool callbacks only per call. No timer or autonomous source survives the call. Gate7 serializes its operational start. | `0x00000` (0) |
| 9 signalRepository | `CounterFactRepository()` default scalar initialization, CounterApplication.swift:24. No peer input or retained observer closure. | `observe` returns exact token1/current value; `receive(_:notify:)` receives its callback only per call; `detach(token)` ends observation. Source8 is supplied to the use-case operation, not this constructor. | `0x00000` (0) |
| 10 useCaseSet | `CounterFactUseCases()` default scalar initialization, CounterApplication.swift:45. No peer input or bound constructor callback. | `start(source:repository:deliver:)` is an operation-only call, with inout source8/repository9 and a synchronous delivery closure at CounterApplication.swift:81. SPEC-015 lines841–843 explicitly classify this finite call. Neither source/repository nor delivery is retained. | `0x00000` (0) |
| 11 factAdmission | `CounterAdmission.init(control:limits:)`, CounterAdmission.swift:137; creates `SingleSourceExecutionAdmissionState` over `CounterQueuedFacts(control:)`. Pointer, context, initial committed-revision value and execution limits all originate in profile0. `init(borrowing:)` subsequently aliases this exact controller. | Constructed after pipeline wake initialization, before first root attach. Initial committed revision is nil in supplied control, not a constructed root14 input. `submit` synchronizes exact context and only `.queued` calls `emitCounterWake`; admission11→wake16 is an authorized operation, with no retained requester/callback adapter. All raw aliases must remain inside profile0 backing scope. | `0x00001` (1): 0 |
| 12 actionDomain | `CounterAction` enum, Counter.swift:3. No constructor inputs; two compiled cases/codes. | Passed by type and decoded at dispatch. Counter's two-case domain is distinct from the analyzer's six-case domain. | `0x00000` (0) |
| 13 actionHandler | `CounterHandler` owner-free enum / static `operation(_:)`, CounterModel.swift:56–60. No instance, constructor parameter, retained function field, key, ticket or live target. | Proposed interpretation: its action12 argument and `CounterOwnedModel.Mutation` result are operation vocabulary. `CounterPipelineOwner.dispatch`, lines302–305, supplies the function, action type and independently constructed root target at call time. Therefore neither action12 nor live root14 is a construction input to this handler. Historical handler13→12 classified its operation signature; this classification changes under construction-only semantics and requires explicit independent review. | `0x00000` (0) |
| 14 rootModelTarget | Profile0 supplies `ObservableModelScope<CounterOwnedModel,CounterModelSchema>` and `ObservableStateRootScope<...,SemanticCompleteIdentity>`, exact schema/owner/backing and configured limits. Direct and scoped pipeline/binding initializers require `root.belongs(to:models)`. | First candidate creates model/registration; state.attachRoot retains the exact key in an independent ticket cache. Dispatch constructs `ObservableStateRootTargetAccess(root:identity:ordinal:)` operationally. Model declaration/schema/value vocabulary is not a live handler owner input. Cache release precedes root shutdown; backing lasts beyond both. | `0x00001` (1): 0 |
| 15 normalizedInput | `HostNormalizedInputGate(configuredSource: InputSourceID(0))`, CounterPipelineOwner.swift:45; constructor definition Sources/GiftUIHostConfiguration/HostNormalizedInputGate.swift:42. Required literal source ID and default sequence seed; no profile pointer or peer-role input. | Location in `CounterControl` is physical co-location. Physical presentation is installed operationally; `submit(...to: &CounterAdmission)` supplies admission11 only at invocation. SPEC-015 lines841–843 explicitly classifies this finite call. Gate scalar state remains in backing0 until teardown, without creating a constructor edge to0. | `0x00000` (0) |
| 16 wakeRequester | `CounterWake()` and `ExecutionWakeAccumulator(requester:)` in `initializeCounterWake`, CounterWakeIntegration.swift:8–11; the actual host binding also constructs `HostScheduledOpportunityController(assemblyReport:report, initialFrameOriginMicroseconds:0)` at49–63. Required stable profile0 control backing; the scheduler **retains the entire report**, Sources/.../HostScheduledOpportunityController.swift:28–50. | Report storageAudit comes from0 and retained capabilitySnapshot/effectivePresentation derive from2–5 (Sources/.../CheckedMVPHostConfigurationValidator.swift:126–159; HostConfigurationResults.swift:40–56). These are real copied configuration origins despite activation-time installation. Pacing/cardinality/workload fields are explicit host constants/configuration, not source8/repository9/useCase10 live inputs. Text validation leaves no package/view field in the report, so no report-origin edge to1. No retained executor/runtime closure and no second canonical accumulator. | `0x0003d` (61): 0,2,3,4,5 |
| 17 residualPolicy | `FixedMVPHostResidualPolicyTable(fatalHookIsAvailable:false)` in CounterHostAssembly.validate. Literal selection only, no peer constructor input or fatal hook. | Pure accessor validation; actual failure routing remains separately evidenced. | `0x00000` (0) |

The exact proposed ordered mask vector for both actual native profiles is:

```text
role:  0 1 2 3 4 5  6 7 8 9 10 11 12 13 14 15 16 17
mask:  0 0 0 0 0 0 63 0 0 0  0  1  0  0  1  0 61  0
```

Relative to current CounterHostGraph, changes are normalized15 `1→0`, handler13
`4096→0`, wake16 `1→61`. Endpoint63, admission1, root1 and all other zeros stay
as traced. Wake report origins must not be reduced to0 by calling the report
inert. Conversely the entire enclosing application aggregate must not replace
executor7, or its member layout would create spurious forward edges. No actual
required upward construction edge has been identified. Review must independently
confirm the handler and retained-report classifications before adopting masks.

## Enclosing construction, activation and lifetime trace

`StaticCounterProfileStorage.runCounterHost` / Dynamic counterpart validate the
actual audit first, before live owner construction. Nested `root.withLifetime`,
semantic `withLifetime`, Canvas `withLifetime`, Static workspace `withGeometry`
and `withUnsafeMutablePointer(to:&control)` enclose the complete host lifetime.
Dynamic geometry/Interaction are moved into the host; Static descriptors remain
within their borrowed arrays. The one-byte `activationBacking.span` is another
mandatory host input, enclosed by the same host lifetime. It is not supplied by
a peer fixed role and must not be omitted from lifetime proof.

`CounterHostSuppliedStorage` / Dynamic equivalent consume borrowed model/root,
semantic and Canvas scopes, geometry and Interaction plus audit and a scoped
`CounterHostControl`. State `.inert` retains all of them and the activation span.
After validation, activation step1 constructs pipeline/endpoint, execution
binding, admission and concrete Static/Dynamic coordinator; root association is
checked at both binding and pipeline initializers. Step2 constructs the host
application aggregate using the same control pointer; its serialization gate
and source/repository/use-case scalar members have the constructors in the table.
That aggregate's retained pointer is an actual mandatory host composition input
from0. This explicit trace prevents its exclusion from executor7's mask from
hiding the pointer or its lifetime.

Step3 runs the first backpressured candidate, takes the exact root identity/key,
and retains a separate model ticket cache. Step4 installs token1 observation,
admits its current scalar via the coordinator's controller and enables delivery.
Step5 accepts a physical presentation and enables application input; the actual
target-local input gate is installed by committed runtime publication. Step6
starts source8 under gate7: synchronous source→repository→delivery uses the
aggregate's retained control0 pointer to alias the existing admission11. The
closure cannot outlive `startSource`, and its actual nested gate.begin rejects
reentry. Step7 installs the scheduler once with the immutable assembly report,
then checks runtime/application/endpoint projections. The scheduler constructor
is activation wiring **and** construction of retained role16 configuration;
classifying its report as an operation-only argument would hide a real origin.

Host teardown refuses application/input, stops source and detaches token1,
cancels/quiesces runtime, releases the independent cache, shuts down root routing,
takes the quiesced opportunity, releases endpoint/coordinator and application,
resets semantic/geometry/Interaction state, then invalidates runtime use of the
report. `CounterPipelineOwner.terminatePresentation` clears admission/capture,
disables wake and quiesces scheduler/input before root shutdown. Active-cycle
terminal refusal defers scheduler quiescence until completion. Only after host
teardown do enclosing lexical scopes and profile-owned backing end. Raw pointers
in admission/application/endpoint never grant independent lifetime. Existing
counter copy/activationBacking escape negatives and the earlier approved scoped
join supply partial evidence; this step does not replace or rerun them.

## Separate operational binding and required coverage

All canonical state is `CounterControl.wake: ExecutionWakeAccumulator<CounterWake>`;
the recorder itself has no pointer/callback. Admission, runtime dirty/recovery
notifications and scheduled host service refer to the same profile0 control
address. `initializeCounterWake` permits one initialization; role16 scheduler
installation permits one binding. Emission accumulates the three SPEC-009 bits;
each accepted fact records its clock independently of the outstanding bit;
the host projects all accumulated bits into pacing state without emitting
another canonical requester call. Scheduler pending reasons are its existing
pacing state, not an additional canonical runtime accumulator. `counterServiceHost`
ends scheduler/control mutation before calling host.runOpportunity, then completes
the same scheduler. Only actual idle entry takes canonical reasons. Mutation phase
and seal membership prevent a synchronous callback from changing the current seal.

The following inventory reads source and frozen step7f results; **no new test ran**.
“Present” means a current actual-counter control exists; unchanged source/control
behavior needs the later source-specific invocation to regain evidence after B02.
Historical unit/component or P07 controls are supporting evidence, not substitutes
for missing actual-counter binding/lifetime tests.

| Required obligation | Present control / actual path | Gap or exact limit |
| --- | --- | --- |
| Queued-only admission notification; rejected/invalid/unavailable submit has no wake side effect | CounterAdmission.swift `submit` methods guard notification on `.queued`; CounterCoordinatorProbe tests accepted state/completion, duplicate completion capacity refusal, invalid state10, 34-capacity refusal and unavailable after quiesce. CounterHostCorpus rejects physical source/revision/malformed input before queue. | **Missing integrated negative counter assertions** that requester count, canonical reasons/outstanding, host wake count and accepted-fact timestamp/count remain unchanged for each rejected admission class/category. Queue/result assertions alone do not prove this. B02's graph/helper scope cannot silently add these controls. |
| Every accepted fact behind a nonfact wake records its own timestamp | CounterWakeIntegration `counterWakeControls` queues one state fact behind dirty+presentation reasons and checks deadline+1 rejection; pointer down/up and completion injection use the same notification code. | **Missing multiple-fact/category control** behind an already outstanding nonfact wake, checking `acceptedFactWakeRecords` per submission and exact supplied-clock behavior. Existing single-fact control must not be described as exhaustive. |
| One canonical three-reason set and outstanding bit; no synchronous opportunity | `counterWakeControls`: reasons.rawValue7, requester+1, hostWakeRequests+1, finalized unchanged; serviced reasons equal actual idle take; outstanding cleared. | Present for both actual hosts; graph pass alone proves none of it. |
| Accepted cycle-time notification survives take until next seal/opportunity | Actual apply-boundary completion injection; `didDeferAfterSeal`, mutation/active/no nested runtime flags, zero completion in current summary, one next-cycle completion, new requester transition and paced wait. | Present for one completion callback; actual autonomous concurrent producer/hardware evidence remains outside this native control. |
| Exact binding/profile identity and valid backing | Same pointer supplied to binding/pipeline/admission/application; `root.belongs(to:models)` at constructors; report/audit profile checked before owner; scheduler.begin validates exact report equality. | **Missing actual counter mismatch negative** for foreign control/profile/report binding, independently proving rejected notification/service and no owner access. Generic scheduler/report and profile tests are supporting only. No retained adapter is proposed as a repair. |
| Scheduler deadlines, frame pacing, no-work | Actual host startup waits until250000, one cycle then noWork; integrated control waits at boundary−1, services at boundary, copied actual scheduler rejects fact deadline+1. | Present finite cases. Copy used only for destructive negative; no full accepted burst28 / physical32 / reject33 / category excess proof for the finite counter. The coordinator's 34-state probe is not the approved 32-slot production fact test. |
| Backpressure and retryable refusal, no replay | Actual endpoint backpressure count0 then accepted no facts/replay; actual three refusal attempts counts1/2/terminal3, no admitted fact replay, notifications and input disabled. | Present. **Missing actual counter nonretryable-refusal and newer-revision supersession controls**; synthetic HostPresentationRecovery / integrated analyzer fixtures and P07 cases do not close those actual application obligations. |
| Phase, reentry, stopped-producer rejection | `startSource` nested gate.begin rejected; callback observes idle/not frameActive; active apply injection admits next cycle only; stopDelivery tests stopped source, detached repo and unavailable gate; post-teardown admission unavailable and input quiesced. | Present; explicit wake-counter no-change assertions for unavailable submit are still missing as above. |
| Partial activation, illegal-state calls, quiescence and backing-last release | Both actual probes cover complete success, injected failure just after runtime construction, preactive/repeated/postteardown illegal calls, idempotent teardown, cache/root/committed/input cleanup. Copy/backing negatives generated by driver. | **Actual counter failure injection covers step1 only**, not every activation step. Synthetic `HostPresetBootstrapTests` cover the lifecycle controller but not each actual retained counter owner. Escaping activation span negative proves one backing origin, not all model/semantic/Canvas/geometry/control backing expiry origins or actual pointer misuse negatives. |
| Exact construction and origin negatives before later projection | CounterGraphProbe has count17/19, duplicate, out-of-order, nil record, self, upward and unknown-bit modes. | **Missing required-origin/callback-indirection negative**: HostComponentGraphValidation.swift:5–38 checks structure, not consistency with supplied factories. Removing a legal lower dependency (e.g. endpoint text1 or report capability3) still satisfies its structural guards. A new positive mask comparison alone is not proof of rejection of hidden origins before later projection. Needs a concrete reviewed fixture/factory validation realization; B01 does not invent a new protocol or call it passed. |

These are current P08 obligations, not optional deferred work. Deferred-work-
curator's blocker classification applies; no Future Work artifact is used to
postpone a required acceptance proof. Existing FW-009/035 remain unchanged.

## Exact bounded B02 proposal and scope disposition

Proposed source footprint is exactly four current fixture files:

1. `CounterHostOwner.swift`: remove the whole-coordinator borrowing
   `CounterHostState.constructedRuntimeProjectionIsValid()` helper; replace its
   call inside `establishWakeAndPacingHostLoop` with the existing controlPointer
   projection below.
2. `CounterDynamicHostOwner.swift`: the same replacement for its Dynamic state
   helper/call site.
3. `CounterHostAssembly.swift`: adopt the reviewed vector above, with comments
   tied to actual construction inputs/report origins, not retained-field-only
   claims; remove the placement-only normalized0 edge and operation-only handler
   edge. Do not add use-case→source/repository or admission→wake operation edges.
4. `CounterGraphProbe.swift`: directly corresponding graph controls using the
   reviewed eighteen-role vector, preserve all existing structural negatives and
   explicitly identify the newly traced endpoint/report configuration origins.
   Do not represent a structural negative as hidden-origin rejection evidence.

At each activation call site, after establishing the scheduler, the proposed
projection is the following finite boolean from the **existing** state getter:

```swift
let control = state.controlPointer
let runtimeProjection = control.pointee.hasRoot
    && control.pointee.committedRecords == 2
    && control.pointee.admissionController != nil
    && control.pointee.wake != nil
    && control.pointee.scheduler != nil
```

`hasRoot` is copied from `rootIdentity != nil` in finalizePipeline at
CounterPipelineOwner.swift:515–520 after the synchronous candidate/cycle; it
replaces that helper's rootPresent read. Both direct/scoped pipeline and binding
initializers continue checking exact root/model association; `attachRoot` must
still retain the exact independent ticket; quiesce must release it before root
shutdown. The projection intentionally does not borrow the entire coordinator or
inspect its noncopyable Optional cache. Actual application `constructedProjectionIsValid`
and native endpoint construction/projection checks remain at the same boundary.
No unchecked conformance, new pointer getter, callback adapter, wake accumulator,
public protocol, allocator/capacity/compiler change, Option A forwarding or
unrelated refactor is proposed. This is untested until the later single B03 call.

**Review assessment of remaining scope:** the four-file B02 footprint cannot
close the missing operational and factory-origin controls above. The plan
requires these coverage gaps to be recorded before B02; they remain obligations
of the existing remaining-P08 exit. Their existence does not itself create a new
human approval gate. Independent review should determine whether B02/B03 may
proceed under the plan as written, with B03 interpreted only as bounded native
feasibility/current-control evidence. Actual missing behavior or additional edits
needed outside the four-file footprint must be reported before such edits; do
not quietly expand B02 into CounterWakeIntegration, host probe failure matrices
or maintained generic validator/API redesign. If hidden-origin rejection requires
a new ownership/contract choice rather than an implementation fixture, stop for
an upstream decision. No such choice is made here. There is no discovered required
upward construction edge or unresolved supplied-backing lifetime origin; the gaps
above are unproved test obligations, not claimed conformance.

## Pinned dependency identities, without execution

[b01-dependency-identities.json](b01-dependency-identities.json) records **492
matching comparisons**, zero missing/stale non-exempt inputs: the exact current
counter-driver preflight (runtime/host inputs and all their artifacts, compiler,
macro tool, core GiftUI object/module, host compiler equality), reciprocal
runtime/core/host receipt hashes, and the recorded MacroSupport library identity.
Only file reads and SHA-256 ran; even `swiftc --version` was not invoked.
The recorded version is Apple Swift6.4 (`swift-6.4-RELEASE`), target
`arm64-apple-macosx26.0`; existing command flags retain LifetimeDependence/Lifetimes,
Osize and whole-module optimization.

| Dependency | Receipt SHA-256 |
| --- | --- |
| `.build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static/result.json` | `39772d9e2cc7d70f47b82970dd1b89ddd3236274ccbb57cf9c547ce4aeaedf69` |
| `.build/contracts/spec-006-rfc-014-swift64/b694e911d7d7658a-gn53u2vi/macos-static/result.json` | `4345209f3f2d58e86ea2fdf3b45d15ee5d1da00cce275b964e156ba353c88793` |
| `.build/contracts/p08-scoped-host-c5eocina/result.json` | `1fb599d72680ae0d25bfc06201d72437a70a1fc42a98579fc50992da2a921c5a` |
| `.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swiftc` | `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69` |

The driver deliberately excludes four maintained source input identities from
historical receipts because it rebuilds their selected modules in the later
single invocation: SemanticRecordStore, HostScheduledOpportunityController,
ExecutionAdmissionController, RecordingPresentationPendingCoordinator. All four
historical/current hashes and mismatches are recorded separately; they are not
492 passing source comparisons and not permission to rebuild now. No dependency
receipt, toolchain selection or exception list was modified.

Later B03 alone may run the predeclared command after reviewed B02:

```sh
python3 scripts/contracts/check-spec-015-counter.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static
```

Recheck receipts immediately before that attempt. Missing/stale inputs require
handoff, not dependency rebuild, compiler switch or extra invocation. Success
must freeze/commit for separate Strong review; failure has no automatic repair
or rerun. Both native profiles execute inside this driver, whose pinned dependency
route is macos-static; this is not four-route or target-image evidence. Current
Embedded `CounterEndpoint` is a placeholder in CounterPipelineOwner.swift, not
the actual native raster endpoint or a proven linked board composition. Pi/nRF
application routes/early images/resource/ABI and final P08 review remain open.

## Review packet and exit

Independent Strong review should read the source manifest, this inventory,
dependency identity JSON and parent dispatch. Verify every row against actual
constructors; specifically judge handler13 zero, normalized15 zero, wake16
report-origin61 and endpoint63; ensure no host aggregate or indirection conceals
an input. Check the two direct control projection replacements against initializer
association, cache lifetime and physical finalization. Disposition the missing
required coverage before B02. No existing masks, graph WIP, compiler feasibility,
HC criterion, native/target route or P08 exit is passed by this document.

B01 stops after committing this packet for that review. B02 is not started.
