# P08 typed-stage correction 1 — borrowed assertion capture

**Correction 1/2 consumed; independent SOURCE PASS at `a72f0943`; rerun pending.**
[Focused independent source review](p08-stage-realization-cycle1-independent-source-review.md)
finds the exact five-site correction ready for the affected registered rerun.
[Activity](p08-stage-realization-activity.md), initial source `8ae0fb1c`, independent
source PASS and actual screen input `f67abf33`. Historical allowances stay closed;
the two-consecutive-unproductive guard remains. This is one grouped cause fix,
not a new optimization variant. Corrected-source execution is **not run**.

The initial screen is preserved in [the immutable failure packet](stage-realization-cycle1/initial-screen.tar.xz)
and [exact commands/hashes/status manifest](stage-realization-cycle1/initial-screen-manifest.json).
Wrapper SHA-256 `1fc14ce1ffc8e6d13202816b69fbfd825d9add4098fdbdede69bf88e2fd73cbc`;
build receipt `7f1013f65f4402f2c5eabed9780d7b24d5428e8ef6da93857a3abb6df6e9e326`;
counter-model log `b0bf6b0a8ddd8ec88aa8e302b3ffd15351834fbdb40160adaa958365b0a05008`.
The run passes 23 preparation checks, fails counter-model compilation, blocks
layout measurement and does not run 202 controls. Partial flags remain false
for focused success, complete collection and aggregate pass. No stack result.

Four helper signatures are diagnosed because `precondition` autoclosures capture
their borrowed `before` parameter; the action helper contains two such calls.
The **only Swift change** evaluates those same five full fingerprint-plus-model
comparisons into owned Bool locals immediately after the same operations, then
asserts each Bool. Four `borrowing P08ReuseFingerprint` parameters, one original
caller baseline, five full comparisons, current admission and all positive twins
remain. No baseline copy/reconstruction, weakened field check, lifetime change,
state/cleanup/phase/loop/label change or capability return is introduced. The
related new helper sites were scanned: no remaining assertion autoclosure uses
the borrowed baseline. The short-circuit RHS observes only model value; `before`
is passed directly to the existing borrowing comparison outside the autoclosure.

Swift SHA-256 `55e9026c25aa66f3374ccd81fa14ab6982e07aea2e3a95b2e2d9fae5c4295631`.
[Manifest](stage-realization-cycle1/manifest.json) SHA-256
`164b1661af57c31bf1b1a9441a46f500040323c2ef3d3cd9a90d2af157060634`
pins [the exact source/driver diff](stage-realization-cycle1/source.diff.xz),
initial manifest, complete unchanged 384/202 and 26-label inventory, native
controls, command and failure packet. [Fresh exact qualification](p08-stage-realization-cycle1-applicability.json)
SHA-256 `872baea16e6eb884c3721f34c924084d254046558c35a852d92f1ee69da27167`
repins the seven noncompiled component predecessors only. Fresh checks verify
all 11 dependency receipts, artifact/Swift-input/compiler/macro identities and
source argv exclusion; the exact driver qualifier accepts all seven. Driver
changes only the qualification path/activity constant. Old receipts, qualifiers,
source freezes and the initial failed candidate remain unchanged.

Compiler-free exact-replacement/count/hash/qualification, Python AST, local-link,
governance and whitespace checks pass. No compiler, suite, build, runtime or image
call was made. The only changed Swift is a formatter-excluded fixture; maintained
Swift formatting is unaffected. Focused review precedes **one affected rerun** of
the exact registered command in the manifest and initial freeze, with the new
qualification. It still omits 202 controls. Any artifact produced must undergo
the planned early reachable-frame/path rejection check before expensive work.
Resource limits, all ownership/contracts, full-image prerequisite and P08/R07/
T8.1/HC-RD-003 open dispositions are unchanged; correction productivity is pending
the affected run, not inferred from this source fix.
