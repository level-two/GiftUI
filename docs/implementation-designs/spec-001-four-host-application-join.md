---
spec: SPEC-001
feature: signal-analyzer
title: Implementation Design — Four-Host Application Join
status: current
authors:
  - codex
created: 2026-09-14
updated: 2026-09-14
implementation_plan: ../implementation-plans/spec-001-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Four-Host Application Join

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specifications.

## Purpose and Boundary

This note explains how each of the four target executables owns the exact
Signal Analyzer object graph while reusing the focused runtime, host,
observable-state, interaction, rendering, and endpoint owners. It fixes the
internal placement of the analyzer-aware fact classifier, typed root-model
storage, action handler, and application-executor adapter so Milestone 6 can be
implemented without moving application knowledge into reusable framework
targets.

SPEC-015 remains authoritative for validation, activation, opportunity,
failure routing, teardown, presets, and platform evidence. This note does not
change a module boundary, public declaration, capacity, preset, lifecycle
transition, failure mapping, resource limit, or connected-hardware requirement.

## Governing Contract

The realization follows SPEC-001 `Target host`, `Observable state and admission
configuration`, `Serialized delivery`, `ViewModel behavior`, and `State /
Lifecycle`; SA-AC-002, SA-AC-028 through SA-AC-040, and SA-AC-045; and plan
tasks T5.1 through T5.5 and T6.2 through T6.5. It also realizes SPEC-015
`Module Contract`, `Construction and validation`, `Activation`, `Opportunity
and pacing`, `Input and action dispatch`, and `Operational state and teardown`;
HC-003, HC-009 through HC-015, and HC-018; and plan tasks T6.1 through T6.4.

ADR-007 places complete-stack knowledge only in a target composition root.
ADR-024 through ADR-026 fix observable ownership, invalidation, and equal
bounded profile behavior. ADR-027 separates synchronous application delivery
from model mutation. ADR-033 places the single typed action handler and the
model-target-generation join at composition.

## Current-Code Context

The portable `SignalAnalyzerView` and its one `State<SignalAnalyzerViewModel>`
declaration are complete. Data, use cases, the Presentation admission adapter,
the six-case handler, and deterministic source are also implemented. The
host target supplies pure preset validation, the exact activation and teardown
controllers, `1/32/1` sequencing, wake/pacing, normalized input, recovery, and
failure routing without importing analyzer modules.

`RuntimeObservableProfileWorkspace` currently provides the production
profile-neutral structural-identity and target-generation algorithm over
dynamic and static slot storage. It deliberately does not consume or own the
`State` initializer; its `encounter` method only records the association.
`DynamicObservableModelStorage` now supplies the first bounded Dynamic-profile
typed storage slice: it binds a transient wrapper to the preserved model and
routes assignment outward for later atomic replacement.
`StaticObservableModelStorage` supplies the matching caller-owned inline typed
value and confines its direct pointer binding to one synchronous traversal
attempt; final address stability remains a generated-root responsibility.
`ObservableStateRegistrationBridge` exposes the existing focused registration
lifecycle to those roots without exposing or duplicating its state machine.
`DynamicObservableModelRegistration` composes the bridge and typed box in one
address-stable Dynamic owner and routes retained model reports back into that
same registration record.
`DynamicObservableRootAdapter` joins this owner to the production profile
workspace. It uses the workspace's publishable generation for attachment and
coordinates candidate discard and published structural removal with exact
registration retirement.
Focused Observable State components separately implement binding, attachment,
atomic replacement, dirty reporting, removal, stale-report rejection, and
shutdown. Existing tests prove those mechanisms independently, but no target
executable yet owns the typed model storage and composes them with the
production workspace.

The generated SPEC-015 preset values and workload manifests are immutable and
fresh. `MVPHostActivationController` already fixes the seven activation calls
and eight teardown calls. `HostPresetBootstrap` prevents instance construction
until validation succeeds and audits exact owner cardinality and endpoint
identity afterward.

## Proposed Internal Organization

Each preset executable owns one concrete root. The roots may share generic,
package-internal helpers, but no reusable target may import an executable or
switch on a platform identity. Each root stores these owners exactly once:

- its immutable generated preset and validated assembly report;
- its selected dynamic or static runtime/profile storage and endpoint stack;
- one application executor, deterministic source, repository, use-case set,
  Presentation admission adapter, and root ViewModel;
- one analyzer-aware endpoint that classifies Presentation facts into the
  host-owned fixed sequencer;
- one typed observable-root adapter joining model storage, focused attachment
  and replacement lifecycles, dirty state, and the runtime profile workspace;
- one immutable six-case `SignalAnalyzerActionHandler` and model-target access;
- one normalized input gate, wake/pacing owner, and total failure-policy owner;
  and
- one `MVPHostActivationController` governing live use of those owners.

