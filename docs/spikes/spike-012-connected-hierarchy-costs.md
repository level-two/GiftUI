---
id: SPIKE-012
feature: signal-analyzer
title: Connected nRF Hierarchy Candidate Costs
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
  - SPIKE-009
  - SPIKE-010
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# SPIKE-012: Connected nRF Hierarchy Candidate Costs

## Target Questions

What are measured Cortex-M4 costs for current packed staging, SPIKE-009's
named-role candidate, and SPIKE-010's bounded actual-body counting prerequisite?
Does sentinel painting establish an observed main-stack extent for these bounded
workloads? Do the snapshot refusal/reuse probes execute successfully on target?

## Bounds / Stop Conditions

The maintainer authorized hardware measurements/experiments after hardware-free
closeout. Use identified J-Link 683833660, supported board/ABI and the paired
compiler. Keep copied applications under `.build/nrf52840/`. No maintained
production changes, architectural selection, performance optimization or physical
touch conformance. Stop on ABI/heap faults, unexpected returns, CPU faults,
invalid paint state or absent cycle-counter calibration. No candidate adoption
thresholds have been agreed; measurements cannot imply acceptance.

## Method

Each copied application retains the production source/link closure and adds the
same benchmark, caller-owned packed-region wrapper and pinned SPIKE-010 lowering.
Only the named-role image selects SPIKE-009's two writers and generated roles.
A volatile benchmark mode chooses packed or snapshot work and a volatile gate
holds before normal production startup. Thus benchmark firmware sizes include
instrumentation; prior SPIKE-009/010 comparisons establish uninstrumented deltas.

Five batches of 32 calls execute per normal/diagnostic case. Packed staging uses
running state, four captured transitions at 17.3s and the default two-second
window; diagnostics contain 96 newline bytes. Model/capture setup happens once
per packed batch and is included in timing. Snapshot counting constructs its
snapshot/workspace/sink on every call and uses its existing nine-byte diagnostic.
It counts 92 scopes but does not publish complete semantics, preserve stable
identity or attach observable state. Its timing is **not a replacement speedup**.

DWT CYCCNT measures elapsed CPU cycles including interrupts. A 100ms busy-wait
compares CYCCNT with Zephyr's 32,768Hz clock and records SystemCoreClock. Paint
only at a verified reset/halt, then run without debugger function calls and read
symbol-addressed results plus the sentinel stack. Calibration, ABI/zero heaps,
returns, refusal/reuse and CPU fault status are prerequisites for a valid sample.

## Reproduction

```sh
python3 experiments/spike-012-connected-hierarchy-costs/prepare.py
bash docs/iterations/iteration-002-review/build-research-firmware.sh spike-012-connected-packed
bash docs/iterations/iteration-002-review/build-research-firmware.sh spike-012-connected-roles
bash docs/iterations/iteration-002-review/build-research-firmware.sh spike-012-connected-snapshot
```

After verifying each generated ELF's ABI/heap/resource record, use an explicitly
authorized connected shell with the repository environment and J-Link runner:

```sh
source scripts/nrf52840/common.sh
giftui_nrf_export_environment
# Repeat for packed, roles, snapshot, with the matching collector argument.
"$GIFTUI_NRF_WEST" flash -d "$PWD/.build/nrf52840/spike-012-connected-packed/firmware" -r jlink --skip-rebuild --dev-id 683833660
python3 experiments/spike-012-connected-hierarchy-costs/collect.py packed
python3 experiments/spike-012-connected-hierarchy-costs/summarize.py
# Restore the verified production image after all collection.
scripts/nrf52840/flash.sh --application signal-analyzer-static --no-build
```

The collector derives result/stack addresses from the exact ELF. It resets and
halts, verifies DHCSR 0x00030003 before/after painting, observes completion without
halting, then captures exactly 124 result bytes and 27,648 stack bytes. Explicit
hexadecimal lengths avoid J-Link's decimal-looking hexadecimal command syntax.
The first extraction failed this byte-count assertion and was rerun; no failed
extraction enters the reported measurements.

