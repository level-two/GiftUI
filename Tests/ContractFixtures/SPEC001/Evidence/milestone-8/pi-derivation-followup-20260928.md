# Pi derivation follow-up — 2026-09-28

This continues the open SPEC-001 T8.1 cadence investigation on
`feature/pi-layout-lookup-performance`, starting from the verified
`feature/pi-frame-performance` baseline. The optional
`GIFTUI_PI_TRACE_DERIVE` timer was added in `46bca971` to separate the
derivation phases. The Raspberry Pi reported `armv6l`; the ARMv6 hard-float
build passed and a 30-second foreground trace completed normally. The
[raw baseline trace](pi-derivation-baseline-profile-20260928.log) contains
15 complete steady frames. The first 15 payload, region, and byte counts
match the previous verified workload.

| Derivation phase | Mean, 15 steady frames |
| --- | ---: |
| Semantic expansion and publication | **122.103 ms** |
| Layout validation, measurement, placement, publication | **91.709 ms** |
| Drawing plan | 2.189 ms |
| Render preflight | 36.001 ms |
| Interaction publication | 1.861 ms |
| Inclusive `pi-present-us derive` | **255.429 ms** |

The listed phase timers do not sum exactly to the inclusive timer because
they omit small entry/exit work and clock calls. Total frame service averaged
1,936.329 ms; offer and framebuffer sink still dominate total service. The
instrumented derivation is already slightly above the entire 250 ms period.
The timers locate the next work but should not be interpreted as
uninstrumented phase costs or physical panel completion.

## Reused semantic publication lookups

Commit `f006c760` builds the bounded occurrence-identity list once per
semantic publication, forms the published child/modifier lookup lists once,
and reuses those lists to construct the render view. It does not change the
published order, selected realization, or profile resource contract. Three
focused `DynamicSemanticHostStorage` tests and the exact Pi host-native
raster gate passed. A clean ARMv6 hard-float build passed with build ID
`70c432501910de5bb5528275c60a18bfe3a66fd1`; a 30-second connected run
completed normally.

The [candidate trace](pi-semantic-publish-candidate-profile-20260928.log)
has 16 complete steady frames. Its first 15 steady frames match the baseline
payload, region, and byte counts in order:

| Phase, matched first 15 | Baseline | Candidate | Difference |
| --- | ---: | ---: | ---: |
| Semantic expansion and publication | 122.103 ms | **74.437 ms** | −47.666 ms |
| Layout | 91.709 ms | 86.589 ms | −5.120 ms |
| Inclusive derivation | 255.429 ms | **202.056 ms** | −53.373 ms |
| Offer including sink | 1,677.705 ms | 1,622.544 ms | −55.161 ms |
| Total frame service | 1,936.329 ms | **1,827.683 ms** | −108.646 ms |

The semantic reduction is consistent with removal of repeated publication
work. The offer difference spans two separate Pi runs and is not assigned to
this derivation change. Even the improved frame service is over seven times
the required 250 ms period. Both runs include the same optional derivation
timers; these are instrumented measurements, not a timer-free release claim.

## Indexed published lookups and layout scopes

Commit `ab76402d` adds bounded identity indexes for the published semantic
layout records and the layout workspace scopes. The existing occurrence and
scope limits also bound these indexes. The 38 dynamic runtime tests and the
exact Pi host-native raster gate passed. A clean ARMv6 hard-float build passed
with build ID `4f91d154a1d728a0ec4c9095edaff3db63d44868`. Two connected
foreground runs completed normally: a [30-second trace](pi-indexed-layout-candidate-profile-20260928.log)
and a [60-second trace](pi-indexed-layout-candidate-60s-20260928.log).

The first 15 complete steady frames of both indexed runs match the semantic
candidate's payload, region, and byte counts in order. All runs used the same
optional derivation timers:

| Phase, matched first 15 | Semantic candidate | Indexed, 30 s | Indexed, 60 s |
| --- | ---: | ---: | ---: |
| Semantic expansion and publication | 74.437 ms | 75.967 ms | 77.650 ms |
| Layout | 86.589 ms | **65.833 ms** | **65.400 ms** |
| Inclusive derivation | 202.056 ms | **183.285 ms** | **185.050 ms** |
| Offer including sink | 1,622.544 ms | 1,672.853 ms | 1,651.950 ms |
| Total frame service | 1,827.683 ms | 1,859.003 ms | 1,840.180 ms |

The repeated layout reduction is about 21 ms (24%) on this matched workload.
Whole-frame service did not improve in these separate short runs because offer
time varied by more than the derivation gain. All 31 complete steady frames of
the longer indexed run averaged 1,867.990 ms total service, with 186.750 ms
derivation, 1,678.120 ms offer, and 841.890 ms sink. The indexing change is
retained for its repeatable phase reduction and exact-output checks; a total
service gain is not claimed. The remaining measured bottleneck is the offer,
especially its framebuffer sink, while the 250 ms cadence gate remains open.

## Current frame cadence

A separate [60-second frame trace](pi-layout-lookup-frame-trace-20260928.log)
used the indexed candidate with `GIFTUI_PI_TRACE=1` and without the optional
derivation subphase timers. It completed 32 steady frames. Mean application
frame service was **1,837.182 ms** (median 1,837.059 ms; observed range
1,748.891–1,935.221 ms), or **0.544 frames/s**. Mean derivation was
185.092 ms, and the inclusive offer was 1,649.300 ms, of which the
framebuffer sink was 829.641 ms. The mean workload was 339.438 payloads,
3,937.094 regions, and 220,653.188 bytes per frame. This remains about
7.35 times the 250 ms service target. The frame timer excludes physical
panel completion and touch response.
