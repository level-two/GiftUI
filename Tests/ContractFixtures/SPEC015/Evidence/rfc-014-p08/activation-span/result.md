# P08 retained activation span — finite FAIL, 2026-10-12

**Direct span primitive passes; actual retained-span owner fails callback
containment. Stopped at6/8 compiler calls. No maintained adoption or accepted
negative execution occurred.** Strong Astra6 Medium, sequential, under the
committed [scope](scope.md). Earlier failed benches and their closed budgets
remain unchanged.

## Exact finite result

| Run | Control | Outcome |
| --- | --- | --- |
|1|Direct safe InlineArray.span in callback, reachable positive main|Compile/link/execute PASS.|
|2|Direct span captured and read after callback, reachable main|Rejects for lifetime dependence on callback-local marker at callback return.|
|3|Actual owner with span physically retained in both enum states|Compile/link/execute PASS for activation, actual accepted runtime opportunity and quiescence.|
|4|Reachable actual active-owner callback escape|Compiles/links; never executed. FAIL containment.|
|5|Same actual owner, adding only copied-self lifetime annotations to its three mutating methods|Compile/link/execute PASS.|
|6|Same reachable escape with annotated methods|Compiles/links; never executed. FAIL containment; candidate stopped.|

The direct primitive checkpoint was committed as `eb89bd2d`. Its marker byte
comes from the actual command-line argument count; explicit noinline callback
and read functions keep a concrete reachable boundary. Run2's diagnostic names
`escaped`, its dependence on local `marker`, and callback return as the escape.

The actual owner retains `Span<UInt8>` as a second payload in **both** inert and
active cases. Every consuming state reconstruction forwards that exact span.
A noinline helper reads it before activation and runtime operations. Actual
backing remains the nested model/root, semantic, Canvas, geometry and control
scopes. The marker is created inside the innermost callback through the standard
library safe InlineArray.span projection. No unsafe lifetime override exists.

The actual marker byte derives from initial control teardown count, unlike the
direct primitive's runtime argument. Constant promotion, callback inlining or
other dependence behavior could matter, but no cause is established by these
runs. An opaque seed, mutable marker or altered callback boundary was not tested.

The sole correction between runs3/4 and5/6 is
`@_lifetime(self: copy self)` on activate, runOpportunity and quiesce. The pinned
standard library uses this checked self-result lifetime form on mutating spans
(e.g. MutableSpan.swapAt); no compiler feature was added. Its acceptance in
run5 and failure to reject run6 do not establish a compiler defect or general
failure of copied-self dependence.

The parent directed an immediate finite stop if the corrected callback negative
was still accepted. Therefore the prepared copy and [local-profile expiry](BackingNegative.swift)
controls were not compiled for this candidate. Two unused numerical calls do
not reopen that stop. No complete ownership/lifetime pattern is verified.

## Runtime and evidence boundary

The actual positive uses the real CyclePipelineOwner, endpoint, binding,
admission and StaticRuntimeExecutionCoordinator. Their construction first occurs
inside activate. Run3 and run5 both execute a full accepted runtime cycle and
synchronous quiescence within all supplying scopes; complete traces and binary
hashes are in [execution-3](execution-3/result.json) and
[execution-5](execution-5/result.json). Run1's primitive output is in
[execution-1](execution-1/result.json). Each binary was executed once.

The actual negative's reachable main constructs a real profile and invokes a
method which captures an **active** owner outside every supplying callback,
then invokes its actual opportunity and quiescence methods. Both accepted
negative executables remain unexecuted. They are not evidence of safe runtime
behavior.

All18 original P07 fixture sources compile unchanged. The overloads stay in
same-module [extensions](FixtureInitializers.swift); existing constructor
signatures remain. The scope marker is test-internal and not a new public role.
No host/controller conformance, nine-stage validation, full P08 completion,
platform or hardware result is claimed. Those boundaries remain open.

[ledger.json](ledger.json) contains all reservations and manual dispositions.
Each run retains its exact command, source snapshots, complete diagnostics,
compiler/source/link-object hashes and immutable raw receipt. Compiler and
schema inputs/artifacts were checked before each call; actual integrated runs
also verified runtime inputs/artifacts. [manifest.json](manifest.json) covers
this frozen evidence. No historical file was rewritten.

Next: independent Strong review of this finite failure. Any further correction
must be separately bounded under the maintainer's resolution request; neither
a direct primitive pass nor unused calls authorize adopting this failed owner.
