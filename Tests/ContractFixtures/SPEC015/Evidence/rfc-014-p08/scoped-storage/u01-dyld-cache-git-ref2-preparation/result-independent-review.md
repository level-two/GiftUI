# Independent exact Git ref route 2 result review — 2026-10-19

Reviewed exact **`c081a421d404f26bc9345607384d3c4fb18c0abf`** against the
frozen request and [startup readiness review](startup-environment-independent-review.md),
including its prior B01/B02 correction reviews. **PASS for the bounded retained
result, integrity/accounting and interpretation; STOP for further P08 activity.**
No result-review defect or credential exposure was found. This is independent
offline inspection of retained local evidence under the reviewed normal
filesystem/OS trust boundary; it is not an independent transport, process-history
or hostile-OS attestation.

## Independently checked result

[Inspection evidence](result-independent-review-inspection.json) records fresh
byte reads, SHA-256, stat metadata and immutable committed-blob comparisons for
all **20 files / 7,582 bytes** in the fixed raw directory. Exact membership,
regular single-link files, directory identity, file device/inode, mode and
mtime/ctime match the packaging record. All **19** terminal-covered sizes/hashes
match; terminal.json itself is separately hashed and matches its committed blob.
The independent manifest format is documented in the inspection; its SHA-256 is
`3b9add5645d84bcfb889f92ac4918a9f92ee369618671c1cd5cdfac38304fdf4`.
It uses its own explicit serialization and does not replace the packaging manifest.

The exact 271-byte GET and 416-byte POST were reconstructed independently from
the frozen origin, paths, headers and 96-byte body, and match the original raw
bytes and intent hashes. Both target only
`github.com/apple-oss-distributions/distribution-macOS.git` with protocol v2,
identity encoding and connection close. The POST packets are command=ls-refs,
object-format=sha1, delimiter, peel, ref-prefix refs/tags/macos-2662, terminal
flush. No fetch/want/have, object ID, broad prefix or follow request is present.

Both responses are HTTP/1.1 **200 OK** with the expected exact Git media type,
unique headers, chunked framing, no content encoding or Content-Length conflict,
and no redirect/authentication/cookie header. Independent packet parsing finds
the exact service envelope, protocol v2, ls-refs and explicit SHA-1 capability;
capabilities.json agrees with the body. The GET body is **191 bytes** and its
framing is exactly `BF\r\n\r\n0\r\n\r\n`. The POST body is **four bytes exactly
`0000`**, one complete Git flush with no ref, object ID, peeled attribute or
trailing bytes; its framing is `4\r\n\r\n0\r\n\r\n`.

Both local TLS receipts agree on TLSv1.3 / TLS_AES_128_GCM_SHA256,
140.82.121.3:443 and certificate SHA-256
`46b601ee08b418cf8a3a1ebfe670ba5ce43bb05a917fa8b2dd087a30471cfc63`.
Static source inspection confirms the pinned controller requires certificate
and hostname verification for github.com using its pinned CA; it does not
accept arbitrary origins or disable verification. The receipts alone do not
independently prove certificate hostname validation or server identity.
Both original response Date headers retain **19 Oct 2026 18:09:55 GMT**.

Launch controller/runtime-lock hashes match the external readiness pins and
current committed bytes:
`9125e13998120ae2f15d71948110b5141c0915e7939955595c6f41076057a374` /
`4e357ba8bc5ff1c41135ef25afeb76a03265577455dbf8390945c70caa72f33a`.
The launch argv and exact four-entry startup environment match the frozen packet.
The consumed launch precedes ordered intent 1, intent 2, child completion and
terminal completion; the deadline is exactly start + 30 seconds. Terminal elapsed
time is **0.879023583 seconds**. Actual child exit/wait status is **0/0**, with
no timeout, full retained stream or missing accounting. Child and terminal
OBSERVED dispositions agree, both stdout/stderr are empty, and every per-response
accounting field matches independently parsed lengths/status/framing.

