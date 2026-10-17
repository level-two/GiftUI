# Independent corrective1 review — 2026-10-17

**Evidence PASS; early codegen prerequisite FAIL confirmed.** Reviewed `1dbb85aa`
against the [bounded design/review](p08-native-cold-pipeline-independent-design-review.md)
and [frozen corrective1 result](native-cold-pipeline-correction1-result/README.md).
This is an unaccepted experimental overlay. **1/2 corrective cycles consumed;
corrective2 has not begun.** P08/R07/T8.1 and SPEC-015 conformance remain open.
The strict first-use Static heap contract is unchanged; no exception, warmup,
unchecked replacement, compiler-policy change or restoration follows from this
failure. The user's aborted restoration is not retried.

## Independently verified facts

- Offline `native-cold-pipeline-correction1-result/verify.py` passes: all228
  archived members, actual host generic edge, external preservation and every
  ordered generated payload byte (bitmap1911; outline13195). Derived-file hashes,
  all48 committed post-format source hashes, pinned compiler/plugin hashes and
  every currently inventoried physical module hash also match. The archive SHA256
  is `6d2ff6ae1aaba5a1c0c4611d7267a15fe1366a61233e0583dd4e7b2d58ce9e0a`.
- `CounterPipelineOwner.beginObservableCandidateAndExpandSemantics`, text range
  `0x53e28..<0x549b0`, retains concrete-type metadata helper calls at `0x540b4`,
  `0x54324`, `0x54648` and generic `CounterScreen._giftUITraverse` at `0x54874`.
  Matching selected-host SIL applies it with the concrete CounterDomain/semantic
  visitor/workspace/sink/binding arguments. This is an actual selected host
  boundary. The separate `SemanticRecordStore.expand` clone at `0x1f00..<0x29e8`
  belongs to the common exercise probe, and is not substituted for that evidence.
  Relocations are restricted to `__TEXT,__text`; data offsets do not establish
  these calls. These surviving edges fail the design's monomorphic codegen gate;
  they are not new measured heap counts or proof that each helper always allocates.
- Provider optimized SIL contains the traversal body and
  `[heuristic_always_inline]`; optimized consumer SIL retains its generic apply
  and a declaration/effect summary without `bb0`. The object-producing provider
  module and separately SIL-producing provider probe module are **byte-identical**:
  44856 bytes, SHA256
  `aa24dafcd48c8dc1079bae766633e723f980767af04240b7f11bd4b125e71439`.
  This strengthens provider identity, but neither optimized SIL listing is a
  decoder of the physical module's serialized body records. A body can be absent
  from final consumer SIL for several reasons. No import-loader trace or physical
  body/deserialization observation establishes which reason applies here.
- The fresh diagnostic directory precedes the retained host, SPEC-006 and
  SPEC-013 directories in all three relevant provider/object-consumer/SIL-consumer
  command vectors; the SPEC-006 directory occurs twice. The inventory records
  differently hashed older GiftUI/ObservableState/SemanticCore candidates, the
  explicit fresh macro executable, and the cache path. The cache manifest contains
  only two Clang shim PCMs plus a timestamp, not evidence of an alternative Swift
  presentation body. Search precedence and matching hashes are useful premises,
  not an observed module-open trace. Some unrelated module commands use the old
  macro; the selected presentation/runtime commands name the fresh one explicitly.
- Nine listed modules passed their partial compilation. GiftUILayout failed on
  private `@inlinable` declarations and unexposed serialization dependencies;
  its copied output and the other changed owners are not freshly qualified.
  Compiled source snapshots precede formatting. No complete candidate link,
  private-client/lifetime gate, application screen or full collection ran.
  Payload equality alone does not qualify new layout, ABI, lifetimes or heap use.

The result's cautious body-availability interpretation is correct. In particular,
do not promote “provider has a body / consumer prints a declaration” into “the
physical serialized body is absent”, “the wrong module was loaded”, “the inliner
rejected an available body”, a compiler defect, or impossibility on pinned Swift.

## One bounded diagnosis before corrective2

Proceed with **one source-unchanged module-resolution/serialization diagnostic
batch**, not another source candidate or annotation experiment. It needs no new
human contract decision. Preserve the existing packet and all experiment outputs;
write a separate result under `.build/contracts/` and freeze its small evidence.

