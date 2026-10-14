# P08 integrated cycle 1 diagnosis and correction handoff — 2026-10-14

Independent Sol 6.1 High read-only diagnosis at `1907033c`, implementation source
still `e2d9db9c`. The [broader activity](p08-integrated-activity.md) and its exact
initial diagnostic sequencing govern. No compiler/build/probe, source mutation
or subagent during diagnosis. Current corrective cycles **0/2 consumed**;
**four initial driver cells consumed: three passed, one failed**. This diagnosis
does not itself consume a correction. The first correction can bundle the five
compiler cause groups below with [B01/O01](p08-integrated-independent-source-review.md),
then freeze and receive independent Strong assessment. No new permission stop
or accepted-contract change is needed by any diagnosed cause.

## Exact evidence and failure boundary

[Immutable initial-native packet](integrated-initial-native/manifest.json)
preserves all four wrapper argv, revision, exit, timestamps and stdout/stderr
hashes. SPEC-011 macOS Dynamic passed **459** assertions at
`.build/contracts/spec-011-owned-keys/tmp0vz0ql4d/macos-dynamic`; SPEC-013 passed
**5,904** at `.build/contracts/spec-013-runtime-cycle/tmpi1u8hyk5/macos-dynamic`;
scoped-host passed **187** at `.build/contracts/p08-scoped-host-ezcy1qan`.
These are component results, not actual-counter, target or full conformance proof.

Actual counter output `.build/contracts/p08-counter-__y0w52r` failed at the
`counter-model` module after 19 recorded commands. Its exact
[commands](integrated-initial-native/initial-macos-dynamic-counter/commands.txt),
[compiler log](integrated-initial-native/initial-macos-dynamic-counter/counter-model.log),
[wrapper result](integrated-initial-native/initial-macos-dynamic-counter/result.json)
and [diagnosis identities](integrated-initial-native/initial-macos-dynamic-counter/diagnosis-identities.json)
are preserved. The identity record freezes 194 maintained Swift source hashes,
the three successful predecessor receipt hashes/applicability distinction and
the existing finite labels. No actual-counter runtime, 384 scoped compiler
controls, five exclusivity controls or reuse runtime label was reached; no final
counter result receipt was emitted. A wrapper failure receipt is not a driver pass.

## Five compiler causes; 31 diagnostics are not 31 repairs

| Cause | Exact source/log location and diagnosis | Contract-preserving correction invariant |
| --- | --- | --- |
| C01: sizing expression complexity | `CounterScopedStorage.swift:905`; log line 33. One Dynamic `CounterGeometryMeasurement` construction exceeds typechecker expression effort. | Split sizing terms into explicitly typed local expressions, preserving exact physical sizes/payload sums and existing arithmetic/limit duties. No compiler flag, algorithm, allocation or resource-limit relaxation; no experimental probe. |
| C02: unsupported InlineArray API | `CounterScopedStorage.swift:1658`; log line 57. InlineArray has no direct `withUnsafeMutableBufferPointer`. The nested calls at 1659–1662 use the same unsupported spelling but are not separate emitted failures yet. | Borrow each original typed inline field through Swift 6.4's supported `mutableSpan`/MutableSpan buffer scope (or existing equivalent typed exclusive borrow), preserving the enclosing nested lifetimes and original addresses. Do not copy backing, borrow the aggregate while a child borrow is live, form an uninitialized span, or add an owned-array allocation. The existing MutableSpan use at line 158 and pinned stdlib interface supply the local API reference; actual compilation remains required. |
| C03: consuming a computed Optional expression | `CounterScopedStorage.swift:1716,1727,1738,1752,1773`; log lines 65,73,81,105,113. `consume stage.take()!` is not a local binding. | Take into a local binding and consume the extracted value once before the switch. Preserve the complete `@_lifetime(self: copy self, ...)` unions, holder's one owned stage, Optional retirement transfer and cleanup on every return. `finish` already uses the local `current` pattern. Do not make scoped values Copyable/Escapable or extract a field from a dying carrier. |
| C04: implicit owned extension constraints | `CounterScopedStorage.swift:1439,1441` conformances cause sixteen repeated requirements at 1777/1793; log lines 121–357. G/C/R/H are inferred Copyable/Escapable on the extensions despite the protocol/body suppressions. | Explicitly retain `~Copyable & ~Escapable` for all four generic parameters on both concrete observation conformances, with their existing protocol/equality requirements. Suppress extension defaults, never add owned conformances to scoped access types or erase their lifetime. Static and Dynamic are one cause family. |
| C05: missing generated-schema import | `CounterDynamicHostProbe.swift:63,65`; log lines 89/97 cannot find `CounterModelSchema`. Six `.failure` contextual-base errors at 75,80,85,90,95,100 (log 377–421) follow the invalid generic signature. | Import the actual generated `P08CounterSchema` module in this file, as the Static counterpart does. Preserve the concrete schema/model equality and rejection assertions. Reassess subsequent diagnostics after the root correction; do not independently rewrite the six outcome comparisons based on these cascades. |

