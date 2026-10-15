# P08 typed-stage cycle 1 — focused independent source review

**SOURCE PASS at `a72f0943`; ready for one affected registered rerun.**
The [cycle 1 freeze](p08-stage-realization-cycle1-source-freeze.md) addresses the
four actual borrowed-parameter capture diagnostics in the preserved
[initial failure packet](stage-realization-cycle1/initial-screen.tar.xz).
No compiler, build, test gate, runtime or image was run in this review.

The complete Swift diff equals exactly five replacements: the original full
fingerprint-plus-model expression is evaluated into an owned Bool immediately
before its original assertion. Inverting those five replacements reproduces the
entire prior Swift file byte for byte. The action helper's two sites and the
input, admission and source helpers' sites are all covered (current 1595, 1598,
1608, 1619, 1632). All four borrowed signatures remain; no assertion autoclosure
still references the borrowed fingerprint. The short-circuit RHS mentions only
host/model observation; the fingerprint is evaluated directly on the LHS.

One original stale baseline, five full comparisons, operation order, same model
observation and immediate assertions remain. Nothing copies/reconstructs the
baseline, shortens its fields or changes capture/admission/positive twins.
Phase/lender/cleanup/origin, namespace/loop/corpus and physical accounting source
are unchanged. The previous source assessment remains bounded; actual compiler
acceptance was not established by it and is still pending for this correction.

Source, driver, qualification, compressed/decompressed exact diff and original
manifest identities verify. Seven original receipt/metadata/argv checks remain
exact (53, 53, 112, 173, 173, 159, 172 inputs); changed source is noncompiled in
every predecessor. Driver changes only qualification path/activity; drift guards
are unchanged. Manifest preserves complete 384/202 labels, native controls,
26 reuse labels and the registered command. Python AST verifies. Unchanged
891-artifact dependency verification was not redundantly repeated.

Independently hashed the five-member failure archive and every member, preserving
actual four diagnostic headers: “'before' cannot be captured by an escaping closure
since it is a borrowed parameter.” Initial 23 pass / counter-model fail / layout
blocked / 202 not run is not relabeled. No initial layout or stack result exists.

Correction **1/2 consumed**, rerun pending; historical allowances remain closed.
The source correction addresses the diagnosed mechanism; compiler/measurement
productivity must be assessed after the rerun. Proceed with the unchanged exact
screen command below, then inspect actual required frames before expensive work.
Partial success cannot satisfy the full-current-collection image prerequisite;
P08/R07/T8.1/HC-RD-003 and all resource/acceptance residuals remain open.

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded --host-build .build/contracts/p08-scoped-host-hzs5q7za --fresh-focused --select-family so07-layout-facts
```