1. Verify this archive, compiler, fresh macro, module candidates and source hashes
   first. Use the archived `compiled-source/` inputs, `diagnostic/Counter.swift`
   and exact fresh modules; current formatted source is a different byte snapshot.
   Record the SDK identity and macro runtime dependencies as well. Do not rebuild
   the macro, alter source, replace retained dependencies or reorder/deduplicate
   `-I` entries. Copy the recorded cache to a new output directory; preserve its
   original hash inventory and record every subsequent diagnostic cache change.
2. Read the pinned front-end's hidden help once to confirm diagnostic syntax.
   Its binary contains `-Rmodule-loading`, `-Rmacro-loading`,
   `-Rmodule-serialization`, `-dump-macro-expansions` and
   `-emit-loaded-module-trace-path`; string presence alone is not flag validation.
   Replay only the archived `P08CounterPresentation-command.json` provider and
   `runtime-sil-command.json` consumer, using argument arrays, with supported
   loading/serialization remarks and provider macro-expansion dumping enabled.
   Redirect all emitted module/object/SIL/ABI files, traces and logs to the new
   directory. Keep target, SDK, `-Osize`, WMO, lifetime features, package/testing
   flags, explicit plugin and ordered import directories unchanged. No runtime or
   additional module compilation is needed. Do not overwrite the presentation
   module the consumer is supposed to import.
3. The two exact command arrays are inside `diagnostics.tar.gz` at
   `diagnostic/P08CounterPresentation-command.json` and
   `diagnostic/runtime-sil-command.json`. Diagnostic forwarding, after verifying
   help, is `-Xfrontend -Rmodule-loading`, `-Xfrontend -Rmacro-loading`,
   `-Xfrontend -Rmodule-serialization`, and
   `-Xfrontend -emit-loaded-module-trace-path -Xfrontend <new-trace.json>`;
   add `-Xfrontend -dump-macro-expansions` only to the provider. Retain the complete
   final argv and exit status, not a reconstructed shell string. Hash the module
   paths actually reported as loaded, including presentation/schema/GiftUI and
   semantic/observable dependencies. Compare the actual macro-expanded traversal,
   evaluate/read closure and attributes against the frozen macro source and SIL.
   If pinned diagnostics expose requested/deserialized SIL bodies, retain those
   records **before optimization**, including the relevant helper/closure chain.
   A final optimized declaration remains insufficient evidence of absence.
4. Stop after these two replays. Report separately: actual physical import;
   generated declaration/attributes; physical or observed deserialized body
   availability; surviving concrete host call. If no supported diagnostic exposes
   the relevant serialized/deserialized body, explicitly leave that question
   unresolved and identify the missing observation. Do not fill it with inference,
   try a flag matrix, enable CMO/serialize-all/unchecked access, or consume
   corrective2 merely to discover whether another annotation helps.

These are diagnostic-only compiler invocations for the next mechanical assignment;
none ran in this review. Diagnostics may explain a missed body without themselves
fixing it. A replay compiling only the provider/consumer remains a partial screen,
not a runnable or safety-qualified candidate.

## Final correction disposition

The approved internal mechanism remains a **conditional, unproved possibility**.
There is presently no evidence-backed concrete final source correction to approve
for execution: first identify a matching-module/serialization boundary and explain
why a bounded change would expose the required checked operation to the actual
concrete caller. Preserve recursive visitor behavior, APIs, fourteen loans,
Optional/lifetime/exclusivity and algorithms. Diagnose remaining checked bank /
stopped / publish forwarding in that same boundary; do not expand unrelated types.
Existing Layout visibility errors and every other changed owner still need their
matching compile qualification within the final grouped correction, not silent
reuse of candidate1 outputs. The current early failure says nothing conclusive
about those uncompiled rows' eventual feasibility.

If diagnosis yields a specific internal repair, corrective2 may proceed under the
standing strict implementation authorization, followed by every design-row
codegen/private-client/lifetime gate and fresh ordinary/host-first cold/reuse
screen. Retain baseline pairing and loaded runtime identity. Only a passing early
screen justifies affected profile collections/images and renewed complete rooted
allocation, Native/Pi stack, physical/Dynamic accounting and caller/exit ledgers.
Old resource/profile packets describe their frozen revisions; they do not qualify
this changed candidate. No full repository suite or hardware run is introduced.

Review boundary: existing-artifact/source inspection, offline replay and document
checks only. No compiler, application, build, source edit, restoration or hardware
operation. External five files and pycache remain untouched.
