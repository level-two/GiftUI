# U01 official dyld schema-source lookup bounds

Baseline: independent three-header absence review `2e30b95adc855546cd4547a739727c9d37cf5b76`.
This is source/provenance preparation only. The current retained candidate is
macOS 26.6.2 build 25G83, shared-cache UUID
`f2e86c53-6052-388b-ba71-5a0c9b569413`; applicability is not assumed.

## Lookup declaration

Official metadata already opened, in sequence, without source/header reads:

1. `https://opensource.apple.com/releases/` — text rendering exposes a release
   picker and no release records. This rendering is not absence proof.
2. `https://github.com/apple-oss-distributions/distribution-macOS` — Apple-owned
   distribution repository; its moving main page names a dyld submodule.
3. `https://github.com/apple-oss-distributions/distribution-macOS/tags` — first
   rendered page names `macos-265` first; web metadata says crawled last month,
   so this is insufficient for a current absence claim.

Predeclared final metadata read:
`https://api.github.com/repos/apple-oss-distributions/distribution-macOS/tags?per_page=100`.
One HTTPS GET, one page only, no pagination, retries, ref probes, search, clone,
archive or recursive tree. Ceiling: 1 MiB response, 30 seconds for this GET.
Retain response bytes/headers and SHA-256 as provenance, including failure.
Inspect only tag names/commit identities. A matching version/build tag may name
a candidate distribution revision; it does not by itself prove cache UUID
applicability. A failure or no matching release/build mapping stops this lookup.

Header candidate declaration: **zero exact header paths/revisions selected**.
Maximum is three, but a version/build-to-dyld revision link must exist before
any exact header candidate is selected. Do not read `main`, `macos-265` or its
dyld revision as a substitute. No header bytes/field offsets are authorized by
this metadata read. There is no automatic second metadata plan.

## Stops and later handoff

If the final metadata read cannot establish the matching release/build source
revision, record the missing proof and STOP. A future request must name an
immutable Apple source revision linked to 26.6.2/25G83, at most three exact
header paths/revisions, raw size/hash provenance and cache-applicability proof.
It must be independently reviewed before any header/schema operation is
proposed. Do not infer field semantics from UUID bytes at 0x58 or reuse an
unrelated header for offsets.

No parser/controller/decoder/dyld tool, runtime/compiler/build/test, binary
acquisition/cache extraction, production repair or retry is permitted. S and
old B remain closed. Three consumed markers remain 1/1, repairs 0, retries 0;
five dirty files and the existing cache are preserved. R01–R04, ordinary loaded
identity, strict cold, U02–U05 and P08/R07/T8.1 stay open. Any actual warm-up,
heap/ownership/privacy/bound/scope choice goes upstream for Astra Medium.
