# P08 integrated independent Strong SOURCE review — 2026-10-14

**Disposition: source readiness FAIL; correct B01 before the initial matrix.**
Independent Sol 6.1 High review of frozen `e2d9db9c`, diff from `369906ab`,
under the [current broader activity](p08-integrated-activity.md). The tree was
clean at entry. The [eight-source/26-label manifest](p08-integrated-source-manifest.json)
and [initial freeze](p08-integrated-source-freeze.md) identify the candidate.
No source fix, compiler, formatter, build, driver, runtime, target, debugger,
IR, image or hardware invocation; no subagents. Source inspection and permitted
documentation checks only. This is an implementation-readiness review, not full
Specification conformance or measured resource/fit evidence.

Accepted ADR-039, approved S11.1–4/S13.1–2/S15.1–2, existing SPEC-011 dispatch
ordering and active shared/owner plans govern. The
[reviewed realization](so04-06-repeated-host-design-handoff.md) and
[independent design review](so04-06-repeated-host-independent-design-review.md)
at `f89ff220` are derived inputs. SPEC-011/013/015 remain implementing;
ITERATION-003 I3-04/05 requires the actual finite counter/four-profile composition,
with ITERATION-001 analyzer/stack regression obligations preserved. Full RFC-015
delivery remains ITERATION-004 I4-07. Conformance-reviewer, implementation-executor
and deferred-work-curator rules were read/applied within this source-only slice.

## Finding B01 — blocking: current action dispatch bypasses execution ordering

`CounterPipelineOwner.swift:275–284` checks the original producer and directly
calls `RuntimeRecordInteractionBridge.dispatch`, mutates the actual model and
increments applied/dirty/wake state. `CounterScopedStorage.swift:1558–1567` calls
that method after a completed pointer cycle and before the next `runOpportunity`.
`CounterPipelineOwner.swift:565–575` has already returned the execution phase to
`.idle`. The subsequent cycle derives the already-mutated value; it does not
admit, seal or apply this retained action.

SPEC-011:723–744 requires final revalidation in **SPEC-009 `.mutating`**,
ordered after admitted state/completion facts, with synchronous reporting.
The separate Observable Model ownership phase permits the checked write but does
not establish the execution phase or admission order. The unchanged bridge still
performs its four focused checks; those checks alone do not satisfy this ordering.
The design review explicitly required the current twin to enter the unchanged
bridge in mutation phase. Therefore `action-current` cannot qualify the intended
actual-host oracle even if its later semantic/pixel result were to pass.

**Minimal correction invariant:** retain immutable original origin, reject stale
origin before current state access/effects, and route an accepted owned capture
through the existing admitted/sealed action and `.mutating` dispatch path.
The current twin must demonstrate one sealed action and exactly one bridge/model
effect in that path, followed by independent semantic/pixel checks. Do not repair
this by merely changing the exposed context, restamping the old capture, or adding
a second transaction/dirty state machine. Necessary internal forwarding/test edits
are within the broader activity; this is a local contract-preserving repair, not
an upstream architecture decision or a new per-file permission gate.

## Observation O01 — non-blocking source safety, strengthen the effect oracle

`CounterScopedStorage.swift:1472–1510` fingerprints admission, pointer, scheduler,
wake, semantic, dirty and dispatch state. Its `CounterJoinSnapshot`
(`CounterHostProbe.swift:143–165`) includes application construction but omits
`applicationCallbacks`, `observationsInstalled`, `observationsDetached`,
`reentrantApplicationRejections` and `stoppedApplicationChecks`.
The stale application's projection/service/start/install/stop batch at
`CounterScopedStorage.swift:1541–1547` compares that fingerprint only.
`CounterApplication.swift:77,93,97,115,123` identifies the omitted control effects.

The actual immutable-origin guards at `CounterApplication.swift:68,74,81,91,101,110`
are correct by source inspection, so this is not a demonstrated stale mutation.
The immediate zero-effects assertion nevertheless fails to inspect all effects
of those operations. Include these bounded counters in the stale fingerprint
or explicit before/after assertions during the B01 correction. This is targeted
coverage strengthening within P08, not optional future scope.

## Remaining inspected source dispositions