Accepted entity-body accounting is **191 + 4 = 195 / 1,048,576 bytes** across
**2/2** request slots. Headers total 1,051 bytes and framing 21 bytes, below each
separate per-response 65,536-byte cap; every retained file is below 1 MiB.
No total wire-byte cap is claimed. Source and receipt inspection evidence no
retry, redirect, fallback, auth replay, repair or third operation. The permanent
fixed session directory stays **1/1 consumed**. The earlier failed pre-marker
attempt at `9542d659` remains failed and grants no reset or retry.

All raw content was read, including exact request/response/framing bytes and
launch/TLS/terminal JSON. No credentials, authorization/cookie material, private
keys or other secrets were observed; independent credential-pattern scans have
zero hits. Public endpoint/certificate/request identifiers and local paths are
preserved in the original evidence.

## Preservation and remaining blockers

Fresh hashes confirm all five pre-existing dirty files and the exact sole
scripts/contracts/__pycache__ member match the original baseline. The four
retained API/tag metadata files match baseline sizes/hashes; prior API GET stays
**1/1 consumed**. Three permanent P08 marker device/inode pairs remain
**[16777234,29640436] / [16777234,29650609] / [16777234,29652748]**, each
**1/1 consumed**. Repairs/retries remain **0/0**; header candidates/bytes remain
**0/3 / 0**. No raw result, marker, dirty file, cache or historical receipt was
modified by this review.

The only lookup conclusion is **no exact refs/tags/macos-2662 advertised at the
retained lookup time**. An empty advertisement does not establish an absent
release or source. Official 26.6.2/build 25G83 association, immutable distribution
revision, dyld revision, loaded-image identity, standalone/cache equivalence and
exact schema applicability to cache UUID f2e86c53-6052-388b-ba71-5a0c9b569413
remain unproved. There is no returned object to follow.

The unresolved P08 blockers remain:

- **U01/R01:** actual selected cold Error metadata runtime body, transitive
  callees, initialization/allocation/ownership and nested stack costs.
- **U01/R02:** applicable populated Error metadata/value-witness layout or exact
  version-matched ABI evidence bounding the unconditional aligned temporary
  reservation. The selected conditional error transfer remains excluded; that
  exclusion does not bound the reservation.
- **U01/R03:** exact linked and ordinary loaded provider identities joining
  caller/generic/decoder bodies and Error metadata provider; standalone/cache
  equivalence and applicable cache-field semantics remain missing.
- **U01/R04:** actual selected memcpy/resolver and canary/guard/failure target
  implementation/cost and safety disposition.
- **U02–U05:** remaining ordinary ABI/metadata/witness closure, callback and
  unsafe ownership/lifetime/quiescence proof, exact observer/transcript cost
  attribution, complete safety matrix and current four-profile ABI/resources.
- Complete callee/safety, strict cold/zero heap, remaining IN-SO/RP-SO/HC-SO
  criteria, P08/R07/T8.1/conformance and downstream I4-07/P09–P12 acceptance.

**STOP.** Any further evidence needs a separately prepared bounded packet and
its required review/authorization. No automatic search, alternate route,
source/header/object read, cache/schema/parser research, controller launch,
compiler/build/test/target operation, retry or allowance reset follows.

This is post-MVP ITERATION-003 revision 5 I3-04/I3-05 evidence under accepted
ADR-039/040 and implementing SPEC-015, preserving closed ITERATION-001 analyzer
and four-stack obligations. The plan stays active; P08 stays open. S and old B
stay closed. No architecture, contract, scope, criterion, exception, lifecycle
or historical budget changed, and no optional deferred-work item arose.

Review execution was limited to offline standard-library byte/hash/stat/JSON/
protocol inspection, static controller source reads, read-only Git inspection
and review/navigation writes. No controller import/execution, network,
source/header/object acquisition, cache/dyld tool, compiler, build, test or target
operation ran. Documentation diff whitespace checks pass; protocol CRLF in raw
files is preserved exactly.
