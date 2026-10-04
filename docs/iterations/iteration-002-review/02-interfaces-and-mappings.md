# Step 02 — Interfaces, Types, and Mappings

Source baseline: `6cf31f266987e917458f31f05ed8c390cda9a202`.
This pass inspects selected producer/consumer seams, not every type in every
module. Governing contracts: SPEC-002/006/007/008/011/013 and the SPEC-001
target-host joins.

## Interaction staging: reproduced capacity omission

`InteractionState` receives five independent storage instances. At
`Sources/GiftUIInteraction/InteractionState.swift:51`, initial admission checks
four capacities but omits `candidateCommittedRecords.capacity`. At line 223,
finish preflight again checks retained committed capacity without checking the
staged committed buffer. When the latter fills, line 247 returns
`.invariantViolation`.

The [research probe](capacity-probe.swift) supplies two candidate slots, two hit
slots, two retained committed slots, and only one staged committed slot. It
compiles the unchanged maintained `InteractionState`, storage protocols, and
values, with instrumented bounded storage. Reproduce from the repository root:

```sh
python3 docs/iterations/iteration-002-review/run-capacity-probe.py
```

Observed:

```text
begin=nil
append-1=requiresGeneration
assign-1=nil
append-2=requiresGeneration
assign-2=nil
finish=Optional(InteractionCapacityResearch.InteractionError.invariantViolation)
after-discard=nil
```

SPEC-011's Lifecycle section requires every capacity/commit-storage preflight
at finish. Its Error Handling table distinguishes contained candidate capacity
exhaustion from runtime safety-not-proven invariant violation. The result is
a reproducible error-classification/preflight defect, not a publication of a
partial table. See CBR-001 in the [register](findings.md).

Counterevidence: the inspected standard nRF construction provides matching
six-slot stores, and existing `makeState(capacity:)` test helpers assign one
capacity to all five stores. No current standard-host failure is demonstrated.
Fresh `GiftUIInteractionTests` pass: 17 XCTest tests and three Swift Testing
cases. That success does not cover this asymmetric-storage input.

The probe was rerun after that root-package build and formatted with the
repository configuration. [Exact result, source/object hashes, and compile
command](evidence/02-capacity-probe.json) identify its inputs. Compiler: Apple
Swift 6.3.3, arm64 macOS. Its lower-owner modules/objects come from the local
root build, and it proves no Embedded or connected behavior. The first probe
attempt used `GiftUI` instead of SwiftPM's `giftui` package identity and could
not access package declarations; that was corrected in the harness only.

## nRF hierarchy mappings: supported simplification opportunity

The portable `SignalAnalyzerView` and its packed nRF projection intentionally
have different storage representations. The packed 3,024-byte semantic region
and checked Int16 layout records preserve fixed storage and checked conversion;
removing those adapters solely to reduce type count is not justified.

The maintenance coupling is more specific: ordinary source files
`StaticSignalAnalyzerNRFModelTextWriter.swift:16,78` and
`StaticSignalAnalyzerNRFModelModifierWriter.swift:52,77` manually bind semantic
roles and model values to numeric ordinals. The topology generator separately
uses a fixed `live` ordinal list and measured JSON projections, and rewrites
parts of existing generated files. A hierarchy edit can therefore require
coordinated changes beyond the portable declaration and a generator run.

Current parity, topology validation, and checksums are counterevidence against
claiming a present semantic mismatch. CBR-002 supports an investigation of
reducing coordinated maintenance: runtime derivation and generated stable-role
bindings are alternatives to measure, not accepted replacements. This refines
the existing hierarchy candidate; it does not include unrelated Static Canvas
specialization or resource generation.

## Duplicate text algorithms: live startup probes, not dead code

`StaticSignalAnalyzerNRFEmbeddedTextMeasure` and `...TextPlace` implement text
layout algorithms in the target host. The production opportunity's
`resolveLayout` in `StaticPreset.swift:2888` instead calls the common
`StaticSignalAnalyzerNRFCommonLayoutPass` and shared `LayoutEngine`.

The older text algorithms are still called by
`giftUISignalAnalyzerLayoutTextValid` at `StaticPreset.swift:300,356`, by
`main.c:82` during startup validation, and by focused tests. They are therefore
not unused files. CBR-003 proposes reviewing whether those probes can exercise
the shared algorithm over the packed workspace, retaining codec/invariant
coverage while retiring duplicated text rules. No flash saving is asserted
without a measured linked artifact.

## Separations retained after inspection

- Candidate records allow a pending generation; committed records require a
  generation. Those types encode different validity states.
- Action generation, model-target generation, semantic revision, and physical
  presentation revision guard different lifetimes. Equal raw widths do not
  make their meanings interchangeable.
- Scoped presentation committers and layout/render adapters combine different
  owner contracts at the target composition boundary. Their existence is not
  by itself leakage into a lower module.
- Native and Embedded workspace realizations can legitimately differ while
  using the common algorithm. Shared semantics need not mean identical storage.

Detailed borrow-escape, all public/package declarations, all adapters, and every
profile construction remain open in the coverage matrix.
