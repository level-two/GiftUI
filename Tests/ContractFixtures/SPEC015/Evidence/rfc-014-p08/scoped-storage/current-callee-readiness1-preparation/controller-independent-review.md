# Independent Strong controller readiness review — 2026-10-19

Verdict: **PASS for one bounded current-callee collection launch**. Reviewed
environment commit `9435d83f` and controller commit
`1dae998fec2a1ebe4da1996781559627d01fe94f` independently by reading code, inputs,
Git blobs and file hashes. No controller, compiler, build, test, decoder,
counter/schema4/P07 or application runtime was launched. The earlier
[applicability PASS](independent-review.md) remains bounded; its B1/B2 are closed
by this packet. No blocking finding remains for this collection.

## B1: authenticated one-shot controller

- External full commit/repository-tree/packet-tree pins govern HEAD and exact
  flat packet membership/bytes. Git object payloads are checked against their
  IDs. Controller code is loaded from authenticated Git blobs; the interpreter
  body is hash-checked once and passed as code. No workspace module or bytecode
  import supplies collection code. The absolute isolated Xcode Python and exact
  env-i bootstrap are enforced. Read-only Git disables external execution and
  rejects includes. Installed Apple system tools/runtime are the explicit trust
  boundary; this is not an OS-image attestation.
- The canonical existing lock is opened without following a symlink and locked
  exclusively, then inputs are reauthenticated. Exclusive permanent output mkdir
  consumes the collection before work. Parent/launch records are fsynced.
  One detached worker inherits the same lock descriptor and permanently claims
  ownership; every child has its own exclusive claim and inherits the lock.
  Worker/marker/lock identities and complete inputs are checked at each
  production boundary. Replay cannot acquire a second worker claim or overwrite
  an existing worker terminal through the controller.
- Direct raw files, actual `Popen.wait()` exits, hashes, claims and atomic
  start/exit/progress/terminal records retain failure evidence. A started child
  is reaped even if start-record writing fails. Spawn failures retain consumed
  claims and null actual exits. Termination prevents later children. Missing
  terminal, lost host or killed worker remains unknown/incomplete and consumed;
  no continuation, retry, repair or synthesized PASS is available.
- The 93 original classifiers retain positive exit-zero/no-error checks and
  negative nonzero-exit/exact text or regex/count checks, unchanged from the old
  qualification runner. All independent controls may collect after a failure;
  any failed control blocks SIL. Eleven complete serialized indexes preserve
  schema/count/hash/offset/raw-prefix checks. All 91 mangled and one demangled
  body identities require unique, serialized, body-positive matches. Fifty
  matching-object captures must pass. Only then may the sole 42-source SIL
  invocation run; it requires actual exit zero and regular nonempty output.
- Budget verification and permanent compiler claims enforce **at most 94
  swiftc invocations**: 93 fixed privacy commands and at most one SIL command.
  The recipe reconstructs those argv from retained command 18 and the original
  privacy packet. Child names are unique and finite. Collection remains **0/1**,
  source candidates **0**, automatic source/tooling repairs **0**, retries **0**.

## B2: complete environment and loader authentication

Independently rehashed **388 direct inputs**, **541 inherited source hashes**,
the exact **548-file discovery inventory**, all **ten selected inherited trees**,
**1,407 current import entries**, **8,578 loader entries across seven roots**,
**1,062 loader aliases** and **34 decoder-library entries**, including complete
membership. All match. Both inherited Swift tool links match their authenticated
link manifest. Resolved loader endpoints stay inside the inventoried roots.

The three previously missing framework roots are now frozen completely.
Every Popen receives its complete reviewed environment dictionary. Ambient
startup/Python/Git/Swift/loader variables are excluded; interpreter-added values
are exact. Explicit fallback paths are system-only, excluding HOME defaults.
Compiler/macro, decoder and interpreter/demangler environments have distinct
reviewed purposes. No unpinned developer/user loader root remains in the recipe.

All five preexisting dirty files still match their preserved hashes and remain
outside the adopted producer/source operands. Their exact diff is preserved;
the existing untracked Python cache is excluded by isolated Python startup.
No production file is included in this review commit. Packet Git bytes match
the reviewed implementation commit before these review/navigation additions.

## Exact clearance and remaining gates

Execute **once only** the env-i Git-blob-to-isolated-Python bootstrap form in
[CONTROLLER.md](CONTROLLER.md), from the repository root, substituting the
independent reviewer's full final commit/tree/packet-tree pins supplied after
this review commit. Those pins cover this verdict/navigation plus unchanged
reviewed controller, recipe and environment bytes. Do not discover replacement
pins at launch, invoke a workspace script directly, or relaunch to poll. The
output marker is absent at review; any later presence consumes the allowance.

No source/code correction is required. A changed input, HEAD/tree, environment,
failed preflight or failed collection supplies no automatic repair/retry/reset.
After a successful bootstrap, use read-only receipts/raw-stream polling only.
Even a collection PASS still requires complete independent current-callee and
safety interpretation before strict-cold preparation. All nine still-unmet SO
criteria, resource/ABI/zero-heap/four-profile gates, P08/R07/T8.1, conformance,
I4-07 and P09–P12 retain their actual open dispositions. No architectural,
contract, resource-limit or lifecycle approval is granted by this review.
