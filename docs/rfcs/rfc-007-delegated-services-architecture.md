---
id: RFC-007
feature: giftui-mvp-architecture
title: GiftUI Delegated Services Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-15
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-001
  - RFC-002
  - RFC-004
  - RFC-005
  - RFC-006
related_adrs:
  - ADR-001
related_specs: []
related_future_work:
  - FW-008
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# RFC-007: GiftUI Delegated Services Architecture

## Summary

This RFC proposes that operations GiftUI delegates to its execution
environment use explicit, injected Service contracts collected in one small
foundational `GiftUIServices` package. For MVP, the common Service catalogue is
limited to:

- monotonic time acquisition through a Clock;
- bounded future wake requests through a Scheduler; and
- optional best-effort diagnostic delivery through a Diagnostic Sink.

A Service answers how GiftUI obtains or performs an environmental operation. A
Capability answers what client-visible GiftUI semantics the configured stack
can promise. A Trait is a typed fact about one selected component, profile,
Service, or environment. These concepts interact but are not interchangeable.

The target host remains the composition root. It selects concrete platform or
runtime Service implementations and injects one immutable Service bundle when
constructing the runtime. `GiftUIServices` contains contracts only: it imports
no concrete platform, backend, OS, RTOS, HAL, event loop, timer, or logging
implementation and performs no discovery.

Static hosts may supply a generic fixed-shape bundle specialized by the
compiler. Dynamic hosts may use bounded type erasure or adapters. Neither path
uses a global registry or ambient Service locator, and both conform to the same
observable contracts.

These are candidate architectural choices. This draft does not approve the
package, final Swift APIs, concrete implementations, capacity values, or
implementation work.

## Context

