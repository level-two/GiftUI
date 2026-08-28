---
id: SPEC-015
feature: giftui-mvp-architecture
title: MVP Target-Host Configuration Contract
status: approved
authors:
  - codex
created: 2026-08-28
updated: 2026-08-28
proposal:
  - PROPOSAL-002
  - PROPOSAL-003
  - PROPOSAL-004
  - PROPOSAL-005
  - PROPOSAL-006
related_rfcs:
  - RFC-001
  - RFC-002
  - RFC-003
  - RFC-004
  - RFC-005
  - RFC-006
  - RFC-008
  - RFC-009
  - RFC-011
related_adrs:
  - ADR-001
  - ADR-003
  - ADR-004
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-012
  - ADR-015
  - ADR-016
  - ADR-017
  - ADR-018
  - ADR-019
  - ADR-020
  - ADR-023
  - ADR-026
  - ADR-027
  - ADR-031
  - ADR-033
related_specs:
  - SPEC-001
  - SPEC-003
  - SPEC-004
  - SPEC-005
  - SPEC-009
  - SPEC-010
  - SPEC-011
  - SPEC-012
  - SPEC-013
  - SPEC-014
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-015: MVP Target-Host Configuration Contract

> **Approval status:** This is the approved Wave 7 `HOST-CONFIGURATION`
> contract from the MVP Specification Portfolio. Its reusable prerequisites
> are approved. SPEC-001 was subsequently reconciled against this contract and
> explicitly approved; neither Specification redefines the other's ownership.

## Summary

This Specification defines the one immutable composition root that joins a
GiftUI runtime profile, capability resolution, exact text resources, a raster
backend endpoint, normalized input, wake and pacing integration, the Signal
Analyzer fact and action domains, root observable-model access, and total
failure policy into each of the four MVP target hosts.

It freezes deterministic startup order, structural graph validation, the
independent conjunctive Canvas-capacity and `rasterPresentation` gates,
immutable action/model binding, bounded pacing, operational-health handling,
teardown, and hardware-free conformance fixtures. It does not move platform
mechanics into portable Presentation or claim connected-hardware conformance.

## Scope

This Specification covers:

- target-host configuration for macOS dynamic, macOS static, Raspberry Pi 1 /
  Linux dynamic, and nRF52840 static;
- exact component-role cardinality and dependency direction;
- immutable configuration values and startup validation reports;
- runtime-profile storage audit consumption;
- exact text-resource, endpoint, surface, capability, and workload joins;
- one Signal Analyzer action domain, handler, root model target, and fact
  admission domain;
- one normalized input source family and one runtime wake integration;
- finite frame pacing and retryable-refusal policy;
- total residual failure policy and optional diagnostic projection;
- quiescence, observation shutdown, and complete graph reconstruction; and
- hardware-free four-preset fixtures plus later connected-target evidence.

MVP inclusion is required to assemble the same portable Signal Analyzer
presentation across the four validation configurations in `docs/MVP_SCOPE.md`.
Without this contract, approved reusable modules cannot establish that their
limits, lifetimes, resources, actions, capabilities, and policies describe one
coherent executable stack.

## Goals

- Make every cross-owner startup invariant explicit and fail closed before the
  first run cycle.
- Preserve one portable Presentation and equivalent observable transcripts
  across both runtime profiles and all four target hosts.
- Keep platform, backend, driver, transport, clock, scheduler, and hardware
  identity at the composition boundary.
- Provide finite production configuration and policy inputs with reproducible
  evidence.
- Permit an implementation planner to construct the four hosts without
  inventing ownership, startup order, or recovery behavior.

## Non-goals

- Adding public `GiftUI` declarations or target-selection branches to portable
  Presentation.
- Redefining focused contracts owned by SPEC-003 through SPEC-014.
- Creating a service locator, dependency-injection framework, open capability
  registry, ambient platform lookup, or platform-owned vertical stack.
- Live mutation of the component graph, surface extent, capability snapshot,
  runtime profile, action domain, or production capacities.
- Selecting concrete macOS window-system APIs, Linux device paths, PiScreen
  transports, nRF52840 peripherals, GPIO acquisition, or board pin mappings.
- Treating diagnostic delivery as semantic control.
- Claiming Raspberry Pi or nRF52840 connected-hardware conformance from host,
  simulator, compile, link, or recording fixtures.

## Dependencies

SPEC-004, SPEC-012, SPEC-013, and SPEC-014 are the direct Wave 7 prerequisites
and are approved. SPEC-003, SPEC-005, and SPEC-009 through SPEC-011 supply the
failure, resource, execution, observable, and interaction values joined here.
All ADRs listed in metadata are accepted. ADR-002 and ADR-013 are superseded
and are not authority.

SPEC-001 is the approved downstream application integration contract. Its fixed
four-channel workload, six-action domain, 250-millisecond cadence, fact-storage
shape, 240 x 240 Pi fixture, and 480 x 320 nRF52840 fixture are authoritative
application inputs. SPEC-015 approval authorizes only the reusable host-
assembly contract and the four configuration obligations defined here;
SPEC-001 approval authorizes the application contract that consumes them.

## Related ADRs

- ADR-001 places the Signal Analyzer's Domain, Data, Presentation, and concrete
  target composition in their inward dependency order.
- ADR-003 supplies the four-channel, 10-Hz-per-channel, 80-transition-per-
  second workload bound used by the admission-service proof.
- ADR-004 supplies the fixed portable hierarchy, six controls, and
  250-millisecond presentation cadence used by the host workload manifest.
- ADR-006 requires profile-equivalent semantics below different storage and
  dispatch strategies.
- ADR-007 and ADR-008 place complete-stack knowledge in an acyclic target-host
  composition root while keeping `GiftUI` the sole portable import.
- ADR-012 requires latest-revision recovery intent, finite host pacing, and a
  terminal unavailable state.
- ADR-015 and ADR-016 require total residual policy after mandatory effects and
  make diagnostics optional and non-authoritative.
- ADR-017 through ADR-020 separate structural selection, immutable capability,
  policy, and health and require bounded host-side `rasterPresentation`
  resolution.
- ADR-023 requires the host to own one exact immutable compatible text-resource
  package for the runtime lifetime.
- ADR-026 requires bounded profile-equivalent observable storage below the
  portable source surface.
- ADR-027 requires a target-composed bounded Presentation-fact adapter between
  the application executor and GiftUI mutation domain.
- ADR-031 requires independent conjunctive Canvas structural-capacity and
  `rasterPresentation` startup gates.
- ADR-033 requires one immutable typed action domain and handler bound to the
  current root observable-model generation.

## Terminology

**Host preset**
: One immutable description of a supported profile, component graph, workload,
  resources, policies, and external integration contracts.

**Structural gate**
: Startup validation of graph shape, role cardinality, profile storage, and
  workload-to-capacity relations. It does not establish semantic capability.

**Capability gate**
: SPEC-004 resolution of all four `rasterPresentation` contributions into one
  immutable effective value. It does not establish Canvas producer capacity.

**Assembly report**
: The bounded immutable success transcript retained for one host lifetime or
  the first deterministic validation failure returned before construction.

**Application opportunity**
: Serialized entry on the Signal Analyzer application executor for source,
  repository, use-case, and admission-adapter work.

**Runtime opportunity**
: A serialized call to SPEC-013's `runOpportunity()` after a wake request and
  host pacing permit it. Wake callbacks never call it synchronously.

