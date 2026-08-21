---
id: RFC-008
feature: observable-reference-state
title: Observable Reference State Architecture
status: review
authors:
  - Yauheni Lychkouski
created: 2026-08-21
updated: 2026-08-21
proposal:
  - PROPOSAL-005
related_rfcs:
  - RFC-001
  - RFC-002
  - RFC-004
  - RFC-005
related_adrs:
  - ADR-004
  - ADR-005
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-011
  - ADR-014
  - ADR-015
  - ADR-016
related_specs:
  - SPEC-001
related_future_work:
  - FW-017
  - FW-019
related_explorations: []
related_spikes:
  - SPIKE-003
supersedes: []
superseded_by: []
target_milestone: MVP
---

# RFC-008: Observable Reference State Architecture

## Summary

This RFC proposes one portable observable-reference-state contract for the
Signal Analyzer across GiftUI's dynamic and static runtime profiles.

The proposed contract gives one structurally identified `@State` location
ownership of one identity-bearing presentation model. The state location
preserves that model while transient view values are recreated, attaches one
runtime invalidation registration while the location is live, and detaches the
registration when a complete published semantic revision removes the
location. Repeating an initializer at the same live structural location does
not replace the preserved model; an admitted assignment to the state location
does.

An observable model reports semantically visible mutations through a narrow,
synchronous change-signaling contract. The MVP tracks dirtiness at the owning
state location rather than recording property-read dependencies. Any reported
model change therefore invalidates the owning semantic root, and the runtime
may coalesce arbitrarily many reports into one complete-root reevaluation and
one published semantic revision. This is intentionally conservative: it
satisfies the fixed Signal Analyzer hierarchy without introducing a reactive
graph, retained subtree lifecycle, or property-level dependency storage.

All model mutation remains inside RFC-004's serialized mutation phase.
External acquisition producers submit bounded state-change facts; applying an
admitted fact may mutate the model and report a change, but a producer may not
mutate the model directly during derivation. Observation never causes
immediate rendering and never bypasses the run-cycle freeze or publication
boundary.

Dynamic and static profiles may use different model storage, observer
representation, and binding machinery. They must preserve the same ownership,
identity, replacement, removal, invalidation, failure, and publication
semantics. The static profile uses generated or caller-supplied bounded state
locations and one bounded registration per live observable model; it may not
fall back to heap allocation, reflection, `Any`, task-local binding, or an
unbounded observer list.

[SPIKE-003](../spikes/spike-003-portable-observable-reference-state-feasibility.md)
has resolved the representation and instrumentation feasibility questions: a
generated typed handle and explicit generated model-owned setters preserve the
common semantics, compile and link for Embedded Swift with the same portable
`@State` source shape, and retain no allocator entry point. The Spike does not
select its disposable declarations or layout as production architecture. This
RFC instead constrains the acceptable family to a bounded typed representation
with synchronous model-owned change signaling; exact declarations, generation
mechanics, storage layout, and capacities remain Specification work.

## Context

[PROPOSAL-005](../proposals/proposal-005-observable-reference-state.md) is
accepted and authorizes architectural exploration of observable reference
state. The feature is required by the Signal Analyzer's Rank 2 client surface:
one presentation model carries acquisition state, bounded capture data,
visible-window selection, and errors, and changes to those values must update
the portable presentation on all four MVP configurations.

[SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md) defines
the application-facing need without selecting a GiftUI mechanism. The
`SignalAnalyzerViewModel` owns one view-state value, receives synchronous
application-domain updates, exposes actions, and must participate in the
GiftUI observation contract. Acquisition may deliver up to 80 transitions per
second while presentation runs at approximately four frames per second, so up
to 20 invalidations may be coalesced into one internally consistent frame.

Accepted architecture already fixes the surrounding ownership:

- ADR-005 keeps declarative evaluation, identity, state, interaction, and
  layout above the backend-neutral render boundary.
- ADR-006 requires equivalent observable semantics across dynamic and static
  profiles while allowing different storage and specialization.
- ADR-008 keeps the portable state-facing declaration in the `GiftUI` import
  surface and requires an acyclic module graph.
- ADR-011 seals bounded mutations and actions into one non-suspending
  serialized cycle, coalesces invalidation, freezes observed state during
  derivation, and publishes only complete semantic revisions.
- ADR-014 and ADR-015 require explicit bounded outcomes and layered failure
  disposition rather than traps or silent fallback for ordinary capacity and
  runtime failures.
- ADR-016 prevents optional diagnostics from becoming a mutation or control
  path.

Current source and legacy design documents provide useful feasibility
evidence but are not architecture. The dynamic runtime currently has a
class-backed `@State`, task-local binding, string structural keys, and an
`Any`-backed store. The static runtime has stable numeric typed slots,
deterministic slot exhaustion, and an invalidation bit, but its portable
thermostat fixture exercises value state rather than an observable reference
model. The macOS Signal Analyzer uses Apple's Observation framework and
`MainActor`; neither is a portable dependency.

The gap is therefore not whether GiftUI needs observation. It is how one
portable ownership and mutation contract can remain familiar on dynamic hosts
and finite on Embedded Swift without letting a profile-specific mechanism
change client-visible behavior.

## Scope and Decision Boundary

This RFC owns one independently reviewable decision cluster:

- the public meaning of observable reference state held through `@State`;
- model ownership, preservation, replacement, and structural removal;
- the change-signaling and runtime-registration relationship;
- invalidation granularity and coalescing;
- the relationship between model mutation and RFC-004 admission, freeze, and
  semantic publication;
- dynamic and bounded static realization constraints;
- failure ownership for state and observation capacity; and
- the physical contract placement needed to preserve the accepted module DAG.

These concerns should remain in one RFC. Observation cannot be reviewed
without knowing which state location owns the model and registration;
lifetime cannot be reviewed without structural identity and publication;
static feasibility cannot be reviewed without the required signaling
cardinality; and mutation admission cannot be reviewed without the
invalidation and freeze semantics. Splitting them would create circular draft
RFCs rather than independently approvable choices.

