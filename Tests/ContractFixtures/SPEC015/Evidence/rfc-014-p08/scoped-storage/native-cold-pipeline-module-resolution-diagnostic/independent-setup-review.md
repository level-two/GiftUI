# Independent diagnostic setup review and repair — 2026-10-17

**Setup failure confirmed; one bounded diagnostic replay approved.** Reviewed
`d623ee4b`, the [result](result.json), raw provider stderr and pinned hidden-help
artifact. Their recorded SHA256 hashes match. The provider rejected the copied
SwiftShims PCM because its embedded cache path is the original path. It exited
before the desired imports/macro/body observations; the consumer did not run.
This is no new codegen, runtime or body-availability result. The earlier actual
host generic call remains independently established. **1/2 corrective cycles
consumed; this setup repair does not start corrective2.**

## Exact next execution

Use the **original cache in place**, not a relocated copy. This corrects the
cache-copy instruction in the [previous review](../p08-native-cold-pipeline-correction1-independent-review.md).
Its original three-file inventory still matches `result.json` exactly at this
review; the PCM's expected path is preserved. This choice avoids rebuilding shims
or changing compiler policy. There is no automatic clean-cache fallback.

1. Create a new diagnostic output directory; preserve both existing packets and
   the failed replay. Recheck the recorded compiler, SDK, macro/runtime inputs,
   source snapshot and physical module hashes. Inventory/hash the entire original
   `.build/contracts/p08-native-cold-correction1-codegen/cache` immediately before
   execution, requiring exact agreement with `cache.original_inventory` in
   `result.json`. Do not run another job against this cache concurrently.
2. Replay the failed provider's recorded argv **once**, changing only its
   `-module-cache-path` value back to the absolute original cache directory and
   its output/log/trace paths to the new output directory. Keep its archived
   `Counter.swift`, frozen macro, SDK/target, all five ordered `-I` entries and
   existing five diagnostic flags. Do not emit over any imported original module.
   Preserve argv, timing, stdout/stderr, exits, output hashes and cache inventory
   immediately afterward. A failure stops this batch; no retry/flag variation.
3. Only after provider success, run the already authorized archived
   `runtime-sil-command.json` consumer **once**, against the original frozen
   module search directories, using the same original cache. Remap source inputs
   to the frozen `inputs/compiled-source/` snapshot and outputs to the new consumer
   directory as previously specified; keep other flags and input ordering exact.
   Add the four already confirmed module/macro-loading, serialization and loaded
   trace diagnostics, with no provider-only macro-expansion dump. This consumer
   observes the original imported presentation module, not the newly emitted
   provider output. Hash actual loaded module paths and compare the provider
   output with its frozen counterpart, recording any difference without replacing
   either. Inventory the cache again and preserve final SIL/logs/trace.
4. Separate added cache entries/timestamps from changed/removed preexisting PCMs.
   Qualification requires the original PCM bytes to remain exact. A changed or
   removed original PCM invalidates exact-cache qualification: stop and record
   the facts, without cleanup, restoration or another fallback. New compiler cache
   artifacts are cache state, not new maintained source or acceptance evidence.

This permits at most **two source-unchanged compiler replays**, provider then
consumer, within the existing diagnostic setup repair. No macro/module rebuild
campaign, shim regeneration, runtime, source candidate, full suite or image is
authorized by this amendment. No further help query or flag search is needed.

## What the available diagnostics establish

The existing `frontend-help-hidden.stdout` SHA256
`77e875d623bb2ddca3af781f2c5e37ff36e5112b20d829980063d72848ab85be`
confirms: `-Rmodule-loading` reports loaded modules; `-Rmacro-loading` reports
loaded macro implementations; `-dump-macro-expansions` dumps expansion results;
`-emit-loaded-module-trace-path` emits loaded-module trace JSON; and
`-Rmodule-serialization` emits module-serialization remarks. Use those exact
confirmed capabilities. The last flag is **not documented as a per-function
serialized-SIL body decoder or an inliner-rejection explanation**.

The batch can establish physical import identity, actual generated declarations/
attributes and whatever serialization remarks are emitted. Positive observed
deserialization/body/inlining for the relevant symbol is useful evidence of its
availability in that run. A final optimized declaration or a missing remark cannot
prove the physical module lacks a body, that the compiler requested/rejected it,
or a compiler defect/impossibility. If these diagnostics do not expose that
distinction, report it unresolved and stop; do not invent another flag experiment
or spend corrective2 on an unsupported source guess. A concrete final repair must
still identify a checked internal boundary and why its change addresses the
observed failure, under the unchanged strict contract and remaining allowance.

Review used only existing artifacts and document checks. No compiler/application
execution, cache mutation, source edit or restoration occurred here. External five
files, pycache and the user's aborted restoration remain untouched; P08 stays open.