**Admission service window**
: The half-open interval beginning when the first compact fact becomes pending
  after the preceding seal and ending when the host begins the next runtime
  opportunity. It is bounded independently from the minimum frame interval.

**Workload manifest**
: The immutable, inspectable value that records every application-derived
  semantic, layout, render, Drawing, action, fact, and input count used to prove
  one preset's production limits before owner construction.

## Public Contract

This Specification adds no public API to `GiftUI`. Portable Presentation MUST
compile with only `import GiftUI` and MUST NOT name a host preset, runtime
profile, capability snapshot, backend, resource package, input adapter,
executor, scheduler, platform, driver, transport, or hardware target.

For equivalent normalized facts, actions, pointer events, resources, limits,
and endpoint scripts, all four host fixtures MUST produce equal semantic,
layout, render-operation, action-dispatch, failure, and publication
transcripts. Pixel encoding and physical delivery may differ only as permitted
by the selected approved backend contracts.

Changing any immutable preset field requires teardown and construction of a
new host. No portable client may observe or request live reconfiguration.

## Module Contract

`GiftUIHostConfiguration` owns the package SPI in this Specification, pure
validation, immutable assembly reports, the owner adapters that join focused
contracts, and common four-preset recording fixtures. It may import the
approved contract-owner modules required to compose them. It MUST NOT own
portable semantic, layout, render, drawing, capability, backend, observable,
interaction, or execution behavior.

Each executable target owns one composition root outside portable
Presentation. It may import `GiftUIHostConfiguration` and its selected concrete
runtime, resource, raster, surface, display, input, application-executor,
scheduler, driver, transport, OS/RTOS, HAL, and hardware integrations. No
selected component may import the executable or host preset.

`SignalAnalyzerDomain`, `SignalAnalyzerData`, and
`SignalAnalyzerPresentation` MUST NOT import `GiftUIHostConfiguration` or a
concrete host. `GiftUIRuntimeCore`, focused owners, capabilities, resource
owners, and backend owners preserve the import prohibitions in their approved
Specifications.

The host is the first and only owner allowed to join:

- profile storage with a concrete endpoint;
- focused-owner results with SPEC-003 failure policy;
- a candidate action record with the root model target generation;
- component-owned capability contributions with host resource policy;
- application callbacks with typed fact admission; and
- wake reasons with platform scheduling and pacing.

## Types / APIs

The following declarations are package SPI. Concrete static hosts MAY generate
specialized equivalents with the same values and behavior.

