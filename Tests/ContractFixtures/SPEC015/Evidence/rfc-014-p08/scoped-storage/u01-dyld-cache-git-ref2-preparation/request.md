# Revised exact Git candidate-ref request — 2026-10-19

**Preparation only; readiness NOT READY pending independent review.**
The concrete [controller](controller.py), [enforcement explanation](controller-preparation.md),
[runtime lock](runtime-lock.json) and [exact invocation/pins](request.json)
replace the bare-Git proposal in `8250f8ec`. The B01/B02 STOP review in `0625592a`
remains historical evidence. This revision proposes their resolution, without
claiming independent acceptance or launch permission. The controller has never
been imported/executed; no network operation occurred.

## Fixed origin and operations

The sole repository is Apple's already identified
`https://github.com/apple-oss-distributions/distribution-macOS.git`.
Retained API metadata supports that repository identity. Candidate spelling
`refs/tags/macos-2662` remains inferred from retained release names; existence,
release meaning, 26.6.2/build 25G83 and cache applicability are unknown.

1. One GET to
   `https://github.com/apple-oss-distributions/distribution-macOS.git/info/refs?service=git-upload-pack`,
   with `Git-Protocol: version=2`, for capability discovery.
2. Only after valid v2 capabilities, at most one POST to
   `https://github.com/apple-oss-distributions/distribution-macOS.git/git-upload-pack`
   with `Content-Type: application/x-git-upload-pack-request` and the exact
   contiguous 96-byte packet body pinned as ASCII and hex in request.json:

```text
0014command=ls-refs\n0017object-format=sha1\n00010009peel\n0024ref-prefix refs/tags/macos-2662\n0000
```

Here `\n` represents a literal LF. Data length prefixes include four hex digits
and the LF. `0001` separates command capabilities from arguments; `0000` ends
this request. No agent, symrefs, unborn, fetch, want/have, object ID, pack, clone
or broad prefix is sent. The prefix can match similarly named refs; any such
response is STOP. Fixed request headers are constructed by `request_bytes`:
Host github.com, Git-Protocol version=2, exact response media type, identity
encoding, Connection close and fixed User-Agent, plus POST type/length only.

The capability parser requires `version 2`, unique printable capability lines,
`ls-refs` and explicit `object-format=sha1`. It rejects unknown ls-refs arguments.
An optional exact smart-HTTP `001e# service=git-upload-pack\n0000` envelope may
precede the required v2 packets. Lowercase four-digit hex lengths, printable
ASCII payloads with one terminal LF, valid data lengths 5–65,520, and exactly
one terminal flush with no trailing bytes are required. Unexpected response
control packets, malformed lengths or truncation are STOP; there is no fallback.

The ls-refs response is empty or exactly one record with a nonzero 40-digit
lowercase SHA-1 and exact `refs/tags/macos-2662`, optionally with one
`peeled:<40-digit-nonzero-SHA1>` attribute. V2 carries peeling as that attribute,
not a second wire ref record. The result normalizes it to
`refs/tags/macos-2662^{}`. Other/duplicate records, names, attributes or hash
formats are STOP. No returned tag/commit/tree/gitlink/object is followed.

## B01: enforced envelope

The controller has two fixed slots checked before emission. It durably records
an intent before DNS/connect, conservatively consuming that slot even if no HTTP
bytes reach the server. One socket/address and one sendall are permitted per
slot; there is no address fallback or replay after partial failure. No generic
URL, third request, retry, redirect, auth replay, alternate origin or protocol
fallback path exists. GET and POST use separate verified TLS connections. The
pinned CA file validates github.com with minimum TLS 1.2.

Only HTTP/1.1 with unique Content-Length or strictly parsed chunked framing is
accepted. Duplicate/folded/conflicting headers, informational status, chunk
extensions/trailers, unsupported content encoding and unknown framing fail
closed. Accepted failure-body bytes count toward the same aggregate limit;
failure status never permits the POST. No decompression exists.

