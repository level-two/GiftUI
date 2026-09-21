---
spec: SPEC-001
feature: signal-analyzer
title: Implementation Design — nRF Static Semantic Records
status: draft
authors:
  - codex
created: 2026-09-21
updated: 2026-09-21
implementation_plan: ../implementation-plans/spec-001-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — nRF Static Semantic Records

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specifications. It remains draft until the proposed record
> table is implemented and measured on the embedded compiler.

## Purpose and Boundary

SPEC-001 T6.8 needs a real Static semantic result that the common layout and
render stages can traverse. The current target host has only checked summary,
Canvas, and action metadata in its 3,024-byte candidate and published regions.
Those records do not represent the portable hierarchy and cannot be passed off
as a complete semantic result. This note selects an internal packed projection
and a generation/verification route for the missing primitive, modifier, tree,
and text records. It does not select a new public semantic API or alter the
approved resource audit.

## Governing Contract

The mechanism realizes SPEC-001's portable view hierarchy, semantic
publication, Static storage, and nRF target-host requirements, especially
SA-AC-005, SA-AC-024, SA-AC-025, SA-AC-039, and SA-AC-045. ADR-004 requires
one shared hierarchy; ADR-011 requires complete publication; ADR-033 requires
bounded typed actions. Approved SPEC-006/007/008/011/012/013/015 define the
reusable semantic, layout, render, Drawing, profile, and workload contracts.
The enclosing host-loop design remains
[the connected-target note](spec-001-connected-target-host-loop.md).

## Current-Code Context

`StaticSignalAnalyzerNRFSemanticRegion.generated.swift` currently owns an
88-byte checked prefix in each exact 3,024-byte region. It records the root,
normal/diagnostic summary, five Canvas descriptors, six action codes, revision,
and integrity word. Candidate storage resets at attempt finish; published
storage remains until replacement or quiescence. `DynamicSemanticHostStorage`
is a host-native oracle for the same portable `SignalAnalyzerView`, but its
arrays and path identities are not an Embedded Swift storage implementation.

## Proposed Internal Organization

The target host's generated Static source owns a compact ordered scope table
and scalar pool inside those same two regions. Each scope has a stable
generated `UInt16` identity derived from its portable source path and role,
not from the current variant's traversal ordinal. A generator or checked
extraction fixture derives the normal and diagnostic tables from the portable
hierarchy and compares them with the Dynamic semantic oracle. A package-local
view borrows a validated region synchronously and implements the existing
semantic layout/render query contracts over the packed records. The host owns
the region lifetime; no view or pointer to it escapes an opportunity.

## Data and Control Flow

The model is borrowed once for semantic derivation. The generated visitor
selects the normal or diagnostic variant, evaluates dynamic text and disabled
state, and writes a complete candidate. It validates counts, topology,
text bounds, action/Canvas associations, and checksum before layout reads it.
Layout and Drawing consume that candidate in the approved stage order. Only
after all required stages and interaction construction succeed does the host
publish by copying the exact validated candidate into retained storage,
changing state/revision/checksum. A rejected candidate leaves the prior
published region unchanged. The copy must borrow both nonoverlapping regions
in one checked scope; it must not spill 3,024 bytes onto the stack or retain
an unsafe pointer after a region borrow ends.

## Algorithms and Data Structures

The proposed upper-bound packing is:

| Region part | Maximum bytes |
| --- | ---: |
| Existing checked prefix | 88 |
| 98 scope records × 24 bytes | 2,352 |
| 139 Unicode scalar values × 4 bytes | 556 |
| Six action-to-scope ordinals × 2 bytes | 12 |
| Reserved alignment/schema space | 16 |
| **Total** | **3,024** |

A scope record carries a stable identity, parent/first-child/next-sibling
ordinals, kind/flags, and three 32-bit payload words. Different generated
kinds interpret payload words as stack spacing/alignment, frame dimensions,
padding, style, text-pool range, or Canvas/action association. An explicit
invalid ordinal represents no relation. The generated encoder checks every
ordinal and payload interpretation, unique identities, tree acyclicity,
exact variant counts, text-pool length, and consumed byte count. The decoder
rejects unknown schema/kinds or mismatched checksum before any query.

The oracle tests measure 96 scopes and 117 text scalars for the normal
variant, and 98 scopes and 129 text scalars for the diagnostic variant. The
98-scope ceiling is the measured diagnostic maximum of 48 semantic nodes plus
50 modifiers; the 139-scalar ceiling comes from the approved generated
workload and leaves ten scalars of headroom. A render-only structural path is
projected to its nearest concrete
scope using the same semantics as the Dynamic oracle. Source-path identity
stability is checked across both variants, especially for all six controls.
If any required current payload cannot be encoded in the three words, this
packing must be revised within the *same* 3,024-byte bound and revalidated;
it is not permission to truncate a modifier or alter the portable hierarchy.

## Lifecycle and State

Construction clears caller-owned profile storage. A candidate belongs to one
active attempt and is invalid after finish. The published region is retained
between attempts, accepts only a strictly newer semantic revision, and is
cleared at quiescence. Validation and publication are fail-closed. The region
pair borrow must preserve the former published bytes until all candidate and
revision checks pass.

## Runtime Profiles and Platforms

Only nRF Static uses this packed representation. Dynamic Pi remains the
comparison oracle, not an embedded dependency. Host-native tests establish
semantic equivalence; a later nRF cross-build establishes compilation, VFP
ABI, forbidden-symbol, and static resource evidence. Neither substitutes for
connected TFT/input execution.

## Resource and Failure Behavior

The table consumes no heap, existential registry, reflection, full
framebuffer, or unbounded collection. Encoding uses fixed counters and
caller-owned regions. Every count, offset, scalar, and revision uses checked
arithmetic; first excess or malformed table fails before publication. The
region-pair operation must not create a full-region temporary on the stack.

## Test and Diagnostic Seams

Host tests compare both variants' primitive/modifier tree, text scalars,
Canvas association, actions and disabled state with the Dynamic semantic
oracle. Negative tests corrupt every record family and reject overflow,
cycle, dangling relation, duplicate identity, stale revision, and late borrow.
The contract manifest records offsets and generated-source provenance. The
nRF build and connected run are recorded separately under T6.8/T8.2.

## Rejected Implementation Alternatives

- Copying `DynamicSemanticHostStorage` into firmware would introduce arrays
  and heap-backed path identities.
- Treating the existing count-only prefix as a semantic result would let
  layout/render bypass the portable hierarchy.
- A full-region stack copy would threaten the approved embedded stack margin.

## Open Implementation Questions

The exact per-kind payload encoding and whether 24 bytes is sufficient for
every current modifier remain to be verified against the real hierarchy.
This is an implementation packing question, not authority to drop semantics;
failure to fit the approved 3,024-byte region is a contract issue to report
upstream. Generator provenance and embedded compiler measurements remain
required before this note can become `current`.

## Code and Evidence Links

- [Current checked prefix](../../Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFSemanticRegion.generated.swift)
- [Portable hierarchy](../../Sources/SignalAnalyzerPresentation/SignalAnalyzerView.swift)
- [Dynamic semantic oracle](../../Sources/GiftUIRuntimeDynamic/DynamicSemanticHostStorage.swift)
- [T6.8 evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/nrf52840-tft-input-adapter.md)
