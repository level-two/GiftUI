# Step 14 — Five-second retention impact and bounded candidate

Research after Step 13, production sources/contracts unchanged. This is a
candidate contract change, not a correction authorized by the current Spec.

## Capacity and measured resources

Four channels at 10 Hz square-wave input permit 80 edges per second. With
inclusive cutoff timestamps and four simultaneous channel events, reserve
`80 × 5 + 4 = 404` records. Keep four scalar channel baselines separately.
The +4 covers the inclusive boundary; it is not an extra set of baseline
records to retain forever. Bursts beyond the supported density retain the
existing capacity-eviction policy and may advance the lower bound.

The nRF live, observable-model and admission slots are each physically present.
Each exact packed transition is 16 bytes. Three slots change from
`3 × 2,404 × 16 = 115,392` to `3 × 404 × 16 = 19,392` bytes, saving 96,000.
[Inventory and source hashes](evidence/14-retention-impact-paths.json).

| Paired nRF linked metric | Original | Isolated five-second candidate |
| --- | ---: | ---: |
| Flash bytes | 275,600 | 275,472 |
| RAM bytes | 191,104 | 95,104 |
| Capture symbol bytes | 115,392 | 19,392 |

The candidate changes both Swift capture capacity/time trimming and the C
storage constant plus exact ABI-size checks in the copied composition root.
All other production selections, board/compiler/configuration pins remain
identical. ARMv7E-M/VFP and disabled heaps pass; allocation refusal stub remains.
Configured stack reservations are unchanged. This is linked storage evidence,
not physical stack/timing evidence or production conformance.
[Paired ELF evidence](evidence/14-retention-elf.json).

## Behavior experiment

[Runner](check-retention-candidate.py) compiles isolated copies of the actual
Domain, Data and TargetHost owning modules, replacing only 2,404→404 and
30-second→5-second capture-policy constants. [Probe](retention-candidate.swift)
executes 2,410 paired history/publication-replay comparisons and 7,200
independent visible-left-edge level comparisons. It feeds four initial low
facts plus 2,400 transitions over the original **30-second workload**.
At the end: revision 2,404, retained lower bound 25s, 404 records including the
four events exactly at 25s. Independent full-history baselines agree for every
channel in every 1/2/5-second window at every synchronized sample tick.

It also exercises retained out-of-order insertion at capacity, equal-time
arrival ordering, older-than-cutoff/negative/nonstandard-channel rejection,
snapshot stability during mutation/clear, epoch rebasing, and exhausted
revision rejection. This preserves mutation replay and compares all initialized
nRF live records with portable capture records at every step.
[Commands, transformations, hashes and result](evidence/14-retention-candidate.json).
It does not run presentation raster parity or physical sustained acquisition.

## Complete owner impact for implementation selection

| Area | Required change / preserved constraint |
| --- | --- |
| ADR-003 and SPEC-001 capture rules | Approve 5s horizon and 404 minimum; update newest-history/overflow wording and cutoff/capacity criteria |
| SPEC-001 workload criteria / workload-oracle fixture | Keep 30s duration, 80 events/s, 2,404 accepted facts, monotonic delivery and 120 paced frames; change zero-retention-eviction/final-2,404-record expectations to trimmed history and exact replay/baselines |
| Domain SignalValues / publication | Change maximumTransitionCount; required StaticStorage capacity follows that constant; validate insertion/eviction replay indices at the smaller exact bound |
| Data SignalCaptureStore | Change cutoff and default/minimum capacity together; preserve ordering, baselines, lower-bound rejection and Clear epoch |
| nRF CaptureStorage / CaptureHistory | Resize all three slots and cutoff together; maintain alignment, record schema and pointer lifetime |
| SnapshotView / ModelCaptureState / admission / sealed application | Capacities derive from CaptureRegions; verify snapshot borrows and copied stores at 404/405, cleanup and reuse; update comments documenting exact bytes |
| C static_host_storage.h, Swift StaticPreset and build-checks.conf | Change physical byte count and all exact ABI guards/symbol-size expectations; root-source profile bytes, raster staging and coverage remain unrelated |
| Host contracts / connected design | Review SPEC-015's workload relations against amended SPEC-001; revise connected-target design's 3-slot accounting and affected plan/conformance evidence rather than changing unrelated host limits |
| Test and native harness literal sizes | Update CaptureRecord/History/Snapshot/Model/Admission/Composition/Producer suites and native full-layout/rehearsal allocation sizes atomically; retain old reports as historical evidence |
| Contract fixtures and oracles | retention-cases.tsv, capture-value-cases.tsv and workload-oracle-cases.tsv need revised expectations; 30-second event-generation and total-delivery oracles stay |
| Portable presentation / Canvas | Existing 1/2/5s ranges remain; compare baseline and approved pixels at cutoff, partial capture, stop/clear and diagnostics; Canvas capture-byte maximum (32) refers to callable captures and must not be resized as signal history |
| Pi and desktop | Array-backed captures can retain existing semantics with the new cap; verify publication consumers, snapshots and sustained-load criteria on Dynamic and desktop Static profiles |

The bounded lexical inventory lists 32 affected/reference paths; this table
identifies additional consumers whose limits derive from shared constants.
Do not indiscriminately replace every `30` or `2404`: test duration, delivered
transition counts and historical reports are distinct from retained capacity.

## Disposition and reproduction

The candidate supports selecting a 5s/404-record contract amendment with
measurable nRF RAM benefit. Amend ADR-003 and affected Specifications before
production implementation; this research does not perform those amendments.

Run `python3 docs/iterations/iteration-002-review/check-retention-candidate.py`.
Build its copied application under `.build/nrf52840/iteration-002-retention/`
using the same paired `west build` options as Step 13, then run
`measure-research-elf.py` against production and candidate build directories.
All generated artifacts stay under `.build/`; no connected changes occur.