```swift
package enum MVPHostKind: UInt8, Equatable, Sendable {
    case macOSDynamic = 0
    case macOSStatic = 1
    case raspberryPiDynamic = 2
    case nrf52840Static = 3
}

package enum HostComponentRole: UInt8, Equatable, Sendable {
    case runtimeProfile = 0
    case textResourcePackage = 1
    case renderProducerContribution = 2
    case rasterBackendContribution = 3
    case surfaceDisplayContribution = 4
    case hostResourcePolicyContribution = 5
    case rasterEndpoint = 6
    case applicationExecutor = 7
    case signalSource = 8
    case signalRepository = 9
    case useCaseSet = 10
    case factAdmission = 11
    case actionDomain = 12
    case actionHandler = 13
    case rootModelTarget = 14
    case normalizedInput = 15
    case wakeRequester = 16
    case residualPolicy = 17
}

package struct HostComponentRoleSet: OptionSet, Equatable, Sendable {
    package let rawValue: UInt32
    package init(rawValue: UInt32)
    package init(_ role: HostComponentRole)
}

package struct HostComponentRecord: Equatable, Sendable {
    package let role: HostComponentRole
    package let dependencies: HostComponentRoleSet
}

package protocol HostComponentGraphView: ~Copyable {
    borrowing var count: UInt8 { get }
    borrowing func record(at index: UInt8) -> HostComponentRecord?
}

package struct HostPacingPolicy: Equatable, Sendable {
    package let minimumFrameIntervalMicroseconds: UInt32
    package let maximumFactServiceLatencyMicroseconds: UInt32
    package let minimumAcceptedTransitionSpacingMicroseconds: UInt32
    package let maximumTransitionFactsPerServiceWindow: UInt16
    package let maximumBootstrapFactsPerServiceWindow: UInt8
    package let maximumActionInducedFactsPerServiceWindow: UInt8
    package let maximumRetryableRefusals: UInt8
    package init?(minimumFrameIntervalMicroseconds: UInt32,
                  maximumFactServiceLatencyMicroseconds: UInt32,
                  minimumAcceptedTransitionSpacingMicroseconds: UInt32,
                  maximumTransitionFactsPerServiceWindow: UInt16,
                  maximumBootstrapFactsPerServiceWindow: UInt8,
                  maximumActionInducedFactsPerServiceWindow: UInt8,
                  maximumRetryableRefusals: UInt8)
}

package enum HostResidualPolicyContext: UInt8, Equatable, Sendable {
    case startupValidation = 0
    case activation = 1
    case presentationBackpressure = 2
    case presentationRetryableRefusal = 3
    case presentationUnavailable = 4
    case containedCandidateFailure = 5
    case staleInputOrRegistration = 6
    case backendOperationalFailure = 7
    case safetyNotProven = 8
}

package struct SignalAnalyzerHostCardinality: Equatable, Sendable {
    package let actionCaseCount: UInt16
    package let rootModelLocationCount: UInt16
    package let activeRegistrationCount: UInt16
    package let stagedAssociationCount: UInt16
    package let snapshotFactCapacity: UInt16
    package let compactFactCapacity: UInt16
    package let reservedFailureFactCapacity: UInt16
    package let normalizedInputSourceCapacity: UInt16
}

package struct SignalAnalyzerDrawingWorkload: Equatable, Sendable {
    package let canvasOccurrences: UInt16
    package let maximumLivePathPoints: UInt16
    package let maximumLivePathSubpaths: UInt16
    package let submittedStrokes: UInt16
    package let snapshottedPoints: UInt16
    package let snapshottedSubpaths: UInt16
    package let normalizedStrokeOperations: UInt16
    package let greatestLineWidth: GeometryScalar
    package let staticCallableCases: UInt16?
    package let maximumStaticCaptureBytes: UInt16?
}

package struct SignalAnalyzerHostWorkload: Equatable, Sendable {
    package let schemaVersion: UInt16
    package let requiredRuntimeLimits: RuntimeProfileLimits
    package let semanticNodeOccurrences: UInt16
    package let layoutScopeOccurrences: UInt16
    package let positionedGlyphCount: UInt16
    package let ordinaryRenderOperations: UInt16
    package let inputEventsPerOpportunity: UInt16
    package let semanticActionsPerOpportunity: UInt16
    package let completionFactsPerOpportunity: UInt16
    package let drawing: SignalAnalyzerDrawingWorkload
}

package struct HostStructuralConfiguration: Equatable, Sendable {
    package let kind: MVPHostKind
    package let profile: RuntimeProfileKind
    package let runtimeLimits: RuntimeProfileLimits
    package let runtimeAudit: RuntimeStorageAudit
    package let cardinality: SignalAnalyzerHostCardinality
    package let workload: SignalAnalyzerHostWorkload
    package let pacing: HostPacingPolicy
}

package struct HostActionModelConfiguration: Equatable, Sendable {
    package let firstActionCode: UInt16
    package let lastActionCode: UInt16
    package let handlerCount: UInt8
    package let rootModelTargetCount: UInt8
    package let maximumNonTransitionPublicationsPerAction: UInt8
}

package struct HostInputWakeConfiguration: Equatable, Sendable {
    package let normalizedInputSourceCount: UInt16
    package let targetLocalPresentationGateCount: UInt8
    package let wakeRequesterCount: UInt8
    package let applicationAndMutationDomainsAreDistinct: Bool
    package let wakeRequesterIsNonReentrant: Bool
}

package struct HostEndpointConfiguration: Equatable, Sendable {
    package let effectivePresentation: EffectiveRasterPresentation
    package let descriptor: RasterSurfaceDescriptor
    package let payloadLimits: RasterPayloadLimits
    package let surfaceWritableCapacityBytes: UInt32
    package let displaySubmissionLifetime: SubmissionLifetime
    package let displayHandoff: SubmissionHandoff
    package let displayMaximumInFlightPayloads: UInt8
    package let displayMaximumInFlightBytes: UInt32
    package let textRasterRealization: RasterRealizationID
    package let healthOwnerCount: UInt8
    package let endpointAndDisplayShareHealthOwner: Bool
}

package protocol MVPHostResidualPolicyTable: ~Copyable {
    borrowing var fatalHookIsAvailable: Bool { get }
    borrowing func allowed(
        for context: HostResidualPolicyContext
    ) -> GiftUIAllowedDispositions
    borrowing func selection(
        for context: HostResidualPolicyContext
    ) -> GiftUIResidualDisposition
}

package enum HostValidationStage: UInt8, Equatable, Sendable {
    case graph = 0
    case runtimeProfile = 1
    case textResources = 2
    case workload = 3
    case capability = 4
    case endpoint = 5
    case actionAndModel = 6
    case inputAndWake = 7
    case policy = 8
}

package enum HostConfigurationError: Equatable, Sendable {
    case duplicateRole(HostComponentRole)
    case missingRole(HostComponentRole)
    case invalidGraph
    case profileMismatch
    case invalidRuntimeProfile(RuntimeProfileValidationError)
    case invalidTextResources(TextResourceValidationError)
    case invalidWorkload
    case insufficientWorkloadCapacity
    case capabilityUnavailable(RasterPresentationUnavailable)
    case invalidEndpointDescriptor
    case invalidActionDomain
    case invalidModelTarget
    case invalidInputIntegration
    case invalidWakeIntegration
    case invalidPacingPolicy
    case incompleteFailurePolicy
    case arithmeticOverflow
    case invariantViolation
}

package struct HostAssemblyReport: Equatable, Sendable {
    package let kind: MVPHostKind
    package let profile: RuntimeProfileKind
    package let storageAudit: RuntimeStorageAudit
    package let capabilitySnapshot: CapabilitySnapshot
    package let effectivePresentation: EffectiveRasterPresentation
    package let drawingPlanOperationLimit: UInt16
    package let minimumSinkOperationCapacity: UInt16
    package let cardinality: SignalAnalyzerHostCardinality
    package let minimumFrameIntervalMicroseconds: UInt32
    package let maximumFactServiceLatencyMicroseconds: UInt32
    package let minimumAcceptedTransitionSpacingMicroseconds: UInt32
    package let maximumCompactFactsPerServiceWindow: UInt16
    package let maximumRetryableRefusals: UInt8
}

package enum HostValidationResult: Equatable, Sendable {
    case valid(HostAssemblyReport)
    case invalid(stage: HostValidationStage, error: HostConfigurationError)
}

package enum MVPHostLifecycleState: UInt8, Equatable, Sendable {
    case valid = 0
    case activating = 1
    case active = 2
    case failed = 3
    case quiescing = 4
    case quiescent = 5
}

package enum HostActivationResult<Failure: Equatable & Sendable>:
    Equatable, Sendable
{
    case active
    case failure(Failure)
}

package enum HostOpportunityResult: Equatable, Sendable {
    case cycle(RunCycleResult<RuntimeOwnerFailure>)
    case invalidLifecycle
}

package protocol MVPHostInstance: ~Copyable {
    associatedtype ActivationFailure: Equatable & Sendable
    borrowing var lifecycleState: MVPHostLifecycleState { get }
    borrowing var assemblyReport: HostAssemblyReport { get }
    mutating func activate() -> HostActivationResult<ActivationFailure>
    mutating func runOpportunity() -> HostOpportunityResult
    mutating func teardown()
}

package protocol MVPHostConfigurationValidator: ~Copyable {
    associatedtype ComponentGraph: HostComponentGraphView
    associatedtype ResidualPolicyTable: MVPHostResidualPolicyTable
    borrowing var structuralConfiguration: HostStructuralConfiguration { get }
    borrowing var componentGraph: ComponentGraph { get }
    borrowing var textResourceValidation: TextResourceValidationResult { get }
    borrowing var capabilityRequirement: RasterPresentationRequirement { get }
    borrowing var capabilityContributions: RasterPresentationContributions { get }
    var capabilityWorkspace: RasterPresentationResolverWorkspace { get set }
    borrowing var endpoint: HostEndpointConfiguration { get }
    borrowing var actionAndModel: HostActionModelConfiguration { get }
    borrowing var inputAndWake: HostInputWakeConfiguration { get }
    borrowing var residualPolicyTable: ResidualPolicyTable { get }
    mutating func validate() -> HostValidationResult
}

package protocol MVPHostResidualPolicy: GiftUIResidualFailurePolicy
where Context == HostResidualPolicyContext {}
```

Each first-party preset exposes one concrete construction function with two
phases: it constructs its concrete validator from the exact inputs in the
following table, calls `validate()` once, and, only for `.valid(report)`,
constructs one concrete `MVPHostInstance` whose `assemblyReport` equals that
report. The function returns the first `HostValidationResult` on failure and
does not expose an instance. `ActivationFailure` is the preset's finite inline
sum of exact focused activation errors; it preserves the originating payload
until SPEC-003 mapping and contains no existential, reference, closure, string,
or diagnostic payload. A host instance is the only API that may activate,
enter `runOpportunity()`, or tear down the assembled owners.

Every role in `HostComponentRole` is required exactly once. A diagnostic
projector is optional, is not a component role, and cannot participate in
validation or correctness. `HostComponentRoleSet` uses bit
`1 << role.rawValue`; bits `18...31` are invalid. `HostComponentGraphView`
enumerates the exact compiler-visible direct dependency records of one preset.
Production views return exactly eighteen records. They are ordered by role raw
value, contain no self-edge or unknown bit, contain no dependency prohibited by
the approved package/module contracts, and form an acyclic graph. A missing,
duplicate, out-of-order, truncated, cyclic, upward, or unknown record is a
graph-stage failure before any later accessor is evaluated.

A concrete validator receives immutable descriptors and inert factories
through one initializer or generated construction function owned by its host.
That surface MUST require the following inputs and MUST retain them without
constructing or starting the corresponding live owner:

| Input | Required validation projection |
| --- | --- |
| component factories | one `HostComponentGraphView` record per required role |
| runtime profile storage factory | selected profile, limits, and one exact audit |
| text package factory | package, selected realization, descriptor, and exact `TextResourceValidationResult` |
| four capability contributor factories | exact requirement, role-addressed contributions, and two-candidate workspace |
| endpoint factory | effective value, surface descriptor, payload limits, text realization, and health-owner identity |
| application factories | source minimum transition spacing, maximum callbacks per action, repository/use-case callback bounds, executor limits, admission adapter, action domain/handler, and root-model descriptors |
| input and wake factories | one normalized source, one target-local gate, one non-reentrant requester, and distinct logical domains |
| policy factory | one finite table enumerating every `HostResidualPolicyContext` plus fatal-hook availability |

