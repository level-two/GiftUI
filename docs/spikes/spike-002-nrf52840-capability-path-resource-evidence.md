---
id: SPIKE-002
feature: capability-system
title: nRF52840 Capability-Path Resource and Zero-Heap Evidence
status: completed
authors:
  - Yauheni Lychkouski
created: 2026-08-19
updated: 2026-08-20
source:
  - RFC-006
  - ADR-019
  - ADR-020
related_future_work:
  - FW-006
related_explorations: []
related_spikes:
  - SPIKE-001
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPIKE-002: nRF52840 Capability-Path Resource and Zero-Heap Evidence

> This Spike measures one representative bounded implementation of RFC-006's
> minimum capability family. It produces feasibility evidence only. Its code,
> types, field widths, diagnostics, and byte costs are not a production
> Specification or accepted resource budget.

## Parent Gate

RFC-006 cannot advance until a representative nRF52840 build or bounded
representation fixture reports the incremental capability-system RAM, resolver
stack, flash, and initialization work and proves zero heap allocation across
the complete capability path.

The Spike feeds those measurements and limitations to RFC-006. It does not
approve the allocator-independent architecture or authorize product code.

## Target Questions

1. What linked RAM and flash does the minimum `rasterPresentation` capability
   path add to an otherwise equivalent nRF52840 firmware image?
2. What is the worst-case resolver stack bound for all required success and
   validation-failure paths?
3. What bounded initialization work does one resolution perform, expressed as
   reproducible operation counts and, if available without connected hardware,
   cycles or elapsed time?
4. Can contribution construction, initialization-time resolution,
   validation-result construction, effective-result storage, and steady-state
   access all link and execute without a heap allocator?
5. Does the representative image remain inside RFC-006's established nRF52840
   limits, and are omitted implementation families absent from the image?

## Required Minimal Experiment Code

Place all disposable code and measurement orchestration under:

`experiments/spike-002-nrf52840-capability-path-resource-evidence/`

The experiment MUST contain two comparable firmware fixtures and one reporting
entry point.

### 1. Baseline firmware fixture

The baseline MUST:

- use `nrf52840dk/nrf52840` and the repository's supported Embedded
  Swift/Zephyr toolchain;
- use the same Swift entry path, Zephyr configuration, compiler flags,
  optimization, runtime support, and observable output mechanism as the
  candidate;
- contain a fixed no-op initialization and steady-state read-shaped control so
  those call sites are not unique to the candidate; and
- keep the Zephyr heap and C allocation arena disabled.

It MUST NOT link the experiment capability vocabulary or resolver.

### 2. Candidate firmware fixture

The candidate MUST differ from the baseline only by the minimum capability
representation and observable execution of the complete capability path.

It MUST include:

- one fixed `rasterPresentation` requirement;
- fixed, bounded contributions representing the render producer,
  RGB565 raster/backend, synchronous borrowed TFT submission, and target host
  resource policy;
- one pure bounded resolver;
- one available effective result;
- stable bounded validation results for success, malformed input, duplicate
  single-owner contribution, incompatible pixel encoding, incompatible
  submission lifetime, and unsatisfied resource bounds;
- caller-owned or static storage for every input, workspace, validation result,
  and effective result; and
- one steady-state accessor that reads the immutable effective result without
  rerunning resolution.

No value may use reflection, string lookup, exceptions, unrestricted
existentials, dynamic discovery, unbounded collection storage, or a heap-backed
diagnostic/provenance representation.

The experiment MUST make the computed result and path execution observable to
the linker, for example through a fixed digest, volatile sink, exported symbol,
or serializable integer status. Merely linking dead, uncalled resolver code is
not evidence.

### 3. Complete-path driver

One candidate entry point MUST execute, in order:

1. contribution construction;
2. successful initialization-time resolution;
3. successful validation-result construction;
4. immutable effective-result storage;
5. steady-state result access without re-resolution; and
6. each required negative validation path.

The path driver MUST expose counters or another fixed-size trace proving that
every phase was reached. The trace is measurement instrumentation, not a
candidate production diagnostic format.

