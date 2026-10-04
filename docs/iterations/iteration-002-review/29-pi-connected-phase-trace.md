# Step 29 — Pi connected phase trace

The maintainer restored Pi connectivity and requested resumption. The prepared
ARMv6 research binary was deployed under the SSH user's experiment directory,
with local and remote SHA256 verified. The original production binary remains
`acf57db5625eb1d2802210aaa6e30128749277d81ad26a3f313b79f8448d8d7e`.
The collector ran the real Dynamic owner and scheduling loop for a bounded 45s,
with its normal automatic Start and no supplied physical contacts.

## Recorded outcomes

- 25 common-pipeline cycles, including 24 pixel-producing cycles and one
  non-rendering activation opportunity. Initial capture 0, final capture 30.
- 26 accepted scheduled source deliveries; median inter-delivery spacing 1.859s.
  These plus four bootstrap records match the final capture count. They do not
  prove the required lossless 80-event/s wall-time workload.
- Median pipeline 1.841s; median offer/production 1.665s, semantic expansion 74.8ms,
  layout 51.4ms and render preflight 25.6ms.
- Median accumulated mmap projection 802.0ms within offer/production. There are
  6,583 pixel payload callbacks; the verbose copy prints each one after timing it.
  This interval is CPU projection into the mapped framebuffer, not panel scanout.
- Sampled peak RSS 9,752KiB. Timeout wrapper returns124; the application reports
  `status=completed`, and the final process check finds no remaining application.

[Validated result](../../../experiments/spike-013-connected-host-followup/evidence/pi.json)
and [raw archive](../../../experiments/spike-013-connected-host-followup/evidence/pi-logs.tar.gz)
preserve every frame/stage/source sample and file hashes. The binary/build input
identities from Step 27 remain unchanged. Doctor, original/research hash checks
and the measurement decoder pass. No production source or service was changed.

## Interpretation and next bounded check

Offer/production dominates this instrumented run. Its per-payload output is an
intrusive measurement: median pipeline time exceeds the unchanged production
baseline's roughly1.37s, and print/collection work is included in surrounding
phase intervals. Do not attribute that entire difference to logging or treat
this copied result as final-artifact conformance.

Preserve this accepted trace and run one additional 45s copy with accumulated
framebuffer counters and one summary per cycle. Keep stage bodies, source loop,
compiler/profile and real projection unchanged. This tests the observer-cost
concern and supplies a quieter phase estimate without selecting an optimization.
SPIKE-013 remains active for that bounded comparison. The Pi connectivity blocker
is resolved; complete physical/pixel/fault/sustained-load coverage remains separate.
