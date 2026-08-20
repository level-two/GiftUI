# ADR Extraction Map

**Status:** Preparation aid; non-authoritative

**Scope:** Approved MVP architecture RFCs (`RFC-002` through `RFC-006`)

**Prepared:** 2026-08-20

## Purpose

This map defines the intended boundary and source owner of each ADR before ADR
extraction begins. It prevents repeated statements in integrating and focused
RFC Decision Summaries from becoming duplicate architecture records.

The map does not reserve ADR IDs, approve a decision, or replace source RFC
text. ADR IDs are allocated only when proposed ADR files are created. Each ADR
must still be independently checked against its approved source, use the ADR
template, remain `proposed`, and receive explicit human acceptance before it
becomes authoritative.

`RFC-007` is draft and contributes no extractable decisions. Its references to
handoff, operational state, or delegated services are context only.

## Ownership Rules for Repeated Decisions

### Frame delivery and responsibility transfer

One ADR sourced primarily from `RFC-004` will own the complete frame-delivery
decision:

- the synchronous borrowed one-shot ordered operation stream;
- complete consumption or safe draining during the backend offer;
- refusal only before irreversible presentation output and without retained
  borrowed data or presentation effects;
- accepted handoff as the logical frame commit and responsibility-transfer
  boundary;
- backend ownership of bounded derived presentation data after handoff; and
- post-handoff progress, device failure, transport failure, retry, and
  abandonment as backend/integration concerns that cannot reopen the Core
  frame transaction.

The related statements in `RFC-002` Decision Summary item 3, `RFC-005`
Decision Summary item 3, and `RFC-006` Decision Summary item 4 are supporting
provenance and constraints on their local designs. They must link to this ADR
rather than produce their own one-shot or post-handoff ADRs.

The ADR does not absorb retryable pre-handoff refusal scheduling. That is a
separately reviewable decision with different state, pacing, and terminal-policy
consequences.

### Capability declaration versus operational state

One ADR sourced primarily from `RFC-006` will own the general classification
boundary among:

- structural component and storage-model selection;
- immutable effective semantic capability declaration;
- explicit realization policy and ordinary configuration; and
- mutable runtime operational state, including backpressure and device health.

`RFC-002` Decision Summary item 7 supplies the assembly-lifetime constraint,
and `RFC-005` Decision Summary item 3 supplies the distinction between explicit
health and diagnostic projections. Neither produces a separate operational-
state ADR.

This capability-boundary ADR classifies post-handoff health as operational
state; it does not redefine the frame commit or ownership-transfer semantics,
which belong exclusively to the `RFC-004` frame-delivery ADR.

### Failure and diagnostics

An `RFC-005` ADR may decide that diagnostics are optional, filtered,
non-authoritative projections distinct from typed outcomes and explicit health.
It must reference the two owners above for operational-state classification and
post-handoff containment. It must not restate those decisions normatively.

## Candidate ADRs

Candidate keys are local planning labels, not artifact IDs.

The extraction completed with these allocations:

| Candidate key | Proposed ADR |
| --- | --- |
| `ARCH-SEMANTICS` | `ADR-005` |
| `ARCH-PROFILES` | `ADR-006` |
| `ARCH-INTEGRATION` | `ADR-007` |
| `ARCH-MODULE-DAG` | `ADR-008` |
| `ARCH-GEOMETRY` | `ADR-009` |
| `FRAME-HANDOFF` | `ADR-010` |
| `RUN-CYCLE` | `ADR-011` |
| `FRAME-REFUSAL` | `ADR-012` |
| `INPUT-ADMISSION` | `ADR-013` |
| `FAILURE-OUTCOMES` | `ADR-014` |
| `FAILURE-DISPOSITION` | `ADR-015` |
| `DIAGNOSTICS` | `ADR-016` |
| `CAP-STATE-PLANES` | `ADR-017` |
| `CAP-MODEL` | `ADR-018` |
| `CAP-RESOLUTION` | `ADR-019` |
| `CAP-RASTER-PRESENTATION` | `ADR-020` |
| `TEXT-GEOMETRY` | `ADR-021` |
| `TEXT-OPERATIONS` | `ADR-022` |
| `TEXT-RESOURCES` | `ADR-023` |