`HostEndpointConfiguration` is the complete inert endpoint-factory projection.
Its effective value equals the resolver result. Its descriptor, writable
capacity, payload limits, display lifetime/handoff, in-flight count/bytes, and
text realization satisfy every exact SPEC-014 construction relation. Its text
realization is the realization accepted by the stage-2 resource validation.
`healthOwnerCount == 1` and `endpointAndDisplayShareHealthOwner == true`; no
second mutable health record is permitted. The live endpoint constructed after
validation MUST expose values equal to this projection before its first offer;
any difference is SPEC-014's construction invariant.

Only negative graph fixtures may pass a graph view containing missing,
duplicate, out-of-order, cyclic, upward, or unknown records. No production
initializer accepts an untyped collection, service locator, ambient lookup, or
already started owner. `validate()` is the single pure validation entry point
and is callable exactly once per validator lifetime. A second call returns
`.invalid(stage: .graph, error: .invariantViolation)` without reading a later
projection or invoking any owner.

The selected `signalSource` constructor MUST receive its monotonic clock,
scheduling, transport, or interrupt dependencies explicitly through
source-owned concrete contracts. Those contracts remain below
`SignalDataSource`; they are not a cross-host service API or another component
role. Validation proves their presence from the generated or compiler-visible
construction graph and performs no ambient lookup or clock/scheduler call.

`HostPacingPolicy` is valid only when all three time values are nonzero, every
fact bound is nonzero, the checked sum of its three per-window fact bounds is
representable as `UInt16` and no greater than
`cardinality.compactFactCapacity`, and the refusal limit is in `1...255`.
Every first-party Signal Analyzer preset MUST use these exact values:

| Pacing field | Value |
| --- | ---: |
| minimum frame interval | 250,000 microseconds |
| maximum compact-fact service latency | 250,000 microseconds |
| minimum accepted transition spacing per channel | 50,000 microseconds |
| transition-derived facts per service window | 20 |
| activation/bootstrap facts per service window | 2 |
| action-induced facts per service window | 6 |
| maximum retryable refusals | 3 |

The maximum conforming production burst is therefore the checked sum
`20 + 2 + 6 == 28`, leaving four slots of fixed storage margin without relying
on that margin for correctness. Twenty is the maximum produced by four
channels whose accepted transitions are at least 50 milliseconds apart per
channel. Bootstrap consists of exactly the capture snapshot and acquisition-
state current-value callbacks required when observation starts. Execution
admits at most six semantic actions per opportunity; each action may
synchronously cause at most one non-transition repository publication, while
any source transition caused by Start remains in the 20-fact transition
bucket. A first-party source, repository, or use-case adapter that can exceed a
category bound is incompatible with the preset and its declared factory
projection is rejected before activation; the host does not resize storage or
spend the four-slot margin to legitimize an unbounded producer. A producer that
violates its successfully validated projection after activation causes a
runtime-scoped invariant with safety not proven.

The first accepted compact fact after a seal starts one admission service
window. The wake requester returns without synchronous runtime entry, and the
host MUST begin the next `runOpportunity()` no later than 250,000 microseconds
after that fact was accepted. The opportunity seals every fact accepted before
its seal; a fact arriving after the seal begins a later window. The minimum
frame interval may delay derivation until the same deadline but MUST NOT extend
the fact-service deadline. Thus every conforming 28-fact boundary burst fits
the 32-slot ring. Separate admission fixtures prove all 32 physical compact
slots accept and physical fact 33 receives SPEC-009's explicit bounded
rejection; producer fixtures prove a category excess is rejected as an
incompatible host workload. The interval bounds semantic derivation and frame
offers, not physical scan-out. The third retryable refusal exhausts the policy;
no fourth offer is scheduled for that pending intent.
`HostAssemblyReport.maximumCompactFactsPerServiceWindow` is exactly `28`; the
separate `cardinality.compactFactCapacity` remains exactly `32`.

Every first-party cardinality MUST contain exactly these values:

| Field | Value |
| --- | ---: |
| action cases | 6 |
| root model locations | 1 |
| active registrations | 1 |
| staged associations | 1 |
| snapshot fact slots | 1 |
| compact fact slots | 32 |
| reserved failure fact slots | 1 |
| normalized input sources | 1 |

Host kind and profile are fixed:

| Host kind | Runtime profile |
| --- | --- |
| `macOSDynamic` | `dynamic` |
| `macOSStatic` | `static` |
| `raspberryPiDynamic` | `dynamic` |
| `nrf52840Static` | `static` |

These values configure focused limits; they do not create a second storage
owner. The six action codes are exactly `0...5`. Decode is total, and any other
code is invalid. The root target is the one structurally owned
`SignalAnalyzerViewModel` location. The host installs exactly one immutable
`SignalAnalyzerActionHandler`; neither the record nor pointer capture retains
the handler or model.

Every first-party preset carries a `SignalAnalyzerHostWorkload` with
`schemaVersion == 1`. Its `requiredRuntimeLimits` is the exact, complete
`RuntimeProfileLimits` value derived before Swift compilation from one checked-
in descriptor of the fixed portable hierarchy and application workload. The
descriptor, generated manifest, and generated preset values are conformance
inputs and MUST be reviewable. Validation requires
`structuralConfiguration.runtimeLimits == workload.requiredRuntimeLimits`;
there is no independently chosen headroom and no omitted or defaulted
`RuntimeProfileLimits` leaf.

The generator counts every semantic occurrence, layout scope, positioned
glyph, ordinary render operation, input event, semantic action, completion
fact, Canvas occurrence, live Path element, snapshotted Drawing element, and
static callable/capture requirement using the owning approved Specification's
counting rules. It then constructs every nested semantic, layout, render,
render-sink, execution, observable-state, interaction, Drawing, and optional
static-Canvas limit from those counts. Hierarchy- and application-derived
counts MUST be value-equal across all four manifests. A limit may differ only
when its owning counting rule consumes a preset's immutable extent, payload
bound, or runtime profile; `staticCanvas` is non-`nil` only for static presets.
The paired macOS manifests use the same extent, so every common-profile leaf is
equal. A generated value at the required limit succeeds; the same fixture with
any independently varied leaf below its requirement fails at `.workload` with
`.insufficientWorkloadCapacity`.

The contained runtime limits MUST additionally satisfy these production
relations:

- observable locations, registrations, and staged associations each equal
  one;
- Interaction action and hit-region capacities each equal six;
- Execution committed-action capacity is at least six and active input-source
  capacity equals one;
- `workload.semanticActionsPerOpportunity` equals six;
- `actionAndModel.maximumNonTransitionPublicationsPerAction` equals one;
- Execution state-change-fact capacity is at least 34, covering the physically
  separate 1/32/1 fact stores in one sealed sequence namespace;
- every fact store has concrete storage for its exact cardinality and no
  ordinary fact may consume the reserved failure slot; and
- every remaining Execution, semantic, layout, render, Drawing, and static-
  Canvas limit equals the corresponding generated
  `workload.requiredRuntimeLimits` value.

Per-cycle input-event and semantic-action limits do not claim that a user can
generate only six events. Their exact nonzero values are recorded in the
manifest. Submission at the configured finite bound succeeds; the first excess
follows SPEC-009's exact capacity refusal and source-sequence cancellation
behavior. Presets MUST test each exact value and may not increase one
dynamically after startup.

