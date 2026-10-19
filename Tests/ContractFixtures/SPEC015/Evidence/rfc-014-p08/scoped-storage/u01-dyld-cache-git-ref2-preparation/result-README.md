# U01 exact Git ref route 2 result — 2026-10-19

**Independent result review: PASS / further P08 activity STOP.**
The [exact c081a421 review](result-independent-review.md) independently verifies
all 20 raw files, 19 terminal hashes/sizes, exact requests/protocol/framing,
195 accepted body bytes, actual exit 0 and preserved state. Only no exact
refs/tags/macos-2662 advertised at lookup time is established. Session/API 1/1,
requests 2/2, repairs/retries 0 and all P08 gates remain unchanged; no automatic
follow/retry. Earlier packaging/preparation checkpoints below are historical.

**STOP / bounded observation recorded; independent result review pending.**
The separately authorized one-shot session completed with terminal `OBSERVED`,
actual child exit/wait status **0/0**, two HTTP **200** responses and complete
retained accounting. The only ref observation is **no exact
`refs/tags/macos-2662` advertised at lookup time**. The fixed
[result directory](../u01-dyld-cache-git-ref2-result/) is permanently consumed
**1/1** and remains unchanged. This note and
[result inspection](result-inspection.json) are separate packaging records in
preparation; they are not an independent result review.

## Retained result and inspection

All **20 files / 7,582 bytes** were read and SHA-256/stat inventoried offline.
The terminal's 19-file size/hash map matches every covered raw file; the
terminal itself is separately hashed. Exact name membership, regular single-link
files, directory/file device/inode and modification metadata are recorded in the
inspection. Raw size/hash manifest SHA-256:
`d7f8575435ec69ebb80abfa3feea14acff19ca29ba35bfd91a3d72dc799fe6c5`.
No result file or directory was edited, removed, replaced or relaunched.

- [Launch](../u01-dyld-cache-git-ref2-result/launch.json) records permanent
  consumption before emission, the frozen controller/runtime-lock pins and the
  exact four-entry startup environment. Its pins match the
  [independent readiness review](startup-environment-independent-review.md).
- [GET request](../u01-dyld-cache-git-ref2-result/1-request.http) is exactly the
  prepared 271-byte capability request. Its HTTP 200 response has 529 header
  bytes, 191 entity-body bytes and 11 chunk-framing bytes. Offline pkt-line
  parsing confirms service discovery, Git protocol v2, ls-refs and SHA-1 support;
  the capability JSON matches the retained body.
- [POST request](../u01-dyld-cache-git-ref2-result/2-request.http) is exactly
  416 bytes with the frozen 96-byte `ls-refs`, SHA-1, peel and
  `ref-prefix refs/tags/macos-2662` body. Its HTTP 200 response has 522 header
  bytes, **4 body bytes exactly `0000`**, and 10 chunk-framing bytes. The body
  is only a complete Git flush packet, with no advertised ref or object ID.
- Both retained TLS receipts report **TLSv1.3 / TLS_AES_128_GCM_SHA256**,
  peer `140.82.121.3:443`, and certificate SHA-256
  `46b601ee08b418cf8a3a1ebfe670ba5ce43bb05a917fa8b2dd087a30471cfc63`.
  The reviewed controller requires verified github.com TLS; these are retained
  local receipts, not independent transport or hostile-OS attestation.
- [Child result](../u01-dyld-cache-git-ref2-result/child-result.json) reports
  two intents, complete accounting, `refs: []` and `no exact candidate advertised`.
  [Terminal](../u01-dyld-cache-git-ref2-result/terminal.json) confirms exit 0,
  no timeout, no full retained stream and no missing accounting. Both stdout and
  stderr are empty. Both responses retain Date **19 Oct 2026 18:09:55 GMT**.

The observed monotonic interval is **0.879023583 seconds**, within the one
30-second deadline. Exactly two ordered intents and complete request/response
pairs fill the two-request ceiling. Accepted HTTP entity bodies total
**191 + 4 = 195 / 1,048,576 bytes**; all retained files are below the 1 MiB
per-file threshold. Headers total 1,051 bytes and framing 21 bytes, each response
below its separate 65,536-byte ceiling. Header/framing/TLS/TCP/DNS and any
unaccepted server-sent data are outside the accepted-body budget; no total
wire-byte cap is claimed. No retry, redirect, fallback, auth replay or repair
is evidenced. Automatic repairs/retries remain **0/0**.

All raw bytes were inspected for secrets, including both exact requests,
headers/bodies/framing, TLS, launch/terminal and stdout/stderr. No credentials,
authorization/cookie headers, private keys or other secrets were observed;
credential-pattern checks have zero hits. Public network/certificate/request
identifiers and local paths remain in the original receipts.

## Interpretation and next boundary

This metadata response establishes only that the exact inferred candidate
`refs/tags/macos-2662` was not advertised by this lookup at the retained time.
It does **not** establish an absent release or absent source, nor official
26.6.2/25G83 association, distribution/dyld revision, loaded-image identity,
standalone/cache equivalence or cache-field applicability. There is no returned
object to follow. Header candidates/bytes remain **0/3 / 0**.

**STOP for separate independent result review, then a separately prepared,
bounded next-evidence packet if further evidence is requested.** No automatic
ref search, alternate route, source/header/Git-object read, cache/schema/parser
research, controller/compiler/build/test/target operation or retry follows.
The earlier failed pre-marker attempt at `9542d659` remains failed; this consumed
session does not erase it or reset any allowance. Prior API GET stays **1/1**;
new Git metadata session stays **1/1**, requests **2/2**, repairs/retries **0**.

The five pre-existing dirty files and exact sole cache membership/hash match
baseline. The three P08 markers retain device/inode identities
`[16777234,29640436]`, `[16777234,29650609]`, `[16777234,29652748]`, each **1/1**
consumed. Their preservation evidence is in the inspection; none was modified.

This remains post-MVP ITERATION-003 revision 5 I3-04/I3-05 evidence under accepted
ADR-039/040 and implementing SPEC-015, preserving closed ITERATION-001 analyzer
and four-stack obligations. S and old B stay closed. U01/R01–R04, ordinary loaded
identity, standalone/cache equivalence, Error size/body/transitive costs,
U02–U05, complete callee/safety, strict cold/zero heap, four-profile ABI/resources,
remaining SO criteria, P08/R07/T8.1/conformance and I4-07/P09–P12 remain open.
No architecture, contract, scope, criterion, exception, lifecycle or historical
budget changed. No new optional deferred-work item arose.

Only offline reads, hashes, metadata/byte/protocol consistency checks and
packaging/navigation edits ran in this step. Documentation diff whitespace checks
pass. The raw HTTP requests, headers and chunk-framing receipts intentionally
retain protocol CRLF/terminal blank lines reported by Git whitespace checking;
these bytes are preserved exactly. No controller import/execution,
network acquisition, compiler, build, test or target operation ran.
