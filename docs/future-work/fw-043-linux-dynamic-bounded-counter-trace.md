---
id: FW-043
feature: giftui-mvp-architecture
title: Assess bounded counter trace writing for Linux Dynamic
status: captured
authors:
  - codex
created: 2026-11-07
updated: 2026-11-08
source:
  - SPEC-015
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

> Historical record: local supporting artifact references were removed during repository cleanup. This edited record does not establish current conformance.

# FW-043: Assess bounded counter trace writing for Linux Dynamic

> This capture preserves a candidate only. It does not change the retained P08
> source, trace contract, or implementation scope.

## Observation / Opportunity

`CounterPipelineOwner.swift` already contains finite bounded writers for many
shared P08 trace shapes, but enables them only for macOS Static and uses
`Darwin.write`. A source inventory identified three Linux-only top-level tuple
shapes with no matching overload. Linux Dynamic continues through generic
`print`, which adds generic reflection and remangling to the linked path. A
Linux-compatible bounded writer might reduce that path if it covers all
selected Dynamic call-site types and preserves the current Pi trace bytes.

## Why Deferred

The preserved Pi evidence is cross-compilation and link evidence; it contains
no Pi application stdout transcript. This environment has no `qemu-arm` runner.
The existing writer's comments pin some reflection spellings, including an
opaque `InlineArray` spelling, to the macOS compiler. Therefore the existing
Native output cannot serve as an exact Pi trace oracle, and no output
equivalence claim is supported yet.

## Potential Value

- A finite writer could avoid generic reflection/remangling work in this
  validation executable and narrow the Pi linked resource proof.

## Current Non-goals

- No current Pi source or trace change is authorized by this capture.
- No trace spelling, application behavior, or resource result is presumed.
- This item does not replace P08's required linked stack/provider/fit evidence.

## Revisit Triggers

- A trustworthy stdout transcript for the exact current Pi image becomes
  available, or a supported local ARMv6 runner can execute that image.
- Any future experiment must first enumerate all selected Dynamic trace types,
  compare complete output bytes, and run a focused ARMv6 cross-compile before
  considering broader evidence refresh.

## Disposition

Captured. P08 is FROZEN / UNMET under the
[approved freeze and certification transfer](../iterations/iteration-003-review/p08-freeze-and-certification-transfer.md).
The existing Pi ELF and conditional proof evidence are retained; old-composition
certification does not continue solely to obtain a P08 PASS. This idea remains
non-authoritative. Its revisit triggers require applicable authorization under
the receiving work's normal gates and do not themselves restart the frozen campaign.

## References

- [SPEC-015](../specs/spec-015-host-configuration.md), deterministic mock trace
  and exact host-fixture alignment.
- [P08 Pi current collection and early image](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-pi-collection-image-result.md),
  which explicitly records cross-compilation rather than target execution.
- [CounterPipelineOwner.swift](../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift),
  bounded Native writer and generic Dynamic `counterTrace` call path.
- Dynamic trace source review,
  exact Linux call-site shape inventory and output-oracle disposition.
