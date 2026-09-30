# Pi semantic publication sort-once optimization — 2026-09-28

This measured and optimized the complete-frame semantic publication path on
`feature/pi-cold-semantic-profile`, based on the verified
`feature/pi-cold-frame-path` branch. No Specification or selected realization
changed. The Raspberry Pi 1 reported `armv6l`; connected runs used a
foreground executable and did not restart a service.

Commit `85b57703` added an optional timer within semantic publication. The
[baseline trace](pi-cold-semantic-publish-profile-20260928.log) used build ID
`ed325dd9c24de402c81574f856001955ef8bad49` and recorded 12 complete
steady frames. The first publication had 124 structural identities. Of the
146.818 ms initial semantic expansion phase, 63.224 ms was spent constructing
published child and modifier lookups, 5.986 ms forming the render view, and
0.120 ms forming the occurrence list. The remaining semantic work, including
tree expansion, was not subdivided.

Commit `8d988bdd` orders the occurrence indices once per publication and
reuses that order for each structural identity's child selection. The child
lists retain their original occurrence order, and the selection still uses
the same prefix and nearest-child rules. Commit `c9e53210` removed the
temporary publication timers after measurement; they are absent from the
retained implementation.

The [candidate trace](pi-cold-semantic-sort-once-profile-20260928.log) and
[repeat](pi-cold-semantic-sort-once-repeat-20260928.log) used build ID
`e0cddae8b39ed84d07511d22c750adc4c74f292c` with the same optional
timers. Each completed 13 steady frames. The first ten steady-frame payload,
region, and byte counts match the baseline in order; the initial workload is
311 payloads, 3,577 regions, and 218,874 bytes in all three runs.

| Timed phase | Baseline | Candidate | Repeat |
| --- | ---: | ---: | ---: |
| **Initial semantic expansion** | **146.818 ms** | **134.790 ms** | **134.788 ms** |
| Initial lookup construction | 63.224 ms | 54.949 ms | 55.485 ms |
| Steady semantic expansion mean | 79.651 ms | 74.503 ms | 74.916 ms |
| Steady lookup construction mean | 55.366 ms | 50.014 ms | 50.889 ms |
| Complete steady frame service mean | 1,542.070 ms | 1,458.978 ms | 1,446.911 ms |

The repeat supports an approximately 8 ms initial lookup reduction and 4–5
ms steady lookup reduction. Whole-frame times span separate short runs, so
their larger differences are not attributed to this change. The optional
timers locate work but do not predict the timer-free gain. The application
frame timer excludes physical panel completion and touch response.

## Timer-free complete frames

The retained code had a clean ARMv6 build with build ID
`392ea165ead5c82e3f753ba19525043dad82dfce`. The local artifact and
deployed executable had matching SHA-256
`9941664a1eed2c924a5706ae29401eb25e8cbc5b4dade07fb9a267b23f05eb13`.
Two [60-second](pi-cold-semantic-sort-once-timer-free-60s-20260928.log)
[foreground runs](pi-cold-semantic-sort-once-timer-free-repeat-60s-20260928.log)
completed 37 and 38 steady frames. Their first 15 payload, region, and byte
counts match the earlier timer-free
[paired-read trace](pi-cold-pixel-read-repeat-20260928.log) in order.

| Application phase, all complete steady frames | Paired-read baseline (38) | Sort once (37) | Repeat (38) |
| --- | ---: | ---: | ---: |
| **Total frame service** | **1,537.141 ms** | **1,562.316 ms** | **1,555.937 ms** |
| Derivation | 188.364 ms | **183.979 ms** | **181.017 ms** |
| Offer including sink | 1,345.909 ms | 1,375.644 ms | 1,372.004 ms |
| Framebuffer sink | 798.468 ms | 805.114 ms | 799.070 ms |

Derivation improved by roughly 4–7 ms against the earlier baseline. Both
candidate runs had slower offer work, so there is no demonstrated
whole-frame gain in these timer-free runs. The initial derivation was 250.935
and 255.478 ms in the candidate runs, versus 260.822 ms in the baseline;
initial complete-presentation time varied much more. The sort-once change is
retained as a small, exact-output semantic improvement, not as a solution to
the 250 ms cadence target.

The focused `DynamicSemanticHostStorage` suite passed three tests; the exact
SPEC-001 Pi host-native raster gate matched its reviewed references. A clean
ARMv6 hard-float build passed, and the timer-free host suite passed **1,144
tests in 17 suites** with `-DGIFTUI_DYNAMIC_PROFILE` after directing the
Clang module cache to `.build/`. The timed candidate's first-frame semantic
phase still takes about 135 ms, and the complete presentation remains far
above the 250 ms period.
