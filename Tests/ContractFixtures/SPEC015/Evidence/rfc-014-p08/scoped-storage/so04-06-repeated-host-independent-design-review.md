# SO-04→06 repeated-host independent Strong design review — 2026-10-14

**Disposition: PASS for a concrete human source-allowance decision only.**
Independent Sol 6.1 High docs/source-read review of the
[handoff](so04-06-repeated-host-design-handoff.md) and
[physical design addendum](../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md#repeated-full-hosts--derived-addendum-2026-10-14)
at `8c1f7ed4`. Input source remains
`369906abf54f6341b0f0287e09d3dfeec28ab005`; prior source review is `5ba87bd0`.
No source edit or compiler/build/formatter/harness/runtime/debugger/IR/image/
target/hardware invocation occurred. No subagents. This review grants no source
or execution allowance and does not close finding 5.

## Contract and lifetime judgment

Accepted ADR-039, approved SPEC-011/013/015 amendments and active owner/shared
plans govern. The feature remains implementing, within ITERATION-003 I3-04/05
counter/four-stack duties and the closed ITERATION-001 analyzer regression
boundary; full RFC-015 delivery remains ITERATION-004 I4-07.

S13.1 permits reuse of initialized physical G/C/R/H only after complete reset,
every old access/callback ends and original roles are restored. S15.1 and
SPEC-015:1336–1372 preserve consuming retirement and terminal failed/quiescent
hosts; fresh complete logical owners must be constructed. The proposed split
of once-per-physical reservation from once-per-host outer construction satisfies
that distinction. Native typed replacement and Embedded deinitialize/initialize
must occur only after the old exclusive scopes end, in the same reserved control
slot. Neither root/model reactivation nor overwriting a live control is selected.

SPEC-009:339–352 explicitly scopes its raw identities to one assembled runtime,
with raw zero first; SPEC-009:1144–1165 similarly scopes submitted source sequences
and requires reassembly on exhaustion. SPEC-010:619–633 scopes registration pairs
to that runtime and expressly says target generations are not cross-runtime
identifiers. SPEC-010:125–130 separately requires model-owner issuance to survive
replacement assemblies; the existing noncopyable issuer implements that rule.
The addendum preserves these different lifetimes. SPEC-015's retirement without
identity reuse forbids reuse in the continuing namespace; it does not override
these explicit fresh-runtime starts.

The selected private origin uses the physical owner's existing identity and
checked session serial (`withStorage`, CounterScopedStorage.swift:1073–1103).
It identifies the actual producer session inside the surviving reservation,
without adding focused identity fields, a global registry, storage lending,
transaction state or a cross-module contract. Reading its active control origin
is allowed only while that original reservation remains live. It cannot validate
a freed pointer and must not be exported as a client capability factory.

The naked raw limit is correct: semantic path/action/target generation and
source/presentation/sequence/ordinal can all collide across fresh runtimes.
SPEC-011:705–736 still requires the four dispatch checks for admitted work;
it supplies no cross-runtime field that could distinguish identical raw bits.
No inspected authoritative clause requires arbitrary old raw bits, deliberately
relabeled through a new current producer, to be distinguishable at that raw API.
The permitted finite claim is original-producer rejection plus ended scoped
capabilities. Restamping an actual old producer or test capture is prohibited.
No RFC/ADR/Spec change is needed for this selected private realization.

## Actual ingress and mint-site dispositions

All paths below are frozen maintained source, not historical Evidence copies.
The design must be realized at these actual seams; a wrapper around the corpus
alone would not satisfy the handoff.

| Actual path | Design disposition and mandatory source-review proof |
| --- | --- |
| CounterAdmission.swift:127–160, both constructors and pointer/state/completion submits | Snapshot immutable origin and owned rejection context at legitimate construction. Each submit compares origin before synchronization/controller access, cancellation, queue writes or wake. Selected mismatch/absent current origin returns existing `.unavailable` with the snapshot, never falls back to owned mode. Owned probes explicitly retain their existing behavior. |
| CounterApplication.swift:62–95, construction → startSource → useCases/source/repository callback | Snapshot origin at actual application construction. Check before any current control access, including the callback's rejection counter, and before minting `CounterAdmission(borrowing:)`. A retained old active application copy must refuse, not merely rely on its normally stopped source/gate. No raw old source value is passed to a fresh application to manufacture this test. |
| CounterHostOwner.swift:153/295 and Dynamic equivalent:120/264 | Coordinators and application owners are constructed inside fresh scoped host state. Install selected origin before these unchanged constructors. Old owner/coordinator/application scopes end before slot replacement; no old host is used after consumption. |
| CounterHostCorpus.swift:91–127, including nested click; CounterWakeIntegration.swift:110–184 | Actual normalized gate/admission and wake corpus run synchronously with the current scoped host. The nested callback is nonescaping; there is no stored callback producer. Retained adversarial input must keep the original adapter/gate observation, and reject before touching the new gate/pointer state. Passing old event bits to a newly minted adapter is not the stale-producer oracle. |
| CounterHostProbe.swift:105–109 and CounterDynamicHostProbe.swift:52–56 | Shutdown refusal checks occur before the old scopes end. Their stopped adapters are not carried into reconstruction. Preserve those tests, and separately retain an actual original adapter for same-address replay. |
| CounterPipelineOwner.swift:208–209, active-cycle injected completion | Mint is inside the live pipeline opportunity; no callback escapes this scope. Preserve the late-admission/no-reentrant-runtime control. The pipeline itself cannot survive reconstruction. |
| CounterScopedStorage.swift:1604–1619, early/failure probes; CounterCoordinatorProbe.swift:24; checker generated coordinator at line 199 | Selected holder probes end before reconstruction; ordinary owned coordinator and compiler fixtures remain compatibility routes. No retained old pointer caller may acquire current origin from a pointer alone. Generated trusted source retains the full carrier unions. |
| CounterPipelineOwner.swift:226–252/278–300, gesture capture → sealed action → dispatch | Production capture/dispatch is host-local and ends with the pipeline. Retained adversarial observation must be made from the actual first-host capture with immutable origin then, not by wrapping raw bits later. Its closed delivery seam rejects before dispatch; the actual second-host twin enters the unchanged bridge in mutation phase and performs all four focused checks. |
| CounterApplication.swift:97–110; CounterHostControl and CounterWakeIntegration.swift:69–103 | Existing stop/detach/quiesce, owned pointer-free requester and scoped host scheduling drain before replacement. Do not retain old wake/control bindings. Source review must also show retained stale test producers cannot use auxiliary application control-touching operations to modify the new pointee. Cleanup clears selected ingress after drain; rejection never repairs or cancels new state. |

This is the complete inspected finite mint/delivery set. It demonstrates that
the two extra ingress files are necessary; none of the unchanged synchronous
helpers requires its own new contract or source seam. If implementation finds
another unavoidable retained ingress, stop and document it rather than expand
the whitelist. Source review must inspect actual copies, callbacks and auxiliary
operations, not infer safety from a new model owner or from a passing label.

## Whitelist and corpus judgment

The exact five-file proposal is adequate: CounterScopedStorage owns physical/
logical reconstruction and corpus; CounterPipelineOwner declares CounterControl
and the real capture/dispatch seam; CounterAdmission owns the copyable adapter;
CounterApplication owns the callback that otherwise launders origin by minting;
check-spec-015-counter.py owns route/label registration. No demonstrated seam
requires a root adapter, focused module, host owner, wake, graph, firmware/C
constant, route recipe or resource-limit change. This is source-design sufficiency,
not compiler feasibility or numerical fit.

The thirteen suffixes per route are adequate and total 26 logical labels:
inventory-two-hosts, control-same-address, terminal-old-host,
raw-namespace-collision, four stale/current pairs (action, input, admission,
source), and cleanup-backing-last. Static and Dynamic use actual preset chains;
Embedded registration remains distinct from execution. Admission labels must
cover all three submit categories. The source labels must identify matching
oracles in the unchanged driver invocation, not be unconditional receipt strings.

The collision oracle must observe actual first-publication/initial-input raw
collisions with identical paths/source IDs and the same live control address.
Each stale/current pair must prove zero new-runtime effects versus real current
admission/dispatch, retaining the existing independent semantic/action/pixel
checks. Terminal rejection occurs before old scoped consumption; existing
compiler negatives prove escape rejection separately. Preserve every earlier
failure/early-return/activation/offer case, 384 non-Embedded/202 Embedded scoped
compiler labels, positive-before-negative order and five Native exclusivity
controls. No new compiler label or invocation is approved.

All origin snapshots, retained observations, reconstruction temporaries and
helper frames enter the 26-family ledger. Original inventory initializes and
finally destroys once; control/outer destruction is separately counted per host.
Static padding/stack/zero heap and Dynamic allocation peaks remain measured
obligations. The 58,648-byte versus 27,648 limit stays a historical failure.

## Decision, checks and stop accounting

No design blocker remains for requesting exactly one source-only pass over the
five named files, one freeze/commit, then independent Sol 6.1 High Strong SOURCE
review, with zero automatic follow-up repairs. That is a concrete human decision
still to be made. Compiler/formatter/build/harness/runtime/IR/debugger/image/
target/hardware allowances remain zero. A later execution proposal is separate.

Correction **1/1 consumed**, further repairs0, next source allowance0. Findings
1–4 remain source-corrected/unexecuted; finding5, IN/RP/HC-SO-001–003, all fit/
P08/R07/T8.1/HC-RD-003/SO-07–09/I4-07/P09–P12 and lifecycle gates stay open.
Historical freezes/receipts/counters and cumulative guard remain unchanged.
Required finding5 correctness is not deferred; no new deferred idea was found.

Permitted documentation consistency checks and this separate docs commit are
recorded in the [current receipt](../progress.md). They establish no source,
compiler, runtime, platform or conformance result.