Adjacent ownership remains separate:

- RFC-001 and SPEC-001 own Signal Analyzer application-domain state,
  acquisition use cases, and presentation behavior. This RFC does not define
  capture storage or acquisition architecture.
- RFC-002 and its accepted ADRs own semantic/backend boundaries, structural
  identity authority, runtime-profile equivalence, and the module dependency
  direction. This RFC specializes the B11 public state seam without reopening
  those choices.
- RFC-004 and ADR-011 own cycle membership, ordering, freeze, dirty recovery,
  and complete revision publication. This RFC defines how observable state
  participates in those phases, not a second transaction model.
- RFC-005 and ADR-014 through ADR-016 own portable outcome meaning,
  disposition authority, and optional diagnostics. This RFC identifies
  observable-state failure conditions but does not create another error
  architecture.
- Public `Binding`, externally owned observation wrappers, and controls that
  require two-way projection remain outside MVP under FW-017.
- Property-level dependency tracking and selective subtree reevaluation are
  captured in FW-019 rather than being required by the Signal Analyzer.

Exact Swift declarations, generated representations, identity widths,
numeric capacities, field layout, and concrete failure cases remain
Specification work after the architecture and its feasibility blocker are
resolved.

## Requirements

### R1 — One portable observable-reference concept

Portable presentation code MUST express one observable reference-state
concept across macOS dynamic, macOS static, Raspberry Pi/Linux dynamic, and
nRF52840 static configurations. A profile MAY specialize representation but
MUST NOT require a separate Signal Analyzer view hierarchy or different
observable behavior.

### R2 — Preserved model identity

One live observable `@State` location MUST preserve one model identity across
transient view reconstruction and repeated body evaluation. A repeated
initializer at the same live structural state location MUST NOT silently
replace or recreate the preserved model.

### R3 — Explicit structural lifetime

Observable state lifetime MUST be associated with runtime-owned structural
identity plus the declaration's state-slot identity. Removal and replacement
MUST have deterministic, testable behavior. Failed or partial derivation MUST
NOT retire state based on an unpublished hierarchy.

### R4 — Bounded observation

Every static-path model location, registration, live-state mark, and teardown
record MUST have a generated, fixed, or caller-supplied bound. Exhaustion MUST
produce an explicit bounded outcome and MUST NOT fall back to untracked local
state, heap allocation, or an unbounded observer collection.

### R5 — Serialized mutation

All GiftUI-observed model mutation MUST occur inside RFC-004's serialized
mutation domain. External producers MUST submit bounded facts through the
approved admission boundary rather than mutate the model directly.

### R6 — Coalesced complete publication

One or more model-change reports in an admitted mutation batch MUST mark the
owning state location dirty without triggering reentrant evaluation. The
runtime MUST freeze mutation before derivation and publish only a complete
semantic revision. Derivation failure MUST leave already-mutated state dirty
for paced recomputation without replaying the mutation or client effect.

### R7 — MVP-proportionate invalidation

The common MVP contract MUST NOT require property-read tracking, a general
dependency graph, partial subtree reconciliation, or retained view lifecycle
machinery. Complete-root reevaluation is permitted. A profile MAY optimize
work internally only when the optimization is observationally equivalent and
does not create a second public semantic contract.

### R8 — Backend and integration isolation

Backends, renderers, platforms, drivers, diagnostics, and hardware
integrations MUST NOT own observable models, attach semantic observers, mutate
application state, invoke client handlers, or decide semantic publication.

### R9 — Portable bounded failure

State-slot exhaustion, registration exhaustion, duplicate ownership, stale or
incompatible state association, and detected mutation-phase violations MUST
follow the accepted bounded outcome and layered disposition architecture.
Ordinary capacity exhaustion MUST NOT be expressed only as a dynamic-profile
trap.

### R10 — Testable profile equivalence

Shared semantic fixtures MUST compare model preservation, initialization,
replacement, removal, change coalescing, mutation ordering, failed derivation,
external-fact admission, and deterministic exhaustion across dynamic and
static profiles.

### R11 — Measured constrained cost

The selected static realization MUST report state and registration RAM,
incremental flash, stack requirements, invalidation work, and zero-heap
evidence for the supported Embedded Swift target before this RFC is ready for
approval.

## Constraints

- Portable Presentation imports only `GiftUI`; it does not import a runtime,
  backend, platform, scheduler, Apple Observation, or hardware module.
- The nRF52840 path may not assume heap allocation, reflection, unrestricted
  existentials, Objective-C runtime facilities, task-local storage, `Task`,
  thread primitives, exceptions, or unbounded collections.
- The supported embedded compilation target is the repository's
  `nrf52840dk/nrf52840` configuration using the bundled
  `armv7em-none-none-eabi` module and hard-float Zephyr flags.
- The active runtime profile, component graph, capacities, and product policy
  are immutable after host assembly. Observable application state is runtime
  operational state, not configuration mutation.
- The Signal Analyzer hierarchy is fixed for MVP. It does not require
  unrestricted dynamic collections, explicit client identity, public
  bindings, or general lifecycle callbacks.
- Acquisition may publish up to 80 transitions per second while frames are
  paced at 250 milliseconds. Observation must allow at least the resulting 20
  changes to coalesce without dropping the underlying admitted facts.
- Direct client observation of the mutable model outside GiftUI's published
  revision boundary is not transactionally atomic and must not be described
  as covered by GiftUI publication.
- Existing dynamic `@State`, static typed slots, Apple Observation use, and
  legacy documents are evidence only. They do not select maintained APIs or
  storage.
- No stable ABI, persistent state format, serialized observation protocol, or
  cross-process identity is required for MVP.

## Proposed Design

### 1. Semantic model: an owned observable state location

The public state-facing declaration remains `@State`. This RFC governs the
case where its value is an observable identity-bearing presentation model.
It does not require every scalar or value-state facility to use an observer.

Each observable state declaration corresponds to one runtime state location:

```text
structural view identity
    + declaration-local state identity
    -> observable state location
       -> preserved model identity
       -> one runtime invalidation registration
       -> dirty/live bookkeeping
```

