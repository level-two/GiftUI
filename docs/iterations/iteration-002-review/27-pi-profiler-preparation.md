# Step 27 — Pi phase profiler prepared; connected measurement blocked

The separate `SignalAnalyzerPiResearch` product builds with the paired 6.3.2
compiler/ARMv6 SDK and passes the repository's 32-bit ARMv6 hard-float inspection.
It copies maintained sources and preserves Dynamic behavior, production automatic
Start and the real source loop. Eleven common stages get CLOCK_MONOTONIC timers;
the existing mmap projection gets separate timing. Source delivery timestamps
and capture counts make the bounded loaded observation inspectable. Timing
includes instrumentation; mmap completion does not prove panel scanout.

Production binary SHA256 remains
`acf57db5625eb1d2802210aaa6e30128749277d81ad26a3f313b79f8448d8d7e`.
Research binary SHA256 is
`cbd434f051724ccdb09fed44998ffd4124b997e385b96734d8226911ace5afa0`.
The research target uses its own scratch directory and artifact filename.
No production executable or service was replaced/restarted.

Pi initially answered `armv6l` and the matching production hash. The isolated
upload then stalled; IPv6 SSH banner exchange and repeated IPv4 connections
timed out. Its owned SCP/SSH processes were terminated. No profiler execution
or phase result is claimed. The remote research file may be incomplete; the
resumption command verifies architecture, repeats isolated deployment and
verifies the full remote binary hash before executing anything. A maintainer
question requests restored connectivity or a reachable SSH address.

## Reproduction and evidence

[Preparation identities](../../../experiments/spike-013-connected-host-followup/evidence/pi-preparation.json),
[binary identities](../../../experiments/spike-013-connected-host-followup/evidence/pi-identities.json),
[prepared/blocked record](../../../experiments/spike-013-connected-host-followup/evidence/pi-prepared.json)
and [raw preparation logs](../../../experiments/spike-013-connected-host-followup/evidence/pi-preparation-logs.tar.gz)
preserve the build and failed connection evidence. Python syntax passes; no
actual Pi run or measurement-decoder outcome is reported as a pass.

Run `python3 experiments/spike-013-connected-host-followup/prepare-pi.py`, then:

```sh
scripts/raspberry-pi/build.sh --package-path .build/raspberry-pi/spike-013/package --product SignalAnalyzerPiResearch
python3 experiments/spike-013-connected-host-followup/run-pi.py
```

The runner optionally accepts an explicitly supplied SSH peer. It requires
`armv6l` before deploying under `~/giftui/experiments/iteration-002-spike-013/`.
The remote collector verifies the research hash, uses the production application
command with a 45s SIGINT timeout and bounded kill fallback, records stdout/RSS,
and leaves service configuration alone. The local decoder requires completed
teardown, complete stage records and actual source deliveries before producing
results. Do not overwrite completed archives when resuming a later campaign.

## Disposition

The hardware-free preparation is complete; this specific connected measurement
remains blocked on Pi connectivity. [SPIKE-013](../../spikes/spike-013-connected-host-followup.md)
remains active; [FW-027](../../future-work/fw-027-pi-performance-investigation-resumption.md)
retains the prior final-artifact timing gap. No numerical result, conformance
pass, optimization, contract change or iteration approval is inferred.
