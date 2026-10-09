# I3-T01 correction package result

**Disposition: passed within the stated hardware-free validation boundary.** Baseline: `4f0e7cb3` (production inherited from iteration 2).
Authority: iteration-3 revision 5; implemented SPEC-001/007/008/012/013/014/015,
accepted ADR-011/030/032 and their linked authority. RFC-013 remains draft.
Eugene requested proceeding and committing each step on 2026-10-09.

## Budget

Eight active hours shared by planning, implementation, checks and reporting.
Launch clock: 2026-10-09 16:43 UTC; 15 minutes charged for preceding orientation.
Final charged upper bound: **140/480 minutes** (15 minutes of orientation plus execution, build, test and reporting time, rounded up conservatively to five minutes). Brief tool-permission latency is conservatively included; no hardware or design-decision waiting was needed. This allowance is closed, not renewed.

## Steps

| Step | Disposition | Evidence |
| --- | --- | --- |
| Launch planning | Complete (`c06a6ec3`) | Seven updated per-Spec plans and three focused design notes |
| I3-T01.1 scheduling | Passed locally (`2e455320`) | Swift schedule corpus (3 tests); native production C loop 2,400 simulated deliveries; nRF build/ABI pass |
| I3-T01.2 raster | Passed locally (`5ccf0a63`) | 17 independent golden masks, 16 chunk-boundary/style combinations, callback order/refusal, nRF build |
| I3-T01.3 layout | Passed locally (`9275c093`) | 16 layout tests, native complete Layout/Drawing storage corpus, nRF build |
| Integrated validation | Passed (`7d618db7` source/test revision) | 74 checks, 60 verified owner/profile reports, current target builds and pixel oracles |

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
Native full-host rehearsal and Pi cross-build were pending at this step;
the final integrated evidence below records their successful completion.

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
Raster commit: `5ccf0a63`; the combined validation result is recorded below.

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

## Final integrated evidence

After formatting, `scripts/test.sh all-hardware-free` completed as
`run-lWETuH3u` on clean revision `7d618db707d68d3fa4f1ab1fa4facec92e63d2f5`:
**74/74 checks pass**, including 300 XCTest and 1,173 Swift Testing tests and
all 15 Specification drivers on macOS Dynamic, macOS Static, Raspberry Pi
ARMv6 and nRF52840 Embedded. All **60 report manifests verify**. The test-harness
repairs are commits `0f93755d` (interruption fixture) and `7d618db7` (source epoch); both interrupted runs remain in the archive.

- [Parent identity](i3-t01-evidence/metadata.txt), [results](i3-t01-evidence/results.tsv),
  [child ledger](i3-t01-evidence/child-reports.tsv) and
  [verified owner identities and metadata](i3-t01-evidence/report-identities.json).
- [Raw validation and supplementary logs](i3-t01-evidence/validation-logs.tar.gz),
  [report/input/command snapshots and current reference bundle](i3-t01-evidence/report-snapshots.tar.gz),
  [archive hashes](i3-t01-evidence/archive-hashes.tsv) and
  [maintained input hashes](i3-t01-evidence/maintained-input-hashes.tsv) and
  [validated contract identities](i3-t01-evidence/contract-hashes.tsv).
- [Supplementary rehearsal identities](i3-t01-evidence/supplementary-checks.json):
  Pi 2,400-transition/120-frame host fixture, default-source nRF production
  rehearsal and its partial-mutation/refusal/recovery controls. These preserve
  simulated-clock/source-pattern distinctions and do not establish target rate.

The current per-Spec target reports include ARMv6 hard-float, ARMv7E-M/VFP,
source/module ownership, heap/resource guards, current source-hashed reference
traces, exact target raster comparisons and failure controls. The archived
snapshots identify full canonical reports under `.build/`; snapshots are not
substitutes for their complete build payloads.

## Resource and performance account

