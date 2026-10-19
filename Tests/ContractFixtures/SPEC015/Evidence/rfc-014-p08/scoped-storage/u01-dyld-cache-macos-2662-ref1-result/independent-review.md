# Independent Strong review — exact dyld ref metadata result

Reviewed 2026-10-19 at **`b3ce1b56805a09d50a07cea8367c1adc5134c188`**.
**PASS for the bounded HTTP failure result and STOP.** No blocking factual,
contract or scope finding was identified. The manifest's stale “unexecuted”
navigation note is corrected in this review change.

Independent standard-library byte/hash/JSON/stat and read-only Git checks
confirm that all three result files equal the reviewed Git blobs. Raw headers
are **1,021 bytes**, SHA-256
**`d643282007c6eaacbc7190e8d5a59f7b990ffac8f9b69f1915cc2e6d754f4b21`**;
the body is **279 bytes**, SHA-256
**`16b605b4b536a18a4158a564f5f2f836d47da19bb8c3c5b201a226d528c20b15`**.
Headers retain CRLF and one status block, **HTTP/2 403**, Date 2026-10-19
15:56:00 GMT, `x-ratelimit-remaining: 0`, used/limit **60/60**, and
`content-length: 279`. The JSON contains only `message` and `documentation_url`;
the message reports API rate-limit exhaustion. It contains no `ref` or `object`.
No conclusion about tag existence, dyld revision or build association follows.

The trusted original launch observation records exactly the independently
reviewed URL
`https://api.github.com/repos/apple-oss-distributions/distribution-macOS/git/ref/tags/macos-2662`,
with `curl --proto '=https' --max-time 30 --max-filesize 1048576 --retry 0
--silent --show-error`, the pinned packet's `macos-2662-ref.headers` as
`--dump-header` destination and `macos-2662-ref.json` as `--output` destination.
There was one call from the repository root, no redirect-follow flag, retry,
page, alternate spelling or fallback. The tool reported exit **0**, empty
stdout/stderr and **0.000012875 seconds**; this is a tool observation, not a
separate raw timing/launch receipt or HTTP success. Curl lacks a fail-on-HTTP
flag, so exit 0 is compatible with this retained 403. The response is within
1 MiB, and the invocation imposed the reviewed 30-second ceiling. This review
did not replay the request or reconstruct network history from response bytes.

The five preexisting dirty-file hashes and exact one-file
`scripts/contracts/__pycache__/` membership/hash match the
[preservation baseline](../u01-dyld-cache-schema-source1-preparation/inspection.json).
The three marker device/inode identities remain
**[16777234,29640436] / [16777234,29650609] / [16777234,29652748]**,
each **1/1 consumed**, repairs **0**, retries **0**. No marker/cache mutation,
network request, returned-object/header/source read, cache-schema parser,
dyld tool/controller, target runtime/compiler/build/test, acquisition or repair
ran in this review.

**Next boundary:** the exact-ref one-GET allowance is consumed. Before another
metadata or source read, prepare a separate concrete evidence request naming
the exact official URL or immutable source/revision, the proposed chain to
26.6.2/25G83 and installed-cache applicability, precise operations/destinations,
byte/time/count bounds, provenance retention and failure stops. Independently
review that preparation before any read. This result/review authorizes no
automatic retry after a rate-limit reset, alternate route, returned-object
follow, source/header acquisition or parser/body/controller work.

Header candidates/bytes remain **0/3 / 0**. Exact source applicability and field
semantics, ordinary loaded identity, platform standalone/cache equivalence,
U01/R01–R04, Error size/body/transitive costs, U02–U05, complete callee/safety,
strict cold/zero heap, four-profile ABI/resources and P08/R07/T8.1/conformance
remain open; S and old B stay closed. SPEC-015 remains implementing under
accepted ADR-039/040 and the counter SRAM exception. No lifecycle, contract,
scope, resource or repair allowance changes; no actual contract/scope choice
arose. Any proposed relaxation goes upstream for the requested Astra Medium
decision. Documentation whitespace checks exclude only unchanged raw headers;
no maintained Swift changed and no formatter/repository test gate ran.
