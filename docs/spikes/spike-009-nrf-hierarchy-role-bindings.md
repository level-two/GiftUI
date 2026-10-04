---
id: SPIKE-009
feature: signal-analyzer
title: nRF Hierarchy Direct-Module Probe and Generated Role Bindings
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
related_spikes:
  - SPIKE-012
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# SPIKE-009: nRF Hierarchy Direct-Module Probe and Generated Role Bindings

Disposable investigation under EXP-001 and draft ITERATION-002. Signal Analyzer
is implemented; this research preserves MVP's common-client-model and bounded
Static constraints. It approves neither replacement nor production code.

## Target Questions

1. Can an unmodified portable dependency closure be compiled directly for
   Embedded Swift as the first prerequisite to direct runtime view derivation?
2. Can the 17 text and 15 live-modifier bindings be inferred from measured
   portable projections, eliminating numeric ordinal coordination in writers?
3. What parity and constrained-resource evidence does that narrower candidate
   produce, and which full-replacement questions remain unanswered?

## Bounds / Stop Conditions

Hardware-free only; current actual declarations, pinned paired Swift 6.3.2,
Zephyr configuration and nRF52840-DK Cortex-M4F hard-float options. No public
API/architecture/contract changes, model substitution disguised as the portable
view, wholesale generated-table replacement, connected work or capture changes.
Stop the direct-module route at an actual Embedded restriction; record later
parity/size/timing as unavailable for that route. Resource acceptance deltas
were requested from the maintainer but are not agreed; report measurements
without declaring a replacement meets a budget. Zero heaps and ABI are checks.

## Method and Reproduction

Run `python3 experiments/spike-009-nrf-hierarchy-roles/run.py` from the root
after the production nRF and native-owner build. The runner recovers exact
Domain compiler/options from the production Ninja graph and compiles the full
actual Domain sources with a project-local module cache. It uses the actual
portable normal/diagnostic render-projection fixtures to infer named roles from
unique text anchors and local button/channel ancestry. It validates structural
roles across both fixtures and fails on missing/duplicate anchors. An ordinal
shift verifies that inference is not pinned to current ordinal numbers.

The candidate generates role identity/ordinal constants and transforms copied
text/modifier writers to dispatch on role identities, including replacing
ordinal ordering/channel arithmetic. It retains the current packed schema,
topology updater, invariant tables and downstream owners. This is a measured
partial cleanup alternative, not complete offline generation or declaration
runtime derivation. Role inference still depends on the known local modifier
shape and canonical projection state; production should expose/check explicit
semantic roles rather than silently infer them from mutable labels.

`Probe.swift` executes the actual firmware Swift closure twice: original and
candidate. Forty-two cases combine idle/running/stopped/failed, 1/2/5s windows,
normal/96-newline diagnostics, and empty/populated four-channel captures.
Each compares complete 3,024-byte staged semantic regions, preserving identity,
text, modifiers, action associations, Canvas bindings and checksum. The runner
compares every transcript byte before hashing and preserves a compressed copy.
Each case also rejects wrong-sized regions and mismatched variants and retires
the model. Five batches of 1,000 semantic derivations measure native timing for
normal/diagnostic states after fixture setup, excluding transcript printing.

Build the copied application with
`bash docs/iterations/iteration-002-review/build-research-firmware.sh spike-009-hierarchy-roles`.
Run `measure-research-elf.py` against production and candidate build directories.
All generated objects/firmware stay under `.build/nrf52840/`. Compare writer
entry frames using the nm addresses and objdump instruction ranges recorded
below; full physical high-water measurement requires connected authorization.

## Results

**Direct unmodified-module route: negative.** The actual
`SignalAcquisitionContracts.swift` uses `any SignalAcquisitionRepository` in
observation/use-case objects. The paired Embedded compiler rejects its stop,
start and clear calls with EmbeddedRestrictions. Generic observation methods
also issue restrictions. This failure precedes the view/macro stage; it does
not originate in a missing macro plugin, tool cache or substitute miniature
view. No linked candidate or runtime cost/parity result exists for this route.
It does not prove that declaration lowering or typed witness derivation is
impossible; the current target already uses lowered typed owners.
[Exact commands, compiler version and diagnostics](../../experiments/spike-009-nrf-hierarchy-roles/evidence/result.json).

**Generated role-binding route: positive bounded evidence.** Thirty-two roles
match both projections and survive ordinal renumbering; missing/duplicate title
anchors are rejected. All 42 full semantic transcripts match byte-for-byte,
including normal and diagnostic states and all three windows. Eighty-four
wrong-region/wrong-variant checks and 42 model retirements pass.
Transcript: 306,792 bytes, SHA-256
`38c2bf62917e58745b079c14bd338a724dc2272e877cad658b1a5e8437de775c`.
[Compressed transcript](../../experiments/spike-009-nrf-hierarchy-roles/evidence/semantic-transcript.txt.gz).

| Linked metric | Original | Role candidate | Delta |
| --- | ---: | ---: | ---: |
| Flash | 275,600 | 275,792 | +192 bytes |
| RAM | 191,104 | 191,104 | 0 |

Both images pass ARMv7E-M/VFP and disabled heaps, retain the unchanged refusal
stub, and contain no allocator entry among the checked allocator symbols.
Stack reservations are unchanged. [ELF identities/configuration](../../experiments/spike-009-nrf-hierarchy-roles/evidence/elf-comparison.json).

Inspected entry allocations, including pushed registers, are: text populate
608→600 bytes; text value 296→296; modifier populate 96→96; modifier payload
128→120. These are local prologues, not a complete call-chain bound or proof
that peak stack cannot increase elsewhere.
[Addressed instructions](../../experiments/spike-009-nrf-hierarchy-roles/evidence/writer-entry-frames.json).

Native median derivation times: normal 60,515→60,443ns; diagnostic
61,029→60,964ns. These differences are small/noisy, measured on macOS with
native Swift and substituted hardware, in sequential baseline/candidate runs.
They support no speedup or nRF latency claim and cannot satisfy a target-time
acceptance budget. No heap allocation proof is inferred from native allocation
behavior; the constrained image/configuration and production owners govern it.

## Limitations

- Full portable runtime derivation, bounded typed witness lowering and complete
  clean table generation were not implemented. The direct-module candidate
  stopped at its first real compiler prerequisite failure.
- Full staged semantic bytes match, so downstream input is unchanged, but this
  experiment does not independently rerun every raster/action/observable
  exception and invalid-identity/partial-expansion/reuse case against new
  runtime derivation machinery. Such machinery does not exist in this Spike.
- Size/ABI checks cover the partial binding candidate. Declared comparison
  budgets, whole-stack bounds, target timing and connected validation remain
  separate requirements before selecting a full replacement.
- This prototype transforms existing writer source; it does not solve the
  topology updater's reliance on existing generated files as inputs.

## Disposition

Complete this bounded Spike with a **retain packed hierarchy** recommendation.
Directly adding the current portable modules to the Embedded closure is not a
viable replacement. Generated/checkable named role bindings are a credible
smaller maintenance candidate with measured +192 flash / zero RAM cost and
semantic parity. Feed this evidence to EXP-001 and iteration scope selection;
normal lifecycle gates precede any selected owner/public/profile change.

## References

- [EXP-001](../explorations/exp-001-nrf-hierarchy-derivation.md)
- [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md)
- [Draft ITERATION-002](../iterations/iteration-002-cleanup.md)
- [Disposable runner](../../experiments/spike-009-nrf-hierarchy-roles/run.py)
- [Disposable probe](../../experiments/spike-009-nrf-hierarchy-roles/Probe.swift)