The analyzer-aware fact switch remains in the executable layer, not
`GiftUIHostConfiguration` or portable Presentation. The reusable host
sequencer remains payload-generic. Likewise, the action/model join lives in the
root because it is the first layer allowed to know both the finite analyzer
action domain and the focused runtime target-generation view.

The typed observable-root adapter is the missing ownership seam. It combines
existing focused components rather than reproducing their state machines. Its
model storage owns one live `SignalAnalyzerViewModel` and one transient
replacement position. Its metadata owns one structural identity, declaration
ordinal, attachment token, target generation, live bit, dirty bit, candidate
bit, and staged replacement bit. Binding a transient `State` delegates
association and generation decisions to the production profile workspace,
then supplies access to the preserved typed storage. A repeated initializer is
consumed but never installed. Publish/discard and replacement use the focused
lifecycle results to determine which exact attachment is detached.

Dynamic roots use the bounded retained model mechanism permitted by the
Dynamic audit. Static roots consume generated address-stable typed model and
replacement storage. Static generated code contains direct typed access and
change-report dispatch; it does not introduce an existential registry,
reflection, `Any`, dynamic collections, or an escaping closure-to-tag bridge.

## Data and Control Flow

Construction is inert until the nine-stage validator returns one valid report.
The factory then creates the concrete owner aggregate and audits its report,
endpoint, and exact cardinalities. Activation follows the existing controller:

1. construct the selected runtime and endpoint without starting either;
2. construct all application owners and the typed root join;
3. begin the first candidate, bind the root declaration, attach the model, and
   publish the association;
4. install both repository sinks and admit the two immediate facts;
5. publish the first accepted physical presentation and enable input;
6. enter one application opportunity to start acquisition; and
7. arm the host wake/pacing loop without synchronous runtime entry.

Repository callbacks always follow this path:

```text
application executor -> repository sink -> Presentation adapter
  -> executable fact classifier -> bounded host sequencer -> wake record
```

They return before ViewModel mutation. A paced runtime opportunity seals the
stores, applies admitted facts and actions in mutation order, accepts model
change reports into one dirty bit, freezes mutation, derives the complete root,
joins candidate actions with the publishable target generation, publishes one
complete semantic revision, and offers the resulting presentation.

Action dispatch first revalidates the committed action and target generations.
The root adapter then borrows the model for that exact generation and invokes
the immutable handler once. The handler may synchronously enter the application
executor; callbacks generated there stop at fact admission for a later cycle.
Neither action records nor pointer capture retain the handler or model.

Teardown delegates the exact eight ordered calls to the existing controller.
The typed root adapter retires its attachment and routing identity at step five;
profile storage is reset only after runtime quiescence. Retired generations are
never made reusable by resetting storage.

## Algorithms and Data Structures

The root adapter is a bounded aggregate, not another coordinator. It delegates:

- structural encounter and published/publishable target lookup to
  `RuntimeObservableProfileWorkspace`;
- association, attachment, replacement, report, and dirty transitions to the
  focused Observable State owners;
- total fact order and physical storage to `HostSequencedFactAdmission`; and
- cycle, publication, recovery, input, and failure decisions to their existing
  owners.

One checked generation source supplies each attachment/target generation.
Reservation precedes candidate installation. A candidate becomes visible to
action binding only through publishable lookup. Replacement stages the new
model and active registration before retiring the former registration. Failed
candidate derivation discards candidate-only state; failed derivation after a
committed replacement preserves the replacement and dirtiness. Published
absence retires the model; later reinsertion consumes a fresh generation.

All root ledgers are fixed records or bit sets. The dynamic and static roots
run the same ordering and state-transition algorithm. A root never infers a
capacity from available memory and never enlarges a validated bound.

## Lifecycle and State

The host controller owns `valid -> activating -> active -> quiescing ->
quiescent`, with terminal `failed`. Inside an active host, application delivery
and runtime mutation remain distinct logical domains even when they share a
thread. The observable-root adapter additionally tracks candidate inactive /
active, live absent / present, and replacement absent / staged states through
the focused finite transitions.

Only a published candidate changes the live structural set. Discard preserves
the prior live model. Observable change reports are legal only for the current
attachment during mutation; stale reports fail closed, contained phase
violations retain dirtiness and request paced retry, and safety-not-proven
failures enter host containment. Application observation and observable
registration remain independent lifecycles.

## Runtime Profiles and Platforms

| Preset | Profile mechanism | Endpoint realization | Required evidence |
| --- | --- | --- | --- |
| macOS Dynamic | bounded retained typed model and dynamic slots | full surface | executable normalized transcript |
| macOS Static | generated inline typed model, replacement, and slots | same logical extent/full surface | equal transcript and allocation inspection |
| Raspberry Pi 1 | Dynamic semantics and bounded retained storage | 240 x 240, 240 x 16 RGB565 region | ARMv6 cross-build and host-native semantic fixture |
| nRF52840 | generated inline Static storage and direct dispatch | 480 x 320, 480 x 4 RGB565 region | Embedded Swift link/resource/ABI inspection |

