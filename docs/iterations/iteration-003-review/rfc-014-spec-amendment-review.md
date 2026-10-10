# RFC-014 coordinated Specification amendment review — 2026-10-10

**Review outcome: ready for human approval consideration; subsequently approved.** The nine coordinated amendments are
drafts under accepted ADR-035/036/037. This is Codex's author/self-review, not an
independent review, human approval or implementation conformance result. Eugene
authorized Spec updates after accepting the ADRs; that instruction did not approve
these newly written contracts.

## Subsequent approval

Eugene explicitly approved all nine amendments presented in `9b2ff666`; see the
[2026-10-10 approval record](rfc-014-spec-approval.md). The review below preserves
its pre-approval findings. The [bounded implementation sequence](rfc-014-implementation-plan.md) and nine
owner plans are now ready. The review below is historical, not a request for
another approval or investigation of these decisions.

## Amendment and authority map

The existing owner Specs are amended in place. Each new `RFC-014 runtime amendment`
section states its exact replacement boundary and takes precedence within the
draft; unrelated baseline obligations remain. Historical approval notices,
completed criteria and task evidence apply to the retained `53740a73` baseline.
The coordinated amendments require fresh evidence before adoption.

| Spec | Accepted authority / amendment | New or refreshed acceptance |
| --- | --- | --- |
| [SPEC-001](../../specs/spec-001-signal-analyzer-reference-application.md#rfc-014-runtime-amendment) | ADR-035/036/037: actual analyzer declarations, explicit capture selection migration, owner transfer/refusal; ADR-034 capture semantics unchanged. | SA-RD-001–004; existing source/action/capture/pixel/workload criteria. |
| [SPEC-002](../../specs/spec-002-portable-foundation.md#rfc-014-runtime-amendment) | ADR-036: explicit migration measurement selection for project-local Swift 6.3.2; historical macOS compiler baseline preserved. | Fresh PF-006/007 measurements under RP-RD-003; no Foundation behavior or ceiling change. |
| [SPEC-006](../../specs/spec-006-declarative-view-semantics.md#rfc-014-runtime-amendment) | ADR-035/036: fixed-domain compiled View, inferred Body, checked access transport, bounded records and complete exact identity. | DV-RD-001–004. |
| [SPEC-007](../../specs/spec-007-layout.md#rfc-014-runtime-amendment) | ADR-035 and preserved ADR-032: bank-scoped semantic input, no second graph or model access in Layout. | LY-RD-001–002. |
| [SPEC-010](../../specs/spec-010-observable-reference-state.md#rfc-014-runtime-amendment) | ADR-036: typed reads/writes, separate owner/allocation/registration identities, State discovery, final-ticket replacement transaction and exact failure routing. | OS-RD-001–004. |
| [SPEC-011](../../specs/spec-011-interaction.md#rfc-014-runtime-amendment) | ADR-035/036 and preserved ADR-033: independently owned exact keys, accepted-offer routing commit and checked model target dispatch. | IN-RD-001–002. |
| [SPEC-012](../../specs/spec-012-canvas-path-stroke-drawing.md#rfc-014-runtime-amendment) | ADR-037 replaces ADR-028: authored protocol Canvas, compiled scoped witness, concrete value staging, bounded errors and exactly-once release. | DR-RD-001–004; unchanged Path/stroke/raster oracles. |
| [SPEC-013](../../specs/spec-013-runtime-profiles.md#rfc-014-runtime-amendment) | ADR-035/036/037: complete limits/audit extension, phase/borrow ownership, compiler policy, same profile outcomes and linked resource proof. | RP-RD-001–004. |
| [SPEC-015](../../specs/spec-015-host-configuration.md#rfc-014-runtime-amendment) | ADR-035/036/037: schema-4 scalar workload contract, explicit model/ticket/pin limits, real host ownership and complete ledger. | HC-RD-001–004. |

The source [RFC](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md)
and [ADR acceptance record](rfc-014-adr-acceptance.md) establish the design gate.
SPEC-003/004/005/008/009/014 remain unchanged: their failure fact vocabulary,
capabilities, resources, normalized operation meaning, execution/handoff and
backend ownership are preserved. Focused owners map new local failures into
existing SPEC-003 facts rather than adding a competing failure owner.

## Findings resolved in the drafts

| Finding | Correction |
| --- | --- |
| Superseded ADR-028 remained a governing reference in implemented Specs. | Acceptance commit reopened SPEC-001/012/013 and replaced the governing reference with ADR-037. All affected contracts now have explicit draft/baseline boundaries. |
| A context-free compiled body accessor cannot express the chosen access model. | SPEC-006 defines the concrete generic nonescapable read, fixed Domain, inferred Body and same-domain visitor rules. No universal Body.Domain constraint or custom Never fallback. |
| Semantic publication could be mistaken for Interaction commit. | SPEC-006/011/013 explicitly preserve accepted-offer routing commit; prior committed keys survive semantic-bank reuse and refused offers. |
| Two metadata records could be mistaken for two capture banks. | SPEC-010/013/015 separate metadata, tickets, pins and entitlement, including installed-empty reservation and retained-owner refusal before commit. |
| Read failures, early producer rejection and postcommit failure could lose cleanup or replay effects. | SPEC-010/012 define deterministic mappings and transaction/release obligations; committed replacement survives later failure and no admitted mutation replays. |
| Old graph descriptors and byte projections could silently become the new production input/budget. | SPEC-006/013/015 require runtime topology, independent bounded pools and an actual complete audit; schema 4 contains scalar bounds/type vocabulary only. |
| SPEC-002's native measurement compiler conflicted with the migration policy. | Focused amendment provides an explicit driver baseline selector and preserves historical reproduction, value/ABI/allocation limits and separate evidence. |
| New criteria had no traceability entry in existing task-evidence ledgers. | SPEC-001 and SPEC-011 have explicitly blocked scope reservations with empty implementation/check/evidence lists. All nine plans are draft for migration and must be decomposed after Spec approval, before readiness. |

## Review scope and validation

Reviewed the new amendment sections against the accepted ADRs, approved RFC,
typed-access/capacity contracts, existing owner API/error/publication/resource
sections and current source/fixture interfaces. The final fixture remains evidence
of representative mechanisms only; no source transformer or new runtime was
implemented or compiled during this documentation change.

Checks cover governance/authority graph, task-evidence coverage, required Spec
sections, new criterion uniqueness, local reference targets, accepted upstream
statuses and whitespace. `scripts/format-swift.sh` precedes the repository
governance gate. Production Sources, Swift tests and build scripts are unchanged;
the two YAML evidence-ledger edits record blocked work, not test passes.

## Remaining gates and risks

No architectural choice or additional investigation is requested. Concrete
schema layouts, path/payload maxima, full source lowering, actual callback/owner
integration and measured linked/stack costs must satisfy the drafted contracts
during implementation. They are not asserted to pass because the fixture compiled.
The selected finite ticket/pin limits are explicit proposed configuration details;
conformance must prove complete ownership fits them or return for a reviewed
contract change. The three-bank architectural limit cannot be increased that way.

The 4 MHz transfer limitation, 250 ms frame/acquisition requirements and separate
connected hardware evidence retain their existing dispositions. A compile, object
inspection or native bridge run cannot satisfy them.

**Next:** human approval of the coordinated Spec amendments, then ready plans and
focused implementation/design tasks for [IH-2–6](rfc-014-implementation-handoff.md).
Approval must cover the new amendment sections and their precedence over the
preserved baseline realization; it must not relabel old evidence as new conformance.
