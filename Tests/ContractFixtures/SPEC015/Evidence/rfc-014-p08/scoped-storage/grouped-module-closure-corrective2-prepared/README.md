# Final corrective2 source and command freeze

**Final corrective2/2 is in progress; compiler unexecuted.** Implements
[1d567952 independent PASS](../p08-grouped-module-closure-corrective2-independent-design-review.md):
exact21 `@usableFromInline` annotations in13 files plus the sole approved
CanvasStagedEntry `value: Payload? = nil` completion, **22 edits in14 files**.
[Per-site edits](source-edits.json), [source diff](source.diff) and
[token/hash qualification](source-qualification.json) are frozen. All other
signature/body/default/access/ownership/lifetime tokens match1d567952 exactly;
288 other frozen inputs, including external5/pycache, State/macro/Counter bytes,
are unchanged. Arithmetic remains ordinary ABI callable; no opacity, codegen,
resource or acceptance claim follows from annotations.

Run once from the repository root (expected30–90 seconds):

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/grouped-module-closure-corrective2-prepared/run.py
```

`--validate` PASSED without a compiler call. [Exact structured argv](prepared.json)
reuses the established pinned recipe; only isolated output paths differ.
All25 owners rebuild fresh; actual current imports verify against the DAG,
canonical8 Static/13 Dynamic selections match the registered AST and reviewed
recipe, all307 source/tool/recipe inputs are [hash-frozen](input-freeze.json).
The accepted unchanged macro identity is reused, Counter is freshly lowered and
its three outputs must match accepted hashes. SDK/package/optimization/lifetime
flags and macOS DYLD framework/library paths are unchanged. No stale project
module directory is accepted. Output is `.build/contracts/p08-grouped-module-closure-corrective2`;
preexistence rejects execution. Each successful owner alone publishes its module;
all independently runnable errors are collected sequentially and dependents blocked.
Inputs revalidate before/after the sweep; runner/argv/audit hashes are frozen in
[recipe receipt](recipe-freeze.json). No source mutation, automatic retry, third
correction or successor activity is allowed after a material failure.

Initial1/1 and corrective1/2 remain consumed; this is the final2/2, not a reset.
Compile PASS still requires applicable normal-import privacy twins, full14-loan/
Optional/lifetime/provenance/failure-cleanup safety controls and physical six-body/
all42-origin/callee/actual CounterPipelineOwner SIL/object specialization with
observer attribution. Only complete codegen+safety PASS permits unchanged strict
host-first cold/reuse. Metadata/observer and key-failure first-use costs remain
unresolved; P08/R07/T8.1 and the combined candidate remain unaccepted.