| Key | Candidate decision boundary | Primary source and Decision Summary coverage | Supporting provenance | Explicitly excluded or delegated |
| --- | --- | --- | --- | --- |
| `ARCH-SEMANTICS` | Semantic UI and proposal-based layout remain above a backend-neutral normalized render boundary; backends do not consume the view/runtime graph. | `RFC-002` item 1 | `RFC-002` requirements R1-R4 and design sections 1, 4-8 | Stream lifetime and frame handoff belong to `FRAME-HANDOFF`; text payload specifics belong to the text ADRs. |
| `ARCH-PROFILES` | Static and dynamic runtimes use different storage/composition strategies beneath one portable declarative semantic model. | `RFC-002` item 2 | `RFC-002` R5 and static/embedded analysis | Capability resolution representation belongs to `CAP-RESOLUTION`. |
| `ARCH-INTEGRATION` | Backends, display/input drivers, and transport/HAL integrations have separate downward ownership; supported platforms are target-host compositions rather than semantic owners. | `RFC-002` items 4 and 5 | `RFC-002` design sections 2, 8-10 | Frame disposition belongs to `FRAME-HANDOFF`; input admission belongs to `INPUT-ADMISSION`. |
| `ARCH-MODULE-DAG` | The acyclic target/module import graph enforces logical ownership; MVP distribution is one package with multiple targets/products and `GiftUI` remains the portable declaration product. | `RFC-002` item 6 | `RFC-002` design sections 1-2 and dependency testing | Future distribution changes remain in `FW-016`. |
| `ARCH-GEOMETRY` | Core layout and Canvas geometry use checked integer scalars without an MVP general constraint solver. | `RFC-002` item 8 | `RFC-002` layout, static, performance, and alternatives sections | Alternative scalars remain in `FW-005`; concrete types and overflow APIs belong in Specifications. |
| `TEXT-GEOMETRY` | Layout is the sole authority for identical canonical text geometry across MVP configurations; backends do not remeasure or substitute logical geometry. | `RFC-003` item 1 | `RFC-003` R1-R2 and ownership design | Payload and resource representation belong to the other text ADRs. |
| `TEXT-OPERATIONS` | The backend-neutral text boundary is a streamable positioned-glyph operation carrying resolved glyph selection and logical positions. | `RFC-003` item 2 | `RFC-003` R3 and lifetime design | General operation-stream lifetime belongs to `FRAME-HANDOFF`. |
| `TEXT-RESOURCES` | One immutable font-resource identity joins canonical metrics to exact selectable outline or bitmap realizations owned by `GiftUITextResources`. | `RFC-003` item 3 | `RFC-003` R4-R6 and module ownership | Exact resource contents and budgets belong in a Specification. |
| `RUN-CYCLE` | Runtime work uses sealed serialized admission, at-most-once mutation/action application, non-suspending derivation, dirty recovery, and complete semantic revision publication independent of presentation outcome. | `RFC-004` items 1 and 2 | `RFC-004` R1-R3, R9, R11 and serialized-state design | Frame acceptance and presentation responsibility belong to `FRAME-HANDOFF`; concrete observable-state APIs require their own feature lifecycle. |
| `FRAME-HANDOFF` | A synchronous borrowed one-shot offer is the sole frame commit/abort and responsibility-transfer boundary, with backend-owned bounded derived data and no Core replay or post-handoff transaction reopening. | `RFC-004` items 3 and 4 | `RFC-002` items 3 and 7; post-handoff clause of `RFC-005` item 3; common-stream clause of `RFC-006` item 4; `SPIKE-001` evidence | Retryable refusal rescheduling belongs to `FRAME-REFUSAL`; capability/state classification belongs to `CAP-STATE-PLANES`; generalized recovery remains in `FW-010` and replayable delivery in `FW-014`. |
| `FRAME-REFUSAL` | Retryable pre-effect refusal retains constant-space latest-revision presentation intent and converges through effect-free rederivation, finite host pacing/attempt policy, and unavailable/quiescent terminal disposition. | `RFC-004` item 5 | `RFC-004` R7, R10 and handoff-recovery design; `RFC-005` disposition table | It does not retain or replay refused payloads and does not govern failures after accepted handoff. |
| `INPUT-ADMISSION` | Presentation-coupled input enters through a backend-neutral sibling seam and is admitted fail-closed using provenance, sequence cancellation, current-revision hit/identity/disabled-state validation, and no stale retargeting. | `RFC-004` item 6 | `RFC-002` item 10 and boundary B11 | Exact event and hit-map types belong in a Specification. |
| `FAILURE-OUTCOMES` | Cross-layer outcomes carry bounded profile-neutral meaning, conservative containment, affected scope, and source-stable identity without promising cross-build numeric stability. | `RFC-005` item 1 | `RFC-005` R1, R5, R8 and outcome/containment design | Durable cross-build identities remain in `FW-012`; finer recovery classes remain in `FW-013`. |
| `FAILURE-DISPOSITION` | Failure handling has ordered ownership: detecting-layer mechanical containment, coordinator-mandated transaction effects, then composition choice among remaining safe responses. | `RFC-005` item 2 | `RFC-005` R2-R3 and policy design | It references, rather than redefines, run-cycle and handoff transaction rules. |
| `DIAGNOSTICS` | Diagnostics are optional filtered non-authoritative projections; approved asynchronous Core outcomes use bounded sequenced admission, while correctness uses typed outcomes and explicit operational health. | `RFC-005` item 3, excluding the post-handoff and state-classification clauses delegated above | `RFC-005` R4, R6-R7 and diagnostics design | `CAP-STATE-PLANES` owns health-versus-capability classification; `FRAME-HANDOFF` owns post-handoff containment and frame disposition. |
| `CAP-STATE-PLANES` | Structural selection, immutable capability declaration, explicit realization policy/configuration, and mutable operational state are separate decision planes. | `RFC-006` item 1 | `RFC-002` item 7; health/diagnostics distinction in `RFC-005` item 3; `RFC-006` R5, R8 and three-plane design | `FRAME-HANDOFF` owns the meaning of accepted handoff and post-handoff frame outcomes. |
| `CAP-MODEL` | MVP capabilities use fixture-driven typed semantic families with explicit quantitative constraints and absence behavior, not platform checks or Boolean/string bags. | `RFC-006` item 2 | `RFC-006` R1-R3, R6-R7 and fixture-driven design | Catalogue growth beyond demonstrated MVP needs requires later lifecycle work. |
| `CAP-RESOLUTION` | The target host performs deterministic allocator-independent bounded initialization-time resolution through an acyclic foundation, producing an immutable result or validation failure for static and dynamic profiles. | `RFC-006` items 3 and 5 | `RFC-006` R4, R9-R10, physical ownership, and `SPIKE-002` evidence | Concrete storage, RAM, stack, flash, and work budgets belong in Specifications and conformance evidence. |
| `CAP-RASTER-PRESENTATION` | The MVP's single composite `rasterPresentation` capability resolves operation coverage, extent, canonical pixel encoding, downstream submission lifetime, and bounded storage across contributor-owned facts. | Capability-specific portion of `RFC-006` item 4 | `RFC-006` minimum-catalogue fixtures and `SPIKE-001`/`SPIKE-002` evidence | The common one-shot delivery rule is inherited from `FRAME-HANDOFF` and must not be restated as a new decision. |

