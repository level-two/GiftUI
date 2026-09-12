---
spec: SPEC-013
feature: giftui-mvp-architecture
title: Implementation Design — Static Generation and Capture Lifetime
status: current
authors:
  - codex
created: 2026-09-12
updated: 2026-09-12
implementation_plan: ../implementation-plans/spec-013-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Static Generation and Capture Lifetime

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note explains SPEC-013 T4.1, T4.3, and T4.4's consumption of the already
approved SPEC-010 observable-slot and SPEC-012 Canvas generator contracts. It
covers deterministic generated metadata, fixed occurrence storage, complete
dispatch, and capture destruction. It does not define a second generator
grammar, select application capacities, or permit a closure fallback.

## Governing Contract

SPEC-013 requires the Static profile to replace dynamic Canvas closures with
nonzero generated callable IDs and inline fixed-layout captures, validate one
complete table at startup, and destroy each occurrence immediately after
invocation. SPEC-010 owns observable structural keys, slot generations, and
generated host traversal. SPEC-012 owns source input validation, deterministic
callable IDs, capture layout, dispatch grammar, typed invocation, and build
rejection. RP-002, RP-003, RP-010, RP-012, and RP-014 consume the resulting
bindings and evidence.

## Inputs and Provenance

The Static build consumes two checked generated inputs:

- SPEC-010's generated observable host declarations and deterministic lexical
  slot order; and
- SPEC-012's checked Canvas manifest, whose source path, schema, expression
  order, IDs, capture fields, offsets, alignments, byte counts, switch
  coverage, and occurrence order are authoritative generator outputs.

Generated source names its input manifest and digest. Regeneration from equal
inputs must be byte-identical. Runtime Profile code validates and stores the
output; it never reparses Presentation source or assigns new IDs.

## Generated Types and Bindings

Each observable occurrence binds its generated structural key and slot index
to the SPEC-010 fixed storage protocol. Each syntactic Canvas expression owns
one nonzero `UInt16` callable ID. Runtime occurrences reuse that ID but own
separate fixed capture records. The generated capture union has the greatest
case size and alignment, never the sum of all cases.

The profile-owned occurrence record contains exactly identity, callable ID,
declared capture byte count, live/released state, and inline capture storage.
It contains no closure, existential, reflection token, dynamic collection, or
fallback box. The audit charges occurrence records and inline capture bytes to
`canvasCallableBytes`; generated switch code is reported separately.

## Validation and Dispatch

Startup validation runs through Runtime Core's
`RuntimeStaticCanvasAuditMetadata`. It checks nonzero bounded case count,
dense `1...count` coverage exactly once, and each exact capture size before any
client or Canvas invocation.

Staging rejects zero/out-of-range IDs and capture-size disagreement before
invocation. Dispatch passes the inline capture as a borrow into the one
generated `StaticCanvasCallableTable` switch. A missing case is a typed Drawing
invariant, not a default closure or dynamic lookup.

## Lifetime and Cleanup

The occurrence record is live from semantic staging through its one
post-layout invocation. On both normal return and typed throw, the adapter
marks it released and destroys the inline capture before publication. Cleanup
releases all later uninvoked occurrences once. Candidate discard, failure,
quiescence, and all-storage reset cannot revive or replay a released capture.

Observable generated records follow SPEC-010's candidate/live publication and
retirement rules independently. Canvas and observable tables may share source
provenance reporting but never storage or IDs.

## Resource and Failure Behavior

Static construction and use allocate zero heap memory. Checked IDs, sizes,
counts, and byte totals never saturate. The generated-code report records
switch text size and greatest inline capture separately from
`canvasCallableBytes`. Unsupported capture source remains a generator/build
failure and cannot become a runtime validation result.

## Test Seams

Tests reproduce the canonical generator inputs, compare stable source digest,
validate exact metadata, fault zero/range/size/coverage cases, invoke every
case, and count destruction after normal and throwing exits. Optimized build,
SIL, symbol, and linked-image inspection reject allocation, closure boxes,
reflection, and incomplete dispatch.

## Rejected Alternatives

- Reassigning Canvas IDs inside Runtime Static was rejected because SPEC-012
  owns deterministic source lowering.
- Storing a union plus an escaping closure was rejected because it is a heap
  fallback and makes switch coverage non-authoritative.
- Summing every capture case into each occurrence was rejected because the
  approved representation uses the greatest aligned case extent.
- Sharing observable and Canvas IDs or storage was rejected because their
  owners, generations, and lifetimes differ.

## Open Implementation Questions

No generator-contract question remains. Exact first-party generated inputs and
numeric capacities remain downstream SPEC-001/SPEC-015 work; T4 fixtures use
only the checked artificial manifests and cannot claim production host values.