The four trailing-closure warnings, two unused descriptor bindings and two
never-mutated extracted locals are non-failing warnings, not additional root
causes or reason to expand the repair. The log proves only these emitted
diagnostics; later ownership/typechecking/runtime/target failures remain possible.

## Bundle B01/O01 into the same correction

B01 remains blocking at `CounterPipelineOwner.swift:275–284` and
`CounterScopedStorage.swift:1558–1567`: direct bridge mutation occurs between
completed host cycles in SPEC-009 `.idle`. The checked model ownership phase does
not establish SPEC-011:723–744's execution order.

Current-origin retained capture must enter the **actual admitted pointer/seal/
mutation path**, preserving its observed capture identity and immutable original
origin. Reject stale origin before touching current gate/controller/cancellation/
queue/wake/model state. Assert the matching sealed capture, same-cycle action
count and exactly-once model/dispatch effect, followed by the independent
semantic/pixel oracle. The implementer can choose concrete mechanics within the
existing contract; do not restamp origin, substitute another capture, fake context
phase, retain a scoped target/root capability or add a second pending transaction
owner. Keep the relocated single dirty field as the pipeline's sole dirty state.

O01 is targeted coverage strengthening: include application callback,
observation installed/detached, reentrant-rejection and stopped-check counters
in the stale-effect fingerprint or explicit before/after assertions. Existing
producer guards are present; this closes an observation gap without changing
behavior. Necessary internal host forwarding, Dynamic probe import and driver
freshness qualification are within the current P08 activity, beyond the starting
eight-source inventory if needed. Freeze the actual resulting source inventory
before the next assessment; do not rewrite the initial manifest or receipts.

## Affected rerun and dependency freshness

The required corrective rerun is the **failed macOS Dynamic actual-counter cell**,
once after cycle 1's source freeze and independent assessment, with the exact
registered form and successful predecessor paths:

```text
scripts/contracts/run-spec-015.sh --profile macos-dynamic --corpus rfc-014-counter --runtime-build .build/contracts/spec-013-runtime-cycle/tmpi1u8hyk5/macos-dynamic --host-build .build/contracts/p08-scoped-host-ezcy1qan
```

The three passed component cells did **not compile CounterScopedStorage.swift**.
Their drivers explicitly hash it as later selected-source applicability only
(`check-spec-011-owned-keys.py:55–57`, `check-spec-013-runtime-cycle.py:44–46`,
`check-spec-015-scoped-host.py:37–39`), and the recorded command sets confirm this.
Thus correcting this counter-only source does not invalidate their component
execution/module artifacts. Their entire input manifests will no longer be
globally current, which must be stated rather than rewriting those receipts.

`check-spec-015-counter.py:30–40` currently verifies whole-file input hashes;
after correction it will reject the old applicability hash. Add a narrow,
reviewed qualification for the exact **noncompiled applicability source**:
pin the original successful receipt hash, its original source hash, corrected
source hash and proof that its recorded compilation inputs exclude that source.
Preserve all actual compiled-source, artifact, compiler, macro, flags/module and
recipe checks; fail on any unlisted mismatch. Keep the historical r06 map intact.
An explicit new qualification record may be added; never broadly skip inputs,
silently accept mutable current source, or relabel the old receipt as current.
This permits evidence reuse without rerunning unchanged successful cells solely
for a source-applicability hash change. If a repair actually changes one of their
compiled inputs, identify it and rerun only that affected predecessor cell once
within cycle 1, recording the concrete dependency reason before invocation.

The remaining profiles' cells are still their **initial** invocations, not
retries: SPEC-011 → SPEC-013 → native scoped-host where applicable → actual
counter, using actual successful predecessor receipts. Preserve 384/202 compiler
labels, five native exclusivity controls, thirteen route labels per route,
positive-before-negative order and intended diagnostic classification. No new
compiler matrix, exploratory probe or image is required by this diagnosis.
SO-08 images wait for four-profile success; actual layouts/ABI/allocator/nested
stack/IRQ and the historical 58,648-byte failure versus 27,648 ceiling remain
open. No deployment, flashing, hardware, P09–12 work or lifecycle transition.

All diagnosed corrections are existing-contract realization work. Bundle them
as cycle 1; preserve failed evidence and source hashes first, independently
review the correction, and allow at most one affected rerun. The second cycle
and cumulative two-unproductive guard remain bounded; no budget is reset here.
No required correction is deferred, and no new optional deferred idea was found.

Diagnosis checks pass: whitespace; four immutable wrapper manifests, 194 source
hashes, two failure files, three predecessor receipt hashes and seven local
handoff links. Only this handoff and the initial evidence packet are committed;
parent maintains subsequent current navigation and cycle accounting.
