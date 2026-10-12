# P08 step 2 — finite counter source and model

2026-10-12; Strong Sol6.1 High, sequential. PASS: existing finite frontend
lowers the authored CounterScreen, CounterCanvas and exact UInt16 actions0/1;
Swift6.4 compiles P08CounterSchema/Presentation/Table and concrete model/domain.
Actual Static and Dynamic observable storage execute **92 assertions**, zero
failures. Clamp/reset/no-op/fact rejection, read-phase mutation rejection,
explicit ticket release and stale-key rejection are exercised. The finite
source specifies title/digit, disabled boundaries and exact optional round
stroke; rendering and source-to-host acceptance remain subsequent tasks.

Command: `python3 scripts/contracts/check-spec-015-counter.py --runtime-build
.build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static`.
Fresh result: `.build/contracts/p08-counter-rks2b60f/result.json`; all recorded
input/artifact hashes reverified before freezing this receipt. Prior verified
Swift6.4 compiler/macro/modules are reused without recompiling P07.

Initial control `.build/contracts/p08-counter-jfx8kr2m` lowered and compiled all
modules, then trapped in the probe: it tried `withDiscovery` after `endFrame`.
`ObservableModelOwnership.beginDiscovery` requires reading. The correction uses
existing `release` directly during mutating phase; the complete rerun passes.
This was a narrowed fixture cause, not an unproductive repair or production
contract issue. Resumed consecutive unproductive guard remains **0/2**.

Full counter host, actual nine-stage audit/report, semantic/layout/drawing/
interaction/presentation pipeline and four routes/early images remain open.
This is no package exit acceptance or implemented transition.