| Item | Observed bound or cost | Limit of evidence |
| --- | --- | --- |
| Source scheduler | One generation and absolute deadline; at most 20 deliveries per poll, existing per-window producer categories retained | Simulated 30s/80-events/s ordering, not connected acquisition latency |
| Unit orthogonal raster | One 8-byte coverage mask plus fixed scalars; no row allocation; at most 232 point reads in the independent 8-point/9-row/3-chunk case | Re-scans per chunk; no universal Dynamic/Pi speedup claim |
| Layout index | 98-byte sorted scope ordinals plus 224 glyph-local bytes, aliasing existing scratch only during Layout | Published Render and line lookup scans remain; runtime-derived graphs are not adopted |
| Linked nRF image after scheduling | 274,368 flash / 95,104 RAM bytes | Step image, identified above |
| After raster | 278,032 flash / 95,104 RAM bytes | +3,664 flash versus scheduling step |
| After layout | 278,592 flash / 95,104 RAM bytes | +560 flash; no linked RAM increase between these step images |
| Limits | Flash 1,048,576; RAM 196,608 bytes; region and configured stack reservations unchanged | No limit raised; no complete feasible-path stack proof |

[Compiler/disassembly evidence](i3-t01-evidence/local-stack-evidence.json)
for the identified layout-step ELF records local frames: production orthogonal
raster 360 bytes, probe specialization 112, workspace scope lookup 56, glyph
append 112, C service 56 and schedule synchronization 24. These include each
function's saved registers and local reservation, **not** its callees,
callbacks, IRQ overlap or a complete application bound. The scalar mask size
alone is not a stack-size claim. Full lifetime/stack obligations remain open.

## Iteration dispositions and direction

The features `signal-analyzer`, `giftui-mvp-architecture`, and `canvas-drawing`
retain their implemented contracts and existing conformance dispositions.
External integration remains at RFC stage with draft RFC-013 and iteration-4
external delivery. No lifecycle approval, scope amendment, exception, graph
migration, display-clock change or connected operation occurs here.

| Criterion | Disposition after this package |
| --- | --- |
| IT-AC-001–003 | Transferred to iteration 4, not met here |
| IT-AC-004 | Changed generated-graph paths pass local semantic/action/pixel/failure regressions; both runtime-derived applications and connected matrix remain unmet |
| IT-AC-005 | This package's changes, identities, limits and dispositions documented; full iteration disposition still open |
| IT-AC-006 | Unmet: generated analyzer graphs remain; both applications' runtime derivation is still I3-04 |
| IT-AC-007 | Partial: bounded lookup/raster counts, linked resources and local stack frames accounted; complete live-memory/phase ledger remains open |
| IT-AC-008 | Partial: unchanged bounded regions and target build/heap/ABI guards; complete runtime-derived lifetime/stack bounds remain unproved |
| IT-AC-009 | Unmet: no connected sustained 80-events/s/four-FPS proof; production nRF remains 4 MHz with the recorded transfer-floor failure |
| IT-AC-010 | Partial owner constraints below; final integrated backend handoff remains open |

For **ME-05/06 and I3-04**, preserve generation-aware source deadlines, account
for the 360-byte raster local frame in complete call paths, and preserve the
Layout-to-Render scratch lifetime when choosing the runtime representation.
The corrected owners are reusable inputs, not proof of the outstanding model
borrow/callback/escape/IRQ realization or the counter's missing resource bounds.
A concrete runtime design and its applicable contract approvals/ready tasks
are still required. No archived candidate is adopted or experiment restarted.

For **ME-08**, revalidate these corrections on the later integrated runtime-derived
analyzer and counter, then obtain the separately authorized connected workload
and stack observations on exact supported artifacts. The hypothetical 32 MHz
assumption is still unverified and is not the production setting.

For **ME-09/iteration 4**, carry forward the fixed synchronous borrowed-stroke
lifetime, Layout scratch retirement before Render reuse, generation/deadline
ownership and existing frame/admission budgets. Package/API extraction and
iteration closure remain behind their existing gates. No automatic successor
or additional preparation allowance follows from closing I3-T01.
