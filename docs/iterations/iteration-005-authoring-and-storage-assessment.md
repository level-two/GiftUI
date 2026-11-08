---
id: ITERATION-005
title: Authoring and Storage Assessment
status: approved
revision: 1
approved_revision: 1
created: 2026-11-08
updated: 2026-11-08
features:
  - observable-reference-state
  - external-application-integration
approval: 'Eugene, 2026-11-08: Please narrow iteration 4 as recommended, move I4-09 and I4-10 to the next iteration, and update the waves, priorities, and dependent documents. This approves the transfer baseline only; RFC/ADR/Spec gates remain separate.'
related_future_work:
  - FW-042
closure: null
---

# ITERATION-005: Authoring and Storage Assessment

## Goal

Improve model authoring for applications on the supported reusable hosts, and
establish evidence-based recommendations for fixed-buffer storage. This post-MVP
iteration receives two existing commitments from iteration 4; it does not promise
buffer replacement or approve RFC-016's proposed API.

## Included Scope

| Item | Source / feature | Intended outcome | Lifecycle routing |
| --- | --- | --- | --- |
| I5-01 — Fixed-buffer InlineArray/Span assessment | I4-09 / I4-AC-010; FW-042; external-application-integration | Inventory tuple buffers; recommend migrate/retain/defer from layout, allocation, copying, borrowing, lifetime and stable-address evidence | Assessment only; bounded Exploration/Spike as needed, normal maintenance or contract gates before adoption |
| I5-02 — Observable model authoring API | I4-10 / I4-AC-011; RFC-016 / accepted PROPOSAL-005; observable-reference-state | Resolve Q1–Q5 and deliver approved generated authoring support; migrate counter then Signal Analyzer and document the supported surface | Human RFC approval, required ADR acceptance and Spec approvals, ready plan before production implementation; RFC-016 remains draft |

## Waves and Priorities

P0 means a named dependency or acceptance gate; P1 is required delivery;
P2 is the bounded assessment, still required for closure.

| Wave | Work / priority | Exit |
| --- | --- | --- |
| W0 — Baseline and decisions | I5-02 API/build contract preparation P1, approvals P0 before implementation; I5-01 assessment P2 | Pin iteration-4 host/compiler/SDK/evidence baseline; review Q1–Q5, obtain required contracts/ready plan; inventory storage candidates and evidence gaps. No compiler upgrade implied. |
| W1 — Authoring implementation and counter | I5-02 P1; applicable ownership/resource qualification P0 | Generated-source/diagnostic and counter migration evidence across the four configurations; preserve existing observation, failure and host semantics. |
| W2 — Analyzer and final validation | I5-02 P1; final conformance P0; I5-01 final recommendations P2 | Analyzer migration after qualified counter path; complete both criteria, resource comparisons and migration guides. Any buffer adoption remains separately gated. |

Storage assessment can proceed alongside authoring work; it is not a prerequisite
unless a concrete approved contract depends on it. Design preparation may begin
earlier, but production migration uses the qualified iteration-4 host baseline
and normal implementation gates. No duplicate host bootstrap is required.

## Exclusions

- Reopening iteration-4 host extraction, package topology or analyzer certification.
- Automatic buffer replacement, compiler upgrade, Core-wide ownership redesign,
  or delivery of unrelated RFC-015 residuals.
- Resource-budget changes, weakened observation/ownership semantics or automatic
  connected-board flashing/deployment.

## Success Criteria and Validation

The transferred criteria retain their original outcomes and validation boundaries.
Old I4 IDs remain reserved as transfer references, not passes.

| ID | Observable result | Required configurations | Evidence / governing contract |
| --- | --- | --- | --- |
| I5-AC-001 | Fixed-buffer assessment inventories tuple candidates and records migrate/retain/defer recommendations with ownership, borrowing and lifetime rationale; distinguishes semantic tuples, ABI storage and pinned/asynchronous buffers | macOS Dynamic/Static, Raspberry Pi 1 ARMv6 and nRF52840 Embedded feasibility on identified toolchains | [FW-042](../future-work/fw-042-inline-array-and-span-storage-assessment.md): layout/stride/alignment, backing and temporary/copy costs, zero-heap/stack/RAM/flash implications, lifetime/exclusivity negative controls and positive twins, stable-address constraints; reproducible evidence or explicit gaps, affected contracts and adoption gates; no replacement or compiler upgrade implied |
| I5-AC-002 | RFC-016 Q1–Q5 have reviewed resolutions; required decisions and Spec amendments are explicitly approved; counter and analyzer use the supported authoring surface without handwritten observation SPI, with complete migration/conformance dispositions | macOS Dynamic/Static, Raspberry Pi 1 ARMv6 Dynamic and nRF52840 Embedded Static | OA-01–07 and M0–M6 evidence: generated-source/diagnostic fixtures, service/fact and actual owned-dispatcher integration, ownership/refusal/reporting equivalence, resource comparisons and migration guide; unresolved approval or unimplemented migration remains unmet unless explicitly excepted |

The four configurations are macOS Dynamic/Static, Raspberry Pi 1 ARMv6 Dynamic,
and nRF52840 Embedded Static. Preserve zero-heap/ABI/resource controls and exact
source/compiler/artifact identities. Connected operations need explicit user
authorization; a native rehearsal or target build is not hardware certification.

## Dependencies and Open Questions

- [ITERATION-004 revision 12](iteration-004-backend-and-application-integration.md)
  owns reusable-host counter/analyzer adoption, existing-contract dispatcher
  residuals and applicable certification. Iteration 5 depends on that baseline;
  iteration 4 does not depend on RFC-016.
- RFC-016 Q1–Q5 and downstream approvals remain open; scheduling does not resolve
  them. Follow M0–M6 and OA-01–07, preserving Dynamic/Static/Embedded semantics.
- FW-042 uses actual compiler/ownership evidence from the adopted baseline; retain
  or defer is a valid candidate disposition with recorded reasons and gaps.

## Revision and Approval History

| Revision | Date | Change / reason | Maintainer approval |
| --- | --- | --- | --- |
| 1 | 2026-11-08 | Receive I4-09/I4-10 as I5-01/I5-02 and I4-AC-010/011 as I5-AC-001/002, without widening their commitments | Eugene: “Please narrow iteration 4 as recommended, move I4-09 and I4-10 to the next iteration, and update the waves, priorities, and dependent documents.” |

## Closure and Follow-up

Disposition I5-AC-001/002 with exact evidence, unmet results or explicitly approved
exceptions before human closure. Capture recommendations not adopted through
FW-042 or linked follow-up artifacts; assessment completion does not approve
replacement. Iteration closure does not advance feature/Specification statuses.

## References

- [RFC-016](../rfcs/rfc-016-observable-model-authoring-api.md)
- [FW-042](../future-work/fw-042-inline-array-and-span-storage-assessment.md)
- [Iteration 4](iteration-004-backend-and-application-integration.md)