Every first-party preset MUST provision at least five Canvas occurrences and
five submitted strokes. The canonical capacity fixture uses one grid Canvas
with one stroke containing twelve two-point subpaths and four trace Canvases
with one stroke each. This fixture is a conservative capacity proof, not a
portable hierarchy requirement. At the admitted 20 transitions per channel
in a five-second visible window, one trace requires at most 202 points and one
subpath. The combined declared minima are therefore:

| Drawing value | Minimum |
| --- | ---: |
| Canvas occurrences | 5 |
| greatest simultaneously live Path points | 202 |
| greatest simultaneously live Path subpaths | 12 |
| submitted strokes / normalized stroke operations | 5 |
| snapshotted points | 832 |
| snapshotted subpaths | 16 |

The host's `ordinaryRenderOperations` is generated from the complete fixed
portable hierarchy using the approved SPEC-008 counting rules and is checked
into each preset fixture. It MUST be nonzero and identical across all four
presets. `ordinaryRenderOperations + 5` MUST use checked arithmetic and fit
the runtime render limit, drawing limit, render-sink limit, and endpoint's
reported lower bound. A different value between profiles or hosts is
`invalidWorkload`, not a target customization.

Static presets require nonzero callable-case and capture-byte values and exact
equality with the generated table metadata. Dynamic presets require both
optional values to be `nil`. `runtimeLimits.maximumOrdinaryRenderOperations`
MUST equal the workload's ordinary operation count. All Drawing-limit fields
must admit the declared minima; equality succeeds.

The macOS dynamic and static fixtures use the same logical extent and exact
resource package, and must resolve equal `EffectiveRasterPresentation` values
apart from storage-mechanism evidence. The Raspberry Pi fixture is 240 x 240
and admits a full-width 16-row RGB565 region. The nRF52840 fixture is 480 x 320
and admits a 480 x 4 RGB565 region, 960-byte rows, and exactly 3,840 raster,
payload, and in-flight bytes with one slot and no full framebuffer. A concrete
macOS window extent is a host input, but the paired dynamic/static fixtures
MUST use the same immutable extent and reassemble after an extent change.

## Behavior

### Construction and validation

Host validation is pure, bounded, non-reentrant, and stops at the first failure
in `HostValidationStage` raw-value order:

1. prove exactly one owner for every required graph role and the approved
   acyclic import/dependency direction;
2. require the preset's profile to equal the selected storage profile, consume
   one successful SPEC-013 audit, and compare every immutable limit;
3. consume one exact `TextResourceValidationResult` for the selected SPEC-005
   package and realization, reject its precise local error, and retain the
   successfully validated package for the host lifetime;
4. validate the complete workload manifest and every
   `requiredRuntimeLimits` leaf against producer, plan, runtime, render, sink,
   observable, interaction, input, action, fact, and Drawing capacities;
5. collect exactly four SPEC-004 contributions, resolve once, and require
   `rasterPresentation` with all five operation bits;
6. require exact equality between the resolved effective presentation and the
   inert SPEC-014 endpoint-factory projection: surface descriptor, payload
   limits, display lifetime, handoff, text raster realization, and health-owner
   identity;
7. validate the six-case action domain, one total handler, one root target,
   publishable target-generation join, and all fact/observable capacities;
8. validate one normalized pointer integration, its target-local presentation
   gate, one non-reentrant wake requester, and distinct logical application
   and mutation domains; and
9. validate the finite pacing table, total SPEC-003 residual policy, required
   fatal hook availability where selected, and diagnostic independence.

No client body, Canvas closure, model attachment, repository observation,
source start, pointer callback, wake request, run opportunity, backend offer,
policy hook, fatal hook, or diagnostic sink is invoked during validation.
The validator may read every `MVPHostResidualPolicyTable` accessor; those are
pure immutable configuration projections, not a
`GiftUIResidualFailurePolicy.decide` invocation, and MUST have no side effect.
Failure retains no partial host and no borrow. Success retains the immutable
configuration, audit, resource package, snapshot, effective presentation, and
report for the complete host lifetime. No live runtime, endpoint, application,
input, wake, policy, diagnostic, source, repository, handler, or model owner is
constructed until all nine stages succeed.

The Drawing structural gate and capability gate are conjunctive. Capability
success cannot repair insufficient Canvas, Path, plan, ordinary-operation, or
sink storage. Structural success cannot manufacture stroke support, encoding,
extent, lifetime, payload, or in-flight compatibility. Canvas capacity fields
MUST NOT be added to SPEC-004's capability vocabulary.

### Activation

After `.valid(report)`, the preset construction function creates one
`MVPHostInstance` in `.valid`. Its first and only `activate()` call performs
these steps in order:

1. construct but do not start the runtime coordinator and endpoint;
2. construct the application executor, source, repository, use cases,
   admission adapter, model, action handler, target access, and root view;
3. attach the one root model during the first runtime candidate;
4. install the admission adapter as both repository sinks on the application
   executor and accept both immediate current-value facts;
5. make input eligible only after the first accepted physical presentation;
6. start acquisition only through an explicit application opportunity; and
7. service later wake and pacing opportunities through the host loop.

Failure at any step performs mandatory containment, stops observation if it
was installed, prevents input eligibility, quiesces the runtime when it was
constructed, enters `.failed`, and returns the original finite
`ActivationFailure` payload to total policy. Success enters `.active` and
returns `.active`. Calling `activate()` in any state other than `.valid` is a
reentrancy invariant, performs no owner call, and returns that exact invariant
in the preset's activation-failure sum. Activation never substitutes a smaller
UI or alternate target graph.

### Opportunity and pacing

An empty-to-nonempty SPEC-009 wake-reason transition requests one host wake.
The wake integration records pending work and returns without entering the
runtime. The host provides a serialized runtime opportunity at or after the
next permitted 250-millisecond frame boundary and no later than the active
admission service-window deadline. `runOpportunity()` is legal only in
`.active`, where it wraps the coordinator result in `.cycle`. Every other-state
call returns `.invalidLifecycle`, maps as a host reentrancy invariant, and
invokes no runtime owner. Facts remain ordered and are not coalesced; only wake
requests and dirty intent may coalesce.

The host does not begin a runtime opportunity before the next permitted frame
boundary. At that boundary the runtime seals and applies all selected admitted
work and performs its approved mutation, derivation, publication, and offer
sequence. A new revision supersedes older pending presentation intent in
constant space.

Backpressure retains pending intent without incrementing the retryable-refusal
counter and schedules a later paced opportunity. Retryable refusal records the
checked count and schedules a later paced opportunity only while the count is
less than three. Count three marks the required presentation facility
unavailable and quiesces presentation-coupled input. Non-retryable refusal
does so immediately. No recovery replays a fact, action, Canvas closure, plan,
operation stream, or refused payload.

### Input and action dispatch

Concrete input drivers normalize and calibrate outside GiftUI. The host-local
gate attaches the current physical presentation revision and drops stale,
unknown, unavailable, malformed, out-of-order, or over-capacity phases before
runtime admission. Runtime admission independently revalidates provenance.

The runtime joins candidate actions with the publishable root target
generation. Dispatch revalidates identity, action generation, enabled state,
and target generation, borrows the current model for that exact generation,
and synchronously invokes the one handler in mutation phase. The handler may
enter the application executor through the explicit use-case adapter. Any
synchronous repository callback stops at fact admission for a later cycle and
cannot reenter model mutation.

### Operational state and teardown

