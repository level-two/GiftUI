# I3-T01 correction package result

Status: active. Baseline: `4f0e7cb3` (production inherited from iteration 2).
Authority: iteration-3 revision 5; implemented SPEC-001/007/008/012/013/014/015,
accepted ADR-011/030/032 and their linked authority. RFC-013 remains draft.
Eugene requested proceeding and committing each step on 2026-10-09.

## Budget

Eight active hours shared by planning, implementation, checks and reporting.
Launch clock: 2026-10-09 16:43 UTC; 15 minutes charged for preceding orientation.
Cumulative usage at launch: 15 minutes. Waiting: zero.

## Steps

| Step | Disposition | Evidence |
| --- | --- | --- |
| Launch planning | Ready | Seven updated per-Spec plans and three focused design notes |
| I3-T01.1 scheduling | Implemented; focused checks pass | Swift schedule corpus (3 tests); native production C loop 2,400 simulated deliveries; nRF build/ABI pass |
| I3-T01.2 raster | Implemented; focused checks pass | 17 independent golden masks, 16 chunk-boundary/style combinations, callback order/refusal, nRF build |
| I3-T01.3 layout | Implemented; focused checks pass | 16 layout tests, native complete Layout/Drawing storage corpus, nRF build |
| Integrated validation | Pending | Four-profile gate and exact target builds |

## Validation boundary and subsequent work

This package starts from the maintained generated production graph. It cannot
satisfy I3-04 runtime derivation or iteration-wide IT-AC-004–010 by itself.
ME-05/06 still needs the runtime realization and applicable approvals; ME-08
needs exact integrated artifacts and separately authorized connected evidence;
ME-09 needs criterion dispositions and human closure. The production display
remains at 4 MHz. Hardware-free checks cannot establish four FPS, connected
80 events/s, physical input behavior or a complete stack bound.

## Scheduling step

The source anchor advances from the previous deadline. Source generation is
checked across opportunities, including Stop+Start without an intervening poll.
Clear does not alter it. The C loop and Swift schedule exercise thirty seconds
at 80/s in twenty-event batches; this is simulated clock evidence, not device
throughput. Excess backlog and arithmetic overflow fail explicitly.

Validation: `scripts/contracts/check-spec-001-nrf-production-host.sh`,
`swift test --filter SignalAnalyzerSourceScheduleTests`, formatter and
`scripts/nrf52840/build.sh --application signal-analyzer-static` pass.
First Swift invocation was blocked by the compiler cache sandbox; the rerun
then exposed mutating calls inside Testing macros, fixed before the passing run.
Native full-host rehearsal and Pi cross-build are pending integrated checks.

[Scheduling nRF resources](i3-t01-evidence/scheduling-memory.txt):
274,368 flash bytes and 95,104 RAM bytes, within unchanged limits;
[ABI](i3-t01-evidence/scheduling-arm-attributes.txt) and
[artifact hash](i3-t01-evidence/scheduling-artifact.sha256).
No complete stack or connected-performance claim follows.

## Raster step

One UInt64 mask replaces the heap row and enables unit orthogonal coverage in
all profiles. Existing general widened arithmetic remains for other strokes.
The independent cell-union regression covers widths 63/64/65/193, round/butt
caps, miter/round joins, duplicate vertices, reversal, negative path/clip
coordinates and refusal across chunk boundaries. Full callback transcripts
match row-major expected pixels; point reads remain at most 232 for the
eight-point, nine-row, three-chunk fixture, instead of per-pixel path walks.
This operation-count bound is not a target time measurement.

Formatter, the 17-mask SPEC-012 independent oracle, four focused raster tests
and the nRF build/ABI pass. The first new test used an invalid negative-origin
surface; it was corrected to the existing zero-origin descriptor contract,
retaining negative path/clip coordinates.
[Tests](i3-t01-evidence/raster-tests.log),
[resources](i3-t01-evidence/raster-memory.txt),
[artifact](i3-t01-evidence/raster-artifact.sha256).

Scheduling commit: `2e455320`; launch commit: `c06a6ec3`. The scheduling native
production rehearsal also passes, including owner partial-mutation/refusal
controls. Its clock is simulated and its default source is below 80/s.

## Layout step

Scope lookup uses a sorted byte-ordinal index and at most seven binary-search
comparisons for 98 scopes, plus final record validation, instead of up to 98
full record scans. Physical append order and all nonzero UInt16 identities
remain supported. Local glyph ordinals are stored once and read directly;
ordinary contiguous glyph append finds the last matching glyph immediately.
Interleaved identities retain a bounded backward search. Existing line scans
and published Render lookups remain unchanged; this is not a claim that all
layout traversal is constant-time.

The two indexes occupy 322 bytes at text-region offsets 4,336–4,657 inclusive,
inside the existing 4,704 bytes. They are cleared before publication and reset.
No retained codec, allocation, storage limit or published bytes change.
The independent host/Embedded publication byte comparison and Render scratch
reuse checks pass.

[Sixteen focused tests](i3-t01-evidence/layout-tests.log),
[native Layout/Drawing](i3-t01-evidence/layout-native.log), formatter and nRF
build/ABI pass. A split range-expression syntax error was caught and repaired
before these passing runs. [Resources](i3-t01-evidence/layout-memory.txt) and
[artifact](i3-t01-evidence/layout-artifact.sha256) identify the changed image.
The Pi native production rehearsal and cross-build also pass.
Raster commit: `5ccf0a63`; combined repository validation follows.

## Integration harness repair

The first aggregate run `run-srW7Ywjw` failed the existing interruption fixture:
its ready marker preceded creation of the staging directory it expected after
TERM. A focused retry passed, and source inspection confirms the race. The
fixture now publishes readiness after both staging directory and metadata exist;
all original interruption/lock/evidence assertions remain. Focused validation:
`ruby Tests/GovernanceTooling/runner_isolation_test.rb` — 3 tests, 30 assertions,
zero failures. The original aggregate was interrupted at SPEC-013 nRF checks
(exit 130) before restarting on the repair; it is not passing evidence.
This is an in-budget gate repair, not another iteration task.

## Reference-clock alignment

The next aggregate run `run-wnkdTKsu` passed the shared checks and all 45
macOS/Pi owner-profile checks, then exposed the independent Static reference's
old 260 ms source anchor. Production now anchors Start at its 250 ms service
opportunity; adding the next 10 ms poll to the reference retained the corrected
defect. The fixture now uses 250 ms, with the exact frame/action and reviewed
pixel comparisons unchanged. That run was interrupted after the mismatch
(exit 130) and is retained as diagnostic evidence, not a passing gate.
Focused validation passes: the full Static reference workload and all 818
ordered frame / 12 action comparisons against the production rehearsal.
