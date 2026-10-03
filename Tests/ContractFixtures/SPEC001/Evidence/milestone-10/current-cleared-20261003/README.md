# Current cleared-state capture — 2026-10-03

The maintainer requested current cleared-screen capture autonomously. Both host-native production recorders now execute the existing Clear operation after the unchanged workload and stop/restart/window-control sequence. SPEC-001's Acquisition actions contract requires restart to preserve capture history: Start is not Clear. No application behavior or visible control was changed.

Clear is admitted through the Pi repository action producer and the nRF repository compact-fact path. The production hosts schedule, apply and present the resulting reset. The fixture asserts zero retained transitions and running acquisition. Capture revision advances from 2404 to 2405; the nRF presentation advances from 818 to 819. The images show flat HIGH/LOW/LOW/HIGH baselines with the current header and controls, preserving the last channel levels. These are fresh recordings, replacing the missing current-source evidence; HistoricalCleared remains untouched.

## Validation

- Candidate-only raster drivers pass for raspberry-pi-armv6 and nrf52840-embedded, including header invariants, normal/diagnostic rasters and production-loop fault checks.
- Independent behavior comparisons remain exact: Pi 120 workload frames, nine initial/action frames, 12 actions; nRF 818 ordered frames and 12 actions. Clear is a separate fixture invocation, not an alteration of these reference corpora.
- All 21 previously approved logical/physical pixel references still match byte-for-byte. The three newly captured cleared images are candidates awaiting visual review; they are not installed as reviewed references.
- Focused repository/capture tests pass: 17 tests in three suites, including Clear in all four acquisition states, retained levels, rebased timestamps and restart behavior. Swift formatting, diff checks and governance validation pass.
- During fixture development, the first Pi attempt lacked an action admission scope and the first nRF attempt lacked pending-fact wake notification. Both failed before producing accepted cleared evidence; the corrected runs above pass. No failed run is claimed as passing.

## Reproduction and applicability

Run `scripts/contracts/check-spec-001-host-native-rasters.sh --profile raspberry-pi-armv6 --candidate-only` and the same command with `nrf52840-embedded`. The script records an additional `GIFTUI_REHEARSAL_CLEARED=1` lifetime and renders Clear with `--include-cleared`. Normal reviewed-reference mode continues to compare the existing seven states until the new cleared candidates are reviewed. `recording-evidence.tar.gz` preserves raw RGB565, traces, original binary/substitution identities, source snapshots and validation logs. Original run identities describe the dirty working-tree capture before this implementation commit; the source snapshots bind the actual changes, including the equivalent renderer-loop formatting cleanup after capture.

Evidence uses host-native recording adapters, not connected display/input or measured target cadence. T7.7's current capture work is now done; its fresh cleared-reference review and T7.9's full eight-state gate remain open. T8.1/T8.2/T8.3 remain unchanged. SPEC-001 remains implementing.

## Artifact identities

```text
Implementation commit: 83d436d70c7f577f19b9695c13198f3407879272
a95d2b0c1c1e1abf09de7d69bb198e136861c2e61cfc5ad609ae6be77804ed6d  nrf-cleared.png
2ae683b352402b7859461e840101114e4dcf51f68c957f9bbb03e23ec0992d06  pi-cleared-physical.png
46d0ee16780d9480022734702f3a5e28351d5025a4ba8a4b91836d9438783295  pi-cleared.png
```
