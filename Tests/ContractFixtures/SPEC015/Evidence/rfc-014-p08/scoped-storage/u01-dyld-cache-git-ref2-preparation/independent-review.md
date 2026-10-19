# Independent Strong review — exact Git ref route preparation 2

Reviewed 2026-10-19 at **`8250f8ece37bc2ebc458c13cdb31251d4dbad646`**.
**STOP / readiness NOT READY.** The proposed provenance question and preserved
stop boundary are sound. The declared Git argv is not an executable bounded
envelope. B01 and B02 below must be resolved in a revised preparation and
independently reviewed before any network operation. This review clears no
request, controller launch, object follow or source/header read.

## Findings and exact next prerequisite

**B01 — request and byte limits have no enforcing controller.** As the packet
correctly discloses, `http.maxRequests=1` limits concurrency; it cannot enforce
two total logical HTTP requests or 1,048,576 aggregate response-body bytes.
Protocol-v2 preference, output patterns and retained trace sizes cannot prove
those limits. Git may negotiate or receive data before an observer detects a
violation. A supervisor timeout alone provides no request/byte enforcement.
The 30-second process-group supervisor and capped receipt writers are also
requirements here, not implemented or reviewed facilities.

The exact missing prerequisite is a **frozen, separately reviewed launcher and
network controller** with the following properties. Merely wrapping the pinned
Git process and inspecting its completed trace is insufficient.

- It permits only the declared GET capability discovery and, only after a
  valid protocol-v2 response, one declared POST `ls-refs` operation to the same
  HTTPS origin/path pair. It checks the operation budget before emission and
  prevents every third request, retry, authentication replay, redirect and
  protocol-v0/v1 fallback. No fetch/pack/object command is possible.
- It specifies and enforces what the aggregate **HTTP response-body byte**
  ceiling counts, including failure bodies and any content decoding. The
  response reader has a shared remaining budget and stops without accepting
  data beyond it; unknown/inconsistent framing or inability to enforce the
  bound fails closed. Headers, TLS/HTTP framing, trace formatting and retained
  stream bytes are separately accounted. Do not claim a body-read ceiling
  limits all server-sent or transport-buffered wire bytes. If that stronger
  meaning is required, resolve it explicitly before readiness.
- Its actual request construction or mediation establishes the allowed
  `ls-refs` ref-prefix and `peel` behavior. The current `--tags`/pattern argv
  does not by itself establish a narrow wire advertisement. Record the frozen
  request and how unexpected similarly prefixed records stop. No returned tag
  or commit object may be read.
- It pins executable/dependency identity, exact environment and actual argv,
  validates TLS for `github.com`, and prevents inherited proxies, credentials,
  cookies, URL rewrites, tracing and prompts. It supplies original request/
  status/protocol and response accounting from the enforcing component;
  pretty-printed Git traces and hashes alone are not transport attestations.
- Before first emission it records a durable one-session launch receipt in the
  exclusively created declared result destination. An interrupted/failed
  attempt remains consumed; no new destination, resume or automatic retry
  evades that receipt. It enforces one monotonic 30-second deadline, terminating
  the complete process group on stop, with actual exit/signal and partial files.
  Every retained stream is capped at 1 MiB; a full/truncated stream fails.
  Record sizes/SHA-256 and accounting completeness even on failure.

These are missing prerequisites, not approval to implement or execute a new
controller in this review. Revise the bounded preparation with one concrete
implementation and its offline reviewable enforcement evidence. Preserve the
same request/byte/time ceilings and no-follow boundary. Any relaxation of
heap/ownership/privacy/bounds/scope or other actual contract choice goes to the
parent for the requested **Astra Medium** decision; this review makes none.