The state location, rather than the transient property-wrapper value, owns the
preservation obligation. The first successful materialization supplies the
initial model. Later transient declarations at the same live location observe
the preserved model and ignore their repeated initializer for replacement
purposes.

The model is reference-semantic at the public contract: all reads during a
cycle and all admitted mutations address one stable model identity. A dynamic
profile may realize that identity as a retained class instance. A static
profile may use generated address-stable storage and a typed reference or
handle, provided the same portable source-level declaration and observable
behavior are preserved. Copying a static handle must not copy or fork the
underlying model state.

The model and its internal application data remain application-owned types.
GiftUI owns only the state location, preservation relationship, observation
registration, and semantic dirty state. GiftUI does not introspect model
properties, store a second copy of the model, or define the Signal Analyzer's
capture representation.

### 2. Initial ownership and application lifecycle

For the Signal Analyzer, the target composition constructs the presentation
model and its application dependencies before the portable root is first
evaluated. The root passes that model as the initial value of its observable
state declaration. The state location then preserves it for the structural
lifetime described below.

Application-domain observation startup and shutdown are not implicit effects
of `@State` access or `View.body`. In particular, reevaluating a transient view
must not call `startObserving()` repeatedly, and removing a state location does
not synthesize an application lifecycle callback. The application or host
owns explicit start/stop coordination through its approved contracts.

This separation is required because GiftUI has no retained view lifecycle in
MVP and because state materialization may be staged or abandoned after a
derivation failure. State initializers used during view declaration must not
perform external side effects whose correctness depends on whether a candidate
semantic revision publishes.

Dynamic ownership may retain the model strongly for the live state location.
Static ownership may reserve generated storage for the assembled application
lifetime and mark the location live or vacant. When a location is removed,
GiftUI detaches only its invalidation registration and releases or resets its
own ownership according to the profile's bounded storage contract. Other
application owners, if any, retain their ordinary ownership; GiftUI does not
claim that model destruction is synonymous with structural removal.

### 3. Change-signaling contract

An observable model exposes a narrow framework-facing ability to attach and
detach one change sink for its owning state location. Exact Swift spelling is
left to the Specification. SPIKE-003 established that explicit generated
setters can realize the required synchronous signaling, but the semantic
contract is:

```text
attach(owner identity, bounded change sink)
    -> active registration or explicit failure

admitted model mutation
    -> zero or more synchronous change reports
    -> owning location dirty
    -> at most one pending wake requirement

detach(owner identity)
    -> no later report reaches the removed location
```

The change report carries no property path, new value, model snapshot,
backend identity, scheduler identity, or diagnostic authority. Its only
semantic meaning is that values derived from the owning model may have
changed and the owning presentation must be reevaluated.

The common MVP cardinality is one owning observable state location per model
within one assembled runtime. Descendants may borrow and read that preserved
model during evaluation without installing additional registrations. Trying
to attach the same model as two independent owning state locations is outside
the required Signal Analyzer surface and produces a deterministic duplicate-
ownership outcome rather than creating an unbounded observer list.

This cardinality does not create a public `ObservedObject` or externally owned
state wrapper. A future accepted feature may generalize observation ownership
without changing the MVP's one-owner behavior.

### 4. Coarse invalidation and reevaluation

The runtime records a dirty bit or equivalent bounded state for the owning
location. Every reported semantically visible mutation marks that state dirty.
Reports do not accumulate into an event history and do not count mutations for
correctness. Twenty capture updates before the next cycle may therefore leave
one dirty bit and one coalesced wake request while all 20 already-admitted
application facts remain reflected in the model.

The MVP runtime reevaluates the complete portable root whenever any live
observable state location is dirty. It does not record which properties were
read by which view descriptions. The resulting hierarchy, layout, operations,
disabled state, and waveform inputs are all derived from one frozen model
state during the cycle.

An implementation may skip an unnecessary wake when a model can prove that a
mutation was semantically invisible, but the common contract does not require
`Equatable` values or equality filtering. A profile-specific optimization may
not omit reevaluation after a reported change unless it proves the same
observable result under shared conformance tests.

Property-level dependency tracking and selective subtree work are deferred by
FW-019. They may later consume the same model-change concept, but the MVP
public contract does not expose property tokens that would freeze a future
algorithm.

### 5. Mutation admission and run-cycle integration

There are two supported mutation origins:

1. **Semantic actions.** RFC-004 admits and dispatches an action during the
   serialized mutation phase. The action calls the presentation model's
   mutation operation synchronously. Model writes report change, mark the
   owner dirty, and return before the next action or fact is applied.
2. **External application facts.** Acquisition, callbacks, interrupts, or
   workers submit bounded typed facts to RFC-004 admission. The next cycle
   seals and applies those facts in order; applying a fact invokes the model's
   synchronous mutation operation inside the same serialized phase.

The model itself is not the cross-domain queue. An external producer cannot
retain mutating authority and rely on an observation callback to make an
already-concurrent write safe. The application/runtime adapter owns fact
conversion, capacity, sequencing, and admission outcomes.

One cycle behaves as follows for observable state:

```text
admit bounded facts and actions
    -> apply each once in serialized order
    -> model reports changes synchronously
    -> coalesce owner dirtiness and wake intent
    -> freeze all observed model mutation
    -> evaluate complete root from stable state
    -> stage new/live/removed state associations
    -> publish complete semantic revision
    -> commit state-association lifetime changes
    -> clear represented dirtiness
```

Facts and input arriving after admission wait for a later cycle. A model change
attempted after freeze is not folded into the current revision. Detected
reentrant or out-of-phase mutation follows the failure behavior below; an
unsynchronized Swift data race remains outside any GiftUI guarantee.

If derivation fails before semantic publication, admitted mutations are not
rolled back. Previously live state associations remain authoritative, staged
new or removed associations do not commit, and affected state remains dirty.
The host requests a paced later cycle that derives from current state without
replaying the mutations, facts, or actions.

