# Independent final investigation review — 2026-10-11

**Disposition: finite investigation complete without a verified candidate.
P08 remains blocked; no further compiler work or production resumption is
authorized.** Strong Sol 6.1 High, sequential. Frozen reviewed revision:
`dff73a36a5a5a6157d24a692f709eb9da332175b`, clean at entry. This was a read-only
audit of recorded evidence; no compiler/test, probe or repair ran.

All **36** frozen [manifest](manifest.json) entries match. Each of the three
run receipts matches its source snapshots and complete stdout/stderr hashes.
Run1/run2 sources, commands, outputs and receipts remain unchanged from the held
revision `0e21d822`. Run3's LayoutB and Supplied sources are byte-identical to
that revision, before the reviewed continuation. Its command retains the pinned
Swift6.3.2 compiler identity and prior flags/module dependencies.

The [accounting review](accounting-review.md) correctly preserved both initial
calls while charging A conservatively1/2. Run1 rejected two caller consumes of
Copyable fields; their two-token correction in run2 exposed actual A activation
lifetime failures and additional imported-profile partial-consumption errors.
The original provisional count and raw ledger remain retained.

Run3 is the fixed second hypothesis, not another layout. Its caller correction
lends the actual profile's fields through a state-free extension, retaining the
audit and nested model/root, semantic, Canvas, geometry and control scopes.
The owner is initialized, activated and quiesced inside those scopes; actual
pipeline/endpoint, binding, admission and coordinator construction remain inside
`activate()`. This stays within the permitted evidence-only caller correction.

[B's complete diagnostic](run-3/stderr.txt) rejects the activation state transfer
at `state.take()` for self-dependent lifetime escape, also reporting consumption
errors in activation/quiescence and internal noncopyable-copy errors. The previous
imported-profile partial-consumption diagnostics are absent. Neither that absence
nor compiler diagnostic wording proves an isolated caller/initializer pass, a
compiler bug, language impossibility or a valid host pattern. Both hypotheses
remain rejected at the actual activation ownership/lifetime boundary.

Final counters agree with the [ledger](ledger.json): **3/6 invocations, 2/2
layouts, zero passing controls, zero negatives, conservative investigation
guard2/2**. Historical production guard remains **2/2**, unchanged. Both failed
positives correctly skip negatives. Three unused numerical calls do not override
the exhausted guard or permit another hypothesis, correction or historical replay.

No successful construction or production authority results. P08 acceptance and
its remaining counter, validation, lifecycle and platform obligations remain
open. No substantiated contract alternative follows from these controls. This
review proposes no further investigation or workaround. A separate explicit
decision is required before any affected work resumes.

This review commit adds this report and its result link, and refreshes only the
corresponding manifest entries; recorded controls and ledgers stay unchanged.
