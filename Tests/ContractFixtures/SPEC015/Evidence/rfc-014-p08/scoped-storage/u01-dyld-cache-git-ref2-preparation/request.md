# Proposed exact smart-HTTPS Git ref read

## Provenance and question

Use only `https://github.com/apple-oss-distributions/distribution-macOS.git`.
The earlier [retained metadata packet](../u01-dyld-cache-schema-source1-preparation/README.md)
identifies the Apple distribution repository and retains API tag/commit records
from that exact repository. The HTTPS Git remote is the same Apple-maintained
repository through a distinct protocol endpoint. Its ref advertisement would
be first-party publication metadata, not a claim that the advertised source
built the installed binary. TLS verifies the transport endpoint; a Git object
ID identifies content and does not attest a build.

The exact candidate is `refs/tags/macos-2662`; include only its possible peeled
advertisement `refs/tags/macos-2662^{}`. Both spellings are fixed in
[request.json](request.json). The spelling is inferred from retained names such
as `macos-265` and `macos-264`, not from any retained 26.6.2 release/build record.
No `main`, neighboring tag, page, broad search or alternate spelling is allowed.
This is a new separately reviewed protocol route; do not replay the consumed
GitHub API `/git/ref/tags/macos-2662` GET or wait for its rate limit to reset.

## Proposed operations and limits

One `git ls-remote --exit-code --tags` process with the exact argv in
`request.json`, protocol v2 requested, redirect following disabled, TLS
verification enabled, and no credentials, cookies, extra HTTP headers or prompts.
The command is declared, not executed. The expected smart-HTTPS exchange is:

1. GET `https://github.com/apple-oss-distributions/distribution-macOS.git/info/refs?service=git-upload-pack`
   for protocol v2 capability discovery.
2. POST `https://github.com/apple-oss-distributions/distribution-macOS.git/git-upload-pack`
   for `ls-refs` with the candidate ref prefix. No `fetch` command, packfile,
   clone, tree, commit/tag object body, submodule or source read is allowed.

There may be fewer requests on failure. Maximum accepted is two logical HTTP
requests, 1,048,576 aggregate HTTP response-body bytes and 30 seconds wall time;
retries zero. Protocol v0/v1 fallback, auth challenge/retry, redirect,
additional logical request, excess bytes or missing/incomplete receipts is STOP.
An exact ref-prefix can also advertise similarly prefixed names; accept only
the two declared exact names and treat any other advertised ref as STOP.

**Unresolved execution-envelope prerequisite:** Git's `http.maxRequests=1`
limits concurrency, not total requests. Bare `ls-remote` offers no hard total
transfer-byte cap and may perform protocol negotiation before a wrapper can
inspect it. The two-request/1-MiB limits above are acceptance ceilings, not a
claim of hard wire enforcement. Before launch, independent readiness review
must require a concrete envelope with enforceable bounds or explicitly return
STOP for this proposal. Do not convert observation of an overrun into a pass.
Do not add proxy/tool/controller operations or relax limits without a revised
bounded preparation and review. This packet clears no execution.

## Environment, receipts and destinations

Any future reviewed launcher must start from the repository root and use a new
result directory
`Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/u01-dyld-cache-git-ref2-result/`.
Replace literal `RESULT` in the pinned argv only with that absolute directory.
Create its empty `empty-git-context/` directory exclusively and run Git with
`-C` there so repository config cannot rewrite the remote. Supply a clean,
explicit environment, disable global/system Git config, prompts, askpass,
credential managers and tracing inherited from the caller, and disallow proxy
or URL rewriting configuration. Record the Git executable/version/hash and
final argv/environment policy before launch. This is metadata tooling, not a
target execution allowance.

Retain original stdout, stderr, complete raw Git curl trace and packet trace as
`ls-remote.stdout`, `ls-remote.stderr`, `git-curl.trace`, `git-packet.trace`.
Enable only launcher-selected `GIT_TRACE_CURL` (with data enabled) and
`GIT_TRACE_PACKET`; keep authentication absent. Trace files are raw trace
receipts, not raw binary HTTP response bodies or cryptographic attestations.
The final execution envelope must specify how aggregate body-byte/request
accounting is derived without confusing trace-format overhead with wire bytes.
Retain a launch receipt, monotonic start/end/timeout, actual exit/signal,
per-stream sizes/SHA-256, request/status/protocol accounting, exact ref records
and any partial files on failure. Retained streams must each be capped at
1 MiB and truncation must fail. A supervising process must enforce the
30-second wall limit and terminate the entire child process group on any stop.
No execution/receipt is fabricated in this preparation.

## Interpretation boundary and stops

Stop after the one session and retained result, including a successful exact
ref advertisement. Exit 2/no match is an observation about this exact candidate
at this time; it does not prove that Apple published no corresponding source.
Nonzero exit, timeout, malformed/duplicate/inconsistent ref records, unexpected
hash format, protocol fallback, failure status or any bound violation is STOP.
No automatic repair, retry, second session, ref spelling or fallback follows.

A successful advertisement may identify a candidate tag/object ID; it does
not establish the release spelling's meaning, macOS 26.6.2 **build 25G83**, the
distribution tree's dyld gitlink/source revision, or their applicability to
shared-cache UUID `f2e86c53-6052-388b-ba71-5a0c9b569413`. The missing chain is:
official exact version/build association → immutable distribution revision →
dyld source revision → exact source schema and cache applicability. Every
missing link remains unproved. No returned object may be followed in this
session, and no header candidate/field offset may be selected from its result.

No cache parser, source/header acquisition, binary extraction/acquisition,
controller/dyld inspection, target runtime/compiler/build/test or repair is
authorized. Preserve the five dirty files/cache and all three consumed P08
markers. The current STOP/open gates in the README remain binding. Any actual
warm-up, heap/ownership/privacy/bound/scope decision goes to Astra Medium.