| Area | Source disposition; execution remains unproved |
| --- | --- |
| Actual producer guards | Both admission constructors snapshot origin/context; all three submits guard before synchronization/controller/cancellation/queue/wake access (`CounterAdmission.swift:140–163`). Pointer/controller/synchronization stay private. Application construction, callback and every auxiliary control-touching operation capture/check origin before fresh adapter minting. Selected retirement retains selected mode with nil active origin, preventing fallback to ordinary owned mode. |
| Capture and forwarding | `CounterProducedAction` constructor/origin fields are file-private; capture is created from the actual gesture resolver at `CounterPipelineOwner.swift:265–272`. Host/state forwarding returns owned facts or performs a closed operation; no scoped geometry/bank/root getter or dispatch-capability factory is added. Original capture is retained before first-host teardown, never wrapped/restamped later. B01 concerns current delivery ordering. |
| Repeated complete hosts | Static and Dynamic sessions reuse one original initialized inventory and control address (`CounterScopedStorage.swift:1914–1938,2038–2062`). Persistent issuers produce fresh model/semantic identities. Terminal old hosts reject activation/opportunities before scope consumption. Replacement root/semantic/Canvas/control construction occurs after the prior nested host scopes return (`1617–1623,1962–1969`); terminal logical owners are destroyed rather than resurrected. |
| Raw collision and corpus | Actual captured identity/action/target generation, semantic revision and source/presentation/sequence/ordinal collisions are asserted before stale ingress (`1519–1526`). Thirteen conditional labels per route correspond to the actual reuse corpus and final cleanup checks; labels are registered exactly once per native route by the driver. Current input/admission/source twins traverse real normalized/sealed admission or actual source→repository→callback paths. B01 blocks action-current; O01 narrows source-stale observation completeness. |
| Single state and cleanup | Dirty state is relocated once to runtime control with a computed pipeline view; no second dirty flag. Session/private typed borrows and complete lifetime unions are preserved. Holder finish consumes scoped carriers and performs ordered reset before origin retirement; factory release destroys original inventory once and finishReservation avoids a second release. Actual exclusivity, Optional projections, complete unwind and backing-last behavior still need matrix evidence. |
| Reused prior findings 1–4 | The corrected Embedded limits assignment, inert cleanup distinction, padded/native borrow separation and actual active/retired carrier matrix remain in source. No regression found in the bounded diff. Diagnostic classification, positive twins and actual runtime enforcement remain unexecuted. |
| Driver identities | `check-spec-015-counter.py:30–40` accepts exact-current source hashes first; old correction-map fallback still checks both pinned recipe and reviewed rebuilt hashes. Existing artifact/compiler/macro verification remains. No historical receipt/hash is rewritten or bypassed by this diff. Registered 384 non-Embedded/202 Embedded compiler labels and five Native exclusivity controls are preserved; cross-target route labels are registration, not execution. |
| Resource accounting | Concrete control/coordinator layouts include the new origin/context and single dirty field. The freeze names retained producer copies, fingerprints, scheduler copies, read helpers and reconstruction frames. Symbolic attribution is not actual target layout, allocator, nested stack/IRQ or fit proof. These duties remain mandatory during the predefined matrix/images and exit review. |

No further blocker was found in this bounded source review. Prior finding 5 now
has the full repeated-host realization; its current-action contract proof remains
incomplete because of B01. It is not fully closed by source inspection.

## Correction handoff, checks and unchanged gates

Current corrective cycles **0/2 consumed**; this independent review consumes
none. Matrix/image cells **0 consumed**, compiler/runtime invocations **0**.
Bundle B01 and O01 into one cause-based correction, freeze it and obtain an
independent Strong assessment before initial validation. Parent owns cycle count
and the cumulative two-unproductive-corrections guard. The current broader user
authorization permits that correction autonomously; historical closed allowances
are unchanged. No per-file/source-only permission request is required.

No new optional deferred idea was found. B01 and its targeted O01 coverage belong
to current correctness and are not deferred. All nine SO criteria, HC-RD-003,
P08/R07/T8.1, the historical **58,648-byte failure** and unchanged **27,648-byte
main-stack ceiling** remain open. I4-07/P09–12, hardware, timing and lifecycle
transition duties remain separate. After independent correction readiness,
proceed with the predefined initial matrix; no full conformance or fit claim.

Permitted checks and this separate documentation commit are recorded in the
[current receipt](../progress.md). They establish documentation/source identity
consistency only, never compiler/runtime/resource acceptance.