## Results

| Workload | Normal median / call | Diagnostic median / call | Observed sentinel extent |
| --- | --- | --- | --- |
| Current packed stage | 55.612 ms | 55.732 ms | 3,992 bytes |
| Named-role packed stage | 54.265 ms | 54.431 ms | 3,984 bytes |
| Actual-body snapshot counting | 6.254 ms | 6.269 ms | 17,896 bytes |

Each case has five batches of 32 calls. All packed returns are 32 × 94 normal
text bytes or 32 × 190 diagnostic bytes. Both comparable images match these
returns. Previous SPIKE-009 native checks supply 42 complete semantic transcript
comparisons; this target campaign does not freshly compare complete staged bytes.
Snapshot returns are 32 × 92 counted scopes. Target depth/node refusal returns
are both zero, followed by a successful 92-scope fresh call.

All runs identify a 64 MHz CPU and 32,768 Hz Zephyr clock. Calibration measures
6,400,034–6,400,037 CYCCNT cycles for the 100 ms busy-wait; RTC measures
3,254–3,256 ticks. CFSR/HFSR are zero, ARMv7E-M/VFP ABI passes, configured heaps
are zero and checked allocator entries are absent.

Instrumented images use 311,612 / 311,944 / 311,736 flash bytes and
191,228 / 191,232 / 191,232 RAM bytes, respectively. They include the benchmark
and both mechanisms; compiler/link placement differs. Use earlier production
comparisons (+192 role flash, +34,184 additive snapshot flash, zero RAM in each)
for candidate size evidence, not these instrumented totals/differences.

The range is `z_main_stack + 64 ..< z_main_stack + 64 + 27,648`, consistent with
the pinned single-thread Zephyr switch's `K_THREAD_STACK_BUFFER + SIZEOF` formula.
This includes the application PSP range; reset MSP uses a different initial
pointer. No GDB function calls or live-stack painting occur in these runs.

[Combined result/provenance record](../../experiments/spike-012-connected-hierarchy-costs/evidence/summary.json),
[exact images and raw measurements](../../experiments/spike-012-connected-hierarchy-costs/evidence/connected-artifacts.tar.gz),
[prepared source identities](../../experiments/spike-012-connected-hierarchy-costs/evidence/preparation.json).
Per-mode JSON preserves all batches, calibration, addresses, returns and hashes.

## Limitations

A sentinel extent is an observed workload result, not an upper bound for all
control-flow paths. These workloads omit rendering, physical input and sustained
80-event/s acquisition. Packed and snapshot operations do different work; only
packed versus roles is a comparable candidate pair. No approved acceptance
budget or full candidate conformance follows from this Spike.

## Disposition

Complete this bounded candidate-cost investigation. The role variant is
2.34–2.42% faster for these specific staging fixtures, with an eight-byte smaller
observed sentinel extent. A single-board microbenchmark and no agreed adoption
budget do not select it for production. The roughly 55 ms staging measurement
does not isolate identity lookup cost or explain the roughly 21-second complete
publication cadence.

Snapshot counting's roughly 6.26 ms and 17,896-byte extent answer a prerequisite
cost question. They cannot establish a full replacement's parity, simultaneously
live storage or stack bound. Do not interpret the different-work timings as a
replacement speedup, add independent stack maxima, or shrink the production
reservation. Retain the packed-runtime recommendation and clean-generation
candidate; feed measured costs into EXP-001 as supplemental evidence.

## References

- [EXP-001](../explorations/exp-001-nrf-hierarchy-derivation.md)
- [SPIKE-009](spike-009-nrf-hierarchy-role-bindings.md)
- [SPIKE-010](spike-010-bounded-declaration-traversal.md)
- [Disposable preparation](../../experiments/spike-012-connected-hierarchy-costs/prepare.py)
- [Benchmark driver](../../experiments/spike-012-connected-hierarchy-costs/benchmark.c)
- [Packed wrapper](../../experiments/spike-012-connected-hierarchy-costs/Benchmark.swift)