The ceiling is **1,048,576 accepted HTTP entity-body octets** across both
operations. Every body receive is bounded by the shared remaining budget. An
oversized declared body/chunk stops before acceptance. Unknown/inconsistent
framing stops. Exactly the ceiling is acceptable only with completed framing;
there is no extra sentinel body read. Headers and chunk framing have separate
65,536-byte caps per response; each retained file is capped at 1 MiB. This is
**not a cap on all server-sent, TLS/socket-buffered or wire bytes**. HTTP framing,
headers, DNS/TCP/TLS and unaccepted data are outside the body-byte measure.

One absolute monotonic 30-second deadline begins after the first time import,
before other imports, identity checks, marker/receipt creation, fork or network.
Startup exhaustion prevents emission. A supervisor enforces the same deadline
and kills the complete child process group/PID; the child also arms a matching
alarm and bounds socket operations. Blocking DNS is bounded by the supervisor.
No child can spawn processes. Bootstrap/filesystem delays before supervision
cannot emit network; durable terminal cleanup may continue after termination.
Missing/incomplete accounting, partial/truncated files or uncertain completion
are STOP. See controller-preparation.md for exact interruption/death behavior.

## B02: isolation and identity

No Git executable/library or repository discovery/configuration is used. There
is no config/URL rewrite mechanism to isolate. No empty descendant directory is
created or asserted as isolation. The pinned `env -i` invocation and `-I -S -B`
remove inherited environment/Python/site effects before interpreter startup;
the controller requires exactly LANG=C, LC_ALL=C and TZ=UTC. Direct sockets do
not read proxy settings, credential/cookie providers, Git config or tracing.
Offline AST import inspection confirms no subprocess/HTTP-client imports;
independent review must inspect the actual construction and call paths.

request.json pins the absolute executable, argv and externally supplied final
controller/runtime-lock SHA-256 arguments. The reviewer must independently
freeze those pins; the script does not approve its own mutable request packet.
Before emission it checks those hashes, Python flags/version, all dependency
bytes and exact OS release/kernel build. Runtime-lock pins Python 3.14.6,
stdlib/extension/framework/OpenSSL and CA bytes. Shared-cache system runtime
bytes are identified by OS build, not extracted/hashed or attested. Normal
filesystem/OS trust remains necessary; identity checks are not a hostile-kernel
attestation.

## Durable result boundary

The sole destination is
`Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/u01-dyld-cache-git-ref2-result/`.
Its exclusive mkdir and parent fsync create the permanent consumed session
marker. Exclusive fsynced launch.json precedes emission. Existing destination
means STOP. Never remove/replace/rename it, use another destination, resume,
repair or retry. Failure before a complete launch receipt still consumes the
created marker. Request bytes/intents, TLS endpoint/certificate metadata,
original status/headers, body and chunk framing, per-operation accounting and
partial files are retained. Empty stdout/stderr are explicit. Terminal records
include monotonic times, actual wait/exit/signal, sizes/SHA-256 and completeness.
Local receipts/hashes do not independently attest transport. There is no Git
trace. Missing/malformed receipts are STOP regardless of other apparent success.

Every result, including no exact match or successful advertisement, ends this
session. No match concerns this candidate at lookup time; it does not prove
absence of corresponding Apple source. Success identifies only an advertised
publication/content name. The missing chain stays: official 26.6.2/build 25G83
association → immutable distribution revision → dyld source revision → exact
schema and cache UUID f2e86c53-6052-388b-ba71-5a0c9b569413 applicability.
Header candidates/bytes stay 0/3 / 0. No source/header/Git-object acquisition,
schema/parser/cache/dyld research, extraction, compiler/build/test/runtime or
target operation follows.

Prior API GET remains 1/1 consumed. Three P08 markers stay each 1/1 consumed,
repairs/retries 0; five dirty files and exact cache membership/hash are preserved.
S and old B stay closed. U01/R01–R04, ordinary identity, standalone/cache
 equivalence, Error size/body/transitive costs, U02–U05, complete callee/safety,
strict cold/zero heap, four-profile ABI/resources, remaining SO criteria,
P08/R07/T8.1/conformance and I4-07/P09–P12 stay open. No architecture, contract,
scope, criterion, resource exception, lifecycle or repair allowance changed.
Actual contract/scope choices return to the parent for requested Astra Medium
review. No such choice was needed for this preparation.
