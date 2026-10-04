# Step 26 — Connected nRF phase, Clear/diagnostic and refusal experiments

[SPIKE-013](../../spikes/spike-013-connected-host-followup.md) copies the actual
production application. Eleven common-owner stage bodies are retained and
wrapped with CYCCNT samples. A real SPI-write wrapper counts calls, successful
payload bytes and cycles. Fixed 704-byte trace storage replaces no owner storage;
heap configuration remains zero. Original startup probes remain linked but are
not executed: the experiment enters production activation directly. Software
controls run at service boundaries; source delays and scheduling bodies remain
unchanged. These are instrumented copies, not final-artifact conformance passes.

## Observations

| Common-owner stage / cost | Normal frames | Maximum 96-byte diagnostic |
| --- | --- | --- |
| Complete pipeline, nominal 64MHz cycles | 20.65–21.22s | 22.11s |
| Layout | 3.59–3.71s | 4.93s |
| Offer/production, including SPI | 16.46–17.01s | 16.52s |
| Real pixel-write calls, within production | 1.108–1.113s | 1.159s |
| Canvas derivation | about 0.238s | about 0.238s |
| Render preflight | about 0.225s | about 0.255s |

Layout and offer/production account for roughly 97% of normal cycle time. SPI
writes are about 5% of total, so wire transfer alone does not explain the gap.
This identifies the phases to investigate; it does not isolate linear lookup
counts or select an index, raster change, buffering policy or hierarchy replacement.

The six-frame case presents initial idle, Start with four bootstrap records,
one scheduled update with five records, Stop with six records, programmatic
Clear with zero records and a 96-byte model diagnostic in failed state. Every
presentation returns1. Clear uses the existing repository/admission hook;
diagnostic injection sets a model fact and does not simulate repository failure.
Two scheduled deliveries are 20.959s apart in host uptime. The preserved source
loop establishes each next deadline from the latest sampled time, without
catching up all transitions due during the long synchronous frame. This case
supplies bounded loaded observations, not the required lossless 80-event/s/30s
corpus or exact pixels.

The separate refusal case returns `-EIO` after the first update's injected pixel
write refusal. Presentation outcomes are `[1,0,1]`: initial accepted, update
refused, then a fresh initial presentation accepted. The injection increments
only the display-SPI counter once. Both retirements report committed revision 0,
pending input 0, needs-presentation 0 and invalidated touch pipeline. The research
runner explicitly reconstructs terminal input storage before its second
production activation; production retirement already reconstructs the repository.
This is fresh activation after cleanup, not retrying a retired graph in place
or adding automatic production recovery. Both cases sample zero CFSR/HFSR.

## Resource and measurement limits

Normal/refusal copies use 277,208 / 277,016 flash bytes and 191,872 RAM bytes
versus production 275,600 / 191,104. Both are ARMv7E-M, VFP hard-float, zero heap,
without allocator entry points, and below the 196,608-byte application RAM limit.
Reset PC/SP and halted DHCSR are checked before/after sentinel painting. Observed
extents are 17,112 and 17,032 of 27,648 usable stack bytes. Startup probes are skipped,
so these extents cannot replace Step 22's 19,480-byte production startup observation
or justify a smaller stack reservation.

The 100ms clock calibration agrees within 0.7ms. Long-frame RTC and nominal CPU
cycle durations differ by up to 0.73%; a 1% agreement limit is explicit in the
decoder and both are retained. The initial 0.1s absolute long-frame comparison
was rejected, then replaced with this bounded relative tolerance. The discrepancy's
cause is unresolved; phase values use nominal 64MHz cycles, include interrupts
and instrumentation, and should not be interpreted as high-precision wall time.
The gap from 250ms remains decisive under either clock. Uncollected preparation
attempts (vector section-name/ELF extraction and register-format assertions) are
excluded; the ELF was relinked before accepted collection. No CPU fault occurred.

## Evidence and reproduction

- [Normal result](../../../experiments/spike-013-connected-host-followup/evidence/normal.json), [refusal result](../../../experiments/spike-013-connected-host-followup/evidence/refusal.json).
- [Preparation identities](../../../experiments/spike-013-connected-host-followup/evidence/preparation.json), paired [normal](../../../experiments/spike-013-connected-host-followup/evidence/normal-resource.json) / [refusal](../../../experiments/spike-013-connected-host-followup/evidence/refusal-resource.json) ABI/resource checks.
- [Normal raw archive](../../../experiments/spike-013-connected-host-followup/evidence/normal-logs.tar.gz), [refusal raw archive](../../../experiments/spike-013-connected-host-followup/evidence/refusal-logs.tar.gz) and [archive/HEX identities](../../../experiments/spike-013-connected-host-followup/evidence/nrf-archives.json).

Run `python3 experiments/spike-013-connected-host-followup/prepare.py`, then
`bash docs/iterations/iteration-002-review/build-research-firmware.sh spike-013-connected-host-normal`
(or `refusal`). Run paired `measure-research-elf.py` before explicit J-Link
flashing of that copy. `collect.py normal` / `refusal` verifies resources, paints
only a reset/halted stack, makes bounded nonhalting reads and saves exact-size
snapshots. `summarize.py` decodes collected data without touching the device.
Do not overwrite accepted archives with a later run. Firmware restoration uses
the original production application and repository J-Link runner.

## Disposition

Target the layout and production phases in future performance work. Preserve
[FW-032](../../future-work/fw-032-nrf-performance-improvement.md)'s lookup hypothesis
until isolated measurement. [FW-033](../../future-work/fw-033-connected-validation-follow-up.md)
now has this bounded Clear/diagnostic and refusal/fresh-activation supplement;
physical provenance, independent full pixels/traces and other fault modes remain.
Pi phase collection is the next step of the same Spike. No production optimization,
authoritative contract, lifecycle stage, criterion or approved exception changes.