[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
accepts the need for cross-cutting architecture that supports the Signal
Analyzer across macOS dynamic, macOS static, Raspberry Pi/Linux dynamic, and
nRF52840 static configurations. Those environments obtain time, wakeups, and
diagnostic output through materially different platform mechanisms.

The accepted [ADR-001](../adrs/adr-001-signal-analyzer-application-boundaries.md)
places target composition in the application host. The host selects and
connects the runtime, backend, display, input, clock, scheduling, and hardware
implementations while keeping them out of portable Presentation. This RFC
preserves that authoritative boundary.

[RFC-002](rfc-002-giftui-mvp-layered-architecture.md) proposes a target-host
composition root and downward package dependencies. [RFC-004](rfc-004-run-cycle-and-frame-transaction.md)
proposes that scheduler wakeups enter a sealed runtime cycle, and
[RFC-005](rfc-005-failure-diagnostics-propagation.md) proposes bounded failure
and diagnostic contracts. All three remain draft and non-authoritative; their
shared boundaries must be reconciled before approval.

[RFC-006](rfc-006-capability-system-architecture.md) now distinguishes
Capabilities, Traits, and Services. It owns semantic capability resolution.
This RFC owns delegated environmental operations and the package through which
they are supplied.

The maintainer discussion attached to this RFC request supplies the key
distinction: a Clock answers “how does GiftUI obtain time?”, while a Capability
answers “what can this GiftUI stack promise to client code?”

RFC-001 used the earlier phrase “backend capabilities” for monotonic time and
timer scheduling. Its accepted ADR-001 establishes target-host composition but
does not make that classification authoritative. RFC-007 proposes the refined
Service terminology; the RFC cross-reference must be reconciled before this
draft advances to approval.

### Terminology

- **Capability:** An externally meaningful promise about which GiftUI
  semantics a configured stack can provide to client code.
- **Trait:** A typed fact owned by one selected component, runtime profile,
  Service, or environment. Traits may inform Capability resolution.
- **Service:** An operation GiftUI delegates to its environment through an
  explicitly supplied contract.
- **Service contract:** The profile-neutral semantics, inputs, outputs,
  failure behavior, ordering, and bounds of one delegated operation family.
- **Service implementation:** A concrete adapter to an event loop, timer,
  counter, RTOS primitive, diagnostic transport, or test fixture.
- **Service bundle:** The immutable set of implementations injected into one
  configured runtime.
- **Service health:** Operational availability after initialization. Health is
  not a mutation of the Service contract or Capability snapshot.

## Requirements

### R1 — Explicit delegation

Every environmental operation required by portable GiftUI runtime behavior
MUST cross an explicit Service contract. Portable runtime code MUST NOT obtain
time, schedule work, or emit diagnostics through ambient platform APIs,
singletons, global closures, or backend identity checks.

### R2 — Capability, Trait, and Service separation

A Service MUST describe an operation and its contract, not a client-visible
semantic promise. Quantitative or structural facts about a Service MAY be
published as Traits for RFC-006 resolution. The Service instance itself MUST
NOT be stored as a Capability value.

### R3 — Composition-root ownership

The target host MUST select, construct, and inject every required Service
implementation. Lower layers MUST NOT discover implementations or import a
concrete platform package to obtain them.

### R4 — Foundational package direction

Common Service contracts MUST live in a small `GiftUIServices` package that
imports no concrete runtime, backend, platform, driver, OS, RTOS, HAL, event
loop, timer, or logging implementation. Concrete adapters MUST depend downward
on `GiftUIServices`; the target host imports both contract and implementation.

### R5 — Immutable bundle and explicit health

The selected Service bundle and implementation identities MUST remain fixed
for the lifetime of one runtime. Runtime unavailability, cancellation, queue
exhaustion, and device loss MUST be operational or failure outcomes, not
implicit replacement or mutation of the bundle.

### R6 — No ambient Service locator

The common architecture MUST NOT require a global registry, thread-local
lookup, string-keyed container, hidden default, or mutable environment
dictionary. Dependencies MUST be visible at runtime construction or at a
narrow contract boundary.

### R7 — Static and dynamic equivalence

Static and dynamic profiles MAY use different dispatch and storage. They MUST
agree on Service semantics, ordering, failure identity, time arithmetic,
scheduling behavior, and conformance fixtures for equivalent inputs.

### R8 — Bounded Embedded Swift representation

The static profile MUST inject and invoke Services without requiring heap
allocation, reflection, strings, exceptions, unrestricted existentials, or an
unbounded callback/registration collection. Every scheduled item, completion,
and diagnostic record MUST have an explicit bound and exhaustion behavior.

### R9 — Monotonic Clock semantics

The MVP Clock MUST provide a monotonic Instant domain and checked Duration
differences suitable for elapsed-time measurement. It MUST NOT require wall
time, time zones, calendars, locale, network synchronization, or Foundation.
Its Instant values MUST NOT be compared across different runtime/Clock
instances unless a later contract explicitly establishes a shared domain.

### R10 — Scheduler re-entry

The MVP Scheduler MUST request a future runtime wake or enqueue a sequenced
input; it MUST NOT execute semantic callbacks directly from an interrupt,
timer thread, platform callback, or arbitrary executor context. Due work enters
through RFC-004's eventual approved cycle-admission boundary.

### R11 — Diagnostic independence

Diagnostic delivery MUST be optional and best-effort. Sink presence, filtering,
formatting, capacity, or failure MUST NOT change semantic state, Capability
resolution, frame content, failure disposition, or scheduling behavior.

### R12 — Structured failures

Service initialization and invocation failures MUST be representable through
the profile-neutral failure contracts governed by RFC-005. Rich platform error
objects MAY be attached dynamically for diagnostics but MUST NOT become the
only control-flow representation.

### R13 — Deterministic tests

Every MVP Service contract MUST have a deterministic, hardware-free test
implementation whose time, wakeups, exhaustion, and diagnostic acceptance can
be controlled explicitly.

### R14 — MVP proportionality

The common MVP Service catalogue MUST contain only environmental operations
required by the Signal Analyzer or the four stack-validation configurations.
Adding an allocator, filesystem, network, randomness, executor, power manager,
wall clock, or other Service requires a concrete accepted need.

## Constraints

- Portable Signal Analyzer Presentation must not import or observe concrete
  Clock, Scheduler, timer, event-loop, OS, RTOS, or logging implementations.
- The application Domain remains independent of clocks under ADR-001. Target
  hosts may supply a Clock to Data, Presentation orchestration, and GiftUI
  runtime integrations through separately typed composition edges.
- Static nRF52840 execution requires bounded, allocation-free common contracts
  and interrupt-safe handoff into normal runtime processing.
- Raspberry Pi/Linux may use monotonic POSIX clocks, timer descriptors, polling,
  or an event loop behind the same contracts; those choices are not portable
  semantics.
- macOS dynamic and static configurations must be able to use deterministic
  test Services without Foundation becoming a common-package dependency.
- Clock and Scheduler contracts must use the run-cycle ordering and failure
  semantics eventually approved from RFC-004 and RFC-005.
- Diagnostic delivery is observation only; product failure policy remains
  separate and composition-root owned.
- Existing logger closures and platform loops are migration evidence, not
  architectural authority or stable API.

## Proposed Design

### 1. Foundational `GiftUIServices` package

`GiftUIServices` owns only portable contracts and value types required to
delegate environmental operations. It is a foundation package alongside
`GiftUICapabilities`, not an umbrella coordinator:

```text
GiftUI runtime / host-facing contracts
                 |
                 v
          GiftUIServices
          /      |      \
         /       |       \
Clock adapter  Scheduler  Diagnostic sink adapter
   macOS/Linux/RTOS implementations

Target host imports the selected implementations and injects their values.
Concrete implementations never flow upward through package imports.
```

The package may depend on a lower shared primitives package for checked
Duration, stable IDs, and portable failure values if RFC-002 and RFC-005 place
those types there. It does not depend on `GiftUI`, semantic runtime, layout,
render core, backend, `GiftUICapabilities`, or a platform package. The target
host adapts Service properties into RFC-006 Traits, avoiding a dependency from
the Service package into the Capability system.

### 2. Explicit Service bundle

At runtime construction, the target host supplies one conceptual bundle:

```text
RuntimeServices {
  clock
  scheduler
  diagnostics
}
```

This is an architectural role, not an approved Swift declaration. Static
configurations may represent it as a generic product of concrete value types,
with an explicit no-op diagnostic sink. Dynamic configurations may use bounded
type erasure, references, or closures behind the same contracts.

Required Services are present by construction or make initialization fail.
Optional Services use explicit typed absence or a conforming no-op
implementation; consumers do not search a registry.

The bundle is passed only to runtime subsystems that need it. Portable `View`
values and application Presentation do not receive a raw bundle or general
Service lookup API.

### 3. Monotonic Clock

The Clock contract conceptually supplies:

- a monotonic Instant value;
- checked forward and signed Duration arithmetic as required by its consumers;
- a stable Clock-domain identity for diagnostics and token validation; and
- Traits such as resolution or maximum representable interval when those facts
  affect a Capability or Scheduler contract.

The Clock does not schedule work. Reading time has no semantic callback or
runtime re-entry. Wraparound, counter width, conversion, and resolution are
explicit contract concerns; a platform adapter cannot expose a raw counter and
leave each caller to interpret it differently.

MVP does not require wall time. A wall-clock change cannot affect animation,
retry, acquisition-window, or frame-deadline arithmetic.

### 4. Wake Scheduler

The Scheduler accepts a bounded request expressed in the injected Clock's
domain and returns a stable token or a structured rejection. A request names a
runtime input/wake reason rather than an arbitrary user closure.

Conceptually:

```text
schedule(deadline, reason) -> token | failure
cancel(token) -> disposition

platform timer / poll / RTOS alarm fires
                 |
                 v
bounded sequenced wake record
                 |
                 v
runtime cycle admission
```

The Scheduler implementation may use a macOS event loop, Linux timer facility,
cooperative polling, or an RTOS/hardware timer. Interrupt and callback paths do
only bounded admission work. They never evaluate views, mutate application
state, render, or invoke action handlers directly.

The target policy owns queue capacity, coalescing, cancellation, and
exhaustion disposition within the eventual approved RFC-004/RFC-005 contracts.
The Scheduler reports facts and outcomes; it does not choose product policy.

### 5. Diagnostic Sink

The Diagnostic Sink consumes the fixed, structured records proposed by
RFC-005. It is a Service because GiftUI delegates delivery to the environment;
it is not a Capability because its presence must not alter client-visible
semantics.

Static implementations may be a no-op sink, fixed ring, UART/RTT writer, or
bounded host-drained buffer. Dynamic implementations may adapt to structured
logging or tracing. Formatting and localization can occur outside the common
runtime path, keyed by stable identifiers.

The sink returns only bounded delivery status used for counters or diagnostics
about diagnostics. Sink rejection or failure cannot become the original
operation's control-flow result.

### 6. Relationship to Traits and Capabilities

Services may provide Traits, but the composition root performs the adaptation:

```text
Clock implementation ------> Clock Service injected into runtime
          |
          +--> resolution/counter bounds Traits --+
                                                   |
Scheduler implementation --> scheduling Traits ---+--> RFC-006 resolver
                                                   |
Diagnostic sink -----------> sink capacity Trait --+

RFC-006 result ----------------------------------------> GiftUI Capabilities
```

Examples:

- a monotonic Clock and bounded Scheduler may help realize a future animation
  Capability, but neither Service is that Capability;
- timer resolution is a Trait, not a Service and not automatically an
  animation promise;
- a Diagnostic Sink is optional infrastructure, not a “logging Capability”;
  and
- absence of an unrelated optional Service must not invalidate a Capability.

`GiftUIServices` and `GiftUICapabilities` remain siblings. Neither package
imports the other. The target host is the only place where concrete Service
selection, Trait contribution, capability resolution, and runtime injection
meet.

### 7. Lifetime, health, and replacement

The Service bundle is immutable for one runtime lifetime. Concrete Service
objects may contain mutable implementation state such as a timer queue or
diagnostic write index, but their contract identity and domain do not change.

Service health changes are operational inputs. A Clock invariant failure may
be runtime-fatal; Scheduler queue exhaustion may reject one request; a
Diagnostic Sink may drop a record. These outcomes do not cause the runtime to
discover a replacement silently.

Changing to a different Clock domain, Scheduler, or required Service
implementation requires construction of a new runtime unless a future RFC
defines a safe reconfiguration transaction.

### 8. Application and framework composition

The target host may inject the same concrete Clock into multiple separately
typed consumers when shared time-domain identity is required. That does not
merge their ownership:

- Signal Analyzer Domain remains unaware of Clock;
- Data may use a Clock through an application-domain contract for acquisition
  timing;
- GiftUI runtime uses Clock/Scheduler Services for run-cycle and presentation
  timing; and
- Presentation receives domain values such as `Duration`, not a platform
  timer implementation.

Whether Data and GiftUI share one Clock instance is a target composition
choice constrained by the application Specification. `GiftUIServices` does
not become a general dependency-injection framework for application services.

### 9. Minimum MVP Service catalogue

| Service | Required? | MVP responsibility |
| --- | --- | --- |
| Monotonic Clock | Required when elapsed time, retry deadlines, or scheduled updates are used | Provide one monotonic Instant domain and checked Duration arithmetic |
| Wake Scheduler | Required when the configured runtime needs future wakeups | Admit bounded deadline requests and re-enter through sequenced runtime input |
| Diagnostic Sink | Optional | Consume structured records best-effort without control-flow effect |

Service requirements are configuration-specific but explicit. A minimal
static loop that is driven entirely by external polling may use an explicit
polling Scheduler implementation rather than omit scheduling semantics
silently.

Allocators, filesystems, network transports, random sources, wall clocks,
executors, power managers, and application repositories are not added merely
because they can be modeled as Services. Each needs an accepted use case and
appropriate lifecycle routing.

## Module Responsibilities

| Module | Responsibility | Dependency impact |
| --- | --- | --- |
| `GiftUIServices` | Portable Clock, Scheduler, Diagnostic Sink, Service-bundle, token, and Service outcome contracts | Foundation package; no concrete platform, runtime, backend, Capability, OS, RTOS, or HAL imports |
| Shared primitives/failure contracts | Checked Duration/Instant support where shared, stable IDs, bounded outcomes | Must remain below Service consumers and implementations; final owner coordinated with RFC-002/RFC-005 |
| Semantic runtime | Consume injected Clock/Scheduler at cycle boundaries; never discover platform implementations | Depends on Service contracts, not concrete adapters |
| Failure/diagnostic integration | Normalize Service failures and structured diagnostic records | Uses RFC-005 contracts; diagnostic sink cannot control policy |
| Platform/RTOS adapters | Implement Services with timers, event loops, counters, polling, UART, RTT, or host logging | Depend downward on `GiftUIServices`; contain no portable semantic ownership |
| Target host | Select implementations, capacities, policies, Trait adapters, and the immutable Service bundle | Composition root may import the complete selected graph |
| Capability system | Consume explicit Traits derived at composition, not Service instances | Sibling foundation; no dependency on `GiftUIServices` |

## Public API Impact

Portable application views gain no Clock, Scheduler, logger, Service locator,
or environment dictionary. Existing `import GiftUI` remains the client
surface.

Later Specifications are expected to define:

- profile-neutral Clock Instant and Duration semantics;
- Scheduler request, token, cancellation, capacity, and wake-record contracts;
- structured Diagnostic Sink admission and no-op behavior;
- static and dynamic Service-bundle representations;
- target-host initialization and validation APIs;
- Service failure identities and operational outcomes; and
- deterministic test implementations.

Host-facing or package SPI may be public to integrators without becoming part
of the declarative view API. No stable ABI is proposed for MVP.

## Capabilities Impact

This RFC removes Clock, Scheduler, and Diagnostic Sink instances from the
Capability catalogue. Their relevant properties may become Traits at target
composition, and the Capabilities they enable remain governed by RFC-006.

Service absence has its own contract. A missing required Service invalidates
runtime construction. It does not produce a fake “unsupported Capability”
unless RFC-006 defines a semantic Capability that depends on that Service.

## Backend Impact

Backends do not own the common Clock or Scheduler merely because they present
frames. A backend may consume injected scheduling or timing contracts through
an approved boundary, or report asynchronous completions that the runtime
sequences. It must not call semantic runtime code directly from a platform
callback.

Platform and display integrations may supply concrete adapters. Device or
transport timers remain below the Service contract and do not leak controller
or OS handles upward.

## Static / Embedded Impact

The common design permits a fully generic bundle such as a concrete Clock,
fixed-capacity Scheduler, and no-op or fixed-ring Diagnostic Sink. Exact Swift
types remain a Specification concern.

The static path requires:

- fixed-shape injection with no ambient lookup;
- explicit scheduler queue and wake-input capacities;
- bounded token identity and deterministic exhaustion;
- interrupt-safe handoff without view evaluation or arbitrary callbacks;
- checked counter wraparound and Duration conversion;
- optional diagnostics with zero semantic dependency; and
- link-map evidence that unused dynamic adapters and rich logging are absent.

Connected-hardware validation remains required for actual timer, interrupt,
and diagnostic transport behavior. A cross-compile proves only build and ABI
viability.

## Performance

Clock reads and Scheduler admissions may occur on runtime hot paths. Static
implementations should specialize to direct calls; dynamic erasure must remain
bounded and measured. Diagnostic formatting is excluded from the common hot
path.

Review and later Specifications must define measurements for:

- Clock read and conversion cost;
- Scheduler insertion, cancellation, due-wake admission, and saturation;
- interrupt/callback-to-cycle latency and bounded work;
- Service-bundle dispatch overhead versus direct wiring;
- Diagnostic Sink admission and drop accounting; and
- idle power or polling implications on the embedded configuration where they
  affect MVP viability.

## Memory / Binary Size

Static accounting includes the Service bundle, scheduler queue, token state,
wake-input handoff, diagnostic sink/ring, failure records, and any conversion
state. Clock state may be zero-sized or a small counter adapter.

The package must not require all Service implementations to link. Generic
specialization or direct composition should retain only selected adapters.
Dynamic profiles may allocate richer event-loop and diagnostic adapters, but
those facilities cannot change the common semantics.

Exact capacities and byte/flash budgets remain open until the four
configuration fixtures and nRF52840 representation are sketched and measured.

## Alternatives

### Services owned by the umbrella `GiftUI` package

This is semantically discoverable and keeps names near client APIs. It would
force lower runtime and platform adapters to import upward into a facade that
depends on them, inviting cycles. A foundational contract package preserves
the conceptual GiftUI ownership without the physical inversion.

### Services embedded in each runtime profile

Dynamic and static runtimes could define separate Clock, Scheduler, and logger
contracts. This is locally simple and may fit unrelated products. It would
duplicate semantics and make cross-profile conformance depend on adapters
between two contract families.

### Backends own timing and diagnostics

A presentation backend often has access to an event loop and logger. Backend
ownership would be convenient for desktop-only rendering, but acquisition,
run-cycle, retry, and diagnostic needs cross backend boundaries. It would also
turn a replaceable renderer into an environmental coordinator.

### Global singleton or Service locator

Ambient lookup minimizes constructor plumbing and is familiar in dynamic
applications. It hides dependencies, introduces mutable global state and
lookup failure, complicates parallel tests, and is unsuitable as the bounded
Embedded Swift common contract.

### Closures as the universal Service representation

Closures are concise and adapt easily on full Swift. They may allocate or
escape, obscure identity and bounds, and are not a sufficient common static
contract. Dynamic adapters may still use closures behind the approved Service
semantics.

### Clock and Scheduler represented as Capabilities

This gives one configuration surface but confuses a mechanism with a semantic
promise. An animation Capability may depend on time and scheduling Services;
the Services themselves answer how work is performed, not what client-visible
behavior GiftUI promises.

### One open-ended Service registry

A heterogeneous registry is extensible for plugins and runtime discovery. It
adds string/type identity, mutation, allocation, failure, and versioning that
the closed MVP stack does not need. Explicit bundle fields keep requirements
and static costs visible.

## Rejected Approaches

No approach is formally rejected while this RFC remains a draft. Review is
expected to accept, revise, or reject the candidates above before ADR
extraction.

## Compatibility

### Source compatibility

Portable views do not change. Target hosts and platform applications must
migrate logger closures, direct clock calls, timer callbacks, and event-loop
wiring to explicit Service adapters and bundle injection. Current proof-of-
concept APIs create no compatibility presumption.

### Behavioral compatibility

Equivalent test Service inputs must produce the same Instant/Duration
arithmetic, wake ordering, cancellation disposition, failure identity, and
diagnostic independence across static and dynamic profiles. Real elapsed time
and platform callback latency need not be identical.

### Package and ABI compatibility

`GiftUIServices` is a candidate package coordinated with RFC-002. No stable
ABI, plugin protocol, serialized Service configuration, or cross-process
contract is proposed.

## Testing Strategy

### Contract fixtures

- Test monotonicity, resolution conversion, checked subtraction, wraparound,
  domain mismatch, and maximum interval for Clock.
- Test stable Scheduler ordering, equal-deadline tie breaks, cancellation,
  saturation, token reuse prevention, late wakeups, and sequenced cycle entry.
- Test Diagnostic Sink absence, acceptance, rejection, ring saturation, and
  sink failure without semantic changes.

### Cross-profile conformance

Run the same scripted Clock, Scheduler, and Diagnostic fixtures through static
generic and dynamic-erased bundles. Compare normalized results and stable
failure/diagnostic identities.

### Dependency enforcement

Fail package/import checks when `GiftUIServices` imports a concrete platform,
runtime, backend, OS, RTOS, HAL, or `GiftUICapabilities`, or when portable
views import Service contracts. Confirm platform adapters depend only
downward.

### Runtime integration

Use a deterministic Clock and manual Scheduler to drive RFC-004 cycle
fixtures without sleeping or reading wall time. Inject simultaneous input,
scheduled wakes, and presentation completions to validate stable ordering.

### Supported configurations

Define one Service fixture and one concrete adapter mapping for each MVP
configuration. Hardware-free tests validate contracts; Raspberry Pi and
nRF52840 connected execution validate the actual platform timer, callback or
interrupt handoff, and selected diagnostic path.

## Risks

- **The Service package becomes a general dependency-injection framework.**
  Keep the catalogue closed and evidence-driven; add operations only through
  accepted requirements.
- **Service Traits recreate a hidden Capability system.** Adapt only explicit
  quantitative facts at the composition root and let RFC-006 own semantic
  resolution.
- **Clock domains are mixed accidentally.** Preserve domain identity and make
  cross-domain comparison invalid unless explicitly adapted.
- **Scheduler callbacks re-enter semantic code.** Require bounded wake records
  and cycle admission rather than arbitrary callbacks.
- **Dynamic conveniences leak into static contracts.** Test a zero-heap bundle
  first and treat type erasure as a profile adapter.
- **Diagnostics become control flow.** Enforce no-op equivalence and inject
  sink failures in conformance tests.
- **Package foundations form a cycle.** Keep `GiftUIServices` and
  `GiftUICapabilities` independent siblings; composition adapts between them.
- **Application and framework timing ownership blur.** Preserve ADR-001 and
  type each injection edge instead of exposing a universal application
  locator.

## Open Questions

1. Which lower portable package owns the common checked `Duration`, Instant,
   stable token, and failure primitives used by `GiftUIServices` without
   making the Service package depend upward on runtime or RFC-005 policy?
2. What exact Scheduler contract is sufficient for MVP: one-shot wakes only,
   or repeating requests as a primitive? What cancellation and equal-deadline
   ordering are required by RFC-004?
3. Which Scheduler queue, wake-input, token, and diagnostic capacities fit the
   nRF52840 configuration, and what are their deterministic exhaustion
   dispositions?
4. Must Signal Analyzer Data and GiftUI runtime share one Clock domain for all
   configurations, or may the host adapt separately timestamped acquisition
   data into portable `Duration` values before Presentation consumes it?
5. Does Diagnostic Sink remain in the common Service bundle or belong solely
   to RFC-005's failure/diagnostic package with only an injection seam exposed
   here? The no-control-flow semantics must remain the same either way.
6. Should an externally polled static runtime use a Scheduler implementation
   with explicit poll semantics, or may the bundle omit Scheduler when no MVP
   framework operation requests a future wake?

## Deferred and Follow-up Work

- Allocators, filesystems, random sources, wall clocks, executors, networking,
  power management, and application repositories are outside this RFC. A
  concrete accepted feature or stack-validation requirement must route each
  through triage before it joins the Service catalogue.
- [RFC-006](rfc-006-capability-system-architecture.md) owns Capability and
  Trait semantics. Its FW-008 preserves a generalized Trait subsystem; RFC-007
  requires only direct, typed adaptation of the few Service properties used by
  MVP fixtures.
- Exact Swift declarations, capacities, adapters, and configuration fixtures
  belong in downstream Specifications after approved decisions are extracted
  into accepted ADRs.

## Decision Summary

If this RFC is approved in substantially its proposed form, the following
architecturally significant choices should be extracted into ADRs:

1. Environmental operations use explicit injected Services distinct from
   client-facing Capabilities and component/environment Traits.
2. One foundational `GiftUIServices` package owns common Service contracts and
   imports no concrete implementation or Capability package.
3. The target host assembles one immutable Service bundle; no global registry,
   ambient locator, or implementation discovery is part of the common model.
4. MVP Services are monotonic Clock, bounded wake Scheduler, and optional
   best-effort Diagnostic Sink only.
5. Scheduler due work re-enters through sequenced runtime input and never
   invokes semantic code directly from callbacks or interrupts.
6. Static and dynamic profiles share Service semantics while permitting
   generic direct dispatch and bounded dynamic erasure respectively.
7. Service health and invocation failures are operational/failure outcomes,
   not Capability mutation or silent implementation replacement.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [PROPOSAL-001: GiftUI MVP Baseline Charter](../proposals/proposal-001-giftui-mvp-baseline-charter.md)
- [PROPOSAL-004: GiftUI Capability System](../proposals/proposal-004-capability-system.md)
- [RFC-001: Signal Analyzer Application Architecture](rfc-001-signal-analyzer-application-architecture.md)
- [RFC-002: GiftUI MVP Layered Architecture](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](rfc-005-failure-diagnostics-propagation.md)
- [RFC-006: GiftUI Capability System Architecture](rfc-006-capability-system-architecture.md)
- [ADR-001: Signal Analyzer Application Boundaries](../adrs/adr-001-signal-analyzer-application-boundaries.md)
- [FW-008: Generalized Component Trait System](../future-work/fw-008-generalized-component-traits.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Project Glossary](../GLOSSARY.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy implementation and design provenance
- Maintainer-provided Capability/Trait/Service discussion attached to the RFC
  authoring request on 2026-08-15.