`RFC-002` Decision Summary item 9 is not an independent ADR. Proof-of-concept
migration is a consequence of the extracted target boundaries and belongs in
Specifications and migration planning, not in a decision record of its own.

## Decision Summary Coverage

This matrix is the completeness check used before ADR drafting.

| Approved RFC | Decision Summary item | ADR owner |
| --- | --- | --- |
| `RFC-002` | 1 | `ARCH-SEMANTICS` |
| `RFC-002` | 2 | `ARCH-PROFILES` |
| `RFC-002` | 3 | `ARCH-SEMANTICS` for the normalized boundary and future producer seam; `FRAME-HANDOFF` for one-shot lifetime and replay prohibition |
| `RFC-002` | 4-5 | `ARCH-INTEGRATION` |
| `RFC-002` | 6 | `ARCH-MODULE-DAG` |
| `RFC-002` | 7 | `CAP-STATE-PLANES`, with frame-lifetime consequences in `FRAME-HANDOFF` |
| `RFC-002` | 8 | `ARCH-GEOMETRY` |
| `RFC-002` | 9 | No ADR; migration consequence |
| `RFC-002` | 10 | `INPUT-ADMISSION` |
| `RFC-003` | 1 | `TEXT-GEOMETRY` |
| `RFC-003` | 2 | `TEXT-OPERATIONS` |
| `RFC-003` | 3 | `TEXT-RESOURCES` |
| `RFC-004` | 1-2 | `RUN-CYCLE` |
| `RFC-004` | 3-4 | `FRAME-HANDOFF` |
| `RFC-004` | 5 | `FRAME-REFUSAL` |
| `RFC-004` | 6 | `INPUT-ADMISSION` |
| `RFC-005` | 1 | `FAILURE-OUTCOMES` |
| `RFC-005` | 2 | `FAILURE-DISPOSITION` |
| `RFC-005` | 3 | `DIAGNOSTICS`, with classification delegated to `CAP-STATE-PLANES` and post-handoff semantics delegated to `FRAME-HANDOFF` |
| `RFC-006` | 1 | `CAP-STATE-PLANES` |
| `RFC-006` | 2 | `CAP-MODEL` |
| `RFC-006` | 3 and 5 | `CAP-RESOLUTION` |
| `RFC-006` | 4 | `CAP-RASTER-PRESENTATION`, inheriting stream lifetime from `FRAME-HANDOFF` |

