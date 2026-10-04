# Step 05 — Portable Declarations and Application Boundaries

Source baseline: `6cf31f26`; review performed on the documentation-only branch.
This pass checks the portable/application boundary and representative execution
paths against SPEC-001/002/006/010/012 and ADR-001/002/003/004/033.

| Owner | Producers / consumers inspected | Responsibility and result |
| --- | --- | --- |
| GiftUI | DeclarativeView, State, Button, action/Canvas payloads, bounded text and checked geometry; semantic traversal and application declarations | Leaf declaration/value owner. Fixed tuple/conditional/optional forms preserve source structure; traversal witnesses allow another owner to expand without importing it. Public underscored compiler witnesses are contractual, not automatically accidental exposed storage. |
| GiftUIMacros | ObservableStateHostMacro, declaration visitor and macro tests | Syntax-only generation of direct declaration ordinals and witnesses; no runtime reflection/discovery. Macro implementation dependencies are compile-time tools, not firmware dependencies. |
| GiftUIDynamicConveniences | DynamicCanvas and portable Canvas | Exact opt-in alias, not a second renderer or pipeline. Removing it is a public spelling decision without demonstrated cleanup benefit. |
| SignalAnalyzerDomain | Acquisition protocols/use cases, primitive/capture/change/publication/diagnostic values | No concrete Data/GiftUI import. Snapshot bootstrap and bounded mutation replay have different lifetime and continuity rules; their representations should not be merged merely because both carry capture state. |
| SignalAnalyzerData | Repository, store, deterministic source/generator; Domain protocols and Presentation sinks | Owns source lifecycle, capture ordering/retention and synchronous revisioned delivery. New terminal-during-start defect reproduced below. |
| SignalAnalyzerPresentation | Portable hierarchy, model, admission adapter, waveform and timeline formatting, normalization/policy seams | Uses injected Domain use cases and fact admission; does not schedule acquisition or import concrete Data. Six typed actions and fixed four-channel declarations remain portable. |
| SignalAnalyzerHost | HostFactAdmission and Presentation fact submission | Host-side bounded admission adapter, separated from portable declaration construction. Detailed runtime/host joins reviewed in later steps. |

The fixed five-child builder maximum and fixed four-channel hierarchy are
requirements (DV-002, SA-AC-006), not evidence that variable collections were
forgotten. State declaration ordinals and semantic locations protect reevaluation
identity; macro/public witness count does not justify erasing that distinction.
BoundedText checks byte capacity and UTF-8; diagnostics and display text cross
the boundary through a checked conversion instead of sharing Domain with GiftUI.

Capture insertion is stable at equal times; eviction updates baselines.
Waveforms use transitions strictly after the left edge and through the right
edge, starting from the level at/before the left edge. Visible ranges and rounded
ruler labels share portable helpers. The five-second candidate reaches retention
contracts/stores, not the existing 30-second validation workload.

## CBR-007 — Terminal callback during source startup is overwritten

The unchanged actual Data sources, including the real deterministic source,
were compiled by [run-acquisition-start-probe.py](run-acquisition-start-probe.py).
[Evidence](evidence/05-acquisition-start-probe.json) includes source/object hashes,
compile command, and exact output. Reproduce from the root after building Domain:

```sh
python3 docs/iterations/iteration-002-review/run-acquisition-start-probe.py
```

At initial capture revision `UInt32.max - 1` and `UInt32.max`, synchronous initial
levels trigger exactly one terminal publication, yet `start()` returns with
`repositoryRunning=true`, `sourceActive=true`, and one ordinary running
publication. A second Start throws unavailable: terminal status and reported
running status disagree. SPEC-001's terminal revision procedure at lines 679–692
requires a retained failed state and stopped source delivery.

`DefaultSignalAcquisitionRepository.start()` sets active/running only after
`source.start` returns. During its callbacks, `failRevision()` sees the old
inactive flag, then `start()` overwrites the failed state. Existing revision
tests emit after startup and do not cover this synchronous boundary. The probe
does not claim full-host containment or Embedded behavior; normal initial
revision zero is counterevidence against an immediate ordinary-launch failure.

No code changed. See the [register](findings.md) for correction/validation routing.
Fresh whole-profile validation is consolidated after the source review steps;
this pass's behavioral evidence is the independent startup reproduction.