### 4. Measurement/reporting entry point

Provide one repository-root command, preferably:

```text
experiments/spike-002-nrf52840-capability-path-resource-evidence/run.sh
```

It MUST build pristine baseline and candidate images, collect their ELF/map
reports, validate configuration and allocator constraints, and emit one stable
summary table. Generated firmware and deployable artifacts MUST remain under
`.build/nrf52840/`; other temporary results may remain under the experiment
directory or `/tmp`.

## Required Build Equivalence

The evidence report MUST show that baseline and candidate use identical:

- source revision;
- compiler and SDK versions;
- board target and CPU/ABI flags;
- debug/release and optimization flags;
- Zephyr configuration except for a documented measurement-only difference;
- Swift runtime and C library linkage; and
- linker garbage-collection and section settings.

If stack instrumentation changes linked RAM or flash, produce separate
resource-measurement and stack-measurement variants. Do not subtract unlike
images without clearly identifying the difference.

## Required Measurements

### Incremental linked RAM

For both baseline and candidate, report at least:

- total linked RAM from ELF load segments;
- `.data`, `.bss`, and any no-init/static capability storage when separately
  available;
- candidate capability input, resolver workspace, validation-result, and
  effective-snapshot symbols or map contributions; and
- `candidate - baseline` linked-RAM delta.

The resolver stack MUST be reported separately and MUST NOT be silently folded
into the linked-RAM delta.

### Incremental flash

For both images, report total linked flash and relevant text/rodata sections,
then report `candidate - baseline`. Preserve the linker map or symbol-size
breakdown needed to explain the delta.

### Worst-case resolver stack

Exercise or conservatively analyze every success and required negative path.
Use one reproducible method:

- a dedicated fixed-size stack filled with a known pattern and inspected for a
  high-water mark;
- compiler-produced stack-usage data plus a complete resolver call-graph sum;
  or
- conservative disassembly/call-graph analysis when the preceding methods are
  unavailable.

The report MUST state the method, include instrumentation overhead where
applicable, list any unanalyzed indirect call, and give one worst-case byte
bound. An estimate without reproduction details is insufficient.

Connected-board measurement is not required by this Spike. If the chosen
method would require flashing, stop and request separate authorization rather
than treating a build as hardware execution.

### Initialization work

Instrument the resolver with fixed-width counters compiled only for the
measurement variant. Report, for each required path:

- contributions visited;
- compatibility intersections or comparisons;
- checked bound/arithmetic operations;
- validation records constructed; and
- total resolver invocations.

Also report cycles or elapsed time only if they can be obtained reproducibly
without claiming connected-hardware evidence. Operation counts are the primary
portable bound. The counters MUST demonstrate that steady-state access does
not invoke the resolver.

### Zero heap allocation

The candidate MUST satisfy all of the following:

- Zephyr configuration contains `CONFIG_HEAP_MEM_POOL_SIZE=0`;
- C library configuration contains `CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0`;
- the ELF has no linked global entry point for `malloc`, `calloc`, `realloc`,
  `aligned_alloc`, `k_malloc`, `k_calloc`, or `k_realloc`;
- the complete-path driver makes every required phase observable and not
  removable as dead code; and
- symbol/map inspection identifies all retained capability storage as fixed,
  caller-owned, stack, or static storage.

If another Swift or Zephyr allocation entry point is discovered during the
Spike, add it to the inspection and record it. Do not claim zero allocation
merely because no allocation was observed in a host test.

### Linked-family exclusion

The candidate symbol and map reports MUST show that dynamic registry,
desktop/full-framebuffer, unrelated backend, and omitted capability-family
implementations are not linked into the image. Record the exact symbol or
section patterns checked.

## Required Limits

The result table MUST compare the candidate image and incremental values with:

- at most 192 KiB total linked RAM;
- at most 16 KiB default display staging;
- at most 1 MiB device flash;
- a warning when firmware exceeds 896 KiB flash;
- a finite, reported worst-case resolver stack bound;
- finite initialization operation counts; and
- zero capability-path heap allocation.