Once the semantic revision publishes, observable-state dirtiness represented
by that revision may clear independently of frame acceptance or physical
presentation. A later backend refusal or device failure does not roll back the
model or reissue change reports.

### 6. Structural identity, replacement, and removal

The semantic runtime derives state identity; the model, backend, and host do
not choose it. Exact encoding belongs to a Specification, but the contract
combines the runtime's structural identity with a declaration-local state
identity so multiple state declarations in one view remain distinct.

The fixed MVP hierarchy requires these cases:

| Case                                                                              | Required behavior                                                                                                                                 |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Same structural and declaration identity appears again                            | Preserve the existing model and registration; repeated initializer does not replace it                                                            |
| Admitted assignment replaces the state value                                      | Detach the old model, install the new model at the same location, report the location dirty, and publish the replacement through the normal cycle |
| Location absent from a complete candidate hierarchy                               | Stage removal; detach and retire the association only when that semantic revision publishes                                                       |
| Derivation fails before publication                                               | Preserve the previously published live set; discard uncommitted association changes and keep current state dirty                                  |
| Removed location appears in a later revision                                      | Materialize fresh state from the new initializer; do not resurrect the retired association implicitly                                             |
| Existing identity is encountered with incompatible model type or generated layout | Return an explicit incompatible-association outcome; do not reinterpret bytes or silently initialize a second value                               |

Moving content changes state lifetime only according to the structural
identity rules established by the semantic runtime. Explicit identity,
unrestricted dynamic collections, and retained lifecycle callbacks are not
introduced by this RFC.

New association creation and removal are transactional only with respect to
which structural locations become live at semantic publication. This does not
provide rollback for arbitrary side effects performed by a model initializer,
which is why such initializers may not rely on candidate publication.

### 7. Dynamic runtime realization

The dynamic profile may use retained class instances, dictionaries or arrays
for state-location lookup, heap-backed registration tokens, and runtime-local
binding context. Those mechanisms remain below the portable contract.

The maintained dynamic implementation must still enforce common semantics:

- one owner registration per model;
- structural preservation rather than wrapper-instance preservation;
- no intermediate publication;
- deterministic duplicate-owner and incompatible-association outcomes;
- removal only after a complete semantic publication; and
- no unbounded queued invalidation history.

Dynamic convenience does not authorize arbitrary cross-thread model mutation,
Apple Observation as a semantic dependency, or richer multi-observer behavior
that portable clients could come to rely on.

### 8. Static runtime realization

The static profile uses a generated, fixed, or caller-supplied set of typed
observable state locations. Each location has, at minimum:

- stable structural/declaration identity or a generated equivalent;
- address-stable model storage or a typed handle to such storage;
- live, staged, and dirty bookkeeping;
- one bounded runtime change-sink registration;
- deterministic type/layout validation; and
- explicit vacant, live, replacing, and removal state as required by the
  implementation strategy.

The profile may use generated direct field access, numeric slot identifiers,
inline arrays, bit sets, tagged fixed records, or specialized calls. It may
not require `Any`, string keys, reflection, task-local context, an arbitrary
existential registry, or a general heap.

The same portable model declaration must not fork into an unrelated value-
snapshot UI model on static targets. A generated typed handle is acceptable
only if copying the handle preserves one underlying model identity and if
client mutation/read semantics remain equivalent to the dynamic model.

SPIKE-003 demonstrated one source-level declaration that compiles both
normally and for the supported Embedded Swift target. Its generated address-
stable typed handle satisfied these requirements without profile-specific
portable Presentation code; an escaping Swift reference instance retained an
unavailable allocation path. The static representation must therefore remain
within the bounded typed family described above unless later evidence supports
an equally portable zero-heap realization. Exact generated declarations and
storage layout remain Specification work.

### 9. Registration and teardown safety

Attaching a model succeeds only when both the state location and its one
registration record are available. A partially attached model must be
detached before returning failure. The runtime may not publish a state
location that cannot report later changes.

Detachment must prevent a later change report from addressing a reused state
location. Static implementations may use a bounded generation, ownership
token, or direct teardown ordering; dynamic implementations may invalidate a
registration object. Exact token widths and wrap handling belong to a
Specification, but stale notification aliasing is forbidden.

Diagnostics may observe attach, detach, exhaustion, or phase failures, but a
diagnostic callback cannot serve as the registration, wake path, or fallback
mutation channel.

### 10. Failure behavior

Observable-state operations use the accepted failure architecture:

| Condition | Minimum meaning and containment |
| --- | --- |
| State-location capacity exhausted | Explicit expected operational outcome; candidate association is not installed and no local fallback is created |
| Registration capacity exhausted | Explicit expected operational outcome; any partial attachment is undone and the candidate association is not published |
| Same model attached to a second owning location | Deterministic duplicate-ownership outcome; neither location silently acquires ambiguous notification semantics |
| Existing location has incompatible model type/layout | Explicit failure with the state location as affected scope; stored bytes are not reinterpreted |
| Stale report targets a detached/reused location | Reject the report; preserve source identity; containment is no narrower than can be proved |
| Mutation report during the frozen or otherwise prohibited phase | Mark the semantic scope dirty and report a phase violation; if stable state cannot be proved, containment is `safety not proven` |
| Unsynchronized client data race or mutation that bypasses the model contract | Client contract violation outside GiftUI's atomic guarantee; it must not be normalized into a successful published revision |

The detecting model adapter or storage performs only mechanical rejection or
detach cleanup. The semantic runtime applies mandatory dirty/publication
effects. Target composition chooses only among remaining safe bounded product
responses. No layer may silently turn exhaustion into a dynamic allocation,
drop a required registration, or publish a possibly torn model snapshot.

Exact cases, payload fields, affected-scope encoding, and target policy tables
belong to Specifications conforming to ADR-014 and ADR-015.

## Module Responsibilities

