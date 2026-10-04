# Step 30 — Pi accumulated-counter comparison and Spike closeout

The second authorized 45s copy retains the actual Dynamic stage bodies, production
source loop and framebuffer projection. It replaces per-payload printing with
caller-installed research callbacks that reset/read three accumulated framebuffer
counters. The executable supplies those callbacks without introducing another
module dependency. The original verbose package, artifact and accepted archive
remain intact. An atomic compressed SSH deployment stages a separately named
research binary; both ARMv6 and its complete remote SHA256 are verified before use.

## Results

| Observation | Verbose copy, Step 29 | Accumulated counters |
| --- | --- | --- |
| Common-pipeline cycles / pixel-producing cycles | 25 / 24 | 33 / 32 |
| Median complete pipeline | 1.841s | 1.381s |
| Median offer/production | 1.665s | 1.219s |
| Median accumulated mmap projection | 0.802s | 0.699s |
| Median semantic expansion | 74.8ms | 74.3ms |
| Median layout | 51.4ms | 53.3ms |
| Median render preflight | 25.6ms | 25.9ms |
| Scheduled source deliveries / final capture | 26 / 30 | 34 / 38 |
| Median source-delivery spacing | 1.859s | 1.400s |
| Sampled peak RSS | 9,752KiB | 9,820KiB |

The one non-rendering activation opportunity is retained in each result; medians
restricted to pixel-producing cycles are 1.846s and 1.383s. The quieter copy's
pixel-producing range is 1.267–1.817s. Its 33 cycles include an initial presentation,
automatic Start opportunity and subsequent loaded opportunities. Source deliveries
plus the four bootstrap records match final capture 38. No physical input lines
were recorded. SIGINT timeout wrapper 124 accompanies application
`status=completed`; a final process check finds no remaining analyzer process.

The quieter median is close to Step 22's unchanged production baseline median
1.369s. Removing per-payload output reduces observed median by 0.460s in this
comparison. Runs are sequential, not paired identical workloads or a controlled
estimate of every timer/logging cost. Both instrumented copies retain interrupts,
scheduling and observer overhead; neither is a final-artifact conformance pass.

Offer/production accounts for about 88% of median cycle time. The 0.699s projection
sum is nested inside it, about 51% of the whole cycle. These intervals include
preemption and mapped framebuffer behavior. They do not time panel scanout or
isolate the remaining raster/endpoint cost by subtraction of per-run medians.
This identifies projection and the rest of production as the next performance
boundaries to profile. No new buffer, partial frame, endpoint bypass, cache or
production optimization is selected. The 250ms/four-fps requirement remains unmet.

The preserved scheduling loop establishes each next source deadline from its
latest sampled wall time and spends more than a second inside synchronous frame
service. The 1.400s median delivered spacing is not the required lossless 80-event/s
workload. The capture counts are bounded evidence, not a 30s sustained
wall-time admission or complete independent semantic/action/pixel comparison.

## Identity, reproduction and evidence

Aggregate binary SHA256:
`0b6513d22202397927ae72946904af8ac4c4524a4add0b4bc504d029e64ef30f`.
Pi reports `armv6l`; original production SHA256 remains
`acf57db5625eb1d2802210aaa6e30128749277d81ad26a3f313b79f8448d8d7e`.
No production executable or service configuration was replaced. Final checks
confirm both research hashes and no remaining analyzer process. Research binaries
remain in the user's experiment directory for reproduction.

- [Aggregate result](../../../experiments/spike-013-connected-host-followup/evidence/pi-aggregate.json) and [raw archive](../../../experiments/spike-013-connected-host-followup/evidence/pi-aggregate-logs.tar.gz).
- [Preparation inputs](../../../experiments/spike-013-connected-host-followup/evidence/pi-aggregate-preparation.json) and [binary identities](../../../experiments/spike-013-connected-host-followup/evidence/pi-aggregate-identities.json).
- [Comparison, integrity and final-state record](evidence/30-pi-measurement-validation.json), [verification logs](evidence/30-pi-verification-logs.tar.gz).

Reproduce only in a fresh evidence directory after preserving accepted records:

```sh
python3 experiments/spike-013-connected-host-followup/prepare-pi-aggregate.py
bash experiments/spike-013-connected-host-followup/build-pi-aggregate.sh
python3 experiments/spike-013-connected-host-followup/run-pi-aggregate.py
```

The build uses the supported repository build/ABI verifier, temporarily produces
the existing research product, saves the aggregate under a new artifact filename,
and restores the original verbose artifact through an exit trap. The remote
collector uses the same application command/timeout. The decoder verifies complete
cycles, stage totals, nested projection time, successful source calls and teardown;
it refuses to overwrite an accepted archive.

Validation checks current copied-input identities, both immutable archives, local
and remote binary identities, final remote process absence, Python/shell syntax,
local links, formatting and governance. Maintained production inputs and the
original 72-check gate archive remain unchanged; that gate is not rerun or relabelled
as proof of this connected workload.

## Disposition

SPIKE-013 is completed: its nRF phase/source/refusal/fresh-activation and Pi
phase/source questions have bounded results and explicit limits. Pi connectivity
no longer blocks the investigation. [FW-027](../../future-work/fw-027-pi-performance-investigation-resumption.md)
and [FW-032](../../future-work/fw-032-nrf-performance-improvement.md) retain the
unmet performance requirements; [FW-033](../../future-work/fw-033-connected-validation-follow-up.md)
retains physical provenance, independent full pixels/traces, overlap/exact-once
and broader fault/resource coverage. Existing approved exceptions are unchanged.
No generic codebase-review pass remains in this research queue. Cleanup scope
selection/approval and any required contract amendments precede remediation.
