# P08 step4 — actual finite counter layout/drawing/render

2026-10-12; Strong Sol6.1 High, sequential. PASS **1066 counted assertions**:
804prior owner/model controls +250actual render/plan checks +12first-excess fixed
storage controls. Actual State expansions0–9 feed maintained layout, generated
Canvas invocation, drawing-plan preflight and combined render on Static/Dynamic.
An independent source-derived oracle checks no stroke at0; positive values have
one white round width1 segment from Canvas-origin+(4,8) to+(4+4×value,8), one
subpath/two points,22text glyphs and exactly one finished synchronous stream.
The sink is a finite recording endpoint component; this is not backend pixel,
concrete host or target-image acceptance. Invocation releases the owned capture,
retaining only identity metadata until discard; cleanup does not release twice.

Final Static composition owns counter-specific finite codecs, with no analyzer
region or P07TargetWorkspace import/object: scope1024(32×32), text/render1056
(16×16line +64×10glyph +160scratch), path20(2×8point +1×4subpath), plan112
(8occupancy/padding +16Canvas +64stroke +16point +4subpath +4tailpadding).
These implement existing focused interfaces/algorithms; they supply no expanded
graph or additional host role. Dynamic uses bounded32scope/64glyph/1Canvas/2point
owners. Complete linked ledger, allocator/stack/ABI and actual host audit remain
open. No analyzer physical reservations are adopted for final counter evidence.

The first control identified missing RenderLowering import. Generic borrowed
observations inside `precondition` autoclosures were then materialized into small
owned scalar/header locals (no plan/workspace copies, unsafe escape or compiler
flag change). Runtime diagnostics narrowed existing analyzer codec constructor
requirements; its temporary physical extent passed component checks but was
replaced before this commit to satisfy SPEC015's counter-owned-storage clause.
The compact plan initially overlapped its occupancy bitmap with Canvas metadata;
reserving one occupancy byte and7alignment bytes corrected the exact layout.
All0–9 cases and first-excess controls pass with final counter-owned regions.
Diagnostic commands/full logs are retained under diagnostics; the compiler's
'compiler bug' message is a diagnostic, not a proven compiler defect.
Every correction had a narrowed cause or passing checks; guard remains **0/2**.

Command: `python3 scripts/contracts/check-spec-015-counter.py --runtime-build
.build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static` after formatter.
Final `.build/contracts/p08-counter-zy3ir___/result.json`; recorded input/artifact
hashes reverified before freezing. Formatlint/governance/diff checks pass.
Next: actual counter coordinator/admission, complete nine-stage host audit and
activation/teardown, then registered four application routes/early linked images.
No P08 self-pass or implemented transition.
