# Independent controller readiness review — 2026-10-19

Reviewed controller preparation commits **`3af5a9f82e26b81cb7d12ec08372356d760ecf62`**
and **`a61bb9e37e223d98e0eabbb76b0696383cf78926`**, with the latter as the
exact final packet. **STOP / readiness NOT READY.** B02's repository discovery
defect is resolved by eliminating Git entirely. B01's request/body/deadline
mechanisms are concrete, but its explicit full-stream failure prerequisite has
been changed without a disposition. No controller launch or network request is
cleared by this review.

## B01 remainder: full retained stream does not stop before POST

The prior independent review at `0625592ae4d54cf0b4a9875a1d06cb3f65e220da`
requires: “Every retained stream is capped at 1 MiB; a full/truncated stream
fails.” The revised request instead says that exactly the ceiling may be
accepted with complete framing. There is no explicit authorization resolving
this difference in the reviewed preparation.

In [controller.py](controller.py), `take` at lines 250–258 accepts equality with
the remaining aggregate budget. Capability parsing at lines 124–140 and
`child` at lines 336–338 have no full-stream rejection before the POST. The
supervisor also permits retained stream size equal to CAP at lines 423–425.
A complete valid GET capability body of exactly 1,048,576 bytes can therefore
be retained and parsed, followed by POST emission. Its subsequent response
cannot produce a successful nonempty ref packet because the body budget is
exhausted, but that eventual STOP does not restore the required stop before
the second request.

This path follows directly from the parser grammar: required capabilities plus
unique unknown capability keys with printable values can fill an exact-cap
body. The code accepts unknown capability keys, bounds each packet separately,
and imposes no smaller capability-body bound. This finding was established by
source inspection, without constructing or executing a controller fixture.

**Exact next prerequisite:** reconcile this explicit prior B01 condition in a
revised frozen packet. Under the existing prerequisite, every full retained
stream must produce STOP before any dependent request, including a full GET
capability stream. Do not silently adopt the revised equality exception.
Any requested change to the condition needs an explicit disposition followed
by independent review. This review does not implement a correction or grant
an attempt, repair, retry or changed limit. The aggregate arithmetic itself
correctly enforces **accepted entity-body bytes <= 1,048,576**.

## Other enforcement findings

Source was read line by line, including startup, all response/failure paths and
supervisor cleanup. No additional execution blocker was identified within the
packet's stated normal filesystem/OS trust boundary.

- **Request budget and isolation:** the child invokes only exchange 1, then
  exchange 2 after successful capability parsing. Order and maximum two are
  checked before emission. Fixed HTTPS host and paths, fixed request bytes,
  one resolved address/connection and one sendall per slot provide no third
  request, retry, address fallback, redirect, auth replay or v0/v1 fallback.
  There is no Git executable, parent repository discovery, configuration,
  proxy, credential, cookie, prompt, subprocess or generic HTTP client path.
- **TLS:** a fresh client context requires certificate/hostname verification
  for github.com, loads the pinned CA file and sets minimum TLS 1.2. There is
  no TLS verification override or alternate hostname in request construction.
- **Protocol and exact refs:** the 96-byte POST's ASCII, hex and declared size
  agree. It requests only ls-refs, sha1, peel and the exact candidate prefix.
  Discovery requires v2, unique capabilities, ls-refs and explicit sha1.
  Packet lengths/control/trailing bytes and printable lines are checked.
  Empty or one exact ref record is accepted, with only an optional nonzero
  peeled SHA-1 attribute. Other names, duplicate records/attributes, all-zero
  or malformed IDs stop; no returned object is followed.
- **Body accounting:** both exchanges share the same remaining accepted-body
  budget, including HTTP failure bodies. Each body recv is bounded by it;
  oversize declared lengths/chunks stop before acceptance. There is no
  decompression or extra body sentinel read. HTTP headers/chunk framing have
  separate 65,536-byte caps. The measure excludes TLS/socket buffering,
  headers, framing and unaccepted wire bytes, as explicitly disclosed.
  Unknown/ambiguous framing and unsupported decoding fail closed. Status and
  media type must succeed before protocol parsing and dependent emission.
- **One-shot receipts:** exclusive fixed mkdir, parent fsync and exclusive
  fsynced launch.json precede DNS/connect/send. Per-request bytes/intents
  precede each connection. Existing destination is an error. The result
  directory remains the consumed marker even if bootstrap accounting fails.
- **Deadline and failure records:** the same monotonic deadline begins before
  remaining imports and identity checks. Supervisor timeout/interruption kills
  the child group and PID and records actual wait/exit status. The child has
  the matching alarm and socket remaining-time checks. DNS is supervised.
  Filesystem cleanup may outlast the network deadline; missing/partial child
  accounting is STOP. Exclusive bounded writers, capped raw streams, child
  RLIMIT_FSIZE/core suppression and closed inherited descriptors support
  retained partial files; terminal accounting hashes/sizes retained files.
  No process can be launched by the child source after the single fork.
- **Runtime pins:** both external request hashes match the exact files;
  all **2,165** pinned file hashes match current bytes. Exact stdlib source/
  extension/bytecode membership is **2,160 resolved paths**, with no additions
  or omissions. The absent zip path is absent. The resolved executable and
  request argv agree; clean environment and -I/-S/-B are explicitly checked.
  System cache libraries remain identified by exact OS build, as disclosed;
  the review makes no hostile-OS or independent transport attestation.

The enforcement prose's count of 2,159 stdlib files differs from the lock's
2,160 resolved members; five further pinned paths produce 2,165 total files.
This is a documentation count correction, not an independent launch blocker.

## Independent inspection and preservation

[Inspection evidence](controller-independent-review-inspection.json) records
AST parsing without importing/executing the controller; exact reviewed-blob
identity for every final preparation file; pins, runtime dependency bytes and
membership; retained API metadata hashes/sizes; five dirty-file hashes; exact
one-file scripts/contracts/__pycache__ membership/hash; three marker device/
inode identities; and absence of the fixed new result directory.

Prior API GET stays **1/1 consumed**, with retained 1,021-byte HTTP headers and
279-byte 403 rate-limit body. This is retained evidence and trusted prior
accounting, not a replay or a new network-history attestation. Three P08 markers
remain **[16777234,29640436] / [16777234,29650609] /
[16777234,29652748]**, each 1/1 consumed, repairs/retries zero. All five dirty
files and the sole existing cache bytecode file match the prior baseline.
The Git-ref2 session remains unlaunched; header candidates/bytes remain 0/3 / 0.

Only read-only Git navigation and standard-library static byte/hash/JSON/stat/
AST inspection ran. No controller import/execution, network, target/compiler/
build/test, source/header/Git-object acquisition, cache-schema parser, dyld tool,
repair or retry ran. The review modifies only this record/evidence and minimal
navigation; it preserves the controller, request, lock and original review.

This remains post-MVP ITERATION-003 revision 5 I3-04/I3-05 evidence under accepted
ADR-039/040 and implementing SPEC-015. Closed ITERATION-001 analyzer/four-stack
obligations are preserved. Candidate existence, exact 26.6.2/build 25G83 release
association, distribution/dyld revision and installed-cache applicability remain
unproved. S/old B stay closed; U01/R01–R04, ordinary identity, Error costs,
U02–U05, complete callee/safety, strict cold/zero heap, four-profile resources,
remaining SO criteria, P08/R07/T8.1/conformance and I4-07/P09–P12 remain open.
No architecture, contract, scope, resource, lifecycle or repair allowance changes.
The B01 remainder is a current readiness prerequisite, not deferred work; no
optional out-of-scope idea arose.