The paired macOS roots differ only in permitted profile storage and dispatch
mechanics. Pi and nRF hardware-free fixtures use the same normalized semantic
script while retaining their exact physical endpoint projections. Cross-build
evidence does not claim connected execution, deployment, or flashing.

## Resource and Failure Behavior

Static roots have compile-time storage for the single live model, one staged
replacement, one registration, one location, dirty/live bits, `1/32/1` facts,
generated Canvas/workspace tables, and all remaining preset limits. Their
construction, opportunities, action dispatch, admission, and teardown must
show zero heap allocation and no prohibited runtime dependency. Dynamic roots
remain bounded to the same semantic cardinalities even where retained storage
is permitted.

Every focused failure keeps its local payload until the host adapter applies
mandatory effects and the total policy table. Partial activation is contained
through recorded progress. Capacity or generation failure never falls back to
unregistered state, direct callback mutation, altered limits, or identity
reuse. Immutable configuration or terminal operational failure requires a
fresh complete root.

## Test and Diagnostic Seams

Each root emits one normalized, immutable transcript with construction owner
counts; callback, fact, sequence, seal, application, action, report, dirty,
wake, publication, Drawing, offer, and teardown events; target and presentation
generations; and final semantic state. Platform-only fields are recorded in a
separate physical/resource section so semantic comparison cannot erase valid
profile differences.

The macOS Dynamic root lands first as the executable reference. The macOS
Static root runs the identical script and adds generated-storage and allocation
inspection. Pi and nRF roots reuse the same host-native semantic corpus before
their cross-build commands produce immutable artifact reports. Fault injection
targets owner construction and every activation stage without invoking later
owners after failure. Diagnostics may observe completed outcomes but cannot
drive any transition.

## Rejected Implementation Alternatives

- Importing Signal Analyzer modules into `GiftUIHostConfiguration` would move
  application knowledge into a reusable host owner and defeat target-root
  composition.
- One runtime registry selecting all four presets would add ambient lookup and
  platform branching where four immutable roots are required.
- Reimplementing observable lifecycle rules in each executable would risk
  profile divergence; roots compose the focused owners instead.
- Treating the existing model-free profile workspace as complete model
  ownership would leave initializers unbound and registrations unattached.
- Using the dynamic retained model path in Static builds would invalidate the
  generated address-stability and zero-allocation evidence.

## Open Implementation Questions

No contract question remains. Concrete executable product and private helper
names are mechanical choices made with each target slice. If the static Swift
toolchain cannot express the generated typed binding without a prohibited
runtime path, that is an implementation blocker to route upstream rather than
permission to weaken the static contract.

## Code and Evidence Links

- [`RuntimeObservableProfileWorkspace.swift`](../../Sources/GiftUIRuntimeCore/RuntimeObservableProfileWorkspace.swift)
  supplies profile-neutral structural identity and target generations.
- [`DynamicObservableModelStorage.swift`](../../Sources/GiftUIRuntimeDynamic/DynamicObservableModelStorage.swift)
  supplies bounded Dynamic-profile initializer preservation and assignment
  routing.
- [`StaticObservableModelStorage.swift`](../../Sources/GiftUIRuntimeStatic/StaticObservableModelStorage.swift)
  supplies attempt-scoped direct binding over caller-owned inline typed
  storage.
- [`ObservableStateRegistrationBridge.swift`](../../Sources/GiftUIObservableState/ObservableStateRegistrationBridge.swift)
  supplies single-issue attachment and report-route lifecycle to a stable root.
- [`DynamicObservableModelRegistration.swift`](../../Sources/GiftUIRuntimeDynamic/DynamicObservableModelRegistration.swift)
  supplies the stable Dynamic attachment, report, and retirement owner.
- [`DynamicObservableRootAdapter.swift`](../../Sources/GiftUIRuntimeDynamic/DynamicObservableRootAdapter.swift)
  joins Dynamic structural reconciliation, target generation, typed binding,
  and registration retirement.
- [`HostActivationController.swift`](../../Sources/GiftUIHostConfiguration/HostActivationController.swift)
  supplies exact activation and teardown ordering.
- [`HostSequencedFactAdmission.swift`](../../Sources/GiftUIHostConfiguration/HostSequencedFactAdmission.swift)
  supplies bounded cross-store fact order.
- [`SignalAnalyzerView.swift`](../../Sources/SignalAnalyzerPresentation/SignalAnalyzerView.swift)
  is the one portable root shared by all presets.
- [`SignalAnalyzerPresets.generated.swift`](../../Sources/GiftUIHostConfiguration/Generated/SignalAnalyzerPresets.generated.swift)
  supplies the four immutable preset projections.

Concrete root and evidence links will be added as T6.2 through T6.5 land.
