# U01 exact dyld ref metadata result — 2026-10-19

**STOP: HTTP 403 rate limit.** The single independently reviewed HTTPS GET to
`https://api.github.com/repos/apple-oss-distributions/distribution-macOS/git/ref/tags/macos-2662`
ran with `--max-time 30 --max-filesize 1048576 --retry 0`, no redirects or
pagination. Curl exited 0 because HTTP failure was not converted to a process
failure. The raw [headers](macos-2662-ref.headers) report HTTP/2 403 and
`x-ratelimit-remaining: 0`; the raw [body](macos-2662-ref.json) reports the
public GitHub API rate limit. No ref object or release/build association was
returned. This does not establish whether the tag exists.

[Independent Strong review](independent-review.md) passes the bounded failure
result and STOP; no retry or alternate read is cleared.

| Raw file | Bytes | SHA-256 |
| --- | ---: | --- |
| `macos-2662-ref.headers` | 1,021 | `d643282007c6eaacbc7190e8d5a59f7b990ffac8f9b69f1915cc2e6d754f4b21` |
| `macos-2662-ref.json` | 279 | `16b605b4b536a18a4158a564f5f2f836d47da19bb8c3c5b201a226d528c20b15` |

The one-GET allowance is consumed. No retry, alternate spelling, second page,
source/header read, cache parser, dyld inspection, runtime, compiler, build,
test, acquisition or repair followed. The prior three one-shot P08 collection
markers and their zero-repair/zero-retry accounting remain unchanged. Exact
26.6.2/25G83-to-dyld revision, cache-field semantics and applicability remain
unproved; U01/R01–R04, strict cold and P08/R07/T8.1 remain open. A separately
bounded and reviewed evidence route is required before further metadata reads.