| Owner | Responsibility | Dependency impact and prohibited ownership |
| --- | --- | --- |
| `GiftUI` | Portable `@State` declaration and the minimum observable-model/change-sink vocabulary needed by client types | Remains the portable leaf; imports no semantic runtime, execution, backend, platform, Observation, scheduler, or hardware implementation |
| Build-time generation support, if selected | Emit typed portable conformances, locations, or access paths proven by SPIKE-003 | Build-time only; generated source must obey the same `GiftUI` contract and must not introduce runtime platform discovery |
| `GiftUISemanticCore` | Structural/declaration state identity, live/staged association semantics, dirty tracking contract, replacement/removal rules, and profile-neutral conformance fixtures | Depends on `GiftUI`; imports no concrete runtime, backend, or platform and does not own RFC-004 scheduling |
| `GiftUIRuntimeDynamic` | Dynamic state-location storage, strong ownership where selected, registration implementation, runtime binding, and dynamic failure adaptation | Depends downward on portable/semantic/execution/failure contracts; imports no concrete backend or Apple Observation as a required semantic owner |
| `GiftUIRuntimeStatic` | Generated or caller-supplied typed locations, fixed registration and live/dirty bookkeeping, deterministic exhaustion, and direct specialized binding | Depends on the same contracts; no heap, reflection, `Any`, task-local binding, or unrestricted existential store |
| RFC-004 execution coordinator | Seal facts/actions, establish the permitted mutation phase, freeze observation, publish revisions, retain dirty state after derivation failure, and request paced cycles | Does not define model storage or public state syntax |
| Application/runtime fact adapter | Convert external acquisition delivery into bounded typed facts and submit them to admission | Cannot mutate the model directly, attach semantic observers, or decide cycle membership after sealing |
| Target host | Construct the application model and dependencies, supply profile storage/capacities and wake integration, and start/stop application-domain observation explicitly | Composition root only; exports no target identity or scheduler to portable views |
| Backend/platform/driver/diagnostics | No observable-state responsibility beyond consuming already published downstream work or optional non-authoritative facts | Cannot own models, register observers, mutate state, wake through diagnostics, or invoke actions |

The exact maintained target names remain Specification work except for the
stable `GiftUI` client module. Any generation plugin or macro implementation
must remain a build-time implementation detail compatible with the one-package
MVP topology; portable Presentation still imports only `GiftUI`.

## Public API Impact

The intended client shape remains familiar:

```swift
struct SignalAnalyzerView: View {
    @State private var viewModel: SignalAnalyzerViewModel

    init(viewModel: SignalAnalyzerViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        // Reads derive Text, disabled state, and waveform inputs.
        // Actions synchronously invoke viewModel mutation methods.
    }
}
```

This example is illustrative, not an approved declaration. The Specification
must decide the exact observable-model marker, generated annotation or manual
conformance, initializer spelling, access control, mutation enforcement, and
whether replacement assignment is exposed in the MVP API.

The public semantic expectations are architectural:

- the first live structural materialization preserves the supplied model;
- body reevaluation reads that preserved identity;
- admitted mutations report changes without explicit view invalidation calls;
- model changes do not immediately render or publish intermediate state;
- no backend, platform, or scheduler type appears in portable code; and
- dynamic and static targets use the same portable presentation source.

This RFC does not add `$viewModel`, dynamic-member projection, `Binding`,
`ObservedObject`, `StateObject`, environment-owned models, arbitrary observer
collections, or automatic application lifecycle callbacks.

## Capabilities Impact

Observable reference state is a required Rank 2 semantic behavior, not an
optional capability. A target that cannot preserve and invalidate the Signal
Analyzer model does not provide the required MVP client surface; portable
views do not branch on an observation capability.

Numeric capacities, generated model support, and selected runtime profile are
immutable host assembly inputs and validated configuration. Runtime
exhaustion or a detached model is an operational outcome, not capability
renegotiation. No new capability vocabulary or resolver input is proposed.

## Backend Impact

Backends see only render operations, frame provenance, and the existing
handoff contract derived after semantic publication. They receive no model,
observer, state key, dirty bit, or mutation callback.

Observable invalidation may cause later frame production, but a backend cannot
request model reevaluation directly, acknowledge a mutation, delay semantic
publication, or roll state back after refusal. Presentation failure remains
independent from semantic state under RFC-004 and RFC-005.

Platform event adapters continue to submit normalized input through RFC-004.
External acquisition adapters submit bounded application facts through the
same admission ownership; they do not become observation backends.

## Static / Embedded Impact

The common static path must prove:

- one portable source-level model and `@State` declaration compile under the
  pinned Embedded Swift toolchain;
- model identity remains stable without a general heap;
- change signaling uses fixed or generated dispatch rather than arbitrary
  escaping closures or observer lists;
- state locations, registrations, touched/live sets, and external-fact
  admission are separately bounded;
- no string structural paths, `Any` state dictionary, reflection, task-local
  binding, Objective-C runtime, Apple Observation, `Task`, thread, or exception
  dependency reaches the image;
- exhaustion and stale-registration fixtures return deterministic outcomes;
- teardown cannot alias a later occupant of the same slot; and
- the Signal Analyzer model's application data and observation bookkeeping fit
  together with the required runtime, rendering, and firmware stack.

Static generation may know the fixed Signal Analyzer hierarchy and model
types. That knowledge may specialize storage and dispatch but may not change
the meaning of repeated initializers, model replacement, structural removal,
coalescing, or publication.

SPIKE-003 is hardware-free: it compiles and links representative fixtures and
runs semantic/resource checks where the host or emulator can do so. It must
not claim connected-board execution. Connected nRF52840 timing, stack
high-water, and full application conformance remain downstream Specification
and implementation evidence.

## Performance

For the proposed coarse design:

- a model change report is constant work: validate the live registration,
  set one dirty bit, and coalesce one wake requirement;
- no per-mutation history or property dependency is retained;
- applying external facts remains proportional to the sealed fact count under
  RFC-004;
- live-state reconciliation is proportional to the number of state locations
  visited by the fixed hierarchy; and
- reevaluation cost is proportional to the complete MVP root rather than an
  affected subtree.

The Signal Analyzer workload must test 80 admitted capture facts per second,
250-millisecond presentation pacing, and up to 20 model change reports
coalesced before one frame. Measurements must separate:

