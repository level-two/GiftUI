# Pi current-artifact connected checks — 2026-10-05

[Deployment and target identity](../21-pi-deployment/result.md) verify ARMv6 Pi
192.168.55.44 against saved SSH host key, with artifact SHA-256
`90dec11ef8cfd39480b888eb0cdef90ac9695d454ef7f9bdd12466ab7c8fa211`. No production code changed after the 74-check gate.

## Acquisition, retention and controls on ARMv6

```sh
ssh -o BatchMode=yes -o ConnectTimeout=15 -o HostKeyAlias=giftui-pi.local -o StrictHostKeyChecking=yes giftui@192.168.55.44 'timeout --signal=INT --kill-after=10 300 ~/giftui/bin/SignalAnalyzerRaspberryPiARMv6 --rehearse-host'
```

[Rehearsal](armv6-rehearsal.log) exits 0/status=passed on the actual target CPU.
It uses real production acquisition/application/input/presentation owners with
software contacts, recording framebuffer and accelerated logical time. This
is not a wall-time or physical-input workload. [Current reference comparison](behavior-comparison.log)
passes all 120 workload frames, nine initial/action frames and 12 actions,
including Start/Stop and 1/2/5s choices, drag/miss behavior and teardown guards.
The unchanged source schedule delivers 2,400 transitions plus four initial
records, capture revision 2,404; its 201,770ms logical span retains 61 records
at the end under five seconds. Counts follow the schedule, separately from
the synchronized 30s/80-event-per-second fixture's 404 retained records.
Baseline/left-edge correctness is covered by current oracle/parity and the
independent full-history corpus; no raw on-device baseline dump is claimed.

## Physical endpoint startup and bounded process loop

The maintained collector `docs/iterations/iteration-002-review/collect-pi-connected.py`
is sent over the same strict SSH connection. It runs the current production
`--run-signal-analyzer` with actual framebuffer/touch endpoints and traces,
45-second SIGINT timeout and 10-second kill fallback. [Raw collection](physical-run.jsonl)
records 31 frame costs, 9808 KiB peak sampled RSS,
45.916s collection duration, and application
`status=completed`; wrapper 124 is the expected timeout result. No physical
contacts or source-delivery/input traces were observed in this idle loop.
Thus active acquisition/control proof above belongs to the recording rehearsal,
not this physical endpoint loop. No synthetic evdev input was injected.

Costs 1,322,263–1,509,253us (mean 1,393,700us) retain the
known four-fps timing failure. No new speed or lossless wall-time claim follows.
[Final state](final-state.log) verifies unchanged deployed hash and no remaining
analyzer process after teardown. The observed trace has no failure status;
the sampled recent kernel log has no application fault entry. This is bounded
observation, not absence of every possible fault.

[Summary](summary.json), [raw file identities](file-hashes.json). Together with
[nRF startup/control/capture/fault/restoration](../16-nrf-connected/result.md),
this completes the selected T12.4/T11.7 connected subset. Complete physical
interaction/independent pixels, sustained timing and whole-stack validation
retain their original exceptions/FW-027/031/032/033 boundaries. No existing
exception is enlarged. The Pi application is stopped; the deployed executable
is ready for ordinary use. No remote service was restarted.