The capability snapshot, graph, resources, profile, policies, and capacities
remain immutable. Endpoint and display health is mutable operational state and
does not change the snapshot. After presentation responsibility transfers, a
device fault is recorded in health and the one-shot stream is drained as
required by SPEC-014; it cannot become a refusal.

Teardown is explicit, synchronous, idempotent, and ordered:

1. refuse new application delivery and normalized input;
2. stop source delivery and detach both repository observations;
3. cancel pointer sequences and pending host callbacks;
4. quiesce the runtime and complete mandatory active-cycle finalization;
5. retire the root observable registration and committed routing state;
6. release endpoint, resource, backend, display, input, and platform owners;
7. reset profile storage only after quiescence; and
8. invalidate the assembly report's runtime use without reusing identity
   generations.

Restart after terminal unavailability, identity exhaustion, graph change,
resource change, extent change, or policy change constructs a fresh complete
host. It does not reactivate the old runtime.

## State / Lifecycle

```text
validator: unvalidated -> validating -> invalid
                              |
                              +-> valid report -> instance: valid -> activating -> active -> quiescing
                                                                  |             |          |
                                                                  +-> failed    +----------> quiescent
```

`invalid` is terminal for the validator and exposes no host instance. `failed`
and `quiescent` are terminal for an instance. Validation and activation are
non-reentrant. An active host has exactly one runtime, endpoint, resource
package, capability snapshot, root model target, handler, application executor,
wake integration, and policy table.

## Capability Requirements

The host constructs a required `RasterPresentationRequirement` with all five
operation bits, the preset's exact logical extent,
`.synchronousBorrowedOneShot`, admitted canonical encodings and submission
lifetimes, exact finite byte ceilings, and `.required` absence. It inserts
exactly one contribution for render producer, raster backend, surface/display,
and host resource policy and resolves exactly once with a two-candidate
workspace.

Any unavailable result rejects startup and maps through SPEC-004's exact
SPEC-003 condition mapping. Optional absence is not permitted for the Signal
Analyzer. Runtime health never triggers resolution again.

## Backend Requirements

The selected endpoint MUST conform to SPEC-014 and exactly match the resolved
effective value. Hosts expose normalized input as a sibling integration seam;
drivers and backends do not dispatch application actions. The Raspberry Pi
host targets `armv6-unknown-linux-gnueabihf` and MUST verify `armv6l` before
connected deployment. The nRF52840 host targets `nrf52840dk/nrf52840`, uses the
bundled `armv7em-none-none-eabi` module with Cortex-M4F hard-float flags, and
requires VFP calling-convention evidence before a connected flash claim.

Connected deployment, service restart, or board flashing is not performed by
this contract and requires a separate explicit user request.

## Error Handling

Every `HostConfigurationError` retains its associated local payload through
owner mapping. Host-owned validation errors map to a SPEC-003 failure with
`.hostComposition` origin and `.runtime` scope. Focused unavailable/error
payloads retain their owning mappings and are not collapsed to a generic host
error.

Host-owned validation errors use this exact shared-condition mapping:

| Host error | SPEC-003 condition | Containment |
| --- | --- | --- |
| `duplicateRole`, `missingRole`, `invalidGraph`, `profileMismatch` | `invalidValue` | `contained` |
| `invalidWorkload` | `invalidValue` | `contained` |
| `invalidActionDomain`, `invalidModelTarget`, `invalidInputIntegration`, `invalidWakeIntegration`, `invalidPacingPolicy` | `invalidValue` | `contained` |
| `insufficientWorkloadCapacity` | `capacityExhausted` | `contained` |
| `arithmeticOverflow` | `arithmeticOverflow` | `contained` |
| `invalidEndpointDescriptor`, `incompleteFailurePolicy`, `invariantViolation`, repeated validation | `invariantViolation` | `safetyNotProven` |

`invalidRuntimeProfile` preserves SPEC-013's exact mapping.
`capabilityUnavailable` preserves SPEC-004's producer-specific mapping with
`.capability` origin. `invalidEndpointDescriptor` is the pure descriptor form
of SPEC-014's effective-value/component construction mismatch and therefore
uses its exact `.invariantViolation`, `.hostComposition`, `.runtime`,
`.safetyNotProven` mapping even though validation detects it before a live
endpoint is constructed. A mismatch returned by an already constructed
endpoint is the same SPEC-014 invariant, never a host `invalidValue`.

`invalidTextResources(error)` uses SPEC-005's exact target-host adapter mapping:

| `TextResourceValidationError` | SPEC-003 condition | Origin | Scope | Containment |
| --- | --- | --- | --- | --- |
| `unsupportedSchema`, `invalidCount`, `malformedMetrics`, `malformedMapping`, `malformedRasterRecord` | `invalidValue` | `hostComposition` | `runtime` | `contained` |
| `invalidIdentity`, `incompatibleViews`, `integrityMismatch` | `invalidIdentity` | `hostComposition` | `runtime` | `contained` |
| `capacityExceeded` | `capacityExhausted` | `hostComposition` | `runtime` | `contained` |

A focused observable, interaction, Drawing, input, or backend error preserves
its approved owner mapping. Host mapping never changes an owner-selected
condition merely because validation observed it.

`HostOpportunityResult.invalidLifecycle` and repeated `activate()` map to
`.reentrancyViolation`, `.hostComposition`, `.runtime`, and
`.safetyNotProven`. They invoke no assembled owner before mechanical
quiescence and the `safetyNotProven` policy route.

The detecting owner performs mechanical containment, the runtime coordinator
applies mandatory cycle/frame effects, and only then may the host invoke a
total residual policy with a valid allowed set. Policy cannot repair startup,
weaken containment, reinterpret failure as success, retry without the fixed
bound, or mutate capability. A result outside `allowed` or incomplete policy
table is an invariant failure; the host quiesces before an optional fatal hook.

The validator itself never invokes policy. Each first-party policy table is a
generated, exhaustively switched value whose construction proves all nine
contexts before it is supplied to the validator. After `validate()` returns
any ordinary failure other than a policy-table defect, the outer bootstrap
adapter discards all validation projections, constructs the correlated
SPEC-003 outcome, and invokes the already complete table exactly once with
`startupValidation`. A policy-table defect or out-of-allowed result is not
routed through that defective table: the adapter records `.safetyNotProven`,
mechanically quiesces, and invokes the separately configured fatal hook only
when its availability was proven independently.

Host routing is exhaustive at the composition boundary:

| Observed outcome | Host context or no call | Additional precondition |
| --- | --- | --- |
| successful validation, activation, opportunity, offer, or teardown | no policy call | success remains success |
| ordinary validation failure other than a policy-table defect | `startupValidation` | validator has returned and projections are discarded |
| policy-stage defect or invalid policy result | no call through the defective table | mechanical safety quiescence precedes an optional proven fatal hook |
| activation failure | `activation` | activation containment has completed |
| endpoint backpressure | `presentationBackpressure` | latest intent remains pending and refusal count is unchanged |
| retryable refusal with retained count below three | `presentationRetryableRefusal` | latest intent remains pending |
| third retryable refusal, non-retryable refusal, or required presentation loss | `presentationUnavailable` | pending intent is cleared and presentation-coupled input is quiesced |
| candidate failure for which its owning approved contract permits a choice and a prior complete root exists | `containedCandidateFailure` | complete candidate is discarded and prior root is preserved |
| stale observable attachment or stale registration for which its owning contract permits a choice | `staleInputOrRegistration` | stale work is rejected without addressing reused identity |
| post-acceptance backend/display fault | `backendOperationalFailure` | one-shot drain and health update have completed |
| runtime-scoped reentrancy, invariant, or other safety-not-proven failure | `safetyNotProven` | partial work is discarded and no later normal cycle is admitted |
| target-local stale/unknown input gate drop, ordinary pointer cancellation, SPEC-010 contained phase violation, or any focused contract row that says no residual policy call | no policy call | the owning mandatory cancellation or dirty-rederivation effect is final |