- fact admission and application;
- model mutation and change-report cost;
- wake coalescing;
- complete-root semantic evaluation;
- layout and operation emission; and
- dirty-to-publication and dirty-to-frame latency.

The RFC establishes no universal microsecond budget. The selected
implementation must demonstrate that the four-frame-per-second Signal
Analyzer cadence remains viable on each claimed stack and that repeated
notifications do not create linear retained work between frames.

## Memory / Binary Size

The static observation overhead is expected to be constant per configured
state location plus bounded global bookkeeping:

```text
model storage owned by the application/profile
    + one state-location identity record
    + one registration or direct sink endpoint
    + live/staged/dirty bits
    + bounded stale-registration protection
    + RFC-004 fact admission storage (owned separately)
```

The design does not require property dependency nodes, observer arrays,
mutation logs, model snapshots, rollback journals, or a retained semantic
history.

SPIKE-003 reports, for comparable baseline and candidate fixtures:

- linked RAM and flash delta;
- bytes per configured observable state location;
- registration and live/dirty bookkeeping;
- model storage and any generated descriptor storage separately;
- maximum stack use or a conservative reproducible bound;
- initialization, attach, mutation, and detach operation counts; and
- absence of heap allocator and forbidden runtime symbols.

Exact acceptable capacities and the complete Signal Analyzer memory budget
belong to downstream Specifications. A dynamic implementation may allocate,
but it must still avoid unbounded pending invalidation history and must expose
equivalent deterministic behavior at configured contract boundaries.

## Alternatives

### Apple Observation or equivalent automatic property tracking

A dynamic profile could rely on Apple's Observation framework or reproduce a
similar registrar with automatic property-access tracking. This provides
familiar tooling and can avoid reevaluating unrelated work.

It is not the proposed common contract because the supported Linux and
Embedded Swift stacks cannot assume that framework or its runtime facilities.
Making its property tokens observable in the public contract would also impose
dependency storage and code-size costs before the Signal Analyzer demonstrates
a need. A dynamic implementation may use compatible internal automation if it
does not change semantics or become a portable dependency.

### Property-level dependency graph with selective reevaluation

The runtime could record every observable property read during body evaluation
and invalidate only dependent subtrees after a write. This may reduce work for
large hierarchies and high-frequency models. It could eventually be realized
as a transparent optimization for runtime profiles that can afford it or as an
optional add-on for high-load or UI-rich systems, provided either form
preserves the common observable-state semantics.

It requires property identities, read scopes, dependency edges, stale-edge
cleanup, bounded graph capacity, and reconciliation semantics. Those costs and
choices are not justified by the fixed MVP hierarchy, for which RFC-002
already permits complete-root reevaluation. RFC-008 rejects it as part of the
MVP architecture. FW-019 preserves it for a later Exploration when measurements
or a later feature provide a concrete need.

### Poll or compare complete model snapshots each cycle

The runtime could avoid explicit change signaling by polling the model or
copying and comparing a snapshot at every host deadline. This simplifies model
instrumentation but requires a clock-driven cycle even when idle, a complete
comparable snapshot, or application-specific equality. Large capture state
makes copying expensive, and polling does not establish when external mutation
is safe relative to freeze. It remains a viable specialized optimization only
if it preserves the explicit admission and publication contract; it is not the
proposed common architecture.

### Explicit client calls to `invalidate()`

Every model mutation could require application code to call a runtime or host
invalidation function. This is easy to prototype and bounded, but it exposes
runtime integration to portable Presentation, permits mutation and
invalidation to drift apart, and makes missing calls silently stale. It also
does not solve model preservation or structural lifetime. The proposed model-
owned signaling contract keeps the dependency narrow and testable.

### Store immutable value snapshots rather than a reference model

Each application fact could create a new complete `SignalAnalyzerViewState`
value and replace `@State`. This can simplify isolation and rollback reasoning
when values are small.

It does not satisfy the accepted problem as stated: the portable presentation
must preserve one reference-model identity that owns actions, use cases, and
derived state. Copying bounded capture values at up to 80 updates per second
may also be more expensive than in-place serialized mutation. Immutable
snapshots may remain an application-internal technique, but they cannot
replace the public reference-state behavior in this feature.

### Runtime-external model ownership with an `ObservedObject`-style wrapper

The application could keep all model ownership outside GiftUI and ask a view
to borrow and observe it. This avoids `@State` owning lifetime but introduces
externally owned observation, potentially multiple subscribers, and teardown
semantics not required by the Signal Analyzer scope. FW-017 already preserves
future public projection/ownership work; the MVP uses one owning `@State`
location.

### Different public state APIs for static and dynamic profiles

The dynamic Signal Analyzer could use class-backed `@State` while the static
application passes a value snapshot or generated slot through different view
initializers. This matches current proof-of-concept implementation boundaries
but violates ADR-006 and the accepted Proposal's requirement for one portable
client concept. Profile-specific machinery must remain below the source-level
contract.

### General multi-observer model registration

An observable model could keep a dynamic or bounded list of subscribers so
several independent state locations and external tools can observe it. This is
more flexible, but it introduces observer identity, list capacity, ordering,
removal, and partial-delivery semantics without an MVP use case. The proposed
one-owner registration is the smallest coherent cardinality for the Signal
Analyzer.

## Rejected Approaches

RFC-008 rejects the alternative approaches above for its MVP decision boundary:

- **Apple Observation or equivalent automatic property tracking as the common
  contract:** unavailable as a portable dependency across the supported Linux
  and Embedded Swift profiles and would expose machinery beyond the required
  coarse invalidation semantics.
- **Property-level dependency tracking and selective reevaluation:** adds a
  dependency graph, reconciliation lifecycle, and bounded-resource choices
  without an MVP workload that needs them. It is preserved by FW-019 for a
  later evidence-driven Exploration, including possible runtime-specific or
  optional add-on forms.
- **Polling or comparing complete model snapshots:** creates clock-driven or
  copying work, requires equality semantics, and does not establish safe
  mutation ordering relative to semantic freeze.