**B02 — an empty descendant directory does not isolate repository config.**
`RESULT/empty-git-context/` is beneath GiftUI's working tree. Git searches parent
directories and can load GiftUI's `.git/config`; `-C` alone does not prevent
`url.*.insteadOf`, repository proxy or other local configuration from affecting
the request. The packet's stated reason for this directory is therefore false.
An independent read-only `git -C <this-packet> rev-parse --show-toplevel` returned
`/Users/eugene/work/GiftUI`, demonstrating parent discovery from the same
descendant hierarchy without creating a result directory or running transport.
The revised launcher must explicitly prevent parent repository discovery and
all local/worktree/global/system configuration effects, or use the reviewed
controller without Git repository discovery. Pin the mechanism and an offline
isolation check; an empty directory, clean environment and disabled global/
system config alone do not establish isolation. No local config values were
printed or network endpoints contacted by this review.

## Verified provenance and interpretation

The exact proposed remote is
`https://github.com/apple-oss-distributions/distribution-macOS.git`. Retained API
records from that Apple distribution repository support the repository identity.
The only candidate names remain **`refs/tags/macos-2662`** and its possible
peeled advertisement **`refs/tags/macos-2662^{}`**. The spelling is inferred;
neither retained record establishes its existence or its release meaning. A
GitHub TLS endpoint and advertised object ID would identify a publication and
content name, not authenticate Apple's build process or an installed cache.
Malformed/duplicate/inconsistent records, unexpected hash format or other refs
remain STOP. Exit 2/no match is limited to this candidate at the lookup time.

The prior exact API GET remains **1/1 consumed**, with retained HTTP/2 403 and
279-byte rate-limit body; there is no ref/object result. Waiting for reset or
replaying it is not permitted. This proposed Git session is separately prepared
and **unlaunched: 0 sessions / 0 requests** observed in the preparation/review.
Its two HTTP operations are a proposed ceiling, not two newly granted retries.
The earlier independent review and trusted retained launch observation establish
the historical API accounting; this offline review does not replay network
history or infer it solely from response bytes.

Even a valid exact ref advertisement leaves this chain missing: official exact
**26.6.2 / build 25G83** association → immutable distribution revision → dyld
source revision → exact source schema and installed-cache applicability to
UUID **`f2e86c53-6052-388b-ba71-5a0c9b569413`**. No returned object or source may
be followed automatically. A schema also cannot repair ordinary-counter
historical loaded identity, different-process evidence limits or platform
standalone/cache equivalence. Header candidates remain **0/3**, bytes **0**;
no offset/guard interpretation or schema qualification follows.

## Inspection, authority and preservation

[Independent inspection](independent-review-inspection.json) verifies all four
preparation files equal the reviewed Git blobs and independently verifies the
four retained HTTP metadata files' sizes/SHA-256 against the preparation.
All five preexisting dirty-file hashes and exact one-file
`scripts/contracts/__pycache__/` membership/hash match. Marker device/inode
identities remain **[16777234,29640436] / [16777234,29650609] /
[16777234,29652748]**, each **1/1 consumed**, repairs **0**, retries **0**.
No cache or marker was modified. Inspection used standard-library byte/hash/
JSON/stat checks and read-only Git navigation; no network, Git transport,
returned-object/source/header read, cache-schema parser, dyld tool/controller,
target runtime/compiler/build/test, acquisition, repair or retry ran.

This remains post-MVP **ITERATION-003 revision 5 I3-04/I3-05** finite P08
safety/fit evidence under accepted **ADR-039/040** and implementing **SPEC-015**.
Closed ITERATION-001 analyzer/four-stack obligations remain preserved; iteration
inclusion does not waive feature gates. S and old B stay closed. U01/R01–R04,
ordinary loaded identity, standalone/cache equivalence, Error size/body/
transitive costs, U02–U05, complete callee/safety, strict cold/zero heap,
four-profile ABI/resources, all remaining SO criteria, P08/R07/T8.1/conformance
and mandatory I4-07/P09–P12 obligations remain open. No architecture, contract,
scope, criterion, resource exception, lifecycle or repair allowance changes.
The controller and config defects block current readiness and are not deferred
work. No new out-of-scope idea or actual contract/scope decision arose.

This commit adds the review/inspection and minimal navigation to the reviewed
STOP. Documentation whitespace verification applies; no maintained Swift was
edited and no formatter or repository test gate is appropriate to this review.