An owning approved contract's explicit no-policy row takes precedence over a
host context that could otherwise appear similar. No outcome may route to more
than one row, and a downstream application context may not replace one of
these host-owned routes.

The concrete `MVPHostResidualPolicy` is total over the following table. The
host constructs inputs only after the listed mandatory effects and with the
exact allowed set. Its selected disposition is fixed; no first-party preset
may choose a different row.

| Context | Mandatory state before policy | Allowed | Selection |
| --- | --- | --- | --- |
| `startupValidation` | partial construction discarded; no runtime work admitted | `quiesceAffectedScope` | `quiesceAffectedScope` |
| `activation` | observation/source/input stopped; partial activation contained | `quiesceAffectedScope` | `quiesceAffectedScope` |
| `presentationBackpressure` | candidate aborted; latest intent pending; count unchanged | `requestPacedRetry`, `quiesceAffectedScope` | `requestPacedRetry` |
| `presentationRetryableRefusal` below three | candidate aborted; checked count retained; latest intent pending | `requestPacedRetry`, `quiesceAffectedScope` | `requestPacedRetry` |
| `presentationUnavailable` | pending intent cleared; facility unavailable; input quiesced | `quiesceAffectedScope` | `quiesceAffectedScope` |
| `containedCandidateFailure` with a prior complete root | candidate discarded; prior publication and model preserved dirty as required | `continueOperation`, `quiesceAffectedScope` | `continueOperation` |
| `staleInputOrRegistration` | stale work rejected and affected sequence cancelled; current state preserved | `continueOperation` | `continueOperation` |
| `backendOperationalFailure` after responsibility transfer | stream drained; health updated; input quiesced | `quiesceAffectedScope` | `quiesceAffectedScope` |
| `safetyNotProven` | partial work discarded; no later normal cycle admitted | `quiesceAffectedScope`, `invokeFatalHook` | `quiesceAffectedScope` |

Backpressure uses `attemptOrdinal == 0` and `attemptLimit == 3`; because it
does not consume the refusal budget, every separately constructed
backpressure input uses those same values. Retryable refusal uses the retained
pre-increment count as its ordinal: `0` after the first refusal and `1` after
the second, with limit `3`. The third refusal observes prior ordinal
`2`; retry is no longer allowed, so it constructs no retry input and enters
`presentationUnavailable`.
All non-retry contexts use ordinal `0` and limit `1`. An initial candidate
failure with no prior root is activation failure, not
`containedCandidateFailure`. Application-specific residual contexts and
choices remain owned by the eventual approved SPEC-001 reconciliation; they
must compose with, and cannot weaken, this host table.

Diagnostics are optional bounded projections after authoritative outcome and
health transitions. Disabled, filtered, saturated, dropped, or failing
diagnostics MUST produce identical validation results, policy inputs,
dispositions, action/fact behavior, and user-visible state.

## Performance Requirements

- Validation must use bounded caller-owned or inline storage and perform no
  heap allocation on static presets.
- Capability resolution occurs once; steady-state snapshot access invokes the
  resolver zero times.
- Static construction, steady-state opportunities, action dispatch, fact
  admission, and teardown use no heap allocation, reflection, tasks, threads,
  exceptions, Objective-C runtime, or dynamically growing collection.
- Every first-party preset records exact configured limits, storage-audit
  fields, endpoint and payload bytes, application storage, host-policy bytes,
  stack high-water, linked RAM, and linked flash separately.
- The nRF52840 assembled image must remain within the approved SPEC-004 and
  SPEC-014 aggregate and incremental budgets and report the complete host cost;
  host accounting cannot hide bytes inside another owner.
- Under the 80-fact-per-second workload, facts are admitted without rejection,
  change reports coalesce, and frame derivation is paced at four per second.
- Validation, opportunity, and teardown latency evidence records the compiler,
  optimization mode, target triple, fixture, and repetition method.

## Compatibility

The four host presets are source-level package SPI, not stable ABI or a
persistent configuration format. Static generation may specialize wiring;
dynamic hosts may use bounded references and existentials. Both preserve the
same values, ordering, outcomes, capacities, and portable Presentation.

Legacy platform-owned stacks, ambient lookup, direct sink-to-ViewModel
mutation, closure-retaining portable Button actions, mutable capability
registries, and target-specific reduced presentations are incompatible.

## Testing Requirements

The repository MUST provide `scripts/contracts/run-spec-015.sh`. From the
repository root it runs hardware-free macOS dynamic/static execution fixtures,
Raspberry Pi ARMv6 compile/link fixtures, and nRF52840 Embedded Swift
compile/link fixtures, exits nonzero on failure, and writes generated evidence
only below `.build/spec-015/`.

Required tests include:

- every validation stage success and each missing, duplicate, out-of-order,
  truncated, cyclic, upward, unknown-bit, malformed, mismatched, overflowing,
  and insufficient input, including a proof that no later projection is read;
- generation of all four schema-1 workload manifests from the checked-in
  hierarchy descriptor, exact equality for every `RuntimeProfileLimits` leaf,
  success at each requirement, and failure when each leaf is independently
  lowered or made unequal; a leaf whose lower value is not constructible must
  instead prove that its owning initializer rejects that value;
- all permutations of capability contribution order and exact effective-value
  equality with the selected endpoint;
- independent failure of the Drawing and capability gates;
- every `TextResourceValidationError` with its exact three-way SPEC-005
  condition mapping, plus resource-identity and lifetime mismatch;
- inert endpoint-descriptor mismatch and already-constructed endpoint mismatch,
  both with SPEC-014's exact safety-not-proven mapping and no live-owner call
  during validation;
- dynamic/static graph, limit, action, fact, and transcript equivalence;
- six total action decodes, invalid codes, model replacement, stale target
  generations, pointer cancellation, and reentrant application callbacks;
- same-thread and distinct-executor application/mutation-domain fixtures;
- wake coalescing, 250-millisecond minimum frame pacing, service-window
  deadlines just before, at, and just after 250 milliseconds, accepted 28-fact
  production bursts, independent acceptance of all 32 physical compact slots,
  explicit rejection of physical fact 33 and of each producer-category excess,
  backpressure, refusal counts one through three, supersession, terminal
  unavailability, and no replay;
- every residual-policy routing row, every explicit no-policy row,
  startup-policy timing after validator return, all allowed/selected pairs,
  diagnostic omission, and fault injection;
- construction-function failure without an instance, activation failure at
  every step, illegal-state API calls, and idempotent teardown from every
  instance state;
- exact Pi 240 x 240 and nRF52840 480 x 320 capability/backend joins;
- forbidden-import and portable-source scans; and
- zero-allocation/static-runtime and resource-accounting evidence.

Human approval requires this complete fixture contract, not pre-approval
implementation. The runner, fixture implementations, and passing evidence are
required before the feature may transition to `implemented`, and implementation
work starts only after Spec approval. Connected PiScreen and nRF52840 TFT
display/input checks are later conformance evidence and must name the hardware,
software, transport, and observed architecture separately.

## Acceptance Criteria