- **Explicit client calls to `invalidate()`:** exposes runtime coordination to
  portable Presentation and permits model mutation and invalidation to drift
  apart silently.
- **Immutable value snapshots in place of a reference model:** does not satisfy
  Proposal 005's preserved reference-identity requirement and may repeatedly
  copy bounded capture data.
- **Runtime-external ownership through an `ObservedObject`-style wrapper:**
  introduces externally owned and potentially multi-subscriber observation
  that is not required by the Signal Analyzer. FW-017 preserves that separate
  future surface.
- **Different public state APIs for static and dynamic profiles:** violates
  ADR-006 and the accepted Proposal's single portable client concept.
- **General multi-observer registration:** adds observer-list capacity,
  identity, ordering, removal, and partial-delivery semantics without an MVP
  use case.

The RFC also rejects mechanisms already excluded by accepted architecture and
Proposal scope: backend-, platform-, driver-, or diagnostic-owned semantic
mutation; unbounded static observer or state storage; direct external mutation
during frozen derivation; rollback or replay of arbitrary client mutation and
side effects; and silent fallback from failed runtime binding to wrapper-local
state. These rejections are scoped to RFC-008 and do not close FW-017 or
FW-019, whose own revisit and promotion gates remain authoritative for future
investigation.

## Compatibility

### Source compatibility

The intended `@State private var viewModel` shape is compatible with the
Signal Analyzer investigation, but exact SwiftUI or Apple Observation source
compatibility is not promised. The model may need an explicit GiftUI marker,
generated annotation, or manual change-report calls. Dynamic-only state
binding internals are not API compatibility commitments.

Application startup must move out of transient view evaluation if it currently
calls `startObserving()` from a view initializer. The host or application
composition should construct the model, start its domain observation through
the approved application contract, and then supply it as the root's initial
state model. This preserves application behavior while avoiding repeated or
abandoned lifecycle effects.

### Behavioral compatibility

The maintained behavior preserves one model across reevaluation, synchronously
applies actions and admitted facts, coalesces invalidation, and publishes
internally consistent revisions. Current code that mutates an observed model
from an arbitrary task, callback, or thread without admission will require
migration.

Dynamic property-level suppression or observation ordering that is not
visible through complete GiftUI revisions is not portable behavior. Static and
dynamic profiles must agree on replacement, removal, duplicate ownership,
failed derivation, and exhaustion fixtures.

### ABI and data compatibility

No public ABI stability, persistent model format, durable state identity, or
serialized observation record is established for MVP. Generated layout and
numeric state identifiers may change between builds unless a later accepted
feature establishes a compatibility requirement.

## Testing Strategy

### Shared semantic conformance

Run each fixture against dynamic and static host runtimes and compare semantic
revisions and normalized downstream results:

- preserve one model across repeated transient root construction;
- adopt an initializer result only for a freshly materialized location, while
  repeated transient wrapper initializers do not replace the live model;
- keep multiple state declarations in one view distinct;
- ignore a repeated initializer while the same location remains live;
- replace the model through one admitted assignment and detach the old
  registration;
- remove a state-bearing branch, publish, and verify later model changes do
  not invalidate the retired location;
- reinsert the branch and verify fresh state rather than implicit resurrection;
- fail derivation before publication and verify the previous live set remains,
  uncommitted association changes are discarded, and dirty state is rederived
  without replay;
- apply several property mutations and up to 20 capture updates in one sealed
  batch and verify one complete published revision with no intermediate view;
- mutate through a Button action and through an admitted external fact and
  compare ordering;
- inject a fact during freeze and verify later admission rather than mutation
  of the current derivation;
- inject a detected out-of-phase report and verify conservative failure
  disposition;
- exhaust state locations and registrations independently;
- attach one model to two owning locations and verify deterministic duplicate
  ownership failure; and
- deliver a stale report after detach/reuse and verify it cannot dirty the new
  occupant.

### Signal Analyzer integration

Use the governed Signal Analyzer presentation model to verify:

- initial idle, empty capture, two-second window, and no-error state;
- Start, Stop, Clear, error, capture, and visible-window mutations invalidate
  all derived text, disabled controls, and waveform inputs;
- acquisition updates enter through bounded fact admission rather than direct
  model mutation;
- 80 transitions per second preserve every admitted application update while
  observation coalesces presentation work at 250-millisecond cadence; and
- one frozen model revision feeds semantic evaluation, layout, render
  operations, and hit/disabled state.

### Compile and dependency checks

- Compile the same portable declaration for macOS dynamic, macOS static,
  Raspberry Pi/Linux dynamic, and the Embedded Swift client module.
- Reject imports from `GiftUI` or semantic core into runtime, backend,
  platform, Observation, scheduler, or hardware implementations.
- Inspect the embedded dependency closure for forbidden allocation,
  reflection, task, exception, and Objective-C runtime symbols.
- Verify any generated source is deterministic and uses only approved portable
  and package-scoped contracts.

### Resource and performance evidence

SPIKE-003 supplies the RFC-level compile, zero-heap, and incremental resource
evidence. Downstream Specifications must add complete application capacities,
stress tests, firmware section limits, stack high-water evidence, and the
required distinction between host, compile-only, simulator, and connected-
hardware claims.

## Risks

- **A production realization may reintroduce unavailable machinery.** The
  familiar `@State` source shape compiled zero-heap with the generated Spike
  handle, while an escaping Swift class retained allocation. Maintained
  declarations and generation must preserve the proven dependency boundary.
- **A generated handle may only imitate reference semantics partially.** The
  conformance suite must prove aliasing, replacement, and removal behavior, not
  merely that one numeric slot can be changed.
- **Coarse invalidation may exceed the embedded cadence.** Measure the complete
  Signal Analyzer root under sustained updates; trigger FW-019 if whole-root
  work fails a required target rather than silently adding a dependency graph.
- **Out-of-domain mutation may already have changed the model before it is
  detected.** Restrict mutating authority, use bounded fact admission, and
  classify detected freeze violations conservatively; observation alone is
  not a concurrency mechanism.
