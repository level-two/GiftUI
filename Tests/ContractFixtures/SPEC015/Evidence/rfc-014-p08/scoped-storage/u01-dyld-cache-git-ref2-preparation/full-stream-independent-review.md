# Independent B01 correction re-review — 2026-10-19

Reviewed exact commit **`e9c7a059beccf6bb08ebd126643191d853b5647c`** against
the prerequisites in `0625592a` and remaining finding in `49228097`.
**GO / independent readiness PASS for the exact fixed one-session invocation.**
B01 and B02 are resolved within the packet's accepted-body-byte and normal
filesystem/OS trust boundary. No further readiness blocker was found. This is
an offline preparation decision; no session or HTTP request was launched.

## Exact reviewed pins and correction

The independently frozen external arguments are:

- Controller SHA-256: `50e71a68c2338711bab014489bc4aa039c0e6f93994fd40dc74471093df3b752`.
- Runtime-lock SHA-256: `aec1718d0aa2b1574a7aa30010743dcad8fc2982c2bdac2b738c7539219c99fa`.

These match both exact files and request.json's clean absolute invocation.
No revised source, different runtime, alternate result destination or changed
argument is covered by this readiness decision.

`save` rejects equality before creating a metadata/request file. In `take`, each
received body chunk is retained and fsynced, added to local and aggregate byte
counters, then checked with `len(body) < CAP`. An exactly full GET body raises
within exchange 1, before its return into capabilities and before exchange 2.
This holds for Content-Length and chunked responses, including error bodies.
Partial accounting records accepted bytes. Supervisor terminal accounting
retains full-file names/sizes/hashes and requires no full files for success.
The prior full-stream STOP requirement is restored. Aggregate equality across
two complete individual body streams below CAP stays within the unchanged cap.

## Remaining envelope and independent evidence

The full controller source and correction diff were re-read. The prior review's
other findings remain valid: fixed ordered GET then optional exact-prefix
ls-refs/peel POST, maximum two logical requests, shared accepted response entity
body <=1,048,576 bytes including failures, no decoding, bounded framing/headers,
strict v2 and exact-ref parsing, verified github.com TLS, no retry/redirect/auth
replay/proxy/config/cookie/credential inheritance, and no object follow.
Exclusive fixed result mkdir and durable launch/request-intent receipts precede
emission; the same monotonic 30-second deadline supervises the child group and
blocking DNS. Missing/incomplete/truncated accounting is STOP, with partial
streams and actual wait/exit status retained. B02 stays resolved by direct sockets
without Git/discovery. No wire-byte cap or independent transport/hostile-OS
attestation is claimed.

[Independent inspection](full-stream-independent-review-inspection.json)
records AST parsing without controller import/execution, exact final Git-blob
checks, equality-guard/accounting-order inspection, unchanged historical reviews,
both pins/argv, all **2,165** runtime file hashes, exact **2,160** resolved stdlib
members, absent import archive, exact OS build, and agreement of the 96-byte POST
ASCII/hex/size. All checks match. No controller behavioral or transport test was
performed or represented as evidence.

All five dirty-file hashes and the exact sole cache file membership/hash match
the baseline. Marker device/inode pairs remain **[16777234,29640436] /
[16777234,29650609] / [16777234,29652748]**, each **1/1 consumed**, repairs/retries
zero. Retained metadata sizes/hashes match, including prior API GET's 1,021-byte
headers and 279-byte HTTP 403 rate-limit body; its **1/1** allowance stays
consumed. The fixed new result directory is absent. Git-ref2 remains unlaunched;
header candidates/bytes remain **0/3 / 0**. Retained records preserve prior
accounting; they do not replay or attest network history anew.

Only offline source/AST/byte/hash/JSON/stat and read-only Git inspection ran.
No controller import/execution, network, compiler/build/test/target operation,
source/header/Git-object acquisition, dyld tool, repair or retry occurred.
No controller/request/lock or historical review was edited by this re-review.

Readiness covers only the prepared metadata session and terminal result boundary.
It adds no automatic retry, successor, object/source/header read or P08
continuation. Candidate existence, 26.6.2/build 25G83 association,
distribution/dyld revision and cache applicability remain unknown. This stays
post-MVP ITERATION-003 revision 5 I3-04/I3-05 under accepted ADR-039/040 and
implementing SPEC-015; closed ITERATION-001 obligations are preserved. S/old B
remain closed; U01/R01–R04, full callee/safety, strict cold/zero heap, remaining
SO/resource/conformance criteria, P08/R07/T8.1 and I4-07/P09–P12 remain open.
No contract, architecture, scope, lifecycle or repair allowance changes, and no
optional deferred-work item arose.