- [ ] **HC-001:** Metadata, manifest, portfolio, and every governing upstream
  artifact link SPEC-015 without granting approval to SPEC-001.
- [ ] **HC-002:** Pure validation processes the nine stages in fixed order,
  stops at the first failure, invokes no runtime/client/external behavior, and
  retains no partial assembly; the preset construction function exposes an
  instance only after a valid report.
- [ ] **HC-003:** Graph fixtures prove exactly one owner per role, an acyclic
  dependency graph, `GiftUI` as the sole portable import, and no platform-owned
  semantic stack or ambient lookup.
- [ ] **HC-004:** Each preset consumes one exact successful SPEC-013 audit,
  requires equality with its complete schema-1 workload-derived limits, and
  rejects every independently mismatched profile, limit leaf, storage, static
  Canvas table, or byte total.
- [ ] **HC-005:** The five-Canvas workload proves the 202 live-point, 12 live-
  subpath, five-stroke, 832 plan-point, and 16 plan-subpath minima; generated
  ordinary operation counts are equal across all hosts and fit every producer,
  runtime, render, and sink bound.
- [ ] **HC-006:** Structural Drawing capacity and `rasterPresentation` resolve
  as independent conjunctive gates; neither repairs the other and no Drawing
  capacity enters SPEC-004 vocabulary.
- [ ] **HC-007:** Capability resolution uses exactly four role contributions,
  all five operation bits, immutable required absence behavior, one resolver
  call, and an endpoint exactly equal to the effective value.
- [ ] **HC-008:** One exact compatible text package, metrics view, raster view,
  and realization remain immutable and borrowed only within approved lifetime;
  all nine validation errors preserve SPEC-005's exact mapping.
- [ ] **HC-009:** All presets configure six action cases, one handler, one root
  location/registration/staging record, fact capacities 1/32/1, and one input
  source; every invalid code, stale generation, and replacement race fails
  closed, and no action record or pointer capture retains the host-owned model
  or immutable handler.
- [ ] **HC-010:** Same-thread and distinct-executor fixtures preserve bounded
  fact admission, later mutation, no reentrant model mutation, ordered
  application, and equivalent transcripts.
- [ ] **HC-011:** Wake requests never enter the runtime synchronously; the frame
  interval and maximum fact-service latency are both 250,000 microseconds; the
  exact 20/2/6 production burst fits 32 slots with four-slot margin, all 32
  physical slots accept, and physical fact 33 and each category excess are
  rejected; retryable-refusal attempts terminate on count three, backpressure
  does not increment the count, and no semantic or payload replay occurs.
- [ ] **HC-012:** The total policy matrix runs only after mandatory effects,
  routes each host outcome exactly once, performs every owning no-policy row,
  selects only allowed dispositions, quiesces without consulting a defective
  table, and is unchanged by every diagnostic configuration and fault.
- [ ] **HC-013:** macOS dynamic/static fixtures share extent and effective
  semantics; Pi resolves 240 x 240 with a 240 x 16 RGB565 region; nRF52840
  resolves 480 x 320 with a 480 x 4 region, 960-byte rows, and 3,840-byte
  raster/payload/in-flight bounds without a full framebuffer.
- [ ] **HC-014:** Activation and teardown tests cover every intermediate state,
  prevent stale callbacks/input/reports, retire identities without reuse, and
  require fresh assembly after terminal unavailability or immutable change.
- [ ] **HC-015:** The static preset evidence reports zero prohibited runtime
  dependencies and allocation, plus exact RAM, stack, flash, profile, host,
  application, capability, backend, and staging costs under pinned toolchains.
- [ ] **HC-016:** `scripts/contracts/run-spec-015.sh` runs all hardware-free
  fixtures from the repository root and confines generated evidence to
  `.build/spec-015/`.
- [ ] **HC-017:** Connected-target requirements remain separately labeled
  downstream conformance evidence and no simulator/build result is presented
  as Raspberry Pi or nRF52840 hardware validation.
- [ ] **HC-018:** `MVPHostInstance` activation, opportunity, and teardown calls
  follow the finite lifecycle, reject illegal-state entry without owner calls,
  preserve exact local failure payloads, and expose the validated report.

## Implementation Notes

One small immutable preset value per executable is preferable to a generic
runtime registry. Static presets may be generated alongside typed observable
and Canvas tables, provided generated Swift and its input descriptor are
checked and inspectable. Dynamic presets can instantiate the same logical
records with bounded retained owners.

The exact ordinary render-operation count is emitted by the deterministic
manifest generator from the fixed hierarchy and checked into the four preset
expectations; it is not discovered by executing a client body during host
validation.

## Open Issues

No architectural issue blocks this approved host-configuration contract.
Approved SPEC-001 preserves this contract's fact-burst, failure normalization,
deterministic mock trace, diagnostic, and exact host-fixture alignment.

## Deferred and Follow-up Work

No new deferred item was created. Existing contextual items remain outside MVP
and are not newly related to this Specification:

- FW-006 preserves optional generated target-configuration tooling;
- FW-009 preserves a shared delegated-service foundation until multiple
  approved consumers justify it; and
- FW-018 preserves live surface reconfiguration, which requires a fresh host
  under this MVP contract.

## References

- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [Feature Lifecycle](../engineering/FEATURE_LIFECYCLE.md)
- [Documentation Rules](../engineering/DOCUMENTATION_RULES.md)
- [AI Agent Rules](../engineering/AI_AGENT_RULES.md)
- [SPEC-001](spec-001-signal-analyzer-reference-application.md) (approved downstream application contract)
- [SPEC-003](spec-003-failure-outcomes-and-containment.md)
- [SPEC-004](spec-004-capability-contribution-and-resolution.md)
- [SPEC-005](spec-005-text-resources.md)
- [SPEC-009](spec-009-execution-cycle-and-frame-handoff.md)
- [SPEC-010](spec-010-observable-reference-state.md)
- [SPEC-011](spec-011-interaction.md)
- [SPEC-012](spec-012-canvas-path-stroke-drawing.md)
- [SPEC-013](spec-013-runtime-profiles.md)
- [SPEC-014](spec-014-backend-integration.md)
- [ADR-001](../adrs/adr-001-signal-analyzer-application-boundaries.md)
- [ADR-003](../adrs/adr-003-transition-based-bounded-capture.md)
- [ADR-004](../adrs/adr-004-portable-fixed-signal-analyzer-presentation.md)
- [ADR-006](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-007](../adrs/adr-007-integration-ownership-and-host-composition.md)
- [ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [ADR-012](../adrs/adr-012-bounded-handoff-refusal-recovery.md)
- [ADR-015](../adrs/adr-015-layered-failure-disposition.md)
- [ADR-016](../adrs/adr-016-non-authoritative-diagnostics.md)
- [ADR-017](../adrs/adr-017-capability-and-operational-state-planes.md)
- [ADR-018](../adrs/adr-018-fixture-driven-typed-capabilities.md)
- [ADR-019](../adrs/adr-019-bounded-host-capability-resolution.md)
- [ADR-020](../adrs/adr-020-raster-presentation-capability.md)
- [ADR-023](../adrs/adr-023-exact-font-resource-identity.md)
- [ADR-026](../adrs/adr-026-profile-equivalent-bounded-observable-state.md)
- [ADR-027](../adrs/adr-027-bounded-presentation-fact-admission.md)
- [ADR-031](../adrs/adr-031-bounded-canvas-failure-and-startup-gate-integration.md)
- [ADR-033](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md)