## Extraction Order

The sequence below minimizes forward references and makes duplicate ownership
visible during review:

1. Extract the RFC-002 structural records: `ARCH-SEMANTICS`, `ARCH-PROFILES`,
   `ARCH-INTEGRATION`, `ARCH-MODULE-DAG`, and `ARCH-GEOMETRY`.
2. Extract `FRAME-HANDOFF` before any other RFC-004, RFC-005, or RFC-006 record
   that refers to refusal, operational health, diagnostics, or raster delivery.
3. Extract `RUN-CYCLE`, `FRAME-REFUSAL`, and `INPUT-ADMISSION`.
4. Extract `FAILURE-OUTCOMES` and `FAILURE-DISPOSITION`, then `DIAGNOSTICS`
   with explicit references to the frame owner.
5. Extract `CAP-STATE-PLANES` before `CAP-MODEL`, `CAP-RESOLUTION`, and
   `CAP-RASTER-PRESENTATION`; reference `FRAME-HANDOFF` rather than repeating
   its one-shot and post-handoff rules.
6. Extract the three RFC-003 text records after `ARCH-SEMANTICS`; each may
   reference `FRAME-HANDOFF` for the common borrowed stream lifetime.

Extraction order does not imply acceptance order. Every proposed ADR remains
independently reviewable and non-authoritative until explicitly accepted.

## Extraction Checks

Before adding each proposed ADR:

- confirm the primary RFC remains `approved` and its Proposal remains
  `accepted`;
- copy only the mapped decision, rationale, consequences, and rejected
  alternatives supported by that RFC;
- use related RFCs as provenance without creating a second normative owner;
- link dependent ADRs rather than restating their decisions;
- preserve deferred boundaries (`FW-005`, `FW-010`, `FW-012`, `FW-013`,
  `FW-014`, and `FW-016`) without promoting them into MVP architecture;
- allocate the next unused ADR ID at file creation time;
- update the source RFC relationships and `docs/features.yaml` in the same
  change; and
- leave the ADR status `proposed` pending explicit human acceptance.

## References

- [Feature Lifecycle](../engineering/FEATURE_LIFECYCLE.md)
- [Documentation Rules](../engineering/DOCUMENTATION_RULES.md)
- [AI Agent Rules](../engineering/AI_AGENT_RULES.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-003: Deterministic Text Rendering Architecture](../rfcs/rfc-003-deterministic-text-rendering-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [ADR Template](../templates/adr.md)
