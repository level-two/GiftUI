# ITERATION-003 Revision 3: Runtime View-Graph Derivation

Date: 2026-10-06. Maintainer: Eugene.

## Maintainer instruction

> Let’s add to the third iteration the removing of the .generated file containing unwrapped view graph, and replace it with the on the fly derivation, like we have for the RPi target. Later we will consider returning to such approach if really needed (when we will have support of interchangeable frontend modules), but now let’s stick into the runtime derivation completely

This explicitly adds a delivery outcome to
[ITERATION-003](../iteration-003-dev-ux-improvement.md). Revision 3 records this
scope authorization; it does not approve an RFC, ADR, Specification or production
implementation. Revision 2 and its original approval remain preserved in Git
history and the [earlier scope review](scope-review-and-approval.md).

## Amendment boundaries

- Add I3-04 and IT-AC-006: remove generated expanded/unwrapped view-graph
  artifacts and production graph-generation dependencies; derive the graph at
  runtime from portable view declarations for Signal Analyzer and the outside
  consumer across macOS Dynamic/Static, Pi ARMv6 Dynamic and nRF Embedded Static.
- Preserve bounded Static storage, zero-heap execution, semantic parity and
  reviewed resource limits. Runtime derivation does not imply Dynamic storage
  on Embedded or replacement of every packed representation.
- A generated topology moved into a different source file, binding table or
  build product still violates the outcome. Other generated resources and
  configuration are not blanket removal targets.
- Retain IT-AC-001–005. Carry the added constraint into draft RFC-013 and audit
  affected accepted decisions and Specifications before implementation. The
  finite binding/build mechanism and safe resource realization remain open.
- Capture possible future generated graphs in FW-035. Reconsider only after
  interchangeable frontend modules are supported and evidence demonstrates a
  concrete need; this adds no frontend-modularity delivery commitment.

## Source observations and routing

The Pi Dynamic pipeline calls `expandSemanticTreeWithStateBinding` on
`SignalAnalyzerView` in
[DynamicSignalAnalyzerPresentationPipeline.swift](../../../Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPresentationPipeline.swift).
The current Static production path includes pre-expanded topology in
[StaticSignalAnalyzerNRFTopologyWriter.generated.swift](../../../Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFTopologyWriter.generated.swift),
produced with packed records by
[generate-spec-001-nrf-topology.py](../../../scripts/contracts/generate-spec-001-nrf-topology.py).
These locate the scope target, not an exhaustive migration inventory or an
implementation design.

The architecture baseline remains implemented under accepted ADR-006 and the
affected owner decisions/Specs. External application integration remains at RFC
stage under accepted PROPOSAL-007 and draft RFC-013. This is post-MVP work: the
closed MVP validated one application across four stacks; revision 3 removes a
development-time graph dependency as part of iteration 3's integration work.

## References

- [RFC-013](../../rfcs/rfc-013-external-application-and-backend-integration.md)
- [FW-035](../../future-work/fw-035-generated-view-graph-for-interchangeable-frontends.md)
- [Numbered Iteration Scopes](../../engineering/ITERATION_SCOPES.md)