RFC-006 does not yet assign an independent byte ceiling to the resolver or
snapshot. Therefore, this Spike MUST report their deltas but MUST NOT invent a
pass/fail budget for those deltas. Reviewers decide whether the measured cost
supports the RFC direction.

## Required Result Table

The completed Spike MUST report at least:

| Metric | Baseline | Candidate | Increment | Limit / interpretation |
| --- | ---: | ---: | ---: | --- |
| Linked RAM bytes | | | | 192 KiB total |
| Linked flash bytes | | | | 1 MiB total; 896 KiB warning |
| Capability fixed storage bytes | 0 | | | Report, do not invent budget |
| Worst-case resolver stack bytes | 0 | | | Finite and reproducible |
| Success-path initialization operations | 0 | | | Finite |
| Worst negative-path initialization operations | 0 | | | Finite |
| Steady-state resolver invocations | 0 | | | Must remain 0 |
| Heap allocator entry points | 0 | 0 | 0 | Must remain 0 |
| Display staging bytes | | | | At most 16 KiB |

The report MUST also contain a path-coverage table showing that contribution
construction, resolution, validation construction, snapshot storage, and
steady-state access were each exercised.

## Bounds / Stop Conditions

- Do not implement a production `GiftUICapabilities` target or public API.
- Do not add more than the single `rasterPresentation` family.
- Do not add generalized Traits, dynamic discovery, string diagnostics, or a
  registry.
- Do not optimize unrelated GiftUI or firmware code to improve the reported
  delta.
- Do not flash or operate connected nRF52840 hardware as part of this Spike.
- Stop after baseline/candidate comparison, complete-path zero-heap proof,
  stack bound, initialization-work report, and omitted-family check are
  reproducible.
- Stop with a negative result if the candidate cannot link without a heap,
  exceeds an established total target limit, has unbounded/unanalyzable stack
  or initialization work, or cannot keep every complete-path phase observable.

## Method

1. Freeze the baseline and candidate build inputs.
2. Build both pristine images with the repository's nRF52840 toolchain.
3. Verify ARMv7E-M and hard-float ELF attributes.
4. Produce ELF header, section, symbol, program-header, size, and map reports.
5. Verify disabled heaps and absence of allocation entry points.
6. Calculate total and incremental linked RAM and flash.
7. Produce and verify the stack bound using the documented method.
8. Record initialization counters and complete-path coverage.
9. Check omitted implementation-family symbols.
10. Re-run from a pristine build and require identical normalized results.

## Reproduction

Use the repository's supported nRF52840 setup and diagnostic workflow. The
completed report MUST record:

- repository revision and dirty-worktree state;
- macOS host version and architecture;
- Swift, Zephyr SDK, west, CMake, and Ninja versions;
- exact board, compiler, ABI, and optimization settings;
- exact repository-root commands;
- hashes of baseline and candidate ELF files; and
- paths to all size, map, stack, symbol, configuration, and summary reports.

The existing `scripts/nrf52840/build.sh` report format SHOULD be reused or
extended within the experiment rather than replaced. Toolchain installation
or repair follows `skills/giftui-nrf-toolchain/SKILL.md`; firmware building
follows `skills/giftui-nrf-build-flash/SKILL.md`, excluding its connected-board
flashing steps.

## Success Criteria

This Spike answers RFC-006's embedded feasibility gate positively only if:

- baseline and candidate are demonstrably comparable;
- the candidate executes or makes observable the complete capability path;
- total RAM, display staging, and flash remain within established limits;
- incremental RAM and flash are reported and attributable;
- worst-case resolver stack is finite, reproducible, and reported;
- initialization work is finite and reported for success and negative paths;
- steady-state access performs zero resolver invocations;
- no prohibited allocator entry point is linked and both heaps are disabled;
  and
- omitted implementation families are absent from the linked image.

Passing establishes only that one bounded representation is feasible. It does
not select final field widths, provenance, diagnostics, storage layout, API, or
resource budgets.

