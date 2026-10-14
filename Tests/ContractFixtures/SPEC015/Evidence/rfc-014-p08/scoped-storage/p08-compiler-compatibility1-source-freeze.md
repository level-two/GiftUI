# P08 compiler compatibility candidate 1 freeze — 2026-10-14

Input `c1339c16`; source baseline `8ef34f59`. Under the
[user-authorized activity](p08-compiler-compatibility1-activity.md), one candidate
is frozen for independent Strong review; invocation0/1 and automatic repairs0.
Historical cycles2/2 stay consumed. No compiler/runtime/fit result is claimed.
The [final crash packet](integrated-cycle2-counter/manifest.json) remains unchanged;
aggregate capture is a source-backed suspect, not a proven compiler-bug diagnosis.

| Affected callback | Capture-shape correction; live checks preserved |
| --- | --- |
| p08CounterGraph selected callback, nested reject/assertions | Project the existing Copyable typed control pointer locally. Every negative and positive assertion rereads its actual pointee; no-effect state is not snapshotted or replaced with constant facts. Audit and all graph masks/cases/observation counts remain unchanged. |
| runP08StaticHost foreign/model/semantic/Canvas/session callbacks | Project existing typed root/semantic/Canvas/control pointers, buffer descriptors and owned limits before nesting; directly borrow outer only for audit. Nested callbacks retain their exact supplied/scoped inputs and use the same original initialized fields/counts. |
| runP08DynamicHost analogous lifetime callbacks | Same projection for its existing typed pointers/limits, within the same synchronous selected reservation. No owned workspace/bank copy is introduced. |
| Static and Dynamic full-host reuse callbacks | Enclose selected reservation with the transcript pointer scope, rather than capturing borrowed outer in a nested transcript closure. Outer audit/run/reconstruct calls remain direct borrowed operations; control assertion autoclosures use the local pointer. |

All projected facts remain function/callback locals inside the original
synchronous physical reservation. Helpers return only existing owned counts;
no pointer/scoped capability is externally returned, no escaping callback or new
generic escapable wrapper is added, and no storage declaration/lifetime union is
relaxed. The two repeated-host transcripts explicitly clear every retained
capture/event/admission/application/revision Optional **before owner.release**.
Those values have no custom destructor, deferred callback, scoped root/target or
cleanup action; their raw pointer fields are inert facts. After release only empty
optionals and the host-count scalar survive to transcript-scope return. Live old/
current guards, two-host counts and original reverse destruction checks are intact.
Owned pointer/buffer/limit locals, enclosing transcript scope and changed closure
contexts still require actual family24/nested-frame attribution; no fit follows.

[New source manifest](p08-compiler-compatibility1-source-manifest.json) freezes
nine current integrated files/two changed paths, the new
[exact qualification](p08-compiler-compatibility1-applicability.json) and immutable
crash-manifest hash. Driver selects this named activity's qualification and records
its use. Same three original successful receipt hashes, original source hashes and
112/173/53 conservative recorded Swift argv-path hashes are required; only the
exact corrected CounterScopedStorage hash changes. All other input/artifact/
compiler/macro/flags/recipe checks and historical r06 fallback remain. Frozen
cycle2 qualification/receipt/manifest are untouched; original whole-source
applicability manifests remain historical. Passed components are not rerun.

Exact 384/202 compiler controls, five Native controls and 13 labels/route (26)
remain unchanged, positive twins first. Independent Strong assessment must check
original reservation/lifetime obligations and all live effects/oracles before the
parent's one registered invocation. No automatic follow-up correction is available.
Permitted consistency checks pass: nine source hashes/two changed paths, exact
qualification/three receipts and 112/173/53 recorded paths, six crash-file hashes,
26 labels, driver AST without invocation, seven local links and whitespace. No
compiler, formatter, build, harness, runtime, IR/probe or agents in this pass.
