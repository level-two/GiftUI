# Architecture Documentation

This directory explains GiftUI's current accepted architecture. Its contents
must be derived from accepted ADRs and updated when those decisions change.

Architecture documents do not approve designs:

```text
RFC decides → ADR records → architecture documentation explains
```

The authoritative architecture is recorded by the
[accepted ADRs](../adrs/README.md). Legacy architecture sources are historical
input and do not override those decisions. They remain available either in the
active tree or through a recorded durable tagged baseline under the
[documentation preservation rules](../engineering/DOCUMENTATION_RULES.md#legacy-and-historical-documents).

See [Documentation Rules](../engineering/DOCUMENTATION_RULES.md).

## Accepted runtime derivation architecture

On 2026-10-10, [ADR-035](../adrs/adr-035-runtime-derived-records-and-exact-identity.md),
[ADR-036](../adrs/adr-036-scoped-model-access-and-bounded-ownership.md) and
[ADR-037](../adrs/adr-037-protocol-canvas-and-scoped-post-layout-drawing.md) were accepted.
Semantic Core emits bounded runtime records with exact structural identity;
fixed-domain scoped access reads stable owned models under serialized mutation
exclusion; protocol Canvas invokes scoped drawing after Layout. Analyzer capture
storage remains three banks with bounded replacement refusal. ADR-037 supersedes
ADR-028's retained-closure representation and preserves its drawing lifecycle.

This is accepted architecture, not a production conformance claim. Affected
Specification amendments and their approval precede migration; the current
production graph and historical implementation evidence remain the baseline.


## Host construction and operational boundaries

Accepted [ADR-038](../adrs/adr-038-construction-graph-and-operational-contracts.md)
adds a precise distinction under ADR-007/008: the fixed eighteen-role graph
records exact direct factory/construction dependencies, including mandatory
inputs, backing and derived configuration origins. Activation and runtime
operations retain separate typed-contract, identity, lifetime and behavioral
validation. Lower-contract imports and actual construction ordering/cycle rules
remain; indirection cannot hide an edge. Runtime-owned canonical wake notification
may use the existing consumer-owned contract, bound once to platform scheduling
by the host. Option B implementation is a separate activity and has not started;
this decision does not validate the current P08 graph or close any acceptance gate.