## Failure Routing

- If established total device limits are exceeded, first record which record,
  provenance, diagnostic, adapter, or workspace representation dominates the
  cost. Return the evidence to RFC-006 review; do not silently replace bounded
  initialization resolution with target-local checks.
- If any complete-path phase requires heap allocation, return RFC-006's static
  representation choice to review.
- If stack or initialization work cannot be bounded, report the specific
  indirect call, recursion, dynamic behavior, or missing tool evidence.
- If only a measurement tool is inadequate, record an inconclusive result and
  propose a narrower follow-up Spike rather than claiming conformance.

## Results

Completed on 2026-08-19. The two pristine builds were byte-for-byte
reproducible and the candidate passed every established target limit and
zero-heap check.

| Metric | Baseline | Candidate | Increment | Limit / interpretation |
| --- | ---: | ---: | ---: | --- |
| Linked RAM bytes | 8,060 | 8,188 | 128 | 192 KiB total |
| Linked flash bytes | 25,816 | 26,920 | 1,104 | 1 MiB total; 896 KiB warning |
| Capability fixed storage bytes | 0 | 80 | 80 | Reported, no invented budget |
| Worst-case resolver stack bytes | 0 | 72 | 72 | Finite disassembly bound |
| Success initialization operations | 0 | 14 | 14 | Finite |
| Worst negative initialization operations | 0 | 14 | 14 | Finite |
| Steady-state resolver invocations | 0 | 0 | 0 | Pass |
| Heap allocator entry points | 0 | 0 | 0 | Pass |
| Display staging bytes | 0 | 3,840 | 3,840 | At most 16 KiB |

The available path and all five required negative paths were retained in the
target ELF and executed by the exact-source host harness. Construction,
resolution, validation construction, snapshot storage, and steady-state
access set the complete `0x1f` path trace. Stable reasons 1 through 5 identify
malformed input, duplicate owner, incompatible encoding, incompatible
submission lifetime, and unsatisfied resource bounds respectively.

Both final images use ARMv7E-M with the VFP-register hard-float convention,
contain both required zero-heap configuration values, and retain none of the
prohibited allocator entry points. Symbol inspection found no dynamic
registry, desktop/full-framebuffer backend, unrelated backend, or omitted
capability-family implementation.

Full reproduction identity, counter categories, stack derivation, hashes,
path coverage, checks, and interpretation are preserved in the
[versioned evidence summary](../../experiments/spike-002-nrf52840-capability-path-resource-evidence/evidence/summary.md).
The one-command runner also retains ELF, map, disassembly, configuration, and
symbol reports under `.build/nrf52840/`.

## Limitations

- A linked image and bounded-representation fixture are not connected-hardware
  validation and must not be described as such.
- Operation counts bound resolver work but do not predict exact on-device
  latency without a separately authorized hardware measurement.
- Baseline subtraction is sensitive to compiler and linker threshold effects;
  preserve maps and explain non-local size changes.
- The Spike does not prove the tiled one-shot rendering contract; SPIKE-001
  owns that evidence.
- The candidate image was cross-built and inspected but not executed on target
  hardware. The exact pure Swift source was executed on the host; on-target
  observability was proved through retained entry, trace, counter, result, and
  storage symbols.
- The 72-byte resolver stack figure is a conservative disassembly call-chain
  bound, not an on-device high-water measurement.

## Disposition

Completed with positive feasibility evidence for RFC-006's nRF52840 resource
and allocator-independence gate. Feed the measurements and limitations into
RFC-006 review. This status does not approve RFC-006 or authorize copying the
experiment code into a production target.

## References

- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [FW-006: Generated Target Configuration](../future-work/fw-006-generated-target-configuration.md)
- [SPIKE-001: Tiled One-Shot Stream and Capability Compatibility Fixtures](spike-001-tiled-one-shot-capability-fixtures.md)
- [GiftUI nRF52840-DK Platform Specification](../GiftUI_nRF52840_DK_Platform_Spec.md) — legacy feasibility context only