- **State removal can race stale reports in a dynamic implementation.** Use
  detach ordering and bounded stale-registration protection, with explicit
  fixtures for slot reuse.
- **Application lifecycle may be accidentally tied to view evaluation.** Keep
  acquisition start/stop in application or host composition and prohibit
  side-effect-dependent state initialization.
- **Dynamic convenience may leak into common semantics.** Run shared failure
  and cardinality fixtures even when the dynamic runtime could allocate more
  observers or use Apple Observation internally.
- **One-owner cardinality may be too narrow for a later reusable view.** It is
  sufficient for the fixed Signal Analyzer; a concrete accepted need should
  revisit externally owned or multi-owner observation rather than expanding
  this RFC speculatively.

## Resolved Questions

### Portable zero-heap reference representation

Can one portable `@State` and observable model declaration compile under the
supported Embedded Swift toolchain while preserving one stable model identity,
bounded change signaling, attach/detach safety, and no general heap?

SPIKE-003 compared a direct Swift class with a generated typed handle. The
escaping class retained an unavailable allocation path. The generated handle
passed shared semantic fixtures, compiled and linked with the portable
`@State` source shape, retained no allocator, and added 448 linked flash bytes,
38 `bss` bytes, and 32 bytes to the conservative fixture stack bound over the
baseline. Representational feasibility is therefore established. RFC review
must still approve or revise the bounded typed family proposed by this RFC;
the Spike result is evidence, not approval of its disposable representation.

### Minimum feasible portable instrumentation

SPIKE-003 demonstrated that explicit generated setters provide sufficient
synchronous model-owned signaling while preserving the portable `@State`
source shape, compiling for both tested profiles, avoiding property dependency
tracking, and making mutation reports testable. Compiler hooks and macros were
not needed to meet the Spike stop condition and were not evaluated. This
closes the feasibility question without making the Spike's disposable setter
spelling or generation layout a production contract.

## Open Questions

No evidence questions remain open after SPIKE-003. RFC review must still
approve or revise the proposed bounded typed representation and synchronous
model-owned signaling boundary; that review gate is not delegated to the
Spike.

## Specification Inputs

State-location counts, registration counts, identity widths, stale-token
protection, external-fact capacities, and exact outcome cases remain
Specification inputs. The Spike supplied representative incremental costs but
did not establish production capacities or encodings. These are not RFC open
questions unless later evidence shows that no finite viable bound fits the
Signal Analyzer.

## Deferred and Follow-up Work

- [SPIKE-003](../spikes/spike-003-portable-observable-reference-state-feasibility.md)
  supplies completed evidence for the representation and instrumentation
  questions. It does not establish production API, storage, or architecture.
- [FW-019](../future-work/fw-019-fine-grained-observable-dependency-tracking.md)
  captures property-level dependency tracking and selective subtree
  reevaluation for a later Exploration, including transparent runtime-specific
  optimization and optional add-on forms. Revisit if measured complete-root
  work misses an accepted target requirement or a later accepted high-load or
  UI-rich feature needs selective observation.
- [FW-017](../future-work/fw-017-public-binding-abstraction.md) keeps public
  `Binding`, externally owned observation, and binding-dependent controls out
  of this MVP feature. Revisit only through its existing concrete triggers.

General reactive streams, persistence, undo, distributed state, background
synchronization, arbitrary observer graphs, animation, explicit client
identity, and retained view lifecycle remain outside Proposal 005. They do not
gain roadmap or implementation status through this RFC.

## Decision Summary

If review supports the proposed direction, the approved RFC is expected to
produce separate ADR candidates for:

1. structurally owned observable reference state, including preservation,
   initializer, replacement, publication-committed removal, and one-owner
   registration semantics;
2. model-owned change signaling with coarse owner-level dirtiness,
   complete-root MVP reevaluation, and RFC-004 serialized publication; and
3. profile-equivalent dynamic and bounded generated/static realization,
   including physical contract placement and deterministic state/registration
   failure behavior.

These are candidate extractions only. This draft does not accept them,
authorize implementation, or select exact APIs and capacities.

## References

- [PROPOSAL-005: Observable Reference State](../proposals/proposal-005-observable-reference-state.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [MVP Milestones](../roadmap/MVP_MILESTONES.md)
- [RFC-001: Signal Analyzer Application Architecture](rfc-001-signal-analyzer-application-architecture.md)
- [RFC-002: GiftUI MVP Layered Architecture](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](rfc-005-failure-diagnostics-propagation.md)
- [ADR-004: Portable Fixed Signal Analyzer Presentation](../adrs/adr-004-portable-fixed-signal-analyzer-presentation.md)
- [ADR-005: Semantic, Layout, and Render Boundary](../adrs/adr-005-semantic-layout-render-boundary.md)
- [ADR-006: Shared Semantics Across Runtime Profiles](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-007: Integration Ownership and Host Composition](../adrs/adr-007-integration-ownership-and-host-composition.md)
- [ADR-008: Module Dependency Graph and MVP Package Topology](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [ADR-011: Serialized Run Cycle and Semantic Publication](../adrs/adr-011-serialized-run-cycle-and-publication.md)
- [ADR-014: Bounded Cross-Layer Outcome Meaning](../adrs/adr-014-bounded-cross-layer-outcomes.md)
- [ADR-015: Layered Failure Disposition Ownership](../adrs/adr-015-layered-failure-disposition.md)
- [ADR-016: Non-Authoritative Diagnostic Projection](../adrs/adr-016-non-authoritative-diagnostics.md)
- [SPEC-001: Signal Analyzer Reference Application](../specs/spec-001-signal-analyzer-reference-application.md)
- [GiftUI Embedded Layer Inventory](../GiftUI_Embedded_Layer_Inventory.md)
- [GiftUI Runtime Profile Migration Plan](../GiftUI_Runtime_Profile_Migration_Plan.md)
- [Legacy GiftUI Framework Specification](../GiftUI_Framework_Spec.md)
