---
id: SPIKE-011
feature: signal-analyzer
title: Clean Offline Analyzer Topology Table Generation
status: completed
authors:
  - codex
created: 2026-10-04
updated: 2026-10-04
source:
  - EXP-001
related_future_work: []
related_explorations:
  - EXP-001
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# SPIKE-011: Clean Offline Analyzer Topology Table Generation

## Target Questions

Can both outputs of the current topology updater be generated from empty
directories without reading previous generated Swift? Can the resulting
tables preserve complete staged semantic bytes and linked costs, and refuse
malformed/stale input before creating partial output?

## Bounds / Stop Conditions

Hardware-free only, both actual measured analyzer projections and the existing
packed schema/codec. Replace neither production scripts nor model/Canvas/state
owners. Stop on source mismatch, malformed graph acceptance, partial output,
semantic transcript mismatch or ABI/heap failure. The maintainer explicitly
kept connected validation deferred.

## Method

The disposable generator reads normal/diagnostic JSON projections, explicit
schema/binding policy and two versioned Swift templates. The templates retain
codec/scaffold operations; topology shapes, fingerprints, generated payload
cases, ordinal/identity lookup cases and projection-derived loop counts are
placeholders. All placeholders are populated from inputs. Neither previous
generated file is read by the generator.

Templates were extracted once from the reviewed implementation, making their
codec provenance explicit. The policy preserves schema capacity/action count,
15 live-modifier identities and identity-keyed layout-property bindings. This
policy is still analyzer-specific metadata; clean generation does not eliminate
manual binding policy or the separate model writers. No claim of automatic
whole-view semantic generation follows from it.

Two CLI runs use an isolated input bundle and registered declaration-source
snapshots, with no generated Swift beneath either input root. Each output
directory is deleted before generation. The runner subsequently reads the
production outputs only as comparison oracles and prepares a copied firmware
application selecting the new outputs.

Validation checks capacity, ranges, unique nonzero identity, root-first graph,
reachability, parent/child agreement, modifier kinds, variant shape/invariants,
binding kinds and source hashes. Registered declaration hash changes require
an explicit projection/policy refresh; hash checks detect staleness, not semantic
correctness of newly supplied fixtures. Validation completes before any output
file is created; a nonempty output directory is refused.

## Reproduction

From the repository root after production/native-owner builds:

```sh
python3 experiments/spike-011-clean-topology-generation/run.py
bash docs/iterations/iteration-002-review/build-research-firmware.sh spike-011-clean-topology-generation
python3 docs/iterations/iteration-002-review/measure-research-elf.py experiments/spike-011-clean-topology-generation/evidence/elf-comparison.json .build/nrf52840/signal-analyzer-static .build/nrf52840/spike-011-clean-topology-generation/firmware
```

Standalone generator interface:
`generate.py INPUT_BUNDLE DECLARATION_SOURCE_ROOT EMPTY_OUTPUT`.
The runner prepares the bundle and records hashes of fixtures, templates,
policy, registered declarations, native objects and parity probe. Generated
files/objects/firmware stay under `.build/nrf52840/`.

## Results

- Two clean generations have identical hashes. Both complete generated Swift
  files match production **byte-for-byte**, including the shared schema codec.
- Twelve refusals pass: duplicate/zero identity, noncontiguous ordinal,
  out-of-range child, child cycle, parent disagreement, unsupported modifier,
  variant shape mismatch, invariant payload mismatch, capacity overflow,
  stale registered declaration and nonempty output. Invalid input produces
  no partial output directory.
- The actual native firmware closure preserves all 42 complete 3,024-byte
  semantic transcripts, 84 wrong-size/variant refusals and 42 retirements.
  The transcript is 306,792 bytes, SHA-256
  `38c2bf62917e58745b079c14bd338a724dc2272e877cad658b1a5e8437de775c`.
- Linked flash remains **275,600 bytes** and RAM **191,104 bytes**: both deltas
  zero. ARMv7E-M/VFP ABI, disabled heaps, checked allocator absence and the
  existing refusal stub pass. Firmware was built, not executed on a board.

[Input/result record](../../experiments/spike-011-clean-topology-generation/evidence/result.json),
[semantic transcript](../../experiments/spike-011-clean-topology-generation/evidence/semantic-transcript.txt.gz),
[paired ELF comparison](../../experiments/spike-011-clean-topology-generation/evidence/elf-comparison.json).

## Limitations

The input projections remain measured fixtures, not executable portable view
source. Four registered declaration sources have freshness checks; transitive
declaration changes require extending/refreshing that registration. A complete
production integration needs projection regeneration/freshness orchestration,
supported failure diagnostics, template ownership and the repository generator
gate. Independent pixel/observable/Canvas parity is not freshly established by
this Spike; emitted sources and semantic inputs are unchanged.

The explicit live/layout binding policy and the model writers still require
maintenance. SPIKE-009's named roles are a separate compatible cleanup, not
silently incorporated here. Runtime declaration replacement, target timing
and physical stack high-water are outside this experiment.

## Disposition

Complete the clean-generation investigation with a supported tooling-cleanup
candidate: replace patch-in-place generation with explicit templates/policy and
clean emission while retaining packed storage and runtime owners. Select that
bounded candidate during iteration planning; normal production review/gates
precede adoption. Full runtime replacement is unnecessary to remove the
generator's dependency on previous output contents.

## References

- [EXP-001](../explorations/exp-001-nrf-hierarchy-derivation.md)
- [Step 19](../iterations/iteration-002-review/19-clean-topology-generation.md)
- [Current updater](../../scripts/contracts/generate-spec-001-nrf-topology.py)
- [Disposable generator](../../experiments/spike-011-clean-topology-generation/generate.py)
- [Disposable runner](../../experiments/spike-011-clean-topology-generation/run.py)
- [Explicit binding/schema policy](../../experiments/spike-011-clean-topology-generation/policy.json)
