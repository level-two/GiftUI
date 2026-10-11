# P08 callback token correction — finite FAIL, 2026-10-11

**The callback-local token hypothesis fails compiler containment. Stopped at7/8
compiler calls. No maintained-source adoption, additional control, or negative
execution occurred.** Strong Astra6 Medium, sequential, under the committed
[scope](scope.md). Prior activation-resolution12/12 and historical2/2 guards
remain unchanged.

## Recorded outcomes

| Run | Control | Outcome |
| --- | --- | --- |
|1|Positive link with empty noncopyable token|Setup failure: test-only enum getter attempts consumption of borrowed self. No lifetime conclusion.|
|2|Same positive, actual-control assertions replace getter|Compile/link and actual runtime execution PASS.|
|3|Copy negative with run2 candidate|Rejects explicit noncopyable owner copy.|
|4|Active owner used after callbacks, internal uncalled negative|Compiles; never executed. Not sufficient to distinguish dead-code pruning.|
|5|Same callback negative with reachable `@main` constructing actual profile and invoking it|Compiles/links; never executed. Excludes absence of reachable caller as explanation for accepted escape.|
|6|Positive with observable nontrivial token destructor|Compile/link/execute PASS, including actual opportunity, accepted endpoint rendering, quiescence and exactly one token destruction after callback.|
|7|Reachable callback negative with same nontrivial token|**Compiles/links; never executed. FAIL required containment.**|

Run5 narrows away the dead-code explanation, so the same token hypothesis was
allowed its nontrivial-destructor correction within the original8-call limit.
Run7 ends that candidate immediately under the assigning agent's explicit stop:
an unused eighth call cannot cure accepted callback escape. The prepared
[local-profile negative](BackingNegative.swift) and its [driver](BackingMain.swift)
were not compiled. Copy rejection was tested for the empty-token candidate only;
it is not presented as a fresh final-candidate negative. No full pattern passes.

## Candidate boundary

The token is created inside the actual control-pointer callback, itself nested
inside the actual model/root, semantic, Canvas and geometry supplying scopes.
`InvestigationControl` borrows the token and pointer; supplied state and two
fixture constructor overloads declare copied lifetime dependence through it.
Generic supplied storage and existing enum inert/active state are preserved.
Actual coordinator and endpoint are first constructed by `activate()`.

For run6/7, the noncopyable token destructor increments the existing test-only
`CycleControl.idleQuiesceMode` byte. This is an observable lifetime marker, not an
owner retirement, quiescence, runtime rejection or substitute for compiler
containment. Positive execution checks it equals1 after callbacks return. The
negative leaves an active owner beyond all callbacks and then calls its actual
opportunity method; it does not merely return a quiesced shell. Its reachable
`@main` makes construction and postcallback use part of the linked executable.
Neither accepted negative executable was run.

The [initializer overloads](FixtureInitializers.swift) now live in same-module
extensions. All18 original P07 test source files remain unchanged; no overlay
replaces them, no module contract or compiler configuration changes. This proves
that the extension organization compiles, not that the unsafe candidate is
adoptable. Token construction is module-internal in evidence only; any eventual
maintained implementation must hide trusted construction at its callback boundary.

The result does not establish why the compiler accepts the escape. In particular,
nontrivial destruction is not sufficient in this source. Possible loss/refinement
of a declared dependency through raw-pointer projection remains an unproved
implementation question. No compiler bug or contract impossibility is claimed.

## Execution and identities

[execution](execution/result.json) retains the run2 binary's complete actual
runtime trace and output (a second identical execution captured durable output;
the initial execution also returned0). [execution-6](execution-6/result.json)
retains the one run6 execution, including executable/output SHA256 values.
Both positives exercise one accepted actual runtime cycle and synchronous
teardown, with five caller checks, coordinator-quiescent check and main count
check; run6 adds the destructor-count check. These are mechanism tests, not
nine-stage host validation, generic host/controller conformance or P08 completion.

Every compiler call has a command, exact source snapshots, complete diagnostics,
source/compiler/link-object hashes and an immutable raw receipt. The final
[ledger](ledger.json) carries manual dispositions and closes the allowance.
All consumed schema/runtime source and artifact identities were checked against
existing receipts before each call. A pre-run2 attempt stopped before compiler
reservation because a concurrent optional checker edit changed its hash. The
parent restored that script exactly; no exception or source rebaselining was used.
Its observed [snapshot](checker-concurrent-edit.txt) is retained only as provenance.

Independent Strong review is next. Any further work needs a separately bounded
assignment under the maintainer's resolution instruction; this failed candidate
and its unused eighth call provide no continuation or implementation authority.
