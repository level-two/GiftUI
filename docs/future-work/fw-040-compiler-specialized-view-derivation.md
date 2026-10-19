---
id: FW-040
feature: external-application-integration
title: Compiler-Specialized View Derivation
status: captured
authors:
  - codex
created: 2026-10-19
updated: 2026-10-19
source:
  - ADR-035
related_future_work:
  - FW-035
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-040: Compiler-Specialized View Derivation

## Observation / Opportunity

In discussion on 2026-10-19, Eugene proposed using SwiftUI-like strongly typed
view composition, associated `Body` types and static methods to automate graph
derivation and move avoidable calculations out of runtime. He requested durable
capture for consideration in a future iteration.

GiftUI already has associated `Body` types, result-builder composition and
generic semantic traversal. Investigate how much concrete-type specialization,
inlining and constant folding can simplify that traversal while actual
declarations and live state still determine occurrences. A `static` method alone
does not guarantee compile-time evaluation; generic instance methods can also
specialize. Type structure can describe fixed children and possible branches,
but does not alone determine active branches, occurrence identity or live values.

Distinguish compiler optimization of runtime derivation from precomputed expanded
topology. The latter is separately captured in FW-035 and conflicts with the
current ADR-035 replacement contract. This item does not assume that SwiftUI's
entire live graph is constructed at compile time.

## Why Deferred

Current work must establish the accepted runtime-derived record implementation
and its conformance. No measured comparison yet establishes additional savings
from this proposal. It is an optimization hypothesis for later iteration
planning, not a prerequisite for current scope.

## Potential Value

- Derive semantics directly from portable declarations without an
  application-specific expanded graph artifact.
- Reduce dispatch, intermediate construction and invariant calculation costs
  where the compiler can prove their removal safe.
- Improve embedded derivation time or stack use, subject to flash/RAM trade-offs.

## Current Non-goals

- Changing current iteration commitments, ADR-035 or approved Specifications.
- Reintroducing generated occurrence topology or retaining the entire expanded
  typed declaration tree.
- Assuming specialization removes state reads, record publication, identity
  reconciliation or state-dependent layout work.
- Authorizing a prototype, compiler migration, hardware run or production change.

## Revisit Triggers

- At planning for the first performance-focused iteration after the runtime
  derivation replacement passes its contract and conformance gates, assess this
  item against a reproducible derivation/resource baseline.
- Earlier if profiling identifies typed traversal, body temporaries or invariant
  graph-construction work as a material contributor to a recorded time, stack,
  RAM or flash budget problem; use the normal change process if it blocks scope.

## Disposition

Captured; no iteration assigned. The proposed next step is an Exploration with a
bounded Spike if implementation evidence is needed. Compare representative fixed
and state-dependent declarations on the same pinned toolchain and optimization
settings; inspect optimized SIL/assembly and measure derivation time, complete
peak stack, linked RAM and flash. Include repeated same-type occurrences,
conditional/optional branches and state/action identity preservation. State
comparison thresholds and stop conditions before execution; distinguish
hardware-free evidence from connected-target timing and stack evidence.

If evidence supports investment, promote through an accepted Proposal and the
applicable RFC/ADR/Specification path, reusing existing authority only where it
covers the work. A later iteration may explicitly select the investigation or
approved implementation; iteration inclusion does not replace lifecycle gates.
Any proposal to precompute occurrence topology must explicitly revisit ADR-035
and FW-035 rather than be classified as ordinary specialization.

## References

- [ADR-035: Runtime-Derived Records and Exact Identity](../adrs/adr-035-runtime-derived-records-and-exact-identity.md).
- [FW-035: Generated View Graphs for Interchangeable Frontends](fw-035-generated-view-graph-for-interchangeable-frontends.md).
- [Typed declaration and traversal contracts](../../Sources/GiftUI/DeclarativeView.swift).
- [Current generated nRF topology](../../Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFTopologyWriter.generated.swift).
- [Embedded Swift specialization model](https://github.com/swiftlang/swift-evolution/blob/main/visions/embedded-swift.md).
- [Apple: Demystify SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10022/).
